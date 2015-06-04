DROP VIEW NAVIGATOR.LLS14_GROUP5_V;

/* Formatted on 04.06.2015 08:41:37 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.LLS14_GROUP5_V
(
   DEVICEID,
   DDATE,
   DATE5,
   LLS1_L_AVG,
   LLS2_L_AVG,
   SUM_AVG,
   LLS1_C,
   LLS2_C
)
AS
   SELECT deviceid,
          ddate,
          date5,
          ROUND (lls1_l) lls1_l_avg,
          ROUND (lls2_l) lls2_l_avg,
          ROUND (lls1_l + lls2_l, 1) sum_avg,
          lls1_c,
          lls2_c
     FROM lls14_group5_mv
/*select deviceid, ddate, date5, round(lls1_l_avg,1) lls1_l_avg , round(lls2_l_avg,1) lls2_l_avg, round(lls1_l_avg+lls2_l_avg,1) sum_avg from (
select t.deviceid, t.ddate, t.date5, avg(t.lls1_l) lls1_l_avg, avg(t.lls2_l) lls2_l_avg\*, avg(t.lls3_l) lls3_l_avg, avg(t.lls4_l) lls4_l_avg *\  from lls14_v t
group by t.deviceid, t.ddate, t.date5)
order by deviceid, date5
*/
;
