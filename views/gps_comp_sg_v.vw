DROP VIEW NAVIGATOR.GPS_COMP_SG_V;

/* Formatted on 04.06.2015 08:41:33 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.GPS_COMP_SG_V
(
   PL_NMB,
   PL_DAT,
   BEG_DAT,
   END_DAT,
   GAR_NMB,
   GOS_NMB,
   GOS_NMBD,
   MARK_NAME,
   CEH,
   NGDU,
   DEVICEID,
   GPS_KM,
   PL_KM,
   OTKL_KM,
   OTKL_PRC,
   MAX_V,
   AVG_V,
   FACT,
   NORM
)
AS
   SELECT pl_nmb,
          pl_dat,
          beg_dat,
          end_dat,
          gar_nmb,
          gos_nmb,
          gos_nmbd,
          mark_name,
          ceh,
          ngdu,
          deviceid,
          gps_km,
          pl_km,
          pl_km - gps_km otkl_km,
          ROUND ( (pl_km - gps_km) / pl_km * 100) otkl_prc,
          max_v,
          avg_v,
          fact,
          norm
     FROM (  SELECT pl1.pl_nmb pl_nmb,
                    pl1.pl_dat pl_dat,
                    pl1.beg_dat,
                    pl1.end_dat,
                    pl1.gar_nmb gar_nmb,
                    pl1.gos_nmb gos_nmb,
                    pl1.gos_nmbd gos_nmbd,
                    pl1.mark_name,
                    pdrz_cod ceh,
                    atc_nmb ngdu,
                    gps.deviceid,
                    ROUND (SUM (gps.l)) gps_km,
                    AVG (pl1.PROBEG) pl_km,
                    ROUND (MAX (gps.v), 1) max_v,
                    ROUND (AVG (gps.v), 1) avg_v,
                    AVG (pl1.FACT) fact,
                    AVG (pl1.NORM) norm
               FROM                                            --gps_data gps,
                   TABLE (
                       gps.gps_processing_all (
                          TO_DATE ('07.09.2011', 'dd.mm.yyyy'),
                          SYSDATE)) gps,
                    gps_stat3_all_v pl1
              WHERE     TO_NUMBER (gps.deviceid) = pl1.gps_block
                    AND gps.gdate BETWEEN pl1.beg_dat AND pl1.end_dat
                    AND pl1.pl_dat >= TO_DATE ('07.09.2011', 'dd.mm.yyyy')
                    AND gps.v BETWEEN 7 AND 250
           --and pl1.gps_block in (106000, 106007)
           GROUP BY pl1.pl_nmb,
                    pl1.pl_dat,
                    pl1.beg_dat,
                    pl1.end_dat,
                    pl1.gar_nmb,
                    pl1.gos_nmb,
                    pl1.gos_nmbd,
                    pl1.mark_name,
                    pdrz_cod,
                    atc_nmb,
                    gps.deviceid) t1
    WHERE t1.gps_km > 1;
