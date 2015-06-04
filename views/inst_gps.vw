DROP VIEW NAVIGATOR.INST_GPS;

/* Formatted on 04.06.2015 08:41:35 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.INST_GPS
(
   GAR_SCOD,
   GAR_NMB,
   GOS_NMB,
   GOS_NMBD,
   ATC_NMB,
   PDRZ_COD,
   PDRZ_NAME,
   MARK_NAME,
   GPS_BLOCK,
   UST_DAT,
   DEMONT_DAT
)
AS
   SELECT DISTINCT gps.gar_scod,
                   gps.gar_nmb,
                   gps.gos_nmb,
                   gps.gos_nmbd,
                   gps.atc_nmb,
                   gps.pdrz_cod,
                   gps.pdrz_name,
                   gps.mark_name,
                   gps.gps_block,
                   gps.ust_dat,
                   gps.demont_dat
     FROM gps_stat3_all_mv gps
    WHERE SYSDATE BETWEEN gps.ust_dat
                      AND NVL (gps.demont_dat,
                               TO_DATE ('01.01.2099', 'dd.mm.yyyy'));
