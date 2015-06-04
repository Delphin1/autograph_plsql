ALTER TABLE NAVIGATOR.FLAGS
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.FLAGS CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.FLAGS
(
  ID            NUMBER                          NOT NULL,
  DEVICEID      NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1)                       NOT NULL,
  POWER         NUMBER(1)                       NOT NULL,
  RESERVPOWER   NUMBER(1),
  ANTENNA1      NUMBER(1),
  ANTENNA2      NUMBER(1),
  IN1           NUMBER(1),
  IN2           NUMBER(1),
  IN3           NUMBER(1),
  IN4           NUMBER(1),
  IN5           NUMBER(1),
  IN6           NUMBER(1),
  IN7           NUMBER(1),
  IN8           NUMBER(1),
  FLAG1         NUMBER(1),
  FLAG2         NUMBER(1),
  FLAG3         NUMBER(1),
  FLAG4         NUMBER(1),
  FLAG5         NUMBER(1),
  FLAG6         NUMBER(1),
  FLAG7         NUMBER(1),
  FLAG8         NUMBER(1),
  GDATE         DATE
)
TABLESPACE NAVITBS
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOLOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE UNIQUE INDEX NAVIGATOR.FLAGS_PK1 ON NAVIGATOR.FLAGS
(ID)
LOGGING
TABLESPACE NAVITBS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE INDEX NAVIGATOR.FLAGS_GDATE ON NAVIGATOR.FLAGS
(GDATE)
LOGGING
TABLESPACE NAVITBS
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOPARALLEL;


CREATE OR REPLACE TRIGGER NAVIGATOR.flags_bi
  before insert ON NAVIGATOR.FLAGS  
  for each row
declare
         tmp number;

begin
    select FLAGS_ID_SEQ.nextval into tmp from dual;
   :new.id := tmp;
     :new.gdate := to_date(substr(:new.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24;
  
end flags_bi;
/


ALTER TABLE NAVIGATOR.FLAGS ADD (
  CONSTRAINT FLAGS_PK1
  PRIMARY KEY
  (ID)
  USING INDEX NAVIGATOR.FLAGS_PK1
  ENABLE VALIDATE);
