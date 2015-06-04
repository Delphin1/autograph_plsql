DROP TABLE NAVIGATOR.COUNT78 CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.COUNT78
(
  DEVICEID      NUMBER                          NOT NULL,
  FLAGSID       NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1)                       NOT NULL,
  COUNT7        NUMBER                          NOT NULL,
  COUNT8        NUMBER                          NOT NULL
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
