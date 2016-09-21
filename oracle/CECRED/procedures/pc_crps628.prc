CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps628 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps628 (Fontes/crps628.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Adriano
       Data    : Dezembro/2012                     Ultima atualizacao: 99/99/99

       Dados referentes ao programa:

       Frequencia: Mensal.
       Objetivo  : Atualizar risco sisbacen de acordo com o ge.

       Alteracoes: 20/03/2013 - Ajuste no "FOR EACH crapris" para pegar o nrctasoc
                                ao inves do nrdconta (Adriano).
                                
                   02/05/2014 - Conversão Progress >> Oracle PLSQL (Tiago Castro - RKAM).

    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS628';

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
      
      -- Busca de execucao de cadastro de risco
      CURSOR cr_craptab IS
        SELECT  to_number(SUBSTR(craptab.dstextab,1,1)) dstextab1,
                to_number(SUBSTR(craptab.dstextab,3,9)) dstextab2
        FROM    craptab 
        WHERE   craptab.cdcooper = pr_cdcooper  
        AND     craptab.nmsistem = 'CRED'       
        AND     craptab.tptabela = 'USUARI'
        AND     craptab.cdempres = 11           
        AND     craptab.cdacesso = 'RISCOBACEN'
        AND     craptab.tpregist = 000; 
      rw_craptab cr_craptab%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      
      vr_vlr_arrasto  NUMBER; -- valor divida risco

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
      -- verifica se tem execucao para cadastro de risco
      OPEN cr_craptab;
      FETCH cr_craptab INTO rw_craptab;
      IF cr_craptab%NOTFOUND THEN
        -- gera critica e encerra programa
        CLOSE cr_craptab;
        vr_cdcritic := 055;
        RAISE vr_exc_fimprg;
      END IF;      
      CLOSE cr_craptab;
      IF rw_craptab.dstextab1 <> 2 THEN
        --gera critica e encerra programa
        vr_cdcritic := 411;
        RAISE vr_exc_fimprg;
      ELSE
        vr_vlr_arrasto := rw_craptab.dstextab2; -- valor divida de risco
      END IF;
       --chama procedura para atualizar tabela de riscos
      pc_crps635_i(pr_cdcooper    => pr_cdcooper
                  ,pr_dtrefere    => rw_crapdat.dtultdia
                  ,pr_vlr_arrasto => vr_vlr_arrasto
                  ,pr_flgresta    => pr_flgresta
                  ,pr_stprogra    => pr_stprogra
                  ,pr_infimsol    => pr_infimsol
                  ,pr_cdcritic    => vr_cdcritic 
                  ,pr_dscritic    => vr_dscritic);
                  
      IF vr_dscritic IS NOT NULL THEN-- verifica se houve erros
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

  END pc_crps628;
/

