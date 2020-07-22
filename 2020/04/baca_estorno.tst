PL/SQL Developer Test script 3.0
601
DECLARE
  -- Procedure Reponsavel por efetuar o estorno da parcela pago em dias diferentes
  PROCEDURE pc_efetua_estor_pgto_outro_dia(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                          ,pr_cdagenci IN crapass.cdagenci%TYPE --> Código da agência
                                          ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> Número do caixa
                                          ,pr_cdoperad IN crapdev.cdoperad%TYPE --> Código do Operador
                                          ,pr_nmdatela IN VARCHAR2 --> Nome da tela
                                          ,pr_idorigem IN INTEGER --> Id do módulo de sistema
                                          ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Número da conta
                                          ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Seq titula
                                          ,pr_dtmvtolt IN craplem.dtmvtolt%TYPE --> Data de Movimento
                                          ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
                                          ,pr_nrparepr IN crappep.nrparepr%TYPE --> Numero da Parcela
                                          ,pr_cdhisest IN craphis.cdhisest%TYPE --> Codigo do Historico de Estorno
                                          ,pr_vllanmto IN craplem.vllanmto%TYPE --> Valor do Lancamento
                                          ,pr_nrdrecid IN craplem.progress_recid%TYPE
                                          ,pr_dtpagemp IN craplem.dtpagemp%TYPE
                                          ,pr_txjurepr IN craplem.txjurepr%TYPE
                                          ,pr_vlpreemp IN craplem.vlpreemp%TYPE
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
  BEGIN                       
    /* .............................................................................

      Programa: pc_efetua_estor_pgto_outro_dia
      Sistema : CECRED
      Sigla   : EMPR
      Autor   : James Prust Junior
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina referente ao Estorno de pagamento de parcelas com pagamento em Outro dia

      Observacao: 02/02/2016 - Incluso novo parametro cdorigem na chamada da procedure 
                             EMPR0001.pc_cria_lancamento_lem (Daniel) 

      Alteracoes: 
    ..............................................................................*/
    DECLARE  
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
    BEGIN
    
      -- A cada lancamento sera gravado a data que foi realizado o estorno
      BEGIN
        UPDATE craplem
           SET craplem.dtestorn = pr_dtmvtolt
         WHERE craplem.progress_recid = pr_nrdrecid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar na tabela de craplem. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Cria o lancamento de estorno
      EMPR0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                     ,pr_dtmvtolt => pr_dtmvtolt   --Data Emprestimo
                                     ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                     ,pr_cdbccxlt => 100           --Codigo Caixa
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_cdpactra => pr_cdagenci   --Posto Atendimento
                                     ,pr_tplotmov => 5             --Tipo movimento
                                     ,pr_nrdolote => 600031        --Numero Lote
                                     ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                     ,pr_cdhistor => pr_cdhisest   --Codigo Historico                            
                                     ,pr_nrctremp => pr_nrctremp   --Numero Contrato
                                     ,pr_vllanmto => pr_vllanmto   --Valor Lancamento
                                     ,pr_dtpagemp => pr_dtpagemp   --Data Pagamento Emprestimo                            
                                     ,pr_txjurepr => pr_txjurepr   --Taxa Juros Emprestimo
                                     ,pr_vlpreemp => pr_vlpreemp   --Valor Emprestimo
                                     ,pr_nrsequni => 0             --Numero Sequencia
                                     ,pr_nrparepr => pr_nrparepr   --Numero Parcelas Emprestimo
                                     ,pr_flgincre => FALSE         --Indicador Credito
                                     ,pr_flgcredi => FALSE         --Credito                            
                                     ,pr_nrseqava => 0             --Pagamento: Sequencia do avalista
                                     ,pr_cdorigem => pr_idorigem
                                     ,pr_cdcritic => vr_cdcritic   --Codigo Erro
                                     ,pr_dscritic => vr_dscritic); --Descricao Erro
                                     
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
        -- Montar descrição de erro não tratado
        vr_dscritic := 'Erro não tratado na EMPR0008.pc_efetua_estor_pgto_outro_dia ' || sqlerrm;
        -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

    END;
          
  END pc_efetua_estor_pgto_outro_dia;
  
  PROCEDURE efetua_estorno (pr_cdcritic OUT PLS_INTEGER
                           ,pr_dscritic OUT VARCHAR2) IS
	BEGIN
	  DECLARE
			pr_cdcooper        crapepr.cdcooper%TYPE;
			pr_nrdconta        crapepr.nrdconta%TYPE;
			pr_nrctremp        crapepr.nrctremp%TYPE;
			pr_cdagenci        crapass.cdagenci%TYPE;
			pr_dtmvtolt        crapdat.dtmvtolt%TYPE;
			pr_idseqttl        crapttl.idseqttl%TYPE := 1;
			pr_nrdcaixa        craperr.nrdcaixa%TYPE := 1;
			pr_cdoperad        crapdev.cdoperad%TYPE := '1';
			pr_nmdatela        VARCHAR2(1000)        := 'ESTORN';
			pr_idorigem        INTEGER               := 5;
			pr_dsjustificativa VARCHAR2(1000)        := 'isencao de multa e juros de mora covid 19';
                           
      CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                pr_nrdconta IN crappep.nrdconta%TYPE,
                pr_nrctremp IN crappep.nrctremp%TYPE,
                pr_nrparepr IN crappep.nrparepr%TYPE) IS
        SELECT inliquid,
           dtultpag,
           dtvencto
        FROM crappep
         WHERE crappep.cdcooper = pr_cdcooper
         AND crappep.nrdconta = pr_nrdconta
         AND crappep.nrctremp = pr_nrctremp
         AND crappep.nrparepr = pr_nrparepr;
      rw_crappep cr_crappep%ROWTYPE;
      
      -- Cursor para buscar os bens do emprestimo
      CURSOR cr_crapbpr(pr_cdcooper IN crapbpr.cdcooper%TYPE,
                pr_nrdconta IN crapbpr.nrdconta%TYPE,
                pr_nrctremp IN crapbpr.nrctrpro%TYPE) IS
        SELECT COUNT(1) total
        FROM crapbpr
         WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp
         AND crapbpr.tpctrpro IN (90,99)
         AND crapbpr.cdsitgrv IN (0,2)
         AND crapbpr.flgbaixa = 1           
         AND crapbpr.tpdbaixa = 'A';
      vr_existbpr PLS_INTEGER := 0;
      
      -- Cursor para o historico do lancamento     
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE,
                pr_cdhistor IN craphis.cdhistor%TYPE) IS
        SELECT cdhisest
        FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
         AND craphis.cdhistor = pr_cdhistor;
      vr_cdhisest craphis.cdhisest%TYPE;
         
      CURSOR cr_crapepr IS
        SELECT crapepr.cdcooper,
               crapepr.nrdconta,
               crapepr.nrctremp,
               crapepr.dtdpagto,
               crapass.cdagenci,
               crapdat.dtmvtolt
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           and crawepr.nrdconta = crapepr.nrdconta
           and crawepr.nrctremp = crapepr.nrctremp
          join crapass
            on crapass.cdcooper = crapepr.cdcooper
           and crapass.nrdconta = crapepr.nrdconta
          join crapdat
            on crapdat.cdcooper = crapepr.cdcooper 
         WHERE crapepr.tpemprst = 1
           AND crapepr.tpdescto <> 2
           AND crapepr.inliquid = 0
           AND crapepr.inprejuz = 0
           AND crawepr.flgreneg = 0
           and crapepr.cdcooper = 1
           and exists (select 1
                         from crappep
                        where crappep.cdcooper = crapepr.cdcooper
                          and crappep.nrdconta = crapepr.nrdconta
                          and crappep.nrctremp = crapepr.nrctremp
                          and crappep.dtvencto between '01/04/2020' and '23/04/2020'
                          and (crappep.vlpagmta > 0 OR crappep.vlpagmra > 0)
                          and rownum <= 1);
      vr_flgconsig PLS_INTEGER := 0;
         
      vr_tab_erro                  GENE0001.typ_tab_erro;
      vr_tab_lancto_parcelas       EMPR0008.typ_tab_lancto_parcelas;
      vr_tab_lancto_cc             EMPR0001.typ_tab_lancconta;
      vr_cdestorno                 tbepr_estorno.cdestorno%TYPE;
      vr_cdlancamento              tbepr_estornolancamento.cdlancamento%TYPE;
      vr_vlpagpar                  crappep.vlpagpar%TYPE;
      vr_vlpagmta                  crappep.vlpagmta%TYPE;
      vr_vlpagmra                  crappep.vlpagmra%TYPE;
      vr_vljuratr                  craplem.vllanmto%TYPE;
      vr_vldescto                  craplem.vllanmto%TYPE;      
      vr_dtmvtolt                  DATE;      
      vr_index_lanc                VARCHAR2(80);
      vr_cdhislcm                  PLS_INTEGER;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_des_reto      VARCHAR2(3);

      BEGIN         
      -- Percorrer todos as parcelas do contrato
      FOR rw_crapepr IN cr_crapepr LOOP
        vr_tab_erro.DELETE;
        vr_tab_lancto_parcelas.DELETE;
        vr_tab_lancto_cc.DELETE;
      
        pr_cdcooper := rw_crapepr.cdcooper;
        pr_nrdconta := rw_crapepr.nrdconta;
        pr_nrctremp := rw_crapepr.nrctremp;
        pr_cdagenci := rw_crapepr.cdagenci;
        pr_dtmvtolt := rw_crapepr.dtmvtolt;
        
        -- Busca os lancamento que podem ser estornados para o contrato informado                     
        EMPR0008.pc_busca_lancamentos_pagto(pr_cdcooper => pr_cdcooper
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_nrdcaixa => pr_nrdcaixa
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_nmdatela => pr_nmdatela
                                           ,pr_idorigem => pr_idorigem
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_idseqttl => pr_idseqttl
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_des_reto => vr_des_reto
                                           ,pr_tab_erro => vr_tab_erro
                                           ,pr_tab_lancto_parcelas => vr_tab_lancto_parcelas);
                           
        IF vr_des_reto = 'NOK' THEN
          IF vr_tab_erro.COUNT > 0 THEN
            -- Buscar o erro encontrado para gravar na vr_des_erro
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            RAISE vr_exc_saida;
          END IF;
        END IF;
          
        --Cria o registro do Estorno
        BEGIN
          INSERT INTO tbepr_estorno
            (cdcooper
            ,cdestorno
            ,nrdconta
            ,nrctremp
            ,cdoperad
            ,cdagenci
            ,dtestorno
            ,hrestorno
            ,dsjustificativa)
          VALUES
            (pr_cdcooper
            ,fn_sequence('TBEPR_ESTORNO','CDESTORNO',pr_cdcooper)
            ,pr_nrdconta
            ,pr_nrctremp
            ,pr_cdoperad
            ,pr_cdagenci
            ,pr_dtmvtolt
            ,gene0002.fn_busca_time
            ,pr_dsjustificativa)
            RETURNING tbepr_estorno.cdestorno INTO vr_cdestorno;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao inserir na tabela de tbepr_estorno. ' ||SQLERRM;
            RAISE vr_exc_saida;
        END;      
        
        IF vr_tab_lancto_parcelas.COUNT <= 0 THEN
          CONTINUE;
        END IF;
        
        -- Percorre todos os lancamentos de acordo com a data de movimento
        FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP
          vr_cdhislcm := 0; -- Historico de lancamento na conta corrente
          vr_vlpagpar := 0; -- Valor do Pagamento
          vr_vlpagmta := 0; -- Valor Pago na Multa
          vr_vlpagmra := 0; -- Valor Pago no Juros de Mora
          vr_vljuratr := 0; -- Valor do Juros em Atraso
          vr_vldescto := 0; -- Valor de Desconto
          
          -- Busca os dados da parcela
          OPEN cr_crappep (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                           pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta,
                           pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp,
                           pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr);
          FETCH cr_crappep INTO rw_crappep;
          -- Verifica se a retornou registro
          IF cr_crappep%NOTFOUND THEN
            CLOSE cr_crappep;
            vr_dscritic := 'Parcela nao encontrada' ||
                   '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                   '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                   '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
            RAISE vr_exc_saida;
          ELSE
            -- Apenas Fecha o Cursor
            CLOSE cr_crappep;
          END IF;
          
          IF NOT(rw_crappep.dtvencto >= TO_DATE('01/04/2020','DD/MM/RRRR') AND TO_DATE('23/04/2020','DD/MM/RRRR') >= rw_crappep.dtvencto) THEN
            CONTINUE;
          END IF;
          
          -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
          OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper,
                           pr_cdhistor => vr_tab_lancto_parcelas(idx).cdhistor);
          FETCH cr_craphis
           INTO vr_cdhisest;
          CLOSE cr_craphis;
          
          IF NVL(vr_cdhisest,0) = 0 THEN
            vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
            RAISE vr_exc_saida;
          END IF;         
          
          -- Verifica se o historico eh pagamento
          IF vr_tab_lancto_parcelas(idx).cdhistor IN (1039,1044,1045,1057) THEN
            CONTINUE;
            
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
            CONTINUE;
            
          -- Valor de Desconto
          ELSIF vr_tab_lancto_parcelas(idx).cdhistor IN (1048,1049) THEN
            CONTINUE;
            
          ELSE
            vr_dscritic := 'Historico nao permitido para efetuar o estorno. Codigo: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).cdhistor);
            RAISE vr_exc_saida;
            
          END IF;
          
          -- Sequencia da tabela de pagamentos das parcelas
          vr_cdlancamento := fn_sequence('TBEPR_ESTORNOLANCAMENTO','CDLANCAMENTO',pr_cdcooper                          || ';' || 
                                              vr_tab_lancto_parcelas(idx).nrdconta || ';' || 
                                              vr_tab_lancto_parcelas(idx).nrctremp || ';' ||
                                              vr_cdestorno);

          BEGIN
            INSERT INTO tbepr_estornolancamento
                        (cdcooper
                        ,nrdconta
                        ,nrctremp
                        ,cdestorno
                        ,cdlancamento
                        ,nrparepr
                        ,dtvencto
                        ,dtpagamento
                        ,vllancamento
                        ,cdhistor)
                 VALUES (pr_cdcooper
                        ,vr_tab_lancto_parcelas(idx).nrdconta
                        ,vr_tab_lancto_parcelas(idx).nrctremp
                        ,vr_cdestorno
                        ,vr_cdlancamento
                        ,vr_tab_lancto_parcelas(idx).nrparepr
                        ,vr_tab_lancto_parcelas(idx).dtvencto
                        ,vr_tab_lancto_parcelas(idx).dtmvtolt
                        ,vr_tab_lancto_parcelas(idx).vllanmto
                        ,vr_tab_lancto_parcelas(idx).cdhistor);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao inserir na tabela de tbepr_estornolancamento. ' ||SQLERRM;
              RAISE vr_exc_saida;
          END;
          
          pc_efetua_estor_pgto_outro_dia(pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_idorigem => pr_idorigem
                                        ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp
                                        ,pr_nrparepr => vr_tab_lancto_parcelas(idx).nrparepr
                                        ,pr_cdhisest => vr_cdhisest
                                        ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto
                                        ,pr_nrdrecid => vr_tab_lancto_parcelas(idx).nrdrecid
                                        ,pr_dtpagemp => vr_tab_lancto_parcelas(idx).dtpagemp
                                        ,pr_txjurepr => vr_tab_lancto_parcelas(idx).txjurepr
                                        ,pr_vlpreemp => vr_tab_lancto_parcelas(idx).vlpreemp
                                        ,pr_des_reto => vr_des_reto
                                        ,pr_tab_erro => vr_tab_erro);
                         
          IF vr_des_reto = 'NOK' THEN
            IF vr_tab_erro.COUNT > 0 THEN
              -- Buscar o erro encontrado para gravar na vr_des_erro
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic ||
                             '. Coop.: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).cdcooper) ||
                             '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                             '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                             '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
              RAISE vr_exc_saida;
            END IF;
          END IF;
            
          -- Armazena o Valor estornado para fazer um unico lancamento em Conta Corrente
          EMPR0008.pc_cria_atualiza_ttlanconta (pr_cdcooper => vr_tab_lancto_parcelas(idx).cdcooper --> Cooperativa conectada
                                               ,pr_nrctremp => vr_tab_lancto_parcelas(idx).nrctremp --> Número do contrato de empréstimo
                                               ,pr_cdhistor => vr_cdhislcm                          --> Codigo Historico
                                               ,pr_dtmvtolt => pr_dtmvtolt                          --> Movimento atual
                                               ,pr_cdoperad => pr_cdoperad                          --> Código do Operador
                                               ,pr_cdpactra => pr_cdagenci                          --> P.A. da transação                                       
                                               ,pr_nrdolote => 600031                               --> Numero do Lote
                                               ,pr_nrdconta => vr_tab_lancto_parcelas(idx).nrdconta --> Número da conta
                                               ,pr_vllanmto => vr_tab_lancto_parcelas(idx).vllanmto --> Valor lancamento
                                               ,pr_nrseqava => 0                                    --> Pagamento: Sequencia do avalista
                                               ,pr_tab_lancconta => vr_tab_lancto_cc                --> Tabela Lancamentos Conta
                                               ,pr_des_erro => vr_des_reto                          --> Retorno OK / NOK
                                               ,pr_dscritic => vr_dscritic);                        --> descricao do erro
                        
          IF vr_des_reto = 'NOK' THEN
            vr_dscritic := vr_dscritic  ||
                           '. Coop.: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).cdcooper) ||
                           '. Conta: '    || TO_CHAR(vr_tab_lancto_parcelas(idx).nrdconta) ||
                           '. Contrato: ' || TO_CHAR(vr_tab_lancto_parcelas(idx).nrctremp) ||
                           '. Parcela: '  || TO_CHAR(vr_tab_lancto_parcelas(idx).nrparepr);
            RAISE vr_exc_saida;
          END IF;
        
        END LOOP; /* END FOR idx IN vr_tab_lancto_parcelas.FIRST..vr_tab_lancto_parcelas.LAST LOOP */
        
        --Percorrer os Lancamentos
        vr_index_lanc := vr_tab_lancto_cc.FIRST;
        WHILE vr_index_lanc IS NOT NULL LOOP
        
          -- Vamos verificar se o historico do lancamento possui historico de estorno cadastrado
          OPEN cr_craphis (pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper,
                           pr_cdhistor => vr_tab_lancto_cc(vr_index_lanc).cdhistor);
          FETCH cr_craphis
           INTO vr_cdhisest;
          CLOSE cr_craphis;
        
          IF NVL(vr_cdhisest,0) = 0 THEN
            vr_dscritic := 'Historico nao possui codigo de estorno cadastrado. Historico: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdhistor);
            RAISE vr_exc_saida;
          END IF;
        
          --> Verificar se conta nao está em prejuizo
          IF NOT PREJ0003.fn_verifica_preju_conta(pr_cdcooper, pr_nrdconta) THEN      
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
            
            IF vr_des_reto = 'NOK' THEN
              IF vr_tab_erro.COUNT > 0 THEN
                -- Buscar o erro encontrado para gravar na vr_des_erro
                vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                vr_dscritic := vr_dscritic  ||
                               '. Coop.: '    || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdcooper) ||
                               '. Conta: '    || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).nrdconta) ||
                               '. Contrato: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).nrctremp);
                RAISE vr_exc_saida;
              END IF;
            END IF;
            
          ELSE          
            --> Caso esteja o credito de estono deve ser direcionado ao bloqueio prejuizo
            PREJ0003.pc_gera_cred_cta_prj(pr_cdcooper => vr_tab_lancto_cc(vr_index_lanc).cdcooper, --> Cooperativa conectada
                                          pr_nrdconta => vr_tab_lancto_cc(vr_index_lanc).nrdconta, --> Número da conta,
                                          pr_cdoperad => vr_tab_lancto_cc(vr_index_lanc).cdoperad, --> Código do Operador,
                                          pr_vlrlanc  => vr_tab_lancto_cc(vr_index_lanc).vllanmto, --> Valor da parcela emprestimo,
                                          pr_dtmvtolt => vr_tab_lancto_cc(vr_index_lanc).dtmvtolt, --> Movimento atual
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);   
                     
            IF vr_dscritic IS NOT NULL OR NVL(vr_cdcritic,0) > 0 THEN
              vr_dscritic := vr_dscritic  ||
                             '. Coop.: '    || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).cdcooper) ||
                             '. Conta: '    || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).nrdconta) ||
                             '. Contrato: ' || TO_CHAR(vr_tab_lancto_cc(vr_index_lanc).nrctremp);
              RAISE vr_exc_saida;
            END IF;        
          END IF;
          
          --Proximo registro
          vr_index_lanc := vr_tab_lancto_cc.NEXT(vr_index_lanc);
        END LOOP;
           
      END LOOP;  
      
      COMMIT;
      --ROLLBACK;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Desfaz a Transacao
        ROLLBACK;
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- Desfaz a Transacao
        ROLLBACK;        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := SQLERRM;
    END;  
  END;
  
BEGIN
  :pr_cdcritic := 0;
  :pr_dscritic := '';
    
  -- Rotina para efetuar o estorno
  efetua_estorno(pr_cdcritic => :pr_cdcritic
                ,pr_dscritic => :pr_dscritic);
  
EXCEPTION
  WHEN OTHERS THEN
    -- Desfaz a Transacao
    ROLLBACK;        
    :pr_cdcritic := 0;
    :pr_dscritic := SQLERRM;
END; 
2
pr_cdcritic
0
5
pr_dscritic
0
5
1
pr_cdhistor
