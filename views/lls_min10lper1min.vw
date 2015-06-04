DROP VIEW NAVIGATOR.LLS_MIN10LPER1MIN;

/* Formatted on 04.06.2015 08:41:36 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.LLS_MIN10LPER1MIN
(
   DEVICEID,
   DATE1,
   D_LLS_SUM
)
AS
     SELECT c2.deviceid, c2.date1, SUM (c2.d_lls) d_lls_sum
       FROM (SELECT deviceid,
                    gdate,
                    date1,
                    date5,
                    lls1_l,
                    lls2_l,
                    lls1_l_next,
                    lls2_l_next,
                    (lls1_l_next + lls2_l_next) - (lls1_l + lls2_l) d_lls
               FROM (SELECT deviceid,
                            gdate,
                            date1,
                            date5,
                            lls1_l,
                            lls2_l,
                            LEAD (c.lls1_l, 1) OVER (ORDER BY deviceid, gdate)
                               lls1_l_next,
                            LEAD (c.lls2_l, 1) OVER (ORDER BY deviceid, gdate)
                               lls2_l_next
                       FROM lls14_v c) c1) c2
   GROUP BY c2.deviceid, c2.date1
     HAVING SUM (c2.d_lls) < -10
--order by 1,2
;
