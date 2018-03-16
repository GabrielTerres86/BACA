CREATE OR REPLACE PACKAGE CECRED.DSCT0002 AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0002                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : Odirlei Busana - AMcom 
  --  Data    : Agosto/2016                     Ultima Atualizacao: 20/06/2017
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto titulos
  --              titulos.
  --
  --  Alteracoes: 05/08/2016 - Conversao Progress para oracle (Odirlei - AMcom)
  --
  --              22/12/2016 - Incluidos novos campos para os tipos typ_rec_contrato_limite
  --                           e typ_rec_chq_bordero. Projeto 300 (Lombardi)
  --  
  --              02/03/2017 - Tornar a pc_lista_avalistas publica. (P210.2 - Jaison/Daniel)
  --  
  --              20/06/2017 - Incluida validacao de tamanho na atribuicao do campo de operador
  --                           (ID + Nome) pois estava estourando a variavel.
  --                           Heitor (Mouts) - Chamado 695581
  --
  --             11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))
  --
  --------------------------------------------------------------------------------------------------------------*/
 
  -- Tabela para armazenar parametros para desconto de titulo(antigo b1wgen0030tt.i/tt-dsctit.)
  TYPE typ_rec_dados_dsctit 
       IS RECORD (vllimite  NUMBER, 
                  vlconsul  NUMBER,
                  vlmaxsac  NUMBER,
                  vlminsac  NUMBER,
                  qtremcrt  INTEGER,
                  qttitprt  INTEGER,
                  qtrenova  INTEGER,
                  qtdiavig  INTEGER,
                  qtprzmin  INTEGER,
                  qtprzmax  INTEGER,
                  qtminfil  INTEGER,
                  nrmespsq  INTEGER,
                  pctitemi  NUMBER,
                  pctolera  NUMBER,
                  pcdmulta  NUMBER,
                  cardbtit  NUMBER,
                  pcnaopag  NUMBER,
                  qtnaopag  INTEGER,
                  qtprotes  INTEGER);
  
  TYPE typ_tab_dados_dsctit IS TABLE OF typ_rec_dados_dsctit 
       INDEX BY PLS_INTEGER;
       
  -- Tabela para armazenar parametros para desconto de titulo - Cecred (antigo b1wgen0030tt.i/tt-dados_cecred_dsctit)    
  TYPE typ_tab_cecred_dsctit IS TABLE OF typ_rec_dados_dsctit 
       INDEX BY PLS_INTEGER;
  
  TYPE typ_rec_dados_limite 
       IS RECORD (pcdmulta NUMBER,
                  codlinha crapldc.cddlinha%TYPE,
                  dsdlinha crapldc.dsdlinha%TYPE,
                  txjurmor crapldc.txjurmor%TYPE,
                  dsramati crapprp.dsramati%TYPE,
                  vlmedtit crapprp.vlmedchq%TYPE,
                  vlfatura crapprp.vlfatura%TYPE,
                  vloutras crapprp.vloutras%TYPE,
                  vlsalari crapprp.vlsalari%TYPE,
                  vlsalcon crapprp.vlsalcon%TYPE,
                  dsdbens1 crapprp.dsdebens%TYPE,
                  dsdbens2 crapprp.dsdebens%TYPE,
                  dsobserv crapprp.dsobserv##1%TYPE,
                  insitlim craplim.insitlim%TYPE,
                  nrctrlim craplim.nrctrlim%TYPE,
                  vllimite craplim.vllimite%TYPE,
                  qtdiavig craplim.qtdiavig%TYPE,
                  cddlinha craplim.cddlinha%TYPE,
                  dtcancel craplim.dtcancel%TYPE,
                  nrctaav1 craplim.nrctaav1%TYPE,
                  nrctaav2 craplim.nrctaav2%TYPE,
                  flgdigit craplim.flgdigit%TYPE,
                  cdtipdoc INTEGER,
                  ------->> Rating <<------
                  nrgarope craplim.nrgarope%TYPE,
                  nrinfcad craplim.nrinfcad%TYPE,
                  nrliquid craplim.nrliquid%TYPE,
                  nrpatlvr craplim.nrpatlvr%TYPE,
                  vltotsfn craplim.vltotsfn%TYPE,
                  nrperger craplim.nrperger%TYPE,
                  perfatcl crapjfn.perfatcl%TYPE,
                  idcobope craplim.idcobope%TYPE);
              
  TYPE typ_tab_dados_limite IS TABLE OF typ_rec_dados_limite       
       INDEX BY PLS_INTEGER;
  
  --> Armazenar dados dos avalistas antigo(b1wgen9999tt.i/tt-dados-avais)     
  TYPE typ_rec_dados_avais 
       IS RECORD ( nrctaava crapass.nrdconta%TYPE,
                   nmdavali crapass.nmprimtl%TYPE,
                   nrcpfcgc crapass.nrcpfcgc%TYPE,
                   nrdocava VARCHAR2(100),
                   tpdocava VARCHAR2(100),
                   nmconjug crapcje.nmconjug%TYPE,
                   nrcpfcjg crapcje.nrcpfcjg%TYPE,
                   nrdoccjg VARCHAR2(100),                              
                   tpdoccjg VARCHAR2(100),
                   nrfonres VARCHAR2(50),
                   dsdemail crapcem.dsdemail%TYPE,
                   dsendere crapenc.dsendere%TYPE,
                   dsendcmp crapenc.nmbairro%TYPE, --> Complementar
                   nmcidade crapenc.nmcidade%TYPE,
                   cdufresd crapenc.cdufende%TYPE,
                   nrcepend crapenc.nrcepend%TYPE,
                   dsnacion crapnac.dsnacion%TYPE,
                   vledvmto NUMBER,
                   vlrenmes NUMBER,
                   idavalis INTEGER,
                   nrendere crapenc.nrendere%TYPE,
                   complend crapenc.complend%TYPE,
                   nrcxapst crapenc.nrcxapst%TYPE,
                   inpessoa crapass.inpessoa%TYPE,
                   cdestcvl crapavt.cdestcvl%TYPE);
  TYPE typ_tab_dados_avais IS TABLE OF typ_rec_dados_avais     
       INDEX BY PLS_INTEGER;

  --> Armazenar dados do bordero antigo(b1wgen0030tt.i/tt-dsctit_dados_bordero) 
  TYPE typ_rec_dados_border
       IS RECORD (dsopedig  VARCHAR2(200),   
                  dsopelib  VARCHAR2(200),
                  nrborder  crapbdt.nrborder%TYPE,
                  nrctrlim  crapbdt.nrctrlim%TYPE,
                  insitbdt  crapbdt.insitbdt%TYPE,
                  insitbdc  crapbdc.insitbdc%TYPE,
                  txmensal  crapbdt.txmensal%TYPE,
                  dtlibbdt  crapbdt.dtlibbdt%TYPE,
                  dtlibbdc  crapbdc.dtlibbdc%TYPE,
                  txdiaria  crapldc.txdiaria%TYPE,
                  txjurmor  crapldc.txjurmor%TYPE,
                  qttitulo  craplot.qtcompln%TYPE,
                  vltitulo  craplot.vlcompcr%TYPE,
                  qtcheque  craplot.qtcompln%TYPE,
                  vlcheque  craplot.vlcompcr%TYPE,
                  dspesqui  VARCHAR2(200),
                  dsdlinha  VARCHAR2(200),
                  flgdigit  crapbdt.flgdigit%TYPE,
                  cdtipdoc  VARCHAR2(80),
                  dsopecoo  VARCHAR2(100)
                  );
  TYPE typ_tab_dados_border IS TABLE OF typ_rec_dados_border
       INDEX BY PLS_INTEGER;  

  
  --> Armazenar dados dos titulos do bordero antigo(b1wgen0030tt.i/tt-tits_do_bordero) 
  TYPE typ_rec_tit_bordero
       IS RECORD (nrdctabb craptdb.nrdctabb%TYPE,
                  nrcnvcob craptdb.nrcnvcob%TYPE,
                  nrinssac craptdb.nrinssac%TYPE,
                  cdbandoc craptdb.cdbandoc%TYPE,
                  nrdconta craptdb.nrdconta%TYPE,
                  nrdocmto craptdb.nrdocmto%TYPE,
                  dtvencto craptdb.dtvencto%TYPE,
                  dtlibbdt craptdb.dtlibbdt%TYPE,
                  nossonum VARCHAR2(50),
                  vltitulo craptdb.vltitulo%TYPE,
                  vlliquid craptdb.vlliquid%TYPE,
                  nmsacado crapsab.nmdsacad%TYPE,
                  insittit craptdb.insittit%TYPE,
                  flgregis crapcob.flgregis%TYPE);

  TYPE typ_tab_tit_bordero IS TABLE OF typ_rec_tit_bordero
       INDEX BY VARCHAR2(50);
         
  --> Armazenar dados das retrições dos titulos do bordero antigo(b1wgen0030tt.i/tt-dsctit_bordero_restricoes) 
  TYPE typ_rec_bordero_restric
       IS RECORD (nrborder crapabt.nrborder%TYPE,
                  nrdocmto crapabt.nrdocmto%TYPE,
                  nrcheque crapcdb.nrcheque%TYPE,
                  tprestri INTEGER,
                  dsrestri crapabc.dsrestri%TYPE,
                  nrseqdig crapabt.nrseqdig%TYPE,
                  flaprcoo crapabc.flaprcoo%TYPE,
                  dsdetres crapabc.dsdetres%TYPE);
  TYPE typ_tab_bordero_restri IS TABLE OF typ_rec_bordero_restric
       INDEX BY PLS_INTEGER;     
  
  --> Armazena sacados que nao pagaram titulos antigo(b1wgen0030tt.i/tt-sacado_nao_pagou) 
  TYPE typ_rec_sacado_nao_pagou
       IS RECORD(nmsacado crapsab.nmdsacad%TYPE, 
                 qtdtitul INTEGER, 
                 vlrtitul NUMBER);
  TYPE typ_tab_sacado_nao_pagou IS TABLE OF typ_rec_sacado_nao_pagou
       INDEX BY VARCHAR2(200);
       
  -->  Armazena dados dos titulos do bordero antigo(b1wgen0030tt.i/tt-dados_tits_bordero) 
  TYPE typ_rec_dados_itens_bordero 
       IS RECORD (nrdconta crapass.nrdconta%TYPE,
                  cdagenci crapass.cdagenci%TYPE,
                  nrctrlim craplim.nrctrlim%TYPE,
                  nrborder crapbdt.nrborder%TYPE,
                  nrmespsq INTEGER,
                  txdiaria NUMBER,
                  txmensal NUMBER,
                  txdanual NUMBER,
                  vllimite crapass.nrdconta%TYPE,
                  ddmvtolt INTEGER,
                  dsmesref VARCHAR2(30),
                  aamvtolt INTEGER,
                  nmprimtl crapass.nmprimtl%TYPE,
                  nmrescop crapcop.nmrescop%TYPE,
                  nmextcop crapcop.nmextcop%TYPE,
                  nmcidade crapcop.nmcidade%TYPE,
                  nmoperad crapope.nmoperad%TYPE,
                  dsopecoo crapope.nmoperad%TYPE);
  TYPE typ_tab_dados_itens_bordero IS TABLE OF typ_rec_dados_itens_bordero
       INDEX BY PLS_INTEGER;        
       
  -->  Armazena dados dos titulos do bordero antigo(b1wgen0030tt.i/tt-contrato_limite) 
  TYPE typ_rec_contrato_limite 
       IS RECORD (nmcidade   VARCHAR2(200),
                  nrctrlim   INTEGER,
                  nmextcop   VARCHAR2(200),
                  cdagenci   VARCHAR2(5),
                  dslinha1   VARCHAR2(400),
                  dslinha2   VARCHAR2(400),
                  nmprimtl   VARCHAR2(200),
                  nrdconta   INTEGER,
                  nrcpfcgc   VARCHAR2(200),
                  txnrdcid   VARCHAR2(200),
                  dsdmoeda   VARCHAR2(200),
                  vllimite   NUMBER,
                  dslimite   VARCHAR2(200),
                  dsdlinha   VARCHAR2(200),
                  qtdiavig   INTEGER,
                  txqtdvig   VARCHAR2(200),
                  dsjurmor   VARCHAR2(200),
                  txdmulta   NUMBER,
                  txmulext   VARCHAR2(200),
                  nmrescop   VARCHAR2(200),
                  nrtelsac   VARCHAR2(200),
                  nrtelouv   VARCHAR2(200),
                  dsendweb   VARCHAR2(200),
                  nmdaval1   VARCHAR2(200),
                  linaval1   VARCHAR2(4000),
                  nmdcjav1   VARCHAR2(200),
                  dscpfav1   VARCHAR2(200),
                  dscfcav1   VARCHAR2(200),
                  nrfonav1   VARCHAR2(200),
                  nmdaval2   VARCHAR2(4000),
                  linaval2   VARCHAR2(4000),
                  nmdcjav2   VARCHAR2(200),
                  dscpfav2   VARCHAR2(200),
                  dscfcav2   VARCHAR2(200),
                  nrfonav2   VARCHAR2(200),
                  nmoperad   VARCHAR2(200));
  
  TYPE typ_tab_contrato_limite IS TABLE OF typ_rec_contrato_limite
       INDEX BY PLS_INTEGER;  
         
  -- Tabela para armazenar parametros para desconto de cheque(antigo b1wgen0009tt.i/tt-dados_dscchq)
  TYPE typ_rec_dados_dscchq
       IS RECORD (vllimite  NUMBER,
                  vlconchq  NUMBER,
                  vlmaxemi  NUMBER,
                  qtdiavig  INTEGER,
                  qtprzmin  INTEGER,
                  qtprzmax  INTEGER,
                  pcchqemi  NUMBER,
                  pcchqloc  NUMBER,
                  qtdevchq  NUMBER,
                  pctolera  NUMBER,
                  pcdmulta  NUMBER,
                  qtdiasoc  INTEGER);

  TYPE typ_tab_dados_dscchq IS TABLE OF typ_rec_dados_dscchq
       INDEX BY PLS_INTEGER;

  -- Tabela para armazenar dados da nota promissoria(antigo b1wgen0009tt.i/tt-dados_nota_pro_chq)
  TYPE typ_rec_dados_nota_pro
       IS RECORD (ddmvtolt  INTEGER,
                  aamvtolt  INTEGER,
                  vlpreemp  NUMBER,
                  dsctremp  VARCHAR2(100),
                  dscpfcgc  VARCHAR2(100),
                  dsmesref  VARCHAR2(100),
                  dsemsnot  VARCHAR2(200),
                  dsendass  VARCHAR2(1000),
                  dtvencto  DATE,
                  dsmvtolt  VARCHAR2(200),
                  dspreemp  VARCHAR2(200),
                  nmrescop  crapcop.nmrescop%TYPE,
                  nmextcop  crapcop.nmextcop%TYPE,
                  nrdocnpj  VARCHAR2(20),
                  dsdmoeda  VARCHAR2(200),
                  nmprimtl  crapass.nmprimtl%TYPE,
                  nrdconta  crapass.nrdconta%TYPE,
                  nmcidpac  VARCHAR2(200));

  TYPE typ_tab_dados_nota_pro IS TABLE OF typ_rec_dados_nota_pro
       INDEX BY PLS_INTEGER;

  -- Armazenar dados dos cheques do bordero antigo(b1wgen0009tt.i/tt-chqs_do_bordero)
  TYPE typ_rec_chq_bordero
       IS RECORD (cdcmpchq crapcdb.cdcmpchq%TYPE,
                  cdbanchq crapcdb.cdbanchq%TYPE,
                  cdagechq crapcdb.cdagechq%TYPE,
                  nrddigc1 crapcdb.nrddigc1%TYPE,
                  nrctachq crapcdb.nrctachq%TYPE,
                  nrddigc2 crapcdb.nrddigc2%TYPE,
                  nrcheque crapcdb.nrcheque%TYPE,
                  nrddigc3 crapcdb.nrddigc3%TYPE,
                  vlcheque crapcdb.vlcheque%TYPE,
                  vlliquid crapcdb.vlliquid%TYPE,
                  dscpfcgc VARCHAR2(20),
                  dtlibera crapcdb.dtlibera%TYPE,
                  nmcheque VARCHAR2(200),
                  dtlibbdc crapcdb.dtlibbdc%TYPE,
                  dtmvtolt crapdat.dtmvtolt%TYPE,
                  insitana crapcdb.insitana%TYPE,
                  nrdolote crapcst.nrdolote%TYPE,
                  insitprv crapcst.insitprv%TYPE);

  TYPE typ_tab_chq_bordero IS TABLE OF typ_rec_chq_bordero
       INDEX BY PLS_INTEGER;
  
  TYPE typ_tab_restri_apr_coo IS TABLE OF VARCHAR2(100)
       INDEX BY VARCHAR2(100);
                 
  --> listar avalistas de contratos
  PROCEDURE pc_lista_avalistas ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta do cooperado
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                ,pr_tpctrato IN INTEGER                --> Tipo de contrado
                                ,pr_nrctrato IN crapepr.nrctremp%TYPE  --> Numero do contrato
                                ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Numero da conta do primeiro avalista
                                ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Numero da conta do segundo avalista
                                 --------> OUT <--------                                   
                                ,pr_tab_dados_avais   OUT typ_tab_dados_avais   --> retorna dados do avalista
                                ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2);            --> Descrição da crítica
                 
  --> Buscar dados para montar contratos etc para desconto de titulos
  PROCEDURE pc_busca_dados_imp_descont( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                       ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                       ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                       ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                       ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                       ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                       ,pr_nrborder IN NUMBER                 --> Numero do bordero
                                       ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                       ,pr_limorbor IN INTEGER                --> Indicador do tipo de dado( 1 - LIMITE DSCTIT 2 - BORDERO DSCTIT)
                                       ,pr_nrvrsctr IN NUMBER DEFAULT 0       --> Numero da versao do contrato
                                       --------> OUT <--------         
                                       --> Tabelas nao serao retornadar pois nao foram convetidas parao projeto indexacao(qrcode)                          
                                       --> pr_tab_emprsts             
                                       --> pr_tab_proposta_limite    
                                       --> pr_tab_proposta_bordero     
                                       ,pr_tab_contrato_limite        OUT DSCT0002.typ_tab_contrato_limite
                                       ,pr_tab_dados_avais            OUT DSCT0002.typ_tab_dados_avais
                                       ,pr_tab_dados_nota_pro         OUT DSCT0002.typ_tab_dados_nota_pro                                     
                                       ,pr_tab_dados_itens_bordero    OUT DSCT0002.typ_tab_dados_itens_bordero
                                       ,pr_tab_tit_bordero            OUT DSCT0002.typ_tab_tit_bordero
                                       ,pr_tab_chq_bordero            OUT DSCT0002.typ_tab_chq_bordero
                                       ,pr_tab_bordero_restri         OUT DSCT0002.typ_tab_bordero_restri
                                       ,pr_tab_sacado_nao_pagou       OUT DSCT0002.typ_tab_sacado_nao_pagou
                                       ,pr_cdcritic                   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic                   OUT VARCHAR2);           --> Descrição da crítica
   
   
  --> Procedure para gerar impressoes do limite de credito 
  PROCEDURE pc_gera_impressao_limite( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);           --> Descrição da crítica            
       
  --> Procedure para gerar impressoes de bordero de tit.
  PROCEDURE pc_gera_impressao_bordero( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);             --> Descrição da crítica     
END  DSCT0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.DSCT0002 AS

 /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCT0002                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : Odirlei Busana - AMcom
  --  Data    : Agosto/2016                     Ultima Atualizacao: 17/04/2017
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto titulos
  --              titulos.
  --
  --  Alteracoes: 05/08/2016 - Conversao Progress para oracle (Odirlei - AMcom)
  --              
  --              22/12/2016 - Incluidos novos campos para os tipos typ_rec_contrato_limite
  --                           e typ_rec_chq_bordero. Projeto 300 (Lombardi)
  --  
  --              17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
  --
  --              24/07/2017 - Alterar cdoedptl para idorgexp.
  --                           PRJ339-CRM  (Odirlei-AMcom)
  --
  --------------------------------------------------------------------------------------------------------------*/
  --> Buscar dados do avalista
  PROCEDURE pc_busca_dados_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE           --> Numero da conta do cooperado
                                    ,pr_nrctrato IN crapavt.nrctremp%TYPE DEFAULT 0 --> Numero do contrato para busca de avalistas terceiros
                                    ,pr_tpctrato IN crapavt.tpctrato%TYPE DEFAULT 0 --> Tipo do contrato para busca de avalistas terceiros
                                    ,pr_tpavalis IN INTEGER                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                     --------> OUT <--------                                   
                                    ,pr_tab_dados_avais IN OUT typ_tab_dados_avais  --> tabela contendo os parametros da cooperativa
                                    ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic           OUT VARCHAR2) IS         --> Descrição da críticaIS
    ---------->> CURSORES <<--------   
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
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
             ass.cdcooper,             
             ass.cdnacion
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;       
    
    --> Busca as informaçoes do titular da conta 
    CURSOR cr_crapttl (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE, 
                       pr_idseqttl crapttl.idseqttl%TYPE )IS
      SELECT ttl.nrdconta,
             ttl.nmextttl,
             ttl.nrcpfcgc,
             ttl.tpdocttl,
             ttl.nrdocttl,
             ttl.cdgraupr,
             ttl.vlsalari    + 
             ttl.vldrendi##1 + 
             ttl.vldrendi##2 +
             ttl.vldrendi##3 +
             ttl.vldrendi##4 +
             ttl.vldrendi##5 +
             ttl.vldrendi##6 vlrenmes
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE; 
        
    --> Buscar endereço
    CURSOR cr_crapenc (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE ) IS
      SELECT enc.nrdconta,
             enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende,
             enc.complend,
             enc.nrcxapst
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;
  
    --> Buscar endevidamento do aval cooperado 
    CURSOR cr_crapsdv (pr_cdcooper crapsdv.cdcooper%TYPE,
                       pr_nrdconta crapsdv.nrdconta%TYPE ) IS
      SELECT nvl(SUM(sdv.vldsaldo),0)
        FROM crapsdv sdv
       WHERE sdv.cdcooper = pr_cdcooper
         AND sdv.nrdconta = pr_nrdconta
         AND sdv.tpdsaldo IN (1,2,3,6);   
    
    --> Buscar email do cooperado
    CURSOR cr_crapcem (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT cem.dsdemail
        FROM crapcem cem
       WHERE cem.cdcooper = pr_cdcooper
         AND cem.nrdconta = pr_nrdconta
         AND cem.idseqttl = 1;
    rw_crapcem cr_crapcem%ROWTYPE;
        
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
    
    --> Buscar conjuge do cooperado
    CURSOR cr_crapcje ( pr_cdcooper crapcje.cdcooper%TYPE,
                        pr_nrdconta crapcje.nrdconta%TYPE )IS
      SELECT cje.nrdconta,
             cje.nrctacje,
             cje.cdcooper,
             cje.nmconjug,
             cje.nrcpfcjg,
             cje.tpdoccje,
             cje.nrdoccje
        FROM crapcje cje
       WHERE cje.cdcooper = pr_cdcooper
         AND cje.nrdconta = pr_nrdconta
         AND cje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    --> Buscar dados avalista terceiro
    CURSOR cr_crapavt IS
      SELECT avt.nrdconta,
             avt.nmdavali,
             avt.nrcpfcgc,
             avt.tpdocava,
             avt.nrdocava,
             avt.nmconjug,
             avt.nrcpfcjg,
             avt.tpdoccjg,
             avt.nrdoccjg,
             avt.dsendres##1,
             avt.dsendres##2,
             avt.nrfonres,
             avt.dsdemail,
             avt.nmcidade,
             avt.cdufresd,
             avt.nrcepend,
             avt.cdnacion,
             avt.vledvmto,
             avt.vlrenmes,
             avt.nrendere,
             avt.complend,
             avt.nrcxapst,
             avt.inpessoa,
             avt.cdestcvl
        FROM crapavt avt
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.tpctrato = pr_tpctrato
         AND avt.nrdconta = pr_nrdconta
         AND avt.nrctremp = pr_nrctrato;
    
    --> Busca a Nacionalidade
    CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
      SELECT crapnac.dsnacion
        FROM crapnac
       WHERE crapnac.cdnacion = pr_cdnacion;
    
         
    --------->> VARIAVEIS <<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION; 
    
    vr_idxavais        PLS_INTEGER;
    vr_nrdocava        VARCHAR2(100);
    vr_cdgraupr        NUMBER;
    vr_vlrenmes        NUMBER;
    vr_vledvmto        NUMBER;
    vr_nmconjug        crapcje.nmconjug%TYPE;
    vr_nrcpfcjg        crapcje.nrcpfcjg%TYPE;
    vr_dsnacion        crapnac.dsnacion%TYPE;
    vr_nrcpfstl        crapttl.nrcpfcgc%TYPE;
    
  BEGIN
  
    -- Se for avalista cooperado
    IF pr_tpavalis = 1 THEN
      --> Buscar conta do cooperado avalista
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN 
        CLOSE cr_crapass;
        vr_cdcritic := 9; -- Associado nao encontrado
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;
      
      --> Buscar endereço do avalista
      OPEN cr_crapenc ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);      
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN
        CLOSE cr_crapenc;
        vr_dscritic := 'Endereco nao cadastrado.';
        RAISE vr_exc_erro;      
      ELSE
        CLOSE cr_crapenc;
      END IF;  
      
      IF rw_crapass.inpessoa = 1 THEN
        vr_nrdocava := 'C.P.F. ';
      ELSE
        vr_nrdocava := 'CNPJ ';
      END IF;
      vr_nrdocava := vr_nrdocava ||
                     gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                               pr_inpessoa => rw_crapass.inpessoa);
      
      vr_cdgraupr := 0;
      vr_vlrenmes := 0;
	  vr_nrcpfstl := 0;
      
      --Pessoa fisica
      IF rw_crapass.inpessoa = 1 THEN
        rw_crapttl := NULL;
        --> Busca as informaçoes do segundo titular da conta
        OPEN cr_crapttl ( pr_cdcooper => rw_crapass.cdcooper,
                          pr_nrdconta => rw_crapass.nrdconta,
                          pr_idseqttl => 2);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%FOUND THEN
          vr_cdgraupr := rw_crapttl.cdgraupr;
		  vr_nrcpfstl := rw_crapttl.nrcpfcgc;
        END IF;
        CLOSE cr_crapttl;              
        
        rw_crapttl := NULL;
        --> Busca as informaçoes do primeiro titular da conta
        OPEN cr_crapttl ( pr_cdcooper => rw_crapass.cdcooper,
                          pr_nrdconta => rw_crapass.nrdconta,
                          pr_idseqttl => 1);
        FETCH cr_crapttl INTO rw_crapttl;
        IF cr_crapttl%FOUND THEN
          vr_vlrenmes := rw_crapttl.vlrenmes;
        END IF;
        CLOSE cr_crapttl;   
      
      END IF;
      
      vr_vledvmto := 0;  
      --> Buscar endevidamento do aval cooperado 
      OPEN cr_crapsdv (pr_cdcooper => rw_crapass.cdcooper,
                       pr_nrdconta => rw_crapass.nrdconta );
      FETCH cr_crapsdv INTO vr_vledvmto;
      CLOSE cr_crapsdv;
        
      rw_crapcem := NULL;
      --> Buscar email do cooperado
      OPEN cr_crapcem (pr_cdcooper => rw_crapass.cdcooper,
                       pr_nrdconta => rw_crapass.nrdconta );
      FETCH cr_crapcem INTO rw_crapcem; 
      CLOSE cr_crapcem;
        
      rw_craptfc := NULL;
      --> Buscar dados de telefones do cooperado
      OPEN cr_craptfc(pr_cdcooper  => rw_crapass.cdcooper,
                      pr_nrdconta  => rw_crapass.nrdconta);
      FETCH cr_craptfc INTO rw_craptfc;
      CLOSE cr_craptfc;
        
      --> Buscar conjuge do cooperado
      OPEN cr_crapcje ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapcje INTO rw_crapcje;
      IF cr_crapcje%FOUND THEN
        --> Validar se o numero da conta do conjuge é maior que zero
        --   busca as informaçoes do nome do primeiro titular da conta de conjuge
        IF rw_crapcje.nrctacje > 0 THEN
          --> Busca as informaçoes do primeiro titular da conta
          OPEN cr_crapttl ( pr_cdcooper => rw_crapcje.cdcooper,
                            pr_nrdconta => rw_crapcje.nrctacje,
                            pr_idseqttl => 1);
          FETCH cr_crapttl INTO rw_crapttl;
          IF cr_crapttl%FOUND THEN
            vr_nmconjug := rw_crapttl.nmextttl;
            vr_nrcpfcjg := rw_crapttl.nrcpfcgc;
          END IF;
          CLOSE cr_crapttl;  
        ELSE
          --> Se o numero da conta nao é maior que zero carrega o nome da crapcje 
          vr_nmconjug := rw_crapcje.nmconjug;
          vr_nrcpfcjg := rw_crapcje.nrcpfcjg;
        END IF;
        
      END IF;
      
      vr_idxavais := pr_tab_dados_avais.count + 1;   
      pr_tab_dados_avais(vr_idxavais).nrctaava := rw_crapass.nrdconta;
      pr_tab_dados_avais(vr_idxavais).nmdavali := rw_crapass.nmprimtl;
      pr_tab_dados_avais(vr_idxavais).nrcpfcgc := rw_crapass.nrcpfcgc;
      pr_tab_dados_avais(vr_idxavais).nrdocava := vr_nrdocava;
      pr_tab_dados_avais(vr_idxavais).tpdocava := NULL;
      pr_tab_dados_avais(vr_idxavais).nmconjug := vr_nmconjug;
      pr_tab_dados_avais(vr_idxavais).nrcpfcjg := vr_nrcpfcjg;
      
      IF vr_cdgraupr = 1 then
        pr_tab_dados_avais(vr_idxavais).nrdoccjg := 'C.P.F. '|| 
                                                    gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_nrcpfstl,
                                                                              pr_inpessoa => 1);
      END IF;
      
      -- Busca a Nacionalidade
      vr_dsnacion := '';
      OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
      FETCH cr_crapnac INTO vr_dsnacion;
      CLOSE cr_crapnac;

      pr_tab_dados_avais(vr_idxavais).tpdoccjg := NULL;
      pr_tab_dados_avais(vr_idxavais).nrfonres := rw_craptfc.nrdddtfc||rw_craptfc.nrtelefo;
      pr_tab_dados_avais(vr_idxavais).dsdemail := rw_crapcem.dsdemail;
      pr_tab_dados_avais(vr_idxavais).dsendere := TRIM(rw_crapenc.dsendere);
      pr_tab_dados_avais(vr_idxavais).dsendcmp := TRIM(rw_crapenc.nmbairro);
      pr_tab_dados_avais(vr_idxavais).nmcidade := TRIM(rw_crapenc.nmcidade);
      pr_tab_dados_avais(vr_idxavais).cdufresd := TRIM(rw_crapenc.cdufende);
      pr_tab_dados_avais(vr_idxavais).nrcepend := rw_crapenc.nrcepend;
      pr_tab_dados_avais(vr_idxavais).dsnacion := vr_dsnacion;
      pr_tab_dados_avais(vr_idxavais).vledvmto := vr_vledvmto;
      pr_tab_dados_avais(vr_idxavais).vlrenmes := vr_vlrenmes;
      pr_tab_dados_avais(vr_idxavais).idavalis := vr_idxavais;
      pr_tab_dados_avais(vr_idxavais).nrendere := rw_crapenc.nrendere;
      pr_tab_dados_avais(vr_idxavais).complend := rw_crapenc.complend;
      pr_tab_dados_avais(vr_idxavais).nrcxapst := rw_crapenc.nrcxapst;
      pr_tab_dados_avais(vr_idxavais).inpessoa := rw_crapass.inpessoa;
    
    -- Se for avalista terceiro  
    ELSIF pr_tpavalis = 2 THEN
    
      --> buscar dados avalistas terceiros
      FOR rw_crapavt IN cr_crapavt LOOP		

        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crapavt.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        vr_idxavais := pr_tab_dados_avais.count + 1;   
        pr_tab_dados_avais(vr_idxavais).nrctaava := 0;
        pr_tab_dados_avais(vr_idxavais).nmdavali := rw_crapavt.nmdavali;
        pr_tab_dados_avais(vr_idxavais).nrcpfcgc := rw_crapavt.nrcpfcgc;
        pr_tab_dados_avais(vr_idxavais).tpdocava := rw_crapavt.tpdocava;
        pr_tab_dados_avais(vr_idxavais).nrdocava := rw_crapavt.nrdocava;
        pr_tab_dados_avais(vr_idxavais).nmconjug := rw_crapavt.nmconjug;
        pr_tab_dados_avais(vr_idxavais).nrcpfcjg := rw_crapavt.nrcpfcjg;
        pr_tab_dados_avais(vr_idxavais).tpdoccjg := rw_crapavt.tpdoccjg;
        pr_tab_dados_avais(vr_idxavais).dsnacion := vr_dsnacion;
        pr_tab_dados_avais(vr_idxavais).cdestcvl := rw_crapavt.cdestcvl;
        
        
        IF nvl(rw_crapavt.nrcpfcjg,0) > 0 THEN
          pr_tab_dados_avais(vr_idxavais).nrdoccjg := 'C.P.F. '|| 
                                                      gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavt.nrcpfcjg,
                                                                                pr_inpessoa => 1);
        ELSE 
           pr_tab_dados_avais(vr_idxavais).nrdoccjg := rw_crapavt.nrdoccjg;
        END IF;  
        
        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crapavt.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        pr_tab_dados_avais(vr_idxavais).dsendere := rw_crapavt.dsendres##1;
        pr_tab_dados_avais(vr_idxavais).dsendcmp := rw_crapavt.dsendres##2;
        pr_tab_dados_avais(vr_idxavais).nrfonres := rw_crapavt.nrfonres;
        pr_tab_dados_avais(vr_idxavais).dsdemail := rw_crapavt.dsdemail;
        pr_tab_dados_avais(vr_idxavais).nmcidade := rw_crapavt.nmcidade;
        pr_tab_dados_avais(vr_idxavais).cdufresd := rw_crapavt.cdufresd;
        pr_tab_dados_avais(vr_idxavais).nrcepend := rw_crapavt.nrcepend;
        pr_tab_dados_avais(vr_idxavais).dsnacion := vr_dsnacion;
        pr_tab_dados_avais(vr_idxavais).vledvmto := rw_crapavt.vledvmto;
        pr_tab_dados_avais(vr_idxavais).vlrenmes := rw_crapavt.vlrenmes;
        pr_tab_dados_avais(vr_idxavais).idavalis := vr_idxavais;
        pr_tab_dados_avais(vr_idxavais).nrendere := rw_crapavt.nrendere;
        pr_tab_dados_avais(vr_idxavais).complend := rw_crapavt.complend;
        pr_tab_dados_avais(vr_idxavais).nrcxapst := rw_crapavt.nrcxapst;
        pr_tab_dados_avais(vr_idxavais).inpessoa := rw_crapavt.inpessoa;
        
      END LOOP;
    END IF;
    
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Nao foi possivel buscar dados do avalista: ' || SQLERRM, chr(13)),chr(10));     
  END pc_busca_dados_avalista;
  
  --> listar avalistas de contratos
  PROCEDURE pc_lista_avalistas ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta do cooperado
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                ,pr_tpctrato IN INTEGER                --> Tipo de contrado
                                ,pr_nrctrato IN crapepr.nrctremp%TYPE  --> Numero do contrato
                                ,pr_nrctaav1 IN crawepr.nrctaav1%TYPE  --> Numero da conta do primeiro avalista
                                ,pr_nrctaav2 IN crawepr.nrctaav2%TYPE  --> Numero da conta do segundo avalista
                                 --------> OUT <--------                                   
                                ,pr_tab_dados_avais   OUT typ_tab_dados_avais   --> retorna dados do avalista
                                ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic          OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_lista_avalistas           Antigo: b1wgen9999.p/lista_avalistas
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para listar avalistas de contratos
    --
    --   Alteração : 08/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->> CURSORES <<--------
    --> Avalistas que possuem conta na cooperativa
    CURSOR cr_craplim_ava (pr_cdcooper crapavt.cdcooper%TYPE,
                           pr_nrdconta crapavt.nrdconta%TYPE,
                           pr_nrctrlim craplim.nrctrlim%TYPE,
                           pr_tpctrato craplim.tpctrlim%TYPE) IS
      SELECT MAX nrdconta
        FROM craplim 
         --> Converter as duas colunas em linha para o for
         UNPIVOT ( MAX FOR conta IN (nrctaav1, nrctaav2) )
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = pr_tpctrato;
         
    --> Avalistas de emprestimo que possuem conta na cooperativa
    CURSOR cr_crawepr_ava (pr_cdcooper crawepr.cdcooper%TYPE,
                           pr_nrdconta crawepr.nrdconta%TYPE,
                           pr_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT MAX nrdconta
        FROM crawepr 
         --> Converter as duas colunas em linha para o for
         UNPIVOT ( MAX FOR conta IN (nrctaav1, nrctaav2) )
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;
    
    --> Validar emprestimo
    CURSOR cr_crawepr (pr_cdcooper crawepr.cdcooper%TYPE,
                       pr_nrdconta crawepr.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE) IS
      SELECT epr.nrctaav1,
             epr.nmdaval1,
             epr.dscpfav1,
             epr.dsendav1##1,
             epr.dsendav1##2,
             epr.nmcjgav1,
             epr.dscfcav1,
             epr.nrctaav2,
             epr.nmdaval2,
             epr.dscpfav2,
             epr.dsendav2##1,
             epr.dsendav2##2,
             epr.nmcjgav2,
             epr.dscfcav2      
        FROM crawepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.nrctremp = pr_nrctremp;           
    rw_crawepr cr_crawepr%ROWTYPE;
    
    --> Buscar dados cartão
    CURSOR cr_crawcrd (pr_cdcooper crawcrd.cdcooper%TYPE,
                       pr_nrdconta crawcrd.nrdconta%TYPE,
                       pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS
      SELECT crd.nrdconta
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE;      
    
    --> Buscar avalistas de contas juridicas para utilizacao de cartao de credito.
    CURSOR cr_craphcj_ava (pr_cdcooper craphcj.cdcooper%TYPE,
                           pr_nrdconta craphcj.nrdconta%TYPE,
                           pr_nrctrhcj craphcj.nrctrhcj%TYPE) IS      
      SELECT MAX nrdconta
        FROM craphcj
         --> Converter as duas colunas em linha para o for
         UNPIVOT ( MAX FOR conta IN (nrctaav1, nrctaav2) )
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrhcj = pr_nrctrhcj;
    
    --> Buscar avalistas do cartão do cooperado
    CURSOR cr_crawcrd_ava (pr_cdcooper crawcrd.cdcooper%TYPE,
                           pr_nrdconta crawcrd.nrdconta%TYPE,
                           pr_nrctrcrd crawcrd.nrctrcrd%TYPE) IS      
      SELECT MAX nrdconta
        FROM crawcrd
         --> Converter as duas colunas em linha para o for
         UNPIVOT ( MAX FOR conta IN (nrctaav1, nrctaav2) )
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    
      
    --------->> VARIAVEIS <<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;  
    
    vr_tpctrato        INTEGER;
    vr_fcraplim        BOOLEAN;
    vr_fcrawepr        BOOLEAN;
    vr_fcraphcj        BOOLEAN;
    vr_idxavais        PLS_INTEGER;
    
    vr_tab_dados_avais typ_tab_dados_avais;
    
    
  
  BEGIN
  
    IF pr_tpctrato IN( 8       --> DSC TIT 
                     , 2       --> DSC CHQ 
                     , 3) THEN --> LIM CRED
        
      CASE pr_tpctrato
        WHEN 8 THEN
          vr_tpctrato := 3;
        WHEN 2 THEN
          vr_tpctrato := 2;
        WHEN 3 THEN
          vr_tpctrato := 1;
        ELSE
          vr_tpctrato := NULL;
      END CASE;       
      
      vr_fcraplim := TRUE;
      
      --> buscar avalistas do contrato
      FOR rw_craplim IN cr_craplim_ava(pr_cdcooper => pr_cdcooper ,
                                       pr_nrdconta => pr_nrdconta ,
                                       pr_nrctrlim => pr_nrctrato ,
                                       pr_tpctrato => vr_tpctrato ) LOOP
        vr_fcraplim := TRUE;
        
        -- Se estiver zerado, pode ir para o proximo
        IF nvl(rw_craplim.nrdconta,0) = 0 THEN
          continue;
        END IF;
        
        --> Buscar dados do avalista
        pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                                ,pr_nrdconta => rw_craplim.nrdconta       --> Numero da conta do cooperado
                                ,pr_tpavalis => 1                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                 --------> OUT <--------                                   
                                ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                                ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                                ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
      
      END LOOP;
      
      IF vr_fcraplim = FALSE THEN
        vr_dscritic := 'Registro de limite nao encontrado.'||
                        pr_cdcooper ||' - '||
                        pr_nrdconta ||' - '||
                        pr_nrctrato ||' - '||
                        pr_tpctrato; 
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar dados do avalista
      pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta               --> Numero da conta do cooperado
                              ,pr_nrctrato => pr_nrctrato               --> Numero do contrato para busca de avalistas terceiros
                              ,pr_tpctrato => pr_tpctrato               --> Tipo do contrato para busca de avalistas terceiros
                              ,pr_tpavalis => 2                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)                              
                               --------> OUT <--------                                   
                              ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                              ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;      
      
    --> EMPRESTIMO     
    ELSIF pr_tpctrato = 1 THEN 
      
      vr_fcrawepr := FALSE;
       
      --> buscar avalistas do emprestimo
      FOR rw_crawepr IN cr_crawepr_ava(pr_cdcooper => pr_cdcooper ,
                                       pr_nrdconta => pr_nrdconta ,
                                       pr_nrctremp => pr_nrctrato ) LOOP
        vr_fcrawepr := TRUE;
        
        -- Se estiver zerado, pode ir para o proximo
        IF nvl(rw_crawepr.nrdconta,0) = 0 THEN
          continue;
        END IF;
        
        --> Buscar dados do avalista
        pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                                ,pr_nrdconta => rw_crawepr.nrdconta       --> Numero da conta do cooperado
                                ,pr_tpavalis => 1                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                 --------> OUT <--------                                   
                                ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                                ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                                ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro; 
        END IF;
      
      END LOOP;
      
      IF vr_fcrawepr = FALSE THEN
        vr_dscritic := 'Registro de emprestimo nao encontrado.'||
                        pr_cdcooper ||' - '||
                        pr_nrdconta ||' - '||
                        pr_nrctrato ||' - '||
                        pr_tpctrato; 
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar dados do avalista
      pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta               --> Numero da conta do cooperado
                              ,pr_nrctrato => pr_nrctrato               --> Numero do contrato para busca de avalistas terceiros
                              ,pr_tpctrato => pr_tpctrato               --> Tipo do contrato para busca de avalistas terceiros
                              ,pr_tpavalis => 2                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)                              
                               --------> OUT <--------                                   
                              ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                              ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;
      
      --> Caso nao encontrou nenhum avalista
      IF vr_tab_dados_avais.count = 0 THEN
        -- Buscar emprestimo
        OPEN cr_crawepr(pr_cdcooper => pr_cdcooper ,
                        pr_nrdconta => pr_nrdconta ,
                        pr_nrctremp => pr_nrctrato );
        FETCH cr_crawepr INTO rw_crawepr;
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr;
          vr_cdcritic := 356;
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crawepr;  
        END IF;
        
        -- Se o avalista nao é cooperado, porém possui dados no emprestimo 
        IF nvl(rw_crawepr.nrctaav1,0) = 0 AND 
           TRIM(rw_crawepr.nmdaval1) IS NOT NULL THEN     
           
          vr_idxavais := vr_tab_dados_avais.count + 1;
          
          vr_tab_dados_avais(vr_idxavais).nrctaava := rw_crawepr.nrctaav1;
          vr_tab_dados_avais(vr_idxavais).nmdavali := rw_crawepr.nmdaval1;
          vr_tab_dados_avais(vr_idxavais).nrdocava := rw_crawepr.dscpfav1;
          vr_tab_dados_avais(vr_idxavais).dsendere := rw_crawepr.dsendav1##1;
          vr_tab_dados_avais(vr_idxavais).dsendcmp := rw_crawepr.dsendav1##2;
          vr_tab_dados_avais(vr_idxavais).nmconjug := rw_crawepr.nmcjgav1;
          vr_tab_dados_avais(vr_idxavais).nrdoccjg := rw_crawepr.dscfcav1;
          vr_tab_dados_avais(vr_idxavais).idavalis := vr_idxavais;
        END IF;
                
        IF nvl(rw_crawepr.nrctaav2,0) = 0 AND 
           TRIM(rw_crawepr.nmdaval2) IS NOT NULL THEN
          vr_idxavais := vr_tab_dados_avais.count + 1;
          
          vr_tab_dados_avais(vr_idxavais).nrctaava := rw_crawepr.nrctaav2;
          vr_tab_dados_avais(vr_idxavais).nmdavali := rw_crawepr.nmdaval2;
          vr_tab_dados_avais(vr_idxavais).nrdocava := rw_crawepr.dscpfav2;
          vr_tab_dados_avais(vr_idxavais).dsendere := rw_crawepr.dsendav2##1;
          vr_tab_dados_avais(vr_idxavais).dsendcmp := rw_crawepr.dsendav2##2;
          vr_tab_dados_avais(vr_idxavais).nmconjug := rw_crawepr.nmcjgav2;
          vr_tab_dados_avais(vr_idxavais).nrdoccjg := rw_crawepr.dscfcav2;
          vr_tab_dados_avais(vr_idxavais).idavalis := vr_idxavais; 
        
        END IF;
      END IF;
      
    --> CARTAO CRED
    ELSIF pr_tpctrato = 4  THEN 
      --> Buscar dados cartão
      OPEN cr_crawcrd (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_nrctrcrd => pr_nrctrato);
      FETCH cr_crawcrd INTO rw_crawcrd;
      -- Se nao encontrar cartão buscar por conta juridica do cartão
      IF cr_crawcrd%NOTFOUND THEN                 
        CLOSE cr_crawcrd;
        vr_fcraphcj := FALSE;
        --> Buscar avalistas de contas juridicas para utilizacao de cartao de credito.
        FOR rw_craphcj IN cr_craphcj_ava (pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrctrhcj => pr_nrctrato) LOOP
          vr_fcraphcj := TRUE;                                  
          --> Buscar dados do avalista
          pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                                  ,pr_nrdconta => rw_craphcj.nrdconta       --> Numero da conta do cooperado
                                  ,pr_tpavalis => 1                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                   --------> OUT <--------                                   
                                  ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                                  ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                                  ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro; 
          END IF;        
        END LOOP; --> FIM LOOP cr_craphcj_ava                                   
        
        --> Se nao encontrou na crawcrd e nem na craphcj, apresenta critica
        IF vr_fcraphcj = FALSE THEN
          vr_dscritic := 'Registro de cartao nao encontrado.'||
                          pr_cdcooper ||' - '||
                          pr_nrdconta ||' - '||
                          pr_nrctrato ||' - '||
                          pr_tpctrato; 
          RAISE vr_exc_erro;
        END IF;
        
      ELSE
        CLOSE cr_crawcrd;
        
        --> Buscar avalistas da proposta de cartão
        FOR rw_crawcrd IN cr_crawcrd_ava (pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => pr_nrdconta,
                                          pr_nrctrcrd => pr_nrctrato) LOOP
                                           
          --> Buscar dados do avalista
          pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                                  ,pr_nrdconta => rw_crawcrd.nrdconta       --> Numero da conta do cooperado
                                  ,pr_tpavalis => 1                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                   --------> OUT <--------                                   
                                  ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                                  ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                                  ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_erro; 
          END IF;        
        END LOOP; --> FIM LOOP cr_crawcrd_ava 
        
      END IF;
      
      --> Buscar dados do avalista
      pc_busca_dados_avalista (pr_cdcooper => pr_cdcooper               --> Código da Cooperativa
                              ,pr_nrdconta => pr_nrdconta               --> Numero da conta do cooperado
                              ,pr_nrctrato => pr_nrctrato               --> Numero do contrato para busca de avalistas terceiros
                              ,pr_tpctrato => pr_tpctrato               --> Tipo do contrato para busca de avalistas terceiros
                              ,pr_tpavalis => 2                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)                              
                               --------> OUT <--------                                   
                              ,pr_tab_dados_avais => vr_tab_dados_avais --> tabela contendo os parametros da cooperativa
                              ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);      --> Descrição da críticaIS
     
      
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Tipo de contrato inexistente. Tipo '|| to_char(pr_nrctrato,'fm000');
      RAISE vr_exc_erro;
    END IF; --> Fim IF pr_tpctrato
    
    pr_tab_dados_avais := vr_tab_dados_avais;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Nao foi possivel listar avalistas: ' || SQLERRM, chr(13)),chr(10));       
  END pc_lista_avalistas;
  
  --> Buscar parametros gerais de desconto de titulo - TAB052
  PROCEDURE pc_busca_parametros_dsctit ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                        ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento 
                                        ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                        ,pr_tpcobran IN INTEGER                --> Tipo de cobrança(1-Sim 0-nao)                                    
                                         --------> OUT <--------                                   
                                        ,pr_tab_dados_dsctit        OUT typ_tab_dados_dsctit        --> tabela contendo os parametros da cooperativa
                                        ,pr_tab_cecred_dsctit OUT typ_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_parametros_dsctit           Antigo: b1wgen0030.p/busca_parametros_dsctit
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 25/03/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar Busca de parametros gerais de desconto de titulo - TAB052
    --
    --   Alteração : 08/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->> CURSORES <<--------  
    --------->> VARIAVEIS <<--------
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro        
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    
    
    vr_cdacesso          craptab.cdacesso%TYPE;
    vr_dstextab          craptab.dstextab%TYPE;
    vr_tab_dstextab      gene0002.typ_split;
    vr_tab_dados_dsctit  typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit typ_tab_cecred_dsctit;
    vr_idxdscti          PLS_INTEGER;
    
    
    
  BEGIN
    IF pr_tpcobran = 1 THEN
      vr_cdacesso := 'LIMDESCTITCR';
    ELSE
      vr_cdacesso := 'LIMDESCTIT';
    END IF;
    
    --> Buscar valores do parametro
    vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                              pr_nmsistem => 'CRED'     , 
                                              pr_tptabela => 'USUARI'   , 
                                              pr_cdempres => 11         , 
                                              pr_cdacesso => vr_cdacesso, 
                                              pr_tpregist => 0);
    
    vr_tab_dstextab := gene0002.fn_quebra_string(pr_string => vr_dstextab, 
                                                 pr_delimit => ';');
    
    
    IF vr_tab_dstextab.count() > 0 THEN
     
      vr_idxdscti := vr_tab_dados_dsctit.count() + 1;
      vr_tab_dados_dsctit(vr_idxdscti).vllimite := vr_tab_dstextab(01);
      vr_tab_dados_dsctit(vr_idxdscti).vlconsul := vr_tab_dstextab(02);
      vr_tab_dados_dsctit(vr_idxdscti).vlmaxsac := vr_tab_dstextab(03);
      vr_tab_dados_dsctit(vr_idxdscti).vlminsac := vr_tab_dstextab(04);
      vr_tab_dados_dsctit(vr_idxdscti).qtremcrt := vr_tab_dstextab(05);
      vr_tab_dados_dsctit(vr_idxdscti).qttitprt := vr_tab_dstextab(06);
      vr_tab_dados_dsctit(vr_idxdscti).qtrenova := vr_tab_dstextab(07);
      vr_tab_dados_dsctit(vr_idxdscti).qtdiavig := vr_tab_dstextab(08);
      vr_tab_dados_dsctit(vr_idxdscti).qtprzmin := vr_tab_dstextab(09);
      vr_tab_dados_dsctit(vr_idxdscti).qtprzmax := vr_tab_dstextab(10);
      vr_tab_dados_dsctit(vr_idxdscti).qtminfil := vr_tab_dstextab(11);
      vr_tab_dados_dsctit(vr_idxdscti).nrmespsq := vr_tab_dstextab(12);
      vr_tab_dados_dsctit(vr_idxdscti).pctitemi := vr_tab_dstextab(13);
      vr_tab_dados_dsctit(vr_idxdscti).pctolera := vr_tab_dstextab(14);
      vr_tab_dados_dsctit(vr_idxdscti).pcdmulta := vr_tab_dstextab(15);
      vr_tab_dados_dsctit(vr_idxdscti).cardbtit := vr_tab_dstextab(31);
      vr_tab_dados_dsctit(vr_idxdscti).pcnaopag := vr_tab_dstextab(33);
      vr_tab_dados_dsctit(vr_idxdscti).qtnaopag := vr_tab_dstextab(34);
      vr_tab_dados_dsctit(vr_idxdscti).qtprotes := vr_tab_dstextab(35);
      
      
      vr_idxdscti := vr_tab_cecred_dsctit.count() + 1;
      
      vr_tab_cecred_dsctit(vr_idxdscti).vllimite := vr_tab_dstextab(16);
      vr_tab_cecred_dsctit(vr_idxdscti).vlconsul := vr_tab_dstextab(17);
      vr_tab_cecred_dsctit(vr_idxdscti).vlmaxsac := vr_tab_dstextab(18);
      vr_tab_cecred_dsctit(vr_idxdscti).vlminsac := vr_tab_dstextab(19);
      vr_tab_cecred_dsctit(vr_idxdscti).qtremcrt := vr_tab_dstextab(20);
      vr_tab_cecred_dsctit(vr_idxdscti).qttitprt := vr_tab_dstextab(21);
      vr_tab_cecred_dsctit(vr_idxdscti).qtrenova := vr_tab_dstextab(22);
      vr_tab_cecred_dsctit(vr_idxdscti).qtdiavig := vr_tab_dstextab(23);
      vr_tab_cecred_dsctit(vr_idxdscti).qtprzmin := vr_tab_dstextab(24);
      vr_tab_cecred_dsctit(vr_idxdscti).qtprzmax := vr_tab_dstextab(25);
      vr_tab_cecred_dsctit(vr_idxdscti).qtminfil := vr_tab_dstextab(26);
      vr_tab_cecred_dsctit(vr_idxdscti).nrmespsq := vr_tab_dstextab(27);
      vr_tab_cecred_dsctit(vr_idxdscti).pctitemi := vr_tab_dstextab(28);
      vr_tab_cecred_dsctit(vr_idxdscti).pctolera := vr_tab_dstextab(29);
      vr_tab_cecred_dsctit(vr_idxdscti).pcdmulta := vr_tab_dstextab(30);
      vr_tab_cecred_dsctit(vr_idxdscti).cardbtit := vr_tab_dstextab(32);
      vr_tab_cecred_dsctit(vr_idxdscti).pcnaopag := vr_tab_dstextab(36);
      vr_tab_cecred_dsctit(vr_idxdscti).qtnaopag := vr_tab_dstextab(37);
      vr_tab_cecred_dsctit(vr_idxdscti).qtprotes := vr_tab_dstextab(38);
    
    ELSE
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de parametros de desconto de titulos nao encontrado.';
      RAISE vr_exc_erro;    
    END IF;
    
    pr_tab_dados_dsctit        := vr_tab_dados_dsctit;
    pr_tab_cecred_dsctit := vr_tab_cecred_dsctit;
  
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Nao foi possivel buscar parametros de desconto de titulos: ' || SQLERRM, chr(13)),chr(10));     
  END pc_busca_parametros_dsctit;  
  
  
  --> Buscar dados de um determinado limite de desconto de titulos
  
  PROCEDURE pc_busca_dados_limite ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                   ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                   ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                   ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                   ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                   ,pr_cddopcao IN VARCHAR2               --> Tipo de busca
                                   ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indicador de tipo de pessoa
                                   --------> OUT <--------                                   
                                   ,pr_tab_dados_limite    OUT typ_tab_dados_limite          --> retorna dos dados
                                   ,pr_tab_dados_dsctit    OUT typ_tab_dados_dsctit          --> tabela contendo os parametros da cooperativa
                                   ,pr_tab_dados_dscchq    OUT DSCT0002.typ_tab_dados_dscchq --> tabela contendo os parametros da cooperativa
                                   ,pr_cdcritic            OUT PLS_INTEGER                   --> Código da crítica
                                   ,pr_dscritic            OUT VARCHAR2) IS                  --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_dados_limite           Antigo: b1wgen0030.p/busca_dados_limite
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 05/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar Busca dados de um determinado limite de desconto de titulos
    --
    --   Alteração : 05/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->> CURSORES <<--------   
    --> Buscar Contrato de limite
    CURSOR cr_craplim IS
      SELECT lim.nrdconta,
             lim.vllimite,
             lim.cddlinha,
             lim.nrctrlim,
             lim.dtrenova,
             lim.dtinivig,
             lim.qtdiavig,
             lim.dtfimvig,
             lim.dsencfin##1,
             lim.dsencfin##2,
             lim.dsencfin##3,
             lim.nrgarope,
             lim.nrinfcad,
             lim.nrliquid,
             lim.nrpatlvr,
             lim.vltotsfn,
             lim.nrctaav1,
             lim.nrctaav2,
             lim.insitlim,
             lim.dtcancel,
             lim.flgdigit,
             lim.nrperger,
             lim.idcobope
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = pr_tpctrlim;
    rw_craplim cr_craplim%ROWTYPE; 
    
    --> Buscar proposta de Contrato de limite
    CURSOR cr_crapprp IS
      SELECT prp.nrdconta,
             prp.dsramati,
             prp.vlmedchq,
             prp.vlfatura,
             prp.vloutras,
             prp.vlsalari,
             prp.vlsalcon,
             prp.dsdebens,
             prp.dsobserv##1
        FROM crapprp prp
       WHERE prp.cdcooper = pr_cdcooper
         AND prp.nrdconta = pr_nrdconta
         AND prp.nrctrato = pr_nrctrlim
         AND prp.tpctrato = pr_tpctrlim;
    rw_crapprp cr_crapprp%ROWTYPE; 
    
    --> Buscar dados de Linhas de Desconto
    CURSOR cr_crapldc (pr_cdcooper crapldc.cdcooper%TYPE,
                       pr_cddlinha crapldc.cddlinha%TYPE )IS
      SELECT ldc.cddlinha,
             ldc.dsdlinha,
             ldc.txjurmor
        FROM crapldc ldc
       WHERE ldc.cdcooper = pr_cdcooper
         AND ldc.cddlinha = pr_cddlinha
         AND ldc.tpdescto = pr_tpctrlim;
    rw_crapldc cr_crapldc%ROWTYPE;
    
    --> Buscar dados financeiros dos cooperados com tipo de pessoa juridica.
    CURSOR cr_crapjfn IS
      SELECT jfn.cdcooper,
             jfn.perfatcl
        FROM crapjfn jfn
       WHERE jfn.cdcooper = pr_cdcooper
         AND jfn.nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
    
    
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dstextab          craptab.dstextab%TYPE;
    vr_cdtipdoc          INTEGER;
    
    vr_tab_dados_dsctit        typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit       typ_tab_cecred_dsctit;
    vr_tab_dados_limite        typ_tab_dados_limite;
    vr_tab_dados_dscchq        DSCT0002.typ_tab_dados_dscchq;
    vr_idxdscti          PLS_INTEGER;
    vr_idxdados          PLS_INTEGER;
    
    
    
  BEGIN
    --> Buscar Contrato de limite
    OPEN cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Registro de limites nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplim;
    END IF;
    
    IF pr_cddopcao = 'X' THEN        
      IF rw_craplim.insitlim <> 2 THEN
      
        vr_cdcritic := 0;
        vr_dscritic := 'O contrato DEVE estar ATIVO.';
        RAISE vr_exc_erro;
      END IF;
    ELSIF pr_cddopcao = 'A'  THEN
      IF rw_craplim.insitlim <> 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'É possivel alterar contratos somente com a situacao EM ESTUDO';
        RAISE vr_exc_erro;       
      END IF;
    ELSIF pr_cddopcao = 'E' THEN
      IF rw_craplim.insitlim <> 1   THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O contrato DEVE estar em ESTUDO.';
        RAISE vr_exc_erro;   
      END IF;
    END IF;
    
     --> Buscar prposta Contrato de limite
    OPEN cr_crapprp;
    FETCH cr_crapprp INTO rw_crapprp;
    IF cr_crapprp%NOTFOUND THEN
      CLOSE cr_crapprp;
      vr_dscritic := 'Regisro de proposta de desconto de titulo nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapprp;
    END IF;
    
    --> Buscar dados de Linhas de Desconto
    OPEN cr_crapldc (pr_cdcooper => pr_cdcooper,
                     pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_dscritic := 'Registro de linha de desconto nao encontrada.';
      RAISE vr_exc_erro;      
    ELSE
      CLOSE cr_crapldc;
    END IF;
    
    --Cheque
    IF pr_tpctrlim = 2 THEN
      --> Buscar parametros gerais de desconto de titulo - TAB052
      DSCC0001.pc_busca_parametros_dscchq (pr_cdcooper => pr_cdcooper   --> Código da Cooperativa                                          
                                          ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                                          ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                                          ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                                          ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                          ,pr_idorigem => pr_idorigem  --> Identificador de Origem 
                                          ,pr_inpessoa => pr_inpessoa  --> Indicador de tipo de pessoa
                                           --------> OUT <--------          
                                          ,pr_tab_dados_dscchq => vr_tab_dados_dscchq  --> tabela contendo os parametros da cooperativa
                                          ,pr_cdcritic         => vr_cdcritic          --> Código da crítica
                                          ,pr_dscritic         => vr_dscritic);        --> Descrição da crítica
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;
      
    --> Titulo
    ELSIF pr_tpctrlim = 3 THEN    
      --> Buscar parametros gerais de desconto de titulo - TAB052
      pc_busca_parametros_dsctit ( pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --> Código da agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa   --> Numero do caixa do operador
                                  ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                  ,pr_dtmvtolt => pr_dtmvtolt   --> data do movimento 
                                  ,pr_idorigem => pr_idorigem   --> Identificador de Origem
                                  ,pr_tpcobran => 0             --> Tipo de cobrança(1-Sim 0-nao)                                    
                                   --------> OUT <--------          
                                  ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit        --> tabela contendo os parametros da cooperativa
                                  ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                  ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                                  ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro; 
      END IF;
    END IF;
    --> Buscar dados financeiros dos cooperados com tipo de pessoa juridica.
    OPEN cr_crapjfn;
    FETCH cr_crapjfn INTO rw_crapjfn; 
    CLOSE cr_crapjfn;
    
    --> Buscar identificador para digitalização
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA' , 
                                               pr_tpregist => ( CASE pr_tpctrlim
                                                                  WHEN 2 THEN 1
                                                                  WHEN 3 THEN 3
                                                                  ELSE 0
                                                                END)); 
    
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Falta registro na Tabela "DIGITALIZA". ';
    END IF; 
    
    vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');
    
    -- buscar index para posibilitar leitura
    vr_idxdscti := vr_tab_dados_dsctit.first();
    
    vr_idxdados := vr_tab_dados_limite.count() + 1; 
    --Cheque
    IF pr_tpctrlim = 2 THEN
      vr_tab_dados_limite(vr_idxdados).pcdmulta := vr_tab_dados_dscchq(vr_tab_dados_dscchq.first).pcdmulta;
    ELSE
      vr_tab_dados_limite(vr_idxdados).pcdmulta := vr_tab_dados_dsctit(vr_idxdscti).pcdmulta;
    END IF;
    vr_tab_dados_limite(vr_idxdados).codlinha := rw_crapldc.cddlinha;
    vr_tab_dados_limite(vr_idxdados).dsdlinha := rw_crapldc.dsdlinha;
    vr_tab_dados_limite(vr_idxdados).txjurmor := rw_crapldc.txjurmor;
    vr_tab_dados_limite(vr_idxdados).dsramati := rw_crapprp.dsramati;
    vr_tab_dados_limite(vr_idxdados).vlmedtit := rw_crapprp.vlmedchq;
    vr_tab_dados_limite(vr_idxdados).vlfatura := rw_crapprp.vlfatura;
    vr_tab_dados_limite(vr_idxdados).vloutras := rw_crapprp.vloutras;
    vr_tab_dados_limite(vr_idxdados).vlsalari := rw_crapprp.vlsalari;
    vr_tab_dados_limite(vr_idxdados).vlsalcon := rw_crapprp.vlsalcon;
    vr_tab_dados_limite(vr_idxdados).dsdbens1 := SUBSTR(rw_crapprp.dsdebens,01,060);
    vr_tab_dados_limite(vr_idxdados).dsdbens2 := SUBSTR(rw_crapprp.dsdebens,61,120);
    vr_tab_dados_limite(vr_idxdados).dsobserv := rw_crapprp.dsobserv##1;
    vr_tab_dados_limite(vr_idxdados).insitlim := rw_craplim.insitlim;
    vr_tab_dados_limite(vr_idxdados).nrctrlim := rw_craplim.nrctrlim;
    vr_tab_dados_limite(vr_idxdados).vllimite := rw_craplim.vllimite;
    vr_tab_dados_limite(vr_idxdados).qtdiavig := rw_craplim.qtdiavig;
    vr_tab_dados_limite(vr_idxdados).cddlinha := rw_craplim.cddlinha;
    vr_tab_dados_limite(vr_idxdados).dtcancel := rw_craplim.dtcancel;
    vr_tab_dados_limite(vr_idxdados).nrctaav1 := rw_craplim.nrctaav1;
    vr_tab_dados_limite(vr_idxdados).nrctaav2 := rw_craplim.nrctaav2;
    vr_tab_dados_limite(vr_idxdados).flgdigit := rw_craplim.flgdigit;
    vr_tab_dados_limite(vr_idxdados).cdtipdoc := vr_cdtipdoc;
    ------------------- Rating -----------------
    vr_tab_dados_limite(vr_idxdados).nrgarope := rw_craplim.nrgarope;
    vr_tab_dados_limite(vr_idxdados).nrinfcad := rw_craplim.nrinfcad;
    vr_tab_dados_limite(vr_idxdados).nrliquid := rw_craplim.nrliquid;
    vr_tab_dados_limite(vr_idxdados).nrpatlvr := rw_craplim.nrpatlvr;
    vr_tab_dados_limite(vr_idxdados).vltotsfn := rw_craplim.vltotsfn;
    vr_tab_dados_limite(vr_idxdados).nrperger := rw_craplim.nrperger;
    --> Faturamento unico cliente - Pessoa Juridica 
    vr_tab_dados_limite(vr_idxdados).perfatcl := rw_crapjfn.perfatcl;
    vr_tab_dados_limite(vr_idxdados).idcobope := rw_craplim.idcobope;
           
    pr_tab_dados_limite  := vr_tab_dados_limite;
    pr_tab_dados_dsctit        := vr_tab_dados_dsctit;
    pr_tab_dados_dscchq  := vr_tab_dados_dscchq;
        
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_dados_limite: ' || SQLERRM, chr(13)),chr(10));   
  
  END pc_busca_dados_limite;
  
  --> Buscar dados de um limite de desconto de titulos COMPLETO - opcao "C"
  PROCEDURE pc_busca_dados_limite_cons (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                       ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                       ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato                                       
                                       ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Indicador de tipo de pessoa
                                       --------> OUT <--------                                   
                                       ,pr_tab_dados_limite     OUT typ_tab_dados_limite          --> retorna dos dados                                       
                                       ,pr_tab_dados_dsctit     OUT typ_tab_dados_dsctit          --> tabela contendo os parametros da cooperativa
                                       ,pr_tab_cecred_dsctit    OUT typ_tab_cecred_dsctit         --> Tabela contendo os parametros da cecred                                
                                       ,pr_tab_dados_dscchq     OUT DSCT0002.typ_tab_dados_dscchq --> tabela contendo os parametros da cooperativa
                                       ,pr_tab_dados_avais      OUT typ_tab_dados_avais           --> retorna dados do avalista
                                       ,pr_cdcritic             OUT PLS_INTEGER                   --> Código da crítica
                                       ,pr_dscritic             OUT VARCHAR2) IS                  --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_dados_limite_cons           Antigo: b1wgen0030.p/busca_dados_limite_consulta
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 25/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados de um limite de desconto de titulos COMPLETO - opcao "C"
    --
    --   Alteração : 25/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxlim          PLS_INTEGER;
    
  BEGIN
  
    ---> Buscar dados de um determinado limite de desconto de titulos
    pc_busca_dados_limite ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                           ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                           ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                           ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                           ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                           ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                           ,pr_tpctrlim => pr_tpctrlim  --> tipo de contrato
                           ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                           ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                           ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
                           ,pr_nrctrlim => pr_nrctrlim  --> Contrato
                           ,pr_cddopcao => 'C'          --> Tipo de busca
                           ,pr_inpessoa => pr_inpessoa  --> Indicador de tipo de pessoa
                           --------> OUT <--------                                   
                           ,pr_tab_dados_limite   => pr_tab_dados_limite --> retorna dos dados
                           ,pr_tab_dados_dsctit   => pr_tab_dados_dsctit --> tabela contendo os parametros da cooperativa                           
                           ,pr_tab_dados_dscchq   => pr_tab_dados_dscchq --> tabela contendo os parametros da cooperativa
                           ,pr_cdcritic => vr_cdcritic          --> Código da crítica
                           ,pr_dscritic => vr_dscritic);        --> Descrição da crítica
                             
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxlim := pr_tab_dados_limite.first;
    
    IF pr_tab_dados_limite.count = 0 THEN
      vr_dscritic := 'Dados de limite nao encontrados.';
      RAISE vr_exc_erro;
    END IF;
    
    
    --> listar avalistas de contratos
    pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                        ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                        ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                        ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                        ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                        ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                        ,pr_idseqttl => pr_idseqttl  --> Sequencial do titular
                        ,pr_tpctrato => (CASE pr_tpctrlim --> Tipo de contrado
                                           WHEN 3 THEN 8
                                           WHEN 2 THEN 2
                                         END)  
                        ,pr_nrctrato => pr_nrctrlim  --> Numero do contrato
                        ,pr_nrctaav1 => pr_tab_dados_limite(vr_idxlim).nrctaav1  --> Numero da conta do primeiro avalista
                        ,pr_nrctaav2 => pr_tab_dados_limite(vr_idxlim).nrctaav2  --> Numero da conta do segundo avalista
                         --------> OUT <--------                                   
                        ,pr_tab_dados_avais   => pr_tab_dados_avais   --> retorna dados do avalista
                        ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                        ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;        
    
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
            
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_dados_limite_cons: ' || SQLERRM, chr(13)),chr(10));   
    
  END pc_busca_dados_limite_cons;
  
  -->  Buscar restricoes de um determinado bordero ou titulo  
  PROCEDURE pc_busca_restricoes ( pr_cdcooper IN crapabt.cdcooper%TYPE  --> Código da Cooperativa
                                 ,pr_nrborder IN crapabt.nrborder%TYPE  --> numero do bordero
                                 ,pr_cdbandoc IN crapabt.cdbandoc%TYPE  --> Codigo do banco
                                 ,pr_nrdctabb IN crapabt.nrdctabb%TYPE  --> Numero da conta no bb
                                 ,pr_nrcnvcob IN crapabt.nrcnvcob%TYPE  --> Número do convenio
                                 ,pr_nrdconta IN crapabt.nrdconta%TYPE  --> Número da Conta cooperado
                                 ,pr_nrdocmto IN crapabt.nrdocmto%TYPE  --> Número ddo documento
                                 --------> OUT <--------                                   
                                 ,pr_tab_tit_bordero_restri IN OUT typ_tab_bordero_restri --> retorna restrições do titulos do bordero
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_restricoes           Antigo: b1wgen0030.p/busca_restricoes
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 26/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar restricoes de um determinado bordero ou titulo  
    --
    --   Alteração : 25/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    --> Buscar restricoes da analise de bordero de titulos
    CURSOR cr_crapabt IS
      SELECT abt.cdcooper
            ,abt.nrborder
            ,abt.nrdocmto
            ,abt.dsrestri
            ,abt.nrseqdig
            ,abt.flaprcoo
            ,abt.dsdetres
        FROM crapabt abt
       WHERE abt.cdcooper = pr_cdcooper
         AND abt.nrborder = pr_nrborder
         AND abt.cdbandoc = pr_cdbandoc
         AND abt.nrdctabb = pr_nrdctabb
         AND abt.nrcnvcob = pr_nrcnvcob
         AND abt.nrdconta = pr_nrdconta
         AND abt.nrdocmto = pr_nrdocmto;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;    
    vr_idxrestr        PLS_INTEGER;
    
  BEGIN
  
    --> Buscar restricoes da analise de bordero de titulos
    FOR rw_crapabt IN cr_crapabt LOOP
      vr_idxrestr := pr_tab_tit_bordero_restri.count + 1;
      pr_tab_tit_bordero_restri(vr_idxrestr).nrborder := rw_crapabt.nrborder;
      pr_tab_tit_bordero_restri(vr_idxrestr).nrdocmto := rw_crapabt.nrdocmto;
      pr_tab_tit_bordero_restri(vr_idxrestr).dsrestri := rw_crapabt.dsrestri;
      pr_tab_tit_bordero_restri(vr_idxrestr).nrseqdig := rw_crapabt.nrseqdig; 
      pr_tab_tit_bordero_restri(vr_idxrestr).flaprcoo := rw_crapabt.flaprcoo;
      pr_tab_tit_bordero_restri(vr_idxrestr).dsdetres := rw_crapabt.dsdetres;
      
           
    END LOOP;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_restricoes: ' || SQLERRM, chr(13)),chr(10));   
  END pc_busca_restricoes;
  
  --> Buscar dados de um determinado bordero
  PROCEDURE pc_busca_dados_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                   ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                   ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                   ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                   --------> OUT <--------                                   
                                   ,pr_tab_dados_border OUT typ_tab_dados_border --> retorna dados do bordero
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_dados_bordero           Antigo: b1wgen0030.p/busca_dados_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 26/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados de um determinado bordero
    --
    --   Alteração : 25/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    --> Buscar bordero de desconto de titulo
    CURSOR cr_crapbdt IS
      SELECT bdt.insitbdt,
             bdt.cddlinha,
             bdt.dtmvtolt,
             bdt.cdagenci,
             bdt.cdbccxlt,
             bdt.nrdolote,
             bdt.cdoperad,
             bdt.dtlibbdt,
             bdt.cdopelib,
             bdt.nrborder,
             bdt.nrctrlim,
             bdt.txmensal,
             bdt.hrtransa,
             bdt.flgdigit,
             bdt.cdopcolb,
             bdt.cdopcoan
        FROM crapbdt bdt
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrborder = pr_nrborder;
    rw_crapbdt  cr_crapbdt%ROWTYPE;
    
    --> Buscar Linhas de Desconto
    CURSOR cr_crapldc (pr_cdcooper crapldc.cdcooper%TYPE ,
                       pr_cddlinha crapldc.cddlinha%TYPE ) IS
      SELECT ldc.cdcooper,
             ldc.txdiaria,
             ldc.txjurmor,
             ldc.dsdlinha
        FROM crapldc ldc
       WHERE ldc.cdcooper = pr_cdcooper
         AND ldc.cddlinha = pr_cddlinha
         AND ldc.tpdescto = 3;
    rw_crapldc cr_crapldc%ROWTYPE;
    
    --> Buscar dados lote
    CURSOR cr_craplot(pr_cdcooper craplot.cdcooper%TYPE,
                      pr_dtmvtolt craplot.dtmvtolt%TYPE,
                      pr_cdagenci craplot.cdagenci%TYPE,
                      pr_cdbccxlt craplot.cdbccxlt%TYPE,
                      pr_nrdolote craplot.nrdolote%TYPE) IS
      SELECT lot.cdcooper,
             lot.qtinfoln,
             lot.vlinfodb,
             lot.vlinfocr,
             lot.qtcompln,
             lot.vlcompdb,
             lot.vlcompcr
        FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper
         AND lot.dtmvtolt = pr_dtmvtolt
         AND lot.cdagenci = pr_cdagenci
         AND lot.cdbccxlt = pr_cdbccxlt
         AND lot.nrdolote = pr_nrdolote;
    rw_craplot cr_craplot%ROWTYPE;
    
    --> buscar operador
    CURSOR cr_crapope (pr_cdcooper crapope.cdcooper%TYPE,
                       pr_cdoperad crapope.cdoperad%TYPE)  IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
                           
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxborde        PLS_INTEGER;
    
    vr_cdtipdoc        INTEGER;
    vr_dstextab        craptab.dstextab%TYPE;
    
    vr_blnfound        BOOLEAN;
    vr_cdopecoo        crapope.cdoperad%TYPE;
    
    
  BEGIN
    --> Buscar bordero de desconto de titulo
    OPEN cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    IF cr_crapbdt%NOTFOUND THEN
      CLOSE cr_crapbdt;
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de Bordero nao encontrado.';
      RAISE vr_exc_erro;      
    ELSE
      CLOSE cr_crapbdt;
    END IF;  
  
    IF pr_cddopcao = 'N' THEN
      IF rw_crapbdt.insitbdt > 2 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao EM ESTUDO ou ANALISADO.';
        RAISE vr_exc_erro; 
      END IF;
    ELSIF pr_cddopcao = 'L' THEN
      IF rw_crapbdt.insitbdt <> 2 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISADO.';
        RAISE vr_exc_erro; 
      END IF;
    ELSIF pr_cddopcao = 'I' THEN
      IF rw_crapbdt.insitbdt = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'O bordero deve estar na situacao ANALISADO ou LIBERADO.';
        RAISE vr_exc_erro; 
      END IF;  
    END IF; 
    
    --> Buscar Linhas de Desconto
    OPEN cr_crapldc (pr_cdcooper => pr_cdcooper,
                     pr_cddlinha => rw_crapbdt.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_cdcritic := 0;
      vr_dscritic := 'Regisro de linha de desconto nao encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapldc;
    END IF;
    
    --> Documentos computados .........................................
    --> Buscar dados lote
    OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                    pr_dtmvtolt => rw_crapbdt.dtmvtolt,
                    pr_cdagenci => rw_crapbdt.cdagenci,
                    pr_cdbccxlt => rw_crapbdt.cdbccxlt,
                    pr_nrdolote => rw_crapbdt.nrdolote);
    FETCH cr_craplot INTO rw_craplot;
    IF cr_craplot%NOTFOUND THEN
      CLOSE cr_craplot;
      vr_cdcritic := 0;
      vr_dscritic := 'Registro de Lote nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplot;
    END IF;
    
    IF pr_cddopcao IN ('L','N') AND
       (rw_craplot.qtinfoln <> rw_craplot.qtcompln   OR
        rw_craplot.vlinfodb <> rw_craplot.vlcompdb   OR
        rw_craplot.vlinfocr <> rw_craplot.vlcompcr)  THEN
      vr_cdcritic := 0;
      vr_dscritic := 'O lote do bordero nao está fechado.';
      RAISE vr_exc_erro;    
    END IF; 
    
    vr_idxborde := pr_tab_dados_border.count + 1;
    
    --> Operadores ...............................................
    --> buscar operador
    OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                    pr_cdoperad => rw_crapbdt.cdoperad);
    FETCH cr_crapope INTO rw_crapope;
    CLOSE cr_crapope;
    
    pr_tab_dados_border(vr_idxborde).dsopedig := rw_crapbdt.cdoperad ||'-'||
                                                 nvl(gene0002.fn_busca_entrada(1,rw_crapope.nmoperad,' '),
                                                     'NAO CADASTRADO');
    IF rw_crapbdt.dtlibbdt IS NOT NULL THEN 
      --> buscar operador Que liberou 
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => rw_crapbdt.cdopelib);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;
      
      pr_tab_dados_border(vr_idxborde).dsopelib := rw_crapbdt.cdopelib ||'-'||
                                                   nvl(gene0002.fn_busca_entrada(1,rw_crapope.nmoperad,' '),
                                                       'NAO CADASTRADO');
    END IF;
    
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA' , 
                                               pr_tpregist => 4 ); 
     
    IF vr_dstextab IS NULL THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Falta registro na Tabela "DIGITALIZA".';
      RAISE vr_exc_erro;     
    END IF;
    
    vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');
    
    
    
    pr_tab_dados_border(vr_idxborde).nrborder := rw_crapbdt.nrborder;
    pr_tab_dados_border(vr_idxborde).nrctrlim := rw_crapbdt.nrctrlim;
    pr_tab_dados_border(vr_idxborde).insitbdt := rw_crapbdt.insitbdt;
    pr_tab_dados_border(vr_idxborde).txmensal := rw_crapbdt.txmensal;
    pr_tab_dados_border(vr_idxborde).dtlibbdt := rw_crapbdt.dtlibbdt;
    pr_tab_dados_border(vr_idxborde).txdiaria := rw_crapldc.txdiaria;
    pr_tab_dados_border(vr_idxborde).txjurmor := rw_crapldc.txjurmor;
    pr_tab_dados_border(vr_idxborde).qttitulo := rw_craplot.qtcompln;
    pr_tab_dados_border(vr_idxborde).vltitulo := rw_craplot.vlcompcr;
    pr_tab_dados_border(vr_idxborde).dspesqui := to_char(rw_crapbdt.dtmvtolt,'DD/MM/RRRR')   ||'-'||
                                                 to_char(rw_crapbdt.cdagenci,'fm000')        ||'-'||
                                                 to_char(rw_crapbdt.cdbccxlt,'fm000')        ||'-'||
                                                 to_char(rw_crapbdt.nrdolote,'fm000000')     ||'-'||
                                                 to_char(to_date(rw_crapbdt.hrtransa,'SSSSS'),'HH:MM:SS');
    pr_tab_dados_border(vr_idxborde).dsdlinha := to_char(rw_crapbdt.cddlinha,'fm000') ||'-'|| rw_crapldc.dsdlinha;
    pr_tab_dados_border(vr_idxborde).flgdigit := rw_crapbdt.flgdigit;
    pr_tab_dados_border(vr_idxborde).cdtipdoc := vr_cdtipdoc;
    
    -- Verifica se tem operador coordenador de liberacao ou analise
    IF TRIM(rw_crapbdt.cdopcolb) IS NOT NULL THEN
      vr_cdopecoo := rw_crapbdt.cdopcolb;
    ELSE
       IF TRIM(rw_crapbdt.cdopcoan) IS NOT NULL THEN
         vr_cdopecoo := rw_crapbdt.cdopcoan;
       END IF;
    END IF;

    IF TRIM(vr_cdopecoo) IS NOT NULL THEN
      OPEN cr_crapope(pr_cdcooper => pr_cdcooper,
                      pr_cdoperad => vr_cdopecoo);
      FETCH cr_crapope INTO rw_crapope;
      vr_blnfound := cr_crapope%FOUND;
      CLOSE cr_crapope;
      -- Se encontrar
      IF vr_blnfound THEN
        pr_tab_dados_border(vr_idxborde).dsopecoo := vr_cdopecoo || ' - '|| rw_crapope.nmoperad;
      END IF;
    END IF;
    

     
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_dados_bordero: ' || SQLERRM, chr(13)),chr(10));   
  END pc_busca_dados_bordero;
    
  --> Rotina para Carregar dados para a impressao da proposta de bordero
  PROCEDURE pc_carrega_proposta_bordero ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                         ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta                                         
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                         ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo movimento
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Identificador do titular
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da terla
                                         ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processp
                                         ,pr_telefone IN VARCHAR2               --> Numero do telefone
                                         ,pr_dsdeben1 IN VARCHAR2               --> 
                                         ,pr_vlsalari IN NUMBER                 --> Valor salario
                                         ,pr_vlsalcon IN NUMBER                 --> Valor salario
                                         ,pr_vloutras IN NUMBER                 --> valor Outros
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Numero do contrato de limite
                                         ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                         ,pr_vllimpro IN NUMBER                 --> Valor de limite
                                         ,pr_dsobserv IN VARCHAR2               --> Descrição de observação
                                         ,pr_vlslddsc IN NUMBER                 --> Valor de saldo desconto
                                         ,pr_qtdscsld IN INTEGER                --> Quantidade de saldo de desconto
                                         ,pr_vlmaxdsc IN NUMBER                 --> Valor maximo de desconto
                                         ,pr_vllimdsc IN NUMBER                 --> Valor limite de desconto
                                         ,pr_vllimchq IN NUMBER                 --> Valor limite de cheque
                                         ,pr_nmempres IN VARCHAR2               --> Nome empresa
                                         ,pr_nmextcop IN crapcop.nmextcop%TYPE  --> Nome extenso da cooperativa
                                         ,pr_dsramati IN VARCHAR2               -->
                                         ,pr_qtdbolet IN VARCHAR2               --> Quantidade de boletos
                                         ,pr_vlmedbol IN NUMBER                 --> Valor media de boleto
                                         ,pr_nrmespsq IN INTEGER                --> Numero de meses para pequisa
                                         ,pr_vlfatura IN NUMBER                 --> Valor da fatura
                                         ,pr_dsmesref IN VARCHAR2               --> Descrição mês de referencia
                                         ,pr_nmrescop IN crapcop.nmrescop%TYPE  --> Nome resumido da cooperativa
                                         ,pr_nmcidade IN crapcop.nmcidade%TYPE  --> Nome da cidade
                                         ,pr_nmoperad IN crapope.nmoperad%TYPE  --> Nome do operador
                                         --------> OUT <--------                                   
                                         ,pr_tab_dados_border OUT typ_tab_dados_border --> retorna dados do bordero
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_carrega_proposta_bordero           Antigo: b1wgen0030.p/carrega_dados_proposta_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 29/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Rotina para Carregar dados para a impressao da proposta de bordero
    --
    --   Alteração : 29/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl
             
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;    
    
    --> Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade,
             age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    --rw_crapage cr_crapage%ROWTYPE;
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    ---------->>> TEMPTABLE <<<---------
    -- TempTables para APLI0001.pc_consulta_poupanca
    vr_tab_conta_bloq  APLI0001.typ_tab_ctablq;
    vr_tab_craplpp     APLI0001.typ_tab_craplpp;
    vr_tab_craplrg     APLI0001.typ_tab_craplpp;
    vr_tab_resgate     APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp   APLI0001.typ_tab_dados_rpp;
    vr_tab_saldo_rdca  APLI0001.typ_tab_saldo_rdca;
    vr_tab_cartoes     CADA0004.typ_tab_cartoes;
    vr_tab_cabec       CADA0004.typ_tab_cabec;
    vr_tab_medias      EXTR0001.typ_tab_medias;
    vr_tab_comp_medias EXTR0001.typ_tab_comp_medias;
    vr_tab_dados_epr   EMPR0001.typ_tab_dados_epr;
    
    vr_idxcmpmd        PLS_INTEGER;
    vr_idxcabec        PLS_INTEGER;
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(1000);        --> Desc. Erro    
    vr_tab_erro        gene0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_percenir        NUMBER;
    vr_rel_dsagenci    VARCHAR2(100);                   
    vr_rel_cdagenci    VARCHAR2(100);
    vr_vlsldtot        NUMBER;
    vr_vlsldrgt        NUMBER;
    vr_vlsdrdpp        NUMBER;
    vr_rel_vlaplica    NUMBER;
    vr_flgativo        INTEGER  := 0;
    vr_flgocorr        INTEGER  := 0;
    vr_nrctrhcj        NUMBER   := 0;
    vr_flgliber        INTEGER  := 0;
    vr_vltotccr        NUMBER   := 0;
    vr_dstipcta        VARCHAR2(100);
    vr_dssitdct        VARCHAR2(100);
    vr_vlsmdtri        NUMBER;
    
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab            craptab.dstextab%TYPE;    
    vr_inusatab            BOOLEAN;
    vr_qtregist            INTEGER;
    
    
  BEGIN
    vr_dscritic := 'Conversao nao concluida.';
    RAISE vr_exc_erro;
    /*
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN 
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;  
  
    --> Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    CLOSE cr_crapage;
    
    vr_rel_dsagenci := to_char(rw_crapass.cdagenci,'fm000')||' - '||
                       nvl(rw_crapage.nmresage,'NAO CADASTRADO');
    vr_rel_cdagenci := rw_crapass.cdagenci;
    
    --> Saldo das aplicacoes    
    vr_vlsldtot := 0;
    
    APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper       => pr_cdcooper --> Codigo Cooperativa
                                       ,pr_cdagenci       => pr_cdagenci --> Codigo Agencia
                                       ,pr_nrdcaixa       => 1           --> Numero do Caixa
                                       ,pr_cdoperad       => 1           --> Codigo do Operador
                                       ,pr_nmdatela       => pr_nmdatela --> Nome da Tela
                                       ,pr_idorigem       => 1           --> Origem
                                       ,pr_nrdconta       => pr_nrdconta --> Número da Conta
                                       ,pr_idseqttl       => 1           --> Sequencia do Titular
                                       ,pr_nraplica       => 0           --> Número da Aplicação
                                       ,pr_cdprogra       => pr_nmdatela --> Codigo do Programa
                                       ,pr_flgerlog       => 0           --> Gerar Log (0-False / 1-True)
                                       ,pr_dtiniper       => NULL        --> Data de Inicio
                                       ,pr_dtfimper       => NULL        --> Data de Termino
                                       ,pr_vlsldapl       => vr_rel_vlaplica   --> Valor do saldo aplicado                             
                                       ,pr_tab_saldo_rdca => vr_tab_saldo_rdca --> Tabela de Saldo do RDCA 
                                       ,pr_des_reto       => vr_des_reto       --> Retorno OK ou NOK
                                       ,pr_tab_erro       => vr_tab_erro);     --> Tabela de Erros
    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      --Se possuir erro na temp-table
      IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';      
      END IF; 
      
      -- Limpar tabela de erros
      vr_tab_erro.DELETE;
      
      RAISE vr_exc_erro;
    END IF; 
    
    --> Buscar saldo das aplicacoes
    APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                      ,pr_cdoperad => '1'           --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela   --> Nome da Tela
                                      ,pr_idorigem => 1             --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                      ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                      ,pr_idseqttl => 1             --> Titular da Conta
                                      ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Data de Movimento
                                      ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
                                      ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                      ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
                                      ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
                                      ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica
																						
    IF nvl(vr_cdcritic,0) <> 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
    
    vr_rel_vlaplica := nvl(vr_vlsldrgt,0) + nvl(vr_rel_vlaplica,0);
    
    -- Foi identificado que as PL TABLES vr_tab_conta_bloq, vr_tab_craplpp, vr_tab_craplrg, vr_tab_resgate
    -- nao sao utilizadas para calcular o valor do saldo de poupanca programada (vr_vlsldppr) que eh o unico 
    -- campo carregado pelo programa
    -- As informacoes da PL TABLE vr_tab_dados_rpp nao sao enviados para o programa
    -- por esse motivo as PL TABLES vr_tab_conta_bloq, vr_tab_craplpp, vr_tab_craplrg, vr_tab_resgate 
    -- e por questao de performace elas nao serao carregadas
    
    --Executar rotina consulta poupanca
    apli0001.pc_consulta_poupanca (pr_cdcooper => pr_cdcooper            --> Cooperativa 
                                  ,pr_cdagenci => pr_cdagenci            --> Codigo da Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa            --> Numero do caixa 
                                  ,pr_cdoperad => pr_cdoperad            --> Codigo do Operador
                                  ,pr_idorigem => pr_idorigem            --> Identificador da Origem
                                  ,pr_nrdconta => pr_nrdconta            --> Nro da conta associado
                                  ,pr_idseqttl => pr_idseqttl            --> Identificador Sequencial
                                  ,pr_nrctrrpp => 0                      --> Contrato Poupanca Programada 
                                  ,pr_dtmvtolt => pr_dtmvtolt            --> Data do movimento atual
                                  ,pr_dtmvtopr => pr_dtmvtopr            --> Data do proximo movimento
                                  ,pr_inproces => pr_inproces            --> Indicador de processo
                                  ,pr_cdprogra => pr_nmdatela            --> Nome do programa chamador
                                  ,pr_flgerlog => FALSE                  --> Flag erro log
                                  ,pr_percenir => vr_percenir            --> % IR para Calculo Poupanca
                                  ,pr_tab_craptab => vr_tab_conta_bloq   --> Tipo de tabela de Conta Bloqueada
                                  ,pr_tab_craplpp => vr_tab_craplpp      --> Tipo de tabela com lancamento poupanca
                                  ,pr_tab_craplrg => vr_tab_craplrg      --> Tipo de tabela com resgates
                                  ,pr_tab_resgate => vr_tab_resgate      --> Tabela com valores dos resgates das contas por aplicacao
                                  ,pr_vlsldrpp    => vr_vlsdrdpp         --> Valor saldo poupanca programada
                                  ,pr_retorno     => vr_des_reto         --> Descricao de erro ou sucesso OK/NOK 
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
    
    vr_rel_vlaplica := nvl(vr_rel_vlaplica,0) + nvl(vr_vlsdrdpp,0);
    
    --> Procedure para listar cartoes do cooperado                    
    CADA0004.pc_lista_cartoes( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                              ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                              ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                              ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                              ,pr_nrdconta => pr_nrdconta --> Numero da conta
                              ,pr_idorigem => pr_idorigem --> Identificado de oriem
                              ,pr_idseqttl => pr_idseqttl --> sequencial do titular
                              ,pr_nmdatela => pr_nmdatela --> Nome da tela
                              ,pr_flgerlog => 'N'         --> identificador se deve gerar log S-Sim e N-Nao
                              ,pr_dtmvtolt => pr_dtmvtolt --> Data da cooperativa
                              ------ OUT ------
                              ,pr_flgativo     => vr_flgativo          --> Retorna situação 1-ativo 2-inativo
                              ,pr_nrctrhcj     => vr_nrctrhcj          --> Retorna numero do contrato
                              ,pr_flgliber     => vr_flgliber          --> Retorna se esta liberado 1-sim 2-nao
                              ,pr_vltotccr     => vr_vltotccr          --> retorna total de limite do cartao 
                              ,pr_tab_cartoes  => vr_tab_cartoes   --> retorna temptable com os dados dos convenios
                              ,pr_des_reto     => vr_des_reto                    --> OK ou NOK
                              ,pr_tab_erro     => vr_tab_erro);
    
    -- Se houve retorno não Ok
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;
    
    CADA0004.pc_obtem_cabecalho_atenda ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                        ,pr_cdagenci => pr_cdagenci --> Codigo de agencia
                                        ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                                        ,pr_cdoperad => pr_cdoperad --> Codigo do operador
                                        ,pr_nrdconta => pr_nrdconta --> Numero da conta
                                        ,pr_nrdctitg => NULL        --> Numero da conta itg
                                        ,pr_dtinicio => pr_dtmvtolt --> Data de incio
                                        ,pr_dtdfinal => pr_dtmvtolt --> data final
                                        ,pr_idorigem => pr_idorigem --> Identificado de oriem
                                        ---------- OUT --------
                                        ,pr_tab_cabec=> vr_tab_cabec --> Retorna dados do cabecalho da tela ATENDA
                                        ,pr_des_reto => vr_des_reto  --> OK ou NOK
                                        ,pr_tab_erro => vr_tab_erro);--> Temptable de erros
    
    IF vr_des_reto = 'NOK' THEN
      -- Retornar a mensagem de erro
      vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;      
    END IF;
    
    --> Rotina para carregar as medias dos cooperados
    EXTR0001.pc_carrega_medias (pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                               ,pr_cdagenci => pr_cdagenci   --> Código da agencia
                               ,pr_nrdcaixa => pr_nrdcaixa   --> Numero do caixa do operador
                               ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                               ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                               ,pr_dtmvtolt => pr_dtmvtolt   --> Data de Movimento
                               ,pr_idorigem => pr_idorigem   --> Identificador de Origem                               
                               ,pr_idseqttl => pr_idseqttl   --> Sequencial do titular
                               ,pr_nmdatela => pr_nmdatela   --> Nome da Tela
                               ,pr_flgerlog => 0             --> Indicador se deve gerar log(0-nao, 1-sim)
                               --------> OUT <--------                                   
                               ,pr_tab_medias      => vr_tab_medias      --> Retornar valores das medias
                               ,pr_tab_comp_medias => vr_tab_comp_medias --> Retorna complemento medias
                               ,pr_cdcritic        => vr_cdcritic        --> Código da crítica
                               ,pr_dscritic        => vr_dscritic);      --> Descrição da crítica
    
    IF nvl(vr_cdcritic,0) <> 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxcabec := vr_tab_cabec.first;    
    IF vr_idxcabec IS NOT NULL THEN
      vr_dstipcta := vr_tab_cabec(vr_idxcabec).dstipcta;
      vr_dssitdct := vr_tab_cabec(vr_idxcabec).dssitdct;
    END IF;
        
    vr_idxcmpmd := vr_tab_comp_medias.first;    
    IF vr_idxcmpmd IS NOT NULL THEN
      vr_vlsmdtri := vr_tab_comp_medias(vr_idxcmpmd).vlsmdtri;
    END IF;  
    
    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);

    -- Leitura do indicador de uso da tabela de taxa de juros
    vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'USUARI'
                                                       ,pr_cdempres => 11
                                                       ,pr_cdacesso => 'PAREMPCTL'
                                                       ,pr_tpregist => 01);


    --Buscar Indicador Uso tabela
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'TAXATABELA'
                                            ,pr_tpregist => 0);
    --Se nao encontrou
    IF vr_dstextab IS NULL THEN
      --Nao usa tabela
      vr_inusatab:= FALSE;
    ELSE
      IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
        --Nao usa tabela
        vr_inusatab:= FALSE;
      ELSE
        --Nao usa tabela
        vr_inusatab:= TRUE;
      END IF;
    END IF;
    
    --> Obter dados de emprestimos do associado 
    empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => pr_cdcooper           --> Cooperativa conectada
                           ,pr_cdagenci       => pr_cdagenci           --> Código da agência
                           ,pr_nrdcaixa       => pr_nrdcaixa           --> Número do caixa
                           ,pr_cdoperad       => pr_cdoperad           --> Código do operador
                           ,pr_nmdatela       => pr_nmdatela           --> Nome datela conectada
                           ,pr_idorigem       => pr_idorigem           --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta           --> Conta do associado
                           ,pr_idseqttl       => pr_idseqttl           --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => rw_crapdat            --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_dtcalcul       => NULL                  --> Data solicitada do calculo
                           ,pr_nrctremp       => 0                     --> Número contrato empréstimo
                           ,pr_cdprogra       => 'b1wgen0030'          --> Programa conectado
                           ,pr_inusatab       => vr_inusatab           --> Indicador de utilização da tabela
                           ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                           ,pr_flgcondc       => FALSE                 --> Mostrar emprestimos liquidados sem prejuizo
                           ,pr_nmprimtl       => rw_crapass.nmprimtl   --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                           ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                           ,pr_nrregist       => 0                     --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN

        vr_dscritic := 'Conta: '||pr_nrdconta||' nao possui emprestimo.: '|| 
                        -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                        vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_dscritic := 'Conta: '||pr_nrdconta||' nao possui emprestimo.';
      END IF;
      RAISE vr_exc_erro;
    END IF;
    */
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
    WHEN OTHERS THEN      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_carrega_proposta_bordero: ' || SQLERRM, chr(13)),chr(10));   
  END pc_carrega_proposta_bordero;
  
  --> Buscar titulos de um determinado bordero a partir da craptdb 
  PROCEDURE pc_busca_titulos_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     --------> OUT <--------                                   
                                     ,pr_tab_tit_bordero        OUT typ_tab_tit_bordero --> retorna titulos do bordero
                                     ,pr_tab_tit_bordero_restri OUT typ_tab_bordero_restri --> retorna restrições do titulos do bordero
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_titulos_bordero           Antigo: b1wgen0030.p/busca_titulos_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 26/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar titulos de um determinado bordero a partir da craptdb 
    --
    --   Alteração : 25/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<---------- 
    
    --> Titulos contidos no  bordero 
    CURSOR cr_craptdb IS
      SELECT tdb.cdcooper,
             cco.flgregis,
             cco.flgutceb,
             tdb.nrdconta,
             tdb.nrinssac,
             tdb.nrdctabb,
             tdb.nrcnvcob,
             tdb.cdbandoc,
             tdb.nrdocmto,
             tdb.dtvencto,
             tdb.dtlibbdt,
             tdb.vltitulo,
             tdb.vlliquid,
             sab.nmdsacad,
             tdb.insittit,
             cob.nrnosnum
        FROM craptdb tdb 
            ,crapcob cob
            ,crapcco cco
            ,crapsab sab
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrborder = pr_nrborder
         AND tdb.nrdconta = pr_nrdconta
            --> Busca dados do boleto de cobranca 
         AND cob.cdcooper = tdb.cdcooper
         AND cob.cdbandoc = tdb.cdbandoc
         AND cob.nrdctabb = tdb.nrdctabb
         AND cob.nrcnvcob = tdb.nrcnvcob
         AND cob.nrdconta = tdb.nrdconta
         AND cob.nrdocmto = tdb.nrdocmto
         --> tipo de convenio 
         AND cco.cdcooper = tdb.cdcooper 
         AND cco.nrconven = tdb.nrcnvcob
         --> Busca os dados do Sacado 
         AND sab.cdcooper(+) = tdb.cdcooper 
         AND sab.nrdconta(+) = tdb.nrdconta 
         AND sab.nrinssac(+) = tdb.nrinssac;
                           
                           
    --> Buscar bordero de desconto de titulo
    CURSOR cr_crapceb (pr_cdcooper  crapceb.cdcooper%TYPE,
                       pr_nrdconta  crapceb.nrdconta%TYPE, 
                       pr_nrcnvcob  crapceb.nrconven%TYPE)IS
      SELECT ceb.nrcnvceb
        FROM crapceb ceb
       WHERE ceb.cdcooper = pr_cdcooper
         AND ceb.nrdconta = pr_nrdconta
         AND ceb.nrconven = pr_nrcnvcob;
    rw_crapceb  cr_crapceb%ROWTYPE;
    
                           
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxtitul        PLS_INTEGER;
    vr_nossonum        VARCHAR2(30);    
    
  BEGIN
  
    --> Titulos contidos no  bordero 
    FOR rw_craptdb IN cr_craptdb LOOP
      IF rw_craptdb.flgregis = 0  THEN  --> FALSE
        IF rw_craptdb.flgutceb = 1 THEN --> 7 digitos
          --> Buscar bordero de desconto de titulo
          OPEN cr_crapceb (pr_cdcooper  => rw_craptdb.cdcooper ,
                           pr_nrdconta  => rw_craptdb.nrdconta , 
                           pr_nrcnvcob  => rw_craptdb.nrcnvcob );
          FETCH cr_crapceb INTO rw_crapceb;
          CLOSE cr_crapceb;
          
          vr_nossonum := to_char(rw_craptdb.nrcnvcob, 'fm0000000')||
                         to_char(rw_crapceb.nrcnvceb, 'fm0000') ||
                         to_char(rw_craptdb.nrdocmto, 'fm000000');
          
          
        ELSE --> 6 digitos 
          vr_nossonum := to_char(rw_craptdb.nrdconta,'fm00000000') ||
                         to_char(rw_craptdb.nrdocmto,'fm000000000' );
        END IF;
      ELSE
        vr_nossonum := rw_craptdb.nrnosnum;
      END IF;
      
      vr_idxtitul := pr_tab_tit_bordero.count + 1;
      pr_tab_tit_bordero(vr_idxtitul).nrdctabb := rw_craptdb.nrdctabb;
      pr_tab_tit_bordero(vr_idxtitul).nrcnvcob := rw_craptdb.nrcnvcob;
      pr_tab_tit_bordero(vr_idxtitul).nrinssac := rw_craptdb.nrinssac;
      pr_tab_tit_bordero(vr_idxtitul).cdbandoc := rw_craptdb.cdbandoc;
      pr_tab_tit_bordero(vr_idxtitul).nrdconta := rw_craptdb.nrdconta;
      pr_tab_tit_bordero(vr_idxtitul).nrdocmto := rw_craptdb.nrdocmto;
      pr_tab_tit_bordero(vr_idxtitul).dtvencto := rw_craptdb.dtvencto;
      pr_tab_tit_bordero(vr_idxtitul).dtlibbdt := rw_craptdb.dtlibbdt;
      pr_tab_tit_bordero(vr_idxtitul).nossonum := vr_nossonum;
      pr_tab_tit_bordero(vr_idxtitul).vltitulo := rw_craptdb.vltitulo;
      pr_tab_tit_bordero(vr_idxtitul).vlliquid := rw_craptdb.vlliquid;
      pr_tab_tit_bordero(vr_idxtitul).nmsacado := rw_craptdb.nmdsacad;
      pr_tab_tit_bordero(vr_idxtitul).insittit := rw_craptdb.insittit;
      pr_tab_tit_bordero(vr_idxtitul).flgregis := rw_craptdb.flgregis;

      -->  Buscar restricoes de um determinado bordero ou titulo  
      pc_busca_restricoes ( pr_cdcooper => pr_cdcooper          --> Código da Cooperativa
                           ,pr_nrborder => pr_nrborder          --> numero do bordero
                           ,pr_cdbandoc => rw_craptdb.cdbandoc  --> Codigo do banco
                           ,pr_nrdctabb => rw_craptdb.nrdctabb  --> Numero da conta no bb
                           ,pr_nrcnvcob => rw_craptdb.nrcnvcob  --> Número do convenio
                           ,pr_nrdconta => rw_craptdb.nrdconta  --> Número da Conta cooperado
                           ,pr_nrdocmto => rw_craptdb.nrdocmto  --> Número ddo documento
                           --------> OUT <--------                                   
                           ,pr_tab_tit_bordero_restri => pr_tab_tit_bordero_restri --> retorna restrições do titulos do bordero
                           ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                           ,pr_dscritic => vr_dscritic);         --> Descrição da crítica
      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro; 
      END IF;   
    
    END LOOP;
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_titulos_bordero: ' || SQLERRM, chr(13)),chr(10));   
  END pc_busca_titulos_bordero;
  
  --> Carrega dados com os titulos do bordero
  PROCEDURE pc_carrega_dados_bordero_tit (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Numero do contrato de limite
                                         ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                         ,pr_nrmespsq IN INTEGER                --> Mes de pesquisa
                                         ,pr_txdiaria IN NUMBER                 --> Taxa diaria
                                         ,pr_txmensal IN NUMBER                 --> Taxa mensa
                                         ,pr_txdanual IN NUMBER                 --> Taxa anual
                                         ,pr_vllimite IN craplim.vllimite%TYPE  --> Valor limite de desconto
                                         ,pr_ddmvtolt IN INTEGER                --> Dia movimento
                                         ,pr_dsmesref IN VARCHAR2               --> Descricao do mes
                                         ,pr_aamvtolt INTEGER                   --> Ano de movimento
                                         ,pr_nmprimtl IN crapass.nmprimtl%TYPE  --> Nome do cooperado
                                         ,pr_nmrescop IN crapcop.nmrescop%TYPE  --> Nome da cooperativa
                                         ,pr_nmcidade IN crapcop.nmcidade%TYPE  --> Nome da cidade
                                         ,pr_nmoperad IN crapope.nmoperad%TYPE  --> Nome do operador                                         
                                         ,pr_dsopecoo IN VARCHAR2               --> Descricao operador coordenador 
                                         --------> OUT <--------                                   
                                         ,pr_tab_dados_tits_bordero OUT typ_tab_dados_itens_bordero --> retorna dados do bordero
                                         ,pr_tab_tit_bordero        OUT typ_tab_tit_bordero        --> retorna titulos do bordero
                                         ,pr_tab_tit_bordero_restri OUT typ_tab_bordero_restri --> retorna restrições do titulos do bordero
                                         ,pr_tab_sacado_nao_pagou   OUT typ_tab_sacado_nao_pagou   --> Retornar dados do sacado que nao pagaram
                                         ,pr_cdcritic OUT PLS_INTEGER                              --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2) IS                             --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_carrega_dados_bordero_tit           Antigo: b1wgen0030.p/carrega_dados_bordero_titulos
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 30/08/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Carrega dados com os titulos do bordero
    --
    --   Alteração : 30/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    -- .........................................................................*/
    
    ---------->>> CURSORES <<<----------
    --> Verifica TODOS os titulos nao pagos por Sacado
    CURSOR cr_craptdb ( pr_cdcooper craptdb.cdcooper%TYPE,
                        pr_nrinssac craptdb.nrinssac%TYPE,
                        pr_dtmvtolt craptdb.dtvencto%TYPE,
                        pr_nrmespsq INTEGER )IS 
      SELECT sum(tdb.vltitulo) vltitsac,
             COUNT(nrinssac) qttitsac
        FROM craptdb tdb
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.insittit = 3
         AND tdb.nrinssac = pr_nrinssac
         AND tdb.dtvencto > pr_dtmvtolt - (pr_nrmespsq * 30);
    rw_craptdb cr_craptdb%ROWTYPE;
    
    ----------->>> TEMPTABLE <<<--------   
    --> Controlar sacado ja verificado
    TYPE typ_tab_nrinssac IS TABLE OF NUMBER
         INDEX BY VARCHAR2(100);
    vr_tab_nrinssac typ_tab_nrinssac;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_idxsac          VARCHAR2(200);
    vr_idxtitbo        PLS_INTEGER;
    
  BEGIN
  
    --> Buscar titulos de um determinado bordero a partir da craptdb 
    pc_busca_titulos_bordero (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                             ,pr_nrborder => pr_nrborder  --> numero do bordero
                             ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                             --------> OUT <--------                                   
                             ,pr_tab_tit_bordero        => pr_tab_tit_bordero       --> retorna titulos do bordero
                             ,pr_tab_tit_bordero_restri => pr_tab_tit_bordero_restri --> retorna restrições do titulos do bordero
                             ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                             ,pr_dscritic => vr_dscritic);--> Descrição da crítica
      
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Ler titulos do bordero
    IF pr_tab_tit_bordero.count > 0 THEN
      FOR vr_idx IN pr_tab_tit_bordero.first..pr_tab_tit_bordero.last LOOP
        -- Se ainda nao validou o sacado
        IF vr_tab_nrinssac.exists(pr_tab_tit_bordero(vr_idx).nrinssac) = FALSE THEN
        
          --> Incluir na temp de controle  
          vr_tab_nrinssac(pr_tab_tit_bordero(vr_idx).nrinssac) := pr_tab_tit_bordero(vr_idx).nrinssac;
          
          --> Verifica TODOS os titulos nao pagos por Sacado 
          OPEN cr_craptdb ( pr_cdcooper => pr_cdcooper,
                            pr_nrinssac => pr_tab_tit_bordero(vr_idx).nrinssac,
                            pr_dtmvtolt => pr_dtmvtolt,
                            pr_nrmespsq => pr_nrmespsq);
          FETCH cr_craptdb INTO rw_craptdb;
          CLOSE cr_craptdb;
          
          -- Se possui quantidade de nao pago
          IF rw_craptdb.qttitsac > 0 THEN
            --Gravar na temptable
            vr_idxsac := pr_tab_tit_bordero(vr_idx).nmsacado || pr_tab_sacado_nao_pagou.count;
            pr_tab_sacado_nao_pagou(vr_idxsac).nmsacado := pr_tab_tit_bordero(vr_idx).nmsacado;
            pr_tab_sacado_nao_pagou(vr_idxsac).qtdtitul := rw_craptdb.qttitsac;
            pr_tab_sacado_nao_pagou(vr_idxsac).vlrtitul := rw_craptdb.vltitsac; 
          END IF;
          
        END IF;  
      
      END LOOP;
    END IF;
    
    vr_idxtitbo := pr_tab_dados_tits_bordero.count + 1;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nrdconta := pr_nrdconta;
    pr_tab_dados_tits_bordero(vr_idxtitbo).cdagenci := pr_cdagenci;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nrctrlim := pr_nrctrlim;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nrborder := pr_nrborder;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nrmespsq := pr_nrmespsq;
    pr_tab_dados_tits_bordero(vr_idxtitbo).txdiaria := pr_txdiaria;
    pr_tab_dados_tits_bordero(vr_idxtitbo).txmensal := pr_txmensal;
    pr_tab_dados_tits_bordero(vr_idxtitbo).txdanual := pr_txdanual;
    pr_tab_dados_tits_bordero(vr_idxtitbo).vllimite := pr_vllimite;
    pr_tab_dados_tits_bordero(vr_idxtitbo).ddmvtolt := pr_ddmvtolt;
    pr_tab_dados_tits_bordero(vr_idxtitbo).dsmesref := pr_dsmesref;
    pr_tab_dados_tits_bordero(vr_idxtitbo).aamvtolt := pr_aamvtolt;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nmprimtl := pr_nmprimtl;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nmrescop := pr_nmrescop;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nmcidade := pr_nmcidade;
    pr_tab_dados_tits_bordero(vr_idxtitbo).nmoperad := pr_nmoperad;  
    pr_tab_dados_tits_bordero(vr_idxtitbo).dsopecoo := pr_dsopecoo;  
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
            
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_titulos_bordero: ' || SQLERRM, chr(13)),chr(10));   
  END pc_carrega_dados_bordero_tit;  
  
  --> Carregar dados para impressao do contrato de limite
  PROCEDURE pc_carrega_dados_ctrlim ( pr_nmcidade   VARCHAR2,
                                      pr_cdufdcop   VARCHAR2,
                                      pr_nrctrlim   INTEGER,
                                      pr_nmextcop   VARCHAR2,
                                      pr_cdagenci   INTEGER,
                                      pr_dslinha1   VARCHAR2,
                                      pr_dslinha2   VARCHAR2,
                                      pr_nmprimtl   VARCHAR2,
                                      pr_nrdconta   INTEGER,
                                      pr_nrcpfcgc   VARCHAR2,
                                      pr_txnrdcid   VARCHAR2,
                                      pr_dsdmoeda   VARCHAR2,
                                      pr_vllimite   NUMBER,
                                      pr_dslimite   VARCHAR2,                                      
                                      pr_dsdlinha   VARCHAR2,
                                      pr_qtdiavig   INTEGER,
                                      pr_txqtdvig   VARCHAR2,
                                      pr_dsjurmor   VARCHAR2,
                                      pr_txdmulta   NUMBER,
                                      pr_txmulext   VARCHAR2,
                                      pr_nmrescop   VARCHAR2,
                                      pr_nrtelsac   VARCHAR2,
                                      pr_nrtelouv   VARCHAR2,
                                      pr_dsendweb   VARCHAR2,
                                      pr_nmdaval1   VARCHAR2,
                                      pr_linaval1   VARCHAR2,
                                      pr_nmdcjav1   VARCHAR2,
                                      pr_dscpfav1   VARCHAR2,
                                      pr_dscfcav1   VARCHAR2,
                                      pr_nrfonav1   VARCHAR2,
                                      pr_nmdaval2   VARCHAR2,
                                      pr_linaval2   VARCHAR2,
                                      pr_nmdcjav2   VARCHAR2,
                                      pr_dscpfav2   VARCHAR2,
                                      pr_dscfcav2   VARCHAR2,
                                      pr_nrfonav2   VARCHAR2,
                                      pr_nmoperad   VARCHAR2,
                                      pr_tpctrlim   INTEGER
                                     --------> OUT <--------                                   
                                     ,pr_tab_contrato_limite OUT typ_tab_contrato_limite --> Retorna dados do contrato de limite
                                     ,pr_cdcritic            OUT PLS_INTEGER             --> Código da crítica
                                     ,pr_dscritic            OUT VARCHAR2) IS            --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_carrega_dados_ctrlim           Antigo: b1wgen0030.p/carrega_dados_contrato_limite
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 26/12/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para Carregar dados para impressao do contrato de limite
    --
    --   Alteração : 26/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    --
    --               26/12/2016 - Adicionados novos campos para impressao do contrato
    --                            de limite de desconto de cheques. Projeto 300 (Lombardi)
    -- .........................................................................*/
    
    ---------->> CURSORES  <<-------- 
    ---------->> VARIAVEIS <<-------- 
    vr_idxctlim PLS_INTEGER;
  BEGIN
    pr_tab_contrato_limite.delete;
    
    vr_idxctlim := pr_tab_contrato_limite.count + 1;
    IF pr_tpctrlim = 2 THEN
      pr_tab_contrato_limite(vr_idxctlim).nmcidade := pr_nmcidade ||' - '||pr_cdufdcop || ', ';
    ELSE
      pr_tab_contrato_limite(vr_idxctlim).nmcidade := pr_nmcidade ||' '||pr_cdufdcop||',';
    END IF;
    pr_tab_contrato_limite(vr_idxctlim).nrctrlim := pr_nrctrlim;
    pr_tab_contrato_limite(vr_idxctlim).nmextcop := pr_nmextcop;
    pr_tab_contrato_limite(vr_idxctlim).cdagenci := to_char(pr_cdagenci,'fm000');
    pr_tab_contrato_limite(vr_idxctlim).dslinha1 := pr_dslinha1;
    pr_tab_contrato_limite(vr_idxctlim).dslinha2 := pr_dslinha2;
    pr_tab_contrato_limite(vr_idxctlim).nmprimtl := pr_nmprimtl;
    pr_tab_contrato_limite(vr_idxctlim).nrdconta := pr_nrdconta;
    pr_tab_contrato_limite(vr_idxctlim).nrcpfcgc := pr_nrcpfcgc;
    pr_tab_contrato_limite(vr_idxctlim).txnrdcid := pr_txnrdcid;
    pr_tab_contrato_limite(vr_idxctlim).dsdmoeda := pr_dsdmoeda;
    pr_tab_contrato_limite(vr_idxctlim).vllimite := pr_vllimite;
    pr_tab_contrato_limite(vr_idxctlim).dslimite := pr_dslimite;
    pr_tab_contrato_limite(vr_idxctlim).dsdlinha := pr_dsdlinha;
    pr_tab_contrato_limite(vr_idxctlim).qtdiavig := pr_qtdiavig;
    pr_tab_contrato_limite(vr_idxctlim).txqtdvig := pr_txqtdvig;
    pr_tab_contrato_limite(vr_idxctlim).dsjurmor := pr_dsjurmor;
    pr_tab_contrato_limite(vr_idxctlim).txdmulta := to_char(pr_txdmulta,'fm990D0000000');
    pr_tab_contrato_limite(vr_idxctlim).txmulext := pr_txmulext;
    pr_tab_contrato_limite(vr_idxctlim).nmrescop := pr_nmrescop;
    pr_tab_contrato_limite(vr_idxctlim).nrtelsac := pr_nrtelsac;
    pr_tab_contrato_limite(vr_idxctlim).nrtelouv := pr_nrtelouv;
    pr_tab_contrato_limite(vr_idxctlim).dsendweb := pr_dsendweb;
    pr_tab_contrato_limite(vr_idxctlim).nmdaval1 := pr_nmdaval1;
    pr_tab_contrato_limite(vr_idxctlim).linaval1 := pr_linaval1;
    pr_tab_contrato_limite(vr_idxctlim).nmdcjav1 := pr_nmdcjav1;
    pr_tab_contrato_limite(vr_idxctlim).dscpfav1 := pr_dscpfav1;
    pr_tab_contrato_limite(vr_idxctlim).dscfcav1 := pr_dscfcav1;
    pr_tab_contrato_limite(vr_idxctlim).nrfonav1 := pr_nrfonav1;
    pr_tab_contrato_limite(vr_idxctlim).nmdaval2 := pr_nmdaval2;
    pr_tab_contrato_limite(vr_idxctlim).linaval2 := pr_linaval2;
    pr_tab_contrato_limite(vr_idxctlim).nmdcjav2 := pr_nmdcjav2;
    pr_tab_contrato_limite(vr_idxctlim).dscpfav2 := pr_dscpfav2;
    pr_tab_contrato_limite(vr_idxctlim).dscfcav2 := pr_dscfcav2;
    pr_tab_contrato_limite(vr_idxctlim).nrfonav2 := pr_nrfonav2;
    pr_tab_contrato_limite(vr_idxctlim).nmoperad := pr_nmoperad;
    
  END pc_carrega_dados_ctrlim;  
  
  --> Buscar dados para montar contratos etc para desconto de titulos
  PROCEDURE pc_busca_dados_imp_descont( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                       ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                       ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                       ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                       ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                       ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                       ,pr_nrborder IN NUMBER                 --> Numero do bordero
                                       ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                       ,pr_limorbor IN INTEGER                --> Indicador do tipo de dado(/* 1 - LIMITE DSCTIT 2 - BORDERO DSCTIT */)                                     
                                       ,pr_nrvrsctr IN NUMBER DEFAULT 0       --> Numero da versao do contrato
                                       --------> OUT <--------         
                                       --> Tabelas nao serao retornadar pois nao foram convetidas parao projeto indexacao(qrcode)                          
                                       --> pr_tab_emprsts             
                                       --> pr_tab_proposta_limite    
                                       --> pr_tab_proposta_bordero     
                                       ,pr_tab_contrato_limite        OUT DSCT0002.typ_tab_contrato_limite
                                       ,pr_tab_dados_avais            OUT DSCT0002.typ_tab_dados_avais
                                       ,pr_tab_dados_nota_pro         OUT DSCT0002.typ_tab_dados_nota_pro                                     
                                       ,pr_tab_dados_itens_bordero    OUT DSCT0002.typ_tab_dados_itens_bordero
                                       ,pr_tab_tit_bordero            OUT DSCT0002.typ_tab_tit_bordero
                                       ,pr_tab_chq_bordero            OUT DSCT0002.typ_tab_chq_bordero
                                       ,pr_tab_bordero_restri         OUT DSCT0002.typ_tab_bordero_restri
                                       ,pr_tab_sacado_nao_pagou       OUT DSCT0002.typ_tab_sacado_nao_pagou
                                       ,pr_cdcritic                   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic                   OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_busca_dados_imp_dsctit           Antigo: b1wgen0030.p/busca_dados_impressao_dsctit
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 19/01/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar busca dados para montar contratos etc para desconto de titulos
    --
    --   Alteração : 05/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
	  --
	  --               24/11/2016 - Ajustes nome do avalista2. (Odirlei-AMcom)
    --
    --               26/12/2016 - Adicionados novos campos para impressao do contrato
    --                            de limite de desconto de cheques. Projeto 300 (Lombardi)
    --
    --               26/05/2017 - Alterado para tipo de impressao 10 - Analise
    --                            PRJ300 - Desconto de cheque (Odirlei-AMcom) 	
    --
    --               25/07/2017 - Alteração no cálculo da taxa de juros diária do borderô de 
    --                            Desconto de Cheques. PRJ300 - Desconto de cheque (Lombardi) 	
    --
    --               19/01/2018 - Inclusao da nova versao de contrato para impressao.
    --                            (Jaison/Lucas SUPERO - PRJ404)
    --
    -- .........................................................................*/
    
    ---------->> CURSORES <<--------   
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
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
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
            ,cop.nrcepend
            ,cop.nrtelsac
            ,cop.nrtelouv
            ,cop.dsendweb
            ,REPLACE(NVL(TRIM(cop.nrtelura),cop.nrtelsac),'-',' ') nrtelura
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE; 
    
    --> buscar operador
    CURSOR cr_crapope IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
    
    --> Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
    
    --> Busca as informaçoes do titular da conta 
    CURSOR cr_crapttl (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE )IS
      SELECT ttl.nrdconta,
             ttl.nmextttl,
             ttl.nrcpfcgc,
             ttl.tpdocttl,
             ttl.nrdocttl,
             ttl.cdempres
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;
    rw_crapttl cr_crapttl%ROWTYPE; 
    
    --> Buscar dados do telefone
    CURSOR cr_craptfc (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE,
                       pr_tptelefo craptfc.tptelefo%TYPE)IS
      SELECT tfc.nrdddtfc,
             tfc.nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl = pr_idseqttl
         AND tfc.tptelefo = pr_tptelefo;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --> Buscar dados pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT jur.cdempres
        FROM crapjur jur
       WHERE jur.cdcooper = pr_cdcooper
         AND jur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --> Dados da Empresa 
    CURSOR cr_crapemp (pr_cdcooper  crapemp.cdcooper%TYPE,
                       pr_cdempres  crapemp.cdempres%TYPE)IS
      SELECT emp.cdcooper,
             emp.nmresemp
        FROM crapemp emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.cdempres = pr_cdempres;
    rw_crapemp cr_crapemp%ROWTYPE;
    
    --> Informacoes da Carteira de Cobranca
    CURSOR cr_crapcob IS
      SELECT SUM(cob.vltitulo)   totbolet,
             COUNT(cob.nrdconta) qtdbolet
        FROM crapcob cob
       WHERE cob.cdcooper = pr_cdcooper
         AND cob.nrdconta = pr_nrdconta
         AND cob.dtelimin IS NULL;
    rw_crapcob cr_crapcob%ROWTYPE;        

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
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
    ----------->>> TEMPTABLE <<<--------
    vr_tab_tot_descontos       DSCT0001.typ_tab_tot_descontos;
    vr_tab_dados_limite        typ_tab_dados_limite; 
    vr_tab_dados_dsctit        typ_tab_dados_dsctit;              
    vr_tab_cecred_dsctit       typ_tab_cecred_dsctit; 
    vr_tab_dados_avais         typ_tab_dados_avais;
    vr_tab_dados_border        typ_tab_dados_border;
    vr_tab_tit_bordero         typ_tab_tit_bordero;
    vr_tab_chq_bordero         DSCT0002.typ_tab_chq_bordero;
    vr_tab_bordero_restri      typ_tab_bordero_restri;
    vr_tab_dados_itens_bordero  typ_tab_dados_itens_bordero;
    vr_tab_sacado_nao_pagou    typ_tab_sacado_nao_pagou;
    vr_tab_contrato_limite     typ_tab_contrato_limite; 
    vr_tab_dados_nota_pro      DSCT0002.typ_tab_dados_nota_pro;
    vr_tab_dados_dscchq        DSCT0002.typ_tab_dados_dscchq;
    
    
    vr_idxdscti                PLS_INTEGER;
    vr_idxtdesc                PLS_INTEGER;
    vr_idxlimit                PLS_INTEGER;
    vr_idxavais                PLS_INTEGER;
    vr_idxborde                PLS_INTEGER;
    
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    
    vr_nmcidage        crapage.nmcidade%TYPE;
    vr_dsemsnot        VARCHAR2(100);
    vr_dsmesref        VARCHAR2(100);
    vr_dscpfcgc        VARCHAR2(100);
    vr_cdempres        crapttl.cdempres%TYPE;
    vr_nmempres        VARCHAR2(100);
    vr_telefone        VARCHAR2(100);
    vr_rel_nrcpfcgc    VARCHAR2(30);
    
    vr_nrdrowid        ROWID;
    
    vr_vlutiliz        NUMBER;
    vr_dstextab        craptab.dstextab%TYPE;
    vr_inusatab        BOOLEAN;
    
    vr_dstpctrl        VARCHAR2(30);
    
    vr_rel_dsdmoeda    VARCHAR2(10) := 'R$';
    vr_rel_txnrdcid    VARCHAR2(500);
    vr_rel_vllimchq    VARCHAR2(500);
    vr_rel_dsdlinha    VARCHAR2(500);
    vr_rel_nmdaval1    VARCHAR2(500);
    vr_rel_linaval1    VARCHAR2(4000);
    vr_rel_dscpfav1    VARCHAR2(500);
    vr_rel_nmdcjav1    VARCHAR2(500);
    vr_rel_dscfcav1    VARCHAR2(500);
    vr_rel_dsendav1    VARCHAR2(500);    
    vr_rel_dsendcm1    VARCHAR2(500);
    vr_rel_nrfonav1    VARCHAR2(500);
    
    vr_rel_nmdaval2    VARCHAR2(500);
    vr_rel_linaval2    VARCHAR2(4000);
    vr_rel_dscpfav2    VARCHAR2(500);
    vr_rel_nmdcjav2    VARCHAR2(500);
    vr_rel_dscfcav2    VARCHAR2(500);
    vr_rel_dsendav2    VARCHAR2(500);
    vr_rel_dsendcm2    VARCHAR2(500);
    vr_rel_nrfonav2    VARCHAR2(500);
    
    vr_rel_dslimite    VARCHAR2(500);
    vr_rel_dslinhax    VARCHAR2(500);
    vr_rel_dslinhax2   VARCHAR2(500);
    vr_rel_txqtdvig    VARCHAR2(500);
    vr_rel_txjurmor    NUMBER;
    vr_rel_dsjurmor    VARCHAR2(500);
    vr_rel_txdmulta    NUMBER;
    vr_rel_txmulext    VARCHAR2(500);
    
    --Limborder = 2
    vr_rel_txdiaria    NUMBER;
    vr_rel_txdanual    NUMBER;
    vr_rel_txmensal    NUMBER;
    vr_rel_nmextcop    VARCHAR2(100);
    vr_rel_vlmedbol    NUMBER;
    vr_rel_dsopecoo    crapope.nmoperad%TYPE;
        
	 -- Variáveis auxiliares
	 vr_stsnrcal BOOLEAN;
	 vr_inpessoa_av INTEGER;
    
  BEGIN
    
    IF pr_tpctrlim NOT IN (2,3) THEN
      vr_dscritic := 'Tipo de contrato de limite invalido.';
      RAISE vr_exc_erro;      
    ELSIF pr_tpctrlim = 2 THEN
      vr_dstpctrl := 'Cheque';
    ELSIF pr_tpctrlim = 3 THEN
      vr_dstpctrl := 'Titulo';
    END IF;
    
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      
      CASE pr_idimpres
        WHEN 1 THEN
          vr_dstransa := 'Carregar dados para impressao completa de limite de desconto de '||vr_dstpctrl||'.';
        WHEN 2 THEN
          vr_dstransa := 'Carregar dados para impressao do contrato de limite de desconto de '||vr_dstpctrl||'.';
        WHEN 3 THEN
          vr_dstransa := 'Carregar dados para impressao da proposta de limite de desconto de '||vr_dstpctrl||'.';
        WHEN 4 THEN
          vr_dstransa := 'Carregar dados para impressao da nota promissoria de limite de desconto de '||vr_dstpctrl||'.';
        WHEN 5 THEN
          vr_dstransa := 'Carregar dados para impressao completa de bordero de desconto de '||vr_dstpctrl||'.';
        WHEN 6 THEN
          vr_dstransa := 'Carregar dados para impressao da proposta de bordero de desconto de '||vr_dstpctrl||'.';
        WHEN 7 THEN
          vr_dstransa := 'Carregar dados para impressao dos '||vr_dstpctrl||' de bordero de desconto de '||vr_dstpctrl||'.';
        WHEN 9 THEN
          vr_dstransa := 'Carregar dados para impressao dos contratos do CET.';
        WHEN 10 THEN
          vr_dstransa := 'Carregar dados para impressao dos '||vr_dstpctrl||' de bordero de desconto de '||vr_dstpctrl||'.';  
        ELSE
          vr_dscritic := 'Tipo de impressao invalida.';
          RAISE vr_exc_erro;
      END CASE;
    END IF;  
    
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      CLOSE BTCH0001.cr_crapdat;
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN 
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;  
    
    --> buscar dados do operador                                              
    OPEN cr_crapope; 
    FETCH cr_crapope INTO rw_crapope;    
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67; -- 'Operador nao cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;
    END IF;
    
    --> Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    IF cr_crapage%FOUND THEN
      vr_nmcidage := rw_crapage.nmcidade;
    ELSE
      vr_nmcidage := rw_crapcop.nmcidade;
    END IF;    
    CLOSE cr_crapage;
    
    vr_dsemsnot := SUBSTR(rw_crapage.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(pr_dtmvtolt);
    vr_dsmesref := gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'MM'));
    vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc, 
                                             pr_inpessoa => rw_crapass.inpessoa);
    
    --> Se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN
      --> Busca as informaçoes do titular da conta
      OPEN cr_crapttl ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%FOUND THEN
        vr_cdempres := rw_crapttl.cdempres;
      END IF;  
      CLOSE cr_crapttl;
      
      --> Buscar dados de telefones do cooperado
      OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => rw_crapass.nrdconta,
                      pr_idseqttl  => pr_idseqttl,
                      pr_tptelefo  => 1);--Residencial
      FETCH cr_craptfc INTO rw_craptfc;
      IF cr_craptfc%FOUND THEN        
        vr_telefone := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;        
      END IF;
      CLOSE cr_craptfc;
      
      
    ELSE
      --> Busca as informaçoes da pessoa juridica
      OPEN cr_crapjur ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_crapass.nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%FOUND THEN
        vr_cdempres := rw_crapjur.cdempres;
      END IF;  
      CLOSE cr_crapjur;
      
      --> Buscar dados de telefones do cooperado
      OPEN cr_craptfc(pr_cdcooper  => pr_cdcooper,
                      pr_nrdconta  => rw_crapass.nrdconta,
                      pr_idseqttl  => pr_idseqttl,
                      pr_tptelefo  => 3); --Comercial
      FETCH cr_craptfc INTO rw_craptfc;
      IF cr_craptfc%FOUND THEN        
        vr_telefone := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;        
      END IF;
      CLOSE cr_craptfc;
   
    END IF;   
    
    vr_rel_nrcpfcgc := gene0002.fn_mask_cpf_cnpj( pr_nrcpfcgc => rw_crapass.nrcpfcgc, 
                                                  pr_inpessoa => rw_crapass.inpessoa);
   
    --> Dados da Empresa 
    OPEN cr_crapemp (pr_cdcooper => pr_cdcooper,
                     pr_cdempres => vr_cdempres);
    FETCH cr_crapemp INTO rw_crapemp;
    IF cr_crapemp%NOTFOUND THEN
      vr_nmempres := to_char(vr_cdempres,'fm00000')||' - NAO CADASTRADA.';
    ELSE
      vr_nmempres := to_char(vr_cdempres,'fm00000')||' - '||rw_crapemp.nmresemp;
    END IF;
    CLOSE cr_crapemp;
    
    
    --> Buscar dados de um determinado limite de desconto de titulos
    pc_busca_dados_limite_cons (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                               ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                               ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                               ,pr_tpctrlim => pr_tpctrlim  --> tipo de contrato
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                               ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
                               ,pr_nrctrlim => pr_nrctrlim  --> Contrato
                               ,pr_inpessoa => rw_crapass.inpessoa  --> Indicador de tipo de pessoa
                               --------> OUT <--------                                   
                               ,pr_tab_dados_limite    => vr_tab_dados_limite --> retorna dos dados
                               ,pr_tab_dados_dsctit    => vr_tab_dados_dsctit              --> tabela contendo os parametros da cooperativa
                               ,pr_tab_cecred_dsctit   => vr_tab_cecred_dsctit       --> Tabela contendo os parametros da cecred                                
                               ,pr_tab_dados_dscchq    => vr_tab_dados_dscchq        --> tabela contendo os parametros da cooperativa
                               ,pr_tab_dados_avais     => vr_tab_dados_avais         --> retorna dados do avalista
                               ,pr_cdcritic            => vr_cdcritic                --> Código da crítica
                               ,pr_dscritic            => vr_dscritic);              --> Descrição da crítica
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxlimit := vr_tab_dados_limite.first;
    
    --> Buscar a soma total de descontos (titulos + cheques)  */
    DSCT0001.pc_busca_total_descontos(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                     ,pr_cdagenci => pr_cdagenci  --> Codigo da agencia
                                     ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa
                                     ,pr_cdoperad => pr_cdoperad  --> codigo do operador
                                     ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                     ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                                     ,pr_idseqttl => pr_idseqttl  --> idseqttl
                                     ,pr_idorigem => pr_idorigem  --> Codigo da origem
                                     ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                     ,pr_flgerlog => 'N'          --> identificador se deve gerar log S-Sim e N-Nao
                                     ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                     ,pr_dscritic => vr_dscritic  --> Descrição da crítica
                                     ,pr_tab_tot_descontos => vr_tab_tot_descontos); --Totais de desconto
                                       
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxtdesc := vr_tab_tot_descontos.first;    
    
    --> Limite de desconto de titulo/Cheque 
    IF pr_limorbor = 1 THEN
      IF pr_tpctrlim = 2 THEN
        vr_idxdscti := vr_tab_dados_dscchq.first;
      ELSIF pr_tpctrlim = 3 THEN
        vr_idxdscti := vr_tab_dados_dsctit.first;
      END IF; 
      
      IF vr_idxdscti IS NULL THEN
        vr_dscritic := 'Registro de limite craptab nao encontrado.';
        RAISE vr_exc_erro;
      END IF;
      
      vr_vlutiliz := 0;
      
      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';
      
      -- Chamar rotina para retorno do saldo em utilização
      GENE0005.pc_saldo_utiliza(pr_cdcooper => pr_cdcooper              --> Código da Cooperativa
                               ,pr_tpdecons => 2 /*b1wgen9999*/         --> Tipo da consulta (Ver observações da rotina)
                               ,pr_cdagenci => pr_cdagenci              --> Código da agência
                               ,pr_nrdcaixa => pr_nrdcaixa              --> Número do caixa
                               ,pr_cdoperad => pr_cdoperad              --> Código do operador
                               ,pr_nrdconta => rw_crapass.nrdconta      --> OU Consulta pela conta
                               ,pr_nrcpfcgc => NULL                     --> OU Consulta pelo Numero do cpf ou cgc do associado
                               ,pr_idseqttl => pr_idseqttl              --> Sequencia de titularidade da conta
                               ,pr_idorigem => pr_idorigem              --> Indicador da origem da chamada
                               ,pr_dsctrliq => NULL                     --> Numero do contrato de liquidacao
                               ,pr_cdprogra => 'DSCT0002'               --> Código do programa chamador
                               ,pr_tab_crapdat => rw_crapdat            --> Tipo de registro de datas
                               ,pr_inusatab => vr_inusatab              --> Indicador de utilização da tabela de juros
                               ,pr_vlutiliz => vr_vlutiliz              --> Valor utilizado do credito
                               ,pr_cdcritic => vr_cdcritic              --> Código de retorno da critica
                               ,pr_dscritic => vr_dscritic);            --> Mensagem de retorno da critica
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      IF LENGTH(TRIM(rw_crapass.tpdocptl)) > 0   THEN
        vr_rel_txnrdcid := rw_crapass.tpdocptl ||': '|| rw_crapass.nrdocptl;
      ELSE 
        vr_rel_txnrdcid := NULL;
      END IF;     
      
      --> Limite de desconto de cheque 
      vr_rel_vllimchq := vr_tab_tot_descontos(vr_idxtdesc).vllimchq;

      --> Linha de Desconto 
      vr_rel_dsdlinha := to_char(vr_tab_dados_limite(vr_idxtdesc).codlinha,'fm000')
                         ||' - '|| vr_tab_dados_limite(vr_idxtdesc).dsdlinha;
      
      --> Localizar dados avalista
      vr_idxavais := vr_tab_dados_avais.first;
      IF vr_idxavais IS NOT NULL THEN
        vr_rel_nmdaval1 := vr_tab_dados_avais(vr_idxavais).nmdavali;
		
				IF pr_tpctrlim = 2 THEN
		        
					-- Se for impressao da versao 2
					IF pr_nrvrsctr = 2 THEN
						vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', nº '|| vr_tab_dados_avais(vr_idxavais).nrendere ||', bairro ' || 
										 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
										 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 GENE0002.fn_mask(vr_tab_dados_avais(vr_idxavais).nrcepend,'99.999-999') || ', na condição de DEVEDOR(ES) SOLIDÁRIO(S)' ||
										 (CASE WHEN vr_tab_dados_avais(vr_idxavais).nrctaava > 0 THEN ', titular da conta corrente nº ' || TRIM(gene0002.fn_mask_conta(vr_tab_dados_avais(vr_idxavais).nrctaava)) ELSE '' END) ||
										 '.';
					ELSE
						vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' || 
										 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
										 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 vr_tab_dados_avais(vr_idxavais).nrcepend;
					END IF;
					
				ELSE
				
					-- Se for impressao da versao 2
					IF pr_nrvrsctr = 2 THEN
				
					   vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).nmdavali || ', ' || 
															  vr_tab_dados_avais(vr_idxavais).dsnacion || ', ' ||
															  vr_tab_dados_avais(vr_idxavais).cdestcvl || ',  inscrito no CPF/CNPJ nº' ||  
															  vr_tab_dados_avais(vr_idxavais).nrcpfcgc || ', com endereço na ' ||
															  vr_tab_dados_avais(vr_idxavais).dsendere || ', nº ' ||
															  vr_tab_dados_avais(vr_idxavais).nrcepend || ', bairro ' ||
															  vr_tab_dados_avais(vr_idxavais).dsendcmp || ', da cidade de ' ||
															  vr_tab_dados_avais(vr_idxavais).nmcidade || '/' ||
															  vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
															  vr_tab_dados_avais(vr_idxavais).nrcepend || ' titular da conta corrente nº '|| 
															  vr_tab_dados_avais(vr_idxavais).nrctaava || '.';
									   
					ELSE
					
					  vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' || 
															 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
															 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
															 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
															 vr_tab_dados_avais(vr_idxavais).nrcepend;
					
					END IF;


				END IF;
        
        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcgc > 0 THEN
					-- Buscar inpessoa
					gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
																		 ,vr_stsnrcal
																		 ,vr_inpessoa_av);
						
					vr_rel_dscpfav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
																											 pr_inpessoa => vr_inpessoa_av);
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdocava IS NULL THEN
          vr_rel_dscpfav1 := vr_tab_dados_avais(vr_idxavais).nrdocava;
        END IF;  
        
        vr_rel_nrfonav1 := vr_tab_dados_avais(vr_idxavais).nrfonres;
        
        --> Conjuge
        vr_rel_nmdcjav1 := vr_tab_dados_avais(vr_idxavais).nmconjug;
        
        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcjg > 0 THEN
					vr_rel_dscfcav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
																											 pr_inpessoa => 1 );
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdoccjg IS NULL THEN
          vr_rel_dscfcav1 := vr_tab_dados_avais(vr_idxavais).nrdoccjg;
        END IF;
        
        vr_rel_dsendav1 := vr_tab_dados_avais(vr_idxavais).dsendere;
        vr_rel_dsendcm1 := vr_tab_dados_avais(vr_idxavais).dsendcmp;
               
      ELSE
        vr_rel_nmdaval1 := NULL;
        vr_rel_linaval1 := NULL;
        vr_rel_dscpfav1 := NULL;
        vr_rel_nmdcjav1 := NULL;
        vr_rel_dscfcav1 := NULL;

      END IF;
      
      --> Localizar dados do proximo avalista
      vr_idxavais := vr_tab_dados_avais.next(vr_idxavais);
      IF vr_idxavais IS NOT NULL THEN
        vr_rel_nmdaval2 := vr_tab_dados_avais(vr_idxavais).nmdavali;
		
				IF pr_tpctrlim = 2 THEN
		        
					-- Se for impressao da versao 2
					IF pr_nrvrsctr = 2 THEN
						vr_rel_linaval2 := vr_tab_dados_avais(vr_idxavais).dsendere || ', nº '|| vr_tab_dados_avais(vr_idxavais).nrendere ||', bairro ' || 
										 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
										 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 GENE0002.fn_mask(vr_tab_dados_avais(vr_idxavais).nrcepend,'99.999-999') || ', na condição de DEVEDOR(ES) SOLIDÁRIO(S)' ||
										 (CASE WHEN vr_tab_dados_avais(vr_idxavais).nrctaava > 0 THEN ', titular da conta corrente nº ' || TRIM(gene0002.fn_mask_conta(vr_tab_dados_avais(vr_idxavais).nrctaava)) ELSE '' END) ||
										 '.';
					ELSE
						vr_rel_linaval2 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' || 
										 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
										 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 vr_tab_dados_avais(vr_idxavais).nrcepend;
					END IF;
					
					
				ElSE
				
					-- Se for impressao da versao 2
					IF pr_nrvrsctr = 2 THEN
					
						vr_rel_linaval2 := vr_tab_dados_avais(vr_idxavais).nmdavali || ', ' || 
										 vr_tab_dados_avais(vr_idxavais).dsnacion || ', ' ||
										 vr_tab_dados_avais(vr_idxavais).cdestcvl || ',  inscrito no CPF/CNPJ nº' ||  
										 vr_tab_dados_avais(vr_idxavais).nrcpfcgc || ', com endereço na ' ||
										 vr_tab_dados_avais(vr_idxavais).dsendere || ', nº ' ||
										 vr_tab_dados_avais(vr_idxavais).nrcepend || ', bairro ' ||
										 vr_tab_dados_avais(vr_idxavais).dsendcmp || ', da cidade de ' ||
										 vr_tab_dados_avais(vr_idxavais).nmcidade || '/' ||
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 vr_tab_dados_avais(vr_idxavais).nrcepend || ' titular da conta corrente nº '|| 
										 vr_tab_dados_avais(vr_idxavais).nrctaava || '.';
					
					ELSE
					
						vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' || 
										 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' || 
										 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' || 
										 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
										 vr_tab_dados_avais(vr_idxavais).nrcepend;
					
					END IF;
				
				
				END IF;
	                           
        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcgc > 0 THEN
					-- Buscar inpessoa
					gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
																		 ,vr_stsnrcal
																		 ,vr_inpessoa_av);
						
					vr_rel_dscpfav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
																											 pr_inpessoa => vr_inpessoa_av);
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdocava IS NULL THEN
          vr_rel_dscpfav2 := vr_tab_dados_avais(vr_idxavais).nrdocava;
        END IF;  
        
        vr_rel_nrfonav2 := vr_tab_dados_avais(vr_idxavais).nrfonres;
        
        --> Conjuge
        vr_rel_nmdcjav2 := vr_tab_dados_avais(vr_idxavais).nmconjug;
        
        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcjg > 0 THEN
            vr_rel_dscfcav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                         pr_inpessoa => 1 );
          
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdoccjg IS NULL THEN
          vr_rel_dscfcav2 := vr_tab_dados_avais(vr_idxavais).nrdoccjg;
        END IF;
        
        vr_rel_dsendav2 := vr_tab_dados_avais(vr_idxavais).dsendere;
        vr_rel_dsendav2 := vr_tab_dados_avais(vr_idxavais).dsendcmp;
               
      ELSE
        vr_rel_nmdaval2 := NULL;
        vr_rel_linaval2 := NULL;
        vr_rel_dscpfav2 := NULL;
        vr_rel_nmdcjav2 := NULL;
        vr_rel_dscfcav2 := NULL;

      END IF;
      
      --> Valor do limite ..........................................
      vr_rel_dslimite := '('|| gene0002.fn_valor_extenso(pr_idtipval => 'M', 
                                                         pr_valor    => vr_tab_dados_limite(vr_idxtdesc).vllimite) ||
                         ')';
      
      IF pr_tpctrlim = 2 THEN
        vr_rel_dslinhax := ', sociedade Cooperativa de crédito, inscrita no CNPJ sob nº '|| 
                              gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj, 
                                                        pr_inpessoa => 2) ||
                           ', estabelecida na '|| rw_crapcop.dsendcop ||', nº. '||
                           rw_crapcop.nrendcop || ', bairro '|| rw_crapcop.nmbairro ||', CEP '||
                           rw_crapcop.nrcepend || ', cidade de '||
                           rw_crapcop.nmcidade ||'-'|| rw_crapcop.cdufdcop ||'.';
         
         vr_rel_dslinhax2 := ', inscrita no CPF/CNPJ nº '||
                               gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc, 
                                                         pr_inpessoa => rw_crapass.inpessoa) ||
                            ' com Sede/Residência na '||rw_crapass.dsendere ||', nº '||
                            ', Bairro '|| rw_crapass.nmbairro ||', cidade de '||
                            rw_crapass.nmcidade ||'/'|| rw_crapass.cdufende ||', CPF '||
                            rw_crapass.nrcepend ||'.';

        -- Se for impressao da versao 2
        IF pr_nrvrsctr = 2 THEN
          vr_rel_dslinhax  := ', sociedade Credora/Cooperativa de crédito, inscrita no CNPJ sob nº '||
                                gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj,
                                                          pr_inpessoa => 2) ||
                              ', estabelecida na '|| rw_crapcop.dsendcop ||', nº. '||
                              TRIM(GENE0002.fn_mask(rw_crapcop.nrendcop,'zzz.zzz.zzz')) || ', bairro '||
                              rw_crapcop.nmbairro ||', CEP '|| gene0002.fn_mask(rw_crapcop.nrcepend,'99.999-999') ||
                              ', cidade de '|| rw_crapcop.nmcidade ||'-'|| rw_crapcop.cdufdcop ||'.';

          -- Verifica se o documento eh um CPF ou CNPJ
          IF rw_crapass.inpessoa = 1 THEN
            -- Busca estado civil e profissao
            OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta); 
            FETCH cr_gnetcvl INTO rw_gnetcvl;
            CLOSE cr_gnetcvl;

            -- Busca a Nacionalidade
            OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
            FETCH cr_crapnac INTO rw_crapnac;
            CLOSE cr_crapnac;

            vr_rel_dslinhax2 := (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN ', nacionalidade ' || LOWER(rw_crapnac.dsnacion) ELSE '' END)
                             || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.dsproftl) ELSE '' END)
                             || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.rsestcvl) ELSE '' END)
                             || ', inscrito(a) no CPF sob nº ' || gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)
                             || ', portador(a) do RG n° ' || rw_crapass.nrdocptl 
                             || ', residente e domiciliado(a) na ' || rw_crapass.dsendere 
                             || ', n° '|| rw_crapass.nrendere || ', bairro ' || rw_crapass.nmbairro
                             || ', da cidade de ' || rw_crapass.nmcidade || '/' || rw_crapass.cdufende
                             || ', CEP '|| gene0002.fn_mask(rw_crapass.nrcepend,'99.999-999') || '.';
          ELSE
            vr_rel_dslinhax2 := ', inscrita no CNPJ sob n° '|| gene0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa)
                             || ' com sede na ' || rw_crapass.dsendere || ', n° ' || rw_crapass.nrendere
                             || ', bairro ' || rw_crapass.nmbairro || ', da cidade de ' || rw_crapass.nmcidade || '/' || rw_crapass.cdufende
                             || ', CEP ' || gene0002.fn_mask(rw_crapass.nrcepend,'99.999-999') || '.';
          END IF;
        END IF;

	    ELSE -- Contrato Limite Titulo
	      -- Se for impressao da versao 2
			  IF pr_nrvrsctr = 2 THEN
				
					vr_rel_dslinhax := ', sociedade Credora/Cooperativa de crédito, inscrita no CNPJ sob nº '||
					                   gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj,
																						           pr_inpessoa => 2) ||
														 ', estabelecida na '|| rw_crapcop.dsendcop ||', nº '||
														 TRIM(GENE0002.fn_mask(rw_crapcop.nrendcop,'zzz.zzz.zzz')) || ', bairro '|| 
														 rw_crapcop.nmbairro ||', CEP '|| gene0002.fn_mask(rw_crapcop.nrcepend,'99.999-999') ||
														 ', cidade de '|| rw_crapcop.nmcidade ||'-'|| rw_crapcop.cdufdcop ||'.';

					-- Verifica se o documento eh um CPF ou CNPJ
					IF rw_crapass.inpessoa = 1 THEN
						-- Busca estado civil e profissao
						OPEN  cr_gnetcvl(pr_cdcooper => pr_cdcooper,
														 pr_nrdconta => pr_nrdconta); 
						FETCH cr_gnetcvl INTO rw_gnetcvl;
						CLOSE cr_gnetcvl;

						-- Busca a Nacionalidade
						OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
						FETCH cr_crapnac INTO rw_crapnac;
						CLOSE cr_crapnac;

						vr_rel_dslinhax2 := (CASE WHEN TRIM(rw_crapnac.dsnacion) IS NOT NULL THEN ', nacionalidade ' || LOWER(rw_crapnac.dsnacion) ELSE '' END)
														 || (CASE WHEN TRIM(rw_gnetcvl.dsproftl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.dsproftl) ELSE '' END)
														 || (CASE WHEN TRIM(rw_gnetcvl.rsestcvl) IS NOT NULL THEN ', ' || LOWER(rw_gnetcvl.rsestcvl) ELSE '' END)
														 || ', inscrito(a) no CPF/CNPJ sob nº '||
														 gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
																				 pr_inpessoa => rw_crapass.inpessoa) ||
													' com Sede/Residência na '||rw_crapass.dsendere ||', nº '|| rw_crapcop.nrendcop ||
													', bairro '|| rw_crapass.nmbairro ||', cidade de '||
													rw_crapass.nmcidade ||'/'|| rw_crapass.cdufende ||', CEP '||
													gene0002.fn_mask(rw_crapass.nrcepend,'99.999-999') ||
													', titular da conta corrente nº ' || gene0002.fn_mask_conta(rw_crapass.nrdconta) || '.';
					ELSE                  

						vr_rel_dslinhax2 := ', inscrito(a) no CPF/CNPJ sob nº '||
												 gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
																		 pr_inpessoa => rw_crapass.inpessoa) ||
											' com Sede/Residência na '||rw_crapass.dsendere ||', nº '|| rw_crapcop.nrendcop ||
											', bairro '|| rw_crapass.nmbairro ||', cidade de '||
											rw_crapass.nmcidade ||'/'|| rw_crapass.cdufende ||', CEP '||
											rw_crapass.nrcepend ||', titular da conta corrente nº ' || rw_crapass.nrdconta || '.';
					END IF;
							
				ELSE
				  vr_rel_dslinhax := 'Inscrita no CNPJ '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapcop.nrdocnpj, 
																						                                 pr_inpessoa => 2) ||
										         ', Inscrição Estadual Isenta, estabelecida na '||
														 rw_crapcop.dsendcop ||', Nr. '||rw_crapcop.nrendcop ||
														 ', Bairro '|| rw_crapcop.nmbairro ||', '||
														 rw_crapcop.nmcidade ||', '|| rw_crapcop.cdufdcop;					
					vr_rel_dslinhax2 := '';
					
				END IF;

      END IF;
    
      --> Quantidade de dias para vigencia....................
      vr_rel_txqtdvig := '('|| gene0002.fn_valor_extenso(pr_idtipval => 'I', 
                                                         pr_valor    => vr_tab_dados_limite(vr_idxtdesc).qtdiavig) ||
                         ') dias.';
      
      
      --> Taxa de juros de mora .............................
      vr_rel_txjurmor := apli0001.fn_round((power(1 + (vr_tab_dados_limite(vr_idxtdesc).txjurmor / 100),12) - 1) * 100,2);
      vr_rel_dsjurmor := to_char(vr_rel_txjurmor,'000D000000')||'% ('|| 
                         gene0002.fn_valor_extenso(pr_idtipval => 'P', 
                                                   pr_valor    => vr_rel_txjurmor) ||
                         ') ao ano; (';
       vr_rel_dsjurmor := vr_rel_dsjurmor || to_char(vr_tab_dados_limite(vr_idxtdesc).txjurmor,'000D000000')||
                                             ' % a.m., capitalizados mensalmente)';       
       
       --> Taxa de multa por extenso ................................
       vr_rel_txdmulta := vr_tab_dados_limite(vr_idxtdesc).pcdmulta;
       
       vr_rel_txmulext := gene0002.fn_valor_extenso(pr_idtipval => 'P', 
                                                    pr_valor    => vr_rel_txdmulta);
       vr_rel_txmulext := '('|| lower(vr_rel_txmulext) ||')';
       
    --> Bordero de desconto de titulo
    ELSIF pr_limorbor = 2 THEN    
      --> Cheque
      IF pr_tpctrlim = 2 THEN
        --> Buscar dados de um determinado bordero
        DSCC0001.pc_busca_dados_bordero ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                         ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                                         ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                                         ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                                         ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                                         ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                                         ,pr_nrborder => pr_nrborder  --> numero do bordero
                                         ,pr_cddopcao => 'M'          --> Cod opcao
                                         --------> OUT <--------                                   
                                         ,pr_tab_dados_border => vr_tab_dados_border --> retorna dados do bordero
                                         ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                         ,pr_dscritic => vr_dscritic);--> Descrição da crítica
                               
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        --> Buscar titulos de um determinado bordero a partir da craptdb 
        DSCC0001.pc_busca_cheques_bordero(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                         ,pr_dtmvtolt => pr_dtmvtolt  --> Data de movimento
                                         ,pr_nrborder => pr_nrborder  --> numero do bordero
                                         ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                                         ,pr_idimpres => pr_idimpres  --> Indicador de impressao
                                         --------> OUT <--------                                   
                                         ,pr_tab_chq_bordero    => vr_tab_chq_bordero    --> retorna titulos do bordero
                                         ,pr_tab_bordero_restri => vr_tab_bordero_restri --> retorna restrições do titulos do bordero
                                         ,pr_cdcritic           => vr_cdcritic           --> Código da crítica
                                         ,pr_dscritic           => vr_dscritic);         --> Descrição da crítica
        
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      --> Titulo
      ELSIF pr_tpctrlim = 3 THEN
        --> Buscar dados de um determinado bordero
        pc_busca_dados_bordero (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                               ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                               ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_nrborder => pr_nrborder  --> numero do bordero
                               ,pr_cddopcao => 'M'          --> Cod opcao
                               --------> OUT <--------                                   
                               ,pr_tab_dados_border => vr_tab_dados_border --> retorna dados do bordero
                               ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                               ,pr_dscritic => vr_dscritic);--> Descrição da crítica
                               
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        --> Buscar titulos de um determinado bordero a partir da craptdb 
        pc_busca_titulos_bordero (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                 ,pr_nrborder => pr_nrborder  --> numero do bordero
                                 ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                                 --------> OUT <--------                                   
                                 ,pr_tab_tit_bordero        => vr_tab_tit_bordero    --> retorna titulos do bordero
                                 ,pr_tab_tit_bordero_restri => vr_tab_bordero_restri --> retorna restrições do titulos do bordero
                                 ,pr_cdcritic => vr_cdcritic  --> Código da crítica
                                 ,pr_dscritic => vr_dscritic);--> Descrição da crítica
        
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      
      vr_idxborde :=  vr_tab_dados_border.first;
            
      ---> Buscar dados de um determinado limite de desconto de titulos
      pc_busca_dados_limite ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                             ,pr_cdagenci => pr_cdagenci  --> Código da agencia
                             ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                             ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                             ,pr_dtmvtolt => pr_dtmvtolt  --> Data do movimento
                             ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                             ,pr_tpctrlim => pr_tpctrlim  --> Tipo de contrrato
                             ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                             ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                             ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
                             ,pr_nrctrlim => vr_tab_dados_border(vr_idxborde).nrctrlim  --> Contrato
                             ,pr_cddopcao => 'M'          --> Tipo de busca
                             ,pr_inpessoa => rw_crapass.inpessoa  --> Indicador de tipo de pessoa
                             --------> OUT <--------                                   
                             ,pr_tab_dados_limite   => vr_tab_dados_limite   --> retorna dos dados
                             ,pr_tab_dados_dsctit   => vr_tab_dados_dsctit         --> tabela contendo os parametros da cooperativa                            
                             ,pr_tab_dados_dscchq   => vr_tab_dados_dscchq   --> tabela contendo os parametros da cooperativa
                             ,pr_cdcritic => vr_cdcritic                     --> Código da crítica
                             ,pr_dscritic => vr_dscritic);                   --> Descrição da crítica
      
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      vr_rel_txdiaria := apli0001.fn_round(((vr_tab_dados_border(vr_idxborde).txmensal / 100) / 30) * 100,7); 
                          
      vr_rel_txdanual := apli0001.fn_round((power(1 + (vr_tab_dados_border(vr_idxborde).txmensal / 100),
                          12) - 1) * 100,6);
      vr_rel_txmensal := vr_tab_dados_border(vr_idxborde).txmensal;
      vr_rel_nmextcop := rw_crapcop.nmextcop;
      vr_rel_dsopecoo := substr(vr_tab_dados_border(vr_idxborde).dsopecoo,1,40);
      
     
      --> Informacoes da Carteira de Cobranca
      OPEN cr_crapcob;
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;
     
      IF rw_crapcob.qtdbolet <> 0 THEN
        --> Valor medio da carteira de cobranca
        vr_rel_vlmedbol := apli0001.fn_round(rw_crapcob.totbolet / rw_crapcob.qtdbolet, 2);
      ELSE
        vr_rel_vlmedbol := 0;      
      END IF;
    END IF;  
    
    --> Buscar dados da agencia
    OPEN cr_crapage (pr_cdcooper => pr_cdcooper ,
                     pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    IF cr_crapage%NOTFOUND THEN
      vr_dscritic := 'Agencia nao encontrada.';
      CLOSE cr_crapage;
      RAISE vr_exc_erro;      
    ELSE
      CLOSE cr_crapage;
    END IF;
    
    -->  Limite - COMPLETA 
    IF pr_idimpres = 1 THEN
      --> Carregar dados para impressao do contrato de limite
      pc_carrega_dados_ctrlim ( pr_nmcidade   => rw_crapage.nmcidade,
                                pr_cdufdcop   => rw_crapcop.cdufdcop,
                                pr_nrctrlim   => vr_tab_dados_limite(vr_idxlimit).nrctrlim,
                                pr_nmextcop   => rw_crapcop.nmextcop,
                                pr_cdagenci   => rw_crapass.cdagenci,
                                pr_dslinha1   => vr_rel_dslinhax,                                
                                pr_dslinha2   => vr_rel_dslinhax2,
                                pr_nmprimtl   => rw_crapass.nmprimtl,
                                pr_nrdconta   => rw_crapass.nrdconta,
                                pr_nrcpfcgc   => vr_rel_nrcpfcgc,
                                pr_txnrdcid   => vr_rel_txnrdcid,
                                pr_dsdmoeda   => vr_rel_dsdmoeda,
                                pr_vllimite   => vr_tab_dados_limite(vr_idxlimit).vllimite,
                                pr_dslimite   => vr_rel_dslimite,
                                pr_dsdlinha   => vr_rel_dsdlinha,
                                pr_qtdiavig   => vr_tab_dados_limite(vr_idxlimit).qtdiavig,
                                pr_txqtdvig   => vr_rel_txqtdvig,
                                pr_dsjurmor   => vr_rel_dsjurmor,
                                pr_txdmulta   => vr_rel_txdmulta,
                                pr_txmulext   => vr_rel_txmulext,
                                pr_nmrescop   => rw_crapcop.nmrescop,
                                pr_nrtelsac   => (CASE WHEN pr_nrvrsctr = 2 THEN rw_crapcop.nrtelura ELSE rw_crapcop.nrtelsac END),
                                pr_nrtelouv   => rw_crapcop.nrtelouv,
                                pr_dsendweb   => rw_crapcop.dsendweb,
                                pr_nmdaval1   => vr_rel_nmdaval1,
                                pr_linaval1   => vr_rel_linaval1,
                                pr_nmdcjav1   => vr_rel_nmdcjav1,
                                pr_dscpfav1   => vr_rel_dscpfav1,
                                pr_dscfcav1   => vr_rel_dscfcav1,
                                pr_nrfonav1   => vr_rel_nrfonav1,
                                pr_nmdaval2   => vr_rel_nmdaval2,
                                pr_linaval2   => vr_rel_linaval2,
                                pr_nmdcjav2   => vr_rel_nmdcjav2,
                                pr_dscpfav2   => vr_rel_dscpfav2,
                                pr_dscfcav2   => vr_rel_dscfcav2,
                                pr_nrfonav2   => vr_rel_nrfonav2,
                                pr_nmoperad   => rw_crapope.nmoperad,
                                pr_tpctrlim   => pr_tpctrlim
                               --------> OUT <--------                                   
                               ,pr_tab_contrato_limite => vr_tab_contrato_limite --> Retorna dados do contrato de limite
                               ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                               ,pr_dscritic => vr_dscritic);       --> Descrição da crítica
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --> Carregar dados para efetuar a impressao da nota promissoria
      DSCC0001.pc_dados_nota_promissoria (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                         ,pr_cdagenci => rw_crapass.cdagenci  --> Código da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                                         ,pr_nrdconta => pr_nrdconta  --> Código do Operador
                                         ,pr_inpessoa => rw_crapass.inpessoa  --> Tipo de pessoa
                                         ,pr_nrcpfcgc => rw_crapass.nrcpfcgc                                    --> Numero CPF/CNPJ
                                         ,pr_nrctrlim => pr_nrctrlim                                       --> Numero do contrato
                                         ,pr_vllimite => vr_tab_dados_limite(vr_idxlimit).vllimite  --> Valor do limite
                                         ,pr_dtmvtolt => pr_dtmvtolt                                       --> Data do movimento
                                         ,pr_dsemsnot => vr_dsemsnot                                               --> Descricao nota
                                         ,pr_dsmesref => vr_dsmesref                                       --> Mes de referencia
                                         ,pr_nmrescop => rw_crapcop.nmrescop                               --> Nome resumido da cooperativa
                                         ,pr_nmextcop => rw_crapcop.nmextcop                               --> Nome extenso da cooperativa
                                         ,pr_nrdocnpj => rw_crapcop.nrdocnpj                               --> Numero do CNPJ
                                         ,pr_dsdmoeda => vr_rel_dsdmoeda                                   --> Descricao da moeda
                                         ,pr_nmprimtl => rw_crapass.nmprimtl                                --> Nome do cooperado
                                          --------> OUT <--------
                                         ,pr_tab_dados_nota_pro  => vr_tab_dados_nota_pro  --> Tabela contendo dados nota promissoria
                                         ,pr_cdcritic            => vr_cdcritic            --> Codigo da critica
                                         ,pr_dscritic            => vr_dscritic);          --> Descricao da critica
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Impressao CONTRATO LIMITE
    ELSIF pr_idimpres = 2  THEN 
      --> Carregar dados para impressao do contrato de limite
      pc_carrega_dados_ctrlim ( pr_nmcidade   => rw_crapage.nmcidade,
                                pr_cdufdcop   => rw_crapcop.cdufdcop,
                                pr_nrctrlim   => vr_tab_dados_limite(vr_idxlimit).nrctrlim,
                                pr_nmextcop   => rw_crapcop.nmextcop,
                                pr_cdagenci   => rw_crapass.cdagenci,
                                pr_dslinha1   => vr_rel_dslinhax,
                                pr_dslinha2   => vr_rel_dslinhax2, 
                                pr_nmprimtl   => rw_crapass.nmprimtl,
                                pr_nrdconta   => rw_crapass.nrdconta,
                                pr_nrcpfcgc   => vr_rel_nrcpfcgc,
                                pr_txnrdcid   => vr_rel_txnrdcid,
                                pr_dsdmoeda   => vr_rel_dsdmoeda,
                                pr_vllimite   => vr_tab_dados_limite(vr_idxlimit).vllimite,
                                pr_dslimite   => vr_rel_dslimite,
                                pr_dsdlinha   => vr_rel_dsdlinha,
                                pr_qtdiavig   => vr_tab_dados_limite(vr_idxlimit).qtdiavig,
                                pr_txqtdvig   => vr_rel_txqtdvig,
                                pr_dsjurmor   => vr_rel_dsjurmor,
                                pr_txdmulta   => vr_rel_txdmulta,
                                pr_txmulext   => vr_rel_txmulext,
                                pr_nmrescop   => rw_crapcop.nmrescop,
                                pr_nrtelsac   => (CASE WHEN pr_nrvrsctr = 2 THEN rw_crapcop.nrtelura ELSE rw_crapcop.nrtelsac END),
                                pr_nrtelouv   => rw_crapcop.nrtelouv,
                                pr_dsendweb   => rw_crapcop.dsendweb,
                                pr_nmdaval1   => vr_rel_nmdaval1,
                                pr_linaval1   => vr_rel_linaval1,
                                pr_nmdcjav1   => vr_rel_nmdcjav1,
                                pr_dscpfav1   => vr_rel_dscpfav1,
                                pr_dscfcav1   => vr_rel_dscfcav1,
                                pr_nrfonav1   => vr_rel_nrfonav1,
                                pr_nmdaval2   => vr_rel_nmdaval2,
                                pr_linaval2   => vr_rel_linaval2,
                                pr_nmdcjav2   => vr_rel_nmdcjav2,
                                pr_dscpfav2   => vr_rel_dscpfav2,
                                pr_dscfcav2   => vr_rel_dscfcav2,
                                pr_nrfonav2   => vr_rel_nrfonav2,
                                pr_nmoperad   => rw_crapope.nmoperad,
                                pr_tpctrlim   => pr_tpctrlim
                               --------> OUT <--------                                   
                               ,pr_tab_contrato_limite => vr_tab_contrato_limite --> Retorna dados do contrato de limite
                               ,pr_cdcritic => vr_cdcritic         --> Código da crítica
                               ,pr_dscritic => vr_dscritic);       --> Descrição da crítica
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
    --> Impressao PROPOSTA 
    ELSIF pr_idimpres = 3  THEN 
      --> Trecho nao convertido, pois nao será necessario para o projeto QRcode
      vr_dscritic := 'Tipo invalido - Rotina nao convertida oracle';
      RAISE vr_exc_erro; 
         
    ELSIF pr_idimpres = 4 THEN
      --> Carregar dados para efetuar a impressao da nota promissoria
      DSCC0001.pc_dados_nota_promissoria (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                         ,pr_cdagenci => rw_crapass.cdagenci  --> Código da agencia
                                         ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                                         ,pr_nrdconta => pr_nrdconta  --> Código do Operador
                                         ,pr_inpessoa => rw_crapass.inpessoa  --> Tipo de pessoa
                                         ,pr_nrcpfcgc => rw_crapass.nrcpfcgc                                    --> Numero CPF/CNPJ
                                         ,pr_nrctrlim => pr_nrctrlim                                       --> Numero do contrato
                                         ,pr_vllimite => vr_tab_dados_limite(vr_idxlimit).vllimite  --> Valor do limite
                                         ,pr_dtmvtolt => pr_dtmvtolt                                       --> Data do movimento
                                         ,pr_dsemsnot => vr_dsemsnot                                               --> Descricao nota
                                         ,pr_dsmesref => vr_dsmesref                                       --> Mes de referencia
                                         ,pr_nmrescop => rw_crapcop.nmrescop                               --> Nome resumido da cooperativa
                                         ,pr_nmextcop => rw_crapcop.nmextcop                               --> Nome extenso da cooperativa
                                         ,pr_nrdocnpj => rw_crapcop.nrdocnpj                               --> Numero do CNPJ
                                         ,pr_dsdmoeda => vr_rel_dsdmoeda                                   --> Descricao da moeda
                                         ,pr_nmprimtl => rw_crapass.nmprimtl                                --> Nome do cooperado
                                          --------> OUT <--------
                                         ,pr_tab_dados_nota_pro  => vr_tab_dados_nota_pro  --> Tabela contendo dados nota promissoria
                                         ,pr_cdcritic            => vr_cdcritic            --> Codigo da critica
                                         ,pr_dscritic            => vr_dscritic);          --> Descricao da critica
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
    --> Impressao Bordero Completa    
    ELSIF pr_idimpres = 5 THEN 
      --> Trecho nao convertido, pois nao será necessario para o projeto QRcode
      vr_dscritic := 'Tipo invalido - Rotina nao convertida oracle';
      RAISE vr_exc_erro;  
      
    --> Impressao Proposta de bordero
    ELSIF pr_idimpres = 6 THEN 
      --> Trecho nao convertido, pois nao será necessario para o projeto QRcode
      vr_dscritic := 'Tipo invalido - Rotina nao convertida oracle';
      RAISE vr_exc_erro; 
      
    -->  7 - Impressao dos titulos do bordero
    --> 10 - Impressao dos cheques para analise
    ELSIF pr_idimpres IN (7,10) THEN 
      
      --> Bordero Cheque
      IF pr_tpctrlim = 2 THEN
        --> Carrega dados com os cheques do bordero
        DSCC0001.pc_carrega_dados_bordero_chq 
                                (pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                ,pr_cdagenci => rw_crapass.cdagenci   --> Código da agencia
                                ,pr_nrdconta => pr_nrdconta           --> Número da Conta
                                ,pr_dtmvtolt => pr_dtmvtolt           --> Data do movimento
                                ,pr_nrctrlim => pr_nrctrlim           --> Numero do contrato de limite
                                ,pr_nrborder => pr_nrborder           --> Numero do bordero
                                ,pr_txdiaria => vr_rel_txdiaria       --> Taxa diaria
                                ,pr_txmensal => vr_rel_txmensal       --> Taxa mensa
                                ,pr_txdanual => vr_rel_txdanual       --> Taxa anual
                                ,pr_vllimite => vr_tab_dados_limite(vr_idxlimit).vllimite  --> Valor limite de desconto
                                ,pr_ddmvtolt => to_char(pr_dtmvtolt,'DD')--> Dia movimento
                                ,pr_dsmesref => vr_dsmesref           --> Descricao do mes
                                ,pr_aamvtolt => to_char(pr_dtmvtolt,'RRRR')--> Ano de movimento
                                ,pr_nmprimtl => rw_crapass.nmprimtl   --> Nome do cooperado
                                ,pr_nmrescop => rw_crapcop.nmrescop   --> Nome da cooperativa
                                ,pr_nmextcop => rw_crapcop.nmextcop   --> Nome extenso da cooperativa
                                ,pr_nmcidade => rw_crapcop.nmcidade   --> Nome da cidade
                                ,pr_nmoperad => rw_crapope.nmoperad   --> Nome do operador                                         
                                ,pr_dsopecoo => vr_rel_dsopecoo       --> Descricao operador coordenador 
                                ,pr_idimpres => pr_idimpres  --> Indicador de impressao
                                 --------> OUT <--------                                   
                                 ,pr_tab_dados_itens_bordero => vr_tab_dados_itens_bordero --> retorna dados do bordero
                                 ,pr_tab_chq_bordero         => vr_tab_chq_bordero        --> retorna cheque do bordero
                                 ,pr_tab_bordero_restri      => vr_tab_bordero_restri     --> retorna restrições do cheque do bordero
                                 ,pr_cdcritic                => vr_cdcritic               --> Código da crítica
                                 ,pr_dscritic                => vr_dscritic);             --> Descrição da crítica

        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;  
      
      --> Bordero titulo
      ELSIF pr_tpctrlim = 3 THEN      
        --> Carrega dados com os titulos do bordero
        pc_carrega_dados_bordero_tit (pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                     ,pr_cdagenci => rw_crapass.cdagenci   --> Código da agencia
                                     ,pr_nrdconta => pr_nrdconta           --> Número da Conta
                                     ,pr_dtmvtolt => pr_dtmvtolt           --> Data do movimento
                                     ,pr_nrctrlim => pr_nrctrlim           --> Numero do contrato de limite
                                     ,pr_nrborder => pr_nrborder           --> Numero do bordero
                                     ,pr_nrmespsq => vr_tab_dados_dsctit(vr_tab_dados_dsctit.first).nrmespsq  --> Mes de pesquisa
                                     ,pr_txdiaria => vr_rel_txdiaria       --> Taxa diaria
                                     ,pr_txmensal => vr_rel_txmensal       --> Taxa mensa
                                     ,pr_txdanual => vr_rel_txdanual       --> Taxa anual
                                     ,pr_vllimite => vr_tab_dados_limite(vr_idxlimit).vllimite  --> Valor limite de desconto
                                     ,pr_ddmvtolt => to_char(pr_dtmvtolt,'DD')--> Dia movimento
                                     ,pr_dsmesref => vr_dsmesref           --> Descricao do mes
                                     ,pr_aamvtolt => to_char(pr_dtmvtolt,'RRRR')--> Ano de movimento
                                     ,pr_nmprimtl => rw_crapass.nmprimtl   --> Nome do cooperado
                                     ,pr_nmrescop => rw_crapcop.nmrescop   --> Nome da cooperativa
                                     ,pr_nmcidade => rw_crapcop.nmcidade   --> Nome da cidade
                                     ,pr_nmoperad => rw_crapope.nmoperad   --> Nome do operador                                         
                                     ,pr_dsopecoo => vr_rel_dsopecoo       --> Descricao operador coordenador 
                                     --------> OUT <--------                                   
                                     ,pr_tab_dados_tits_bordero => vr_tab_dados_itens_bordero --> retorna dados do bordero
                                     ,pr_tab_tit_bordero        => vr_tab_tit_bordero        --> retorna titulos do bordero
                                     ,pr_tab_tit_bordero_restri => vr_tab_bordero_restri     --> retorna restrições do titulos do bordero
                                     ,pr_tab_sacado_nao_pagou   => vr_tab_sacado_nao_pagou   --> Retornar dados do sacado que nao pagaram
                                     ,pr_cdcritic               => vr_cdcritic               --> Código da crítica
                                     ,pr_dscritic               => vr_dscritic);             --> Descrição da crítica
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
    --> Impressao CONTRATO DO CET  
    ELSIF pr_idimpres = 9 THEN
      --> Trecho nao convertido, pois nao será necessario para o projeto QRcode
      vr_dscritic := 'Tipo invalido - Rotina nao convertida oracle';
      RAISE vr_exc_erro; 
    END IF; 
    
    pr_tab_contrato_limite      := vr_tab_contrato_limite;
    pr_tab_dados_avais          := vr_tab_dados_avais;          
    pr_tab_dados_nota_pro       := vr_tab_dados_nota_pro;         
    pr_tab_dados_itens_bordero  := vr_tab_dados_itens_bordero;   
    pr_tab_tit_bordero          := vr_tab_tit_bordero;          
    pr_tab_bordero_restri       := vr_tab_bordero_restri;
    pr_tab_sacado_nao_pagou     := vr_tab_sacado_nao_pagou;     
    pr_tab_chq_bordero          := vr_tab_chq_bordero;
        
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans => 0,
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_busca_dados_imp_dsctit: ' || SQLERRM, chr(13)),chr(10));   
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
  END pc_busca_dados_imp_descont;
  
  --> Procedure para gerar impressoes do limite de credito 
  PROCEDURE pc_gera_impressao_limite( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_gera_impressao_limite           Antigo: b1wgen0030i.p/gera-impressao-limite
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Agosto/2016.                   Ultima atualizacao: 19/01/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar impressoes do limite de credito 
    --
    --   Alteração : 05/082016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    --
    --               26/12/2016 - Adicionados novos campos para impressao do contrato
    --                            de limite de desconto de cheques. Retirados alguns
    --                            campos que não estavam sendo usados.
    --                            Projeto 300 (Lombardi)
    --
    --               19/01/2018 - Inclusao da nova versao de contrato para impressao.
    --                            (Jaison/Lucas SUPERO - PRJ404)
    --
    -- .........................................................................*/
    
    ----------->>> CURSORES  <<<-------- 
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE; 
    
    --> Buscar dados associado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl
             
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crapass2 cr_crapass%ROWTYPE;
    
    --> Buscar Contrato de limite
    CURSOR cr_craplim IS
      SELECT lim.nrdconta,
             lim.cdageori,
             lim.vllimite,
             lim.cddlinha,
             lim.dtinivig,
             lim.idcobope,
						 lim.dtpropos
        FROM craplim lim
       WHERE lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = pr_tpctrlim;
    rw_craplim cr_craplim%ROWTYPE; 
    
    --> Buscar dados de Linhas de Desconto
    CURSOR cr_crapldc (pr_cdcooper crapldc.cdcooper%TYPE,
                       pr_cddlinha crapldc.cddlinha%TYPE )IS
      SELECT ldc.cddlinha,
             ldc.dsdlinha,
             ldc.txjurmor,
             ldc.txmensal
        FROM crapldc ldc
       WHERE ldc.cdcooper = pr_cdcooper
         AND ldc.cddlinha = pr_cddlinha
         AND ldc.tpdescto = pr_tpctrlim;
    rw_crapldc cr_crapldc%ROWTYPE;

    --> Buscar os emails para envio
    CURSOR cr_craprel (pr_cdcooper craprel.cdcooper%TYPE,
                       pr_cdrelato craprel.cdrelato%TYPE)IS
      SELECT rel.dsdemail
        FROM craprel rel
       WHERE rel.cdcooper = pr_cdcooper
         AND rel.cdrelato = pr_cdrelato;
    rw_craprel cr_craprel%ROWTYPE;
    
    --> Buscar dados agencia
    CURSOR cr_crapage (pr_cdcooper crapage.cdcooper%TYPE,
                       pr_cdagenci crapage.cdagenci%TYPE)IS
      SELECT age.cdagenci,
             age.nmresage,
             age.nmcidade,
             age.cdufdcop
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;

    --> Garantia Operacoes de Credito
    CURSOR cr_cobertura (pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
      SELECT tco.cdcooper,
             tco.nrconta_terceiro,
             tco.perminimo
        FROM tbgar_cobertura_operacao tco
       WHERE tco.idcobertura = pr_idcobert;
    rw_cobertura cr_cobertura%ROWTYPE;
        
    --> Buscar endereço
    CURSOR cr_crapenc (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE ) IS
      SELECT enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;

    ----------->>> TEMPTABLE <<<--------
    vr_tab_dados_avais         typ_tab_dados_avais;
    vr_tab_tit_bordero         typ_tab_tit_bordero;
    vr_tab_chq_bordero         DSCT0002.typ_tab_chq_bordero;  
    vr_tab_bordero_restri      typ_tab_bordero_restri;
    vr_tab_dados_tits_bordero  typ_tab_dados_itens_bordero;
    vr_tab_sacado_nao_pagou    typ_tab_sacado_nao_pagou;
    vr_tab_contrato_limite     typ_tab_contrato_limite;  
    vr_tab_dados_nota_pro      DSCT0002.typ_tab_dados_nota_pro;  
    
    vr_idxctlim                PLS_INTEGER;
    vr_idxpromi                PLS_INTEGER;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_flgcriti        BOOLEAN;
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;
    
    vr_nmarquiv        Varchar2(200);
    vr_dsdireto        Varchar2(200);
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100); 
    
    vr_cdtipdoc        INTEGER;
    vr_cdageqrc        INTEGER;
    vr_dstextab        craptab.dstextab%TYPE;
    
    vr_qrcode          VARCHAR2(100);
    vr_dstitulo        VARCHAR2(300);
    vr_txcetano        NUMBER;
    vr_txcetmes        NUMBER;
    vr_dscetano        VARCHAR2(200);
    vr_rel_cpfavali    VARCHAR2(500);
    vr_rel_nrcpfcjg    VARCHAR2(500);
    vr_dstpctrl        VARCHAR2(100);
    vr_cdrelato        INTEGER;
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    vr_nmjasper        VARCHAR2(50);
    vr_dsxmlnode       VARCHAR2(50);
    vr_nrfonres1       VARCHAR2(20);
    vr_nrfonres2       VARCHAR2(20);
    vr_nrvrsctr        NUMBER; 
    vr_flgachou        BOOLEAN;
    vr_inbreakpag      INTEGER;
    vr_ind_dev_sol     INTEGER;
		vr_ind_interv      INTEGER;
    vr_dspercob        VARCHAR2(200);	
    vr_dsavali1        VARCHAR2(500);
    vr_dsavali2        VARCHAR2(500);
    
    --> CET
    vr_desxml_CET      CLOB;
    vr_nmarqimp_CET    varchar2(60);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
    
  BEGIN
  
    IF pr_tpctrlim NOT IN (2,3) THEN
      vr_dscritic := 'Tipo de contrato de limite invalido.';
      RAISE vr_exc_erro;      
    ELSIF pr_tpctrlim = 2 THEN
      vr_dstpctrl := 'Cheque';
    ELSIF pr_tpctrlim = 3 THEN
      vr_dstpctrl := 'Titulo';
    END IF;  
  
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      
      CASE pr_idimpres
        WHEN 1 THEN
          vr_dstransa := 'Gerar impressao da proposta e contrato do limite de desconto de '||vr_dstpctrl;
        WHEN 2 THEN
          vr_dstransa := 'Gerar impressao do contrato do limite de desconto de '||vr_dstpctrl;
        WHEN 3 THEN
          vr_dstransa := 'Gerar impressao da proposta do limite de desconto de '||vr_dstpctrl;
        WHEN 4 THEN
          vr_dstransa := 'Gerar impressao da nota promissoria do limite de desconto de '||vr_dstpctrl;
        WHEN 9 THEN
          vr_dstransa := 'Gerar impressao de demonstracao do cet';
        ELSE
          vr_dscritic := 'Tipo de impressao invalida.';
          RAISE vr_exc_erro;
      END CASE;
    END IF; 
    
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF; 
      
    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN 
      CLOSE cr_crapass;
      vr_flgcriti := TRUE;
    ELSE
      CLOSE cr_crapass;
    END IF; 
    
    

    IF pr_idimpres IN( 1,      --> COMPLETA 
                       2 )THEN --> CONTRATO 
                       
      --> Buscar Contrato de limite
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF cr_craplim%NOTFOUND THEN
        CLOSE cr_craplim;
        vr_flgcriti := TRUE;
      ELSE
        CLOSE cr_craplim;
      END IF;

      --> Se for Cheque e igual ou superior a data do novo contrato
      IF (pr_tpctrlim = 2 OR pr_tpctrlim = 3) AND 
         nvl(rw_craplim.dtinivig, rw_craplim.dtpropos) >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                 ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
        vr_nrvrsctr := 2;
      END IF;

    END IF;

    --> Buscar dados para montar contratos etc para desconto de titulos
    pc_busca_dados_imp_descont( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagenci => pr_cdagecxa  --> Código da agencia
                               ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdoperad => pr_cdopecxa  --> Código do Operador
                               ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                               ,pr_tpctrlim => pr_tpctrlim  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                               ,pr_dtmvtolt => pr_dtmvtolt  --> Data de Movimento
                               ,pr_dtmvtopr => pr_dtmvtopr  --> Data do proximo Movimento
                               ,pr_inproces => pr_inproces  --> Indicador do processo 
                               ,pr_idimpres => pr_idimpres  --> Indicador de impresao
                               ,pr_nrctrlim => pr_nrctrlim  --> Contrato
                               ,pr_nrborder => 0            --> Numero do bordero
                               ,pr_flgerlog => 0            --> Indicador se deve gerar log(0-nao, 1-sim)
                               ,pr_limorbor => 1            --> Indicador do tipo de dado( 1 - LIMITE DSCTIT 2 - BORDERO DSCTIT )                                     
                               ,pr_nrvrsctr => vr_nrvrsctr  --> Numero da versao do contrato
                               --------> OUT <--------         
                               --> Tabelas nao serao retornadar pois nao foram convetidas parao projeto indexacao(qrcode)                          
                               --> pr_tab_emprsts             
                               --> pr_tab_proposta_limite    
                               --> pr_tab_proposta_bordero     
                               ,pr_tab_contrato_limite    => vr_tab_contrato_limite   
                               ,pr_tab_dados_avais        => vr_tab_dados_avais       
                               ,pr_tab_dados_nota_pro     => vr_tab_dados_nota_pro                          
                               ,pr_tab_dados_itens_bordero => vr_tab_dados_tits_bordero
                               ,pr_tab_tit_bordero        => vr_tab_tit_bordero     
                               ,pr_tab_chq_bordero        => vr_tab_chq_bordero  
                               ,pr_tab_bordero_restri     => vr_tab_bordero_restri
                               ,pr_tab_sacado_nao_pagou   => vr_tab_sacado_nao_pagou  
                               ,pr_cdcritic               => vr_cdcritic              
                               ,pr_dscritic               => vr_dscritic);
    
    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio( pr_tpdireto => 'C' --> cooper 
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');
                                         
    --> Se nao for impressao do cet gera arquivo normal
    IF pr_idimpres <> 9 THEN
    
      vr_nmarquiv := 'crrl519_'||pr_dsiduser;
      
      --> Remover arquivo existente   
      vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';
      
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
      
      --> Montar nome do arquivo
      pr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';
      
      --> Buscar identificador para digitalização
      vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                                 pr_nmsistem => 'CRED'      , 
                                                 pr_tptabela => 'GENERI'    , 
                                                 pr_cdempres => 00          , 
                                                 pr_cdacesso => 'DIGITALIZA' , 
                                                 pr_tpregist => (CASE pr_tpctrlim
                                                                   WHEN 3 THEN 3  -- Limite de Desc. de titulo. (GED) 
                                                                   WHEN 2 THEN 1  -- Limite de Desc. de Cheque. (GED) 
                                                                   ELSE NULL 
                                                                 END)); 
      
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_dscritic := 'Falta registro na Tabela "DIGITALIZA". ';
      END IF; 
      
      vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                                pr_dstext  => vr_dstextab, 
                                                pr_delimitador => ';');
    
    END IF;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>
                    <idimpres>'|| pr_idimpres ||'</idimpres>' ||
                   '<tpctrlim>'|| pr_tpctrlim ||'</tpctrlim>' ||
                   '<nrvrsctr>'|| vr_nrvrsctr ||'</nrvrsctr>');
      
    --> Contrato do CET 
    IF pr_idimpres = 9 THEN
      --> trecho nao convertido pois nao usará QRcode
      vr_dscritic := 'Tipo de impressao invalido.';
      RAISE vr_exc_erro;
    --> PROPOSTA
    ELSIF pr_idimpres = 3 THEN  
      --> trecho nao convertido pois nao usará QRcode
      vr_dscritic := 'Tipo de impressao invalido.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    IF cr_crapage%NOTFOUND THEN 
      CLOSE cr_crapage;
      vr_cdcritic := 962;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapage;
    END IF;

    IF pr_idimpres IN( 1,      --> COMPLETA 
                       2 )THEN --> CONTRATO 
                       
      vr_flgcriti := FALSE;
      
      --Buscar indice do primeiro registro
      vr_idxctlim := vr_tab_contrato_limite.first;
      IF vr_idxctlim IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel gerar a impressao.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Buscar dados de Linhas de Desconto
      OPEN cr_crapldc (pr_cdcooper => pr_cdcooper,
                       pr_cddlinha => rw_craplim.cddlinha);
      FETCH cr_crapldc INTO rw_crapldc;
      IF cr_crapldc%NOTFOUND THEN
        CLOSE cr_crapldc;
        vr_flgcriti := TRUE;
      ELSE
        CLOSE cr_crapldc;
      END IF;
      
      IF vr_flgcriti THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel gerar a impressao.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Chamar rorina para calcular o contrato do cet
      CCET0001.pc_calculo_cet_limites( pr_cdcooper  => pr_cdcooper         -- Cooperativa
                                      ,pr_dtmvtolt  => pr_dtmvtolt         -- Data Movimento
                                      ,pr_cdprogra  => 'ATENDA'            -- Programa chamador
                                      ,pr_nrdconta  => pr_nrdconta         -- Conta/dv
                                      ,pr_inpessoa  => rw_crapass.inpessoa -- Indicativo de pessoa
                                      ,pr_cdusolcr  => 1                   -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  => rw_craplim.cddlinha -- Linha de credio
                                      ,pr_tpctrlim  => 3                   --> Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                      ,pr_nrctrlim  => pr_nrctrlim         -- Contrato
                                      ,pr_dtinivig  => nvl(rw_craplim.dtinivig,pr_dtmvtolt)         -- Data liberacao
                                      ,pr_qtdiavig  => vr_tab_contrato_limite(vr_idxctlim).qtdiavig -- Dias de vigencia                                                          
                                      ,pr_vlemprst  => vr_tab_contrato_limite(vr_idxctlim).vllimite -- Valor emprestado
                                      ,pr_txmensal  => rw_crapldc.txmensal -- Taxa mensal     
                                      ,pr_txcetano  => vr_txcetano         -- Taxa cet ano
                                      ,pr_txcetmes  => vr_txcetmes         -- Taxa cet mes 
                                      ,pr_cdcritic  => vr_cdcritic
                                      ,pr_dscritic  => vr_dscritic);
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      --> Cheque
      IF pr_tpctrlim = 2 THEN
        
        vr_dscetano := TRIM(to_char(vr_txcetano,'fm990D00'))||'%'|| 
                       ' ao ano ('||
                       TRIM(to_char(vr_txcetmes,'fm990D00'))||' % ao mes), conforme planilha demonstrativa de cálculo.';
        
				IF vr_nrvrsctr = 2 THEN
					vr_dstitulo := 'CONTRATO DE LIMITE DE DESCONTO DE CHEQUES E GARANTIA REAL N.';
				ELSE
          vr_dstitulo := 'CONTRATO DE DESCONTO DE CHEQUES PRE-DATADOS E GARANTIA REAL N.';
				END IF;
      --> titulo  
      ELSIF pr_tpctrlim = 3 THEN
        
        vr_dscetano := gene0002.fn_valor_extenso( pr_idtipval => 'P', 
                                                  pr_valor    => vr_txcetano);
        vr_dscetano := to_char(vr_txcetano,'990D00')||'% ('|| 
                       lower(vr_dscetano)||') ao ano; ('||
                       to_char(vr_txcetmes,'990D00')||' % ao mes),';
        				  
        IF vr_nrvrsctr = 2 THEN	   
          vr_dscetano := TRIM(to_char(vr_txcetano,'fm990D00'))||'%'|| 
                       ' ao ano ('||
                       TRIM(to_char(vr_txcetmes,'fm990D00'))||' % ao mes), conforme planilha demonstrativa de cálculo.';

			    vr_dstitulo := 'CONTRATO DE LIMITE DE DESCONTO DE TÍTULO N.';
	      ELSE
          vr_dstitulo := 'CONTRATO DE DESCONTO DE TÍTULOS No:';	  
	      END IF;
      END IF;
      
      --Incluir no QRcode a agencia onde foi criado o contrato.
      IF nvl(rw_craplim.cdageori,0) = 0 THEN
        vr_cdageqrc := vr_tab_contrato_limite(vr_idxctlim).cdagenci;
      ELSE
        vr_cdageqrc := rw_craplim.cdageori;
      END IF;
      
      vr_qrcode := pr_cdcooper ||'_'||
                   vr_cdageqrc ||'_'||
                   TRIM(gene0002.fn_mask_conta(pr_nrdconta)) ||'_'||
                   0           ||'_'||
                   TRIM(gene0002.fn_mask_contrato(pr_nrctrlim)) ||'_'||
                   0           ||'_'||
                   vr_cdtipdoc;
      
      vr_nrfonres1 := vr_tab_contrato_limite(vr_idxctlim).nrfonav1;
      IF length(vr_nrfonres1) = 11 THEN
        vr_nrfonres1 := gene0002.fn_mask(vr_nrfonres1,'(99)99999-9999');
      ELSIF length(vr_nrfonres1) = 10 THEN
        vr_nrfonres1 := gene0002.fn_mask(vr_nrfonres1,'(99)9999-9999');
      ELSE
        vr_nrfonres1 := gene0002.fn_mask(vr_nrfonres1,'99999-9999');
      END IF;
      
      vr_nrfonres2 := vr_tab_contrato_limite(vr_idxctlim).nrfonav2;
      IF length(vr_nrfonres2) = 11 THEN
        vr_nrfonres2 := gene0002.fn_mask(vr_nrfonres2,'(99)99999-9999');
      ELSIF length(vr_nrfonres2) = 10 THEN
        vr_nrfonres2 := gene0002.fn_mask(vr_nrfonres2,'(99)9999-9999');
      ELSE
        vr_nrfonres2 := gene0002.fn_mask(vr_nrfonres2,'99999-9999');
      END IF;
      
      
      vr_dsavali1 := vr_tab_contrato_limite(vr_idxctlim).linaval1; --  vr_tab_contrato_limite(vr_idxctlim).nmdaval1 || ', inscrito no CPF/CNPJ nº ' || vr_tab_contrato_limite(vr_idxctlim).dscpfav1 || ' titular da conta corrente nº ' || vr_tab_contrato_limite(vr_idxctlim).linaval1;
      
      vr_dsavali2 := vr_tab_contrato_limite(vr_idxctlim).linaval2; --vr_tab_contrato_limite(vr_idxctlim).nmdaval2 || ', inscrito no CPF/CNPJ nº ' || vr_tab_contrato_limite(vr_idxctlim).dscpfav2 || ' titular da conta corrente nº ';
      
      pc_escreve_xml('<Contrato>'||
                         '<dsqrcode>'|| vr_qrcode                                    ||'</dsqrcode>'|| 
                         '<dstitulo>'|| vr_dstitulo                                  ||'</dstitulo>'||
                         '<tpctrlim>'|| pr_tpctrlim                                  ||'</tpctrlim>'||
                         '<nrctrlim>'|| TRIM(gene0002.fn_mask_contrato(pr_nrctrlim)) ||'</nrctrlim>'||
                         '<nrdconta>'|| gene0002.fn_mask_conta(pr_nrdconta)          ||'</nrdconta>'||
                         '<nmextcop>'|| vr_tab_contrato_limite(vr_idxctlim).nmextcop ||'</nmextcop>'|| 
                         '<cdagenci>'|| vr_tab_contrato_limite(vr_idxctlim).cdagenci ||'</cdagenci>'||
                         '<dslinha1>'|| vr_tab_contrato_limite(vr_idxctlim).dslinha1 ||'</dslinha1>'||                    
                         '<dslinha2>'|| vr_tab_contrato_limite(vr_idxctlim).dslinha2 ||'</dslinha2>'||                    
                         '<nmprimtl>'|| vr_tab_contrato_limite(vr_idxctlim).nmprimtl ||'</nmprimtl>'|| 
                         '<nrdconta>'|| vr_tab_contrato_limite(vr_idxctlim).nrdconta ||'</nrdconta>'||
                         '<nrcpfcgc>'|| vr_tab_contrato_limite(vr_idxctlim).nrcpfcgc ||'</nrcpfcgc>'|| 
                         '<txnrdcid>'|| vr_tab_contrato_limite(vr_idxctlim).txnrdcid ||'</txnrdcid>'||
                         '<dsdmoeda>'|| vr_tab_contrato_limite(vr_idxctlim).dsdmoeda ||'</dsdmoeda>'|| 
                         '<vllimite>'|| to_char(vr_tab_contrato_limite(vr_idxctlim).vllimite,'fm999G999G999G990D00') ||'</vllimite>'||
                         '<dslimite>'|| vr_tab_contrato_limite(vr_idxctlim).dslimite ||'</dslimite>'|| 
                         '<dsdlinha>'|| vr_tab_contrato_limite(vr_idxctlim).dsdlinha ||'</dsdlinha>'|| 
                         '<qtdiavig>'|| vr_tab_contrato_limite(vr_idxctlim).qtdiavig ||'</qtdiavig>'||
                         '<txqtdvig>'|| vr_tab_contrato_limite(vr_idxctlim).txqtdvig ||'</txqtdvig>'|| 
                         '<dsjurmor>'|| vr_tab_contrato_limite(vr_idxctlim).dsjurmor ||'</dsjurmor>'||                  
                         '<txdmulta>'|| to_char(vr_tab_contrato_limite(vr_idxctlim).txdmulta,'fm990D000000') ||'</txdmulta>'||
                         '<txmulext>'|| vr_tab_contrato_limite(vr_idxctlim).txmulext ||'</txmulext>'|| 
                         '<nmcidade>'|| vr_tab_contrato_limite(vr_idxctlim).nmcidade ||'</nmcidade>'|| 
                         '<dscetano>'|| vr_dscetano                                  ||'</dscetano>'||
                         '<nmrescop>'|| vr_tab_contrato_limite(vr_idxctlim).nmrescop ||'</nmrescop>'||  
                         '<nrtelsac>'|| vr_tab_contrato_limite(vr_idxctlim).nrtelsac ||'</nrtelsac>'||
                         '<nrtelouv>'|| vr_tab_contrato_limite(vr_idxctlim).nrtelouv ||'</nrtelouv>'||
                         '<dsendweb>'|| vr_tab_contrato_limite(vr_idxctlim).dsendweb ||'</dsendweb>'||
                         '<nmoperad>'|| vr_tab_contrato_limite(vr_idxctlim).nmoperad ||'</nmoperad>'||
                         '<localpag>'|| rw_crapage.nmcidade||'/'||rw_crapage.cdufdcop||'</localpag>'||
                         '<dtcontra>'|| to_char(rw_craplim.dtpropos, 'DD/MM/RRRR')   || '</dtcontra>'||
                         '<dsavali1>'|| vr_dsavali1                                  ||'</dsavali1>'||
                         '<dsavali2>'|| vr_dsavali2                                  ||'</dsavali2>');

      IF pr_tpctrlim = 2 THEN
        vr_ind_dev_sol := 0;
				vr_ind_interv := 0;

        -- Se possui avalista ativa indicador
        IF TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL OR
           TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN
           vr_ind_dev_sol := 1;
        END IF;

        pc_escreve_xml('<avalistas>'||
                         '<aval1>'||
                           '<nrsequen>1</nrsequen>'||
                           '<nmdavali>'|| vr_tab_contrato_limite(vr_idxctlim).nmdaval1 ||'</nmdavali>'||
                           '<linavali>'|| vr_tab_contrato_limite(vr_idxctlim).linaval1 ||'</linavali>'||
                           '<dsendcjg>'|| vr_tab_contrato_limite(vr_idxctlim).linaval1 ||'</dsendcjg>'||
                           '<nmconjug>'|| vr_tab_contrato_limite(vr_idxctlim).nmdcjav1 ||'</nmconjug>'|| 
                           '<cpfavali>'|| vr_tab_contrato_limite(vr_idxctlim).dscpfav1 ||'</cpfavali>'||
                           '<nrcpfcjg>'|| vr_tab_contrato_limite(vr_idxctlim).dscfcav1 ||'</nrcpfcjg>'|| 
                           '<fonavali>'|| vr_nrfonres1                                 ||'</fonavali>'|| 
                           '<nrfoncjq>'|| vr_nrfonres1                                 ||'</nrfoncjq>'||
                         '</aval1>
                          <aval2>'||
                           '<nrsequen>2</nrsequen>'|| 
                           '<nmdavali>'|| vr_tab_contrato_limite(vr_idxctlim).nmdaval2 ||'</nmdavali>'||
                           '<linavali>'|| vr_tab_contrato_limite(vr_idxctlim).linaval2 ||'</linavali>'||
                           '<dsendcjg>'|| vr_tab_contrato_limite(vr_idxctlim).linaval2 ||'</dsendcjg>'||
                           '<nmconjug>'|| vr_tab_contrato_limite(vr_idxctlim).nmdcjav2 ||'</nmconjug>'||
                           '<cpfavali>'|| vr_tab_contrato_limite(vr_idxctlim).dscpfav2 ||'</cpfavali>'||
                           '<nrcpfcjg>'|| vr_tab_contrato_limite(vr_idxctlim).dscfcav2 ||'</nrcpfcjg>'||
                           '<fonavali>'|| vr_nrfonres2                                 ||'</fonavali>'|| 
                           '<nrfoncjq>'|| vr_nrfonres2                                 ||'</nrfoncjq>'||
                         '</aval2>
                      </avalistas>');                              

        -- Se possui cobertura
        IF rw_craplim.idcobope > 0 THEN
          --> Garantia Operacoes de Credito
          OPEN  cr_cobertura(pr_idcobert => rw_craplim.idcobope);
          FETCH cr_cobertura INTO rw_cobertura;
          vr_flgachou := cr_cobertura%FOUND;
          CLOSE cr_cobertura;
          -- Se achou
          IF vr_flgachou THEN
            vr_dspercob := TRIM(to_char(rw_cobertura.perminimo,'990D00')) || '%';

            -- Se possui conta vinculada
            IF rw_cobertura.nrconta_terceiro > 0 THEN
              vr_ind_dev_sol := 1;
							vr_ind_interv := 1;

              --> Buscar cooperado
              OPEN cr_crapass(pr_cdcooper => rw_cobertura.cdcooper,
                              pr_nrdconta => rw_cobertura.nrconta_terceiro);
              FETCH cr_crapass INTO rw_crapass2;
              CLOSE cr_crapass;

              --> Buscar endereço do avalista
              OPEN  cr_crapenc(pr_cdcooper => rw_cobertura.cdcooper,
                               pr_nrdconta => rw_cobertura.nrconta_terceiro);      
              FETCH cr_crapenc INTO rw_crapenc;
              CLOSE cr_crapenc;

              pc_escreve_xml('<interv_garantidor>'||
                                 '<nro_interv>'|| (1 + (CASE WHEN TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL THEN 1 ELSE 0 END)
                                                     + (CASE WHEN TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN 1 ELSE 0 END)) ||'</nro_interv>'||
                                 '<nminterv>'|| rw_crapass2.nmprimtl ||'</nminterv>'||
                                 '<cpfinterv>'|| GENE0002.fn_mask_cpf_cnpj(rw_crapass2.nrcpfcgc,rw_crapass2.inpessoa) ||'</cpfinterv>'||
                                 '<lninterv>'|| rw_crapenc.dsendere  || ', nº '|| rw_crapenc.nrendere ||', bairro ' || 
                                                rw_crapenc.nmbairro  || ', da cidade de ' || 
                                                rw_crapenc.nmcidade  || '/' || 
                                                rw_crapenc.cdufende  || ', CEP ' ||
                                                rw_crapenc.nrcepend  || ', na condição de INTERVENIENTE/GARANTIDOR' ||
                                                ', titular da conta corrente nº' || 
                                                TRIM(gene0002.fn_mask_conta(rw_cobertura.nrconta_terceiro)) ||'.' ||'</lninterv>'||
																 '<nrdconta_interv>' || TRIM(gene0002.fn_mask_conta(rw_cobertura.nrconta_terceiro)) || '</nrdconta_interv>'||																								
                             '</interv_garantidor>');
            END IF;
          END IF;
        END IF;
        
        -- Se possui avalista ativa indicador
        IF TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL AND
           TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN
           vr_inbreakpag := 1;
        ELSIF (TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL OR
               TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL) AND
               TRIM(rw_crapass2.nmprimtl) IS NOT NULL THEN
           vr_inbreakpag := 1;
        ELSE
           vr_inbreakpag := 0;
        END IF;

        pc_escreve_xml('<dspercob>'|| nvl(vr_dspercob, ' ') ||'</dspercob>' ||
                       '<ind_dev_sol>'|| vr_ind_dev_sol ||'</ind_dev_sol>' ||
                       '<vr_ind_interv>'|| vr_ind_interv ||'</vr_ind_interv>' ||											 
                       '<inbreakpag>'|| vr_inbreakpag ||'</inbreakpag>');

      ELSE
        vr_ind_dev_sol := 0;
				vr_ind_interv := 0;

        -- Se possui avalista ativa indicador
        IF TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL OR
           TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN
           vr_ind_dev_sol := 1;
        END IF;
				
        pc_escreve_xml('<avalistas>'||
                         '<aval1>'||
                           '<nrsequen>1</nrsequen>'||
                           '<nmdavali>'|| vr_tab_contrato_limite(vr_idxctlim).nmdaval1 ||'</nmdavali>'||
                           '<linavali>'|| vr_tab_contrato_limite(vr_idxctlim).linaval1 ||'</linavali>'||
                           '<dsendcjg>'|| vr_tab_contrato_limite(vr_idxctlim).linaval1 ||'</dsendcjg>'||
                           '<nmconjug>'|| vr_tab_contrato_limite(vr_idxctlim).nmdcjav1 ||'</nmconjug>'|| 
                           '<cpfavali>'|| vr_tab_contrato_limite(vr_idxctlim).dscpfav1 ||'</cpfavali>'||
                           '<nrcpfcjg>'|| vr_tab_contrato_limite(vr_idxctlim).dscfcav1 ||'</nrcpfcjg>'|| 
                           '<fonavali>'|| vr_nrfonres1                                 ||'</fonavali>'|| 
                           '<nrfoncjq>'|| vr_nrfonres1                                 ||'</nrfoncjq>'||
                         '</aval1>
                          <aval2>'||
                           '<nrsequen>2</nrsequen>'|| 
                           '<nmdavali>'|| vr_tab_contrato_limite(vr_idxctlim).nmdaval2 ||'</nmdavali>'||
                           '<linavali>'|| vr_tab_contrato_limite(vr_idxctlim).linaval2 ||'</linavali>'||
                           '<dsendcjg>'|| vr_tab_contrato_limite(vr_idxctlim).linaval2 ||'</dsendcjg>'||
                           '<nmconjug>'|| vr_tab_contrato_limite(vr_idxctlim).nmdcjav2 ||'</nmconjug>'||
                           '<cpfavali>'|| vr_tab_contrato_limite(vr_idxctlim).dscpfav2 ||'</cpfavali>'||
                           '<nrcpfcjg>'|| vr_tab_contrato_limite(vr_idxctlim).dscfcav2 ||'</nrcpfcjg>'||
                           '<fonavali>'|| vr_nrfonres2                                 ||'</fonavali>'|| 
                           '<nrfoncjq>'|| vr_nrfonres2                                 ||'</nrfoncjq>'||
                         '</aval2>
                      </avalistas>');                              
											
        -- Se possui cobertura
        IF rw_craplim.idcobope > 0 THEN
          --> Garantia Operacoes de Credito
          OPEN  cr_cobertura(pr_idcobert => rw_craplim.idcobope);
          FETCH cr_cobertura INTO rw_cobertura;
          vr_flgachou := cr_cobertura%FOUND;
          CLOSE cr_cobertura;
          -- Se achou
          IF vr_flgachou THEN
            vr_dspercob := TRIM(to_char(rw_cobertura.perminimo,'990D00')) || '%';

            -- Se possui conta vinculada
            IF rw_cobertura.nrconta_terceiro > 0 THEN
              vr_ind_dev_sol := 1;
							vr_ind_interv := 1;

              --> Buscar cooperado
              OPEN cr_crapass(pr_cdcooper => rw_cobertura.cdcooper,
                              pr_nrdconta => rw_cobertura.nrconta_terceiro);
              FETCH cr_crapass INTO rw_crapass2;
              CLOSE cr_crapass;

              --> Buscar endereço do avalista
              OPEN  cr_crapenc(pr_cdcooper => rw_cobertura.cdcooper,
                               pr_nrdconta => rw_cobertura.nrconta_terceiro);      
              FETCH cr_crapenc INTO rw_crapenc;
              CLOSE cr_crapenc;

              pc_escreve_xml('<interv_garantidor>'||
                                 '<nro_interv>'|| (1 + (CASE WHEN TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL THEN 1 ELSE 0 END)
                                                     + (CASE WHEN TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN 1 ELSE 0 END)) ||'</nro_interv>'||
                                 '<nminterv>'|| rw_crapass2.nmprimtl ||'</nminterv>'||
                                 '<cpfinterv>'|| GENE0002.fn_mask_cpf_cnpj(rw_crapass2.nrcpfcgc,rw_crapass2.inpessoa) ||'</cpfinterv>'||
                                 '<lninterv>'|| rw_crapenc.dsendere  || ', nº '|| rw_crapenc.nrendere ||', bairro ' || 
                                                rw_crapenc.nmbairro  || ', da cidade de ' || 
                                                rw_crapenc.nmcidade  || '/' || 
                                                rw_crapenc.cdufende  || ', CEP ' ||
                                                rw_crapenc.nrcepend  || ', na condição de INTERVENIENTE/GARANTIDOR' ||
                                                ', titular da conta corrente nº' || 
                                                TRIM(gene0002.fn_mask_conta(rw_cobertura.nrconta_terceiro)) ||'.' ||'</lninterv>'||
																 '<nrdconta_interv>' || TRIM(gene0002.fn_mask_conta(rw_cobertura.nrconta_terceiro)) || '</nrdconta_interv>'||																								
                             '</interv_garantidor>');
            END IF;
          END IF;
        END IF;											
    
        -- Se possui avalista ativa indicador
        IF TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL AND
           TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL THEN
           vr_inbreakpag := 1;
        ELSIF (TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval1) IS NOT NULL OR
               TRIM(vr_tab_contrato_limite(vr_idxctlim).nmdaval2) IS NOT NULL) AND
               TRIM(rw_crapass2.nmprimtl) IS NOT NULL THEN
           vr_inbreakpag := 1;
        ELSE
           vr_inbreakpag := 0;
        END IF;

        pc_escreve_xml('<dspercob>'|| nvl(vr_dspercob, ' ') ||'</dspercob>' ||
                       '<ind_dev_sol>'|| vr_ind_dev_sol ||'</ind_dev_sol>' ||
                       '<vr_ind_interv>'|| vr_ind_interv ||'</vr_ind_interv>' ||											 
                       '<inbreakpag>'|| vr_inbreakpag ||'</inbreakpag>');

      END IF;
    
      --> Gerar XML para dados do relatorio de CET   
      CCET0001.pc_imprime_limites_cet( pr_cdcooper  => pr_cdcooper                 -- Cooperativa
                                      ,pr_dtmvtolt  => pr_dtmvtolt                 -- Data Movimento
                                      ,pr_cdprogra  => 'ATENDA'                    -- Programa chamador
                                      ,pr_nrdconta  => pr_nrdconta                 -- Conta/dv
                                      ,pr_inpessoa  => rw_crapass.inpessoa         -- Indicativo de pessoa
                                      ,pr_cdusolcr  => 1                           -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  => rw_craplim.cddlinha         -- Linha de credio
                                      ,pr_tpctrlim  => pr_tpctrlim                 -- Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                      ,pr_nrctrlim  => pr_nrctrlim                 -- Contrato
                                      ,pr_dtinivig  => nvl(rw_craplim.dtinivig,pr_dtmvtolt)         -- Data liberacao
                                      ,pr_qtdiavig  => vr_tab_contrato_limite(vr_idxctlim).qtdiavig -- Dias de vigencia                                      
                                      ,pr_vlemprst  => vr_tab_contrato_limite(vr_idxctlim).vllimite -- Valor emprestado
                                      ,pr_txmensal  => rw_crapldc.txmensal         -- Taxa mensal                                                               
                                      ,pr_flretxml  => 1                           -- Indicador se deve apenas retornar o XML da impressao
                                      ,pr_des_xml   => vr_desxml_CET               -- XML
                                      ,pr_nmarqimp  => vr_nmarqimp_CET             -- Nome do arquivo
                                      ,pr_cdcritic  => vr_cdcritic                 --> Código da crítica
                                      ,pr_dscritic  => vr_dscritic);               --> Descrição da crítica
    
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
          
      pc_escreve_xml('</Contrato>');  
       
    END IF;
    
    IF pr_idimpres IN( 1,      --> COMPLETA
                       4 )THEN --> PROMISSORIA
                       
      -- Buscar indice do primeiro registro
      vr_idxpromi := vr_tab_dados_nota_pro.FIRST;
      IF vr_idxpromi IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel gerar a impressao.';
        RAISE vr_exc_erro;
      END IF;

      pc_escreve_xml('<Promissoria>'||
                         '<tpctrlim>'|| pr_tpctrlim ||'</tpctrlim>'||
                         '<nmrescop>'|| UPPER(vr_tab_dados_nota_pro(vr_idxpromi).nmrescop) ||'</nmrescop>'||
                         '<nmextcop>'|| vr_tab_dados_nota_pro(vr_idxpromi).nmextcop ||'</nmextcop>'||
                         '<nrdocnpj>'|| vr_tab_dados_nota_pro(vr_idxpromi).nrdocnpj ||'</nrdocnpj>'||
                         '<ddmvtolt>'|| GENE0002.fn_mask(vr_tab_dados_nota_pro(vr_idxpromi).ddmvtolt,'99') ||'</ddmvtolt>'||
                         '<dsmesref>'|| INITCAP(vr_tab_dados_nota_pro(vr_idxpromi).dsmesref) ||'</dsmesref>'||
                         '<aamvtolt>'|| vr_tab_dados_nota_pro(vr_idxpromi).aamvtolt ||'</aamvtolt>'||
                         '<dsctremp>'|| TRIM(vr_tab_dados_nota_pro(vr_idxpromi).dsctremp) ||'</dsctremp>'||
                         '<dsdmoeda>'|| vr_tab_dados_nota_pro(vr_idxpromi).dsdmoeda ||'</dsdmoeda>'||
                         '<vlpreemp>'|| TO_CHAR(vr_tab_dados_nota_pro(vr_idxpromi).vlpreemp,'fm999G999G999G990D00') ||'</vlpreemp>'||
                         '<dsmvtolt>'|| vr_tab_dados_nota_pro(vr_idxpromi).dsmvtolt ||'</dsmvtolt>'||
                         '<dspreemp>'|| vr_tab_dados_nota_pro(vr_idxpromi).dspreemp ||'</dspreemp>'||
                         '<nmprimtl>'|| vr_tab_dados_nota_pro(vr_idxpromi).nmprimtl ||'</nmprimtl>'||
                         '<dscpfcgc>'|| vr_tab_dados_nota_pro(vr_idxpromi).dscpfcgc ||'</dscpfcgc>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(vr_tab_dados_nota_pro(vr_idxpromi).nrdconta)) ||'</nrdconta>'||
                         '<nmcidpac>'|| vr_tab_dados_nota_pro(vr_idxpromi).nmcidpac ||'</nmcidpac>'||
                         '<dsemsnot>'|| vr_tab_dados_nota_pro(vr_idxpromi).dsemsnot ||'</dsemsnot>'||
                         '<dsendass><![CDATA['|| vr_tab_dados_nota_pro(vr_idxpromi).dsendass ||']]></dsendass>');

      IF vr_tab_dados_avais.COUNT > 0 THEN

        pc_escreve_xml('<avalistas>');

        FOR vr_idx IN vr_tab_dados_avais.FIRST..vr_tab_dados_avais.LAST LOOP
          IF vr_tab_dados_avais(vr_idx).nrcpfcgc > 0 THEN
            IF pr_tpctrlim = 2 THEN
              vr_rel_cpfavali := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idx).nrcpfcgc,
                                                           pr_inpessoa => 1);
            ELSE
              vr_rel_cpfavali := 'C.P.F. '|| GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idx).nrcpfcgc,
                                                                       pr_inpessoa => 1);
            END IF;
          ELSE
            vr_rel_cpfavali := NULL;
          END IF;

          IF vr_tab_dados_avais(vr_idx).nrcpfcjg > 0 THEN
            IF pr_tpctrlim = 2 THEN
              vr_rel_nrcpfcjg := GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idx).nrcpfcjg,
                                                           pr_inpessoa => 1);
            ELSE
              vr_rel_nrcpfcjg := 'C.P.F. '|| GENE0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idx).nrcpfcjg,
                                                                       pr_inpessoa => 1);
            END IF;
          ELSE
            vr_rel_nrcpfcjg := NULL;
          END IF;

            pc_escreve_xml('<aval>'||
                             '<nmdavali>'|| vr_tab_dados_avais(vr_idx).nmdavali ||'</nmdavali>'||
                             '<nmconjug>'|| vr_tab_dados_avais(vr_idx).nmconjug ||'</nmconjug>'||
                             '<cpfavali>'|| vr_rel_cpfavali ||'</cpfavali>'||
                             '<nrcpfcjg>'|| vr_rel_nrcpfcjg ||'</nrcpfcjg>'||
                             '<dsendava><![CDATA['|| vr_tab_dados_avais(vr_idx).dsendere ||' '
                                         || vr_tab_dados_avais(vr_idx).nrendere ||'<br>'
                                         || vr_tab_dados_avais(vr_idx).dsendcmp ||'<br>'
                                         || GENE0002.fn_mask(vr_tab_dados_avais(vr_idx).nrcepend,'99999.999') ||' - '
                                         || vr_tab_dados_avais(vr_idx).nmcidade ||'/'
                                         || vr_tab_dados_avais(vr_idx).cdufresd ||
                             ']]></dsendava>'||
                           '</aval>');
        END LOOP;

        pc_escreve_xml('</avalistas>');

      END IF;

      pc_escreve_xml('</Promissoria>');

    END IF;
    
    --> Descarregar buffer
    pc_escreve_xml(' ',TRUE);  
    
    IF vr_desxml_CET IS NOT NULL THEN  
      -- concatena xml retornado CCET com xml contratos
      dbms_lob.append(vr_des_xml, vr_desxml_CET);
      dbms_lob.freetemporary(vr_desxml_CET);
    END IF;
    
    pc_escreve_xml('</raiz>',TRUE);
    
    -- Se foi solicitado para enviar email
    IF pr_flgemail = 1 THEN

      -- Se for cheque
      IF pr_tpctrlim = 2 THEN
        vr_cdrelato := 518;
      ELSE
        vr_cdrelato := 519;
      END IF;

      --> Buscar os emails para envio
      OPEN cr_craprel(pr_cdcooper => pr_cdcooper,
                      pr_cdrelato => vr_cdrelato);
      FETCH cr_craprel INTO rw_craprel;
      IF cr_craprel%NOTFOUND THEN 
        CLOSE cr_craprel;
        vr_cdcritic := 0;
        vr_dscritic := 'Relatorio nao cadastrado - ' || vr_cdrelato || '.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craprel;
      END IF;
      -- Se nao possui email informado
      IF TRIM(rw_craprel.dsdemail) IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Necessario cadastro de e-mail. Tela PAMREL.';
        RAISE vr_exc_erro;
      END IF;

      vr_dsmailcop := REPLACE(rw_craprel.dsdemail, ',', ';');
      vr_dscormail := 'SEGUE ARQUIVO EM ANEXO.';
      vr_dsassmail := 'crrl' || vr_cdrelato || ' - Conta/dv: ' ||
                      TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) || ' - PA ' ||
                      rw_crapage.cdagenci || ' ' || rw_crapage.nmresage;
    ELSE
      vr_dsmailcop := NULL;
      vr_dscormail := NULL;
      vr_dsassmail := NULL;
    END IF;

    IF pr_tpctrlim = 2 THEN
      
      IF pr_idimpres = 2 THEN
        vr_nmjasper := 'crrl519_contrato_limite_cheque.jasper';
        -- Se for impressao da versao 2
        IF vr_nrvrsctr = 2 THEN
          vr_nmjasper := 'crrl519_contrato_limite_cheque_v2.jasper';
        END IF;
        vr_dsxmlnode := '/raiz/Contrato';
      ELSE				  
        vr_nmjasper := 'crrl519_contrato_limite.jasper';   											    
        vr_dsxmlnode := '/raiz';
      END IF;
     
    ELSE
      
      -- Incluir tratativa para completa e nao completa
      IF vr_nrvrsctr = 2 THEN
         vr_nmjasper := 'crrl519_contrato_limite_novo.jasper'; 
      ELSE
          vr_nmjasper := 'crrl519_contrato_limite.jasper';   
      END IF;									
      				    
      vr_dsxmlnode := '/raiz';
    
    END IF;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'ATENDA'
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => vr_dsxmlnode
                               , pr_dsjasper  => vr_nmjasper
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto||'/'||pr_nmarqpdf
                               , pr_cdrelato => 519
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 132
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;  
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;
       
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans => 0,
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_gera_impressao_limite: ' || SQLERRM, chr(13)),chr(10));   
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;   
  END pc_gera_impressao_limite;  
  
  
  --> Procedure para gerar impressoes de bordero de tit.
  PROCEDURE pc_gera_impressao_bordero( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo Movimento
                                     ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo 
                                     ,pr_idimpres IN INTEGER                --> Indicador de impresao
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                     ,pr_dsiduser IN VARCHAR2               --> Descricao do id do usuario
                                     ,pr_flgemail IN INTEGER                --> Indicador de envia por email (0-nao, 1-sim)
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------                                   
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_gera_impressao_limite           Antigo: b1wgen0030i.p/gera-impressao-bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Setembro/2016.                   Ultima atualizacao: 08/09/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar impressoes de bordero de tit.
    --
    --   Alteração : 08/09/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    --               
    --               22/12/2016 - Alterado nome do Jasper de "crrl519_bordero"
    --                            para "crrl519_bordero_titulos". PRJ300 (Lombardi)
    --               
    -- .........................................................................*/
    
    ----------->>> CURSORES  <<<-------- 
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --> Buscar dados do bordero
    CURSOR cr_crapbdt IS
      SELECT *
        FROM crapbdt
       WHERE crapbdt.cdcooper = pr_cdcooper
         AND crapbdt.nrdconta = pr_nrdconta
         AND crapbdt.nrborder = pr_nrborder;
         
    rw_crapbdt cr_crapbdt%ROWTYPE;
    
    ----------->>> TEMPTABLE <<<--------   
    vr_tab_tot_descontos       DSCT0001.typ_tab_tot_descontos;
    vr_tab_dsctit_dados_limite DSCT0002.typ_tab_dados_limite; 
    vr_tab_dsctit              DSCT0002.typ_tab_dados_dsctit;              
    vr_tab_cecred_dsctit       DSCT0002.typ_tab_cecred_dsctit; 
    vr_tab_dados_avais         DSCT0002.typ_tab_dados_avais;
    vr_tab_dados_border        DSCT0002.typ_tab_dados_border;
    vr_tab_tit_bordero         DSCT0002.typ_tab_tit_bordero;
    vr_tab_chq_bordero         DSCT0002.typ_tab_chq_bordero;  
    vr_tab_bordero_restri      DSCT0002.typ_tab_bordero_restri;
    vr_tab_dados_itens_bordero DSCT0002.typ_tab_dados_itens_bordero;
    vr_tab_sacado_nao_pagou    DSCT0002.typ_tab_sacado_nao_pagou;
    vr_tab_contrato_limite     DSCT0002.typ_tab_contrato_limite;  
    vr_tab_dados_nota_pro      DSCT0002.typ_tab_dados_nota_pro;
    vr_tab_restri_apr_coo      typ_tab_restri_apr_coo;
    vr_tab_tit_bordero_ord     DSCT0002.typ_tab_tit_bordero;        
    
    
    vr_idxborde                PLS_INTEGER;
    vr_idxord                  VARCHAR2(50);
    vr_idx                     VARCHAR2(50);
    vr_idxrestr                VARCHAR2(100);
    vr_idxsac                  VARCHAR2(100);
    
    
    
    TYPE typ_rec_totais 
         IS RECORD( qttottit  INTEGER,
                    vltottit  NUMBER,
                    vltotliq  NUMBER,
                    qtrestri  INTEGER,
                    vlmedtit  NUMBER);
    TYPE typ_tab_totais IS TABLE OF typ_rec_totais
         INDEX BY PLS_INTEGER;
         vr_tab_totais typ_tab_totais;
    
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_flgcriti        BOOLEAN;
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_blnfound        BOOLEAN;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;    
    
    vr_nmarquiv        Varchar2(200);
    vr_dsdireto        Varchar2(200);
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100); 

    vr_cdtipdoc        INTEGER;
    vr_cdageqrc        INTEGER;
    vr_dstextab        craptab.dstextab%TYPE;
    
    vr_dstitulo        VARCHAR2(200);
    vr_qrcode          VARCHAR2(200);
    vr_dsmvtolt        VARCHAR2(200);
    vr_rel_qtdprazo    INTEGER;
    vr_dscpfcgc        VARCHAR2(20);
    vr_inpessoa        INTEGER;
    vr_idxtot          PLS_INTEGER;
    vr_dstpcobr        VARCHAR2(20);
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Gerar impressao de bordero de titulo';      
    END IF; 

    -- Busca dos dados da cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    vr_blnfound := cr_crapcop%FOUND;
    CLOSE cr_crapcop;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    END IF;
    
    -- Busca dos dados do bordero
    OPEN cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    vr_blnfound := cr_crapbdt%FOUND;
    CLOSE cr_crapbdt;
    -- Se NAO encontrar
    IF NOT vr_blnfound THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel encontrar Bordero.';
      RAISE vr_exc_erro;
    END IF;
    
    --> Buscar dados para montar contratos etc para desconto de cheques
    DSCT0002.pc_busca_dados_imp_descont
                      (pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                      ,pr_cdagenci => pr_cdagecxa  --> Código da agencia
                      ,pr_nrdcaixa => pr_nrdcaixa  --> Numero do caixa do operador
                      ,pr_cdoperad => pr_cdopecxa  --> Código do Operador
                      ,pr_nmdatela => pr_nmdatela  --> Nome da Tela
                      ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                      ,pr_tpctrlim => 3            --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                      ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                      ,pr_idseqttl => pr_idseqttl  --> Titular da Conta
                      ,pr_dtmvtolt => pr_dtmvtolt  --> Data de Movimento
                      ,pr_dtmvtopr => pr_dtmvtopr  --> Data do proximo Movimento
                      ,pr_inproces => pr_inproces  --> Indicador do processo 
                      ,pr_idimpres => pr_idimpres  --> Indicador de impresao
                      ,pr_nrctrlim => rw_crapbdt.nrctrlim  --> Contrato
                      ,pr_nrborder => pr_nrborder  --> Numero do bordero
                      ,pr_flgerlog => 0            --> Indicador se deve gerar log(0-nao, 1-sim)
                      ,pr_limorbor => 2            --> Indicador do tipo de dado( 1 - LIMITE DSCCHQ 2 - BORDERO DSCCHQ )                                     
                      --------> OUT <--------         
                      --> Tabelas nao serao retornadar pois nao foram convetidas parao projeto indexacao(qrcode)                          
                      --> pr_tab_emprsts             
                      --> pr_tab_proposta_limite    
                      --> pr_tab_proposta_bordero     
                      ,pr_tab_contrato_limite     => vr_tab_contrato_limite   
                      ,pr_tab_dados_avais         => vr_tab_dados_avais       
                      ,pr_tab_dados_nota_pro      => vr_tab_dados_nota_pro                          
                      ,pr_tab_dados_itens_bordero => vr_tab_dados_itens_bordero
                      ,pr_tab_tit_bordero         => vr_tab_tit_bordero     
                      ,pr_tab_chq_bordero         => vr_tab_chq_bordero  
                      ,pr_tab_bordero_restri      => vr_tab_bordero_restri
                      ,pr_tab_sacado_nao_pagou    => vr_tab_sacado_nao_pagou  
                      ,pr_cdcritic                => vr_cdcritic              
                      ,pr_dscritic                => vr_dscritic);

    IF nvl(vr_cdcritic,0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;    
    
    -- Buscar diretorio da cooperativa
    vr_dsdireto := GENE0001.fn_diretorio( pr_tpdireto => 'C' --> cooper 
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

    vr_nmarquiv := 'crrl519_'||pr_dsiduser;
      
    --> Remover arquivo existente   
    vr_dscomand := 'rm '||vr_dsdireto||'/'||vr_nmarquiv||'* 2>/dev/null';
      
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
      
    --> Montar nome do arquivo
    pr_nmarqpdf := vr_nmarquiv || gene0002.fn_busca_time || '.pdf';
      
    --> Buscar identificador para digitalização
    vr_dstextab :=  TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper, 
                                               pr_nmsistem => 'CRED'      , 
                                               pr_tptabela => 'GENERI'    , 
                                               pr_cdempres => 00          , 
                                               pr_cdacesso => 'DIGITALIZA' , 
                                               pr_tpregist => 4 ); --> Contrato Desc. Tit. (GED)
      
    IF TRIM(vr_dstextab) IS NULL THEN
      vr_dscritic := 'Falta registro na Tabela "DIGITALIZA". ';
    END IF; 
      
    vr_cdtipdoc :=  gene0002.fn_busca_entrada(pr_postext => 3, 
                                              pr_dstext  => vr_dstextab, 
                                              pr_delimitador => ';');
    
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    -->  7 - Bordero titulos
    --> 10 - Cheques do bordero para analise
    IF pr_idimpres IN (7,10) THEN
      --Buscar indice do primeiro registro
      vr_idxborde := vr_tab_dados_itens_bordero.FIRST;
      IF vr_idxborde IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Nao foi possivel gerar a impressao.';
        RAISE vr_exc_erro;
      END IF;
      
      --> Em analise
      IF rw_crapbdt.insitbdt = 2 THEN
        vr_dstitulo := 'DEMONSTRATIVO PARA ANALISE DE DESCONTO DE TITULOS';
      ELSE
        vr_dstitulo := 'BORDERO DE DESCONTO DE TITULOS';
      END IF;  
      
      vr_dsmvtolt := vr_tab_dados_itens_bordero(vr_idxborde).nmcidade ||', '|| GENE0005.fn_data_extenso(pr_dtmvtolt);
      
      --Incluir no QRcode a agencia onde foi criado o contrato.
      IF nvl(rw_crapbdt.cdageori,0) = 0 THEN
        vr_cdageqrc := vr_tab_dados_itens_bordero(vr_idxborde).cdagenci;
      ELSE
        vr_cdageqrc := rw_crapbdt.cdageori;
      END IF;
      
      vr_qrcode   := pr_cdcooper ||'_'||
                     vr_cdageqrc ||'_'||
                     TRIM(gene0002.fn_mask_conta(pr_nrdconta))    ||'_'||
                     TRIM(gene0002.fn_mask_contrato(pr_nrborder)) ||'_'||
                     0           ||'_'||
                     0           ||'_'||
                     vr_cdtipdoc;
      
      --> INICIO
      pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

      pc_escreve_xml('<Bordero>'||
                         '<tpctrlim>'|| 3 ||'</tpctrlim>'||
                         '<nmextcop>'|| rw_crapcop.nmextcop ||'</nmextcop>'||
                         '<dstitulo>'|| vr_dstitulo ||'</dstitulo>'||
                         '<dsqrcode>'|| vr_qrcode ||'</dsqrcode>'||
                         '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(pr_nrdconta)) ||'</nrdconta>'||
                         '<nmprimtl>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmprimtl ||'</nmprimtl>'||
                         '<cdagenci>'|| vr_tab_dados_itens_bordero(vr_idxborde).cdagenci ||'</cdagenci>'||
                         '<nrborder>'|| TRIM(GENE0002.fn_mask_contrato(pr_nrborder)) ||'</nrborder>'||
                         '<nrctrlim>'|| TRIM(GENE0002.fn_mask_contrato(rw_crapbdt.nrctrlim)) ||'</nrctrlim>'||
                         '<vllimite>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).vllimite,'fm999G999G999G990D00') ||'</vllimite>'||
                         '<txdanual>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txdanual,'fm9999g999g990d000000') ||'</txdanual>'||
                         '<txmensal>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txmensal,'fm9999g999g990d000000') ||'</txmensal>'||
                         '<txdiaria>'|| TO_CHAR(vr_tab_dados_itens_bordero(vr_idxborde).txdiaria,'fm9999g999g990d000000') ||'</txdiaria>'||
                         '<dsmvtolt>'|| vr_dsmvtolt ||'</dsmvtolt>'||  
                         '<nmoperad>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmoperad ||'</nmoperad>');

      
      --> reordenar para exibição no relatorio
      IF vr_tab_tit_bordero.count > 0 THEN
        vr_idx := vr_tab_tit_bordero.first;
        WHILE vr_idx IS NOT NULL LOOP

          vr_idxord := (9-vr_tab_tit_bordero(vr_idx).flgregis) ||  -- Ordernar decrescente
                       lpad(vr_tab_tit_bordero(vr_idx).nrinssac,14,'0')||
                       vr_tab_tit_bordero_ord.count;
                       
          vr_tab_tit_bordero_ord(vr_idxord) := vr_tab_tit_bordero(vr_idx);
          vr_idx :=  vr_tab_tit_bordero.next(vr_idx);
        END LOOP;
      END IF;
      
      pc_escreve_xml('<titulos>');  
      vr_idxord := vr_tab_tit_bordero_ord.first;
      WHILE vr_idxord IS NOT NULL  LOOP
      
        IF vr_tab_tit_bordero_ord(vr_idxord).dtlibbdt IS NOT NULL THEN
          vr_rel_qtdprazo := vr_tab_tit_bordero_ord(vr_idxord).dtvencto - vr_tab_tit_bordero_ord(vr_idxord).dtlibbdt;
        ELSE
          vr_rel_qtdprazo := vr_tab_tit_bordero_ord(vr_idxord).dtvencto - pr_dtmvtolt;
        END IF;
        
        -- Calcular totais por tipo de cobrança
        vr_idxtot := vr_tab_tit_bordero_ord(vr_idxord).flgregis;
        
        IF vr_tab_totais.exists(vr_idxtot) THEN
          vr_tab_totais(vr_idxtot).qttottit := vr_tab_totais(vr_idxtot).qttottit + 1;
        ELSE
          vr_tab_totais(vr_idxtot).qttottit := 1;
        END IF;
        
        vr_tab_totais(vr_idxtot).vltottit := nvl(vr_tab_totais(vr_idxtot).vltottit,0) + vr_tab_tit_bordero_ord(vr_idxord).vltitulo;
        vr_tab_totais(vr_idxtot).vltotliq := nvl(vr_tab_totais(vr_idxtot).vltotliq,0) + vr_tab_tit_bordero_ord(vr_idxord).vlliquid;
        
        IF length(vr_tab_tit_bordero_ord(vr_idxord).nrinssac) > 11 THEN
          vr_inpessoa := 2;
        ELSE
          vr_inpessoa := 1;
        END IF;
        
        vr_dscpfcgc := gene0002.fn_mask_cpf_cnpj( pr_nrcpfcgc => vr_tab_tit_bordero_ord(vr_idxord).nrinssac, 
                                                  pr_inpessoa => vr_inpessoa);
        
        pc_escreve_xml('<titulo>'||
                          '<flgregis>'||   vr_tab_tit_bordero_ord(vr_idxord).flgregis   ||'</flgregis>'|| 
                          '<dtvencto>'||   to_char(vr_tab_tit_bordero_ord(vr_idxord).dtvencto,'DD/MM/RRRR')   ||'</dtvencto>'|| 
                          '<nossonum>'||   vr_tab_tit_bordero_ord(vr_idxord).nossonum   ||'</nossonum>'|| 
                          '<vltitulo>'||   to_char(vr_tab_tit_bordero_ord(vr_idxord).vltitulo,'fm999G999G999G990D00')   ||'</vltitulo>'|| 
                          '<vlliquid>'||   to_char(vr_tab_tit_bordero_ord(vr_idxord).vlliquid,'fm999G999G999G990D00')   ||'</vlliquid>'|| 
                          '<qtdprazo>'||   vr_rel_qtdprazo                              ||'</qtdprazo>'|| 
                          '<nmsacado>'||   gene0007.fn_caract_controle(substr(vr_tab_tit_bordero_ord(vr_idxord).nmsacado,1,32))   ||'</nmsacado>'|| 
                          '<dscpfcgc>'||   vr_dscpfcgc                                  ||'</dscpfcgc>'|| 
                          '<restricoes>');
        
        -- Percorre as restricoes
        IF vr_tab_bordero_restri.COUNT > 0 THEN
          FOR idx2 IN vr_tab_bordero_restri.FIRST..vr_tab_bordero_restri.LAST LOOP
            -- Sea for restricao do cheque em questao
            IF vr_tab_bordero_restri(idx2).nrdocmto = vr_tab_tit_bordero_ord(vr_idxord).nrdocmto THEN
              
              --> Nao imprimir restriçoes referentes a titulos protestados ou em cartório
              IF vr_tab_bordero_restri(idx2).nrseqdig IN (90,91,11) THEN
                continue;
              END IF;  
            
              vr_tab_totais(vr_idxtot).qtrestri := nvl(vr_tab_totais(vr_idxtot).qtrestri,0) + 1;
              
              pc_escreve_xml('<restricao><texto>'|| gene0007.fn_caract_controle(vr_tab_bordero_restri(idx2).dsrestri) ||'</texto></restricao>');
              -- Se foi aprovado pelo coordenador
              IF vr_tab_bordero_restri(idx2).flaprcoo = 1 THEN
              
                IF NOT vr_tab_restri_apr_coo.exists(vr_tab_bordero_restri(idx2).dsrestri) THEN
                  vr_tab_restri_apr_coo(vr_tab_bordero_restri(idx2).dsrestri) := '';
                END IF;              

              END IF;
            END IF;
          END LOOP;
        END IF;
        pc_escreve_xml('</restricoes></titulo>');
        
      
        vr_idxord := vr_tab_tit_bordero_ord.next(vr_idxord);
      END LOOP;
      
      pc_escreve_xml('</titulos><totais>');  
            
      
      --> Listar Totais
      IF vr_tab_totais.count > 0 THEN
        IF vr_tab_totais.count > 1 THEN
          vr_tab_totais(2).vlmedtit := 0;
          --Gerar um total geral, caso exista mais de uma posicao
          FOR idxtot IN vr_tab_totais.first..vr_tab_totais.last LOOP
            
            vr_tab_totais(2).qttottit := nvl(vr_tab_totais(2).qttottit,0) + vr_tab_totais(idxtot).qttottit;
            vr_tab_totais(2).qtrestri := nvl(vr_tab_totais(2).qtrestri,0) + vr_tab_totais(idxtot).qtrestri;
            vr_tab_totais(2).vltottit := nvl(vr_tab_totais(2).vltottit,0) + vr_tab_totais(idxtot).vltottit;
            vr_tab_totais(2).vltotliq := nvl(vr_tab_totais(2).vltotliq,0) + vr_tab_totais(idxtot).vltotliq;            
          
          END LOOP;
          vr_tab_totais(2).vlmedtit := apli0001.fn_round(  vr_tab_totais(2).vltottit
                                                         / vr_tab_totais(2).qttottit,2);
        END IF;
      
        FOR idxtot IN vr_tab_totais.first..vr_tab_totais.last LOOP
        
        --> Calcular media
        vr_tab_totais(idxtot).vlmedtit := apli0001.fn_round( vr_tab_totais(idxtot).vltottit / 
                                                             vr_tab_totais(idxtot).qttottit,2);
        vr_dstpcobr := ' ';
        IF idxtot = 0 THEN
          vr_dstpcobr := '(S/ REG)';
        ELSIF idxtot = 1 THEN  
          vr_dstpcobr := '(REGIST)';
        END IF;
        pc_escreve_xml('<total>
                          <tpcobran>'|| vr_dstpcobr                    ||'</tpcobran>
                          <dsqtdtot>'|| vr_tab_totais(idxtot).qttottit ||' TÍTULOS' ||'</dsqtdtot>
                          <vldtotal>'|| to_char(vr_tab_totais(idxtot).vltottit,'fm999G999G999G990D00') ||'</vldtotal>
                          <vltotliq>'|| to_char(vr_tab_totais(idxtot).vltotliq,'fm999G999G999G990D00') ||'</vltotliq>
                          <vldmedia>'|| to_char(vr_tab_totais(idxtot).vlmedtit,'fm999G999G999G990D00') ||'</vldmedia>
                          <qtrestri>'|| vr_tab_totais(idxtot).qtrestri ||'</qtrestri>
                        </total>');  
        END LOOP;
      END IF;
      
      pc_escreve_xml('</totais>',TRUE);
      
      -- Se possui restricoes aprovadas pelo coordenador
      IF vr_tab_restri_apr_coo.COUNT > 0 THEN
        pc_escreve_xml(  '<restricoes_coord dsopecoo="'|| vr_tab_dados_itens_bordero(vr_idxborde).dsopecoo ||'">');
        vr_idxrestr := vr_tab_restri_apr_coo.FIRST;
        WHILE vr_idxrestr IS NOT NULL LOOP
          pc_escreve_xml(    '<restricao><texto>'|| gene0007.fn_caract_controle(vr_idxrestr) ||'</texto></restricao>');
          vr_idxrestr := vr_tab_restri_apr_coo.NEXT(vr_idxrestr);
        END LOOP;
        pc_escreve_xml(  '</restricoes_coord>');
      END IF;
      
      --> Exibir sacados que com pagamentos nao efetuados/pendentes
      IF vr_tab_sacado_nao_pagou.count > 0 THEN
        pc_escreve_xml('<sacnaopago>',TRUE);
        vr_idxsac := vr_tab_sacado_nao_pagou.first;
        WHILE vr_idxsac IS NOT NULL LOOP        
          pc_escreve_xml('<sacado>
                             <nmsacado>'|| gene0007.fn_caract_controle(vr_tab_sacado_nao_pagou(vr_idxsac).nmsacado) ||'</nmsacado>
                             <qtdtitul>'|| vr_tab_sacado_nao_pagou(vr_idxsac).qtdtitul ||'</qtdtitul>
                             <vlrtitul>'|| to_char(vr_tab_sacado_nao_pagou(vr_idxsac).vlrtitul,'fm999G999G999G990D00') ||'</vlrtitul>
                          </sacado>');  
          vr_idxsac := vr_tab_sacado_nao_pagou.next(vr_idxsac);
        END LOOP;
        pc_escreve_xml('</sacnaopago>');
      END IF;      
      
      pc_escreve_xml('</Bordero></raiz>',TRUE);      
      
      --> Solicita geracao do PDF
      gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                                 , pr_cdprogra  => 'ATENDA'
                                 , pr_dtmvtolt  => pr_dtmvtolt
                                 , pr_dsxml     => vr_des_xml
                                 , pr_dsxmlnode => '/raiz/Bordero'
                                 , pr_dsjasper  => 'crrl519_bordero_titulos.jasper'
                                 , pr_dsparams  => null
                                 , pr_dsarqsaid => vr_dsdireto||'/'||pr_nmarqpdf
                                 , pr_cdrelato => 519
                                 , pr_flg_gerar => 'S'
                                 , pr_qtcoluna  => 132
                                 , pr_sqcabrel  => 1
                                 , pr_flg_impri => 'N'
                                 , pr_nmformul  => ' '
                                 , pr_nrcopias  => 1
                                 , pr_nrvergrl  => 1
                                 , pr_des_erro  => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
        RAISE vr_exc_erro; -- encerra programa
      END IF; 
      
      IF pr_idorigem = 5 THEN
        -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
        GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => NULL
                                    ,pr_nrdcaixa => NULL
                                    ,pr_nmarqpdf => vr_dsdireto ||'/'||pr_nmarqpdf
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);
        -- Se retornou erro
        IF NVL(vr_des_reto,'OK') <> 'OK' THEN
          IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
            vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
            vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
            RAISE vr_exc_erro; -- encerra programa
          END IF;
        END IF;

        -- Remover relatorio do diretorio padrao da cooperativa
        gene0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => 'rm '||vr_dsdireto ||'/'||pr_nmarqpdf
                             ,pr_typ_saida   => vr_typsaida
                             ,pr_des_saida   => vr_dscritic);
        -- Se retornou erro
        IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
          -- Concatena o erro que veio
          vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;
          
      
    END IF;
    
  
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;

      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans => 0,
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
      END IF;
      
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro pc_gera_impressao_limite: ' || SQLERRM, chr(13)),chr(10));   
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => pr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
      END IF; 
  END pc_gera_impressao_bordero; 
  
END DSCT0002;
/
