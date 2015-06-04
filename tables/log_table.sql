ALTER TABLE NAVIGATOR.LOG_TABLE
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.LOG_TABLE CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.LOG_TABLE
(
  LOG_SCOD  NUMBER                              NOT NULL,
  LOG_DATE  DATE                                NOT NULL,
  LOG_CODE  NUMBER                              DEFAULT 0,
  LOG_MESS  VARCHAR2(100 BYTE),
  COMP      VARCHAR2(100 BYTE),
  PROG      VARCHAR2(50 BYTE)
)
TABLESPACE USERS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          128K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX NAVIGATOR.PK1 ON NAVIGATOR.LOG_TABLE
(LOG_SCOD)
LOGGING
TABLESPACE USERS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          128K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


ALTER TABLE NAVIGATOR.LOG_TABLE ADD (
  CONSTRAINT PK1
  PRIMARY KEY
  (LOG_SCOD)
  USING INDEX NAVIGATOR.PK1
  ENABLE VALIDATE);
