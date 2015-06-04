DROP VIEW NAVIGATOR.L_MIN50PER1MIN_V;

/* Formatted on 04.06.2015 08:41:36 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.L_MIN50PER1MIN_V
(
   DEVICEID,
   DATE1,
   L_1MIN
)
AS
     SELECT c.deviceid, c.date1, SUM (c.l) l_1min
       FROM coordinate c
      WHERE c.v < 250
   GROUP BY c.deviceid, c.date1
     HAVING SUM (c.l) < 0.050
--order by 1,2
;
