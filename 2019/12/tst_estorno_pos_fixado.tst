PL/SQL Developer Test script 3.0
424
declare 
  CURSOR cr_contratos IS
    select * from (
      select crapepr.cdcooper,
             crapepr.nrdconta,
             crapepr.nrctremp,
             crapepr.vlpreemp,
             crapepr.dtdpagto,
             nvl((select sum(craplem.vllanmto)
                from craplem
               where craplem.cdcooper = crapepr.cdcooper
                 and craplem.nrdconta = crapepr.nrdconta
                 and craplem.nrctremp = crapepr.nrctremp
                 and craplem.cdhistor in (1076,1047,1618,1540)
                 and craplem.dtmvtolt = '11/12/2019'),0) multa,
             nvl((select sum(craplem.vllanmto)
                from craplem
               where craplem.cdcooper = crapepr.cdcooper
                 and craplem.nrdconta = crapepr.nrdconta
                 and craplem.nrctremp = crapepr.nrctremp
                 and craplem.cdhistor in (1078,1077,1620,1619)
                 and craplem.dtmvtolt = '11/12/2019'),0) juros_mora,
             nvl((select sum(craplem.vllanmto)
                from craplem
               where craplem.cdcooper = crapepr.cdcooper
                 and craplem.nrdconta = crapepr.nrdconta
                 and craplem.nrctremp = crapepr.nrctremp
                 and craplem.cdhistor in (2312,2311)
                 and craplem.dtmvtolt = '11/12/2019'),0) iof,
             crapsda.vlsddisp + crapsda.vllimcre saldo_disponivel,
             crapass.cdagenci
        from crapepr
        join crapass
          on crapass.cdcooper = crapepr.cdcooper
         and crapass.nrdconta = crapepr.nrdconta
        join crapsda
          on crapsda.cdcooper = crapepr.cdcooper
         and crapsda.nrdconta = crapepr.nrdconta
         and crapsda.dtmvtolt = '10/12/2019'
       where crapepr.cdcooper = 1
         and crapepr.tpemprst = 1
         and TO_CHAR(crapepr.dtdpagto,'DD') = 10
         and crapepr.inliquid = 0
         and crapepr.inprejuz = 0
         and exists (select 1
                       from craplem
                       join craphis
                         on craphis.cdcooper = craplem.cdcooper
                        and craphis.cdhistor = craplem.cdhistor
                        and craphis.indebcre = 'C'
                      where craplem.cdcooper = crapepr.cdcooper
                        and craplem.nrdconta = crapepr.nrdconta
                        and craplem.nrctremp = crapepr.nrctremp
                        and craplem.dtmvtolt = '11/12/2019')
         and exists (select 1
                       from crappep
                      where crappep.cdcooper = crapepr.cdcooper
                        and crappep.nrdconta = crapepr.nrdconta
                        and crappep.nrctremp = crapepr.nrctremp
                        and crappep.dtvencto = '10/12/2019'
                        and crappep.dtultpag = '11/12/2019')
      ) tabela
  where saldo_disponivel > 0
    and saldo_disponivel - vlpreemp > 0;
  
  -- Cursor para o historico do lancamento     
  CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE,
                    pr_cdhistor IN craphis.cdhistor%TYPE) IS
    SELECT cdhisest
		  FROM craphis
		 WHERE craphis.cdcooper = pr_cdcooper
       AND craphis.cdhistor = pr_cdhistor;
  vr_cdhisest craphis.cdhisest%TYPE;
  
  -- Valor do IOF Pago     
  vr_vlpiofpr NUMBER;
  vr_blnfound BOOLEAN;
  
  /* Tratamento de erro */
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_exc_erro EXCEPTION;
  vr_exc_estorno EXCEPTION;
  
  /* Erro em chamadas da pc_gera_erro */
  vr_des_reto             VARCHAR2(3);
  vr_tab_erro             GENE0001.typ_tab_erro;
  vr_tab_lancto_cc        EMPR0001.typ_tab_lancconta;
  vr_tab_saldos           EXTR0001.typ_tab_saldos;
  
  -- Cursor generico de calendario
  rw_crapdat              BTCH0001.cr_crapdat%ROWTYPE;
  vr_nrseqdig_IOF         PLS_INTEGER := 1;
  vr_vljurmes             NUMBER;
  vr_vljurmes_old         NUMBER;
  vr_tab_lancto_parcelas  EMPR0008.typ_tab_lancto_parcelas;
  vr_cdhislcm             NUMBER;
  vr_vlpagpar             crappep.vlpagpar%TYPE;
  vr_vlpagmta             crappep.vlpagmta%TYPE;
  vr_vliof                crappep.vliofcpl%TYPE;--P437
  vr_vlpagmra             crappep.vlpagmra%TYPE;
  vr_vlpagtot             crappep.vlpagpar%TYPE;
  vr_vljuratr             craplem.vllanmto%TYPE;
  vr_vldescto             craplem.vllanmto%TYPE;
  vr_vlsdvpar_final       NUMBER(25,2);
  vr_vlsomato             NUMBER(25,2);
  vr_index_lanc           VARCHAR2(80);
  vr_index_saldo          PLS_INTEGER;
begin
  
 FOR rw_contratos IN cr_contratos LOOP
    vr_tab_erro.DELETE;
    vr_tab_lancto_parcelas.DELETE;
    vr_tab_lancto_cc.DELETE;
    
    BEGIN
      SAVEPOINT save_estorno;
    
      -- Verifica se a data esta cadastrada
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_contratos.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Alimenta a booleana
      vr_blnfound := BTCH0001.cr_crapdat%FOUND;
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_dscritic := gene0001.fn_busca_critica(356);
        RAISE vr_exc_erro;
      END IF;
      
      -- Busca os lancamento que podem ser estornados para o contrato informado                     
      EMPR0008.pc_busca_lancamentos_pagto(pr_cdcooper => rw_contratos.cdcooper
                                         ,pr_cdagenci => rw_contratos.cdagenci
                                         ,pr_nrdcaixa => 1
                                         ,pr_cdoperad => '1'
                                         ,pr_nmdatela => 'ESTORN'
                                         ,pr_idorigem => 5
                                         ,pr_nrdconta => rw_contratos.nrdconta
                                         ,pr_idseqttl => 1
                                         ,pr_nrctremp => rw_contratos.nrctremp
                                         ,pr_des_reto => vr_des_reto
                                         ,pr_tab_erro => vr_tab_erro
                                         ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                                 
      -- Vamos verificar se possui registro
      IF vr_tab_lancto_parcelas.COUNT <= 0 THEN
        vr_dscritic := 'Lancamento de pagamento nao encontrado';
        vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
        RAISE vr_exc_erro;
      END IF;
      
      -- Percorre todos os lancamentos de acordo com a data de movimento
      FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
        vr_cdhislcm := 0; -- Historico de lancamento na conta corrente
        vr_vlpagpar := 0; -- Valor do Pagamento
        vr_vlpagmta := 0; -- Valor Pago na Multa
        vr_vlpagmra := 0; -- Valor Pago no Juros de Mora
        vr_vljuratr := 0; -- Valor do Juros em Atraso
        vr_vldescto := 0; -- Valor de Desconto
        
        -- Verifica se o historico eh pagamento
        IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039,1044,1045,1057) THEN        
          vr_vlpagpar := 0;
          
          -- Valor Pendente de Pagamento
          IF NVL(vr_tab_lancto_parcelas(idx).vllanmto,0) - NVL(rw_contratos.vlpreemp,0) < 0 THEN
            vr_vlpagpar := NVL(rw_contratos.juros_mora,0) + NVL(rw_contratos.multa,0);
          END IF;        
                    
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor IN (1045,1057) THEN
            vr_cdhislcm := 1539;
          ELSE
            vr_cdhislcm := 108;
          END IF;
          
        -- Juros de Mora
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1619,1077,1620,1078) THEN
          vr_vlpagmra := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1619 THEN
            vr_cdhislcm := 1543;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1077 THEN
            vr_cdhislcm := 1071;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1620 THEN
            vr_cdhislcm := 1544;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1078 THEN
            vr_cdhislcm := 1072;
          END IF;
            
        -- Multa
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1540,1047,1618,1076) THEN
          vr_vlpagmta := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          -- Vamos verificar qual historico foi lancado na conta corrente
          IF vr_tab_lancto_parcelas(idx).cdhistor = 1540 THEN
            vr_cdhislcm := 1541;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1047 THEN
            vr_cdhislcm := 1060;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1618 THEN
            vr_cdhislcm := 1542;
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor = 1076 THEN
            vr_cdhislcm := 1070;
          END IF;
            
        -- Juros de Atraso  
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1050,1051) THEN
          vr_vljuratr := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
          
        -- Valor de Desconto
        ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1048,1049) THEN
          vr_vldescto := NVL(vr_tab_lancto_parcelas(idx).vllanmto,0);
        ELSE
          CONTINUE;
        END IF;
        
        vr_vlsdvpar_final := 0;
              
        -- Atualiza os dados da Parcela
        BEGIN
          UPDATE crappep
             SET crappep.vlpagpar = nvl(crappep.vlpagpar,0) + nvl(vr_vlpagpar,0)
                ,crappep.vlsdvpar = nvl(crappep.vlsdvpar,0) - nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vlsdvsji = nvl(crappep.vlsdvsji,0) - nvl(vr_vlpagpar,0) - nvl(vr_vljuratr,0) + nvl(vr_vldescto,0)
                ,crappep.vldespar = nvl(crappep.vldespar,0) - nvl(vr_vldescto,0)
                ,crappep.vlpagjin = nvl(crappep.vlpagjin,0) - nvl(vr_vljuratr,0)
                ,crappep.vlpagmra = nvl(crappep.vlpagmra,0) - nvl(vr_vlpagmra,0)
                ,crappep.vlpagmta = nvl(crappep.vlpagmta,0) - nvl(vr_vlpagmta,0)
           WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr
             RETURNING crappep.vlsdvpar INTO vr_vlsdvpar_final;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
            vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
            RAISE vr_exc_erro;
        END;
        
        IF NVL(vr_vlsdvpar_final,0) > 0 THEN
          BEGIN
            UPDATE crappep
               SET inliquid = 1
             WHERE crappep.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
               AND crappep.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
               AND crappep.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
               AND crappep.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar a tabela crappep. ' || SQLERRM;
              vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
              RAISE vr_exc_erro;
          END;      
        END IF;
        
        -- Exclui os lancamentos do extratdo do empréstimo
        BEGIN
          DELETE FROM craplem
           WHERE craplem.cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND craplem.nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND craplem.nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND craplem.nrparepr = vr_tab_lancto_parcelas(idx).nrparepr
             AND craplem.dtmvtolt = vr_tab_lancto_parcelas(idx).dtmvtolt
             AND craplem.cdhistor IN (1076,1047,1618,1540, -- Multa
                                      1078,1077,1620,1619, -- Juros de Mora
                                      2312,2311,           -- IOF
                                      1051,1050);          -- Juros de Atraso
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Nao foi possivel excluir os lancamentos do emprestimo';
            vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
            RAISE vr_exc_erro;
        END;
        
        -- Atualiza os dados da Parcela
        BEGIN
          UPDATE craplem
             SET vllanmto = vllanmto + NVL(vr_vlpagpar,0)
           WHERE cdcooper = vr_tab_lancto_parcelas(idx).cdcooper
             AND nrdconta = vr_tab_lancto_parcelas(idx).nrdconta
             AND nrctremp = vr_tab_lancto_parcelas(idx).nrctremp
             AND nrparepr = vr_tab_lancto_parcelas(idx).nrparepr
             and cdhistor in (1039,1044,1057,1045)
             and dtmvtolt = '11/12/2019';
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela craplem. ' || SQLERRM;
            vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
            RAISE vr_exc_erro;
        END;
        
        /*
        -- Condicao para verificar se possui saldo em conta corrente
        --Limpar tabela saldos
        vr_tab_saldos.DELETE;

        --Obter Saldo do Dia
        EXTR0001.pc_obtem_saldo_dia(pr_cdcooper   => rw_contratos.cdcooper
                                   ,pr_rw_crapdat => rw_crapdat
                                   ,pr_cdagenci   => 1
                                   ,pr_nrdcaixa   => 1
                                   ,pr_cdoperad   => '1'
                                   ,pr_nrdconta   => rw_contratos.nrdconta
                                   ,pr_vllimcre   => 0
                                   ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                   ,pr_flgcrass   => false
                                   ,pr_des_reto   => vr_dscritic
                                   ,pr_tab_sald   => vr_tab_saldos
                                   ,pr_tipo_busca => 'A'
                                   ,pr_tab_erro   => vr_tab_erro);

        vr_vlsomato := 0;
        --Buscar Indice
        vr_index_saldo := vr_tab_saldos.FIRST;
        IF vr_index_saldo IS NOT NULL THEN
          vr_vlsomato := ROUND(nvl(vr_tab_saldos(vr_index_saldo).vlsddisp, 0) + nvl(vr_tab_saldos(vr_index_saldo).vllimcre, 0),2);
        END IF;
                
        -- Caso não conseguir pagar toda a parcela, ignoro o caso
        IF vr_vlpagpar <= 0 THEN
           vr_vlpagpar  
        ELSE IF END IF;        
        
        IF vr_vlsomato - vr_vlpagpar <= 0 THEN
          RAISE vr_exc_erro;
        END IF;
        */
        
        IF NVL(vr_cdhislcm,0) > 0 AND NVL(vr_tab_lancto_parcelas(idx).vllanmto,0) > 0 THEN
          -- Historico de Pagamento de Empréstimo
          IF vr_cdhislcm IN (1539,108) THEN
            vr_tab_lancto_parcelas(idx).vllanmto := vr_vlpagpar;
          END IF;
        
          -- Armazena o Valor estornado para fazer um unico lancamento em Conta Corrente
          EMPR0008.pc_cria_atualiza_ttlanconta(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper --> Cooperativa conectada
                                              ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp --> Número do contrato de empréstimo
                                              ,pr_cdhistor => vr_cdhislcm                          --> Codigo Historico
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt                  --> Movimento atual
                                              ,pr_cdoperad => '1'                                  --> Código do Operador
                                              ,pr_cdpactra => rw_contratos.cdagenci                          --> P.A. da transação                                       
                                              ,pr_nrdolote => 600031                               --> Numero do Lote
                                              ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta --> Número da conta
                                              ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto --> Valor lancamento
                                              ,pr_nrseqava => 0                                    --> Pagamento: Sequencia do avalista
                                              ,pr_tab_lancconta => vr_tab_lancto_cc                --> Tabela Lancamentos Conta
                                              ,pr_des_erro => vr_des_reto                          --> Retorno OK / NOK
                                              ,pr_dscritic => vr_dscritic);                        --> descricao do erro
                                          
          IF vr_des_reto = 'NOK' THEN
            vr_dscritic := vr_dscritic|| '. Coop: '|| rw_contratos.cdcooper ||'. Conta: '||rw_contratos.nrdconta || '.CtrEmp:'||rw_contratos.nrctremp;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;
    
      --Percorrer os Lancamentos
      vr_index_lanc := vr_tab_lancto_cc.FIRST;
      WHILE vr_index_lanc IS NOT NULL LOOP
        vr_cdhisest := 0;
        -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
        OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                         pr_cdhistor => vr_tab_lancto_cc(vr_index_lanc).cdhistor);
        FETCH cr_craphis
         INTO vr_cdhisest;
        CLOSE cr_craphis;
          
        IF vr_tab_lancto_cc(vr_index_lanc).cdhistor IN (1539,108) THEN
          vr_cdhisest := vr_tab_lancto_cc(vr_index_lanc).cdhistor;
        END IF;
        
        IF NVL(vr_cdhisest,0) = 0 THEN
          vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdhistor);
          RAISE vr_exc_erro;
        END IF;
       
        /* Lanca em C/C e atualiza o lote */
        EMPR0001.pc_cria_lancamento_cc (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper --> Cooperativa conectada
                                       ,pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt --> Movimento atual
                                       ,pr_cdagenci => vr_tab_lancto_cc(vr_index_lanc).cdagenci --> Código da agência
                                       ,pr_cdbccxlt => vr_tab_lancto_cc(vr_index_lanc).cdbccxlt --> Número do caixa
                                       ,pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad --> Código do Operador
                                       ,pr_cdpactra => vr_tab_lancto_cc(vr_index_lanc).cdpactra --> P.A. da transação
                                       ,pr_nrdolote => vr_tab_lancto_cc(vr_index_lanc).nrdolote --> Numero do Lote
                                       ,pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta --> Número da conta
                                       ,pr_cdhistor => vr_cdhisest                              --> Codigo historico
                                       ,pr_vllanmto => vr_tab_lancto_cc(vr_index_lanc).vllanmto --> Valor da parcela emprestimo
                                       ,pr_nrparepr => 0                                        --> Número parcelas empréstimo
                                       ,pr_nrctremp => vr_tab_lancto_cc(vr_index_lanc).nrctremp --> Número do contrato de empréstimo
                                       ,pr_nrseqava => vr_tab_lancto_cc(vr_index_lanc).nrseqava --> Pagamento: Sequencia do avalista
                                       ,pr_des_reto => vr_des_reto                              --> Retorno OK / NOK
                                       ,pr_tab_erro => vr_tab_erro);                            --> Tabela com possíves erros  
        
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        vr_index_lanc := vr_tab_lancto_cc.NEXT(vr_index_lanc);
      END LOOP;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz transacoes
        vr_dscritic := NULL;
        ROLLBACK TO SAVEPOINT save_estorno;
    END;
    
  END LOOP;  

  :result := 'Sucesso';
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    :result := 'Erro 01: Cod. Critica: ' || vr_cdcritic || '. Descricao: ' || vr_dscritic;
  WHEN OTHERS THEN
    ROLLBACK;
    :result := 'Erro 02: ' || SQLERRM;
end;
1
result
1
Sucesso
5
5
rw_contratos.cdcooper
rw_contratos.nrdconta
rw_contratos.nrctremp
vr_dscritic
