ALTER TABLE NAVIGATOR.GPS_CRD_TIMES
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.GPS_CRD_TIMES CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.GPS_CRD_TIMES
(
  CRDID   NUMBER                                NOT NULL,
  GDATE1  DATE,
  GDATE5  DATE,
  DDATE   DATE,
  MDATE   DATE,
  YDATE   DATE,
  QDATE   DATE,
  TBL     NVARCHAR2(2)
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

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.CRDID IS 'date';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.GDATE1 IS '1 ������';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.GDATE5 IS '5 �����';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.DDATE IS '�����';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.MDATE IS '�����';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.YDATE IS '���';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.QDATE IS '�������';

COMMENT ON COLUMN NAVIGATOR.GPS_CRD_TIMES.TBL IS '�������';



CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_DDATE ON NAVIGATOR.GPS_CRD_TIMES
(DDATE)
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


CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_GDATE1 ON NAVIGATOR.GPS_CRD_TIMES
(GDATE1)
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


CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_GDATE5 ON NAVIGATOR.GPS_CRD_TIMES
(GDATE5)
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


CREATE UNIQUE INDEX NAVIGATOR.GPS_TIMES_PK1 ON NAVIGATOR.GPS_CRD_TIMES
(CRDID)
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


CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_QDATE ON NAVIGATOR.GPS_CRD_TIMES
(QDATE)
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


CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_YDATE ON NAVIGATOR.GPS_CRD_TIMES
(YDATE)
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


CREATE INDEX NAVIGATOR.GPS_CRD_TIMES_MDATE ON NAVIGATOR.GPS_CRD_TIMES
(MDATE)
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


ALTER TABLE NAVIGATOR.GPS_CRD_TIMES ADD (
  CONSTRAINT GPS_TIMES_PK1
  PRIMARY KEY
  (CRDID)
  USING INDEX NAVIGATOR.GPS_TIMES_PK1
  ENABLE VALIDATE);