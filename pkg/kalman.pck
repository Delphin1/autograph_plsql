create or replace package kalman is

  -- Author  : TSG
  -- Created : 22.02.2013 11:26:54
  -- Purpose : ������� ����������� ������ ������� �� pl/sql, ������ ���� � http://habrahabr.ru/post/140274/

  -- Public type declarations
  TYPE numset_t IS TABLE OF NUMBER;

  -- Public function and procedure declarations
  /*
  F � ���������� ����������� �������� �������, � ������ � �������� � ��� ����� ���� ����������� ������������ ������ ������� �� �������� �������� �� ����� ������������� (����� ����� ������ ���������). ������ ������ ������� �������, ���������� ��� � �������� ������� ��� �������� ������ ��� ���������� ������ 1 (�� ���� �� ���������, ��� ��������������� �������� ����� ����� ����������� ���������).
  
  B � ���������� ������������ ���������� ������������ �����������. ���� �� � ��� ���� �������������� ���������� �� �������� ��������� ��� ������� ������� �� ������ ������������, �� ���� �������� �� ��������� ��� ��������� ������ ������� �� ����� �������������. ��� ��� ����������� ����������� � ����� ������ ��� (��� ���������� � ���), �� ��������� B = 0.
  
  H � ������� ������������ ��������� ����� ����������� � ���������� �������, ���� ��� ���������� ������ ��� ���������� ����� ������ 1.
  
  ����������� ������������ �������
  
  R � ������ ��������� ����� ���� ���������� ���������� ������������� �������� � ������������ ����������� �� ���������.
  
  Q � ����������� ���� �������� �������� ����� ������� �������, ��� ��� ��������� ���������� ��������� ��������, ��� �� ������ ��������. � ����� ������, ����� ��������� ���� �������� ��� ����������� ���������� ������ ����������.
  */
  PROCEDURE get_ref_cursor(sqlselect IN VARCHAR2, rc OUT sys_refcursor);
  procedure Flt(inMass in SYS_REFCURSOR,
                
                F          number := 1,
                H          number := 1,
                Q          number := 2,
                R          number := 15,
                Covariance number := 0.1);

  function Fltf(inMass     in SYS_REFCURSOR,
                F          number := 1,
                H          number := 1,
                Q          number := 2,
                R          number := 15,
                Covariance number := 0.1) return numset_t
    PIPELINED;
  procedure Filter(id         number,
                   date_from  date,
                   date_to    date,
                   F          number := 1,
                   H          number := 1,
                   Q          number := 2,
                   R          number := 15,
                   Covariance number := 0.1);

end kalman;
/
create or replace package body kalman is
  PROCEDURE get_ref_cursor(sqlselect IN VARCHAR2, rc OUT sys_refcursor) AS
  BEGIN
    OPEN rc FOR sqlselect;
  END;
--------------------------------------------------------------------------------
  procedure Flt(inMass     SYS_REFCURSOR,
                F          number := 1,
                H          number := 1,
                Q          number := 2,
                R          number := 15,
                Covariance number := 0.1) is
    somename number;
  begin
    LOOP
      FETCH inMass
        INTO somename;
      EXIT WHEN inMass%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(somename);
    END LOOP;
    CLOSE inMass;
  end;
--------------------------------------------------------------------------------
function Fltf(inMass     in SYS_REFCURSOR,
                F          number := 1,
                H          number := 1,
                Q          number := 2,
                R          number := 15,
                Covariance number := 0.1) return numset_t PIPELINED is
    somename number;                
begin
  LOOP
      FETCH inMass
        INTO somename;
      EXIT WHEN inMass%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(somename);
      pipe row(somename);
    END LOOP;
    CLOSE inMass;
    return;
end;  
--------------------------------------------------------------------------------
procedure Filter(id number, date_from date, date_to date,
                F          number := 1,
                H          number := 1,
                Q          number := 2,
                R          number := 15,
                Covariance number := 0.1) is
  X0 float;
  P0 float;
  K  float;
  Cvr  float := Covariance;
  State float;
  cnt number := 1;   
begin
for c in (select l.gdate, l.lls1_l+l.lls2_l S from LLS14 l where l.deviceid = id and gdate between date_from and date_to order by l.gdate) loop
  if (cnt=1) then State := c.s;
  end if;

  X0 := F*State;
  P0 := F*Cvr*F + Q;

  K := H*P0/(H*P0*H + R);
  State := X0 + K*(c.S - H*X0);
  Cvr := (1 - K*H)*P0;      
  cnt := cnt + 1;
  dbms_output.put_line(to_char(c.gdate, 'dd.mm.yyyy hh24:mi:ss') || ' ' || c.S || ' ' || Round(State,1));
  end loop;
end;

end;
/
