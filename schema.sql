show tables;

ALTER TABLE records ADD disabled TINYINT(1) DEFAULT 0;
 
CREATE INDEX recordorder ON records (domain_id, ordername);
 
 
CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB;
 
CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);
 
 
CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                TINYINT(1),
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB;
 
CREATE INDEX domainidindex ON cryptokeys(domain_id);
 
 
CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY(id)
) Engine=InnoDB;
 
CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);
 
 
CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) NOT NULL,
  comment               VARCHAR(64000) NOT NULL,
  PRIMARY KEY(id)
) Engine=InnoDB;
 
CREATE INDEX comments_domain_id_idx ON comments (domain_id);
CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


SET @old_sql_mode := @@sql_mode ;

-- derive a new value by removing NO_ZERO_DATE and NO_ZERO_IN_DATE
SET @new_sql_mode := @old_sql_mode ;
SET @new_sql_mode := TRIM(BOTH ',' FROM REPLACE(CONCAT(',',@new_sql_mode,','),',NO_ZERO_DATE,'  ,','));
SET @new_sql_mode := TRIM(BOTH ',' FROM REPLACE(CONCAT(',',@new_sql_mode,','),',NO_ZERO_IN_DATE,',','));
SET @@sql_mode := @new_sql_mode ;

update records set created_at = '1970-01-02 00:00:00' WHERE created_at = '0000-00-00 00:00:00'; 
alter table records modify created_at datetime DEFAULT CURRENT_TIMESTAMP;

-- when we are done with required operations, we can revert back
-- to the original sql_mode setting, from the value we saved
SET @@sql_mode := @old_sql_mode ;

show tables;
