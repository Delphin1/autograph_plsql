ALTER TABLE NAVIGATOR.COORDINATE
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.COORDINATE CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.COORDINATE
(
  DEVICEID      NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  LATITUDE      BINARY_FLOAT,
  LONGTITUDE    BINARY_FLOAT,
  LNHDOP        NUMBER(1),
  HDOP          NUMBER(2),
  VALIDTIME     NUMBER(1),
  SOURCE        NUMBER(1),
  POWER         NUMBER(1),
  RESERVPOWER   NUMBER(1),
  ANTENNA1      NUMBER(1),
  ANTENNA2      NUMBER(1),
  SATCOUNT      NUMBER(2),
  SPEED         BINARY_FLOAT,
  AZIMUT        NUMBER,
  ALTITUDE      NUMBER,
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
  GDATE         DATE                            NOT NULL,
  INSDATE       DATE                            DEFAULT sysdate,
  DATE5         DATE,
  DATE1         DATE,
  FLAGSID       NUMBER,
  CRDID         NUMBER,
  DDATE         DATE,
  L             BINARY_FLOAT,
  V             BINARY_FLOAT,
  A             BINARY_FLOAT
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


CREATE INDEX NAVIGATOR.ID_A_AND_V ON NAVIGATOR.COORDINATE
(V, A)
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


CREATE INDEX NAVIGATOR.ID_GDATE_LAT_LON_IDX ON NAVIGATOR.COORDINATE
(DEVICEID, GDATE, LATITUDE, LONGTITUDE)
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


CREATE INDEX NAVIGATOR.COORDINATE_GDATE_IDX_ASC ON NAVIGATOR.COORDINATE
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


CREATE UNIQUE INDEX NAVIGATOR.CRD_PK ON NAVIGATOR.COORDINATE
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


CREATE INDEX NAVIGATOR.DATE5_IDX ON NAVIGATOR.COORDINATE
(DATE5)
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


CREATE INDEX NAVIGATOR.DDATE_IDX ON NAVIGATOR.COORDINATE
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
NOPARALLEL
REVERSE;


CREATE INDEX NAVIGATOR.ID_IDX ON NAVIGATOR.COORDINATE
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


CREATE INDEX NAVIGATOR.DATE1_IDX ON NAVIGATOR.COORDINATE
(DATE1)
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


CREATE OR REPLACE TRIGGER NAVIGATOR.coordinate_ins_date
  before insert ON NAVIGATOR.COORDINATE
  for each row
declare
tmp number;

begin
   select SEQ_CRD.nextval into tmp from dual;  
   :new.crdid := tmp;
   :new.gdate := to_date(substr(:new.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24;
   :new.date5 := TRUNC(:new.gdate) - trunc((TRUNC(:new.gdate) - :new.gdate) * 24  * 60 / 5) * 5 / 24 / 60 ;
   :new.date1 := TRUNC(:new.gdate,'mi');
   :new.ddate := TRUNC(:new.gdate,'dd');
   insert into GPS_CRD_TIMES (crdid     ,GDATE1    ,GDATE5    , DDATE     , MDATE                 ,YDATE                   , QDATE                , Tbl) 
          values             (:new.crdid,:new.date1,:new.date5, :new.ddate, trunc(:new.gdate,'MM'),trunc(:new.gdate,'YYYY'), trunc(:new.gdate,'Q'), 'C');
end coordinate_ins_date;
/


ALTER TABLE NAVIGATOR.COORDINATE ADD (
  CONSTRAINT CRD_PK
  PRIMARY KEY
  (CRDID)
  USING INDEX NAVIGATOR.CRD_PK
  ENABLE VALIDATE);
