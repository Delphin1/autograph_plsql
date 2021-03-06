DROP TABLE NAVIGATOR.GPS_STAT3_ALL_MV CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.GPS_STAT3_ALL_MV
(
  SCOD        NUMBER,
  ATC_NMB     NUMBER,
  GAR_SCOD    NUMBER,
  GAR_NMB     NUMBER(6),
  GOS_NMB     VARCHAR2(96 BYTE),
  GOS_NMBD    VARCHAR2(15 BYTE),
  PDRZ_COD    NUMBER(5),
  PDRZ_NAME   VARCHAR2(900 BYTE),
  MARK_NAME   VARCHAR2(900 BYTE),
  UST_DAT     DATE,
  DEMONT_DAT  DATE,
  OBOR_NAME   VARCHAR2(900 BYTE),
  GPS_BLOCK   VARCHAR2(90 BYTE),
  PL_SCOD     NUMBER,
  PL_NMB      NUMBER(7),
  PL_DAT      DATE,
  MONTH_PL    DATE,
  BEG_WRKH    NUMBER(2),
  BEG_WRKM    NUMBER,
  PL_DAT_ET   DATE,
  END_WRKH    NUMBER(2),
  END_WRKM    NUMBER,
  PROBEG      NUMBER,
  FACT        NUMBER,
  NORM        NUMBER,
  BEG_TOPL    NUMBER,
  IN_TOPL     NUMBER,
  END_TOPL    NUMBER,
  OUT_TOPL    NUMBER,
  BEG_DAT     DATE,
  END_DAT     DATE
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
