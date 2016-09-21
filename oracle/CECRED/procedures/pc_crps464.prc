CREATE OR REPLACE PROCEDURE CECRED.
         pc_crps464 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps464                        (Fontes/crps464.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Ze Eduardo
       Data    : Fevereiro/2006                    Ultima atualizacao: 23/06/2014

       Dados referentes ao programa:

       Frequencia: Diario.
       Objetivo  : Gerar arquivos de retorno para os bloquetos pagos no caixa.
                   Atende a solicitacao 82.
                   Ordem 33.

       Alteracoes: 10/04/2006 - Incluir geracao de arquivo Pre-Impresso (Ze).

                   08/08/2006 - Retirado informacao fixa "0014",
                                Acerto no crapass.inarqcbr e Convenio com 7 digitos
                                crapceb (Julio/Ze).

                   23/08/2006 - Nao gerar arquivo para PRE-IMPRESSOS que sejam
                                tipo FEBRABAN (Julio/Ze).

                   31/08/2006 - Alterado envio de email pela BO b1wgen0011 (David).

                   03/10/2006 - Gerar arquivos diferentes para conta e convenios
                                (Julio)

                   12/04/2007 - Retirar rotina de email em comentario (David).

                   21/08/2007 - Alterado para valor de tarifa pegar informacoes da
                                crapcco.vlrtarcx quando bloqueto for pago no caixa
                                ou crapcco.vlrtarnt quando bloqueto for pago via
                                internet (Elton).

                   02/04/2008 - Conversao do programa para BO b1wgen0010.
                                Efetuado chamada do mesmo pelo programa.
                                (Sidnei - Precise)
                              - Utilizar includes para temp-tables (David).
                              - Incluido novo parametro, referente ao numero de
                                convenio, na procedure gera_retorno_arq_cobranca da
                                BO b1wgen0010 (Elton).

                   22/07/2010 - Incluida chamada da procedure
                                gera_retorno_arq_cobranca_viacredi se cooperativa
                                for viacredi (Elton).

                   20/09/2010 - Incluir CREDCREA na geracao do arq. retorno do
                                CoopCob (Ze).

                   13/10/2010 - Alteracao no parametro gera_retorno_arq_cobranca
                                (Ze).

                   23/06/2014 - Conversão Progres --> Oracle (Odirlei/AMcom)

                   07/03/2016 - Correção do direcionamento das mensagens de log do 
                                programa para proc_message.log conforme SD 405425
                                (Carlos Rafael Tanholi)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS464';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_fimprg EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_nmarqlog   VARCHAR2(300);

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

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------
      vr_des_reto         varchar2(20) := null;
      -- temptable com a linhas do arquivo de cobrança
      vr_tab_arq_cobranca cobr0001.typ_tab_arq_cobranca;
      --temptable de erros
      vr_tab_erro         gene0001.typ_tab_erro;
      --------------------------- SUBROTINAS INTERNAS --------------------------

    BEGIN

      vr_nmarqlog := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');

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
      /*************************************************************
        Chamada da BO que implementa logica que havia no 464 para envio
        de arquivo de retorno de cobranca
      **************************************************************/
      COBR0001.pc_gera_retorno_arq_cobranca
					(pr_cdcooper => pr_cdcooper        -- Codigo da cooperativa
					,pr_crapdat  => rw_crapdat         -- registro com as data do sistema
					,pr_nrdconta => 0                  -- Numero da conta
					,pr_dtpgtini => rw_crapdat.dtmvtolt-- data inicial do pagamento
					,pr_dtpgtfim => rw_crapdat.dtmvtolt-- Data final do pagamento
					,pr_nrcnvcob => 0                  -- Numero do convenio de cobrança
					,pr_cdagenci => 0                  -- Codigo da agencia para erros
					,pr_nrdcaixa => 0                  -- Codigo do caixa para erros
					,pr_origem   => 2 /* 2-CAIXA*/     -- indicador de origem /* 1-AYLLOS/2-CAIXA/3-INTERNET */
					,pr_cdprogra => vr_cdprogra        -- Codigo do programa
					,pr_des_reto => vr_des_reto        -- Descricao do retorno 'OK/NOK'
					,pr_tab_arq_cobranca => vr_tab_arq_cobranca  -- temptable com as linhas do arquivo de cobrança
					,pr_tab_erro => vr_tab_erro);      -- tabela de erros

      -- se retornou algum erro
      IF vr_tab_erro.count > 0 THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- ir para o final e terminar com fimprg
        raise vr_exc_fimprg;
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
                                  ,pr_nmarqlog => vr_nmarqlog
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

  END pc_crps464;
