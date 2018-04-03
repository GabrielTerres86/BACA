CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS474 (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE --> Codigo Agencia
                                       ,pr_nmdatela IN VARCHAR2                   --> Nome Tela
                                       ,pr_idparale in crappar.idparale%TYPE --> Indicador de processoparalelo
                                       ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS474                      Antigo: Fontes/CRPS474.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Gabriel
  Data    : Fevereiro/2012.                    Ultima atualizacao: 21/12/2017

  Dados referentes ao programa:

  Frequencia: Diaria
  Objetivo  : Pagamento de parcelas dos emprestimos.

  Alteracoes: 05/02/2013 - Tratar transacao por parcela (Gabriel).

              25/02/2013 - Mandar numero do contrato para a procedure
                           de validacao de pagamento (Gabriel).

              27/02/2013 - Atribuir valor da referencia dos juros somente
                           quando o mesmo vier com valor positivo (Gabriel).

              17/04/2013 - Ajuste para pagamento parcial em dia (Gabriel).

              22/08/2013 - Incluido a chamada da procedure "atualiza_desconto"
                           "atualiza_emprestimo" para os contratos que
                           nao ocorreram debito (James).

              09/10/2013 - Atribuido valor 0 no campo crapcyb.cdagenci
                           (James)

              01/11/2013 - Ajustes realizados:
                           - Atender ao comunicado 08/2011;
                           - Inclusao do parametro cdpactra na chamada das
                             procedures lanca_juro_contrato,
                             efetiva_pagamento_normal_parcela,
                             efetiva_pagamento_atrasado_parcela;
                           (Adriano).

              14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                           vip no cyber (James).

              27/11/2013 - Enviado cdpactra/cdagenci = 1 nas procedures:
                            - lanca_juro_contrato,
                            - efetiva_pagamento_normal_parcela,
                            - efetiva_pagamento_atrasado_parcela
                           (Adriano).

              11/02/2014 - Remover a criacao do emprestimo no CYBER (James)

              27/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)

              24/07/2014 - Ajuste para verificar se a parcela anterior foi paga. (James)

              14/01/2015 - Implementação lógica para processamento on-line e diário. 229243 (Jean -RKAM)

              23/01/2014 - Tratamento para o contrato em prejuizo. (James)

              07/10/2015 - Verificar parametro de bloqueio na TAB096 referente ao
                           pagto de boletos de emprestimo - Projeto 210 (Rafael)

              25/11/2015 - Ajuste ref ao lancamento de juros remuneratorios referente
                           ao pagto de boletos de emprestimo - Projeto 210 (Rafael)

               02/02/2016 - Incluso novo parametro cdorigem referente Projeto Pgo
                      PP InternetBank. (Daniel)

         03/02/2016 - (Chamado 393718) Inclusao de um log dos saldos antes
                            e apos cada transacao de debito efetivada no
                            contrato (Tiago Castro - RKAM).

              31/03/2016 - Ajustes savepoits SD352945 (Odirlei-AMcom)
			  
              14/04/2016 - Ajuste feito para não ser possível executar o programa caso
                           não for dia útil, apenas quando inprocess = 1, conforme solicitado
                           no chamado 409646. (Kelvin)
              27/04/2016 - Ajuste para bloquear a conta 8415005 para nao debitar
                           o emprestimo. (James)

              27/05/2016 - Ajuste feito na alteracao que foi realizada no dia 14/04/2016, estava
                           abortando o processamento tambem para INPROCES = 2, indevidamente.
                           Executar em paralelo tambem no processo diurno.
                           Chamado 458731 (Heitor - RKAM)
              
              15/06/2016 - Alterado tratamento de erros para geracao de erro no proc_batch
                           caso ocorra problema em algum processo paralelo.
                           Retornado o processo paralelo somente para o periodo da noite.
                           (Heitor - RKAM)

              21/06/2016 - Alterado teste para processamento noturno, estava testando inproces = 2,
                           quando o correto e testar inproces > 2.
                           Heitor (RKAM)
		      
			  05/07/2016 - Melhorias de performance e gerenciamento de memoria. Chamado 479871.
			               Alterado local onde e feito uma das geracoes de log, pois o indice
						   utilizado na geracao poderia estar nulo, ocasionando problemas.
						               Chamado 408357. (Heitor - RKAM)

              26/09/2016 - Incluido verificacao de contratos de acordo, Prj. 302 (Jean Michel).

              30/01/2017 - #551205 Inlusão de loop para todas as cooperativas para tirar a lógica
                           de negócio de dentro do job; inclusão de log de controle de erros e tempo
                           de execuão do programa; melhorias menores de código (Carlos)

              23/02/2016 - Incluída verificação de contas e contratos específicos com
                           bloqueio judicial para não debitar parcelas - AJFink SD#618307
                           
              22/03/2017 - Retorno das alterações referentes ao chamado #551205 (Carlos)
              
              11/04/2017 - Logar início e fim do job apenas com pr_cdagenci = 0 (não paralelo) (Carlos)

              23/06/2017 - #674963 Não logar críticas 995 (Carlos)

              21/12/2017 - Recuperacao do valor de resgate. (Jaison/Marcos Martini - PRJ404)

    ............................................................................. */

  DECLARE

    /*Cursores Locais */

    -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
        FROM crapcop crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    /* Cursor de Emprestimos */
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_nrdconta IN crapepr.nrdconta%TYPE
                         ,pr_nrctremp IN crapepr.nrctremp%TYPE
                         ,pr_inliquid IN crapepr.inliquid%TYPE) IS
      SELECT crapepr.dtdpagto
           , crapepr.rowid
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp
         AND crapepr.inliquid = pr_inliquid
         AND crapepr.inprejuz = 0;
    rw_crapepr cr_crapepr%ROWTYPE;

    --Selecionar Parcelas emprestimo
       CURSOR cr_crappep (pr_cdcooper  IN crappep.cdcooper%TYPE
                         ,pr_dtmvtolt  IN crappep.dtvencto%TYPE
                         ,pr_dtmvtoan  IN crappep.dtvencto%TYPE
                         ,pr_cdagenci IN crapass.cdagenci%TYPE) IS
         SELECT crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crappep.dtvencto
           , crappep.vlsdvpar
           , crappep.nrparepr
           , crappep.inliquid
           , crappep.rowid
           , crawepr.dtlibera
           , crawepr.tpemprst
        FROM crawepr
           , crapass
           , crappep
       WHERE crawepr.cdcooper (+) = crappep.cdcooper
         AND crawepr.nrdconta (+) = crappep.nrdconta
         AND crawepr.nrctremp (+) = crappep.nrctremp
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci)
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crappep.cdcooper = pr_cdcooper
                 AND crappep.dtvencto <= pr_dtmvtolt
         AND crappep.inprejuz = 0
                       AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
       ORDER
          BY crappep.cdcooper
           , crappep.nrdconta
           , crappep.nrctremp
           , crappep.nrparepr;
    rw_crappep cr_crappep%ROWTYPE;

    /* Cursor de Lançamentos de crédito em conta */
        CURSOR cr_craplcmC(pr_cdcooper IN craplcm.cdcooper%TYPE
                          ,pr_nrdconta IN craplcm.nrdconta%TYPE
                          ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE) IS
      SELECT a.vllanmto
            FROM craplcm a
                ,craphis b
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.dtmvtolt = pr_dtmvtolt
         AND a.cdhistor = b.cdhistor
         and b.cdcooper = a.cdcooper
         AND b.indebcre = 'C';
    rw_craplcmC cr_craplcmC%ROWTYPE;

    -- Cursor para verificar se existe algum boleto em aberto
        CURSOR cr_cde (pr_cdcooper IN crapcob.cdcooper%TYPE
                      ,pr_nrdconta IN crapcob.nrdconta%TYPE
                      ,pr_nrctremp IN crapcob.nrctremp%TYPE) IS
      SELECT cob.nrdocmto
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.incobran = 0
                AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                    (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                FROM tbepr_cobranca cde
               WHERE cde.cdcooper = pr_cdcooper
                 AND cde.nrdconta = pr_nrdconta
                 AND cde.nrctremp = pr_nrctremp);
    rw_cde cr_cde%ROWTYPE;

    -- Cursor para verificar se existe algum boleto pago pendente de processamento
        CURSOR cr_ret (pr_cdcooper IN crapcob.cdcooper%TYPE
                      ,pr_nrdconta IN crapcob.nrdconta%TYPE
                      ,pr_nrctremp IN crapcob.nrctremp%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT cob.nrdocmto
        FROM crapcob cob, crapret ret
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.incobran = 5
         AND cob.dtdpagto = pr_dtmvtolt
               AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrctremp, cob.nrdocmto) IN
                   (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrctremp, nrboleto
                FROM tbepr_cobranca cde
               WHERE cde.cdcooper = pr_cdcooper
                 AND cde.nrdconta = pr_nrdconta
                 AND cde.nrctremp = pr_nrctremp)
         AND ret.cdcooper = cob.cdcooper
         AND ret.nrdconta = cob.nrdconta
         AND ret.nrcnvcob = cob.nrcnvcob
         AND ret.nrdocmto = cob.nrdocmto
         AND ret.dtocorre = cob.dtdpagto
         AND ret.cdocorre = 6
         AND ret.flcredit = 0;
    rw_ret cr_ret%ROWTYPE;
    
    CURSOR cr_erro(pr_cdcooper in crapcop.cdcooper%TYPE) IS
      SELECT c.dsvlrprm
        FROM crapprm c
       WHERE c.nmsistem = 'CRED'
         AND c.cdcooper = pr_cdcooper
         AND c.cdacesso = 'PC_CRPS474-ERRO';
    rw_erro cr_erro%ROWTYPE;

    -- Consulta contratos ativos de acordos
   CURSOR cr_ctr_acordo IS
   SELECT tbrecup_acordo_contrato.nracordo
         ,tbrecup_acordo.cdcooper
         ,tbrecup_acordo.nrdconta
         ,tbrecup_acordo_contrato.nrctremp
     FROM tbrecup_acordo_contrato
     JOIN tbrecup_acordo
       ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
    WHERE tbrecup_acordo.cdsituacao = 1
      AND tbrecup_acordo_contrato.cdorigem IN (2,3);

   rw_ctr_acordo cr_ctr_acordo%ROWTYPE;

    --tabela de Memoria dos detalhes de emprestimo
    vr_tab_crawepr EMPR0001.typ_tab_crawepr;

    --Tabela de Memoria de Mensagens Confirmadas
    vr_tab_msg_confirma EMPR0001.typ_tab_msg_confirma;

    --Tabela de Memoria de Erros
    vr_tab_erro GENE0001.typ_tab_erro;

    /* Tabela de Memoria de Pagamentos de Parcela */
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;

    /* Tabela de Memoria de Calculados */
    vr_tab_calculado empr0001.typ_tab_calculado;

    /* Contratos de acordo */
    TYPE typ_tab_acordo   IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
    vr_tab_acordo   typ_tab_acordo;

    --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS474';

    -- Globais
    vr_rowid rowid;
    vr_vlsomato_tmp number;

    --Variaveis Locais
    vr_vlapagar NUMBER;
    vr_vlsomato NUMBER;
    vr_vlresgat NUMBER;
    vr_vljurmes NUMBER;
    vr_dtultdia DATE;
    vr_dtcalcul DATE;
    vr_cdoperad VARCHAR2(1);
    vr_flgpagpa BOOLEAN;
    vr_flgemdia BOOLEAN;
    vr_ehmensal BOOLEAN;
    vr_diarefju INTEGER;
    vr_mesrefju INTEGER;
    vr_anorefju INTEGER;
    vr_flgpripr BOOLEAN;

    vr_cdindice VARCHAR2(30) := ''; -- Indice da tabela de acordos

    --Variaveis de Indices
       vr_index_crawepr VARCHAR2(30);
    vr_index_pgto_parcel PLS_INTEGER;

    --Variaveis para retorno de erro
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);
       vr_des_erro      VARCHAR2(3);

    --Variaveis de Excecao
       vr_exc_final     EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;

    -- ID para o paralelismo
    vr_idparale INTEGER;
    -- Qtde parametrizada de Jobs
    vr_qtdjobs NUMBER;

    -- Parametro de bloqueio de resgate de valores em c/c
    vr_blqresg_cc VARCHAR2(1);

    -- Parametro de contas que nao podem debitar os emprestimos
    vr_dsctajud    crapprm.dsvlrprm%TYPE;
    -- Parametro de contas e contratos específicos que nao podem debitar os emprestimos SD#618307
    vr_dsctactrjud crapprm.dsvlrprm%TYPE := null;

    vr_flgerlog    BOOLEAN := FALSE;

    -- Busca de todas as agencias da cooperativa
    CURSOR cr_crapage(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_dtmvtolt IN crappep.dtvencto%TYPE
                     ,pr_dtmvtoan IN crappep.dtvencto%TYPE) IS
      SELECT crapass.cdagenci
            ,count(crapass.cdagenci)
        FROM crappep
            ,crapass
       WHERE crappep.cdcooper = pr_cdcooper
         AND crapass.cdcooper = crappep.cdcooper
         AND crapass.nrdconta = crappep.nrdconta
         AND crapass.cdagenci =
             decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci)
         AND crappep.dtvencto <= pr_dtmvtolt
         AND ((crappep.inliquid = 0) OR
             (crappep.inliquid = 1 AND crappep.dtvencto > pr_dtmvtoan))
       GROUP BY crapass.cdagenci
       ORDER BY 2 DESC;

    -- Bloco PLSQL para chamar a execução paralela do pc_crps414
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(30);
    --Procedure para limpar os dados das tabelas de memoria
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_crawepr.DELETE;
      vr_tab_calculado.DELETE;
      vr_tab_msg_confirma.DELETE;
      vr_tab_pgto_parcel.DELETE;
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS474.pc_limpa_tabela. '||sqlerrm;
        --Sair do programa
        RAISE vr_exc_saida;
    END pc_limpa_tabela;

    --Verificar Pagamento
       PROCEDURE pc_verifica_pagamento (pr_vlsomato IN NUMBER          --Soma Total
                                       ,pr_inliquid IN INTEGER         --Indicador Liquidacao
                                       ,pr_flgpagpa OUT BOOLEAN        --Indicador Pago
                                       ,pr_des_reto OUT VARCHAR2) IS   -- Indicador Erro OK/NOK
    BEGIN
      BEGIN
        /* Se parcela ja liquidada ou nao tem valor pra pagar, nao permitir pagamento */
           IF nvl(pr_vlsomato,0) <= 0 OR pr_inliquid = 1 THEN
             pr_flgpagpa:= FALSE;
        ELSE
             pr_flgpagpa:= TRUE;
        END IF;
        --Retornar OK
           pr_des_reto:= 'OK';
      EXCEPTION
        WHEN OTHERS THEN
             pr_des_reto:= 'NOK';
      END;
    END pc_verifica_pagamento;

    --Verificar a data do ultimo processamento
    PROCEDURE pc_verifica_processo IS

      -- Cursor de seleção do parametro CRPS474_DATA_PROCESSO
      CURSOR cr_crapprm IS
        SELECT a.dsvlrprm
          FROM crapprm a
         WHERE a.cdcooper = pr_cdcooper
           and a.cdacesso = 'CRPS474_DATA_PROCESSO';

      rw_crapprm cr_crapprm%ROWTYPE;

      -- Variveis locais
      vr_dtutlpro DATE;

    BEGIN
      --Abre cursor buscando o parametro.
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO rw_crapprm;
      CLOSE cr_crapprm;

      --Converte o valor do parametro em data
      vr_dtutlpro := to_date(substr(rw_crapprm.dsvlrprm, 1, 10), 'DD/MM/YYYY');

      --Verifica se ja ocorreu processo hoje
      IF vr_dtutlpro = TRUNC(rw_crapdat.dtmvtolt) THEN
        vr_flgpripr := TRUE;
      ELSE
        vr_flgpripr := FALSE;
      END IF;

    END pc_verifica_processo;

    --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
    PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                    pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
      --> Controlar geração de log de execução dos jobs 
      BTCH0001.pc_log_exec_job( pr_cdcooper  => pr_cdcooper         --> Cooperativa
                               ,pr_cdprogra  => vr_cdprogra         --> Codigo do programa
                               ,pr_nomdojob  => 'JBEPR_PGMTO_PARCS' --> Nome do job
                               ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                               ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                               ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
    END pc_controla_log_batch;


    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS474
    ---------------------------------------
  BEGIN

    --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

    -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

    -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
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
      RAISE vr_exc_saida;
    END IF;
    
    -- Carregar Contratos de Acordos
    FOR rw_ctr_acordo IN cr_ctr_acordo LOOP
      vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                     LPAD(rw_ctr_acordo.nrctremp,10,'0');
      vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;
    END LOOP;


    if pr_cdagenci = 0 then
      begin
        delete crapprm c
         where c.nmsistem = 'CRED'
           and c.cdcooper = pr_cdcooper
           and c.cdacesso = 'PC_CRPS474-ERRO';
        
        commit;
        
      exception
        when others then
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || 'Erro ao tentar deletar registro de erro da CRAPPRM');
          --Sair do programa
          RAISE vr_exc_saida;
      end;
    end if;

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
    -- Se nao encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
         vr_cdcritic:= 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
         vr_cdcritic:= 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    IF pr_cdagenci = 0 THEN
      pc_controla_log_batch('I');
    END IF;

    /* 229243 Paralelismo visando performance
    *  Rodar Somente no processo Noturno */
    IF rw_crapdat.inproces > 2 and
       pr_cdagenci = 0 THEN
      /* Inicial rotinas em paralelo por agencia para agilizar processamento */

      -- Gerar o ID para o paralelismo
      vr_idparale := gene0001.fn_gera_ID_paralelo;
      -- Se houver algum erro, o id vira zerado
      IF vr_idparale = 0 THEN
        -- Levantar exceção
        pr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
        RAISE vr_exc_saida;
      END IF;
      -- Buscar quantidade parametrizada de Jobs
      vr_qtdjobs := NVL(gene0001.fn_param_sistema('CRED'
                                                 ,pr_cdcooper
                                                 ,'QTD_PARALE_CRPS474')
                       ,16);
      -- Para cada agência da cooperativa
      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                  ,pr_idprogra => LPAD(rw_crapage.cdagenci
                                                      ,3
                                                      ,'0') --> Utiliza a agência como id programa
                                  ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE' || chr(13) || --
                      '  wpr_stprogra NUMBER;' || chr(13) || --
                      '  wpr_infimsol NUMBER;' || chr(13) || --
                      '  wpr_cdcritic NUMBER;' || chr(13) || --
                      '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                      'BEGIN' || chr(13) || --
                      '  pc_crps474( ' || --
                      pr_cdcooper || ',' || --
                      rw_crapage.cdagenci || --
                      ', ''JOB'',' || --
                      vr_idparale || ',' || --
                      ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                      chr(13) || --
                      'END;'; --
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := 'JBEPR_PG_PARC_' || rw_crapage.cdagenci || '$';
                       
        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                              ,pr_cdprogra => vr_cdprogra --> Código do programa
                              ,pr_dsplsql  => vr_dsplsql --> Bloco PLSQL a executar
                              ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva  => NULL --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname  => vr_jobname --> Nome randomico criado
                              ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
        -- Chama rotina que irá pausar este processo controlador
        -- caso tenhamos excedido a quantidade de JOBS em execuçao
        gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                    ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                                    ,pr_des_erro => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
      END LOOP;
      -- Chama rotina de aguardo agora passando 0, para esperarmos
      -- até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                  ,pr_qtdproce => 0
                                  ,pr_des_erro => pr_dscritic);
      -- Testar saida com erro
      open cr_erro(pr_cdcooper);
      fetch cr_erro into rw_erro;
      if cr_erro%found then
        close cr_erro;
        vr_cdcritic := 0;
        vr_dscritic := rw_erro.dsvlrprm;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_erro;
      END IF;

      IF pr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
        RAISE vr_exc_saida;
      END IF;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;

      RETURN;
    END IF;
    
    /*No ultimo dia util do ano, nao havera debito de parcelas em atraso no
    processo, mesmo que houver saldo em conta. Nesta data nenhum lancamento
    e feito na conta. Comunicado 08/2011.*/
       IF to_number(to_char(rw_crapdat.dtmvtolt,'MM')) = 12 THEN
      --Buscar Ultimo dia util ano
         vr_dtultdia:= GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                                  ,pr_dtmvtolt  => last_day(rw_crapdat.dtmvtolt)
                                                  ,pr_tipo      => 'A'
                                                  ,pr_excultdia => TRUE);

      --Ultimo dia util do ano igual data processamento
      IF rw_crapdat.dtmvtolt = vr_dtultdia THEN
        --Sair
        RAISE vr_exc_fimprg;
      END IF;
    END IF;

    /* 229243 Verifica na crapprm a ultima data de execução */
    pc_verifica_processo;
    /***************************************/

    --Setar Operador
       vr_cdoperad:= '1';

    --Limpar Tabela
    pc_limpa_tabela;

    IF  TRUNC(SYSDATE) <> rw_crapdat.dtmvtolt
        AND rw_crapdat.inproces = 1 THEN
      --> O JOB esta configurado para rodar de Segunda a Sexta
      -- Mas nao existe a necessidade de rodar nos feriados
      -- Por isso que validamos se o dia de hoje eh o dia do sistema
      RAISE vr_exc_saida;
    END IF;

    -- Parametro de bloqueio de resgate de valores em c/c
    -- ref ao pagto de contrato com boleto (Projeto 210)
    vr_blqresg_cc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                               pr_cdcooper => pr_cdcooper,
                                               pr_cdacesso => 'COBEMP_BLQ_RESG_CC');

    -- Lista de contas que nao podem debitar na conta corrente, devido a acao judicial
    vr_dsctajud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                             pr_cdcooper => pr_cdcooper,
                                             pr_cdacesso => 'CONTAS_ACAO_JUDICIAL');

    -- Lista de contas e contratos específicos que nao podem debitar os emprestimos (formato="(cta,ctr)") SD#618307
    vr_dsctactrjud := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_cdacesso => 'CTA_CTR_ACAO_JUDICIAL');

    /* Todas as parcelas nao liquidadas que estao para serem pagas em dia ou estao em atraso */
       FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                    ,pr_cdagenci => pr_cdagenci) LOOP

         vr_tab_crawepr.DELETE;

      IF rw_crappep.dtlibera IS NOT NULL THEN
           vr_index_crawepr := lpad(rw_crappep.cdcooper,10,'0')||
                               lpad(rw_crappep.nrdconta,10,'0')||
                               lpad(rw_crappep.nrctremp,10,'0');
           vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crappep.dtlibera;
           vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crappep.tpemprst;
      END IF;

      --Selecionar Informacoes Emprestimo
         OPEN cr_crapepr (pr_cdcooper => rw_crappep.cdcooper
                         ,pr_nrdconta => rw_crappep.nrdconta
                         ,pr_nrctremp => rw_crappep.nrctremp
                         ,pr_inliquid => 0);
         FETCH cr_crapepr INTO rw_crapepr;
      
      --Se nao encontrou
      IF cr_crapepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapepr;
        --Proxima Parcela
        CONTINUE;
      END IF;

      --Fechar CURSOR
      CLOSE cr_crapepr;

      /* 229243 Verifica se possui movimento de credito no dia */
      IF rw_crapdat.inproces = 1
         AND vr_flgpripr THEN
        --Selecionar Lançamentos de credito da conta
        OPEN cr_craplcmC(pr_cdcooper => rw_crappep.cdcooper
                        ,pr_nrdconta => rw_crappep.nrdconta
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
        FETCH cr_craplcmC
          INTO rw_craplcmC;
        
        --Se nao encontrou
        IF cr_craplcmC%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_craplcmC;
          --Proxima Parcela
          CONTINUE;
        END IF;
        
        --Fechar CURSOR
        CLOSE cr_craplcmC;
      END IF;
      /***************************************/

      /* Saldo devedor da parcela */
      vr_vlapagar     := rw_crappep.vlsdvpar;
      vr_vlsomato_tmp := nvl(vr_vlsomato,0); -- apenas para log
      
      -- gera log para futuros rastreios
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => 1
                          ,pr_dscritic => null
                          ,pr_dsorigem => 'AYLLOS'
                          ,pr_dstransa => 'Busca saldo do contrato: ' ||
                                          rw_crappep.nrctremp ||
                                          ' Processo: ' ||
                                           rw_crapdat.inproces
                          ,pr_dttransa => trunc(sysdate)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CRPS474'
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrdrowid => vr_rowid);

      --Validar Pagamentos
         EMPR0001.pc_valida_pagamentos_geral (pr_cdcooper => pr_cdcooper                   --> Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci                   --> Codigo Agencia
                                             ,pr_nrdcaixa => 0                             --> Codigo Caixa
                                             ,pr_cdoperad => vr_cdoperad                   --> Operador
                                             ,pr_nmdatela => pr_nmdatela                   --> Nome da Tela
                                             ,pr_idorigem => 7 /*Batch*/                   --> Identificador origem
                                             ,pr_nrdconta => rw_crappep.nrdconta           --> Numero da Conta
                                             ,pr_nrctremp => rw_crappep.nrctremp           --> Numero Contrato
                                             ,pr_idseqttl => 1                             --> Sequencial Titular
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt           --> Data Emprestimo
                                             ,pr_flgerlog => TRUE                          --> Erro no Log
                                             ,pr_dtrefere => rw_crapdat.dtmvtolt           --> Data Referencia
                                             ,pr_vlapagar => vr_vlapagar                   --> Valor Pagar
                                             ,pr_tab_crawepr => vr_tab_crawepr             --> Tabela com Contas e Contratos
                                             ,pr_vlsomato => vr_vlsomato                   --> Soma Total
                                             ,pr_vlresgat => vr_vlresgat                   --> Soma
                                             ,pr_tab_erro => vr_tab_erro                   --> tabela Erros
                                             ,pr_des_reto => vr_des_erro                   --> Indicador OK/NOK
                                             ,pr_tab_msg_confirma => vr_tab_msg_confirma); --> Tabela Confirmacao

      --Se ocorreu erro
      IF vr_des_erro <> 'OK' AND
         vr_tab_erro.count > 0 THEN
          
             vr_cdcritic:= 0;
             vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
          -- Envio centralizado de log de erro
             btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                       ,pr_ind_tipo_log => 2 -- Erro tratato
                                       ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_cdprogra || ' --> '
                                                        || vr_dscritic );
          --Proximo registro
          CONTINUE;
        END IF;

      -- Trava para nao cobrar as parcelas desta conta pelo motivo de uma acao judicial
      IF INSTR(',' || vr_dsctajud || ',',',' || rw_crappep.nrdconta || ',') > 0 THEN
        vr_vlsomato_tmp := 0;
        vr_vlsomato     := 0;
      END IF;

      -- Trava para nao cobrar as parcelas desta conta e contrato específico pelo motivo de uma acao judicial SD#618307
      IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(rw_crappep.nrdconta))||','||trim(to_char(rw_crappep.nrctremp))||')') > 0 THEN
        vr_vlsomato_tmp := 0;
        vr_vlsomato     := 0;
      END IF;

      gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid,
                                pr_nmdcampo => 'Saldo',
                                pr_dsdadant => to_char(nvl(vr_vlsomato_tmp,0),'fm999G999G990D00'),
                                pr_dsdadatu => to_char(vr_vlsomato,'fm999G999G990D00'));

      vr_vlsomato_tmp := vr_vlsomato;
      /* Atribuir se operacao esta em dia ou atraso */
         vr_flgemdia:= rw_crappep.dtvencto > rw_crapdat.dtmvtoan;

         IF vr_flgemdia THEN /* Parcela em dia */
        /* Parcela em dia */
        /* 229243 Definido pela area de negocio que serão pagas apenas
        parcelas vencidas no processo on-line */
        
        IF rw_crapdat.inproces <> 1 THEN
          /*primeiro processamento*/

          --Criar savepoint
          SAVEPOINT sav_trans_474;

          --Atualizar quantidade meses descontados
          BEGIN
             UPDATE crapepr SET crapepr.qtmesdec = nvl(crapepr.qtmesdec,0) + 1
             WHERE crapepr.rowid = rw_crapepr.rowid;
          EXCEPTION
            WHEN OTHERS THEN
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_saida;
          END;

          --Verificar Pagamento
           pc_verifica_pagamento (pr_vlsomato => vr_vlsomato           --> Soma Total
                                 ,pr_inliquid => rw_crappep.inliquid   --> Indicador Liquidacao
                                 ,pr_flgpagpa => vr_flgpagpa           --> Pagamento OK
                                 ,pr_des_reto => vr_des_erro);         --> Indicador Erro OK/NOK
          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            --Proximo Registro
            CONTINUE;
          END IF;

          /* verificar se existe boleto de contrato em aberto e se pode lancar juros remuneratorios no contrato */
          /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
          IF vr_blqresg_cc = 'S' THEN

            -- inicializar rows de cursores
            rw_cde := NULL;
            rw_ret := NULL;

            /* 2º se permitir, verificar se possui boletos em aberto */
              OPEN cr_cde( pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp);
              FETCH cr_cde INTO rw_cde;
            CLOSE cr_cde;

            /* 3º se existir boleto de contrato em aberto, lancar juros */
              IF nvl(rw_cde.nrdocmto,0) > 0 THEN
              IF vr_flgpagpa THEN
                vr_flgpagpa := FALSE;
              END IF;
            ELSE
              /* 4º cursor para verificar se existe boleto pago pendente de processamento */
                OPEN cr_ret( pr_cdcooper => rw_crappep.cdcooper
                            ,pr_nrdconta => rw_crappep.nrdconta
                            ,pr_nrctremp => rw_crappep.nrctremp
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                FETCH cr_ret INTO rw_ret;
              CLOSE cr_ret;

              /* 6º se existir boleto de contrato pago pendente de processamento, lancar juros */
              IF nvl(rw_ret.nrdocmto,0) > 0 
                  AND vr_flgpagpa THEN
                  vr_flgpagpa := FALSE;
                END IF;

            END IF;
              END IF;

          vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_crappep.nrdconta,10,'0') ||
                         LPAD(rw_crappep.nrctremp,10,'0');

          IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
            vr_flgpagpa := FALSE;
          END IF;

          /* Sem valor suficiente para pagar parcela ou parcela ja liquidada */
          IF NOT vr_flgpagpa THEN
            --buscar ultimo dia Util do mes
             vr_dtcalcul:= GENE0005.fn_valida_dia_util (pr_cdcooper => pr_cdcooper
                                                       ,pr_dtmvtolt => last_day(rw_crappep.dtvencto)
                                                       ,pr_tipo => 'A'
                                                       ,pr_excultdia => TRUE);
            --Determinar se eh mensal
             vr_ehmensal:= rw_crappep.dtvencto > vr_dtcalcul;

            /* 229243 Juros não devem ser lançados no processamento on line */
            IF rw_crapdat.inproces <> 1 THEN
              --Lancar Juro Contrato
             EMPR0001.pc_lanca_juro_contrato (pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci           --> Codigo Agencia
                                             ,pr_nrdcaixa => 0                     --> Codigo Caixa
                                             ,pr_nrdconta => rw_crappep.nrdconta   --> Numero da Conta
                                             ,pr_nrctremp => rw_crappep.nrctremp   --> Numero Contrato
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data Emprestimo
                                             ,pr_cdoperad => vr_cdoperad           --> Operador
                                             ,pr_cdpactra => pr_cdagenci           --> Posto Atendimento
                                             ,pr_flnormal => TRUE                  --> Lancamento Normal
                                             ,pr_dtvencto => rw_crappep.dtvencto   --> Data vencimento
                                             ,pr_ehmensal => vr_ehmensal           --> Indicador Mensal
                                             ,pr_dtdpagto => rw_crapepr.dtdpagto   --> Data pagamento
                                             ,pr_tab_crawepr => vr_tab_crawepr     --> Tabela com Contas e Contratos
                                             ,pr_cdorigem => 7 -- 7) Batch
                                             ,pr_vljurmes => vr_vljurmes           --> Valor Juros no Mes
                                             ,pr_diarefju => vr_diarefju           --> Dia Referencia Juros
                                             ,pr_mesrefju => vr_mesrefju           --> Mes Referencia Juros
                                             ,pr_anorefju => vr_anorefju           --> Ano Referencia Juros
                                             ,pr_des_reto => vr_des_erro           --> Retorno OK/NOK
                                             ,pr_tab_erro => vr_tab_erro);         --> tabela Erros

              --Se ocorreu erro
              IF vr_des_erro <> 'OK' AND vr_tab_erro.count > 0 THEN
                
                 vr_cdcritic:= 0;
                 vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                
                  -- Envio centralizado de log de erro
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                           ,pr_ind_tipo_log => 2 -- Erro tratato
                                           ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_dscritic );
                  --Rollback até savepoint
                  ROLLBACK TO SAVEPOINT sav_trans_474;
                  --Proximo registro
                  CONTINUE;
                END IF;

            END IF;

            --Possui Juros
             IF nvl(vr_vljurmes,0) > 0 THEN
              /* Atualiza saldo devedor e juros */
              BEGIN
                 UPDATE crapepr SET crapepr.diarefju = nvl(vr_diarefju,0)
                                   ,crapepr.mesrefju = nvl(vr_mesrefju,0)
                                   ,crapepr.anorefju = nvl(vr_anorefju,0)
                                   ,crapepr.vlsdeved = nvl(crapepr.vlsdeved,0) + nvl(vr_vljurmes,0)
                                   ,crapepr.vljuratu = nvl(crapepr.vljuratu,0) + nvl(vr_vljurmes,0)
                                   ,crapepr.vljuracu = nvl(crapepr.vljuracu,0) + nvl(vr_vljurmes,0)
                 WHERE crapepr.rowid = rw_crapepr.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                   vr_cdcritic:= 0;
                   vr_dscritic:= 'Erro ao atualizar crapepr. '||SQLERRM;
                  --Levantar Excecao
                  RAISE vr_exc_saida;
              END;
            END IF;
            --Proximo Registro
            CONTINUE;
          END IF; --NOT vr_flgpagpa

          /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
           EMPR0001.pc_verifica_parcel_anteriores (pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                                  ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                  ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                  ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                  ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                                  ,pr_dscritic => vr_dscritic);       --> Descricao Erro
          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            --Proximo Registro
            CONTINUE;
          END IF;

          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 1
                              ,pr_dsorigem => 'AYLLOS'
                              ,pr_dscritic => null
                              ,pr_dstransa => 'Efetiva parcela normal, contrato: ' ||
                                              rw_crappep.nrctremp ||
                                              '  Saldo em ' ||
                                              rw_crapdat.dtmvtoan || ': ' ||
                                              to_char(nvl(vr_vlsomato, 0),'fm999G999G990D00') ||
                                              '  A Pagar: ' ||
                                              nvl(vr_vlapagar, 0)
                              ,pr_dttransa => trunc(sysdate)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'CRPS474'
                              ,pr_nrdconta => rw_crappep.nrdconta
                              ,pr_nrdrowid => vr_rowid);

          /* Se saldo disp. maior que sald. devedor, entao pega saldo devedor */
           IF nvl(vr_vlsomato,0) > nvl(vr_vlapagar,0) THEN
            --Soma total recebe valor a pagar
             vr_vlsomato:= vr_vlapagar;
          END IF;

          --Efetivar Pagamento Normal da Parcela
           EMPR0001.pc_efetiva_pagto_parcela (pr_cdcooper => pr_cdcooper          --> Codigo Cooperativa
                                             ,pr_cdagenci => pr_cdagenci          --> Codigo Agencia
                                             ,pr_nrdcaixa => 0                    --> Codigo Caixa
                                             ,pr_cdoperad => vr_cdoperad          --> Operador
                                             ,pr_nmdatela => pr_nmdatela          --> Nome da Tela
                                             ,pr_idorigem => 7 /*Batch*/          --> Identificador origem
                                             ,pr_cdpactra => pr_cdagenci /*cdpactra*/ --> Posto Atendimento
                                             ,pr_nrdconta => rw_crappep.nrdconta  --> Numero da Conta
                                             ,pr_idseqttl => 1 /* Tit. */         --> Sequencial Titular
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data Emprestimo
                                             ,pr_flgerlog => 'S'                  --> Erro no Log
                                             ,pr_nrctremp => rw_crappep.nrctremp  --> Numero Contrato
                                             ,pr_nrparepr => rw_crappep.nrparepr  --> Numero parcela
                                             ,pr_vlparepr => vr_vlsomato          --> Valor da parcela
                                             ,pr_tab_crawepr => vr_tab_crawepr    --> Tabela com Contas e Contratos
                                             ,pr_tab_erro => vr_tab_erro          --> tabela Erros
                                             ,pr_des_reto => vr_des_erro);        --> Indicador OK/NOK

          --Se ocorreu erro
          IF vr_des_erro <> 'OK' THEN
            -- Se tem erro
            IF vr_tab_erro.count > 0 THEN
               vr_cdcritic:= 0;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || vr_dscritic );
              --Desfazer transacao
              ROLLBACK TO SAVEPOINT sav_trans_474;
              --Proximo registro
              CONTINUE;
            END IF;
          END IF;
        END IF;
        
         ELSE /* Parcela vencida */
        /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
        /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
        IF vr_blqresg_cc = 'S' THEN

          -- inicializar rows de cursores
          rw_cde := NULL;
          rw_ret := NULL;

          /* 2º se permitir, verificar se possui boletos em aberto */
              OPEN cr_cde( pr_cdcooper => rw_crappep.cdcooper
                          ,pr_nrdconta => rw_crappep.nrdconta
                          ,pr_nrctremp => rw_crappep.nrctremp);
              FETCH cr_cde INTO rw_cde;
          CLOSE cr_cde;

          /* 3º se existir boleto de contrato em aberto, nao debitar */
              IF nvl(rw_cde.nrdocmto,0) > 0 THEN
            vr_vlsomato := 0;
          ELSE
            /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
                OPEN cr_ret( pr_cdcooper => rw_crappep.cdcooper
                            ,pr_nrdconta => rw_crappep.nrdconta
                            ,pr_nrctremp => rw_crappep.nrctremp
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                FETCH cr_ret INTO rw_ret;
            CLOSE cr_ret;

            /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
                IF nvl(rw_ret.nrdocmto,0) > 0 THEN
              vr_vlsomato := 0;
            END IF;

          END IF;

        END IF;

        vr_cdindice := LPAD(pr_cdcooper,10,'0') || LPAD(rw_crappep.nrdconta,10,'0') ||
                       LPAD(rw_crappep.nrctremp,10,'0');

        IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
          vr_vlsomato := 0;
        END IF;

        IF vr_vlsomato <= 0 THEN
          /* Sem nada para pagar */
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => 1
                              ,pr_dsorigem => 'AYLLOS'
                              ,pr_dscritic => null
                              ,pr_dstransa => 'Nada a pagar, contrato: ' ||
                                              rw_crappep.nrctremp ||
                                              '  Saldo em ' ||
                                              rw_crapdat.dtmvtoan || ': ' ||
                                              to_char(nvl(vr_vlsomato, 0),'fm999G999G990D00') ||
                                              '  A Pagar: ' ||
                                              to_char(nvl(vr_vlapagar, 0),'fm999G999G990D00')
                              ,pr_dttransa => trunc(sysdate)
                              ,pr_flgtrans => 1
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'CRPS474'
                              ,pr_nrdconta => rw_crappep.nrdconta
                              ,pr_nrdrowid => vr_rowid);

          gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid,
                                    pr_nmdcampo => 'Saldo',
                                    pr_dsdadant => to_char(nvl(vr_vlsomato_tmp,0),'fm999G999G990D00'),
                                    pr_dsdadatu => to_char(vr_vlsomato,'fm999G999G990D00'));
          --Proximo registro
          CONTINUE;
        END IF;

        /* Verifica se tem uma parcela anterior nao liquida e ja vencida */
           EMPR0001.pc_verifica_parcel_anteriores (pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                                  ,pr_nrdconta => rw_crappep.nrdconta --> Número da conta
                                                  ,pr_nrctremp => rw_crappep.nrctremp --> Número do contrato de empréstimo
                                                  ,pr_nrparepr => rw_crappep.nrparepr --> Número parcelas empréstimo
                                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Movimento atual
                                                  ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                                  ,pr_dscritic => vr_dscritic);       --> Descricao Erro
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          --Proximo Registro
          CONTINUE;
        END IF;

        --Criar savepoint
        SAVEPOINT sav_trans_474;

        --Buscar pagamentos Parcela
           EMPR0001.pc_busca_pgto_parcelas (pr_cdcooper => pr_cdcooper                --> Cooperativa conectada
                                           ,pr_cdagenci => pr_cdagenci                --> Código da agência
                                           ,pr_nrdcaixa => 0                          --> Número do caixa
                                           ,pr_cdoperad => vr_cdoperad                --> Código do Operador
                                           ,pr_nmdatela => pr_nmdatela                --> Nome da tela
                                           ,pr_idorigem => 7 /*Batch*/                --> Id do módulo de sistema
                                           ,pr_nrdconta => rw_crappep.nrdconta        --> Número da conta
                                           ,pr_idseqttl => 1                          --> Seq titula
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt        --> Movimento atual
                                           ,pr_flgerlog => 'N'                        --> Indicador S/N para geração de log
                                           ,pr_nrctremp => rw_crappep.nrctremp        --> Número do contrato de empréstimo
                                           ,pr_dtmvtoan => rw_crapdat.dtmvtoan        --> Data anterior
                                           ,pr_nrparepr => rw_crappep.nrparepr        --> Número parcelas empréstimo
                                           ,pr_des_reto => vr_des_erro                --> Retorno OK / NOK
                                           ,pr_tab_erro => vr_tab_erro                --> Tabela com possíves erros
                                           ,pr_tab_pgto_parcel => vr_tab_pgto_parcel  --> Tabela com registros de pagamentos
                                           ,pr_tab_calculado   => vr_tab_calculado);  --> Tabela com totais calculados
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN
          -- Se tem erro
          IF vr_tab_erro.count > 0 THEN
               vr_cdcritic:= 0;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            -- Envio centralizado de log de erro
               btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                         ,pr_ind_tipo_log => 2 -- Erro tratato
                                         ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                          || vr_cdprogra || ' --> '
                                                          || vr_dscritic );
            --Desfazer transacao
            ROLLBACK TO SAVEPOINT sav_trans_474;
            --Proximo registro
            CONTINUE;
          END IF;
        END IF;

        --Se retornou dados Buscar primeiro registro
           vr_index_pgto_parcel:= vr_tab_pgto_parcel.FIRST;

        IF vr_index_pgto_parcel IS NOT NULL THEN
          /* Se valor disponivel a pagar eh maior do que tem que pagar , entao liquida parcela */
             IF nvl(vr_vlsomato,0) > nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0) THEN
               vr_vlsomato:= nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0);
          END IF;

        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => 1
                            ,pr_dsorigem => 'AYLLOS'
                            ,pr_dscritic => null
                            ,pr_dstransa => 'Efetiva parcela atraso, contrato: ' ||rw_crappep.nrctremp||
                                            '  Saldo em ' ||rw_crapdat.dtmvtoan || ': ' ||
                                            to_char(nvl(vr_vlsomato, 0),'fm999G999G990D00')||'  A Pagar: ' ||
                                            to_char(nvl(vr_tab_pgto_parcel(vr_index_pgto_parcel).vlatrpag,0),'fm999G999G990D00')
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS474'
                            ,pr_nrdconta => rw_crappep.nrdconta
                            ,pr_nrdrowid => vr_rowid);
        
		gene0001.pc_gera_log_item(pr_nrdrowid => vr_rowid,
                                  pr_nmdcampo => 'Saldo',
                                  pr_dsdadant => to_char(nvl(vr_vlsomato_tmp,0),'fm999G999G990D00'),
                                  pr_dsdadatu => to_char(vr_vlsomato,'fm999G999G990D00'));
        END IF;

        --Efetivar Pagamento da Parcela Atrasada
           EMPR0001.pc_efetiva_pagto_atr_parcel (pr_cdcooper => pr_cdcooper           --> Cooperativa conectada
                                                ,pr_cdagenci => pr_cdagenci           --> Código da agência
                                                ,pr_nrdcaixa => 0                     --> Número do caixa
                                                ,pr_cdoperad => vr_cdoperad           --> Código do Operador
                                                ,pr_nmdatela => pr_nmdatela           --> Nome da tela
                                                ,pr_idorigem => 7 /*Batch*/           --> Id do módulo de sistema
                                                ,pr_cdpactra => pr_cdagenci /*cdpactra*/ --> P.A. da transação
                                                ,pr_nrdconta => rw_crappep.nrdconta   --> Número da conta
                                                ,pr_idseqttl => 1 /* Titular */       --> Seq titula
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Movimento atual
                                                ,pr_flgerlog => 'N'                   --> Indicador S/N para geração de log
                                                ,pr_nrctremp => rw_crappep.nrctremp   --> Número do contrato de empréstimo
                                                ,pr_nrparepr => rw_crappep.nrparepr   --> Número parcelas empréstimo
                                                ,pr_vlpagpar => vr_vlsomato           --> Soma Total
                                                ,pr_tab_crawepr => vr_tab_crawepr     --> Tabela com Contas e Contratos
                                                ,pr_des_reto => vr_des_erro           --> Retorno OK / NOK
                                                ,pr_tab_erro => vr_tab_erro);         --> Tabela com possíves erros

        /* Se deu erro eh porque nao tinha dinheiro minimo suficiente */
        --Se ocorreu erro
        IF vr_des_erro <> 'OK' THEN

		  --Desfazer transacao
          ROLLBACK TO SAVEPOINT sav_trans_474;
          
          IF vr_tab_erro.count > 0 AND
             vr_tab_erro(vr_tab_erro.FIRST).cdcritic <> 995 THEN

            vr_cdcritic := 0;            
            vr_dscritic := 'ERRO coop ' || rw_crappep.cdcooper ||
                           ' nrdconta ' || rw_crappep.nrdconta ||
                           ' nrctremp ' || rw_crappep.nrctremp ||
                           ': '|| vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                           
            -- Gerar log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, 
                                       pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                          ' - '||vr_cdprogra ||' --> '|| vr_dscritic,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
          
          END IF;

          --Proximo registro
          CONTINUE;
        END IF;
      END IF;

      /* 229243 - Commit para processamento on-line */
      IF rw_crapdat.inproces = 1 THEN
        --Salvar informacoes no banco de dados parcela a parcela
        COMMIT;
      END IF;
      /***************************************/
    END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

    /* 229243 - Atualizar Processamento na crapprm */
    --Atualiza ultimo processamento
    BEGIN
      UPDATE crapprm a
         SET a.dsvlrprm = to_char(rw_crapdat.dtmvtolt, 'DD/MM/YYYY')
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdacesso = 'CRPS474_DATA_PROCESSO';
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapprm. ' || SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_saida;
    END;
    --Limpar Tabela
    pc_limpa_tabela;

    IF pr_cdagenci = 0 THEN
      -- Processo OK, devemos chamar a fimprg
         btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => vr_cdprogra
                                   ,pr_infimsol => pr_infimsol
                                   ,pr_stprogra => pr_stprogra);

      --Salvar informacoes no banco de dados
      COMMIT;
    ELSE
      -- Encerrar o job do processamento paralelo dessa agência
         gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                     ,pr_idprogra => pr_cdagenci
                                     ,pr_des_erro => vr_dscritic);
    END IF;

    IF pr_cdagenci = 0 THEN
      pc_controla_log_batch('F');
    END IF;
  
  EXCEPTION
    WHEN vr_exc_fimprg THEN

        -- Buscar a descricao da critica
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      
      -- Se foi gerada critica para envio ao log
      IF vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
      END IF;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      END IF;

      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
         btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                  ,pr_cdprogra => vr_cdprogra
                                  ,pr_infimsol => pr_infimsol
                                  ,pr_stprogra => pr_stprogra);
      --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
      -- Efetuar commit pois gravaremos o que foi processado ate entao
      COMMIT;

    WHEN vr_exc_saida THEN

        -- Buscar a descricao
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

      -- Devolvemos codigo e critica encontradas
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          pc_controla_log_batch('E', vr_dscritic);
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      
      IF pr_cdagenci <> 0 THEN
        BEGIN
          INSERT INTO crapprm(nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dstexprm
                             ,dsvlrprm)
                             VALUES
                             ('CRED'
                             ,pr_cdcooper
                             ,'PC_CRPS474-ERRO'
                             ,'Erro na execução da rotina pc_crps474'
                             ,'Agência: '||pr_cdagenci||' - Erro: '||pr_dscritic);
        EXCEPTION
          WHEN dup_val_on_index then
            NULL;
        END;
      END IF;
    WHEN OTHERS THEN
      cecred.pc_internal_exception;
      -- Efetuar retorno do erro nao tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;

      IF pr_cdagenci = 0 THEN
        pc_controla_log_batch('E', pr_dscritic);
      END IF;

      IF pr_cdagenci <> 0 THEN
        -- Encerrar o job do processamento paralelo dessa agência
        gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                    ,pr_idprogra => pr_cdagenci
                                    ,pr_des_erro => vr_dscritic);
      ELSE
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
      END IF;
      -- Efetuar rollback
      ROLLBACK;
      
      IF pr_cdagenci <> 0 THEN
        BEGIN
          INSERT INTO crapprm(nmsistem
                             ,cdcooper
                             ,cdacesso
                             ,dstexprm
                             ,dsvlrprm)
                             VALUES
                             ('CRED'
                             ,pr_cdcooper
                             ,'PC_CRPS474-ERRO'
                             ,'Erro na execução da rotina pc_crps474'
                             ,'Agência: '||pr_cdagenci||' - Erro: '||pr_dscritic);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX then
            NULL;
        END;
      END IF;
  END;
END PC_CRPS474;
/
