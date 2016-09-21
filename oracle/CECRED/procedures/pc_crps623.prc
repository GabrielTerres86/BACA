CREATE OR REPLACE PROCEDURE CECRED.pc_crps623(pr_cdcooper IN crapcop.cdcooper%TYPE     --> COOPERATIVA SOLICITADA
                                      ,pr_flgresta IN PLS_INTEGER               --> FLAG PADR�O PARA UTILIZA��O DE RESTART
                                      ,pr_stprogra OUT PLS_INTEGER              --> SA�DA DE TERMINO DA EXECU��O
                                      ,pr_infimsol OUT PLS_INTEGER              --> SA�DA DE TERMINO DA SOLICITA��O
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE    --> CRITICA ENCONTRADA
                                      ,pr_dscritic OUT VARCHAR2) IS             --> TEXTO DE ERRO/CRITICA ENCONTRADA
BEGIN

  /* ..........................................................................

   Programa: fontes/crps623.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2012                   Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 013.
               Faz a conexao com o banco progrid para limpeza da gnapses.

   Alteracoes:
               03/07/2014 - Convers�o Progress >> Oracle (Renato - Supero)

  ............................................................................. */
  DECLARE

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
           , cop.nmrescop
           , cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; -- CODIGO DA COOPERATIVA
    rw_crapcop     cr_crapcop%ROWTYPE;

    -- Buscar parametro de execu��o
    CURSOR cr_craptab IS
      SELECT craptab.dstextab
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 00
         AND craptab.cdacesso = 'EXELIMPEZA'
         AND craptab.tpregist = 001;
    rw_craptab     cr_craptab%ROWTYPE;

    -- TIPOS

    -- CURSOR GEN�RICO DE CALEND�RIO
    rw_crapdat      btch0001.cr_crapdat%ROWTYPE;

    -- VARI�VEIS
    -- C�digo do programa
    vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS623';

    -- TRATAMENTO DE ERROS
    vr_exc_saida    EXCEPTION;
    vr_exc_fimprg   EXCEPTION;
    vr_cdcritic     PLS_INTEGER;
    vr_dscritic     VARCHAR2(4000);

  BEGIN

    -- INCLUIR NOME DO M�DULO LOGADO
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);

    -- VERIFICA SE A COOPERATIVA ESTA CADASTRADA
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
      INTO rw_crapcop;

    -- SE N�O ENCONTRAR
    IF cr_crapcop%NOTFOUND THEN
      -- FECHAR O CURSOR POIS HAVER� RAISE
      CLOSE cr_crapcop;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE cr_crapcop;
    END IF;

    -- LEITURA DO CALEND�RIO DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

    -- SE N�O ENCONTRAR
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR O CURSOR POIS EFETUAREMOS RAISE
      CLOSE btch0001.cr_crapdat;
      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- VALIDA��ES INICIAIS DO PROGRAMA
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    -- SE A VARIAVEL DE ERRO � <> 0
    IF vr_cdcritic <> 0 THEN
      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      RAISE vr_exc_saida;
    END IF;

    -- Buscar parametros de execu��o
    OPEN  cr_craptab;
    FETCH cr_craptab INTO rw_craptab;

    -- Verifica se h� registros
    IF cr_craptab%NOTFOUND THEN
      vr_cdcritic := 176; -- 176 - Falta tabela de execucao de limpeza - registro 001
      RAISE vr_exc_saida;
    ELSE
      -- Verifica a informa��o retornada
      IF rw_craptab.dstextab = '1' THEN
        vr_cdcritic := 177; -- 177 - Limpeza ja rodou este mes.
        RAISE vr_exc_fimprg;
      END IF;
    END IF;

    CLOSE cr_craptab;

    -- Excluir os registros de 30 dias para tr�s
    BEGIN
      DELETE gnapses
       WHERE gnapses.dtsessao < (rw_crapdat.dtmvtolt - 30)
         AND gnapses.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN OTHERS THEN
        -- Encerrar com erro, informando problema na exclus�o
        vr_dscritic := 'Erro ao excluir GNAPSES: '||SQLERRM;
        RAISE vr_exc_saida;
    END;

    -- Define e busca informa��es da cr�tica a ser exibida no hist�rico
    vr_cdcritic := 661; -- 661 - DELETADOS NO
    vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    vr_dscritic := vr_dscritic||' GNAPSES = '||to_Char(SQL%ROWCOUNT, 'FM9g999g990');

    -- ENVIO CENTRALIZADO DE LOG DE ERRO
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 1 -- PROCESSO NORMAL
                              ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> ' || vr_dscritic);

    -- PROCESSO OK, DEVEMOS CHAMAR A FIMPRG
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);

    -- SALVAR INFORMA��ES ATUALIZADAS
    COMMIT;

  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- SE FOI RETORNADO APENAS C�DIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRI��O
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- ENVIO CENTRALIZADO DE LOG DE ERRO
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- ERRO TRATATO
                                ,pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);

      -- CHAMAMOS A FIMPRG PARA ENCERRARMOS O PROCESSO SEM PARAR A CADEIA
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);

      -- EFETUAR COMMIT
      COMMIT;
    WHEN vr_exc_saida THEN
      -- SE FOI RETORNADO APENAS C�DIGO
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- BUSCAR A DESCRI��O
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- DEVOLVEMOS C�DIGO E CRITICA ENCONTRADAS DAS VARIAVEIS LOCAIS
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := vr_dscritic;
      -- EFETUAR ROLLBACK
      ROLLBACK;
    WHEN OTHERS THEN
      -- EFETUAR RETORNO DO ERRO N�O TRATADO
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      -- EFETUAR ROLLBACK
      ROLLBACK;
  END;

END pc_crps623;
/

