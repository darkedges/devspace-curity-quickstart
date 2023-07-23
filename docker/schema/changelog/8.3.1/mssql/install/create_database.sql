IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'se_curity_store')
  CREATE DATABASE [se_curity_store];

-- Remove both as tokens references delegations
IF  EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'delegations') AND
    EXISTS (SELECT * FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'tokens')
  DROP TABLE [tokens], [delegations];

--
--  Delegations
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'delegations')
  DROP TABLE [delegations];

CREATE TABLE [delegations]
(
  [id]                          VARCHAR(40)   NOT NULL PRIMARY KEY,
  [owner]                       VARCHAR(128)  NOT NULL,
  [created]                     BIGINT        NOT NULL,
  [expires]                     BIGINT        NOT NULL,
  [scope]                       VARCHAR(1000),
  [scope_claims]                VARCHAR(MAX),
  [client_id]                   VARCHAR(128)  NOT NULL,
  [redirect_uri]                VARCHAR(512),
  [status]                      VARCHAR(16)   NOT NULL,
  [claims]                      VARCHAR(MAX),
  [authentication_attributes]   VARCHAR(MAX),
  [authorization_code_hash]     VARCHAR(89)
)
go

CREATE NONCLUSTERED INDEX IDX_DELEGATIONS_CLIENT_ID               ON [delegations]([client_id] ASC);
CREATE NONCLUSTERED INDEX IDX_DELEGATIONS_STATUS                  ON [delegations]([status] ASC);
CREATE NONCLUSTERED INDEX IDX_DELEGATIONS_EXPIRES                 ON [delegations]([expires] ASC);
CREATE NONCLUSTERED INDEX IDX_DELEGATIONS_OWNER                   ON [delegations]([owner] ASC);
CREATE NONCLUSTERED INDEX IDX_DELEGATIONS_AUTHORIZATION_CODE_HASH ON [delegations]([authorization_code_hash] ASC);

--
--  Tokens
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'tokens')
  DROP TABLE [tokens];

CREATE TABLE [tokens]
(
  [token_hash]     VARCHAR(89)       NOT NULL PRIMARY KEY,
  [id]             VARCHAR(64),
  [delegations_id] VARCHAR(40)    NOT NULL ,
  [purpose]        VARCHAR(32)    NOT NULL,
  [usage]          VARCHAR(8)     NOT NULL,
  [format]         VARCHAR(32)    NOT NULL,
  [created]        BIGINT         NOT NULL,
  [expires]        BIGINT         NOT NULL,
  [scope]          VARCHAR(1000)  NULL,
  [scope_claims]   VARCHAR(MAX)   NULL,
  [status]         VARCHAR(16)    NOT NULL,
  [issuer]         VARCHAR(200)   NOT NULL,
  [subject]        VARCHAR(64)    NOT NULL,
  [audience]       VARCHAR(512),
  [not_before]     BIGINT,
  [claims]         VARCHAR(MAX),
  [meta_data]      VARCHAR(MAX)
);

CREATE NONCLUSTERED INDEX IDX_TOKENS_ID       ON [tokens]([id]);
CREATE NONCLUSTERED INDEX IDX_TOKENS_STATUS   ON [tokens] (status ASC);
CREATE NONCLUSTERED INDEX IDX_TOKENS_EXPIRES  ON [tokens] (expires ASC);

--
--  Nonces
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'nonces')
  DROP TABLE [nonces];

CREATE TABLE [nonces]
(
  [token]           VARCHAR(64) NOT NULL PRIMARY KEY,
  [reference_data]  VARCHAR(MAX) NOT NULL,
  [created]         BIGINT NOT NULL,
  [ttl]             BIGINT NOT NULL,
  [consumed]        BIGINT,
  [status]          VARCHAR(16) NOT NULL DEFAULT 'issued'
);

--
--  Accounts
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'accounts')
  DROP TABLE [accounts];

CREATE TABLE [accounts]
(
  [account_id]  UNIQUEIDENTIFIER  NOT NULL DEFAULT NEWID() PRIMARY KEY,
  [username]    VARCHAR(64)       NOT NULL,
  [password]    VARCHAR(128),
  [email]       VARCHAR(64),
  [phone]       VARCHAR(32),
  [attributes]  VARCHAR(MAX),
  [active]      TINYINT           NOT NULL DEFAULT 0,
  [created]     BIGINT            NOT NULL,
  [updated]     BIGINT            NOT NULL
)
go

CREATE UNIQUE NONCLUSTERED INDEX IDX_ACCOUNTS_PHONE ON [accounts]([phone]) WHERE [phone] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX IDX_ACCOUNTS_EMAIL ON [accounts]([email]) WHERE [email] IS NOT NULL;
CREATE UNIQUE NONCLUSTERED INDEX IDX_ACCOUNTS_USERNAME ON [accounts]([username]) WHERE [username] IS NOT NULL;

--
--  Linked Accounts
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'linked_accounts')
  DROP TABLE [linked_accounts];

CREATE TABLE [linked_accounts]
(
  [account_id]                  VARCHAR(64),
  [linked_account_id]           VARCHAR(64) NOT NULL,
  [linked_account_domain_name]  VARCHAR(64) NOT NULL,
  [linking_account_manager]     VARCHAR(128),
  [created]                     DATETIME    NOT NULL,

  PRIMARY KEY ([linked_account_id], [linked_account_domain_name])
);

CREATE NONCLUSTERED INDEX IDX_LINKED_ACCOUNTS_ACCOUNTS_ID ON [linked_accounts]([account_id] ASC);

--
--  Sessions
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'sessions')
  DROP TABLE [sessions];

CREATE TABLE [sessions]
(
  [id]            VARCHAR(64)   NOT NULL PRIMARY KEY,
  [session_data]  VARCHAR(MAX)  NOT NULL,
  [expires]       BIGINT        NOT NULL
);

CREATE NONCLUSTERED INDEX IDX_SESSIONS_ID ON [sessions]([id] ASC);
CREATE UNIQUE NONCLUSTERED INDEX IDX_SESSIONS_ID_EXPIRES ON [sessions]([id], [expires]);

--
--  Devices
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'devices')
  DROP TABLE [devices];

CREATE TABLE [devices]
(
  [id]          VARCHAR(64) PRIMARY KEY NOT NULL,
  [device_id]   VARCHAR(64),
  [account_id]  VARCHAR(256),
  [external_id] VARCHAR(32),
  [alias]       VARCHAR(30),
  [form_factor] VARCHAR(10),
  [device_type] VARCHAR(50),
  [owner]       VARCHAR(256),
  [attributes]  VARCHAR(MAX),
  [expires]     BIGINT,
  [created]     BIGINT NOT NULL,
  [updated]     BIGINT NOT NULL
);

CREATE NONCLUSTERED INDEX IDX_DEVICES_ACCOUNT_ID                  ON [devices]([account_id] ASC);
CREATE UNIQUE NONCLUSTERED INDEX IDX_DEVICES_DEVICE_ID_ACCOUNT_ID ON [devices]([device_id] ASC, [account_id] ASC);

--
--  Audit log
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'audit')
  DROP TABLE [audit];

CREATE TABLE [audit]
(
  [id]                    VARCHAR(64)   PRIMARY KEY,
  [instant]               DATETIME      NOT NULL,
  [event_instant]         VARCHAR(64)   NOT NULL,
  [server]                VARCHAR(255)  NOT NULL,
  [message]               VARCHAR(MAX)  NOT NULL,
  [event_type]            VARCHAR(48)   NOT NULL,
  [subject]               VARCHAR(128),
  [client]                VARCHAR(128),
  [resource]              VARCHAR(128),
  [authenticated_subject] VARCHAR(128),
  [authenticated_client]  VARCHAR(128),
  [acr]                   VARCHAR(128),
  [endpoint]              VARCHAR(255),
  [session]               VARCHAR(128)
);

--
-- Dynamically Registered Clients
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'dynamically_registered_clients')
  DROP TABLE [dynamically_registered_clients];

CREATE TABLE [dynamically_registered_clients]
(
  [client_id]           VARCHAR(64)   NOT NULL PRIMARY KEY,
  [client_secret]       VARCHAR(128),
  [instance_of_client]  VARCHAR(64)   NULL,
  [created]             DATETIME      NOT NULL,
  [updated]             DATETIME      NOT NULL,
  [initial_client]      VARCHAR(64)   NULL,
  [authenticated_user]  VARCHAR(64)   NULL,
  [attributes]          VARCHAR(MAX)  NOT NULL DEFAULT '{}',
  [status]              VARCHAR(16)   NOT NULL DEFAULT 'active' CHECK ([status] IN('active', 'inactive', 'revoked')),
  [scope]               VARCHAR(MAX)  NULL,
  [redirect_uris]       VARCHAR(MAX)  NULL,
  [grant_types]         VARCHAR(500)  NULL
);

CREATE NONCLUSTERED INDEX IDX_DRC_INSTANCE_OF_CLIENT ON [dynamically_registered_clients]([instance_of_client]);
CREATE NONCLUSTERED INDEX IDX_DRC_CREATED            ON [dynamically_registered_clients]([created]);
CREATE NONCLUSTERED INDEX IDX_DRC_STATUS             ON [dynamically_registered_clients]([status]);
CREATE NONCLUSTERED INDEX IDX_DRC_AUTHENTICATED_USER ON [dynamically_registered_clients]([authenticated_user]);

--
-- Buckets
--

IF EXISTS (SELECT 1 FROM sys.tables t JOIN sys.schemas s ON (t.schema_id = s.schema_id) WHERE s.name = 'dbo' AND t.name = 'buckets')
  DROP TABLE [buckets];

CREATE TABLE [buckets] (
  [subject]     VARCHAR(128)  NOT NULL,
  [purpose]     VARCHAR(64)   NOT NULL,
  [attributes]  VARCHAR(MAX)  NOT NULL,
  [created]     DATETIME      NOT NULL,
  [updated]     DATETIME      NOT NULL,

  PRIMARY KEY ([subject], [purpose])
);