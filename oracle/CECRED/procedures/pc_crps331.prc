CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS331(pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                               ,pr_dscritic OUT varchar2) IS          --> Texto de erro/critica encontrada

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: PC_CRPS331
  --  Autor   : Andrino Carlos de Souza Junior (RKAM)
  --  Data    : Novembro/2015                     Ultima Atualizacao: - 23/01/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Recebimento de negativacoes do Serasa
  --
  --  Alteracoes: 13/03/2016 - Ajustes decorrente a mudança de algumas rotinas da PAGA0001 
  --						   para a COBR0006 em virtude da conversão das rotinas de arquivos CNAB
  --						  (Andrei - RKAM).
  --
  --		      20/06/2016 - Receber o numero da conta ja na primeira linha do arquivo.
  --
  --			  21/11/2016 - #557129 Incluida a função trim em algumas atribuições para corrigir a conversão para
  --                           o tipo number (Carlos)
  --
  --              23/02/2017 - #602584 Implementado na rotina que trata os retornos da Serasa, algumas condições para 
  --						   que o sistema consiga identificar corretamente quando ocorreu erro na Serasa e salvar 
  --						   o log na Cecred (Andrey Formigari - Mouts).
  --
  --			  08/03/2017 - #611513 Validação para identificar uma inclusão de registro já existente e não alterar
  --						  seu statis. (Andrey Formigari - Mouts).
  -- 
  --        30/03/2017 - #551229 Job ENVIO_SERASA excluído para a criação dos jobs JBCOBRAN_ENVIO_SERASA e JBCOBRAN_RECEBE_SERASA.
  --                     Log de início, fim e erros na execução dos jobs. (Carlos)
  --
  --        23/01/2018 - Ajustar log escrito negatativacao para negativacao (Lucas Ranghetti #832284)

  --        20/05/2019 - Ajustar mensagem para Exclusão de negativação quando 
  --                     pois estava como Envio . PRB0041685 (INC0013353)
  --                     (Roberto Holz  - Mout´s) / Alcemir Jr.

  ---------------------------------------------------------------------------------------------------------------

  -- Atualiza a situacao do boleto
  PROCEDURE pc_atualiza_situacao(pr_rowid    IN  ROWID,
                                 pr_intipret IN  PLS_INTEGER, -- 1-Inclusao, 2-Exclusao, 3-Consulta (para os casos de remessa informacional)
                                 pr_dsretser IN  VARCHAR2,
                                 pr_ufexceca IN  VARCHAR2, -- Indicador de UF com execao (que necessita de AR)
                                 pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE,
                                 pr_dscritic OUT VARCHAR2) IS

       -- Busca os dados do boleto
       CURSOR cr_crapcob IS
         SELECT a.inserasa,
                a.cdcooper,
                a.cdbandoc,
                a.nrdctabb,
                a.nrcnvcob,
                a.nrdconta,
                a.nrdocmto,
                b.cdagenci,
                b.cdbccxlt,
                b.nrdolote,
                b.nrconven,
                a.dtretser
           FROM crapcco b,
                crapcob a
          WHERE a.ROWID = pr_rowid
            AND b.cdcooper = a.cdcooper
            AND b.nrconven = a.nrcnvcob;
       rw_crapcob cr_crapcob%ROWTYPE;

       -- Cursor sobre os erros
       CURSOR cr_erro(pr_cderro_serasa tbcobran_erros_serasa.cderro_serasa%TYPE) IS
         SELECT dserro_serasa,
                cdocorre,
                cdmotivo
           FROM tbcobran_erros_serasa
          WHERE cderro_serasa = pr_cderro_serasa;
       rw_erro cr_erro%ROWTYPE;

       type typ_tab_erros IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;

       -- Variaveis gerais
       vr_inserasa    crapcob.inserasa%TYPE;
       vr_dtretser    DATE; -- Data de retorno da Serasa
       vr_dslog       VARCHAR2(500);
       vr_inreterr    PLS_INTEGER; -- Indicador de erro (0-Sem erro, 1-Com erro)
       vr_erros       typ_tab_erros; -- Tabela com os erros no retorno
	   vr_erros_temp  PLS_INTEGER := 0; -- Variavel com o código do erro temporario
       vr_ind         PLS_INTEGER := 0; -- Indice da tabelas de erros
       vr_tab_lcm     PAGA0001.typ_tab_lcm_consolidada; -- Tabela de lancamentos para cobranda da tarifa


       --Variaveis de controle do programa
       vr_cdcritic    NUMBER:= 0;
       vr_dscritic    VARCHAR2(4000);
       vr_des_erro    VARCHAR2(10);

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;

    BEGIN

      -- Abre o cursor de boletos
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;
      
      -- Define se houve erro no processo
      IF pr_dsretser IS NULL THEN
        vr_inreterr := 0;
      ELSE
        vr_inreterr := 1;
        
        -- loop para popular os erros
        LOOP
          EXIT WHEN TRIM(substr(pr_dsretser,(vr_ind*3)+1)) IS NULL;
          
          -- Busca o codigo de erro, contendo 3 posicoes
          vr_erros(vr_ind+1) := trim(substr(pr_dsretser,(vr_ind*3)+1,3));
		  vr_erros_temp := vr_erros(vr_ind+1);
                    
          -- Conforme e-mail passado pela Marajoana (Serasa-17/03/2016), nos casos de remessa informacional
          -- vira apenas um erro
          IF pr_intipret = 3 THEN
            EXIT;
          END IF;
            
          -- Vai para o proximo registro
          vr_ind := vr_ind + 1;
          EXIT;
        END LOOP;
      END IF;
      
      -- Verifica para qual situacao devera ser alterada a situacao
      
      IF pr_intipret = 3 AND -- Se for remessa
         pr_ufexceca <> 'S' AND -- E nao for excecao
         rw_crapcob.inserasa IN (2,5) THEN -- E estiver com o status de enviada ou negativada
        vr_inserasa := rw_crapcob.inserasa; -- Continua com o mesmo status
        vr_dtretser := rw_crapcob.dtretser; -- Manter a mesma data
        vr_dslog := 'Serasa - Recebido informacoes apenas informacionais';
      ELSIF pr_intipret = 3 AND -- Se for consulta (para os casos de SP)
         rw_crapcob.inserasa = 2 AND -- E estiver com o status de enviada
         vr_erros_temp = 0 THEN  -- E veio como REGISTRO AR - ASSINADO
        vr_inserasa := rw_crapcob.inserasa; -- Continua com o mesmo status
        vr_dtretser := pr_dtmvtolt; -- Coloca como recebida com sucesso
        vr_dslog := 'Serasa - Recebido informacoes do AR';
      ELSIF pr_intipret = 3 AND -- Se for consulta (para os casos de SP)
         rw_crapcob.inserasa = 2 AND -- E estiver com o status de enviada
         vr_erros_temp <> 0 THEN  -- E veio com erro
        vr_inserasa := 6; -- Recusada Serasa
        vr_dtretser := NULL; -- Nao recebida
        vr_dslog := 'Serasa - Erro no recebimento da solicitacao da negativacao do AR';
      ELSIF pr_intipret = 3 AND -- Se for consulta (para os casos de SP)
         rw_crapcob.inserasa <> 2 THEN -- E estiver com o status diferente de enviada
        vr_inserasa := rw_crapcob.inserasa; -- Continua com o mesmo status
        vr_dtretser := NULL; -- Nao coloca como recebida
        vr_dslog := 'Serasa - Recebido informacoes do AR, porem boleto nao esta com situacao de enviada';        
      ELSIF pr_intipret = 1 AND -- Se for Inclusao
         vr_inreterr = 0 AND -- E foi recebida com sucesso
         rw_crapcob.inserasa IN (1,2) THEN -- E o tipo da solicitacao for pendente de envio ou enviada
        vr_inserasa := 2; -- Continua como enviada
        vr_dtretser := pr_dtmvtolt; -- Coloca como recebida com sucesso
        vr_dslog := 'Negativacao em andamento';
      ELSIF pr_intipret = 1 AND -- Se for Inclusao
         vr_inreterr = 1 AND -- E houver erro de recebimento
         rw_crapcob.inserasa IN (1,2) THEN -- E o tipo da solicitacao for pendente de envio ou enviada
        IF vr_erros_temp <> 59 THEN -- INCLUSAO PARA REGISTRO JA EXISTENTE
          vr_inserasa := 6; -- Recusada Serasa
          vr_dtretser := NULL; -- Nao recebida
        ELSE
          vr_inserasa := rw_crapcob.inserasa; -- Nao muda a situacao. Deixa a anterior
          vr_dtretser := rw_crapcob.dtretser; -- Manter a mesma data
        END IF;
				
				OPEN cr_erro(vr_erros_temp);
				FETCH cr_erro INTO rw_erro;
					--
          vr_dslog := 'Falha no processo de negativacao - Motivo: Retorno Serasa: ' || rw_erro.dserro_serasa;
					--
				CLOSE cr_erro;
        
      ELSIF pr_intipret = 1 AND -- Se for Inclusao
         vr_inreterr = 0 AND -- E foi recebida com sucesso
         rw_crapcob.inserasa NOT IN (1,2) THEN -- E o tipo da solicitacao for diferente de enviada (foi alterada durante o envio)
        vr_inserasa := rw_crapcob.inserasa; -- Nao deve-se alterar a situacao, pois a mesma foi alterada para cancelada
                                            -- Neste caso no proximo dia sera enviado o cancelamento
        vr_dtretser := NULL; -- Nao recebida
        vr_dslog := 'Serasa - Recebido confirmacao de recebimento da solicitacao de inclusao, mas boleto esta com situacao ';
        IF rw_crapcob.inserasa = 0 THEN
          vr_dslog := vr_dslog || ' de nao negativada';
        ELSIF rw_crapcob.inserasa = 3 THEN
          vr_dslog := vr_dslog || ' de pendente de envio de cancelamento';
        ELSIF rw_crapcob.inserasa = 4 THEN
          vr_dslog := vr_dslog || ' de pendente de cancelamento';
        ELSIF rw_crapcob.inserasa = 5 THEN
          vr_dslog := vr_dslog || ' de negativado';
        ELSIF rw_crapcob.inserasa = 6 THEN
          vr_dslog := vr_dslog || ' de recusado na Serasa';
        ELSIF rw_crapcob.inserasa = 7 THEN
          vr_dslog := vr_dslog || ' de acao judicial';
        ELSE
          vr_dslog := vr_dslog || ' desconhecida ('||rw_crapcob.inserasa||')';
        END IF;
        
      ELSIF pr_intipret = 1 AND -- Se for Inclusao
         vr_inreterr = 1 AND -- E houver erro de recebimento
         rw_crapcob.inserasa NOT IN (1,2) THEN -- E o tipo da solicitacao for diferente de enviada (foi alterada durante o envio)
        vr_inserasa := 0; -- Coloca como nao negativado, pois a inclusao nao foi feita e a situacao atual 
                          -- estava como pendente de cancelamento
        vr_dtretser := NULL; -- Nao recebida
        vr_dslog := 'Serasa - Erro no recebimento, mas situacao estava como solicitado cancelamento. Alterado situacao para nao negativado.';
        
      ELSIF pr_intipret = 2 THEN -- Se for Exclusao, independente se foi com sucesso e o historico antigo
                                 -- Deve-se colocar como nao negativada, pois se deu erro eh porque nao estava na Serasa
                                 -- E se estiver para cancelar nao pode existir outro historico (o sistema bloqueia novas solicitacoes)
        vr_inserasa := 0; -- Coloca como nao negativada
        vr_dtretser := NULL; -- Coloca como nao recebida no Serasa
        -- mensagem alterada de Envio para Exclusão . PRB0041685(INC0013353). 20/05/2019 (Roberto Holz - Mout´s)
        vr_dslog := 'Exclusão do cancelamento de negativacao do boleto - Serasa';
      END IF;

      -- Se a UF necessitar de AR e for o retorno de uma inclusao, nao deve-se atualizar o boleto
      IF (NOT (pr_ufexceca = 'S' AND pr_intipret = 1)) OR  vr_inserasa = 6 THEN
        -- Altera a situacao conforme regra acima      
        BEGIN
          UPDATE crapcob
             SET inserasa = vr_inserasa,
                 dtretser = vr_dtretser                                        
           WHERE ROWID = pr_rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao alterar CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Insere o historico da movimentacao
        BEGIN
          INSERT INTO tbcobran_his_neg_serasa
            (cdcooper    
            ,cdbandoc    
            ,nrdctabb    
            ,nrcnvcob    
            ,nrdconta    
            ,nrdocmto    
            ,nrsequencia 
            ,dhhistorico 
            ,inserasa
            ,dtretser    
            ,cdoperad)
          VALUES
            (rw_crapcob.cdcooper    
            ,rw_crapcob.cdbandoc    
            ,rw_crapcob.nrdctabb    
            ,rw_crapcob.nrcnvcob    
            ,rw_crapcob.nrdconta    
            ,rw_crapcob.nrdocmto
            ,(SELECT nvl(MAX(nrsequencia),0)+1 FROM tbcobran_his_neg_serasa 
                                              WHERE cdcooper = rw_crapcob.cdcooper
                                                AND cdbandoc = rw_crapcob.cdbandoc
                                                AND nrdctabb = rw_crapcob.nrdctabb
                                                AND nrcnvcob = rw_crapcob.nrcnvcob
                                                AND nrdconta = rw_crapcob.nrdconta
                                                AND nrdocmto = rw_crapcob.nrdocmto)
            ,SYSDATE
            ,vr_inserasa
            ,vr_dtretser
            ,'1');
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tbcobran_his_neg_serasa: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;
      
      -- Inserir log do recebimento
      paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid,
                                    pr_cdoperad => '1',
                                    pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                    pr_dsmensag => substr(vr_dslog,1,109),
                                    pr_des_erro => vr_des_erro,
                                    pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Limpa a tabela de lancamentos
      vr_tab_lcm.delete;
      
      -- Se possuir erros, gera as ocorrencias
      IF vr_inreterr = 1 THEN
        -- Vai para o primeiro registro do indice
        vr_ind := vr_erros.first;
        -- efetua loop sobre os erros
        LOOP
          EXIT WHEN vr_ind IS NULL;
          -- Busca o erro na tabela de erros da Serasa
          OPEN cr_erro(vr_erros(vr_ind));
          FETCH cr_erro INTO rw_erro;
          IF cr_erro%NOTFOUND THEN
            CLOSE cr_erro;
            vr_dscritic := 'Erro '||vr_erros(vr_ind)||' nao previsto na tabela de erros da Serasa.';
            RAISE vr_exc_saida;
          END IF;
          CLOSE cr_erro;
          
          -- Se possuir motivo de erro, gera a ocorrencia
          IF rw_erro.cdmotivo IS NOT NULL THEN
            --Prepara retorno cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => pr_rowid --ROWID da cobranca
                                               ,pr_cdocorre => rw_erro.cdocorre
                                               ,pr_cdmotivo => rw_erro.cdmotivo
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => 0
                                               ,pr_cdagectl => 0
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => '1' --Codigo Operador
                                               ,pr_nrremass => 0
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
            -- Efetua a cobranca da tarifa
            PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => pr_rowid --ROWID da cobranca
                                                ,pr_cdocorre => rw_erro.cdocorre  --Codigo Ocorrencia
                                                ,pr_tplancto => 'T'         --Tipo Lancamento
                                                ,pr_vltarifa => 0           --Valor Tarifa
                                                ,pr_cdhistor => 0           --Codigo Historico
                                                ,pr_cdmotivo => rw_erro.cdmotivo     --Codigo motivo
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
            
          END IF;

          -- Inserir log do erro
          paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_rowid,
                                        pr_cdoperad => '1',
                                        pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                        pr_dsmensag => 'Retorno Serasa: '||vr_erros(vr_ind)||'-'||rw_erro.dserro_serasa,
                                        pr_des_erro => vr_des_erro,
                                        pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          -- Vai para o proximo registro
          vr_ind := vr_erros.next(vr_ind);
                      
        END LOOP;
      ELSE -- Insere a ocorrencia se foi com sucesso
        IF pr_intipret = 1 THEN -- Se for inclusao
          -- Se for excecao, gera tarifa especifica
          IF pr_ufexceca = 'S' THEN
            --Prepara retorno cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => pr_rowid --ROWID da cobranca
                                               ,pr_cdocorre => 93 -- Negativacao Serasa
                                               ,pr_cdmotivo => 'S4' -- Enviado a Serasa com sucesso (AR)
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => 0
                                               ,pr_cdagectl => 0
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => '1' --Codigo Operador
                                               ,pr_nrremass => 0
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica

            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
            -- Efetua a cobranca da tarifa
            PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => pr_rowid --ROWID da cobranca
                                                ,pr_cdocorre => 93          --Codigo Ocorrencia
                                                ,pr_tplancto => 'T'         --Tipo Lancamento
                                                ,pr_vltarifa => 0           --Valor Tarifa
                                                ,pr_cdhistor => 0           --Codigo Historico
                                                ,pr_cdmotivo => 'S4'        --Codigo motivo
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;
            
          ELSE -- Se for normal
            --Prepara retorno cooperado
            COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => pr_rowid --ROWID da cobranca
                                               ,pr_cdocorre => 93 -- Negativacao Serasa
                                               ,pr_cdmotivo => 'S2' -- Enviado a Serasa com sucesso
                                               ,pr_vltarifa => 0
                                               ,pr_cdbcoctl => 0
                                               ,pr_cdagectl => 0
                                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                               ,pr_cdoperad => '1' --Codigo Operador
                                               ,pr_nrremass => 0
                                               ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                               ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se Ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

            -- Efetua a cobranca da tarifa
            PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => pr_rowid --ROWID da cobranca
                                                ,pr_cdocorre => 93          --Codigo Ocorrencia
                                                ,pr_tplancto => 'T'         --Tipo Lancamento
                                                ,pr_vltarifa => 0           --Valor Tarifa
                                                ,pr_cdhistor => 0           --Codigo Historico
                                                ,pr_cdmotivo => 'S2'        --Codigo motivo
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                                ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                                ,pr_dscritic => vr_dscritic); --Descricao Critica
            --Se ocorreu erro
            IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

          END IF;
        ELSIF pr_intipret = 2 THEN -- Se for exclusao
          --Prepara retorno cooperado
          COBR0006.pc_prep_retorno_cooper_90 (pr_idregcob => pr_rowid --ROWID da cobranca
                                             ,pr_cdocorre => 94 -- Cancelamento Negativacao Serasa
                                             ,pr_cdmotivo => 'S2' -- Cancelado negativacao na Serasa
                                             ,pr_vltarifa => 0
                                             ,pr_cdbcoctl => 0
                                             ,pr_cdagectl => 0
                                             ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                             ,pr_cdoperad => '1' --Codigo Operador
                                             ,pr_nrremass => 0
                                             ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                             ,pr_dscritic => vr_dscritic); --Descricao Critica
          --Se Ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;

          -- Efetua a cobranca da tarifa
          PAGA0001.pc_prep_tt_lcm_consolidada (pr_idtabcob => pr_rowid --ROWID da cobranca
                                              ,pr_cdocorre => 94          --Codigo Ocorrencia
                                              ,pr_tplancto => 'T'         --Tipo Lancamento
                                              ,pr_vltarifa => 0           --Valor Tarifa
                                              ,pr_cdhistor => 0           --Codigo Historico
                                              ,pr_cdmotivo => 'S2'        --Codigo motivo
                                              ,pr_tab_lcm_consolidada => vr_tab_lcm --Tabela de Lancamentos
                                              ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                              ,pr_dscritic => vr_dscritic); --Descricao Critica
          --Se ocorreu erro
          IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END IF;
      
      IF vr_tab_lcm.exists(vr_tab_lcm.first) THEN
        -- Efetua o pagamento da tarifa
        PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                             ,pr_dtmvtolt => pr_dtmvtolt         --Data Movimento
                                             ,pr_cdagenci => rw_crapcob.cdagenci --Codigo Agencia
                                             ,pr_cdbccxlt => rw_crapcob.cdbccxlt --Codigo banco caixa
                                             ,pr_nrdolote => rw_crapcob.nrdolote --Numero do Lote
                                             ,pr_cdpesqbb => rw_crapcob.nrconven --Codigo Convenio
                                             ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                             ,pr_dscritic => vr_dscritic         --Descricao Critica
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm);        --Tabela Lancamentos
        --Se ocorreu erro
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
      END IF;
      
    EXCEPTION
       WHEN vr_exc_saida THEN
         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
       WHEN OTHERS THEN
         cecred.pc_internal_exception(3);

         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
    END;

  BEGIN
    
  
--********************************
--/* INICIO DA ROTINA PRINCIPAL */
--********************************
     DECLARE


       /* Cursores da pc_crps331 */
       -- Cursor com as UFs que possuem AR
       CURSOR cr_excecao IS
         SELECT dsuf
           FROM tbcobran_param_exc_neg_serasa
          WHERE indexcecao = 1; -- UF utiliza AR
       
       -- cursor sobre as cooperativas   
       CURSOR cr_crapcop IS
         SELECT cdcooper,
                cdagectl,
                nrdocnpj
           FROM crapcop;

       -- Cursor sobre os boletos
       CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE,
                         pr_nrcnvcob crapcob.nrcnvcob%TYPE,
                         pr_nrdconta crapcob.nrdconta%TYPE, 
                         pr_nrdocmto crapcob.nrdocmto%TYPE) IS
         SELECT ROWID
           FROM crapcob
          WHERE cdcooper = pr_cdcooper
            AND nrcnvcob = pr_nrcnvcob
            AND nrdconta = pr_nrdconta
            AND nrdocmto = pr_nrdocmto;
       rw_crapcob cr_crapcob%ROWTYPE;

       -- Cursor sobre data
       rw_crapdat btch0001.cr_crapdat%ROWTYPE;
 
       -- Registro sobre as cooperativas      
       type typ_tab_crapcop IS TABLE OF PLS_INTEGER INDEX BY PLS_INTEGER;
       vr_crapcop  typ_tab_crapcop;
       vr_crapcop2 typ_tab_crapcop;

       -- PL/Table que vai armazenar os nomes de arquivos a serem processados
       vr_tab_arqtmp      gene0002.typ_split;
       vr_indice          integer;

       /* Variaveis Locais da pc_crps331 */
       vr_dsdireto    VARCHAR2(300); -- Diretorio onde sera recebido o arquivo
       vr_dsdirprc    VARCHAR2(300); -- Diretorio para onde o arquivo recebido eh movido apos o processo
       vr_listaarq    VARCHAR2(4000); -- Lista de arquivos
       vr_dsdlinha    VARCHAR2(32000); -- Linha que sera processada
       vr_utlfileh    UTL_FILE.file_type; -- Handle do arquivo
       vr_uf_excecao  VARCHAR2(100):= ';'; -- UFs que possuem AR, separado por ;
       vr_ufexceca    VARCHAR2(01);  -- Indicador de registro com UF que possui AR
       vr_cdcooper    crapcob.cdcooper%TYPE; -- Codigo da cooperativa
       vr_nrcnvcob    crapcob.nrcnvcob%TYPE; -- Numero do convenio
       vr_nrdconta    crapcob.nrdconta%TYPE; -- Numero da conta
       vr_nrdocmto    crapcob.nrdocmto%TYPE; -- Numero do documento
       vr_intipret    PLS_INTEGER;           -- Tipo de retorno -- 1-Inclusao, 2-Exclusao
       vr_dsretser    VARCHAR2(500);         -- Codigos de erros da Serasa
       vr_ufsacado    crapsab.cdufsaca%TYPE; -- UF do sacado
       vr_intipreg    PLS_INTEGER;           -- Tipo de registro que esta contido na linha
       vr_qtarquiv    PLS_INTEGER;
       
       -- Job de recebimento
       vr_nomdojob VARCHAR2(40) := 'JBCOBRAN_RECEBE_SERASA';
       vr_idprglog tbgen_prglog.idprglog%TYPE := 0;

       --Variaveis de controle do programa
       vr_cdcritic    NUMBER:= 0;
       vr_dscritic    VARCHAR2(4000);
       vr_des_erro    VARCHAR2(10);

       --Variaveis de Excecao
       vr_exc_saida  EXCEPTION;
       
     BEGIN
       
       -- Gera log de arquivo processado
       btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                 ,pr_ind_tipo_log => 1 -- Aviso
                                 ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                  || vr_nomdojob || ' --> Inicio da rotina'
                                 ,pr_dstiplog     => 'I'
                                 ,pr_cdprograma   => vr_nomdojob);

       -- Abre o cursor de data
       OPEN btch0001.cr_crapdat(3); -- Cooperativa Cecred
       FETCH btch0001.cr_crapdat INTO rw_crapdat;
       CLOSE btch0001.cr_crapdat;
       
       -- Popula as UFs que possuem AR
       FOR rw_excecao IN cr_excecao LOOP
         vr_uf_excecao := vr_uf_excecao ||rw_excecao.dsuf||';';
       END LOOP;
       
       -- Popula as cooperativas
       FOR rw_crapcop IN cr_crapcop LOOP
         vr_crapcop(rw_crapcop.cdagectl)  := rw_crapcop.cdcooper;
         vr_crapcop2(substr(lpad(rw_crapcop.nrdocnpj,15,'0'),1,9)) := rw_crapcop.cdcooper;
       END LOOP;

       -- Busca diretorio que o arquivo devera ser gerado
       vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'DIR_RECEBE_SERASA');

       -- Busca o diretorio que o arquivo recebido devera ser movido apos o processo
       vr_dsdirprc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                pr_cdacesso => 'DIR_RECEBIDOS_SERASA');
       --vr_dsdireto := '/microsq1/cecred/andrino/serasa'; -- Retirar isso

       -- Listar arquivos
       gene0001.pc_lista_arquivos( pr_path     => vr_dsdireto
                                  ,pr_pesq     => '%CVDEV%'
                                  ,pr_listarq  => vr_listaarq
                                  ,pr_des_erro => vr_dscritic);
       -- Se ocorreu erro, cancela o programa
       IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;

       -- Se possuir arquivos para serem processados
       IF vr_listaarq IS NOT NULL THEN

         --Carregar a lista de arquivos txt na pl/table
         vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarq);
         
         -- Leitura da PL/Table e processamento dos arquivos
         vr_indice := vr_tab_arqtmp.first;
         WHILE vr_indice IS NOT NULL LOOP

           -- Abrir o arquivo
           GENE0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                   ,pr_nmarquiv => vr_tab_arqtmp(vr_indice)
                                   ,pr_tipabert => 'R'
                                   ,pr_utlfileh => vr_utlfileh
                                   ,pr_des_erro => pr_dscritic);

           -- Verifica se houve erros na abertura do arquivo
           IF pr_dscritic IS NOT NULL THEN
             pr_dscritic := 'Erro ao abrir o arquivo: '||vr_tab_arqtmp(vr_indice);
             RAISE vr_exc_saida;
           END IF;

           -- Se o arquivo estiver aberto
           IF  utl_file.IS_OPEN(vr_utlfileh) THEN

             -- Percorrer as linhas do arquivo
             LOOP
               -- Limpa a variável que receberá a linha do arquivo
               vr_dsdlinha := NULL;

               BEGIN
                 -- Lê a linha do arquivo
                 GENE0001.pc_le_linha_arquivo(pr_utlfileh => vr_utlfileh
                                             ,pr_des_text => vr_dsdlinha);

                 -- Busca o tipo de registro
                 vr_intipreg := substr(vr_dsdlinha,1,1);
                 
                 -- Se for o cabecalho do arquivo, deve-se buscar a cooperativa
                 IF vr_intipreg = 0 THEN
                   -- Busca a cooperativa
                   vr_cdcooper := vr_crapcop2(substr(vr_dsdlinha,2,9));
                   
                 -- Se for de cabecalho do registro, deve-se limpar as variaveis de controle
                 ELSIF vr_intipreg = 1 THEN
                   
                   -- Busca o numero do convenio
                   vr_nrcnvcob := trim(substr(vr_dsdlinha,773,10));

                   -- Busca o numero da conta
                   -- Este campo sera rebido somente apos o dia 10/06. Antes disso era recebido 
                   -- no registro 2
                   vr_nrdconta := nvl(trim(substr(vr_dsdlinha,783,10)),0);

                   -- Busca o numero do documento
                   vr_nrdocmto := trim(substr(vr_dsdlinha,704,10));
                   
                   -- Busca a UF do devedor
                   vr_ufsacado := trim(substr(vr_dsdlinha,473,2));

                   -- Verificar se a UF deve possuir AR
                   IF instr(vr_uf_excecao,vr_ufsacado) <> 0 THEN
                     vr_ufexceca := 'S';
                   ELSE
                     vr_ufexceca := 'N';
                   END IF;

                   -- Busca o tipo de retorno
                   IF substr(vr_dsdlinha,2,1) = 'I' THEN
                     vr_intipret := 1; -- Inclusao
                   ELSIF substr(vr_dsdlinha,2,1) = 'E' THEN
                     vr_intipret := 2; -- Exclusao
                   ELSE
                     vr_intipret := 3; -- Consulta
                   END IF;
                   
                   -- Busca os codigos de erros
                   vr_dsretser := substr(vr_dsdlinha,834,60);
                   
                   -- em 10/06/2016 o numero da conta passou a ser enviado no registro 1
                   -- Se foi recebido o numero da conta no registro 1, ele devera ser processado
                   IF vr_nrdconta <> 0 THEN
                     -- Busca o rowid do boleto
                     OPEN cr_crapcob(vr_cdcooper, vr_nrcnvcob, vr_nrdconta, vr_nrdocmto);
                     FETCH cr_crapcob INTO rw_crapcob;
                     IF cr_crapcob%NOTFOUND THEN
                       CLOSE cr_crapcob;
                       vr_dscritic := 'Boleto nao encontrado: '||vr_cdcooper||' - '||vr_nrcnvcob||' - '||
                                                                 vr_nrdconta||' - '||vr_nrdocmto;
                       RAISE vr_exc_saida;
                     END IF;
                     CLOSE cr_crapcob;
                     
                     -- Efetua a integracao do registro
                     pc_atualiza_situacao(pr_rowid    => rw_crapcob.rowid,
                                          pr_intipret => vr_intipret,
                                          pr_dsretser => RTRIM(vr_dsretser),
                                          pr_ufexceca => vr_ufexceca,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_dscritic => vr_dscritic);
                     IF vr_dscritic IS NOT NULL THEN
                       RAISE vr_exc_saida;
                     END IF;
                   END IF;
                   
                 ELSIF vr_intipreg = 2 THEN -- Se for tipo de registro 2
                   -- em 10/06/2016 o numero da conta passou a ser enviado no registro 1
                   -- Se foi recebido o numero da conta no registro 1, ele já foi processado,
                   -- entao nao deve ser processado no registro 2
                   IF nvl(vr_nrdconta,0) = 0 THEN
                     -- Busca a cooperativa
                   vr_cdcooper := vr_crapcop(substr(vr_dsdlinha,273,4));
                   
                   -- Busca a conta
                   vr_nrdconta := REPLACE(substr(vr_dsdlinha,280,10),'.','');
                   
                   -- Busca o rowid do boleto
                   OPEN cr_crapcob(vr_cdcooper, vr_nrcnvcob, vr_nrdconta, vr_nrdocmto);
                   FETCH cr_crapcob INTO rw_crapcob;
                   IF cr_crapcob%NOTFOUND THEN
                     CLOSE cr_crapcob;
                     vr_dscritic := 'Boleto nao encontrado: '||vr_cdcooper||' - '||vr_nrcnvcob||' - '||
                                                               vr_nrdconta||' - '||vr_nrdocmto;
                     RAISE vr_exc_saida;
                   END IF;
                   CLOSE cr_crapcob;
                   
                   -- Efetua a integracao do registro
                   pc_atualiza_situacao(pr_rowid    => rw_crapcob.rowid,
                                        pr_intipret => vr_intipret,
                                        pr_dsretser => RTRIM(vr_dsretser),
                                        pr_ufexceca => vr_ufexceca,
                                        pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                        pr_dscritic => vr_dscritic);
                   IF vr_dscritic IS NOT NULL THEN
                     RAISE vr_exc_saida;
                   END IF;
                   END IF;
                   
                 END IF;
                 
               EXCEPTION
                 WHEN no_data_found THEN
                   -- Acabou a leitura, então finaliza o loop
                   EXIT;
                 WHEN OTHERS THEN
                   cecred.pc_internal_exception(3, 'Arq: ' || vr_tab_arqtmp(vr_indice) || 
                                                   ' Linha: ' || vr_dsdlinha);
                   EXIT;
               END;

             END LOOP; -- Finaliza o loop das linhas do arquivo

             -- Fechar o arquivo
             GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
           END IF;

           -- Mover o arquivo para o diretorio de recebidos
           GENE0001.pc_OScommand_Shell('mv ' || vr_dsdireto || '/' || vr_tab_arqtmp(vr_indice)||' '||
                                                vr_dsdirprc);
           
           -- Grava as atualizacoes efetuadas
           COMMIT; 

           -- Vai para o proximo registro
           vr_indice := vr_tab_arqtmp.next(vr_indice);

         END LOOP;
         
       END IF;

       IF vr_tab_arqtmp.exists(1) THEN
         vr_qtarquiv := vr_tab_arqtmp.last;
       ELSE
         vr_qtarquiv := 0;
       END IF;

       -- Gera log de arquivo processado
       btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                 ,pr_ind_tipo_log => 1 -- Aviso
                                 ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                  || vr_nomdojob || ' --> Termino da rotina. '||to_char(vr_qtarquiv)|| ' arquivos processados com sucesso!'
                                 ,pr_dstiplog     => 'F'
                                 ,pr_cdprograma   => vr_nomdojob);

     EXCEPTION
       WHEN vr_exc_saida THEN
           -- Buscar a descrição
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

         -- Devolvemos código e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         
         btch0001.pc_gera_log_batch(pr_cdcooper     => 3 -- Cecred
                                   ,pr_ind_tipo_log => 2 -- erro tratado
                                   ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||' - '
                                                    || vr_nomdojob || ' --> ' || vr_dscritic
                                   ,pr_dstiplog     => 'E'
                                   ,pr_cdprograma   => vr_nomdojob);

         -- Logar fim de execução sem sucesso
         cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                               ,PR_CDPROGRAMA => vr_nomdojob
                               ,pr_cdcooper   => 3
                               ,pr_flgsucesso => 0
                               ,PR_IDPRGLOG   => vr_idprglog);
         
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN

         cecred.pc_internal_exception(3);

         -- Efetuar retorno do erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := SQLERRM;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS331;
/
