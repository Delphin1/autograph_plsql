DROP VIEW NAVIGATOR.GPS_STAT3_ALL_V;

/* Formatted on 04.06.2015 08:41:34 (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW NAVIGATOR.GPS_STAT3_ALL_V
(
   SCOD,
   ATC_NMB,
   GAR_SCOD,
   GAR_NMB,
   GOS_NMB,
   GOS_NMBD,
   PDRZ_COD,
   PDRZ_NAME,
   MARK_NAME,
   UST_DAT,
   DEMONT_DAT,
   OBOR_NAME,
   GPS_BLOCK,
   PL_SCOD,
   PL_NMB,
   PL_DAT,
   MONTH_PL,
   BEG_WRKH,
   BEG_WRKM,
   PL_DAT_ET,
   END_WRKH,
   END_WRKM,
   PROBEG,
   FACT,
   NORM,
   BEG_TOPL,
   IN_TOPL,
   END_TOPL,
   OUT_TOPL,
   BEG_DAT,
   END_DAT
)
AS
   SELECT pl_scod scod,
          ATC_NMB,
          GAR_SCOD,
          GAR_NMB,
          GOS_NMB,
          GOS_NMBD,
          PDRZ_COD,
          PDRZ_NAME,
          MARK_NAME,
          UST_DAT,
          DEMONT_DAT,
          OBOR_NAME,
          GPS_BLOCK,
          PL_SCOD,
          PL_NMB,
          PL_DAT,
          MONTH_PL,
          BEG_WRKH,
          BEG_WRKM,
          PL_DAT_ET,
          END_WRKH,
          END_WRKM,
          PROBEG,
          FACT,
          NORM,
          beg_topl,
          in_topl,
          end_topl,
          out_topl,
          CASE
             WHEN ATC_NMB = 1 AND gos_nmb NOT IN ('р708нн', 'р722нн')
             THEN
                beg_dat - 2 / 24
             ELSE
                beg_dat
          END
             beg_dat,
          --decode(ATC_NMB, 1, beg_dat-2/24, beg_dat) beg_dat2,
          CASE
             WHEN ATC_NMB = 1 AND gos_nmb NOT IN ('р708нн', 'р722нн')
             THEN
                end_dat - 2 / 24
             ELSE
                end_dat
          END
             end_dat
     --decode(ATC_NMB, 1, end_dat-2/24, end_dat) end_dat
     FROM (SELECT pl.pl_scod scod,
                  pl."ATC_NMB",
                  pl."GAR_SCOD",
                  pl."GAR_NMB",
                  pl."GOS_NMB",
                  pl."GOS_NMBD",
                  pl."PDRZ_COD",
                  pl."PDRZ_NAME",
                  pl."MARK_NAME",
                  pl."UST_DAT",
                  pl."DEMONT_DAT",
                  pl."OBOR_NAME",
                  pl."GPS_BLOCK",
                  pl."PL_SCOD",
                  pl."PL_NMB",
                  pl."PL_DAT",
                  pl."MONTH_PL",
                  pl."BEG_WRKH",
                  pl."BEG_WRKM",
                  pl."PL_DAT_ET",
                  pl."END_WRKH",
                  pl."END_WRKM",
                  pl."PROBEG",
                  pl."FACT",
                  pl."NORM",
                  beg_topl,
                  in_topl,
                  end_topl,
                  out_topl,
                  pl.pl_dat + pl.beg_wrkh / 24 + pl.beg_wrkm / 24 / 60
                     beg_dat,
                  pl.pl_dat_et + pl.end_wrkh / 24 + pl.end_wrkm / 24 / 60
                     end_dat
             FROM gps_stat3_all@abtsaup pl);
