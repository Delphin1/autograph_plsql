DROP TABLE NAVIGATOR.CAN6 CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.CAN6
(
  DEVICEID      NUMBER                          NOT NULL,
  FLAGSID       NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1)                       NOT NULL,
  RECID         NUMBER                          NOT NULL,
  WHEEL1        NUMBER                          NOT NULL,
  WHEEL2        NUMBER                          NOT NULL,
  WHEEL3        NUMBER                          NOT NULL,
  WHEEL4        NUMBER                          NOT NULL,
  WHEEL5        NUMBER                          NOT NULL,
  WHEEL6        NUMBER                          NOT NULL
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
