DROP VIEW NAVIGATOR.COORDINATE_GRP;

/* Formatted on 04.06.2015 08:41:31 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.COORDINATE_GRP
(
   DEVICEID,
   DAY,
   SUM_L,
   AVG_V,
   MAX_V,
   MAX_A
)
AS
     SELECT c1.deviceid,
            c1.day,
            ROUND (SUM (c1.l)) sum_l,
            ROUND (AVG (c1.v)) avg_v,
            ROUND (MAX (c1.v)) max_v,
            ROUND (MAX (c1.a)) max_a
       FROM (SELECT c.DEVICEID,
                    c.dDATE day,
                    c.l,
                    c.v,
                    c.a
               FROM coordinate_v c) c1
   GROUP BY c1.deviceid, c1.day
     HAVING SUM (c1.l) > 5
--order by 1,2
;
