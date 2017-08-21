create or replace procedure cecred.pc_crps616_new(pr_cdcooper  in craptab.cdcooper%type,
                                                  pr_flgresta  in pls_integer,            --> Flag padr�o para utiliza��o de restart
                                                  pr_stprogra out pls_integer,            --> Sa�da de termino da execu��o
                                                  pr_infimsol out pls_integer,            --> Sa�da de termino da solicita��o,
                                                  pr_cdcritic out crapcri.cdcritic%type,
                                                  pr_dscritic out varchar2) as
/* ............................................................................

   Programa: pc_crps616 (Antigo Fontes/crps616.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2012                       Ultima atualizacao: 18/08/2017

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Atualizar saldo das parcelas de todos os contratos de emprestimo

   Alteracoes: 15/01/2013 - Atualizar o campo crapepr.dtdpagto com a data da
                            primeira parcela nao liquidada.
                           (David Kruger).

               12/07/2013 - Ajuste na gravacao de juros + 60 (Gabriel).

               06/12/2013 - Ajuste para melhorar a performance (James).

               24/01/2014 - Convers�o Progress >> Oracle PL/SQL (Daniel - Supero).

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
                            utilizado temp-table para selecionar o valor j� pago dos emprestimos.
                            A atualiza��o das tabelas crapepr e crappep ocorre com o comando forall.
                            (Alisson - AMcom)
                            
               02/04/2015 - Ajuste na procedure pc_calc_atraso_parcela para verificar os historicos
                            de emprestimo e financiamento. (James)
                            
               21/05/2015 - Ajuste para verificar se Cobra Multa. (James)    
               
               09/10/2015 - Incluir hist�ricos de estorno. (Oscar)
               
               23/02/2017 - Altera��es para ganho de performance: (Rodrigo)
               
               18/08/2017 - #696286 Programa pc_crps616_new com as melhorias de performance, por�m com 
                            rollback no lugar do commit e exporta��o da crapepr; chamado pelo programa 
                            crpN616.p, que est� cadastrado na crapprg apenas para a Altovale (Carlos)
               
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

  -- Cursor gen�rico de parametriza��o
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

  -- Buscar os empr�stimos pr�-fixados e ainda n�o liquidados
  cursor cr_crapepr (pr_cdcooper in crapepr.cdcooper%type) is
    select /*+ PARALLEL (crapepr) */ crapepr.cdcooper,
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
     where crapepr.cdcooper = pr_cdcooper
       and crapepr.tpemprst = 1
       and crapepr.inliquid = 0;
       

  -- Buscar informa��es complementares do empr�stimo
  cursor cr_crawepr (pr_cdcooper in crawepr.cdcooper%TYPE) is
    select /*+ PARALLEL (crawepr) */ 
           crawepr.nrdconta,
           crawepr.nrctremp,
           crawepr.dtlibera
      from crawepr
     where crawepr.cdcooper = pr_cdcooper
       and crawepr.tpemprst = 1;
     
  -- Busca das linhas de cr�dito
  CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
    SELECT craplcr.perjurmo
          ,craplcr.cdlcremp
          ,craplcr.flgcobmu
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper;
  rw_craplcr cr_craplcr%ROWTYPE;

  -- Buscar o ultimo lan�amento de juros
  CURSOR cr_craplem_carga (pr_cdcooper IN craplem.cdcooper%type,
                           pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
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
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.nrdolote in (600012,600013,600031)
       AND craplem.cdhistor in (1044,1045,1039,1057,1716,1707,1714,1705)
       AND craplem.dtmvtolt between trunc(pr_dtmvtolt,'mm') and trunc(last_day(pr_dtmvtolt)) --> Mesmo ano e m�s corrente
    GROUP BY craplem.nrdconta,craplem.nrctremp;
        
  -- Buscar parcelas n�o liquidadas
  cursor cr_crappep (pr_cdcooper in crappep.cdcooper%TYPE) is
    SELECT /*+ PARALLEL (crappep) */
           crappep.cdcooper,
           crappep.nrdconta,
           crappep.nrctremp,
           crappep.nrparepr,
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
       and crappep.inliquid = 0;
  --
  
  -- Cursor global para carregar PL-Table 
  CURSOR cr_craplem_his (pr_cdcooper craplem.cdcooper%TYPE) IS
    SELECT /*+ PARALLEL (craplem) */
           nrdconta,
           nrctremp,
           nrparepr,
           dtmvtolt
      FROM craplem
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.cdhistor in (1078,1620,1077,1619)
  ORDER BY craplem.nrdconta, craplem.nrctremp, craplem.nrparepr;
  --
  
  TYPE typ_reg_craplcr IS RECORD
    (perjurmo craplcr.perjurmo%type,
     flgcobmu craplcr.flgcobmu%type);
  TYPE typ_tab_craplcr IS TABLE OF typ_reg_craplcr INDEX BY PLS_INTEGER;
  
  -- Array de Linhas Creditos
  vr_tab_craplcr typ_tab_craplcr;

  -- Estrutura para carga das tabelas com BULK COLLECT
   
  TYPE typ_craplem_bulk IS TABLE OF cr_craplem_his%ROWTYPE INDEX BY PLS_INTEGER;
  vr_craplem_bulk typ_craplem_bulk;  

  TYPE typ_reg_craplem IS RECORD
    (
     nrdconta craplem.nrdconta%TYPE,
     nrctremp craplem.nrctremp%TYPE,
     nrparepr craplem.nrparepr%TYPE,
     dtmvtolt craplem.dtmvtolt%TYPE
    );
  TYPE typ_tab_craplem_his IS TABLE OF typ_reg_craplem INDEX BY PLS_INTEGER;
  
  
  TYPE typ_crappep_bulk IS TABLE OF cr_crappep%ROWTYPE INDEX BY PLS_INTEGER;
  vr_crappep_bulk typ_crappep_bulk;  

  TYPE typ_reg_crappep IS RECORD
    (nrparepr crappep.nrparepr%type,
     dtvencto crappep.dtvencto%type,
     vlsdvpar crappep.vlsdvpar%type,
     dtultpag crappep.dtultpag%type,
     vlsdvsji crappep.vlsdvsji%type,
     vlparepr crappep.vlparepr%type,
     vlpagmta crappep.vlpagmta%type,
     vlpagmra crappep.vlpagmra%type,
     vlsdvatu crappep.vlsdvatu%type,
     vljura60 crappep.vljura60%type,
     vlmrapar crappep.vlmrapar%type,
     vlmtapar crappep.vlmtapar%type,
     vr_rowid ROWID,
     tab_craplem typ_tab_craplem_his);
  TYPE typ_tab_crappep IS TABLE OF typ_reg_crappep INDEX BY PLS_INTEGER;


  TYPE typ_crapepr_bulk IS TABLE OF cr_crapepr%ROWTYPE INDEX BY PLS_INTEGER;
  vr_crapepr_bulk typ_crapepr_bulk;    
  
  TYPE typ_reg_crapepr IS RECORD
    (cdcooper crapepr.cdcooper%TYPE,
     nrdconta crapepr.nrdconta%TYPE,
     nrctremp crapepr.nrctremp%TYPE,
     vlemprst crapepr.vlemprst%TYPE,
     qtpreemp crapepr.qtpreemp%TYPE,
     dtdpagto crapepr.dtdpagto%TYPE,
     txmensal crapepr.txmensal%TYPE,
     cdlcremp crapepr.cdlcremp%TYPE,
     qtmesdec crapepr.qtmesdec%TYPE,
     qtprecal crapepr.qtprecal%TYPE,
     qttolatr crapepr.qttolatr%TYPE,
     vr_rowid ROWID,
     tab_crappep typ_tab_crappep
    );
  TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY VARCHAR2(20);

  vr_tab_crapepr typ_tab_crapepr;

  
  TYPE typ_crawepr_bulk IS TABLE OF cr_crawepr%ROWTYPE INDEX BY PLS_INTEGER;
  vr_crawepr_bulk typ_crawepr_bulk;  

  TYPE typ_reg_crawepr IS RECORD
    (dtlibera crawepr.dtlibera%TYPE,
     nrdconta crawepr.nrdconta%TYPE,
     nrctremp crawepr.nrctremp%TYPE
    );
  TYPE typ_tab_crawepr IS TABLE OF typ_reg_crawepr INDEX BY VARCHAR2(20);
     
  vr_tab_crawepr typ_tab_crawepr;
  -- ----------------

  -- Estrutura para atualiza��o das tabelas com FORALL
  TYPE typ_reg_atu_crappep IS RECORD
    (vlsdvatu crappep.vlsdvatu%type,
     vljura60 crappep.vljura60%type,
     vlmrapar crappep.vlmrapar%type,
     vlmtapar crappep.vlmtapar%type,
     vr_rowid ROWID);
  TYPE typ_tab_atu_crappep IS TABLE OF typ_reg_atu_crappep INDEX BY PLS_INTEGER;
  vr_tab_atu_crappep typ_tab_atu_crappep;
  
   TYPE typ_reg_atu_crapepr IS RECORD
    (dtdpagto crapepr.dtdpagto%type,
     vlsdvctr crapepr.vlsdvctr%type,
     qtlcalat crapepr.qtlcalat%type,
     qtpcalat crapepr.qtpcalat%type,
     vlsdevat crapepr.vlsdevat%type,
     vlpapgat crapepr.vlpapgat%type,
     vlppagat crapepr.vlppagat%type,
     qtmdecat crapepr.qtmdecat%type,
     vr_rowid ROWID);
  TYPE typ_tab_atu_crapepr IS TABLE OF typ_reg_atu_crapepr INDEX BY PLS_INTEGER;
  vr_tab_atu_crapepr typ_tab_atu_crapepr;   
  -- ----------------

  TYPE typ_tab_craplem IS TABLE OF NUMBER INDEX BY VARCHAR2(20);
  vr_tab_craplem typ_tab_craplem;
  
  -- Indice para o Array de historicos
  rw_crapdat       btch0001.cr_crapdat%rowtype;
  -- C�digo do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);
  -- Vari�veis para auxiliar o processamento
  vr_fldtpgto      boolean;
  vr_flgtrans      boolean;
  vr_vlatupar      NUMBER(35,2); -- 10 decimais
  -- Exce��o para sair do bloco de busca em caso de erro
  leave_busca      exception;
  -- Vari�veis para auxiliar no c�lculo dos novos valores das parcelas
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
  vr_idxepr        PLS_INTEGER;
  vr_index_craplem VARCHAR2(20);
  
  -- Vari�veis carga de empr�stimos para tabela em mem�ria 
  vr_index_crapepr VARCHAR2(20);
  vr_index_crawepr VARCHAR2(20);
  vr_index_crappep PLS_INTEGER;
  vr_idx VARCHAR2(20);
  vr_idxpep PLS_INTEGER;
  
  -- Calcula o valor da parcela em atraso
  PROCEDURE pc_calc_atraso_parcela(pr_dtmvtolt in crapdat.dtmvtolt%type,--> Data atual do sistema
                                   pr_nrparepr in crappep.nrparepr%type,--> Parcela
                                   pr_dtdpagto in crapepr.dtdpagto%type,--> Data de pagamento
                                   pr_txmensal in crapepr.txmensal%type,--> Taxa mensal
                                   pr_dtultpag in crappep.dtultpag%type,--> Data do �ltimo pagamento
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
      -- Dividir a data em dia/mes/ano para utiliza��o da rotina dia360
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

      /* Calcula quantos dias passaram do vencimento at� o parametro par_dtmvtolt
         ser� usado para comparar se a quantidade de dias que passou est� dentro
         da toler�ncia */
      vr_qtdianor := pr_dtmvtolt - pr_dtvencto;
      -- Se j� houve pagamento
      IF pr_dtultpag IS NOT NULL OR pr_vlpagmra > 0 THEN        
        /* Obter ultimo lancamento de juro do contrato */
        IF vr_tab_crapepr(vr_idx).tab_crappep(pr_nrparepr).tab_craplem.COUNT > 0 THEN
          
          FOR idx IN vr_tab_crapepr(vr_idx).tab_crappep(pr_nrparepr).tab_craplem.FIRST..vr_tab_crapepr(vr_idx).tab_crappep(pr_nrparepr).tab_craplem.LAST LOOP
            IF vr_tab_crapepr(vr_idx).tab_crappep(pr_nrparepr).tab_craplem(idx).dtmvtolt > vr_dtmvtolt OR vr_dtmvtolt IS NULL THEN
              vr_dtmvtolt := vr_tab_crapepr(vr_idx).tab_crappep(pr_nrparepr).tab_craplem(idx).dtmvtolt;
            END IF;
          END LOOP;
          
        END IF;                
      END IF;

      /* Calcular quantidade de dias para o juros de mora desde a ultima 
         ocorr�ncia de juros de mora/vencimento at� o par_dtmvtolt */
      vr_qtdiamor := pr_dtmvtolt - vr_dtmvtolt;

      -- Se a quantidade de dias est� dentro da tolerancia
      IF vr_qtdianor <= pr_nrdiatol THEN
        -- Zerar a multa
        vr_percmult := 0;
      ELSE
        -- Multa recebe o valor passado como parametro
        vr_percmult := pr_percmult;
      END IF;

      -- Calcular o valor da multa, descontando o que j� foi calculado para a parcela
      pr_vlmtapar := ROUND((pr_vlparepr * vr_percmult / 100),2) - pr_vlpagmta;

      -- Considerando valor da parcela
      empr0001.pc_calc_juros_normais_total(pr_vlpagpar => pr_vlsdvpar,
                                           pr_txmensal => pr_txmensal,
                                           pr_qtdiajur => vr_qtdiasld,
                                           pr_vljinpar => vr_vljinpar);
      -- Valor atual parcela
      pr_vlatupar := pr_vlsdvpar + vr_vljinpar;

      /* Verifica se esta na tolerancia dos juros de mora,
         aux_qtdianor � quantidade de dias que passaram
         par_nrdiatol � quantidade de dias de toler�ncia parametrizada */
      IF vr_qtdianor <= pr_nrdiatol THEN
        -- Zerar o percentual de mora
        pr_vlmrapar := 0;
      ELSE
        -- TAxa de mora recebe o valor da linha de cr�dito
        vr_txdiaria := ROUND( (100 * (POWER ((pr_perjurmo  / 100) + 1 , (1 / 30)) - 1)), 10);
        -- Dividimos por 100
        vr_txdiaria := vr_txdiaria / 100;
        -- Valor de juros de mora � relativo ao juros sem inadimplencia da parcela + taxa diaria calculada + quantidade de dias de mora
        pr_vlmrapar := pr_vlsdvsji * vr_txdiaria * vr_qtdiamor;
      END IF;

    END;

  END pc_calc_atraso_parcela;

  -- Procedure para calcular valor antecipado de parcelas de empr�stimo
  PROCEDURE pc_calc_antecipa_parcela(pr_dtvencto IN crappep.dtvencto%TYPE, --> Data do vencimento
                                     pr_vlsdvpar IN crappep.vlsdvpar%TYPE, --> Valor devido parcela
                                     pr_txmensal IN crapepr.txmensal%TYPE, --> Taxa aplicada ao empr�stimo
                                     pr_dtmvtolt IN crapdat.dtmvtolt%TYPE, --> Data do movimento atual
                                     pr_dtdpagto IN crapepr.dtdpagto%TYPE, --> Data de Pagamento
                                     pr_vlatupar OUT crappep.vlsdvpar%TYPE, --> Valor atualizado da parcela
                                     pr_vldespar OUT crappep.vlsdvpar%TYPE) IS --> Valor desconto da parcela
  BEGIN
    DECLARE
      -- variaveis auxiliares ao calculo
      vr_ndiasant INTEGER; --> Nro de dias de antecipa��o
      vr_diavenct INTEGER; --> Dia de vencimento
      vr_mesvenct INTEGER; --> Mes de vencimento
      vr_anovenct INTEGER; --> Ano de vencimento
    BEGIN

      vr_diavenct := to_number(to_char(pr_dtvencto, 'dd'));
      vr_mesvenct := to_number(to_char(pr_dtvencto, 'mm'));
      vr_anovenct := to_number(to_char(pr_dtvencto, 'yyyy'));
      -- Calcula a quantidade de dias de antecipa��o
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
      -- Valor do desconto � igual ao valor devido - valor atualizado
      pr_vldespar := pr_vlsdvpar - pr_vlatupar;

    END;

  END pc_calc_antecipa_parcela;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPN616';
  
  -- Incluir nome do m�dulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS616_NEW',
                             pr_action => vr_cdprogra);
  -- Valida��es iniciais do programa
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
    -- Verificar se existe informa��o, e gerar erro caso n�o exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exce��o
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informa��o, e gerar erro caso n�o exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exce��o
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
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
  -- Se n�o encontrar
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
                                      pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
    --Montar Indice craplem
    vr_index_craplem := lpad(rw_craplem.nrdconta,10,'0')||lpad(rw_craplem.nrctremp,10,'0');                                  
    vr_tab_craplem(vr_index_craplem):= rw_craplem.vllanmto;    
  END LOOP;                                 

  -- carrega a PLTABLE dos empr�stimos
  OPEN cr_crapepr (pr_cdcooper);

  LOOP 
    FETCH cr_crapepr BULK COLLECT INTO vr_crapepr_bulk LIMIT 100000; -- carrega de 100 em 100 mil registros

    EXIT WHEN vr_crapepr_bulk.COUNT = 0;
        
    IF vr_crapepr_bulk.COUNT > 0 THEN
      -- percorre a PLTABLE refazendo o indice com a composicao dos campos
      FOR idx IN vr_crapepr_bulk.FIRST..vr_crapepr_bulk.LAST LOOP
        -- monta o indice
        vr_index_crapepr := lpad(vr_crapepr_bulk(idx).nrdconta,10,'0')||lpad(vr_crapepr_bulk(idx).nrctremp,10,'0');

        vr_tab_crapepr(vr_index_crapepr).cdcooper := vr_crapepr_bulk(idx).cdcooper;
        vr_tab_crapepr(vr_index_crapepr).nrdconta := vr_crapepr_bulk(idx).nrdconta;
        vr_tab_crapepr(vr_index_crapepr).nrctremp := vr_crapepr_bulk(idx).nrctremp;
        vr_tab_crapepr(vr_index_crapepr).vlemprst := vr_crapepr_bulk(idx).vlemprst;
        vr_tab_crapepr(vr_index_crapepr).qtpreemp := vr_crapepr_bulk(idx).qtpreemp;
        vr_tab_crapepr(vr_index_crapepr).dtdpagto := vr_crapepr_bulk(idx).dtdpagto;
        vr_tab_crapepr(vr_index_crapepr).txmensal := vr_crapepr_bulk(idx).txmensal;
        vr_tab_crapepr(vr_index_crapepr).cdlcremp := vr_crapepr_bulk(idx).cdlcremp;
        vr_tab_crapepr(vr_index_crapepr).qtmesdec := vr_crapepr_bulk(idx).qtmesdec;
        vr_tab_crapepr(vr_index_crapepr).qtprecal := vr_crapepr_bulk(idx).qtprecal;
        vr_tab_crapepr(vr_index_crapepr).qttolatr := vr_crapepr_bulk(idx).qttolatr;
        vr_tab_crapepr(vr_index_crapepr).vr_rowid := vr_crapepr_bulk(idx).rowid;
      END LOOP;
    END IF;
        
    vr_crapepr_bulk.DELETE;
  END LOOP;
  CLOSE cr_crapepr;

  -- carrega a PLTABLE dos empr�stimos
  OPEN cr_crawepr (pr_cdcooper);

  LOOP 
    FETCH cr_crawepr BULK COLLECT INTO vr_crawepr_bulk LIMIT 100000; -- carrega de 100 em 100 mil registros

    EXIT WHEN vr_crawepr_bulk.COUNT = 0;
        
    IF vr_crawepr_bulk.COUNT > 0 THEN
      -- percorre a PLTABLE refazendo o indice com a composicao dos campos
      FOR idx IN vr_crawepr_bulk.FIRST..vr_crawepr_bulk.LAST LOOP
        -- monta o indice
        vr_index_crawepr := lpad(vr_crawepr_bulk(idx).nrdconta,10,'0')||lpad(vr_crawepr_bulk(idx).nrctremp,10,'0');

        IF vr_tab_crapepr.exists(vr_index_crawepr) THEN
          vr_tab_crawepr(vr_index_crawepr).dtlibera := vr_crawepr_bulk(idx).dtlibera;
        END IF;
      END LOOP;
    END IF;
        
    vr_crawepr_bulk.DELETE;
  END LOOP;
  CLOSE cr_crawepr;

  -- carrega a PLTABLE das presta��es de empr�stimo
  OPEN cr_crappep (pr_cdcooper);

  LOOP 
    FETCH cr_crappep BULK COLLECT INTO vr_crappep_bulk LIMIT 200000; -- carrega de 200 em 200 mil registros

    EXIT WHEN vr_crappep_bulk.COUNT = 0;
        
    IF vr_crappep_bulk.COUNT > 0 THEN
      -- percorre a PLTABLE refazendo o indice com a composicao dos campos
      FOR idx IN vr_crappep_bulk.FIRST..vr_crappep_bulk.LAST LOOP       
       
        -- monta o indice
        vr_index_crapepr := lpad(vr_crappep_bulk(idx).nrdconta,10,'0')||lpad(vr_crappep_bulk(idx).nrctremp,10,'0');
        vr_index_crappep := vr_crappep_bulk(idx).nrparepr;
                
        IF vr_tab_crapepr.exists(vr_index_crapepr) THEN
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).nrparepr := vr_crappep_bulk(idx).nrparepr;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).dtvencto := vr_crappep_bulk(idx).dtvencto;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlsdvpar := vr_crappep_bulk(idx).vlsdvpar;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).dtultpag := vr_crappep_bulk(idx).dtultpag;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlsdvsji := vr_crappep_bulk(idx).vlsdvsji;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlparepr := vr_crappep_bulk(idx).vlparepr;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlpagmta := vr_crappep_bulk(idx).vlpagmta;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlpagmra := vr_crappep_bulk(idx).vlpagmra;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vlsdvatu := vr_crappep_bulk(idx).vlsdvatu;
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).vr_rowid := vr_crappep_bulk(idx).rowid;
        END IF;        

      END LOOP;
    END IF;
        
    vr_crappep_bulk.DELETE;

  END LOOP;
  CLOSE cr_crappep;

  -- carrega a PLTABLE das presta��es de empr�stimo
  OPEN cr_craplem_his (pr_cdcooper);

  LOOP 
    FETCH cr_craplem_his BULK COLLECT INTO vr_craplem_bulk LIMIT 300000; -- carrega de 300 em 300 mil registros

    EXIT WHEN vr_craplem_bulk.COUNT = 0;
        
    IF vr_craplem_bulk.COUNT > 0 THEN
      -- percorre a PLTABLE refazendo o indice com a composicao dos campos
      FOR idx IN vr_craplem_bulk.FIRST..vr_craplem_bulk.LAST LOOP
        -- monta o indice
        vr_index_crapepr := lpad(vr_craplem_bulk(idx).nrdconta,10,'0')||lpad(vr_craplem_bulk(idx).nrctremp,10,'0');
        vr_index_crappep := vr_craplem_bulk(idx).nrparepr;
        
        IF vr_tab_crapepr.exists(vr_index_crapepr) AND 
           vr_tab_crapepr(vr_index_crapepr).tab_crappep.exists(vr_index_crappep) THEN
          vr_tab_crapepr(vr_index_crapepr).tab_crappep(vr_index_crappep).tab_craplem(idx).dtmvtolt := vr_craplem_bulk(idx).dtmvtolt;
        END IF;        

      END LOOP;
    END IF;
        
    vr_craplem_bulk.DELETE;

  END LOOP;
  CLOSE cr_craplem_his;


  -- Leitura dos empr�stimos pr�-fixados e n�o liquidados
  vr_idx := vr_tab_crapepr.FIRST;
  
  WHILE vr_idx IS NOT NULL LOOP
    -- Inicializar vari�veis
    vr_cdcritic := 0;
    vr_vlsdevat := 0;
    vr_vlpreapg := 0;
    vr_vlprepag := 0;
    vr_vlsdvctr := 0;
    vr_vlatupar := 0;
    vr_fldtpgto := false;
    vr_flgtrans := false;
    vr_nrdiatol := nvl(vr_tab_crapepr(vr_idx).qttolatr, 0);
    
    -- Atualiza��o do saldo das parcelas de todos os contratos de empr�stimo
    begin
      -- Buscar informa��es da linha de cr�dito
      IF vr_tab_craplcr.EXISTS(vr_tab_crapepr(vr_idx).cdlcremp) THEN
        rw_craplcr.perjurmo := vr_tab_craplcr(vr_tab_crapepr(vr_idx).cdlcremp).perjurmo;
        rw_craplcr.flgcobmu := vr_tab_craplcr(vr_tab_crapepr(vr_idx).cdlcremp).flgcobmu;
      ELSE  
        -- Gerar erro
        vr_cdcritic := 535;
        RAISE leave_busca;
      END IF;  
      
      -- Verifica se Cobra Multa
      IF rw_craplcr.flgcobmu = 1 THEN
        -- Utilizar como % de multa, as 6 primeiras posi��es encontradas
        vr_percmultab_calc := vr_percmultab;
      ELSE
        vr_percmultab_calc := 0;
          
      END IF;
      
      -- inicializa com a data de pagamento do epr atual
      vr_dtdpagto := vr_tab_crapepr(vr_idx).dtdpagto;

      IF vr_tab_crapepr(vr_idx).tab_crappep.COUNT = 0 THEN
        vr_idx := vr_tab_crapepr.next(vr_idx);
        CONTINUE;
      END IF;

      -- Leitura das parcelas em aberto
      FOR vr_idxpep IN vr_tab_crapepr(vr_idx).tab_crappep.FIRST..vr_tab_crapepr(vr_idx).tab_crappep.LAST LOOP
        -- Inicializar vari�veis
        vr_vlmrapar := 0;
        vr_vlmtapar := 0;

        if rw_crapdat.dtmvtolt <=  vr_tab_crawepr(vr_idx).dtlibera then
          -- Nao liberado
          vr_vlatupar := vr_tab_crapepr(vr_idx).vlemprst / vr_tab_crapepr(vr_idx).qtpreemp;
          vr_vlsdvctr := vr_vlsdvctr + vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar;

        elsif vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto >  rw_crapdat.dtmvtoan and
              vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto <= rw_crapdat.dtmvtolt then
          -- Parcela em dia
          vr_vlatupar := vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar;
          vr_vlsdvctr := vr_vlsdvctr + vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar;
          /* A regularizar */
          vr_vlpreapg := vr_vlpreapg + vr_vlatupar;

        elsif vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto < rw_crapdat.dtmvtolt then
          -- Calculo do valor da parcela em atraso
          pc_calc_atraso_parcela(pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                 pr_nrparepr => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).nrparepr,
                                 pr_dtdpagto => vr_tab_crapepr(vr_idx).dtdpagto,
                                 pr_txmensal => vr_tab_crapepr(vr_idx).txmensal,
                                 pr_dtultpag => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtultpag,
                                 pr_dtvencto => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto,
                                 pr_vlsdvpar => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar,
                                 pr_vlsdvsji => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvsji,
                                 pr_vlparepr => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlparepr,
                                 pr_vlpagmta => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlpagmta,
                                 pr_vlpagmra => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlpagmra,
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

        elsif vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto > rw_crapdat.dtmvtolt then
          -- Parcela a Vencer
          -- Procedure para calcular valor antecipado de parcelas de empr�stimo
          pc_calc_antecipa_parcela(pr_dtvencto => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto,
                                   pr_vlsdvpar => vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar,
                                   pr_txmensal => vr_tab_crapepr(vr_idx).txmensal,
                                   pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                   pr_dtdpagto => vr_tab_crapepr(vr_idx).dtdpagto,
                                   pr_vlatupar => vr_vlatupar,
                                   pr_vldespar => vr_vldespar);

          -- Saldo Contratado
          vr_vlsdvctr := vr_vlsdvctr + vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vlsdvpar;

        end if;

        if not vr_fldtpgto then
          -- Armazena a data de pagamento da primeira parcela
          vr_dtdpagto := vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).dtvencto;
          vr_fldtpgto := true;
        end if;

        /* Se liberado */
        IF NOT rw_crapdat.dtmvtolt <= vr_tab_crawepr(vr_idx).dtlibera THEN
          vr_vlsdevat := vr_vlsdevat + vr_vlatupar;
        END IF;

        -- atualiza_valores_crappep
        vr_index:= vr_tab_atu_crappep.count+1;
        vr_tab_atu_crappep(vr_index).vlsdvatu:= vr_vlatupar;
        vr_tab_atu_crappep(vr_index).vljura60:= 0;
        vr_tab_atu_crappep(vr_index).vlmrapar:= vr_vlmrapar;
        vr_tab_atu_crappep(vr_index).vlmtapar:= vr_vlmtapar;
        vr_tab_atu_crappep(vr_index).vr_rowid:= vr_tab_crapepr(vr_idx).tab_crappep(vr_idxpep).vr_rowid;
      END LOOP;

      -- Montar Indice Lancamentos
      vr_index_craplem := lpad(vr_tab_crapepr(vr_idx).nrdconta,10,'0')||lpad(vr_tab_crapepr(vr_idx).nrctremp,10,'0');
      
      IF vr_tab_craplem.EXISTS(vr_index_craplem) THEN
        vr_vlprepag := NVL(vr_vlprepag,0) + NVL(vr_tab_craplem(vr_index_craplem),0);
      END IF;  
      
      -- Vamos verificar se o emprestimo jah foi liberado
      IF rw_crapdat.dtmvtolt <= vr_tab_crawepr(vr_idx).dtlibera THEN
        -- Valor do saldo contratado
        vr_vlsdvctr := vr_tab_crapepr(vr_idx).vlemprst;
        -- Saldo devedor
        vr_vlsdevat := vr_tab_crapepr(vr_idx).vlemprst;
        -- Valor a regularizar
        vr_vlpreapg := 0;
      END IF;

      -- Verificar se os meses decorrentes esta negativo
      vr_qtmesdec := vr_tab_crapepr(vr_idx).qtmesdec;
      IF vr_qtmesdec < 0 THEN
         vr_qtmesdec := 0;
      END IF;

      -- Alterar data de pagamento do empr�stimo
      vr_idxepr := vr_tab_atu_crapepr.count+1;
      vr_tab_atu_crapepr(vr_idxepr).dtdpagto:= vr_dtdpagto;
      vr_tab_atu_crapepr(vr_idxepr).vlsdvctr:= vr_vlsdvctr;
      vr_tab_atu_crapepr(vr_idxepr).qtlcalat:= 0;
      vr_tab_atu_crapepr(vr_idxepr).qtpcalat:= vr_tab_crapepr(vr_idx).qtprecal;
      vr_tab_atu_crapepr(vr_idxepr).vlsdevat:= vr_vlsdevat;
      vr_tab_atu_crapepr(vr_idxepr).vlpapgat:= vr_vlpreapg;
      vr_tab_atu_crapepr(vr_idxepr).vlppagat:= vr_vlprepag;
      vr_tab_atu_crapepr(vr_idxepr).qtmdecat:= vr_qtmesdec;
      vr_tab_atu_crapepr(vr_idxepr).vr_rowid:= vr_tab_crapepr(vr_idx).vr_rowid;

      vr_flgtrans := true;
    exception
      when leave_busca THEN
        
        rollback;
    end;
    -- Se houve erro na atualiza��o do contrato, aborta a execu��o
    if not vr_flgtrans and vr_cdcritic > 0 then
      raise vr_exc_saida;
    END IF;
    
    vr_idx := vr_tab_crapepr.next(vr_idx);
  END LOOP; -- vr_tab_crapepr
  
  -- Atualizar Parcela Emprestimo
  BEGIN
    FORALL idx IN INDICES OF vr_tab_atu_crappep SAVE EXCEPTIONS
      update /*+ PARALLEL (crappep) */ crappep
         set vlsdvatu = vr_tab_atu_crappep(idx).vlsdvatu,
             vljura60 = vr_tab_atu_crappep(idx).vljura60,
             vlmrapar = vr_tab_atu_crappep(idx).vlmrapar,
             vlmtapar = vr_tab_atu_crappep(idx).vlmtapar
      where rowid = vr_tab_atu_crappep(idx).vr_rowid;
  EXCEPTION
    when others then
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao atualizar crappep: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
      raise vr_exc_saida;
  END;

  -- Atualizar Emprestimo
  BEGIN
    FORALL idx IN INDICES OF vr_tab_atu_crapepr SAVE EXCEPTIONS
      update /*+ PARALLEL (crapepr) */ crapepr
         set dtdpagto = vr_tab_atu_crapepr(idx).dtdpagto,
             vlsdvctr = vr_tab_atu_crapepr(idx).vlsdvctr,
             qtlcalat = vr_tab_atu_crapepr(idx).qtlcalat,
             qtpcalat = vr_tab_atu_crapepr(idx).qtpcalat,
             vlsdevat = vr_tab_atu_crapepr(idx).vlsdevat,
             vlpapgat = vr_tab_atu_crapepr(idx).vlpapgat,
             vlppagat = vr_tab_atu_crapepr(idx).vlppagat,
             qtmdecat = vr_tab_atu_crapepr(idx).qtmdecat
      where rowid = vr_tab_atu_crapepr(idx).vr_rowid;
  EXCEPTION
    when others then
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao atualizar crapepr: '||SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
      raise vr_exc_saida;
  END;
  
  -- Gravar os dados das tabelas afetadas em arquivo .csv para compara��o
  vr_cdcritic := exporta_tabela_para_csv(p_query => 'select * from crapepr where crapepr.cdcooper = 16 and crapepr.inliquid = 0 order by cdcooper,nrdconta,nrctremp',
                                         p_dir => '/micros/cecred/rodrigo/crps616/',
                                         p_arquivo => 'crapepr_16_new',
                                         p_formato_data => 'DD/MM/RRRR');

  vr_cdcritic := exporta_tabela_para_csv(p_query => 'select * from crappep where crappep.cdcooper = 16 and crappep.inliquid = 0 order by cdcooper,nrdconta,nrctremp,nrparepr',
                                         p_dir => '/micros/cecred/rodrigo/crps616/',
                                         p_arquivo => 'crappep_16_new',
                                         p_formato_data => 'DD/MM/RRRR');
  
  -----------------------------

 
  -- Finaliza a execu��o com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --Salvar Informa��es                          
--  commit;
  ROLLBACK;
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
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processado at� ent�o
--    commit;
    ROLLBACK;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas c�digo
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos c�digo e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper);
    -- Efetuar retorno do erro n�o tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
end;
/
