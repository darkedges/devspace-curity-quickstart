-- Drop together, as they are referencing each other through Foreign Key
DROP TABLE IF EXISTS tokens, delegations;

--
--  Delegations
--

CREATE TABLE delegations (
  id                          VARCHAR(40)  NOT NULL    COMMENT 'Unique identifier',
  owner                       VARCHAR(128) NOT NULL    COMMENT 'Subject for whom the delegation is issued',
  created                     BIGINT       NOT NULL    COMMENT 'Moment when delegations record is created, as measured in number of seconds since epoch',
  expires                     BIGINT       NOT NULL    COMMENT 'Moment when delegation expires, as measured in number of seconds since epoch',
  scope                       VARCHAR(1000)NULL        COMMENT 'Space delimited list of scope values',
  scope_claims                TEXT         NULL        COMMENT 'JSON with the scope-claims configuration at the time of delegation issuance',
  client_id                   VARCHAR(128) NOT NULL    COMMENT 'Reference to a client; non-enforced',
  redirect_uri                VARCHAR(512) NULL        COMMENT 'Optional value for the redirect_uri parameter, when provided in a request for delegation',
  status                      VARCHAR(16)  NOT NULL    COMMENT 'Status of the delegation instance, from {"issued", "revoked"}',
  claims                      TEXT         NULL        COMMENT 'Optional JSON-blob that contains a list of claims that are part of the delegation',
  authentication_attributes   TEXT         NULL        COMMENT 'The JSON-serialized AuthenticationAttributes established for this delegation',
  authorization_code_hash     VARCHAR(89)  NULL        COMMENT 'A hash of the authorization code that was provided when this delegation was issued.',
  PRIMARY KEY (`id`),
  KEY `IDX_AUTHORIZATION_CLIENT_ID` (`client_id`),
  KEY `IDX_AUTHORIZATION_STATUS` (`status`),
  KEY `IDX_AUTHORIZATION_EXPIRES` (`expires`),
  KEY `IDX_AUTHORIZATION_OWNER` (`owner`),
  KEY `IDX_AUTHORIZATION_AUTHORIZATION_CODE_HASH` (`authorization_code_hash`)
);

--
--  Tokens
--

CREATE TABLE tokens (
  token_hash     VARCHAR(89)   NOT NULL    COMMENT 'Base64 encoded sha-512 hash of the token value.',
  id             VARCHAR(64)   NULL        COMMENT 'Identifier of the token, when it exists, this can be the value from the "jti"-claim of a JWT, etc. Opaque tokens do not have an id.',
  delegations_id VARCHAR(40)   NOT NULL    COMMENT 'Reference to the delegation instance that underlies the token',
  purpose        VARCHAR(32)   NOT NULL    COMMENT 'Purpose of the token, i.e. "nonce", "accesstoken", "refreshtoken", "custom", etc.',
  `usage`        VARCHAR(8)    NOT NULL    COMMENT 'Indication whether the token is a bearer or proof token, from {"bearer", "proof"}',
  format         VARCHAR(32)   NOT NULL    COMMENT 'The format of the token, i.e. "opaque", "jwt", etc.',
  created        BIGINT        NOT NULL    COMMENT 'Moment when token record is created, as measured in number of seconds since epoch',
  expires        BIGINT        NOT NULL    COMMENT 'Moment when token expires, as measured in number of seconds since epoch',
  scope          VARCHAR(1000) NULL        COMMENT 'Space delimited list of scope values',
  scope_claims   TEXT          NULL        COMMENT 'Space delimited list of scope-claims values',
  status         VARCHAR(16)   NOT NULL    COMMENT 'Status of the token from {"issued", "used", "revoked"}',
  issuer         VARCHAR(200)  NOT NULL    COMMENT 'Optional name of the issuer of the token (jwt.iss)',
  subject        VARCHAR(64)   NOT NULL    COMMENT 'Optional subject of the token (jwt.sub)',
  audience       VARCHAR(512)  NULL        COMMENT 'Space separated list of audiences for the token (jwt.aud)',
  not_before     BIGINT        NULL        COMMENT 'Moment before which the token is not valid, as measured in number of seconds since epoch (jwt.nbf)',
  claims         TEXT          NULL        COMMENT 'Optional JSON-blob that contains a list of claims that are part of the token',
  meta_data      TEXT          NULL,
  PRIMARY KEY (`token_hash`),
  KEY `IDX_TOKENS_ID` (`id`),
  KEY `IDX_TOKENS_STATUS` (`status`),
  KEY `IDX_TOKENS_EXPIRES` (`expires`),
  KEY `FK_DELEGATION_DELEGATION_ID_idx` (`delegations_id`)
);

--
--  Nonces
--

DROP TABLE IF EXISTS nonces;

CREATE TABLE nonces (
  token          VARCHAR(64) NOT NULL                   COMMENT 'Value issued as random nonce',
  reference_data TEXT        NOT NULL                   COMMENT 'Value that is referenced by the nonce value',
  created        BIGINT      NOT NULL                   COMMENT 'Moment when nonce record is created, as measured in number of seconds since epoch',
  ttl            BIGINT      NOT NULL                   COMMENT 'Time To Live, period in seconds since created after which the nonce expires',
  consumed       BIGINT      NULL                       COMMENT 'Moment when nonce was consumed, as measured in number of seconds since epoch',
  status         VARCHAR(16) NOT NULL DEFAULT 'issued'  COMMENT 'Status of the nonce from {"issued", "revoked", "used"}',
  PRIMARY KEY (token)
);

--
--  Accounts
--

-- Drop referencing tables together with accounts
DROP TABLE IF EXISTS linked_accounts, devices, accounts;

-- MySQL needs a default value for account_id, will be overwritten by the trigger.
CREATE TABLE accounts (
  account_id VARCHAR(64) DEFAULT ''   NOT NULL    COMMENT 'ID of this account. Unique.',
  username   VARCHAR(64)              NOT NULL    COMMENT 'The username of this account. Unique.',
  password   VARCHAR(128)                         COMMENT 'The hashed password. Optional',
  email      VARCHAR(64)                          COMMENT 'The associated email address',
  phone      VARCHAR(32)                          COMMENT 'The phone number of the account owner. Optional',
  attributes JSON                                 COMMENT 'Key/value map of additional attributes associated with the account.',
  active     TINYINT DEFAULT 0        NOT NULL    COMMENT 'Indicates if this account has been activated or not. Activation is usually via email or sms.',
  created    BIGINT                   NOT NULL    COMMENT 'Time since epoch of account creation, in seconds',
  updated    BIGINT                   NOT NULL    COMMENT 'Time since epoch of latest account update, in seconds',
  PRIMARY KEY (account_id)
);

CREATE UNIQUE INDEX IDX_ACCOUNTS_PHONE
  ON accounts (phone ASC);
CREATE UNIQUE INDEX IDX_ACCOUNTS_EMAIL
  ON accounts (email);
CREATE UNIQUE INDEX IDX_ACCOUNTS_USERNAME
  ON accounts (username);

CREATE TRIGGER before_insert_accounts
BEFORE INSERT ON accounts
FOR EACH ROW
  BEGIN
    SET new.account_id = uuid();
  END
;

--
--  Linked Accounts
--

CREATE TABLE linked_accounts (
  account_id                 VARCHAR(64) NOT NULL  COMMENT 'Account ID, typically a global one, of the account being linked from (the linker)',
  linked_account_id          VARCHAR(64) NOT NULL  COMMENT 'Account ID, typically a local or legacy one, of the account being linked (the linkee)',
  linked_account_domain_name VARCHAR(64) NOT NULL  COMMENT 'The domain (i.e., organizational group or realm) of the account being linked',
  linking_account_manager    VARCHAR(128)          COMMENT 'The account manager handling this linked account',
  created                    DATETIME    NOT NULL  COMMENT 'The instant in time this link was created',
  PRIMARY KEY (linked_account_id, linked_account_domain_name)
);

CREATE INDEX IDX_LINKED_ACCOUNTS_ACCOUNTS_ID
  ON linked_accounts (account_id ASC);

--
--  Sessions
--

DROP TABLE IF EXISTS sessions;

CREATE TABLE sessions (
  id           VARCHAR(64) NOT NULL   COMMENT 'Id given to the session',
  session_data TEXT        NOT NULL   COMMENT 'Value that is referenced by the session id',
  expires      BIGINT      NOT NULL   COMMENT 'Moment when session record expires, as measured in number of seconds since epoch',
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IDX_SESSIONS_ID_EXPIRES ON sessions(id, expires);

--
--  Devices
--

CREATE TABLE devices (
  id          VARCHAR(64) NOT NULL    COMMENT 'Unique ID of the device',
  device_id   VARCHAR(64)             COMMENT 'The device ID that identifies the physical device',
  account_id  VARCHAR(256)            COMMENT 'The user account ID that is associated with the device',
  external_id VARCHAR(32),
  alias       VARCHAR(30)             COMMENT 'The user-recognizable name or mnemonic identifier of the device (e.g., my work iPhone)',
  form_factor VARCHAR(10)             COMMENT 'The type or form of device (e.g., laptop, phone, tablet, etc.)',
  device_type VARCHAR(50)             COMMENT 'The device type (i.e., make, manufacturer, provider, class)',
  owner       VARCHAR(256)            COMMENT 'The owner of the device. This is the user who has administrative rights on the device',
  attributes  JSON                    COMMENT 'Key/value map of custom attributes associated with the device.',
  expires     BIGINT                  COMMENT 'Time since epoch of device expiration, in seconds',
  created     BIGINT      NOT NULL    COMMENT 'Time since epoch of device creation, in seconds',
  updated     BIGINT      NOT NULL    COMMENT 'Time since epoch of latest device update, in seconds',
  PRIMARY KEY (id)
);

--
--  Audit log
--

CREATE TABLE audit (
  id                    VARCHAR(64)   PRIMARY KEY COMMENT 'Unique ID of the log message',
  instant               DATETIME      NOT NULL    COMMENT 'Moment that the event was logged',
  event_instant         VARCHAR(64)   NOT NULL    COMMENT 'Moment that the event occurred',
  server                VARCHAR(255)  NOT NULL    COMMENT 'The server node where the event occurred',
  message               TEXT          NOT NULL    COMMENT 'Message describing the event',
  event_type            VARCHAR(48)   NOT NULL    COMMENT 'Type of event that the message is about',
  subject               VARCHAR(128)              COMMENT 'The subject (i.e., user) effected by the event',
  client                VARCHAR(128)              COMMENT 'The client ID effected by the event',
  resource              VARCHAR(128)              COMMENT 'The resource ID effected by the event',
  authenticated_subject VARCHAR(128)              COMMENT 'The authenticated subject (i.e., user) effected by the event',
  authenticated_client  VARCHAR(128)              COMMENT 'The authenticated client effected by the event',
  acr                   VARCHAR(128)              COMMENT 'The ACR used to authenticate the subject (i.e., user)',
  endpoint              VARCHAR(255)              COMMENT 'The endpoint where the event was triggered',
  session               VARCHAR(128)              COMMENT 'The session ID in which the event was triggered'
);

--
-- Dynamically Registered Clients
--

CREATE TABLE dynamically_registered_clients (
  client_id           VARCHAR(64)                           NOT NULL  COMMENT 'The client ID of this client instance',
  client_secret       VARCHAR(128)                                    COMMENT 'The hash of this client''s secret',
  instance_of_client  VARCHAR(64)                           NULL      COMMENT 'The client ID on which this instance is based, or NULL if non-templatized client',
  created             DATETIME                              NOT NULL  COMMENT 'When this client was originally created (in UTC time)',
  updated             DATETIME                              NOT NULL  COMMENT 'When this client was last updated (in UTC time)',
  initial_client      VARCHAR(64)                           NULL      COMMENT 'In case the user authenticated, this value contains a client_id value of the initial token. If the initial token was issued through a client credentials-flow, the initial_client value is set to the client that authenticated. Registration without initial token (i.e. with no authentication) will result in a null value for initial_client',
  authenticated_user  VARCHAR(64)                           NULL      COMMENT 'In case a user authenticated (through a client), this value contains the sub value of the initial token',
  attributes          JSON                                  NOT NULL  COMMENT 'Arbitrary attributes tied to this client',
  status              ENUM('active', 'inactive', 'revoked') NOT NULL  COMMENT 'The current status of the client',
  scope               TEXT                                  NULL      COMMENT 'Space separated list of scopes defined for this client (non-templatized clients only)',
  redirect_uris       TEXT                                  NULL      COMMENT 'Space separated list of redirect URI''s defined for this client (non-templatized clients only)',
  grant_types         VARCHAR(500)                          NULL      COMMENT 'Space separated list of grant types defined for this client (non-templatized clients only)',

  PRIMARY KEY (client_id)
);

CREATE INDEX IDX_DRC_INSTANCE_OF_CLIENT ON dynamically_registered_clients(instance_of_client);
CREATE INDEX IDX_DRC_CREATED            ON dynamically_registered_clients(created);
CREATE INDEX IDX_DRC_STATUS             ON dynamically_registered_clients(status);
CREATE INDEX IDX_DRC_AUTHENTICATED_USER ON dynamically_registered_clients(authenticated_user);

--
-- Buckets
--

CREATE TABLE buckets (
  subject     VARCHAR(128)  NOT NULL COMMENT 'The subject that together with the purpose identify this bucket',
  purpose     VARCHAR(64)   NOT NULL COMMENT 'The purpose of this bucket, eg. "login_attempt_counter"',
  attributes  JSON          NOT NULL COMMENT 'All attributes stored for this subject/purpose',
  created     DATETIME      NOT NULL COMMENT 'When this bucket was created',
  updated     DATETIME      NOT NULL COMMENT 'When this bucket was last updated',

  PRIMARY KEY (subject, purpose)
);

