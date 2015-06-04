DROP TABLE NAVIGATOR.LLS14_GROUP5_MV CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.LLS14_GROUP5_MV
(
  DEVICEID  NUMBER                              NOT NULL,
  DDATE     DATE,
  DATE5     DATE,
  LLS1_L    NUMBER,
  LLS2_L    NUMBER,
  LLS1_C    NUMBER,
  LLS2_C    NUMBER
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


-- Note: Index I_SNAP$_LLS14_GROUP5_MV will be created automatically 
--       by Oracle with the associated materialized view.  The following
--       script for this index is for informational purposes only.
CREATE UNIQUE INDEX NAVIGATOR.I_SNAP$_LLS14_GROUP5_MV ON NAVIGATOR.LLS14_GROUP5_MV
(SYS_OP_MAP_NONNULL("DEVICEID"), SYS_OP_MAP_NONNULL("DDATE"), SYS_OP_MAP_NONNULL("DATE5"))
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
