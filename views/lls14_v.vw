DROP VIEW NAVIGATOR.LLS14_V;

/* Formatted on 04.06.2015 08:41:38 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.LLS14_V
(
   DEVICEID,
   GDATE,
   DATE1,
   DATE5,
   DDATE,
   LLS1_L,
   LLS2_L,
   SUM_L
)
AS
   SELECT deviceid,
          gdate,
          date1,
          date5,
          ddate,
          lls1_l,
          lls2_l,
          lls1_l + lls2_l sum_l
     FROM (SELECT t.deviceid,
                  t.gdate,
                  t.date1,
                  t.date5,
                  t.ddate,
                  DECODE (t.validlls1, 1, t.lls1_l, 0) lls1_l,
                  DECODE (t.validlls2, 1, t.lls2_l, 0) lls2_l /*, decode(t.validlls3,1,t.lls3_l,0) lls3_l, decode(t.validlls4,1,t.lls4_l,0) lls4_l*/
             FROM lls14 t
            WHERE t.validtime = 1) t2;
