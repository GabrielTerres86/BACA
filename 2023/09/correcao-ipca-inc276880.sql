DECLARE
  vr_cdcooper   craplac.cdcooper%TYPE := 10;
  vr_cdprograma tbgen_prglog.cdprograma%type := 'INC0276880';
  
  vr_vllanmto  craplac.vllanmto%TYPE;
  vr_dslog     tbgen_prglog_ocorrencia.dsmensagem%TYPE;
  vr_vlbascal  NUMBER;
  vr_vlsldtot  NUMBER;
  vr_vlsldrgt  NUMBER;
  vr_vlultren  NUMBER;
  vr_vlrentot  NUMBER;
  vr_vlrevers  NUMBER;
  vr_vlrdirrf  NUMBER;
  vr_percirrf  NUMBER;

  vr_cdcritic  crapcri.cdcritic%TYPE := 0;
  vr_dscritic  VARCHAR2(5000) := NULL;
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
  vr_exc_saida EXCEPTION;

  rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;

  CURSOR cr_craprac IS
    SELECT  rac.cdcooper
           ,rac.nrdconta
           ,rac.nraplica
           ,rac.dtmvtolt
           ,rac.idsaqtot
           ,rac.vlbasapl
           ,rac.vlsldatl
           ,rac.dtatlsld
           ,rac.txaplica
           ,rac.qtdiacar
           ,rac.cdprodut
           ,rac.dtaniver
      FROM CECRED.craprac rac
     WHERE rac.cdprodut = 1057
       AND rac.cdcooper = 10
       AND rac.nrdconta = 62766
       AND rac.nraplica = 32;
  rw_craprac cr_craprac%ROWTYPE;

  CURSOR cr_craplac(pr_cdcooper NUMBER
                   ,pr_nrdconta NUMBER
                   ,pr_nraplica NUMBER) IS
    SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lap.vllanmto) vllanmto
      FROM CECRED.craplac lap
          ,CECRED.craphis his
     WHERE lap.cdcooper = his.cdcooper
       AND lap.CDHISTOR = his.CDHISTOR
       AND lap.cdcooper = pr_cdcooper
       AND lap.nrdconta = pr_nrdconta
       AND lap.nraplica = pr_nraplica;
  rw_craplac cr_craplac%ROWTYPE;
  PROCEDURE lancamento_craplac(pr_cdcooper   IN craplac.cdcooper%TYPE
                              ,pr_nrdconta   IN craplac.nrdconta%TYPE
                              ,pr_nraplica   IN craplac.nraplica%TYPE
                              ,pr_dtmvtolt   IN craplac.dtmvtolt%TYPE
                              ,pr_vllanmto   IN craplac.vllanmto%TYPE
                              ,pr_cdhistor   IN craplac.cdhistor%TYPE
                              ,pr_flagupdate IN NUMBER
                              ,pr_vlbasapl   IN craprac.vlbasapl%TYPE
                              ,pr_vlsldatl   IN craprac.vlsldatl%TYPE
                              ,pr_dtatlsld   IN craprac.dtatlsld%TYPE
                              ,pr_vlupdate   IN craplac.vllanmto%TYPE
                              ,pr_cdcritic   OUT crapcri.cdcritic%TYPE
                              ,pr_dscritic   OUT VARCHAR2) IS
    vr_cdbccxlt craplac.cdbccxlt%TYPE := 100;
    vr_nrdolote craplac.nrdolote%TYPE := 8480;
    vr_nrdocmto craplac.nrdocmto%TYPE;
  BEGIN
    vr_nrdocmto := CECRED.SEQCAPT_CRAPLAC_NRSEQDIG.nextval;
  
    INSERT INTO cecred.craplac
      (cdcooper
      ,dtmvtolt
      ,cdagenci
      ,cdbccxlt
      ,nrdolote
      ,nrdconta
      ,nraplica
      ,nrdocmto
      ,nrseqdig
      ,vllanmto
      ,cdhistor)
    VALUES
      (pr_cdcooper
      ,pr_dtmvtolt
      ,1
      ,vr_cdbccxlt
      ,vr_nrdolote
      ,pr_nrdconta
      ,pr_nraplica
      ,vr_nrdocmto + 555000
      ,NVL(vr_nrdocmto, 0) + 1
      ,pr_vllanmto
      ,pr_cdhistor);
  
    IF pr_flagupdate = 1
    THEN
      UPDATE cecred.craprac
         SET craprac.vlbasant = pr_vlbasapl
            ,craprac.vlsldant = pr_vlsldatl
            ,craprac.dtsldant = pr_dtatlsld
            ,craprac.vlsldatl = pr_vlupdate + pr_vllanmto
            ,craprac.dtatlsld = pr_dtmvtolt
       WHERE craprac.cdcooper = pr_cdcooper
         AND craprac.nrdconta = pr_nrdconta
         AND craprac.nraplica = pr_nraplica;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 999;
      pr_dscritic := 'Erro na procedure lancamento_craplac. Detalhes: ' || SQLERRM;
  END lancamento_craplac;
  
BEGIN
  OPEN cecred.btch0001.cr_crapdat(pr_cdcooper => 10);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;

  IF btch0001.cr_crapdat%NOTFOUND
  THEN
    CLOSE btch0001.cr_crapdat;
    vr_dscritic := 'Erro no carregamento do cursor btch0001.cr_crapdat. Dados nao encontrados.';
    RAISE vr_exc_saida;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;

  FOR rw_craprac IN cr_craprac
  LOOP
    vr_vllanmto := 0;
  
    OPEN cr_craplac(rw_craprac.cdcooper, rw_craprac.nrdconta, rw_craprac.nraplica);
    FETCH cr_craplac
      INTO rw_craplac;
  
    IF cr_craplac%NOTFOUND
    THEN
      CLOSE cr_craplac;
      vr_dscritic := 'Erro no carregamento do cursor cr_craplac. Dados nao encontrados.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplac;
    END IF;
  
    IF rw_craprac.idsaqtot IN (1, 2)
    THEN
      IF rw_craplac.vllanmto < 0
      THEN
        vr_vllanmto := rw_craplac.vllanmto * -1;
        vr_dslog    := 'Saque total realizado, valor de lancamento menor que zero. '
                       || 'Conta: ' || rw_craprac.nrdconta || '; '
                       || 'Aplicacao: ' || rw_craprac.nraplica || '; '
                       || 'Valor original: ' || TO_CHAR(rw_craplac.vllanmto) || '; '
                       || 'Valor a lancar: ' || TO_CHAR(vr_vllanmto) || '; ';
        
        CECRED.pc_log_programa(pr_dstiplog   => 'O',
                               pr_dsmensagem => vr_dslog,
                               pr_cdmensagem => 111,
                               pr_cdprograma => vr_cdprograma,
                               pr_cdcooper   => vr_cdcooper,
                               pr_idprglog   => vr_idprglog);
                               
        lancamento_craplac(pr_cdcooper   => rw_craprac.cdcooper,
                           pr_nrdconta   => rw_craprac.nrdconta,
                           pr_nraplica   => rw_craprac.nraplica,
                           pr_dtmvtolt   => rw_crapdat.dtmvtolt,
                           pr_vllanmto   => vr_vllanmto,
                           pr_cdhistor   => 3328,
                           pr_flagupdate => 0,
                           pr_vlbasapl   => rw_craprac.vlbasapl,
                           pr_vlsldatl   => rw_craprac.vlsldatl,
                           pr_dtatlsld   => rw_craprac.dtatlsld,
                           pr_vlupdate   => 0,
                           pr_cdcritic   => vr_cdcritic,
                           pr_dscritic   => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
      ELSE
        vr_dslog := 'Saque total realizado, valor de lancamento maior que zero. '
                    || 'Conta: ' || rw_craprac.nrdconta || '; '
                    || 'Aplicacao: ' || rw_craprac.nraplica || '; '
                    || 'Valor: ' || TO_CHAR(rw_craplac.vllanmto) || '; ';
                    
        CECRED.pc_log_programa(pr_dstiplog   => 'O',
                               pr_dsmensagem => vr_dslog,
                               pr_cdmensagem => 222,
                               pr_cdprograma => vr_cdprograma,
                               pr_cdcooper   => vr_cdcooper,
                               pr_idprglog   => vr_idprglog);
        CONTINUE;
      END IF;
    ELSE
      BEGIN
        UPDATE cecred.craprac
           SET craprac.vlsldatl = rw_craplac.vllanmto
         WHERE craprac.cdcooper = rw_craprac.cdcooper
           AND craprac.nrdconta = rw_craprac.nrdconta
           AND craprac.nraplica = rw_craprac.nraplica;      
        EXCEPTION
        WHEN OTHERS THEN         
          vr_dscritic := 'Erro na procedure lancamento_craplac. Detalhes: ' || SQLERRM; 
          RAISE vr_exc_saida;
      END;
    END IF;
  END LOOP;
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_saida THEN
    IF vr_cdcritic <> 0
    THEN
      vr_dscritic := 'Erro ao rodar script : ' 
                     || gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                     || '. Detalhes: '
                     || vr_dscritic;
    END IF;
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 777,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => vr_cdcooper,
                           pr_idprglog   => vr_idprglog);
  
  WHEN OTHERS THEN
    vr_dscritic := 'Erro nao tratado ao rodar script : ' || SQLERRM;
    
    ROLLBACK;
    
    CECRED.pc_log_programa(pr_dstiplog   => 'O',
                           pr_dsmensagem => vr_dscritic,
                           pr_cdmensagem => 888,
                           pr_cdprograma => vr_cdprograma,
                           pr_cdcooper   => vr_cdcooper,
                           pr_idprglog   => vr_idprglog);
END;
