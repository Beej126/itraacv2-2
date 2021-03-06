USE iTRAAC
go

/*************** tblClients */
ALTER TABLE tblClients ADD SponsorGUID uniqueidentifier NULL -- replaces SponsorID
ALTER TABLE tblClients ADD CreateUserGUID uniqueidentifier NULL -- replaces AgentID
ALTER TABLE tblClients ADD RowVersion timestamp NOT NULL -- might come in handy
ALTER TABLE tblClients ADD SuffixName VARCHAR(10) NULL -- there's a conversion script which finally moves stuff like Billy Jr. III out to this field so it doesn't litter the lastname
ALTER TABLE tblClients ADD CreateDate DATETIME not null DEFAULT(GETDATE()) -- finally!!
ALTER TABLE tblClients ADD DoDId VARCHAR(10)
ALTER TABLE tblClients ADD Birthdate datetime
ALTER TABLE tblClients ALTER COLUMN SuspensionRoleID INT NULL --this goes along with patching cp_parmsel_iTRAAC_Client to return isnull(SuspensionRoleID, 0)

ALTER TABLE tblClients DROP CONSTRAINT PK1
create UNIQUE index ix_ClientID on tblClients (ClientID)

CREATE CLUSTERED INDEX ix_SponsorGUID ON tblClients (SponsorGUID ASC)
ALTER TABLE tblClients ADD CONSTRAINT PK_Clients PRIMARY KEY (RowGUID) 
-- DROP INDEX tblClients.ix_RowGUID
-- CREATE UNIQUE INDEX ix_RowGUID ON tblClients (RowGUID, ClientID) INCLUDE (LName, CCode) -- (LName, CCode are for DailyActivity_s) replaces existing index on corresponding identity cols
-- ALTER TABLE tblClients DROP CONSTRAINT PK1
-- CREATE UNIQUE INDEX ix_RowGUID ON tblClients (RowGUID, ClientID) INCLUDE () -- replaces existing index on corresponding identity cols

CREATE NONCLUSTERED INDEX ix_CCode ON tblClients (CCode) -- for customer search
CREATE NONCLUSTERED INDEX ix_LName ON tblClients (LName, FName) INCLUDE (CCode, SSN) -- customer search
-- DROP INDEX tblClients.ix_SSN
CREATE NONCLUSTERED INDEX ix_SSN ON tblClients (SSN, RowGUID) -- customer search & register new customer search
CREATE NONCLUSTERED INDEX ix_Email ON tblClients(Email, SponsorGUID)
CREATE NONCLUSTERED INDEX ix_DoDId ON tblClients(DoDId)

ALTER TABLE tblClients ADD CONSTRAINT DF_tblClients_RowGUID DEFAULT (NEWSEQUENTIALID()) FOR ROWGUID


--nixing this idea and simply stamping previous name info on TaxFormPackage *only* when names actually change:
-- ALTER TABLE tblClients ADD ReplacementClientGUID UNIQUEIDENTIFIER -- facilitates tracking name changes over time, previous identities will chain up to the current name
--CREATE NONCLUSTERED INDEX ix_ReplacementClientGUID ON tblClients(ReplacementClientGUID) INCLUDE (RowGUID, ClientID, FName, LName) -- for Sponsor_TaxForms & Sponsor_Remarks procs walking the "Previous Identities" info
--sp_procsearch 'ReplacementClientGUID'


------ _ -------------------------------- _ ---------- _ ----- _ ----------------------------------- _ -----
--    / \      ____   _       _____      / \          / /     | |      _   _  _____           __    | |  
--   / ^ \    / __ \ | |     |  __ \    / ^ \        / /      | |     | \ | ||  ___|\        / /    | |  
--  /_/ \_\  | |  | || |     | |  | |  /_/ \_\      / /     __| |__   |  \| || |__ \ \  /\  / /   __| |__
--    | |    | |  | || |     | |  | |    | |       / /      \ \ / /   |     ||  __| \ \/  \/ /    \ \ / /
--    | |    | |__| || |____ | |__| |    | |      / /        \ V /    | |\  || |____ \  /\  /      \ V / 
--    |_|     \____/ |______||_____/     |_|     /_/          \_/     |_| \_||______| \/  \/        \_/  
------------------------------------------------------------------------------------------------------------




