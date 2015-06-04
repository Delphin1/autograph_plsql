ALTER TABLE NAVIGATOR.PARAM
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.PARAM CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.PARAM
(
  CRDID  NUMBER                                 NOT NULL,
  L      BINARY_FLOAT,
  V      BINARY_FLOAT,
  A      BINARY_FLOAT
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

COMMENT ON TABLE NAVIGATOR.PARAM IS 'Not use !!!';



CREATE INDEX NAVIGATOR.PARAM_V_IDX ON NAVIGATOR.PARAM
(V)
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


CREATE INDEX NAVIGATOR.PARAM_V_CURID_IDX ON NAVIGATOR.PARAM
(CRDID, V)
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


ALTER TABLE NAVIGATOR.PARAM ADD (
  CONSTRAINT PARAM_PK
  PRIMARY KEY
  (CRDID)
  USING INDEX NAVIGATOR.PARAM_V_CURID_IDX
  ENABLE VALIDATE);

ALTER TABLE NAVIGATOR.PARAM ADD (
  CONSTRAINT PARAM_FK 
  FOREIGN KEY (CRDID) 
  REFERENCES NAVIGATOR.COORDINATE (CRDID)
  ON DELETE CASCADE
  ENABLE VALIDATE);
