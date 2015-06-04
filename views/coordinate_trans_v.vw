DROP VIEW NAVIGATOR.COORDINATE_TRANS_V;

/* Formatted on 04.06.2015 08:41:32 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.COORDINATE_TRANS_V
(
   CRDID,
   DEVICEID,
   GDATE1,
   X1,
   Y1,
   GDATE2,
   X2,
   Y2
)
AS
     SELECT DISTINCT c1.crdid,
                     c1.deviceid,
                     c1.gdate1,
                     c1.x1,
                     c1.y1,
                     c1.gdate2,
                     c2.longtitude x2,
                     c2.latitude y2                   /*, c1.l, c1.v, c1.a  */
       FROM (SELECT DISTINCT
                    c.crdid,
                    c.deviceid,
                    c.gdate gdate1,
                    c.longtitude x1,
                    c.latitude y1                         /*, c.l, c.v, c.a,*/
                                 ,
                    LEAD (c.gdate, 1) OVER (ORDER BY deviceid, gdate) gdate2
               FROM coordinate c             --order  by 1 c.deviceid, c.gdate
                                ) c1,
            coordinate c2
      WHERE c1.deviceid = c2.deviceid AND c1.gdate2 = c2.gdate
   ORDER BY crdid                                          --deviceid, gdate1
;
