-- Drop together, as they are referencing each other through Foreign Key.
-- Oracle PL/SQL drop table function works only with one table at a time, we need to run both queries to check if table exist and drop.
SET sqlblanklines ON;

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "tokens"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "delegations"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/
--
--  Delegations
--

CREATE TABLE "delegations"
(
  "id"                            VARCHAR2(40)      NOT NULL PRIMARY KEY,
  "owner"                         VARCHAR2(128)     NOT NULL,
  "created"                       NUMBER(19)        NOT NULL,
  "expires"                       NUMBER(19)        NOT NULL,
  "scope"                         VARCHAR2(1000)            ,
  "scope_claims"                  CLOB                      ,
  "client_id"                     VARCHAR2(128)     NOT NULL,
  "redirect_uri"                  VARCHAR2(512)             ,
  "status"                        VARCHAR2(16)      NOT NULL,
  "claims"                        CLOB                      ,
  "authentication_attributes"     CLOB,
  "authorization_code_hash"       VARCHAR2(89)
);

CREATE INDEX IDX_DELEGATIONS_CLIENT_ID               ON "delegations"("client_id" ASC);
CREATE INDEX IDX_DELEGATIONS_STATUS                  ON "delegations"("status" ASC);
CREATE INDEX IDX_DELEGATIONS_EXPIRES                 ON "delegations"("expires" ASC);
CREATE INDEX IDX_DELEGATIONS_OWNER                   ON "delegations"("owner" ASC);
CREATE INDEX IDX_DELEGATIONS_AUTHORIZATION_CODE_HASH ON "delegations"("authorization_code_hash" ASC);

--
--  Tokens
--

CREATE TABLE "tokens"
(
  "token_hash"      VARCHAR2(89)      NOT NULL PRIMARY KEY,
  "id"              VARCHAR2(64)              ,
  "delegations_id"  VARCHAR2(40)      NOT NULL,
  "purpose"         VARCHAR2(32)      NOT NULL,
  "usage"           VARCHAR2(8)       NOT NULL,
  "format"          VARCHAR2(32)      NOT NULL,
  "created"         NUMBER(19)        NOT NULL,
  "expires"         NUMBER(19)        NOT NULL,
  "scope"           VARCHAR2(1000),
  "scope_claims"    CLOB,
  "status"          VARCHAR2(16)      NOT NULL,
  "issuer"          VARCHAR2(200)     NOT NULL,
  "subject"         VARCHAR2(64)      NOT NULL,
  "audience"        VARCHAR2(512)             ,
  "not_before"      NUMBER(19)                ,
  "claims"          CLOB                      ,
  "meta_data"       CLOB
);

CREATE INDEX IDX_TOKENS_ID       ON "tokens"("id");
CREATE INDEX IDX_TOKENS_STATUS   ON "tokens" ("status" ASC);
CREATE INDEX IDX_TOKENS_EXPIRES  ON "tokens" ("expires" ASC);

--
--  Nonces
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "nonces"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "nonces"
(
  "token"           VARCHAR2(64)  NOT NULL PRIMARY KEY,
  "reference_data"  CLOB          NOT NULL,
  "created"         NUMBER(19)    NOT NULL,
  "ttl"             NUMBER(19)    NOT NULL,
  "consumed"        NUMBER(19)            ,
  "status"          VARCHAR2(16)  DEFAULT 'issued' NOT NULL
);

--
--  Accounts
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "accounts"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "accounts"
(
  "account_id"  CHAR(36)    DEFAULT SYS_GUID()  NOT NULL  PRIMARY KEY,
  "username"    VARCHAR2(64)                    NOT NULL,
  "password"    VARCHAR2(128)                           ,
  "email"       VARCHAR2(64)                            ,
  "phone"       VARCHAR2(32)                            ,
  "attributes"  CLOB                                    ,
  "active"      NUMBER(3)   DEFAULT 0           NOT NULL,
  "created"     NUMBER(19)                      NOT NULL,
  "updated"     NUMBER(19)                      NOT NULL
);

CREATE UNIQUE INDEX IDX_ACCOUNTS_PHONE ON "accounts" ("phone" ASC);
CREATE UNIQUE INDEX IDX_ACCOUNTS_EMAIL ON "accounts" ("email");
CREATE UNIQUE INDEX IDX_ACCOUNTS_USERNAME ON "accounts" ("username");

--
--  Linked Accounts
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "linked_accounts"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "linked_accounts"
(
  "account_id"                  VARCHAR2(64),
  "linked_account_id"           VARCHAR2(64)    NOT NULL,
  "linked_account_domain_name"  VARCHAR2(64)    NOT NULL,
  "linking_account_manager"     VARCHAR2(128),
  "created"                     TIMESTAMP(3)    NOT NULL,

  PRIMARY KEY ("linked_account_id", "linked_account_domain_name")
);

CREATE INDEX IDX_LINKED_ACCOUNTS_ACCOUNTS_ID ON "linked_accounts"("account_id" ASC);

--
--  Sessions
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "sessions"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "sessions"
(
  "id"            VARCHAR2(64)    NOT NULL PRIMARY KEY,
  "session_data"  CLOB            NOT NULL,
  "expires"       NUMBER(19)      NOT NULL
);

CREATE UNIQUE INDEX IDX_SESSIONS_ID_EXPIRES ON "sessions"("id", "expires");

--
--  Devices
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "devices"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "devices"
(
  "id"          VARCHAR2(64)  PRIMARY KEY NOT NULL,
  "device_id"   VARCHAR2(64),
  "account_id"  VARCHAR2(256),
  "external_id" VARCHAR2(32),
  "alias"       VARCHAR2(30),
  "form_factor" VARCHAR2(10),
  "device_type" VARCHAR2(50),
  "owner"       VARCHAR2(256),
  "attributes"  CLOB,
  "expires"     NUMBER(19),
  "created"     NUMBER(19)    NOT NULL,
  "updated"     NUMBER(19)    NOT NULL
);

CREATE INDEX IDX_DEVICES_ACCOUNT_ID                  ON "devices"("account_id" ASC);
CREATE UNIQUE INDEX IDX_DEVICES_DEVICE_ID_ACCOUNT_ID ON "devices"("device_id" ASC, "account_id" ASC);

--
--  Audit log
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "audit"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "audit"
(
  "id"                    VARCHAR2(64)  NOT NULL PRIMARY KEY,
  "instant"               TIMESTAMP(3)  NOT NULL,
  "event_instant"         VARCHAR2(64)  NOT NULL,
  "server"                VARCHAR(255)  NOT NULL,
  "message"               CLOB,
  "event_type"            VARCHAR2(48)  NOT NULL,
  "subject"               VARCHAR2(128),
  "client"                VARCHAR2(128),
  "resource"              VARCHAR2(128),
  "authenticated_subject" VARCHAR2(128),
  "authenticated_client"  VARCHAR2(128),
  "acr"                   VARCHAR2(128),
  "endpoint"              VARCHAR2(255),
  "session"               VARCHAR2(128)
);

--
-- Dynamically Registered Clients
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "dynamically_registered_clients"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "dynamically_registered_clients"
(
  "client_id"           VARCHAR2(64)        NOT NULL PRIMARY KEY,
  "client_secret"       VARCHAR2(128),
  "instance_of_client"  VARCHAR2(64)        NULL,
  "created"             TIMESTAMP(3)        NOT NULL,
  "updated"             TIMESTAMP(3)        NOT NULL,
  "initial_client"      VARCHAR2(64)        NULL,
  "authenticated_user"  VARCHAR2(64)        NULL,
  "attributes"          CLOB DEFAULT '{}'   NOT NULL,
  "status"              VARCHAR2(16) DEFAULT 'active'   NOT NULL CHECK ("status" IN('active', 'inactive', 'revoked')),
  "scope"               CLOB                NULL,
  "redirect_uris"       CLOB                NULL,
  "grant_types"         VARCHAR2(500)       NULL
);

CREATE INDEX IDX_DRC_INSTANCE_OF_CLIENT ON "dynamically_registered_clients"("instance_of_client");
CREATE INDEX IDX_DRC_CREATED            ON "dynamically_registered_clients"("created");
CREATE INDEX IDX_DRC_STATUS             ON "dynamically_registered_clients"("status");
CREATE INDEX IDX_DRC_AUTHENTICATED_USER ON "dynamically_registered_clients"("authenticated_user");

--
-- Buckets
--

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE "buckets"';
  EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE != -942 THEN
    RAISE;
  END IF;
END;
/

CREATE TABLE "buckets" (
  "subject"     VARCHAR2(128)   NOT NULL,
  "purpose"     VARCHAR2(64)    NOT NULL,
  "attributes"  CLOB            NOT NULL,
  "created"     TIMESTAMP(3)    NOT NULL,
  "updated"     TIMESTAMP(3)    NOT NULL,

  PRIMARY KEY ("subject", "purpose")
);
