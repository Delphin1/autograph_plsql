create or replace package gps_agr is

  -- Author  : TSG
  -- Created : 23.12.2011 10:43:09
  -- Purpose : 
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  
  -- Public constant declarations
--  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
--  <VariableName> <Datatype>;

  -- Public function and procedure declarations
  --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
  procedure get_big_changes(date_from date := trunc(sysdate, 'dd')-10, date_to date := trunc(sysdate, 'dd'), p_l number := 10, p_km number := 0.050);
  procedure get_gps_pivot_mon(cur_m date := trunc(sysdate-1, 'mm'));
  procedure gps_charges_all(date_from date := trunc(sysdate, 'dd')-10, date_to date := trunc(sysdate, 'dd'));

end gps_agr;
/
create or replace package body gps_agr is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  procedure get_big_changes(date_from date := trunc(sysdate, 'dd')-10, date_to date := trunc(sysdate, 'dd'), p_l number := 10, p_km number := 0.050) as

  begin
    delete big_changes1min c
    where c.beg_time between date_from and date_to
    and c.porog_l = p_l and c.porog_km = p_km ;
    commit;
    
    insert into big_changes1min (deviceid, beg_time, change, porog_l, porog_km) 
    select c3.deviceid, c3.date1, c3.d_lls_sum, p_l, p_km from (
      select c2.deviceid, c2.date1, sum(c2.d_lls) d_lls_sum from (
      select  deviceid, gdate, date1, /*date5,*/lls1_l, lls2_l,lls1_l_next, lls2_l_next, (lls1_l_next+lls2_l_next) - (lls1_l+lls2_l) d_lls from (
              select deviceid, gdate, date1, /*date5,*/ lls1_l, lls2_l,
              lead(c.lls1_l,1) over (partition by deviceid order by deviceid, gdate) lls1_l_next,
              lead(c.lls2_l,1) over (partition by deviceid order by deviceid, gdate) lls2_l_next
              from lls14_v c where c.gdate between date_from and date_to) c1) c2
              where c2.lls1_l_next is not null and c2.lls2_l_next is not null
            group by c2.deviceid, c2.date1
            having sum(c2.d_lls) < -abs(p_l) or sum(c2.d_lls) > abs(p_l)
      ) c3,    
      (select c.deviceid, c.date1, sum(c.l) l_1min
      from coordinate_v c
      where 
      c.gdate between date_from and date_to
      group by c.deviceid, c.date1
      having sum(c.l) < 0.050) l3
      where c3.deviceid = l3.deviceid and c3.date1 = l3.date1;
    commit;
  end;
----------------------------------------------------------------------------------------------------------------------------------------------------------
procedure get_gps_pivot_mon(cur_m date := trunc(sysdate-1, 'mm')) as
begin

     delete gps_pivot_mon p
     where p.gps_month = cur_m;
     commit;
     dbms_output.put_line('Deleting: OK');
     begin
          insert into gps_pivot_mon (gps_month, deviceid,        gar_scod,         d1,                  d2,              d3,              d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14, d15, d16, d17, d18, d19, d20, d21, d22, d23, d24, d25, d26, d27, d28, d29, d30, d31, sm)
                         select cur_m, s2.deviceid, s2.gar_scod ,to_number(c1) d1,to_number(c2) d2,to_number(c3) d3,to_number(c4) d4,to_number(c5),to_number(c6),to_number(c7),to_number(c8),to_number(c9),to_number(c10)
                                                                   ,to_number(c11),to_number(c12),to_number(c13),to_number(c14),to_number(c15),to_number(c16),to_number(c17),to_number(c18),to_number(c19),to_number(c20)
                                                                   ,to_number(c21),to_number(c22),to_number(c23),to_number(c24),to_number(c25),to_number(c26),to_number(c27),to_number(c28),to_number(c29),to_number(c30),to_number(c31)
           , nvl(c1,0) + nvl(c2,0) + nvl(c3,0) + nvl(c4,0) + nvl(c5,0) + nvl(c6,0) + nvl(c7,0) + nvl(c8,0) + nvl(c9,0) + nvl(c10,0)
           + nvl(c11,0) + nvl(c12,0) + nvl(c13,0) + nvl(c14,0) + nvl(c15,0) + nvl(c16,0) + nvl(c17,0) + nvl(c18,0) + nvl(c19,0) + nvl(c20,0)
           + nvl(c21,0) + nvl(c22,0) + nvl(c23,0) + nvl(c24,0) + nvl(c25,0) + nvl(c26,0) + nvl(c27,0) + nvl(c28,0) + nvl(c29,0) + nvl(c30,0) + nvl(c31,0) sm  from (
              select s1.deviceid, s1.gar_scod, 
              round(sum(decode(s1.day,1,s1.l))) as c1,
              round(sum(decode(s1.day,2,s1.l))) as c2,
              round(sum(decode(s1.day,3,s1.l))) as c3,
              round(sum(decode(s1.day,4,s1.l))) as c4,
              round(sum(decode(s1.day,5,s1.l))) as c5,
              round(sum(decode(s1.day,6,s1.l))) as c6,
              round(sum(decode(s1.day,7,s1.l))) as c7,
              round(sum(decode(s1.day,8,s1.l))) as c8,
              round(sum(decode(s1.day,9,s1.l))) as c9,
              round(sum(decode(s1.day,10,s1.l))) as c10,
              round(sum(decode(s1.day,11,s1.l))) as c11,
              round(sum(decode(s1.day,12,s1.l))) as c12,
              round(sum(decode(s1.day,13,s1.l))) as c13,
              round(sum(decode(s1.day,14,s1.l))) as c14,
              round(sum(decode(s1.day,15,s1.l))) as c15,
              round(sum(decode(s1.day,16,s1.l))) as c16,
              round(sum(decode(s1.day,17,s1.l))) as c17,
              round(sum(decode(s1.day,18,s1.l))) as c18,
              round(sum(decode(s1.day,19,s1.l))) as c19,
              round(sum(decode(s1.day,20,s1.l))) as c20,
              round(sum(decode(s1.day,21,s1.l))) as c21,
              round(sum(decode(s1.day,22,s1.l))) as c22,
              round(sum(decode(s1.day,23,s1.l))) as c23,
              round(sum(decode(s1.day,24,s1.l))) as c24,
              round(sum(decode(s1.day,25,s1.l))) as c25,
              round(sum(decode(s1.day,26,s1.l))) as c26,
              round(sum(decode(s1.day,27,s1.l))) as c27,
              round(sum(decode(s1.day,28,s1.l))) as c28,
              round(sum(decode(s1.day,29,s1.l))) as c29,
              round(sum(decode(s1.day,30,s1.l))) as c30,
              round(sum(decode(s1.day,31,s1.l))) as c31
              from
              (select c1.deviceid, p.gar_scod, c1.ddate - cur_m + 1 day, c1.l
              from coordinate_v c1, gps_park p
              where c1.latitude <> 0 and c1.longtitude <> 0 
              and trunc(c1.gdate, 'mm') = cur_m
              and c1.deviceid = p.gps_block
              and c1.gdate between p.ust_dat and nvl(p.demont_dat, to_date('01012099','ddmmyyyy'))
              ) s1
              group by s1.deviceid, s1.gar_scod
              ) s2;            
              
        exception when others then             --ловим все ошибки
           dbms_output.put_line(sqlerrm);
         
     end;         
     commit;     
     
end;
----------------------------------------------------------------------------------------------------------------------------------------------------------
procedure gps_charges(devid number, date_from date := trunc(sysdate, 'dd')-5, date_to date := trunc(sysdate, 'dd')) is
          nrows number := 19;
          delta number := 10;
begin
     delete gps_charge g where g.time_int between date_from and date_to and g.deviceid = devid;
     commit;
     insert into gps_charge (deviceid, TIME_INT, CHARGE_VAL)      
    select distinct s2.deviceid, s2.gdate20 TIME_INT,  s2.zapr - mod(s2.zapr,5) CHARGE_VAL from (
    select deviceid, gdate20, max1, max_plus1, max_plus2, max_minus1, max_minus2, max1- least(min1, min_minus1, min_minus2) zapr,
    case when (max1 > max_plus1) and (max1 > max_plus2)  and (max1 > max_minus1) and (max1 > max_minus2) and (max1 > min1 + delta or max1 > min_minus1 + delta)
         then 1
         else 0
    end c1_max, 
    min1, min_plus1, min_plus2, min_minus1, min_minus2, 
    case when (min1 < min_plus1) and (min1 < min_plus2)  and (min1 < min_minus1) and (min1 < min_minus2)
         then 1
         else 0
    end c1_min
    
     from (
    select deviceid, gdate20, max1
    , lead(max1,1) over (partition by deviceid order by deviceid, gdate20) max_plus1
    , lead(max1,2) over (partition by deviceid order by deviceid, gdate20) max_plus2
    , lag(max1,1) over (partition by deviceid order by deviceid, gdate20) max_minus1
    , lag(max1,2) over (partition by deviceid order by deviceid, gdate20) max_minus2
    , min1
    , lead(min1,1) over (partition by deviceid order by deviceid, gdate20) min_plus1
    , lead(min1,2) over (partition by deviceid order by deviceid, gdate20) min_plus2
    , lag(min1,1) over (partition by deviceid order by deviceid, gdate20) min_minus1
    , lag(min1,2) over (partition by deviceid order by deviceid, gdate20) min_minus2
    from (
            select deviceid, gdate20, min(avg_s2) min1, max(avg_s2) max1 from (
                  select rn, deviceid, gdate,  
                  --TRUNC(gdate) - trunc((TRUNC(gdate) - gdate) * 24  * 60 / 30) * 30 / 24 / 60 gdate20,
                  trunc(gdate, 'hh') gdate20,
                                                              
                s1, s2, nr2, round(s2 / (nr2),1) avg_s2 from (
              select rn, deviceid, gdate, s1, s2, nrows nr,  case
                  when rn < nrows  then rn
                  else nrows
                end nr2
                  from (
              select  rownum rn, deviceid, l4.gdate, l4.s1, l4.s2 from 
              (select   deviceid, l3.gdate, sum(l3.lls1_sum) s1, 
              sum(sum(l3.lls1_sum)) over (order by gdate ROWS BETWEEN nrows PRECEDING AND current row) s2
                from (
              select l2.deviceid, l2.ddate, l2.gdate,  l2.lls1_l + lls2_l lls1_sum, /* l2.lls1_l, l2.lls2_l,  l2.lls1_l + lls2_l lls1_sum, lls1_l_next, lls2_l_next, lls1_l_next + lls2_l_next lls2_next_sum, */(lls1_l_next + lls2_l_next) - (l2.lls1_l + lls2_l) lls_delta
                from (
                  select l1.deviceid, l1.ddate, l1.gdate, l1.lls1_l, l1.lls2_l,  
                  lead(l1.lls1_l,1) over (partition by deviceid order by deviceid, gdate) lls1_l_next 
                  ,lead(l1.lls2_l,1) over (partition by deviceid order by deviceid, gdate) lls2_l_next
                  from lls14_v l1
              where 
              l1.ddate between date_from and date_to

                 and l1.deviceid = devid
              ) l2 where l2.lls1_l_next is not null and l2.lls2_l_next is not null
              ) l3  
              where l3.lls_delta <> 0
              group by deviceid, gdate) l4 
              )
              )
    --        )
            --where mod(rn,20) = 0
    --     ) where  abs(s_40-s) > 10
    )
    group by deviceid, gdate20
    )
    group by min1, max1, deviceid, gdate20)) s2
    where c1_max =1;
    commit;
end;
----------------------------------------------------------------------------------------------------------------------------------------------------------
 procedure gps_charges_all(date_from date := trunc(sysdate, 'dd')-10, date_to date := trunc(sysdate, 'dd')) is
 begin
       for cur0 in (select distinct gps_block deviceid from gps_park t) loop
           gps_charges(cur0.deviceid, date_from, date_to);
       end loop;
 end;
----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  

--begin
  -- Initialization
--  <Statement>;
end gps_agr;
/
