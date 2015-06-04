DROP TABLE NAVIGATOR.TARE CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.TARE
(
  DEVICEID  NUMBER,
  SENSOR    NUMBER,
  VAL_L     NUMBER,
  VAL_S     NUMBER
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


CREATE INDEX NAVIGATOR.TARE_SENSOR_IDX ON NAVIGATOR.TARE
(SENSOR)
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


CREATE INDEX NAVIGATOR.TARE_DIVICEID_IDX ON NAVIGATOR.TARE
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


ALTER TABLE NAVIGATOR.TARE ADD (
  CONSTRAINT TERE_SENSOR_FK 
  FOREIGN KEY (SENSOR) 
  REFERENCES NAVIGATOR.SENSORS (ID)
  ENABLE VALIDATE);
