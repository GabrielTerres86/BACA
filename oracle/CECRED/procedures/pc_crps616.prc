create or replace procedure cecred.pc_crps616(pr_cdcooper  in craptab.cdcooper%type,
                                              pr_cdagenci  in crapage.cdagenci%type,  --> Codigo Agencia
                                              pr_idparale  in crappar.idparale%type,  --> Indicador de processoparalelo
                                              pr_flgresta  in pls_integer,            --> Flag padrão para utilização de restart
                                              pr_stprogra out pls_integer,            --> Saída de termino da execução
                                              pr_infimsol out pls_integer,            --> Saída de termino da solicitação,
                                              pr_cdcritic out crapcri.cdcritic%type,
                                              pr_dscritic out varchar2) as
/* ............................................................................

   Programa: pc_crps616 (Antigo Fontes/crps616.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2012                       Ultima atualizacao: 07/02/2018

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Atualizar saldo das parcelas de todos os contratos de emprestimo

   Alteracoes: 15/01/2013 - Atualizar o campo crapepr.dtdpagto com a data da
                            primeira parcela nao liquidada.
                           (David Kruger).

               12/07/2013 - Ajuste na gravacao de juros + 60 (Gabriel).

               06/12/2013 - Ajuste para melhorar a performance (James).

               24/01/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).

               12/02/2014 - Ajuste para atualizar os valores do emprestimo
                            e gravar na tabela crapepr e crappep. (James)

               02/05/2014 - Ajuste no calculo da tolerancia da multa e Juros
                            de Mora. (James)

               14/05/2014 - Ajuste para buscar o prazo de tolerancia da tabela crapepr
                            e nao mais da tab089. (James)

               16/06/2014 - Ajuste para calcular o valor total pago no mes, para verificar o
                            historico de pagamento de avalista. (James)

               01/08/2014 - Ajuste para filtrar a parcela no calculo do juros de mora. (James)

               04/11/2014 - Ajustes de Performance. Foram retirados selects de dentro do loop e
                            utilizado temp-table para selecionar o valor já pago dos emprestimos.
                            A atualização das tabelas crapepr e crappep ocorre com o comando forall.
                            (Alisson - AMcom)

               02/04/2015 - Ajuste na procedure pc_calc_atraso_parcela para verificar os historicos
                            de emprestimo e financiamento. (James)

               21/05/2015 - Ajuste para verificar se Cobra Multa. (James)

               09/10/2015 - Incluir históricos de estorno. (Oscar)

               07/02/2018 - Projeto Ligeirinho - Incluindo paralelismo para melhorar a performance
                            da rotina (Fabiano B. Dias - AMcom)
............................................................................. */
  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;

  -- Cursor genérico de parametrização
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.dstextab
          ,tab.tpregist
          ,tab.ROWID
      FROM craptab tab
     WHERE tab.cdcooper        = pr_cdcooper
       AND UPPER(tab.nmsistem) = pr_nmsistem
       AND UPPER(tab.tptabela) = pr_tptabela
       AND tab.cdempres        = pr_cdempres
       AND UPPER(tab.cdacesso) = pr_cdacesso
       AND tab.tpregist        = NVL(pr_tpregist,tab.tpregist);
  rw_craptab cr_craptab%ROWTYPE;

  -- Ligeirinho - Buscar agências da cooperativa que possuem os empréstimos pré-fixados e ainda não liquidados
  cursor cr_crapepr_agenci (pr_cdcooper in crapepr.cdcooper%type
                           ,pr_cdagenci in crapepr.cdagenci%type
                           ,pr_dtmvtolt in crapdat.dtmvtolt%TYPE
                           ,pr_cdprogra in tbgen_batch_controle.cdprogra%TYPE
                           ,pr_qterro   in number ) is
    select distinct crapass.cdagenci
      from crapepr
          ,crapass
     where crapepr.cdcooper = crapass.cdcooper
       and crapepr.nrdconta = crapass.nrdconta
       and crapepr.cdcooper = pr_cdcooper
       and crapepr.tpemprst = 1
       and crapepr.inliquid = 0
       and crapass.cdagenci = decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci)
       and (pr_qterro = 0 or
           (pr_qterro > 0 and exists ( select 1
                                         from tbgen_batch_controle
                                        where tbgen_batch_controle.cdcooper    = pr_cdcooper
                                          and tbgen_batch_controle.cdprogra    = pr_cdprogra
                                          and tbgen_batch_controle.tpagrupador = 1
                                          and tbgen_batch_controle.cdagrupador = crapass.cdagenci
                                          and tbgen_batch_controle.insituacao  = 1
                                          and tbgen_batch_controle.dtmvtolt    = pr_dtmvtolt)));

  -- Buscar os empréstimos pré-fixados e ainda não liquidados
  cursor cr_crapepr (pr_cdcooper in crapepr.cdcooper%type
                    ,pr_cdagenci in crapepr.cdagenci%type) is
    select crapepr.cdcooper,
           crapepr.nrdconta,
           crapepr.nrctremp,
           crapepr.vlemprst,
           crapepr.qtpreemp,
           crapepr.dtdpagto,
           crapepr.txmensal,
           crapepr.cdlcremp,
           crapepr.qtmesdec,
           crapepr.qtprecal,
           crapepr.qttolatr,
           crapepr.rowid
      from crapepr
          ,crapass
     where crapepr.cdcooper = crapass.cdcooper
       and crapepr.nrdconta = crapass.nrdconta
       and crapepr.cdcooper = pr_cdcooper
       and crapass.cdagenci = decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci) -- Ligeirinho.
       and crapepr.tpemprst = 1
       and crapepr.inliquid = 0;

  -- Buscar informações complementares do empréstimo
  cursor cr_crawepr (pr_cdcooper in crawepr.cdcooper%type,
                     pr_nrdconta in crawepr.nrdconta%type,
                     pr_nrctremp in crawepr.nrctremp%type) is
    select crawepr.dtlibera
      from crawepr
     where crawepr.cdcooper = pr_cdcooper
       and crawepr.nrdconta = pr_nrdconta
       and crawepr.nrctremp = pr_nrctremp;
  rw_crawepr     cr_crawepr%rowtype;

  -- Busca das linhas de crédito
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
    SELECT craplcr.perjurmo
          ,craplcr.cdlcremp
          ,craplcr.flgcobmu
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper;
  rw_craplcr cr_craplcr%ROWTYPE;

  -- Buscar o ultimo lançamento de juros
  CURSOR cr_craplem_carga (pr_cdcooper IN craplem.cdcooper%TYPE,
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                           pr_cdagenci IN craplem.cdagenci%TYPE) IS
    SELECT /*+ index (craplem craplem##craplem4) */
       craplem.nrdconta,
       craplem.nrctremp,
       SUM(DECODE(craplem.cdhistor,
                      1044,
                      craplem.vllanmto,
                      1039,
                      craplem.vllanmto,
                      1045,
                      craplem.vllanmto,
                      1057,
                      craplem.vllanmto,
                      1716,
                      craplem.vllanmto * -1,
                      1707,
                      craplem.vllanmto * -1,
                      1714,
                      craplem.vllanmto * -1,
                      1705,
                      craplem.vllanmto * -1)) as vllanmto
     FROM craplem
         ,crapass
     WHERE craplem.cdcooper = crapass.cdcooper
       AND craplem.nrdconta = crapass.nrdconta
       AND craplem.cdcooper = pr_cdcooper
       AND crapass.cdagenci = decode(pr_cdagenci, 0, crapass.cdagenci, pr_cdagenci) -- Ligeirinho.
       AND craplem.nrdolote in (600012,600013,600031)
       AND craplem.cdhistor in (1044,1045,1039,1057,1716,1707,1714,1705)
       AND craplem.dtmvtolt between trunc(pr_dtmvtolt,'mm') and trunc(last_day(pr_dtmvtolt)) --> Mesmo ano e mês corrente
    GROUP BY craplem.nrdconta,craplem.nrctremp;

  -- Buscar parcelas não liquidadas
  cursor cr_crappep (pr_cdcooper in crappep.cdcooper%type,
                     pr_nrdconta in crappep.nrdconta%type,
                     pr_nrctremp in crappep.nrctremp%type) is
    select crappep.nrparepr,
           crappep.dtvencto,
           crappep.vlsdvpar,
           crappep.dtultpag,
           crappep.vlsdvsji,
           crappep.vlparepr,
           crappep.vlpagmta,
           crappep.vlpagmra,
           crappep.vlsdvatu,
           crappep.rowid
      from crappep
     where crappep.cdcooper = pr_cdcooper
       and crappep.nrdconta = pr_nrdconta
       and crappep.nrctremp = pr_nrctremp
       and crappep.inliquid = 0;
  --
  TYPE typ_reg_craplcr IS RECORD
    (perjurmo craplcr.perjurmo%type,
     flgcobmu craplcr.flgcobmu%type);
  TYPE typ_tab_craplcr IS TABLE OF typ_reg_craplcr INDEX BY PLS_INTEGER;
  -- Array de Linhas Creditos
  vr_tab_craplcr typ_tab_craplcr;

  --
  TYPE typ_reg_crappep IS RECORD
    (vlsdvatu crappep.vlsdvatu%type,
     vljura60 crappep.vljura60%type,
     vlmrapar crappep.vlmrapar%type,
     vlmtapar crappep.vlmtapar%type,
     vr_rowid rowid);
  TYPE typ_tab_crappep IS TABLE OF typ_reg_crappep INDEX BY PLS_INTEGER;
  vr_tab_crappep typ_tab_crappep;

  --
  TYPE typ_reg_crapepr IS RECORD
    (dtdpagto crapepr.dtdpagto%type,
     vlsdvctr crapepr.vlsdvctr%type,
     qtlcalat crapepr.qtlcalat%type,
     qtpcalat crapepr.qtpcalat%type,
     vlsdevat crapepr.vlsdevat%type,
     vlpapgat crapepr.vlpapgat%type,
     vlppagat crapepr.vlppagat%type,
     qtmdecat crapepr.qtmdecat%type,
     vr_rowid rowid);
  TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
  vr_tab_crapepr typ_tab_crapepr;

  --
  TYPE typ_tab_craplem IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
  vr_tab_craplem typ_tab_craplem;

  -- Indice para o Array de historicos
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);
  -- Variáveis para auxiliar o processamento
  vr_fldtpgto      boolean;
  vr_flgtrans      boolean;
  vr_vlatupar      NUMBER(35,2); -- 10 decimais
  -- Exceção para sair do bloco de busca em caso de erro
  leave_busca      exception;
  -- Variáveis para auxiliar no cálculo dos novos valores das parcelas
  vr_nrdiatol      INTEGER; -- Prazo para tolerancia da multa
  vr_vldespar      crappep.vldespar%type;
  vr_vlmrapar      crappep.vlmrapar%type; -- Valor do Juros de Mora
  vr_vlmtapar      crappep.vlmtapar%type; -- Valor da Multa
  vr_percmultab      NUMBER; -- % de multa para o calculo
  vr_percmultab_calc NUMBER; -- % de multa para o calculo
  vr_vlsdevat      NUMBER; -- Saldo devedor atualizado
  vr_vlpreapg      NUMBER; -- Valor parcela a pagar
  vr_vlprepag      NUMBER; -- Valor parcela paga
  vr_vlsdvctr      NUMBER; -- Saldo Contratado
  vr_dtdpagto      DATE; -- Data de pagamento
  vr_qtmesdec      crapepr.qtmesdec%type;
  vr_index         PLS_INTEGER;
  vr_index_craplem VARCHAR2(20);

  ------------------------
  -- Ligeirinho - inicio:
  ------------------------
  -- ID para o paralelismo
  vr_idparale      integer;
  -- Qtde parametrizada de Jobs
  vr_qtdjobs       number;
  -- Job name dos processos criados
  vr_jobname       varchar2(30);
  -- Bloco PLSQL para chamar a execução paralela do pc_crps750
  vr_dsplsql       varchar2(4000);
  --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
  vr_idcontrole    tbgen_batch_controle.idcontrole%TYPE;
  vr_idlog_ini_ger tbgen_prglog.idprglog%type := null;
  vr_idlog_ini_par tbgen_prglog.idprglog%type := null;
  vr_tpexecucao    tbgen_prglog.tpexecucao%type;
  vr_qterro        number := 0;
  vr_inproces      crapdat.inproces%type;
  vr_dtmvtolt      crapdat.dtmvtolt%type;
  ------------------------
  -- Ligeirinho - fim.
  ------------------------
  -- Calcula o valor da parcela em atraso
  PROCEDURE pc_calc_atraso_parcela(pr_dtmvtolt in crapdat.dtmvtolt%type,--> Data atual do sistema
                                   pr_cdcooper in crapepr.cdcooper%type,--> Cooperativa conectada
                                   pr_nrdconta in crapepr.nrdconta%type,--> Número da conta
                                   pr_nrctremp in crapepr.nrctremp%type,--> Número do contrato de empréstimo
                                   pr_nrparepr in crappep.nrparepr%type,--> Parcela
                                   pr_dtdpagto in crapepr.dtdpagto%type,--> Data de pagamento
                                   pr_txmensal in crapepr.txmensal%type,--> Taxa mensal
                                   pr_dtultpag in crappep.dtultpag%type,--> Data do último pagamento
                                   pr_dtvencto in crappep.dtvencto%type,--> Data de vencimento da parcela
                                   pr_vlsdvpar in crappep.vlsdvpar%type,--> Saldo devedor da parcela
                                   pr_vlsdvsji in crappep.vlsdvsji%type,--> Valor do Juros
                                   pr_vlparepr in crappep.vlparepr%type,--> Numero da Parcela
                                   pr_vlpagmta in crappep.vlpagmta%type,-->
                                   pr_vlpagmra in crappep.vlpagmra%type,--> Valor Pago no Juros de Mora
                                   pr_perjurmo in craplcr.perjurmo%type,--> Percentual de Juros de Mora
                                   pr_percmult in NUMBER, --> Percentual de juros de multa
                                   pr_nrdiatol in INTEGER, --> Prazo para tolerancia da multa
                                   pr_vlatupar out NUMBER, --> Valor atual da parcela
                                   pr_vlmrapar out crappep.vlmrapar%type, --> Valor de mora
                                   pr_vlmtapar out crappep.vlmtapar%type) IS  --> Valor de multa

  BEGIN
    DECLARE
      CURSOR cr_craplem_his (pr_cdcooper craplem.cdcooper%type,
                             pr_nrdconta craplem.nrdconta%type,
                             pr_nrctremp craplem.nrctremp%type,
                             pr_nrparepr craplem.nrparepr%type) is
      SELECT dtmvtolt
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.nrparepr = pr_nrparepr
         AND craplem.cdhistor in (1078,1620,1077,1619);
      rw_craplem cr_craplem_his%ROWTYPE;

      vr_dtmvtolt DATE;    --> Data de pagamento
      vr_diavtolt INTEGER; --> Dia do pagamento
      vr_mesvtolt INTEGER; --> Mes do pagamento
      vr_anovtolt INTEGER; --> Ano do pagamento
      vr_qtdianor INTEGER; --> Qtde de dias passados da data do vcto
      vr_qtdiasld INTEGER; --> Qtde de dias de atraso
      vr_qtdiamor NUMBER;  --> Qtde de dias entre a data atual e a calculada
      vr_percmult NUMBER;  --> % de multa para o calculo
      vr_txdiaria NUMBER(18,10); --> Taxa para calculo de mora
      vr_vljinpar crappep.vlsdvatu%type; -- 10 decimais

    BEGIN
      -- Se ainda nao pagou nada da parcela, pegar a data de vencimento dela
      IF pr_dtultpag IS NULL OR pr_dtultpag < pr_dtvencto  THEN
        vr_dtmvtolt := pr_dtvencto;
      ELSE
        -- Senao pegar a ultima data que pagou a parcela
        vr_dtmvtolt := pr_dtultpag;
      END IF;
      -- Dividir a data em dia/mes/ano para utilização da rotina dia360
      vr_diavtolt := to_number(to_char(pr_dtmvtolt, 'dd'));
      vr_mesvtolt := to_number(to_char(pr_dtmvtolt, 'mm'));
      vr_anovtolt := to_number(to_char(pr_dtmvtolt, 'yyyy'));
      -- Calcular quantidade de dias para o saldo devedor
      empr0001.pc_calc_dias360(pr_ehmensal => false,
                               pr_dtdpagto => to_number(to_char(pr_dtdpagto, 'dd')),
                               pr_diarefju => to_number(to_char(vr_dtmvtolt, 'dd')),
                               pr_mesrefju => to_number(to_char(vr_dtmvtolt, 'mm')),
                               pr_anorefju => to_number(to_char(vr_dtmvtolt, 'yyyy')),
                               pr_diafinal => vr_diavtolt,
                               pr_mesfinal => vr_mesvtolt,
                               pr_anofinal => vr_anovtolt,
                               pr_qtdedias => vr_qtdiasld);

      /* Calcula quantos dias passaram do vencimento até o parametro par_dtmvtolt
         será usado para comparar se a quantidade de dias que passou está dentro
         da tolerância */
      vr_qtdianor := pr_dtmvtolt - pr_dtvencto;
      -- Se já houve pagamento
      IF pr_dtultpag IS NOT NULL OR pr_vlpagmra > 0 THEN
        /* Obter ultimo lancamento de juro do contrato */
        FOR rw_craplem IN cr_craplem_his(pr_cdcooper => pr_cdcooper,
                                         pr_nrdconta => pr_nrdconta,
                                         pr_nrctremp => pr_nrctremp,
                                         pr_nrparepr => pr_nrparepr) LOOP

          IF rw_craplem.dtmvtolt > vr_dtmvtolt OR vr_dtmvtolt IS NULL THEN
            vr_dtmvtolt := rw_craplem.dtmvtolt;
          END IF;

        END LOOP; /* END FOR rw_craplem */

      END IF;

      /* Calcular quantidade de dias para o juros de mora desde
         o ultima ocorrência de juros de mora/vencimento até o par_dtmvtolt */
      vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;

      -- Se a quantidade de dias está dentro da tolerancia
      IF vr_qtdianor <= pr_nrdiatol THEN
        -- Zerar a multa
        vr_percmult := 0;
      ELSE
        -- Multa recebe o valor passado como parametro
        vr_percmult := pr_percmult;
      END IF;

      -- Calcular o valor da multa, descontando o que já foi calculado para a parcela
      pr_vlmtapar := ROUND((pr_vlparepr * vr_percmult / 100),2) - pr_vlpagmta;

      -- Considerando valor da parcela
      empr0001.pc_calc_juros_normais_total(pr_vlpagpar => pr_vlsdvpar,
                                           pr_txmensal => pr_txmensal,
                                           pr_qtdiajur => vr_qtdiasld,
                                           pr_vljinpar => vr_vljinpar);
      -- Valor atual parcela
      pr_vlatupar := pr_vlsdvpar + vr_vljinpar;

      /* Verifica se esta na tolerancia dos juros de mora,
         aux_qtdianor é quantidade de dias que passaram
         par_nrdiatol é quantidade de dias de tolerância parametrizada */
      IF vr_qtdianor <= pr_nrdiatol THEN
        -- Zerar o percentual de mora
        pr_vlmrapar := 0;
      ELSE
        -- TAxa de mora recebe o valor da linha de crédito
        vr_txdiaria := ROUND( (100 * (POWER ((pr_perjurmo  / 100) + 1 , (1 / 30)) - 1)), 10);
        -- Dividimos por 100
        vr_txdiaria := vr_txdiaria / 100;
        -- Valor de juros de mora é relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
        pr_vlmrapar := pr_vlsdvsji * vr_txdiaria * vr_qtdiamor;
      END IF;

    END;

  END pc_calc_atraso_parcela;

  -- Procedure para calcular valor antecipado de parcelas de empréstimo
  PROCEDURE pc_calc_antecipa_parcela(pr_dtvencto IN crappep.dtvencto%TYPE, --> Data do vencimento
                                     pr_vlsdvpar IN crappep.vlsdvpar%TYPE, --> Valor devido parcela
                                     pr_txmensal IN crapepr.txmensal%TYPE, --> Taxa aplicada ao empréstimo
                                     pr_dtmvtolt IN crapdat.dtmvtolt%TYPE, --> Data do movimento atual
                                     pr_dtdpagto IN crapepr.dtdpagto%TYPE, --> Data de Pagamento
                                     pr_vlatupar OUT crappep.vlsdvpar%TYPE, --> Valor atualizado da parcela
                                     pr_vldespar OUT crappep.vlsdvpar%TYPE) IS --> Valor desconto da parcela
  BEGIN
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipação
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
    BEGIN

      vr_diavenct := to_number(to_char(pr_dtvencto, 'dd'));
      vr_mesvenct := to_number(to_char(pr_dtvencto, 'mm'));
      vr_anovenct := to_number(to_char(pr_dtvencto, 'yyyy'));
      -- Calcula a quantidade de dias de antecipação
      empr0001.pc_calc_dias360(pr_ehmensal => false,
                               pr_dtdpagto => to_number(to_char(pr_dtdpagto, 'dd')),
                               pr_diarefju => to_number(to_char(pr_dtmvtolt, 'dd')),
                               pr_mesrefju => to_number(to_char(pr_dtmvtolt, 'mm')),
                               pr_anorefju => to_number(to_char(pr_dtmvtolt, 'yyyy')),
                               pr_diafinal => vr_diavenct,
                               pr_mesfinal => vr_mesvenct,
                               pr_anofinal => vr_anovenct,
                               pr_qtdedias => vr_ndiasant);
      -- Calculo do valor atualizado na parcela
      pr_vlatupar := round(pr_vlsdvpar * power(1 + (pr_txmensal / 100), (vr_ndiasant / 30 * -1)), 2);
      -- Valor do desconto é igual ao valor devido - valor atualizado
      pr_vldespar := pr_vlsdvpar - pr_vlatupar;

    END;

  END pc_calc_antecipa_parcela;
-------------------------------------------------------------------------------
begin

  -- Nome do programa
  vr_cdprogra := 'CRPS616';

  --

  --

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS616',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;

  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    else
      -- Atribuir o indicador de processo
      vr_inproces := rw_crapdat.inproces;
      vr_dtmvtolt := rw_crapdat.dtmvtolt;
    end if;
  close btch0001.cr_crapdat;

  -- Obter o % de multa da CECRED - TAB090
  OPEN cr_craptab(pr_cdcooper => 3 -- Fixo 3 - Cecred
                 ,pr_nmsistem => 'CRED'
                 ,pr_tptabela => 'USUARI'
                 ,pr_cdempres => 11
                 ,pr_cdacesso => 'PAREMPCTL'
                 ,pr_tpregist => 01);
  FETCH cr_craptab INTO rw_craptab;
  -- Se não encontrar
  IF cr_craptab%NOTFOUND THEN
     -- Fechar o cursor pois teremos raise
     CLOSE cr_craptab;
     -- Gerar erro com critica 55
     vr_cdcritic := 55;
     vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
     RAISE vr_exc_saida;
  ELSE
     -- Fecha o cursor para continuar o processo
     CLOSE cr_craptab;
  END IF;

  vr_percmultab := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));

  -- Carregar tabela memoria linhas de credito
  FOR rw_craplcr IN cr_craplcr (pr_cdcooper => pr_cdcooper) LOOP
    vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
    vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
  END LOOP;

  -- Carregar tabela memoria total pago no mes
  FOR rw_craplem IN cr_craplem_carga (pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                      pr_cdagenci => pr_cdagenci) LOOP
    --Montar Indice craplem
    vr_index_craplem := lpad(rw_craplem.nrdconta,10,'0')||lpad(rw_craplem.nrctremp,10,'0');
    vr_tab_craplem(vr_index_craplem):= rw_craplem.vllanmto;
  END LOOP;

  -- Ligeirinho - inicio:

  -- Buscar quantidade parametrizada de Jobs
  vr_qtdjobs := gene0001.fn_retorna_qt_paralelo( pr_cdcooper --pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                               , vr_cdprogra --pr_cdprogra  IN crapprg.cdprogra%TYPE    --> Código do programa
                                               );

  /* Paralelismo visando performance Rodar Somente no processo Noturno */
  if vr_inproces         > 2 and
     vr_qtdjobs          > 0 and
     pr_cdagenci         = 0 then

    -- Gerar o ID para o paralelismo
    vr_idparale := gene0001.fn_gera_ID_paralelo;

    -- Se houver algum erro, o id vira zerado
    IF vr_idparale = 0 THEN
       -- Levantar exceção
       vr_dscritic := 'ID zerado na chamada a rotina gene0001.fn_gera_ID_paral.';
       RAISE vr_exc_saida;
    END IF;

    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I',
                    pr_cdprograma => vr_cdprogra,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_ger);

    -- Verifica se algum job paralelo executou com erro
    vr_qterro := 0;

    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);
/*
    if vr_qterro > 0 then
      vr_cdcritic := 0;
      vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
      raise vr_exc_saida;
    end if;
*/
    -- Leitura das agências que possuem empréstimos pré-fixados e não liquidados
    for rw_crapepr_agenci in cr_crapepr_agenci (pr_cdcooper => pr_cdcooper
                                               ,pr_cdagenci => pr_cdagenci
                                               ,pr_dtmvtolt => vr_dtmvtolt
                                               ,pr_cdprogra => vr_cdprogra
                                               ,pr_qterro   => vr_qterro ) loop

      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := vr_cdprogra ||'_'|| rw_crapepr_agenci.cdagenci || '$';

      -- Cadastra o programa paralelo
      gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                ,pr_idprogra => LPAD(rw_crapepr_agenci.cdagenci,3,'0') --> Utiliza a agência como id programa
                                ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Montar o bloco PLSQL que será executado
      -- Ou seja, executaremos a geração dos dados
      -- para a agência atual atraves de Job no banco
      vr_dsplsql := 'DECLARE' || chr(13) || --
                    '  wpr_stprogra NUMBER;' || chr(13) || --
                    '  wpr_infimsol NUMBER;' || chr(13) || --
                    '  wpr_cdcritic NUMBER;' || chr(13) || --
                    '  wpr_dscritic VARCHAR2(1500);' || chr(13) || --
                    'BEGIN' || chr(13) || --
                    '  pc_crps616( '|| pr_cdcooper || ',' ||
                                       rw_crapepr_agenci.cdagenci || ',' ||
                                       vr_idparale || ',' ||
                                       'null' || ',' ||
                                       ' wpr_stprogra, wpr_infimsol, wpr_cdcritic, wpr_dscritic);' ||
                    chr(13) || --
                    'END;'; --

      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                           ,pr_cdprogra => vr_cdprogra  --> Código do programa
                           ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                           ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                           ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                           ,pr_jobname  => vr_jobname   --> Nome randomico criado
                           ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

      -- Grava LOG de ocorrência inicial do cursor cr_crapepr
      pc_log_programa(PR_DSTIPLOG           => 'O',
                      PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 4,
                      pr_dsmensagem         => 'Aguarda paralelo. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces||' pr_idparale => '||vr_idparale||' pr_qtdproce => '||vr_qtdjobs ,
                      PR_IDPRGLOG           => vr_idlog_ini_ger);

      -- Chama rotina que irá pausar este processo controlador
      -- caso tenhamos excedido a quantidade de JOBS em execuçao
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                               ,pr_qtdproce => vr_qtdjobs --> Máximo de 10 jobs neste processo
                               ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      if  vr_dscritic is not null then
        -- Levantar exceçao
        raise vr_exc_saida;
      end if;

    end loop; --  rw_crapepr_agenci

    --dbms_output.put_line('Inicio pc_aguarda_paralelo GERAL - '||to_char(sysdate,'hh24:mi:ss'));

    -- Chama rotina de aguardo agora passando 0, para esperarmos
    -- até que todos os Jobs tenha finalizado seu processamento
    gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                ,pr_qtdproce => 0
                                ,pr_des_erro => vr_dscritic);

    -- Testar saida com erro
    if  vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    -- Verifica se algum job executou com erro
    vr_qterro := gene0001.fn_ret_qt_erro_paralelo(pr_cdcooper    => pr_cdcooper,
                                                  pr_cdprogra    => vr_cdprogra,
                                                  pr_dtmvtolt    => rw_crapdat.dtmvtolt,
                                                  pr_tpagrupador => 1,
                                                  pr_nrexecucao  => 1);
    if vr_qterro > 0 then
      vr_cdcritic := 0;
      vr_dscritic := 'Paralelismo possui job executado com erro. Verificar na tabela tbgen_batch_controle e tbgen_prglog';
      raise vr_exc_saida;
    end if;

  else

    if pr_cdagenci <> 0 then
      vr_tpexecucao := 2;
    else
      vr_tpexecucao := 1;
    end if;

    -- Grava controle de batch por agência
    gene0001.pc_grava_batch_controle(pr_cdcooper    => pr_cdcooper               -- Codigo da Cooperativa
                                    ,pr_cdprogra    => vr_cdprogra               -- Codigo do Programa
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt       -- Data de Movimento
                                    ,pr_tpagrupador => 1                         -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                    ,pr_cdagrupador => pr_cdagenci               -- Codigo do agrupador conforme (tpagrupador)
                                    ,pr_cdrestart   => null                      -- Controle do registro de restart em caso de erro na execucao
                                    ,pr_nrexecucao  => 1                         -- Numero de identificacao da execucao do programa
                                    ,pr_idcontrole  => vr_idcontrole             -- ID de Controle
                                    ,pr_cdcritic    => pr_cdcritic               -- Codigo da critica
                                    ,pr_dscritic    => vr_dscritic);
    -- Testar saida com erro
    if  vr_dscritic is not null then
      -- Levantar exceçao
      raise vr_exc_saida;
    end if;

    --Grava LOG sobre o ínicio da execução da procedure na tabela tbgen_prglog
    pc_log_programa(pr_dstiplog   => 'I',
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par);

    -- Grava LOG de ocorrência inicial do cursor cr_crapepr
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Início - cursor cr_crapepr. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini_par);

    -- Ligeirinho - fim.
/*
    if pr_cdagenci in (1,2) then
       vr_dscritic := 'teste forçando agência 1 e 2 - restast.';
       raise vr_exc_saida;
    end if;
*/     
    -- Leitura dos empréstimos pré-fixados e não liquidados
    for rw_crapepr in cr_crapepr (pr_cdcooper
                                 ,pr_cdagenci) loop
      vr_cdcritic := 0;
      vr_vlsdevat := 0;
      vr_vlpreapg := 0;
      vr_vlprepag := 0;
      vr_vlsdvctr := 0;
      vr_vlatupar := 0;
      vr_fldtpgto := false;
      vr_flgtrans := false;
      vr_nrdiatol := nvl(rw_crapepr.qttolatr,0);
      -- Atualização do saldo das parcelas de todos os contratos de empréstimo
      begin
        -- Leitura das informações complementares do empréstimo
        open cr_crawepr (rw_crapepr.cdcooper,
                 rw_crapepr.nrdconta,
                 rw_crapepr.nrctremp);
        fetch cr_crawepr into rw_crawepr;
        if cr_crawepr%notfound then
          close cr_crawepr;
          vr_cdcritic := 535;
          raise leave_busca;
        end if;
        close cr_crawepr;

        -- Buscar informações da linha de crédito
        IF vr_tab_craplcr.EXISTS(rw_crapepr.cdlcremp) THEN
          rw_craplcr.perjurmo := vr_tab_craplcr(rw_crapepr.cdlcremp).perjurmo;
          rw_craplcr.flgcobmu := vr_tab_craplcr(rw_crapepr.cdlcremp).flgcobmu;
        ELSE
          -- Gerar erro
          vr_cdcritic := 535;
          RAISE leave_busca;
        END IF;

        -- Verifica se Cobra Multa
        IF rw_craplcr.flgcobmu = 1 THEN
          -- Utilizar como % de multa, as 6 primeiras posições encontradas
          vr_percmultab_calc := vr_percmultab;
        ELSE
          vr_percmultab_calc := 0;
        END IF;

        -- Leitura das parcelas em aberto
        for rw_crappep in cr_crappep (rw_crapepr.cdcooper,
                      rw_crapepr.nrdconta,
                      rw_crapepr.nrctremp) loop
          vr_vlmrapar := 0;
          vr_vlmtapar := 0;

          if rw_crapdat.dtmvtolt <= rw_crawepr.dtlibera then
            -- Nao liberado
            vr_vlatupar := rw_crapepr.vlemprst / rw_crapepr.qtpreemp;
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

          elsif rw_crappep.dtvencto >  rw_crapdat.dtmvtoan and
              rw_crappep.dtvencto <= rw_crapdat.dtmvtolt then
            -- Parcela em dia
            vr_vlatupar := rw_crappep.vlsdvpar;
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;
            /* A regularizar */
            vr_vlpreapg := vr_vlpreapg + vr_vlatupar;

          elsif rw_crappep.dtvencto < rw_crapdat.dtmvtolt then
            -- Calculo do valor da parcela em atraso
            pc_calc_atraso_parcela(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                       pr_cdcooper => rw_crapepr.cdcooper,
                       pr_nrdconta => rw_crapepr.nrdconta,
                       pr_nrctremp => rw_crapepr.nrctremp,
                       pr_nrparepr => rw_crappep.nrparepr,
                       pr_dtdpagto => rw_crapepr.dtdpagto,
                       pr_txmensal => rw_crapepr.txmensal,
                       pr_dtultpag => rw_crappep.dtultpag,
                       pr_dtvencto => rw_crappep.dtvencto,
                       pr_vlsdvpar => rw_crappep.vlsdvpar,
                       pr_vlsdvsji => rw_crappep.vlsdvsji,
                       pr_vlparepr => rw_crappep.vlparepr,
                       pr_vlpagmta => rw_crappep.vlpagmta,
                       pr_vlpagmra => rw_crappep.vlpagmra,
                       pr_perjurmo => rw_craplcr.perjurmo,
                       pr_percmult => vr_percmultab_calc,
                       pr_nrdiatol => vr_nrdiatol,
                       pr_vlatupar => vr_vlatupar,
                       pr_vlmrapar => vr_vlmrapar,
                       pr_vlmtapar => vr_vlmtapar);

            -- Regularizar
            vr_vlpreapg := vr_vlpreapg + vr_vlatupar;
            -- Saldo Contratado
            vr_vlsdvctr := vr_vlsdvctr + vr_vlatupar;

          elsif rw_crappep.dtvencto > rw_crapdat.dtmvtolt then
            -- Parcela a Vencer
            -- Procedure para calcular valor antecipado de parcelas de empréstimo
            pc_calc_antecipa_parcela(pr_dtvencto => rw_crappep.dtvencto,
                         pr_vlsdvpar => rw_crappep.vlsdvpar,
                         pr_txmensal => rw_crapepr.txmensal,
                         pr_dtmvtolt => rw_crapdat.dtmvtolt,
                         pr_dtdpagto => rw_crapepr.dtdpagto,
                         pr_vlatupar => vr_vlatupar,
                         pr_vldespar => vr_vldespar);

            -- Saldo Contratado
            vr_vlsdvctr := vr_vlsdvctr + rw_crappep.vlsdvpar;

          end if;

          if not vr_fldtpgto then
            -- Armazena a data de pagamento da primeira parcela
            vr_dtdpagto := rw_crappep.dtvencto;
            vr_fldtpgto := true;
          end if;

          /* Se liberado */
          IF NOT rw_crapdat.dtmvtolt <= rw_crawepr.dtlibera THEN
            vr_vlsdevat := vr_vlsdevat + vr_vlatupar;
          END IF;

          -- atualiza_valores_crappep
          vr_index:= vr_tab_crappep.count+1;
          vr_tab_crappep(vr_index).vlsdvatu:= vr_vlatupar;
          vr_tab_crappep(vr_index).vljura60:= 0;
          vr_tab_crappep(vr_index).vlmrapar:= vr_vlmrapar;
          vr_tab_crappep(vr_index).vlmtapar:= vr_vlmtapar;
          vr_tab_crappep(vr_index).vr_rowid:= rw_crappep.rowid;
        end loop; -- rw_crappep

        -- Montar Indice Lancamentos
        vr_index_craplem := lpad(rw_crapepr.nrdconta,10,'0')||lpad(rw_crapepr.nrctremp,10,'0');

        IF vr_tab_craplem.EXISTS(vr_index_craplem) THEN
          vr_vlprepag := NVL(vr_vlprepag,0) + NVL(vr_tab_craplem(vr_index_craplem),0);
        END IF;

        -- Vamos verificar se o emprestimo jah foi liberado
        IF rw_crapdat.dtmvtolt <= rw_crawepr.dtlibera THEN
          -- Valor do saldo contratado
          vr_vlsdvctr := rw_crapepr.vlemprst;
          -- Saldo devedor
          vr_vlsdevat := rw_crapepr.vlemprst;
          -- Valor a regularizar
          vr_vlpreapg := 0;
        END IF;

        -- Verificar se os meses decorrentes esta negativo
        vr_qtmesdec := rw_crapepr.qtmesdec;
        IF vr_qtmesdec < 0 THEN
          vr_qtmesdec := 0;
        END IF;

        -- Alterar data de pagamento do empréstimo
        vr_index:= vr_tab_crapepr.count+1;
        vr_tab_crapepr(vr_index).dtdpagto:= vr_dtdpagto;
        vr_tab_crapepr(vr_index).vlsdvctr:= vr_vlsdvctr;
        vr_tab_crapepr(vr_index).qtlcalat:= 0;
        vr_tab_crapepr(vr_index).qtpcalat:= rw_crapepr.qtprecal;
        vr_tab_crapepr(vr_index).vlsdevat:= vr_vlsdevat;
        vr_tab_crapepr(vr_index).vlpapgat:= vr_vlpreapg;
        vr_tab_crapepr(vr_index).vlppagat:= vr_vlprepag;
        vr_tab_crapepr(vr_index).qtmdecat:= vr_qtmesdec;
        vr_tab_crapepr(vr_index).vr_rowid:= rw_crapepr.rowid;

        vr_flgtrans := true;
      exception
        when leave_busca then
          rollback;
      end;
      -- Se houve erro na atualização do contrato, aborta a execução
      if not vr_flgtrans and vr_cdcritic > 0 then
        raise vr_exc_saida;
      end if;
    end loop; --rw_crapepr

    -- Grava LOG de ocorrência final do cursor cr_craprpp
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => 'Fim - cursor cr_crapepr. AGENCIA: '||pr_cdagenci||' - INPROCES: '||vr_inproces,
                    PR_IDPRGLOG           => vr_idlog_ini_par);

    -- Atualizar Parcela Emprestimo
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => ' Atualizar Parcela Emprestimo. '||'vr_tab_crappep='||vr_tab_crappep.count,
                    PR_IDPRGLOG           => vr_idlog_ini_par);
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crappep SAVE EXCEPTIONS
        update crappep
           set vlsdvatu = vr_tab_crappep(idx).vlsdvatu,
               vljura60 = vr_tab_crappep(idx).vljura60,
               vlmrapar = vr_tab_crappep(idx).vlmrapar,
               vlmtapar = vr_tab_crappep(idx).vlmtapar
        where rowid = vr_tab_crappep(idx).vr_rowid;
    EXCEPTION
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crappep: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        raise vr_exc_saida;
    END;

    -- Atualizar Emprestimo
    pc_log_programa(PR_DSTIPLOG           => 'O',
                    PR_CDPROGRAMA         => vr_cdprogra ||'_'|| pr_cdagenci || '$',
                    pr_cdcooper           => pr_cdcooper,
                    pr_tpexecucao         => vr_tpexecucao,   -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_tpocorrencia       => 4,
                    pr_dsmensagem         => ' Atualizar Emprestimo. '||'vr_tab_crapepr='||vr_tab_crapepr.count,
                    PR_IDPRGLOG           => vr_idlog_ini_par);
    BEGIN
      FORALL idx IN INDICES OF vr_tab_crapepr SAVE EXCEPTIONS
        update crapepr
           set dtdpagto = vr_tab_crapepr(idx).dtdpagto,
               vlsdvctr = vr_tab_crapepr(idx).vlsdvctr,
               qtlcalat = vr_tab_crapepr(idx).qtlcalat,
               qtpcalat = vr_tab_crapepr(idx).qtpcalat,
               vlsdevat = vr_tab_crapepr(idx).vlsdevat,
               vlpapgat = vr_tab_crapepr(idx).vlpapgat,
               vlppagat = vr_tab_crapepr(idx).vlppagat,
               qtmdecat = vr_tab_crapepr(idx).qtmdecat
        where rowid = vr_tab_crapepr(idx).vr_rowid;
    EXCEPTION
      when others then
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar crapepr: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
        raise vr_exc_saida;
    END;

    --Grava data fim para o JOB na tabela de LOG
    pc_log_programa(pr_dstiplog   => 'F',
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par,
                    pr_flgsucesso => 1);

  end if; -- Ligeirinho.

  if pr_idparale = 0 then

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
              ,pr_cdprogra => vr_cdprogra
              ,pr_infimsol => pr_infimsol
              ,pr_stprogra => pr_stprogra);

    if vr_idcontrole <> 0 then
    -- Atualiza finalização do batch na tabela de controle
    gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                    ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                    ,pr_dscritic   => vr_dscritic);
    end if;

    if vr_inproces > 2 then
      --Grava LOG sobre o fim da execução da procedure na tabela tbgen_prglog
      pc_log_programa(pr_dstiplog   => 'F',
             pr_cdprograma => vr_cdprogra,
             pr_cdcooper   => pr_cdcooper,
             pr_tpexecucao => 1,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
             pr_idprglog   => vr_idlog_ini_ger,
             pr_flgsucesso => 1);
    end if;

    --Salvar informacoes no banco de dados
    COMMIT;

  else
    -- Atualiza finalização do batch na tabela de controle
    gene0001.pc_finaliza_batch_controle(pr_idcontrole => vr_idcontrole   --ID de Controle
                    ,pr_cdcritic   => pr_cdcritic     --Codigo da critica
                    ,pr_dscritic   => vr_dscritic);

    -- Encerrar o job do processamento paralelo dessa agência
    gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                 ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                 ,pr_des_erro => vr_dscritic);

    --Salvar informacoes no banco de dados
    commit;

  end if;

exception
  when vr_exc_fimprg then

    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;

    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;

    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    --Grava data fim para o JOB na tabela de LOG - Ligeirinho
    pc_log_programa(pr_dstiplog   => 'F',
                    pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                    pr_cdcooper   => pr_cdcooper,
                    pr_tpexecucao => vr_tpexecucao, -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                    pr_idprglog   => vr_idlog_ini_par,
                    pr_flgsucesso => 1);
                    
    if nvl(pr_idparale,0) <> 0 then
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 3,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 0);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if;

    -- Efetuar commit pois gravaremos o que foi processo até então
    commit;

  when vr_exc_saida then

    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;

    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    
    if nvl(pr_idparale,0) <> 0 then
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 3,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 0);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if;
    
    -- Efetuar rollback
    rollback;

  when others then

    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;

    if nvl(pr_idparale,0) <> 0 then
      -- Grava LOG de ocorrência final da procedure apli0001.pc_calc_poupanca
      pc_log_programa(PR_DSTIPLOG           => 'E',
                      PR_CDPROGRAMA         => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper           => pr_cdcooper,
                      pr_tpexecucao         => vr_tpexecucao,    -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_tpocorrencia       => 3,
                      pr_dsmensagem         => 'pr_cdcritic:'||pr_cdcritic||CHR(13)||
                                               'pr_dscritic:'||pr_dscritic,
                      PR_IDPRGLOG           => vr_idlog_ini_par);

      --Grava data fim para o JOB na tabela de LOG
      pc_log_programa(pr_dstiplog   => 'F',
                      pr_cdprograma => vr_cdprogra||'_'||pr_cdagenci,
                      pr_cdcooper   => pr_cdcooper,
                      pr_tpexecucao => vr_tpexecucao,          -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                      pr_idprglog   => vr_idlog_ini_par,
                      pr_flgsucesso => 0);

      -- Encerrar o job do processamento paralelo dessa agência
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
    end if;

    -- Efetuar rollback
    rollback;

end;
