DECLARE
  CURSOR c_vlrDevolver(pr_cdcooper cecred.crapcop.cdcooper%type) IS
  SELECT c.* FROM (
    SELECT 5 as cdcooper, 99963337 as nrdconta, 0.33 as valor FROM DUAL
    UNION ALL
    SELECT 5 as cdcooper, 99995492 as nrdconta, 0.92 as valor FROM DUAL
    UNION ALL
    SELECT 11 as cdcooper, 99924110 as nrdconta, 0.29 as valor FROM DUAL
    UNION ALL
    SELECT 11 as cdcooper, 99981009 as nrdconta, 0.43 as valor FROM DUAL
    UNION ALL
    SELECT 6 as cdcooper, 99986256 as nrdconta, 1.45 as valor FROM DUAL
    UNION ALL
    SELECT 6 as cdcooper, 99988267 as nrdconta, 0.48 as valor FROM DUAL
    UNION ALL
    SELECT 1 as cdcooper, 99995387 as nrdconta, 0.18 as valor FROM DUAL
    UNION ALL
    SELECT 1 as cdcooper, 99995549 as nrdconta, 0.53 as valor FROM DUAL
    UNION ALL
    SELECT 1 as cdcooper, 99999633 as nrdconta, 2.58 as valor FROM DUAL
    UNION ALL
    SELECT 1 as cdcooper, 99999714 as nrdconta, 1.15 as valor FROM DUAL
    ) c
  where c.cdcooper = pr_cdcooper
  ORDER BY c.cdcooper, c.nrdconta;  
  
  CURSOR cr_crapass(pr_cdcooper cecred.crapass.cdcooper%type,
                    pr_nrdconta cecred.crapass.nrdconta%type) IS
    SELECT crapass.inpessoa
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
  rw_crapass                cr_crapass%ROWTYPE;

  rw_crapdat                cecred.btch0001.cr_crapdat%ROWTYPE;  
  
  vr_exc_erro               EXCEPTION;
  vr_cdcritic               cecred.crapcri.cdcritic%type;
  vr_dscritic               cecred.crapcri.dscritic%type;

  vc_cdcooper               CONSTANT cecred.crapcop.cdcooper%type := 11;
  vc_nrdcontaAdm            CONSTANT cecred.crapass.nrdconta%type := 99501112;
  vc_dstransa               CONSTANT VARCHAR2(4000) := 'Reversao ao fundo de Reserva de Valores a Devolver por script - RITM0263297';  
  vc_tpDevolucaoDepVista    CONSTANT cecred.tbcotas_devolucao.tpdevolucao%type := 4;
  vc_tpDevolucaoCotaCapital CONSTANT cecred.tbcotas_devolucao.tpdevolucao%type := 3;
  vc_cdHistorPF             CONSTANT cecred.craphis.cdhistor%type := 4058;
  vc_cdHistorPJ             CONSTANT cecred.craphis.cdhistor%type := 4062;
  vc_cdHistorEstornoPF      CONSTANT cecred.craphis.cdhistor%type := 4059;
  vc_cdHistorEstornoPJ      CONSTANT cecred.craphis.cdhistor%type := 4061;
  
  vr_dtInicioCredito        cecred.tbcotas_devolucao.dtinicio_credito%type;
  vr_vlCapitalDepVista      cecred.tbcotas_devolucao.vlcapital%type;
  vr_vlPagoDepVista         cecred.tbcotas_devolucao.vlpago%type;
  vr_vlCapitalCotaCapital   cecred.tbcotas_devolucao.vlcapital%type;
  vr_vlPagoCotaCapital      cecred.tbcotas_devolucao.vlpago%type;
  vr_vlDevolverDepVista     NUMBER(15,2); 
  vr_vlDevolverCotaCapital  NUMBER(15,2);
  vr_vlTotalDevolver        NUMBER(15,2);
  vr_vlrTransfCota          NUMBER(15,2);
  vr_vlrTransfSobras        NUMBER(15,2);
  vr_vlrTransfPF            NUMBER(15,2);
  vr_vlrTransfPJ            NUMBER(15,2);
  vr_cdagenciAdm            cecred.crapass.cdagenci%type;
  vr_nrdocmto               cecred.craplcm.nrdocmto%type;
  vr_tab_retorno            cecred.lanc0001.typ_reg_retorno;
  vr_incrineg               NUMBER;
  
  vr_dttransa                     cecred.craplgm.dttransa%type;
  vr_hrtransa                     cecred.craplgm.hrtransa%type;
  vr_cdoperad                     cecred.craplgm.cdoperad%TYPE;
  vr_nrdrowid                     ROWID;
  vr_des_reto                     VARCHAR2(3);
  
  
BEGIN
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
  OPEN btch0001.cr_crapdat(pr_cdcooper => vc_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  IF btch0001.cr_crapdat%NOTFOUND THEN
    CLOSE btch0001.cr_crapdat;
    vr_cdcritic := 1;
    RAISE vr_exc_erro;
  ELSE
    CLOSE btch0001.cr_crapdat;
  END IF;  
  
  vr_vlrTransfPF := 0;
  vr_vlrTransfPJ := 0;
  
  FOR rw_vlrDevolver IN c_vlrDevolver(vc_cdcooper) LOOP
    vr_vlrTransfCota := 0;
    vr_vlrTransfSobras := 0;
    
    OPEN cr_crapass(rw_vlrDevolver.cdcooper, rw_vlrDevolver.nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      vr_cdcritic := 9;
      vr_dscritic := NULL;
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;

    CADA0004.pc_buscar_tbcota_devol(pr_cdcooper         => rw_vlrDevolver.CDCOOPER,
                                    pr_nrdconta         => rw_vlrDevolver.NRDCONTA,
                                    pr_tpdevolucao      => vc_tpDevolucaoDepVista,
                                    pr_vlcapital        => vr_vlCapitalDepVista,
                                    pr_dtinicio_credito => vr_dtInicioCredito,
                                    pr_vlpago           => vr_vlPagoDepVista,
                                    pr_cdcritic         => vr_cdcritic,
                                    pr_dscritic         => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;
    vr_dscritic := null;
    
    CADA0004.pc_buscar_tbcota_devol(pr_cdcooper         => rw_vlrDevolver.CDCOOPER,
                                    pr_nrdconta         => rw_vlrDevolver.NRDCONTA,
                                    pr_tpdevolucao      => vc_tpDevolucaoCotaCapital,
                                    pr_vlcapital        => vr_vlCapitalCotaCapital,
                                    pr_dtinicio_credito => vr_dtInicioCredito,
                                    pr_vlpago           => vr_vlPagoCotaCapital,
                                    pr_cdcritic         => vr_cdcritic,
                                    pr_dscritic         => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_erro;
    END IF;
    vr_dscritic := null;

    vr_vlDevolverDepVista    := nvl(vr_vlCapitalDepVista,0) - nvl(vr_vlPagoDepVista,0);
    vr_vlDevolverCotaCapital := nvl(vr_vlCapitalCotaCapital,0) - nvl(vr_vlPagoCotaCapital,0);
    vr_vlTotalDevolver       := vr_vlDevolverDepVista + vr_vlDevolverCotaCapital;    
    
    dbms_output.put_line(''); 
    dbms_output.put_line('Conta: ' || rw_vlrDevolver.NRDCONTA); 
    dbms_output.put_line('Tipo de pessoa: ' || rw_crapass.inpessoa);
    dbms_output.put_line('Valor Dep. Vista: ' || vr_vlDevolverDepVista);
    dbms_output.put_line('Valor Cota Capital: ' || vr_vlDevolverCotaCapital);
    dbms_output.put_line('Valor a Devolver total: ' || vr_vlTotalDevolver);
    dbms_output.put_line('Valor a Transferir: ' || rw_vlrDevolver.valor);
    
    
    CASE
      when vr_vlTotalDevolver = 0 THEN
       dbms_output.put_line('Nao ha Valor a Devolver');
       CONTINUE;
       
      when vr_vlTotalDevolver < rw_vlrDevolver.valor THEN
       dbms_output.put_line('Valor a Devolver menor que valor a Transferir');
       CONTINUE;
      
      when vr_vlTotalDevolver >= rw_vlrDevolver.valor THEN
        
        IF rw_vlrDevolver.valor <= vr_vlDevolverCotaCapital THEN
          vr_vlrTransfCota := rw_vlrDevolver.valor;
          vr_vlrTransfSobras := 0;
        ELSE
          vr_vlrTransfCota := vr_vlDevolverCotaCapital;
          vr_vlrTransfSobras := rw_vlrDevolver.valor - vr_vlDevolverCotaCapital;
        END IF;
        
        CECRED.GENE0001.pc_gera_log(pr_cdcooper => vc_cdcooper,
                                    pr_cdoperad => vr_cdoperad,
                                    pr_dscritic => vr_dscritic,
                                    pr_dsorigem => 'AIMARO',
                                    pr_dstransa => vc_dstransa,
                                    pr_dttransa => vr_dttransa,
                                    pr_flgtrans => 1,
                                    pr_hrtransa => vr_hrtransa,
                                    pr_idseqttl => 0,
                                    pr_nmdatela => NULL,
                                    pr_nrdconta => rw_vlrDevolver.nrdconta,
                                    pr_nrdrowid => vr_nrdrowid);
        
        IF vr_vlrTransfCota > 0 THEN
          CECRED.CADA0004.pc_atualizar_tbcota_devol(pr_cdcooper    => rw_vlrDevolver.CDCOOPER,
                                                    pr_nrdconta    => rw_vlrDevolver.NRDCONTA,
                                                    pr_tpdevolucao => vc_tpDevolucaoCotaCapital,
                                                    pr_vlpago      => vr_vlrTransfCota,
                                                    pr_cdcritic    => vr_cdcritic,
                                                    pr_dscritic    => vr_dscritic);
                                                      
          IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            dbms_output.put_line('Falha ao atualizar valor Cota Capital (CADA0004.pc_atualizar_tbcota_devol): ' || vr_dscritic);
            RAISE vr_exc_erro;
          END IF;
          
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.VLPAGO (Cota = 3)',
                                           pr_dsdadant => nvl(vr_vlPagoCotaCapital,0),
                                           pr_dsdadatu => nvl(vr_vlPagoCotaCapital,0) + vr_vlrTransfCota);
                                       
          dbms_output.put_line('Retirado dos Valores a Devolver de Cota: ' || vr_vlrTransfCota);
        END IF;
        
        IF vr_vlrTransfSobras > 0 THEN
          CECRED.CADA0004.pc_atualizar_tbcota_devol(pr_cdcooper    => rw_vlrDevolver.CDCOOPER,
                                                    pr_nrdconta    => rw_vlrDevolver.NRDCONTA,
                                                    pr_tpdevolucao => vc_tpDevolucaoDepVista,
                                                    pr_vlpago      => vr_vlrTransfSobras,
                                                    pr_cdcritic    => vr_cdcritic,
                                                    pr_dscritic    => vr_dscritic);
                                                      
          IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            dbms_output.put_line('Falha ao atualizar valor Sobras - Dep Vista (CADA0004.pc_atualizar_tbcota_devol): ' || vr_dscritic);
            RAISE vr_exc_erro;
          END IF;
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                           pr_nmdcampo => 'TBCOTAS_DEVOLUCAO.VLPAGO (Sobras/Dep Vista = 4)',
                                           pr_dsdadant => nvl(vr_vlPagoDepVista,0),
                                           pr_dsdadatu => nvl(vr_vlPagoDepVista,0) + vr_vlrTransfSobras);
                                       
          dbms_output.put_line('Retirado dos Valores a Devolver de Sobras/Dep Vista: ' || vr_vlrTransfSobras);
        END IF;        
                
        IF rw_crapass.inpessoa = 1 THEN
          vr_vlrTransfPF := vr_vlrTransfPF + rw_vlrDevolver.valor;
        ELSE
          vr_vlrTransfPJ := vr_vlrTransfPJ + rw_vlrDevolver.valor;  
        END IF;
        
        dbms_output.put_line('Valor sumarizado PF: ' || vr_vlrTransfPF);
        dbms_output.put_line('Valor sumarizado PJ: ' || vr_vlrTransfPJ);
    END CASE;
  END LOOP;
  
  SELECT CDAGENCI
    INTO vr_cdagenciAdm
    FROM CECRED.CRAPASS A
   WHERE a.nrdconta = vc_nrdcontaAdm
     AND a.cdcooper = vc_cdcooper;
   
     
   IF nvl(vr_vlrTransfPF,0) > 0 THEN
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
    cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                             ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                             ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                             ,pr_cdbccxlt    => 1
                                             ,pr_nrdolote    => vc_cdHistorPF
                                             ,pr_nrdctabb    => vc_nrdcontaAdm
                                             ,pr_nrdocmto    => vr_nrdocmto
                                             ,pr_cdhistor    => vc_cdHistorPF
                                             ,pr_vllanmto    => vr_vlrTransfPF
                                             ,pr_nrdconta    => vc_nrdcontaAdm
                                             ,pr_hrtransa    => gene0002.fn_busca_time
                                             ,pr_inprolot    => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                             ,pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                             ,pr_incrineg    => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                             ,pr_cdcritic    => vr_cdcritic      -- OUT
                                             ,pr_dscritic    => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)

      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        dbms_output.put_line('Falha ao lancar valor PF na Conta Administrativa (Lanc0001.pc_gerar_lancamento_conta): ' || vr_dscritic);
        RAISE vr_exc_erro;
      END IF;
      
      vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
      cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                               ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                               ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                               ,pr_cdbccxlt    => 1
                                               ,pr_nrdolote    => vc_cdHistorEstornoPF
                                               ,pr_nrdctabb    => vc_nrdcontaAdm
                                               ,pr_nrdocmto    => vr_nrdocmto
                                               ,pr_cdhistor    => vc_cdHistorEstornoPF
                                               ,pr_vllanmto    => vr_vlrTransfPF
                                               ,pr_nrdconta    => vc_nrdcontaAdm
                                               ,pr_hrtransa    => gene0002.fn_busca_time
                                               ,pr_inprolot    => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                               ,pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                               ,pr_incrineg    => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                               ,pr_cdcritic    => vr_cdcritic      -- OUT
                                               ,pr_dscritic    => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)

      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        dbms_output.put_line('Falha ao lancar valor PF na Conta Administrativa (Lanc0001.pc_gerar_lancamento_conta): ' || vr_dscritic);
        RAISE vr_exc_erro;
      END IF;
   END IF;  
   
   IF nvl(vr_vlrTransfPJ,0) > 0 THEN 
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
     cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                              ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                              ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                              ,pr_cdbccxlt    => 1
                                              ,pr_nrdolote    => vc_cdHistorPJ
                                              ,pr_nrdctabb    => vc_nrdcontaAdm
                                              ,pr_nrdocmto    => vr_nrdocmto
                                              ,pr_cdhistor    => vc_cdHistorPJ
                                              ,pr_vllanmto    => vr_vlrTransfPJ
                                              ,pr_nrdconta    => vc_nrdcontaAdm
                                              ,pr_hrtransa    => gene0002.fn_busca_time
                                              ,pr_inprolot    => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                              ,pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                              ,pr_incrineg    => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                              ,pr_cdcritic    => vr_cdcritic      -- OUT
                                              ,pr_dscritic    => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)

     IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       dbms_output.put_line('Falha ao lancar valor PF na Conta Administrativa (Lanc0001.pc_gerar_lancamento_conta): ' || vr_dscritic);
       RAISE vr_exc_erro;
     END IF;
      
     vr_nrdocmto := vc_cdcooper || vc_nrdcontaAdm || TO_NUMBER(gene0002.fn_mask(TO_CHAR(SYSTIMESTAMP, 'FF'),'9999999999')); 
     cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => vc_cdcooper
                                              ,pr_dtmvtolt    => rw_crapdat.DTMVTOLT
                                              ,pr_cdagenci    => nvl(vr_cdagenciAdm,0)
                                              ,pr_cdbccxlt    => 1
                                              ,pr_nrdolote    => vc_cdHistorEstornoPJ
                                              ,pr_nrdctabb    => vc_nrdcontaAdm
                                              ,pr_nrdocmto    => vr_nrdocmto
                                              ,pr_cdhistor    => vc_cdHistorEstornoPJ
                                              ,pr_vllanmto    => vr_vlrTransfPJ
                                              ,pr_nrdconta    => vc_nrdcontaAdm
                                              ,pr_hrtransa    => gene0002.fn_busca_time
                                              ,pr_inprolot    => 1 -- Indica se a procedure deve processar (incluir/atualizar) o LOTE (CRAPLOT)
                                              ,pr_tab_retorno => vr_tab_retorno -- OUT Record com dados retornados pela procedure
                                              ,pr_incrineg    => vr_incrineg      -- OUT Indicador de cr?tica de neg?cio
                                              ,pr_cdcritic    => vr_cdcritic      -- OUT
                                              ,pr_dscritic    => vr_dscritic);    -- OUT Nome da tabela onde foi realizado o lan?amento (CRAPLCM, conta transit?ria, etc)

     IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       dbms_output.put_line('Falha ao lancar valor PF na Conta Administrativa (Lanc0001.pc_gerar_lancamento_conta): ' || vr_dscritic);
       RAISE vr_exc_erro;
     END IF;
   END IF; 
   
   COMMIT;
     
EXCEPTION
  WHEN vr_exc_erro THEN      
    IF (vr_dscritic IS NULL) THEN
      vr_dscritic := cecred.GENE0001.fn_busca_critica(vr_cdcritic);
    END IF;
    vr_dscritic := to_char(sysdate,'hh24:mi:ss') || vr_dscritic;
    
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro - vr_cdcritic: ' || vr_cdcritic || ' - ' || vr_dscritic); 
        
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro: ' || sqlerrm);
END;    
