CREATE OR REPLACE PACKAGE CECRED."DSCT0002" AS

  /*-------------------------------------------------------------------------------------------------------------
  --
  --  Programa:  DSCT0002                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : Odirlei Busana - AMcom
  --  Data    : Agosto/2016                     Ultima Atualizacao: 09/09/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto de titulos
  --
  --
  --  Histórico de Alterações:
  --    05/08/2016 - Conversao Progress para oracle (Odirlei - AMcom)
  --
  --    22/12/2016 - Incluidos novos campos para os tipos typ_rec_contrato_limite
  --                 e typ_rec_chq_bordero. Projeto 300 (Lombardi)
  --
  --    02/03/2017 - Tornar a pc_lista_avalistas publica. (P210.2 - Jaison/Daniel)
  --
  --    20/06/2017 - Incluida validacao de tamanho na atribuicao do campo de operador
  --                 (ID + Nome) pois estava estourando a variavel.
  --                 Heitor (Mouts) - Chamado 695581
  --
  --    11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))
  --
  --    25/01/2018 - Inclusão da Procedure "pc_busca_parametros_dsctit", referente à
  --                 conversão de Progress para Oracle da tela "TAB052".
  --                (Gustavo Sene - GFT)
  --
  --    01/02/2018 - Inclusão de Parâmetro de entrada por Tipo de Pessoa (Física / Jurídica)
  --                 na procedure "pc_busca_parametros_dsctit"
  --                (Gustavo Sene - GFT)
  --
  --    13/03/2018 - Inclusão da Procedure "pc_efetua_analise_pagador", referente à rotina (JOB)
  --                 de validação diária dos Pagadores (Borderô). (Gustavo Sene - GFT)
  --
  --    12/04/2018 - Adicionado novo parametro na chamada da procedure pc_gera_impressao_bordero
  --                 referente ao indicador se deve imprimir restricoes. (Alex Sandro - GFT)
  --
  --    13/04/2018 - Remoção do campo 'pctitemi' Percentual de títulos por pagador da procedure
  --                 'pc_busca_parametros_dsctit'  (Leonardo Oliveira - GFT).
  --
  --    10/05/2018 - Inserção do campo 'cardbtit_c' para cálculo do % Geral de Liquidez
  --
  --    10/05/2018 - Ajuste para considerar os novos contratos do PJ404 a com a data da proposta
  --                 para contratos de desconto de título e cheque (Lucas Skroch - Supero)
  --
  --    13/08/2018 - Adicionados novos campos para o calculo de liquidez (Luis Fernando - GFT)
  --
  --    05/09/2018 - Correções na descrição do histórico e % de multa, taxa mensal e mora na pc_gera_extrato_bordero - Andrew Albuquerque (GFT)
  --
  --    14/09/2018 - pc_gera_extrato_bordero: Alterada ordenação do dataset principal de extrato, para imprimir
  --                 todos os Débitos e depois os Créditos. - Andrew Albuquerque (GFT)
  --
  --    03/04/2019 - substituição da tabela CRAPNRC pela TBRISCO_OPERACOES (Mario - AMcom)
  --
  --    23/04/2018 - Ajuste na tratativa Cooper Central (cdcooper=3)nas 2 tabelas
  --                 crapnrc e tbrisco_operacoes (Mário-AMcom)
  --
  --------------------------------------------------------------------------------------------------------------*/

  -- Registro para armazenar parametros para desconto de titulo
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
                  pctolera  NUMBER,
                  pcdmulta  NUMBER,
                  cardbtit  NUMBER,
                  cardbtit_c  NUMBER,
                  pcnaopag  NUMBER,
                  qtnaopag  INTEGER,
                  qtprotes  INTEGER,
                  ---- NOVOS CAMPOS ----
                  vlmxassi  NUMBER,   -- Valor Máximo Dispensa Assinatura
                  flemipar  INTEGER,  -- Verificar se Emitente é Cônjugue do Cooperado (no caso de Pessoa Física) / Verificar se Emitente é Sócio do Cooperado (no caso de Pessoa Jurídica)
                  flpjzemi  INTEGER,  -- Verificar Prejuízo do Emitente
                  flpdctcp  INTEGER,  -- Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
                  qttliqcp  INTEGER,  -- Mínimo de Liquidez do Cedente x Pagador (Qtd. de Titulos)
                  vltliqcp  INTEGER,  -- Mínimo de Liquidez do Cedente x Pagador (Valor dos Titulos)
                  qtmintgc  INTEGER,  -- Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Titulos)
                  vlmintgc  INTEGER,  -- Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Titulos)
                  qtmesliq  INTEGER,  -- Qtd. Meses Cálculo Percentual de Liquidez
                  vlmxprat  INTEGER,  -- Valor máximo permitido por ramo de atividade
                  pcmxctip  INTEGER,  -- Concentração máxima de títulos por pagador
                  flcocpfp  INTEGER,  -- Consulta de CPF/CNPJ do pagador --> Excluir
                  qtmxdene  INTEGER,  -- Quantidade máxima de dias para envio para Esteira
                  qtdiexbo  INTEGER,  -- Dias para expirar borderô
                  qtmxtbib  INTEGER,  -- Quantidade máxima de títulos por borderô IB
                  qtmxtbay  INTEGER,  -- Quantidade máxima de títulos por borderô Ayllos
                  qtmitdcl  INTEGER,  -- Quantidade mínima de títulos descontados para cálculo da liquidez
                  vlmintcl  NUMBER,  -- Valor mínimo para cálculo liquidez
                  pctitpag  INTEGER   -- Percentual de títulos por pagador
                  );

  -- Tabela para armazenar parametros para desconto de titulo (antigo b1wgen0030tt.i/tt-dsctit.)
  TYPE typ_tab_dados_dsctit IS TABLE OF typ_rec_dados_dsctit
       INDEX BY PLS_INTEGER;

  -- Tabela para armazenar parametros para desconto de titulo - CECRED (antigo b1wgen0030tt.i/tt-dados_cecred_dsctit)
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
                  dsopecoo  VARCHAR2(100),
                  innivris  VARCHAR2(2),
                  qtdiaatr  NUMBER,
                  inprejuz  INTEGER,
                  dtliqprj  crapbdt.dtliqprj%TYPE,
                  flverbor crapbdt.flverbor%TYPE
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
                  dtdpagto craptdb.dtdpagto%TYPE,
                  nossonum VARCHAR2(50),
                  vltitulo craptdb.vltitulo%TYPE,
                  vlliquid craptdb.vlliquid%TYPE,
                  vlsldtit craptdb.vlsldtit%TYPE,
                  inprejuz crapbdt.inprejuz%TYPE,
                  vlsdprej craptdb.vlsdprej%TYPE,
                  nmsacado crapsab.nmdsacad%TYPE,
                  flgregis crapcob.flgregis%TYPE,
                  insittit craptdb.insittit%TYPE,
                  insitapr craptdb.insitapr%TYPE,
                  nrctrdsc tbdsct_titulo_cyber.nrctrdsc%TYPE,
                  dssittit VARCHAR2(100),
                  flverbor crapbdt.flverbor%TYPE);

  TYPE typ_tab_tit_bordero IS TABLE OF typ_rec_tit_bordero
       INDEX BY VARCHAR2(50);

  --> Armazenar dados das retrições dos titulos do bordero antigo(b1wgen0030tt.i/tt-dsctit_bordero_restricoes)
  TYPE typ_rec_bordero_restric
       IS RECORD (nrborder crapabt.nrborder%TYPE,
                  nrdocmto crapabt.nrdocmto%TYPE,
                  nrcheque crapcdb.nrcheque%TYPE,
                  tprestri INTEGER,
                  dsrestri crapabt.dsrestri%TYPE,
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
                  dsopecoo crapope.nmoperad%TYPE,
                  flverbor crapbdt.flverbor%TYPE);
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


  type tpy_rec_analise_pagador is record (
       qtremessa_cartorio tbdsct_analise_pagador.qtremessa_cartorio%type,
       qttit_protestados  tbdsct_analise_pagador.qttit_protestados%type,
       qttit_naopagos     tbdsct_analise_pagador.qttit_naopagos%type,
       pemin_liquidez_qt  tbdsct_analise_pagador.pemin_liquidez_qt%type,
       pemin_liquidez_vl  tbdsct_analise_pagador.pemin_liquidez_vl%type,
       peconcentr_maxtit  tbdsct_analise_pagador.peconcentr_maxtit%type,
       inemitente_conjsoc tbdsct_analise_pagador.inemitente_conjsoc%type,
       inpossui_titdesc   tbdsct_analise_pagador.inpossui_titdesc%type,
       invalormax_cnae    tbdsct_analise_pagador.invalormax_cnae%type,
       inpossui_criticas  tbdsct_analise_pagador.inpossui_criticas%type );

  type tpy_tab_analise_pagador is table of tpy_rec_analise_pagador
       index by pls_integer;

  -- Registro para armazenar parametros para desconto de titulo
  TYPE typ_rec_dados_proposta
       IS RECORD (nrdconta  crapass.nrdconta%TYPE
                  ,nrctrlim craplim.nrctrlim%TYPE
                  ,nrcpfcgc VARCHAR2(30)
                  ,nmdsecao VARCHAR2(100)
                  ,dsramati crapprp.dsramati%TYPE
                  ,dsagenci VARCHAR2(200)
                  ,vllimchq NUMBER
                  ,rel_tpcobran VARCHAR2(100)
                  ,dsdlinha VARCHAR2(400)
                  ,dtcalcul DATE
                  ,nmempres VARCHAR2(100)
                  ,telefone VARCHAR2(100)
                  ,vlsalari NUMBER
                  ,vlsmdtri NUMBER
                  ,vlcaptal NUMBER
                  ,vlprepla NUMBER
                  ,vlsalcon NUMBER
                  ,vloutras NUMBER
                  ,vltotccr NUMBER
                  ,vlaplica NUMBER
                  ,dsdeben1 VARCHAR2(60)
                  ,dsdeben2 VARCHAR2(60)
                  ,vlfatura NUMBER
                  ,tpcobran VARCHAR2(25)
                  ,vllimpro NUMBER
                  ,vlmedtit NUMBER
                  ,nrmatric crapass.nrmatric%TYPE
                  ,nmprimtl crapass.nmprimtl%TYPE
                  ,dtadmemp crapass.dtadmemp%TYPE
                  ,dstipcta VARCHAR2(100)
                  ,dssitdct VARCHAR2(100)
                  ,dtadmiss crapass.dtadmiss%TYPE
                  ,vllimcre crapass.vllimcre%TYPE
                  ,vlutiliz NUMBER
                  ,dsobserv crapprp.dsobserv##1%TYPE
                  ,dsobser1 crapprp.dsobserv##1%TYPE
                  ,dsobser2 crapprp.dsobserv##1%TYPE
                  ,dsobser3 crapprp.dsobserv##1%TYPE
                  ,dsobser4 crapprp.dsobserv##1%TYPE
                  ,nmoperad crapope.nmoperad%TYPE
                  ,nmcidade VARCHAR2(100)
                  ,nmresco1 VARCHAR2(100)
                  ,nmresco2 VARCHAR2(100)
                  ,ddmvtolt VARCHAR2(100)
                  ,dsmesref VARCHAR2(100)
                  ,aamvtolt VARCHAR2(100)
                  ,dsemsnot VARCHAR2(100)
                  ,dsdrisco crapgrp.dsdrisgp%TYPE
                  ,vlendivi NUMBER
                  ,dsdopera VARCHAR2(100)
                  ,nrctrrat NUMBER
                  ,indrisco VARCHAR2(100)
                  ,nrnotrat NUMBER
                  ,nrnotatl NUMBER
                  ,vloperac VARCHAR2(100)
                  );

  -- Tabela para armazenar parametros para desconto de titulo (antigo b1wgen0030tt.i/tt-dsctit.)
  TYPE typ_tab_dados_proposta IS TABLE OF typ_rec_dados_proposta
       INDEX BY PLS_INTEGER;

-- P450 SPT13 - alteracao para habilitar rating novo
  TYPE typ_rec_rating_hist
       IS RECORD (dsdopera  VARCHAR2(100)
                  ,nrctrrat NUMBER(10)
                  ,indrisco VARCHAR2(3)
                  ,nrnotrat NUMBER(25,2)
                  ,vloperac NUMBER
                  ,dsditrat VARCHAR2(100)
                  );

  TYPE typ_tab_rating_hist IS TABLE OF typ_rec_rating_hist
       INDEX BY PLS_INTEGER;
-- P450 SPT13 - alteracao para habilitar rating novo

  --> Buscar dados do avalista
  PROCEDURE pc_busca_dados_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE           --> Numero da conta do cooperado
                                    ,pr_nrctrato IN crapavt.nrctremp%TYPE DEFAULT 0 --> Numero do contrato para busca de avalistas terceiros
                                    ,pr_tpctrato IN crapavt.tpctrato%TYPE DEFAULT 0 --> Tipo do contrato para busca de avalistas terceiros
                                    ,pr_tpavalis IN INTEGER                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                     --------> OUT <--------
                                    ,pr_tab_dados_avais IN OUT typ_tab_dados_avais  --> tabela contendo os parametros da cooperativa
                                    ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic           OUT VARCHAR2);           --> Descrição da crítica

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
                                       ,pr_tpimpres IN VARCHAR2 DEFAULT NULL
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
                                       ,pr_tab_dados_proposta         OUT typ_tab_dados_proposta
                                       ,pr_tab_emprestimos            OUT EMPR0001.typ_tab_dados_epr
                                       ,pr_tab_grupo                  OUT GECO0001.typ_tab_crapgrp
                                       ,pr_tab_rating_hist            OUT typ_tab_rating_hist
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 0      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);             --> Descrição da crítica


  --> Procedure para obter parametros gerais de desconto de titulos (TAB052)
  PROCEDURE pc_busca_parametros_dsctit ( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                        ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> data do movimento
                                        ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                        ,pr_tpcobran IN NUMBER                 --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                        ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo de Pessoa:   1 = Física / 2 = Jurídica

                                         --------> OUT <--------
                                        ,pr_tab_dados_dsctit  OUT typ_tab_dados_dsctit  --> tabela contendo os parametros da cooperativa
                                        ,pr_tab_cecred_dsctit OUT typ_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2);            --> Descrição da crítica

  PROCEDURE pc_efetua_analise_pagador  ( pr_cdcooper IN crapsab.cdcooper%TYPE  --> Código da Cooperativa do Pagador (Sacado)
                                        ,pr_nrdconta IN crapsab.nrdconta%TYPE DEFAULT NULL  --> Número da Conta do Pagador       (Sacado)
                                        ,pr_nrinssac IN crapsab.nrinssac%TYPE DEFAULT NULL  --> Número de Inscrição do Pagador   (Sacado)
                                         --------> OUT <--------
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2             --> Descrição da crítica
                                        );

  --> Buscar titulos de um determinado bordero a partir da craptdb
  PROCEDURE pc_busca_titulos_bordero (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     --------> OUT <--------
                                     ,pr_tab_tit_bordero        OUT typ_tab_tit_bordero --> retorna titulos do bordero
                                     ,pr_tab_tit_bordero_restri OUT typ_tab_bordero_restri --> retorna restrições do titulos do bordero
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);          --> Descrição da crítica

  PROCEDURE pc_atualiza_calculos_pagador ( pr_cdcooper IN crapsab.cdcooper%TYPE  --> Código da Cooperativa do Pagador (Sacado)
                                   ,pr_nrdconta IN crapsab.nrdconta%TYPE  --> Número da Conta do Pagador       (Sacado)
                                   ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Número de Inscrição do Pagador   (Sacado)
                                   ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE DEFAULT NULL --> Data inicial para calculo da liquidez
                                   ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE DEFAULT NULL --> Data final para calculo da liquidez
                                   ,pr_qtcarpag     IN NUMBER DEFAULT NULL   --> Quantidade de dias apos vencimento de carencia
                                   ,pr_qttliqcp     IN NUMBER DEFAULT NULL   --> Quantidade limite para liquidez
                                   ,pr_vltliqcp     IN NUMBER DEFAULT NULL   --> Valor limite para liquidez
                                   ,pr_pcmxctip     IN NUMBER DEFAULT NULL   --> Valor limite para concentracao
                                   ,pr_qtmitdcl     IN INTEGER DEFAULT NULL  --> Quantidade minima de titulos para calculo de liquidez
                                   ,pr_vlmintcl     IN NUMBER DEFAULT NULL   --> Valor minimo para titulo entrar no calculo de liquidez
                                   ,pr_flforcar     IN BOOLEAN DEFAULT FALSE --> Força os cálculos independente se houve job no d-1
                                   --------------> OUT <--------------
                                   ,pr_pc_cedpag    OUT NUMBER
                                   ,pr_qtd_cedpag   OUT NUMBER
                                   ,pr_pc_conc      OUT NUMBER
                                   ,pr_qtd_conc     OUT NUMBER
                                   ,pr_cdcritic          OUT PLS_INTEGER  --> Código da crítica
                                   ,pr_dscritic          OUT VARCHAR2     --> Descrição da crítica
                                  );

  PROCEDURE pc_busca_dados_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                   ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_analise_pagador_paralelo (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                 ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_analise_pagador_agencia (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE   --> Código da Agencia
                                        ,pr_idparale IN INTEGER
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                        ,pr_dscritic OUT VARCHAR2);

  PROCEDURE pc_gera_extrato_bordero( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 0      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica


  FUNCTION fn_busca_tbrisco_flag_ativo (pr_cdcooper IN tbrisco_operacoes.cdcooper%TYPE  --> Código da Cooperativa
                                       ,pr_nrdconta IN tbrisco_operacoes.nrdconta%TYPE  --> Conta do associado
                                       ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE  --> Tipo do contrato de rating
                                       ,pr_nrctrato IN tbrisco_operacoes.nrctremp%TYPE) --> Número do contrato do rating
                                                                                        RETURN NUMBER;

  /* Rotina responsavel por buscar a descrição da situacao do contrato */
  FUNCTION fn_busca_descricao_dominio (pr_nmdominio IN VARCHAR2
                                      ,pr_cddominio IN INTEGER) RETURN VARCHAR2;
END  DSCT0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED."DSCT0002" AS

  -------------------------------------------------------------------------------------------------------------
  --
  --  Programa: DSCT0002                       Antiga: generico/procedures/b1wgen0030.p
  --  Autor   : Odirlei Busana - AMcom
  --  Data    : Agosto/2016                     Ultima Atualizacao: 09/09/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package para rotinas envolvendo desconto titulos
  --              titulos.
  --
  --  Alteracoes:
  --    05/08/2016 - Conversao Progress para oracle (Odirlei - AMcom)
  --
  --              22/12/2016 - Incluidos novos campos para os tipos typ_rec_contrato_limite
  --                           e typ_rec_chq_bordero. Projeto 300 (Lombardi)
  --
  --              17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
  --
  --              24/07/2017 - Alterar cdoedptl para idorgexp.
  --                           PRJ339-CRM  (Odirlei-AMcom)
  --
  --             03/10/2017 - Imprimir conta quando o avalista for cooperado
  --                          Junior (Mouts) - Chamado 767055
  --
  --             25/01/2018 - Inclusão da Procedure "pc_busca_parametros_dsctit", referente à
  --                 conversão de Progress para Oracle da tela "TAB052".
  --                (Gustavo Sene - GFT)
  --
  --             08/03/2018 - Chamado 847579 - Correção da impressão de estado incorreto na impressao do contrato de limite
  --
  --    01/02/2018 - Inclusão de Parâmetro de entrada por Tipo de Pessoa (Física / Jurídica)
  --                 na procedure "pc_busca_parametros_dsctit"
  --                (Gustavo Sene - GFT)
  --
  --    13/03/2018 - Inclusão da Procedure "pc_efetua_analise_pagador", referente à rotina (JOB)
  --                 de validação diária dos Pagadores (Borderô). (Gustavo Sene - GFT)
  --
  --    11/04/2018 - Adicionado a utilização da tabela crawlim Paulo Penteado (GFT)
  --
  --   12/04/2018 - Adicionado novo parametro na chamada da procedure pc_gera_impressao_bordero
  --                referente ao indicador se deve imprimir restricoes. (Alex Sandro - GFT)
  --
  --   13/04/2018 - Remoção do campo 'pctitemi' Percentual de títulos por pagador da procedure
  --               'pc_busca_parametros_dsctit'  (Leonardo Oliveira - GFT).
  --
  --   14/05/2018 - Adicionada nova procedure para a impressão de proposta (Luis Fernando - GFT)
  --
  --   16/07/2018 - Alteracoes para contemplar o novo sistema de criticas do border (Luis Fernando - GFT)
  --
  --   13/08/2018 - Adicionados mais parametros no calculo de liquidez - Luis Fernando (GFT)
  --
  --   05/09/2018 - Correções na descrição do histórico e % de multa, taxa mensal e mora na pc_gera_extrato_bordero - Andrew Albuquerque (GFT)
  --
  --   14/09/2018 - pc_gera_extrato_bordero: Alterada ordenação do dataset principal de extrato, para imprimir
  --                todos os Débitos e depois os Créditos. - Andrew Albuquerque (GFT)
  --
  --   19/09/2018 - Alterado a procedure pc_busca_titulos_bordero para adicionar retorno da descrição da
  --                situação do titulo dssittit (Paulo Penteado GFT)
  --
  --   12/01/2019 - Alterada ordem de retorno das informacoes do bordero. Campo tipo de documento deve ser o 14 da lista.
  --                Heitor (Mouts) - INC0030658
  -------------------------------------------------------------------------------------------------------------
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  vr_texto_completo  varchar2(32600);

  -- Rotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                          , pr_fecha_xml in boolean default false
                          ) is
  BEGIN
     gene0002.pc_escreve_xml( vr_des_xml
                            , vr_texto_completo
                            , pr_des_dados
                            , pr_fecha_xml );
  END pc_escreve_xml;

FUNCTION fn_letra_risco (pr_innivris IN crapris.innivris%TYPE) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_letra_risco
    Sistema  :
    Sigla    : CRED
    Autor    : Vitor Shimada Assanuma (GFT)
    Data     : 03/08/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Trocar o número do risco para letra
  ---------------------------------------------------------------------------------------------------------------------*/
  BEGIN
     RETURN (
       CASE
         WHEN pr_innivris=2 THEN 'A'
         WHEN pr_innivris=3 THEN 'B'
         WHEN pr_innivris=4 THEN 'C'
         WHEN pr_innivris=5 THEN 'D'
         WHEN pr_innivris=6 THEN 'E'
         WHEN pr_innivris=7 THEN 'F'
         WHEN pr_innivris=8 THEN 'G'
         WHEN pr_innivris=9 THEN 'H'
       END
     );
END fn_letra_risco;


  /* Rotina responsavel por buscar do Flag de Contrato Ativo */
  FUNCTION fn_busca_tbrisco_flag_ativo (pr_cdcooper IN tbrisco_operacoes.cdcooper%TYPE  --> Código da Cooperativa
                                       ,pr_nrdconta IN tbrisco_operacoes.nrdconta%TYPE  --> Conta do associado
                                       ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE  --> Tipo do contrato de rating
                                       ,pr_nrctrato IN tbrisco_operacoes.nrctremp%TYPE) --> Número do contrato do rating
                                                                                        RETURN NUMBER IS

  /* ..........................................................................

     Programa: fn_busca_tbrisco_flag_ativo (crapnrc)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Mario C. Bernat
     Data    : Abril/2019.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao da situação do contrato

  ............................................................................. */

    vr_achou_contrato NUMBER(1);
    vr_dscritic varchar2(4000);

   BEGIN

       vr_achou_contrato := 0;

       --EPR - Emprestimo / Financiamentos
       IF pr_tpctrato = 90 THEN
         BEGIN
           SELECT 1
             INTO vr_achou_contrato
             FROM crapepr t
            WHERE t.cdcooper = pr_cdcooper
              AND t.inliquid = 0   -- Nao pode estar liquidado
              AND t.inprejuz = 0   -- Nao pode estar em prejuizo
              AND t.nrdconta = pr_nrdconta
              AND t.nrctremp = pr_nrctrato;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN NULL;
         END;

       --LIM - Limite de Credito
       -- tpctrato = 1 -> Limite de Credito (tpctrlim = 1)  -- Limite de Crédito
       -- tpctrato = 2 -> Limite de Credito (tpctrlim = 2)  -- Limite de Desconto de Cheque
       -- tpctrato = 3 -> Limite de Credito (tpctrlim = 3)  -- Limite Desconto de Título
       ELSIF pr_tpctrato IN (1,2,3) THEN
         BEGIN
           SELECT 1
             INTO vr_achou_contrato
                 FROM craplim t
                WHERE t.cdcooper = pr_cdcooper
                  AND t.insitlim = 2
                  AND t.nrdconta = pr_nrdconta
                  AND t.nrctrlim = pr_nrctrato
                  AND t.tpctrlim = pr_tpctrato;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN NULL;
         END;

       --BDT - Borderôs de descontos de Títulos
       ELSIF pr_tpctrato = 91 THEN
         BEGIN
           SELECT 1
             INTO vr_achou_contrato
             FROM crapbdt t
            WHERE t.cdcooper = pr_cdcooper
              AND t.insitbdt = 3
              AND t.dtlibbdt IS NOT NULL
              AND t.nrdconta = pr_nrdconta
              AND t.nrborder = pr_nrctrato;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN NULL;
         END;

       --BDC - Borderôs de descontos de Cheques
       ELSIF pr_tpctrato = 92 THEN
         BEGIN
           SELECT 1
             INTO vr_achou_contrato
             FROM  crapdat d
            ,crapbdc t
            WHERE t.cdcooper = pr_cdcooper
              AND t.insitbdc = 3
        AND d.cdcooper = 3
              AND t.dtlibbdc <= d.dtmvtolt
              AND t.nrdconta = pr_nrdconta
              AND t.nrborder = pr_nrctrato;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN NULL;
         END;

       --PRE - Pré-aprovados (nrctremp igual a 0)
       ELSIF pr_tpctrato = 68 THEN
         BEGIN
           SELECT DISTINCT 1
             INTO vr_achou_contrato
             FROM crapcpa t
                 ,tbepr_carga_pre_aprv x
            WHERE t.cdcooper = pr_cdcooper
              AND t.nrdconta = pr_nrdconta
              AND x.cdcooper = t.cdcooper
              AND x.idcarga  = t.iddcarga
              AND x.flgcarga_bloqueada = 0   -- 0-Nao bloqueada
              AND x.indsituacao_carga = 1;   -- 2-Liberada
         EXCEPTION
           WHEN NO_DATA_FOUND THEN NULL;
           WHEN OTHERS THEN NULL;
         END;
       END IF;

       -- Retorna indicador se Titulo está Ativo
       IF vr_achou_contrato = 1 THEN   -- achou
         RETURN (1);
       ELSE
         RETURN (0);
       END IF;

  END fn_busca_tbrisco_flag_Ativo;


  /* Rotina responsavel por buscar a descrição da situacao do contrato */
  FUNCTION fn_busca_descricao_dominio (pr_nmdominio IN VARCHAR2
                                      ,pr_cddominio IN INTEGER) RETURN VARCHAR2 IS
  BEGIN

   /* ..........................................................................

     Programa: fn_busca_descricao_dominio
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Mario C. Bernat
     Data    : Abril/2019.                          Ultima Atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que chamado por outros programas.
     Objetivo  : Buscar a descricao do Dominio

  ............................................................................. */
    DECLARE

      CURSOR cr_tbgen_dominio_campo(pr_cddominio IN tbgen_dominio_campo.cddominio%TYPE) IS
      SELECT tbgen_dominio_campo.dscodigo
        FROM tbgen_dominio_campo
       WHERE nmdominio = pr_nmdominio
         AND cddominio = pr_cddominio;
      rw_tbgen_dominio_campo cr_tbgen_dominio_campo%ROWTYPE;

    BEGIN
      OPEN cr_tbgen_dominio_campo(pr_cddominio => pr_cddominio);

      FETCH cr_tbgen_dominio_campo INTO rw_tbgen_dominio_campo;

      IF cr_tbgen_dominio_campo%NOTFOUND THEN

        --Fechar o cursor
        CLOSE cr_tbgen_dominio_campo;

        RETURN '***';
      ELSE
        --Fechar o cursor
        CLOSE cr_tbgen_dominio_campo;

        RETURN rw_tbgen_dominio_campo.dscodigo;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;

  END fn_busca_descricao_dominio;

-------------------------
  --> Buscar dados do avalista
  PROCEDURE pc_busca_dados_avalista (pr_cdcooper IN crapcop.cdcooper%TYPE           --> Código da Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE           --> Numero da conta do cooperado
                                    ,pr_nrctrato IN crapavt.nrctremp%TYPE DEFAULT 0 --> Numero do contrato para busca de avalistas terceiros
                                    ,pr_tpctrato IN crapavt.tpctrato%TYPE DEFAULT 0 --> Tipo do contrato para busca de avalistas terceiros
                                    ,pr_tpavalis IN INTEGER                         --> Tipo de avalista (1- Avalista cooperado, 2 - Terceiro)
                                     --------> OUT <--------
                                    ,pr_tab_dados_avais IN OUT typ_tab_dados_avais  --> tabela contendo os parametros da cooperativa
                                    ,pr_cdcritic           OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic           OUT VARCHAR2) IS         --> Descrição da crítica
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
    select max nrdconta
    from   craplim
         --> Converter as duas colunas em linha para o for
           unpivot ( max for conta in (nrctaav1, nrctaav2) )
    where  cdcooper    = pr_cdcooper
    and    nrdconta    = pr_nrdconta
    and    nrctrlim    = pr_nrctrlim
    and    tpctrlim    = pr_tpctrato
    and    pr_tpctrato <> 3

    union  all

    select max nrdconta
    from   crawlim
           --> Converter as duas colunas em linha para o for
           unpivot ( max for conta in (nrctaav1, nrctaav2) )
    where  cdcooper    = pr_cdcooper
    and    nrdconta    = pr_nrdconta
    and    nrctrlim    = pr_nrctrlim
    and    tpctrlim    = pr_tpctrato
    and    pr_tpctrato = 3;

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
                                        ,pr_tpcobran IN NUMBER                 --> Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                        ,pr_inpessoa IN crapass.inpessoa%TYPE  --> Tipo de Pessoa:   1 = Física / 2 = Jurídica
                                         --------> OUT <--------
                                        ,pr_tab_dados_dsctit  OUT typ_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                        ,pr_tab_cecred_dsctit OUT typ_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                        ,pr_cdcritic          OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2) IS          --> Descrição da crítica
    ----------------------------------------------------------------------------
    --
    --  Programa : pc_busca_parametros_dsctit           Antigo: b1wgen0030.p/busca_parametros_dsctit
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 01/02/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para efetuar Busca de parametros gerais de desconto de titulo - TAB052
    --
    --   Alteração :
    --    08/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
    --
    --    01/02/2018 - Inclusão de Parâmetro de entrada por Tipo de Pessoa (Física / Jurídica)
    --                (Gustavo Sene - GFT)
    ----------------------------------------------------------------------------

    --------->> VARIAVEIS <<--------
    -- Variáveis de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_cdacesso          craptab.cdacesso%TYPE;
    vr_dstextab          craptab.dstextab%TYPE;
    vr_tab_dstextab      gene0002.typ_split;
    vr_tab_dados_dsctit  typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit typ_tab_cecred_dsctit;

    ---------->> CURSORES <<--------

  BEGIN

    IF pr_inpessoa = 1 THEN -- Pessoa Física
      IF pr_tpcobran = 1 THEN    -- Cobrança Registrada
        vr_cdacesso := 'LIMDESCTITCRPF';
      ELSIF pr_tpcobran = 0 THEN -- Cobrança Sem Registro
        vr_cdacesso := 'LIMDESCTITPF';
    END IF;

    ELSIF pr_inpessoa = 2 THEN -- Pessoa Jurídica
      IF  pr_tpcobran = 1 THEN   -- Cobrança Registrada
        vr_cdacesso := 'LIMDESCTITCRPJ';
      ELSIF pr_tpcobran = 0 THEN -- Cobrança Sem Registro
        vr_cdacesso := 'LIMDESCTITPJ';
      END IF;
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

      ----------- OPERACIONAL ------------
      vr_tab_dados_dsctit(1).vllimite := to_number(vr_tab_dstextab(01),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).vlconsul := to_number(vr_tab_dstextab(02),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).vlmaxsac := to_number(vr_tab_dstextab(03),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).vlminsac := to_number(vr_tab_dstextab(04),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).qtremcrt := vr_tab_dstextab(05);
      vr_tab_dados_dsctit(1).qttitprt := vr_tab_dstextab(06);
      vr_tab_dados_dsctit(1).qtrenova := vr_tab_dstextab(07);
      vr_tab_dados_dsctit(1).qtdiavig := vr_tab_dstextab(08);
      vr_tab_dados_dsctit(1).qtprzmin := vr_tab_dstextab(09);
      vr_tab_dados_dsctit(1).qtprzmax := vr_tab_dstextab(10);
      vr_tab_dados_dsctit(1).qtminfil := vr_tab_dstextab(11);
      vr_tab_dados_dsctit(1).nrmespsq := vr_tab_dstextab(12);

      vr_tab_dados_dsctit(1).pctolera := vr_tab_dstextab(14);
      vr_tab_dados_dsctit(1).pcdmulta := to_number(vr_tab_dstextab(15),'000d000000','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).cardbtit := vr_tab_dstextab(31);
      vr_tab_dados_dsctit(1).cardbtit_c := vr_tab_dstextab(32);
      vr_tab_dados_dsctit(1).pcnaopag := vr_tab_dstextab(33);
      vr_tab_dados_dsctit(1).qtnaopag := vr_tab_dstextab(34);
      vr_tab_dados_dsctit(1).qtprotes := vr_tab_dstextab(35);
      ---- NOVOS CAMPOS - OPERACIONAL ----
      vr_tab_dados_dsctit(1).vlmxassi := to_number(vr_tab_dstextab(39),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).flemipar := vr_tab_dstextab(40);
      vr_tab_dados_dsctit(1).flpjzemi := vr_tab_dstextab(41);
      vr_tab_dados_dsctit(1).flpdctcp := vr_tab_dstextab(42);
      vr_tab_dados_dsctit(1).qttliqcp := vr_tab_dstextab(43);
      vr_tab_dados_dsctit(1).vltliqcp := vr_tab_dstextab(44);
      vr_tab_dados_dsctit(1).qtmintgc := vr_tab_dstextab(45);
      vr_tab_dados_dsctit(1).vlmintgc := vr_tab_dstextab(46);
      vr_tab_dados_dsctit(1).qtmesliq := vr_tab_dstextab(47);
      vr_tab_dados_dsctit(1).vlmxprat := vr_tab_dstextab(48);
      vr_tab_dados_dsctit(1).pcmxctip := vr_tab_dstextab(49);
      vr_tab_dados_dsctit(1).flcocpfp := vr_tab_dstextab(50);
      vr_tab_dados_dsctit(1).qtmxdene := vr_tab_dstextab(51);
      vr_tab_dados_dsctit(1).qtdiexbo := vr_tab_dstextab(52);
      vr_tab_dados_dsctit(1).qtmxtbib := vr_tab_dstextab(53);
      vr_tab_dados_dsctit(1).qtmxtbay := vr_tab_dstextab(54);
      vr_tab_dados_dsctit(1).qtmitdcl := vr_tab_dstextab(71);
      vr_tab_dados_dsctit(1).vlmintcl := to_number(vr_tab_dstextab(72),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_dados_dsctit(1).pctitpag := vr_tab_dstextab(73);
      -------------- CECRED --------------
      vr_tab_cecred_dsctit(1).vllimite := to_number(vr_tab_dstextab(16),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).vlconsul := to_number(vr_tab_dstextab(17),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).vlmaxsac := to_number(vr_tab_dstextab(18),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).vlminsac := to_number(vr_tab_dstextab(19),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).qtremcrt := vr_tab_dstextab(20);
      vr_tab_cecred_dsctit(1).qttitprt := vr_tab_dstextab(21);
      vr_tab_cecred_dsctit(1).qtrenova := vr_tab_dstextab(22);
      vr_tab_cecred_dsctit(1).qtdiavig := vr_tab_dstextab(23);
      vr_tab_cecred_dsctit(1).qtprzmin := vr_tab_dstextab(24);
      vr_tab_cecred_dsctit(1).qtprzmax := vr_tab_dstextab(25);
      vr_tab_cecred_dsctit(1).qtminfil := vr_tab_dstextab(26);
      vr_tab_cecred_dsctit(1).nrmespsq := vr_tab_dstextab(27);

      vr_tab_cecred_dsctit(1).pctolera := vr_tab_dstextab(29);
      vr_tab_cecred_dsctit(1).pcdmulta := to_number(vr_tab_dstextab(30),'000d000000','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).cardbtit := vr_tab_dstextab(32);
      vr_tab_cecred_dsctit(1).pcnaopag := vr_tab_dstextab(36);
      vr_tab_cecred_dsctit(1).qtnaopag := vr_tab_dstextab(37);
      vr_tab_cecred_dsctit(1).qtprotes := vr_tab_dstextab(38);
      ------ NOVOS CAMPOS - CECRED -------
      vr_tab_cecred_dsctit(1).vlmxassi := to_number(vr_tab_dstextab(55),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).flemipar := vr_tab_dstextab(56);
      vr_tab_cecred_dsctit(1).flpjzemi := vr_tab_dstextab(57);
      vr_tab_cecred_dsctit(1).flpdctcp := vr_tab_dstextab(58);
      vr_tab_cecred_dsctit(1).qttliqcp := vr_tab_dstextab(59);
      vr_tab_cecred_dsctit(1).vltliqcp := vr_tab_dstextab(60);
      vr_tab_cecred_dsctit(1).qtmintgc := vr_tab_dstextab(61);
      vr_tab_cecred_dsctit(1).vlmintgc := vr_tab_dstextab(62);
      vr_tab_cecred_dsctit(1).qtmesliq := vr_tab_dstextab(63);
      vr_tab_cecred_dsctit(1).vlmxprat := vr_tab_dstextab(64);
      vr_tab_cecred_dsctit(1).pcmxctip := vr_tab_dstextab(65);
      vr_tab_cecred_dsctit(1).flcocpfp := vr_tab_dstextab(66);
      vr_tab_cecred_dsctit(1).qtmxdene := vr_tab_dstextab(67);
      vr_tab_cecred_dsctit(1).qtdiexbo := vr_tab_dstextab(68);
      vr_tab_cecred_dsctit(1).qtmxtbib := vr_tab_dstextab(69);
      vr_tab_cecred_dsctit(1).qtmxtbay := vr_tab_dstextab(70);
      vr_tab_cecred_dsctit(1).qtmitdcl := vr_tab_dstextab(74);
      vr_tab_cecred_dsctit(1).vlmintcl := to_number(vr_tab_dstextab(75),'999999990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_cecred_dsctit(1).pctitpag := vr_tab_dstextab(76);
      ------------------------------------

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
                                   ,pr_tpctrprp IN VARCHAR2 DEFAULT 'C'   --> Tipo de informação ('C' = Contrato / 'P' = Proposta)
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
    select * from (
    select lim.nrdconta
          ,lim.vllimite
          ,lim.cddlinha
          ,lim.nrctrlim
          ,lim.dtrenova
          ,lim.dtinivig
          ,lim.qtdiavig
          ,lim.dtfimvig
          ,lim.dsencfin##1
          ,lim.dsencfin##2
          ,lim.dsencfin##3
          ,lim.nrgarope
          ,lim.nrinfcad
          ,lim.nrliquid
          ,lim.nrpatlvr
          ,lim.vltotsfn
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,lim.insitlim
          ,lim.dtcancel
          ,lim.flgdigit
          ,lim.nrperger
      ,lim.idcobope
            ,'C' as tpctrprp
    from   craplim lim
    where  lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim


    union  all

    select lim.nrdconta
          ,lim.vllimite
          ,lim.cddlinha
          ,lim.nrctrlim
          ,lim.dtrenova
          ,lim.dtinivig
          ,lim.qtdiavig
          ,lim.dtfimvig
          ,lim.dsencfin##1
          ,lim.dsencfin##2
          ,lim.dsencfin##3
          ,lim.nrgarope
          ,lim.nrinfcad
          ,lim.nrliquid
          ,lim.nrpatlvr
          ,lim.vltotsfn
          ,lim.nrctaav1
          ,lim.nrctaav2
          ,lim.insitlim
          ,lim.dtcancel
          ,lim.flgdigit
          ,lim.nrperger
      ,lim.idcobope
            ,'P' as tpctrprp
    from   crawlim lim
    where  lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim
      and    pr_tpctrlim  = 3) aux
    where aux.tpctrprp = pr_tpctrprp;
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
                                  ,pr_tpcobran => 1             --> Tipo de cobrança(1-Sim 0-nao)
                                  ,pr_inpessoa => pr_inpessoa   --> Indicador de tipo de pessoa
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
                                       ,pr_tpctrprp IN VARCHAR2               --> Tipo de informação ('C' = Contrato / 'P' = Proposta)
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
                           ,pr_tpctrprp => pr_tpctrprp  --> Tipo de informação
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
    --               03/08/2018 - Inserção dos campos de Risco (Vitor Shimada Assanuma - GFT)
    --               24/08/2018 - Inserção dos campo de Prejuizo (Vitor Shimada Assanuma - GFT)
    -- .........................................................................*/

    ---------->>> CURSORES <<<----------
    --> Buscar bordero de desconto de titulo
    CURSOR cr_crapbdt (pr_dtmvtoan crapdat.dtmvtoan%TYPE)IS
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
             bdt.cdopcoan,
             DSCT0003.fn_retorna_rating(bdt.nrinrisc) AS dsinrisc,
             bdt.qtdirisc,
             bdt.inprejuz,
             bdt.dtliqprj,
             bdt.flverbor,
             (SELECT COUNT(1)
                FROM craptdb tdb
               WHERE tdb.cdcooper = bdt.cdcooper
                 AND tdb.nrdconta = bdt.nrdconta
                 AND tdb.nrborder = bdt.nrborder
                 AND tdb.insitapr <> 2) AS qttitulo,
             (SELECT SUM(vltitulo)
                FROM craptdb tdb
               WHERE tdb.cdcooper = bdt.cdcooper
                 AND tdb.nrdconta = bdt.nrdconta
                 AND tdb.nrborder = bdt.nrborder
                 AND tdb.insitapr <> 2) AS vltitulo
        FROM crapbdt bdt
        LEFT JOIN crapris ris
          ON ris.cdcooper = bdt.cdcooper
         AND ris.nrdconta = bdt.nrdconta
         AND bdt.nrborder = ris.nrctremp
         AND ris.cdmodali = 301
         AND ris.dtrefere = pr_dtmvtoan
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

    -- variaveis de data
    vr_dtmvtoan crapdat.dtmvtoan%TYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  BEGIN
    --Selecionar dados da data
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se encontrar
    IF BTCH0001.cr_crapdat%FOUND THEN
      vr_dtmvtoan:= rw_crapdat.dtmvtoan;
    END IF;
    -- Apenas fechar o cursor
    CLOSE BTCH0001.cr_crapdat;

    --> Buscar bordero de desconto de titulo
    OPEN cr_crapbdt (pr_dtmvtoan => vr_dtmvtoan);
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
    pr_tab_dados_border(vr_idxborde).qttitulo := rw_crapbdt.qttitulo;
    pr_tab_dados_border(vr_idxborde).vltitulo := rw_crapbdt.vltitulo;
    pr_tab_dados_border(vr_idxborde).dspesqui := to_char(rw_crapbdt.dtmvtolt,'DD/MM/RRRR')   ||'-'||
                                                 to_char(rw_crapbdt.cdagenci,'fm000')        ||'-'||
                                                 to_char(rw_crapbdt.cdbccxlt,'fm000')        ||'-'||
                                                 to_char(rw_crapbdt.nrdolote,'fm000000')     ||'-'||
                                                 to_char(to_date(rw_crapbdt.hrtransa,'SSSSS'),'HH:MM:SS');
    pr_tab_dados_border(vr_idxborde).dsdlinha := to_char(rw_crapbdt.cddlinha,'fm000') ||'-'|| rw_crapldc.dsdlinha;
    pr_tab_dados_border(vr_idxborde).flgdigit := rw_crapbdt.flgdigit;
    pr_tab_dados_border(vr_idxborde).cdtipdoc := vr_cdtipdoc;
    pr_tab_dados_border(vr_idxborde).innivris := rw_crapbdt.dsinrisc;
    pr_tab_dados_border(vr_idxborde).qtdiaatr := NVL(rw_crapbdt.qtdirisc, 0);
    pr_tab_dados_border(vr_idxborde).inprejuz := rw_crapbdt.inprejuz;
    pr_tab_dados_border(vr_idxborde).dtliqprj := rw_crapbdt.dtliqprj;
    pr_tab_dados_border(vr_idxborde).flverbor := rw_crapbdt.flverbor;

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

  PROCEDURE pc_busca_dados_bordero_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                   ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                   ,pr_cddopcao IN VARCHAR2               --> Cod opcao
                                   ,pr_xmllog    IN VARCHAR2               --> XML com informacoes de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                   ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                   ,pr_retxml IN OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  /* .........................................................................
    --
    --  Programa : pc_busca_dados_bordero_web
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Vitor Shimada Assanuma (GFT)
    --  Data     : Agosto/2018.                   Ultima atualizacao: 03/08/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados de um determinado bordero
    --
    --   Alteração :
    -- .........................................................................*/
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_erro  EXCEPTION;

    -- variaveis de retorno
    vr_tab_dados_border typ_tab_dados_border;
    vr_index    INTEGER;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variaveis de data
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      --Selecionar dados da data
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se encontrar
      IF BTCH0001.cr_crapdat%FOUND THEN
        vr_dtmvtolt:= rw_crapdat.dtmvtolt;
      END IF;
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;

      pc_busca_dados_bordero (pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_idorigem => vr_idorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrborder => pr_nrborder
                             ,pr_cddopcao => pr_cddopcao
                             --------> OUT <--------
                             ,pr_tab_dados_border => vr_tab_dados_border --> retorna dados do bordero
                             ,pr_cdcritic => vr_cdcritic           --> Código da crítica
                             ,pr_dscritic => vr_dscritic);          --> Descrição da crítica

      IF vr_cdcritic > 0 AND TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      -- Inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      -- inicilizar as informaçoes do xml
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                             '<root><dados>');

       -- Ler os registros de titulos e incluir no xml
       vr_index := vr_tab_dados_border.first;

       -- Leitura dos registros
       WHILE vr_index IS NOT NULL LOOP
         pc_escreve_xml('<inf>'||
                            '<nrborder>' || vr_tab_dados_border(vr_index).nrborder || '</nrborder>' ||
                            '<nrctrlim>' || vr_tab_dados_border(vr_index).nrctrlim || '</nrctrlim>' ||
                            '<insitbdt>' || vr_tab_dados_border(vr_index).insitbdt || '</insitbdt>' ||
                            '<txmensal>' || vr_tab_dados_border(vr_index).txmensal || '</txmensal>' ||
                            '<txjurmor>' || vr_tab_dados_border(vr_index).txjurmor || '</txjurmor>' ||
                            '<dtlibbdt>' || to_char(vr_tab_dados_border(vr_index).dtlibbdt,'DD/MM/RRRR') || '</dtlibbdt>' ||
                            '<txdiaria>' || vr_tab_dados_border(vr_index).txdiaria || '</txdiaria>' ||
                            '<qttitulo>' || vr_tab_dados_border(vr_index).qttitulo || '</qttitulo>' ||
                            '<vltitulo>' || vr_tab_dados_border(vr_index).vltitulo || '</vltitulo>' ||
                            '<dspesqui>' || vr_tab_dados_border(vr_index).dspesqui || '</dspesqui>' ||
                            '<dsdlinha>' || vr_tab_dados_border(vr_index).dsdlinha || '</dsdlinha>' ||
                            '<dsopelib>' || vr_tab_dados_border(vr_index).dsopelib || '</dsopelib>' ||
                            '<dsopedig>' || vr_tab_dados_border(vr_index).dsopedig || '</dsopedig>' ||
                            '<flgdigit>' || vr_tab_dados_border(vr_index).flgdigit || '</flgdigit>' ||
                            '<cdtipdoc>' || vr_tab_dados_border(vr_index).cdtipdoc || '</cdtipdoc>' ||
                            '<dsopecoo>' || vr_tab_dados_border(vr_index).dsopecoo || '</dsopecoo>' ||
                            '<innivris>' || vr_tab_dados_border(vr_index).innivris || '</innivris>' ||
                            '<qtdiaatr>' || vr_tab_dados_border(vr_index).qtdiaatr || '</qtdiaatr>' ||
                            '<inprejuz>' || vr_tab_dados_border(vr_index).inprejuz || '</inprejuz>' ||
                            '<dtliqprj>' || vr_tab_dados_border(vr_index).dtliqprj || '</dtliqprj>' ||
                        '</inf>'
                      );
         vr_index := vr_tab_dados_border.next(vr_index);
       END LOOP;
       pc_escreve_xml ('</dados></root>',true);
       pr_retxml := xmltype.createxml(vr_des_xml);

       /* liberando a memória alocada pro clob */
       dbms_lob.close(vr_des_xml);
       dbms_lob.freetemporary(vr_des_xml);
  EXCEPTION
    WHEN vr_exc_erro THEN
       IF  vr_cdcritic <> 0 THEN
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;

  WHEN OTHERS THEN
       pr_dscritic := 'Erro geral na rotina dsct0002.pc_busca_dados_bordero_web: '||SQLERRM;

  END pc_busca_dados_bordero_web;



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
    --
    --               19/09/2018 - Adicionado retorno da descrição da situação do titulo dssittit (Paulo Penteado GFT)
    --
    --               05/11/2018 - Adicionado retorno de valor prejuízo vlsdprej e inprejuz (Lucas Negoseki GFT)
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
             tdb.dtdpagto,
             tdb.vltitulo,
             tdb.vlliquid,
             tdb.vlsldtit + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra) + (tdb.vliofcpl - tdb.vlpagiof) as vlsldtit,
             bdt.inprejuz,
             tdb.vlsdprej
               + (tdb.vlttjmpr - tdb.vlpgjmpr)
               + (tdb.vlttmupr - tdb.vlpgmupr)
               + (tdb.vljraprj - tdb.vlpgjrpr)
               + (tdb.vliofprj - tdb.vliofppr) AS vlsdprej,
             sab.nmdsacad,
             tdb.insittit,
             tdb.insitapr,
             cob.nrnosnum,
             ttc.nrctrdsc,
             CASE WHEN tdb.insittit = 2 AND tdb.dtdpagto > gene0005.fn_valida_dia_util(tdb.cdcooper, tdb.dtvencto) THEN
                       'Pago após vencimento'
                  ELSE dsct0003.fn_busca_situacao_titulo(tdb.insittit, 1)
              END dssittit
        FROM craptdb tdb
            ,crapcob cob
            ,crapcco cco
            ,crapsab sab
            ,tbdsct_titulo_cyber ttc
            ,crapbdt bdt
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
         AND sab.nrinssac(+) = tdb.nrinssac
         --> Busca Contrato Cyber
         AND ttc.cdcooper(+) = tdb.cdcooper
         AND ttc.nrborder(+) = tdb.nrborder
         AND ttc.nrdconta(+) = tdb.nrdconta
         AND ttc.nrtitulo(+) = tdb.nrtitulo
         --> Buscar bordero
         AND bdt.cdcooper = tdb.cdcooper
         AND bdt.nrborder = tdb.nrborder;


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
      pr_tab_tit_bordero(vr_idxtitul).dtdpagto := rw_craptdb.dtdpagto;
      pr_tab_tit_bordero(vr_idxtitul).nossonum := vr_nossonum;
      pr_tab_tit_bordero(vr_idxtitul).vltitulo := rw_craptdb.vltitulo;
      pr_tab_tit_bordero(vr_idxtitul).vlliquid := rw_craptdb.vlliquid;
      pr_tab_tit_bordero(vr_idxtitul).vlsldtit := rw_craptdb.vlsldtit;
      pr_tab_tit_bordero(vr_idxtitul).inprejuz := rw_craptdb.inprejuz;
      pr_tab_tit_bordero(vr_idxtitul).vlsdprej := rw_craptdb.vlsdprej;
      pr_tab_tit_bordero(vr_idxtitul).nmsacado := rw_craptdb.nmdsacad;
      pr_tab_tit_bordero(vr_idxtitul).insittit := rw_craptdb.insittit;
      pr_tab_tit_bordero(vr_idxtitul).insitapr := rw_craptdb.insitapr;
      pr_tab_tit_bordero(vr_idxtitul).flgregis := rw_craptdb.flgregis;
      pr_tab_tit_bordero(vr_idxtitul).nrctrdsc := rw_craptdb.nrctrdsc;
      pr_tab_tit_bordero(vr_idxtitul).dssittit := rw_craptdb.dssittit;

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

    --> Verificar versão do bordero
    CURSOR cr_crapbdt (pr_cdcooper crapbdt.cdcooper%TYPE,
                       pr_nrborder crapbdt.nrborder%TYPE) IS
      SELECT flverbor
      FROM crapbdt
      WHERE cdcooper = pr_cdcooper
        AND nrborder = pr_nrborder;
    rw_crapbdt cr_crapbdt%ROWTYPE;

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
    -- Buscar o bordero para pegar a versão dele
    OPEN cr_crapbdt(pr_cdcooper, pr_nrborder);
    FETCH cr_crapbdt INTO rw_crapbdt;
    CLOSE cr_crapbdt;

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
    pr_tab_dados_tits_bordero(vr_idxtitbo).flverbor := rw_crapbdt.flverbor;

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

  PROCEDURE pc_carrega_dados_proposta (pr_cdcooper IN crapcop.cdcooper%TYPE
                                       ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                       ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                       ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do proximo movimento
                                       ,pr_inproces IN crapdat.inproces%TYPE  --> Indicador do processo
                                       ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                       ,pr_nmempres IN VARCHAR2
                                       ,pr_telefone IN VARCHAR2
                                       ,pr_vlsalari IN crapprp.vlsalari%TYPE
                                       ,pr_vlsalcon IN crapprp.vlsalcon%TYPE
                                       ,pr_vloutras IN crapprp.vloutras%TYPE
                                       ,pr_dsdeben1 IN VARCHAR2
                                       ,pr_dsdeben2 IN VARCHAR2
                                       ,pr_vlfatura IN NUMBER
                                       ,pr_vlmedtit IN NUMBER
                                       ,pr_vllimite IN NUMBER
                                       ,pr_dsobserv IN VARCHAR2
                                       ,pr_dsramati IN crapprp.dsramati%TYPE
                                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE
                                       ,pr_nmoperad IN crapope.nmoperad%TYPE  --> Nome do operador
                                       ,pr_nmcidade IN crapcop.nmcidade%TYPE  --> Nome da cidade
                                       ,pr_nmextcop IN VARCHAR2
                                       ,pr_tab_dados_proposta OUT typ_tab_dados_proposta
                                       ,pr_tab_emprestimos    OUT EMPR0001.typ_tab_dados_epr
                                       ,pr_tab_grupo          OUT GECO0001.typ_tab_crapgrp
                                       ,pr_tab_rating_hist    OUT typ_tab_rating_hist
                                      ) IS
 /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_carrega_dados_proposta
    Sistema  : Cred
    Sigla    :
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para carregar os dados da proposta
  ---------------------------------------------------------------------------------------------------------------------*/

    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    vr_des_reto        VARCHAR2(1000);        --> Desc. Erro
    vr_tab_erro        gene0001.typ_tab_erro;
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    vr_vlsmdtri        NUMBER;
    vr_tab_comp_medias EXTR0001.typ_tab_comp_medias;
    vr_tab_medias      EXTR0001.typ_tab_medias;
    vr_idxcmpmd        PLS_INTEGER;
    vr_tab_cartoes     CADA0004.typ_tab_cartoes;
    vr_tab_cabec       CADA0004.typ_tab_cabec;
    vr_idxdcabec       PLS_INTEGER;
    vr_flgativo        INTEGER  := 0;
    vr_nrctrhcj        NUMBER   := 0;
    vr_flgliber        INTEGER  := 0;
    vr_vltotccr        NUMBER   := 0;
    vr_rel_vlaplica    NUMBER;
    vr_vlsldapl        NUMBER;
    vr_tab_saldo_rdca  APLI0001.typ_tab_saldo_rdca;
    vr_vlsldrgt        NUMBER;
    vr_vlsldtot        NUMBER;
    vr_vlsdrdpp        NUMBER;
    vr_tab_conta_bloq  APLI0001.typ_tab_ctablq;
    vr_tab_craplpp     APLI0001.typ_tab_craplpp;
    vr_tab_craplrg     APLI0001.typ_tab_craplpp;
    vr_tab_resgate     APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp   APLI0001.typ_tab_dados_rpp;
    vr_percenir        NUMBER;
    vr_tab_dados_epr   EMPR0001.typ_tab_dados_epr;
    vr_qtregist        INTEGER;
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab            craptab.dstextab%TYPE;
    vr_inusatab            BOOLEAN;
    vr_vlutiliz            NUMBER;
    vr_ddmvtolt            VARCHAR(100);
    vr_msmvtolt            VARCHAR(100);
    vr_aamvtolt            VARCHAR(100);
    vr_dsemsnot            VARCHAR(100);
    vr_flggrupo            INTEGER;
    vr_nrdgrupo            crapgrp.nrdgrupo%TYPE;
    vr_gergrupo            VARCHAR2(100);
    vr_dsdrisgp            crapgrp.dsdrisgp%TYPE;
    vr_vlendivi            NUMBER;
    vr_idxrating           PLS_INTEGER;
    vr_dsdrisco            crapgrp.dsdrisgp%TYPE;
    vr_tab_grupo           GECO0001.typ_tab_crapgrp;
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;


    vr_index_sado_rdca PLS_INTEGER;
    vr_tst_rdca        NUMBER;

    /*Historico dos registros de rating*/
    CURSOR cr_rating_hist IS
      SELECT
        RATI0001.fn_busca_descricao_operacao(tpctrrat) AS dsdopera,
        nrctrrat,
        indrisco,
        nrnotrat,
        rati0001.fn_valor_operacao(crapnrc.cdcooper
                                    ,crapnrc.nrdconta
                                    ,crapnrc.tpctrrat
                                    ,crapnrc.nrctrrat) AS vloperac,
        RATI0001.fn_busca_descricao_situacao(insitrat) AS dsditrat
      FROM
        crapnrc
      WHERE
        crapnrc.cdcooper = pr_cdcooper
        AND crapnrc.cdcooper = 3
        AND crapnrc.nrdconta = pr_nrdconta
        AND crapnrc.flgativo = 1
        --AND (crapnrc.insitrat = 2 OR (crapnrc.tpctrrat = 3 AND crapnrc.nrctrrat = pr_nrctrlim))
      UNION
      SELECT
        RATI0001.fn_busca_descricao_operacao(tpctrato) AS dsdopera,
        nrctremp         nrctrrat,
        cecred.risc0004.fn_traduz_risco(inrisco_rating)   indrisco,
        inpontos_rating  nrnotrat,
        rati0001.fn_valor_operacao(tbrisco_operacoes.cdcooper
                                  ,tbrisco_operacoes.nrdconta
                                  ,tbrisco_operacoes.tpctrato
                                  ,tbrisco_operacoes.nrctremp) AS vloperac,
        dsct0002.fn_busca_descricao_dominio('INSITUACAO_RATING'
                                  ,tbrisco_operacoes.Insituacao_Rating) AS dsditrat
      FROM
        tbrisco_operacoes
      WHERE
            tbrisco_operacoes.cdcooper = pr_cdcooper
        AND tbrisco_operacoes.cdcooper <> 3
        AND tbrisco_operacoes.nrdconta = pr_nrdconta
        AND dsct0002.fn_busca_tbrisco_flag_ativo
                             (pr_cdcooper => tbrisco_operacoes.cdcooper   --> Código da Cooperativa
                             ,pr_nrdconta => tbrisco_operacoes.nrdconta   --> Conta do associado
                             ,pr_tpctrato => tbrisco_operacoes.tpctrato   --> Tipo do contrato de rating
                             ,pr_nrctrato => tbrisco_operacoes.nrctremp) = 1 --> Número do contrato do rating
        --AND (crapnrc.insitrat = 2 OR (crapnrc.tpctrrat = 3 AND crapnrc.nrctrrat = pr_nrctrlim))
      ;
    rw_rating_hist cr_rating_hist%ROWTYPE;
    /*Pega o rating ativo (menor nota com maior valor)*/
    CURSOR cr_rating_ativo IS
      SELECT
        RATI0001.fn_busca_descricao_operacao(tpctrrat) AS dsdopera,
        nrctrrat,
        indrisco,
        nrnotrat,
        nrnotatl,
        rati0001.fn_valor_operacao(crapnrc.cdcooper
                                    ,crapnrc.nrdconta
                                    ,crapnrc.tpctrrat
                                    ,crapnrc.nrctrrat) AS vloperac
       FROM crapnrc
      WHERE crapnrc.nrctrrat = pr_nrctrlim
        AND crapnrc.cdcooper = pr_cdcooper
        AND crapnrc.nrdconta = pr_nrdconta
        AND crapnrc.cdcooper = 3
        AND crapnrc.flgativo = 1
        AND crapnrc.insitrat = 1
        AND (rati0001.fn_valor_operacao(crapnrc.cdcooper
                                    ,crapnrc.nrdconta
                                    ,crapnrc.tpctrrat
                                    ,crapnrc.nrctrrat),crapnrc.nrnotrat,crapnrc.cdcooper,crapnrc.nrdconta,crapnrc.tpctrrat,crapnrc.nrctrrat) IN (
                                        SELECT
                                          max(rati0001.fn_valor_operacao(nrc.cdcooper
                                                                ,nrc.nrdconta
                                                                ,nrc.tpctrrat
                                                                ,nrc.nrctrrat)) AS maior,
                                          nrc.nrnotrat,
                                          nrc.cdcooper,
                                          nrc.nrdconta,
                                          nrc.tpctrrat,
                                          nrc.nrctrrat
                                        FROM
                                          crapnrc nrc
                                        WHERE
                                          nrc.cdcooper = crapnrc.cdcooper
                                          AND nrc.flgativo = 1
                                          AND nrc.insitrat=1
                                          AND nrc.nrdconta = crapnrc.nrdconta
                                          AND nrc.nrnotrat = (SELECT MIN(crapnrc.nrnotrat) FROM crapnrc n WHERE   nrc.cdcooper = n.cdcooper
                                                                AND n.flgativo = nrc.flgativo
                                                                AND n.insitrat = nrc.insitrat
                                                                AND n.nrdconta = nrc.nrdconta)
                                        GROUP BY
                                          nrc.nrnotrat,
                                          nrc.cdcooper,
                                          nrc.nrdconta,
                                          nrc.tpctrrat,
                                          nrc.nrctrrat)
      UNION
      SELECT
        RATI0001.fn_busca_descricao_operacao(tpctrato) AS dsdopera,
        nrctremp          nrctrrat,
        cecred.risc0004.fn_traduz_risco(inrisco_rating) indrisco,
        inpontos_rating   nrnotrat,
        INPONTOS_RATING    nrnotatl,
        rati0001.fn_valor_operacao(tbrisco_operacoes.cdcooper
                                  ,tbrisco_operacoes.nrdconta
                                  ,tbrisco_operacoes.tpctrato
                                  ,tbrisco_operacoes.nrctremp) AS vloperac
       FROM tbrisco_operacoes
      WHERE tbrisco_operacoes.nrctremp = pr_nrctrlim
        AND tbrisco_operacoes.cdcooper = pr_cdcooper
        AND tbrisco_operacoes.nrdconta = pr_nrdconta
        AND tbrisco_operacoes.cdcooper <> 3
        AND dsct0002.fn_busca_tbrisco_flag_Ativo (tbrisco_operacoes.cdcooper
                                                 ,tbrisco_operacoes.nrdconta
                                                 ,tbrisco_operacoes.tpctrato
                                                 ,tbrisco_operacoes.nrctremp) = 1  --crapnrc.flgativo = 1
        AND tbrisco_operacoes.insituacao_rating = 2  --crapnrc.insitrat = 1
        AND (rati0001.fn_valor_operacao(tbrisco_operacoes.cdcooper
                                          ,tbrisco_operacoes.nrdconta
                                          ,tbrisco_operacoes.tpctrato
                                          ,tbrisco_operacoes.nrctremp)
                                       ,tbrisco_operacoes.inpontos_rating
                                       ,tbrisco_operacoes.cdcooper
                                       ,tbrisco_operacoes.nrdconta
                                       ,tbrisco_operacoes.tpctrato
                                       ,tbrisco_operacoes.nrctremp)
                                    IN (
                                        SELECT
                                          max(rati0001.fn_valor_operacao(nrc.cdcooper
                                                                ,nrc.nrdconta
                                                                        ,nrc.tpctrato
                                                                        ,nrc.nrctremp)) AS maior,
                                          nrc.inpontos_rating nrnotrat,
                                          nrc.cdcooper,
                                          nrc.nrdconta,
                                          nrc.tpctrato,
                                          nrc.nrctremp
                                        FROM
                                          tbrisco_operacoes nrc
                                        WHERE
                                              nrc.cdcooper = tbrisco_operacoes.cdcooper
                                          AND dsct0002.fn_busca_tbrisco_flag_Ativo (nrc.cdcooper
                                                                                   ,nrc.nrdconta
                                                                                   ,nrc.tpctrato
                                                                                   ,nrc.nrctremp) = 1 --nrc.flgativo = 1
                                          AND nrc.insituacao_rating = 2  --nrc.insitrat = 1
                                          AND nrc.nrdconta = tbrisco_operacoes.nrdconta
                                          AND nrc.inpontos_rating = (SELECT MIN(tbrisco_operacoes.inpontos_rating)
                                                                FROM tbrisco_operacoes n
                                                               WHERE nrc.cdcooper = n.cdcooper
                                                                 --AND n.flgativo = nrc.flgativo
                                                                 and n.insituacao_rating = nrc.insituacao_rating
                                                                 AND n.insituacao_rating = nrc.insituacao_rating
                                                                AND n.nrdconta = nrc.nrdconta)
                                        GROUP BY
                                          nrc.inpontos_rating,
                                          nrc.cdcooper,
                                          nrc.nrdconta,
                                          nrc.tpctrato,
                                          nrc.nrctremp)
      ;
    rw_rating_ativo cr_rating_ativo%ROWTYPE;


    -- Buscar Saldo de Cotas
    CURSOR cr_crapcot IS
        SELECT vldcotas
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;


    CURSOR cr_crappla IS
         SELECT
          crappla.vlprepla
         FROM crappla
         WHERE crappla.cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND crappla.tpdplano = 1
         AND crappla.cdsitpla = 1;
    vr_vlprepla crappla.vlprepla%TYPE;

    -- Cursor para pegar todos os parametros de cobrança
    CURSOR cr_crapcco IS
         SELECT cdcooper, nrconven, flgregis
         FROM crapcco
         WHERE cdcooper = pr_cdcooper
         AND dsorgarq <> 'PROTESTO'
    ;rw_crapcco cr_crapcco%ROWTYPE;

    -- Cursor de Cadastro de Emissao de Boletos de Cobranca
    CURSOR cr_crapceb(vr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_nrconven IN crapcco.nrconven%TYPE) IS
           SELECT * FROM crapceb
           WHERE cdcooper = vr_cdcooper
             AND nrconven = pr_nrconven
             AND nrdconta = pr_nrdconta
    ;rw_crapceb cr_crapceb%ROWTYPE;

    -- Resultado
    par_tpcobran VARCHAR2(1);
    rel_tpcobran VARCHAR2(100);

    --PL tables para calculo de rating
    vr_flgcriar             INTEGER;
    vr_tab_rating_sing      RATI0001.typ_tab_crapras;
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;

    BEGIN
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

      /*Obtem saldo das aplicacoes*/
      APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper       => pr_cdcooper --> Codigo Cooperativa
                                       ,pr_cdagenci       => pr_cdagenci --> Codigo Agencia
                                       ,pr_nrdcaixa       => pr_nrdcaixa --> Numero do Caixa
                                       ,pr_cdoperad       => pr_cdoperad --> Codigo do Operador
                                       ,pr_nmdatela       => pr_nmdatela --> Nome da Tela
                                       ,pr_idorigem       => pr_idorigem --> Origem
                                       ,pr_nrdconta       => pr_nrdconta --> Número da Conta
                                       ,pr_idseqttl       => pr_idseqttl --> Sequencia do Titular
                                       ,pr_nraplica       => 0           --> Número da Aplicação
                                       ,pr_cdprogra       => pr_nmdatela --> Codigo do Programa
                                       ,pr_flgerlog       => 0           --> Gerar Log (0-False / 1-True)
                                       ,pr_dtiniper       => NULL        --> Data de Inicio
                                       ,pr_dtfimper       => NULL        --> Data de Termino
                                       ,pr_vlsldapl       => vr_vlsldapl   --> Valor do saldo aplicado
                                       ,pr_tab_saldo_rdca => vr_tab_saldo_rdca --> Tabela de Saldo do RDCA
                                       ,pr_des_reto       => vr_des_reto       --> Retorno OK ou NOK
                                       ,pr_tab_erro       => vr_tab_erro);     --> Tabela de Erros


      -- loop sobre a tabela de saldo
      vr_index_sado_rdca := vr_tab_saldo_rdca.first;
      WHILE vr_index_sado_rdca IS NOT NULL LOOP
        -- Somar o valor de resgate
        vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_index_sado_rdca).sldresga;

        vr_index_sado_rdca := vr_tab_saldo_rdca.next(vr_index_sado_rdca);
      END LOOP;


      vr_rel_vlaplica := nvl(vr_rel_vlaplica,0) + nvl(vr_vlsldapl,0);

      --> Buscar saldo das aplicacoes
      APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela   --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                      ,pr_nrdconta => pr_nrdconta   --> Número da Conta
                                      ,pr_idseqttl => pr_idseqttl   --> Titular da Conta
                                      ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Data de Movimento
                                      ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
                                      ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
                                      ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
                                      ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
                                      ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
                                      ,pr_dscritic => vr_dscritic); --> Descrição da crítica

      vr_rel_vlaplica := nvl(vr_rel_vlaplica,0) + nvl(vr_vlsldrgt,0);

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

       vr_rel_vlaplica := nvl(vr_rel_vlaplica,0) + nvl(vr_vlsdrdpp,0);

      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;

        -- Limpar tabela de erros
        vr_tab_erro.DELETE;

        RAISE vr_exc_erro;
      END IF;

      -- Pesquisa o tipo de cobrança (Migracao da b1wgen0030.busca_tipos_cobranca)
      OPEN cr_crapcco();
      LOOP
         FETCH cr_crapcco INTO rw_crapcco;
         EXIT WHEN cr_crapcco%NOTFOUND;
         OPEN cr_crapceb(vr_cdcooper => rw_crapcco.cdcooper
                        ,pr_nrconven => rw_crapcco.nrconven);
         LOOP
            FETCH cr_crapceb INTO rw_crapceb;
            EXIT WHEN cr_crapceb%NOTFOUND;
              IF par_tpcobran = 'R' AND  rw_crapcco.flgregis = 0 THEN
               par_tpcobran := 'T';
               rel_tpcobran := 'REGISTRADA E SEM REGISTRO';
               EXIT;
            END IF;

            IF par_tpcobran = 'S' AND rw_crapcco.flgregis = 1 THEN
               par_tpcobran := 'T';
               rel_tpcobran := 'REGISTRADA E SEM REGISTRO';
               EXIT;
            END IF;

            IF rw_crapcco.flgregis = 1 THEN
               par_tpcobran := 'R';
               rel_tpcobran :=  'REGISTRADA';
            ELSE
               par_tpcobran := 'S';
               rel_tpcobran :=  'SEM REGISTRO';
            END IF;
         END LOOP;
         CLOSE cr_crapceb;
      END LOOP;
      CLOSE cr_crapcco;

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


      -- Buscar Saldo de Cotas
      OPEN cr_crapcot;
      FETCH cr_crapcot
        INTO vr_vldcotas;
      CLOSE cr_crapcot;


      -- Plano
      OPEN cr_crappla;
      FETCH cr_crappla
            INTO vr_vlprepla;
      CLOSE cr_crappla;

      vr_idxdcabec := vr_tab_cabec.first;
      pr_tab_dados_proposta(0).nrdconta := pr_nrdconta; --> add
      pr_tab_dados_proposta(0).nrctrlim := pr_nrctrlim; --> add
      pr_tab_dados_proposta(0).nmempres := pr_nmempres;
      pr_tab_dados_proposta(0).telefone := pr_telefone;
      pr_tab_dados_proposta(0).vlsalari := pr_vlsalari;
      pr_tab_dados_proposta(0).vlsalcon := pr_vlsalcon;
      pr_tab_dados_proposta(0).vloutras := pr_vloutras;
      pr_tab_dados_proposta(0).vltotccr := vr_vltotccr;

      vr_vlsmdtri := NULL;
      vr_idxcmpmd := vr_tab_comp_medias.first;
      IF vr_idxcmpmd IS NOT NULL THEN
        vr_vlsmdtri := vr_tab_comp_medias(vr_idxcmpmd).vlsmdtri;
      END IF;
      pr_tab_dados_proposta(0).vlsmdtri := vr_vlsmdtri;
      pr_tab_dados_proposta(0).vlaplica := vr_rel_vlaplica;
      pr_tab_dados_proposta(0).dsdeben1 := pr_dsdeben1;
      pr_tab_dados_proposta(0).dsdeben2 := pr_dsdeben2;
      pr_tab_dados_proposta(0).vlfatura := pr_vlfatura;
      pr_tab_dados_proposta(0).vlmedtit := pr_vlmedtit;
      pr_tab_dados_proposta(0).vllimpro := pr_vllimite;
      pr_tab_dados_proposta(0).nrmatric := vr_tab_cabec(vr_idxdcabec).nrmatric;
      pr_tab_dados_proposta(0).nmprimtl := vr_tab_cabec(vr_idxdcabec).nmprimtl;
      pr_tab_dados_proposta(0).nrcpfcgc := vr_tab_cabec(vr_idxdcabec).nrcpfcgc;
      pr_tab_dados_proposta(0).dtadmemp := vr_tab_cabec(vr_idxdcabec).dtadmemp;
      pr_tab_dados_proposta(0).dstipcta := vr_tab_cabec(vr_idxdcabec).dstipcta;
      pr_tab_dados_proposta(0).dssitdct := vr_tab_cabec(vr_idxdcabec).dssitdct;
      pr_tab_dados_proposta(0).dtadmiss := vr_tab_cabec(vr_idxdcabec).dtadmiss;
      pr_tab_dados_proposta(0).vllimcre := vr_tab_cabec(vr_idxdcabec).vllimcre;
      pr_tab_dados_proposta(0).dsobserv := pr_dsobserv;
      pr_tab_dados_proposta(0).dsobser1 := pr_dsobserv;
      pr_tab_dados_proposta(0).dsramati := pr_dsramati;
      pr_tab_dados_proposta(0).dtcalcul := pr_dtmvtolt;
      pr_tab_dados_proposta(0).vlcaptal := vr_vldcotas;
      pr_tab_dados_proposta(0).vlprepla := vr_vlprepla;
      pr_tab_dados_proposta(0).tpcobran := rel_tpcobran;
      pr_tab_dados_proposta(0).nmoperad := pr_nmoperad;
      pr_tab_dados_proposta(0).nmcidade := pr_nmcidade;
      pr_tab_dados_proposta(0).nmresco1 := pr_nmextcop;

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

      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

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

      vr_vlutiliz := 0;
      -- Chamar rotina para retorno do saldo em utilização
      GENE0005.pc_saldo_utiliza(pr_cdcooper => pr_cdcooper              --> Código da Cooperativa
                               ,pr_tpdecons => 2 /*b1wgen9999*/         --> Tipo da consulta (Ver observações da rotina)
                               ,pr_cdagenci => pr_cdagenci              --> Código da agência
                               ,pr_nrdcaixa => pr_nrdcaixa              --> Número do caixa
                               ,pr_cdoperad => pr_cdoperad              --> Código do operador
                               ,pr_nrdconta => pr_nrdconta              --> OU Consulta pela conta
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

      pr_tab_dados_proposta(0).vlutiliz := vr_vlutiliz;

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
                           ,pr_nmprimtl       => vr_tab_cabec(vr_idxdcabec).nmprimtl   --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza--> Dados tabela parametro
                           ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                           ,pr_nrregist       => 0                     --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist           --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros

      pr_tab_emprestimos := vr_tab_dados_epr;

      vr_ddmvtolt := GENE0002.fn_valor_extenso(pr_idtipval => 'I',pr_valor    => TO_CHAR(pr_dtmvtolt,'DD'));
      vr_msmvtolt := GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'MM'));
      vr_aamvtolt := GENE0002.fn_valor_extenso(pr_idtipval => 'I',pr_valor    => TO_CHAR(pr_dtmvtolt,'RRRR'));
      vr_dsemsnot := gene0005.fn_data_extenso(pr_dtmvtolt);

      pr_tab_dados_proposta(0).ddmvtolt := vr_ddmvtolt;
      pr_tab_dados_proposta(0).dsmesref := vr_msmvtolt;
      pr_tab_dados_proposta(0).aamvtolt := vr_aamvtolt;
      pr_tab_dados_proposta(0).dsemsnot := vr_dsemsnot;

      -- Verifica se tem grupo economico em formacao
      GECO0001.pc_busca_grupo_associado(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_flggrupo => vr_flggrupo
                                         ,pr_nrdgrupo => vr_nrdgrupo
                                         ,pr_gergrupo => vr_gergrupo
                                         ,pr_dsdrisgp => vr_dsdrisgp);

      --  Se conta pertence a um grupo
      IF  vr_flggrupo = 1 THEN
          geco0001.pc_calc_endivid_grupo(pr_cdcooper  => pr_cdcooper
                                        ,pr_cdagenci  => pr_cdagenci
                                        ,pr_nrdcaixa  => 0
                                        ,pr_cdoperad  => pr_cdoperad
                                        ,pr_nmdatela  => pr_nmdatela
                                        ,pr_idorigem  => 1
                                        ,pr_nrdgrupo  => vr_nrdgrupo
                                        ,pr_tpdecons  => TRUE
                                        ,pr_dsdrisco  => vr_dsdrisco
                                        ,pr_vlendivi  => vr_vlendivi
                                        ,pr_tab_grupo => vr_tab_grupo
                                        ,pr_cdcritic  => vr_cdcritic
                                        ,pr_dscritic  => vr_dscritic);

        IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
        END IF;
      END IF;
      pr_tab_dados_proposta(0).dsdrisco := vr_dsdrisco;
      pr_tab_dados_proposta(0).vlendivi := vr_vlendivi;
      pr_tab_grupo := vr_tab_grupo;

      -- Ratings Ativos propostos - Pegar o de nota maior e maior valor
      OPEN cr_rating_ativo;
      FETCH cr_rating_ativo INTO rw_rating_ativo;
      IF (cr_rating_ativo%FOUND) THEN
        CLOSE cr_rating_ativo;
        pr_tab_dados_proposta(0).dsdopera := rw_rating_ativo.dsdopera;
        pr_tab_dados_proposta(0).nrctrrat := rw_rating_ativo.nrctrrat;
        pr_tab_dados_proposta(0).indrisco := rw_rating_ativo.indrisco;
        pr_tab_dados_proposta(0).nrnotrat := rw_rating_ativo.nrnotrat;
        pr_tab_dados_proposta(0).nrnotatl := rw_rating_ativo.nrnotatl;
        pr_tab_dados_proposta(0).vloperac := rw_rating_ativo.vloperac;
      ELSE
        CLOSE cr_rating_ativo;
        -- O registro crapnrc do Rating pode nao existir (proposta de operacao). Entao cria ele aqui
        RATI0001.pc_calcula_rating(pr_cdcooper => pr_cdcooper   --> Codigo Cooperativa
                                  ,pr_cdagenci => pr_cdagenci   --> Codigo Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa   --> Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad   --> Codigo Operador
                                  ,pr_nrdconta => pr_nrdconta   --> Numero da Conta
                                  ,pr_tpctrato => 3             --> Tipo Contrato Rating
                                  ,pr_nrctrato => pr_nrctrlim   --> Numero Contrato Rating
                                  ,pr_flgcriar => vr_flgcriar   --> Indicado se deve criar o rating
                                  ,pr_flgcalcu => 1             --> Indicador de calculo
                                  ,pr_idseqttl => pr_idseqttl   --> Sequencial do Titular
                                  ,pr_idorigem => pr_idorigem   --> Identificador Origem
                                  ,pr_nmdatela => 'b1wgen0043'  --> Nome da tela
                                  ,pr_flgerlog => 0             --> Identificador de geração de log
                                  ,pr_tab_rating_sing      => vr_tab_rating_sing      --> Registros gravados para rati
                                  ,pr_flghisto => 1
                                  ,pr_tab_impress_coop     => vr_tab_impress_coop     --> Registro impressão da Cooper
                                  ,pr_tab_impress_rating   => vr_tab_impress_rating   --> Registro itens do Rating
                                  ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do coo
                                  ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do coo
                                  ,pr_tab_impress_assina   => vr_tab_impress_assina   --> Assinatura na impressao do R
                                  ,pr_tab_efetivacao       => vr_tab_efetivacao       --> Registro dos itens da efetiv
                                  ,pr_tab_ratings          => vr_tab_ratings          --> Informacoes com os Ratings d
                                  ,pr_tab_crapras          => vr_tab_crapras          --> Tabela com os registros proc
                                  ,pr_tab_erro             => vr_tab_erro             --> Tabela de retorno de erro
                                  ,pr_des_reto             => vr_dscritic);           --> Ind. de retorno OK/NOK

        pr_tab_dados_proposta(0).dsdopera := RATI0001.fn_busca_descricao_operacao(3);
        pr_tab_dados_proposta(0).nrctrrat := pr_nrctrlim;
        pr_tab_dados_proposta(0).nrnotrat := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.FIRST).vlrtotal;
        pr_tab_dados_proposta(0).indrisco := vr_tab_impress_risco_cl(vr_tab_impress_risco_cl.FIRST).dsdrisco;
        --pr_tab_dados_proposta(0).indrisco := vr_tab_impress_risco_cl(0).indrisco;
        --pr_tab_dados_proposta(0).dsditrat := RATI0001.fn_busca_descricao_situacao(1);
      END IF;

      /*Histórico de Ratings*/
      OPEN cr_rating_hist;
      vr_idxrating := 0;
      LOOP
        FETCH cr_rating_hist INTO rw_rating_hist;
        EXIT  WHEN cr_rating_hist%NOTFOUND;
        pr_tab_rating_hist(vr_idxrating).dsdopera := rw_rating_hist.dsdopera;
        pr_tab_rating_hist(vr_idxrating).nrctrrat := rw_rating_hist.nrctrrat;
        pr_tab_rating_hist(vr_idxrating).indrisco := rw_rating_hist.indrisco;
        pr_tab_rating_hist(vr_idxrating).nrnotrat := rw_rating_hist.nrnotrat;
        pr_tab_rating_hist(vr_idxrating).vloperac := rw_rating_hist.vloperac;
        pr_tab_rating_hist(vr_idxrating).dsditrat := rw_rating_hist.dsditrat;
        vr_idxrating := vr_idxrating+1;
      END LOOP;
      CLOSE cr_rating_hist;

  END pc_carrega_dados_proposta;

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
    --
    --               06/06/2018 - Alteração do juros de ano para juros simples.
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
  EXCEPTION
    WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_carrega_dados_ctrlim: ' || SQLERRM;
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
                                       ,pr_tpimpres IN VARCHAR2 DEFAULT NULL
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
                                       ,pr_tab_dados_proposta         OUT typ_tab_dados_proposta
                                       ,pr_tab_emprestimos            OUT EMPR0001.typ_tab_dados_epr
                                       ,pr_tab_grupo                  OUT GECO0001.typ_tab_crapgrp
                                       ,pr_tab_rating_hist            OUT typ_tab_rating_hist
                                       ,pr_cdcritic                   OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic                   OUT VARCHAR2) IS          --> Descrição da crítica
    ------------------------------------------------------------------------------
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
    --   Histórico de Alterações:
    --     05/08/2016 - Conversão Progress -> Oracle (Odirlei-AMcom)
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
    --    01/02/2018 - Inclusão de Parâmetro de entrada por tipo de pessoa: Física / Jurídica
    --                (Gustavo Sene - GFT)
    ------------------------------------------------------------------------------


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
      SELECT age.nmcidade,
           age.cdufdcop
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
    vr_tab_dados_proposta      typ_tab_dados_proposta;
    vr_tab_emprestimos         EMPR0001.typ_tab_dados_epr;
    vr_tab_grupo               GECO0001.typ_tab_crapgrp;
    vr_tab_rating_hist         typ_tab_rating_hist;


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
   vr_tpctrprp VARCHAR2(1);

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

    vr_dsemsnot := SUBSTR(vr_nmcidage,1,15) ||', ' || gene0005.fn_data_extenso(pr_dtmvtolt);
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

    IF pr_idimpres = 3 THEN
      vr_tpctrprp := 'P';
    ELSE
      vr_tpctrprp := 'C';
    END IF;

    IF pr_tpimpres IS NOT NULL THEN
      vr_tpctrprp := 'P';
    END IF;

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
                               ,pr_tpctrprp => vr_tpctrprp  --> Tipo de informação ('C' = Contrato / 'P' = Proposta)
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
                             GENE0002.fn_mask(vr_tab_dados_avais(vr_idxavais).nrcepend,'99.999-999') || ', na condição de DEVEDOR SOLIDÁRIO' ||
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

      vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', nº '|| vr_tab_dados_avais(vr_idxavais).nrendere ||', bairro ' ||
                 vr_tab_dados_avais(vr_idxavais).dsendcmp || ', da cidade de ' ||
                 vr_tab_dados_avais(vr_idxavais).nmcidade || '/' ||
                 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
                             GENE0002.fn_mask(vr_tab_dados_avais(vr_idxavais).nrcepend,'99.999-999') || ', na condição de DEVEDOR SOLIDÁRIO' ||
                             (CASE WHEN vr_tab_dados_avais(vr_idxavais).nrctaava > 0 THEN ', titular da conta corrente nº ' || TRIM(gene0002.fn_mask_conta(vr_tab_dados_avais(vr_idxavais).nrctaava)) ELSE '' END) ||
                             '.';

      ELSE

      vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' ||
                           vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' ||
                           vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' ||
                           vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
                           vr_tab_dados_avais(vr_idxavais).nrcepend;

      END IF;


    END IF;

        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcgc > 0 THEN
          IF pr_tpctrlim = 2 THEN
            -- Buscar inpessoa
            gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
                                       ,vr_stsnrcal
                                       ,vr_inpessoa_av);
            vr_rel_dscpfav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                         pr_inpessoa => vr_inpessoa_av);
          ELSE
            IF pr_nrvrsctr = 2 THEN
              -- Buscar inpessoa
              gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
                                         ,vr_stsnrcal
                                         ,vr_inpessoa_av);
              vr_rel_dscpfav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                           pr_inpessoa => vr_inpessoa_av );

            ELSE
            vr_rel_dscpfav1 := 'C.P.F. '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                                     pr_inpessoa => 1 );
          END IF;
          END IF;
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdocava IS NULL THEN
          vr_rel_dscpfav1 := vr_tab_dados_avais(vr_idxavais).nrdocava;
        END IF;

        vr_rel_nrfonav1 := vr_tab_dados_avais(vr_idxavais).nrfonres;

        --> Conjuge
        vr_rel_nmdcjav1 := vr_tab_dados_avais(vr_idxavais).nmconjug;

        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcjg > 0 THEN
          IF pr_tpctrlim = 2 THEN
            vr_rel_dscfcav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                         pr_inpessoa => 1 );
          ELSE
            IF pr_nrvrsctr = 2 THEN
              vr_rel_dscfcav1 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                           pr_inpessoa => 1 );
            ELSE
            vr_rel_dscfcav1 := 'C.P.F. '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                                     pr_inpessoa => 1 );
          END IF;
          END IF;
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

          vr_rel_linaval2 := vr_tab_dados_avais(vr_idxavais).dsendere || ', nº '|| vr_tab_dados_avais(vr_idxavais).nrendere ||', bairro ' ||
                 vr_tab_dados_avais(vr_idxavais).dsendcmp || ', da cidade de ' ||
                 vr_tab_dados_avais(vr_idxavais).nmcidade || '/' ||
                 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
                             GENE0002.fn_mask(vr_tab_dados_avais(vr_idxavais).nrcepend,'99.999-999') || ', na condição de DEVEDOR SOLIDÁRIO' ||
                             (CASE WHEN vr_tab_dados_avais(vr_idxavais).nrctaava > 0 THEN ', titular da conta corrente nº ' || TRIM(gene0002.fn_mask_conta(vr_tab_dados_avais(vr_idxavais).nrctaava)) ELSE '' END) ||
                             '.';

      ELSE

        vr_rel_linaval1 := vr_tab_dados_avais(vr_idxavais).dsendere || ', bairro ' ||
                 vr_tab_dados_avais(vr_idxavais).dsendcmp ||', da cidade de ' ||
                 vr_tab_dados_avais(vr_idxavais).nmcidade ||'/' ||
                 vr_tab_dados_avais(vr_idxavais).cdufresd || ', CEP ' ||
                 vr_tab_dados_avais(vr_idxavais).nrcepend;

      END IF;


    END IF;

        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcgc > 0 THEN
          IF pr_tpctrlim = 2 THEN
            -- Buscar inpessoa
            gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
                                       ,vr_stsnrcal
                                       ,vr_inpessoa_av);
            vr_rel_dscpfav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                         pr_inpessoa => vr_inpessoa_av );
          ELSE
            IF pr_nrvrsctr = 2 THEN
              -- Buscar inpessoa
              gene0005.pc_valida_cpf_cnpj(vr_tab_dados_avais(vr_idxavais).nrcpfcgc
                                         ,vr_stsnrcal
                                         ,vr_inpessoa_av);
              vr_rel_dscpfav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                           pr_inpessoa => vr_inpessoa_av );
            ELSE
            vr_rel_dscpfav2 := 'C.P.F. '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcgc,
                                                                     pr_inpessoa => 1 );
          END IF;
          END IF;
        ELSIF vr_tab_dados_avais(vr_idxavais).nrdocava IS NULL THEN
          vr_rel_dscpfav2 := vr_tab_dados_avais(vr_idxavais).nrdocava;
        END IF;

        vr_rel_nrfonav2 := vr_tab_dados_avais(vr_idxavais).nrfonres;

        --> Conjuge
        vr_rel_nmdcjav2 := vr_tab_dados_avais(vr_idxavais).nmconjug;

        IF  vr_tab_dados_avais(vr_idxavais).nrcpfcjg > 0 THEN
          IF pr_tpctrlim = 2 THEN
          vr_rel_dscfcav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                       pr_inpessoa => 1 );
          ELSE
            IF pr_nrvrsctr = 2 THEN
              vr_rel_dscfcav2 := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                           pr_inpessoa => 1 );

            ELSE
            vr_rel_dscfcav2 := 'C.P.F. '|| gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_dados_avais(vr_idxavais).nrcpfcjg,
                                                                     pr_inpessoa => 1 );
            END IF;
          END IF;

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

      -- Se for bordero novo utiliza Juros Simples, senão Juros Composto
      IF vr_tab_dados_border(vr_idxborde).flverbor = 1 THEN
        vr_rel_txdiaria := apli0001.fn_round(((vr_tab_dados_border(vr_idxborde).txmensal / 100) / 30) * 100,7);
        vr_rel_txdanual := apli0001.fn_round(((vr_tab_dados_border(vr_idxborde).txmensal / 100) * 12) * 100,6);
      ELSE
        vr_rel_txdiaria := apli0001.fn_round(((vr_tab_dados_border(vr_idxborde).txmensal / 100) / 30) * 100,7);
        vr_rel_txdanual := apli0001.fn_round((power(1 + (vr_tab_dados_border(vr_idxborde).txmensal / 100), 12) - 1) * 100,6);
      END IF;

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

      /*Carrega os dados exclusivos da proposta*/

      pc_carrega_dados_proposta (pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtmvtopr => pr_dtmvtopr
                                       ,pr_inproces => pr_inproces
                                       ,pr_idorigem => pr_idorigem
                                       ,pr_nmempres => vr_nmempres
                                       ,pr_telefone => vr_telefone
                                       ,pr_vlsalari => vr_tab_dados_limite(vr_idxlimit).vlsalari
                                       ,pr_vlsalcon => vr_tab_dados_limite(vr_idxlimit).vlsalcon
                                       ,pr_vloutras => vr_tab_dados_limite(vr_idxlimit).vloutras
                                       ,pr_dsdeben1 => vr_tab_dados_limite(vr_idxlimit).dsdbens1
                                       ,pr_dsdeben2 => vr_tab_dados_limite(vr_idxlimit).dsdbens2
                                       ,pr_vlfatura => vr_tab_dados_limite(vr_idxlimit).vlfatura
                                       ,pr_vlmedtit => vr_tab_dados_limite(vr_idxlimit).vlmedtit
                                       ,pr_vllimite => vr_tab_dados_limite(vr_idxlimit).vllimite
                                       ,pr_dsobserv => vr_tab_dados_limite(vr_idxlimit).dsobserv
                                       ,pr_dsramati => vr_tab_dados_limite(vr_idxlimit).dsramati
                                       ,pr_nrctrlim => pr_nrctrlim
                                       ,pr_nmoperad   => rw_crapope.nmoperad
                                       ,pr_nmcidade   => rw_crapage.nmcidade
                                       ,pr_nmextcop   => rw_crapcop.nmextcop
                                       ,pr_tab_dados_proposta => vr_tab_dados_proposta
                                       ,pr_tab_emprestimos    => vr_tab_emprestimos
                                       ,pr_tab_grupo          => vr_tab_grupo
                                       ,pr_tab_rating_hist    => vr_tab_rating_hist
                                      );

      pr_tab_dados_proposta := vr_tab_dados_proposta;
      pr_tab_emprestimos    := vr_tab_emprestimos;
      pr_tab_grupo          := vr_tab_grupo;
      pr_tab_rating_hist    := vr_tab_rating_hist;

      IF nvl(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
      END IF;

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
    --               10/04/2019 - Inclusao do Rating relatorio P450 (Rating)
    --                            (Daniele Rocha)
    --
    --               18/07/2019 - Incluído outras rendas do cônjuge.
    --                            PRJ 438 - Sprint 16 - Rubens Lima (Mout's)
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
    --     descontos de titulos
    SELECT lim.nrdconta,
           lim.cdageori,
           lim.vllimite,
           lim.cddlinha,
           lim.dtinivig,
           lim.idcobope,
           lim.dtpropos,
           lim.nrctrlim
      FROM craplim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = pr_tpctrlim
       AND pr_tpctrlim <> 3

    UNION ALL

    --     proposta principal do limites de desconto de titulo
    SELECT lim.nrdconta,
           lim.cdageori,
           lim.vllimite,
           lim.cddlinha,
           lim.dtinivig,
           lim.idcobope,
           lim.dtpropos,
           lim.nrctrlim
      FROM crawlim lim
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = pr_tpctrlim
       AND lim.nrctrmnt = 0
       AND pr_tpctrlim = 3

    UNION ALL

    --     proposta de manutenção de limites de desconto de titulo
    SELECT mnt.nrdconta,
           mnt.cdageori,
           mnt.vllimite,
           mnt.cddlinha,
           mnt.dtinivig,
           mnt.idcobope,
           mnt.dtpropos,
           mnt.nrctrlim
      FROM crawlim mnt,
           crawlim lim
     WHERE mnt.cdcooper = lim.cdcooper
       AND mnt.nrdconta = lim.nrdconta
       AND mnt.nrctrlim = lim.nrctrmnt
       AND mnt.tpctrlim = lim.tpctrlim
       AND lim.cdcooper = lim.cdcooper
       AND lim.nrdconta = pr_nrdconta
       AND lim.nrctrlim = pr_nrctrlim
       AND lim.tpctrlim = pr_tpctrlim
       AND pr_tpctrlim = 3;
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

    --> Buscar conjuge
    CURSOR cr_conjuge (pr_cdcooper crapcje.cdcooper%TYPE,
                       pr_nrdconta crapcje.nrdconta%TYPE ) IS
     SELECT e.nrctacje
     FROM crapcje e
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta
     AND   idseqttl = 1;    
    --Rendas
    CURSOR cr_rendas(pr_cdcooper crapcje.cdcooper%TYPE,
                     pr_nrdconta crapcje.nrdconta%TYPE ) IS
     SELECT NVL(t.vldrendi##1,0) + 
            NVL(t.vldrendi##2,0) + 
            NVL(t.vldrendi##3,0) + 
            NVL(t.vldrendi##4,0) + 
            NVL(t.vldrendi##5,0) + 
            NVL(t.vldrendi##6,0)
     FROM crapttl t
     WHERE t.cdcooper = pr_cdcooper
     AND   t.nrdconta = pr_nrdconta;
    ----------->>> TEMPTABLE <<<--------
    vr_tab_dados_avais         typ_tab_dados_avais;
    vr_tab_tit_bordero         typ_tab_tit_bordero;
    vr_tab_chq_bordero         DSCT0002.typ_tab_chq_bordero;
    vr_tab_bordero_restri      typ_tab_bordero_restri;
    vr_tab_dados_tits_bordero  typ_tab_dados_itens_bordero;
    vr_tab_sacado_nao_pagou    typ_tab_sacado_nao_pagou;
    vr_tab_contrato_limite     typ_tab_contrato_limite;
    vr_tab_dados_nota_pro      DSCT0002.typ_tab_dados_nota_pro;
    vr_tab_dados_proposta      typ_tab_dados_proposta;
    vr_tab_emprestimos         EMPR0001.typ_tab_dados_epr;
    vr_tab_grupo               GECO0001.typ_tab_crapgrp;
    vr_tab_rating_hist         typ_tab_rating_hist;
    vr_nrctacjg                CRAPCJE.nrctacje%TYPE;
    vr_vlrencjg                NUMBER :=0;
    
    vr_idxctlim                PLS_INTEGER;
    vr_idxpromi                PLS_INTEGER;

    vr_idx_proposta            PLS_INTEGER;
    vr_index_emprestimo        PLS_INTEGER;
    vr_index_rating_hist       PLS_INTEGER;

    vr_tpimpres                VARCHAR2(5) := NULL;

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

    vr_nrctrlim craplim.nrctrlim%TYPE;

    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);

    vr_des_inrisco_rat_inc VARCHAR2(200); -- SERA DEVOLVIDO 1o RATING   DO CONTRATO DA CONTA
    vr_inpontos_rat_inc    INTEGER; -- SERA DEVOLVIDO 1o PONTOS   DO CONTRATO DA CONTA
    vr_innivel_rat_inc     VARCHAR2(10); -- SERA DEVOLVIDO 1o NIVEL    DO CONTRATO DA CONTA
    vr_insegmento_rat_inc  VARCHAR2(50); -- SERA DEVOLVIDO 1o SEGMENTO DO CONTRATO DA CONTA
    vr_vlr                 crapepr.vlemprst%type;
    vr_qtdreg              INTEGER;
    vr_nrctro_out          INTEGER; -- SERA DEVOLVIDO 1o NUMERO    CONTRATO DA CONTA
    vr_tpctrato_out        INTEGER; -- SERA DEVOLVIDO 1o TIPO       CONTRATO DA CONTA
    vr_retxml_clob         CLOB; -- XML COM TODOS OS CONTRATOS/TIPOS DA CONTA

    vr_habrat VARCHAR2(1) := 'N'; -- P450 - Paramentro para Habilitar Novo Ratin (S/N)

    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;


  BEGIN

    vr_habrat := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                           pr_cdcooper => pr_cdcooper,
                                           pr_cdacesso => 'HABILITA_RATING_NOVO');

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

      --> Buscar Contrato de limite
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF cr_craplim%NOTFOUND THEN
        CLOSE cr_craplim;
        vr_flgcriti := TRUE;
      ELSE
        CLOSE cr_craplim;
      END IF;

    IF pr_idimpres IN( 1,      --> COMPLETA
                       2,      --> CONTRATO
                       3 )THEN --> PROPOSTA

      --> Se for Cheque e igual ou superior a data do novo contrato
      IF (pr_tpctrlim = 2 OR pr_tpctrlim = 3) AND
         rw_craplim.dtpropos >= TO_DATE(GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                 ,pr_cdacesso => 'DT_VIG_IMP_CTR_V2'),'DD/MM/RRRR') THEN
        vr_nrvrsctr := 2;
      END IF;

    END IF;

    IF pr_idimpres = 3 THEN
      vr_nrctrlim := pr_nrctrlim;
    ELSE
      vr_nrctrlim := rw_craplim.nrctrlim;
    END IF;

    IF pr_tpctrlim = 3 THEN
      IF rw_craplim.dtinivig IS NULL THEN
        vr_tpimpres := 'P';
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
                               ,pr_nrctrlim => vr_nrctrlim  --> Contrato
                               ,pr_nrborder => 0            --> Numero do bordero
                               ,pr_flgerlog => 0            --> Indicador se deve gerar log(0-nao, 1-sim)
                               ,pr_limorbor => 1            --> Indicador do tipo de dado( 1 - LIMITE DSCTIT 2 - BORDERO DSCTIT )
                               ,pr_nrvrsctr => vr_nrvrsctr  --> Numero da versao do contrato
                               ,pr_tpimpres => vr_tpimpres
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
                               ,pr_tab_dados_proposta     => vr_tab_dados_proposta
                               ,pr_tab_emprestimos        => vr_tab_emprestimos
                               ,pr_tab_grupo              => vr_tab_grupo
                               ,pr_tab_rating_hist        => vr_tab_rating_hist
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
                       2,      --> CONTRATO
                       3) THEN --> PROPOSTA

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
                                      ,pr_nrctrlim  => rw_craplim.nrctrlim         -- Contrato
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
                   TRIM(gene0002.fn_mask_contrato(rw_craplim.nrctrlim)) ||'_'||
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
                         '<nrctrlim>'|| TRIM(gene0002.fn_mask_contrato(rw_craplim.nrctrlim)) ||'</nrctrlim>'||
                         '<nrdconta>'|| gene0002.fn_mask_conta(pr_nrdconta)          ||'</nrdconta>'||
                         '<nmextcop>'|| vr_tab_contrato_limite(vr_idxctlim).nmextcop ||'</nmextcop>'||
                         '<cdagenci>'|| vr_tab_contrato_limite(vr_idxctlim).cdagenci ||'</cdagenci>'||
                         '<dsagenci>'|| rw_crapage.nmresage                          ||'</dsagenci>'||
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

      -- Projeto 470 - SM 1 - 18/03/2019
      -- Marcelo Telles Coelho - Mouts
      DECLARE
        vr_dsfrase_cooperado   VARCHAR2(4000);
        vr_dsfrase_cooperativa VARCHAR2(4000);
      BEGIN
        cntr0001.pc_ver_protocolo (pr_cdcooper            => pr_cdcooper
                                  ,pr_nrdconta            => pr_nrdconta
                                  ,pr_nrcontrato          => pr_nrctrlim
                                  ,pr_tpcontrato          => CASE WHEN pr_tpctrlim = 2 THEN 27 ELSE 28 END
                                  ,pr_dsfrase_cooperado   => vr_dsfrase_cooperado
                                  ,pr_dsfrase_cooperativa => vr_dsfrase_cooperativa);
        IF vr_dsfrase_cooperado IS NOT NULL THEN
          pc_escreve_xml('<autorizacao_por_senha>');
          pc_escreve_xml('<dsfrase_cooperado>'||vr_dsfrase_cooperado||'</dsfrase_cooperado>');
          pc_escreve_xml('<dsfrase_cooperativa>'||vr_dsfrase_cooperativa||'</dsfrase_cooperativa>');
          pc_escreve_xml('</autorizacao_por_senha>');
        END IF;
      END;
      -- Fim Projeto 470 - SM 1

      --> Gerar XML para dados do relatorio de CET
      CCET0001.pc_imprime_limites_cet( pr_cdcooper  => pr_cdcooper                 -- Cooperativa
                                      ,pr_dtmvtolt  => pr_dtmvtolt                 -- Data Movimento
                                      ,pr_cdprogra  => 'ATENDA'                    -- Programa chamador
                                      ,pr_nrdconta  => pr_nrdconta                 -- Conta/dv
                                      ,pr_inpessoa  => rw_crapass.inpessoa         -- Indicativo de pessoa
                                      ,pr_cdusolcr  => 1                           -- Codigo de uso da linha de credito
                                      ,pr_cdlcremp  => rw_craplim.cddlinha         -- Linha de credio
                                      ,pr_tpctrlim  => pr_tpctrlim                 -- Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                      ,pr_nrctrlim  => rw_craplim.nrctrlim                 -- Contrato
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
    IF pr_idimpres = 3 THEN ---PROPOSTA

     --Buscar indice do primeiro registro
     vr_idx_proposta := vr_tab_dados_proposta.FIRST;

      -- P450 SPT13 - alteracao para habilitar rating novo
      IF (pr_cdcooper <> 3 AND vr_habrat = 'S') THEN
        /*incluido o rating  no relatorio Projeto 450- rating 04/2019*/
        vr_des_inrisco_rat_inc := ''; -- SERÁ DEVOLVIDO 1° RATING   DO CONTRATO DA CONTA
        vr_inpontos_rat_inc    := 0; -- SERÁ DEVOLVIDO 1° PONTOS   DO CONTRATO DA CONTA
        vr_innivel_rat_inc     := ''; -- SERÁ DEVOLVIDO 1° NIVEL    DO CONTRATO DA CONTA
        vr_insegmento_rat_inc  := ''; -- SERÁ DEVOLVIDO 1° SEGMENTO DO CONTRATO DA CONTA
        vr_vlr                 := 0;
        vr_qtdreg              := 0;
        vr_nrctro_out          := 0; -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
        vr_tpctrato_out        := 0; -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
        vr_retxml_clob         := '';

        RATI0003.pc_busca_dados_rating_inclusao(pr_cdcooper            => pr_cdcooper, -- COOPERATIVA CAMPO OBRIGATÓRIO
                                                pr_nrdconta            => pr_nrdconta, -- CONTA       CAMPO OBRIGATÓRIO
                                                pr_nrctro              => rw_craplim.nrctrlim, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA

                                                pr_tpctrato            => pr_tpctrlim, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                                pr_des_inrisco_rat_inc => vr_des_inrisco_rat_inc, -- SERÁ DEVOLVIDO 1° RATING   DO CONTRATO DA CONTA
                                                pr_inpontos_rat_inc    => vr_inpontos_rat_inc, -- SERÁ DEVOLVIDO 1° PONTOS   DO CONTRATO DA CONTA
                                                pr_innivel_rat_inc     => vr_innivel_rat_inc, -- SERÁ DEVOLVIDO 1° NIVEL    DO CONTRATO DA CONTA
                                                pr_insegmento_rat_inc  => vr_insegmento_rat_inc, -- SERÁ DEVOLVIDO 1° SEGMENTO DO CONTRATO DA CONTA
                                                pr_vlr                 => vr_vlr,
                                                pr_qtdreg              => vr_qtdreg,
                                                pr_nrctro_out          => vr_nrctro_out, -- SERÁ DEVOLVIDO 1° NUMERO    CONTRATO DA CONTA
                                                pr_tpctrato_out        => vr_tpctrato_out, -- SERÁ DEVOLVIDO 1° TIPO       CONTRATO DA CONTA
                                                pr_retxml_clob         => vr_retxml_clob, -- XML COM TODOS OS CONTRATOS/TIPOS DA CONTA
                                                pr_cdcritic            => vr_cdcritic, --> codigo da critica
                                                pr_dscritic            => vr_dscritic);
      END IF;
      -- P450 SPT13 - alteracao para habilitar rating novo

     /*Busca a conta do cônjuge*/
     OPEN cr_conjuge (pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
     FETCH cr_conjuge INTO vr_nrctacjg;                 
     CLOSE cr_conjuge;
     
     /*Se possuir conjuge, busca as rendas*/
     IF NVL(vr_nrctacjg,0) > 0 THEN
       OPEN cr_rendas (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => vr_nrctacjg);
        FETCH cr_rendas INTO vr_vlrencjg;
       CLOSE cr_rendas;
     END IF;

     pc_escreve_xml('<Proposta>');
     pc_escreve_xml(
                          '<nrdconta>'  || TRIM(GENE0002.fn_mask_conta(vr_tab_dados_proposta(vr_idx_proposta).nrdconta))     || '</nrdconta>' ||
                          '<nrctrlim>'  || TRIM(GENE0002.fn_mask_contrato(vr_tab_dados_proposta(vr_idx_proposta).nrctrlim))  || '</nrctrlim>' ||
                          '<aux_tpdocged>'|| vr_cdtipdoc || '</aux_tpdocged>'  ||
                          '<nrmatric>'  || gene0002.fn_mask(vr_tab_dados_proposta(vr_idx_proposta).nrmatric, 'zzz.zz9' ) || '</nrmatric>' ||
                          '<nmprimtl>'  || vr_tab_dados_proposta(vr_idx_proposta).nmprimtl || '</nmprimtl>' ||
                          '<dtadmiss>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).dtadmiss,'dd/mm/rrrr') || '</dtadmiss>' ||
                          '<nrcpfcgc>'  || vr_tab_dados_proposta(vr_idx_proposta).nrcpfcgc || '</nrcpfcgc>' ||
                          '<nmempres>'  || vr_tab_dados_proposta(vr_idx_proposta).nmempres || '</nmempres>' ||
                          '<nmdsecao>'  || vr_tab_dados_proposta(vr_idx_proposta).nmdsecao || '</nmdsecao>' ||
                          '<dtadmemp>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).dtadmemp,'dd/mm/rrrr')  || '</dtadmemp>' ||
                          '<telefone>'  || vr_tab_dados_proposta(vr_idx_proposta).telefone || '</telefone>' ||
                          '<dstipcta>'  || vr_tab_dados_proposta(vr_idx_proposta).dstipcta || '</dstipcta>' ||
                          '<dssitdct>'  || vr_tab_dados_proposta(vr_idx_proposta).dssitdct || '</dssitdct>' ||
                          '<dsramati>'  || vr_tab_dados_proposta(vr_idx_proposta).dsramati || '</dsramati>' ||
                          '<dsagenci>'  ||  rw_crapage.nmresage                            || '</dsagenci>' ||
                          '<vlsalari>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlsalari,'FM999G999G990D00')  || '</vlsalari>' ||
                          '<vlsalcon>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlsalcon,'FM999G999G990D00')  || '</vlsalcon>' ||
                          '<vlrencjg>'	|| to_char(vr_vlrencjg,'FM999G999G990D00')  || '</vlrencjg>' ||
                          
                          '<vlfatura>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlfatura,'FM999G999G990D00')  || '</vlfatura>' ||
                          '<vllimcre>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vllimcre,'FM999G999G990D00')  || '</vllimcre>' ||
                          '<vltotccr>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vltotccr,'FM999G999G990D00')  || '</vltotccr>' ||
                          '<vllimchq>'  ||to_char( vr_tab_dados_proposta(vr_idx_proposta).vllimchq,'FM999G999G990D00')  || '</vllimchq>' ||
                          '<dsdeben1>'  || vr_tab_dados_proposta(vr_idx_proposta).dsdeben1 || '</dsdeben1>' ||
                          '<dsdeben2>'  || vr_tab_dados_proposta(vr_idx_proposta).dsdeben2 || '</dsdeben2>' ||
                          '<rel_tpcobran>'|| vr_tab_dados_proposta(vr_idx_proposta).tpcobran || '</rel_tpcobran>'||
                          '<vlsmdtri>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlsmdtri,'FM999G999G990D00')  || '</vlsmdtri>' ||
                          '<vlcaptal>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlcaptal,'FM999G999G990D00') || '</vlcaptal>' ||
                          '<vlprepla>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlprepla,'FM999G999G990D00') || '</vlprepla>' ||
                          '<vlaplica>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlaplica,'FM999G999G990D00') || '</vlaplica>' ||
                          '<vloutras>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vloutras,'FM999G999G990D00')  || '</vloutras>' ||
                          '<vllimpro>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vllimpro,'FM999G999G990D00')  || '</vllimpro>' ||
                          '<dsdlinha>'  || vr_tab_contrato_limite(vr_idxctlim).dsdlinha  || '</dsdlinha>' ||
                          '<vlmedtit>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlmedtit,'FM999G999G990D00')  || '</vlmedtit>' ||
                          '<dtcalcul>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).dtcalcul,'dd/mm/rrrr')  || '</dtcalcul>' ||
                          '<vlutiliz>'  || to_char(vr_tab_dados_proposta(vr_idx_proposta).vlutiliz,'FM999G999G990D00')  || '</vlutiliz>' ||
                          '<dsobser1>'  || vr_tab_dados_proposta(vr_idx_proposta).dsobser1 || '</dsobser1>' ||
                          '<dsobser2>'  || vr_tab_dados_proposta(vr_idx_proposta).dsobser2 || '</dsobser2>' ||
                          '<dsobser3>'  || vr_tab_dados_proposta(vr_idx_proposta).dsobser3 || '</dsobser3>' ||
                          '<dsobser4>'  || vr_tab_dados_proposta(vr_idx_proposta).dsobser4 || '</dsobser4>' ||
                          '<nmoperad>'  || vr_tab_dados_proposta(vr_idx_proposta).nmoperad || '</nmoperad>' ||
                          '<nmcidade>'  || vr_tab_dados_proposta(vr_idx_proposta).nmcidade || '</nmcidade>' ||
                          '<ddmvtolt>'  || vr_tab_dados_proposta(vr_idx_proposta).ddmvtolt || '</ddmvtolt>' ||
                          '<dsmesref>'  || vr_tab_dados_proposta(vr_idx_proposta).dsmesref || '</dsmesref>' ||
                          '<aamvtolt>'  || vr_tab_dados_proposta(vr_idx_proposta).aamvtolt || '</aamvtolt>' ||
                          '<dsemsnot>'  || vr_tab_dados_proposta(vr_idx_proposta).dsemsnot || '</dsemsnot>' ||
                          '<nmresco1>'  || vr_tab_dados_proposta(vr_idx_proposta).nmresco1 || '</nmresco1>' ||
                          '<nmresco2>'  || vr_tab_dados_proposta(vr_idx_proposta).nmresco2 || '</nmresco2>');



                    -- ler os registros de emprestimo e incluir no xml
                    vr_index_emprestimo := vr_tab_emprestimos.first;
                    while vr_index_emprestimo is not null loop

                        pc_escreve_xml(
                          '<emprestimo>' ||
                                          '<nrctremp>'  || vr_tab_emprestimos(vr_index_emprestimo).nrctremp || '</nrctremp>' ||
                                          '<vlsdeved>'  || vr_tab_emprestimos(vr_index_emprestimo).vlsdeved || '</vlsdeved>' ||
                                          '<dspreapg>'  || vr_tab_emprestimos(vr_index_emprestimo).dspreapg || '</dspreapg>' ||
                                          '<vlpreemp>'  || vr_tab_emprestimos(vr_index_emprestimo).vlpreemp || '</vlpreemp>' ||
                                          '<dslcremp>'  || vr_tab_emprestimos(vr_index_emprestimo).dslcremp || '</dslcremp>' ||
                                          '<dsfinemp>'  || vr_tab_emprestimos(vr_index_emprestimo).dsfinemp || '</dsfinemp>' ||
                          '</emprestimo>');

                        vr_index_emprestimo := vr_tab_emprestimos.next(vr_index_emprestimo);
                    end loop;

                    -- P450 SPT13 - alteracao para habilitar rating novo
                    IF (pr_cdcooper = 3 OR vr_habrat = 'N') THEN
                      pc_escreve_xml(
                                     '<ratingRisco>' ||
                                       '<dsdopera>' || vr_tab_dados_proposta(vr_idx_proposta).dsdopera || '</dsdopera>'     ||
                                       '<nrctrrat>' || TRIM(GENE0002.fn_mask_contrato(vr_tab_dados_proposta(vr_idx_proposta).nrctrrat))  || '</nrctrrat>'     ||
                                       '<indrisco>' || vr_tab_dados_proposta(vr_idx_proposta).indrisco || '</indrisco>'     ||
                                       '<nrnotrat>' || to_char(vr_tab_dados_proposta(vr_idx_proposta).nrnotrat,'FM999G999G990D00') || '</nrnotrat>'     ||
                                       '<dsdrisco>' || vr_tab_dados_proposta(vr_idx_proposta).dsdrisco || '</dsdrisco>'     ||
                                     '</ratingRisco>');
                    ELSE
                      pc_escreve_xml(
                                     '<ratingRisco>' ||
                                       '<des_inrisco_rat_inc>'|| vr_des_inrisco_rat_inc            ||'</des_inrisco_rat_inc>' || /*Risco do Rating (alfabético -AA..)*/
                                       '<inpontos_rat_inc>'   || vr_inpontos_rat_inc               ||'</inpontos_rat_inc>' || /*Pontuação Rating (numérico)*/
                                       '<innivel_rat_inc>'    || vr_innivel_rat_inc                ||'</innivel_rat_inc>' || /*Nivel Rating (baixo / médio/ alto risco)*/
                                       '<insegmento_rat_inc>' || vr_insegmento_rat_inc             ||'</insegmento_rat_inc>'||  /*Segmento (texto - informação de qual garantia foi utilizada)*/
                                     '</ratingRisco>');
                    END IF;
                    -- P450 SPT13 - alteracao para habilitar rating novo

                    -- ler os registros de proposta e incluir no xml
                    vr_index_rating_hist := vr_tab_rating_hist.first;
                    while vr_index_rating_hist is not null loop

                        pc_escreve_xml(
                          '<ratingHistorico>' ||
                                          '<dsdopera>' || vr_tab_rating_hist(vr_index_rating_hist).dsdopera || '</dsdopera>'     ||
                                          '<nrctrrat>' || TRIM(GENE0002.fn_mask_contrato(vr_tab_rating_hist(vr_index_rating_hist).nrctrrat))  || '</nrctrrat>'     ||
                                          '<indrisco>' || vr_tab_rating_hist(vr_index_rating_hist).indrisco || '</indrisco>'     ||
                                          '<nrnotrat>' || to_char(vr_tab_rating_hist(vr_index_rating_hist).nrnotrat,'FM999G999G990D00') || '</nrnotrat>'     ||
                                          '<vloperac>' || to_char(vr_tab_rating_hist(vr_index_rating_hist).vloperac,'FM999G999G990D00') || '</vloperac>'     ||
                                          '<dsditrat>' || vr_tab_rating_hist(vr_index_rating_hist).dsditrat || '</dsditrat>'     ||
                          '</ratingHistorico>');

                        vr_index_rating_hist := vr_tab_rating_hist.next(vr_index_rating_hist);
                    end loop;


      pc_escreve_xml('</Proposta>');


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

    -- PARA PROPOSTA
    IF pr_idimpres = 3 THEN
       vr_nmjasper := 'crrl519_proposta.jasper';
       vr_dsxmlnode := '/raiz/Proposta';

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
                                  pr_dsdadatu => rw_craplim.nrctrlim);
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
                                  pr_dsdadatu => rw_craplim.nrctrlim);
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 0      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
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
    --               06/06/2018 - Remoção das restrições da impressão do bordero
    --
    --               16/08/2018 - Zerar o prazo quando o titulo estiver vencido
    --
    --               05/09/2018 - Campos de restrição de volta mas somente para borderos antigos (Vitor S. Assanuma - GFT)
    --
    --               30/10/2018 - Verificação se o borderô está no modelo antigo ou novo. (Vitor S. Assanuma - GFT)
    --
    --               26/11/2018 - Alteração no cálculo de liquidez para mensal para bater com o cálculo inserido na CRAPLJT (Vitor S. Assanuma - GFT)
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
    vr_tab_dados_proposta      typ_tab_dados_proposta;
    vr_tab_emprestimos         EMPR0001.typ_tab_dados_epr;
    vr_tab_grupo               GECO0001.typ_tab_crapgrp;
    vr_tab_rating_hist         typ_tab_rating_hist;

    vr_idxborde                PLS_INTEGER;
    vr_idxord                  VARCHAR2(50);
    vr_idx                     VARCHAR2(50);
    vr_idxrestr                VARCHAR2(100);
    vr_idxsac                  VARCHAR2(100);

    vr_vldjuros NUMBER;
    vr_qtd_dias INTEGER;



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

    vr_vldjurosliq NUMBER;
    vr_dtrefere DATE;
    vr_dtcalcul DATE;
    vr_jurosdia NUMBER;
    vr_vltotjur NUMBER;
    vr_dia INTEGER;

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
                      ,pr_tab_dados_proposta      => vr_tab_dados_proposta
                      ,pr_tab_emprestimos         => vr_tab_emprestimos
                      ,pr_tab_grupo               => vr_tab_grupo
                      ,pr_tab_rating_hist         => vr_tab_rating_hist
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
                         '<nmoperad>'|| vr_tab_dados_itens_bordero(vr_idxborde).nmoperad ||'</nmoperad>' ||
                         '<flgrestr>'|| pr_flgrestr ||'</flgrestr>' ||
                         '<flverbor>'|| vr_tab_dados_itens_bordero(vr_idxborde).flverbor ||'</flverbor>'
                         );


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
        --Verifica se o valor líquido do título é 0, se for calcula
        IF (vr_tab_tit_bordero_ord(vr_idxord).vlliquid = 0 AND vr_tab_dados_itens_bordero(vr_idxborde).flverbor = 1) THEN
          IF  pr_dtmvtolt > vr_tab_tit_bordero_ord(vr_idxord).dtvencto THEN
              vr_qtd_dias := ccet0001.fn_diff_datas(vr_tab_tit_bordero_ord(vr_idxord).dtvencto, pr_dtmvtolt);
          ELSE
              vr_qtd_dias := vr_tab_tit_bordero_ord(vr_idxord).dtvencto -  pr_dtmvtolt;
          END IF;
          --  Percorre a quantidade de dias baseado na data atual até o vencimento do título
          vr_vltotjur    := 0;
          vr_vldjurosliq := 0;
          vr_dtrefere := last_day(pr_dtmvtolt);
          vr_dtcalcul := pr_dtmvtolt;
          vr_jurosdia := ((vr_tab_dados_itens_bordero(vr_idxborde).txmensal / 100) / 30);

          WHILE (vr_qtd_dias > 0) LOOP
            vr_dtcalcul := vr_dtcalcul+1;
            vr_dtrefere := last_day(vr_dtcalcul);
            IF (vr_dtcalcul+vr_qtd_dias) > vr_dtrefere THEN             -- se a ultima data calculada + os dias restantes de juros são maior que a data de referencia
              vr_dia := vr_dtrefere - (vr_dtcalcul-1);                      -- calcula quantos dias terão juros naquele mes
              vr_dtcalcul := vr_dtrefere;                             -- coloca o proximo dia de calculo de juros para o proximo dia da referencia
              vr_qtd_dias := vr_qtd_dias - vr_dia;                       -- tira quantos dias de juros foram calculados do total
            ELSE
              vr_dia := vr_qtd_dias;                                    --
              vr_dtcalcul := vr_dtrefere;
              vr_qtd_dias := 0;
            END IF;

            vr_vldjurosliq := apli0001.fn_round(vr_tab_tit_bordero_ord(vr_idxord).vltitulo * vr_dia * vr_jurosdia,2);        -- calcula o juros em cima dos dias
            vr_vltotjur    := vr_vltotjur + vr_vldjurosliq;
          END LOOP;
          vr_tab_tit_bordero_ord(vr_idxord).vlliquid := apli0001.fn_round(vr_tab_tit_bordero_ord(vr_idxord).vltitulo - vr_vltotjur, 2);
        END IF;

        IF vr_tab_tit_bordero_ord(vr_idxord).dtlibbdt IS NOT NULL THEN
          vr_rel_qtdprazo := vr_tab_tit_bordero_ord(vr_idxord).dtvencto - vr_tab_tit_bordero_ord(vr_idxord).dtlibbdt;
        ELSE
          IF (vr_tab_tit_bordero_ord(vr_idxord).insitapr <> 2) THEN
            vr_rel_qtdprazo := vr_tab_tit_bordero_ord(vr_idxord).dtvencto - pr_dtmvtolt;
          ELSE
            vr_rel_qtdprazo := 0;
          END IF;
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
                          '<dscpfcgc>'||   vr_dscpfcgc                                  ||'</dscpfcgc>');

        -- Caso seja bordero antigo, escreve as restrições
        IF (pr_flgrestr = 1) THEN
          pc_escreve_xml( '<restricoes>');

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

                pc_escreve_xml('<restricao><texto>'|| gene0007.fn_caract_controle(vr_tab_bordero_restri(idx2).dsrestri) ||'</texto>' ||'</restricao>');
                -- Se foi aprovado pelo coordenador
                IF vr_tab_bordero_restri(idx2).flaprcoo = 1 THEN

                  IF NOT vr_tab_restri_apr_coo.exists(vr_tab_bordero_restri(idx2).dsrestri) THEN
                    vr_tab_restri_apr_coo(vr_tab_bordero_restri(idx2).dsrestri) := '';
                  END IF;

                END IF;
              END IF;
            END LOOP;
          END IF;
          pc_escreve_xml('</restricoes>');
        END IF;
        pc_escreve_xml('</titulo>');


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
                          <qtrestri>'|| NVL(vr_tab_totais(idxtot).qtrestri, 0) ||'</qtrestri>
                          <flgrestr>'|| pr_flgrestr ||'</flgrestr>
                        </total>');
        END LOOP;
      END IF;
      pc_escreve_xml('</totais>',TRUE);

      -- Caso seja borderô antigo
      IF (pr_flgrestr = 1) THEN
        -- Se possui restricoes aprovadas pelo coordenador
        IF vr_tab_restri_apr_coo.COUNT > 0 THEN
          pc_escreve_xml(  '<restricoes_coord dsopecoo="'|| vr_tab_dados_itens_bordero(vr_idxborde).dsopecoo ||'">');
          vr_idxrestr := vr_tab_restri_apr_coo.FIRST;
          WHILE vr_idxrestr IS NOT NULL LOOP
            pc_escreve_xml(    '<restricao><texto>'|| gene0007.fn_caract_controle(vr_idxrestr) ||'</texto>' ||
                               '<flgrestr>'|| pr_flgrestr ||'</flgrestr>' ||
            '</restricao>');
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

PROCEDURE pc_gera_extrato_bordero( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
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
                                     ,pr_flgrestr IN INTEGER DEFAULT 0      --> Indicador se deve imprimir restricoes(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Retornar nome do relatorio PDF
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .........................................................................
    --
    --  Programa : pc_gera_extrato_bordero
    --  Sistema  : Cred
    --  Sigla    : DSCT0002
    --  Autor    : Vitor Shimada Assanuma (GFT)
    --  Data     : Agosto/2018.                   Ultima atualizacao: 09/09/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar impressoes de extrato de bordero
    --
    --   Alteração :
    --    16/08/2018 - Vitor Shimada Assanuma (GFT) - Retirando os históricos: 2666 (Rendas à apropriar) e 2678 (Baixa da carteira ao resgatar título)
    --    27/08/2018 - Vitor Shimada Assanuma (GFT) - Incluir mensagem quando bordero em Prejuizo.
    --    05/09/2018 - Andrew Albuquerque     (GFT) - Correções na descrição do histórico e % de multa, taxa mensal e mora.
    --    14/09/2018 - Andrew Albuquerque     (GFT) - Alterada ordenação do dataset principal de extrato, para imprimir todos os Débitos e depois os Créditos.
    --    28/09/2018 - Vitor Shimada Assanuma (GFT) - Valor descontado, somando o valor dos titulos resgatados.
    --    03/10/2018 - Cássia de Oliveira     (GFT) - Alterado regra da situação do titulo.
    --    26/10/2018 - Vitor Shimada Assanuma (GFT) - Retirado o histórico 2763 da listagem.
    --    30/11/2018 - Lucas Negoseki         (GFT) - Retirado diversos históricos de prejuízo da listagem.
    -- .........................................................................*/
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
    vr_vldebito        tbdsct_lancamento_bordero.vllanmto%TYPE;
    vr_vlcredito       tbdsct_lancamento_bordero.vllanmto%TYPE;
    vr_vlsaldo         NUMBER(25,2);
    vr_insitit         VARCHAR2(200);

    --> Buscar dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT *
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper
    ;rw_crapcop cr_crapcop%ROWTYPE;

    --> Buscar dados do bordero
    CURSOR cr_crapbdt IS
      SELECT
        bdt.*,
        ldc.dsdlinha,
        ldc.txjurmor,
        (SELECT COUNT(1)      FROM craptdb WHERE cdcooper = bdt.cdcooper AND nrdconta = bdt.nrdconta AND nrborder = bdt.nrborder) AS qttitbor,
        (SELECT SUM(vltitulo) FROM craptdb WHERE cdcooper = bdt.cdcooper AND nrdconta = bdt.nrdconta AND nrborder = bdt.nrborder AND insitapr <> 2) AS vltitbor,
        (SELECT SUM(tdb.vlsdprej
          + (tdb.vlttjmpr - tdb.vlpgjmpr)
          + (tdb.vlttmupr - tdb.vlpgmupr)
          + (tdb.vljraprj - tdb.vlpgjrpr)) FROM craptdb tdb WHERE cdcooper = bdt.cdcooper AND nrdconta = bdt.nrdconta AND nrborder = bdt.nrborder AND insitapr <> 2) AS vlprjbor -- Saldo atualizado
      FROM crapbdt bdt
        INNER JOIN crapldc ldc ON bdt.cdcooper = ldc.cdcooper AND bdt.cddlinha = ldc.cddlinha AND ldc.tpdescto = 3
      WHERE bdt.cdcooper = pr_cdcooper
        AND bdt.nrdconta = pr_nrdconta
        AND bdt.nrborder = pr_nrborder
    ;rw_crapbdt cr_crapbdt%ROWTYPE;

    --> Buscar dados dos titulos
    CURSOR cr_craptdb IS
      SELECT
        tdb.*,
        DENSE_RANK() OVER (PARTITION BY tdb.nrdconta ORDER BY tdb.dtvencto, tdb.nrtitulo) AS seq
      FROM craptdb tdb
      WHERE tdb.cdcooper = pr_cdcooper
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.nrborder = pr_nrborder
      ORDER BY tdb.dtvencto
    ;
    rw_craptdb cr_craptdb%ROWTYPE;

    --> Buscar dados de lançamentos de bordero
    CURSOR cr_craptlb IS
      SELECT
        tlb.nrdconta,
        tlb.nrborder,
        tlb.nrdocmto,
        tlb.nrtitulo,
        tlb.dtmvtolt,
        tlb.vllanmto,
        CASE WHEN gene0005.fn_valida_dia_util(tdb.cdcooper, tdb.dtvencto) = tlb.dtmvtolt
          THEN 0
          ELSE tdb.dtvencto - tlb.dtmvtolt
        END AS qtdiaatr,
        his.cdhistor,
        -- correção do campo de exibição de descrição no extrato.
        his.dsextrat,
        his.indebcre,
        CASE WHEN (his.indebcre = 'D') THEN tlb.vllanmto ELSE (tlb.vllanmto - tlb.vllanmto*2) END AS vlconvertido,
        CASE WHEN tdb.nrtitulo IS NULL THEN 0 ELSE tdb.seq END as seq
      FROM tbdsct_lancamento_bordero tlb
        LEFT JOIN (SELECT
                    DENSE_RANK() OVER (PARTITION BY tdb.nrdconta ORDER BY tdb.dtvencto, tdb.nrtitulo) AS seq,
                    tdb.cdcooper,
                    tdb.nrdconta,
                    tdb.nrborder,
                    tdb.nrtitulo,
                    tdb.dtvencto,
                    tdb.vltitulo
                  FROM craptdb tdb
                  WHERE tdb.cdcooper = pr_cdcooper
                    AND tdb.nrdconta = pr_nrdconta
                    AND tdb.nrborder = pr_nrborder
                  ORDER BY tdb.dtvencto, tdb.nrtitulo) tdb ON tlb.cdcooper = tdb.cdcooper AND tlb.nrdconta = tdb.nrdconta AND tlb.nrborder = tdb.nrborder AND tlb.nrtitulo = tdb.nrtitulo
        INNER JOIN craphis his ON tlb.cdcooper = his.cdcooper AND tlb.cdhistor = his.cdhistor
      WHERE tlb.cdcooper = pr_cdcooper
        AND tlb.nrdconta = pr_nrdconta
        AND tlb.nrborder = pr_nrborder
        AND his.cdhistor NOT IN (DSCT0003.vr_cdhistordsct_rendaapropr,
                                 DSCT0003.vr_cdhistordsct_apropjurrem,
                                 DSCT0003.vr_cdhistordsct_resgatetitdsc,
                                 DSCT0003.vr_cdhistordsct_jratuprejuz,
                                 PREJ0005.vr_cdhistordsct_principal,
                                 PREJ0005.vr_cdhistordsct_juros_60_rem,
                                 PREJ0005.vr_cdhistordsct_juros_60_mor,
                                 PREJ0005.vr_cdhistordsct_juros_60_mul,
                                 PREJ0005.vr_cdhistordsct_multa_atraso,
                                 PREJ0005.vr_cdhistordsct_juros_mora,
                                 PREJ0005.vr_cdhistordsct_juros_atuali,
                                 -- Retirado para mostrar apenas valor total
                                 PREJ0005.vr_cdhistordsct_rec_principal,
                                 PREJ0005.vr_cdhistordsct_rec_jur_60,
                                 PREJ0005.vr_cdhistordsct_rec_jur_atuali,
                                 PREJ0005.vr_cdhistordsct_rec_mult_atras,
                                 PREJ0005.vr_cdhistordsct_rec_jur_mora,
                                 -- Retirado para mostrar apenas estorno valor total
                                 PREJ0005.vr_cdhistordsct_est_principal,
                                 PREJ0005.vr_cdhistordsct_est_jur_60,
                                 PREJ0005.vr_cdhistordsct_est_jur_prej,
                                 PREJ0005.vr_cdhistordsct_est_mult_atras,
                                 PREJ0005.vr_cdhistordsct_est_jur_mor
                                 )
      ORDER BY tlb.dtmvtolt asc, his.indebcre desc, tlb.nrtitulo ASC, tlb.progress_recid
    ;rw_craptlb cr_craptlb%ROWTYPE;

  BEGIN
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Gerar impressao de extrato de bordero de titulo';
    END IF;

    -- Busca dos dados da cooperativa
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se NAO encontrar
    IF NOT cr_crapcop%FOUND THEN
      CLOSE cr_crapcop;
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapcop;

    -- Busca dos dados do bordero
    OPEN cr_crapbdt;
    FETCH cr_crapbdt INTO rw_crapbdt;
    -- Se NAO encontrar
    IF NOT cr_crapbdt%FOUND THEN
      CLOSE cr_crapbdt;
      vr_cdcritic := 0;
      vr_dscritic := 'Nao foi possivel encontrar Bordero.';
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapbdt;

    -- Buscar diretorio da cooperativa
    vr_dsdireto := GENE0001.fn_diretorio( pr_tpdireto => 'C' --> cooper
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '/rl');

    vr_nmarquiv := 'crrl750_'||pr_dsiduser;

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

    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>');

    -- XML dos dados do BORDERO
    pc_escreve_xml('<Bordero>'||
                      '<nmrescop>'|| TRIM(rw_crapcop.nmrescop)                             ||'</nmrescop>' ||
                      '<nmextcop>'|| TRIM(rw_crapcop.nmextcop)                             ||'</nmextcop>' ||
                      '<dtmvtolt>'|| to_char(pr_dtmvtolt, 'DD/MM/RRRR')                    ||'</dtmvtolt>' ||
                      '<nrdconta>'|| TRIM(GENE0002.fn_mask_conta(pr_nrdconta))             ||'</nrdconta>' ||
                      '<cdagenci>'|| rw_crapbdt.cdagenci                                   ||'</cdagenci>' ||
                      '<nrborder>'|| TRIM(GENE0002.fn_mask_contrato(pr_nrborder))          ||'</nrborder>' ||
                      '<inprejuz>'|| rw_crapbdt.inprejuz                                   ||'</inprejuz>' ||
                      '<dtprejuz>'|| to_char(rw_crapbdt.dtprejuz, 'DD/MM/RRRR')            ||'</dtprejuz>' ||
                      '<vlprjbor>'|| to_char(rw_crapbdt.vlprjbor, 'fm999G999G999G990D00')  ||'</vlprjbor>' ||
                      '<dsdlinha>'|| rw_crapbdt.dsdlinha                                   ||'</dsdlinha>' ||
                      '<qttitbor>'|| rw_crapbdt.qttitbor                                   ||'</qttitbor>' ||
                      '<vltitbor>'|| to_char(rw_crapbdt.vltitbor, 'fm999G999G999G990D00')  ||'</vltitbor>' ||
                      '<txmensal>'|| to_char(rw_crapbdt.txmensal, 'fm9999G999G990D000000') ||'</txmensal>' ||
                      '<txjurmor>'|| to_char(rw_crapbdt.txjurmor, 'fm9999G999G990D000000') ||'</txjurmor>' ||
                      '<vltxmult>'|| to_char(rw_crapbdt.vltxmult, 'fm999G999G999G990D00')  ||'</vltxmult>' ||
                      '<vltxmora>'|| to_char(rw_crapbdt.vltxmora, 'fm9999G999G990D000000') ||'</vltxmora>' ||
                      '<dtlibbdt>'|| to_char(rw_crapbdt.dtlibbdt, 'DD/MM/RRRR')            ||'</dtlibbdt>'
                  );

    -- XML dos TITULOS
    pc_escreve_xml('<titulos>');
    OPEN cr_craptdb();
    LOOP
      FETCH cr_craptdb INTO rw_craptdb;
      EXIT  WHEN cr_craptdb%NOTFOUND;
      --Verifica a situacao do titulo
      IF rw_craptdb.insittit = 2 AND rw_craptdb.dtdpagto > gene0005.fn_valida_dia_util(rw_craptdb.cdcooper, rw_craptdb.dtvencto) THEN
        vr_insitit := 'Pago após vencimento';
      --Verifica se o titulo está vencido
      ELSIF (rw_craptdb.insittit NOT IN (1,2,3)) AND rw_craptdb.insitapr <> 2
       AND (gene0005.fn_valida_dia_util(rw_craptdb.cdcooper, rw_craptdb.dtvencto) < pr_dtmvtolt) THEN
         vr_insitit := 'Vencido';
      ELSE
        vr_insitit := dsct0003.fn_busca_situacao_titulo(rw_craptdb.insittit, 1);
      END IF;
      pc_escreve_xml('<titulo>' ||
                         '<nrseqtit>'|| rw_craptdb.seq                                         ||'</nrseqtit>' ||
                         '<dtvencto>'|| to_char(rw_craptdb.dtvencto, 'DD/MM/RRRR')             ||'</dtvencto>' ||
                         '<vltitulo>'|| to_char(rw_craptdb.vltitulo, 'fm999G999G999G990D00')   ||'</vltitulo>' ||
                         '<insittit>'|| vr_insitit                                             ||'</insittit>' ||
                     '</titulo>'
                    );
    END LOOP;
    pc_escreve_xml('</titulos>');

    -- XML dos Lançamentos
    pc_escreve_xml('<bdtlancs>');
    vr_vlsaldo := 0;
    OPEN cr_craptlb();
    LOOP
      FETCH cr_craptlb INTO rw_craptlb;
      EXIT  WHEN cr_craptlb%NOTFOUND;
      -- Atualiza o saldo
      vr_vlsaldo := vr_vlsaldo + rw_craptlb.vlconvertido;

      -- Caso seja Debito colocar o valor no débito e zerar crédito.
      IF rw_craptlb.indebcre = 'D' THEN
        vr_vldebito  := rw_craptlb.vllanmto;
        vr_vlcredito := 0;
      ELSE
        vr_vldebito  := 0;
        vr_vlcredito := rw_craptlb.vllanmto;
      END IF;

      -- Caso os dias de atraso seja positivo (Nao esta em atraso), entao zera.
      IF rw_craptlb.qtdiaatr > 0 THEN
        rw_craptlb.qtdiaatr := 0;
      END IF;

      pc_escreve_xml('<bdtlanc>' ||
                         '<nrseqtit>'|| rw_craptlb.seq                                ||'</nrseqtit>' ||
                         '<dtmvtolt>'|| to_char(rw_craptlb.dtmvtolt, 'DD/MM/RRRR')    ||'</dtmvtolt>' ||
                         '<dshistor>'|| rw_craptlb.dsextrat                           ||'</dshistor>' ||
                         '<qtdiaatr>'|| ABS(rw_craptlb.qtdiaatr)                      ||'</qtdiaatr>' ||
                         '<nrtitulo>'|| rw_craptlb.nrtitulo                           ||'</nrtitulo>' ||
                         '<vldebito>'|| to_char(vr_vldebito, 'fm999G999G999G990D00')  ||'</vldebito>' ||
                         '<vlcredit>'|| to_char(vr_vlcredito, 'fm999G999G999G990D00') ||'</vlcredit>' ||
                         '<vldsaldo>'|| to_char(vr_vlsaldo, 'fm999G999G999G990D00')   ||'</vldsaldo>' ||
                     '</bdtlanc>'
                    );
    END LOOP;
    pc_escreve_xml('</bdtlancs>');
    pc_escreve_xml('</Bordero></raiz>',TRUE);

    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => 'ATENDA'
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz/Bordero'
                               , pr_dsjasper  => 'crrl750_bordero_extrato.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto||'/'||pr_nmarqpdf
                               , pr_cdrelato => 750
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
END pc_gera_extrato_bordero;

PROCEDURE pc_efetua_analise_pagador  ( pr_cdcooper IN crapsab.cdcooper%TYPE  --> Código da Cooperativa do Pagador (Sacado)
                                        ,pr_nrdconta IN crapsab.nrdconta%TYPE DEFAULT NULL  --> Número da Conta do Pagador       (Sacado)
                                        ,pr_nrinssac IN crapsab.nrinssac%TYPE DEFAULT NULL  --> Número de Inscrição do Pagador   (Sacado)
                                         --------------> OUT <--------------
                                        ,pr_cdcritic          OUT PLS_INTEGER  --> Código da crítica
                                        ,pr_dscritic          OUT VARCHAR2     --> Descrição da crítica
                                        ) IS
    -------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_efetua_analise_pagador
    --  Sistema  : CRED (DSCT)
    --  Sigla    : DSCT0002
    --  Autor    : Gustavo Guedes de Sene (GFT)
    --  Data     : Março/2018                    Ultima atualizacao: 13/03/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Diário (via JOB)
    --   Objetivo  : Procedure para analisar e validar as possíveis críticas
    --               para um Limite de Desconto de Títulos.
    --
    --   Histórico de Alterações:
    --    13/03/2018 - Versão Inicial (Criação) - Gustavo Guedes de Sene (GFT)
    --    03/05/2018 - Remocao do campo invalormax_cnae, alterado o calculado para uma funcao em DSCT0003.fn_calcula_cnae()
    --    24/05/2018 - Inserção da procedure generica de calculo de liquidez - Vitor Shimada Assanuma (GFT)
    -------------------------------------------------------------------------------------------------

    ----------------------> VARIAVEIS <----------------------

    -- Variáveis de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    -- Demais variáveis
    vr_flcrapsab           boolean;
    vr_vlliquidez          number;
    vr_qtliquidez          number;
    vr_conjuge             integer;
    vr_socio               integer;
    vr_coop_tit_conta_pag  integer;
    vr_concentracao_maxima number;
    --
    vr_inpossui_criticas   integer;
    --
    vr_tab_dados_dsctit    typ_tab_dados_dsctit;
    vr_tab_dados_dsctit_fis    typ_tab_dados_dsctit;
    vr_tab_dados_dsctit_jur    typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   typ_tab_cecred_dsctit;
    vr_tab_analise_pagador tpy_tab_analise_pagador;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    --Variaveis da liquidez
    vr_vlconcentracao NUMBER(25,2);
    vr_qtconcentracao NUMBER(25,2);

--    vr_tempo INTEGER;

    ----------------------> CURSORES <----------------------

    -- PASSO 1: OBTENÇÃO DOS REGISTROS SUJEITOS À ANÁLISE --
    --
    -- [PAGADORES] - Obter dados dos Pagadores a serem analisados
    CURSOR cr_crapsab IS
     SELECT pag.cdcooper,
            pag.nrdconta,
            pag.nrinssac,
            pag.cdtpinsc,
            ass.inpessoa,
            ass.nrcpfcgc
       FROM crapsab pag, crapass ass
      WHERE pag.cdcooper = pr_cdcooper
      AND pag.nrdconta = pr_nrdconta
      AND pag.nrinssac = nvl(pr_nrinssac, pag.nrinssac)
        AND ass.cdcooper = pag.cdcooper
        AND ass.nrdconta = pag.nrdconta
        AND EXISTS (SELECT 1
               FROM crapcob cob -- Boletos de Cobrança
              WHERE cob.cdcooper = pag.cdcooper
                AND cob.nrdconta = pag.nrdconta
                AND cob.nrinssac = pag.nrinssac
                AND cob.incobran = 0 -- Cobrança em aberto
                AND cob.flgregis = 1
                AND cob.dtvencto > rw_crapdat.dtmvtolt);

    rw_crapsab cr_crapsab%rowtype;


    -- PASSO 2: OBTENÇÃO DOS VALORES A SEREM COMPARADOS AOS PARÂMETROS DA TAB052, CADPCN e CADPCP --
    --
    -- [PAGADORES] - Obter Qtd. de Títulos Remetidos ao Cartório do Sacado (Pagador) para o Cedente em questão
    cursor cr_qt_remessa_cartorio is
    select count(1) qt_tit_remessa
    from   crapcco cco,
           crapceb ceb,
           crapcob cob,
           crapret ret
    where  cco.cdcooper = rw_crapsab.cdcooper
    and    cco.flgregis = 1 -- Cobrança Registrada em Cartório
    and    ceb.cdcooper = cco.cdcooper
    and    ceb.cdcooper = rw_crapsab.cdcooper
    and    ceb.nrconven = cco.nrconven
    and    ceb.nrdconta = rw_crapsab.nrdconta
    --
    and    cob.cdcooper = ceb.cdcooper
    and    cob.nrdconta = ceb.nrdconta
    and    cob.nrcnvcob = ceb.nrconven
    AND    cob.dtmvtolt >= add_months(rw_crapdat.dtmvtolt,-12)
    --
    and    cob.nrinssac = rw_crapsab.nrinssac
    --
    and    ret.cdcooper = cob.cdcooper
    and    ret.nrdconta = cob.nrdconta
    and    ret.nrcnvcob = cob.nrcnvcob
    and    ret.nrdocmto = cob.nrdocmto
    and    ret.cdocorre = 23; -- Remetidos ao Cartório
    rw_qt_remessa_cartorio cr_qt_remessa_cartorio%rowtype;

    -- [PAGADORES] - Obter Qtd. de Títulos Protestados do Sacado (Pagador) para o Cedente em questão
    cursor cr_qt_protestados is
    select count(1) qt_tit_protestados
    from   crapcco cco,
           crapceb ceb,
           crapcob cob,
           crapret ret
    where  cco.cdcooper = rw_crapsab.cdcooper
    and    cco.flgregis = 1 -- Cobrança Registrada em Cartório
    and    ceb.cdcooper = cco.cdcooper
    and    ceb.cdcooper = rw_crapsab.cdcooper
    and    ceb.nrconven = cco.nrconven
    and    ceb.nrdconta = rw_crapsab.nrdconta
    --
    and    cob.cdcooper = ceb.cdcooper
    and    cob.nrdconta = ceb.nrdconta
    and    cob.nrcnvcob = ceb.nrconven
    AND    cob.dtmvtolt >= add_months(rw_crapdat.dtmvtolt,-12)
    --
    and    cob.incobran = 3 -- Baixado
    --
    and    cob.nrinssac = rw_crapsab.nrinssac
    --
    and    ret.cdcooper = cob.cdcooper
    and    ret.nrdconta = cob.nrdconta
    and    ret.nrcnvcob = cob.nrcnvcob
    and    ret.nrdocmto = cob.nrdocmto
    and    ret.cdocorre = 9 -- Protestados
    --
    and    ret.cdmotivo = '14';
    rw_qt_protestados cr_qt_protestados%rowtype;

    -- [PAGADORES] - Obter Qtd. de Títulos Não Pagos pelo Sacado (Pagador) em questão
    cursor cr_qt_nao_pagos is
    select count(1) qt_tit_nao_pagos
    from   crapcob cob
    where  cob.incobran = 0
    and    cob.cdcooper = rw_crapsab.cdcooper
    and    cob.nrdconta = rw_crapsab.nrdconta
    AND    cob.dtvencto < rw_crapdat.dtmvtolt
    AND    cob.dtmvtolt >= add_months(rw_crapdat.dtmvtolt,-6)
    and    cob.nrinssac = rw_crapsab.nrinssac;
    rw_qt_nao_pagos cr_qt_nao_pagos%rowtype;

    -- [PAGADORES] - Verificar se o emitente é Cônjuge/Sócio do Pagador
    --
    -- Cônjuge
    cursor cr_conjuge is
      select  1
        from  crapcje cje
       where  cje.cdcooper = rw_crapsab.cdcooper
         and  cje.nrdconta = rw_crapsab.nrdconta
         and (cje.nrctacje = rw_crapsab.nrdconta or cje.nrcpfcjg = rw_crapsab.nrinssac);
    rw_conjuge cr_conjuge%rowtype;

    -- Sócio
    cursor cr_socio is
      select  1
        from  crapavt avt
       where  avt.cdcooper = rw_crapsab.cdcooper
         and  avt.nrdconta = rw_crapsab.nrdconta
         and (avt.nrdctato = rw_crapsab.nrdconta or avt.nrcpfcgc = rw_crapsab.nrinssac)
         and  avt.tpctrato = 6
         and  avt.dsproftl = 'SOCIO/PROPRIETARIO';
    rw_socio cr_socio%rowtype;

    -- [PAGADORES] - Verificar se Cooperado Possui Títulos Descontados na Conta do Pagador
    CURSOR cr_coop_tit_conta_pag is
    SELECT COUNT(1) tem_tit_conta_pag
    FROM   craptdb tdb
    WHERE tdb.cdcooper = pr_cdcooper
      AND tdb.nrinssac = rw_crapsab.nrcpfcgc -- cedente
      AND tdb.dtresgat is null and tdb.dtlibbdt is not null -- titulos descontados
      AND tdb.nrdconta in (select nrdconta -- busca conta do pagador
                            from crapass rem
                           where rem.nrcpfcgc     = rw_crapsab.nrinssac --pagador
                             and rem.cdcooper     = pr_cdcooper);
    rw_coop_tit_conta_pag cr_coop_tit_conta_pag%rowtype;

    PROCEDURE pc_resetar_flag_analise is
    BEGIN
       vr_tab_analise_pagador(1).qtremessa_cartorio := 0;
       vr_tab_analise_pagador(1).qttit_protestados  := 0;
       vr_tab_analise_pagador(1).qttit_naopagos     := 0;
       vr_tab_analise_pagador(1).pemin_liquidez_qt  := 0;
       vr_tab_analise_pagador(1).pemin_liquidez_vl  := 0;
       vr_tab_analise_pagador(1).peconcentr_maxtit  := 0;
       vr_tab_analise_pagador(1).inemitente_conjsoc := 0;
       vr_tab_analise_pagador(1).inpossui_titdesc   := 0;

       vr_inpossui_criticas := 0;
       vr_conjuge := 0;
       vr_socio := 0;

    END;


    PROCEDURE pc_inserir_analise(pr_cdcooper in crapsab.cdcooper%type --> Código da Cooperativa do Pagador
                                ,pr_nrdconta in crapsab.nrdconta%type --> Número da Conta do Pagador
                                ,pr_nrinssac in crapsab.nrinssac%type --> Número de Inscrição do Pagador
                                 --------> OUT <--------
                                ,pr_dscritic out varchar2             --> Descrição da crítica
                                                         ) IS

    BEGIN
        update tbdsct_analise_pagador
           set dtanalise          = SYSDATE
              ,hranalise          = to_char(SYSDATE,'sssss')
              ,qtremessa_cartorio = vr_tab_analise_pagador(1).qtremessa_cartorio
              ,qttit_protestados  = vr_tab_analise_pagador(1).qttit_protestados
              ,qttit_naopagos     = vr_tab_analise_pagador(1).qttit_naopagos
              ,pemin_liquidez_qt  = vr_tab_analise_pagador(1).pemin_liquidez_qt
              ,pemin_liquidez_vl  = vr_tab_analise_pagador(1).pemin_liquidez_vl
              ,peconcentr_maxtit  = vr_tab_analise_pagador(1).peconcentr_maxtit
              ,inemitente_conjsoc = vr_tab_analise_pagador(1).inemitente_conjsoc
              ,inpossui_titdesc   = vr_tab_analise_pagador(1).inpossui_titdesc
              ,inpossui_criticas  = vr_inpossui_criticas
        where  cdcooper = pr_cdcooper
          and  nrdconta = pr_nrdconta
          and  nrinssac = pr_nrinssac;
       IF SQL%NOTFOUND THEN
       insert into tbdsct_analise_pagador
              (cdcooper
              ,nrdconta
              ,nrinssac
              ,dtanalise
              ,hranalise
              ,qtremessa_cartorio
              ,qttit_protestados
              ,qttit_naopagos
              ,pemin_liquidez_qt
              ,pemin_liquidez_vl
              ,peconcentr_maxtit
              ,inemitente_conjsoc
              ,inpossui_titdesc
              ,inpossui_criticas)
       values (pr_cdcooper
              ,pr_nrdconta
              ,pr_nrinssac
              ,SYSDATE
              ,to_char(SYSDATE,'sssss')
              ,vr_tab_analise_pagador(1).qtremessa_cartorio
              ,vr_tab_analise_pagador(1).qttit_protestados
              ,vr_tab_analise_pagador(1).qttit_naopagos
              ,vr_tab_analise_pagador(1).pemin_liquidez_qt
              ,vr_tab_analise_pagador(1).pemin_liquidez_vl
              ,vr_tab_analise_pagador(1).peconcentr_maxtit
              ,vr_tab_analise_pagador(1).inemitente_conjsoc
              ,vr_tab_analise_pagador(1).inpossui_titdesc
              ,vr_inpossui_criticas);
       END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao gravar o registro tbdsct_analise_pagador: '|| sqlerrm;
    END;

  BEGIN

   -- Verificar se a data existe
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_cdcritic := 1;
         raise vr_exc_erro;
   end   if;
   close btch0001.cr_crapdat;

   -- Início da Validação das regras do Pagador --
   vr_flcrapsab := false;


         pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                   ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                   ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                   ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                   ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                   ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                   ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                   ,pr_inpessoa          => 1
                                   ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit_fis  --> Tabela contendo os parametros da cooperativa
                                   ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);
   if  nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
       raise vr_exc_erro;
   end if;

   pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                   ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                   ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                   ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                   ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                   ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                   ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                   ,pr_inpessoa          => 2
                                   ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit_jur  --> Tabela contendo os parametros da cooperativa
                                   ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);
         if  nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
             raise vr_exc_erro;
         end if;

   FOR rw_crapsab IN cr_crapsab LOOP

         vr_flcrapsab := true;

         IF (rw_crapsab.inpessoa=1) THEN
            vr_tab_dados_dsctit := vr_tab_dados_dsctit_fis;
         ELSE
            vr_tab_dados_dsctit := vr_tab_dados_dsctit_jur;
         END IF;

         pc_resetar_flag_analise;

         --  QTREMESSA_CARTORIO : Qtd Remessa em Cartório acima do permitido. (Ref. TAB052: qtremcrt)
         open  cr_qt_remessa_cartorio;
         fetch cr_qt_remessa_cartorio into rw_qt_remessa_cartorio;
         close cr_qt_remessa_cartorio;

         if  rw_qt_remessa_cartorio.qt_tit_remessa > vr_tab_dados_dsctit(1).qtremcrt then
             vr_tab_analise_pagador(1).qtremessa_cartorio := rw_qt_remessa_cartorio.qt_tit_remessa;
             vr_inpossui_criticas := 1;
         end if;

         --  QTTIT_PROTESTADOS  : Qtd de Títulos Protestados acima do permitido. (Ref. TAB052: qttitprt)
         open  cr_qt_protestados;
         fetch cr_qt_protestados into rw_qt_protestados;
         close cr_qt_protestados;

         if  rw_qt_protestados.qt_tit_protestados > vr_tab_dados_dsctit(1).qttitprt then
             vr_tab_analise_pagador(1).qttit_protestados := rw_qt_protestados.qt_tit_protestados;
             vr_inpossui_criticas := 1;
         end if;

         --  QTTIT_NAOPAGOS     : Qtd de Títulos Não Pagos pelo Pagador acima do permitido. (Ref. TAB052: qtnaopag)
         open  cr_qt_nao_pagos;
         fetch cr_qt_nao_pagos into rw_qt_nao_pagos;
         close cr_qt_nao_pagos;

         if  rw_qt_nao_pagos.qt_tit_nao_pagos > vr_tab_dados_dsctit(1).qtnaopag then
             vr_tab_analise_pagador(1).qttit_naopagos := rw_qt_nao_pagos.qt_tit_nao_pagos;
             vr_inpossui_criticas := 1;
         end if;
         --

         --  INEMITENTE_CONJSOC : Emitente é Cônjuge/Sócio do Pagador (0 = Não / 1 = Sim). (Ref. TAB052: flemipar)
         open  cr_conjuge;
         fetch cr_conjuge into rw_conjuge;
         if    cr_conjuge%found then
               vr_conjuge := 1;
         end if;
         close cr_conjuge;

         open  cr_socio;
         fetch cr_socio into rw_socio;
         if    cr_socio%found then
               vr_socio := 1;
         end if;
         close cr_socio;

         if  vr_tab_dados_dsctit(1).flemipar = 1 and ( nvl(vr_conjuge, 0) > 0 or nvl(vr_socio, 0) > 0 ) then
             vr_tab_analise_pagador(1).inemitente_conjsoc := 1;
             vr_inpossui_criticas := 1;
         end if;

         --  INPOSSUI_TITDESC   : Cooperado possui Títulos Descontados na Conta deste Pagador  (0 = Não / 1 = Sim). (Ref. TAB052: flpdctcp)
         if vr_tab_dados_dsctit(1).flpdctcp = 1 then
           open  cr_coop_tit_conta_pag;
           fetch cr_coop_tit_conta_pag into rw_coop_tit_conta_pag;
           if    cr_coop_tit_conta_pag%found then
                 vr_coop_tit_conta_pag := rw_coop_tit_conta_pag.tem_tit_conta_pag;
           end if;
           close cr_coop_tit_conta_pag;


           if  nvl(vr_coop_tit_conta_pag, 0) > 0 then
               vr_tab_analise_pagador(1).inpossui_titdesc := 1;
               vr_inpossui_criticas := 1;
           end if;

         end if;

         pc_inserir_analise(pr_cdcooper => rw_crapsab.cdcooper
                           ,pr_nrdconta => rw_crapsab.nrdconta
                           ,pr_nrinssac => rw_crapsab.nrinssac
                           ,pr_dscritic => vr_dscritic);

         if  trim(vr_dscritic) is not null then
             raise vr_exc_erro;
         end if;

         pc_atualiza_calculos_pagador (pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => rw_crapsab.nrdconta
                                      ,pr_nrinssac => rw_crapsab.nrinssac
                                      ,pr_dtmvtolt_de => rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                                      ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                      ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                                      ,pr_qttliqcp => vr_tab_dados_dsctit(1).qttliqcp
                                      ,pr_vltliqcp => vr_tab_dados_dsctit(1).vltliqcp
                                      ,pr_pcmxctip => vr_tab_dados_dsctit(1).pcmxctip
                                      ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                                      ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                                      ,pr_flforcar => TRUE
                                      --------------> OUT <--------------
                                      ,pr_pc_cedpag  => vr_vlliquidez
                                      ,pr_qtd_cedpag => vr_qtliquidez
                                      ,pr_pc_conc    => vr_vlconcentracao
                                      ,pr_qtd_conc   => vr_qtconcentracao
                                      ,pr_cdcritic   => pr_cdcritic
                                      ,pr_dscritic   => pr_dscritic
                                      );
         COMMIT;
   END LOOP;

   if  not(vr_flcrapsab) then
       vr_cdcritic := 0;
       vr_dscritic := 'Dados do Pagador não encontrados.';
       raise vr_exc_erro;
   end if;
   -- Fim validação das regras do Pagador --


  EXCEPTION
   WHEN vr_exc_erro THEN
        IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        END IF;

   WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Nao foi possivel efetuar a analise diaria dos Pagadores: ' || SQLERRM, chr(13)),chr(10));

  END pc_efetua_analise_pagador;

  PROCEDURE pc_atualiza_calculos_pagador ( pr_cdcooper IN crapsab.cdcooper%TYPE  --> Código da Cooperativa do Pagador (Sacado)
                                   ,pr_nrdconta IN crapsab.nrdconta%TYPE  --> Número da Conta do Pagador       (Sacado)
                                   ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Número de Inscrição do Pagador   (Sacado)
                                   ,pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE DEFAULT NULL --> Data inicial para calculo da liquidez
                                   ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE DEFAULT NULL --> Data final para calculo da liquidez
                                   ,pr_qtcarpag     IN NUMBER DEFAULT NULL   --> Quantidade de dias apos vencimento de carencia
                                   ,pr_qttliqcp     IN NUMBER DEFAULT NULL   --> Quantidade limite para liquidez
                                   ,pr_vltliqcp     IN NUMBER DEFAULT NULL   --> Valor limite para liquidez
                                   ,pr_pcmxctip     IN NUMBER DEFAULT NULL   --> Valor limite para concentracao
                                   ,pr_qtmitdcl     IN INTEGER DEFAULT NULL  --> Quantidade minima de titulos para calculo de liquidez
                                   ,pr_vlmintcl     IN NUMBER DEFAULT NULL   --> Valor minimo para titulo entrar no calculo de liquidez
                                   ,pr_flforcar     IN BOOLEAN DEFAULT FALSE --> Força os cálculos independente se houve job no d-1
                                   --------------> OUT <--------------
                                   ,pr_pc_cedpag    OUT NUMBER
                                   ,pr_qtd_cedpag   OUT NUMBER
                                   ,pr_pc_conc      OUT NUMBER
                                   ,pr_qtd_conc     OUT NUMBER
                                   ,pr_cdcritic          OUT PLS_INTEGER  --> Código da crítica
                                   ,pr_dscritic          OUT VARCHAR2     --> Descrição da crítica
                                  ) IS
    -------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_atualiza_calculos_pagador
    --  Sistema  : CRED (DSCT)
    --  Sigla    : DSCT0002
    --  Autor    : Luis Fernando (GFT)
    --  Data     : Julho/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado
    --   Objetivo  : Procedure para recalcular concentracao e liquidez de determinado pagador na conta.
    --               Atualiza caso tenha dado crítica no valor da crítica. Atualiza os valores atuais na tabela de analise de pagador
    --
    --   Alteracoes: 13/08/2018 - Adicionado novos parametros para o calculo de liquidez - Luis Fernando (GFT)
    -------------------------------------------------------------------------------------------------

    -- Variáveis de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    -- Caso houver exceção de Concentração Máxima cadastrada...
    CURSOR cr_concentracao_excecao IS
    SELECT
           pag.vlpercen pe_conc_excecao
    FROM
           crapsab pag
    WHERE
           pag.cdcooper = pr_cdcooper
           AND pag.nrdconta = pr_nrdconta
           AND pag.nrinssac = pr_nrinssac
           AND pag.vlpercen > 0
    ;
    rw_concentracao_excecao cr_concentracao_excecao%rowtype;

    -- Cursor para pegar o tipo do cooperado
    CURSOR cr_crapass IS
      SELECT
      inpessoa
      FROM
      crapass ass
      WHERE
      nrdconta = pr_nrdconta
      AND cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor para verificar se ainda mantem as criticas
    CURSOR cr_analise_pagador IS
      SELECT
        *
      FROM
        tbdsct_analise_pagador
      WHERE
        cdcooper = pr_cdcooper
        AND nrdconta = pr_nrdconta
        AND nrinssac = pr_nrinssac
    ;
    rw_analise_pagador tbdsct_analise_pagador%ROWTYPE;

    vr_concentracao_maxima NUMBER := 0;
    vr_inpossui_criticas   NUMBER := 0;
    -- Critica
    vr_cri_liquidez_qt NUMBER := 0;
    vr_cri_liquidez_vl NUMBER := 0;
    vr_cri_concentr_maxtit NUMBER := 0;

    -- Caso nao passe por parametro os dados da tab052
    vr_qtcarpag  NUMBER;
    vr_qttliqcp  NUMBER;
    vr_vltliqcp  NUMBER;
    vr_pcmxctip  NUMBER;
    vr_qtmitdcl  INTEGER;
    vr_vlmintcl  NUMBER;
    vr_dtmvtolt_de crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt_ate crapdat.dtmvtolt%TYPE;
    vr_tab_dados_dsctit    typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   typ_tab_cecred_dsctit;
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    BEGIN
      OPEN cr_analise_pagador;
      FETCH cr_analise_pagador INTO rw_analise_pagador;
      IF (cr_analise_pagador%NOTFOUND) THEN
        CLOSE cr_analise_pagador;
        vr_dscritic := 'Erro ao carregar críticas de pagador';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_analise_pagador;
      -- Verificar se a data existe
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      IF    btch0001.cr_crapdat%notfound then
            CLOSE btch0001.cr_crapdat;
            vr_cdcritic := 1;
            RAISE vr_exc_erro;
      END   IF;
      close btch0001.cr_crapdat;




      IF (pr_qtcarpag IS NULL OR pr_qttliqcp IS NULL OR pr_vltliqcp IS NULL OR pr_pcmxctip IS NULL OR pr_dtmvtolt_de IS NULL OR pr_qtmitdcl IS NULL OR pr_vlmintcl is NULL) THEN
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%NOTFOUND THEN
          vr_cdcritic := 1187;
          RAISE vr_exc_erro;
        END IF;

        pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                   ,pr_cdagenci          => null -- Não utiliza dentro da procedure
                                   ,pr_nrdcaixa          => null -- Não utiliza dentro da procedure
                                   ,pr_cdoperad          => null -- Não utiliza dentro da procedure
                                   ,pr_dtmvtolt          => null -- Não utiliza dentro da procedure
                                   ,pr_idorigem          => null -- Não utiliza dentro da procedure
                                   ,pr_tpcobran          => 1    -- Tipo de Cobrança: 0 = Sem Registro / 1 = Com Registro
                                   ,pr_inpessoa          => rw_crapass.inpessoa
                                   ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                   ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);

         vr_qtcarpag  := vr_tab_dados_dsctit(1).cardbtit_c;
         vr_qttliqcp  := vr_tab_dados_dsctit(1).qttliqcp;
         vr_vltliqcp  := vr_tab_dados_dsctit(1).vltliqcp;
         vr_pcmxctip  := vr_tab_dados_dsctit(1).pcmxctip;
         vr_qtmitdcl  := vr_tab_dados_dsctit(1).qtmitdcl;
         vr_vlmintcl  := vr_tab_dados_dsctit(1).vlmintcl;
         vr_dtmvtolt_de := rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30;
         vr_dtmvtolt_ate := rw_crapdat.dtmvtolt;
      ELSE
        vr_qtcarpag := pr_qtcarpag;
        vr_qttliqcp := pr_qttliqcp;
        vr_vltliqcp := pr_vltliqcp;
        vr_pcmxctip := pr_pcmxctip;
        vr_dtmvtolt_de := pr_dtmvtolt_de;
        vr_dtmvtolt_ate:= pr_dtmvtolt_ate;
        vr_qtmitdcl  := pr_qtmitdcl;
        vr_vlmintcl  := pr_vlmintcl;
      END IF;



      DSCT0003.pc_calcula_concentracao(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrinssac => pr_nrinssac
                     ,pr_dtmvtolt_de => vr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => vr_dtmvtolt_ate
                     ,pr_qtcarpag => vr_qtcarpag
                     ,pr_qtmitdcl => vr_qtmitdcl
                     ,pr_vlmintcl => vr_vlmintcl
                    -- OUT --
                    ,pr_pc_conc      => pr_pc_conc
                    ,pr_qtd_conc     => pr_qtd_conc
                    );

      --  PECONCENTR_MAXTIT  : Perc. Concentração Máxima Permitida de Títulos excedida. (Ref. TAB052: pcmxctip)
      OPEN  cr_concentracao_excecao;
      FETCH cr_concentracao_excecao into rw_concentracao_excecao;
      --    Se houver exceção cadastrada na CADPCP, e ela for maior que o valor da TAB052, será considerada a exceção.
      IF    cr_concentracao_excecao%found and rw_concentracao_excecao.pe_conc_excecao > vr_pcmxctip THEN
            vr_concentracao_maxima := rw_concentracao_excecao.pe_conc_excecao;
      ELSE
            vr_concentracao_maxima := vr_pcmxctip;
      END IF;
      CLOSE cr_concentracao_excecao;
      IF  pr_pc_conc > vr_concentracao_maxima then
          vr_cri_concentr_maxtit := pr_pc_conc;
          vr_inpossui_criticas := 1;
      END IF;


      IF (pr_flforcar) THEN
        DSCT0003.pc_calcula_liquidez_pagador(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrinssac => pr_nrinssac
                     ,pr_dtmvtolt_de => vr_dtmvtolt_de
                     ,pr_dtmvtolt_ate => vr_dtmvtolt_ate
                     ,pr_qtcarpag => vr_qtcarpag
                     ,pr_qtmitdcl => vr_qtmitdcl
                     ,pr_vlmintcl => vr_vlmintcl
                       -- OUT --
                    ,pr_pc_cedpag    => pr_pc_cedpag
                    ,pr_qtd_cedpag   => pr_qtd_cedpag
       );

       --  PEMIN_LIQUIDEZ_QT  : Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos).  (Ref. TAB052: qttliqcp)
       if  pr_qtd_cedpag < vr_qttliqcp then
           vr_cri_liquidez_qt := pr_qtd_cedpag;
           vr_inpossui_criticas := 1;
       end if;

       --  PEMIN_LIQUIDEZ_VL  : Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos).  (Ref. TAB052: vltliqcp)
       if  pr_pc_cedpag < vr_vltliqcp then
           vr_cri_liquidez_vl := pr_pc_cedpag;
           vr_inpossui_criticas := 1;
       end if;

     ELSE
       vr_cri_liquidez_qt := rw_analise_pagador.pemin_liquidez_qt;
       vr_cri_liquidez_vl := rw_analise_pagador.pemin_liquidez_vl;
       pr_qtd_cedpag      := rw_analise_pagador.perc_liquidez_qt;
       pr_pc_cedpag       := rw_analise_pagador.perc_liquidez_vl;
       END IF;

       vr_inpossui_criticas := CASE WHEN (nvl(rw_analise_pagador.qtremessa_cartorio,0)
                                            + nvl(rw_analise_pagador.qttit_protestados,0)
                                            + nvl(rw_analise_pagador.qttit_naopagos,0)
                                            + nvl(rw_analise_pagador.pemin_liquidez_qt,0)
                                            + nvl(rw_analise_pagador.pemin_liquidez_vl,0)
                                            + nvl(rw_analise_pagador.peconcentr_maxtit,0)
                                            + nvl(rw_analise_pagador.inemitente_conjsoc,0)
                                            + nvl(rw_analise_pagador.inpossui_titdesc,0)
                                            + nvl(rw_analise_pagador.invalormax_cnae,0)
                                            + vr_inpossui_criticas
                                          ) > 0 THEN 1 ELSE 0 END;

       UPDATE tbdsct_analise_pagador
           SET dtanalise          = SYSDATE
              ,hranalise          = to_char(SYSDATE,'sssss')
              ,pemin_liquidez_qt  = vr_cri_liquidez_qt
              ,pemin_liquidez_vl  = vr_cri_liquidez_vl
              ,peconcentr_maxtit  = vr_cri_concentr_maxtit
              ,inpossui_criticas  = vr_inpossui_criticas
              ,perc_liquidez_qt = pr_qtd_cedpag
              ,perc_liquidez_vl = pr_pc_cedpag
              ,perc_concentracao= pr_pc_conc
        WHERE
          cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta
         AND nrinssac = pr_nrinssac;


      EXCEPTION
       WHEN vr_exc_erro THEN
            IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            ELSE
                pr_cdcritic := vr_cdcritic;
                pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
            END IF;

       WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := replace(replace('Nao foi calcular os dados dos pagadores: ' || SQLERRM, chr(13)),chr(10));
  END pc_atualiza_calculos_pagador;

  PROCEDURE pc_analise_pagador_paralelo (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                 ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica

    vr_exc_erro        EXCEPTION;
    vr_dstextab        NUMBER;
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro

    --Definicao das tabelas de memoria
    vr_tab_agendto PAGA0001.typ_tab_agendto;

    vr_cdprogra VARCHAR2(50) := 'PAGADOR';
    vr_idparale INTEGER;
    vr_qtdjobs             number;
    vr_qterro              number := 0;
    vr_jobname             varchar2(30);
    vr_dsplsql             varchar2(4000);

    CURSOR cr_crapage IS
      SELECT  crapage.cdagenci
             ,crapage.nmresage
      FROM  crapage
       where crapage.cdcooper = pr_cdcooper
         AND crapage.cdagenci <> 999
    ;
    BEGIN
      vr_idparale := gene0001.fn_gera_id_paralelo;
      vr_qtdjobs := gene0001.fn_retorna_qt_paralelo(pr_cdcooper --> Código da coopertiva
                                                   ,vr_cdprogra --> Código do programa
                                                   );
      FOR reg_crapage in cr_crapage LOOP
        vr_jobname := vr_cdprogra ||'_'|| reg_crapage.cdagenci || '$';
        -- Cadastra o programa paralelo
        gene0001.pc_ativa_paralelo(pr_idparale => vr_idparale
                                    ,pr_idprogra => LPAD(reg_crapage.cdagenci,3,'0') --> Utiliza a agência como id programa
                                    ,pr_des_erro => vr_dscritic);

        -- Testar saida com erro
        if vr_dscritic is not null then
          -- Levantar exceçao
          raise vr_exc_erro;
        END if;

        vr_dsplsql := 'declare'            ||chr(13)||
                      ' wpr_cdcritic  number(5); '     ||chr(13)||
                      ' wpr_dscritic  varchar2(4000); '||chr(13)||
                      ' begin '||chr(13)||
                      '   dsct0002.pc_analise_pagador_agencia('||pr_cdcooper||','||chr(13)||
                                               reg_crapage.cdagenci||','||chr(13)||
                                               vr_idparale||','||chr(13)||
                                               'wpr_cdcritic,' ||chr(13)||
                                               'wpr_dscritic'  ||chr(13)||
                                               ');'||chr(13)||
                      'end;';
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra => vr_cdprogra  --> Código do programa
                                ,pr_dsplsql  => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe  => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva  => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname  => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro => vr_dscritic);

          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_erro;
          END IF;
          gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => vr_qtdjobs
                                   ,pr_des_erro => vr_dscritic);
      END LOOP;

      --Chama rotina de aguardo agora passando 0, para esperar
      --até que todos os Jobs tenha finalizado seu processamento
      gene0001.pc_aguarda_paralelo(pr_idparale => vr_idparale
                                   ,pr_qtdproce => 0
                                   ,pr_des_erro => vr_dscritic);

      -- Testar saida com erro
      IF  vr_dscritic IS NOT NULL THEN
        -- Levantar exceçao
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
        pr_dscritic := replace(replace('Nao foi possivel buscar dados do avalista: ' || SQLERRM, chr(13)),chr(10));

  END pc_analise_pagador_paralelo;

  PROCEDURE pc_analise_pagador_agencia (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                                        ,pr_cdagenci IN crapass.cdagenci%TYPE   --> Código da Agencia
                                        ,pr_idparale IN INTEGER
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Código da Critica
                                        ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica

    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;

    CURSOR cr_crapass IS
      SELECT
        ass.nrdconta,
        ass.cdcooper
      FROM
        crapass ass
        INNER JOIN craplim lim ON lim.nrdconta = ass.nrdconta AND lim.cdcooper = ass.cdcooper
      WHERE
        ass.cdcooper = pr_cdcooper
        AND ass.cdagenci = pr_cdagenci
        AND ass.cdsitdct = 1 -- Situacao normal
        AND lim.tpctrlim=3
        AND lim.insitlim=2
    ;
    rw_crapass cr_crapass%ROWTYPE;
    BEGIN
      OPEN cr_crapass;
      LOOP
      FETCH cr_crapass INTO rw_crapass;
        EXIT WHEN cr_crapass%NOTFOUND;
        pc_efetua_analise_pagador(pr_cdcooper  => rw_crapass.cdcooper
                                  ,pr_nrdconta => rw_crapass.nrdconta
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
      END LOOP;
      gene0001.pc_encerra_paralelo(pr_idparale => pr_idparale
                                  ,pr_idprogra => LPAD(pr_cdagenci,3,'0')
                                  ,pr_des_erro => vr_dscritic);
      IF TRIM(vr_dscritic) IS NOT NULL THEN
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
        pr_dscritic := replace(replace('Erro nao tratado em DSCT0002.pc_analise_pagador_agencia ' || SQLERRM, chr(13)),chr(10));
  END pc_analise_pagador_agencia;
END DSCT0002;
/
