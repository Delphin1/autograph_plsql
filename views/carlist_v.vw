DROP VIEW NAVIGATOR.CARLIST_V;

/* Formatted on 04.06.2015 08:41:30 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.CARLIST_V
(
   DEVICEID,
   LLS1TARE,
   LLS2TARE
)
AS
   WITH t
        AS (SELECT DECODE (SUBSTR (t.tmp_str, 1, 1), '[', t.tmp_str) deviceid,
                   DECODE (SUBSTR (t.tmp_str, 1, 9),
                           'LLS1Tare=', SUBSTR (t.tmp_str, 10))
                      LLS1Tare,
                   DECODE (SUBSTR (t.tmp_str, 1, 9),
                           'LLS2Tare=', SUBSTR (t.tmp_str, 10))
                      LLS2Tare
              --,t.tmp_str
              --, instr(t.tmp_str, 'LLS1Tare=')
              FROM carlisttmp t)
     SELECT MAX (id) AS deviceid,
            MAX (LLS1Tare) AS LLS1Tare,
            MAX (LLS2Tare) AS LLS2Tare
       FROM (SELECT t.*,
                    TO_NUMBER (SUBSTR (t.deviceid, 2, 7)) id,
                    ROW_NUMBER ()
                    OVER (
                       PARTITION BY CASE
                                       WHEN deviceid IS NOT NULL
                                       THEN
                                          'deviceid'
                                       WHEN LLS1Tare IS NOT NULL
                                       THEN
                                          'LLS1Tare'
                                       WHEN LLS2Tare IS NOT NULL
                                       THEN
                                          'LLS2Tare'
                                    END
                       ORDER BY COALESCE (deviceid, LLS1Tare, LLS2Tare))
                       AS rn
               FROM t) v
   GROUP BY rn;
