CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS624(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                      ,pr_cdagenci  IN crapage.cdagenci%type  --> Codigo da agencia logada
                                      ,pr_cdoperad  IN crapope.cdoperad%type  --> Codigo do operador logado
                                      ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                      ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                      ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                      ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  /* ..........................................................................

     Programa: PC_CRPS624    (Fontes/crps624.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Adriano
     Data    : Agosto/2012                     Ultima atualizacao: 26/11/2013

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Realiza o calculo do fluxo financeiro.


     Alteracoes: 15/03/2013 - Incluido a chamada para as procedures
                              pi_rec_mov_conta_itg_f, pi_rem_mov_conta_itg_f
                              (Adriano).

                 26/11/2013 - Conversao Progress >> Oracle PLSQL (Odirlei-AMcom)

   ............................................................................. */

  -- Codigo do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS624';
  -- Tratamento de erros
  vr_exc_fimprg EXCEPTION;
  vr_exc_saida  EXCEPTION;

  vr_tab_erro   gene0001.typ_tab_erro;
  vr_dscritic   varchar2(4000);
  vr_cdcritic   crapcri.cdcritic%TYPE;

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nrtelura
          ,cop.dsdircop
          ,cop.cdbcoctl
          ,cop.cdagectl
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  /* Cursor generico de calendario */
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;

  /* Ler todas as cooperativas ativas */
  CURSOR cr_lista_crapcop IS
    SELECT cop.cdcooper, cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper <> 3
       AND cop.flgativo = 1;

BEGIN

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
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;
  -- Leitura do calendario da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se nao encontrar
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
  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro e <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Iniciando a busca das cooperativas para processo
  FOR rw_coop IN cr_lista_crapcop LOOP

    -- Gravar movimento do fluxo financeiro
    FLXF0001.pc_grava_fluxo_financeiro( pr_cdcooper => rw_coop.cdcooper     -- Codigo da Cooperativa
                                       ,pr_nmrescop => rw_coop.nmrescop     -- Nome resumido da Coop
                                       ,pr_cdagenci => pr_cdagenci          -- Codigo da agencia
                                       ,pr_nrdcaixa => 0                    -- Numero da caixa
                                       ,pr_cdoperad => pr_cdoperad          -- Codigo do operador
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento
                                       ,pr_cdprogra => vr_cdprogra          -- Nome da tela
                                       ,pr_dtmvtoan => rw_crapdat.dtmvtoan  -- Data de movimento anterior
                                       ,pr_dtmvtopr => rw_crapdat.dtmvtopr  -- Data do movimento posterior
                                       ,pr_tab_erro => vr_tab_erro          -- Tabela contendo os erros
                                       ,pr_dscritic => vr_dscritic);

    IF vr_dscritic <> 'OK' OR vr_tab_erro.count > 0 THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Iterar todos os erros da tab erro
      IF vr_tab_erro.count > 0 THEN
        FOR vr_idx IN vr_tab_erro.first..vr_tab_erro.last LOOP
          -- Envio ao log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_tab_erro(vr_idx).dscritic );
        END LOOP;
      END IF;  
      -- Direcionar a saida para desfazer as alterações
      RAISE vr_exc_saida;
    END IF;

  END LOOP;

  -- Processo OK, devemos chamar a fimprg
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

END PC_CRPS624;
/
