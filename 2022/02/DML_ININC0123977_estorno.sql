
DECLARE 
 
  vr_cdcooper    NUMBER := 9;
  vr_nrdconta    NUMBER := 508870;
  vr_nrctremp    NUMBER := 10012786;
  vr_dtmvtolt    DATE := to_date('23/01/2022','DD/MM/RRRR');
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  vr_cdhistor    NUMBER;
  vr_cdagenci    NUMBER       := 1;
  vr_cdoperad    VARCHAR2(10) := 1;
  vr_nmdatela    VARCHAR2(10) := 'ESTPRJ';
  vr_nrdolote    NUMBER       := 0;
  vr_vltaxas     NUMBER       := 0;
  vr_vljuros     NUMBER       := 0;
     
  
  -- Excessões
  vr_exc_erro    EXCEPTION;
  vr_des_erro    VARCHAR2(4000);     
  vr_des_reto    VARCHAR2(500);
  vr_tab_erro    gene0001.typ_tab_erro ;
  vr_cdcritic    NUMBER(3);
  vr_dscritic    VARCHAR2(1000);
  
  CURSOR cr_craplcm_adp (pr_cdcooper IN NUMBER,
                         pr_nrdconta IN NUMBER,
                         pr_dtmvtolt IN DATE )IS
    SELECT x.cdhistor
          ,SUM(x.vllanmto) vllanmto
      FROM craplcm x
     WHERE x.cdcooper = pr_cdcooper
       AND x.nrdconta = pr_nrdconta
       AND x.dtmvtolt > pr_dtmvtolt
       AND x.cdhistor IN (37, 2323)
     GROUP BY x.cdhistor;
     
  -- Buscar proximo Lote
  CURSOR c_busca_prx_lote(pr_dtmvtolt DATE
                         ,pr_cdcooper NUMBER
                         ,pr_cdagenci NUMBER) IS
    SELECT MAX(nrdolote) nrdolote
      FROM craplot
     WHERE craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdcooper = pr_cdcooper
       AND craplot.cdagenci = pr_cdagenci;
  

begin
  
  
  /* Busca data de movimento */
  open btch0001.cr_crapdat(vr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  close btch0001.cr_crapdat;
  
  
  OPEN c_busca_prx_lote(pr_dtmvtolt => RW_CRAPDAT.DTMVTOLT
                       ,pr_cdcooper => vr_cdcooper
                       ,pr_cdagenci => vr_cdagenci);
  fetch c_busca_prx_lote into vr_nrdolote;
  close c_busca_prx_lote;

  vr_nrdolote := nvl(vr_nrdolote,0) + 1;
                            
  FOR rw_craplcm_adp IN cr_craplcm_adp (pr_cdcooper => vr_cdcooper,
                                        pr_nrdconta => vr_nrdconta,
                                        pr_dtmvtolt => vr_dtmvtolt) LOOP
 
    IF rw_craplcm_adp.cdhistor = 37 THEN
      vr_cdhistor := 1667;
    ELSIF rw_craplcm_adp.cdhistor = 2323 THEN
      vr_cdhistor := 2649 ;
    ELSE  
      vr_dscritic := 'Historico nao mapeado, estorno de cc nao ocorrerá';
      raise vr_exc_erro;      
    END IF;    

    empr0001.pc_cria_lancamento_cc(pr_cdcooper => vr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_cdbccxlt => 100
                                  ,pr_cdoperad => '1'
                                  ,pr_cdpactra => vr_cdagenci
                                  ,pr_nrdolote => vr_nrdolote
                                  ,pr_nrdconta => vr_nrdconta
                                  ,pr_cdhistor => vr_cdhistor
                                  ,pr_vllanmto => rw_craplcm_adp.vllanmto
                                  ,pr_nrparepr => 0
                                  ,pr_nrctremp => vr_nrctremp
                                  ,pr_nrseqava => 0
                                  ,pr_idlautom => 0
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro );

    IF vr_des_reto <> 'OK' THEN
      IF vr_tab_erro.count() > 0 THEN
        -- Atribui críticas às variaveis
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := 'Falha estorno '||vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Falha ao Estornar '||sqlerrm;
        raise vr_exc_erro;
      END IF;
    END IF;

   
  END LOOP;                                         

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic);
  WHEN OTHERS THEN
    
    vr_dscritic := 'Erro ao estornar '||vr_dscritic;
    raise_application_error(-20500,vr_dscritic);  
    
END;
