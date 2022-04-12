DECLARE
  vr_cdCooperativa NUMBER;
  vr_cdPrograma VARCHAR2(20);
  vr_cdCritic NUMBER;
  vr_dscritic VARCHAR2(4000);
BEGIN
  
  vr_cdCooperativa := 14;
  vr_cdPrograma := 'INC0134493';

  UPDATE CECRED.CRAPTAB
     SET DSTEXTAB = '0 1 000,00000001 1 000,00000000 005,27137790 0   0 0 000,24818902 10/04/2018 000,00000000 000,00000000 100,00 100,00 0 000,00000000 0'
   WHERE CDCOOPER = 14
     AND TPTABELA = 'GENERI'
     AND CDACESSO = 'EXEICMIRET';
  
  cecred.sobr0001.pc_calculo_retorno_sobras(pr_cdcooper => vr_cdCooperativa,
                                            pr_cdprogra => vr_cdPrograma,
                                            pr_cdcritic => vr_cdCritic,
                                            pr_dscritic => vr_dscritic);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;