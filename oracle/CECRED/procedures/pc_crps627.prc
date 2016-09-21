CREATE OR REPLACE PROCEDURE CECRED.pc_crps627(pr_cdcooper  IN NUMBER         --> C�digo da cooperativa
                                      ,pr_flgresta  IN PLS_INTEGER    --> Indicador para utiliza��o de restart
                                      ,pr_stprogra  OUT PLS_INTEGER   --> Sa�da de termino da execu��o
                                      ,pr_infimsol  OUT PLS_INTEGER   --> Sa�da de termino da solicita��o
                                      ,pr_cdcritic  OUT NUMBER        --> C�digo cr�tica
                                      ,pr_dscritic  OUT VARCHAR2) IS  --> Descri��o cr�tica
  /* ..........................................................................

   Programa: PC_CRPS627   (antigo Fontes/crps627.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano
   Data    : Outubro/2012                     Ultima atualizacao: 13/09/2013

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Realiza a formacao do grupo economico.


   Alteracoes: 22/03/2013 - Ajuste para alimentar a aux_persocio com as posicoes
                            "91,6" ao inves de "28,6" (Adriano).

               13/09/2013 - Convers�o Progress >> PLSQL (Petter-Supero)
  ............................................................................. */
BEGIN
  DECLARE
    vr_cdprogra        VARCHAR2(10);                   --> Nome do programa
    vr_exc_erro        EXCEPTION;                      --> Controle de exce��o
    rw_crapdat         btch0001.cr_crapdat%rowtype;    --> Dados para fetch de cursor gen�rico
    vr_persocio        NUMBER(10,2);                   --> S�cios
    vr_cdoperad        VARCHAR2(40);                   --> C�digo do cooperado

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> C�digo da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Busca dados de taxas
    CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE               --> C�digo cooperativa
                     ,pr_nmsistem IN craptab.nmsistem%TYPE               --> Nome sistema
                     ,pr_tptabela IN craptab.tptabela%TYPE               --> Tipo tabela
                     ,pr_cdempres IN craptab.cdempres%TYPE               --> c�digo empresa
                     ,pr_cdacesso IN craptab.cdacesso%TYPE               --> C�digo acesso
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS           --> Tipo de registro
      SELECT substr(cb.dstextab, 49, 15) dstextabs
            ,cb.dstextab
      FROM craptab cb
      WHERE cb.cdcooper = pr_cdcooper
        AND cb.nmsistem = pr_nmsistem
        AND cb.tptabela = pr_tptabela
        AND cb.cdempres = pr_cdempres
        AND cb.cdacesso = pr_cdacesso
        AND cb.tpregist = pr_tpregist;
    rw_craptab cr_craptab%rowtype;

  BEGIN
    -- Atribui��o de valores iniciais da procedure
    vr_cdprogra := 'CRPS627';
    vr_persocio := 0;

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS627', pr_action => NULL);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Se n�o encontrar registros montar mensagem de critica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;

      pr_cdcritic := 651;

      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Valida��es iniciais do programa
    btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                              ,pr_flgbatch => 1
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_infimsol => pr_infimsol
                              ,pr_cdcritic => pr_cdcritic);

    -- Caso retorno cr�tica busca a descri��o
    IF pr_cdcritic <> 0 THEN
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
      RAISE vr_exc_erro;
    END IF;

    -- Selecionar informacoes das datas
    OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Buscar a descri��o das faixas contido na craptab
    OPEN cr_craptab(pr_cdcooper, 'CRED', 'GENERI', 00, 'PROVISAOCL', 999);
    FETCH cr_craptab INTO rw_craptab;

    -- Verifica se a tupla retornou registro
    IF cr_craptab%NOTFOUND THEN
      CLOSE cr_craptab;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') || ' - ' || vr_cdprogra || ' --> Valor do Percentual Societario Exigido ' ||
                                                    'ao foi encontrado para a ' || rw_crapcop.nmrescop
                                ,pr_nmarqlog     => 'PROC_BATCH');

      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craptab;
      vr_persocio := to_number(substr(rw_craptab.dstextab, 91, 6));
    END IF;

    -- Incluir include
    PC_CRPS634_I(pr_cdcooper    => pr_cdcooper
                ,pr_cdagenci    => 0
                ,pr_cdoperad    => vr_cdoperad
                ,pr_cdprogra    => vr_cdprogra
                ,pr_persocio    => vr_persocio
                ,pr_tab_crapdat => rw_crapdat
                ,pr_cdcritic    => pr_cdcritic
                ,pr_dscritic    => pr_dscritic);

    -- Verifica se ocorreram erros
    IF pr_dscritic IS NOT NULL OR pr_cdcritic > 0 THEN
      RAISE vr_exc_erro;
    END IF;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas c�digo
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descri��o
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      -- Efetuar rollback
      ROLLBACK;
    WHEN others THEN
      -- Efetuar retorno do erro n�o tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;
END PC_CRPS627;
/

