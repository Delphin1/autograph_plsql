DROP VIEW NAVIGATOR.GPS_TOPL_AVG;

/* Formatted on 04.06.2015 08:41:35 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.GPS_TOPL_AVG
(
   RN,
   DEVICEID,
   DDATE,
   GDATE,
   S1,
   S2,
   NR2,
   AVG_S2
)
AS
   SELECT "RN",
          "DEVICEID",
          "DDATE",
          "GDATE",
          "S1",
          "S2",
          "NR2",
          "AVG_S2"
     FROM (SELECT rn,
                  deviceid,
                  ddate,
                  gdate,
                  s1,
                  s2,
                  nr2,
                  ROUND (s2 / (nr2), 1) avg_s2
             FROM (SELECT rn,
                          deviceid,
                          ddate,
                          gdate,
                          s1,
                          s2,
                          19 nr,
                          CASE WHEN rn < 19 THEN rn ELSE 19 END nr2
                     FROM (SELECT                               /*rownum rn,*/
                                 deviceid,
                                  ddate,
                                  l4.gdate,
                                  l4.s1,
                                  l4.s2,
                                  ROW_NUMBER ()
                                  OVER (PARTITION BY deviceid, ddate
                                        ORDER BY deviceid, ddate)
                                     rn
                             FROM (  SELECT deviceid,
                                            ddate,
                                            l3.gdate,
                                            SUM (l3.lls1_sum) s1,
                                            SUM (
                                               SUM (l3.lls1_sum))
                                            OVER (
                                               PARTITION BY deviceid, ddate
                                               ORDER BY gdate
                                               ROWS BETWEEN 19 PRECEDING
                                                    AND     CURRENT ROW)
                                               s2
                                       FROM (SELECT l2.deviceid,
                                                    l2.ddate,
                                                    l2.gdate,
                                                    l2.lls1_l + lls2_l lls1_sum, /* l2.lls1_l, l2.lls2_l,  l2.lls1_l + lls2_l lls1_sum, lls1_l_next, lls2_l_next, lls1_l_next + lls2_l_next lls2_next_sum, */
                                                      (  lls1_l_next
                                                       + lls2_l_next)
                                                    - (l2.lls1_l + lls2_l)
                                                       lls_delta
                                               FROM (SELECT l1.deviceid,
                                                            l1.ddate,
                                                            l1.gdate,
                                                            l1.lls1_l,
                                                            l1.lls2_l,
                                                            LEAD (
                                                               l1.lls1_l,
                                                               1)
                                                            OVER (
                                                               PARTITION BY deviceid,
                                                                            ddate
                                                               ORDER BY
                                                                  deviceid,
                                                                  gdate)
                                                               lls1_l_next,
                                                            LEAD (
                                                               l1.lls2_l,
                                                               1)
                                                            OVER (
                                                               PARTITION BY deviceid,
                                                                            ddate
                                                               ORDER BY
                                                                  deviceid,
                                                                  gdate)
                                                               lls2_l_next
                                                       FROM lls14_v l1 --where
 --l1.ddate between to_date('17.01.2012','dd.mm.yyyy') and to_date('19.01.2012','dd.mm.yyyy')
                               --l1.ddate = to_date('17.01.2012','dd.mm.yyyy')
                                                   -- and l1.deviceid = 155401
                                                    ) l2
                                              WHERE     l2.lls1_l_next
                                                           IS NOT NULL
                                                    AND l2.lls2_l_next
                                                           IS NOT NULL) l3
                                   --          where l3.lls_delta <> 0
                                   --where abs(l3.lls_delta) > 0.1
                                   GROUP BY deviceid, ddate, gdate) l4))) t;
