CREATE OR REPLACE PROCEDURE CECRED.pc_crps273 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps273 (Fontes/crps273.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah
       Data    : Agosto/1999                       Ultima atualizacao: 26/10/2017

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Atende a solicitacao 001 (batch - atualizacao).
                   Roda somente no dia 10 ou seguinte.
                   Calcula o total de creditos do mes anterios (lavagem de
                   dinheiro).


       Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando.

                   09/06/2008 - Incluído o mecanismo de pesquisa no "for each" na
                                tabela CRAPHIS para buscar primeiro pela chave de
                                acesso (craphis.cdcooper = glb_cdcooper).
                                - Kbase IT Solutions - Paulo Ricardo Maciel.

                   19/10/2009 - Alteracao Codigo Historico (Kbase).

                   05/03/2010 - Alteracao Historico (GATI)

                   10/03/2014 - Conversão Progress >> PLSQL (Edison-Amcom).
                                
                   07/08/2017 - Não executar processo quando a data não for a da regra - Chamado 678813
                                Padronizar as mensagens - Chamado 721285
                                Tratar os exception others - Chamado 721285
                                Ajustada chamada para buscar a descrição da critica - Chamado 721285
                                Retirada exception vr_exc_fimprg
                               ( Belli - Envolti )                   
                                
                   26/10/2017 - Ajustar set module e gerar Log TBGEN - 
                                O erro de Dead Lock esta com a equipe de DB
                               ( Belli - Envolti - Chamados 7774244 e 788269 )                   

    ............................................................................ */
    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS273';
      vr_cdrotina CONSTANT VARCHAR2(15)          := 'PC_' || vr_cdprogra ;
      
      -- Controla o tipo de ocorrencia - Chamados 788269 - 26/10/2017
      vr_ind_tipo_log      NUMBER(1);
      vr_dstiplog          VARCHAR2(1);
      vr_cdcriticidade     tbgen_prglog_ocorrencia.cdcriticidade%TYPE;

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      
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

      --tabela de saldos de todos os cooperados
      CURSOR cr_crapsld(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT crapsld.nrdconta
              ,crapsld.vlcremes
              ,crapsld.vltotcre##1
              ,crapsld.vltotcre##2
              ,crapsld.vltotcre##3
              ,crapsld.vltotcre##4
              ,crapsld.vltotcre##5
              ,crapsld.vltotcre##6
              ,crapsld.vltotcre##7
              ,crapsld.vltotcre##8
              ,crapsld.vltotcre##9
              ,crapsld.vltotcre##10
              ,crapsld.vltotcre##11
              ,crapsld.vltotcre##12
              ,ROWID
        FROM   crapsld
        WHERE  crapsld.cdcooper = pr_cdcooper
        ORDER BY crapsld.nrdconta;

      rw_crapsld cr_crapsld%ROWTYPE;

      --lancamentos na conta do cooperado no periodo e historicos
      --com indicador de crédito que somem na estatística
      CURSOR cr_craplcm( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_dtiniref IN DATE
                        ,pr_dtfimref IN DATE) IS
        SELECT craplcm.vllanmto
              ,craplcm.cdhistor
        FROM   craplcm
              ,craphis
        WHERE  craplcm.cdcooper = craphis.cdcooper
        AND    craplcm.cdhistor = craphis.cdhistor
        AND    craphis.incremes = 1 -- Indicador de credito do mes: 1-soma na estatistica
        AND    craplcm.cdcooper = pr_cdcooper
        AND    craplcm.nrdconta = pr_nrdconta
        AND    craplcm.dtmvtolt > pr_dtiniref
        AND    craplcm.dtmvtolt < pr_dtfimref
        ORDER BY /*craplcm.cdcooper
                ,craplcm.nrdconta
                ,*/craplcm.dtmvtolt
                ,craplcm.cdhistor
                ,craplcm.nrdocmto;

      ------------------------------- VARIAVEIS -------------------------------
      vr_dtfimref   DATE;
      vr_dtiniref   DATE;
      vr_dtmesref   NUMBER;

  --> Controla log proc_batch, atualizando parâmetros conforme tipo de ocorrência
  PROCEDURE pc_gera_log(pr_cdcooper_in   IN crapcop.cdcooper%TYPE,
                        pr_dstiplog      IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                        pr_dscritic      IN VARCHAR2 DEFAULT NULL,
                        pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0,
                        pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0,
                        pr_ind_tipo_log  IN tbgen_prglog_ocorrencia.tpocorrencia%type DEFAULT 2) IS

    -----------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gera_log
    --  Sistema  : Rotina para gravar logs em tabelas
    --  Sigla    : CRED
    --  Autor    : Ana Lúcia E. Volles - Envolti
    --  Data     : Novembro/2017           Ultima atualizacao: 20/11/2017
    --  Chamado  : 788269
    --
    -- Dados referentes ao programa:
    -- Frequencia: Rotina executada em qualquer frequencia.
    -- Objetivo  : Controla gravação de log em tabelas.
    --
    -- Alteracoes:  
    --             
    ------------------------------------------------------------------------------------------------------------   
  BEGIN     
    --> Controlar geração de log de execução dos jobs
    --Como executa na cadeira, utiliza pc_gera_log_batch
    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                      
                              ,pr_ind_tipo_log  => pr_ind_tipo_log
                              ,pr_nmarqlog      => 'proc_batch.log'                 
                              ,pr_dstiplog      => NVL(pr_dstiplog,'E')             
                              ,pr_cdprograma    => vr_cdprogra                      
                              ,pr_tpexecucao    => 1 -- batch                       
                              ,pr_cdcriticidade => pr_cdcriticidade                      
                              ,pr_cdmensagem    => pr_cdmensagem                      
                              ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                  || vr_cdprogra || ' --> '|| pr_dscritic);
  EXCEPTION  
    WHEN OTHERS THEN  
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
  END pc_gera_log;
  
  PROCEDURE prc_processa 
    /* .............................................................................

       Programa: pc_crps273
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Data    : Oktober/2017                     Ultima atualizacao: 26/10/2017
       Autor   : Belli - Envolti - Chamado 774244

       Dados referentes ao programa:

       Frequencia: Disparado pela ppropria procedure.
       Objetivo  : Otimizar o controle do programa.

       Alteracoes: 

    ............................................................................. */
  IS
  BEGIN
    -- Incluir set modulo - Chamado 774244 - 26/10/2017
    GENE0001.pc_set_modulo(pr_module => vr_cdrotina || '.prc_processa', pr_action => NULL);

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    --vai para o último dia de dois meses anteriores
    vr_dtiniref := last_day(add_months(rw_crapdat.dtmvtolt,-2));
    --vai para o primeiro dia do mes de referencia
    vr_dtfimref := trunc(rw_crapdat.dtmvtolt,'MONTH');

    --calcula o mes de referencia
    IF to_number(to_char(rw_crapdat.dtmvtolt,'MM')) < 3 THEN
      vr_dtmesref := to_number(to_char(rw_crapdat.dtmvtolt,'MM')) + 10;
    ELSE
      vr_dtmesref := to_number(to_char(rw_crapdat.dtmvtolt,'MM')) - 2;
    END IF;

    -- inicio do processo
    FOR rw_crapsld IN cr_crapsld(pr_cdcooper => pr_cdcooper) LOOP

      --verifica e atribui os creditos do mes ao campo ref. ao mes do processamento
      CASE vr_dtmesref
        WHEN 01 THEN rw_crapsld.vltotcre##1  := rw_crapsld.vlcremes;
        WHEN 02 THEN rw_crapsld.vltotcre##2  := rw_crapsld.vlcremes;
        WHEN 03 THEN rw_crapsld.vltotcre##3  := rw_crapsld.vlcremes;
        WHEN 04 THEN rw_crapsld.vltotcre##4  := rw_crapsld.vlcremes;
        WHEN 05 THEN rw_crapsld.vltotcre##5  := rw_crapsld.vlcremes;
        WHEN 06 THEN rw_crapsld.vltotcre##6  := rw_crapsld.vlcremes;
        WHEN 07 THEN rw_crapsld.vltotcre##7  := rw_crapsld.vlcremes;
        WHEN 08 THEN rw_crapsld.vltotcre##8  := rw_crapsld.vlcremes;
        WHEN 09 THEN rw_crapsld.vltotcre##9  := rw_crapsld.vlcremes;
        WHEN 10 THEN rw_crapsld.vltotcre##10 := rw_crapsld.vlcremes;
        WHEN 11 THEN rw_crapsld.vltotcre##11 := rw_crapsld.vlcremes;
        WHEN 12 THEN rw_crapsld.vltotcre##12 := rw_crapsld.vlcremes;
      END CASE;

      --zerando o valor dos creditos do mes
      rw_crapsld.vlcremes := 0;

      --busca todos os lancamentos do periodo do cooperado
      --com indicador de crédito que somem na estatística
      --para recompor os creditos do mes
      FOR rw_craplcm IN cr_craplcm( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapsld.nrdconta
                                   ,pr_dtiniref => vr_dtiniref
                                   ,pr_dtfimref => vr_dtfimref) LOOP

        --acumulando os valores do mes de referencia
        rw_crapsld.vlcremes := nvl(rw_crapsld.vlcremes,0) + nvl(rw_craplcm.vllanmto,0);
      END LOOP;

      BEGIN
        UPDATE crapsld
          SET vlcremes      = rw_crapsld.vlcremes
              ,vltotcre##1  = rw_crapsld.vltotcre##1
              ,vltotcre##2  = rw_crapsld.vltotcre##2
              ,vltotcre##3  = rw_crapsld.vltotcre##3
              ,vltotcre##4  = rw_crapsld.vltotcre##4
              ,vltotcre##5  = rw_crapsld.vltotcre##5
              ,vltotcre##6  = rw_crapsld.vltotcre##6
              ,vltotcre##7  = rw_crapsld.vltotcre##7
              ,vltotcre##8  = rw_crapsld.vltotcre##8
              ,vltotcre##9  = rw_crapsld.vltotcre##9
              ,vltotcre##10 = rw_crapsld.vltotcre##10
              ,vltotcre##11 = rw_crapsld.vltotcre##11
              ,vltotcre##12 = rw_crapsld.vltotcre##12
        WHERE ROWID = rw_crapsld.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                         ' crapsld' || '. vlcremes:' || rw_crapsld.vlcremes ||
                         ', vltotcre:' || rw_crapsld.vltotcre##1 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##2 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##3 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##4 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##5 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##6 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##7 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##8 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##9 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##10 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##11 ||
                         ', vltotcre:' || rw_crapsld.vltotcre##12 ||
                         ', rowid:' || rw_crapsld.rowid ||
                         '. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END LOOP;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      RAISE vr_exc_saida;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      --Variavel de erro recebe erro ocorrido
      vr_cdcritic := 9999;
      -- monta descrição do erro com os parametros
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) || SQLERRM;
      RAISE vr_exc_saida;

  END prc_processa;
    
    ---
    
  BEGIN

    --------------- VALIDACOES INICIAIS -----------------
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => vr_cdrotina
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;

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
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

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

    -- Log de início da execução
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'I');
          
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

    --
    -- Não executar processo quando a data não for a da regra - 07/08/2017 - Chamado 678813
    /* Roda somente no dia 10 (ou seguinte) de cada mes */
    IF NOT (to_number(TO_CHAR(rw_crapdat.dtmvtolt,'DD')) >= 10 AND
            to_number(to_char(rw_crapdat.dtmvtoan,'DD')) <  10) THEN
      --finaliza o programa sem gerar excecao
      NULL;
    ELSE
        prc_processa;
      -- Retorna set modulo - Chamado 774244 - 26/10/2017
      GENE0001.pc_set_modulo(pr_module => vr_cdrotina, pr_action => NULL);
    END IF;
    --

    -- Log de término da execução
    pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                pr_dstiplog      => 'F');


    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas
    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Ajustada chamada para buscar a descrição da critica - 07/08/2017 - Chamado 721285
      -- Devolvemos código e critica encontradas das variaveis locais
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      -- Devolvemos código e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      -- Monta se chega erro tratado ou não tratado para apontar o tipo de ocorrencia - Chamado 788269 - 26/10/2017
      IF pr_cdcritic IN ( 9999, 1035 ) THEN 
        vr_ind_tipo_log  := 3;
        vr_cdcriticidade := 2;
      ELSE 
        vr_ind_tipo_log  := 2; 
        vr_cdcriticidade := 1;
      END IF;

      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => vr_cdcriticidade,
                  pr_cdmensagem    => vr_cdcritic,
                  pr_ind_tipo_log  => vr_ind_tipo_log);

      -- Efetuar rollback
      ROLLBACK;     
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log - 07/08/2017 - Chamado 721285        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) || SQLERRM;

      -- Envio centralizado de log de erro
      pc_gera_log(pr_cdcooper_in   => pr_cdcooper,
                  pr_dstiplog      => 'E',
                  pr_dscritic      => vr_dscritic,
                  pr_cdcriticidade => 2,
                  pr_cdmensagem    => vr_cdcritic,
                  pr_ind_tipo_log  => 3);

      -- Efetuar rollback
      ROLLBACK; 
  END;

  END pc_crps273;
/
