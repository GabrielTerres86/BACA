create or replace function cecred.fn_retorna_valores_aplicacao (pr_cdcooper IN crapadi.cdcooper%TYPE
                                                               ,pr_nrdconta IN crapadi.nrdconta%TYPE
                                                               ,pr_nrctagar IN crapadt.nrctagar%TYPE
                                                               ,pr_cdaditiv IN crapadt.cdaditiv%TYPE
                                                               ,pr_nraplica IN crapadi.nraplica%TYPE
                                                               ,pr_tpproapl IN crapadi.tpproapl%TYPE) RETURN VARCHAR2 IS

  /**********FUNCTION UTLIZADA NO BI, ANTES DE MEXER FALAR COM JULIANA, GUILHERME, GIOVANI OU VANESSA******************************************/

  -- Programa: fn_retorna_valores_aplicacao
  -- Sistema : Conta-Corrente - Cooperativa de Credito
  -- Sigla   : CRED
  -- Autor   : Jean Michel
  -- Data    : Maio/2015.                     Ultima atualizacao: 22/03/2017

  -- Dados referentes ao programa:

  -- Frequencia : A view para calculo de saldo de aplicacao que retorna informacoes para o BI utiliza esta function
  -- Objetivo   : Retornar os registros de saldo de aplicacoes vinculadas a aditivos de empréstimos.
  --
  -- Parâmetros : pr_cdcooper: Codigo da Cooperativa
  --              pr_nrdconta: Numero da Conta
  --              pr_nrctagar: Numero da Conta do Garantidor
  --              pr_nraplica: Numero da Aplicacao
  --              pr_cdaditiv: Codigo do Aditiva
  --              pr_tpproapl: Tipo de Produto(1 - Antigo / 2 - Novo)
  --              pr_tpaplica: Tipo de Aplicacao
  --              pr_tpaplrdc: Tipo do Produto
  --
  -- Alteracoes: 17/11/2016 -  Correção do campo pr_tpproapl (1 - NOVO / 2 - ANTIGO ) era ((2 - NOVO / 1 - ANTIGO )
  --                           foi criado invertido, sendo assim não trazia as informações SD555414- Vanessa Klein
  --
  --             22/03/2017 - #455742 Ajuste de passagem dos parâmetros de informações da aplicação e cdprogra
  --                          na rotina pc_saldo_rdc_pos (Carlos)
  -- .............................................................................

  -- Seleciona produtos e aplicacoes novas
  CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE
                   ,pr_nrdconta IN craprac.nrdconta%TYPE
                   ,pr_nraplica IN craprac.nraplica%TYPE) IS
    SELECT
      rac.cdcooper AS cdcooper,
      rac.nrdconta AS nrdconta,
      rac.nraplica AS nraplica,
      cpc.idtippro AS idtippro,
      rac.dtmvtolt AS dtmvtolt,
      rac.txaplica AS txaplica,
      cpc.idtxfixa AS idtxfixa,
      cpc.cddindex AS cddindex,
      rac.qtdiacar AS qtdiacar,
      rac.vlaplica AS vlaplica,
      cpc.nmprodut AS nmprodut,
      rac.dtvencto AS dtvencto
    FROM
      craprac rac,
      crapcpc cpc
    WHERE     rac.cdcooper = pr_cdcooper
          AND rac.nrdconta = pr_nrdconta
          AND rac.nraplica = pr_nraplica
          AND rac.cdprodut = cpc.cdprodut;

  rw_craprac cr_craprac%ROWTYPE;

  -- Aplicacoes RDCA
  CURSOR cr_craprda (pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Codigo da cooperativa
                    ,pr_nrdconta  IN craprda.nrdconta%TYPE        --> Numero da conta
                    ,pr_nraplica  IN craprda.nraplica%TYPE) IS    --> Numero da aplicacao

    -- Cursor sobre o cadastro de aplicacoes RDCA.
    SELECT rda.nraplica,
           rda.tpaplica,
           rda.vlsdrdca,
           rda.dtmvtolt,
           rda.cdagenci,
           rda.cdbccxlt,
           rda.nrdolote,
           rda.inaniver,
           rda.dtfimper,
           rda.vlaplica,
           rda.tpnomapl,
           rda.qtdiauti,
           rda.qtdiaapl,
           rda.dtvencto,
           rda.vlsltxmm,
           rda.dtatslmm,
           rda.dtatslmx,
           rda.vlsltxmx,
           lap.txaplica,
           lap.txaplmes
      FROM craprda rda
          ,craplap lap
     WHERE rda.cdcooper = pr_cdcooper
       AND rda.nrdconta = pr_nrdconta
       AND rda.nraplica = pr_nraplica       
       AND lap.cdcooper = rda.cdcooper
       AND lap.dtmvtolt = rda.dtmvtolt
       AND lap.cdagenci = rda.cdagenci
       AND lap.cdbccxlt = rda.cdbccxlt
       AND lap.nrdolote = rda.nrdolote
       AND lap.nrdconta = rda.nrdconta
       AND lap.nrdocmto = rda.nraplica;

  rw_craprda cr_craprda%ROWTYPE;

  vr_craprda apli0001.typ_tab_craprda;

  --Selecionar informacoes das poupancas programadas
  CURSOR cr_craprpp (pr_cdcooper IN craprpp.cdcooper%TYPE
                    ,pr_nrdconta IN craprpp.nrdconta%TYPE) IS

    SELECT rpp.nrctrrpp
          ,rpp.nrdconta
          ,rpp.cdagenci
          ,rpp.cdbccxlt
          ,rpp.nrdolote
          ,rpp.dtmvtolt
          ,rpp.dtvctopp
          ,rpp.dtdebito
          ,rpp.vlprerpp
          ,rpp.qtprepag
          ,rpp.vlprepag
          ,rpp.vljuracu
          ,rpp.vlrgtacu
          ,rpp.dtinirpp
          ,rpp.dtrnirpp
          ,rpp.dtaltrpp
          ,rpp.dtcancel
          ,rpp.flgctain
          ,rpp.dtiniper
          ,rpp.dtfimper
          ,rpp.vlabcpmf
          ,rpp.cdsitrpp
          ,rpp.vlsdrdpp
          ,rpp.ROWID
    FROM craprpp rpp
    WHERE rpp.cdcooper = pr_cdcooper
    AND   rpp.nrdconta = pr_nrdconta;

  rw_craprpp cr_craprpp%ROWTYPE;

  /* Cursor generico de parametrizacao */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nmsistem IN craptab.nmsistem%TYPE
                   ,pr_tptabela IN craptab.tptabela%TYPE
                   ,pr_cdempres IN craptab.cdempres%TYPE
                   ,pr_cdacesso IN craptab.cdacesso%TYPE
                   ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.dstextab
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
       AND upper(tab.nmsistem) = pr_nmsistem
       AND upper(tab.tptabela) = pr_tptabela
       AND tab.cdempres = pr_cdempres
       AND upper(tab.cdacesso) = pr_cdacesso
       AND tab.tpregist = pr_tpregist;
  rw_craptab cr_craptab%ROWTYPE;

  -- Cursor sobre a descricao dos varios tipos de captacao oferecidas para o cooperado.
  CURSOR cr_crapdtc(pr_tpaplica crapdtc.tpaplica%TYPE) IS
    SELECT tpaplrdc,
           dsaplica
      FROM crapdtc
     WHERE crapdtc.cdcooper = pr_cdcooper
       AND crapdtc.tpaplica = pr_tpaplica;

  rw_crapdtc cr_crapdtc%ROWTYPE;

  /*
  -- Cursor sobre a descricao dos varios tipos de captacao oferecidas para o cooperado.
  CURSOR cr_crapdtc_2(pr_tpaplica crapdtc.tpaplica%TYPE) IS
    SELECT dsaplica
      FROM crapdtc
     WHERE crapdtc.cdcooper = pr_cdcooper
       AND crapdtc.tpaplica = pr_tpaplica
       AND crapdtc.tpaplrdc = 3;
  rw_crapdtc_2 cr_crapdtc_2%ROWTYPE;
  */

  -- Definicao do tipo para a tabela de datas
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  -- Tratamento de erros
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);
  vr_des_reto   VARCHAR2(4000);        --> Indicador de saida com erro (OK/NOK)
  vr_tab_erro   GENE0001.typ_tab_erro; --> Tabela com erros

  -- Variaveis locais
  vr_nrdconta NUMBER(10);
  vr_vlbascal NUMBER := 0;        -- Base de Calculo
  vr_vlsldtot NUMBER := 0;        -- Saldo Total
  vr_vlsdrdpp NUMBER := 0;
  vr_vlsldrgt NUMBER := 0;        -- Saldo de Resgate
  vr_vlrgttot NUMBER := 0;
  vr_vlsldapl NUMBER := 0;        -- Valor Aplicado
  vr_vlsdrdca NUMBER := 0;
  vr_vldperda NUMBER := 0;
  vr_txaplica NUMBER := 0;
  vr_vlultren NUMBER := 0;        -- Ultimo Rendimento
  vr_vlrentot NUMBER := 0;        -- Rendimento Total
  vr_vlrevers NUMBER := 0;        -- Valor de Revers?o
  vr_vlrdirrf NUMBER := 0;        -- Valor de IRRF
  vr_percirrf NUMBER := 0;        -- Percentual de IRRF
  vr_percenir NUMBER := 0;
  vr_perirrgt NUMBER := 0;
  vr_vlrenrgt NUMBER := 0;
  vr_vlirftot NUMBER := 0;
  vr_vlrendmm NUMBER := 0;
  vr_vlrvtfim NUMBER := 0;
  vr_dup_vlsdrdca NUMBER := 0;
  vr_dtinitax DATE;
  vr_dtfimtax DATE;
  vr_dscprodu VARCHAR2(50) := '';
  vr_dshistor VARCHAR2(50) := '';
  vr_dtmvtolt DATE;
  vr_dtvencto DATE;

BEGIN

  -- Verifica se a cooperativa esta cadastrada
  OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
  -- Se n?o encontrar
  IF BTCH0001.cr_crapdat%NOTFOUND THEN
   -- Fechar o cursor pois haver? raise
   CLOSE BTCH0001.cr_crapdat;
  ELSE
   -- Apenas fechar o cursor
   CLOSE BTCH0001.cr_crapdat;
  END IF;

  -- Buscar a descricao das faixas contido na craptab
  OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                 ,pr_nmsistem => 'CRED'
                 ,pr_tptabela => 'USUARI'
                 ,pr_cdempres => 11
                 ,pr_cdacesso => 'MXRENDIPOS'
                 ,pr_tpregist => 1);
  FETCH cr_craptab
   INTO rw_craptab;
  -- Se n?o encontrar
  IF cr_craptab%NOTFOUND THEN
    CLOSE cr_craptab;
    -- Utilizar datas padr?o
    vr_dtinitax := to_date('01/01/9999','dd/mm/yyyy');
    vr_dtfimtax := to_date('01/01/9999','dd/mm/yyyy');
  ELSE
    CLOSE cr_craptab;
    -- Utilizar datas da tabela
    vr_dtinitax := TO_DATE(gene0002.fn_busca_entrada(1,rw_craptab.dstextab,';'),'DD/MM/YYYY');
    vr_dtfimtax := TO_DATE(gene0002.fn_busca_entrada(2,rw_craptab.dstextab,';'),'DD/MM/YYYY');
  END IF;

  -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
  vr_percenir:= GENE0002.fn_char_para_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                                       ,pr_nmsistem => 'CRED'
                                                                       ,pr_tptabela => 'CONFIG'
                                                                       ,pr_cdempres => 0
                                                                       ,pr_cdacesso => 'PERCIRAPLI'
                                                                       ,pr_tpregist => 0));

  -- Verifica tipo do aditivo
  IF pr_cdaditiv = 2 THEN
    vr_nrdconta := pr_nrdconta;
  ELSE
    vr_nrdconta := pr_nrctagar;
  END IF;

  -- Verifica tipo de aplicacao (1 - NOVO / 2 - ANTIGO )
  IF pr_tpproapl = 2 THEN -- Consulta de antigas aplicacoes
    
    -- Consulta aplicacao antiga
    OPEN cr_craprda(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => vr_nrdconta
                   ,pr_nraplica => pr_nraplica);

    FETCH cr_craprda INTO rw_craprda;

    CLOSE cr_craprda;

    vr_craprda(1).dtvencto := rw_craprda.dtvencto;
    vr_craprda(1).dtmvtolt := rw_craprda.dtmvtolt;
    vr_craprda(1).vlsdrdca := rw_craprda.vlsdrdca;
    vr_craprda(1).qtdiauti := rw_craprda.qtdiauti;
    vr_craprda(1).vlsltxmm := rw_craprda.vlsltxmm;
    vr_craprda(1).dtatslmm := rw_craprda.dtatslmm;
    vr_craprda(1).vlsltxmx := rw_craprda.vlsltxmx;
    vr_craprda(1).dtatslmx := rw_craprda.dtatslmx;
    vr_craprda(1).tpaplica := rw_craprda.tpaplica;          
    vr_craprda(1).txaplica := rw_craprda.txaplica;
    vr_craprda(1).txaplmes := rw_craprda.txaplmes;

    -- Insere valor inicial de aplicao
    vr_vlsldapl := rw_craprda.vlaplica;
    vr_dtmvtolt := rw_craprda.dtmvtolt;
    vr_dtvencto := rw_craprda.dtfimper;

    -- Busca a descricao dos varios tipos de captacao oferecidas para o cooperado.
    OPEN cr_crapdtc(rw_craprda.tpaplica);
    FETCH cr_crapdtc INTO rw_crapdtc;

    CLOSE cr_crapdtc;

    -- Nome do produto
    IF rw_craprda.tpaplica = 3  THEN -- RDCA30
      vr_dshistor := 'RDCA   ';
      vr_dscprodu := vr_dshistor;
    ELSIF rw_craprda.tpaplica = 5 THEN -- RDCA60
      vr_dshistor := 'RDCA60 ';
      vr_dscprodu := vr_dshistor;
    ELSIF rw_crapdtc.tpaplrdc = 2  THEN /** RDCPOS **/
      vr_dshistor := 'RDC' || to_char(rw_craprda.qtdiauti,'fm0000');
      vr_dscprodu := rw_crapdtc.dsaplica;
      
      /*
      -- Abre o cursor que contem a descricao dos varios tipos de captacao oferecidas para o cooperado.
      OPEN cr_crapdtc_2(rw_craprda.tpnomapl);
      FETCH cr_crapdtc_2 INTO rw_crapdtc_2;

      IF cr_crapdtc_2%FOUND THEN
        vr_dshistor := 'Teste'; --rw_crapdtc_2.dsaplica;
      END IF;
      CLOSE cr_crapdtc_2;
      */

      vr_dscprodu := vr_dshistor;

    ELSE
      vr_dshistor := rpad(substr(rw_crapdtc.dsaplica,1,7),7,' ');
      vr_dscprodu := substr(rw_crapdtc.dsaplica,1,6);
    END IF;   
    -- Fim Nome do Produto   

    IF NVL(rw_craprda.tpaplica,1) = 1 THEN -- POUPANCA


      OPEN cr_craprpp(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => vr_nrdconta);

      LOOP
        --Posicionar no proximo registro
        FETCH cr_craprpp INTO rw_craprpp;

        --Sair quando nao encontrar mais registros
        EXIT WHEN cr_craprpp%NOTFOUND;

        -- Incializar o saldo com o valor da tabela
        vr_vlsldtot := rw_craprpp.vlsdrdpp;
        vr_dtmvtolt := rw_craprpp.dtmvtolt;
        vr_dtvencto := rw_craprpp.dtvctopp;

        --Executar rotina para calcular saldo poupanca programada
        APLI0001.pc_calc_saldo_rpp (pr_cdcooper => pr_cdcooper
                                   ,pr_cdprogra => 'PC_CONS_SLD_APLI_BI'
                                   ,pr_inproces => 1
                                   ,pr_percenir => vr_percenir
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                   ,pr_dtiniper => rw_craprpp.dtiniper
                                   ,pr_dtfimper => rw_craprpp.dtfimper
                                   ,pr_vlabcpmf => rw_craprpp.vlabcpmf
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtoan
                                   ,pr_dtmvtopr => rw_crapdat.dtmvtolt
                                   ,pr_vlsdrdpp => vr_vlsdrdpp
                                   ,pr_des_erro => vr_dscritic);

        -- Valor do Saldo da poupanca recebe atual + calculado
        vr_vlsldtot:= NVL(vr_vlsldtot,0) + NVL(vr_vlsdrdpp,0);

      END LOOP;

      -- Saldo da poupanca
      vr_vlsldapl := rw_craprpp.vlprerpp;
      vr_vlsdrdca := NVL(vr_vlsldtot,0);
      vr_vlsldrgt := NVL(vr_vlsldtot,0);
      vr_dscprodu := 'P.PROG';

      --Fechar Cursor
      CLOSE cr_craprpp;

    ELSIF rw_craprda.tpaplica = 3 THEN

        -- Consulta saldo aplicacao RDCA30
        APLI0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper     => pr_cdcooper,           --> Cooperativa
                                              pr_dtmvtolt     => rw_crapdat.dtmvtoan,   --> Data do processo
                                              pr_inproces     => 1,                     --> Indicador do processo
                                              pr_dtmvtopr     => rw_crapdat.dtmvtopr,   --> Proximo dia util
                                              pr_cdprogra     => 'PC_CONS_SLD_APLI_BI', --> Programa em execucao
                                              pr_cdagenci     => 1,                     --> Codigo da agencia
                                              pr_nrdcaixa     => 1,                     --> Numero do caixa
                                              pr_nrdconta     => vr_nrdconta,           --> Nro da conta da aplicacao RDCA
                                              pr_nraplica     => rw_craprda.nraplica,   --> Nro da aplicacao RDCA
                                              pr_vlsdrdca     => vr_vlsdrdca,           --> Saldo da aplicacao
                                              pr_dup_vlsdrdca => vr_dup_vlsdrdca,       --> Acumulo do saldo da aplicacao RDCA
                                              pr_vlsldapl     => vr_vlsdrdca,           --> Saldo da aplicacao RDCA
                                              pr_sldpresg     => vr_vlsldrgt,           --> Saldo para resgate
                                              pr_vldperda     => vr_vldperda,           --> Valor calculado da perda
                                              pr_txaplica     => vr_txaplica,           --> Taxa aplicada sob o emprestimo
                                              pr_des_reto     => vr_des_reto,           --> OK ou NOK
                                              pr_tab_erro     => vr_tab_erro);          --> Tabela com erros
        vr_vlsldrgt := vr_dup_vlsdrdca;

      ELSIF rw_craprda.tpaplica = 5 THEN

        -- Consulta saldo aplicacao RDCA60
        APLI0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper,
                                              pr_dtmvtolt => rw_crapdat.dtmvtoan,
                                              pr_dtmvtopr => rw_crapdat.dtmvtopr, --> Proximo dia util
                                              pr_cdprogra => 'PC_CONS_SLD_APLI_BI',
                                              pr_cdagenci => 1,
                                              pr_nrdcaixa => 1,
                                              pr_nrdconta => vr_nrdconta,
                                              pr_nraplica => rw_craprda.nraplica,
                                              pr_vlsdrdca => vr_vlsdrdca,  --> Saida
                                              pr_sldpresg => vr_vlsldrgt,  --> Saida
                                              pr_des_reto => vr_des_reto,  --> Saida
                                              pr_tab_erro => vr_tab_erro); --> Saida

      ELSE

        -- Verifica tipo de aplicacao(1-PRE/2-POS)

        IF rw_crapdtc.tpaplrdc = 1  THEN
          -- Rotina de calculo do saldo das aplicacoes RDC PRE para resgate
          APLI0001.pc_saldo_rdc_pre(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_nraplica => rw_craprda.nraplica
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtoan
                                   ,pr_dtiniper => NULL
                                   ,pr_dtfimper => NULL
                                   ,pr_txaplica => 0
                                   ,pr_flggrvir => FALSE
                                   ,pr_tab_crapdat => rw_crapdat
                                   ,pr_vlsdrdca => vr_vlsdrdca      --> Saida
                                   ,pr_vlrdirrf => vr_vlrdirrf      --> Saida
                                   ,pr_perirrgt => vr_perirrgt      --> Saida
                                   ,pr_des_reto => vr_des_reto      --> Saida
                                   ,pr_tab_erro => vr_tab_erro);     --> Saida

          vr_vlsldrgt := rw_craprda.vlsdrdca;

        ELSIF rw_crapdtc.tpaplrdc = 2 THEN
          -- Rotina de calculo do saldo das aplicacoes RDC POS
          apli0001.pc_saldo_rdc_pos(pr_cdcooper => pr_cdcooper,         --> Cooperativa
                           pr_dtmvtolt => rw_crapdat.dtmvtoan, --> Movimento atual
                           pr_dtmvtopr => rw_crapdat.dtmvtolt, --> Proximo dia util
                           pr_nrdconta => vr_nrdconta,         --> Nro da conta da aplicacao RDC
                           pr_craprda  => vr_craprda,          --> Informações da aplicacao RDC
                           pr_dtmvtpap => rw_crapdat.dtmvtoan,         --> Data do movimento atual passado
                           pr_dtcalsld => rw_crapdat.dtmvtoan,         --> Data do movimento atual passado
                           pr_flantven => FALSE,               --> Flag antecede vencimento
                           pr_flggrvir => FALSE,               --> Identificador se deve gravar valor insento
                           pr_dtinitax => vr_dtinitax,         --> Data de inicio da utilizacao da taxa de poupanca.
                           pr_dtfimtax => vr_dtfimtax,         --> Data de fim da utilizacao da taxa de poupanca.
                           pr_cdprogra => '',                  --> Código do programa
                           pr_vlsdrdca => vr_vlsdrdca,         --> Saldo da aplicacao pos calculo
                           pr_vlrentot => vr_vlrentot,         --> Saldo da aplicacao pos calculo
                           pr_vlrdirrf => vr_vlrdirrf,         --> Valor de IR
                           pr_perirrgt => vr_perirrgt,         --> Percentual de IR resgatado
                           pr_des_reto => vr_des_reto,         --> OK ou NOK
                           pr_tab_erro => vr_tab_erro);        --> Tabela com erros
        
          -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
          APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                       ,pr_cdagenci => 1         --> Codigo da agencia
                                       ,pr_nrdcaixa => 1         --> Numero do caixa
                                       ,pr_nrctaapl => vr_nrdconta         --> Nro da conta da aplicacao RDC
                                       ,pr_nraplres => rw_craprda.nraplica --> Nro da aplicacao RDC
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtoan         --> Data do movimento atual passado
                                       ,pr_dtaplrgt => rw_crapdat.dtmvtoan         --> Data do movimento atual passado
                                       ,pr_vlsdorgt => 0                   --> Valor RDC
                                       ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                       ,pr_dtinitax => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlsddrgt => vr_vlsldrgt         --> Valor do resgate total sem irrf ou o solicitado
                                       ,pr_vlrenrgt => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                       ,pr_vlrdirrf => vr_vlrdirrf         --> IRRF do que foi solicitado
                                       ,pr_perirrgt => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                       ,pr_vlrgttot => vr_vlrgttot         --> Resgate para zerar a aplicacao
                                       ,pr_vlirftot => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                       ,pr_vlrendmm => vr_vlrendmm         --> Rendimento da ultima provisao ate a data do resgate
                                       ,pr_vlrvtfim => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicacao
                                       ,pr_des_reto => vr_des_reto         --> OK ou NOK
                                       ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
     
          IF NVL(vr_vlrgttot,0) > 0 THEN
            vr_vlsldrgt := vr_vlrgttot;
          ELSE
            vr_vlsldrgt := rw_craprda.vlsdrdca;
          END IF;

        END IF;

      END IF;

  ELSIF pr_tpproapl = 1 THEN -- Consulta de novas aplicacoes

    -- Consulta aplicacao nova
    OPEN cr_craprac(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => vr_nrdconta
                   ,pr_nraplica => pr_nraplica);

    FETCH cr_craprac INTO rw_craprac;

    CLOSE cr_craprac;

    -- Insere valor inicial de aplicao
    vr_vlsldapl := rw_craprac.vlaplica;
    vr_dtmvtolt := rw_craprac.dtmvtolt;
    vr_dtvencto := rw_craprac.dtvencto;

    -- Nome do produto
    vr_dscprodu := rw_craprac.nmprodut;

    -- Verifica tipo de aplicacao (1-PRE/2-POS)
    IF rw_craprac.idtippro = 1 THEN

      -- Consulta saldo de aplicacao pre
      apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                             ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                             ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                             ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                             ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                             ,pr_idtxfixa => rw_craprac.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                             ,pr_cddindex => rw_craprac.cddindex -- Codigo de Indexador
                                             ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                             ,pr_idgravir => 0                   -- Imunidade Tributaria
                                             ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                             ,pr_dtfimcal => rw_crapdat.dtmvtoan -- Data de Fim do Calculo
                                             ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                             ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                             ,pr_vlsldtot => vr_vlsdrdca         -- Valor de Saldo Total
                                             ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                             ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                             ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                             ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                             ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                             ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                             ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                             ,pr_dscritic => vr_dscritic);       -- Descricao de Critica

    ELSIF rw_craprac.idtippro = 2 THEN

      -- Consulta saldo de aplicacao pos
      apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper -- Codigo da Cooperativa
                                             ,pr_nrdconta => rw_craprac.nrdconta -- Conta do Cooperado
                                             ,pr_nraplica => rw_craprac.nraplica -- Numero da Aplicacao
                                             ,pr_dtiniapl => rw_craprac.dtmvtolt -- Data de Movimento
                                             ,pr_txaplica => rw_craprac.txaplica -- Taxa de Aplicacao
                                             ,pr_idtxfixa => rw_craprac.idtxfixa -- Taxa Fixa (0-Nao / 1-Sim)
                                             ,pr_cddindex => rw_craprac.cddindex -- Codigo de Indexador
                                             ,pr_qtdiacar => rw_craprac.qtdiacar -- Quantidade de Dias de Carencia
                                             ,pr_idgravir => 0                   -- Imunidade Tributaria
                                             ,pr_dtinical => rw_craprac.dtmvtolt -- Data de Inicio do Calculo
                                             ,pr_dtfimcal => rw_crapdat.dtmvtoan         -- Data de Fim do Calculo
                                             ,pr_idtipbas => 2                   -- Tipo Base / 2-Total
                                             ,pr_vlbascal => vr_vlbascal         -- Valor de Base
                                             ,pr_vlsldtot => vr_vlsdrdca         -- Valor de Saldo Total
                                             ,pr_vlsldrgt => vr_vlsldrgt         -- Valor de Saldo p/ Resgate
                                             ,pr_vlultren => vr_vlultren         -- Valor do ultimo rendimento
                                             ,pr_vlrentot => vr_vlrentot         -- Valor de rendimento total
                                             ,pr_vlrevers => vr_vlrevers         -- Valor de reversao
                                             ,pr_vlrdirrf => vr_vlrdirrf         -- Valor de IRRF
                                             ,pr_percirrf => vr_percirrf         -- Percentual de IRRF
                                             ,pr_cdcritic => vr_cdcritic         -- Codigo de Critica
                                             ,pr_dscritic => vr_dscritic);       -- Descricao de Critica

    END IF;    
  END IF;

  -- Retorna valores em uma string para a funcao ser chamada somente uma vez
  RETURN vr_dscprodu || '|' || (NVL(ROUND(vr_vlsldapl,2),'0') || '|' || NVL(ROUND(vr_vlsdrdca,2),'0') || '|' || NVL(ROUND(vr_vlsldrgt,2),'0')) || '|' || TO_CHAR(vr_dtmvtolt) || '|' || TO_CHAR(vr_dtvencto);

end fn_retorna_valores_aplicacao;
/
