create or replace package kalman is

  -- Author  : TSG
  -- Created : 22.02.2013 11:26:54
  -- Purpose : ѕопытка реализовать фильтр  алмана на pl/sql, пример вз€т с http://habrahabr.ru/post/140274/

  -- Public type declarations
  TYPE numset_t IS TABLE OF NUMBER;

  -- Public function and procedure declarations
  /*
  F Ч переменна€ описывающа€ динамику системы, в случае с топливом Ч это может быть коэффициент определ€ющий расход топлива на холостых оборотах за врем€ дискретизации (врем€ между шагами алгоритма). ќднако помимо расхода топлива, существуют ещЄ и заправкиЕ поэтому дл€ простоты примем эту переменную равную 1 (то есть мы указываем, что предсказываемое значение будет равно предыдущему состо€нию).
  
  B Ч переменна€ определ€юща€ применение управл€ющего воздействи€. ≈сли бы у нас были дополнительна€ информаци€ об оборотах двигател€ или степени нажати€ на педаль акселератора, то этот параметр бы определ€л как изменитс€ расход топлива за врем€ дискретизации. “ак как управл€ющих воздействий в нашей модели нет (нет информации о них), то принимаем B = 0.
  
  H Ч матрица определ€юща€ отношение между измерени€ми и состо€нием системы, пока без объ€снений примем эту переменную также равную 1.
  
  ќпределение сглаживающих свойств
  
  R Ч ошибка измерени€ может быть определена испытанием измерительных приборов и определением погрешности их измерени€.
  
  Q Ч определение шума процесса €вл€етс€ более сложной задачей, так как требуетс€ определить дисперсию процесса, что не всегда возможно. ¬ любом случае, можно подобрать этот параметр дл€ обеспечени€ требуемого уровн€ фильтрации.
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
