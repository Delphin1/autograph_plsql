ALTER TABLE NAVIGATOR.BIG_CHANGES1MIN
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.BIG_CHANGES1MIN CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.BIG_CHANGES1MIN
(
  DEVICEID  NUMBER                              NOT NULL,
  BEG_TIME  DATE                                NOT NULL,
  CHANGE    NUMBER(10,2),
  POROG_L   NUMBER                              NOT NULL,
  POROG_KM  NUMBER
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
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;


CREATE INDEX NAVIGATOR.BIG_CHANGES5MIN_DEVICEID_IDX ON NAVIGATOR.BIG_CHANGES1MIN
(DEVICEID)
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


CREATE UNIQUE INDEX NAVIGATOR.BIG_CHANGES5MIN_PK ON NAVIGATOR.BIG_CHANGES1MIN
(DEVICEID, BEG_TIME, POROG_L, POROG_KM)
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


ALTER TABLE NAVIGATOR.BIG_CHANGES1MIN ADD (
  CONSTRAINT BIG_CHANGES5MIN_PK
  PRIMARY KEY
  (DEVICEID, BEG_TIME, POROG_L, POROG_KM)
  USING INDEX NAVIGATOR.BIG_CHANGES5MIN_PK
  ENABLE VALIDATE);