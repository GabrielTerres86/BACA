CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS152" ( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                          ,pr_flgresta  IN PLS_INTEGER            --> Flag padr�o para utiliza��o de restart
                                          ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                          ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                          ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* ..........................................................................

       Programa: pc_crps152                             (Antigo Fontes/crps152.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Odair
       Data    : Marco/96                      Ultima atualizacao: 22/05/2013

       Dados referentes ao programa:

       Frequencia: Diario. Exclusivo.
       Objetivo  : Atende a solicitacao 5.
                   Ajuste mensal e semanal dos contadores de extrato e talonarios.
                   Ordem do programa na solicitacao 4.

       Alteracoes: 18/07/97 - Alterar para eliminar o controle semanal (Odair)

                   27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

                 15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 25/03/2013 - Alterado campo crapass.qttalmes pelo crapass.qtfolmes
                              Projeto de Tarifas Fase 2 - Grupo de cheques (Lucas R)

                 22/05/2013 - Convers�o Progress >> PLSQL (Marcos-Supero)
    ............................................................................. */


    DECLARE

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      ----------------------------- VARIAVEIS ------------------------------

      -- C�digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS152';
      -- Tratamento de erros
      vr_exc_erro exception;
      vr_exc_fimprg exception;
      vr_cdcritic   crapcri.cdcritic%TYPE;
      vr_dscritic   VARCHAR2(4000);

    BEGIN

      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1--true
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF vr_cdcritic <> 0 THEN
        -- Buscar descri��o da cr�tica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        -- Envio centralizado de log de erro
        RAISE vr_exc_erro;
      END IF;

      -- Somente continuar se o m�s da data atual � diferente do m�s do pr�ximo dia util
      IF trunc(rw_crapdat.dtmvtolt,'mm') <> trunc(rw_crapdat.dtmvtopr,'mm') THEN
        BEGIN
          -- Zerar campos
          --   -> qtfolmes (Quantidade de folhas retiradas no mes.)
          --   -> qtextmes (Quantidade de extratos emitidos na semana.)
          UPDATE crapass
             SET qtfolmes = 0
                ,qtextmes = 0
           WHERE cdcooper = pr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar a tabela CRAPASS. Detalhes '||sqlerrm;
            RAISE vr_exc_erro;
        END;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
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
        -- Efetuar commit pois gravaremos o que foi processo at� ent�o
        COMMIT;

      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos c�digo e critica encontradas
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
    END;
  END pc_crps152;
/

