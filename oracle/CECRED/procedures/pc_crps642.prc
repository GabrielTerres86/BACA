CREATE OR REPLACE PROCEDURE CECRED.pc_crps642 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                                              ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação                                        
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_crps642  (Antigo: fontes/crps642.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Lucas Lunelli
       Data    : Abril/2013                        Ultima atualizacao: 30/12/2015

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Solicitacao 005. Efetuar debito de agendamentos de
                   convenios SICREDI feitos na Internet. 
                   
                               ************ ATENCAO *************
                   CASO NECESSARIO RODAR PROGRAMA MANUALMENTE VERIFICAR A NECESSIDADE DE AJUSTAR O
                   PARAMETRO(CRAPPRM) CTRL_DEBSIC_EXEC QUE CONTROLA A EXECUÇÃO DO PROGRAMA.

       Alteracoes: 21/05/2013 - Ajuste para nao realizar operacao de debito em
                                contas que nao possuem fundos (Elton).

                   27/09/2013 - Conversão Progress >> Oracle PLSQL (Edison-AMcom)
                   
                   22/05/2014 - Inclusão do tratamento de encerramento da solicitação
                                neste programa (Marcos-Supero)
                   
                   01/07/2014 - Tratamento para que o dtmvtopg seja a data do 
                                movimento atual qdo inproces = 1 
                                Prj automatiza compe (Tiago/Aline).                                

                   03/11/2015 - Ajustar o nome do parametro na chamada da procedure
                                SICR0001.pc_gera_relatorio (Douglas - 285228)
                                
                   19/11/2015 - Alterado tratamento do para definir a data de acordo com o inprocess,
                                procedimento será rodado por job e inproces sempre será 1 
                                SD358499 (Odirlei-AMcom)
                   
                   30/12/2015 - Ajuste na chamada da proc. pc_atualiza_trans_nao_efetiv, adicionado
                                param de saida pr_dstransa. (Jorge/David) Proj. 131 - Assinatura Multipla              
    ..............................................................................*/
    
    DECLARE

      ------------------------------------------------
      -- DECLARAÇÃO DE CURSORES
      ------------------------------------------------
      --Selecionar informacoes dos associados
      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Código do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS642';
      -- Tratamento de erros
      vr_exc_saida    EXCEPTION;
      vr_exc_fimprg   EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      
      -- Variáveis de controle de calendário
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;
      -- Variáveis diversas
      vr_dtmvtopg     DATE;
      vr_flsgproc     BOOLEAN;
      vr_dstextab     craptab.dstextab%TYPE; 
      vr_tab_agendamentos SICR0001.typ_tab_agendamentos;
      vr_dstransa     VARCHAR2(4000);
      vr_flultexe     INTEGER;
      vr_qtdexec      INTEGER;
      

    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS642'
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
	    -- Verificação do calendário
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                ,pr_flgbatch => 1
                                ,pr_cdprogra => vr_cdprogra
                                ,pr_infimsol => pr_infimsol
                                ,pr_cdcritic => vr_cdcritic);

      --Se retornou critica aborta programa
      IF vr_cdcritic <> 0 THEN
        --Descricao do erro recebe mensagam da critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;

      vr_dtmvtopg:= rw_crapdat.dtmvtolt;
      
      --> Verificar/controlar a execução da DEBNET e DEBSIC 
      SICR0001.pc_controle_exec_deb (  pr_cdcooper  => pr_cdcooper        --> Código da coopertiva
                                      ,pr_cdtipope  => 'I'                         --> Tipo de operacao I-incrementar e C-Consultar
                                      ,pr_dtmvtolt  => rw_crapdat.dtmvtolt         --> Data do movimento                                
                                      ,pr_cdprogra  => vr_cdprogra                 --> Codigo do programa                                  
                                      ,pr_flultexe  => vr_flultexe                 --> Retorna se é a ultima execução do procedimento
                                      ,pr_qtdexec   => vr_qtdexec                  --> Retorna a quantidade
                                      ,pr_cdcritic  => vr_cdcritic                 --> Codigo da critica de erro
                                      ,pr_dscritic  => vr_dscritic);               --> descrição do erro se ocorrer

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida; 
      END IF; 
      
      --> Commit para garantir a gravação do parametro de 
      --> controle de execução do programa DEBSIC CTRL_DEBSIC_EXEC
      COMMIT;
/*      
      -- Procedure para atualizar o registro de transação para não efetivado
      PAGA0001.pc_atualiza_trans_nao_efetiv ( pr_cdcooper => pr_cdcooper  --Código da Cooperativa
                                             ,pr_nrdconta => 0           --Numero da Conta
                                             ,pr_cdagenci => 90          --Código da Agencia
                                             ,pr_dtmvtolt => vr_dtmvtopg --Data Proximo Pagamento
                                             ,pr_dstransa => vr_dstransa --Msg Transacao
                                             ,pr_cdcritic => vr_cdcritic --Código de erro
                                             ,pr_dscritic => vr_dscritic);
      
      IF  vr_dscritic IS NOT NULL  THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;
*/
      -- Carrega o numero de dias para baixa dos valores
      vr_dstextab := TABE0001.fn_busca_dstextab( pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 00
                                                ,pr_cdacesso => 'HRPGSICRED'
                                                ,pr_tpregist => 90);
                                                    
      IF vr_dstextab IS NULL THEN
        -- setando a mensagem de erro
        vr_dscritic := 'Tabela HRPGSICRED nao cadastrada.';
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;
      
      /** Verificar se deve fazer segundo processamento - DEBSIC **/
      IF substr(vr_dstextab,19,3) = 'SIM' THEN
        vr_flsgproc := TRUE;
      ELSE
        vr_flsgproc := FALSE;
      END IF;  
      
      -- Busca os lançamentos de agendamento efetuado pela INTERNET e TAA retornandso na tabela temporária
      SICR0001.pc_obtem_agendamentos_debito( pr_cdcooper => pr_cdcooper                 --> Informações da cooperativa
                                            ,pr_nmrescop => rw_crapcop.nmrescop         --> Nome resumido da cooperativa
                                            ,pr_dtmvtopg => vr_dtmvtopg                 --> Data da efetivação do débito
                                            ,pr_inproces => rw_crapdat.inproces         --> Indicador do processo
                                            ,pr_tab_agendamentos => vr_tab_agendamentos --> Retorna os agendamentos
                                            ,pr_cdcritic => vr_cdcritic                 --> Codigo da critica de erro
                                            ,pr_dscritic => vr_dscritic);               --> Descrição do erro
      
      IF vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;
      
      -- Efetuando a operação de débitos
      SICR0001.pc_efetua_debitos( pr_cdcooper => pr_cdcooper         --> Código da coopertiva
                                 ,pr_dtmvtopg => vr_dtmvtopg         --> Data da efetivação do débito
                                 ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                 ,pr_cdprogra => vr_cdprogra         --> Código do programa
                                 ,pr_flsgproc => vr_flsgproc         --> Indicador do segundo processamento - DEBSIC 
                                 ,pr_tab_agendamentos => vr_tab_agendamentos --> Tabela temporária com a carga de agendamentos
                                 ,pr_cdcritic => vr_cdcritic         --> Codigo da critica de erro
                                 ,pr_dscritic => vr_dscritic);       --> descrição do erro se ocorrer
                                            
      IF vr_dscritic IS NOT NULL THEN
        --Envio do log de erro
        RAISE vr_exc_saida;
      END IF;
      
      -- Gderando o resumo das operações efetuadas
      SICR0001.pc_gera_relatorio( pr_cdcooper  => pr_cdcooper         --> Código da cooperativa
                                 ,pr_cdprogra  => vr_cdprogra         --> Código do programa
                                 ,pr_inproces  => rw_crapdat.inproces --> Indicador do processo
                                 ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento
                                 ,pr_tab_agend => vr_tab_agendamentos --> Tabela temporária com a carga de agendamentos
                                 ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica de erro
                                 ,pr_dscritic  => vr_dscritic);       --> descrição do erro se ocorrer
     
      -- Encerramento da solicitação
      pr_infimsol := 1;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetuar Commit de informações pendentes de gravação
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo até então
        COMMIT;      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos código e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps642;
/
