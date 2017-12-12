CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS750_1( pr_faseprocesso IN INTEGER
                                                ,pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                                                ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                                                ,pr_nrctremp IN crapepr.nrctremp%type  --> contrato de emprestimo
                                                ,pr_nrparepr IN crappep.nrparepr%TYPE  --> numero da parcela
                                                ,pr_cdagenci IN crapass.cdagenci%type  --> código da agencia
                                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE  --> Código do operador
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da Critica
BEGIN

  /* .............................................................................

  Programa: PC_CRPS750_1                      
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Everton (Mout´S)
  Data    : Abril/2017.                    Ultima atualizacao:  07/08/2017

  Dados referentes ao programa:

  Frequencia: Diaria
         Programa Chamador: PC_CRPS750 (rotina de priorização das parcelas para pagamento)
  
  Objetivo  : Pagamento de parcelas dos emprestimos TR (Price TR) em substituição ao programa PC_CRPS171.

  Alteracoes: 12/04/2017 - Criação da rotina (Everton / Mout´S)
  
              19/07/2017 - Adequação para pagamento de empréstimos com adiantamento e acertos gerais
              
              07/08/2017 - Correção da execução do relatório 135, que não estava sendo
                           gerado na execução em paralelo.

              07/11/2017 - Ajuste realizado para gravacao do arquivo referente ao relatorio 135 por agencia.
                           Everton (Mouts) - Chamado 773664

    ............................................................................. */

  DECLARE

    -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;    
    
    -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS750_1';
    
    --Variáveis de controle
      vr_dtcursor      DATE;
       
    --Variaveis para retorno de erro
      vr_cdcritic      INTEGER:= 0;
      vr_dscritic      VARCHAR2(4000);

    --Variaveis de Excecao
       vr_exc_erro     EXCEPTION;      

    --Fase processo 1
    --Procedure para gerar os dados das tabelas de parcelas
    PROCEDURE pc_gera_tabela_parcelas(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      -- Busca dos empréstimos
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.cdcooper
              ,epr.cdorigem
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,trunc(add_months(rw_crapdat.dtmvtolt, - (epr.qtmesdec - trunc(epr.qtprecal))),'MM')+ (to_char(epr.dtdpagto,'dd')-1) dtdpagto_nova
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,epr.tpdescto
              ,epr.indpagto
              ,ass.cdagenci  --ews
              ,epr.cdfinemp
              ,epr.vlemprst
          FROM crapepr epr,
               crapass ass
         WHERE epr.cdcooper = ass.cdcooper   --ews
           AND epr.nrdconta = ass.nrdconta
           AND epr.cdcooper = pr_cdcooper          --> Coop conectada
           AND epr.inliquid = 0                    --> Somente não liquidados
           AND epr.indpagto = 0                    --> Nao pago no mês ainda
           AND epr.flgpagto = 0                    --> Débito em conta
           AND epr.tpemprst = 0                    --> Price
           AND epr.dtdpagto <= vr_dtcursor
         ORDER BY epr.nrdconta
                 ,epr.nrctremp;

      -- Busca o cadastro de linhas de crédito
      CURSOR cr_craplcr IS
        SELECT lcr.cdlcremp
              ,lcr.txdiaria
              ,lcr.cdusolcr
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper;

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

      -- Consulta contratos ativos de acordos
       CURSOR cr_ctr_acordo IS
       SELECT tbrecup_acordo_contrato.nracordo
             ,tbrecup_acordo_contrato.nrctremp
             ,tbrecup_acordo.cdcooper
             ,tbrecup_acordo.nrdconta
         FROM tbrecup_acordo_contrato
         JOIN tbrecup_acordo
           ON tbrecup_acordo.nracordo   = tbrecup_acordo_contrato.nracordo
        WHERE tbrecup_acordo.cdsituacao = 1
          AND tbrecup_acordo_contrato.cdorigem IN (2,3);

       rw_ctr_acordo cr_ctr_acordo%ROWTYPE;

      -- Definição de tipo para armazenar informações da linha de crédito
      TYPE typ_reg_craplcr IS
        RECORD(txdiaria craplcr.txdiaria%TYPE
              ,cdusolcr craplcr.cdusolcr%TYPE);
      TYPE typ_tab_craplcr IS
        TABLE OF typ_reg_craplcr
          INDEX BY PLS_INTEGER; -- Cod linha de crédito
      vr_tab_craplcr typ_tab_craplcr;

      TYPE typ_tab_acordo   IS TABLE OF NUMBER(10) INDEX BY VARCHAR2(30);
      vr_tab_acordo   typ_tab_acordo;

      -- Variáveis para passagem a rotina pc_calcula_lelem
      vr_diapagto     INTEGER;
      vr_qtprepag     crapepr.qtprepag%TYPE;
      vr_qtprecal_lem crapepr.qtprecal%TYPE;
      vr_vlprepag     craplem.vllanmto%TYPE;
      vr_vljuracu     crapepr.vljuracu%TYPE;
      vr_vljurmes     crapepr.vljurmes%TYPE;
      vr_dtultpag     crapepr.dtultpag%TYPE;
      vr_txdjuros     crapepr.txjuremp%TYPE;
      vr_qtprecal     crapepr.qtprecal%TYPE;      --> Quantidade de parcelas do empréstimo
      vr_vlsdeved     NUMBER(14,2);               --> Saldo devedor do empréstimo
      vr_dtdpagto     crapepr.dtdpagto%TYPE;

      -- Variáveis auxiliares ao processo
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_tab_vlmindeb NUMBER;                 --> Valor mínimo a debitar por prestações de empréstimo
      vr_nrparcela    tbepr_tr_parcelas.nrparcela%TYPE;
      vr_qtparcela    tbepr_tr_parcelas.qtparcela%TYPE;
      vr_vlparcela    tbepr_tr_parcelas.vlparcela%TYPE;
      vr_dsobservacao tbepr_tr_parcelas.dsobservacao%TYPE;
      vr_flgprocessa  tbepr_tr_parcelas.flgprocessa%TYPE;
      vr_blqresg_cc   VARCHAR2(1);                   --> Parametro de bloqueio de resgate de valores em c/c
      vr_dsctajud     crapprm.dsvlrprm%TYPE;         --> Parametro de contas que nao podem debitar os emprestimos
      vr_dsctactrjud  crapprm.dsvlrprm%TYPE := null; --> Parametro de contas e contratos específicos que nao podem debitar os emprestimos SD#618307
      vr_cdindice     VARCHAR2(30) := '';            --> Indice da tabela de acordos
      vr_mesespago    INTEGER;
      vr_inliquid     crapepr.inliquid%TYPE;

    vr_idprglog   NUMBER;
      
      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
    BEGIN
	   --
       --
       IF pr_cdcooper = 3 then
        -- gera log para futuros rastreios
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => 'CRPS750_1',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => 2,
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Inicio pc_gera_tabela_parcelas.',
                        PR_IDPRGLOG           => vr_idprglog);                           
                           
       END IF;
       -- 
       --
       -- Leitura do indicador de uso da tabela de taxa de juros
       vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'TAXATABELA'
                                                ,pr_tpregist => 0);
       -- Se encontrar
       IF vr_dstextab IS NOT NULL THEN
          -- Se a primeira posição do campo
          -- dstextab for diferente de zero
          IF SUBSTR(vr_dstextab,1,1) != '0' THEN
             -- É porque existe tabela parametrizada
             vr_inusatab := TRUE;
          ELSE
             -- Não existe
             vr_inusatab := FALSE;
          END IF;
       ELSE
          -- Não existe
          vr_inusatab := FALSE;
       END IF;        
       --
       FOR rw_crapepr IN cr_crapepr LOOP
         --
         IF TRUNC(rw_crapepr.dtdpagto_nova,'MM') >= TRUNC(vr_dtcursor,'MM') THEN
           -- Inicializar variaveis para o cálculo
           --vr_flgrejei := FALSE;
           vr_diapagto := 0;
           vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
           vr_vlprepag := 0;
           vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
           vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
           vr_vljurmes := 0;
           vr_dtultpag := rw_crapepr.dtultpag;
           -- Chamar rotina de cálculo externa
           empr0001.pc_leitura_lem(pr_cdcooper    => rw_crapepr.cdcooper
                                  ,pr_cdprogra    => vr_cdprogra
                                  ,pr_rw_crapdat  => rw_crapdat
                                  ,pr_nrdconta    => rw_crapepr.nrdconta
                                  ,pr_nrctremp    => rw_crapepr.nrctremp
                                  ,pr_dtcalcul    => NULL
                                  ,pr_diapagto    => vr_diapagto
                                  ,pr_txdjuros    => vr_txdjuros
                                  ,pr_qtprepag    => vr_qtprepag
                                  ,pr_qtprecal    => vr_qtprecal_lem
                                  ,pr_vlprepag    => vr_vlprepag
                                  ,pr_vljuracu    => vr_vljuracu
                                  ,pr_vljurmes    => vr_vljurmes
                                  ,pr_vlsdeved    => vr_vlsdeved
                                  ,pr_dtultpag    => vr_dtultpag
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_des_erro    => vr_dscritic);
           -- Se a rotina retornou com erro
           IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
             -- Gerar exceção
             RAISE vr_exc_erro;
           END IF;
           -- 
           -- Se a parcela do mês foi paga
           IF vr_qtprecal_lem >= 1 THEN
             --
             IF vr_vlsdeved <= 0 THEN
               vr_inliquid := 1;
               --
               -- Desativar o Rating associado a esta operaçao
               rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                     ,pr_cdagenci   => 0                   --> Código da agência
                                     ,pr_nrdcaixa   => 0                   --> Número do caixa
                                     ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                     ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                     ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                     ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                     ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                     ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros



               /** GRAVAMES **/
                GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                               ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                               ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                               ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                               ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                               ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica

               
             ELSE
               vr_inliquid := 0;
             END IF;
             --
             BEGIN
               UPDATE crapepr
                  SET dtdpagto  = add_months(rw_crapepr.dtdpagto,1)
                     ,dtultpag  = vr_dtultpag
                     ,indpagto  = 1
                     ,inliquid  = vr_inliquid 
                WHERE rowid = rw_crapepr.rowid;
             EXCEPTION
              WHEN OTHERS THEN
                 -- Gerar erro e fazer rollback
                 vr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
                             || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                             || '. Detalhes: '||sqlerrm;
                 RAISE vr_exc_erro;
             END;
             --  
           END IF;     
           --
         END IF;
         --
       END LOOP;
       --
       BEGIN
         DELETE tbepr_tr_parcelas
           WHERE cdcooper = pr_cdcooper;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao deletar tabelas de parcelas. Rotina pc_CRPS750_1.pc_gera_tabela_parcelas. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_erro;
       END;
       --
       IF pr_cdcooper = 3 then
       -- gera log para futuros rastreios
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => 'CRPS750_1',
                        pr_cdcooper           => pr_cdcooper,
                        pr_tpexecucao         => 2,
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => 'Após DELETE tbepr_tr_parcelas.',
                        PR_IDPRGLOG           => vr_idprglog);                           
       --
       END IF;
       --
       -- Carregar Contratos de Acordos
       FOR rw_ctr_acordo IN cr_ctr_acordo LOOP
         vr_cdindice := LPAD(rw_ctr_acordo.cdcooper,10,'0') || LPAD(rw_ctr_acordo.nrdconta,10,'0') ||
                        LPAD(rw_ctr_acordo.nrctremp,10,'0');
         vr_tab_acordo(vr_cdindice) := rw_ctr_acordo.nracordo;
       END LOOP;
       --
       -- Leitura do indicador de uso da tabela de taxa de juros
       vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'USUARI'
                                                ,pr_cdempres => 11
                                                ,pr_cdacesso => 'TAXATABELA'
                                                ,pr_tpregist => 0);
       -- Se encontrar
       IF vr_dstextab IS NOT NULL THEN
         -- Se a primeira posição do campo
         -- dstextab for diferente de zero
         IF SUBSTR(vr_dstextab,1,1) != '0' THEN
           -- É porque existe tabela parametrizada
           vr_inusatab := TRUE;
         ELSE
           -- Não existe
           vr_inusatab := FALSE;
         END IF;
       ELSE
         -- Não existe
         vr_inusatab := FALSE;
       END IF;
       --
       -- Valor minimo para debito dos atrasos das prestacoes
       vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'VLMINDEBTO'
                                                ,pr_tpregist => 0);
       -- Se houver valor
       IF vr_dstextab IS NOT NULL THEN
         -- Converter o valor do parâmetro para number
         vr_tab_vlmindeb := nvl(gene0002.fn_char_para_number(vr_dstextab),0);
       ELSE
         -- Considerar o valor mínimo como zero
         vr_tab_vlmindeb := 0;
       END IF;
       --
       -- Busca do cadastro de linhas de crédito de empréstimo
       FOR rw_craplcr IN cr_craplcr LOOP
         -- Guardamos a taxa e o indicador de emissão de boletos
         vr_tab_craplcr(rw_craplcr.cdlcremp).txdiaria := rw_craplcr.txdiaria;
         vr_tab_craplcr(rw_craplcr.cdlcremp).cdusolcr := rw_craplcr.cdusolcr;
       END LOOP;
       --
       --
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
       --
       FOR rw_crapepr IN cr_crapepr LOOP
         --
         IF pr_cdcooper = 3 then
         -- gera log para futuros rastreios
          pc_log_programa(PR_DSTIPLOG           => 'O',
                          PR_CDPROGRAMA         => 'CRPS750_1',
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,
                          pr_tpocorrencia       => 4,
                          pr_dsmensagem         => 'Início loop cr_crapepr:'||
                                                   ' Conta: '||rw_crapepr.nrdconta||
                                                   ' Contrato:'||rw_crapepr.nrctremp,
                          PR_IDPRGLOG           => vr_idprglog);                            
                           
         END IF;  

         -- acerto de datas
         IF to_char(rw_crapepr.dtdpagto,'dd') <> to_char(rw_crapepr.dtdpagto_nova,'dd') THEN
           rw_crapepr.dtdpagto_nova := rw_crapepr.dtdpagto_nova - 1;
         END IF;
         -- se ainda com diferença
         IF to_char(rw_crapepr.dtdpagto,'dd') <> to_char(rw_crapepr.dtdpagto_nova,'dd') THEN
           rw_crapepr.dtdpagto_nova := rw_crapepr.dtdpagto_nova - 1;
         END IF;
         --
         -- Inicializa variáveis
         vr_dsobservacao := null;
         vr_flgprocessa  := 1;
         -- ******************************************************************************************
         -- **** Bloco de verificação de exceções que impedem o pagamento das parcelas ***************
         -- **** Será utilizado o campo dsobservacao para armazenar os motivos para não pagamento ****
         -- ******************************************************************************************
         -- Trava para nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial
         IF (pr_cdcooper = 1 AND rw_crapepr.nrdconta = 3044831 AND rw_crapepr.nrctremp = 146922) THEN
           vr_dsobservacao := vr_dsobservacao||'Nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial; ';
           vr_flgprocessa  := 0;
         END IF;

         -- Trava para nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial #455213
         IF (pr_cdcooper = 1 AND rw_crapepr.nrdconta = 2496380 AND rw_crapepr.nrctremp = 289361) THEN
           vr_dsobservacao := vr_dsobservacao||'Nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial; ';
           vr_flgprocessa  := 0;
         END IF;

         -- Condicao para verificar se permite incluir as linhas parametrizadas
         IF INSTR(',' || vr_dsctajud || ',',',' || rw_crapepr.nrdconta || ',') > 0 THEN
           vr_dsobservacao := vr_dsobservacao||'Nao cobrar as parcelas desta conta e contrato pelo motivo de uma acao judicial; ';
           vr_flgprocessa  := 0;
         END IF;

         -- Condicao para verificar se permite incluir as linhas parametrizadas SD#618307
         IF INSTR(replace(vr_dsctactrjud,' '),'('||trim(to_char(rw_crapepr.nrdconta))||','||trim(to_char(rw_crapepr.nrctremp))||')') > 0 THEN
           vr_dsobservacao := vr_dsobservacao||'Contas e contratos específicos que nao podem debitar os emprestimos; ';
           vr_flgprocessa  := 0;
         END IF;

         /* verificar se existe boleto de contrato em aberto e se pode debitar do cooperado */
         /* 1º) verificar se o parametro está bloqueado para realizar busca de boleto em aberto */
         IF vr_blqresg_cc = 'S' THEN

            -- inicializar rows de cursores
            rw_cde := NULL;
            rw_ret := NULL;

            /* 2º se permitir, verificar se possui boletos em aberto */
            OPEN cr_cde( pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => rw_crapepr.nrdconta
                        ,pr_nrctremp => rw_crapepr.nrctremp);
            FETCH cr_cde INTO rw_cde;
            CLOSE cr_cde;

            /* 3º se existir boleto de contrato em aberto, nao debitar */
            IF nvl(rw_cde.nrdocmto,0) > 0 THEN
               vr_dsobservacao := vr_dsobservacao||'Boleto de contrato em aberto, nao debitar; ';
               vr_flgprocessa  := 0;
            ELSE
               /* 4º cursor para verificar se existe boleto pago pendente de processamento, nao debitar */
               OPEN cr_ret( pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => rw_crapepr.nrdconta
                           ,pr_nrctremp => rw_crapepr.nrctremp
                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
               FETCH cr_ret INTO rw_ret;
               CLOSE cr_ret;

               /* 6º se existir boleto de contrato pago pendente de processamento, nao debitar */
               IF nvl(rw_ret.nrdocmto,0) > 0 THEN
                  vr_dsobservacao := vr_dsobservacao||'Boleto de contrato pago pendente de processamento, nao debitar; ';
                  vr_flgprocessa  := 0;
               END IF;

            END IF;
            --
         END IF;
         --
         -- Se não houver cadastro da linha de crédito do empréstimo
         IF NOT vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
           -- Gerar critica 363
           vr_cdcritic := 363;
           vr_dscritic := gene0001.fn_busca_critica(363) || ' LCR: ' || to_char(rw_crapepr.cdlcremp,'fm9990');
           RAISE vr_exc_erro;
         END IF;
         --
         -- Nao debitar os emprestimos com emissao de boletos
         IF vr_tab_craplcr(rw_crapepr.cdlcremp).cdusolcr = 2 THEN
           -- Ignorá-lo
           vr_dsobservacao := vr_dsobservacao||'Nao debitar os emprestimos com emissao de boletos; ';
           vr_flgprocessa  := 0;
         END IF;
         --
         vr_cdindice := LPAD(rw_crapepr.cdcooper,10,'0') || LPAD(rw_crapepr.nrdconta,10,'0') ||
                        LPAD(rw_crapepr.nrctremp,10,'0');

         IF vr_tab_acordo.EXISTS(vr_cdindice) THEN
           vr_dsobservacao := vr_dsobservacao||'Nao debitar os emprestimos com Acordo; ';
           vr_flgprocessa  := 0;
         END IF;
         --
         -- Se está setado para utilizarmos a tabela de juros
         IF vr_inusatab THEN
           -- Iremos buscar a tabela de juros na linha de crédito
           vr_txdjuros := vr_tab_craplcr(rw_crapepr.cdlcremp).txdiaria;
         ELSE
           -- Usar taxa cadastrada no empréstimo
           vr_txdjuros := rw_crapepr.txjuremp;
         END IF;
         -- Inicializar variaveis para o cálculo
         --vr_flgrejei := FALSE;
         vr_diapagto := 0;
         vr_qtprepag := NVL(rw_crapepr.qtprepag,0);
         vr_vlprepag := 0;
         vr_vlsdeved := NVL(rw_crapepr.vlsdeved,0);
         vr_vljuracu := NVL(rw_crapepr.vljuracu,0);
         vr_vljurmes := 0;
         vr_dtultpag := rw_crapepr.dtultpag;
         -- Chamar rotina de cálculo externa
         empr0001.pc_leitura_lem(pr_cdcooper    => rw_crapepr.cdcooper
                                ,pr_cdprogra    => vr_cdprogra
                                ,pr_rw_crapdat  => rw_crapdat
                                ,pr_nrdconta    => rw_crapepr.nrdconta
                                ,pr_nrctremp    => rw_crapepr.nrctremp
                                ,pr_dtcalcul    => NULL
                                ,pr_diapagto    => vr_diapagto
                                ,pr_txdjuros    => vr_txdjuros
                                ,pr_qtprepag    => vr_qtprepag
                                ,pr_qtprecal    => vr_qtprecal_lem
                                ,pr_vlprepag    => vr_vlprepag
                                ,pr_vljuracu    => vr_vljuracu
                                ,pr_vljurmes    => vr_vljurmes
                                ,pr_vlsdeved    => vr_vlsdeved
                                ,pr_dtultpag    => vr_dtultpag
                                ,pr_cdcritic    => vr_cdcritic
                                ,pr_des_erro    => vr_dscritic);
         -- Se a rotina retornou com erro
         IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
           -- Gerar exceção
           RAISE vr_exc_erro;
         END IF;
         --
         vr_dsobservacao := vr_dsobservacao||'pago mês:'||vr_qtprecal_lem;
         -- Garantir que o saldo devedor não fique zerado
         IF vr_vlsdeved < 0 THEN
           vr_vlsdeved := 0;
         END IF;

         -- Se o empréstimo estiver ativo
         IF rw_crapepr.inliquid = 0 THEN
           -- Acumular a quantidade calculada com a da tabela
           vr_qtprecal := rw_crapepr.qtprecal + vr_qtprecal_lem;
         ELSE
           -- Utilizar apenas a quantidade de parcelas
           vr_qtprecal := rw_crapepr.qtpreemp;
         END IF;
         --
         vr_mesespago := trunc(vr_qtprecal) - trunc(rw_crapepr.qtprecal);
         --
         IF vr_mesespago > 0 THEN
           -- Nao pode ter mais de 11 meses, senao cancela rotina
           -- Andrino
           IF vr_mesespago > 11 THEN
             -- Adicionar de quantidade anos
             vr_dtdpagto := add_months(rw_crapepr.dtdpagto_nova,vr_mesespago);
           ELSE
             -- Adicionar de quantidade meses pago dentro do mês
             vr_dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagto_nova  --> Data do pagamento anterior
                                                 ,pr_qtmesano => vr_mesespago        --> + mês
                                                 ,pr_tpmesano => 'M'
                                                 ,pr_des_erro => vr_dscritic);
             -- Parar se encontrar erro
             IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
             END IF;
           END IF;
         ELSIF vr_mesespago < 0 then
           vr_dtdpagto := add_months(rw_crapepr.dtdpagto_nova,vr_mesespago);
         ELSE
           vr_dtdpagto  := rw_crapepr.dtdpagto_nova;
         END IF;
         --
         vr_nrparcela := trunc(vr_qtprecal)+1;
         vr_qtparcela := vr_nrparcela - vr_qtprecal;
         vr_vlparcela := vr_qtparcela * rw_crapepr.vlpreemp;
         -- se saldo devedor menor que parcela ou for a última parcela, paga saldo devedor
         IF (vr_vlparcela > vr_vlsdeved) OR (vr_nrparcela > rw_crapepr.qtpreemp) then
           --
           vr_vlparcela := vr_vlsdeved;
           vr_qtparcela := vr_vlparcela / rw_crapepr.vlpreemp;
           --
           -- se for resíduo e a data estiver em mês posterior e não houve pagamento superior ao valor da
           -- parcela no mês deve trazer a data para mês atual, respeitando o dia de vencimento
           IF ((vr_dtdpagto > vr_dtcursor) or (vr_qtprecal > rw_crapepr.qtmesdec)) and vr_vlprepag < rw_crapepr.vlpreemp THEN
              -- respeitará a data de vencimento do empréstimo(dia), para não gerar pagamentos fora do dia correto
              vr_dtdpagto  := trunc(vr_dtcursor,'MM') + to_char(vr_dtdpagto,'dd') - 1 ;
              --
              -- se a data pagamento gerada for para próximo mês, deve definir data como último dia do mês corrente
              IF  trunc(vr_dtdpagto,'MM') <> trunc(vr_dtcursor,'MM') THEN
                --
                vr_dtdpagto := trunc(vr_dtdpagto,'MM') - 1;
                --
              END IF;
              --
           END IF;           
           --
         ELSE
           -- Andrino/Everton
           -- Se tiver parcelas adiantadas, deve-se gerar tambem o pagamento dentro do mes
           -- valor adiantado deve ser menor que o valor da parcela, pagondo a diferença até 
           -- completar o valor da parcela para o mês em questão.
           IF ((vr_dtdpagto > vr_dtcursor) or (vr_qtprecal > rw_crapepr.qtmesdec)) and vr_vlprepag < rw_crapepr.vlpreemp THEN
              -- respeitará a data de vencimento do empréstimo(dia), para não gerar pagamentos fora do dia correto
              vr_dtdpagto  := trunc(vr_dtcursor,'MM') + to_char(vr_dtdpagto,'dd') - 1 ;
              --
              -- se a data pagamento gerada for para próximo mês, deve definir data como último dia do mês corrente
              IF  trunc(vr_dtdpagto,'MM') <> trunc(vr_dtcursor,'MM') THEN
                --
                vr_dtdpagto := trunc(vr_dtdpagto,'MM') - 1;
                --
              END IF;
              --
              vr_qtparcela := round(vr_vlprepag / rw_crapepr.vlpreemp,4);
              vr_vlparcela := rw_crapepr.vlpreemp - vr_vlprepag;
           END IF;
		 --
         --
		 END IF;

         IF pr_cdcooper = 3 then
         -- gera log para futuros rastreios
          pc_log_programa(PR_DSTIPLOG           => 'O',
                          PR_CDPROGRAMA         => 'CRPS750_1',
                          pr_cdcooper           => pr_cdcooper,
                          pr_tpexecucao         => 2,
                          pr_tpocorrencia       => 4,
                          pr_dsmensagem         => 'Antes insert tbepr_tr_parcelas:'||
                                                   ' Conta: '||rw_crapepr.nrdconta||
                                                   ' Contrato:'||rw_crapepr.nrctremp||
                                                   ' Data pgto:'||to_char(vr_dtdpagto,'dd/mm/yyyy')||
                                                   ' Saldo Dev:'||to_char(vr_vlsdeved),
                          PR_IDPRGLOG           => vr_idprglog);
                           
         END IF;  
         --
         -- Enquanto data de vencimento da parcela for menor que data processamento E houver saldo devedor do emprestimo
         WHILE (vr_dtdpagto <= vr_dtcursor) and (vr_vlsdeved > 0) LOOP
           --
           BEGIN
             INSERT INTO tbepr_tr_parcelas
               ( cdcooper,
                 cdagenci,
                 nrdconta,
                 nrctremp,
                 dtdpagto,
                 nrparcela,
                 vlparcela,
                 qtparcela,
                 dtmvtolt,
                 vlpago,
                 dtcalculo,
                 flgacordo,
                 dsobservacao,
                 vltaxa_juros,
                 vlsaldo_devedor,
                 vlmin_parcela,
                 flgprocessa
               )
               VALUES
               ( rw_crapepr.cdcooper,
                 rw_crapepr.cdagenci,
                 rw_crapepr.nrdconta,
                 rw_crapepr.nrctremp,
                 vr_dtdpagto,
                 vr_nrparcela,
                 vr_vlparcela,
                 vr_qtparcela,
                 rw_crapdat.dtmvtolt,
                 NULL,
                 SYSDATE,
                 0,
                 vr_dsobservacao,
                 vr_txdjuros,
                 vr_vlsdeved,
                 vr_tab_vlmindeb,
                 vr_flgprocessa
               );
           EXCEPTION
             WHEN OTHERS THEN
               --Variavel de erro recebe erro ocorrido
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir tabelas de parcelas. Rotina pc_CRPS750_1.pc_gera_tabela_parcelas. '||sqlerrm;
               --Sair do programa
               RAISE vr_exc_erro;
           END;
           --
           -- Adicionar de 1 em 1 mês até a data alcançar a data atual
           vr_dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => vr_dtdpagto         --> Data do pagamento anterior
                                               ,pr_qtmesano => 1                   --> +1 mês
                                               ,pr_tpmesano => 'M'
                                               ,pr_des_erro => vr_dscritic);
           -- Parar se encontrar erro
           IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
           END IF;
           --
           vr_vlsdeved  := vr_vlsdeved - vr_vlparcela;
           vr_nrparcela := vr_nrparcela + 1;
           vr_qtparcela := 1;
           vr_vlparcela := vr_qtparcela * rw_crapepr.vlpreemp;
           --
           -- se saldo devedor menor que parcela ou for a última parcela, paga somente saldo devedor
           IF (vr_vlparcela > vr_vlsdeved) OR (vr_nrparcela > rw_crapepr.qtpreemp) then
             --
             vr_vlparcela := vr_vlsdeved;
             vr_qtparcela := vr_vlparcela / rw_crapepr.vlpreemp;
             --vr_nrparcela := rw_crapepr.qtpreemp;
            -- vr_vlsdeved  := 0;
             --
           END IF;
           --
         END LOOP;
         --
       END LOOP;
       --
    EXCEPTION
      WHEN vr_exc_erro THEN
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao criar tabelas de parcelas. Rotina pc_CRPS750_1.pc_gera_tabela_parcelas. '||sqlerrm;
        --Sair do programa
        RAISE vr_exc_erro;
    END pc_gera_tabela_parcelas;
    --
    -- 
    --
    --Fase processo 2
    --Procedure para gerar o pagamento das parcelas de empréstimos TR
    PROCEDURE pc_gera_pagamento(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                               ,pr_nrdconta IN crapepr.nrdconta%TYPE  --> Número da conta
                               ,pr_nrctremp IN crapepr.nrctremp%type  --> contrato de emprestimo
                               ,pr_nrparepr IN crappep.nrparepr%TYPE ) IS  --> numero da parcela

      -- Variaveis para gravação da craplot
      vr_cdagenci INTEGER := pr_cdagenci;
      vr_cdbccxlt CONSTANT PLS_INTEGER := 100;
      
      ------------------------------- CURSORES ---------------------------------

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.cdsecext
              ,ass.nrramemp
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;

      -- Busca das informações de saldo cfme a conta
      CURSOR cr_crapsld IS
        SELECT sld.nrdconta
              ,sld.vlsdblfp
              ,sld.vlsdbloq
              ,sld.vlsdblpr
              ,sld.vlsddisp
              ,sld.vlipmfap
              ,sld.vlipmfpg
              ,sld.vlsdchsl
          FROM crapsld sld
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;

      -- Busca das informações de históricos de lançamento
      CURSOR cr_craphis IS
        SELECT his.cdhistor
              ,his.inhistor
              ,his.indoipmf
          FROM craphis his
         WHERE cdcooper = pr_cdcooper;

      -- Busca dos empréstimos
      CURSOR cr_crapepr IS
        SELECT epr.rowid
              ,epr.cdcooper
              ,epr.cdorigem 
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.inliquid
              ,epr.qtpreemp
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.dtmvtolt
              ,epr.inprejuz
              ,epr.txjuremp
              ,epr.vljuracu
              ,epr.dtdpagto
              ,epr.flgpagto
              ,epr.qtmesdec
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.qtprepag
              ,epr.dtultpag
              ,epr.tpdescto
              ,epr.indpagto
              ,prc.cdagenci --ews
              ,epr.cdfinemp
              ,epr.vlemprst
              ,prc.dtdpagto dtdpagtoprc
              ,prc.vlparcela
              ,prc.vltaxa_juros
              ,prc.vlsaldo_devedor
              ,prc.rowid rowidprc
          FROM crapepr epr,
               tbepr_tr_parcelas prc
         WHERE epr.cdcooper = prc.cdcooper
         --  AND epr.cdagenci = prc.cdagenci  --ews
           AND epr.nrdconta = prc.nrdconta
           AND epr.nrctremp = prc.nrctremp
           AND epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp
           AND prc.nrparcela = pr_nrparepr;

      -- Busca dos lançamentos de deposito a vista
      CURSOR cr_craplcm IS
        SELECT lcm.nrdconta
              ,lcm.dtrefere
              ,lcm.vllanmto
              ,lcm.dtmvtolt
              ,lcm.cdhistor
              ,ROW_NUMBER () OVER (PARTITION BY lcm.nrdconta, lcm.cdhistor
                                       ORDER BY lcm.nrdconta, lcm.cdhistor) sqatureg
          FROM craplcm lcm
         WHERE lcm.cdcooper = pr_cdcooper
           AND lcm.nrdconta = pr_nrdconta
           AND lcm.cdhistor <> 289
           AND lcm.dtmvtolt = rw_crapdat.dtmvtolt
         ORDER BY lcm.cdhistor;

      -- Buscar as capas de lote para a cooperativa e data atual
      CURSOR cr_craplot(pr_nrdolote IN craplot.nrdolote%TYPE
                       ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
        SELECT lot.cdagenci
              ,lot.cdbccxlt
              ,lot.nrdolote
              ,lot.tplotmov
              ,lot.nrseqdig
              ,lot.vlinfodb
              ,lot.vlcompdb
              ,lot.qtinfoln
              ,lot.qtcompln
              ,lot.vlinfocr
              ,lot.vlcompcr
              ,lot.dtmvtolt
              ,rowid
          FROM craplot lot
         WHERE lot.cdcooper = pr_cdcooper
           AND lot.dtmvtolt = pr_dtmvtolt
           AND lot.cdagenci = vr_cdagenci
           AND lot.cdbccxlt = vr_cdbccxlt
           AND lot.nrdolote = pr_nrdolote;
      -- Criaremos um registro para cada tipo de lote utilizado
      rw_craplot_8457 cr_craplot%ROWTYPE; --> Lancamento de prestação de empréstimo
      rw_craplot_8453 cr_craplot%ROWTYPE; --> Lancamento de pagamento de empréstimo na CC
      
      -- Verificar se já existe outro lançamento para o lote atual
      CURSOR cr_craplem_nrdocmto(pr_dtmvtolt crapdat.dtmvtolt%TYPE
                                ,pr_nrdolote craplot.nrdolote%TYPE
                                ,pr_nrdconta crapepr.nrdconta%TYPE
                                ,pr_nrdocmto craplem.nrdocmto%TYPE) IS
        SELECT count(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = vr_cdagenci
           AND cdbccxlt = vr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto;
      vr_qtd_lem_nrdocmto NUMBER;    
      
      ------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição dos lançamentos de deposito a vista
      TYPE typ_reg_craplcm_det IS
        RECORD(dtrefere craplcm.dtrefere%TYPE,
               vllanmto craplcm.vllanmto%TYPE,
               dtmvtolt craplcm.dtmvtolt%TYPE,
               cdhistor craplcm.cdhistor%TYPE,
               sqatureg NUMBER(05));
      TYPE typ_tab_craplcm_det IS
        TABLE OF typ_reg_craplcm_det
          INDEX BY PLS_INTEGER; -- Cod historico || sequencia registro

      TYPE typ_reg_craplcm IS
        RECORD(tab_craplcm typ_tab_craplcm_det);
      TYPE typ_tab_craplcm IS
        TABLE OF typ_reg_craplcm
          INDEX BY PLS_INTEGER; -- Numero da conta
      vr_tab_craplcm typ_tab_craplcm;

      -- Definição de tipo para armazenar informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(vllimcre crapass.vllimcre%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,nrramemp crapass.nrramemp%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      -- Definição de tipo para armazenar informações dos saldos associados
      TYPE typ_reg_crapsld IS
        RECORD(vlsdblfp crapsld.vlsdblfp%TYPE
              ,vlsdbloq crapsld.vlsdbloq%TYPE
              ,vlsdblpr crapsld.vlsdblpr%TYPE
              ,vlsddisp crapsld.vlsddisp%TYPE
              ,vlsdchsl crapsld.vlsdchsl%TYPE
              ,vlipmfap crapsld.vlipmfap%TYPE
              ,vlipmfpg crapsld.vlipmfpg%TYPE);
      TYPE typ_tab_crapsld IS
        TABLE OF typ_reg_crapsld
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapsld typ_tab_crapsld;

      -- Definição de tipo para armazenar as informações de histórico
      TYPE typ_reg_craphis IS
        RECORD(inhistor craphis.inhistor%TYPE
              ,indoipmf craphis.indoipmf%TYPE);
      TYPE typ_tab_craphis IS
        TABLE OF typ_reg_craphis
          INDEX BY PLS_INTEGER; --> Código do histórico
      vr_tab_craphis typ_tab_craphis; 
      
      ---------------------- VARIÁVEIS -------------------------
      -- Variáveis de CPMF
      vr_dtinipmf DATE;
      vr_dtfimpmf DATE;
      vr_txcpmfcc NUMBER(12,6);
      vr_txrdcpmf NUMBER(12,6);
      vr_indabono INTEGER;
      vr_dtiniabo DATE;  
      
      -- Variáveis auxiliares no processo
      vr_vldescto     NUMBER(18,6);           --> Valor de desconto das parcelas
      vr_vlsldtot     NUMBER;                 --> Valor de saldo total
      vr_vlcalcob     NUMBER;                 --> Valor calculado de cobrança
      vr_vlpremes     NUMBER;                 --> Valor da prestação do mês  
      vr_ind_lcm      NUMBER(10);             --> Indice da tabela craplcm 
      vr_flgrejei     BOOLEAN;                --> Flag para indicação de empréstimo rejeitado 
      vr_nrdocmto     craplem.nrdocmto%TYPE;  --> Número do documento para a LEM
      vr_cdhismul     INTEGER;
      vr_vldmulta     NUMBER;
      vr_cdhismor     INTEGER;
      vr_vljumora     NUMBER;
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros
      vr_flgprc       INTEGER;
      vr_cdagencia    tbepr_tr_parcelas.cdagenci%TYPE;
      vr_seqdig       NUMBER(10);
      
      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- Variaveis para o CPMF cfme cada histório na craplcm
      vr_inhistor PLS_INTEGER;
      vr_indoipmf PLS_INTEGER;
      vr_txdoipmf NUMBER;        
      
      ----------------- SUBROTINAS INTERNAS --------------------

      -- Subrotina para checar a existência de lote cfme tipo passado
      PROCEDURE pc_cria_craplot(pr_dtmvtolt   IN craplot.dtmvtolt%TYPE
                               ,pr_nrdolote   IN craplot.nrdolote%TYPE
                               ,pr_tplotmov   IN craplot.tplotmov%TYPE
                               ,pr_rw_craplot IN OUT NOCOPY cr_craplot%ROWTYPE
                               ,pr_dscritic  OUT VARCHAR2) IS
      BEGIN
        -- Buscar as capas de lote cfme lote passado
        OPEN cr_craplot(pr_nrdolote => pr_nrdolote
                       ,pr_dtmvtolt => pr_dtmvtolt);
        FETCH cr_craplot
         INTO pr_rw_craplot; --> Rowtype passado
        -- Se não tiver encontrado
        IF cr_craplot%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_craplot;
          -- Efetuar a inserção de um novo registro
          BEGIN
            INSERT INTO craplot(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdolote
                               ,tplotmov
                               ,nrseqdig
                               ,vlinfodb
                               ,vlcompdb
                               ,qtinfoln
                               ,qtcompln
                               ,vlinfocr
                               ,vlcompcr
                               ,cdhistor
                               ,tpdmoeda
                               ,cdoperad)
                         VALUES(pr_cdcooper
                               ,pr_dtmvtolt
                               ,vr_cdagenci
                               ,vr_cdbccxlt
                               ,pr_nrdolote --> Cfme enviado
                               ,pr_tplotmov --> Cfme enviado
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,0
                               ,1
                               ,'1')
                       RETURNING dtmvtolt
                                ,cdagenci
                                ,cdbccxlt
                                ,nrdolote
                                ,tplotmov
                                ,nrseqdig
                                ,rowid
                            INTO pr_rw_craplot.dtmvtolt
                                ,pr_rw_craplot.cdagenci
                                ,pr_rw_craplot.cdbccxlt
                                ,pr_rw_craplot.nrdolote
                                ,pr_rw_craplot.tplotmov
                                ,pr_rw_craplot.nrseqdig
                                ,pr_rw_craplot.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              pr_dscritic := 'Erro ao inserir capas de lotes (craplot), lote: '||pr_nrdolote||'. Detalhes: '||sqlerrm;
          END;
        ELSE
          -- apenas fechar o cursor
          CLOSE cr_craplot;
        END IF;
      END;            
 
    BEGIN
      -- verificar se existem parcelas com vencimento anterior já rejeitadas (não pagas)
      BEGIN
        SELECT 1
          INTO vr_flgprc
          FROM tbepr_tr_parcelas prc
         WHERE prc.cdcooper = pr_cdcooper
           and prc.nrdconta = pr_nrdconta
           and prc.nrctremp = pr_nrctremp
           and prc.nrparcela < pr_nrparepr
           and prc.vlpago = 0 
           and rownum = 1;
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN
          vr_flgprc := 0;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao selecionar parcelas (TBEPR_TR_PARCELAS) '
                      || '- Conta:'||pr_nrdconta || ' CtrEmp:'||pr_nrctremp
                      || '. Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;  
      END; 
      --
      -- se parcelas com vencimento anterior já rejeitadas, não precisa carregar tabelas
      -- de saldo, lançamentos do dia, associados, cpmf
      IF vr_flgprc = 1 THEN
        vr_flgrejei := TRUE;
        --
        --
      ELSE
        --
        -- Procedimento padrão de busca de informações de CPMF
        gene0005.pc_busca_cpmf(pr_cdcooper  => pr_cdcooper
                              ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                              ,pr_dtinipmf  => vr_dtinipmf
                              ,pr_dtfimpmf  => vr_dtfimpmf
                              ,pr_txcpmfcc  => vr_txcpmfcc
                              ,pr_txrdcpmf  => vr_txrdcpmf
                              ,pr_indabono  => vr_indabono
                              ,pr_dtiniabo  => vr_dtiniabo
                              ,pr_cdcritic  => vr_cdcritic
                              ,pr_dscritic  => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
          -- Gerar raise
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
        -- 
        -- Busca dos associados da cooperativa
        FOR rw_crapass IN cr_crapass LOOP
          -- Adicionar ao vetor as informações chaveando pela conta
          vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
          vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
          vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
          vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
          vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
          vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
          vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
        END LOOP;

        -- Busca dos lancamentos de deposito a vista
        FOR rw_craplcm IN cr_craplcm LOOP
          -- Adicionar ao vetor as informações chaveando pela conta
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtrefere := rw_craplcm.dtrefere;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).vllanmto := rw_craplcm.vllanmto;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).dtmvtolt := rw_craplcm.dtmvtolt;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).cdhistor := rw_craplcm.cdhistor;
          vr_tab_craplcm(rw_craplcm.nrdconta).tab_craplcm(cr_craplcm%ROWCOUNT).sqatureg := rw_craplcm.sqatureg;
        END LOOP;

        -- Busca das informações de saldo cfme a conta
        FOR rw_crapsld IN cr_crapsld LOOP
          -- Adicionar ao vetor as informações de saldo novamente chaveando pela conta
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblfp := rw_crapsld.vlsdblfp;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdbloq := rw_crapsld.vlsdbloq;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdblpr := rw_crapsld.vlsdblpr;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsddisp := rw_crapsld.vlsddisp;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfap := rw_crapsld.vlipmfap;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlipmfpg := rw_crapsld.vlipmfpg;
          vr_tab_crapsld(rw_crapsld.nrdconta).vlsdchsl := rw_crapsld.vlsdchsl;
        END LOOP;

        -- Busca do cadastro de histórico
        FOR rw_craphis IN cr_craphis LOOP
          -- Adicionar ao vetor utilizando o histórico como chave
          vr_tab_craphis(rw_craphis.cdhistor).inhistor := rw_craphis.inhistor;
          vr_tab_craphis(rw_craphis.cdhistor).indoipmf := rw_craphis.indoipmf;
        END LOOP;
        --
      END IF;
      --
      -- Busca do Empréstimo  
      FOR rw_crapepr IN cr_crapepr LOOP
        --
        -- se parcelas com vencimento anterior já rejeitadas, nem entra no cálculo
        IF vr_flgprc = 1 then
          vr_vldescto := 0;
        ELSE
          vr_vldescto := rw_crapepr.vlparcela;
          --
          -- Verificar se a conta não possui saldo
          IF NOT vr_tab_crapsld.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 10
            vr_cdcritic := 10;
            vr_dscritic := gene0001.fn_busca_critica(10) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_erro;
          END IF;

          -- Verificar se a conta não está na crapass
          IF NOT vr_tab_crapass.EXISTS(rw_crapepr.nrdconta) THEN
            -- Gerar critica 251
            vr_cdcritic := 251;
            vr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_crapepr.nrdconta);
            RAISE vr_exc_erro;
          END IF;

          -- Calcular o saldo total --
          vr_vlsldtot := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapass(rw_crapepr.nrdconta).vllimcre,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Calcular o saldo a cobrar --
          vr_vlcalcob := NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsddisp,0)
                       + NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlsdchsl,0) - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfap,0)
                       - NVL(vr_tab_crapsld(rw_crapepr.nrdconta).vlipmfpg,0);

          -- Se o valor a cobrar ficar negativo
          IF vr_vlcalcob < 0 THEN
            -- Descontar do total o valor absoluto a cobrar aplicando o * de CPMF
            vr_vlsldtot := vr_vlsldtot - (TRUNC((ABS(vr_vlcalcob)  * vr_txcpmfcc),2));
          END IF;

          -- Busca dos lançamentos de deposito a vista
          IF vr_tab_craplcm.EXISTS(rw_crapepr.nrdconta) THEN
            vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.first;
            WHILE vr_ind_lcm IS NOT NULL LOOP
              -- No primeiro registro do histórico atual
              IF vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).sqatureg = 1 THEN
                -- Verificar se o histórico está cadastrado
                IF NOT vr_tab_craphis.EXISTS(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor) THEN
                  -- Gerar critica 83 no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || to_char(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor,'fm9900') || ' ' ||gene0001.fn_busca_critica(83) );
                  -- Limpar as variaveis de controle do cpmf
                  vr_inhistor := 0;
                  vr_indoipmf := 0;
                  vr_txdoipmf := 0;
                ELSE
                  -- Utilizaremos do cadastro do histórico
                  vr_inhistor := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor;
                  vr_indoipmf := vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).indoipmf;
                  vr_txdoipmf := vr_txcpmfcc;
                  -- Se houver abono e o histórico for um dos abaixo:
                  -- CDHISTOR DSHISTOR
                  -- -------- --------------------------------------------------
                  -- 114 DB.APLIC.RDCA
                  -- 127 DB. COTAS
                  -- 160 DB.POUP.PROGR
                  -- 177 DB.APL.RDCA60
                  IF vr_indabono = 0 AND vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                    -- Indicar que não há CPMF
                    vr_indoipmf := 1;
                    vr_txdoipmf := 0;
                  END IF;
                END IF;
              END IF;

              -- Se houver abono e a data for inferior a data lançada e o histório estiver na lista abaixo:
              -- CDHISTOR DSHISTOR
              -- -------- --------------------------------------------------
              -- 186 CR.ANTEC.RDCA
              -- 187 CR.ANT.RDCA60
              -- 498 CR.ANTEC.RDCA
              -- 500 CR.ANT.RDCA60
              IF vr_indabono = 0 AND vr_dtiniabo <= vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtrefere AND
                 vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor IN(0114,0127,0160,0177) THEN
                -- Descontar do saldo total este lançamento aplicando a taxa de CPMF cadastrada
                vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * vr_txcpmfcc),2));
              END IF;

              -- Se tivermos um lançamento de crédito da data atual --
              IF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN (1) AND rw_crapdat.dtmvtolt = vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).dtmvtolt THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Acumular ao saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot + (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas acumular o lançamento
                  vr_vlsldtot := vr_vlsldtot + vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              -- Senão, se tivermos um lançamento de débito --
              ELSIF vr_tab_craphis(vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).cdhistor).inhistor IN(11,13,14,15) THEN
                -- Tratamento de CPMF --
                IF vr_indoipmf = 2 THEN
                  -- Diminuir do saldo o valor do lançamento aplicando a taxa de CPMF +1 do teste de histórico acima
                  vr_vlsldtot := vr_vlsldtot - (TRUNC((vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto * (1+vr_txdoipmf)),2));
                ELSE
                  -- Apenas diminuir o lançamento
                  vr_vlsldtot := vr_vlsldtot - vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm(vr_ind_lcm).vllanmto;
                END IF;
              END IF;

              vr_ind_lcm := vr_tab_craplcm(rw_crapepr.nrdconta).tab_craplcm.next(vr_ind_lcm);
            END LOOP; -- Fim leitura craplcm
          END IF;
        
          -- Armazenar o valor original de desconto
          vr_vlpremes := vr_vldescto;

          -- Se o valor de desconto aplicando a CPMF for maior que o saldo total
          IF TRUNC((vr_vldescto * (1 + vr_txcpmfcc)),2) > vr_vlsldtot THEN
            -- Se houver saldo total
            IF vr_vlsldtot > 0 THEN
              -- Aplicar a taxa de CPMF
              vr_vldescto := TRUNC(vr_vlsldtot * vr_txrdcpmf,2);
            ELSE
              -- Utilizaremos zero
              vr_vldescto := 0;
            END IF;
            -- Se o valor original do desconto for superior ao desconto acima ajustado
            IF vr_vlpremes > vr_vldescto THEN
              -- Indicar que há rejeição
              vr_flgrejei := TRUE;
            END IF;
          END IF;
          -- 
        END IF;       
        --
        --
        -- Se houver desconto E (tipo de empréstimo não for consignado Ou se for pagamento deve ser > dia 10)
        IF vr_vldescto > 0 AND (rw_crapepr.tpdescto = 1 OR to_char(rw_crapdat.dtmvtolt,'dd') > 10) THEN
            -- Testar se já retornado o registro de capas de lote para o 8457
            IF rw_craplot_8457.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criá-lo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8457
                             ,pr_tplotmov   => 1
                             ,pr_rw_craplot => rw_craplot_8457
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_erro;
              END IF;
            END IF;

            -- Efetuar lancamento na conta-corrente
            BEGIN
              INSERT INTO craplcm(cdcooper--
                                 ,dtmvtolt--
                                 ,cdagenci--
                                 ,cdbccxlt--
                                 ,nrdolote--
                                 ,cdpesqbb
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig--
                                 ,vllanmto
                                 ,nrparepr)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8457.dtmvtolt
                                 ,rw_craplot_8457.cdagenci
                                 ,rw_craplot_8457.cdbccxlt
                                 ,rw_craplot_8457.nrdolote
                                 ,gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9')  
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrdconta
                                 ,to_char(rw_crapepr.nrdconta,'fm00000000')
                                 ,rw_craplot_8457.nrseqdig + 1     
                                 ,108 --> Prest Empr.
                                 ,rw_craplot_8457.nrseqdig + 1
                                 ,vr_vldescto
                                 ,pr_nrparepr);
            EXCEPTION
              WHEN DUP_VAL_ON_INDEX THEN
                BEGIN
                  SELECT MAX(NVL(nrseqdig,0))+1
                    INTO vr_seqdig
                    FROM craplcm
                   WHERE cdcooper = pr_cdcooper
                     AND dtmvtolt = rw_craplot_8457.dtmvtolt
                     AND cdagenci = rw_craplot_8457.cdagenci
                     AND cdbccxlt = rw_craplot_8457.cdbccxlt
                     AND nrdolote = rw_craplot_8457.nrdolote;
                 EXCEPTION
                   WHEN OTHERS THEN   
                       vr_dscritic := 'Erro ao criar sequencia da (CRAPLCM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '- Seq.Lote:'||to_char(rw_craplot_8457.nrseqdig+1)
                            || '. Detalhes: '||sqlerrm;
                   RAISE vr_exc_erro;                      
                 END;
                 --
                 BEGIN 
                     INSERT INTO craplcm(cdcooper--
                                 ,dtmvtolt--
                                 ,cdagenci--
                                 ,cdbccxlt--
                                 ,nrdolote--
                                 ,cdpesqbb
                                 ,nrdconta
                                 ,nrdctabb
                                 ,nrdctitg
                                 ,nrdocmto
                                 ,cdhistor
                                 ,nrseqdig--
                                 ,vllanmto
                                 ,nrparepr)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8457.dtmvtolt
                                 ,rw_craplot_8457.cdagenci
                                 ,rw_craplot_8457.cdbccxlt
                                 ,rw_craplot_8457.nrdolote
                                 ,gene0002.fn_mask(rw_crapepr.nrctremp,'zz.zzz.zz9')  
                                 ,rw_crapepr.nrdconta
                                 ,rw_crapepr.nrdconta
                                 ,to_char(rw_crapepr.nrdconta,'fm00000000')
                                 ,rw_craplot_8457.nrseqdig + 1     
                                 ,108 --> Prest Empr.
                                 ,vr_seqdig
                                 ,vr_vldescto
                                 ,pr_nrparepr);
                 EXCEPTION
                   WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao criar lancamento2 para a conta corrente (CRAPLCM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '- Seq.Lote:'||to_char(rw_craplot_8457.nrseqdig+1)
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
                 END;
                 --                                 
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento para a conta corrente (CRAPLCM) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '- Seq.Lote:'||to_char(rw_craplot_8457.nrseqdig+1)
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;

            -- Subtrai o valor pago do saldo disponivel
            vr_vlsldtot := vr_vlsldtot - vr_vldescto;

            -- Efetuar criação do avisos de débito em conta
            BEGIN
              INSERT INTO crapavs(cdcooper
                                 ,dtmvtolt
                                 ,cdagenci
                                 ,cdempres
                                 ,cdhistor
                                 ,cdsecext
                                 ,dtdebito
                                 ,dtrefere
                                 ,insitavs
                                 ,nrdconta
                                 ,nrdocmto
                                 ,nrseqdig
                                 ,tpdaviso
                                 ,vldebito
                                 ,vlestdif
                                 ,vllanmto
                                 ,flgproce
                                 ,nrparepr)
                           VALUES(pr_cdcooper
                                 ,rw_craplot_8457.dtmvtolt
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdagenci
                                 ,0
                                 ,108 -- Mesmo do lançamento
                                 ,vr_tab_crapass(rw_crapepr.nrdconta).cdsecext
                                 ,rw_craplot_8457.dtmvtolt
                                 ,rw_craplot_8457.dtmvtolt
                                 ,0
                                 ,rw_crapepr.nrdconta
                                 ,to_number(to_char(systimestamp,'hh24missFF4')||to_char(pr_nrparepr))
                                 ,rw_craplot_8457.nrseqdig + 1
                                 ,2
                                 ,0
                                 ,0
                                 ,vr_vldescto
                                 ,0
                                 ,pr_nrparepr); -- false
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar aviso de débito em conta corrente (CRAPAVS) '
                            || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                            || '. Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;

            -- Atualizar as informações no lote utilizado
            BEGIN
              UPDATE craplot
                 SET vlinfodb = vlinfodb + vr_vldescto
                    ,vlcompdb = vlcompdb + vr_vldescto
                    ,qtinfoln = qtinfoln + 1
                    ,qtcompln = qtcompln + 1
                    ,nrseqdig = nrseqdig + 1
               WHERE rowid = rw_craplot_8457.rowid
               RETURNING nrseqdig INTO rw_craplot_8457.nrseqdig; -- Atualizamos a sequencia no rowtype
            EXCEPTION
              WHEN OTHERS THEN
                -- Gerar erro e fazer rollback
                vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8457.nrdolote||'. Detalhes: '||sqlerrm;
                RAISE vr_exc_erro;
            END;

            -- Testar se já retornado o registro de capas de lote para o 8453
            IF rw_craplot_8453.rowid IS NULL THEN
              -- Chamar rotina para buscá-lo, e se não encontrar, irá criálo
              pc_cria_craplot(pr_dtmvtolt   => rw_crapdat.dtmvtolt
                             ,pr_nrdolote   => 8453
                             ,pr_tplotmov   => 5
                             ,pr_rw_craplot => rw_craplot_8453
                             ,pr_dscritic   => vr_dscritic);
              -- Se houve retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                -- Sair do processo
                RAISE vr_exc_erro;
              END IF;
            END IF;

            -- Inicializar número auxiliar de documento com o empréstimo
            vr_nrdocmto := rw_crapepr.nrctremp;

            -- Verificar se já existe outro lançamento para este lote
            vr_qtd_lem_nrdocmto := 0;
            OPEN cr_craplem_nrdocmto(pr_dtmvtolt => rw_craplot_8453.dtmvtolt
                                    ,pr_nrdolote => rw_craplot_8453.nrdolote
                                    ,pr_nrdconta => rw_crapepr.nrdconta
                                    ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplem_nrdocmto
             INTO vr_qtd_lem_nrdocmto;
            CLOSE cr_craplem_nrdocmto;
            -- Se encontrou somente um registro (FIND)
            IF vr_qtd_lem_nrdocmto = 1 THEN
              -- Concatenar o número 9 + o contrato do empréstimo já montado
              vr_nrdocmto := '9' || vr_nrdocmto;
            END IF;

            -- Cria lancamento de pagamento para o emprestimo
            BEGIN
              INSERT INTO craplem(cdcooper--
                                 ,dtmvtolt--
                                 ,dtpagemp
                                 ,cdagenci--
                                 ,cdbccxlt--
                                 ,nrdolote--
                                 ,nrdconta--
                                 ,nrctremp
                                 ,nrdocmto--
                                 ,cdhistor
                                 ,nrseqdig
                                 ,vllanmto
                                 ,txjurepr
                                 ,vlpreemp
                                 ,nrparepr)
                           VALUES(pr_cdcooper--
                                 ,rw_craplot_8453.dtmvtolt--
                                 ,rw_craplot_8453.dtmvtolt
                                 ,rw_craplot_8453.cdagenci--
                                 ,rw_craplot_8453.cdbccxlt--
                                 ,rw_craplot_8453.nrdolote--
                                 ,rw_crapepr.nrdconta--
                                 ,rw_crapepr.nrctremp
                                 ,rw_craplot_8453.nrseqdig + 1 --vr_nrdocmto--
                                 ,95 --> Pg Empr CC
                                 ,rw_craplot_8453.nrseqdig + 1
                                 ,vr_vldescto
                                 ,rw_crapepr.vltaxa_juros 
                                 ,rw_crapepr.vlpreemp
                                 ,pr_nrparepr);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento de parcela para o emprestimo (CRAPLEM) '
                          || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;

          -- Atualizar as informações no lote utilizado
          BEGIN
            UPDATE craplot
               SET vlinfocr = vlinfocr + vr_vldescto
                  ,vlcompcr = vlinfocr + vr_vldescto
                  ,qtinfoln = qtinfoln + 1
                  ,qtcompln = qtcompln + 1
                  ,nrseqdig = nrseqdig + 1
             WHERE rowid = rw_craplot_8453.rowid
             RETURNING nrseqdig INTO rw_craplot_8453.nrseqdig; -- Atualizamos a sequencia no rowtype
          EXCEPTION
            WHEN OTHERS THEN
              -- Gerar erro e fazer rollback
              vr_dscritic := 'Erro ao atualizar capas de lotes (craplot), lote: '||rw_craplot_8453.nrdolote||'. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;

          -- Atualizar informações no rowtype do empréstimo
          -- para atualização única da tabela posteriormente
          rw_crapepr.dtultpag := rw_crapdat.dtmvtolt;
          IF rw_crapepr.txjuremp <> rw_crapepr.vltaxa_juros THEN
            rw_crapepr.txjuremp := rw_crapepr.vltaxa_juros;
            vr_inusatab := true;
          ELSE
            vr_inusatab := false;
          END IF;

          -- Caso pagamento seja menor que data atual
          IF rw_crapepr.dtdpagtoprc < rw_crapdat.dtmvtolt THEN

            -- Procedure para lancar Multa e Juros de Mora para o TR
            EMPR0009.pc_efetiva_pag_atraso_tr_prc(pr_cdcooper => pr_cdcooper
                                             ,pr_cdagenci => vr_cdagenci
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nmdatela => vr_cdprogra
                                             ,pr_idorigem => 1
                                             ,pr_nrdconta => rw_crapepr.nrdconta
                                             ,pr_nrctremp => rw_crapepr.nrctremp
                                             ,pr_vlpreapg => vr_vldescto
                                             ,pr_nrparcela => pr_nrparepr
                                             ,pr_dtdpagto  => rw_crapepr.dtdpagtoprc
                                             ,pr_vlpagpar => vr_vldescto
                                             ,pr_vlsldisp => vr_vlsldtot
                                             ,pr_cdhismul => vr_cdhismul
                                             ,pr_vldmulta => vr_vldmulta
                                             ,pr_cdhismor => vr_cdhismor
                                             ,pr_vljumora => vr_vljumora
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
            -- Se houve retorno de erro
            IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
              -- Verifica se foi passado apenas o codigo
              IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
                vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);    
              END IF;
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || 'Erro ao debitar multa e juros de mora. '
                                                         || 'Conta: ' || rw_crapepr.nrdconta || ', '
                                                         || 'Contrato: ' || rw_crapepr.nrctremp || '. '
                                                         || 'Critica: ' || vr_dscritic );
              -- Reseta variaveis
              vr_cdcritic := 0;
              vr_dscritic := NULL;
            END IF;
            --
          END IF;
          --
        ELSE
          -- Zerar o valor de desconto
          vr_vldescto := 0;
        END IF;
        --
        -- Se o saldo devedor for menor ou igual ao desconto da parcela
        IF rw_crapepr.vlsaldo_devedor <= vr_vldescto THEN
          -- Indicar que o emprestimo está liquidado
          rw_crapepr.inliquid := 1;
          -- Desativar o Rating associado a esta operaçao
          rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                     ,pr_cdagenci   => 0                   --> Código da agência
                                     ,pr_nrdcaixa   => 0                   --> Número do caixa
                                     ,pr_cdoperad   => pr_cdoperad         --> Código do operador
                                     ,pr_rw_crapdat => rw_crapdat          --> Vetor com dados de parâmetro (CRAPDAT)
                                     ,pr_nrdconta   => rw_crapepr.nrdconta --> Conta do associado
                                     ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                     ,pr_nrctrrat   => rw_crapepr.nrctremp --> Número do contrato de Rating
                                     ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                     ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                     ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                     ,pr_inusatab   => vr_inusatab         --> Indicador de utilização da tabela de juros
                                     ,pr_nmdatela   => vr_cdprogra         --> Nome datela conectada
                                     ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                     ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                     ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros



          /** GRAVAMES **/
          GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper          -- Código da cooperativa
                                               ,pr_nrdconta => rw_crapepr.nrdconta  -- Numero da conta do contrato
                                               ,pr_nrctrpro => rw_crapepr.nrctremp  -- Numero do contrato
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  -- Data de movimento para baixa
                                               ,pr_des_reto => vr_des_reto          -- Retorno OK ou NOK
                                               ,pr_tab_erro => vr_tab_erro          -- Retorno de erros em PlTable
                                               ,pr_cdcritic => vr_cdcritic          -- Retorno de codigo de critica
                                               ,pr_dscritic => vr_dscritic);        -- Retorno de descricao de critica


        ELSE
          -- Indicar que o emprestimo não está liquidado
          rw_crapepr.inliquid := 0;
        END IF;

        -- Para registros rejeitados
        IF vr_flgrejei THEN
          BEGIN
          vr_cdagencia := vr_tab_crapass(rw_crapepr.nrdconta).cdagenci;
          EXCEPTION
            WHEN OTHERS THEN
               vr_cdagencia := rw_crapepr.cdagenci;
          END;
          -- Cria o registro de rejeitos
          BEGIN
            INSERT INTO craprej(cdcooper
                               ,dtmvtolt
                               ,cdagenci
                               ,cdbccxlt
                               ,nrdconta
                               ,nraplica
                               ,vllanmto
                               ,vlsdapli
                               ,vldaviso
                               ,cdpesqbb
                               ,cdcritic)
                         VALUES(pr_cdcooper
                               ,rw_crapepr.dtdpagtoprc
                               ,vr_cdagencia
                               ,171
                               ,rw_crapepr.nrdconta
                               ,rw_crapepr.nrctremp
                               ,vr_vldescto
                               ,rw_crapepr.vlsaldo_devedor 
                               ,rw_crapepr.vlpreemp
                               ,to_char(ROUND(nvl(rw_crapepr.vlparcela,0) - vr_vldescto,2),'fm0g000g000d00')
                               ,171); --> Guardar ou a regularizar
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento de Rejeitados (craprej) '
                          || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                          || '. Detalhes: '||sqlerrm;
              RAISE vr_exc_erro;
          END;

        END IF; 
        --
        -- se é o pagamento da parcela do mês
        IF TRUNC(rw_crapepr.dtdpagtoprc,'MM') = trunc(rw_crapdat.dtmvtolt,'MM') THEN
          --
          -- se foi integralmente pago
          IF vr_vlpremes = vr_vldescto then
            --
            -- Adicionar 1 mês a data atual
            rw_crapepr.dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagtoprc  --> Data do pagamento anterior
                                               ,pr_qtmesano => 1                             --> +1 mês
                                               ,pr_tpmesano => 'M'
                                               ,pr_des_erro => vr_dscritic);
            -- Parar se encontrar erro
            IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF; 
            --  
            rw_crapepr.indpagto := 1;                                            
            --
          -- se não foi pago integralmente, não muda mês e nem finaliza pagamento mês
          ELSIF vr_vldescto > 0 THEN
            rw_crapepr.dtdpagto := rw_crapepr.dtdpagtoprc;
            rw_crapepr.indpagto := 0; 
          -- se não foi pago nada, não muda dtdpgto e nem finaliza pagamento mês
          ELSE
            rw_crapepr.indpagto := 0; 
          END IF;
          --
        -- se NÃO é o pagamento da parcela do mês
        ELSIF TRUNC(rw_crapepr.dtdpagtoprc,'MM') < trunc(rw_crapdat.dtmvtolt,'MM') THEN
          --
          -- se foi integralmente pago
          IF vr_vlpremes = vr_vldescto then
            --
            -- Adicionar 1 mês a data atual
            rw_crapepr.dtdpagto := gene0005.fn_calc_data(pr_dtmvtolt => rw_crapepr.dtdpagtoprc  --> Data do pagamento anterior
                                               ,pr_qtmesano => 1                             --> +1 mês
                                               ,pr_tpmesano => 'M'
                                               ,pr_des_erro => vr_dscritic);
            -- Parar se encontrar erro
            IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_erro;
            END IF; 
            --  
            rw_crapepr.indpagto := 0;                                            
            --
          -- se não foi pago integralmente, não muda mês e nem finaliza pagamento mês
          ELSIF vr_vldescto > 0 THEN
            rw_crapepr.dtdpagto := rw_crapepr.dtdpagtoprc;
            rw_crapepr.indpagto := 0; 
          -- se não foi pago nada, não muda dtdpgto e nem finaliza pagamento mês
          ELSE
            rw_crapepr.indpagto := 0; 
          END IF;
          --           
        END IF;
        --
        -- Finalmente após todo o processamento, é atualizada a tabela de empréstimo CRAPEPR
        BEGIN
          UPDATE crapepr
            SET dtdpagto  = rw_crapepr.dtdpagto
                ,dtultpag = rw_crapepr.dtultpag
                ,txjuremp = rw_crapepr.txjuremp
                ,inliquid = rw_crapepr.inliquid
                ,indpagto = rw_crapepr.indpagto
         WHERE rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar o empréstimo (CRAPEPR).'
                        || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                        || '. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;  
        --
        BEGIN
          UPDATE tbepr_tr_parcelas
            SET vlpago  = vr_vldescto
         WHERE rowid = rw_crapepr.rowidprc;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar erro e fazer rollback
            vr_dscritic := 'Erro ao atualizar a parcela/empréstimo (TBEPR_TR_PARCELAS).'
                        || '- Conta:'||rw_crapepr.nrdconta || ' CtrEmp:'||rw_crapepr.nrctremp
                        || '. Detalhes: '||sqlerrm;
            RAISE vr_exc_erro;
        END;  
        --   
      END LOOP;
      --
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao criar pagar parcelas. Rotina pc_CRPS750_1.pc_gera_pagamento. - '||nvl(vr_dscritic,sqlerrm);
        --Sair do programa
        RAISE vr_exc_erro;
    END pc_gera_pagamento; 
      
    --Fase processo 3
    --Procedure para gerar o movimento de rejeitados
    PROCEDURE pc_gera_movimento_rejeitados(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                           pr_cdagenci IN crapass.cdagenci%TYPE) IS    

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.vllimcre
              ,ass.cdagenci
              ,ass.cdsecext
              ,ass.nrramemp
              ,ass.inpessoa
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper;
                 
      -- Busca dos telefones dos associados
      CURSOR cr_craptfc IS
        SELECT nrdconta
              ,tptelefo
              ,nrdddtfc
              ,nrtelefo
              ,ROW_NUMBER () OVER (PARTITION BY nrdconta
                                               ,tptelefo
                                       ORDER BY progress_recid) sqregtpt
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND tptelefo IN(1,2,3); -- Res, Cel e Com.  

      -- Busca das empresas em titulares de conta
      CURSOR cr_crapttl IS
        SELECT nrdconta
              ,cdempres
              ,cdturnos
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND idseqttl = 1; --> Somente titulares

      -- Busca das empresas no cadastro de pessoas juridicas
      CURSOR cr_crapjur IS
        SELECT nrdconta
              ,cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper;   
         
      -- Leitura dos registros rejeitos do empréstimo
      CURSOR cr_craprej IS
        SELECT cdagenci
              ,nrdconta
              ,nraplica
              ,min(dtmvtolt) dtmvtolt
              ,sum(gene0002.fn_char_para_number(cdpesqbb)) cdpesqbb
              ,max(vlsdapli)- sum(vllanmto) vlsdapli --ews
              ,max(vldaviso) vldaviso
              ,sum(vllanmto) vllanmto
              ,ROW_NUMBER () OVER (PARTITION BY cdagenci
                                       ORDER BY cdagenci) sqregpac
              ,COUNT (*) OVER (PARTITION BY cdagenci) qtregpac
              ,COUNT (*)  qtparcelas
          FROM craprej
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = 171
           AND cdcritic = 171
        GROUP BY cdagenci
              ,nrdconta
              ,nraplica
        ORDER BY cdagenci
                ,nrdconta
                ,nraplica; 

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;                                
           
      -- Definição de tipo para armazenar os telefones do associado
      TYPE typ_reg_craptfc IS
        RECORD(nrfonere VARCHAR2(30)
              ,nrfoncel VARCHAR2(30)
              ,nrfoncom VARCHAR2(30));
      TYPE typ_tab_craptfc IS
        TABLE OF typ_reg_craptfc
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_craptfc typ_tab_craptfc;

      -- Tipo para busca da empresa tanto de pessoa física quanto juridica
      -- Para fisica também armazena o turno
      TYPE typ_reg_empresa IS
        RECORD(cdempres crapttl.cdempres%TYPE
              ,cdturnos crapttl.cdturnos%TYPE);
      TYPE typ_tab_empresa IS
        TABLE OF typ_reg_empresa
          INDEX BY PLS_INTEGER; -- Obs. A chave é o número da conta
      vr_tab_empresa typ_tab_empresa;    
      
      -- Definição de tipo para armazenar informações dos associados
      TYPE typ_reg_crapass IS
        RECORD(vllimcre crapass.vllimcre%TYPE
              ,cdagenci crapass.cdagenci%TYPE
              ,cdsecext crapass.cdsecext%TYPE
              ,nrramemp crapass.nrramemp%TYPE
              ,inpessoa crapass.inpessoa%TYPE
              ,nmprimtl crapass.nmprimtl%TYPE);
      TYPE typ_tab_crapass IS
        TABLE OF typ_reg_crapass
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;      

      -- Variaveis para os XMLs e relatórios
      vr_clobarq     CLOB;                  -- Clob para conter o dados do txt
      vr_clobxml     CLOB;                  -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo
      vr_dspathcopia VARCHAR2(4000);        -- Path para cópia do arquivo exportado
      vr_flgarqtx    BOOLEAN := FALSE;      -- Indicar que gerou o txt  
      
      -- Variaveis
      vr_nmresage crapage.nmresage%TYPE;  
      
      -- Campos para o relatório
      vr_nrramfon VARCHAR2(60);             -- Telefones
      vr_vlsdapli VARCHAR2(30);             -- Saldo devedor
      vr_vldaviso VARCHAR2(30);             -- Valor prestação
      vr_vllanmto VARCHAR2(30);             -- Valor débito
      vr_vlestour VARCHAR2(30);             -- Valor estouro
      vr_cdturnos NUMBER;                   -- Turno de trabalho
      
      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;          
           
    BEGIN
      -- Busca dos associados da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Adicionar ao vetor as informações chaveando pela conta
        vr_tab_crapass(rw_crapass.nrdconta).vllimcre := rw_crapass.vllimcre;
        vr_tab_crapass(rw_crapass.nrdconta).cdagenci := rw_crapass.cdagenci;
        vr_tab_crapass(rw_crapass.nrdconta).cdsecext := rw_crapass.cdsecext;
        vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
        vr_tab_crapass(rw_crapass.nrdconta).nrramemp := rw_crapass.nrramemp;
        vr_tab_crapass(rw_crapass.nrdconta).inpessoa := rw_crapass.inpessoa;
        vr_tab_crapass(rw_crapass.nrdconta).nmprimtl := rw_crapass.nmprimtl;
      END LOOP;
      -- Buscar todos os telefones dos associados
      FOR rw_craptfc IN cr_craptfc LOOP
        -- Somente gravar o primeiro registro (find-first)
        IF rw_craptfc.sqregtpt = 1 THEN
          -- Gravar os campos residencial, celular ou comercial
          -- conforme o tipo de registro de telefone da tabela
          IF rw_craptfc.tptelefo = 1 THEN
            -- Residencial, armazena DDD e número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfonere := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
          ELSIF rw_craptfc.tptelefo = 3 THEN
            -- Comercial, armazena DDD e número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfoncom := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
          ELSE
            -- Celular armazena apenas o número
            vr_tab_craptfc(rw_craptfc.nrdconta).nrfoncel := rw_craptfc.nrtelefo;
          END IF;
        END IF;
      END LOOP;
      --
      -- Carregar PLTABLE de titulares de conta
      FOR rw_crapttl IN cr_crapttl LOOP
        vr_tab_empresa(rw_crapttl.nrdconta).cdempres := rw_crapttl.cdempres;
        vr_tab_empresa(rw_crapttl.nrdconta).cdturnos := rw_crapttl.cdturnos;
      END LOOP;
      -- Carregar PLTABLE de empresas
      FOR rw_crapjur IN cr_crapjur LOOP
        vr_tab_empresa(rw_crapjur.nrdconta).cdempres := rw_crapjur.cdempres;
      END LOOP;

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);   
                                            
      -- Buscar todos os registros rejeitados --
      FOR rw_craprej IN cr_craprej LOOP
        -- Se ainda não preparou o arquivo txt
        IF NOT vr_flgarqtx THEN
          -- Preparar o CLOB para armazenar as infos do arquivo
          dbms_lob.createtemporary(vr_clobarq, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobarq, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobarq,'PA;CONTA/DV;EMP;RAMAL/TELEFONE;TU;NOME;CONTRATO;DIA;SLD DEVEDOR;PRESTACAO;VLR DEBITO;VLR ESTOURO'||chr(10));
          -- Indica que preparou
          vr_flgarqtx := TRUE;
        END IF;
        -- Para cada agencia nova
        IF rw_craprej.sqregpac = 1 THEN
          -- Buscar o nome do PAC
          vr_nmresage := NULL;
          OPEN cr_crapage(rw_craprej.cdagenci);
          FETCH cr_crapage
           INTO vr_nmresage;
          CLOSE cr_crapage;
          -- Se não encontrar descrição
          IF nvl(vr_nmresage, ' ') = ' ' THEN
            -- Usar descrição genérica
            vr_nmresage := 'PA NAO CADASTRADO';
          END IF;
          -- Cada PAC terá um arquivo diferente portanto
          -- preparar o CLOB para o relatório do PAC atual
          dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
          dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
          pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><pac cdagenci="'||rw_craprej.cdagenci||'" nmresage="'||vr_nmresage||'">');
        END IF;
        -- Validar se a conta atual existe na tabela de memória dos associados
        IF NOT vr_tab_crapass.EXISTS(rw_craprej.nrdconta) THEN
          -- Fechar os CLOBS para limpar a memória
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          dbms_lob.close(vr_clobarq);
          dbms_lob.freetemporary(vr_clobarq);
          -- Gerar critica 9
          pr_cdcritic := 9;
          pr_dscritic := gene0001.fn_busca_critica(251) || ' Cta: ' || gene0002.fn_mask_conta(rw_craprej.nrdconta);
          RAISE vr_exc_erro;
        END IF;
        -- Inicializar os campos do relatório
        vr_nrramfon := '';
        vr_vlsdapli := null;
        vr_vldaviso := null;
        vr_vllanmto := null;
        vr_vlestour := null;

        -- Se não existir registro na tabela de empresas
        IF NOT vr_tab_empresa.EXISTS(rw_craprej.nrdconta) THEN
          -- Inicializar um registro vazio para evitar erros futuros
          vr_tab_empresa(rw_craprej.nrdconta).cdempres := null;
        END IF;

        -- Busca dos telefones, primeiramente verifica se existe algum
        -- registro carregado na tabela de telefones (craptfc)
        IF vr_tab_craptfc.EXISTS(rw_craprej.nrdconta) THEN
          -- Se houver o telefone residencial
          IF vr_tab_craptfc(rw_craprej.nrdconta).nrfonere IS NOT NULL THEN
            -- Adicioná-lo
            vr_nrramfon := vr_tab_craptfc(rw_craprej.nrdconta).nrfonere;
          END IF;
          -- Se houver celelular
          IF vr_tab_craptfc(rw_craprej.nrdconta).nrfoncel IS NOT NULL THEN
            -- Adicioná-lo (com uma / caso já tenhamos enviado o residencial)
            IF vr_nrramfon IS NOT NULL THEN
              vr_nrramfon := vr_nrramfon || '/';
            END IF;
            vr_nrramfon := vr_nrramfon || vr_tab_craptfc(rw_craprej.nrdconta).nrfoncel;
          END IF;
          -- Se chegarmos neste ponto e não foi encontrado nenhum telefone
          IF vr_nrramfon IS NULL THEN
            -- Utilizaremos o telefone comercial da tabela
            vr_nrramfon := vr_tab_craptfc(rw_craprej.nrdconta).nrfoncom;
          END IF;
        END IF;

        -- Enviaremos os campos de saldo devedor, prestação, valor débito e valor estouro
        -- somente se o valor dor superior a zero, senão enviaremos null
        IF rw_craprej.cdpesqbb > 0 THEN
          vr_vlestour := to_char(rw_craprej.cdpesqbb,'fm999g999g990d00');
        END IF;
        IF rw_craprej.vlsdapli > 0 THEN
          vr_vlsdapli := to_char(rw_craprej.vlsdapli,'fm999g999g990d00');
        END IF;
        IF rw_craprej.vldaviso > 0 THEN
          vr_vldaviso := to_char(rw_craprej.vldaviso,'fm999g999g990d00');
        END IF;
        IF rw_craprej.vllanmto > 0 THEN
          vr_vllanmto := to_char(rw_craprej.vllanmto,'fm999g999g990d00');
        END IF;

        -- Enviar o registro para o relatório
        pc_escreve_clob(vr_clobxml,'<rejeitos>'
                                 ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(rw_craprej.nrdconta))||'</nrdconta>'
                                 ||'  <cdempres>'||vr_tab_empresa(rw_craprej.nrdconta).cdempres||'</cdempres>'
                                 ||'  <nrramfon>'||substr(vr_nrramfon,1,20)||'</nrramfon>'
                                 ||'  <cdturnos>'||vr_tab_empresa(rw_craprej.nrdconta).cdturnos||'</cdturnos>'
                                 ||'  <nmprimtl>'||substr(vr_tab_crapass(rw_craprej.nrdconta).nmprimtl,1,26)||'</nmprimtl>'
                                 ||'  <nraplica>'||LTRIM(gene0002.fn_mask(rw_craprej.nraplica,'zzzz.zz9'))||'</nraplica>'
                                 ||'  <diapagto>'||to_char(rw_craprej.dtmvtolt,'dd')||'</diapagto>'
                                 ||'  <vlsdapli>'||vr_vlsdapli||'</vlsdapli>'
                                 ||'  <vldaviso>'||vr_vldaviso||'</vldaviso>'
                                 ||'  <vllanmto>'||vr_vllanmto||'</vllanmto>'
                                 ||'  <vlestour>'||vr_vlestour||'</vlestour>'
                                 ||'</rejeitos>');

        -- Se existe turno cadastrado
        IF vr_tab_empresa(rw_craprej.nrdconta).cdturnos IS NOT NULL THEN
          -- Usá-la
          vr_cdturnos := vr_tab_empresa(rw_craprej.nrdconta).cdturnos;
        ELSE
          -- Usar zero
          vr_cdturnos := 0;
        END IF;

        -- Enviaremos os campos de saldo devedor, prestação e valor débito
        -- somente se o valor dor superior a zero, senão enviaremos 0
        IF rw_craprej.vlsdapli > 0 THEN
          vr_vlsdapli := to_char(rw_craprej.vlsdapli,'999g990d00');
        ELSE
          vr_vlsdapli := to_char(0,'999g990d00');
        END IF;
        IF rw_craprej.vldaviso > 0 THEN
          vr_vldaviso := to_char(rw_craprej.vldaviso,'999g990d00');
        ELSE
          vr_vldaviso := to_char(0,'999g990d00');
        END IF;
        IF rw_craprej.vllanmto > 0 THEN
          vr_vllanmto := to_char(rw_craprej.vllanmto,'999g990d00');
        ELSE
          vr_vllanmto := to_char(0,'999g990d00');
        END IF;
        -- Quanto ao saldo devedor seguirá o mesmo esquema acima, ou seja, só envia se houver
        -- e a mascara neste ponto é um pouco diferente da versão no XML
        IF rw_craprej.cdpesqbb > 0 THEN
          vr_vlestour := to_char(rw_craprej.cdpesqbb,'999g990d00');
        ELSE
          vr_vlestour := to_char(0,'999g990d00');
        END IF;

        -- Enviamos também as informações para o arquivo de exportação
        pc_escreve_clob(vr_clobarq,LPAD(rw_craprej.cdagenci,3,' ')||';'
                                   ||gene0002.fn_mask_conta(rw_craprej.nrdconta)||';'
                                   ||LPAD(vr_tab_empresa(rw_craprej.nrdconta).cdempres,5,' ')||';'
                                   ||RPAD(substr(vr_nrramfon,1,20),20,' ')||';'
                                   ||LPAD(vr_cdturnos,2,' ')||';'
                                   ||RPAD(substr(vr_tab_crapass(rw_craprej.nrdconta).nmprimtl,1,26),26,' ')||';'
                                   ||gene0002.fn_mask(rw_craprej.nraplica,'zzzz.zz9')||';'
                                   ||to_char(rw_craprej.dtmvtolt,'dd')||';'
                                   ||vr_vlsdapli||';'
                                   ||vr_vldaviso||';'
                                   ||vr_vllanmto||';'
                                   ||vr_vlestour
                                   ||chr(10));

        -- No ultimo registro do pac
        IF rw_craprej.sqregpac = rw_craprej.qtregpac THEN
          -- Encerrar a tag do pac atual
          pc_escreve_clob(vr_clobxml,'</pac>');

          -- Submeter o relatório 135
          gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                     ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                     ,pr_dsxml     => vr_clobxml                           --> Arquivo XML de dados
                                     ,pr_dsxmlnode => '/pac/rejeitos'                      --> Nó base do XML para leitura dos dados
                                     ,pr_dsjasper  => 'crrl135.jasper'                     --> Arquivo de layout do iReport
                                     ,pr_dsparams  => null                                 --> Sem parâmetros
                                     ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl135_'||to_char(rw_craprej.cdagenci,'fm000')||'.lst' --> Arquivo final com o path
                                     ,pr_qtcoluna  => 132                                  --> 132 colunas
                                     ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                     ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                     ,pr_nmformul  => ''                                   --> Nome do formulário para impressão
                                     ,pr_nrcopias  => 2                                    --> Número de cópias
                                     ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                                     ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
          -- Liberando a memória alocada pro CLOB
          dbms_lob.close(vr_clobxml);
          dbms_lob.freetemporary(vr_clobxml);
          -- Testar se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;
      --
      -- Ao final do processamento, se foi ativada a flag do arquivo
      IF vr_flgarqtx THEN
        -- Tenta buscar o parâmetro para cópia do TXT para algum usuário
        IF gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL135_COPIA') IS NOT NULL THEN
          -- Efetuar a cópia do arquivo crrl35.txt também para diretório parametrizado
          vr_dspathcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL135_COPIA');
        END IF;
        -- Submeter a geração do arquivo txt puro
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                           ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                                           ,pr_dsxml     => vr_clobarq                           --> Arquivo XML de dados
                                           ,pr_cdrelato  => '135'                                --> Código do relatório
                                           ,pr_dsarqsaid => vr_nom_direto||'/salvar/crrl135_'||to_char(pr_cdagenci,'fm000')||'.txt' --> Arquivo final com o path
                                           ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                                           ,pr_dspathcop => vr_dspathcopia                       --> Copiar para o diretório
                                           ,pr_fldoscop  => 'S'                                  --> Copia convertendo para DOS
                                           ,pr_flgremarq => 'N'                                  --> Após cópia, remover arquivo de origem
                                           ,pr_des_erro  => vr_dscritic);                        --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobarq);
        dbms_lob.freetemporary(vr_clobarq);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Ao final do processo irá eliminar os registros rejeitos
      BEGIN
        DELETE craprej rej
         WHERE rej.cdcooper = pr_cdcooper
           AND rej.cdagenci = pr_cdagenci
           AND rej.cdbccxlt = 171
           AND rej.cdcritic = 171;
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro e fazer rollback
          pr_cdcritic := 'Erro ao atualizar a limpeza na tabela de registros rejeitos (CRAPREJ). Detalhes: '||sqlerrm;
          RAISE vr_exc_erro;
      END;
      --
      --
                                          
    EXCEPTION
      WHEN OTHERS THEN
        --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro Rotina pc_CRPS750_1.pc_gera_movimento_rejeitados. '||sqlerrm||'-'||pr_dscritic;
        --Sair do programa
        RAISE vr_exc_erro;
    END pc_gera_movimento_rejeitados;    
    ---------------------------------------
    -- Inicio Bloco Principal PC_CRPS750_1
    ---------------------------------------
  BEGIN
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
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
      --
      -- se processo for na diária, pega os empréstimos vencidos no dia
      IF rw_crapdat.inproces > 2 then
        vr_dtcursor := rw_crapdat.dtmvtolt;
      -- se processo não for na diária, pega somente os empréstimos atrasados
      ELSE
        vr_dtcursor := rw_crapdat.dtmvtolt - 1;
      END IF;
      --  
      IF pr_faseprocesso = 1 THEN
        pc_gera_tabela_parcelas(pr_cdcooper);
      ELSIF pr_faseprocesso = 2 THEN
        pc_gera_pagamento(pr_cdcooper 
                         ,pr_nrdconta 
                         ,pr_nrctremp
                         ,pr_nrparepr);
      ELSIF pr_faseprocesso = 3 THEN
        pc_gera_movimento_rejeitados(pr_cdcooper,
                                     pr_cdagenci);
      END IF;
      --
  EXCEPTION
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
  END;
END PC_CRPS750_1;
/
