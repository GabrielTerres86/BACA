CREATE OR REPLACE PROCEDURE CECRED.pc_crps096 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps096       (Fontes/crps096.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Setembro/94.                     Ultima atualizacao: 22/09/2017

       Dados referentes ao programa:

       Frequencia: Roda Mensalmente no Processo de Limpeza
       Objetivo  : Limpeza dos Cartoes de Cheque Especial Vencidos.

                   Atende a Solicitacao 013.
                   Ordem da Solicitacao 065.
                   Exclusividade = 2
                   Ordem do Programa na Solicitacao = 12

       Alteracao - 16/12/94 - Alterado para nao flegar a solicitacao como atendida e
                              nao atualizar a tabela de Execucao. (Odair).

                   10/01/2000 - Padronizar mensagens (Deborah).
                   
                   15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre.
                   
                   24/05/2007 - Fazer limpeza das tabelas:
                                crawcrd/crapcrd(Ha mais de 3 anos) - BB,  
                                craphdp/crapddp/crapmdp(Ha mais de 6 meses),
                                crapcch(Ha mais de 6 meses) (Guilherme).
                                
                   18/06/2014 - Exclusao do uso da tabela crapcar.
                                (Tiago Castro - Tiago RKAM)
                                         
                   18/07/2014 - Conversão progres -> oracle (Odirlei-AMcom)
                   
                   29/07/2014 - Incluso nova regra nas administradoras a serem 
                                desconsideradas no processo de exclusão. (Daniel)
                                
                   02/02/2015 - Incluso nova regra para deletar os registro de
                                cadastro de favorecidos quando o cooperado
                                solicitar a exclusao.
                                Tabela a ser limpa: crapcti(Registro com mais de 31
                                dias) (Andre Santos - SUPERO)
                                
                   15/10/2015 - Desenvolvimento do projeto 126. (James)              

                   22/09/2016 - Removi do proc_bath e passei para o proc_message
                                o log 661, SD 402979. (Carlos Rafael Tanholi)

                   22/09/2017 - Ignorar os cartões CECRED no processo de limpeza 
                                das tabelas crawcrd/crapcrd (Douglas - Chamado 760181)                                 
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS096';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_des_erro   VARCHAR2(4000);

      -- Tabela Temporaria
      vr_tab_erro GENE0001.typ_tab_erro;

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
            
      -- Busca dos para limpeza da Tabela de Holerite de Pagamento
      CURSOR cr_craphdp IS
        SELECT ROWID,
               cdcooper,
               nrdconta,
               idseqttl,
               dtrefere,
               cddpagto,
               dtmvtolt       
          FROM craphdp 
         WHERE craphdp.cdcooper = pr_cdcooper 
           AND craphdp.dtmvtolt <= (rw_crapdat.dtmvtolt - 210);
                       
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------     
      vr_dstextab   craptab.dstextab%TYPE;  --> desc texto do valor da tabela generica
      vr_qtcchdel   NUMBER;                 --> qtd de registros limpos da tabela crapcch
      vr_qtctidel   NUMBER:= 0;             --> qtd de registros limpos da tabela crapcti      
      vr_qtddpdel   NUMBER:= 0;             --> qtd de registros limpos da tabela crapdpd
      vr_qtmdpdel   NUMBER:= 0;             --> qtd de registros limpos da tabela crapmdp
      vr_qthdpdel   NUMBER:= 0;             --> qtd de registros limpos da tabela craphdp
      vr_qtwrddel   NUMBER:= 0;             --> qtd de registros limpos da tabela crawcrd
      vr_qtcrddel   NUMBER:= 0;             --> qtd de registros limpos da tabela crapcrd
      vr_dsconteu   VARCHAR2(200);
      vr_qtlimdia   PLS_INTEGER := 0;      
      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => NULL);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;
                  
      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- Limite de dias para exclusao de proposta de cartao rejeitado
      TARI0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper,
                                             pr_cdbattar => 'LIMDIAREJCAD',
                                             pr_dsconteu => vr_dsconteu,
                                             pr_cdcritic => vr_cdcritic,
                                             pr_dscritic => vr_dscritic,
                                             pr_des_erro => vr_des_erro,
                                             pr_tab_erro => vr_tab_erro);

      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro <> 'OK' THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN
          -- Recebe Fescrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          -- Gera Log
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 2, -- Erro Tratado
                                     pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss')  ||
                                                        ' -' || vr_cdprogra || ' --> '  ||
                                                        vr_dscritic || ' - VLRCHEQSPB');
          -- Efetua Limpeza das variaveis de critica
          vr_tab_erro.DELETE;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
          vr_qtlimdia := 0;
        END IF;
      ELSE
        vr_qtlimdia := NVL(gene0002.fn_char_para_number(vr_dsconteu),0);
        
      END IF;
      
      -- Buscar parametro na tabela generica EXELIMPEZA
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED', 
                                                 pr_tptabela => 'GENERI', 
                                                 pr_cdempres => 00, 
                                                 pr_cdacesso => 'EXELIMPEZA', 
                                                 pr_tpregist => 001);
                                                 
      -- Se não localizar valor, gerar critica e abortar
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_cdcritic := 176; --> 176 - Falta tabela de execucao de limpeza - registro 001
        RAISE vr_exc_saida;
      ELSIF TRIM(vr_dstextab) <> '0' THEN
        vr_cdcritic := 177; --> 177 - Limpeza ja rodou este mes.
        RAISE vr_exc_saida;
      END IF;
            
      /* Procedimento de limpeza CCH */
      BEGIN
        DELETE crapcch 
         WHERE crapcch.cdcooper = pr_cdcooper 
           AND crapcch.dtmvtolt <= (rw_crapdat.dtmvtolt - 210);
         
         vr_qtcchdel := SQL%ROWCOUNT;
      EXCEPTION   
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapcch: '||SQLerrm;
          raise vr_exc_saida;
      END;
      
      vr_qtddpdel := 0;
      vr_qtmdpdel := 0;
      vr_qthdpdel := 0;
      vr_qtctidel := 0;
      
      /*Procedimento de limpeza CRAPHDP e filhas */ 
      FOR rw_craphdp IN cr_craphdp LOOP
        
        -- Limpeza da Tabela de Detalhes do Pagamento (Holerite)
        BEGIN
          DELETE crapddp
           WHERE crapddp.cdcooper = rw_craphdp.cdcooper
             AND crapddp.nrdconta = rw_craphdp.nrdconta
             AND crapddp.idseqttl = rw_craphdp.idseqttl
             AND crapddp.dtrefere = rw_craphdp.dtrefere
             AND crapddp.cddpagto = rw_craphdp.cddpagto
             AND crapddp.dtmvtolt = rw_craphdp.dtmvtolt;
           
           vr_qtddpdel := vr_qtddpdel + SQL%ROWCOUNT;
           
        EXCEPTION   
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapddp: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        -- Limpeza da Tabela de Mensagens do Pagamento (Holerite)
        BEGIN
          DELETE crapmdp
           WHERE crapmdp.cdcooper = rw_craphdp.cdcooper
             AND crapmdp.nrdconta = rw_craphdp.nrdconta
             AND crapmdp.idseqttl = rw_craphdp.idseqttl
             AND crapmdp.dtrefere = rw_craphdp.dtrefere
             AND crapmdp.cddpagto = rw_craphdp.cddpagto
             AND crapmdp.dtmvtolt = rw_craphdp.dtmvtolt;
           
           vr_qtmdpdel := vr_qtmdpdel + SQL%ROWCOUNT;
           
        EXCEPTION   
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapmdp: '||SQLERRM;
            RAISE vr_exc_saida;
        END;  
        
        -- Limpeza da Tabela de Holerite de Pagamento
        BEGIN
          DELETE craphdp
          WHERE ROWID = rw_craphdp.rowid;
        EXCEPTION   
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possivel efetuar limpeza da tabela craphdp: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        
        vr_qthdpdel := vr_qthdpdel + 1;
        
      END LOOP;  -- Fim loop craphdp
      
      -- Limpeza da tabela temporaria de Cadastro de cartoes de credito
      BEGIN
        DELETE crawcrd
         WHERE EXISTS 
               (SELECT 1 FROM crapcrd
                 WHERE crapcrd.cdcooper = pr_cdcooper
                   AND crapcrd.dtcancel <= (rw_crapdat.dtmvtolt - 1095)
                   AND TO_CHAR(crapcrd.cdadmcrd) NOT IN ('83','84','85','86','87','88')
                   AND crapcrd.cdadmcrd NOT BETWEEN 10 AND 80 -- Cartões CECRED
                   AND crawcrd.cdcooper = crapcrd.cdcooper
                   AND crawcrd.nrdconta = crapcrd.nrdconta
                   AND crawcrd.nrctrcrd = crapcrd.nrctrcrd);
      
        vr_qtwrddel := SQL%ROWCOUNT;
        
      EXCEPTION   
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crawcrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
        
      -- Limpeza da tabela de Cadastro de cartoes de credito
      BEGIN
        DELETE crapcrd
         WHERE crapcrd.cdcooper = pr_cdcooper
           AND crapcrd.dtcancel <= (rw_crapdat.dtmvtolt - 1095)
           AND TO_CHAR(crapcrd.cdadmcrd) NOT IN ('83','84','85','86','87','88')
           AND crapcrd.cdadmcrd NOT BETWEEN 10 AND 80; -- Cartões CECRED
        
        vr_qtcrddel := SQL%ROWCOUNT;
        
      EXCEPTION   
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapcrd: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Somente vamos apagar caso a quantidade de limite de dias for maior que 0
      IF vr_qtlimdia > 0 THEN
        
         BEGIN
           DELETE crapcrd
            WHERE EXISTS 
                  (SELECT 1 
                     FROM crawcrd
                    WHERE crawcrd.cdcooper  = crapcrd.cdcooper
                      AND crawcrd.nrdconta  = crapcrd.nrdconta
                      AND crawcrd.nrctrcrd  = crapcrd.nrctrcrd
                      AND crawcrd.cdcooper  = pr_cdcooper
                      AND crawcrd.dtrejeit <= (rw_crapdat.dtmvtolt - vr_qtlimdia)
                      AND crawcrd.insitcrd = 1 /* Aprovado */
                      AND crawcrd.cdadmcrd BETWEEN 10 AND 80);
          
           vr_qtcrddel := NVL(vr_qtcrddel,0) + NVL(SQL%ROWCOUNT,0);
            
         EXCEPTION   
           WHEN OTHERS THEN
             vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapcrd: '||SQLERRM;
             RAISE vr_exc_saida;
         END;
         
         BEGIN
           DELETE crawcrd
            WHERE crawcrd.cdcooper = pr_cdcooper
              AND crawcrd.dtrejeit <= (rw_crapdat.dtmvtolt - vr_qtlimdia)
              AND crawcrd.insitcrd = 1 /* Aprovado */
              AND crawcrd.cdadmcrd BETWEEN 10 AND 80;
           
           vr_qtwrddel := NVL(vr_qtwrddel,0) + NVL(SQL%ROWCOUNT,0);
            
         EXCEPTION   
           WHEN OTHERS THEN
             vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crawcrd: '||SQLERRM;
             RAISE vr_exc_saida;
         END;          
      
      END IF; /* END IF vr_qtlimdia > 0 THEN */      
      
      /* Procedimento de limpeza CTI */
      BEGIN
        DELETE crapcti cti
         WHERE cti.cdcooper = pr_cdcooper
           AND cti.insitfav = 3 -- Situacao (3-Excluido Pelo Usuario)
           AND cti.dttransa <= (rw_crapdat.dtmvtolt - 31);
         
         vr_qtctidel := SQL%ROWCOUNT;
      EXCEPTION   
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possivel efetuar limpeza da tabela crapcti: '||SQLERRM;
          raise vr_exc_saida;
      END;
       
      /*  Imprime no log do processo os totais das exclusoes   */
      vr_cdcritic := 661;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);          
                                                     
      /*Mostra CRAPCCH*/     
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' CCH = '|| TRIM(to_char(vr_qtcchdel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message'); 
     
      /*Mostra CRAPCRD e CRAWCRD*/                                                                                                    
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' CRD = '|| TRIM(to_char(vr_qtcrddel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');                                                      
                                                     
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' WRD = '|| TRIM(to_char(vr_qtwrddel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');                                                      
                                                     
      /*Mostra CRAPHDP e filhas CRAPDDP e CRAPMDP*/
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' HDP = '|| TRIM(to_char(vr_qthdpdel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');
                                                     
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' DDP = '|| TRIM(to_char(vr_qtddpdel,'9G999G990'))
                                 ,pr_nmarqlog     => 'proc_message');                                                     
      
      btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 1 -- processo normal
                                 ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                     vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                     ' MDP = '|| TRIM(to_char(vr_qtmdpdel,'9G999g990'))
                                 ,pr_nmarqlog     => 'proc_message');                                                     
                                                     
      btch0001.pc_gera_log_batch( pr_cdcooper    => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- processo normal
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '||
                                                    vr_cdprogra || ' --> ' || vr_dscritic|| 
                                                    ' CTI = '|| TRIM(to_char(vr_qtctidel,'9G999g990'))
                                ,pr_nmarqlog     => 'proc_message');                                                    
                                                                                                                   
      ----------------- ENCERRAMENTO DO PROGRAMA -------------------

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Salvar informações atualizadas
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit
        COMMIT;

      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := SQLERRM;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps096;
/
