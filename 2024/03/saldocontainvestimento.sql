DECLARE
vr_cdprograma   VARCHAR2(50) := 'SCRIPT-LCI';
rw_crapdat      btch0001.cr_crapdat%rowtype;
pr_cdcooper     NUMBER := 1;
vr_vllanmto     NUMBER(25,2) := 150.74;
vr_exc_saida    EXCEPTION;
vr_idprglog     NUMBER;
vr_dscritic     VARCHAR(4000);
pr_nrdconta     NUMBER := 84620340;

CURSOR cr_crapsli(pr_cdcooper IN crapsli.cdcooper%TYPE
                 ,pr_nrdconta IN crapsli.nrdconta%TYPE
                 ,pr_dtrefere IN crapsli.dtrefere%TYPE) IS
        SELECT
          sli.cdcooper
         ,sli.nrdconta
         ,sli.dtrefere
         ,sli.vlsddisp
         ,sli.rowid
        FROM
          crapsli sli
        WHERE
              sli.cdcooper = pr_cdcooper
          AND sli.nrdconta = pr_nrdconta
          AND sli.dtrefere = pr_dtrefere;

      rw_crapsli cr_crapsli%ROWTYPE;
  
BEGIN
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;          
  CLOSE BTCH0001.cr_crapdat;
 
  OPEN cr_crapsli(pr_cdcooper => pr_cdcooper
                 ,pr_nrdconta => pr_nrdconta
                 ,pr_dtrefere => rw_crapdat.dtultdia);
  FETCH cr_crapsli INTO rw_crapsli;
  IF (rw_crapsli.vlsddisp - vr_vllanmto) <= 0 THEN
    vr_dscritic := 'Saldo menor que zero: ' || rw_crapsli.vlsddisp;
    RAISE vr_exc_saida;
  ELSE
    BEGIN
      UPDATE cecred.crapsli
         SET vlsddisp = vlsddisp - vr_vllanmto
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND dtrefere = rw_crapdat.dtultdia;

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir registro na CRAPSLI. Erro: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  END IF;
  COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 222,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;
    WHEN OTHERS THEN
      vr_dscritic := 'Erro nao especificado! ' || SQLERRM;
      CECRED.pc_log_programa(pr_dstiplog   => 'O',
                             pr_dsmensagem => vr_dscritic,
                             pr_cdmensagem => 333,
                             pr_cdprograma => vr_cdprograma,
                             pr_cdcooper   => 3,
                             pr_idprglog   => vr_idprglog); 
      ROLLBACK;                
END;
