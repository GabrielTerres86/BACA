CREATE OR REPLACE PROCEDURE CECRED.pc_crps648 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                       ,pr_nmdatela IN VARCHAR2               --> Nome da Tela
                                       ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN

  /* ............................................................................

   Programa: pc_crps648                         Antigo: fontes/crps648.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Julho/2013.                        Ultima atualizacao: 09/03/2016 


   Frequencia : Sempre que for chamado. RODA NA CADEIA CECRED
   Objetivo   : Integrar pagamentos INSS recebidas via MQ

   Observacao :

   Alterações : 07/08/2014 - Conversao Progress -> Oracle (Alisson - AMcom)

                09/03/2016 - feita a troca na geração do log que gerava no batch para o message conforme 
                             solicitado no chamado 396313. (Kelvin)


  ............................................................................. */

  DECLARE

    ------------------------ CONSTANTES  -------------------------------------

    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS648';  -- Codigo do Programa

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_cdcritic   PLS_INTEGER:= 0;
    vr_des_reto   VARCHAR2(3);
    vr_dscritic   VARCHAR2(4000);

    -------------------------------- EXCECOES  -------------------------------
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;

    ------------------------------- CURSORES ---------------------------------

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    --Tabela de Erros
    vr_tab_erro GENE0001.typ_tab_erro;


  BEGIN
    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar critica
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
      -- Montar critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

    --Mensagem Inicio Processamento
    vr_dscritic:= 'INSS - INICIO - Pagamento Beneficios';
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
    --Limpar tabela erros
    vr_tab_erro.DELETE;

    /* Executar Solicitação Creditos Beneficios INSS */
    inss0001.pc_benef_inss_proces_pagto (pr_cdcooper => pr_cdcooper   --Cooperativa
                                        ,pr_cdagenci => 1             --Codigo Agencia
                                        ,pr_nrdcaixa => 1             --Numero Caixa
                                        ,pr_idorigem => 1             --Origem Processamento
                                        ,pr_cdoperad => '1'           --Operador
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --Data Movimento
                                        ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                        ,pr_cdprogra => vr_cdprogra   --Nome Programa
                                        ,pr_des_reto => vr_des_reto   --Saida OK/NOK
                                        ,pr_tab_erro => vr_tab_erro); --Tabela Erros
    --Se ocorreu erro
    IF vr_des_reto = 'NOK' THEN
      vr_dscritic:= ' INSS - FIM    - Pagamento Beneficios - ';
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT = 0 THEN
        --Montar Mensagem
        vr_dscritic:= vr_dscritic||'Erro no processo de pagamento do Beneficio INSS';
      ELSE
        --Primeiro erro da tabela
        vr_dscritic:= vr_dscritic||vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      END IF;
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF;

    --Mensagem Final Processamento
    vr_dscritic:= 'INSS - FIM    - Pagamento Beneficios';
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(SYSDATE,
                                                    'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

		-- commit final
		COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar COMMIT;
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps648;
/
