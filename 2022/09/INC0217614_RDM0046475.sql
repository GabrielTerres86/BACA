begin

    UPDATE CECRED.CRAPLFT SET CRAPLFT.DTVENCTO = TO_DATE('16/09/2022', 'DD/MM/YYYY')
     WHERE CRAPLFT.PROGRESS_RECID IN (
            SELECT craplft.PROGRESS_RECID
              FROM CECRED.tbconv_arrecadacao
                   ,CECRED.crapcon
                   ,CECRED.craplft
             WHERE crapcon.cdcooper >= 1 AND crapcon.cdempcon = tbconv_arrecadacao.cdempcon 
               AND crapcon.cdsegmto = tbconv_arrecadacao.cdsegmto  AND crapcon.tparrecd = tbconv_arrecadacao.tparrecadacao
               AND crapcon.cdcooper = craplft.cdcooper AND crapcon.cdempcon = craplft.cdempcon 
               AND crapcon.cdsegmto = craplft.cdsegmto AND crapcon.cdhistor = craplft.cdhistor
               AND craplft.DTMVTOLT >= TO_DATE('05/09/2022', 'DD/MM/YYYY') AND craplft.DTMVTOLT < TO_DATE('07/09/2022' , 'DD/MM/YYYY')
               AND crapcon.tparrecd = 2 AND craplft.insitfat = 1
               AND craplft.CDEMPCON <> 432
    );

  commit;
end;