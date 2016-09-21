CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps356 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

   Programa: pc_crps356 (Fontes/crps356.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Setembro/2003                   Ultima atualizacao: 19/03/2014

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 13.
               Ordem na Solicitacao = 21
               Gerar arquivo para microfilmagem relatorio razao de capital.

   Alteracoes: 02/08/2004 - Alterar diretorio win12 (Margarete).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Troca de posicao do include var_batch.i. O include
                            estava abaixo do include gerarazao_def.i gerando
                            erro de compilacao de variavel glb_cdcooper nao
                            definida - SQLWorks - Eder

               07/03/2006 - Efetuado acerto programa(Alimentar variavel
                            aux_cdcxaage apos iniprg.p. Retirado da include
                            gerarazao_def.i)(Mirtes)

               19/03/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

..............................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS356';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
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


      ------------------------------- VARIAVEIS -------------------------------
      vr_dtperini DATE;              --> Data inicial do periodo
      vr_dtperfim DATE;              --> Data final do periodo
      vr_sufixarq VARCHAR2(07);      --> Extensao do arquivo CRADRAP
      vr_nom_direto VARCHAR2(500);   --> Diretorio base da cooperativa
      vr_nmarquiv VARCHAR2(500);     --> Nome do arquivo

      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
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
      vr_dtperfim := last_day(add_months(rw_crapdat.dtmvtolt,-1)); -- Ultimo dia do mes anterior
      vr_dtperini := trunc(vr_dtperfim,'MM'); -- Primeiro dia do mes anterior

      vr_sufixarq := '.'|| to_char(vr_dtperfim,'YYYYMM');


      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'W' -- /usr/coop/win12/
                                            ,pr_cdcooper => pr_cdcooper);

      vr_nmarquiv := vr_nom_direto ||
                     '/microfilmagem/cradrct' || vr_sufixarq;

      -- Chama rotina para geracao do livro auxiliar
      cobr0002.pc_gera_razao(pr_cdcooper => pr_cdcooper,
                             pr_dtperini => vr_dtperini,
                             pr_dtperfim => vr_dtperfim,
                             pr_nmestrut => 'craplct',
                             pr_nmcampocta => 'nrdconta',
                             pr_nmestrut_aux => 'craplct',
                             pr_nmarquiv => vr_nmarquiv,
                             pr_stprogra => pr_stprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic,
                             pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

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
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
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
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

  END pc_crps356;
/

