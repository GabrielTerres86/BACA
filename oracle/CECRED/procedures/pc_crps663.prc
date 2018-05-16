CREATE OR REPLACE PROCEDURE CECRED.pc_crps663 (pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
    /* .............................................................................

     Programa: pc_crps663            Antigo: fontes/crps663.i (include de crps662.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Teobaldo Jamunda
     Data    : Maio/2019                         Ultima atualizacao: __/__/____

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Efetuar debito de consorcios, mediante chamada de rotina principal
                 CNSO0001.pc_gera_debitos

     Alteracoes: 03/05/2018 - Conversao Progress -> Oracle - Teobaldo J. (AMcom)

     ................................................................................ */


    -- Selecionar os dados da Cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,cop.cdbcoctl
            ,cop.cdagectl
            ,cop.dsdircop
            ,cop.nrctactl
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
      
    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;       
       
    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS663';

    -- Tratamento de erros
    vr_exc_erro   exception;
    vr_exc_fimprg exception;
    vr_cdcritic   crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_nmrelato   VARCHAR2(255);
    vr_flultexe   INTEGER;
    vr_qtdexec    INTEGER;

BEGIN    
     
    -- Verifica quantidade de execucoes do programa durante o dia no Debitador Unico
    gen_debitador_unico.pc_qt_hora_prg_debitador(pr_cdcooper   => pr_cdcooper        --> Cooperativa
                                                ,pr_cdprocesso => 'PC_'||vr_cdprogra --> Processo cadastrado na tela do Debitador (tbgen_debitadorparam)
                                                ,pr_ds_erro    => vr_dscritic);      --> Retorno de Erro/Crítica
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);
     
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1 --true
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);
    
    --Se retornou critica aborta programa
    IF vr_cdcritic <> 0 THEN
      --Descricao do erro recebe mensagam da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_cdprogra || ' --> '
                                                    || vr_dscritic );
      --Sair do programa
      RAISE vr_exc_erro;
    END IF;
    
    /* Procedimento para verificar/controlar a execução da CRPS663 */
    cecred.sicr0001.pc_controle_exec_deb(pr_cdcooper => pr_cdcooper,           --> Código da coopertiva
                                         pr_cdtipope => 'I',                   --> Tipo de operacao I-incrementar e C-Consultar
                                         pr_dtmvtolt => rw_crapdat.dtmvtolt,   --> Data do movimento
                                         pr_cdprogra => vr_cdprogra,           --> Codigo do programa
                                         pr_flultexe => vr_flultexe,           --> Retorna se é a ultima execução do procedimento
                                         pr_qtdexec  => vr_qtdexec,            --> Retorna a quantidade
                                         pr_cdcritic => vr_cdcritic,           --> Codigo da critica de erro
                                         pr_dscritic => vr_dscritic);          --> descrição do erro se ocorrer
    
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Commit para garantir o
    --controle de execucao do programa
    COMMIT;  

    -- Executa rotina principal Debito de Consorcio 
    CNSO0001.pc_gera_debitos (pr_cdcooper => pr_cdcooper  --> Cooperativa
                             ,pr_flgresta => pr_flgresta         --> Flag padrao para utilizacao de restart
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Indicador processo
                             ,pr_flultexe => vr_flultexe         --> Flag para indicar se eh ultima execucao
                             ,pr_cdprogra => vr_cdprogra         --> Codigo programa
                             ,pr_nmrelato => vr_nmrelato         --> Nome do relatorio gerado
                             ,pr_cdcritic => vr_cdcritic         --> Codigo da Critica
                             ,pr_dscritic => vr_dscritic);       --> Descricao da Critica

    IF vr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_erro;
    END IF;
           
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

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
    WHEN vr_exc_erro THEN
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
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

END pc_crps663;
/
