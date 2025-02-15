DECLARE
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  
BEGIN
  
  UPDATE PAGAMENTO.TB_BAIXA_PCR_REMESSA TBPREM SET TBPREM.NRPROGRESS_CRAPTIT = NULL
   WHERE TBPREM.IDBAIXA_PCR_REMESSA in (72617427, 72617667, 72617555, 72617571, 72617700, 72617358, 72617376, 72617715, 72617405,
										72617502, 72617684, 72617736, 72617487, 72617596, 72617652, 72617340, 72617520, 72617538,
										72617633, 72617613);
							
  UPDATE cecred.craptit tit
     SET tit.cdctrbxo = ' '
   WHERE tit.progress_recid IN (246730806, 246730877, 246730900, 246730901, 246737252, 246737264, 246737316, 246737331, 246737332,
								246737428, 246737531, 246738097, 246738123, 246738266, 246738323, 246738934, 246739109, 246739175,
								246739255, 246739598);
								
  COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'INC0353914');
END;  