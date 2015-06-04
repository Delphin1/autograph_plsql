DROP VIEW NAVIGATOR.GPS_AGR_V;

/* Formatted on 04.06.2015 08:41:33 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.GPS_AGR_V
(
   DEVICEID,
   DAY,
   MONTH,
   QUATER,
   YEAR,
   SUM_L,
   AVG_V
)
AS
     SELECT c.DEVICEID DEVICEID,
            t.ddate day,
            t.mdate month,
            t.qdate quater,
            t.ydate year,
            SUM (c.l) sum_l,
            AVG (c.v) avg_v
       FROM COORDINATE_v c, gps_crd_times t
      WHERE     c.crdid = t.crdid(+)
            AND c.latitude <> 0
            AND c.longtitude <> 0
            AND t.tbl = 'C'
   --and t.mdate = to_date('01.01.2013','dd.mm.yyyy')
   GROUP BY c.DEVICEID,
            t.ddate,
            t.mdate,
            t.qdate,
            t.ydate
     HAVING SUM (c.l) > 1
--order by 1,2
;
