DROP TABLE NAVIGATOR.COUNT12 CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.COUNT12
(
  DEVICEID      NUMBER                          NOT NULL,
  FLAGSID       NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1)                       NOT NULL,
  COUNT1        NUMBER                          NOT NULL,
  COUNT2        NUMBER                          NOT NULL
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
