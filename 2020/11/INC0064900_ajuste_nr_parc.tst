PL/SQL Developer Test script 3.0
164
declare
  vr_cdcooper crappep.cdcooper%TYPE := 2;
  vr_nrdconta crappep.nrdconta%TYPE := 761095;
  vr_nrctremp crappep.nrctremp%TYPE := 274894;  
  vr_vlempres crapepr.vlemprst%TYPE := 3716.64;
  
  CURSOR cr_crapepr IS 
     SELECT t.vlsdeved
          , t.cdlcremp
          , t.cdfinemp
          , t.dtdpagto
       FROM crapepr t
      WHERE t.cdcooper = vr_cdcooper
        AND t.nrdconta = vr_nrdconta
        AND t.nrctremp = vr_nrctremp;
  
  rw_crapepr cr_crapepr%ROWTYPE;

  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_tab_parc_epr empr0018.typ_tab_parc_epr;
  vr_tab_erro gene0001.typ_tab_erro;
  
  vr_des_erro VARCHAR2(100);
  vr_des_reto VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);

  vr_cdcritic INTEGER := 0.0;
  vr_qtdiacar INTEGER := 0.0;
  vr_vlajuepr INTEGER := 0.0;
  vr_txdiaria INTEGER := 0.0;
  vr_txmensal INTEGER := 0.0;
  
  vr_exc_erro EXCEPTION;  
  
BEGIN
  vr_tab_parc_epr.delete;
  IF vr_tab_parc_epr.first > 0 THEN
     dbms_output.put_line(vr_tab_parc_epr(1).vlparepr);
     vr_tab_parc_epr.delete;
  END IF;
  
  OPEN cr_crapepr;
  FETCH cr_crapepr INTO rw_crapepr;
  CLOSE cr_crapepr;
  
  OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  CLOSE BTCH0001.cr_crapdat;
  
  -- Calcula o valor das parcelas
  EMPR0018.pc_calcula_emprestimo(pr_cdcooper => vr_cdcooper,
                                 pr_cdagenci => 1,
                                 pr_nrdcaixa => 1,
                                 pr_cdoperad => 1,
                                 pr_nmdatela => 'ATENDA',
                                 pr_cdorigem => 5,
                                 pr_nrdconta => vr_nrdconta,
                                 pr_idseqttl => 1,
                                 pr_flgerlog => FALSE,
                                 pr_nrctremp => vr_nrctremp,
                                 pr_cdlcremp => rw_crapepr.cdlcremp,
                                 pr_cdfinemp => rw_crapepr.cdfinemp,
                                 pr_vlemprst => vr_vlempres,
                                 pr_qtparepr => 10,
                                 pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_dtdpagto => rw_crapepr.dtdpagto,
                                 pr_flggrava => FALSE,
                                 pr_dtlibera => rw_crapdat.dtmvtolt,
                                 pr_idfiniof => 0,
                                 pr_qtdiacar => vr_qtdiacar,
                                 pr_vlajuepr => vr_vlajuepr,
                                 pr_txdiaria => vr_txdiaria,
                                 pr_txmensal => vr_txmensal,
                                 pr_tparcepr => vr_tab_parc_epr,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_des_erro => vr_des_erro,
                                 pr_des_reto => vr_des_reto,
                                 pr_tab_erro => vr_tab_erro);
  
  -- Delete as PEP que serão recalculadas    
  BEGIN
    DELETE CRAPPEP pep 
     WHERE pep.cdcooper = vr_cdcooper
       AND pep.nrdconta = vr_nrdconta
       AND pep.nrctremp = vr_nrctremp
       AND pep.nrparepr > 2;
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao excluir crappep.'||sqlerrm;
      RAISE vr_exc_erro;
  END;                   
  
  -- Reinsere as parcelas 
  FOR I IN 1 .. vr_tab_parc_epr.COUNT LOOP
    BEGIN
      INSERT INTO crappep(cdcooper
                         ,nrdconta
                         ,nrctremp
                         ,nrparepr
                         ,vlparepr
                         ,vlsdvpar
                         ,vlsdvsji
                         ,dtvencto
                         ,inliquid)
                   VALUES(vr_cdcooper
                         ,vr_nrdconta
                         ,vr_nrctremp
                         ,vr_tab_parc_epr(i).nrparepr + 2 -- Pra começar da parcela 3
                         ,vr_tab_parc_epr(i).vlparepr
                         ,vr_tab_parc_epr(i).vlparepr
                         ,vr_tab_parc_epr(i).vlparepr
                         ,vr_tab_parc_epr(i).dtvencto
                         ,0);
                               
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao incluir parcela na crappep.'||sqlerrm;
        RAISE vr_exc_erro; 
    END; 
  END LOOP;
  
  -- Atualiza a crawepr
  BEGIN
      UPDATE crawepr
         SET crawepr.qtpreemp = 12
            ,crawepr.vlpreemp = vr_tab_parc_epr(1).vlparepr
       WHERE crawepr.cdcooper = vr_cdcooper
         AND crawepr.nrdconta = vr_nrdconta
         AND crawepr.nrctremp = vr_nrctremp; 
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a crawepr.'||sqlerrm;
        RAISE vr_exc_erro;    
    END;

  -- Atualiza a crapepr
  BEGIN
      UPDATE crapepr
         SET crapepr.vlpreemp = vr_tab_parc_epr(1).vlparepr
            ,crapepr.qtpreemp = 12
       WHERE crapepr.cdcooper = vr_cdcooper
         AND crapepr.nrdconta = vr_nrdconta
         AND crapepr.nrctremp = vr_nrctremp; 
    EXCEPTION 
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a crawepr.'||sqlerrm;
        RAISE vr_exc_erro;    
    END;

    COMMIT;
    
EXCEPTION
  WHEN vr_exc_erro THEN
    dbms_output.put_line('Erro: '|| vr_dscritic);
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||vr_dscritic);    

  WHEN OTHERS THEN
    dbms_output.put_line('Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));
    ROLLBACK;
    dbms_output.put_line('Efetuado Rollback.');
    Raise_Application_Error(-20002,'Erro Geral no Script. Erro: '||SubStr(SQLERRM,1,255));    
end;
0
1
vr_tab_parc_epr(1).vlparepr
