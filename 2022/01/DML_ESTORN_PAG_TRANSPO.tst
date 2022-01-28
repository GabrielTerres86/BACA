PL/SQL Developer Test script 3.0
313
-- Created on 28/01/2022 by F0032386 
DECLARE 
 
  vr_cdcooper    NUMBER := 9;
  vr_nrdconta    NUMBER := 508870;
  vr_nrctremp    NUMBER := 10012786;
  vr_dtmvtolt    DATE := to_date('23/12/2021','DD/MM/RRRR');
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
  
  PROCEDURE pc_estorno_pagamento_web ( pr_cdcooper IN NUMBER 
                                      ,pr_nrdconta IN VARCHAR2  -- Conta corrente
                                      ,pr_nrctremp IN VARCHAR2  -- contrato
                                      ,pr_dtmvtolt IN varchar2
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ) IS 

     
     -- Variáveis
    
     rw_crapdat     btch0001.cr_crapdat%rowtype;
     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_inprejuz    integer;

     

     CURSOR cr_crapepr(pr_cdcooper in number
                      ,pr_nrdconta in number
                      ,pr_nrctremp in number) IS
        SELECT *
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
     cursor c_busca_abono is
        select 1
        from   craplem lem
        where  lem.cdcooper = pr_cdcooper
        and    lem.nrdconta = pr_nrdconta
        and    lem.nrctremp = pr_nrctremp
        and    lem.dtmvtolt > rw_crapdat.dtultdma
        and    lem.dtmvtolt <= rw_crapdat.dtultdia
        and    lem.cdhistor = 2391
        and not exists (select 1 from craplem t
                           where t.dtmvtolt > lem.dtmvtolt
                             and t.cdcooper = lem.cdcooper
                             and t.nrdconta = lem.nrdconta
                             and t.nrctremp = lem.nrctremp
                             and t.vllanmto = lem.vllanmto
                             and t.cdhistor = 2395); -- abono


        vr_existe_abono integer := 0;

  BEGIN


    /* Busca data de movimento */
    open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    close btch0001.cr_crapdat;

    /*Busca informações do emprestimo */
    open cr_crapepr(pr_cdcooper => pr_cdcooper
                     , pr_nrdconta => pr_nrdconta
                     , pr_nrctremp => pr_nrctremp);

    fetch cr_crapepr into rw_crapepr;
    if cr_crapepr%found then
       vr_inprejuz := rw_crapepr.inprejuz;
    end if;
    close cr_crapepr;

    /* Verifica se possui abono ativo, não pode efetuar o estorno do pagamento */
    open c_busca_abono;
    fetch c_busca_abono into vr_existe_abono;
    close c_busca_abono;

    if nvl(vr_existe_abono,0) = 1 then
       vr_des_erro := 'Não é permitido efetuar o estorno do pagamento pois existe um lançamento de abono.';
       raise vr_exc_erro;
    end if;

    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0002-Efetuando estorno da transferencia para prejuizo, Cooper: ' || pr_cdcooper ||
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || rw_crapepr.tpemprst || ', Data: ' || pr_dtmvtolt ;


    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'INTRANET'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    

    if nvl(vr_inprejuz,2) = 1 then
      prej0002.pc_estorno_pagamento(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_dtmvtolt => to_date(pr_dtmvtolt,'dd/mm/yyyy')
                           ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                           ,pr_tab_erro => vr_tab_erro);
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_des_erro := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_cdcritic := 0;
          vr_des_erro := 'Não foi possivel executar estorno do Pagamento do Prejuízo.';
        END IF;
        RAISE vr_exc_erro;
      END IF;
    ELSE
       vr_des_erro := 'Contrato não está em prejuízo !';
       raise vr_exc_erro;
    END IF;

    vr_dstransa := 'PREJ0002-Estorno da transferência para prejuizo, referente contrato: ' || pr_nrctremp ||', realizada com sucesso.';
    -- Gerando Log de Consulta
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
   
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      if vr_des_erro is null then
         vr_des_erro := 'Erro na rotina pc_estorno_prejuizo: ';
      end if;
      pr_dscritic := vr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0002-Estorno transferencia para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
     
      
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      vr_des_erro := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
      pr_dscritic := vr_des_erro;
      pr_cdcritic := 0;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0002-Estorno da Transferência Prejuízo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      

  END pc_estorno_pagamento_web;
  

begin
  

  pc_estorno_pagamento_web ( pr_cdcooper => vr_cdcooper
                            ,pr_nrdconta => vr_nrdconta
                            ,pr_nrctremp => vr_nrctremp
                            ,pr_dtmvtolt => vr_dtmvtolt
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);
                          
   COMMIT;
  
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
        vr_dscritic := 'Falha estorno Pagamento '||vr_tab_erro(vr_tab_erro.first).dscritic;
        RAISE vr_exc_erro;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Falha ao Estornar Pagamento '||sqlerrm;
        raise vr_exc_erro;
      END IF;
    END IF;

   
  END LOOP;                                         

  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20500,vr_cdcritic||'-'||vr_dscritic);
  WHEN OTHERS THEN
    
    vr_dscritic := 'Erro ao estornar pagamento '||vr_dscritic;
    raise_application_error(-20500,vr_dscritic);  
    
END;
0
0
