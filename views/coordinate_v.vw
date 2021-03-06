DROP VIEW NAVIGATOR.COORDINATE_V;

/* Formatted on 04.06.2015 08:41:32 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.COORDINATE_V
(
   DEVICEID,
   DATADATETIME,
   LATITUDE,
   LONGTITUDE,
   LNHDOP,
   HDOP,
   VALIDTIME,
   SOURCE,
   POWER,
   RESERVPOWER,
   ANTENNA1,
   ANTENNA2,
   SATCOUNT,
   SPEED,
   AZIMUT,
   ALTITUDE,
   IN1,
   IN2,
   IN3,
   IN4,
   IN5,
   IN6,
   IN7,
   IN8,
   FLAG1,
   FLAG2,
   FLAG3,
   FLAG4,
   FLAG5,
   FLAG6,
   FLAG7,
   FLAG8,
   GDATE,
   DELTA_GDATE,
   INSDATE,
   DATE5,
   DATE1,
   DDATE,
   FLAGSID,
   CRDID,
   L,
   V,
   A
)
AS
   SELECT c."DEVICEID",
          c."DATADATETIME",
          c."LATITUDE",
          c."LONGTITUDE",
          c."LNHDOP",
          c."HDOP",
          c."VALIDTIME",
          c."SOURCE",
          c."POWER",
          c."RESERVPOWER",
          c."ANTENNA1",
          c."ANTENNA2",
          c."SATCOUNT",
          c."SPEED",
          c."AZIMUT",
          c."ALTITUDE",
          c."IN1",
          c."IN2",
          c."IN3",
          c."IN4",
          c."IN5",
          c."IN6",
          c."IN7",
          c."IN8",
          c."FLAG1",
          c."FLAG2",
          c."FLAG3",
          c."FLAG4",
          c."FLAG5",
          c."FLAG6",
          c."FLAG7",
          c."FLAG8",
          c."GDATE",
            c.gdate
          - LAG (c.gdate, 1)
               OVER (PARTITION BY deviceid ORDER BY c.deviceid, c.gdate)
             delta_gdate,
          c."INSDATE",
          c."DATE5",
          c."DATE1",
          c.ddate,
          c."FLAGSID",
          c."CRDID",
          c.l,
          c.v,
          c.a
     FROM coordinate c
    WHERE c.a < 9 AND c.v BETWEEN 6.2 AND 250;
