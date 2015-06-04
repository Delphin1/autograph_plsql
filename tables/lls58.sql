DROP TABLE NAVIGATOR.LLS58 CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.LLS58
(
  DEVICEID      NUMBER                          NOT NULL,
  FLAGSID       NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1)                       NOT NULL,
  LLS5          NUMBER                          NOT NULL,
  VALIDLLS5     NUMBER(1)                       NOT NULL,
  LLS6          NUMBER                          NOT NULL,
  VALIDLLS6     NUMBER(1)                       NOT NULL,
  LLS7          NUMBER                          NOT NULL,
  VALIDLLS7     NUMBER(1)                       NOT NULL,
  LLS8          NUMBER                          NOT NULL,
  VALIDLLS8     NUMBER(1)                       NOT NULL
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
