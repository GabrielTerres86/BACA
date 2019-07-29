CREATE OR REPLACE PACKAGE CECRED.TELA_ADITIV IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ADITIV
  --  Sistema  : Rotinas utilizadas pela Tela ADITIV
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  --
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ADITIV
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------
  --> Descricao dos tipo de aditivos
  TYPE typ_dsaditiv IS VARRAY(9) OF VARCHAR2(50);
  vr_tab_dsaditiv typ_dsaditiv := typ_dsaditiv('1- Alteracao Data do Debito',
                                               '2- Aplicacao Vinculada',
                                               '3- Aplicacao Vinculada Terceiro',
                                               '4- Inclusao de Fiador/Avalista',
                                               '5- Substituicao de Veiculo',
                                               '6- Interveniente Garantidor Veiculo',
                                               '7- Sub-rogacao - C/ Nota Promissoria',
                                               '8- Sub-rogacao - S/ Nota Promissoria',
                                               '9- Cobertura de Aplicacao Vinculada a Operacao');
  
  
  TYPE typ_rec_promis 
       IS RECORD(nrpromis crapadi.nrpromis%TYPE,
                 vlpromis crapadi.vlpromis%TYPE);
  TYPE typ_tab_promis IS TABLE OF typ_rec_promis 
       INDEX BY PLS_INTEGER; 
  
  --  type para armazenar dados do aditivo (antiga b1wgen0115tt.i - tt-aditiv)
  TYPE typ_rec_aditiv 
       IS RECORD ( cdaditiv crapadt.cdaditiv%TYPE,
                   nraditiv crapadt.nraditiv%TYPE,
                   nrdconta crapadt.nrdconta%TYPE,
                   nrctremp crapadt.nrctremp%TYPE,
                   dsaditiv VARCHAR2(50),
                   dtmvtolt crapadt.dtmvtolt%TYPE,
                   nrctagar crapadt.nrctagar%TYPE,
                   nrcpfgar crapadt.nrcpfgar%TYPE,
                   nrdocgar crapadt.nrdocgar%TYPE,
                   nmdgaran crapadt.nmdgaran%TYPE,
                   promis   typ_tab_promis,
                   flgpagto crapadi .flgpagto%TYPE,
                   dtdpagto crapadi.dtdpagto%TYPE,
                   dscatbem crapadi.dscatbem%TYPE,
                   dsmarbem crapadi.dsmarbem%TYPE,
                   dsbemfin crapadi.dsbemfin%TYPE,
                   dschassi crapadi.dschassi%TYPE,
                   nrdplaca crapadi.nrdplaca%TYPE,
                   dscorbem crapadi.dscorbem%TYPE,
                   nranobem crapadi.nranobem%TYPE,
                   nrmodbem crapadi.nrmodbem%TYPE,                   
                   dstpcomb crapadi.dstpcomb%TYPE,  
                   vlfipbem crapadi.vlfipbem%TYPE,
                   vlrdobem crapadi.vlrdobem%TYPE,
                   dstipbem crapadi.dstipbem%TYPE,
                   nrrenava crapadi.nrrenava%TYPE,
                   tpchassi crapadi.tpchassi%TYPE,
                   ufdplaca crapadi.ufdplaca%TYPE,
                   uflicenc crapadi.uflicenc%TYPE,
                   nmdavali crapadi.nmdavali%TYPE,
                   tpdescto crapepr.tpdescto%TYPE,
                   dscpfavl VARCHAR2(50),
                   nrcpfcgc crapadi.nrcpfcgc%TYPE,
                   nrsequen INTEGER,
                   idseqbem crapbpr.idseqbem%TYPE,
                   dsbemsub varchar2(250),
                   dspropri varchar2(1000),
                   dschssub crapadi.dschassi%TYPE,
                   dssitgrv varchar(25));
  TYPE typ_tab_aditiv IS TABLE OF typ_rec_aditiv
       INDEX BY PLS_INTEGER;
            
  --  type para armazenar dados da aplicacoes (antiga b1wgen0115tt.i - tt-aplicacoes)
  TYPE typ_rec_aplicacoes 
       IS RECORD (nraplica craprda.nraplica%TYPE,
                  dtmvtolt craprda.dtmvtolt%TYPE,
                  dshistor craphis.dshistor%TYPE,
                  nrdocmto VARCHAR2(50),
                  dtvencto craprda.dtvencto%TYPE,
                  vlsldapl craprda.vlsdrdca%TYPE,
                  sldresga craprda.vlsdrdca%TYPE,
                  flgselec INTEGER,
                  tpaplica craprda.tpaplica%TYPE,
                  vlaplica craprda.vlaplica%TYPE,
                  tpproapl INTEGER);
  TYPE typ_tab_aplicacoes IS TABLE OF typ_rec_aplicacoes
       INDEX BY PLS_INTEGER;
       
  TYPE typ_tab_clausula IS TABLE OF VARCHAR2(4000)
       INDEX BY PLS_INTEGER;
       
  TYPE typ_rec_clausula 
      IS RECORD (clausula typ_tab_clausula);
      
  TYPE typ_tab_clau_adi IS TABLE OF typ_rec_clausula
       INDEX BY PLS_INTEGER;
       
       
  ----------------------------------- ROTINAS -------------------------------
  
  --> Buscar dados do aditivo do emprestimo
  PROCEDURE pc_busca_dados_aditiv_prog(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                                      ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da agencia
                                      ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE --> Nome da tela
                                      ,pr_idorigem  IN INTEGER               --> Origem 
                                      ,pr_dtmvtolt  IN VARCHAR2              --> Data de movimento
                                      ,pr_dtmvtopr  IN VARCHAR2              --> Data do prox. movimento
                                      ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador de processo
                                      ,pr_cddopcao  IN VARCHAR2              --> Codigo da opcao
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato
                                      ,pr_dtmvtolx  IN VARCHAR2              --> Data de consulta
                                      ,pr_nraditiv  IN crapadt.nraditiv%TYPE --> Numero do aditivo
                                      ,pr_cdaditiv  IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                                      ,pr_tpaplica  IN craprda.tpaplica%TYPE --> tipo de aplicacao
                                      ,pr_nrctagar  IN crapass.nrdconta%TYPE --> conta garantia
                                      ,pr_tpctrato  IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                                      ,pr_flgpagin  IN INTEGER               --> Flag (0-false 1-true)
                                      ,pr_nrregist  IN INTEGER               --> Numero de registros a serem retornados
                                      ,pr_nriniseq  IN INTEGER               --> Registro inicial
                                      ,pr_flgerlog  IN INTEGER               --> Gerar log(0-false 1-true)
                                      --------> OUT <--------
                                      ,pr_qtregist OUT INTEGER               --> Retornar quantidade de registros
                                      ,pr_clob_xml OUT CLOB                  --> XML com informacoes do retorno
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2);            --> Descricao da critica

  --> Gerar a impressao do contrato de aditivo
  PROCEDURE pc_gera_impressao_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo do programa
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_dsiduser   IN VARCHAR2              --> id do usuario
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           ,pr_tpctrato   IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                           --------> OUT <--------
                           ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2    );        --> Descrição da crítica

  PROCEDURE pc_busca_dados_garopc(pr_cddopcao     IN VARCHAR2 --> Opcao selecionada
                                 ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                                 ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                                 ,pr_nrctremp     IN crapadt.nrctremp%TYPE --> Numero do contrato
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_busca_cobert_garopc_prog(pr_idcobert  IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                                       ,pr_inresaut OUT tbgar_cobertura_operacao.inresgate_automatico%TYPE --> Resgate Automatico (0-Nao/ 1-Sim)
                                       ,pr_permingr OUT tbgar_cobertura_operacao.perminimo%TYPE --> Percentual minimo da cobertura da garantia
                                       ,pr_inaplpro OUT tbgar_cobertura_operacao.inaplicacao_propria%TYPE --> Aplicacao propria (0-Nao/ 1-Sim)
                                       ,pr_inpoupro OUT tbgar_cobertura_operacao.inpoupanca_propria%TYPE --> Poupanca propria (0-Nao/ 1-Sim)
                                       ,pr_nrctater OUT tbgar_cobertura_operacao.nrconta_terceiro%TYPE --> Conta de terceiro
                                       ,pr_inaplter OUT tbgar_cobertura_operacao.inaplicacao_terceiro%TYPE --> Aplicacao de terceiro (0-Nao/ 1-Sim)
                                       ,pr_inpouter OUT tbgar_cobertura_operacao.inpoupanca_terceiro%TYPE --> Poupanca de terceiro (0-Nao/ 1-Sim)
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2); --> Descricao da critica

  PROCEDURE pc_busca_tipo_aditivo(pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp     IN crapadt.nrctremp%TYPE --> Numero do contrato
                                 ,pr_nraditiv     IN crapadt.nraditiv%TYPE --> Numero do Adivito
                                 ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  procedure pc_cria_aditivo (par_cdcooper in crawepr.cdcooper%type,
                             par_nrdconta in crawepr.nrdconta%type,
                             par_nrctremp in crawepr.nrctremp%type,
                             par_dtmvtolt in crapadt.dtmvtolt%type,
                             par_cdagenci in crapadt.cdagenci%type,
                             par_cdoperad in crapadt.cdoperad%type,
                             par_tpctrato in crapadt.tpctrato%type,
                             par_nrcpfcgc in crapass.nrcpfcgc%type,
                             par_dsbemfin in crapadi.dsbemfin%type,
                             par_dschassi in crapadi.dschassi%type,
                             par_nrdplaca in crapadi.nrdplaca%type,
                             par_dscorbem in crapadi.dscorbem%type,
                             par_nranobem in crapadi.nranobem%type,
                             par_nrmodbem in crapadi.nrmodbem%type,
                             par_nrrenava in crapadi.nrrenava%type,
                             par_tpchassi in crapadi.tpchassi%type,
                             par_ufdplaca in crapadi.ufdplaca%type,
                             par_uflicenc in crapadi.uflicenc%type,
                             par_dscatbem in crapadi.dscatbem%type,
                             par_dsmarbem in crapadi.dsmarbem%type,
                             par_vlfipbem in crapadi.vlfipbem%type,
                             par_vlrdobem in crapadi.vlrdobem%type,
                             par_dstipbem in crapadi.dstipbem%type,
                             par_dstpcomb in crapadi.dstpcomb%type,
                             par_idseqbem in crapadi.idseqbem%type,
                             par_idseqsub in crapadi.idseqsub%type,
                             par_rowidepr out varchar2,
                             par_uladitiv out crapadt.nraditiv%type,
                             par_cdcritic out number,
                             par_dscritic out varchar2);

  procedure pc_cadastro_interveniente(pr_cdcooper in crapavt.cdcooper%type,
                                      pr_nrdconta in crapavt.nrdconta%type,
                                      pr_nrctremp in crapavt.nrctremp%type,
                                      pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                                      pr_cdcritic out number,
                                      pr_dscritic out varchar2);

  /* Rotina para gravação do Tipo05 oriunda de chamada do AyllosWeb */
  PROCEDURE pc_grava_aditivo_tipo5(pr_nrdconta in crawepr.nrdconta%type --> Conta
                                  ,pr_nrctremp in varchar2 --> Contrato
                                  ,pr_tpctrato in varchar2 --> Tipo Contrato
                                  ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto, Caminhão ou Outros Veiculos)
                                  ,pr_dstipbem in varchar2 --> Tipo do Bem (Usado/Zero KM)
                                  ,pr_dsmarbem in varchar2 --> Marca do Bem
                                  ,pr_nrmodbem in varchar2 --> Ano Modelo
                                  ,pr_nranobem in varchar2 --> Ano Fabricação
                                  ,pr_dsbemfin in varchar2 --> Modelo bem financiado
                                  ,pr_vlfipbem in varchar2 --> Valor da FIPE
                                  ,pr_vlrdobem in varchar2 --> Valor do bem
                                  ,pr_tpchassi in varchar2 --> Tipo Chassi
                                  ,pr_dschassi in varchar2 --> Chassi
                                  ,pr_dscorbem in varchar2 --> Cor
                                  ,pr_ufdplaca in varchar2 --> UF Placa
                                  ,pr_nrdplaca in varchar2 --> Placa
                                  ,pr_nrrenava in varchar2 --> Renavam
                                  ,pr_uflicenc in varchar2 --> UF Licenciamento
                                  ,pr_nrcpfcgc in varchar2 --> CPF Interveniente
                                  ,pr_idseqbem IN VARCHAR2 --> Sequencia do bem em substituição
                                  ,pr_cdopeapr IN VARCHAR2 --> Operador da aprovação
                                  ,pr_nrgravam IN VARCHAR2 --> Numero gravame
                                  ,pr_xmllog     IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic   OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic   OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo   OUT VARCHAR2   --> Nome do campo com erro
                                  ,pr_des_erro   OUT VARCHAR2); --> Erros do processo                             

END TELA_ADITIV;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ADITIV IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ADITIV
  --  Sistema  : Rotinas utilizadas pela Tela ADITIV
  --  Sigla    : EMPR
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela ADITIV
  --
  -- Alteracoes: 17/08/2018 - Inclusão Apl. Programada
  --                          Proj. 411.2 - CIS Corporate
  --
  ---------------------------------------------------------------------------
  
  --> Retornar QRcode para digitalização
  FUNCTION fn_qrcode_digitaliz (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrdconta IN crapass.nrdconta%TYPE,
                                pr_cdagenci IN crapage.cdagenci%TYPE,
                                pr_nrborder IN NUMBER,
                                pr_nrcontra IN NUMBER,
                                pr_nraditiv IN NUMBER,
                                pr_cdtipdoc IN INTEGER )RETURN VARCHAR2 IS
  /*
    O QR Code possui a seguinte estrutura:
      • Cooperativa;
      • PA onde a operação de crédito foi efetivada; (epr.cdagenci, lim.cdageori)
      • ContaCorrente do Cooperado;
      • Número do Borderô, possui o valor 0 (zero) quando o tipo de documento for um contrato (1,3,5,19)
      e/ou aditivo (18), conforme códigos cadastrados na tela TAB093.
      • Número do Contrato, possui o valor 0 (zero) quando o tipo de documento for um borderô (2,4);
      • Número do Aditivo, possui o valor 0 (zero) quando o tipo de documento for um borderô (2,4) ou
      contrato de limite de crédito (19). Quando tiver valor obrigatoriamente tem um contrato. 
      • Tipo do Documento
      
      Valor a serem utilizados no campo Tipo de Documento:
      84 - Limite de Crédito;
      85 - Limite de Desconto de Título;
      86 - Limite de Desconto de Cheque;
      87 - Borderô de Cheque
      88 - Borderô de Título
      89 - Empréstimo/Financiamento;
      102 - Aditivos de Contrato de Empréstimo */
  
    vr_qrcode VARCHAR2(100);
  BEGIN
  
    vr_qrcode := pr_cdcooper ||'_'||
                 pr_cdagenci ||'_'||
                 TRIM(gene0002.fn_mask_conta(pr_nrdconta))   ||'_'||
                 TRIM(gene0002.fn_mask_contrato(pr_nrborder))||'_'||
                 TRIM(gene0002.fn_mask_contrato(pr_nrcontra))||'_'||
                 pr_nraditiv ||'_'||
                 pr_cdtipdoc;
    RETURN vr_qrcode;
  END;
  
  --> buscar as aplicacooes do aditivo
  PROCEDURE pc_buscar_aplicacoes (pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                                 ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                                 ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                                 ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                                 ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                                 ,pr_idorigem   IN INTEGER               --> Origem 
                                 ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                                 ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                                 ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                                 ,pr_cddopcao   IN VARCHAR2              --> Codigo da opcao
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta                                 
                                 ,pr_tpaplica   IN craprda.tpaplica%TYPE --> tipo de aplicacao
                                 ,pr_nraplica   IN crapadi.nraplica%TYPE --> Numero da aplicacao
                                 --------> OUT <--------
                                 ,pr_tab_aplicacoes IN OUT typ_tab_aplicacoes  --> Retornar dados das aplicações 
                                 ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descrição da crítica
  
  
    ------------>> CURSORES <<-----------
    
    -- Selecionar quantidade de saques em poupanca nos ultimos 6 meses
    CURSOR cr_craplpp (pr_cdcooper IN craplpp.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT craplpp.nrdconta
            ,craplpp.nrctrrpp
            ,Count(*) qtlancmto
        FROM craplpp craplpp
       WHERE craplpp.cdcooper = pr_cdcooper 
         AND craplpp.nrdconta = pr_nrdconta
         AND craplpp.cdhistor IN (158,496)
         AND craplpp.dtmvtolt > pr_dtmvtolt
       GROUP BY craplpp.nrdconta,craplpp.nrctrrpp
      HAVING Count(*) > 3
      UNION
      SELECT rac.nrdconta
            ,rac.nrctrrpp
            ,Count(*) qtlancmto
      FROM crapcpc cpc, craprac rac, craplac lac
      WHERE rac.cdcooper = pr_cdcooper
      AND   rac.nrdconta = pr_nrdconta 
      AND   rac.nrctrrpp > 0                 -- Apenas apl. programadas
      AND   cpc.cdprodut = rac.cdprodut
      AND   rac.cdcooper = lac.cdcooper
      AND   rac.nrdconta = lac.nrdconta
      AND   rac.nraplica = lac.nraplica 
      AND   lac.cdhistor in (cpc.cdhsrgap)
      AND   lac.dtmvtolt > pr_dtmvtolt       
      GROUP BY rac.nrdconta,rac.nrctrrpp        
      HAVING Count(*) > 3;

    --Contar a quantidade de resgates das contas
    CURSOR cr_craplrg_saque (pr_cdcooper IN craplrg.cdcooper%TYPE
                            ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,COUNT(*) qtlancmto
      FROM craplrg lrg
      WHERE lrg.cdcooper = pr_cdcooper
      AND lrg.tpaplica = 4
      AND lrg.inresgat = 0
      AND lrg.nrdconta = pr_nrdconta
      GROUP BY lrg.nrdconta,lrg.nraplica;

    --Selecionar informacoes dos lancamentos de resgate
    CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                      ,pr_dtresgat IN craplrg.dtresgat%TYPE
                      ,pr_nrdconta IN crapcop.nrdconta%TYPE) IS
      SELECT lrg.nrdconta
            ,lrg.nraplica
            ,lrg.tpaplica
            ,lrg.tpresgat
            ,NVL(SUM(NVL(lrg.vllanmto,0)),0) vllanmto
      FROM craplrg lrg
      WHERE lrg.cdcooper = pr_cdcooper
      AND   lrg.dtresgat <= pr_dtresgat
      AND   lrg.inresgat = 0
      AND   lrg.tpresgat = 1
      AND lrg.nrdconta = pr_nrdconta
      GROUP BY lrg.nrdconta
              ,lrg.nraplica
              ,lrg.tpaplica
              ,lrg.tpresgat;
         
      
    ----------->>> VARIAVEIS <<<--------    
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(1000);        --> Retorno
    vr_tab_erro        gene0001.typ_tab_erro;
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
    
    vr_tab_saldo_rdca  APLI0001.typ_tab_saldo_rdca; 
    vr_vlsldapl        NUMBER;
    vr_tab_aplica      apli0005.typ_tab_aplicacao;
    vr_idxrdca         PLS_INTEGER;
    vr_idxaplic        PLS_INTEGER;
    
    -- TempTables para APLI0001.pc_consulta_poupanca
    vr_tab_ctablq      APLI0001.typ_tab_ctablq;
    vr_tab_craplpp     APLI0001.typ_tab_craplpp;
    vr_tab_craplrg     APLI0001.typ_tab_craplpp;
    vr_tab_resgate     APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp   APLI0001.typ_tab_dados_rpp;
    vr_index_craplpp   VARCHAR2(20);
    vr_index_craplrg   VARCHAR2(20);
    vr_index_resgate   VARCHAR2(25);
    vr_percenir        NUMBER;
    vr_vlsldppr        NUMBER;
    
    
    
  BEGIN
    IF pr_tpaplica = 0 THEN
      -- apensa sair do programa
      RAISE vr_exc_sucesso;
          
    ELSIF pr_tpaplica = 1 THEN
          
      -- limpa as PLTABLES
      vr_tab_ctablq.DELETE;
      vr_tab_craplpp.DELETE;
      vr_tab_craplrg.DELETE;
      vr_tab_resgate.DELETE;

      -- Carregar tabela de memoria de contas bloqueadas
      TABE0001.pc_carrega_ctablq(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_tab_cta_bloq => vr_tab_ctablq);

      -- Carregar tabela de memoria de lancamentos na poupanca
      FOR rw_craplpp IN cr_craplpp (pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => pr_dtmvtolt - 180
                                   ,pr_nrdconta => pr_nrdconta) LOOP
        --Se possuir mais de 3 registros
        IF rw_craplpp.qtlancmto > 3 THEN
          -- Montar indice para acessar tabela
          vr_index_craplpp:= LPad(rw_craplpp.nrdconta,10,'0')||LPad(rw_craplpp.nrctrrpp,10,'0');
          -- Atribuir quantidade encontrada de cada conta ao vetor
          vr_tab_craplpp(vr_index_craplpp):= rw_craplpp.qtlancmto;
        END IF;
      END LOOP;

      -- Carregar tabela de memoria com total de resgates na poupanca
      FOR rw_craplrg IN cr_craplrg_saque (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta) LOOP
        -- Montar Indice para acesso quantidade lancamentos de resgate
        vr_index_craplrg:= LPad(rw_craplrg.nrdconta,10,'0')||LPad(rw_craplrg.nraplica,10,'0');
        -- Popular tabela de memoria
        vr_tab_craplrg(vr_index_craplrg):= rw_craplrg.qtlancmto;
      END LOOP;

      -- Carregar tabela de memória com total resgatado por conta e aplicacao
      FOR rw_craplrg IN cr_craplrg (pr_cdcooper => pr_cdcooper
                                   ,pr_dtresgat => pr_dtmvtopr
                                   ,pr_nrdconta => pr_nrdconta) LOOP
        -- Montar indice para selecionar total dos resgates na tabela auxiliar
        vr_index_resgate := LPad(rw_craplrg.nrdconta,10,'0') ||
                            LPad(rw_craplrg.tpaplica,05,'0') ||
                            LPad(rw_craplrg.nraplica,10,'0');
        -- Popular a tabela de memoria com a soma dos lancamentos de resgate
        vr_tab_resgate(vr_index_resgate).tpresgat := rw_craplrg.tpresgat;
        vr_tab_resgate(vr_index_resgate).vllanmto := rw_craplrg.vllanmto;
      END LOOP;
          
      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= GENE0002.fn_char_para_number
                          (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'CONFIG'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'PERCIRAPLI'
                                                     ,pr_tpregist => 0));
        
      --Executar rotina consulta poupanca
      apli0001.pc_consulta_poupanca (pr_cdcooper => pr_cdcooper            --> Cooperativa 
                                    ,pr_cdagenci => pr_cdagenci            --> Codigo da Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa            --> Numero do caixa 
                                    ,pr_cdoperad => pr_cdoperad            --> Codigo do Operador
                                    ,pr_idorigem => pr_idorigem            --> Identificador da Origem
                                    ,pr_nrdconta => pr_nrdconta            --> Nro da conta associado
                                    ,pr_idseqttl => 1                      --> Identificador Sequencial
                                    ,pr_nrctrrpp => pr_nraplica            --> Contrato Poupanca Programada 
                                    ,pr_dtmvtolt => pr_dtmvtolt            --> Data do movimento atual
                                    ,pr_dtmvtopr => pr_dtmvtopr            --> Data do proximo movimento
                                    ,pr_inproces => pr_inproces            --> Indicador de processo
                                    ,pr_cdprogra => pr_nmdatela            --> Nome do programa chamador
                                    ,pr_flgerlog => FALSE                  --> Flag erro log
                                    ,pr_percenir => vr_percenir            --> % IR para Calculo Poupanca
                                    ,pr_tab_craptab   => vr_tab_ctablq     --> Tipo de tabela de Conta Bloqueada
                                    ,pr_tab_craplpp   => vr_tab_craplpp    --> Tipo de tabela com lancamento poupanca
                                    ,pr_tab_craplrg   => vr_tab_craplrg    --> Tipo de tabela com resgates
                                    ,pr_tab_resgate   => vr_tab_resgate    --> Tabela com valores dos resgates das contas por aplicacao
                                    ,pr_vlsldrpp      => vr_vlsldppr       --> Valor saldo poupanca programada
                                    ,pr_retorno       => vr_des_reto       --> Descricao de erro ou sucesso OK/NOK 
                                    ,pr_tab_dados_rpp => vr_tab_dados_rpp  --> Poupancas Programadas
                                    ,pr_tab_erro      => vr_tab_erro);     --> Saida com erros;
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
            
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
            
        RAISE vr_exc_erro;      
      END IF;
          
      --Ler valores de retorno
      IF vr_tab_dados_rpp.count > 0 THEN
        FOR idx IN vr_tab_dados_rpp.first..vr_tab_dados_rpp.last LOOP
            
          -- Buscar as aplicações que possua saldo e nao estejam bloqueadas
          IF vr_tab_dados_rpp(idx).vlsdrdpp > 0 AND
             vr_tab_dados_rpp(idx).dsblqrpp <> 'SIM' THEN
                
            vr_idxaplic := pr_tab_aplicacoes.count + 1;
            pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_dados_rpp(idx).nrctrrpp;
            pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_dados_rpp(idx).dtmvtolt;
            pr_tab_aplicacoes(vr_idxaplic).dshistor := 'P.PROG ';
            pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_dados_rpp(idx).vlprerpp;
            pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_dados_rpp(idx).nrctrrpp;
            pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_dados_rpp(idx).dtvctopp;
            
            IF pr_cddopcao = 'I' THEN
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_dados_rpp(idx).vlsdrdpp;
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_dados_rpp(idx).vlrgtrpp;
              pr_tab_aplicacoes(vr_idxaplic).tpaplica := 1;
              pr_tab_aplicacoes(vr_idxaplic).tpproapl := 2;   
            ELSE
              IF vr_tab_dados_rpp(idx).vlsdrdpp > 0 THEN
                pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_dados_rpp(idx).vlsdrdpp;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).vlsldapl := 0;
              END IF;
              
              IF vr_tab_dados_rpp(idx).vlrgtrpp > 0 THEN
                pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_dados_rpp(idx).vlrgtrpp;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).sldresga := 0;
              END IF;
            END IF;
            
          END IF;                           
        END LOOP;
      END IF;
        
    ELSE
  
      --Obtem Dados Aplicacoes
      APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper    => pr_cdcooper          --Codigo Cooperativa
                                         ,pr_cdagenci    => pr_cdagenci          --Codigo Agencia
                                         ,pr_nrdcaixa    => pr_nrdcaixa          --Numero do Caixa
                                         ,pr_cdoperad    => pr_cdoperad          --Codigo Operador
                                         ,pr_nmdatela    => pr_nmdatela          --Nome da Tela
                                         ,pr_idorigem    => pr_idorigem          --Origem dos Dados
                                         ,pr_nrdconta    => pr_nrdconta          --Numero da Conta do Associado
                                         ,pr_idseqttl    => 1                    --Sequencial do Titular
                                         ,pr_nraplica    => pr_nraplica          --Numero da Aplicacao
                                         ,pr_cdprogra    => pr_nmdatela          --Nome da Tela
                                         ,pr_flgerlog    => 0 /*FALSE*/          --Imprimir log
                                         ,pr_dtiniper    => NULL                 --Data Inicio periodo   
                                         ,pr_dtfimper    => NULL                 --Data Final periodo
                                         ,pr_vlsldapl    => vr_vlsldapl          --Saldo da Aplicacao
                                         ,pr_tab_saldo_rdca  => vr_tab_saldo_rdca    --Tipo de tabela com o saldo RDCA
                                         ,pr_des_reto    => vr_des_reto          --Retorno OK ou NOK
                                         ,pr_tab_erro    => vr_tab_erro);        --Tabela de Erros
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na temp-table
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';      
        END IF; 
              
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
              
        RAISE vr_exc_erro;
      END IF; 
            
      IF pr_tpaplica IN (7 ,8) THEN
        -- Consulta de novas aplicacoes
        apli0005.pc_busca_aplicacoes(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                    ,pr_cdoperad   => pr_cdoperad     --> Código do Operador
                                    ,pr_nmdatela   => pr_nmdatela     --> Nome da Tela
                                    ,pr_idorigem   => pr_idorigem     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                    ,pr_nrdconta   => pr_nrdconta     --> Número da Conta
                                    ,pr_idseqttl   => 1               --> Titular da Conta
                                    ,pr_nraplica   => pr_nraplica     --> Número da Aplicação - Parâmetro Opcional
                                    ,pr_cdprodut   => 0               --> Código do Produto – Parâmetro Opcional 
                                    ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de Movimento
                                    ,pr_idconsul   => 0               --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                    ,pr_idgerlog   => 0               --> Identificador de Log (0 – Não / 1 – Sim) 																 
                                    ,pr_cdcritic   => vr_cdcritic     --> Código da crítica
                                    ,pr_dscritic   => vr_dscritic     --> Descrição da crítica
                                    ,pr_tab_aplica => vr_tab_aplica); --> Tabela com os dados da aplicação );

        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        IF vr_tab_aplica.count > 0 THEN
          FOR idx in vr_tab_aplica.first..vr_tab_aplica.last LOOP
            IF pr_cddopcao = 'I'  AND 
               vr_tab_aplica(idx).idblqrgt > 0 THEN
              continue;
            END IF;  
          
            vr_idxrdca := vr_tab_saldo_rdca.count + 1;
            vr_tab_saldo_rdca(vr_idxrdca).dsaplica := vr_tab_aplica(idx).dsnomenc;
            vr_tab_saldo_rdca(vr_idxrdca).vlsdrdad := vr_tab_aplica(idx).vlsldrgt;
            vr_tab_saldo_rdca(vr_idxrdca).vllanmto := vr_tab_aplica(idx).vlsldtot;
            vr_tab_saldo_rdca(vr_idxrdca).vlaplica := vr_tab_aplica(idx).vlaplica;
            vr_tab_saldo_rdca(vr_idxrdca).dtvencto := vr_tab_aplica(idx).dtvencto;
            vr_tab_saldo_rdca(vr_idxrdca).indebcre := vr_tab_aplica(idx).dsblqrgt;
            vr_tab_saldo_rdca(vr_idxrdca).cdoperad := vr_tab_aplica(idx).cdoperad;
            vr_tab_saldo_rdca(vr_idxrdca).sldresga := vr_tab_aplica(idx).vlsldrgt;
            vr_tab_saldo_rdca(vr_idxrdca).qtdiaapl := vr_tab_aplica(idx).qtdiaapl;
            vr_tab_saldo_rdca(vr_idxrdca).qtdiauti := vr_tab_aplica(idx).qtdiacar;
            vr_tab_saldo_rdca(vr_idxrdca).txaplmax := vr_tab_aplica(idx).txaplica;
            vr_tab_saldo_rdca(vr_idxrdca).txaplmin := vr_tab_aplica(idx).txaplica;
            vr_tab_saldo_rdca(vr_idxrdca).tpaplrdc := vr_tab_aplica(idx).idtippro;
            IF vr_tab_aplica(idx).idtippro = 1 THEN
              vr_tab_saldo_rdca(vr_idxrdca).tpaplica := 7;
            ELSE
              vr_tab_saldo_rdca(vr_idxrdca).tpaplica := 8;
            END IF;  
            vr_tab_saldo_rdca(vr_idxrdca).dtmvtolt := vr_tab_aplica(idx).dtmvtolt;
            vr_tab_saldo_rdca(vr_idxrdca).nrdocmto := vr_tab_aplica(idx).nraplica;
            vr_tab_saldo_rdca(vr_idxrdca).nraplica := vr_tab_aplica(idx).nraplica;
            vr_tab_saldo_rdca(vr_idxrdca).idtipapl := 'N';
            vr_tab_saldo_rdca(vr_idxrdca).dshistor := vr_tab_aplica(idx).dsnomenc;
          
          END LOOP;
        END IF;                    
      END IF; --> Fim IF pr_tpaplica IN (7 ,8) 
      
      IF vr_tab_saldo_rdca.count > 0 THEN
        FOR idx IN vr_tab_saldo_rdca.first..vr_tab_saldo_rdca.last LOOP
          -- Inclusao apresenta todos que possuen valor saldo
          IF pr_cddopcao = 'I' THEN
            IF vr_tab_saldo_rdca(idx).tpaplica = pr_tpaplica AND
               vr_tab_saldo_rdca(idx).vllanmto > 0           AND
               vr_tab_saldo_rdca(idx).indebcre <> 'B'        THEN
               
              vr_idxaplic := pr_tab_aplicacoes.count + 1;
              pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_saldo_rdca(idx).nraplica;
              pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_saldo_rdca(idx).dtmvtolt;
              pr_tab_aplicacoes(vr_idxaplic).dshistor := vr_tab_saldo_rdca(idx).dsaplica;
              pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_saldo_rdca(idx).vlaplica;
              pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_saldo_rdca(idx).nrdocmto;
              pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_saldo_rdca(idx).dtvencto;
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_saldo_rdca(idx).vllanmto;
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_saldo_rdca(idx).sldresga;
              pr_tab_aplicacoes(vr_idxaplic).tpaplica := pr_tpaplica;
              IF vr_tab_saldo_rdca(idx).idtipapl = 'N' THEN
                pr_tab_aplicacoes(vr_idxaplic).tpproapl := 1;
              ELSE
                pr_tab_aplicacoes(vr_idxaplic).tpproapl := 2; 
              END if;  
            END IF;
          -- demais apresenta a aplicacao idependente do valor
          ELSE
            vr_idxaplic := pr_tab_aplicacoes.count + 1;
            pr_tab_aplicacoes(vr_idxaplic).nraplica := vr_tab_saldo_rdca(idx).nraplica;
            pr_tab_aplicacoes(vr_idxaplic).dtmvtolt := vr_tab_saldo_rdca(idx).dtmvtolt;
            pr_tab_aplicacoes(vr_idxaplic).dshistor := vr_tab_saldo_rdca(idx).dsaplica;
            pr_tab_aplicacoes(vr_idxaplic).vlaplica := vr_tab_saldo_rdca(idx).vlaplica;
            pr_tab_aplicacoes(vr_idxaplic).nrdocmto := vr_tab_saldo_rdca(idx).nrdocmto;
            pr_tab_aplicacoes(vr_idxaplic).dtvencto := vr_tab_saldo_rdca(idx).dtvencto;
            IF vr_tab_saldo_rdca(idx).vllanmto > 0 THEN 
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := vr_tab_saldo_rdca(idx).vllanmto;
            ELSE
              pr_tab_aplicacoes(vr_idxaplic).vlsldapl := 0;
            END IF;
            
            IF vr_tab_saldo_rdca(idx).sldresga > 0 THEN
              pr_tab_aplicacoes(vr_idxaplic).sldresga := vr_tab_saldo_rdca(idx).sldresga;
            ELSE
              pr_tab_aplicacoes(vr_idxaplic).sldresga := 0;
            END IF;
            
          END IF;           
        END LOOP;
      END IF;
    END IF;  
    
    
  EXCEPTION   
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador 
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_buscar_aplicacoes: ' || SQLERRM;  
  END pc_buscar_aplicacoes;
  
  --> Carregar clausulas do contrato
  PROCEDURE pc_carrega_clausulas (pr_ddmvtolt IN VARCHAR2,
                                  pr_dsddmvto IN VARCHAR2,
                                  pr_dtdpagto IN DATE,
                                  pr_nrctremp IN NUMBER, 
                                  pr_cdc      IN VARCHAR2,
                                  pr_dsaplica IN VARCHAR2,
                                  pr_dscpfgar IN VARCHAR2,
                                  pr_nmprigar IN VARCHAR2,
                                  pr_nrctagar IN NUMBER,
                                  pr_nmdavali IN VARCHAR2,
                                  pr_dscpfavl IN VARCHAR2,
                                  pr_nrctaavl IN NUMBER,
                                  --> automovel
                                  pr_dsbemfin IN VARCHAR2,
                                  pr_nrrenava IN VARCHAR2,
                                  pr_tpchassi IN VARCHAR2,
                                  pr_nrdplaca IN VARCHAR2,
                                  pr_ufdplaca IN VARCHAR2,
                                  pr_dscorbem IN VARCHAR2,
                                  pr_nranobem IN VARCHAR2,
                                  pr_nrmodbem IN VARCHAR2,
                                  pr_uflicenc IN VARCHAR2,
                                  pr_dscpfpro IN VARCHAR2,
                                  pr_dsbemant IN VARCHAR2,
                                  pr_dscatbem IN VARCHAR2,
                                  pr_dstipbem IN VARCHAR2,
                                  pr_dsmarbem IN VARCHAR2,
                                  pr_dschassi IN VARCHAR2,
                                  pr_vlrdobem in number,
                                  pr_dspropri IN VARCHAR2,
                                  pr_dstpcomb IN VARCHAR2,
                                  pr_tab_clau_adi OUT typ_tab_clau_adi) IS
  
    vr_tab_clau_adi typ_tab_clau_adi;
    vr_dscontra VARCHAR2(100);
  BEGIN
    IF pr_cdc = 'N' THEN
      vr_dscontra := '/Contrato de Credito Simplificado';    
    END IF;
  
    vr_tab_clau_adi.delete;
    
    --> Tipo 1 - Alteracao Data do Debito
    vr_tab_clau_adi(1).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - Alteração da data de pagamento, prevista no item 1.9. da ' ||
                          'Cédula de Credito Bancário ou item 4.3. do Termo de Adesão ao Contrato de ' ||
                          'Credito Simplificado, que passa a vigorar com a seguinte redação: debito em '||
                          'conta corrente sempre no dia '|| pr_ddmvtolt || pr_dsddmvto;
                          
    vr_tab_clau_adi(1).clausula(2) 
                       := 'CLAUSULA SEGUNDA - Alteração da data de vencimento da primeira parcela/debito, '||
                          'prevista no item 1.10. da Cédula de Credito Bancário ou item 4.4. do '||
                          'Termo de Adesão ao Contrato de Credito Simplificado, que passa a ser '||
                          to_char(pr_dtdpagto,'DD/MM/RRRR') ||'.';
  
    vr_tab_clau_adi(1).clausula(3) 
                       := 'CLAUSULA TERCEIRA - Em função da alteração da data do vencimento fica '||
                          'automaticamente prorrogado o prazo de vigência e o numero de prestações estabelecidas '||
                          'no item 1.7. da Cédula de Credito Bancário ou item 4.2. do Termo de Adesão ao '||
                          'Contrato de Credito Simplificado, gerando saldo remanescente a ser liquidado pelo ' ||
                          'Emitente/Cooperado(a) e Devedores Solidários.';
                       
    vr_tab_clau_adi(1).clausula(4) 
                       := 'CLAUSULA QUARTA - Ficam ratificadas todas as demais condições da Cédula de Credito ' ||
                          'Bancário/Contrato de Credito Simplificado ora aditado (a), em ' ||
                          'tudo o que não expressamente modificado no presente termo.';

                      
  
    --> Tipo 2- Aplicacao Vinculada
    vr_tab_clau_adi(2).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - O Emitente/Cooperado(a) compromete-se a manter em aplicação(ões) '||
                          'financeiras perante esta Cooperativa de Credito, valor que somado ao saldo das '||
                          'cotas de capital do mesmo, atinjam no mínimo o equivalente ao saldo da divida em '||
                          'dinheiro, certa, liquida e exigível emprestado na Cédula de Credito Bancário'||vr_dscontra ||
                          ' n. '|| pr_nrctremp || ', ate a sua total liquidação.';
    
    vr_tab_clau_adi(2).clausula(2) 
                       := 'CLAUSULA SEGUNDA - A(s) aplicação(ões) com o(s) numero(s) '||
                          pr_dsaplica ||', mantida(s) pelo Emitente/Cooperado(a) junto a Cooperativa, '||
                          'tornar-se-á(ao) aplicação(ões) vinculada(s) ate que se cumpram todas as '||
                          'obrigações assumidas na Cédula de Credito Bancário'||vr_dscontra ||' original.';
                       
    vr_tab_clau_adi(2).clausula(3) 
                       := 'CLAUSULA TERCEIRA - O não cumprimento das obrigacoes assumidas no presente termo '||
                          'aditivo e na Cédula de Credito Bancário'|| vr_dscontra ||' principal, '||
                          'bem com o inadimplemento de 02 (duas) prestações mensais consecutivas '||
                          'ou alternadas, independentemente de qualquer notificação judicial ou ' ||
                          'extrajudicial, implicara no vencimento antecipado de todo o saldo devedor do '||
                          'empréstimo/financiamento servindo a(s) referida(s) aplicação(ões) vinculada(s) para a '||
                          'imediata liquidação do saldo devedor.';
  
    vr_tab_clau_adi(2).clausula(4) 
                       := 'CLAUSULA QUARTA - Caso a(s) aplicação(ões) venham a ser utilizada(s) para liquidação ' ||
                          'do saldo devedor do empréstimo/financiamento, a(s) mesma(s) poderão '||
                          'ser movimentada(s) livremente pela Cooperativa, a qualquer tempo, independente de '||
                          'notificação judicial ou extrajudicial.';
    
    vr_tab_clau_adi(2).clausula(5) 
                       := 'CLAUSULA QUINTA - A(s) aplicação(ões) acima enumarada(s), podera(ão) ser liberada(s) '||
                          'parcialmente, e se possível, a medida que o  saldo devedor do ' ||
                          'empréstimo/financiamento for sendo liquidado.'; 
  
    vr_tab_clau_adi(2).clausula(6) 
                       := 'CLAUSULA SEXTA - Ficam ratificadas todas as demais condições da Cédula de Credito ' ||
                          'Bancario'||vr_dscontra ||' ora aditado(a), em tudo o que não expressamente modificado no presente termo.';
 
  
  
    --> Tipo 3- Aplicacao Vinculada Terceiro
    vr_tab_clau_adi(3).clausula(1) 
                       := 'CLAUSULA PRIMEIRA - Para garantir o cumprimento das obrigações assumidas na Cédula de '||
                          'Credito Bancário'||vr_dscontra ||' ora aditado(a), '||
                          'comparece como Interveniente Garantidor(a) '|| pr_nmprigar || 
                          ', inscrito no CPF/CNPJ sob o n. '|| pr_dscpfgar ||', titular da conta corrente '|| pr_nrctagar ||
                          ', mantida perante esta Cooperativa.';
      
    vr_tab_clau_adi(3).clausula(2) 
                       := 'CLAUSULA SEGUNDA - O(A) Interveniente Garantidor(a) compromete-se a manter em '||
                          'aplicação(ões) financeiras perante esta Cooperativa de Credito, valor ' ||
                          'que somado ao saldo das cotas de capital do mesmo, atinjam no mínimo ' ||
                          'o equivalente ao saldo da divida em dinheiro, certa, liquida e exigível emprestado ' ||
                          'na Cédula de Credito Bancário'||vr_dscontra ||', ate a sua total ' ||
                          'liquidação.';
  
    vr_tab_clau_adi(3).clausula(3) 
                      := 'CLAUSULA TERCEIRA - A(s) aplicação(ões) com o(s) numero(s) '||
                         pr_dsaplica ||', mantida(s) pelo Interveniente '||     
                         'Garantidor(a) junto a Cooperativa, tornar-se-á(ão) aplicação(ões) '||
                         'vinculada(s) ate que se cumpram todas as obrigações assumidas na Cédula de Credito '||
                         'Bancário'||vr_dscontra ||' original.';
                         
    vr_tab_clau_adi(3).clausula(4) 
                      := 'CLAUSULA QUARTA - O não cumprimento das obrigações assumidas no presente termo '||
                         'aditivo e na Cédula de Credito Bancário'||vr_dscontra ||' principal, '||
                         'bem com o inadimplemento de 02(duas) prestações mensais consecutivas '||
                         'ou alternadas, independentemente de qualquer notificação judicial ou '||
                         'extrajudicial, implicara no vencimento antecipado de todo o saldo devedor do '||
                         'empréstimo/financiamento servindo a(s) referida(s) aplicação(ões) vinculada(s) para a '||
                         'imediata liquidação do saldo devedor.';
                      
    vr_tab_clau_adi(3).clausula(5) 
                      := 'CLAUSULA QUINTA - Caso a(s) aplicação(ões) venham a ser utilizada(s) para liquidação ' ||
                         'do saldo devedor do empréstimo/financiamento, a(s) mesma(s) poderão '||
                         'ser movimentada(s) livremente pela Cooperativa, a qualquer tempo, sem qualquer '||
                         'notificação judicial ou extrajudicial, independentemente de notificação judicial '||
                         'ou extrajudicial.';
                      
    vr_tab_clau_adi(3).clausula(6) 
                      := 'CLAUSULA SEXTA - A(s) aplicação(ões) acima enumarada(s), podera(ao) ser liberada(s) '||
                         'parcialmente, e se possível, a medida que o saldo devedor do ' ||
                         'empréstimo/financiamento for sendo liquidado.';                   
                      
    vr_tab_clau_adi(3).clausula(7) 
                      := 'CLAUSULA SETIMA - Ficam ratificadas todas as demais condições da Cédula de Credito ' ||
                         'Bancário'||vr_dscontra ||' ora aditado(a), em tudo o que não expressamente modificado no presente termo.';                   

                      
    --> Tipo 4 - Inclusao de Fiador/Avalista
      
    vr_tab_clau_adi(4).clausula(1) 
                      := 'CLAUSULA PRIMEIRA - Para garantir o cumprimento das obrigações assumidas na Cédula '||
                         'de Credito Bancário'||vr_dscontra ||' ora aditado(a), '||
                         'comparece como Devedor Solidário/Fiador '|| pr_nmdavali ||
                         ', inscrito no CPF/CNPJ sob n. '|| pr_dscpfavl ||', titular da conta corrente n. '||
                         gene0002.fn_mask_conta(pr_nrctaavl) ||', mantida perante esta Cooperativa.';
                      
    vr_tab_clau_adi(4).clausula(2) 
                      := 'CLAUSULA SEGUNDA - O Devedor Solidário/Fiador declara-se solidariamente responsáveis '||
                         'com o(a) Emitente/Cooperado pela integral e pontual liquidação de '||
                         'todas as suas obrigações, principais e acessorias, decorrentes deste ajuste, nos '||
                         'termos dos artigos 275 e seguintes do Código Civil Brasileiro, renunciando expressamente, '||
                         'os benefícios de ordem que trata o artigo 827, em conformidade com o artigo 282, incisos '||
                         ' I e II, todos também do Código Civil Brasileiro.';                  
                      
    vr_tab_clau_adi(4).clausula(3) 
                      := 'CLAUSULA TERCEIRA - O Devedor Solidário, ao assinar o presente termo aditivo declara '||
                         'ter lido previamente e ter conhecimento das Condições Especificas da Cédula de '||
                         'Credito Bancário';
    IF pr_cdc = 'N' THEN                      
      vr_tab_clau_adi(4).clausula(3) := vr_tab_clau_adi(4).clausula(3) ||
                                        '/Termo de Adesão ao contrato de Credito Simplificado original(naria), ';
    END IF;                     
    vr_tab_clau_adi(4).clausula(3) := vr_tab_clau_adi(4).clausula(3) || 
                         'cujas disposições se aplicam completamente a este instrumento, com as '||
                         'quais concorda incondicionalmente, ratificando-as integralmente neste ato, não '||
                         'possuindo duvidas com relação a quaisquer de suas clausulas.';
        
    
    --> Tipo 5- Substituicao de Veiculo
    vr_tab_clau_adi(5).clausula(1) 
                      := '1. Garantia: As partes resolvem de comum e recíproco acordo, substituir o bem '||pr_dsbemant||'deixado em garantia, '||
                         'descrito na Cédula de Crédito Bancário Contrato de Crédito Simplificado ora aditado(a), para inclusão de nova '||
                         'garantia constituída em favor da COOPERATIVA, a alienação fiduciária do veículo abaixo descrito e caracterizado, '||
                         'declarando neste ato que o bem encontra-se livre de quaisquer ônus.<br>';
                      
    if pr_dscatbem is not null then
      vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'ESPÉCIE: '||pr_dscatbem||'<br>';
    end if;
    if pr_dstipbem is not null then
      vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'TIPO: '||pr_dstipbem||'<br>';
    end if;
    if pr_dsmarbem is not null then
      vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'MARCA/MODELO: '||pr_dsmarbem||'/'||pr_dsbemfin||'<br>';
    else
      vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'MARCA/MODELO: '||pr_dsbemfin||'<br>';
    end if;
    --
    vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'PLACA: '||pr_nrdplaca||'<br>'||
                                     'RENAVAM: '||pr_nrrenava||'<br>'||
                                     'CHASSI: '||pr_dschassi||'<br>'||
                                     'UF PLACA: '||pr_ufdplaca||'<br>'||
                                     'UF LICENCIAMENTO: '||pr_uflicenc||'<br>'||
                                     'COR: '||pr_dscorbem||'<br>'||
                                     'ANO FAB: '||pr_nranobem||'<br>'||
                                     'ANO MOD: '||pr_nrmodbem||' '||pr_dstpcomb||'<br>';
    --
    if pr_vlrdobem is not null then
      vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'VALOR DE MERCADO: R$ '||to_char(pr_vlrdobem, 'fm999g999g990d00')||'<br>';
    end if;
    --
    vr_tab_clau_adi(5).clausula(1) := vr_tab_clau_adi(5).clausula(1)||
                                     'PROPRIETÁRIO(A): '||pr_dspropri;
    
    vr_tab_clau_adi(5).clausula(2) 
                      := /*'CLAUSULA SEGUNDA - Ficam ratificadas todas as demais condições da Cédula de Credito '||
                         'Bancário'||vr_dscontra ||' ora aditado (a), em '||
                         'tudo o que não expressamente modificado no presente termo.';*/
                         '1.1 O(A) PROPRIETÁRIO(A) declara estar ciente de que deverá comparecer ao Departamento de Trânsito para requerer a expedição '||
                         'do novo Certificado de Registro de Veículo – CRV, contendo o ônus de alienação fiduciária em favor da COOPERATIVA, o qual deverá '||
                         'ser entregue à COOPERATIVA, dentro do prazo máximo de 15 (quinze) dias, contados da data da assinatura deste Termo Aditivo.<br>'||
                         '1.2 O(A) PROPRIETÁRIO(A) será responsável pelo pagamento de todas as despesas decorrentes do registro e da liberação da garantia '||
                         'prevista no Contrato ora aditado, inclusive na hipótese de cancelamento de referida operação.<br>'||
                         '1.3 O(A) PROPRIETÁRIO(A) obriga-se a não alterar qualquer característica do bem, nem o utiliza-lo de modo diverso do fim a que se '||
                         'destina, salvo mediante prévia anuência da COOPERATIVA, aceitando o encargo de fieis depositário do veículo dado em garantia, sem '||
                         'qualquer ônus para a COOPERATIVA.<br>'||
                         '1.4 O(A) PROPRIETÁRIO(A) obriga-se a contratar seguro do veículo alienado fiduciariamente, por valor e prazo igual ou superior ao '||
                         'do contrato original, na mais ampla forma contra todos os riscos a que possa estar sujeito o veículo, designando a COOPERATIVA como '||
                         'beneficiária da respectiva apólice, a qual deverá ser entregue à COOPERATIVA no prazo de 10 (dez) dias da data da assinatura deste '||
                         'aditivo.<br>'||
                         '1.5 A indenização paga pela seguradora, será aplicada na amortização ou liquidação das obrigações assumidas no Contrato ora aditado, '||
                         'revertendo ao(à) PROPRIETÁRIO(A), após a quitação do saldo devedor, eventual valor excedente apurado, sendo que se o valor do seguro '||
                         'não bastar para o pagamento do crédito da COOPERATIVA, o(a) COOPERADO(A) continuará responsável pelo pagamento do saldo devedor.<br>'||
                         '1.6 Se houver atraso no pagamento ou vencimento antecipado das obrigações decorrentes do Contrato original, a COOPERATIVA poderá '||
                         'vender ou negociar o veículo dado em garantia e aplicar o produto da venda na amortização ou liquidação da dívida, podendo praticar '||
                         'todos os atos necessários a essa finalidade.<br>'||
                         '1.7 O(A) PROPRIETÁRIO(A) autoriza desde já, que seja realizada por parte da COOPERATIVA, a inserção do gravame sobre o bem acima '||
                         'indicado, permanecendo, no entanto, responsável por todas as obrigações fiscais relativas ao referido veículo.<br>'||
                         '2. Ficam ratificadas todas as demais cláusulas e condições Cédula de Crédito Bancário Contrato de Crédito Simplificado nº '||pr_nrctremp||
                         ', em tudo o que não expressamente modificado no presente termo.';

    pr_tab_clau_adi := vr_tab_clau_adi;
  END;
  
  -- Bem substituido
  FUNCTION fn_busca_chassi_substituido(pr_cdcooper in crapbpr.cdcooper%type,
                                       pr_nrdconta in crapbpr.nrdconta%type,
                                       pr_tpctrpro in crapbpr.tpctrpro%type,
                                       pr_nrctrpro in crapbpr.nrctrpro%type,
                                       pr_idseqbem in crapbpr.idseqbem%type,
                                       pr_dscritic out varchar2) RETURN varchar2 IS
  /*---------------------------------------------------------------------------------------------------------------
                           
    Programa : fn_busca_chassi_substituido
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Daniel - Envolti
    Data     : Setembro/2018                         Ultima atualizacao: 18/09/2018
                                    
        Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Buscar o bem que foi substituído por outro
    
    Alterações : xx/xx/xxxx - 
    
    -------------------------------------------------------------------------------------------------------------*/    
    cursor cr_crapbpr is
      select c.dschassi
        from crapbpr c
       where c.cdcooper = pr_cdcooper
         and c.nrdconta = pr_nrdconta
         and c.tpctrpro = pr_tpctrpro
         and c.nrctrpro = pr_nrctrpro
         and c.idseqbem = pr_idseqbem;
    --
    vr_dsbemsub   varchar2(250);
  BEGIN
    open cr_crapbpr;
      fetch cr_crapbpr into vr_dsbemsub;
      if cr_crapbpr%notfound then
        close cr_crapbpr;
        return(null);
      end if;
    close cr_crapbpr;
    --
    return(vr_dsbemsub);
  exception
    when others then
      pr_dscritic := 'Erro ao buscar o bem substituído: '||sqlerrm;
      return(null);
  END;
  
  FUNCTION fn_busca_dados_proprietario(pr_cdcooper in crapadi.cdcooper%type,
                                       pr_nrdconta in crapadi.nrdconta%type,
                                       pr_nrctremp in crapadi.nrctremp%type,
                                       pr_nrcpfcgc in crapadi.nrcpfcgc%type,
                                       pr_dscritic out varchar2) RETURN varchar2 IS
    -- Buscar se existe Interveniente
    cursor cr_crapavt is
      select c.nmdavali,
             n.dsnacion,
             c.dsproftl,
             case c.cdestcvl
               when  1 then 'SOLTEIRO(A)'
               when  2 then 'CASADO(A)-COMUNHAO UNIVERSAL'
               when  3 then 'CASADO(A)-COMUNHAO PARCIAL'
               when  4 then 'CASADO(A)-SEPARACAO DE BENS'
               when  5 then 'VIUVO(A)'
               when  6 then 'SEPARADO(A) JUDICIALMENTE'
               when  7 then 'DIVORCIADO(A)'
               when  8 then 'CASADO(A)-REGIME TOTAL'
               when  9 then 'CAS REGIME MISTO OU ESPECIAL'
               when 11 then 'CASADO(A)-PART.FINAL AQUESTOS'
               else null
             end dsestcvl,
             c.nrcpfcgc,
             c.inpessoa,
             c.dsendres##1,
             c.nrendere,
             c.dsendres##2 nmbairro,
             c.nmcidade,
             c.cdufresd,
             c.nrcepend,
             c.nrdconta
        from crapnac n,
             crapavt c
       where c.cdcooper = pr_cdcooper
         and c.tpctrato = 9
         and c.nrdconta = pr_nrdconta
         and c.nrctremp = pr_nrctremp
         and c.nrcpfcgc = pr_nrcpfcgc
         and n.cdnacion = c.cdnacion;
    vr_crapavt   cr_crapavt%rowtype;
    --
    cursor cr_crapass is
      select c.nmprimtl,
             n.dsnacion,
             c.dsproftl,
             case t.cdestcvl
               when  1 then 'SOLTEIRO(A)'
               when  2 then 'CASADO(A)-COMUNHAO UNIVERSAL'
               when  3 then 'CASADO(A)-COMUNHAO PARCIAL'
               when  4 then 'CASADO(A)-SEPARACAO DE BENS'
               when  5 then 'VIUVO(A)'
               when  6 then 'SEPARADO(A) JUDICIALMENTE'
               when  7 then 'DIVORCIADO(A)'
               when  8 then 'CASADO(A)-REGIME TOTAL'
               when  9 then 'CAS REGIME MISTO OU ESPECIAL'
               when 11 then 'CASADO(A)-PART.FINAL AQUESTOS'
               else null
             end dsestcvl,
             c.nrcpfcgc,
             c.inpessoa,
             e.dsendere,
             e.nrendere,
             e.nmbairro,
             e.nmcidade,
             e.cdufende,
             e.nrcepend,
             c.nrdconta
        from crapnac n,
             crapenc e,
             crapttl t,
             crapass c
       where (   (    nvl(pr_nrcpfcgc, 0) <> 0
                  and c.nrcpfcgc = pr_nrcpfcgc)
              or (    nvl(pr_nrcpfcgc, 0) = 0
                  and c.cdcooper = pr_cdcooper
                  and c.nrdconta = pr_nrdconta))
         and n.cdnacion = c.cdnacion
         and t.nrdconta(+) = c.nrdconta
         and t.cdcooper(+) = c.cdcooper
         and t.idseqttl(+) = 1
         and e.cdcooper = c.cdcooper
         and e.nrdconta = c.nrdconta
         and e.idseqttl = 1
         and e.tpendass = decode(c.inpessoa,1,10,9);
    vr_crapass   cr_crapass%rowtype;
    --
    vr_dspropri  varchar2(1000);
  BEGIN
    -- Testar se o CPF está na lista de avalistas ou intervenientes
    open cr_crapavt;
      fetch cr_crapavt into vr_crapavt;
      -- Se não encontrar
      if cr_crapavt%notfound then 
        -- Verificar se o CPF é de algum Cooperado, ou então buscar pela conta
        open cr_crapass;
          fetch cr_crapass into vr_crapass;
          -- Se não encontrar
          if cr_crapass%notfound then 
            -- Gerar critica
            pr_dscritic := 'Não existem informações para o proprietário do bem';
            close cr_crapavt;
            close cr_crapass;
            return(null);
          else
            vr_dspropri := vr_crapass.nmprimtl||', ';
            if trim(vr_crapass.dsnacion) is not null and
               vr_crapass.inpessoa = 1 then
              vr_dspropri := vr_dspropri||
                           vr_crapass.dsnacion||', ';
            end if;
            if trim(vr_crapass.dsproftl) is not null then
              vr_dspropri := vr_dspropri||
                           vr_crapass.dsproftl||', ';
            end if;
            if trim(vr_crapass.dsestcvl) is not null then
              vr_dspropri := vr_dspropri||
                           vr_crapass.dsestcvl||', ';
            end if;
            vr_dspropri := vr_dspropri||
                           'inscrito(a) no CPF/CNPJ sob nº '||gene0002.fn_mask_cpf_cnpj(vr_crapass.nrcpfcgc,
                                                                                        vr_crapass.inpessoa)||', '||
                           'com endereço na '||vr_crapass.dsendere||', '||
                           'nº '||vr_crapass.nrendere||', '||
                           'bairro '||vr_crapass.nmbairro||', '||
                           'da cidade de '||vr_crapass.nmcidade||'/'||vr_crapass.cdufende||', '||
                           'CEP '||gene0002.fn_mask_cep(vr_crapass.nrcepend)||', '||
                           'titular da conta corrente nº '||gene0002.fn_mask_conta(vr_crapass.nrdconta)||', '||
                           'na qualidade de COOPERADO ou INTERVENIENTE GARANTIDOR.';
          end if;
        close cr_crapass;
      else
        vr_dspropri := vr_crapavt.nmdavali||', ';
        if trim(vr_crapavt.dsnacion) is not null and
           vr_crapavt.inpessoa = 1 then
          vr_dspropri := vr_dspropri||
                       vr_crapavt.dsnacion||', ';
        end if;
        if trim(vr_crapavt.dsproftl) is not null then
          vr_dspropri := vr_dspropri||
                       vr_crapavt.dsproftl||', ';
        end if;
        if trim(vr_crapavt.dsestcvl) is not null then
          vr_dspropri := vr_dspropri||
                       vr_crapavt.dsestcvl||', ';
        end if;
        vr_dspropri := vr_dspropri||
                       'inscrito(a) no CPF/CNPJ sob nº '||gene0002.fn_mask_cpf_cnpj(vr_crapavt.nrcpfcgc,
                                                                                    vr_crapavt.inpessoa)||', '||
                       'com endereço na '||vr_crapavt.dsendres##1||', '||
                       'nº '||vr_crapavt.nrendere||', '||
                       'bairro '||vr_crapavt.nmbairro||', '||
                       'da cidade de '||vr_crapavt.nmcidade||'/'||vr_crapavt.cdufresd||', '||
                       'CEP '||gene0002.fn_mask_cep(vr_crapavt.nrcepend)||', '||
                       'na qualidade de COOPERADO ou INTERVENIENTE GARANTIDOR.';
      end if;
    close cr_crapavt;
    return(vr_dspropri);
  exception
    when others then
      pr_dscritic := 'Erro ao buscar dados do proprietário: '||sqlerrm;
      return(null);
  END;
  
  --> Buscar dados do aditivo do emprestimo
  PROCEDURE pc_busca_dados_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           ,pr_cddopcao   IN VARCHAR2              --> Codigo da opcao
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_dtmvtolx   IN crapdat.dtmvtolt%TYPE --> Data de consulta
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_tpaplica   IN craprda.tpaplica%TYPE --> tipo de aplicacao
                           ,pr_nrctagar   IN crapass.nrdconta%TYPE --> conta garantia
                           ,pr_tpctrato   IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                           ,pr_flgpagin   IN INTEGER               --> Flag (0-false 1-true)
                           ,pr_nrregist   IN INTEGER               --> Numero de registros a serem retornados
                           ,pr_nriniseq   IN INTEGER               --> Registro inicial
                           ,pr_flgerlog   IN INTEGER               --> Gerar log(0-false 1-true)
                           --------> OUT <--------
                           ,pr_qtregist       OUT INTEGER             --> Retornar quantidad de registros
                           ,pr_tab_aditiv     OUT typ_tab_aditiv      --> Retornar dados do aditivo
                           ,pr_tab_aplicacoes OUT typ_tab_aplicacoes  --> Retornar dados das aplicações 
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descrição da crítica
                                    
    /* .............................................................................
    
        Programa: pc_busca_dados_aditiv    (antiga: b1wgen0115.p/Busca_Dados)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: 30/07/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em buscar dados do aditivo do emprestimo
    
        Observacao: -----
    
        Alteracoes: 23/01/2017 - Quando garantia do aditivo é aplicação de
                                 terceiros, passar número da conta como parâmetro
                                 ao invés de zero. (AJFink SD#597917)

                    01/11/2017 - Ajustes conforme inclusao do campo tipo de contrato.
                                 (Jaison/Marcos Martini - PRJ404)
                                 
                    30/07/2018 - P442 - Inclusão de campos do projeto (Marcos-Envolti)

    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
        
    
    vr_cdaditiv        crapadt.cdaditiv%TYPE;    
    vr_nrdconta        crapass.nrdconta%TYPE;
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrregist        INTEGER;
    vr_nrdrowid        ROWID;
    
    vr_idxaditv        PLS_INTEGER;
    vr_fcrapadt        BOOLEAN;    
    vr_fcrapadi        BOOLEAN;
    
    ---------->> CURSORES <<--------   
    
    --> Buscar aditivo
    CURSOR cr_crapadi IS
      SELECT *
        FROM crapadi
       WHERE crapadi.cdcooper = pr_cdcooper
         AND crapadi.nrdconta = pr_nrdconta
         AND crapadi.nrctremp = pr_nrctremp
         AND crapadi.nraditiv = pr_nraditiv
         AND crapadi.tpctrato = pr_tpctrato;
    rw_crapadi cr_crapadi%ROWTYPE;
    
    --> Buscar aditivo
    CURSOR cr_crapadi2 IS
      SELECT *
        FROM crapadi
       WHERE crapadi.cdcooper = pr_cdcooper
         AND crapadi.nrdconta = pr_nrdconta
         AND crapadi.nrctremp = pr_nrctremp
         AND crapadi.nraditiv = pr_nraditiv
         AND crapadi.nrsequen = 1
         AND crapadi.tpctrato = pr_tpctrato;
    
    --> Buscar dados associado
    CURSOR cr_crapass IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;  
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta
        FROM crawepr epr            
       WHERE epr.cdcooper = pr_cdcooper
         AND ((nvl(pr_nrdconta,0) <> 0 AND epr.nrdconta = pr_nrdconta) OR
              (nvl(pr_nrdconta,0) = 0))
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;   
    
    --> Buscar dados emprestimo
    CURSOR cr_crapepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta,
             epr.flgpagto,
             epr.tpdescto
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;     
    
    --> Buscar aditivos contratuais
    CURSOR cr_crapadt IS
      SELECT *
        FROM crapadt adt
       WHERE adt.cdcooper = pr_cdcooper
         AND adt.nrdconta = nvl(nullif(pr_nrdconta,0),adt.nrdconta)
         AND adt.nrctremp = nvl(nullif(pr_nrctremp,0),adt.nrctremp) 
         AND adt.dtmvtolt >= nvl(pr_dtmvtolx,adt.dtmvtolt)
         AND adt.tpctrato = pr_tpctrato;
    
    --> Buscar aditivos contratuais
    CURSOR cr_crapadt2 IS
      SELECT *
        FROM crapadt adt
       WHERE adt.cdcooper = pr_cdcooper
         AND adt.nrdconta = pr_nrdconta
         AND adt.nrctremp = pr_nrctremp
         AND adt.nraditiv = pr_nraditiv
         AND adt.tpctrato = pr_tpctrato;
    rw_crapadt cr_crapadt2%ROWTYPE;
    
    --> Buscar aditivos contratuais
    CURSOR cr_crapadt3(pr_dsbemfin IN crapbpr.dsbemfin%TYPE
                      ,pr_dschassi IN crapbpr.dschassi%TYPE
                      ,pr_nrdplaca IN crapbpr.nrdplaca%TYPE
                      ,pr_dscorbem IN crapbpr.dscorbem%TYPE
                      ,pr_nranobem IN crapbpr.nranobem%TYPE
                      ,pr_nrmodbem IN crapbpr.nrmodbem%TYPE
                      ,pr_nrrenava IN crapbpr.nrrenava%TYPE
                      ,pr_tpchassi IN crapbpr.tpchassi%TYPE
                      ,pr_ufdplaca IN crapbpr.ufdplaca%TYPE
                      ,pr_uflicenc IN crapbpr.uflicenc%TYPE) IS
      SELECT 1
        FROM crapadt
        JOIN crapadi
          ON crapadi.cdcooper = crapadt.cdcooper
         AND crapadi.nrdconta = crapadt.nrdconta
         AND crapadi.nrctremp = crapadt.nrctremp
         AND crapadi.nraditiv = crapadt.nraditiv
       WHERE crapadt.cdcooper = pr_cdcooper
         AND crapadt.nrdconta = pr_nrdconta
         AND crapadt.nrctremp = pr_nrctremp
         AND crapadt.cdaditiv = 5
         AND crapadi.dsbemfin = pr_dsbemfin
         AND crapadi.dschassi = pr_dschassi
         AND crapadi.nrdplaca = pr_nrdplaca
         AND crapadi.dscorbem = pr_dscorbem
         AND crapadi.nranobem = pr_nranobem
         AND crapadi.nrmodbem = pr_nrmodbem
         AND crapadi.nrrenava = pr_nrrenava
         AND crapadi.tpchassi = pr_tpchassi
         AND crapadi.ufdplaca = pr_ufdplaca
         AND crapadi.uflicenc = pr_uflicenc;
    rw_crapadt3 cr_crapadt3%ROWTYPE;
    
    --> Buscar bens da proposta de emprestimo do cooperado.
    CURSOR cr_crapbpr IS
      SELECT bpr.idseqbem
            ,bpr.dsmarbem
            ,bpr.dsbemfin
            ,bpr.nrcpfbem
            ,bpr.dschassi
            ,bpr.nrdplaca
            ,bpr.dscorbem
            ,bpr.nranobem
            ,bpr.nrmodbem
            ,bpr.nrrenava
            ,bpr.tpchassi
            ,bpr.ufdplaca
            ,bpr.uflicenc
        FROM crapbpr bpr
       WHERE bpr.cdcooper = pr_cdcooper
         AND bpr.nrdconta = pr_nrdconta
         AND bpr.tpctrpro = 90
         AND bpr.nrctrpro = pr_nrctremp
         AND bpr.flgalien = 1; --TRUE
         
    --> Buscar dados do contrato de limite
    CURSOR cr_craplim IS
      SELECT lim.nrctrlim,
             lim.dtinivig, 
             lim.nrdconta 
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.tpctrlim = pr_tpctrato 
         AND((nvl(pr_nrdconta,0) <> 0 AND lim.nrdconta = pr_nrdconta) OR
             (nvl(pr_nrdconta,0) = 0))
         AND lim.nrctrlim = pr_nrctremp;
    rw_craplim cr_craplim%ROWTYPE;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  BEGIN
  
    vr_dscritic := NULL;
    vr_cdcritic := 0;
    vr_nrdconta := 0;
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Busca Aditivo Contratual de Emprestimo.';
    vr_nrregist := pr_nrregist;
    vr_cdaditiv := pr_cdaditiv;
    
    pr_tab_aditiv.delete;
    pr_tab_aplicacoes.delete;
    
    --> Validar opções existentes
    IF pr_cddopcao NOT IN ('C','E','I','V','X') THEN
      vr_cdcritic := 14; -- 014 - Opcao errada.
      RAISE vr_exc_erro;
    END IF;
    
    --> Visualizar
    IF pr_cddopcao = 'V' THEN
      IF pr_nrdconta <> 0 THEN
        --> Validar associado
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN 
          CLOSE cr_crapass;
          vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapass;
        END IF;      
      END IF;
      
      IF pr_nrctremp <> 0 THEN
        IF pr_tpctrato = 90 THEN
        --> Validar emprestimo
        OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr;
          vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crawepr;
          END IF;
        ELSE
          --> Validar Contrato de Limite
          OPEN cr_craplim;
          FETCH cr_craplim INTO rw_craplim;
          IF cr_craplim%NOTFOUND THEN
            CLOSE cr_craplim;
            vr_dscritic := 'Contrato de Limite nao encontrado';
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_craplim;
          END IF;
        END IF;
      END IF;
      
      --> Buscar aditivos contratuais
      FOR rw_crapadt IN cr_crapadt LOOP
        pr_qtregist := nvl(pr_qtregist,0) + 1;
        
        --> Controlar paginacao
        IF pr_flgpagin =1                 AND
           ((pr_qtregist < pr_nriniseq) OR
            (pr_qtregist > (pr_nriniseq + pr_nrregist))) THEN
          continue;
        END IF;
        
        IF vr_nrregist > 0 or
           pr_flgpagin = 0 THEN
          
          vr_idxaditv := pr_tab_aditiv.COUNT + 1;
          pr_tab_aditiv(vr_idxaditv).nrdconta := rw_crapadt.nrdconta;
          pr_tab_aditiv(vr_idxaditv).nrctremp := rw_crapadt.nrctremp;
          pr_tab_aditiv(vr_idxaditv).dsaditiv := vr_tab_dsaditiv(rw_crapadt.cdaditiv);
          pr_tab_aditiv(vr_idxaditv).nraditiv := rw_crapadt.nraditiv;
          pr_tab_aditiv(vr_idxaditv).dtmvtolt := rw_crapadt.dtmvtolt;          
        END IF;   
        
      END LOOP;
      
    -- C-Consulta, E-Exclusao e I-Inclusao 
    ELSIF pr_cddopcao IN ('C','E','I') THEN
      
      -- Se NAO for Emprestimo/Financiamento e NAO for
      -- Cobertura de Aplicacao Vinculada a Operacao
      IF pr_tpctrato <> 90 AND
         pr_cdaditiv <> 9  THEN
         vr_dscritic := 'TIPO DE ADITIVO NAO ' || (CASE WHEN pr_cddopcao = 'C' THEN 'ENCONTRADO' ELSE 'PERMITIDO' END);
         RAISE vr_exc_erro;
      END IF;
      
      -- Não permitir a exclusão de aditivos de veículos (opção 5) adicionados no sistema.
      if pr_cddopcao = 'E' AND pr_cdaditiv = 5 then
         vr_dscritic := 'Exclusao de aditivo de substituicao de veiculo nao permitida';
         RAISE vr_exc_erro;
      end if;
      
      --> Validar associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;       
      
      IF pr_tpctrato = 90 THEN
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
        END IF;
      ELSE
        --> Validar Contrato de Limite
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF cr_craplim%NOTFOUND THEN
          CLOSE cr_craplim;
          vr_dscritic := 'Contrato de Limite nao encontrado';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_craplim;
        END IF;
      END IF;
      
      --> Buscar aditivos contratuais
      OPEN cr_crapadt2;
      FETCH cr_crapadt2 INTO rw_crapadt;
      vr_fcrapadt := cr_crapadt2%FOUND;
      CLOSE cr_crapadt2;
      
      vr_idxaditv := pr_tab_aditiv.COUNT + 1;
      pr_tab_aditiv(vr_idxaditv).nrdconta := pr_nrdconta;
      pr_tab_aditiv(vr_idxaditv).nrctremp := pr_nrctremp;
      pr_tab_aditiv(vr_idxaditv).nraditiv := pr_nraditiv;
      pr_tab_aditiv(vr_idxaditv).cdaditiv := vr_cdaditiv;
      
      -- Se nao encontrouo registro e não é inclusao
      IF vr_fcrapadt = FALSE AND
         pr_cddopcao NOT IN ('I') THEN
        vr_cdcritic := 816; --> 816 - Aditivo nao encontrado.
        RAISE vr_exc_erro;
      END IF;
      
      IF vr_fcrapadt = TRUE THEN
        vr_cdaditiv                         := rw_crapadt.cdaditiv;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := rw_crapadt.cdaditiv;
        pr_tab_aditiv(vr_idxaditv).nrctagar := rw_crapadt.nrctagar;
        pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadt.nrcpfgar;
        pr_tab_aditiv(vr_idxaditv).nrdocgar := rw_crapadt.nrdocgar;
        pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadt.nmdgaran;
        pr_tab_aditiv(vr_idxaditv).dtmvtolt := rw_crapadt.dtmvtolt;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := vr_cdaditiv;
            
      END IF;
      
      IF vr_cdaditiv > 9 OR vr_cdaditiv < 1 THEN
        vr_cdcritic := 814; -- 814 - Tipo de Aditivo errado.
      END IF;  
      
      -- '2- Aplicacao Vinculada',
      -- '3- Aplicacao Vinculada Terceiro',
      IF vr_cdaditiv IN ('2','3') THEN
        
        IF pr_cdaditiv = 3 THEN
          if pr_nrctagar <> 0 then --SD#597917
            vr_nrdconta := pr_nrctagar;
          else
            vr_nrdconta := rw_crapadt.nrctagar;
          end if;
        ELSE 
          vr_nrdconta := pr_nrdconta;
        END IF;
          
        IF pr_cddopcao = 'I' THEN
        
          vr_dscritic := 'Tipo de aditivo permite somente CONSULTA';
              RAISE vr_exc_erro; 
        
        ELSE
          --> Buscar itens do aditivo contratual
          FOR rw_crapadi IN cr_crapadi LOOP
          
            --> buscar as aplicacooes do aditivo
            pc_buscar_aplicacoes (pr_cdcooper   => pr_cdcooper  --> Codigo da cooperativa            
                                 ,pr_cdagenci   => pr_cdagenci  --> Codigo da agencia
                                 ,pr_nrdcaixa   => pr_nrdcaixa  --> Numero do caixa 
                                 ,pr_cdoperad   => pr_cdoperad  --> Codigo do operador
                                 ,pr_nmdatela   => pr_nmdatela  --> Nome da tela
                                 ,pr_idorigem   => pr_idorigem  --> Origem 
                                 ,pr_dtmvtolt   => pr_dtmvtolt  --> Data de movimento
                                 ,pr_dtmvtopr   => pr_dtmvtopr  --> Data do prox. movimento
                                 ,pr_inproces   => pr_inproces  --> Indicador de processo
                                 ,pr_cddopcao   => pr_cddopcao  --> Codigo da opcao
                                 ,pr_nrdconta   => vr_nrdconta  --> Numero da conta                                 
                                 ,pr_tpaplica   => rw_crapadi.tpaplica  --> tipo de aplicacao
                                 ,pr_nraplica   => rw_crapadi.nraplica  --> Numero da aplicacao    
                                 --------> OUT <--------
                                 ,pr_tab_aplicacoes => pr_tab_aplicacoes  --> Retornar dados das aplicações 
                                 ,pr_cdcritic  => vr_cdcritic           --> Código da crítica
                                 ,pr_dscritic  => vr_dscritic );        --> Descrição da crítica
            IF nvl(vr_cdcritic,0) > 0 OR
               TRIM(vr_dscritic) IS NOT NULL THEN
              RAISE vr_exc_erro; 
            END IF; 
          END LOOP; --> Fim loop cr_crapadi
        
        END IF;
      
      -- 7- Sub-rogacao - C/ Nota Promissoria
      ELSIF vr_cdaditiv = 7 THEN
        --> Buscar itens do aditivo contratual
        FOR rw_crapadi IN cr_crapadi LOOP
          pr_tab_aditiv(vr_idxaditv).promis(rw_crapadi.nrsequen).nrpromis := rw_crapadi.nrpromis;
          pr_tab_aditiv(vr_idxaditv).promis(rw_crapadi.nrsequen).vlpromis := rw_crapadi.vlpromis;
          pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadi.nmdavali;          
        END LOOP;  
      
      ELSIF pr_cdaditiv = 9   AND
            pr_cddopcao = 'E' THEN

        vr_dscritic := 'Tipo de aditivo nao permite EXCLUSAO';
        RAISE vr_exc_erro;

      ELSE
        --> Buscar iten do aditivo contratual
        OPEN cr_crapadi;
        FETCH cr_crapadi INTO rw_crapadi;
        vr_fcrapadi := cr_crapadi%FOUND;
        CLOSE cr_crapadi;
        
      END IF; --> Fim IF vr_cdaditiv IN ('2','3')  
      
      IF vr_fcrapadi = TRUE THEN
        pr_tab_aditiv(vr_idxaditv).flgpagto := rw_crapadi.flgpagto;
        pr_tab_aditiv(vr_idxaditv).dtdpagto := rw_crapadi.dtdpagto;
        pr_tab_aditiv(vr_idxaditv).dscatbem := rw_crapadi.dscatbem;
        pr_tab_aditiv(vr_idxaditv).dsmarbem := rw_crapadi.dsmarbem;
        pr_tab_aditiv(vr_idxaditv).dsbemfin := rw_crapadi.dsbemfin;
        pr_tab_aditiv(vr_idxaditv).dschassi := rw_crapadi.dschassi;
        pr_tab_aditiv(vr_idxaditv).nrdplaca := rw_crapadi.nrdplaca;
        pr_tab_aditiv(vr_idxaditv).dscorbem := rw_crapadi.dscorbem;
        pr_tab_aditiv(vr_idxaditv).nranobem := rw_crapadi.nranobem;
        pr_tab_aditiv(vr_idxaditv).nrmodbem := rw_crapadi.nrmodbem;
        pr_tab_aditiv(vr_idxaditv).dstpcomb := rw_crapadi.dstpcomb;
        pr_tab_aditiv(vr_idxaditv).vlrdobem := rw_crapadi.vlrdobem;
        pr_tab_aditiv(vr_idxaditv).vlfipbem := rw_crapadi.vlfipbem;
        pr_tab_aditiv(vr_idxaditv).dstipbem := rw_crapadi.dstipbem;        
        pr_tab_aditiv(vr_idxaditv).nrrenava := rw_crapadi.nrrenava;
        pr_tab_aditiv(vr_idxaditv).tpchassi := rw_crapadi.tpchassi;
        pr_tab_aditiv(vr_idxaditv).ufdplaca := rw_crapadi.ufdplaca;
        pr_tab_aditiv(vr_idxaditv).uflicenc := rw_crapadi.uflicenc;
        pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        -- Se houve substituição de bem
        IF rw_crapadi.idseqsub > 0 THEN
          pr_tab_aditiv(vr_idxaditv).dschssub := fn_busca_chassi_substituido(rw_crapadi.cdcooper,
                                                                        rw_crapadi.nrdconta,
                                                                        99,
                                                                        rw_crapadi.nrctremp,
                                                                        rw_crapadi.idseqsub,
                                                                        vr_dscritic);
        if vr_dscritic is not null then
          raise vr_exc_erro;
        end if;
        ELSE
          pr_tab_aditiv(vr_idxaditv).dschssub := ' ';
        END IF;
        
        -- Trazer  situação Gravames quando houver bem sustituido
        IF rw_crapadi.idseqbem > 0 THEN
          grvm0001.pc_situac_gravame_bem(pr_cdcooper => rw_crapadi.cdcooper
                                        ,pr_nrdconta => rw_crapadi.nrdconta
                                        ,pr_nrctrpro => rw_crapadi.nrctremp
                                        ,pr_idseqbem => rw_crapadi.idseqbem
                                        ,pr_dssituac => pr_tab_aditiv(vr_idxaditv).dssitgrv
                                        ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          
        END IF;

        -- Buscar dados do interveniente garantidor do bem
        pr_tab_aditiv(vr_idxaditv).dspropri := fn_busca_dados_proprietario(rw_crapadi.cdcooper,
                                                                           rw_crapadi.nrdconta,
                                                                           rw_crapadi.nrctremp,
                                                                           rw_crapadi.nrcpfcgc,
                                                                           vr_dscritic);
        if vr_dscritic is not null then
          raise vr_exc_erro;
        end if;
        
        IF vr_cdaditiv IN ( 7,8) THEN
          pr_tab_aditiv(vr_idxaditv).nrcpfgar := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdgaran := rw_crapadi.nmdavali;
        END IF;
        
        IF vr_cdaditiv = 8 THEN  
          pr_tab_aditiv(vr_idxaditv).promis(1).vlpromis := rw_crapadi.vlpromis;
        ELSE
          pr_tab_aditiv(vr_idxaditv).promis(1).vlpromis := 0;
        END IF;  
      
        -- Para aditivos do tipo 5
      
      END IF;
      
      CASE vr_cdaditiv
        WHEN 1 THEN -- 1- Alteracao Data do Debito
        
          --> Validar emprestimo
          OPEN cr_crapepr;
          FETCH cr_crapepr INTO rw_crapepr;
          IF cr_crapepr%NOTFOUND THEN
            CLOSE cr_crapepr;
            vr_cdcritic := 356; -- 356 - Contrato de emprestimo nao encontrado.
            RAISE vr_exc_erro;
          ELSE
            CLOSE cr_crapepr;
          END IF;
          
          IF pr_cddopcao = 'E' THEN
            vr_dscritic := 'Tipo de aditivo nao permite EXCLUSAO';
            RAISE vr_exc_erro;
          ELSIF pr_cddopcao <> 'C' THEN
            pr_tab_aditiv(vr_idxaditv).flgpagto := rw_crapepr.flgpagto;
            pr_tab_aditiv(vr_idxaditv).tpdescto := rw_crapepr.tpdescto;
          END IF;
          
      WHEN 4 THEN --> 4- Inclusao de Fiador/Avalista
        IF pr_cddopcao IN ('E','I') THEN
          vr_dscritic := 'Tipo de aditivo permite somente CONSULTA';
          RAISE vr_exc_erro;
        END IF;      
        
        --> Buscar iten do aditivo contratual
        OPEN cr_crapadi2;
        FETCH cr_crapadi2 INTO rw_crapadi;
        vr_fcrapadi := cr_crapadi2%FOUND;
        CLOSE cr_crapadi2;  
        
        IF vr_fcrapadi = TRUE THEN
          pr_tab_aditiv(vr_idxaditv).dscpfavl := gene0002.fn_mask_cpf_cnpj(rw_crapadi.nrcpfcgc,1);
          pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        END IF;
                
      WHEN 5 THEN --> 5 - Substituicao de Veiculo   
        /*vr_contador := 0;*/
        IF  pr_cddopcao <> 'I' THEN
          pr_tab_aditiv(vr_idxaditv).nrcpfcgc := rw_crapadi.nrcpfcgc;
          pr_tab_aditiv(vr_idxaditv).nmdavali := rw_crapadi.nmdavali;
        END IF;  

      WHEN 6 THEN --> 6- Interveniente Garantidor Veiculo
        IF pr_cddopcao = 'I' THEN
          vr_dscritic := 'TIPO DE ADITIVO NAO PERMITIDO';
          RAISE vr_exc_erro;
        END IF;          
      ELSE
        NULL;    
      END CASE;
          
    ELSIF pr_cddopcao = 'X' THEN
    
      --> Validar associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;       
      
      --> Validar emprestimo
      OPEN cr_crawepr;
      FETCH cr_crawepr INTO rw_crawepr;
      IF cr_crawepr%NOTFOUND THEN
        CLOSE cr_crawepr;
        vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crawepr;
      END IF;
      
      ---->> BENS ALIENADOS <<----
      --> Buscar bens da proposta de emprestimo do cooperado.
      FOR rw_crapbpr IN cr_crapbpr LOOP

        -- Se houver aditivo nao elim.
        OPEN cr_crapadt3(pr_dsbemfin => rw_crapbpr.dsbemfin
                        ,pr_dschassi => rw_crapbpr.dschassi
                        ,pr_nrdplaca => rw_crapbpr.nrdplaca
                        ,pr_dscorbem => rw_crapbpr.dscorbem
                        ,pr_nranobem => rw_crapbpr.nranobem
                        ,pr_nrmodbem => rw_crapbpr.nrmodbem
                        ,pr_nrrenava => rw_crapbpr.nrrenava
                        ,pr_tpchassi => rw_crapbpr.tpchassi
                        ,pr_ufdplaca => rw_crapbpr.ufdplaca
                        ,pr_uflicenc => rw_crapbpr.uflicenc);
        FETCH cr_crapadt3 INTO rw_crapadt3;
        vr_fcrapadt := cr_crapadt3%FOUND;
        CLOSE cr_crapadt3;

        -- Se encontrou
        IF vr_fcrapadt THEN
          CONTINUE;
        END IF;

        vr_idxaditv := pr_tab_aditiv.COUNT + 1;
        pr_tab_aditiv(vr_idxaditv).dsbemfin := rw_crapbpr.dsbemfin;
        pr_tab_aditiv(vr_idxaditv).dschassi := rw_crapbpr.dschassi;
        pr_tab_aditiv(vr_idxaditv).nrdplaca := rw_crapbpr.nrdplaca;
        pr_tab_aditiv(vr_idxaditv).dscorbem := rw_crapbpr.dscorbem;
        pr_tab_aditiv(vr_idxaditv).nranobem := rw_crapbpr.nranobem;
        pr_tab_aditiv(vr_idxaditv).nrmodbem := rw_crapbpr.nrmodbem;
        pr_tab_aditiv(vr_idxaditv).nrrenava := rw_crapbpr.nrrenava;
        pr_tab_aditiv(vr_idxaditv).tpchassi := rw_crapbpr.tpchassi;
        pr_tab_aditiv(vr_idxaditv).ufdplaca := rw_crapbpr.ufdplaca;
        pr_tab_aditiv(vr_idxaditv).uflicenc := rw_crapbpr.uflicenc;
        pr_tab_aditiv(vr_idxaditv).idseqbem := rw_crapbpr.idseqbem;
        pr_tab_aditiv(vr_idxaditv).nrcpfcgc := rw_crapbpr.nrcpfbem;
        pr_tab_aditiv(vr_idxaditv).nrdconta := pr_nrdconta;
        pr_tab_aditiv(vr_idxaditv).nrctremp := pr_nrctremp;
        pr_tab_aditiv(vr_idxaditv).nraditiv := pr_nraditiv;
        pr_tab_aditiv(vr_idxaditv).cdaditiv := pr_cdaditiv;
        -- Busca situação Gravames
        grvm0001.pc_situac_gravame_bem(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctrpro => pr_nrctremp
                                      ,pr_idseqbem => rw_crapbpr.idseqbem
                                      ,pr_dssituac => pr_tab_aditiv(vr_idxaditv).dssitgrv
                                      ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END LOOP;
      
    ELSE
      vr_cdcritic := 14; -- 014 - Opcao errada.
      RAISE vr_exc_erro;
    END IF; --> Fim IF pr_cddopcao
    
           
  EXCEPTION
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
      -- Verifica se deve gerar log
      IF pr_flgerlog = 1 AND pr_nrdconta > 0 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> false
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

      END IF;
      
            
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao buscar dados aditivo: ' || SQLERRM;         
  END pc_busca_dados_aditiv;  
  
  --> Buscar dados do aditivo do emprestimo
  PROCEDURE pc_busca_dados_aditiv_prog(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                                      ,pr_cdagenci  IN crapage.cdagenci%TYPE --> Codigo da agencia
                                      ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                                      ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Codigo do operador
                                      ,pr_nmdatela  IN craptel.nmdatela%TYPE --> Nome da tela
                                      ,pr_idorigem  IN INTEGER               --> Origem 
                                      ,pr_dtmvtolt  IN VARCHAR2              --> Data de movimento
                                      ,pr_dtmvtopr  IN VARCHAR2              --> Data do prox. movimento
                                      ,pr_inproces  IN crapdat.inproces%TYPE --> Indicador de processo
                                      ,pr_cddopcao  IN VARCHAR2              --> Codigo da opcao
                                      ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                      ,pr_nrctremp  IN crapepr.nrctremp%TYPE --> Numero do contrato
                                      ,pr_dtmvtolx  IN VARCHAR2              --> Data de consulta
                                      ,pr_nraditiv  IN crapadt.nraditiv%TYPE --> Numero do aditivo
                                      ,pr_cdaditiv  IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                                      ,pr_tpaplica  IN craprda.tpaplica%TYPE --> tipo de aplicacao
                                      ,pr_nrctagar  IN crapass.nrdconta%TYPE --> conta garantia
                                      ,pr_tpctrato  IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                                      ,pr_flgpagin  IN INTEGER               --> Flag (0-false 1-true)
                                      ,pr_nrregist  IN INTEGER               --> Numero de registros a serem retornados
                                      ,pr_nriniseq  IN INTEGER               --> Registro inicial
                                      ,pr_flgerlog  IN INTEGER               --> Gerar log(0-false 1-true)
                                      --------> OUT <--------
                                      ,pr_qtregist OUT INTEGER               --> Retornar quantidade de registros
                                      ,pr_clob_xml OUT CLOB                  --> XML com informacoes do retorno
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da critica
                                    
    /* .............................................................................
    
        Programa: pc_busca_dados_aditiv_prog
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Jaison Fernando
        Data    : Novembro/2017.                    Ultima atualizacao: 30/07/2018
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado.
    
        Objetivo  : Rotina responsavel em buscar dados do aditivo do emprestimo e retornar ao Progress.
    
        Observacao: -----
    
        Alteracoes: 30/07/2018 - P442 - Inclusão de campos do projeto (Marcos-Envolti)

    ..............................................................................*/

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro        EXCEPTION;

    -- Variaveis locais
    vr_idxpromi        PLS_INTEGER;
    vr_tab_aditiv      typ_tab_aditiv;
    vr_tab_aplicacoes  typ_tab_aplicacoes;  
    vr_xml_temp        VARCHAR2(32767);
    vr_dtmvtolt        DATE;
    vr_dtmvtopr        DATE;
    vr_dtmvtolx        DATE;

  BEGIN
    -- Converte as datas
    vr_dtmvtolt := TO_DATE(TRIM(pr_dtmvtolt),'DD/MM/RRRR');
    vr_dtmvtopr := TO_DATE(TRIM(pr_dtmvtopr),'DD/MM/RRRR');
    vr_dtmvtolx := TO_DATE(TRIM(pr_dtmvtolx),'DD/MM/RRRR');

    --> Buscar dados do aditivo do emprestimo
    pc_busca_dados_aditiv(pr_cdcooper   => pr_cdcooper
                         ,pr_cdagenci   => pr_cdagenci
                         ,pr_nrdcaixa   => pr_nrdcaixa
                         ,pr_cdoperad   => pr_cdoperad
                         ,pr_nmdatela   => pr_nmdatela
                         ,pr_idorigem   => pr_idorigem
                         ,pr_dtmvtolt   => vr_dtmvtolt
                         ,pr_dtmvtopr   => vr_dtmvtopr
                         ,pr_inproces   => pr_inproces
                         ,pr_cddopcao   => pr_cddopcao
                         ,pr_nrdconta   => pr_nrdconta
                         ,pr_nrctremp   => pr_nrctremp
                         ,pr_dtmvtolx   => vr_dtmvtolx
                         ,pr_nraditiv   => pr_nraditiv
                         ,pr_cdaditiv   => pr_cdaditiv
                         ,pr_tpaplica   => pr_tpaplica
                         ,pr_nrctagar   => pr_nrctagar
                         ,pr_tpctrato   => pr_tpctrato
                         ,pr_flgpagin   => pr_flgpagin
                         ,pr_nrregist   => pr_nrregist
                         ,pr_nriniseq   => pr_nriniseq
                         ,pr_flgerlog   => pr_flgerlog
                         --------> OUT <--------
                         ,pr_qtregist       => pr_qtregist        --> Retornar quantidad de registros
                         ,pr_tab_aditiv     => vr_tab_aditiv      --> Retornar dados do aditivo
                         ,pr_tab_aplicacoes => vr_tab_aplicacoes  --> Retornar dados das aplicações 
                         ,pr_cdcritic       => vr_cdcritic        --> Código da crítica
                         ,pr_dscritic       => vr_dscritic);      --> Descrição da crítica
    -- Se houve erro
    IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 

    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_xml, TRUE);
    dbms_lob.open(pr_clob_xml, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');

    IF vr_tab_aditiv.COUNT > 0 THEN

      -- Abertura de TAG
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<aditivos>');

      -- Percorre todos os aditivos
      FOR vr_idx IN vr_tab_aditiv.FIRST..vr_tab_aditiv.LAST LOOP

        -- Montar XML com registros
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<aditivo>'
                                                  ||  '<nrdconta>' || vr_tab_aditiv(vr_idx).nrdconta || '</nrdconta>'
                                                  ||  '<nrctremp>' || vr_tab_aditiv(vr_idx).nrctremp || '</nrctremp>'
                                                  ||  '<nraditiv>' || vr_tab_aditiv(vr_idx).nraditiv || '</nraditiv>'
                                                  ||  '<cdaditiv>' || vr_tab_aditiv(vr_idx).cdaditiv || '</cdaditiv>'
                                                  ||  '<dsaditiv>' || vr_tab_aditiv(vr_idx).dsaditiv || '</dsaditiv>'
                                                  ||  '<dtmvtolt>' || TO_CHAR(vr_tab_aditiv(vr_idx).dtmvtolt,'DD/MM/RRRR') || '</dtmvtolt>'
                                                  ||  '<nrctagar>' || vr_tab_aditiv(vr_idx).nrctagar || '</nrctagar>'
                                                  ||  '<nrcpfgar>' || vr_tab_aditiv(vr_idx).nrcpfgar || '</nrcpfgar>'
                                                  ||  '<nrdocgar>' || vr_tab_aditiv(vr_idx).nrdocgar || '</nrdocgar>'
                                                  ||  '<nmdgaran>' || vr_tab_aditiv(vr_idx).nmdgaran || '</nmdgaran>'
                                                  ||  '<flgpagto>' || vr_tab_aditiv(vr_idx).flgpagto || '</flgpagto>'
                                                  ||  '<dtdpagto>' || TO_CHAR(vr_tab_aditiv(vr_idx).dtdpagto,'DD/MM/RRRR') || '</dtdpagto>'
                                                  ||  '<dscatbem>' || vr_tab_aditiv(vr_idx).dscatbem || '</dscatbem>'
                                                  ||  '<dsmarbem>' || vr_tab_aditiv(vr_idx).dsmarbem || '</dsmarbem>'
                                                  ||  '<dsbemfin>' || vr_tab_aditiv(vr_idx).dsbemfin || '</dsbemfin>'
                                                  ||  '<dschassi>' || vr_tab_aditiv(vr_idx).dschassi || '</dschassi>'
                                                  ||  '<nrdplaca>' || vr_tab_aditiv(vr_idx).nrdplaca || '</nrdplaca>'
                                                  ||  '<dscorbem>' || vr_tab_aditiv(vr_idx).dscorbem || '</dscorbem>'
                                                  ||  '<nranobem>' || vr_tab_aditiv(vr_idx).nranobem || '</nranobem>'
                                                  ||  '<nrmodbem>' || vr_tab_aditiv(vr_idx).nrmodbem || '</nrmodbem>'
                                                  ||  '<dstpcomb>' || vr_tab_aditiv(vr_idx).dstpcomb || '</dstpcomb>'
                                                  ||  '<vlrdobem>' || vr_tab_aditiv(vr_idx).vlrdobem || '</vlrdobem>'
                                                  ||  '<vlfipbem>' || vr_tab_aditiv(vr_idx).vlfipbem || '</vlfipbem>'
                                                  ||  '<dstipbem>' || vr_tab_aditiv(vr_idx).dstipbem || '</dstipbem>'
                                                  ||  '<nrrenava>' || vr_tab_aditiv(vr_idx).nrrenava || '</nrrenava>'
                                                  ||  '<tpchassi>' || vr_tab_aditiv(vr_idx).tpchassi || '</tpchassi>'
                                                  ||  '<ufdplaca>' || vr_tab_aditiv(vr_idx).ufdplaca || '</ufdplaca>'
                                                  ||  '<uflicenc>' || vr_tab_aditiv(vr_idx).uflicenc || '</uflicenc>'
                                                  ||  '<nmdavali>' || vr_tab_aditiv(vr_idx).nmdavali || '</nmdavali>'
                                                  ||  '<tpdescto>' || vr_tab_aditiv(vr_idx).tpdescto || '</tpdescto>'
                                                  ||  '<dscpfavl>' || vr_tab_aditiv(vr_idx).dscpfavl || '</dscpfavl>'
                                                  ||  '<nrcpfcgc>' || vr_tab_aditiv(vr_idx).nrcpfcgc || '</nrcpfcgc>'
                                                  ||  '<nrsequen>' || vr_tab_aditiv(vr_idx).nrsequen || '</nrsequen>'
                                                  ||  '<idseqbem>' || vr_tab_aditiv(vr_idx).idseqbem || '</idseqbem>'
                                                  ||  '<dschssub>' || vr_tab_aditiv(vr_idx).dschssub || '</dschssub>'
                                                  ||  '<dssitgrv>' || vr_tab_aditiv(vr_idx).dssitgrv || '</dssitgrv>'
                                                  ||  '<promissorias>');

        -- Listagem das promissorias
        vr_idxpromi := vr_tab_aditiv(vr_idx).promis.first;
        WHILE vr_idxpromi IS NOT NULL LOOP
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<promis>
                                                          <nrseqpro>'|| vr_idxpromi ||'</nrseqpro>
                                                          <nrpromis>'|| vr_tab_aditiv(vr_idx).promis(vr_idxpromi).nrpromis ||'</nrpromis>
                                                          <vlpromis>'|| vr_tab_aditiv(vr_idx).promis(vr_idxpromi).vlpromis ||'</vlpromis>
                                                        </promis>');
          vr_idxpromi := vr_tab_aditiv(vr_idx).promis.next(vr_idxpromi);
        END LOOP;

        -- Fechamento de TAGs
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</promissorias></aditivo>');	

      END LOOP;

      -- Fechamento de TAG
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</aditivos>');
    END IF;

    IF vr_tab_aplicacoes.COUNT > 0 THEN

      -- Abertura de TAG
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<aplicacoes>');

      -- Percorre todas as aplicacoes
      FOR vr_idx IN vr_tab_aplicacoes.FIRST..vr_tab_aplicacoes.LAST LOOP

        -- Montar XML com registros de aplicacao
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<aplicacao>'
                                                  ||  '<nraplica>' || vr_tab_aplicacoes(vr_idx).nraplica || '</nraplica>'
                                                  ||  '<dtmvtolt>' || TO_CHAR(vr_tab_aplicacoes(vr_idx).dtmvtolt,'DD/MM/RRRR') || '</dtmvtolt>'
                                                  ||  '<dshistor>' || vr_tab_aplicacoes(vr_idx).dshistor || '</dshistor>'
                                                  ||  '<vlaplica>' || vr_tab_aplicacoes(vr_idx).vlaplica || '</vlaplica>'
                                                  ||  '<nrdocmto>' || vr_tab_aplicacoes(vr_idx).nrdocmto || '</nrdocmto>'
                                                  ||  '<dtvencto>' || TO_CHAR(vr_tab_aplicacoes(vr_idx).dtvencto,'DD/MM/RRRR') || '</dtvencto>'
                                                  ||  '<vlsldapl>' || vr_tab_aplicacoes(vr_idx).vlsldapl || '</vlsldapl>'
                                                  ||  '<sldresga>' || vr_tab_aplicacoes(vr_idx).sldresga || '</sldresga>'
                                                  || '</aplicacao>');	

      END LOOP;

      -- Fechamento de TAG
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</aplicacoes>');
    END IF;

    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_xml
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);

  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro ao buscar dados aditivo: ' || SQLERRM;

  END pc_busca_dados_aditiv_prog;

  --> Rotina responsavel em buscar dados para assinatura do contrato
  PROCEDURE pc_Trata_Dados_Assinatura ( pr_cdcooper     IN crapavl.cdcooper%TYPE,
                                        pr_nrdconta     IN crapavl.nrdconta%TYPE,
                                        pr_nrctremp     IN crapepr.nrctremp%TYPE,
                                        pr_nrctacon     IN crapavl.nrdconta%TYPE,
                                        pr_nrctaava     IN crapavt.nrdconta%TYPE,
                                        pr_nmdavali     IN crapavt.nmdavali%TYPE,
                                        pr_iddoaval     IN INTEGER,
                                        pr_tpdconsu     IN INTEGER,
                                        pr_linhatra IN OUT VARCHAR2,
                                        pr_nmdevsol IN OUT VARCHAR2,
                                        pr_dscpfcgc IN OUT VARCHAR2,
                                        pr_dsendere IN OUT VARCHAR2,
                                        pr_dstelefo IN OUT VARCHAR2,
                                        pr_cdcritic    OUT PLS_INTEGER,          --> Código da crítica
                                        pr_dscritic    OUT VARCHAR2    ) IS      --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_Trata_Dados_Assinatura    (antiga: b1wgen0115.p/Trata_Dados_Assinatura)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em buscar dados para assinatura do contrato
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    
    ---------->>> CURSORES <<<--------
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE; 
    
    --> Buscar dados do endereço
    CURSOR cr_crapenc (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT enc.cdcooper,
             enc.dsendere,
             enc.nrendere,
             enc.nmcidade
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1;
    rw_crapenc cr_crapenc%ROWTYPE;
    
    --> Buscar dados do telefone
    CURSOR cr_craptfc (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT tfc.nrdddtfc,
             tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = 1;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --> Buscar dados avalista
    CURSOR cr_crapavt(pr_cdcooper  crapavt.cdcooper%TYPE,
                      pr_nrdconta  crapavt.nrdconta%TYPE,
                      pr_nrctremp  crapavt.nrctremp%TYPE,
                      pr_nmdavali  crapavt.nmdavali%TYPE) IS
      SELECT avt.cdcooper
            ,avt.dsendres##1
            ,avt.nrendere
            ,avt.nmcidade
            ,avt.nmdavali
            ,avt.nrfonres
            ,avt.inpessoa
            ,avt.nrcpfcgc
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = 1
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctremp
         AND avt.nmdavali = pr_nmdavali;
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar dodos do conjuge do Avalista
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cje.nmconjug,
             cje.nrcpfcjg,
             cje.dsendcom,
             cje.nrfonemp
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    
    
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro        EXCEPTION;
    
    vr_inpessoa        VARCHAR2(1);
    vr_nmdevsol        VARCHAR2(100);
    vr_dscpfcgc        VARCHAR2(20);
    vr_dsendere        VARCHAR2(100);
    vr_dstelefo        VARCHAR2(100);
    
        
    
  BEGIN
    IF pr_nrctacon <> 0  THEN --> Dados do cooperado
    
      --> Buscar dados do cooperado
      OPEN cr_crapass(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN        
        CLOSE cr_crapass;
        vr_dscritic := 'Associado não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      --> Buscar dados de endereço do cooperado
      OPEN cr_crapenc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN        
        CLOSE cr_crapenc;
        vr_dscritic := 'Endereço do associado não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapenc;
      END IF;
      
      --> Buscar dados de telefones do cooperado
      OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => pr_nrctacon);
      FETCH cr_craptfc INTO rw_craptfc;
      IF cr_craptfc%NOTFOUND THEN        
        CLOSE cr_craptfc;
        vr_dscritic := 'Telefone do associado não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptfc;
      END IF;
      
      vr_inpessoa := rw_crapass.inpessoa;
      vr_nmdevsol := rw_crapass.nmprimtl;
      vr_dscpfcgc := rw_crapass.nrcpfcgc;
      vr_dsendere := rw_crapenc.dsendere ||' '|| rw_crapenc.nrendere|| ', '||rw_crapenc.nmcidade;
      vr_dstelefo := '('|| rw_craptfc.nrdddtfc||') '|| rw_craptfc.nrtelefo;
      
    ELSE --> Avalista terceiro ou Conjuge terceiro
      --> Avalista
      IF pr_tpdconsu = 1 THEN 
        --> Buscar dados avalista
        OPEN cr_crapavt(pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => pr_nrdconta,
                        pr_nrctremp  => pr_nrctremp,
                        pr_nmdavali  => pr_nmdavali); 
        FETCH cr_crapavt INTO rw_crapavt;
        IF cr_crapavt%NOTFOUND THEN
          CLOSE cr_crapavt;
        ELSE
          CLOSE cr_crapavt;
          
          vr_inpessoa := rw_crapavt.inpessoa;
          vr_nmdevsol := rw_crapavt.nmdavali;
          vr_dscpfcgc := rw_crapavt.nrcpfcgc;
          vr_dsendere := rw_crapavt.dsendres##1 ||' '|| rw_crapavt.nrendere|| ', '||rw_crapavt.nmcidade;
          vr_dstelefo := rw_crapavt.nrfonres;
          
        END IF;
      
      --> Conjuge do Avalista
      ELSE
        --> Buscar dados do conjuge
        OPEN cr_crapcje(pr_cdcooper  => pr_cdcooper,
                        pr_nrdconta  => pr_nrctaava);
        FETCH cr_crapcje INTO rw_crapcje;
        IF cr_crapcje%NOTFOUND THEN        
          CLOSE cr_crapcje;
        ELSE
          CLOSE cr_crapcje;
          vr_inpessoa := 1;
          vr_nmdevsol := rw_crapcje.nmconjug;
          vr_dscpfcgc := rw_crapcje.nrcpfcjg;
          vr_dsendere := rw_crapcje.dsendcom;
          vr_dstelefo := rw_crapcje.nrfonemp;
          
          --Se nao localizou o endereço
          IF TRIM(vr_dsendere) IS NULL THEN
          
            --> Buscar dados de endereço do cooperado
            OPEN cr_crapenc(pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrctaava);
            FETCH cr_crapenc INTO rw_crapenc;
            IF cr_crapenc%FOUND THEN              
              vr_dsendere := rw_crapenc.dsendere ||' '|| rw_crapenc.nrendere|| ', '||rw_crapenc.nmcidade;
            END IF;
            CLOSE cr_crapenc;
          END IF; 
          
          IF trim(vr_dstelefo) IS NULL THEN
            --> Buscar dados de telefones do cooperado
            OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                            pr_nrdconta  => pr_nrctaava);
            FETCH cr_craptfc INTO rw_craptfc;
            IF cr_craptfc%FOUND THEN        
              vr_dstelefo := '('|| rw_craptfc.nrdddtfc||') '|| rw_craptfc.nrtelefo;
            END IF;
            CLOSE cr_craptfc;
          END IF;
          
        END IF;
      END IF;
    END IF;
    
    --> Assinatura, nome, Endereco , telefone e CPF 
    pr_linhatra := pr_linhatra || pr_iddoaval || ')';
    pr_nmdevsol := pr_nmdevsol || 'Nome: '    || vr_nmdevsol;
    pr_dsendere := pr_dsendere || 'Endereco: '|| vr_dsendere;
    pr_dstelefo := pr_dstelefo || 'Telefone: '|| vr_dstelefo;

    IF vr_inpessoa = 1 THEN
      pr_dscpfcgc := pr_dscpfcgc || 'CPF: ';
    ELSE
      pr_dscpfcgc := pr_dscpfcgc || 'CNPJ: ';
    END IF;
    
    pr_dscpfcgc := pr_dscpfcgc || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_dscpfcgc, 
                                                            pr_inpessoa => vr_inpessoa);
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_Trata_Dados_Assinatura: ' || SQLERRM;   
  END pc_Trata_Dados_Assinatura;
  
  PROCEDURE pc_Trata_Assinatura ( pr_cdcooper       IN crapavl.cdcooper%TYPE,
                                  pr_nrdconta       IN crapavl.nrdconta%TYPE,
                                  pr_nrctremp       IN crapepr.nrctremp%TYPE,
                                  pr_nrctaava       IN crapavt.nrdconta%TYPE,
                                  pr_nmdavali       IN crapavt.nmdavali%TYPE,
                                  pr_iddoaval       IN INTEGER,              
                                  pr_cdaditiv       IN crapadt.cdaditiv%TYPE,
                                  pr_linhatra      OUT VARCHAR2,
                                  pr_nmdevsol      OUT VARCHAR2,
                                  pr_dscpfcgc      OUT VARCHAR2,
                                  pr_dsendere      OUT VARCHAR2,
                                  pr_dstelefo      OUT VARCHAR2,
                                  pr_linhatra_cje  OUT VARCHAR2,
                                  pr_nmdevsol_cje  OUT VARCHAR2,
                                  pr_dscpfcgc_cje  OUT VARCHAR2,
                                  pr_dsendere_cje  OUT VARCHAR2,
                                  pr_dstelefo_cje  OUT VARCHAR2,
                                  pr_cdcritic      OUT PLS_INTEGER,          --> Código da crítica
                                  pr_dscritic      OUT VARCHAR2    ) IS      --> Descrição da crítica
    /* .............................................................................
    
        Programa: pc_Trata_Assinatura    (antiga: b1wgen0115.p/Trata_Assinatura)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Agosto/2016.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em montar os dados para assinatura do contrato
    
        Observacao: -----
    
        Alteracoes:

		22/05/2017 - Ateração na chamada da procedure pc_trata_dados_assinatura
                     o parametro pr_tpdconsu de 1 para 2 com o objetivo de buscar 
                     o conjuge do avalista(663707 - Mateus Zimmermann - Mouts)	
    ..............................................................................*/
    
    ---------->>> CURSORES <<<--------
    --> Buscar dodos do conjuge do Avalista
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cje.nmconjug,
             cje.nrcpfcjg,
             cje.dsendcom,
             cje.nrfonemp,
             cje.nrctacje
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_exc_erro        EXCEPTION;
    
  BEGIN
  
    --> Dados do avalista
    pc_Trata_Dados_Assinatura ( pr_cdcooper    => pr_cdcooper,
                                pr_nrdconta    => pr_nrdconta,
                                pr_nrctremp    => pr_nrctremp,
                                pr_nrctacon    => pr_nrctaava,
                                pr_nrctaava    => pr_nrctaava,
                                pr_nmdavali    => pr_nmdavali,
                                pr_iddoaval    => pr_iddoaval,
                                pr_tpdconsu    => 1,
                                pr_linhatra    => pr_linhatra,
                                pr_nmdevsol    => pr_nmdevsol,
                                pr_dscpfcgc    => pr_dscpfcgc,
                                pr_dsendere    => pr_dsendere,
                                pr_dstelefo    => pr_dstelefo,
                                pr_cdcritic    => vr_cdcritic,
                                pr_dscritic    => vr_dscritic );
         
    
    --> Buscar dados do conjuge
    OPEN cr_crapcje(pr_cdcooper  => pr_cdcooper,
                    pr_nrdconta  => pr_nrctaava);
    FETCH cr_crapcje INTO rw_crapcje;
    IF cr_crapcje%FOUND THEN        
      CLOSE cr_crapcje;
      
      --> Dados do avalista
      pc_Trata_Dados_Assinatura ( pr_cdcooper    => pr_cdcooper,
                                  pr_nrdconta    => pr_nrdconta,
                                  pr_nrctremp    => pr_nrctremp,
                                  pr_nrctacon    => rw_crapcje.nrctacje,
                                  pr_nrctaava    => pr_nrctaava,
                                  pr_nmdavali    => NULL,
                                  pr_iddoaval    => pr_iddoaval,
                                  pr_tpdconsu    => 2,
                                  pr_linhatra    => pr_linhatra_cje,
                                  pr_nmdevsol    => pr_nmdevsol_cje,
                                  pr_dscpfcgc    => pr_dscpfcgc_cje,
                                  pr_dsendere    => pr_dsendere_cje,
                                  pr_dstelefo    => pr_dstelefo_cje,
                                  pr_cdcritic    => vr_cdcritic,
                                  pr_dscritic    => vr_dscritic);      
    ELSE  
      CLOSE cr_crapcje;
    END IF;  
    
  EXCEPTION
    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na pc_Trata_Assinatura: ' || SQLERRM; 
  END pc_Trata_Assinatura;
  
  --> Gerar a impressao do contrato de aditivo
  PROCEDURE pc_gera_impressao_aditiv 
                          ( pr_cdcooper   IN crapcop.cdcooper%TYPE --> Codigo da cooperativa            
                           ,pr_cdagenci   IN crapage.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa   IN crapbcx.nrdcaixa%TYPE --> Numero do caixa 
                           ,pr_idorigem   IN INTEGER               --> Origem 
                           ,pr_nmdatela   IN craptel.nmdatela%TYPE --> Nome da tela
                           ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo do programa
                           ,pr_cdoperad   IN crapope.cdoperad%TYPE --> Codigo do operador
                           ,pr_dsiduser   IN VARCHAR2              --> id do usuario
                           ,pr_cdaditiv   IN crapadt.cdaditiv%TYPE --> Codigo do aditivo
                           ,pr_nraditiv   IN crapadt.nraditiv%TYPE --> Numero do aditivo
                           ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato
                           ,pr_nrdconta   IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data de movimento
                           ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data do prox. movimento
                           ,pr_inproces   IN crapdat.inproces%TYPE --> Indicador de processo
                           ,pr_tpctrato   IN crapadt.tpctrato%TYPE --> Tipo do Contrato do Aditivo
                           --------> OUT <--------
                           ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                           ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2    ) IS      --> Descrição da crítica
                                    
    /* .............................................................................
    
        Programa: pc_gera_impressao_aditiv    (antiga: b1wgen0115.p/Gera_Impressao)
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Odirlei Busana (Amcom)
        Data    : Julho/2016.                    Ultima atualizacao: 01/11/2017
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina responsavel em gerar a impressao do contrato de aditivo
    
        Observacao: -----
    
        Alteracoes: 01/11/2017 - Ajustes conforme inclusao do campo tipo de contrato.
                                 (Jaison/Marcos Martini - PRJ404)

    ..............................................................................*/
    ---------->>> CURSORES <<<--------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;   
    
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta,
             epr.cdlcremp,
             epr.cdagenci,
             epr.nmdaval1,
             epr.nrctaav1,
             epr.nmdaval2,
             epr.nrctaav2,
             epr.idcobope,
             epr.idcobefe
        FROM crawepr epr            
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE; 
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.inpessoa,
             ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE;
    rw_crapass_gar cr_crapass%ROWTYPE;
    
    --> Buscar qualificações do cooperado
    CURSOR cr_crapass_quali (pr_cdcooper crapass.cdcooper%TYPE,
                             pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl,
             ass.cdnacion,
             enc.dsendere,
             enc.nrendere,
             enc.nmbairro,
             enc.nmcidade,
             enc.cdufende,
             enc.nrcepend
        FROM crapass ass
            ,crapenc enc
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND enc.cdcooper = ass.cdcooper
         AND enc.nrdconta = ass.nrdconta
         AND enc.idseqttl = 1
         AND enc.tpendass = DECODE(ass.inpessoa,1,10,9); -- 9 - comercial / 10 - residencial
    rw_crapass_quali cr_crapass_quali%ROWTYPE;
		
    --> Busca a Nacionalidade
    CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
      SELECT crapnac.dsnacion
        FROM crapnac
       WHERE crapnac.cdnacion = pr_cdnacion;
    rw_crapnac cr_crapnac%ROWTYPE;

    --> Cursor para buscar estado civil da pessoa fisica, jurida nao tem
    CURSOR cr_gnetcvl(pr_cdcooper crapttl.cdcooper%TYPE
                     ,pr_nrdconta crapttl.nrdconta%TYPE) IS
      SELECT gnetcvl.rsestcvl,
             crapttl.dsproftl
       FROM  crapttl,
             gnetcvl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
         AND crapttl.idseqttl = 1 -- Primeiro Titular
         AND gnetcvl.cdestcvl = crapttl.cdestcvl;
    rw_gnetcvl cr_gnetcvl%ROWTYPE;
		    
    --> buscar operador
    CURSOR cr_crapope IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE; 
    
    --> Verificar se linha
    CURSOR cr_craplcr (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_cdlcremp crawepr.cdlcremp%TYPE) IS
      SELECT craplcr.dslcremp
        FROM craplcr
       WHERE craplcr.cdcooper = pr_cdcooper 
         AND craplcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;
    
    --> Seleciona dados do limite
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                     ,pr_nrdconta IN craplim.nrdconta%TYPE
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
      SELECT craplim.idcobope,
             craplim.idcobefe,
             craplim.dtinivig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = pr_tpctrlim;
    rw_craplim cr_craplim%ROWTYPE;

    --> Seleciona dados da cobertura
    CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
      SELECT tco.perminimo,
             tco.nrconta_terceiro,
             tco.qtdias_atraso_permitido
        FROM tbgar_cobertura_operacao tco
       WHERE tco.idcobertura = pr_idcobert;
    rw_cobertura cr_cobertura%ROWTYPE;

    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_exc_sucesso     EXCEPTION;
    
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        gene0001.typ_tab_erro;
        
    vr_dstextab        craptab.dstextab%TYPE; 
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);   
    
    vr_qtregist        INTEGER;
    vr_tab_aditiv      typ_tab_aditiv;
    vr_tab_aplicacoes  typ_tab_aplicacoes;
    
    vr_idxaditi        PLS_INTEGER; 
    vr_idxpromi        PLS_INTEGER; 
    
    vr_tpdocged        INTEGER; 
    vr_dsqrcode        VARCHAR2(100);
    
    vr_nmoperad        VARCHAR2(100);
    vr_cdc             CHAR;
    vr_dtmvtolt        DATE;
    vr_rel_nrcpfgar    VARCHAR2(100);
    vr_rel_nmcidade    VARCHAR2(100);
    vr_totpromi        NUMBER;
    vr_rel_vlpromis    VARCHAR2(1000);
    vr_rel_nrcpfcgc    VARCHAR2(25);
    vr_dsddpagt        VARCHAR2(100);
    vr_dsaplica        VARCHAR2(1000);
    vr_dscpfgar        VARCHAR2(100);
    vr_nmprigar        crapass.nmprimtl%TYPE;
    vr_nrctaavl        crapass.nrdconta%TYPE;
    vr_cdagenci        crapass.cdagenci%TYPE;
    vr_tpchassi        VARCHAR2(100);
    vr_dtctrato        DATE;
    vr_modrelat        VARCHAR2(10);
    vr_tpctrava        INTEGER;
    vr_idcobert        NUMBER;
    vr_Inpessoa        NUMBER;
    
    vr_linhatra        VARCHAR2(100);
    vr_nmdevsol        VARCHAR2(100);
    vr_dscpfcgc        VARCHAR2(100);
    vr_dsendere        VARCHAR2(200);
    vr_dstelefo        VARCHAR2(100);
    vr_linhatra_cje    VARCHAR2(100);
    vr_nmdevsol_cje    VARCHAR2(100);
    vr_dscpfcgc_cje    VARCHAR2(100);
    vr_dsendere_cje    VARCHAR2(200);
    vr_dstelefo_cje    VARCHAR2(100);
    
    vr_tab_clau_adi    typ_tab_clau_adi;
    vr_tab_clausulas   typ_tab_clausula;
    vr_tab_aval        DSCT0002.typ_tab_dados_avais;
    
	vr_nrdconta_quali crapass.nrdconta%TYPE;
	vr_dsqualifica    VARCHAR2(1000);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    vr_dsjasper  VARCHAR2(100);
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN  
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/'||pr_dsiduser;
    
    IF TRIM(pr_dsiduser) IS NOT NULL THEN
      vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
      
      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomand
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      --Se ocorreu erro dar RAISE
      IF vr_typsaida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF; 
    END IF;
    
    --> Montar nome do arquivo
    pr_nmarqpdf := pr_dsiduser || gene0002.fn_busca_time || '.pdf';
    
    --> Buscar dados do aditivo do emprestimo
    pc_busca_dados_aditiv ( pr_cdcooper   => pr_cdcooper --> Codigo da cooperativa            
                           ,pr_cdagenci   => 0 --> Codigo da agencia
                           ,pr_nrdcaixa   => 0 --> Numero do caixa 
                           ,pr_cdoperad   => pr_cdoperad --> Codigo do operador
                           ,pr_nmdatela   => pr_nmdatela --> Nome da tela
                           ,pr_idorigem   => pr_idorigem --> Origem 
                           ,pr_dtmvtolt   => pr_dtmvtolt --> Data de movimento
                           ,pr_dtmvtopr   => pr_dtmvtopr --> Data do prox. movimento
                           ,pr_inproces   => pr_inproces --> Indicador de processo
                           ,pr_cddopcao   => 'C' --> Codigo da opcao
                           ,pr_nrdconta   => pr_nrdconta --> Numero da conta
                           ,pr_nrctremp   => pr_nrctremp --> Numero do contrato
                           ,pr_dtmvtolx   => NULL --> Data de consulta
                           ,pr_nraditiv   => pr_nraditiv  --> Numero do aditivo
                           ,pr_cdaditiv   => pr_cdaditiv --> Codigo do aditivo
                           ,pr_tpaplica   => 0 --> tipo de aplicacao
                           ,pr_nrctagar   => 0 --> conta garantia
                           ,pr_tpctrato   => pr_tpctrato --> Tipo do Contrato do Aditivo
                           ,pr_flgpagin   => 0 --> Flag (0-false 1-true)
                           ,pr_nrregist   => 0 --> Numero de registros a serem retornados
                           ,pr_nriniseq   => 0 --> Registro inicial
                           ,pr_flgerlog   => 0 --> Gerar log(0-false 1-true)
                           --------> OUT <--------
                           ,pr_qtregist       => vr_qtregist        --> Retornar quantidad de registros
                           ,pr_tab_aditiv     => vr_tab_aditiv      --> Retornar dados do aditivo
                           ,pr_tab_aplicacoes => vr_tab_aplicacoes  --> Retornar dados das aplicações 
                           ,pr_cdcritic       => vr_cdcritic                --> Código da crítica
                           ,pr_dscritic       => vr_dscritic      );     --> Descrição da crítica
      
    --> Dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    CLOSE cr_crapass;
      
    IF pr_tpctrato = 90 THEN
      --> Dados do emprestimo
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    CLOSE cr_crawepr;
      
      vr_cdagenci := rw_crawepr.cdagenci;
      vr_dtctrato := rw_crawepr.dtmvtolt;
      vr_idcobert := rw_crawepr.idcobope;
      vr_modrelat := (CASE WHEN rw_crawepr.idcobope = rw_crawepr.idcobefe THEN '_1' ELSE '_2' END);
    ELSE
      --> Dados do limite
      OPEN cr_craplim(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctrlim => pr_nrctremp
                     ,pr_tpctrlim => pr_tpctrato);
      FETCH cr_craplim INTO rw_craplim;
      CLOSE cr_craplim;
      
      vr_cdagenci := rw_crapass.cdagenci;
      vr_dtctrato := rw_craplim.dtinivig;
      vr_idcobert := rw_craplim.idcobope;
      vr_modrelat := (CASE WHEN rw_craplim.idcobope = rw_craplim.idcobefe THEN '_1' ELSE '_2' END);
    END IF;
    
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA' , 
                                               pr_tpregist => 18 ); --> Aditivo Emprestimo/Financiamento (GED)
     
    vr_tpdocged :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');
    
    --> Montar o qrcode para digitalização
    vr_dsqrcode := fn_qrcode_digitaliz (pr_cdcooper => pr_cdcooper,
                                        pr_cdagenci => vr_cdagenci,
                                        pr_nrdconta => pr_nrdconta,
                                        pr_nrborder => 0,
                                        pr_nrcontra => pr_nrctremp,
                                        pr_nraditiv => pr_nraditiv,
                                        pr_cdtipdoc => vr_tpdocged);
                                    
    vr_idxaditi := vr_tab_aditiv.first;
    vr_dtmvtolt := vr_tab_aditiv(vr_idxaditi).dtmvtolt;
    
    --> buscar dados do operador                                              
    OPEN cr_crapope; 
    FETCH cr_crapope INTO rw_crapope;    
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
    ELSE
      CLOSE cr_crapope;
    END IF;
    
    vr_cdc := 'N';
    
    IF pr_cdaditiv < 9 THEN
      --> Verificar se linha é CDC        
      OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                      pr_cdlcremp => rw_crawepr.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
      CLOSE cr_craplcr;
      
      vr_cdc := empr0003.fn_verifica_cdc(pr_cdcooper => pr_cdcooper, 
                                         pr_dslcremp => rw_craplcr.dslcremp);
    END IF;
    
    -- Montar mascara CNPJ/CPF
    vr_rel_nrcpfcgc := gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,
                                                 rw_crapass.inpessoa);
    
    --Definir dia de pagamento
    vr_dsddpagt := gene0002.fn_valor_extenso(pr_idtipval => 'I', 
                                             pr_valor    => to_char(vr_tab_aditiv(vr_idxaditi).dtdpagto,'DD') );    
    vr_dsddpagt := '(' || TRIM(vr_dsddpagt)|| ')'||' de cada mes.';
    
    --> Concatenar aplicações
    IF vr_tab_aplicacoes.count > 0 THEN
      FOR idx IN vr_tab_aplicacoes.first..vr_tab_aplicacoes.last LOOP
        IF vr_dsaplica IS NOT NULL THEN
          vr_dsaplica := vr_dsaplica ||','||
                         TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(idx).nraplica));
        ELSE
          vr_dsaplica := TRIM(gene0002.fn_mask_contrato(vr_tab_aplicacoes(idx).nraplica));
        END IF;
      END LOOP;    
    END IF;
    
    IF pr_cdaditiv = 3 THEN
      --> dados do interveniente garantidor 
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => vr_tab_aditiv(vr_idxaditi).nrctagar);
      FETCH cr_crapass INTO rw_crapass_gar;
      CLOSE cr_crapass;
      
      vr_dscpfgar := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass_gar.nrcpfcgc,
                                               pr_inpessoa => rw_crapass_gar.inpessoa);
      vr_nmprigar := rw_crapass_gar.nmprimtl;
        
    ELSIF pr_cdaditiv = 4 THEN
    
      IF rw_crawepr.nmdaval1 = vr_tab_aditiv(vr_idxaditi).nmdavali   THEN
        vr_nrctaavl := rw_crawepr.nrctaav1;
      ELSIF rw_crawepr.nmdaval2 = vr_tab_aditiv(vr_idxaditi).nmdavali    THEN
        vr_nrctaavl := rw_crawepr.nrctaav2;
      ELSE
        vr_nrctaavl := 0;
      END IF;  
    ELSIF pr_cdaditiv = 5 THEN
      
      IF vr_tab_aditiv(vr_idxaditi).tpchassi = 1 THEN
        vr_tpchassi := '1 - Remarcado';
      ELSE
        vr_tpchassi := '2 - Normal';
      END IF;
        
    END IF;
    
    --> Carregar clausulas do contrato
    pc_carrega_clausulas ( pr_ddmvtolt => to_char(vr_tab_aditiv(vr_idxaditi).dtdpagto,'DD'),
                           pr_dsddmvto => vr_dsddpagt,
                           pr_dtdpagto => vr_tab_aditiv(vr_idxaditi).dtdpagto,
                           pr_nrctremp => pr_nrctremp, 
                           pr_cdc      => vr_cdc,
                           pr_dsaplica => vr_dsaplica,
                           --pr_nmprimtl => rw_crapass.nmprimtl,
                           --pr_nrdconta => pr_nrdconta,
                           pr_dscpfgar => vr_dscpfgar,
                           pr_nmprigar => vr_nmprigar,
                           pr_nrctagar => vr_tab_aditiv(vr_idxaditi).nrctagar,
                           pr_nmdavali => vr_tab_aditiv(vr_idxaditi).nmdavali,
                           pr_dscpfavl => vr_tab_aditiv(vr_idxaditi).dscpfavl,
                           pr_nrctaavl => vr_nrctaavl,
                           --> automovel
                           pr_dsbemfin => vr_tab_aditiv(vr_idxaditi).dsbemfin,
                           pr_nrrenava => to_char(vr_tab_aditiv(vr_idxaditi).nrrenava,'fm999g999g999g999'),
                           pr_tpchassi => vr_tpchassi,
                           pr_nrdplaca => substr(vr_tab_aditiv(vr_idxaditi).nrdplaca,1,3)
                                       || '-'
                                       || substr(vr_tab_aditiv(vr_idxaditi).nrdplaca,4,4),
                           pr_ufdplaca => vr_tab_aditiv(vr_idxaditi).ufdplaca,
                           pr_dscorbem => vr_tab_aditiv(vr_idxaditi).dscorbem,
                           pr_nranobem => vr_tab_aditiv(vr_idxaditi).nranobem,
                           pr_nrmodbem => vr_tab_aditiv(vr_idxaditi).nrmodbem,
                           pr_uflicenc => vr_tab_aditiv(vr_idxaditi).uflicenc,
                           pr_dscpfpro => vr_tab_aditiv(vr_idxaditi).nrcpfcgc,
                           pr_dsbemant => vr_tab_aditiv(vr_idxaditi).dsbemsub,
                           pr_dscatbem => vr_tab_aditiv(vr_idxaditi).dscatbem,
                           pr_dstipbem => vr_tab_aditiv(vr_idxaditi).dstipbem,
                           pr_dsmarbem => vr_tab_aditiv(vr_idxaditi).dsmarbem,
                           pr_dschassi => vr_tab_aditiv(vr_idxaditi).dschassi,
                           pr_vlrdobem => vr_tab_aditiv(vr_idxaditi).vlrdobem,
                           pr_dspropri => vr_tab_aditiv(vr_idxaditi).dspropri,
                           pr_dstpcomb => vr_tab_aditiv(vr_idxaditi).dstpcomb,
                           pr_tab_clau_adi => vr_tab_clau_adi);
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz><termo>');    
    pc_escreve_xml('<cdaditiv>' || pr_cdaditiv               || '</cdaditiv>'||
                   '<dsqrcode>' || vr_dsqrcode               || '</dsqrcode>'||
                   '<nrctremp>' || TRIM(gene0002.fn_mask_contrato(pr_nrctremp))|| '</nrctremp>' ||
                   '<nraditiv>' || pr_nraditiv               || '</nraditiv>'||
                   '<nrcpfcgc>' || gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa) || '</nrcpfcgc>'||
                   '<dtmvtolt>' || to_char(vr_dtmvtolt,'DD/MM/RRRR')  || '</dtmvtolt>' ||
                   '<nrdconta>' || trim(gene0002.fn_mask_conta(pr_nrdconta)) || '</nrdconta>' ||
                   '<nmprimtl>' || rw_crapass.nmprimtl       || '</nmprimtl>' ||
                   '<nmrescop>' || rw_crapcop.nmextcop       || '</nmrescop>' );    

    -- Testar tipo de pessoa quando houver Avalista
    IF vr_tab_aditiv(vr_idxaditi).nrcpfcgc <> 0 THEN
      IF length(vr_tab_aditiv(vr_idxaditi).nrcpfcgc) > 11 THEN  
        vr_inpessoa := 2;
      ELSE
        vr_inpessoa := 1;
      END IF;
      
      -- Enviar ao XML
      pc_escreve_xml('<nrcpfcgc_adit>' || gene0002.fn_mask_cpf_cnpj(vr_tab_aditiv(vr_idxaditi).nrcpfcgc,vr_Inpessoa) ||'</nrcpfcgc_adit>'||
                     '<nmprimtl_adit>' || vr_tab_aditiv(vr_idxaditi).nmdavali ||'</nmprimtl_adit>');

    ELSE
      -- Enviar ao XML as informacoes em branco
      pc_escreve_xml('<nrcpfcgc_adit>0</nrcpfcgc_adit>'||
                     '<nmprimtl_adit> </nmprimtl_adit>');
    END IF;
    
    
    
    IF pr_cdaditiv < 7 THEN
      pc_escreve_xml('<flctrcdc>' || vr_cdc                || '</flctrcdc>' );

    ELSIF pr_cdaditiv = 9 THEN

      --> Atribuir conta de qualificação
	  vr_nrdconta_quali := pr_nrdconta;

      --> Dados da cobertura
      OPEN cr_cobertura(pr_idcobert => vr_idcobert);
      FETCH cr_cobertura INTO rw_cobertura;
      CLOSE cr_cobertura;
      
      -- Se possui garantidor terceiro
      IF NVL(rw_cobertura.nrconta_terceiro,0) > 0 THEN
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_cobertura.nrconta_terceiro);
        FETCH cr_crapass INTO rw_crapass_gar;
        CLOSE cr_crapass;
	      --> Atribuir conta de qualificação
		  vr_nrdconta_quali := rw_cobertura.nrconta_terceiro;
      END IF;
			
			-- Buscar qualificação do cooperado
			OPEN cr_crapass_quali(pr_cdcooper => pr_cdcooper
			                     ,pr_nrdconta => vr_nrdconta_quali);
			FETCH cr_crapass_quali INTO rw_crapass_quali;
			CLOSE cr_crapass_quali;
			
			-- Verifica se o documento eh um CPF ou CNPJ
			IF rw_crapass_quali.inpessoa = 1 THEN
				-- Busca estado civil e profissao
				OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
												 pr_nrdconta => vr_nrdconta_quali); 
				FETCH cr_gnetcvl INTO rw_gnetcvl;
				CLOSE cr_gnetcvl;

				-- Busca a Nacionalidade
				OPEN  cr_crapnac(pr_cdnacion => rw_crapass_quali.cdnacion);
				FETCH cr_crapnac INTO rw_crapnac;
				CLOSE cr_crapnac;

				vr_dsqualifica := trim(gene0002.fn_mask_conta(rw_crapass_quali.nrdconta)) || ', de titularidade de ' || rw_crapass_quali.nmprimtl
				                 || (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN ', nacionalidade ' || LOWER(rw_crapnac.dsnacion) ELSE '' END)
												 || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.dsproftl) ELSE '' END)
												 || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.rsestcvl) ELSE '' END)
												 || ', inscrito(a) no CPF sob nº ' || gene0002.fn_mask_cpf_cnpj(rw_crapass_quali.nrcpfcgc,rw_crapass_quali.inpessoa)
												 || ', portador(a) do RG n° ' || rw_crapass_quali.nrdocptl 
												 || ', residente e domiciliado(a) na ' || rw_crapass_quali.dsendere 
												 || ', n° '|| rw_crapass_quali.nrendere || ', bairro ' || rw_crapass_quali.nmbairro
												 || ', da cidade de ' || rw_crapass_quali.nmcidade || '/' || rw_crapass_quali.cdufende
												 || ', CEP '|| gene0002.fn_mask(rw_crapass_quali.nrcepend,'99.999-999');
    ELSE
				vr_dsqualifica := trim(gene0002.fn_mask_conta(rw_crapass_quali.nrdconta)) || ', de titularidade de ' || rw_crapass_quali.nmprimtl
				                 || ', inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(rw_crapass_quali.nrcpfcgc,rw_crapass_quali.inpessoa)
												 || ' com sede na ' || rw_crapass_quali.dsendere || ', n° ' || rw_crapass_quali.nrendere
												 || ', bairro ' || rw_crapass_quali.nmbairro || ', da cidade de ' || rw_crapass_quali.nmcidade || '/' || rw_crapass_quali.cdufende
												 || ', CEP ' || gene0002.fn_mask(rw_crapass_quali.nrcepend,'99.999-999');
			END IF;
			

      vr_modrelat := pr_tpctrato || vr_modrelat;

      pc_escreve_xml('<modrelat>'   || vr_modrelat             || '</modrelat>' ||
                     '<tpctrato>'   || pr_tpctrato             || '</tpctrato>' ||
                     '<dscpfcgc>'   || vr_rel_nrcpfcgc         || '</dscpfcgc>' ||
                     '<nmextcop>'   || rw_crapcop.nmextcop     || '</nmextcop>' ||
                     '<nmcopres>'   || rw_crapcop.nmrescop     || '</nmcopres>' ||
                     '<nrdocnpj>'   || GENE0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2) || '</nrdocnpj>' ||
                     '<dtctrato>'   || TO_CHAR(vr_dtctrato,'DD/MM/RRRR') || '</dtctrato>' ||
                     '<perminimo>'  || TO_CHAR(rw_cobertura.perminimo,'FM999G999G999G990D00')  || '</perminimo>' ||
                     '<nminterv>'   || rw_crapass_gar.nmprimtl    ||'</nminterv>'  ||
                     '<cpfinterv>'  || GENE0002.fn_mask_cpf_cnpj(rw_crapass_gar.nrcpfcgc,rw_crapass_gar.inpessoa) || '</cpfinterv>' ||
                     '<qtdiatraso>' || rw_cobertura.qtdias_atraso_permitido || '</qtdiatraso>' ||
					 '<dsqualific>' || vr_dsqualifica || '</dsqualific>');

      CASE pr_tpctrato
        --> LIM CRED
        WHEN 1 THEN
          vr_tpctrava := 3;
        --> DSC CHQ 
        WHEN 2 THEN
          vr_tpctrava := 2;
        --> DSC TIT 
        WHEN 3 THEN
          vr_tpctrava := 8;
        --> EMPRESTIMO
        WHEN 90 THEN
          vr_tpctrava := 1;
      END CASE;

      -- Listar avalistas de contratos
      DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper  --> Codigo da Cooperativa
                                 ,pr_cdagenci => pr_cdagenci  --> Codigo da agencia
                                 ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                                 ,pr_cdoperad => pr_cdoperad  --> Codigo do Operador
                                 ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                 ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                                 ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                 ,pr_idseqttl => 1            --> Sequencial do titular
                                 ,pr_tpctrato => vr_tpctrava  --> Tipo de contrato
                                 ,pr_nrctrato => pr_nrctremp  --> Numero do contrato
                                 ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
                                 ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
                                  --------> OUT <--------                                   
                                 ,pr_tab_dados_avais => vr_tab_aval   --> retorna dados do avalista
                                 ,pr_cdcritic        => vr_cdcritic   --> Código da crítica
                                 ,pr_dscritic        => vr_dscritic); --> Descrição da crítica
      
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      IF vr_tab_aval.COUNT > 0 THEN
        pc_escreve_xml('<fiadores>');
        FOR vr_ind_aval IN vr_tab_aval.FIRST..vr_tab_aval.LAST LOOP
          pc_escreve_xml('<fiador'|| vr_ind_aval || '>
                               <nmdavali>' || vr_tab_aval(vr_ind_aval).nmdavali || '</nmdavali>
                               <cpfavali>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcgc,vr_tab_aval(vr_ind_aval).inpessoa) || '</cpfavali>
                               <nmconjug>' || vr_tab_aval(vr_ind_aval).nmconjug || '</nmconjug>
                               <nrcpfcjg>' || GENE0002.fn_mask_cpf_cnpj(vr_tab_aval(vr_ind_aval).nrcpfcjg,1) || '</nrcpfcjg>
                         </fiador'|| vr_ind_aval || '>');
        END LOOP;
        pc_escreve_xml('</fiadores>');
      END IF;

    ELSE

      --Listar promissorias
      vr_totpromi     := 0;
      IF pr_cdaditiv = 7 THEN
        pc_escreve_xml('<promissorias>');
        vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.first;
        WHILE vr_idxpromi IS NOT NULL LOOP
          vr_totpromi := vr_totpromi + 
                           vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis;
                           
          pc_escreve_xml('<promis>
                            <nrpromis>'|| vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).nrpromis ||'</nrpromis>
                            <vlpromis>'|| to_char(vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis,'FM999G999G999G990D00')   ||'</vlpromis>
                          </promis>');                       

          vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.next(vr_idxpromi);
        END LOOP;                    
        pc_escreve_xml('</promissorias>');      
      ELSE
        vr_idxpromi := vr_tab_aditiv(vr_idxaditi).promis.first;
        IF vr_idxpromi IS NOT NULL THEN
          vr_totpromi := vr_tab_aditiv(vr_idxaditi).promis(vr_idxpromi).vlpromis;
        END IF;
      END IF;  
      vr_rel_vlpromis := gene0002.fn_valor_extenso(pr_idtipval => 'M', 
                                                   pr_valor    => vr_totpromi );      
      
      vr_rel_nrcpfgar := gene0002.fn_mask_cpf_cnpj(vr_tab_aditiv(vr_idxaditi).nrcpfgar,1);
              
      pc_escreve_xml('<nmdgaran>'     || vr_tab_aditiv(vr_idxaditi).nmdgaran  || '</nmdgaran>' ||
                     '<nrcpfgar>'     || vr_rel_nrcpfgar                      || '</nrcpfgar>' ||
                     '<totpromi>'     || to_char(vr_totpromi,'FM999G999G999G990D00') || '</totpromi>' ||
                     '<totpromi_ext>' || vr_rel_vlpromis                      || '</totpromi_ext>' ||                                         
                     '<dscpfcgc>'     || vr_rel_nrcpfcgc                      || '</dscpfcgc>');
    END IF;
    
    --> EXIBIR CLAUSULAS DO CONTRATO
    IF vr_tab_clau_adi.EXISTS(pr_cdaditiv) THEN
      vr_tab_clausulas := vr_tab_clau_adi(pr_cdaditiv).clausula;
      IF vr_tab_clausulas.count > 0 THEN
        pc_escreve_xml('<clausulas>');
        FOR vr_idx IN vr_tab_clausulas.first..vr_tab_clausulas.last LOOP
          pc_escreve_xml('<clausula>
                            <texto><![CDATA['||vr_tab_clausulas(vr_idx) ||']]></texto>
                         </clausula>');    
        END LOOP;    
        pc_escreve_xml('</clausulas>');
      END IF;
    END IF;  
    
    --> ASSINATURAS
    IF pr_cdaditiv = 9 THEN
      vr_rel_nmcidade := rw_crapcop.nmcidade||'/'|| rw_crapcop.cdufdcop ||', '||gene0005.fn_data_extenso(pr_dtmvtolt)||'.';
    ELSE
    vr_rel_nmcidade := rw_crapcop.nmcidade||', '||gene0005.fn_data_extenso(pr_dtmvtolt)||'.';
    END IF;

    pc_escreve_xml('<nmcidade>'||vr_rel_nmcidade||'</nmcidade>');
    
    IF pr_cdaditiv < 7 THEN
      
      pc_escreve_xml('<assinaturas>');
      --> Dados do avalista 1 e conjuge
      IF nvl(rw_crawepr.nrctaav1,0) <> 0    OR
         TRIM(rw_crawepr.nmdaval1) IS NOT NULL THEN
        pc_Trata_Assinatura ( pr_cdcooper     => pr_cdcooper,
                              pr_nrdconta     => pr_nrdconta,
                              pr_nrctremp     => pr_nrctremp,
                              pr_nrctaava     => rw_crawepr.nrctaav1,
                              pr_nmdavali     => rw_crawepr.nmdaval1,
                              pr_iddoaval     => 1,
                              pr_cdaditiv     => pr_cdaditiv,
                              pr_linhatra     => vr_linhatra,
                              pr_nmdevsol     => vr_nmdevsol,
                              pr_dscpfcgc     => vr_dscpfcgc,
                              pr_dsendere     => vr_dsendere,
                              pr_dstelefo     => vr_dstelefo,
                              pr_linhatra_cje => vr_linhatra_cje,
                              pr_nmdevsol_cje => vr_nmdevsol_cje,
                              pr_dscpfcgc_cje => vr_dscpfcgc_cje,
                              pr_dsendere_cje => vr_dsendere_cje,
                              pr_dstelefo_cje => vr_dstelefo_cje,
                              pr_cdcritic     => vr_cdcritic, 
                              pr_dscritic     => vr_dscritic);
                              
        IF TRIM(vr_linhatra) IS NOT NULL THEN
          pc_escreve_xml('<avalista>
                             <linhatra>'       ||  vr_linhatra    ||'</linhatra>'||
                            '<nmdevsol>'       ||  vr_nmdevsol    ||'</nmdevsol>'||
                            '<dscpfcgc>'       ||  vr_dscpfcgc    ||'</dscpfcgc>'||
                            '<dsendere>'       ||  vr_dsendere    ||'</dsendere>'||
                            '<dstelefo>'       ||  vr_dstelefo    ||'</dstelefo>'||
                            '<vr_linhatra_cje>'|| vr_linhatra_cje ||'</vr_linhatra_cje>'||
                            '<vr_nmdevsol_cje>'|| vr_nmdevsol_cje ||'</vr_nmdevsol_cje>'||
                            '<vr_dscpfcgc_cje>'|| vr_dscpfcgc_cje ||'</vr_dscpfcgc_cje>'||
                            '<vr_dsendere_cje>'|| vr_dsendere_cje ||'</vr_dsendere_cje>'||
                            '<vr_dstelefo_cje>'|| vr_dstelefo_cje ||'</vr_dstelefo_cje>
                          </avalista>');
        END IF; 
        
        --> Dados do avalista 2 e conjuge 
        IF nvl(rw_crawepr.nrctaav2,0) <> 0    OR
           TRIM(rw_crawepr.nmdaval2) IS NOT NULL THEN
          pc_Trata_Assinatura ( pr_cdcooper     => pr_cdcooper,
                                pr_nrdconta     => pr_nrdconta,
                                pr_nrctremp     => pr_nrctremp,
                                pr_nrctaava     => rw_crawepr.nrctaav2,
                                pr_nmdavali     => rw_crawepr.nmdaval2,
                                pr_iddoaval     => 2,
                                pr_cdaditiv     => pr_cdaditiv,
                                pr_linhatra     => vr_linhatra,
                                pr_nmdevsol     => vr_nmdevsol,
                                pr_dscpfcgc     => vr_dscpfcgc,
                                pr_dsendere     => vr_dsendere,
                                pr_dstelefo     => vr_dstelefo,
                                pr_linhatra_cje => vr_linhatra_cje,
                                pr_nmdevsol_cje => vr_nmdevsol_cje,
                                pr_dscpfcgc_cje => vr_dscpfcgc_cje,
                                pr_dsendere_cje => vr_dsendere_cje,
                                pr_dstelefo_cje => vr_dstelefo_cje,
                                pr_cdcritic     => vr_cdcritic, 
                                pr_dscritic     => vr_dscritic);
                                
          IF TRIM(vr_linhatra) IS NOT NULL THEN
            pc_escreve_xml('<avalista>
                             <linhatra>'       ||  vr_linhatra    ||'</linhatra>'||
                            '<nmdevsol>'       ||  vr_nmdevsol    ||'</nmdevsol>'||
                            '<dscpfcgc>'       ||  vr_dscpfcgc    ||'</dscpfcgc>'||
                            '<dsendere>'       ||  vr_dsendere    ||'</dsendere>'||
                            '<dstelefo>'       ||  vr_dstelefo    ||'</dstelefo>'||
                            '<vr_linhatra_cje>'|| vr_linhatra_cje ||'</vr_linhatra_cje>'||
                            '<vr_nmdevsol_cje>'|| vr_nmdevsol_cje ||'</vr_nmdevsol_cje>'||
                            '<vr_dscpfcgc_cje>'|| vr_dscpfcgc_cje ||'</vr_dscpfcgc_cje>'||
                            '<vr_dsendere_cje>'|| vr_dsendere_cje ||'</vr_dsendere_cje>'||
                            '<vr_dstelefo_cje>'|| vr_dstelefo_cje ||'</vr_dstelefo_cje>
                          </avalista>');
          END IF; 
        END IF; 
        
      END IF; 

      pc_escreve_xml('</assinaturas>');
    END IF;  
    
    --> Descarregar buffer
    pc_escreve_xml('</termo></raiz>',TRUE);
    
    IF pr_cdaditiv < 7 THEN
      vr_dsjasper := 'crrl724_aditiv.jasper';
    ELSIF pr_cdaditiv = 9 THEN
      vr_dsjasper := 'crrl724_aditiv_tipo9.jasper';
    ELSE
      vr_dsjasper := 'crrl724_aditiv_declaracao.jasper';
    END IF;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/termo'
                               , pr_dsjasper  => vr_dsjasper
                               , pr_cdrelato  => 724
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'S'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;
    
    -- copia contrato pdf do diretorio da cooperativa para servidor web
    gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                               , pr_cdagenci => NULL
                               , pr_nrdcaixa => NULL
                               , pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_des_reto => vr_des_reto
                               , pr_tab_erro => vr_tab_erro
                               );

    -- caso apresente erro na operação
    IF nvl(vr_des_reto,'OK') <> 'OK' THEN
      IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;

    -- Remover relatorio do diretorio padrao da cooperativa
    gene0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);

    -- Se retornou erro
    IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT null THEN
      -- Concatena o erro que veio
      vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
      RAISE vr_exc_erro; -- encerra programa
    END IF;
    
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
          
  EXCEPTION
    WHEN vr_exc_sucesso THEN
      NULL; --> Apenas retornar para programa chamador
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao aditivo: ' || SQLERRM, chr(13)),chr(10));   
  END pc_gera_impressao_aditiv;

  PROCEDURE pc_busca_dados_garopc(pr_cddopcao     IN VARCHAR2 --> Opcao selecionada
                                 ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                                 ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                                 ,pr_nrctremp     IN crapadt.nrctremp%TYPE --> Numero do contrato
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_dados_garopc
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Seleciona dados do emprestimo
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE
                       ,pr_cddopcao IN VARCHAR2) IS
        SELECT wpr.idcobope
              ,lcr.cdlcremp codlinha
              ,0 vlropera
          FROM crawepr wpr
              ,crapepr epr
              ,craplcr lcr 
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp = pr_nrctremp
           AND wpr.cdcooper = lcr.cdcooper
           AND wpr.cdlcremp = lcr.cdlcremp
           AND wpr.cdcooper = epr.cdcooper
           AND wpr.nrdconta = epr.nrdconta
           AND wpr.nrctremp = epr.nrctremp
           AND epr.inliquid = DECODE(pr_cddopcao, 'I', 0, epr.inliquid); -- 0 - Ativo
           
      -- Seleciona dados do limite
      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE
                       ,pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                       ,pr_cddopcao IN VARCHAR2) IS
        SELECT craplim.idcobope
              ,craplim.cddlinha codlinha
              ,craplim.vllimite vlropera
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.nrctrlim = pr_nrctrlim
           AND craplim.tpctrlim = pr_tpctrlim
           AND craplim.insitlim = DECODE(pr_cddopcao, 'I', 2, craplim.insitlim); -- 2 - Ativo

      rw_dados   cr_crapepr%ROWTYPE;
      
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      vr_des_reto VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis locais
      vr_blnachou BOOLEAN;
      vr_dstextab craptab.dstextab%TYPE;
      vr_inusatab BOOLEAN;
      vr_vltotpre NUMBER(25,2) := 0;
      vr_qtprecal NUMBER(10) := 0;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ADITIV'
                                ,pr_action => NULL);

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Se for Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Seleciona dados do emprestimo
        OPEN cr_crapepr(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctremp => pr_nrctremp
                       ,pr_cddopcao => pr_cddopcao);
        FETCH cr_crapepr INTO rw_dados;
        vr_blnachou := cr_crapepr%FOUND;
        CLOSE cr_crapepr;

        -- Calendario da cooperativa
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;

        -- Buscar configurações necessárias para busca de saldo de empréstimo
        -- Verificar se usa tabela juros
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'USUARI'
                                                 ,pr_cdempres => 11
                                                 ,pr_cdacesso => 'TAXATABELA'
                                                 ,pr_tpregist => 0);
        -- Se a primeira posição do campo dstextab for diferente de zero
        vr_inusatab := SUBSTR(vr_dstextab,1,1) != '0';
                    
        -- Buscar o saldo devedor atualizado do contrato
        EMPR0001.pc_saldo_devedor_epr (pr_cdcooper => vr_cdcooper       --> Cooperativa conectada
                                      ,pr_cdagenci => 1                 --> Codigo da agencia
                                      ,pr_nrdcaixa => 0                 --> Numero do caixa
                                      ,pr_cdoperad => '1'               --> Codigo do operador
                                      ,pr_nmdatela => 'ATENDA'          --> Nome datela conectada
                                      ,pr_idorigem => 1 /*Ayllos*/      --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta       --> Conta do associado
                                      ,pr_idseqttl => 1                 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                      ,pr_nrctremp => pr_nrctremp       --> Numero contrato emprestimo
                                      ,pr_cdprogra => 'B1WGEN0001'      --> Programa conectado
                                      ,pr_inusatab => vr_inusatab       --> Indicador de utilizacão da tabela
                                      ,pr_flgerlog => 'N'               --> Gerar log S/N
                                      ,pr_vlsdeved => rw_dados.vlropera --> Saldo devedor calculado
                                      ,pr_vltotpre => vr_vltotpre       --> Valor total das prestacães
                                      ,pr_qtprecal => vr_qtprecal       --> Parcelas calculadas
                                      ,pr_des_reto => vr_des_reto       --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);     --> Tabela com possives erros
        -- Se houve retorno de erro
        IF vr_des_reto = 'NOK' THEN
          -- Extrair o codigo e critica de erro da tabela de erro
          vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          -- Limpar tabela de erros
          vr_tab_erro.DELETE;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Seleciona dados do limite
        OPEN cr_craplim(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrlim => pr_nrctremp
                       ,pr_tpctrlim => pr_tpctrato
                       ,pr_cddopcao => pr_cddopcao);
        FETCH cr_craplim INTO rw_dados;
        vr_blnachou := cr_craplim%FOUND;
        CLOSE cr_craplim;
      END IF;

      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Contrato inexistente ou inativo.';
        RAISE vr_exc_erro;
      END IF;

      -- Se nao achou linha
      IF rw_dados.codlinha = 0 THEN
        vr_dscritic := 'Linha não encontrada.';
        RAISE vr_exc_erro;
      END IF;

      -- Se nao achou valor
      IF rw_dados.vlropera = 0 THEN
        vr_dscritic := 'Valor da operação deverá ser superior a 0.';
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'idcobope'
                            ,pr_tag_cont => (CASE WHEN pr_cddopcao = 'I' THEN 0 ELSE rw_dados.idcobope END)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'codlinha'
                            ,pr_tag_cont => rw_dados.codlinha
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlropera'
                            ,pr_tag_cont => TO_CHAR(rw_dados.vlropera,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados_garopc;

  PROCEDURE pc_busca_cobert_garopc_prog(pr_idcobert  IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                                       ,pr_inresaut OUT tbgar_cobertura_operacao.inresgate_automatico%TYPE --> Resgate Automatico (0-Nao/ 1-Sim)
                                       ,pr_permingr OUT tbgar_cobertura_operacao.perminimo%TYPE --> Percentual minimo da cobertura da garantia
                                       ,pr_inaplpro OUT tbgar_cobertura_operacao.inaplicacao_propria%TYPE --> Aplicacao propria (0-Nao/ 1-Sim)
                                       ,pr_inpoupro OUT tbgar_cobertura_operacao.inpoupanca_propria%TYPE --> Poupanca propria (0-Nao/ 1-Sim)
                                       ,pr_nrctater OUT tbgar_cobertura_operacao.nrconta_terceiro%TYPE --> Conta de terceiro
                                       ,pr_inaplter OUT tbgar_cobertura_operacao.inaplicacao_terceiro%TYPE --> Aplicacao de terceiro (0-Nao/ 1-Sim)
                                       ,pr_inpouter OUT tbgar_cobertura_operacao.inpoupanca_terceiro%TYPE --> Poupanca de terceiro (0-Nao/ 1-Sim)
                                       ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

        Programa: pc_busca_cobert_garopc_prog
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Jaison Fernando
        Data    : Novembro/2017.                    Ultima atualizacao: 

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado.

        Objetivo  : Rotina responsavel em buscar dados da cobertura e retornar ao Progress.

        Observacao: -----

        Alteracoes: 

    ..............................................................................*/
    DECLARE
      -- Seleciona garantias para operacoes de credito
      CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT tco.inresgate_automatico
              ,tco.perminimo           
              ,tco.inaplicacao_propria 
              ,tco.inpoupanca_propria  
              ,tco.nrconta_terceiro    
              ,tco.inaplicacao_terceiro
              ,tco.inpoupanca_terceiro 
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;

    BEGIN

      -- Seleciona garantias para operacoes de credito
      OPEN cr_cobertura(pr_idcobert => pr_idcobert);
      FETCH cr_cobertura INTO rw_cobertura;
      CLOSE cr_cobertura;

      -- Retorna os valores
      pr_inresaut := NVL(rw_cobertura.inresgate_automatico,0);
      pr_permingr := NVL(rw_cobertura.perminimo,0);
      pr_inaplpro := NVL(rw_cobertura.inaplicacao_propria,0);
      pr_inpoupro := NVL(rw_cobertura.inpoupanca_propria,0);
      pr_nrctater := NVL(rw_cobertura.nrconta_terceiro,0);
      pr_inaplter := NVL(rw_cobertura.inaplicacao_terceiro,0);
      pr_inpouter := NVL(rw_cobertura.inpoupanca_terceiro,0);

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao buscar dados tbgar_cobertura_operacao: ' || SQLERRM;
    END;

  END pc_busca_cobert_garopc_prog;

  PROCEDURE pc_busca_tipo_aditivo(pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                                 ,pr_nrctremp     IN crapadt.nrctremp%TYPE --> Numero do contrato
                                 ,pr_nraditiv     IN crapadt.nraditiv%TYPE --> Numero do Adivito
                                 ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_tipo_aditivo
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Novembro/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar o tipo do aditivo.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Seleciona tipo
      CURSOR cr_crapadt(pr_cdcooper IN crapadt.cdcooper%TYPE
                       ,pr_nrdconta IN crapadt.nrdconta%TYPE
                       ,pr_nrctremp IN crapadt.nrctremp%TYPE
                       ,pr_nraditiv IN crapadt.nraditiv%TYPE
                       ,pr_tpctrato IN crapadt.tpctrato%TYPE) IS
        SELECT crapadt.cdaditiv
          FROM crapadt
         WHERE crapadt.cdcooper = pr_cdcooper
           AND crapadt.nrdconta = pr_nrdconta
           AND crapadt.nrctremp = pr_nrctremp
           AND crapadt.nraditiv = pr_nraditiv
           AND crapadt.tpctrato = pr_tpctrato;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis locais
      vr_cdaditiv crapadt.cdaditiv%TYPE;

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona tipo
      OPEN cr_crapadt(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp
                     ,pr_nraditiv => pr_nraditiv
                     ,pr_tpctrato => pr_tpctrato);
      FETCH cr_crapadt INTO vr_cdaditiv;
      CLOSE cr_crapadt;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdaditiv'
                            ,pr_tag_cont => NVL(vr_cdaditiv,0)
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_tipo_aditivo;
  
  
  procedure pc_obtem_nro_aditivo(par_cdcooper in crapadt.cdcooper%type,
                                 par_nrdconta in crapadt.nrdconta%type,
                                 par_nrctremp in crapadt.nrctremp%type,
                                 par_tpctrato in crapadt.tpctrato%type,
                                 par_uladitiv out crapadt.nraditiv%type) is
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_obtem_nro_aditivo
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Daniel - Envolti
    Data     : Setembro/2018                         Ultima atualizacao: 18/09/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Obter o número do aditivo
    
    Alterações : xx/xx/xxxx - 

    -------------------------------------------------------------------------------------------------------------*/    
    cursor cr_crapadt is
      select nvl(max(nraditiv), 0) + 1
        from crapadt
       where crapadt.cdcooper = par_cdcooper
         and crapadt.nrdconta = par_nrdconta
         and crapadt.nrctremp = par_nrctremp
         and crapadt.tpctrato = par_tpctrato;
  begin
    open cr_crapadt;
      fetch cr_crapadt into par_uladitiv;
    IF cr_crapadt%NOTFOUND THEN
      par_uladitiv := 1;
    END IF;
    close cr_crapadt;
  end;
  
  procedure pc_cria_aditivo (par_cdcooper in crawepr.cdcooper%type,
                             par_nrdconta in crawepr.nrdconta%type,
                             par_nrctremp in crawepr.nrctremp%type,
                             par_dtmvtolt in crapadt.dtmvtolt%type,
                             par_cdagenci in crapadt.cdagenci%type,
                             par_cdoperad in crapadt.cdoperad%type,
                             par_tpctrato in crapadt.tpctrato%type,
                             par_nrcpfcgc in crapass.nrcpfcgc%type,
                             par_dsbemfin in crapadi.dsbemfin%type,
                             par_dschassi in crapadi.dschassi%type,
                             par_nrdplaca in crapadi.nrdplaca%type,
                             par_dscorbem in crapadi.dscorbem%type,
                             par_nranobem in crapadi.nranobem%type,
                             par_nrmodbem in crapadi.nrmodbem%type,
                             par_nrrenava in crapadi.nrrenava%type,
                             par_tpchassi in crapadi.tpchassi%type,
                             par_ufdplaca in crapadi.ufdplaca%type,
                             par_uflicenc in crapadi.uflicenc%type,
                             par_dscatbem in crapadi.dscatbem%type,
                             par_dsmarbem in crapadi.dsmarbem%type,
                             par_vlfipbem in crapadi.vlfipbem%type,
                             par_vlrdobem in crapadi.vlrdobem%type,
                             par_dstipbem in crapadi.dstipbem%type,
                             par_dstpcomb in crapadi.dstpcomb%type,
                             par_idseqbem in crapadi.idseqbem%type,
                             par_idseqsub in crapadi.idseqsub%type,
                             par_rowidepr out varchar2,
                             par_uladitiv out crapadt.nraditiv%type,
                             par_cdcritic out number,
                             par_dscritic out varchar2) is
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_cria_aditivo
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Daniel - Envolti
    Data     : Setembro/2018                         Ultima atualizacao: 18/09/2018
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Criar o aditivo
    
    Alterações : xx/xx/xxxx - 

    -------------------------------------------------------------------------------------------------------------*/    
    -- Checar se a proposta existe
    cursor cr_crawepr is
      select rowid
        from crawepr
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta
         and nrctremp = par_nrctremp;
    
    -- BUscar dados do Associado do Contrato
    cursor cr_crapass1 is
      select nrcpfcgc,
             nmprimtl
        from crapass
       where cdcooper = par_cdcooper
         and nrdconta = par_nrdconta;
    v_crapass1       cr_crapass1%rowtype;
    -- Buscar dados do Interveniente Garantidor
    cursor cr_crapavt is
      select nrcpfcgc,
             nmdavali
        from crapavt
       where crapavt.cdcooper = par_cdcooper
         AND crapavt.tpctrato = 9
         AND crapavt.nrdconta = par_nrdconta
         AND crapavt.nrctremp = par_nrctremp
         AND crapavt.nrcpfcgc = par_nrcpfcgc;
    v_crapavt        cr_crapavt%rowtype;
    
    -- Buscar dados de qualquer conta do Cooperado (Quando não Interveniente)
    cursor cr_crapass2 is
      select nrcpfcgc,
             nmprimtl
        from crapass
       where nrcpfcgc = par_nrcpfcgc
       order by progress_recid DESC;
    v_crapass2       cr_crapass2%rowtype;
    --
    v_nrcpfcgc       crapadi.nrcpfcgc%type;
    v_nmdavali       crapadi.nmdavali%type;
    --
    vr_exc_erro      exception;
  begin
    -- Obtem novo numero de Aditivo
    pc_obtem_nro_aditivo(par_cdcooper,
                         par_nrdconta,
                         par_nrctremp,
                         par_tpctrato,
                         par_uladitiv);
    
    -- Checar se a proposta existe
    open cr_crawepr;
      fetch cr_crawepr into par_rowidepr;
      if cr_crawepr%notfound then
        par_cdcritic := 356;
        raise vr_exc_erro;
      end if;
    close cr_crawepr;
    
    -- Criar o Aditivo
    insert into crapadt (nrdconta,
                         nrctremp,
                         nraditiv,
                         dtmvtolt,
                         cdaditiv,
                         cdcooper,
                         flgdigit,
                         cdagenci,
                         cdoperad,
                         tpctrato)
    values (par_nrdconta,
            par_nrctremp,
            par_uladitiv,
            par_dtmvtolt,
            5,
            par_cdcooper,
            0,
            par_cdagenci,
            par_cdoperad,
            par_tpctrato);
    
    /*** GRAVAMES - Apenas quando tipo 5 ***/
    /* Verificar o CPF da conta do contrato */
    open cr_crapass1;
      fetch cr_crapass1 into v_crapass1;
      if cr_crapass1%found then
        v_nrcpfcgc := v_crapass1.nrcpfcgc;
        v_nmdavali := v_crapass1.nmprimtl;
      end if;
    close cr_crapass1;
    
    -- Se foi enviado CPF Avalista 
    if nvl(par_nrcpfcgc, 0) <> 0 AND nvl(par_nrcpfcgc, 0) <> nvl(v_crapass1.nrcpfcgc, 0) then
      -- Buscar dados como Interveniente Garantidor
      open cr_crapavt;
        fetch cr_crapavt into v_crapavt;
        if cr_crapavt%found then
          v_nrcpfcgc := v_crapavt.nrcpfcgc;
          v_nmdavali := v_crapavt.nmdavali;
        ELSE
          -- Buscar dados em qualquer conta do Cooperado
          open cr_crapass2;
            fetch cr_crapass2 into v_crapass2;
            if cr_crapass2%found THEN
              v_nrcpfcgc := v_crapass2.nrcpfcgc;
              v_nmdavali := v_crapass2.nmprimtl;
            ELSE
              -- Limpar avalista e mantem o contratante
              v_nrcpfcgc := 0;
            end if;
          close cr_crapass2;  
        end if;
      close cr_crapavt;
    else
      -- Limpar avalista e mantem o contratante
      v_nrcpfcgc := 0;
    end if;
    
    -- Criar item do Aditivo
    insert into crapadi (nrdconta,
                         nrctremp,
                         nraditiv,
                         nrsequen,
                         nrcpfcgc,
                         dsbemfin,
                         dschassi,
                         nrdplaca,
                         dscorbem,
                         nranobem,
                         nrmodbem,
                         nmdavali,
                         nrrenava,
                         tpchassi,
                         ufdplaca,
                         uflicenc,
                         cdcooper,
                         tpctrato,
                         dscatbem,
                         dsmarbem,
                         vlfipbem,
                         vlrdobem,
                         dstipbem,
                         dstpcomb,
                         idseqbem,
                         idseqsub)
    values (par_nrdconta,
            par_nrctremp,
            par_uladitiv,
            1,
            v_nrcpfcgc,
            par_dsbemfin,
            par_dschassi,
            par_nrdplaca,
            par_dscorbem,
            par_nranobem,
            par_nrmodbem,
            v_nmdavali,
            par_nrrenava,
            par_tpchassi,
            par_ufdplaca,
            par_uflicenc,
            par_cdcooper,
            par_tpctrato,
            par_dscatbem,
            par_dsmarbem,
            par_vlfipbem,
            par_vlrdobem,
            par_dstipbem,
            par_dstpcomb,
            par_idseqbem,
            par_idseqsub);
    
  exception
    when vr_exc_erro then
      if par_cdcritic <> 0 and
         par_dscritic is null then
        par_dscritic := gene0001.fn_busca_critica(pr_cdcritic => par_cdcritic);
      end if;
    when others then
      par_cdcritic := 0;
      par_dscritic := 'Erro nao tratado na rotina TELA_ADITIV.PC_CRIA_ADITIVO: ' || sqlerrm;
  end;
  
  procedure pc_cadastro_interveniente(pr_cdcooper in crapavt.cdcooper%type,
                                      pr_nrdconta in crapavt.nrdconta%type,
                                      pr_nrctremp in crapavt.nrctremp%type,
                                      pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                                      pr_cdcritic out number,
                                      pr_dscritic out varchar2) is
    -- Buscar se existe Interveniente
    cursor cr_crapavt is
      select 1
        from crapavt
       where cdcooper = pr_cdcooper
         and tpctrato = 9
         and nrdconta = pr_nrdconta
         and nrctremp = pr_nrctremp
         and nrcpfcgc = pr_nrcpfcgc;
    vr_indexis number;
    -- Buscar associado
    cursor cr_crapass is
      select c.nmprimtl,
             n.dsnacion,
             c.dsproftl,
             case t.cdestcvl
               when  1 then 'SOLTEIRO(A)'
               when  2 then 'CASADO(A)-COMUNHAO UNIVERSAL'
               when  3 then 'CASADO(A)-COMUNHAO PARCIAL'
               when  4 then 'CASADO(A)-SEPARACAO DE BENS'
               when  5 then 'VIUVO(A)'
               when  6 then 'SEPARADO(A) JUDICIALMENTE'
               when  7 then 'DIVORCIADO(A)'
               when  8 then 'CASADO(A)-REGIME TOTAL'
               when  9 then 'CAS REGIME MISTO OU ESPECIAL'
               when 11 then 'CASADO(A)-PART.FINAL AQUESTOS'
               else null
             end dsestcvl,
             c.nrcpfcgc,
             c.inpessoa,
             e.dsendere,
             e.nrendere,
             e.nmbairro,
             e.nmcidade,
             e.cdufende,
             e.nrcepend,
             c.nrdconta,
             j.nrcpfcjg,
             j.nmconjug,
             j.tpdoccje,
             j.nrdoccje,
             c.tpdocptl,
             c.nrdocptl,
             f.nrtelefo,
             m.dsdemail,
             c.cdnacion,
             e.complend,
             e.nrcxapst
        from crapnac n,
             crapenc e,
             crapttl t,
             craptfc f,
             crapcem m,
             crapcje j,
             crapass c
       where (   (    nvl(pr_nrcpfcgc, 0) <> 0
                  and c.nrcpfcgc = pr_nrcpfcgc)
              or (    nvl(pr_nrcpfcgc, 0) = 0
                  and c.cdcooper = pr_cdcooper
                  and c.nrdconta = pr_nrdconta))
         and n.cdnacion = c.cdnacion
         and j.cdcooper(+) = c.cdcooper
         and j.nrdconta(+) = c.nrdconta
         and j.idseqttl(+) = 1
         and f.nrdconta(+) = c.nrdconta
         and f.cdcooper(+) = c.cdcooper
         and f.idseqttl(+) = 1
         and m.nrdconta(+) = c.nrdconta
         and m.cdcooper(+) = c.cdcooper
         and m.idseqttl(+) = 1
         and t.nrdconta(+) = c.nrdconta
         and t.cdcooper(+) = c.cdcooper
         and t.idseqttl(+) = 1
         and e.cdcooper = c.cdcooper
         and e.nrdconta = c.nrdconta
         and e.idseqttl = 1
         and e.tpendass = decode(c.inpessoa,1,10,9);
    vr_crapass   cr_crapass%rowtype;
  begin
    -- Testar se o CPF está na lista de avalistas ou intervenientes
    open cr_crapavt;
      fetch cr_crapavt into vr_indexis;
      -- Se não encontrar
      if cr_crapavt%notfound then
        close cr_crapavt;
        -- Verificar se o CPF é de algum Cooperado
        open cr_crapass;
          fetch cr_crapass into vr_crapass;
          -- Se não encontrar
          if cr_crapass%notfound then
            -- Esta situação não deve ocorrer, pois quando não existe o cpf, a tela obriga a cadastrar. Portanto, não tratamos neste ponto.
            close cr_crapass;
            return;
          end if;
        close cr_crapass;
        -- Cria o interveniente
        tela_manbem.pc_cria_interveniente(par_cdcooper  => pr_cdcooper,
                                          par_nrdconta  => pr_nrdconta,
                                          par_nrctremp  => pr_nrctremp,
                                          par_nrcpfcgc  => pr_nrcpfcgc,
                                          par_nmdavali  => vr_crapass.nmprimtl,
                                          par_nrcpfcjg  => vr_crapass.nrcpfcjg,
                                          par_inpessoa  => vr_crapass.inpessoa,
                                          par_nmconjug  => vr_crapass.nmconjug,
                                          par_tpdoccjg  => vr_crapass.tpdoccje,
                                          par_nrdoccjg  => vr_crapass.nrdoccje,
                                          par_tpdocava  => vr_crapass.tpdocptl,
                                          par_nrdocava  => vr_crapass.nrdocptl,
                                          par_dsendres1 => vr_crapass.dsendere,
                                          par_dsendres2 => vr_crapass.nmbairro,
                                          par_nrfonres  => vr_crapass.nrtelefo,
                                          par_dsdemail  => vr_crapass.dsdemail,
                                          par_nmcidade  => vr_crapass.nmcidade,
                                          par_cdufresd  => vr_crapass.cdufende,
                                          par_nrcepend  => vr_crapass.nrcepend,
                                          par_cdnacion  => vr_crapass.cdnacion,
                                          par_nrendere  => vr_crapass.nrendere,
                                          par_complend  => vr_crapass.complend,
                                          par_nrcxapst  => vr_crapass.nrcxapst,
                                          par_dtnascto  => null,
                                          par_cdcritic  => pr_cdcritic,
                                          par_dscritic  => pr_dscritic);
      ELSE
        CLOSE cr_crapavt;
      end IF;
      
  exception
    when others then
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na rotina TELA_ADITIV.pc_cadastro_interveniente: ' || sqlerrm;
  end;


  /* Rotina para gravação do Tipo05 oriunda de chamada do AyllosWeb */
  PROCEDURE pc_grava_aditivo_tipo5(pr_nrdconta in crawepr.nrdconta%type --> Conta
                                  ,pr_nrctremp in varchar2 --> Contrato
                                  ,pr_tpctrato in varchar2 --> Tipo Contrato
                                  ,pr_dscatbem in varchar2 --> Categoria (Auto, Moto, Caminhão ou Outros Veiculos)
                                  ,pr_dstipbem in varchar2 --> Tipo do Bem (Usado/Zero KM)
                                  ,pr_dsmarbem in varchar2 --> Marca do Bem
                                  ,pr_nrmodbem in varchar2 --> Ano Modelo
                                  ,pr_nranobem in varchar2 --> Ano Fabricação
                                  ,pr_dsbemfin in varchar2 --> Modelo bem financiado
                                  ,pr_vlfipbem in varchar2 --> Valor da FIPE
                                  ,pr_vlrdobem in varchar2 --> Valor do bem
                                  ,pr_tpchassi in varchar2 --> Tipo Chassi
                                  ,pr_dschassi in varchar2 --> Chassi
                                  ,pr_dscorbem in varchar2 --> Cor
                                  ,pr_ufdplaca in varchar2 --> UF Placa
                                  ,pr_nrdplaca in varchar2 --> Placa
                                  ,pr_nrrenava in varchar2 --> Renavam
                                  ,pr_uflicenc in varchar2 --> UF Licenciamento
                                  ,pr_nrcpfcgc in varchar2 --> CPF Interveniente
                                  ,pr_idseqbem IN VARCHAR2 --> Sequencia do bem em substituição
                                  ,pr_cdopeapr IN VARCHAR2 --> Operador da aprovação
                                  ,pr_nrgravam IN VARCHAR2 --> Numero gravame
                                  ,pr_xmllog   IN VARCHAR2 --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                                  ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

    Programa: pc_grava_aditivo_tipo5
    Sistema : Ayllos Web
    Autor   : Marcos Martini - Envolti
    Data    : Julho/2017                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar o Aditivo do Tipo 05 - Substituição de Bens

    Alteracoes: -----
    ..............................................................................*/
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis
    rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
    vr_dsmodbem   VARCHAR2(100);
    vr_nrmodbem   crapadi.nrmodbem%type;
    vr_dstpcomb   crapadi.dstpcomb%type;
    vr_rowidepr   varchar2(20);
    vr_uladitiv   crapadt.nraditiv%type;
    vr_nmopeapr   crapope.nmoperad%type;
    vr_idseqant   crapadi.idseqbem%type;
    vr_idseqnov   crapadi.idseqbem%type;
      
    --> Buscar dados da proposta de emprestimo
    CURSOR cr_crawepr IS
      SELECT epr.nrctremp,
             epr.dtmvtolt,
             epr.nrdconta,
             lcr.tpctrato
        FROM crawepr epr
            ,craplcr lcr            
       WHERE epr.cdcooper = lcr.cdcooper
         AND epr.cdlcremp = lcr.cdlcremp
         AND epr.cdcooper = vr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;      
    --
    cursor cr_crapope is
      select nmoperad
        from crapope
       where cdcooper = vr_cdcooper
         and cdoperad = pr_cdopeapr;
    v_rowid       ROWID;     
  BEGIN
    -- Extrai os dados vindos do XML
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;                         
                             
    -- Buscar data do sistema
    -- Verifica se a cooperativa esta cadastrada
    open btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      -- Se não encontrar
      if btch0001.cr_crapdat%notfound then
        -- Fechar o cursor pois haverá raise
        close btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        raise vr_exc_saida;
      end if;
    close btch0001.cr_crapdat;
    -- Buscar dados do emprestimo
    if pr_tpctrato = 90 then
      --> Validar emprestimo
      open cr_crawepr;
        fetch cr_crawepr into rw_crawepr;
        if cr_crawepr%notfound then
          close cr_crawepr;
          vr_dscritic := 'Contrato/Proposta de emprestimo nao encontrado';
          raise vr_exc_saida;
        end if;
      close cr_crawepr;
    else
      vr_cdcritic := 14; -- 014 - Opcao errada.
      raise vr_exc_saida;
    end if; --> Fim IF pr_cddopcao
      
    -- Tratar situação do Zero KM no serviço da Fipe
    vr_dsmodbem := upper(pr_nrmodbem);
    IF vr_dsmodbem LIKE 'ZERO KM%' THEN
      -- Trocar Zero KM pelo ano corrente
      vr_dsmodbem := (to_number(to_char(SYSDATE,'RRRR'))+1)||REPLACE(vr_dsmodbem,'ZERO KM','');
    END IF;
    
    -- Separa os dados do modelo. Ano e tipo de combustível chegam no mesmo campo. (Ex: "2018 GASOLINA")
    vr_nrmodbem := substr(vr_dsmodbem, 1, 4);
    vr_dstpcomb := ltrim(substr(vr_dsmodbem, 5));
    
    -- Se Gravames Online habilitado e não recebemos o numero da Alienação
    IF grvm0001.fn_tem_gravame_online(vr_cdcooper) = 'S' THEN
      IF pr_nrgravam IS NULL THEN
        vr_dscritic := 'Numero da alienacao e obrigatorio para geracao de Aditivo Contrato de Substituicao de Veiculo!';
        raise vr_exc_saida;
      END IF;
    END IF;
    
    -- Guardar ID bem anterior, pois ele poderá ser alterado caso dê erro 
    -- na cópia do mesmo para tpctrato = 99 caso já exista outro bem substituido
    vr_idseqant := pr_idseqbem;

    -- Chamar substituição de Bem
    tela_manbem.pc_substitui_bem(par_cdcooper => vr_cdcooper,
                                 par_nrdconta => pr_nrdconta,
                                 par_nrctremp => pr_nrctremp,
                                 par_idseqbem => vr_idseqant,
                                 par_cdoperad => vr_cdoperad,
                                 par_dscatbem => upper(pr_dscatbem),
                                 par_dtmvtolt => rw_crapdat.dtmvtolt,
                                 par_dsbemfin => gene0007.fn_caract_acento(upper(pr_dsbemfin)),
                                 par_nmdatela => vr_nmdatela,
                                 par_cddopcao => 'I',
                                 par_tplcrato => rw_crawepr.tpctrato,
                                 par_uladitiv => vr_uladitiv,
                                 par_cdaditiv => 5,
                                 par_flgpagto => null,
                                 par_dtdpagto => null,
                                 par_tpctrato => pr_tpctrato,
                                 par_dschassi => upper(pr_dschassi),
                                 par_nrdplaca => upper(nvl(pr_nrdplaca,' ')),
                                 par_dscorbem => upper(pr_dscorbem),
                                 par_nranobem => pr_nranobem,
                                 par_nrmodbem => vr_nrmodbem,
                                 par_nrrenava => nvl(pr_nrrenava,0),
                                 par_tpchassi => pr_tpchassi,
                                 par_ufdplaca => upper(nvl(pr_ufdplaca,' ')),
                                 par_uflicenc => upper(pr_uflicenc),
                                 par_nrcpfcgc => pr_nrcpfcgc,
                                 par_vlmerbem => pr_vlrdobem,
                                 par_dstipbem => upper(pr_dstipbem),
                                 par_dsmarbem => gene0007.fn_caract_acento(upper(pr_dsmarbem)),
                                 par_vlfipbem => pr_vlfipbem,
                                 par_dstpcomb => upper(vr_dstpcomb),
                                 par_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem),
                                 par_nrgravam => pr_nrgravam,
                                 par_idseqnov => vr_idseqnov,
                                 par_cdcritic => vr_cdcritic,
                                 par_dscritic => vr_dscritic);
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
      
    -- Chamar gravação do Adtivo
    pc_cria_aditivo(par_cdcooper => vr_cdcooper,
                    par_nrdconta => pr_nrdconta,
                    par_nrctremp => pr_nrctremp,
                    par_dtmvtolt => rw_crapdat.dtmvtolt,
                    par_cdagenci => vr_cdagenci,
                    par_cdoperad => vr_cdoperad,
                    par_tpctrato => pr_tpctrato,
                    par_nrcpfcgc => pr_nrcpfcgc,
                    par_dsbemfin => upper(pr_dsbemfin),
                    par_dschassi => upper(pr_dschassi),
                    par_nrdplaca => upper(nvl(pr_nrdplaca,' ')),
                    par_dscorbem => upper(pr_dscorbem),
                    par_nranobem => pr_nranobem,
                    par_nrmodbem => vr_nrmodbem,
                    par_nrrenava => nvl(pr_nrrenava,0),
                    par_tpchassi => pr_tpchassi,
                    par_ufdplaca => upper(nvl(pr_ufdplaca,0)),
                    par_uflicenc => upper(pr_uflicenc),
                    par_dscatbem => upper(pr_dscatbem),
                    par_dsmarbem => upper(pr_dsmarbem),
                    par_vlfipbem => pr_vlfipbem,
                    par_vlrdobem => pr_vlrdobem,
                    par_dstipbem => upper(pr_dstipbem),
                    par_dstpcomb => upper(vr_dstpcomb),
                    par_idseqbem => vr_idseqnov,
                    par_idseqsub => vr_idseqant,
                    par_rowidepr => vr_rowidepr,
                    par_uladitiv => vr_uladitiv,
                    par_cdcritic => vr_cdcritic,
                    par_dscritic => vr_dscritic);
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Verificar se o interveniente está cadastrado. Cadastrar caso não esteja.
    IF pr_nrcpfcgc > 0 THEN
      pc_cadastro_interveniente(pr_cdcooper => vr_cdcooper,
                                pr_nrdconta => pr_nrdconta,
                                pr_nrctremp => pr_nrctremp,
                                pr_nrcpfcgc => pr_nrcpfcgc,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic);
      if vr_cdcritic > 0 or
         vr_dscritic is not null then
        raise vr_exc_saida;
      end if;
    END IF;
        
    -- Geracao de LOG 
    if pr_cdopeapr is not null then
      -- Busca nome do operador
      open cr_crapope;
        fetch cr_crapope into vr_nmopeapr;
        if cr_crapope%found then
          -- Gerar LOG
          gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => pr_cdopeapr,
                               pr_dscritic => vr_dscritic,
                               pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem),
                               pr_dstransa => ('Substituicao de Alienacao de Bem - Aditivo ' || to_char(vr_uladitiv) || ' - Aprovado por Coordenador ' || pr_cdopeapr || ' - ' || vr_nmopeapr ||'.'),
                               pr_dttransa => trunc(SYSDATE),
                               pr_flgtrans => 1,
                               pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS')),
                               pr_idseqttl => 1,
                               pr_nmdatela => vr_nmdatela,
                               pr_nrdconta => pr_nrdconta,
                               pr_nrdrowid => v_rowid); 
        end if;
      close cr_crapope;
    end if;
    
    -- Retornar aditivo criado
    pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root><Dados NRADITIV="' || vr_uladitiv || '"/></Root>');
                                     
    
    --
    commit;
  EXCEPTION
    when vr_exc_saida then
      pr_cdcritic := vr_cdcritic;
      if vr_dscritic is null and
         pr_cdcritic > 0 then
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      end if;
      pr_dscritic := vr_dscritic;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
    when others then
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro na rotina TELA_ADITIV.PC_GRAVA_ADITIVO_TIPO5: ' || sqlerrm;
      -- Carregar XML padrao para variavel de retorno
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      rollback;
  END;

END TELA_ADITIV;
/
