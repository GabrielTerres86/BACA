  declare
      -- Local variables here
      CURSOR cr_tbepr_adiamento_contrato (pr_dtmvtoan IN crapdat.dtmvtoan%TYPE)IS
        select distinct 
               tbepr_adiamento_contrato.cdcooper, 
               tbepr_adiamento_contrato.nrdconta, 
               tbepr_adiamento_contrato.nrctremp,
               crapepr.dtdpagto,
               crapepr.diarefju,
               crapepr.mesrefju,
               crapepr.anorefju,
               crawepr.dtlibera,
               crapepr.vlsdeved,
               crapepr.vlpreemp,
               crapepr.txjuremp,
               (select max(crappep.nrparepr)       
                  from crappep
                 where crappep.cdcooper = crapepr.cdcooper
                   and crappep.nrdconta = crapepr.nrdconta
                   and crappep.nrctremp = crapepr.nrctremp
                   and crappep.inliquid = 0) ultima_parcela
          from tbepr_adiamento_contrato
          JOIN crapepr
            ON crapepr.cdcooper = tbepr_adiamento_contrato.cdcooper
           AND crapepr.nrdconta = tbepr_adiamento_contrato.nrdconta
           AND crapepr.nrctremp = tbepr_adiamento_contrato.nrctremp
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
         WHERE crapepr.inliquid = 0
           AND crapepr.dtdpagto > pr_dtmvtoan
           and crapepr.cdcooper IN (9,13,7,8);
      
      -- Variável genérica de calendário com base no cursor da btch0001
      rw_crapdat         btch0001.cr_crapdat%ROWTYPE;
      vr_tab_erro        gene0001.typ_tab_erro;    
      vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
      vr_tab_calculado   empr0001.typ_tab_calculado;
      vr_vlparepr        NUMBER(25,2);
    
      -- Variaveis sistemas
      vr_vljurmes        NUMBER(25,2);
      vr_residuo         NUMBER(25,2);
      vr_texto_completo  CLOB;
      vr_des_log         CLOB;
      vr_dsdireto        VARCHAR2(1000);
    
      -- Variavel tratamento de erro
      vr_dscritic        VARCHAR2(1000);
      vr_exc_erro        EXCEPTION;
      vr_des_reto        VARCHAR2(10);
    
      --Procedure para Lancar Juros no Contrato
      PROCEDURE pc_calcula_juros(pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE --Data Emprestimo
                                ,pr_flnormal    IN BOOLEAN --Lancamento Normal
                                ,pr_dtvencto    IN crapdat.dtmvtolt%TYPE --Data vencimento
                                ,pr_ehmensal    IN BOOLEAN --Indicador Mensal
                                ,pr_dtdpagto    IN crapdat.dtmvtolt%TYPE --Data pagamento
                                ,pr_diarefju    IN crapepr.diarefju%TYPE
                                ,pr_mesrefju    IN crapepr.mesrefju%TYPE
                                ,pr_anorefju    IN crapepr.anorefju%TYPE
                                ,pr_dtlibera    IN crawepr.dtlibera%TYPE
                                ,pr_txjuremp    IN crapepr.txjuremp%TYPE
                                ,pr_vlsdeved    IN crapepr.vlsdeved%TYPE
                                ,pr_vljurmes    OUT NUMBER --Valor Juros no Mes
                                ,pr_dscritic    OUT VARCHAR2) IS
      BEGIN
        DECLARE
          --Variaveis Locais
          vr_diavtolt INTEGER;
          vr_mesvtolt INTEGER;
          vr_anovtolt INTEGER;
          vr_qtdiajur NUMBER;
          vr_potencia NUMBER(30, 10);
          vr_valor    NUMBER;
          vr_dtrefjur DATE;
          vr_diarefju crapepr.diarefju%TYPE;
          vr_mesrefju crapepr.mesrefju%TYPE;
          vr_anorefju crapepr.anorefju%TYPE;
        BEGIN          
          --Dia/Mes/Ano Referencia
          IF pr_diarefju <> 0 AND pr_mesrefju <> 0 AND pr_anorefju <> 0 THEN
            --Setar Dia/mes?ano
            vr_diavtolt := pr_diarefju;
            vr_mesvtolt := pr_mesrefju;
            vr_anovtolt := pr_anorefju;
          ELSE
            --Setar dia/mes/ano
            vr_diavtolt := to_number(to_char(pr_dtlibera, 'DD'));
            vr_mesvtolt := to_number(to_char(pr_dtlibera, 'MM'));
            vr_anovtolt := to_number(to_char(pr_dtlibera, 'YYYY'));
          END IF;
          
          --Se for normal
          IF pr_flnormal THEN
            --Data Referencia recebe vencimento
            vr_dtrefjur := pr_dtvencto;
          ELSE
            --Data referencia recebe movimento
            vr_dtrefjur := pr_dtmvtolt;
          END IF;
          
          --Retornar Dia/mes/ano de referencia
          vr_diarefju := to_number(to_char(vr_dtrefjur, 'DD'));
          vr_mesrefju := to_number(to_char(vr_dtrefjur, 'MM'));
          vr_anorefju := to_number(to_char(vr_dtrefjur, 'YYYY'));
          
          --Calcular Quantidade dias
          empr0001.pc_calc_dias360(pr_ehmensal => pr_ehmensal -- Indica se juros esta rodando na mensal
                                  ,pr_dtdpagto => to_char(pr_dtdpagto, 'DD') -- Dia do primeiro vencimento do emprestimo
                                  ,pr_diarefju => vr_diavtolt -- Dia da data de referência da última vez que rodou juros
                                  ,pr_mesrefju => vr_mesvtolt -- Mes da data de referência da última vez que rodou juros
                                  ,pr_anorefju => vr_anovtolt -- Ano da data de referência da última vez que rodou juros
                                  ,pr_diafinal => vr_diarefju -- Dia data final
                                  ,pr_mesfinal => vr_mesrefju -- Mes data final
                                  ,pr_anofinal => vr_anorefju -- Ano data final
                                  ,pr_qtdedias => vr_qtdiajur); -- Quantidade de dias calculada
          
          --Calcular Juros
          vr_valor    := 1 + (pr_txjuremp / 100);
          vr_potencia := POWER(vr_valor, vr_qtdiajur);
          --Retornar Juros do Mes
          pr_vljurmes := pr_vlsdeved * (vr_potencia - 1);
          
          --Se valor for zero ou negativo
          IF pr_vljurmes <= 0 THEN
            --zerar Valor
            pr_vljurmes := 0;
          END IF;
            
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar descrição de erro não tratado
            pr_dscritic := 'Erro não tratado na pc_calcula_juros. ' ||sqlerrm;            
        END;
      END pc_calcula_juros;
    
    BEGIN
      -- Inicializar o CLOB
      vr_texto_completo := NULL;
      vr_des_log        := NULL;
      dbms_lob.createtemporary(vr_des_log, TRUE);
      dbms_lob.open(vr_des_log, dbms_lob.lob_readwrite);
    
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => 1);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        RETURN;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
    
      ------------------------------------------------------------------------------------
      -- Atualiza o risco das operações de cessão de cartão
      ------------------------------------------------------------------------------------   
      gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,'Cooperativa;Conta;Contrato;Parcela;Valor da Prestacao Atual;Residuo;Novo Valor Parcela'|| chr(10));
      
      FOR rw_tbepr_adiamento_contrato IN cr_tbepr_adiamento_contrato (pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
        vr_tab_erro.DELETE;
        vr_tab_pgto_parcel.DELETE;
        vr_tab_calculado.DELETE;
        vr_vlparepr := 0;
        
        -- Para essa proposta especifica não sera alterado o valor de parcela
        IF rw_tbepr_adiamento_contrato.cdcooper = 8 AND rw_tbepr_adiamento_contrato.nrdconta = 44377 AND rw_tbepr_adiamento_contrato.nrctremp = 6080 THEN
          CONTINUE;  
        END IF;
        
        --------------------------------------------------------------------------------------------------      
        -- Calcular Juros Remuneratorio ate hoje para compor o saldo
        --------------------------------------------------------------------------------------------------
        pc_calcula_juros(pr_dtmvtolt    => rw_crapdat.dtmvtolt
                        ,pr_flnormal    => FALSE
                        ,pr_dtvencto    => NULL
                        ,pr_ehmensal    => FALSE
                        ,pr_dtdpagto    => rw_tbepr_adiamento_contrato.dtdpagto
                        ,pr_diarefju    => rw_tbepr_adiamento_contrato.diarefju
                        ,pr_mesrefju    => rw_tbepr_adiamento_contrato.mesrefju
                        ,pr_anorefju    => rw_tbepr_adiamento_contrato.anorefju
                        ,pr_dtlibera    => rw_tbepr_adiamento_contrato.dtlibera
                        ,pr_txjuremp    => rw_tbepr_adiamento_contrato.txjuremp
                        ,pr_vlsdeved    => rw_tbepr_adiamento_contrato.vlsdeved
                        ,pr_vljurmes    => vr_vljurmes
                        ,pr_dscritic    => vr_dscritic);
                        
        -- Condicao para verificar se houve critica                         
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        --------------------------------------------------------------------------------------------------      
        -- Calcula saldo devedor atualizado
        --------------------------------------------------------------------------------------------------
        empr0001.pc_busca_pgto_parcelas(pr_cdcooper => rw_tbepr_adiamento_contrato.cdcooper
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nmdatela => 'ATENDA'
                                       ,pr_idorigem => 5
                                       ,pr_nrdconta => rw_tbepr_adiamento_contrato.nrdconta
                                       ,pr_idseqttl => 1
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_flgerlog => 0
                                       ,pr_nrctremp => rw_tbepr_adiamento_contrato.nrctremp
                                       ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                       ,pr_nrparepr => 0
                                       ,pr_des_reto => vr_des_reto
                                       ,pr_tab_erro => vr_tab_erro
                                       ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                       ,pr_tab_calculado   => vr_tab_calculado);
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;            
          ELSE
            vr_dscritic := 'Não foi possivel obter dados de emprestimos.';
          END IF;      
          RAISE vr_exc_erro;
        END IF;
        
        --------------------------------------------------------------------------------------------------      
        -- Calculo do residuo
        --------------------------------------------------------------------------------------------------
        vr_residuo := (NVL(rw_tbepr_adiamento_contrato.vlsdeved,0) + NVL(vr_vljurmes,0)) - NVL(vr_tab_calculado(1).vlsdeved,0);
        
        --------------------------------------------------------------------------------------------------      
        -- Atualiza o valor da parcela com o valor do residuo
        --------------------------------------------------------------------------------------------------
        BEGIN
           UPDATE crappep SET 
                  vlparepr = NVL(vlparepr,0) + NVL(vr_residuo,0),
                  vlsdvpar = NVL(vlsdvpar,0) + NVL(vr_residuo,0),
                  vlsdvsji = NVL(vlsdvsji,0) + NVL(vr_residuo,0)
            WHERE crappep.cdcooper = rw_tbepr_adiamento_contrato.cdcooper
              AND crappep.nrdconta = rw_tbepr_adiamento_contrato.nrdconta
              AND crappep.nrctremp = rw_tbepr_adiamento_contrato.nrctremp
              AND crappep.nrparepr = rw_tbepr_adiamento_contrato.ultima_parcela
              AND crappep.inliquid = 0
              AND crappep.vlparepr = rw_tbepr_adiamento_contrato.vlpreemp
              RETURNING crappep.vlparepr INTO vr_vlparepr;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Registrar log
        gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,rw_tbepr_adiamento_contrato.cdcooper||';'||
                                                             rw_tbepr_adiamento_contrato.nrdconta||';'||
                                                             rw_tbepr_adiamento_contrato.nrctremp||';'||
                                                             rw_tbepr_adiamento_contrato.ultima_parcela||';'||
                                                             rw_tbepr_adiamento_contrato.vlpreemp||';'||
                                                             vr_residuo ||';'|| 
                                                             vr_vlparepr || chr(10));
        COMMIT;
        
      END LOOP;
    
      -- Fecha o arquivo
      gene0002.pc_escreve_xml(vr_des_log,vr_texto_completo,' ' || chr(10),TRUE);
    
      vr_dsdireto := gene0001.fn_param_sistema('CRED', 3, 'ROOT_MICROS') ||'cecred/james';
      DBMS_XSLPROCESSOR.CLOB2FILE(vr_des_log,vr_dsdireto,'contratos_residuo_2.csv',NLS_CHARSET_ID('UTF8'));
    
      dbms_lob.close(vr_des_log);
      dbms_lob.freetemporary(vr_des_log);
    
      COMMIT;
      dbms_output.put_line('sucesso');
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        dbms_output.put_line(vr_dscritic);
        ROLLBACK;
      WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
        ROLLBACK;
    end;
