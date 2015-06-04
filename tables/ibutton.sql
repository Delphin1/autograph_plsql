ALTER TABLE NAVIGATOR.IBUTTON
 DROP PRIMARY KEY CASCADE;

DROP TABLE NAVIGATOR.IBUTTON CASCADE CONSTRAINTS;

CREATE TABLE NAVIGATOR.IBUTTON
(
  DEVICEID      NUMBER                          NOT NULL,
  DATADATETIME  VARCHAR2(30 BYTE)               NOT NULL,
  VALIDTIME     NUMBER(1),
  EVENTDATA     VARCHAR2(12 BYTE),
  FLAGSID       NUMBER,
  IBUTTONID     NUMBER
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


CREATE UNIQUE INDEX NAVIGATOR.IBUTTON_PK ON NAVIGATOR.IBUTTON
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


CREATE OR REPLACE TRIGGER NAVIGATOR.IBUTTON_bi
  before insert ON NAVIGATOR.IBUTTON
  for each row
declare
         tmp number;

begin
/*    if length(to_char(:old.ibuttonid))>30 then
      dbms_output.put_line('String ' || :old.ibuttonid || 'too long');
      :new.ibuttonid := 1;
      null;
    end if;
*/    
    select SEQ_IBUTTONID.NEXTVAL into tmp from dual;
   :new.IBUTTONID := tmp;

end IBUTTON_bi;
/


ALTER TABLE NAVIGATOR.IBUTTON ADD (
  CONSTRAINT IBUTTON_PK
  PRIMARY KEY
  (DEVICEID)
  USING INDEX NAVIGATOR.IBUTTON_PK
  ENABLE VALIDATE);
