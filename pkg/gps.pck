create or replace package gps is

  -- Author  : TSG
  -- Created : 02.09.2011 10:39:08
  -- Purpose : gps monitoring
  
  type gps_rec is record (
      DEVICEID number, 
      gdate date,
      date1 date,
      date5 date,
      l BINARY_FLOAT, 
      v BINARY_FLOAT,
      a BINARY_FLOAT
  );
  
  TYPE tbl_gps IS TABLE OF gps_rec;
  
  TYPE t_array IS TABLE OF VARCHAR2(50)
   INDEX BY BINARY_INTEGER;

  FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array; 
  function gps_processing(id number, date_from date := trunc(sysdate, 'dd'), date_to date := sysdate) RETURN tbl_gps parallel_enable pipelined;
  function gps_processing_all(date_from date := trunc(sysdate, 'dd'), date_to date := sysdate) RETURN tbl_gps parallel_enable pipelined;
  procedure move_gps_data (date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd'));
  procedure calc_lva (id in number, date_from in date := trunc(sysdate, 'dd')-5, date_to in date := trunc(sysdate, 'dd'));
  procedure calc_lva_all (date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd'));
 -- procedure calc_lva_all (date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd'));
  function get_l_my(xx1 BINARY_FLOAT, yy1 BINARY_FLOAT, xx2 BINARY_FLOAT, yy2 BINARY_FLOAT) return BINARY_FLOAT;
  procedure fill_tare;
  function get_tare_val(id number, lls number, in_val_s number) return number;
  procedure calc_GPS_COMP_SG (date_from date := trunc(sysdate)-10, date_to date := sysdate);
  procedure get_osttopl(devid in number,  beg_dat in date, end_dat in date, beg_topl out number, end_topl out number);
  procedure ost_topl (date_from date := trunc(sysdate)-10, date_to date := sysdate);
  function get_ost4beg(devid number, beg_dat date) return number ;
  function get_ost4end(devid number, end_dat date) return number ;  
  procedure job_work(days_ago number := 10);
  procedure no_coordinate (cur_date date :=  trunc(sysdate) -1);
  function pivot_q(m number, y number) return varchar2;
  procedure trimBigTables(dayago number :=180);


end gps;
/
create or replace package body gps is

  function timeshift (id number, cdate date) return number is
       result number;
  begin
       select decode(atc_nmb, 2, 4,
                              1, 6,
                              4) shift into result from (
          select atc_nmb from gps_stat3_all_mv t
          where to_number(t.gps_block) = id
          and cdate between t.ust_dat and nvl(t.demont_dat, to_date('01.01.2099','dd.mm.yyyy'))
          and  rownum =1
          order by t.pl_dat desc);
       return result;     
  end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function get_l_contarovich(x1 BINARY_FLOAT, y1 BINARY_FLOAT, x2 BINARY_FLOAT, y2 BINARY_FLOAT) return BINARY_FLOAT is
         Meters_Per_Degree BINARY_FLOAT := 111194;
         dx BINARY_FLOAT; dy BINARY_FLOAT;
         pi BINARY_FLOAT := 2*asin(1);
begin
              dx := (x2-x1)*Meters_Per_Degree*cos(y1+y2)*pi/360;
              dy := (y2-y2)*Meters_Per_Degree;
--              return  round(SQRT(dx*dx+dy*dy));
              return  SQRT(dx*dx+dy*dy);

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function gr2rad(gr BINARY_FLOAT) return BINARY_FLOAT is
          pi BINARY_FLOAT := 2*asin(1);
begin
     return gr*pi/180;
end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function get_l_my(xx1 BINARY_FLOAT, yy1 BINARY_FLOAT, xx2 BINARY_FLOAT, yy2 BINARY_FLOAT) return BINARY_FLOAT is
         Ugol_to_meter BINARY_FLOAT := 6372795;
         x1 BINARY_FLOAT; x2 BINARY_FLOAT;
         y1 BINARY_FLOAT; y2 BINARY_FLOAT;
         
         dx BINARY_FLOAT; dy BINARY_FLOAT;
         pi BINARY_FLOAT := 2*asin(1);
begin
              x1:=gr2rad(xx1);
              y1:=gr2rad(yy1);
              x2:=gr2rad(xx2);
              y2:=gr2rad(yy2);

              
              dx := x2-x1;
              --dy := y2-y1;

              -- Формула взята с http://gis-lab.info/qa/great-circles.html 
              --return  round(SQRT(dx*dx+dy*dy));
              return  atan(sqrt(power(cos(y2)*sin(dx),2) + power(cos(y1)*sin(y2)-sin(y1)*cos(y2)*cos(dx),2))/(sin(y1)*sin(y2)+cos(y1)*cos(y2)*cos(dx))) * Ugol_to_meter;

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function get_l_gaversin(xx1 BINARY_FLOAT, yy1 BINARY_FLOAT, xx2 BINARY_FLOAT, yy2 BINARY_FLOAT) return BINARY_FLOAT is
         Ugol_to_meter BINARY_FLOAT := 6372795;
         x1 BINARY_FLOAT; x2 BINARY_FLOAT;
         y1 BINARY_FLOAT; y2 BINARY_FLOAT;
         
         dx BINARY_FLOAT; dy BINARY_FLOAT;
         pi BINARY_FLOAT := 2*asin(1);
begin
              x1:=gr2rad(xx1);
              y1:=gr2rad(yy1);
              x2:=gr2rad(xx2);
              y2:=gr2rad(yy2);

              
              dx := x2-x1;
              dy := y2-y1;

              -- Формула взята с http://gis-lab.info/qa/great-circles.html 
              --return  round(SQRT(dx*dx+dy*dy));
              return   2*asin(sqrt(power(sin(dy/2),2)+ cos(y1)*cos(y2)*power(sin(dx/2),2))) * Ugol_to_meter;

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
  function gps_processing(id number, date_from date := trunc(sysdate, 'dd'), date_to date := sysdate) RETURN tbl_gps parallel_enable pipelined is
            first_i boolean := true;
            x1 BINARY_FLOAT; y1 BINARY_FLOAT; t1 date;  l BINARY_FLOAT; v BINARY_FLOAT; a BINARY_FLOAT;
            dt BINARY_FLOAT;
                       
            --Min_Speed_Limit number := 0.1;
            my_row gps_rec;
            
  begin
       for cur  in (select c.deviceid id, c.gdate t, c.longtitude as x, c.latitude y, c.date5 date5, c.date1 date1  from coordinate c where c.gdate between date_from and date_to and c.deviceid = id order by c.gdate) loop
           if (first_i = false) then
              --l := get_l_gaversin(x1, y1, cur.x, cur.y)   ;  --m
              l := get_l_my(x1, y1, cur.x, cur.y)   ;  --m
              dt := (cur.t - t1) * 24 * 3600; --сек
              if dt <> 0 then
                 v := l / dt ; 
                 a := v / dt;
              --dbms_output.put_line(to_char(a, '9999.99999'));
              v := v*3600/1000;
--              dbms_output.put_line(to_char(a, '9999.99999'));

                    my_row.DEVICEID := cur.id; 
                    my_row.gdate := cur.t;
                    my_row.date5 := cur.date5;
                    my_row.date1 := cur.date1;
                    my_row.l := round(l / 1000,4) ;  --км
                    my_row.v := round(v,4);
                    my_row.a := round(a,4);
                    --dbms_output.put_line(round(v,1));
                    pipe row(my_row);
                  --dbms_output.put_line(cur.id || ' ' || dx || ' ' || dy || ' ' || TO_CHAR(l, '9999999999.999') || ' ' || TO_CHAR(v, '999.999'));    

              end if;
                  x1 := cur.x; y1 := cur.y; t1 := cur.t;
           else
              first_i := false;    
              x1 := cur.x; y1 := cur.y; t1 := cur.t;
           end if;
       end loop;
       RETURN;
       exception
                when others then
                dbms_output.put_line(SQLERRM);
--       end;
 end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function gps_processing_all(date_from date := trunc(sysdate, 'dd'), date_to date := sysdate) RETURN tbl_gps parallel_enable pipelined is
begin
     for cur1 in (select distinct c.deviceid deviceid from coordinate c) loop
       for cur2 in (select * from table(gps.gps_processing(cur1.deviceid, date_from, date_to))) loop
           pipe row(cur2);
       end loop;
     end loop;
     RETURN;
end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure move_gps_data(date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd')) is
          Min_Speed_Limit number := 5;
          Max_Speed_Limit number := 250;
begin
     delete from gps_data d
     where d.date5 between date_from and date_to;
     commit;
    
     insert into gps_data (deviceid, date5, l, v, min_v, max_v , hour, day, week, month, quarter, year)
     select to_char(t1.deviceid), t1.date5,  round(l,3) l, round(v,1) v, round(t1.min_v,1) min_v, round(t1.max_v,1) max_v
     --select to_char(t1.deviceid), t1.date5,  /*round(l,3) */ 0 l, /*round(v,1)*/ 0 v, 0 /*round(t1.min_v,1)*/ min_v, round(t1.max_v,1) max_v
      --to_char(t.date5, 'mi')/5 date5m , 
,      to_number(to_char(trunc(t1.date5, 'hh24'), 'hh')) dateh, 
      to_number(to_char(trunc(t1.date5, 'dd'), 'dd')) dated, 
      to_number(to_char(t1.date5, 'w')) datew, 
      to_number(to_char(t1.date5, 'mm')) datem, 
      to_number(to_char(t1.date5,'q'))  dateq, 
      to_number(to_char(t1.date5, 'yyyy')) datey
      
        from (
          select t.deviceid, t.date5
          ,sum(t.l) l, 
          avg(t.v) v, 
          min(t.v) min_v, 
          max(t.v) max_v
          from table(gps.gps_processing_all(date_from, date_to)) t
          where t.v between Min_Speed_Limit and Max_Speed_Limit
          group by (t.deviceid, t.date5 )
      ) t1;
     commit;

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure calc_lva (id number, date_from date, date_to date) is
    my_l BINARY_FLOAT; my_v BINARY_FLOAT := 0; my_a BINARY_FLOAT;
    dt BINARY_FLOAT; prev_v BINARY_FLOAT;
    x1 BINARY_FLOAT; y1 BINARY_FLOAT;
    x2 BINARY_FLOAT; y2 BINARY_FLOAT;
    gdate1 date; gdate2 date;
    cursor c (my_id number, my_date_from date, my_date_to date) is
    select c.crdid, c.deviceid, c.gdate gdate1,   c.longtitude x1, c.latitude y1 /*, c.l, c.v, c.a,*/
           , lead(c.gdate,1) over (partition by deviceid order by deviceid, gdate) gdate2
           , lead(c.longtitude ,1) over (partition by deviceid order by deviceid, gdate) x2
           , lead(c.latitude  ,1) over (partition by deviceid order by deviceid, gdate) y2
           from coordinate c
           where
           c.deviceid = my_id and gdate between my_date_from and my_date_to and longtitude <> 0 and latitude<>0
           order by c.gdate for update /*nowait*/;
    cur1 c%rowtype;
    
begin
    begin  
    open c(id, date_from, date_to);
    
      loop  
           fetch c into cur1;
           if c%notfound then exit; end if;
           prev_v := my_v;
           x1 := cur1.x1; y1 := cur1.y1;            
           x2 := cur1.x2; y2 := cur1.y2;            
           gdate1 := cur1.gdate1; gdate2 := cur1.gdate2;
           my_l := gps.get_l_my(x1, y1, x2, y2); --m
           
           dt:= gdate2 - gdate1;
           if dt > 0  then
               my_v := my_l/dt /1000 / 24 ; --km/hour
               dt := dt * 24 * 60 * 60; --sec
               my_a := (my_v - prev_v) * 10 / 36 / dt; --m/sec
               --insert into param (crdid, l, v, a) values (cur1.crdid, l/1000, v, a);
               update coordinate set l = my_l/1000, v = my_v, a = my_a where current of c;
           end if;
       end loop;
       exception when others then             --ловим все ошибки
           dbms_output.put_line(sqlerrm);    
    end;
    close c;
    commit;           
    
end;

-----------------------------------------------------------------------------------------------------------------------------------------------------
  procedure calc_lva_old2 (id number, date_from date, date_to date) is
    l BINARY_FLOAT; v BINARY_FLOAT := 0; a BINARY_FLOAT;
    dt BINARY_FLOAT; prev_v BINARY_FLOAT;
    x1 BINARY_FLOAT; y1 BINARY_FLOAT;
    x2 BINARY_FLOAT; y2 BINARY_FLOAT;
    gdate1 date; gdate2 date;
    
  begin
       delete  from param p
       where  exists 
      (select 1 from coordinate c where c.deviceid=id and c.crdid=p.crdid and c.gdate between date_from and date_to);
       commit;

       for cur1 in (
       select c.crdid, c.deviceid, c.gdate gdate1,   c.longtitude x1, c.latitude y1 /*, c.l, c.v, c.a,*/
, lead(c.gdate,1) over (partition by deviceid order by deviceid, gdate) gdate2
, lead(c.longtitude ,1) over (partition by deviceid order by deviceid, gdate) x2
, lead(c.latitude  ,1) over (partition by deviceid order by deviceid, gdate) y2
 from coordinate c
where
c.deviceid = id and gdate between date_from and date_to and longtitude <> 0 and latitude<>0
order by c.gdate
) loop
           prev_v := v;
           x1 := cur1.x1; y1 := cur1.y1;            
           x2 := cur1.x2; y2 := cur1.y2;            
           gdate1 := cur1.gdate1; gdate2 := cur1.gdate2;
           l := gps.get_l_my(x1, y1, x2, y2); --m
           
           dt:= gdate2 - gdate1;
           if dt > 0  then
               v := l/dt /1000 / 24 ; --km/hour
               dt := dt * 24 * 60 * 60; --sec
               a := (v - prev_v) * 10 / 36 / dt; --m/sec
               --a := l / power(dt,2); --m/sec2
               insert into param (crdid, l, v, a) values (cur1.crdid, l/1000, v, a);
--               commit;           
--               dbms_output.put_line(to_char(gdate1, 'dd.mm.yyyy hh24:mi:ss') || ' ' || cur1.crdid || ' ' || l || ' ' || v || ' ' || a);  
           end if;
--           dbms_output.put_line(to_char(gdate1, 'dd.mm.yyyy hh24:mi:ss') || ' ' || cur1.crdid || ' ' || l || ' ' || v || ' ' || a);    

       end loop;
       commit;           
       exception
          when others then
          dbms_output.put_line(SQLERRM);
  end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
  procedure calc_lva_old1 (id number, date_from date, date_to date) is
            cursor cur1 is select t.crdid crdid, t.deviceid deviceid, t.gdate1 gdate1, t.x1 x1, t.y1 y1, t.gdate2 gdate2, t.x2 x2, t.y2 y2 from coordinate_trans_v t where t.deviceid = id and t.gdate1 between date_from and date_to;
            cur_rec cur1%ROWTYPE;
  begin            
    open cur1;
    loop
        fetch cur1 into cur_rec;    
        if cur1%NOTFOUND then 
           exit;
        end if;
        dbms_output.put_line(cur_rec.x1 || ' ' || cur_rec.x2);
    end loop;
    close cur1;
  end;
-----------------------------------------------------------------------------------------------------------------------------------------------------  
  procedure calc_lva_all (date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd')) is
  begin
       --for cur0 in (select distinct c.deviceid deviceid from coordinate c) loop
       for cur0 in (select distinct gps_block deviceid from gps_park t) loop
           calc_lva(cur0.deviceid, date_from, date_to);
       end loop;
  end;

-----------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION SPLIT (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array 
   IS
   
      i       number :=0;
      pos     number :=0;
      lv_str  varchar2(200) := p_in_string;
   strings t_array;
   BEGIN
      -- determine first chuck of string  
      pos := instr(lv_str,p_delim,1,1);
      -- while there are chunks left, loop 
      WHILE ( pos != 0) LOOP
         -- increment counter 
         i := i + 1;
         -- create array element for chuck of string 
         strings(i) := REPLACE(substr(lv_str,1,pos),p_delim,'');
         -- remove chunk from string 
         lv_str := substr(lv_str,pos+1,length(lv_str));
         -- determine next chunk 
         pos := instr(lv_str,p_delim,1,1);
         -- no last chunk, add to array 
         IF pos = 0 THEN
            strings(i+1) := lv_str;
         END IF;
      END LOOP;
      -- return array 
      RETURN strings;
   END SPLIT; 
-----------------------------------------------------------------------------------------------------------------------------------------------------   
procedure razbor_tare(deviceid number, lls number, str varchar) is
  i       number;
  str_arr gps.t_array;
  /*val_s1 number := null;
  val_l1 number := null;
  val_s2 number := null;
  val_l2 number := null;*/
  val_s number;
  val_l number;

  flag number := 1;
begin
     str_arr := gps.split(str,',');
     for i in 1..str_arr.count loop
         if (mod(i,3)<>0 and (str_arr(i) is not null)) then
            if (flag=1) then
               val_l := to_number(str_arr(i));      
               /*if val_l1 is null then
                  val_l1 := to_number(str_arr(i));      
                else
                  if val_l2 is null then
                     val_l2 := to_number(str_arr(i));      
                  else
                     val_l1:= val_l2;
                     val_l2 := to_number(str_arr(i));      
                  end if;
                end if;*/
               flag := 2;
            else 
                val_s := to_number(str_arr(i));      
                /*if val_s1 is null then
                  val_s1 := to_number(str_arr(i));      
                else
                  if val_s2 is null then
                     val_s2 := to_number(str_arr(i));      
              
                  else
                     val_s1:= val_s2;
                     val_s2 := to_number(str_arr(i));      
                  end if;*/
                  --insert into tare (deviceid, sensor, val_l1, val_s1, val_l2, val_s2) values (deviceid, lls, val_l1, val_s1, val_l2, val_s2);  
                  insert into tare (deviceid, sensor, val_l, val_s) values (deviceid, lls, val_l, val_s);  
         --       end if;
               flag := 1;
            end if;
         end if;
--         dbms_output.put_line(str_arr(i));
     end loop;
end;  
-----------------------------------------------------------------------------------------------------------------------------------------------------
  procedure fill_tare is
           deviceid number;
           i number :=0;
           LLS1Tare varchar2(200);
           LLS2Tare varchar2(200);
           Fuel varchar2(200);

  begin
       for cur1 in (select t.* from carlisttmp t) loop
           if (substr(cur1.tmp_str, 1,1) = '[') then       
              if (i>0) then
                 razbor_tare(deviceid, 1, lls1tare);
                 razbor_tare(deviceid, 2, lls2tare);           
              end if;
              deviceid := to_number(substr(cur1.tmp_str,2,7));
           elsif (substr(cur1.tmp_str, 1,9) = 'LLS1Tare=') then
              LLS1Tare :=  substr(cur1.tmp_str, 9+1);     
           elsif (substr(cur1.tmp_str, 1,9) = 'LLS2Tare=') then
              LLS2Tare :=  substr(cur1.tmp_str, 9+1);     
           elsif (substr(cur1.tmp_str, 1,5) = 'Fuel=') then
              Fuel :=  substr(cur1.tmp_str, 5+1);     
           end if;
           i := i +1;
           --dbms_output.put_line(cur1.deviceid);  
        end loop;
         razbor_tare(deviceid, 1, lls1tare);
         razbor_tare(deviceid, 2, lls2tare);           

  end;
-----------------------------------------------------------------------------------------------------------------------------------------------------

function get_tare_val(id number, lls number, in_val_s number) return number 
is
  val_l1 number;
  k number;
  min_val_l number;
  min_val_s number;
  max_val_l number;
  max_val_s number;

begin
          begin
       select t2.val_l, t2.val_s into min_val_l, min_val_s from (
          select t.val_l, t.val_s from tare t
          where t.deviceid = id and t.sensor =lls
          and t.val_s <= in_val_s
          order by t.val_s desc) t2
          where rownum =1;
          exception
              when NO_DATA_FOUND then
                   --DBMS_OUTPUT.put_line('deviceid: ' || id || ' lls: ' || lls || ' val_s: ' || in_val_s);
                   min_val_l := 0; 
                   min_val_s := 0;
     end;
     
     
     begin
       select t2.val_l, t2.val_s into max_val_l, max_val_s   from (
          select t.val_l, t.val_s from tare t
          where t.deviceid = id and t.sensor =lls
          and t.val_s >= in_val_s
          order by t.val_s asc) t2
          where rownum =1;
       exception
              when NO_DATA_FOUND then
                  max_val_l := min_val_l;
                  max_val_s := min_val_s;                  
     end;
     if max_val_s = min_val_s then
        return max_val_l;     
     end if;
     k :=  (max_val_l - min_val_l)/(max_val_s - min_val_s);   --угловой коэффициент
     val_l1 := round(k*(in_val_s-min_val_s)+ min_val_l,1);
     return val_l1;
     

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function get_ost4beg(devid number, beg_dat date) return number  -- предидущее значение
is
        result number;   
        --flag boolean := false;
        nrows number := 19;
        end_dat date := trunc(beg_dat)+1;
        
begin

select  nvl(round(s2 / (nr2),1),0) avg_s2  into result from (
          select rn, deviceid, ddate, gdate, s1, s2, nrows nr,  case
              when rn < nrows  then rn
              else nrows
            end nr2
              from (
          select  /*rownum rn,*/ deviceid, ddate, l4.gdate, l4.s1, l4.s2, row_number() over (partition by deviceid,ddate order by deviceid, ddate) rn from
          (select   deviceid, ddate, l3.gdate, sum(l3.lls1_sum) s1,
          sum(sum(l3.lls1_sum)) over (partition by deviceid, ddate order by gdate ROWS BETWEEN nrows PRECEDING AND current row) s2
            from (
          select l2.deviceid, l2.ddate, l2.gdate,  l2.lls1_l + lls2_l lls1_sum, /* l2.lls1_l, l2.lls2_l,  l2.lls1_l + lls2_l lls1_sum, lls1_l_next, lls2_l_next, lls1_l_next + lls2_l_next lls2_next_sum, */(lls1_l_next + lls2_l_next) - (l2.lls1_l + lls2_l) lls_delta
            from (
              select l1.deviceid, l1.ddate, l1.gdate, l1.lls1_l, l1.lls2_l,
              lead(l1.lls1_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls1_l_next
              ,lead(l1.lls2_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls2_l_next
              from lls14_v l1
          where
          l1.gdate between trunc(beg_dat) and end_dat
          --l1.ddate = to_date('17.01.2012','dd.mm.yyyy')
             and l1.deviceid = devid
          ) l2 where l2.lls1_l_next is not null and l2.lls2_l_next is not null and gdate >= beg_dat
          ) l3
--          where l3.lls_delta <> 0
          --where abs(l3.lls_delta) > 0.1
          group by deviceid, ddate, gdate) l4 order by gdate desc
          ) where rownum =1 /*order by gdate*/
          ) ;



--     select avg_s2 into result from gps_topl_avg t where t.deviceid = devid and t.gdate between  beg_dat and trunc(beg_dat,'dd')+1 and rownum = 1  order by t.gdate;

     /*begin
          select sum_avg into result from (
          select l.sum_avg from lls14_group5_v l where l.deviceid = devid and l.date5 <= beg_dat and l.date5 >= trunc(beg_dat) order by l.date5 desc)
          where rownum =1;
          exception
              when NO_DATA_FOUND then
                   flag := true;
      end;
      if flag then
         begin
              select sum_avg into result from ( select l.sum_avg from lls14_group5_v l where l.deviceid = devid and l.date5 >= beg_dat and l.date5 <= end_dat order by l.date5) where rownum =1;
              exception
              when NO_DATA_FOUND then
                   result := null;
         end;   
      end if;*/
      return result;
end;

function get_ost4end(devid number, end_dat date) return number  -- последующее значение
is
        result number;   
         nrows number := 19;
--        flag boolean := false;
          beg_dat date := trunc(end_dat, 'dd');
begin
select  nvl(round(s2 / (nr2),1),0) avg_s2  into result from (
          select rn, deviceid, ddate, gdate, s1, s2, nrows nr,  case
              when rn < nrows  then rn
              else nrows
            end nr2
              from (
          select  /*rownum rn,*/ deviceid, ddate, l4.gdate, l4.s1, l4.s2, row_number() over (partition by deviceid,ddate order by deviceid, ddate) rn from
          (select   deviceid, ddate, l3.gdate, sum(l3.lls1_sum) s1,
          sum(sum(l3.lls1_sum)) over (partition by deviceid, ddate order by gdate ROWS BETWEEN nrows PRECEDING AND current row) s2
            from (
          select l2.deviceid, l2.ddate, l2.gdate,  l2.lls1_l + lls2_l lls1_sum, /* l2.lls1_l, l2.lls2_l,  l2.lls1_l + lls2_l lls1_sum, lls1_l_next, lls2_l_next, lls1_l_next + lls2_l_next lls2_next_sum, */(lls1_l_next + lls2_l_next) - (l2.lls1_l + lls2_l) lls_delta
            from (
              select l1.deviceid, l1.ddate, l1.gdate, l1.lls1_l, l1.lls2_l,
              lead(l1.lls1_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls1_l_next
              ,lead(l1.lls2_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls2_l_next
              from lls14_v l1
          where
          l1.gdate between beg_dat and end_dat
          --l1.ddate = to_date('17.01.2012','dd.mm.yyyy')
             and l1.deviceid = devid
          ) l2 where l2.lls1_l_next is not null and l2.lls2_l_next is not null
          ) l3
--          where l3.lls_delta <> 0
          --where abs(l3.lls_delta) > 0.1
          group by deviceid, ddate, gdate) l4
          ) where rownum =1 /*order by gdate*/
          ) ;

--      select avg_s2 into result from (select avg_s2 from gps_topl_avg t where t.deviceid = devid and t.gdate between trunc(end_dat, 'dd') and end_dat  order by t.gdate desc) where rownum = 1;
/*     begin
          select sum_avg into result from (
          select l.sum_avg from lls14_group5_v l where l.deviceid = devid and l.date5 >= end_dat and l.date5 <= trunc(end_dat)+1 order by l.date5 )
          where rownum =1;
          exception
              when NO_DATA_FOUND then
                   flag := true;
      end;
      if flag then
         begin
              select sum_avg into result from ( select l.sum_avg from lls14_group5_v l where l.deviceid = devid and l.date5 <= end_dat and l.date5 >= beg_dat order by l.date5 desc) where rownum =1;
              exception
              when NO_DATA_FOUND then
                   result := null;
         end;   
      end if;
*/      return result;
end;

-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure get_osttopl(devid in number,  beg_dat in date, end_dat in date, beg_topl out number, end_topl out number) is 
begin


   select nvl(max(avg_s2) keep (dense_rank last order by gdate desc),0) ,
          nvl(max(avg_s2) keep (dense_rank last order by gdate asc),0) into beg_topl, end_topl
      from
(
          select rn, deviceid, ddate, gdate, s1, s2, nr2, round(s2 / (nr2),1) avg_s2 from (
          select rn, deviceid, ddate, gdate, s1, s2, 19 nr,  case
              when rn < 19  then rn
              else 19
            end nr2
              from (
          select  /*rownum rn,*/ deviceid, ddate, l4.gdate, l4.s1, l4.s2, row_number() over (partition by deviceid,ddate order by deviceid, ddate) rn from
          (select   deviceid, ddate, l3.gdate, sum(l3.lls1_sum) s1,
          sum(sum(l3.lls1_sum)) over (partition by deviceid, ddate order by gdate ROWS BETWEEN 19 PRECEDING AND current row) s2
            from (
          select l2.deviceid, l2.ddate, l2.gdate,  l2.lls1_l + lls2_l lls1_sum, /* l2.lls1_l, l2.lls2_l,  l2.lls1_l + lls2_l lls1_sum, lls1_l_next, lls2_l_next, lls1_l_next + lls2_l_next lls2_next_sum, */(lls1_l_next + lls2_l_next) - (l2.lls1_l + lls2_l) lls_delta
            from (
              select l1.deviceid, l1.ddate, l1.gdate, l1.lls1_l, l1.lls2_l,
              lead(l1.lls1_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls1_l_next
              ,lead(l1.lls2_l,1) over (partition by deviceid, ddate order by deviceid, gdate) lls2_l_next
              from lls14_v l1
          where
          GDATE between trunc(beg_dat) and trunc(end_dat)+1
          --l1.ddate = to_date('17.01.2012','dd.mm.yyyy')
           and l1.deviceid = devid
          ) l2 where l2.lls1_l_next is not null and l2.lls2_l_next is not null
          ) l3
--          where l3.lls_delta <> 0
          --where abs(l3.lls_delta) > 0.1
          group by deviceid, ddate, gdate) l4
          )
          ) order by gdate
)t where GDATE between beg_dat and end_dat;
end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
 procedure ost_topl (date_from date := trunc(sysdate)-10, date_to date := sysdate) is
 cursor sg_cur is
        select t.scod, t.pl_nmb, t.deviceid, t.beg_dat, t.end_dat, t.beg_topl_gps, t.end_topl_gps from gps_comp_sg t
        where t.pl_dat between date_from and date_to
         FOR UPDATE of beg_topl_gps, end_topl_gps nowait;
 beg_topl_g number;
 end_topl_g number;
 begin
      for cur in sg_cur
      loop
          get_osttopl(cur.deviceid, cur.beg_dat, cur.end_dat, beg_topl_g, end_topl_g);
          update gps_comp_sg t
                 set t.beg_topl_gps = beg_topl_g, 
                     t.end_topl_gps = end_topl_g
                 where t.scod = cur.scod;

      end loop;
      commit;
 end;
 
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure calc_GPS_COMP_SG (date_from date := trunc(sysdate)-10, date_to date := sysdate) is
beg_topl number;
end_topl number;
begin
     delete GPS_COMP_SG g where g.pl_dat between date_from and date_to;
     commit;

  insert into navigator.gps_comp_sg (SCOD, PL_NMB, PL_DAT, BEG_DAT, END_DAT, GAR_NMB, GOS_NMB, GOS_NMBD, MARK_NAME, CEH, PDRZ_NAME, NGDU, DEVICEID, GPS_KM, gps_km_wo_jumps, PL_KM,OTKL_KM,OTKL_PRC, MAX_V, AVG_V, FACT, NORM, beg_topl, in_topl, end_topl, out_topl, OTKL_PROBEG_KM, OTKL_PROBEG_PRC, BEG_TOPL_GPS, END_TOPL_GPS) 
  select scod, pl_nmb, pl_dat, beg_dat, end_dat, gar_nmb, gos_nmb ,gos_nmbd, mark_name, ceh, PDRZ_NAME, ngdu, deviceid, gps_km, gps_km_wo_jumps, pl_km, pl_km-gps_km otkl_km, decode(nvl(pl_km,0),0,0,round((pl_km-gps_km)/pl_km*100)) otkl_prc, max_v, avg_v, fact, norm , beg_topl, in_topl, end_topl, out_topl, (fact - norm) otkl_probeg_km,
      decode(nvl(fact,0),0,0,round((fact-norm)/fact*100)) otkl_probeg_prc, null, null
      /*
      , (select round(max(l1.lls1_l+l1.lls2_l),2) from lls14_v l1 where l1.deviceid = t1.deviceid and l1.gdate = (select max(l.gdate)  from lls14_v l where l.deviceid = t1.deviceid and l.gdate < beg_dat))  beg_topl_gps
      , (select round(max(l1.lls1_l+l1.lls2_l),2) from lls14_v l1 where l1.deviceid = t1.deviceid and l1.gdate = (select min(l.gdate)  from lls14_v l where l.deviceid = t1.deviceid and l.gdate > end_dat))  end_topl_gps
      */
      from (
      select pl1.scod scod, pl1.pl_nmb pl_nmb,
        pl1.pl_dat pl_dat,
        pl1.beg_dat,
        pl1.end_dat,
        pl1.gar_nmb gar_nmb,
        pl1.gos_nmb gos_nmb,
        pl1.gos_nmbd gos_nmbd,
        pl1.mark_name,
        pdrz_cod ceh,
        PDRZ_NAME, 
        atc_nmb ngdu,
        gps.deviceid,
        round(sum(gps.l)) gps_km,
        round(sum(
                          case
                                     when gps.delta_gdate*24 > 1 and  gps.l > 10  then 0
                          else 
                                     gps.l
                          end 
          )) gps_km_wo_jumps,
        
        
        round(avg(pl1.PROBEG),1) pl_km,
        round(max(gps.v),1) max_v,
        round(avg(gps.v),1) avg_v,
        round(avg(pl1.FACT),1) fact,
        round(avg(pl1.NORM),1) norm,
        round(avg(pl1.beg_topl),1) beg_topl,
        round(avg(pl1.in_topl),1) in_topl,
        round(avg(pl1.end_topl),1) end_topl,
        round(avg(pl1.out_topl),1) out_topl   
      from
      --gps_data gps,
      coordinate_v gps,
      gps_stat3_all_mv pl1
      where
      gps.deviceid = pl1.gps_block
      and pl1.PL_DAT between date_from and date_to
      and gps.gdate between pl1.beg_dat and pl1.end_dat
--      and gps.gdate between &date_from and &date_to
      --and pl1.pl_dat >= to_date('07.09.2011','dd.mm.yyyy')
      --and gps.GDATE  >= to_date('07.09.2011','dd.mm.yyyy')
      
      
      --and gps.v between 6.5 and 250
      --and pl1.gps_block in (106000, 106007)
      group by pl1.scod,  pl1.pl_nmb,
        pl1.pl_dat,
        pl1.beg_dat,
        pl1.end_dat,
        pl1.gar_nmb,
        pl1.gos_nmb,
        pl1.gos_nmbd,
        pl1.mark_name,
        pdrz_cod,
        PDRZ_NAME,
        atc_nmb,
        gps.deviceid
      ) t1
      where t1.gps_km > 1;
    commit;
--- Добавляем п/л которые не вошли в предидущий insert
insert into gps_comp_sg s (scod, pl_nmb, pl_dat, beg_dat, end_dat, gar_nmb, gos_nmb, gos_nmbd, mark_name, ceh, ngdu, deviceid, s.pl_km, s.fact, s.norm, s.beg_topl, s.end_topl, s.in_topl, s.out_topl)
select pl.pl_scod, pl.pl_nmb, pl.pl_dat, pl.beg_dat, pl.end_dat, pl.gar_nmb, pl.gos_nmb, pl.gos_nmbd, pl.mark_name, pl.pdrz_cod, pl.atc_nmb, pl.gps_block, pl.probeg, pl.fact, pl.norm, pl.beg_topl, pl.end_topl, pl.in_topl, pl.out_topl  from gps_stat3_all_mv pl
where pl.PL_DAT between date_from and date_to
and pl.scod not in (select scod from gps_comp_sg s)
and pl.ust_dat <= date_from and nvl(pl.demont_dat, to_date('01.01.2099', 'dd.mm.yyyy')) >= date_to;
commit;
-------------------------------------------------------    

    
--    update   GPS_COMP_SG t1
                   --set t1.beg_topl_gps = (select avg_s2 from (select avg_s2 from navigator.gps_topl_avg t where t.deviceid = t1.deviceid and t.gdate >=  t1.beg_dat order by t.gdate) where rownum = 1)
                   --set t1.beg_topl_gps = (select avg_s2 from navigator.gps_topl_avg t where  t.deviceid = t1.deviceid and t.gdate >= t1.beg_dat and rownum =1),
                   --set  t1.end_topl_gps = (select avg_s2 from (select avg_s2 from gps_topl_avg t where t.deviceid = t1.deviceid and t.gdate <= t1.end_dat order by t.gdate  desc) where rownum = 1)
--             set t1.beg_topl_gps = gps.get_ost4beg(t1.deviceid, t1.beg_dat),
--                 t1.end_topl_gps = gps.get_ost4end(t1.deviceid, t1.end_dat)
                 /*set beg_topl_gps = (select round(max(l1.lls1_l+l1.lls2_l),2) from lls14_v l1 where l1.deviceid = t1.deviceid and l1.gdate = (select max(l.gdate)  from lls14_v l where l.gdate between date_from and date_to and l.deviceid = t1.deviceid and l.gdate <= beg_dat)),
                     end_topl_gps = (select round(max(l1.lls1_l+l1.lls2_l),2) from lls14_v l1 where l1.deviceid = t1.deviceid and l1.gdate = (select min(l.gdate)  from lls14_v l where l.gdate between date_from and date_to and l.deviceid = t1.deviceid and l.gdate >= end_dat)) */
--             where t1.pl_dat between date_from and date_to;
      
   

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure job_work(days_ago number := 10) is
  startTime  date;
begin
--     dbms_stats.gather_schema_stats(ownname=>'NAVIGATOR', cascade=>TRUE);

     startTime := sysdate;
     -- dbms_output.put_line('gps.calc_lva_all start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps.calc_lva_all(trunc(sysdate, 'dd')-days_ago );
     -- dbms_output.put_line('gps.calc_lva_all stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('calc_lva_all: ' || (sysdate-startTime)*24*60*60 );
---------------------------------------------------------------------------     
     startTime := sysdate;
     -- dbms_output.put_line('gps.calc_GPS_COMP_SG start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     
     gps.calc_GPS_COMP_SG(trunc(sysdate, 'dd')-days_ago);
     -- dbms_output.put_line('gps.calc_GPS_COMP_SG stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('calc_GPS_COMP_SG: ' || (sysdate-startTime)*24*60*60);
---------------------------------------------------------------------------     
     startTime := sysdate;
     -- dbms_output.put_line('gps.ost_top start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps.ost_topl(trunc(sysdate, 'dd')-days_ago);
     -- dbms_output.put_line('gps.ost_top stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('ost_top: ' || (sysdate-startTime)*24*60*60);
---------------------------------------------------------------------------
     startTime := sysdate;
     -- dbms_output.put_line('gps_agr.get_big_changes start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps_agr.get_big_changes(trunc(sysdate, 'dd')-days_ago);
     -- dbms_output.put_line('gps_agr.get_big_changes stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('get_big_changes: ' || (sysdate-startTime)*24*60*60 );
---------------------------------------------------------------------------     
     startTime := sysdate;
     -- dbms_output.put_line('gps_agr.get_gps_pivot_mon start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps_agr.get_gps_pivot_mon();
     -- dbms_output.put_line('gps_agr.get_gps_pivot_mon stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('get_gps_pivot_mon: ' || (sysdate-startTime)*24*60*60 );
---------------------------------------------------------------------------     
     startTime := sysdate;
     -- dbms_output.put_line('gps_agr.gps_charges_all start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps_agr.gps_charges_all(trunc(sysdate, 'dd')-days_ago);
     -- dbms_output.put_line('gps_agr.gps_charges_all stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('gps_charges_all: ' || (sysdate-startTime)*24*60*60 );
---------------------------------------------------------------------------     

     startTime := sysdate;
     -- dbms_output.put_line('gps.trimBigTables start ' || to_char(startTime, 'dd.mm.yyyy hh24:mi:ss'));  
     gps.trimBigTables();
     -- dbms_output.put_line('gps.trimBigTables stop ' || to_char(sysdate, 'dd.mm.yyyy hh24:mi:ss'));
     -- dbms_output.put_line('trimBigTables: ' || (sysdate-startTime)*24*60*60 );

---------------------------------------------------------------------------

end;

-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure no_coordinate(cur_date date :=  trunc(sysdate) -1) is
          cnt number;
begin
     select  count(*) into cnt from coordinate c
             where trunc(c.gdate)  = cur_date;
     if (cnt = 0) then
        send_mail('<gps@belkam.com>', '<tsg@belkam.com>', '0 data in gps coordinate on ' || to_char(cur_date, 'dd_mm_yyyy'), 'no gps data on ' || to_char(cur_date, 'dd_mm_yyyy'));
     end if;

end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
function pivot_q(m number, y number) return varchar2 is
  qq  varchar2(32000);
  mstr varchar2(3);
  ystr varchar2(4);
begin
  mstr := '0' || m;
  mstr := substr(mstr, -2);
  ystr := y;
  -- Test statements here
  qq :=   navigator.pkg_pivot.pivot_sql
  ('select to_number(to_char(last_day(to_date(''' || ystr ||  mstr || '01'', ''yyyymmdd'')), ''dd'')) from dual'
  --,'select t.obj_id, count(t.obj_id) cnt, trunc(t.cdate), dense_rank() over(order by trunc(t.cdate)) rn from dst_log t where to_char(t.cdate,''yyyy'') = ''' || year || ''' and to_char(t.cdate,''mm'') = ''' || month || ''' group by t.obj_id, trunc(t.cdate)'
  ,'select t.deviceid, count(t.deviceid) cnt, t.ddate, dense_rank() over(order by t.ddate) rn from coordinate t where to_char(t.gdate,''yyyy'') = ''' || ystr || ''' and to_char(t.gdate,''mm'') = ''' || mstr || ''' group by t.deviceid, t.ddate'
--  ,'select t.deviceid, count(t.deviceid) cnt, to_char(trunc(t.gdate),''dd''), dense_rank() over(order by to_char(trunc(t.gdate),''dd'')) rn from coordinate_v t where to_char(t.gdate,''yyyy'') = ''' || ystr || ''' and to_char(t.gdate,''mm'') = ''' || mstr || ''' group by t.deviceid, tto_char(trunc(t.gdate),''dd'')'
  , varchar2_table('deviceid')
  , varchar2_table('cnt')
  , varchar2_table(
/*  'with s as
  (select ''01'' st, to_char(last_day(to_date(''' || ystr ||  mstr || '''01'''', ''yyyymmdd'')),''dd'') ed from dual
  )
  select st + level - 1 dt
  from s
  connect by st + level - 1 <= ed'
 */ 
  'with s as
  (select to_date(''' || ystr ||  mstr || '01'', ''yyyymmdd'') st, last_day(to_date(''' || ystr ||  mstr || '01'', ''yyyymmdd'')) ed from dual
  )
  select st + level - 1 dt
  from s
  connect by st + level - 1 <= ed'
  )
  );  
  qq := replace(qq,'''','''''');
  return replace(qq,'coordinate_v','coordinate_v@gps');
end;
-----------------------------------------------------------------------------------------------------------------------------------------------------
procedure trimBigTables(dayago number :=180) is --Удаляем данные старше @dayago и данные "из будущего"
begin
  delete COORDINATE t
  where t.gdate < sysdate -dayago or t.gdate > sysdate +1;
  commit;
  
  delete FLAGS t
  where t.gdate < sysdate -dayago or t.gdate > sysdate +1;
  commit;
  
  delete GPS_CRD_TIMES t
  where t.gdate1 < sysdate -dayago or t.gdate1 > sysdate +1;
  commit;
          
  delete ANALOG t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  
  delete LLS14 t
  where t.gdate < sysdate -dayago or t.gdate > sysdate +1;
  commit;
  
  delete LLS58 t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  
  delete EVENT t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  
  delete COUNT12 t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  delete COUNT34 t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  delete COUNT56 t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
  delete COUNT78 t
  where to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 < sysdate -dayago or to_date(substr(t.datadatetime,1,19), 'yyyy-mm-dd hh24:mi:ss') + 4/24 > sysdate +1;
  commit;
 
  
end;
-----------------------------------------------------------------------------------------------------------------------------------------------------

end gps; 
/
