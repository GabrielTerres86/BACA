CREATE OR REPLACE PROCEDURE CECRED.pc_crps328 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da critica
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica

  /* ............................................................................

     Programa: pc_crps328
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Andrino Carlos de Souza Junior - Mout'S
     Data    : Outubro/2016                         Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario (CRON).
     Objetivo  : Envio de SMS dos boletos de cobranca

     Alteracao : 

  ............................................................................ */

  ------------------------------- CURSORES ---------------------------------

    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
            ,cop.cdbcoctl
            ,cop.cdagectl
      FROM crapcop cop
      WHERE cop.cdcooper = decode(pr_cdcooper,3,cop.cdcooper,pr_cdcooper) -- Se for passado a Cecred como parametro, executa todas as cooperativas
        AND cop.flgativo = 1;

    -- Cursor sobre os boletos pendentes
    CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE,
                      pr_dtmvtoan DATE,
                      pr_dtmvtopr DATE) IS
      SELECT a.rowid,
             a.nrdconta,
             a.nrcnvcob,
             a.nrdocmto,
             a.cdbandoc,
             a.nrdctabb,
             a.dtvencto,
             a.insmsant,
             a.insmsvct,
             a.insmspos,
             b.nrcelsac
        FROM crapsab b,
             crapcob a
       WHERE a.cdcooper = pr_cdcooper
         AND a.incobran = 0 -- Pendente
         AND a.dtvencto BETWEEN pr_dtmvtoan AND pr_dtmvtopr
         AND a.inavisms > 0 -- Possui aviso de SMS
         AND b.cdcooper = a.cdcooper
         AND b.nrdconta = a.nrdconta
         AND b.nrinssac = a.nrinssac;

    -- Cursor sobre os SMS em processamento
    CURSOR cr_sms(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT b.cdretorno,
             a.invencimento,
             b.cdtarifa,
             a.ROWID,
             b.nrddd||b.nrtelefone nrtelefone,
             c.rowid rowid_crapcob
        FROM crapcob c,
             tbgen_sms_controle b,
             tbcobran_sms a
       WHERE a.cdcooper = pr_cdcooper
         AND a.instatus_sms = 2 -- Em processamento
         AND b.cdretorno IS NOT NULL -- Ja teve processamento
         AND b.idlote_sms = a.idlote_sms
         AND b.idsms = a.idsms
         AND c.cdcooper = a.cdcooper
         AND c.nrdconta = a.nrdconta
         AND c.nrcnvcob = a.nrcnvcob
         AND c.nrdocmto = a.nrdocmto
         AND c.nrdctabb = a.nrdctabb
         AND c.cdbandoc = a.cdbandoc;

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

    ------------------------------- VARIAVEIS -------------------------------

    -- Codigo do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS328';

    -- Tratamento de erros
    vr_exc_saida    EXCEPTION;
    vr_cdcritic     crapcri.cdcritic%TYPE;
    vr_dscritic     VARCHAR2(4000);
    vr_des_erro     VARCHAR2(500);

    -- Variaveis de controle de calendario
    rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

    -- variáveis auxiliares
    vr_dtmvtoan     DATE;  -- Data do vencimento - 1, ja calculada com o final de semana e feriados
    vr_invencimento tbcobran_sms.invencimento%TYPE; -- Indicador do tipo de vencimento
    vr_processo     PLS_INTEGER; -- Indicador de processo
    vr_insituacao   tbcobran_sms.instatus_sms%TYPE; -- Situacao do envio
    vr_cdocorre     crapoco.cdocorre%TYPE; -- Ocorrencia de retorno
    vr_cdmotivo     crapmot.cdmotivo%TYPE; -- Motivo de retorno
    
    -- Variaveis de retorno da busca da tarifa
    vr_cdhistor  INTEGER; 
    vr_cdhisest  NUMBER;
    vr_vltarifa  NUMBER;
    vr_dtdivulg  DATE;
    vr_dtvigenc  DATE;
    vr_cdfvlcop  INTEGER;
    vr_tab_erro  GENE0001.typ_tab_erro;

    --Variavel para log
    vr_idlog_ini_ger tbgen_prglog.idprglog%type;

    --------------------------- SUBROTINAS INTERNAS --------------------------

  BEGIN
    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
                              
    vr_idlog_ini_ger := null;
   
    pc_log_programa(pr_dstiplog   => 'I'
                   ,pr_cdprograma => vr_cdprogra
                   ,pr_cdcooper   => pr_cdcooper
                   ,pr_tpexecucao => 2    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                   ,pr_idprglog   => vr_idlog_ini_ger);
   
    -- Loop sobre as cooperativa ativas
    FOR rw_crapcop IN cr_crapcop LOOP

      -- Busca a data da cooperativa
      OPEN btch0001.cr_crapdat(rw_crapcop.cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
        
      -- Se a cooperativa estiver em processo batch, nao faz nada
      IF rw_crapdat.inproces <> 1 THEN
        continue;
      END IF;

      -- Busca a data de vencimento anterior. Deve-se efetuar tratamento especial para os dias
      -- onde o dia anterior for uma segunda feira ou for após um feriado
      vr_dtmvtoan := gene0005.fn_valida_dia_util(pr_cdcooper => rw_crapcop.cdcooper,
                                                 pr_dtmvtolt => rw_crapdat.dtmvtoan -1,
                                                 pr_tipo => 'A') + 1;
      
      -- Somente enviar das 08:00 horas ate as 19 horas
      IF to_char(SYSDATE,'hh24mi') BETWEEN 0800 AND 1900 THEN
        -- Busca os boletos pendentes de envio      
        FOR rw_crapcob IN cr_crapcob(pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtoan => vr_dtmvtoan,
                                     pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP
          BEGIN
          -- Se a data de vencimento for maior que a data atual e menor ou igual ao proximo dia util
          IF rw_crapcob.dtvencto > rw_crapdat.dtmvtolt AND
             rw_crapcob.dtvencto <= rw_crapdat.dtmvtopr AND
            rw_crapcob.insmsant = 1 THEN
            vr_invencimento := 1; -- Avisar 1 dia antes do vencimento
          ELSIF rw_crapcob.dtvencto > rw_crapdat.dtmvtoan AND 
            rw_crapcob.dtvencto <= rw_crapdat.dtmvtolt AND
            rw_crapcob.insmsvct = 1 THEN
            vr_invencimento := 2; -- Avisar no vencimento
          ELSIF rw_crapcob.dtvencto < rw_crapdat.dtmvtolt AND
            rw_crapcob.insmspos = 1 THEN
            vr_invencimento := 3; -- Avisar 1 dia apos ao vencimento
          ELSE
          
            -- Nao precisa de aviso
            continue;
          END IF;
            
          -- Valida o Celular
          IF rw_crapcob.nrcelsac = 0 OR substr(rw_crapcob.nrcelsac, 3, 9) < 69999999 THEN
            -- Atualiza o indicador de processo com erro
            vr_processo := 3;
              
            -- Gera a instrucao de erro
            COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_crapcob.rowid
                                              ,pr_cdocorre => 37   -- Instrucao Rejeitada
                                              ,pr_cdmotivo => 'B7' -- Numero do celular pagador nao informado
                                              ,pr_vltarifa => 0    -- Valor da Tarifa  
                                              ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                              ,pr_cdagectl => rw_crapcop.cdagectl
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_cdoperad => 1
                                              ,pr_nrremass => 0
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
            -- Verifica se ocorreu erro durante a execucao
            IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Envia log de erro
            paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid,
                                          pr_cdoperad => '1',
                                          pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                          pr_dsmensag => 'Erro no envio do SMS. Celular do pagador nao cadastrado',
                                          pr_des_erro => vr_des_erro,
                                          pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;

          ELSE
            -- Atualiza o indicador de processo com sucesso
            vr_processo := 2;

            -- Gera o registro para enviar o SMS
            BEGIN
              INSERT INTO tbcobran_sms
                (cdcooper,
                 nrdconta,    
                 nrcnvcob,    
                 nrdocmto,    
                 cdbandoc,    
                 nrdctabb,    
                 dhgeracao,   
                 invencimento,
                 instatus_sms)
               VALUES
                (rw_crapcop.cdcooper,
                 rw_crapcob.nrdconta,    
                 rw_crapcob.nrcnvcob,    
                 rw_crapcob.nrdocmto,    
                 rw_crapcob.cdbandoc,    
                 rw_crapcob.nrdctabb,
                 SYSDATE,
                 vr_invencimento,
                 1);
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao inserir na TBCOBRAN_SMS: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;  
            
          -- Atualiza o indcador de envio
          BEGIN
            UPDATE crapcob
               SET insmsant = decode(vr_invencimento,1,vr_processo,insmsant),
                   insmsvct = decode(vr_invencimento,2,vr_processo,insmsvct),
                   insmspos = decode(vr_invencimento,3,vr_processo,insmspos)
             WHERE ROWID = rw_crapcob.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              pr_dscritic := 'Erro ao atualizar CRAPCOB: '||SQLERRM;
              RAISE vr_exc_saida;
          END;
            
            COMMIT;
          EXCEPTION
            WHEN vr_exc_saida THEN
              -- Se foi retornado apenas codigo
              IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
                -- Buscar a descricao
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              
              -- Efetuar rollback
              ROLLBACK;
              
              pc_log_programa(PR_DSTIPLOG           => 'O'
                             ,PR_CDPROGRAMA         => vr_cdprogra 
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_tpocorrencia       => 4
                             ,pr_dsmensagem         => 'Erro envio automatico, boleto '||rw_crapcob.rowid||' - '||vr_dscritic
                             ,PR_IDPRGLOG           => vr_idlog_ini_ger);
            WHEN OTHERS THEN
              -- Efetuar retorno do erro nao tratado
              vr_cdcritic := 0;
              vr_dscritic := sqlerrm;
              
             -- Efetuar rollback
              ROLLBACK;
              
              pc_log_programa(PR_DSTIPLOG           => 'O'
                             ,PR_CDPROGRAMA         => vr_cdprogra 
                             ,pr_cdcooper           => pr_cdcooper
                             ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_tpocorrencia       => 4
                             ,pr_dsmensagem         => 'Erro envio automatico, boleto '||rw_crapcob.rowid||' - '||vr_dscritic
                             ,PR_IDPRGLOG           => vr_idlog_ini_ger);
          END;
        END LOOP; -- Loop sobre os boletos pendentes de envio
      END IF; -- Fim da validacao de horario

      -- Busca os SMS que foram processados, mas estao pendentes de retorno
      FOR rw_sms IN cr_sms(rw_crapcop.cdcooper) LOOP
        BEGIN
        /* Lista de retornos possiveis do CRRETORNO (existente no ESMS0001
            -- 0 - Com sucesso
            -- 10 - Erro
        */  
      
        -- Se foi enviado com sucesso
        IF rw_sms.cdretorno = 0 THEN
          -- Atualiza a situacao para o envio
          vr_insituacao := 4; -- Enviado
          
          vr_cdocorre := 36;  -- Confirmacao de envio de SMS
          vr_cdmotivo := 87;  -- Enviado com sucesso

          -- Busca o valor da tarifa
          TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => rw_crapcop.cdcooper  --Codigo Cooperativa
                                      ,pr_cdtarifa  => rw_sms.cdtarifa  --Codigo Tarifa
                                      ,pr_vllanmto  => 0            --Valor Lancamento
                                      ,pr_cdprogra  => NULL         --Codigo Programa
                                      ,pr_cdhistor  => vr_cdhistor  --Codigo Historico da tarifa
                                      ,pr_cdhisest  => vr_cdhisest  --Historico Estorno
                                      ,pr_vltarifa  => vr_vltarifa  --Valor tarifa
                                      ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                      ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                      ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                      ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                      ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                      ,pr_tab_erro  => vr_tab_erro); --Tabela erros
          
        ELSE
          vr_insituacao := 3; -- Com erro

          vr_cdocorre := 37;  -- SMS rejeitado
          vr_cdmotivo := '89';  -- Nao enviado
          vr_vltarifa := 0; -- Sem tarifa
        END IF;
        
        -- Gerar o retorno para o cooperado 
        COBR0006.pc_prep_retorno_cooper_90(pr_idregcob => rw_sms.rowid_crapcob
                                          ,pr_cdocorre => vr_cdocorre
                                          ,pr_cdmotivo => vr_cdmotivo
                                          ,pr_vltarifa => nvl(vr_vltarifa,0)    -- Valor da Tarifa  
                                          ,pr_cdbcoctl => rw_crapcop.cdbcoctl
                                          ,pr_cdagectl => rw_crapcop.cdagectl
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdoperad => 1
                                          ,pr_nrremass => 0
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
        -- Verifica se ocorreu erro durante a execucao
        IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Atualiza a situacao do envio
        BEGIN
          UPDATE tbcobran_sms
             SET instatus_sms = vr_insituacao
           WHERE ROWID = rw_sms.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar TBCOBRAN_SMS: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Atualiza a situacao no boleto
        BEGIN
          UPDATE crapcob a
             SET a.insmsant = decode(rw_sms.invencimento,1,decode(vr_insituacao,3,3,a.insmsant),a.insmsant),
                 a.insmsvct = decode(rw_sms.invencimento,2,decode(vr_insituacao,3,3,a.insmsvct),a.insmsvct),
                 a.insmspos = decode(rw_sms.invencimento,3,decode(vr_insituacao,3,3,a.insmspos),a.insmspos)
           WHERE ROWID = rw_sms.rowid_crapcob;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro na atualizacao da CRAPCOB: '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- Inserir log do envio do SMS
        IF vr_insituacao = 3 THEN -- Com erro
          -- Envia log de erro
          paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_sms.rowid_crapcob,
                                        pr_cdoperad => '1',
                                        pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                        pr_dsmensag => 'Erro no envio do SMS ao celular '|| rw_sms.nrtelefone ||' do pagador',
                                        pr_des_erro => vr_des_erro,
                                        pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        ELSE
          -- Envia log de sucesso
          paga0001.pc_cria_log_cobranca(pr_idtabcob => rw_sms.rowid_crapcob,
                                        pr_cdoperad => '1',
                                        pr_dtmvtolt => trunc(SYSDATE), -- Rotina nao utiliza esta data
                                        pr_dsmensag => 'Envio do SMS ao celular '|| rw_sms.nrtelefone ||' do pagador com sucesso',
                                        pr_des_erro => vr_des_erro,
                                        pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
          COMMIT;
        EXCEPTION
          WHEN vr_exc_saida THEN
            -- Se foi retornado apenas codigo
            IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
              -- Buscar a descricao
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
            -- Efetuar rollback
            ROLLBACK;
            
            pc_log_programa(PR_DSTIPLOG           => 'O'
                           ,PR_CDPROGRAMA         => vr_cdprogra 
                           ,pr_cdcooper           => pr_cdcooper
                           ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           ,pr_tpocorrencia       => 4
                           ,pr_dsmensagem         => 'Erro retorno SMS, boleto '||rw_sms.rowid_crapcob||' - '||vr_dscritic
                           ,PR_IDPRGLOG           => vr_idlog_ini_ger);
          WHEN OTHERS THEN
            -- Efetuar retorno do erro nao tratado
            vr_cdcritic := 0;
            vr_dscritic := sqlerrm;
   
           -- Efetuar rollback
            ROLLBACK;
            
            pc_log_programa(PR_DSTIPLOG           => 'O'
                           ,PR_CDPROGRAMA         => vr_cdprogra 
                           ,pr_cdcooper           => pr_cdcooper
                           ,pr_tpexecucao         => 2   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                           ,pr_tpocorrencia       => 4
                           ,pr_dsmensagem         => 'Erro retorno SMS, boleto '||rw_sms.rowid_crapcob||' - '||vr_dscritic
                           ,PR_IDPRGLOG           => vr_idlog_ini_ger);
        END;
      END LOOP; -- Loop sobre os envios pendentes

    END LOOP; -- FOR rw_crapcoop

    pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 1);

  EXCEPTION
     WHEN vr_exc_saida THEN

       -- Se foi retornado apenas codigo
       IF NVL(vr_cdcritic, 0) > 0 AND trim(vr_dscritic) IS NULL THEN
         -- Buscar a descricao
         vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       END IF;

       -- Devolvemos codigo e critica encontradas
       pr_cdcritic := NVL(vr_cdcritic,0);
       pr_dscritic := vr_dscritic;

       -- Efetuar rollback
       ROLLBACK;

      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 0); 
     WHEN OTHERS THEN
       -- Efetuar retorno do erro nao tratado
       pr_cdcritic := 0;
       pr_dscritic := sqlerrm;
       -- Efetuar rollback
       ROLLBACK;
      
      pc_log_programa(pr_dstiplog   => 'F'   
                     ,pr_cdprograma => vr_cdprogra           
                     ,pr_cdcooper   => pr_cdcooper 
                     ,pr_tpexecucao => 2 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                     ,pr_idprglog   => vr_idlog_ini_ger
                     ,pr_flgsucesso => 0); 
  END pc_crps328;
/
