CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------

    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018                  Ultima atualizacao: 01/03/2019

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de Títulos dentro da ATENDA

    Alteracoes: 01/03/2018 - Criação (Paulo Penteado (GFT))
                02/03/2018 - Inclusão da Função    fn_em_contingencia_ibratan (Gustavo Sene (GFT))
                02/03/2018 - Inclusão da Procedure pc_confirmar_novo_limite   (Gustavo Sene (GFT))
                02/03/2018 - Inclusão da Procedure pc_negar_proposta          (Gustavo Sene (GFT))
                13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta somente se 
                   tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT) KE00726701-276)
                23/03/2018 - Inclusão da Procedure pc_buscar_titulos          (Andrew Albuquerque (GFT))
                26/03/2018 - Inclusão da Procedure pc_buscar_titulos_web      (Andrew Albuquerque (GFT))
                26/03/2018 - Inclusão da Procedure pc_busca_dados_limite e pc_busca_dados_limite_web (Luis Fernando (GFT))
                26/03/2018 - Inclusão da procedure pc_obtem_dados_proposta_web (Paulo Penteado (GFT))
                02/04/2018 - Inclusão do record 'typ_rec_tit_bordero' e das procedures 'pc_buscar_tit_bordero' e 'pc_buscar_tit_bordero_web' para listar e buscar detalhes e restrições dos titulos do borderô (Leonardo Oliveira (GFT))
                04/04/2018 - Ajuste no retorno das críticas na operação 'pc_detalhes_tit_bordero' (Leonardo Oliveira (GFT)) 
        26/04/2018 - Ajuste no retorno das propostas 'pc_obtem_dados_proposta_web' (Leonardo Oliveira (GFT))
                22/08/2018 - Inclusão das procedures pc_busca_hist_alt_limite e pc_busca_hist_alt_limite_web (Andrew Albuquerque - GFT)        
                22/08/2018 - Inclusão da procedure pc_gravar_hist_alt_limite (Paulo Penteado (GFT))
                23/08/2018 - Alteraçao na procedure pc_efetivar_proposta / Registrar na tabela de histórico de alteraçao 
                             de contrato de limite (Andrew Albuquerque - GFT)
                04/09/2018 - Alteração do type de retorno dos históricos de limite, e da data de inclusão quando é Cancelamento de Limite (Andrew Albuquerque - GFT)
                11/10/2018 - Ajuste no CURSOR cr_crapcob para carregar situação do título, responsável por buscar informações dos 
                             titulos/boletos (utilizado em outras package) (Andrew Albuquerque - GFT)
                06/11/2018 - Fabio dos Santos (GFT) - Inclusao da chamada do InterrompeFluxo da Esteira, na pc_altera_bordero
                23/11/2018 - Adicionado para guardar o usuario que fez a ultima analise do bordero (clicou no botao analisar) para ser enviado para a esteira
				01/03/2019 - Removido da clausula WHERE o campo cdtpinsc quando efetuar leitura da crapsab (Daniel)
				30/07/2019 - Removida porcentagem de Liquidez do pagador com o cedente quando não houver parcelas suficientes para o calculo - Darlei (Supero)
				
  ---------------------------------------------------------------------------------------------------------------------*/

  /* Tabela de retorno do histórico de alteração dos contratos de limite*/
  TYPE typ_rec_hist_alt_limites
       IS RECORD (idhistaltlim   NUMBER(10),
                  cdcooper       NUMBER(10),
                  nrdconta       NUMBER(10),
                  tpctrlim       NUMBER(5),
                  nrctrlim       NUMBER(10),
                  dtinivig       DATE,
                  dtfimvig       DATE,
                  vllimite       NUMBER(25,2),
                  insitlim       NUMBER(5),
                  dssitlim       VARCHAR2(30),
                  dhalteracao    DATE,
                  dsmotivo       VARCHAR2(1000));
  TYPE  typ_tab_hist_alt_limites IS TABLE OF typ_rec_hist_alt_limites
    INDEX BY binary_integer;
    
  /*Tabela de retorno dos titulos do bordero*/
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
                  dssituac CHAR(1),
                  sitibrat CHAR(1),
                  dssittit VARCHAR2(100));

  TYPE typ_tab_tit_bordero IS TABLE OF typ_rec_tit_bordero
       INDEX BY VARCHAR2(50);

  /*Tabela de retorno dos dados obtidos na consulta de titulos*/
  TYPE typ_reg_dados_titulos IS RECORD(
        progress_recid crapcob.progress_recid%TYPE,
        cdcooper       crapcob.cdcooper%TYPE,
        nrdconta       crapcob.nrdconta%TYPE,
        nrctremp       crapcob.nrctremp%TYPE,
        nrcnvcob       crapcob.nrcnvcob%TYPE,
        nrdocmto       crapcob.nrdocmto%TYPE,
        nrinssac       crapcob.nrinssac%TYPE,
        nmdsacad       crapsab.nmdsacad%TYPE,
        dtvencto       crapcob.dtvencto%TYPE,
        dtmvtolt       crapcob.dtmvtolt%TYPE,
        vltitulo       crapcob.vltitulo%TYPE,
        nrnosnum       crapcob.nrnosnum%TYPE,
        flgregis       crapcob.flgregis%TYPE,
        cdtpinsc       crapcob.cdtpinsc%TYPE,
        dssituac       CHAR(1),
        vldpagto       crapcob.vldpagto%TYPE,
        cdbandoc       crapcob.cdbandoc%TYPE,
        nrdctabb       crapcob.nrdctabb%TYPE,
        dtdpagto       crapcob.dtdpagto%TYPE,
        incobran       crapcob.incobran%TYPE,
        insittit       craptdb.insittit%TYPE,
        nrborder       craptdb.nrborder%TYPE,
        dtlibbdt       craptdb.dtlibbdt%TYPE,
        dssittit       VARCHAR2(100)
        );
  
  TYPE typ_tab_dados_titulos IS TABLE OF typ_reg_dados_titulos INDEX BY BINARY_INTEGER;
  
  TYPE typ_reg_dados_pagador IS RECORD(
       nrdconta        crapsab.nrdconta%TYPE,
       nrinssac        crapsab.nrinssac%TYPE,
       cdcooper        crapsab.cdcooper%TYPE,
       vlttitbd        NUMBER,   -- valor acumulado dos titulos para o bordero
       nrcepsac        crapsab.nrcepsac%TYPE,
       inpessoa        crapsab.cdtpinsc%TYPE
  );
  TYPE typ_tab_dados_pagador IS TABLE OF typ_reg_dados_pagador INDEX BY LONG;
  
  /*Tabela que retorna os dados do contrato de limite*/
  TYPE typ_reg_dados_limite IS RECORD(
        dtpropos 		craplim.dtpropos%TYPE,
        dtinivig 		craplim.dtinivig%TYPE,
        nrctrlim 		craplim.nrctrlim%TYPE,
        vllimite 		craplim.vllimite%TYPE,
        qtdiavig 		craplim.qtdiavig%TYPE,
        cddlinha 		craplim.cddlinha%TYPE,
        tpctrlim 		craplim.tpctrlim%TYPE,
        vlutiliz    NUMBER,
        qtutiliz    INTEGER,
        dtfimvig    craplim.dtfimvig%TYPE,
        pctolera    INTEGER
        
  );

  TYPE typ_tab_dados_limite IS TABLE OF typ_reg_dados_limite INDEX BY BINARY_INTEGER;
  
/*Tabela que armazena as informações da proposta de limite de desconto de titulo*/
type typ_reg_dados_proposta is record
     (nrdconta       crawlim.nrdconta%type
     ,insitlim       crawlim.insitlim%type
     ,dtpropos       crawlim.dtpropos%type
     ,dtinivig       crawlim.dtinivig%type
     ,inbaslim       crawlim.inbaslim%type
     ,vllimite       crawlim.vllimite%type
     ,nrctrlim       crawlim.nrctrlim%type
     ,cdmotcan       crawlim.cdmotcan%type
     ,dtfimvig       crawlim.dtfimvig%type
     ,qtdiavig       crawlim.qtdiavig%type
     ,cdoperad       crawlim.cdoperad%type
     ,dsencfin##1    crawlim.dsencfin##1%type
     ,dsencfin##2    crawlim.dsencfin##2%type
     ,dsencfin##3    crawlim.dsencfin##3%type
     ,flgimpnp       crawlim.flgimpnp%type
     ,nrctaav1       crawlim.nrctaav1%type
     ,nrctaav2       crawlim.nrctaav2%type
     ,dsendav1##1    crawlim.dsendav1##1%type
     ,dsendav1##2    crawlim.dsendav1##2%type
     ,dsendav2##1    crawlim.dsendav2##1%type
     ,dsendav2##2    crawlim.dsendav2##2%type
     ,nmdaval1       crawlim.nmdaval1%type
     ,nmdaval2       crawlim.nmdaval2%type
     ,dscpfav1       crawlim.dscpfav1%type
     ,dscpfav2       crawlim.dscpfav2%type
     ,nmcjgav1       crawlim.nmcjgav1%type
     ,nmcjgav2       crawlim.nmcjgav2%type
     ,dscfcav1       crawlim.dscfcav1%type
     ,dscfcav2       crawlim.dscfcav2%type
     ,tpctrlim       crawlim.tpctrlim%type
     ,qtrenova       crawlim.qtrenova%type
     ,cddlinha       crawlim.cddlinha%type
     ,dtcancel       crawlim.dtcancel%type
     ,cdopecan       crawlim.cdopecan%type
     ,cdcooper       crawlim.cdcooper%type
     ,qtrenctr       crawlim.qtrenctr%type
     ,cdopelib       crawlim.cdopelib%type
     ,nrgarope       crawlim.nrgarope%type
     ,nrinfcad       crawlim.nrinfcad%type
     ,nrliquid       crawlim.nrliquid%type
     ,nrpatlvr       crawlim.nrpatlvr%type
     ,idquapro       crawlim.idquapro%type
     ,nrperger       crawlim.nrperger%type
     ,vltotsfn       crawlim.vltotsfn%type
     ,flgdigit       crawlim.flgdigit%type
     ,dtrenova       crawlim.dtrenova%type
     ,tprenova       crawlim.tprenova%type
     ,dsnrenov       crawlim.dsnrenov%type
     ,nrconbir       crawlim.nrconbir%type
     ,dtconbir       crawlim.dtconbir%type
     ,inconcje       crawlim.inconcje%type
     ,cdopeori       crawlim.cdopeori%type
     ,cdageori       crawlim.cdageori%type
     ,dtinsori       crawlim.dtinsori%type
     ,cdopeexc       crawlim.cdopeexc%type
     ,cdageexc       crawlim.cdageexc%type
     ,dtinsexc       crawlim.dtinsexc%type
     ,dtrefatu       crawlim.dtrefatu%type
     ,insitblq       crawlim.insitblq%type
     ,insitest       crawlim.insitest%type
     ,dtenvest       crawlim.dtenvest%type
     ,hrenvest       crawlim.hrenvest%type
     ,cdagenci       crawlim.cdagenci%type
     ,hrinclus       crawlim.hrinclus%type
     ,dtdscore       crawlim.dtdscore%type
     ,dsdscore       crawlim.dsdscore%type
     ,cdopeste       crawlim.cdopeste%type
     ,flgaprvc       crawlim.flgaprvc%type
     ,dtenefes       crawlim.dtenefes%type
     ,dsprotoc       crawlim.dsprotoc%type
     ,dtaprova       crawlim.dtaprova%type
     ,insitapr       crawlim.insitapr%type
     ,cdopeapr       crawlim.cdopeapr%type
     ,hraprova       crawlim.hraprova%type
     ,dtmanute       crawlim.dtmanute%type
     ,dtenvmot       crawlim.dtenvmot%type
     ,hrenvmot       crawlim.hrenvmot%type
     ,dsnivris       crawlim.dsnivris%type
     ,dsobscmt       crawlim.dsobscmt%type
     ,dtrejeit       crawlim.dtrejeit%type
     ,hrrejeit       crawlim.hrrejeit%type
     ,cdoperej       crawlim.cdoperej%type
     ,ininadim       crawlim.ininadim%type
     ,nrctrmnt       crawlim.nrctrmnt%type
     ,dssitlim       varchar2(100)
     ,dssitest       varchar2(100)
     ,dssitapr       varchar2(100)
     ,inctrmnt       number);

type typ_tab_dados_proposta is table of typ_reg_dados_proposta index by pls_integer;

/*Tabela de retorno dos dados obtidos para o biro*/
TYPE typ_reg_dados_biro IS RECORD(
      dsnegati        VARCHAR2(225),
      qtnegati        integer,
      vlnegati        number,
      dtultneg        date
    );
  
TYPE typ_tab_dados_biro IS TABLE OF typ_reg_dados_biro INDEX BY BINARY_INTEGER;
  
  
    
/*Tabela de retorno dos dados obtidos para os detalhes*/
TYPE typ_reg_dados_detalhe IS RECORD(
     concpaga        VARCHAR2(20),
     liqpagcd        VARCHAR2(20),
     liqgeral        VARCHAR2(20)
    ,dtreapro        VARCHAR2(20) -- Marcelo Telles Coelho - Mouts - 25/04/2019 - RITM0050653
	,qtparcmi        INTEGER      -- Atende parcelas minimas para porcentagem em tela
);
TYPE typ_tab_dados_detalhe IS TABLE OF typ_reg_dados_detalhe INDEX BY BINARY_INTEGER;
  
  
/*Tabela de retorno dos dados obtidos para as criticas*/
TYPE typ_reg_dados_critica IS RECORD(
     dsc                   VARCHAR2(225),
     vlr               VARCHAR(225) -- numero
);

TYPE typ_tab_dados_critica IS TABLE OF typ_reg_dados_critica INDEX BY BINARY_INTEGER;  


/*Tabela de retorno dos dados obtidos na consulta de bordero*/
TYPE typ_reg_borderos IS RECORD(
     nrborder       crapbdt.nrborder%TYPE,
     dtmvtolt       crapbdt.dtmvtolt%TYPE,
     nrctrlim       crapbdt.nrctrlim%TYPE,
     nrdconta       crapbdt.nrdconta%TYPE,
     dtlibbdt       crapbdt.dtlibbdt%TYPE,
     dssitbdt       VARCHAR2(50),
     aux_qttottit   INTEGER,
     aux_vltottit   craptdb.vltitulo%TYPE,
     aux_qtsitapr   INTEGER,
     aux_vlsitapr   craptdb.vltitulo%TYPE,
     dsinsitapr     VARCHAR2(50),
     flrestricao    INTEGER,
     inprejuz       INTEGER

);
TYPE typ_tab_borderos IS TABLE OF typ_reg_borderos INDEX BY BINARY_INTEGER;

/*Tabela de retorno dos dados obtidos na consulta de titulo*/
TYPE typ_reg_titulo IS RECORD(
    nrinssac craptdb.nrinssac%TYPE,
    nrdconta craptdb.nrdconta%TYPE,
    dtvencto craptdb.dtvencto%TYPE,
    nossonum VARCHAR2(50),
    nmdsacad VARCHAR(500),
    diasatr  INTEGER,
    diasprz  INTEGER,
    vltitulo craptdb.vltitulo%TYPE,
    vlsldtit craptdb.vlsldtit%TYPE,
    nmsacado crapsab.nmdsacad%TYPE,
    cdtpinsc crapsab.cdtpinsc%TYPE,
    nrctrdsc tbdsct_titulo_cyber.nrctrdsc%TYPE,
    vlpago   NUMBER(15,2),
    vlmulta  NUMBER(15,2),
    vlmora   NUMBER(15,2),
    vliof    NUMBER(15,2),
    vlpagar  NUMBER(15,2),
    dtliqprj crapbdt.dtliqprj%TYPE,
    dtprejuz crapbdt.dtprejuz%TYPE,
    vlaboprj crapbdt.vlaboprj%TYPE,
    vljraprj craptdb.vljraprj%TYPE,
    vljrmprj craptdb.vljrmprj%TYPE,
    vlpgjmpr craptdb.vlpgjmpr%TYPE,
    vlpgmupr craptdb.vlpgmupr%TYPE,
    vlprejuz craptdb.vlprejuz%TYPE,
    vlsdprej craptdb.vlsdprej%TYPE,
    vlsprjat craptdb.vlsprjat%TYPE,
    vlttjmpr craptdb.vlttjmpr%TYPE,
    vlttmupr craptdb.vlttmupr%TYPE,
    inprejuz crapbdt.inprejuz%TYPE,
    qtdirisc crapbdt.qtdirisc%TYPE
);
TYPE typ_tab_titulo IS TABLE OF typ_reg_titulo INDEX BY BINARY_INTEGER;


  --     buscar informações dos titulos/boletos (utilizado em outras package)
  CURSOR cr_crapcob(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                   ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                   ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                   ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
  SELECT cob.cdcooper
        ,cob.nrdconta
        ,cob.nrctremp
        ,cob.nrcnvcob
        ,cob.nrdocmto
        ,cob.nrinssac
        ,sab.nmdsacad
        ,cob.dtvencto
        ,cob.dtmvtolt
        ,cob.vltitulo
        ,cob.nrnosnum
        ,cob.flgregis
        ,cob.cdtpinsc
        ,cob.vldpagto
        ,cob.cdbandoc
        ,cob.nrdctabb
        ,cob.dtdpagto
        ,tdb.nrborder
        ,tdb.dtlibbdt
        ,sab.nrcepsac
        ,CASE WHEN tdb.insittit = 2 AND tdb.dtdpagto > gene0005.fn_valida_dia_util(tdb.cdcooper, tdb.dtvencto) THEN 
                  'Pago após vencimento'
              ELSE dsct0003.fn_busca_situacao_titulo(tdb.insittit, 1) 
          END dssittit
        ,nvl((SELECT decode(inpossui_criticas,1,'S','N')
              FROM   tbdsct_analise_pagador tap 
              WHERE  tap.cdcooper = cob.cdcooper
              AND    tap.nrdconta = cob.nrdconta
              AND    tap.nrinssac = cob.nrinssac),'A') AS dssituac
        ,COUNT(1) over() qtregist 
  FROM   crapcob cob 
         INNER JOIN crapsab sab ON sab.nrinssac = cob.nrinssac AND 
                                   sab.cdcooper = cob.cdcooper AND 
                                   sab.nrdconta = cob.nrdconta  
         LEFT  JOIN craptdb tdb ON cob.cdcooper = tdb.cdcooper AND 
                                   cob.cdbandoc = tdb.cdbandoc AND  
                                   cob.nrdctabb = tdb.nrdctabb AND  
                                   cob.nrdconta = tdb.nrdconta AND  
                                   cob.nrcnvcob = tdb.nrcnvcob AND  
                                   cob.nrdocmto = tdb.nrdocmto  
  WHERE  cob.flgregis > 0 
  AND    cob.incobran = 0 
  AND    cob.nrdconta = pr_nrdconta
  AND    cob.cdcooper = pr_cdcooper
  AND    cob.nrcnvcob = pr_nrcnvcob
  AND    cob.cdbandoc = pr_cdbandoc
  AND    cob.nrdctabb = pr_nrdctabb
  AND    cob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%rowtype;


--> Função que retorna se o Serviço IBRATAN está em Contigência ou Não.
FUNCTION fn_em_contingencia_ibratan (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

FUNCTION fn_contigencia_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE ) RETURN BOOLEAN;

--> Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN crawlim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN crawlim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  );

PROCEDURE pc_efetivar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> Código do Operador
                              ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                              ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                              ,pr_idorigem    in integer               --> Identificador Origem Chamada
                              ,pr_insitapr    in crawlim.insitapr%type --> Decisão (Dependente do Retorno da Análise)
                              --------> OUT <--------
                              ,pr_cdcritic    out pls_integer          --> Codigo da critica
                              ,pr_dscritic    out varchar2             --> Descricao da critica
                              );


PROCEDURE pc_efetivar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Contrato
                                  ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo


PROCEDURE pc_cancelar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Contrato
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  crawlim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  crawlim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                               --------> OUT <--------
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              );  

PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  crawlim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  crawlim.tpctrlim%type --> Tipo de contrato do limite
                                   ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                   ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
                                   ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                                   ,pr_cdcritic out pls_integer           --> Codigo da critica
                                   ,pr_dscritic out varchar2              --> Descricao da critica
                                   ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   );

PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_alterar_proposta_manute_web(pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                         -- OUT
                                        ,pr_cdcritic out pls_integer          --> Codigo da critica
                                        ,pr_dscritic out varchar2             --> Descric?o da critica
                                        ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                        ,pr_des_erro out varchar2);           --> Erros do processo

PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                      -- OUT
                                     ,pr_cdcritic out pls_integer          --> Codigo da critica
                                     ,pr_dscritic out varchar2             --> Descric?o da critica
                                     ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                     ,pr_des_erro out varchar2             --> Erros do processo
                                     );


PROCEDURE pc_obtem_proposta_aciona_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                      ,pr_nrctrlim in crawlim.nrctrlim%type --> Numero do Contrato do Limite
                                      ,pr_nrctrmnt in crawlim.tpctrlim%type --> Numero da proposta do Limite
                                      ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                       -- OUT
                                      ,pr_cdcritic out pls_integer          --> Codigo da critica
                                      ,pr_dscritic out varchar2             --> Descric?o da critica
                                      ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                      ,pr_des_erro out varchar2             --> Erros do processo
                                      );
                                      
PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da Movimentação
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN crapcob.dtvencto%TYPE  --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                  ,pr_dtemissa IN crapbdt.dtmvtolt%TYPE DEFAULT NULL --> Filtro data de Emissao do borderô
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer       --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica
	  
PROCEDURE pc_buscar_titulos_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_busca_dados_limite (pr_nrdconta IN craplim.nrdconta%TYPE
                                   ,pr_cdcooper IN craplim.cdcooper%TYPE
                                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                                   ,pr_insitlim IN craplim.insitlim%TYPE
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                   --------> OUT <--------
                                   ,pr_tab_dados_limite   out  typ_tab_dados_limite --> Tabela de retorno
                                   ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                   );
                                   
PROCEDURE pc_busca_dados_limite_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo do contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Situacao do Contrato
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  );
                                     
PROCEDURE pc_prepara_titulos_resumo (pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                               ,pr_qtregist           out integer                --> Qtde total de registros
                               ,pr_tab_dados_titulos  out  typ_tab_dados_titulos --> Tabela de retorno de titulos
                               ,pr_tab_pagadores      out  typ_tab_dados_pagador --> Tabela de retorno de pagadores
                               ,pr_cdcritic           out pls_integer            --> Codigo da critica
                               ,pr_dscritic           out varchar2               --> Descricao da critica
                               );
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_chave           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                 ,pr_calcpagador        IN INT DEFAULT 1           --> Define se calcula o pagador 
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 );
                                 
PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                );
                                
PROCEDURE pc_solicita_biro_bordero(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrinssac  IN crapcob.nrinssac%TYPE --> Numero de inscricao do sacado
                                  ,pr_vlttitbd  IN NUMBER                --> Valor total dos titulos do pagador para o novo bordero
                                  ,pr_inpessoa  IN crapsab.cdtpinsc%TYPE 
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                  ,pr_nrcepsac  IN crapsab.nrcepsac%TYPE   
                                  ,pr_cdoperad  IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  );
                                
PROCEDURE pc_solicita_biro_bordero_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE     --> Contrato de bordero         
                                  ,pr_chave    in varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  );
                                  
PROCEDURE pc_analise_pagador_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE     --> Contrato de bordero                 
                                  ,pr_chave    IN varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  );
                                  
PROCEDURE pc_insere_bordero(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                           ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Conta do associado
                           ,pr_tpctrlim          IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite
                           ,pr_insitlim          IN craplim.insitlim%TYPE --> Situação do contrato de limite
                           ,pr_dtmvtolt          IN crapdat.dtmvtolt%TYPE --> Tipo de registro de datas
                           ,pr_cdoperad          IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                           ,pr_cdagenci          IN crapass.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa          IN craperr.nrdcaixa%TYPE --> Numero Caixa
                           ,pr_nmdatela          IN craplgm.nmdatela%TYPE --> Nome da tela.
                           ,pr_idorigem          IN VARCHAR2              --> Identificador Origem pagamento
                           ,pr_idseqttl          IN INTEGER 
                           ,pr_dtmvtopr          IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                           ,pr_inproces          IN crapdat.inproces%TYPE --> Indicador processo
                           ,pr_tab_dados_titulos IN typ_tab_dados_titulos --> Titulos para desconto
                           ,pr_tab_borderos     OUT typ_tab_borderos      --> Dados do borderô inserido
                           ,pr_dsmensag         OUT VARCHAR2              --> Mensagem
                           ,pr_cdcritic         OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic         OUT VARCHAR2              --> Descricao da critica
                           );
                                  
PROCEDURE pc_insere_bordero_web(pr_tpctrlim IN craplim.tpctrlim%TYPE --> Tipo de contrato
                                 ,pr_insitlim IN craplim.insitlim%TYPE --> Situacao do contrato
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                 ,pr_chave    IN VARCHAR2              --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de movimentacao 
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                 );
                                 
PROCEDURE pc_detalhes_tit_bordero(pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                             ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                             ,pr_nrborder   IN crapbdt.nrborder%TYPE
                             ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                             ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscrição do sacado
                             ,pr_nmdsacad           out crapsab.nmdsacad%TYPE   --> Nome do Sacado
                             ,pr_tab_dados_biro     out  typ_tab_dados_biro    --> Tabela de retorno biro
                             ,pr_tab_dados_detalhe  out  typ_tab_dados_detalhe --> Tabela de retorno detalhe
                             ,pr_tab_dados_critica  out  typ_tab_dados_critica --> Tabela de retorno critica
                             ,pr_cdcritic           out pls_integer            --> Codigo da critica
                             ,pr_dscritic           out varchar2               --> Descricao da critica
                             );

procedure pc_detalhes_tit_bordero_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                      ,pr_nrborder   IN crapbdt.nrborder%TYPE
                                      ,pr_chave    in varchar2              --> lista de 'nosso numero' a ser pesquisado
                                      ,pr_xmllog      in varchar2              --> xml com informações de log
                                       --------> out <--------
                                      ,pr_cdcritic out pls_integer             --> código da crítica
                                      ,pr_dscritic out varchar2                --> descrição da crítica
                                      ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                      ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                      ,pr_des_erro out varchar2                --> erros do processo
                                    );

PROCEDURE pc_buscar_tit_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_tit_bordero   out  typ_tab_tit_bordero --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  );
                               
PROCEDURE pc_buscar_tit_bordero_web (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                );               
      

PROCEDURE pc_buscar_dados_bordero_web (
                                pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                ,pr_dtmvtolt IN VARCHAR2 --> Data de movimentação do sistema
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );                      
  
PROCEDURE pc_validar_titulos_alteracao (
                                pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                ,pr_dtmvtolt IN VARCHAR2 --> Data de movimentação do sistema
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );
PROCEDURE pc_altera_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                               ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                               ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao
                               ,pr_nrborder           in crapbdt.nrborder%type   --> Borderô sendo alterado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                               );
                               
    
PROCEDURE pc_resgate_titulo_bordero_web (pr_nrctrlim   IN crapbdt.nrctrlim%TYPE  --> Numero do contrato
                               ,pr_nrdconta    IN crapbdt.nrdconta%TYPE  --> Numero da conta
                               ,pr_dtmvtolt    IN VARCHAR2  --> Data Movimento
                               ,pr_dtmvtoan    IN VARCHAR2  --> Data anterior do movimento
                               ,pr_dtresgat    IN VARCHAR2  --> Data do resgate
                               ,pr_inproces    IN crapdat.inproces%TYPE  --> Indicador processo
                               ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                               ,pr_xmllog      in varchar2              --> xml com informações de log
                               --------> out <--------
                               ,pr_cdcritic out pls_integer             --> código da crítica
                               ,pr_dscritic out varchar2                --> descrição da crítica
                               ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                               ,pr_nmdcampo out varchar2                --> nome do campo com erro
                               ,pr_des_erro out varchar2                --> erros do processo
                               );
                               
PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Borderô
                                ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );
                              
PROCEDURE pc_titulos_resumo_resgatar_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                              ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                            );

PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                                 ,pr_cdcooper IN crapbdt.cdcooper%TYPE
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                     --------> OUT <--------
                                 ,pr_qtregist OUT INTEGER
                                 ,pr_tab_borderos   out  typ_tab_borderos --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 );

PROCEDURE pc_busca_borderos_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  );

PROCEDURE pc_contingencia_ibratan_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                 );

PROCEDURE pc_busca_dados_titulo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                     ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                     ,pr_chave       IN VARCHAR2              --> lista de 'nosso numero' a ser pesquisado
                                     ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                                     --------> out <--------
                                     ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                                     ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY xmltype       --> arquivo de retorno do xml
                                     ,pr_nmdcampo OUT VARCHAR2                --> nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2                --> erros do processo
                                    );                                 
                                 
PROCEDURE pc_busca_motivos_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                   ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                   ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                   ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                   ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2); --> Erros do processo
                                     
PROCEDURE pc_grava_motivo_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                  ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                  ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                  ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                  ,pr_cdmotivo  IN VARCHAR2
                                  ,pr_dsmotivo  IN VARCHAR2 
                                  ,pr_dsobservacao IN VARCHAR2                                   
                                  ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2); --> Erros do processo

PROCEDURE pc_busca_hist_alt_limite (pr_cdcooper  IN craplim.cdcooper%TYPE
                                   ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                   ,pr_tpctrlim  IN craplim.tpctrlim%TYPE
                                   ,pr_nrctrlim  IN craplim.nrctrlim%TYPE DEFAULT 0
                                   --------> OUT <--------
                                   ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                   ,pr_tab_dados_hist   out  typ_tab_hist_alt_limites --> Tabela de retorno
                                   ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                                   );

PROCEDURE pc_busca_hist_alt_limite_web (pr_nrdconta  IN craplim.nrdconta%TYPE
                                       ,pr_tpctrlim  IN craplim.tpctrlim%TYPE
                                       ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                       ,pr_xmllog    IN VARCHAR2              --> xml com informações de log
                                       --------> OUT <--------
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2              --> Erros do processo 
                                       );
                                       
  PROCEDURE pc_gravar_hist_alt_limite(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                     ,pr_nrctrlim  IN crawlim.nrctrlim%type --> Contrato
                                     ,pr_tpctrlim  IN crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                     ,pr_dsmotivo  IN tbdsct_hist_alteracao_limite.dsmotivo%TYPE --> Motivo da alteração
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                     );
END TELA_ATENDA_DSCTO_TIT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de Títulos dentro da ATENDA

    Alteracoes: 
      01/03/2018 - Criação: Paulo Penteado (GFT) / Gustavo Sene (GFT)
      02/03/2018 - Inclusão da Função    fn_em_contingencia_ibratan (Gustavo Sene (GFT))
      02/03/2018 - Inclusão da Procedure pc_confirmar_novo_limite   (Gustavo Sene (GFT))
      02/03/2018 - Inclusão da Procedure pc_negar_proposta          (Gustavo Sene (GFT))
      13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta somente se 
                   tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT) KE00726701-276)
      23/03/2018 - Inclusão da Procedure pc_buscar_titulos          (Andrew Albuquerque (GFT))
      26/03/2018 - Inclusão da Procedure pc_buscar_titulos_web      (Andrew Albuquerque (GFT))
      26/03/2018 - Inclusão da Procedure pc_busca_dados_limite e pc_busca_dados_limite_web (Luis Fernando (GFT))
      26/03/2018 - Adicionado as procedures pc_obtem_dados_proposta, pc_obtem_dados_proposta_web, pc_inserir_contrato_limite.
                   Alterado as procedures pc_confirmar_novo_limite e pc_negar_proposta. Alterações necessárias para adaptação 
                   do processo de criação de proposta de limite de desconto de títulos (Paulo Penteado (GFT) KE00726701-304)
      13/04/2018 - Criadas funcionalidades de inclusão, alteração e resgate de borderôs (Luis Fernando (GFT)
      23/04/2018 - Alteração para que quando seja adicionado um titulo ao bordero, alterar o status do bordero para 'Em estudo' (Vitor (GFT))
      25/04/2018 - Alterado o calculo das porcentagens da Liquidez (Vitor (GFT))
      21/05/2018 - Adicionada procedure para trazer se a esteira e o motor estão em contingencia (Luis Fernando (GFT))
      13/04/2018 - Criadas funcionalidades de inclusão, alteração e resgate de borderôes (Luis Fernando (GFT)
      22/08/2018 - Inclusão das procedures pc_busca_hist_alt_limite e pc_busca_hist_alt_limite_web (Andrew Albuquerque - GFT)
      22/08/2018 - Inclusão da procedure pc_gravar_hist_alt_limite (Paulo Penteado (GFT))
      23/08/2018 - Alteraçao na procedure pc_efetivar_proposta / Registrar na tabela de histórico de alteraçao 
                   de contrato de limite (Andrew Albuquerque - GFT)
	  23/08/2018 - PRJ 438 - Gravar, Alterar e Consultar motivos de anulação - Paulo Martins - Mouts
      04/09/2018 - Alteração do type de retorno dos históricos de limite, e da data de inclusão quando é Cancelamento de Limite (Andrew Albuquerque - GFT)
	  19/09/2018 - Alterado a procedure pc_busca_titulos_bordero para adicionar retorno da descrição da 
                   situação do titulo dssittit (Paulo Penteado GFT)
      30/07/2019 - Removida porcentagem de Liquidez do pagador com o cedente quando não houver parcelas suficientes para o calculo
				   Darlei (Supero)
  ---------------------------------------------------------------------------------------------------------------------*/


   -- Variáveis para armazenar as informações em XML
   vr_des_xml         clob;
   vr_texto_completo  varchar2(32600);
   vr_index           pls_integer;

   -- Variaveis para verificação de contigencia de esteira e motor
   vr_flctgest boolean;
   vr_flctgmot boolean;
  

FUNCTION fn_contigencia_motor_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ) RETURN BOOLEAN IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_contigencia_motor_esteira
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para verificar e tanto o motor quanto a esteira estão em contingência

    Alteração : 26/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_dscritic varchar2(10000);
  vr_dsmensag varchar2(10000);
BEGIN
   este0003.pc_verifica_contigenc_motor(pr_cdcooper => pr_cdcooper
                                       ,pr_flctgmot => vr_flctgmot
                                       ,pr_dsmensag => vr_dsmensag
                                       ,pr_dscritic => vr_dscritic);

   este0003.pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                         ,pr_flctgest => vr_flctgest
                                         ,pr_dsmensag => vr_dsmensag
                                         ,pr_dscritic => vr_dscritic);

   if  (vr_flctgest and vr_flctgmot) then
       return true;
   else
       return false;
   end if;
END fn_contigencia_motor_esteira;


FUNCTION fn_contigencia_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ) RETURN BOOLEAN IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_contigencia_esteira
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : 10/07/2018

    Objetivo  : Procedure para verificar  a esteira em contingência

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_dscritic varchar2(10000);
  vr_dsmensag varchar2(10000);
BEGIN
   este0003.pc_verifica_contigenc_esteira(pr_cdcooper => pr_cdcooper
                                         ,pr_flctgest => vr_flctgest
                                         ,pr_dsmensag => vr_dsmensag
                                         ,pr_dscritic => vr_dscritic);

   return vr_flctgest;
END fn_contigencia_esteira;

FUNCTION fn_em_contingencia_ibratan (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_em_contingencia_ibratan
    Sistema  : CRED
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Guedes de Sene (GFT)
    Data     : Março/2018

    Frequencia: Sempre que for chamado

    Objetivo  : Função que retorna se o Serviço IBRATAN está em Contigência ou Não.

    Alteração : 01/03/2018 - Criação (Gustavo Sene (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

  vr_inobriga varchar2(1);

  -- Variáveis de críticas
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(10000);

  -- Tratamento de erros
  vr_exc_saida exception;


BEGIN
  este0003.pc_obrigacao_analise_autom(pr_cdcooper => pr_cdcooper
                                     ,pr_inobriga => vr_inobriga
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic
                                     );

  if vr_inobriga = 'N' then -- Se análise IBRATAN não obrigatória
    return TRUE;  --> Em Contingência
  else                      -- Se análise IBRATAN obrigatória
    return FALSE; --> Não está em Contingêngia
  end if;

END fn_em_contingencia_ibratan;


-- Rotina para escrever texto na variável CLOB do XML
PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                        , pr_fecha_xml in boolean default false
                        ) is
BEGIN
   gene0002.pc_escreve_xml( vr_des_xml
                          , vr_texto_completo
                          , pr_des_dados
                          , pr_fecha_xml );
END;


PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN crawlim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN crawlim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.

    Alteração : 28/02/2018 - Criação (Paulo Penteado (GFT))
                10/04/2018 - Substituido a tabela craplim pela cralim (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;

   vr_dtviglim date;

   --> Buscar Contrato de limite
   cursor cr_crawlim is
   select 1
   from   crawlim lim
   where  lim.dtpropos <= vr_dtviglim
   and    lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   vr_dtviglim := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => 0
                                                   ,pr_cdacesso => 'DT_VIG_LIMITE_DESC_TIT'), 'DD/MM/RRRR');

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%found then
         close cr_crawlim;
         vr_dscritic := 'Esta proposta foi incluída no processo antigo. Favor cancela-la e incluir novamente através do novo processo.';
         raise vr_exc_erro;
   end   if;
   close cr_crawlim;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

  when others then
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := replace(replace('Erro pc_validar_data_proposta: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_data_proposta;


PROCEDURE pc_validar_efetivacao_proposta(pr_cdcooper          in crapcop.cdcooper%type     --> Código da Cooperativa
                                        ,pr_nrdconta          in crapass.nrdconta%type     --> Número da Conta
                                        ,pr_nrctrlim          in crawlim.nrctrlim%type     --> Contrato
                                        ,pr_cdagenci          out crapass.cdagenci%type    --> Codigo da agencia
                                        ,pr_tab_crapdat       out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic          out pls_integer              --> Código da crítica
                                        ,pr_dscritic          out varchar2                 --> Descrição da crítica
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_confirm_novo_limite
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Sene (GFT)
    Data     : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validação de informações ante de efetuar a confirmação do novo limite

    Alteração : 03/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Verifica Conta (Cadastro de associados)
   cursor cr_crapass is
   select dtelimin
         ,cdsitdtl
         ,cdagenci
         ,inpessoa
         ,nrdconta
   from   crapass
   where  crapass.cdcooper = pr_cdcooper
   and    crapass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;

   -- Verifica Cadastro de Lancamento de Contratos de Descontos.
   cursor cr_crapcdc is
   select 1
   from   crapcdc
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3;
   rw_crapcdc cr_crapcdc%rowtype;

   cursor cr_craplim is
   select nrctrlim
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    tpctrlim = 3
   and    insitlim = 2;
   rw_craplim cr_craplim%rowtype;

   cursor cr_crawlim is
   select insitlim
         ,insitapr
         ,vllimite
         ,nvl(nrctrmnt,0) nrctrmnt
   from   crawlim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   --    Verifica se a data esta cadastrada
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_saida;
   else
         pr_tab_crapdat := rw_crapdat;
   end   if;
   close btch0001.cr_crapdat;

   --    Verifica se existe a conta
   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_cdcritic := 9;
         raise vr_exc_saida;
   else
         pr_cdagenci := rw_crapass.cdagenci;
   end   if;
   close cr_crapass;

   --  Verifica se a conta foi eliminada
   if  rw_crapass.dtelimin is not null then
       vr_cdcritic := 410;
       raise vr_exc_saida;
   end if;

   --  Verifica se a conta está em prejuizo
   if  rw_crapass.cdsitdtl in (5,6,7,8) then
       vr_cdcritic := 695;
       raise vr_exc_saida;
   end if;

   --  Verifica se conta esta bloqueada
   if  rw_crapass.cdsitdtl in (2,4) then
       vr_cdcritic := 95;
       raise vr_exc_saida;
   end if;

   --  Verifica se existe contrato
   if  pr_nrctrlim = 0 then
       vr_cdcritic := 22;
       raise vr_exc_saida;
   end if;

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
         close cr_crawlim;
         vr_cdcritic := 484;
         raise vr_exc_saida;
   end   if;
   close cr_crawlim;

   if  not fn_contigencia_motor_esteira(pr_cdcooper => pr_cdcooper) then
       if  rw_crawlim.insitapr not in (1,2) then
           vr_dscritic := 'Para esta operação, a Decisão deve ser "Aprovada Automaticamente" ou "Aprovada Manual".';
           raise vr_exc_saida;
       end if;
   end if;

   if  rw_crawlim.insitlim not in (1,5) then
       vr_dscritic := 'Para esta operação, a situação da proposta deve ser "Em estudo" ou "Aprovada".';
       raise vr_exc_saida;
   end if;

   --    Verifica se ja existe um contrato ativo caso efetive uma proposta principal
   if  rw_crawlim.nrctrmnt = 0 then
       open  cr_craplim;
       fetch cr_craplim into rw_craplim;
       if    cr_craplim%found then
             close cr_craplim;
             vr_dscritic := 'Efetivação de proposta não permitida! O contrato ' ||rw_craplim.nrctrlim || ' já ativo deve ser cancelado primeiro.';
             raise vr_exc_saida;
       end   if;
       close cr_craplim;
   end if;

   --    Verifica se ja existe lancamento
   open  cr_crapcdc;
   fetch cr_crapcdc into rw_crapcdc;
   if    cr_crapcdc%found then
         close cr_crapcdc;
         vr_cdcritic := 92;
         raise vr_exc_saida;
   end   if;
   close cr_crapcdc;

EXCEPTION
   when vr_exc_saida then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := nvl(vr_cdcritic,0);
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

  when others then
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := replace(replace('Erro pc_validar_efetivacao_proposta: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_efetivacao_proposta;                                   


PROCEDURE pc_inserir_contrato_limite(pr_cdcooper in crapcop.cdcooper%type --> Código da Cooperativa
                                    ,pr_nrdconta in crapass.nrdconta%type --> Número da Conta
                                    ,pr_nrctrlim in crawlim.nrctrlim%type --> Contrato
                                    ,pr_tpctrlim in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                    ,pr_dtmvtolt in crapdat.dtmvtolt%type --> Tipo de registro de datas
                                    ,pr_dscritic out varchar2             --> Descricao da critica
                                    ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_inserir_contrato_limite
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Objetivo  : Procedure para carregar as informações da proposta na type

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))
    Alteração : 13/11/2018 - Adicionado campos idcobope e idcobefe (Lucas Negoseki (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;
   
   cursor cr_crawlim is
   select lim.*
   from   crawlim lim
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   close cr_crawlim;

   begin         
      -- inserir o registro do contrato de limite de desconto de título de acordo com a proposta
      insert into cecred.craplim
             (/*01*/ nrdconta
             ,/*02*/ insitlim
             ,/*03*/ dtpropos
             ,/*04*/ dtinivig
             ,/*05*/ inbaslim
             ,/*06*/ vllimite
             ,/*07*/ nrctrlim
             ,/*08*/ cdmotcan
             ,/*09*/ dtfimvig
             ,/*10*/ qtdiavig
             ,/*11*/ cdoperad
             ,/*12*/ dsencfin##1
             ,/*13*/ dsencfin##2
             ,/*14*/ dsencfin##3
             ,/*15*/ flgimpnp
             ,/*16*/ nrctaav1
             ,/*17*/ nrctaav2
             ,/*18*/ dsendav1##1
             ,/*19*/ dsendav1##2
             ,/*20*/ dsendav2##1
             ,/*21*/ dsendav2##2
             ,/*22*/ nmdaval1
             ,/*23*/ nmdaval2
             ,/*24*/ dscpfav1
             ,/*25*/ dscpfav2
             ,/*26*/ nmcjgav1
             ,/*27*/ nmcjgav2
             ,/*28*/ dscfcav1
             ,/*29*/ dscfcav2
             ,/*30*/ tpctrlim
             ,/*31*/ qtrenova
             ,/*32*/ cddlinha
             ,/*33*/ cdcooper
             ,/*34*/ qtrenctr
             ,/*35*/ cdopelib
             ,/*36*/ nrgarope
             ,/*37*/ nrinfcad
             ,/*38*/ nrliquid
             ,/*39*/ nrpatlvr
             ,/*40*/ idquapro
             ,/*41*/ nrperger
             ,/*42*/ vltotsfn
             ,/*43*/ flgdigit
             ,/*44*/ nrconbir
             ,/*45*/ dtconbir
             ,/*46*/ inconcje
             ,/*47*/ cdopeori
             ,/*48*/ cdageori
             ,/*49*/ dtinsori
             ,/*50*/ insitblq
             ,/*51*/ dtmanute
             ,/*52*/ ininadim
             ,/*53*/ idcobope
             ,/*54*/ idcobefe )
      values (/*01*/ rw_crawlim.nrdconta
             ,/*02*/ 2 --Ativo
             ,/*03*/ pr_dtmvtolt
             ,/*04*/ pr_dtmvtolt
             ,/*05*/ rw_crawlim.inbaslim
             ,/*06*/ rw_crawlim.vllimite
             ,/*07*/ rw_crawlim.nrctrlim
             ,/*08*/ rw_crawlim.cdmotcan
             ,/*09*/ (pr_dtmvtolt + rw_crawlim.qtdiavig)
             ,/*10*/ rw_crawlim.qtdiavig
             ,/*11*/ rw_crawlim.cdoperad
             ,/*12*/ rw_crawlim.dsencfin##1
             ,/*13*/ rw_crawlim.dsencfin##2
             ,/*14*/ rw_crawlim.dsencfin##3
             ,/*15*/ rw_crawlim.flgimpnp
             ,/*16*/ rw_crawlim.nrctaav1
             ,/*17*/ rw_crawlim.nrctaav2
             ,/*18*/ rw_crawlim.dsendav1##1
             ,/*19*/ rw_crawlim.dsendav1##2
             ,/*20*/ rw_crawlim.dsendav2##1
             ,/*21*/ rw_crawlim.dsendav2##2
             ,/*22*/ rw_crawlim.nmdaval1
             ,/*23*/ rw_crawlim.nmdaval2
             ,/*24*/ rw_crawlim.dscpfav1
             ,/*25*/ rw_crawlim.dscpfav2
             ,/*26*/ rw_crawlim.nmcjgav1
             ,/*27*/ rw_crawlim.nmcjgav2
             ,/*28*/ rw_crawlim.dscfcav1
             ,/*29*/ rw_crawlim.dscfcav2
             ,/*30*/ rw_crawlim.tpctrlim
             ,/*31*/ 0
             ,/*32*/ rw_crawlim.cddlinha
             ,/*33*/ rw_crawlim.cdcooper
             ,/*34*/ rw_crawlim.qtrenctr
             ,/*35*/ rw_crawlim.cdopelib
             ,/*36*/ rw_crawlim.nrgarope
             ,/*37*/ rw_crawlim.nrinfcad
             ,/*38*/ rw_crawlim.nrliquid
             ,/*39*/ rw_crawlim.nrpatlvr
             ,/*40*/ rw_crawlim.idquapro
             ,/*41*/ rw_crawlim.nrperger
             ,/*42*/ rw_crawlim.vltotsfn
             ,/*43*/ rw_crawlim.flgdigit
             ,/*44*/ rw_crawlim.nrconbir
             ,/*45*/ rw_crawlim.dtconbir
             ,/*46*/ rw_crawlim.inconcje
             ,/*47*/ rw_crawlim.cdopeori
             ,/*48*/ rw_crawlim.cdageori
             ,/*49*/ trunc(sysdate)
             ,/*50*/ rw_crawlim.insitblq
             ,/*51*/ trunc(sysdate)
             ,/*52*/ rw_crawlim.ininadim
             ,/*53*/ rw_crawlim.idcobope
             ,/*54*/ rw_crawlim.idcobefe );
   exception
      when others then
           vr_dscritic := 'Erro ao inserir o contrato de limite de desconto de título: '||sqlerrm;
           raise vr_exc_saida;
   end; 
EXCEPTION
   when vr_exc_saida then
        pr_dscritic := vr_dscritic;

   when others then
        pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_inserir_contrato_limite: ' || sqlerrm;

END pc_inserir_contrato_limite;


PROCEDURE pc_efetivar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> Código do Operador
                              ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                              ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                              ,pr_idorigem    in integer               --> Identificador Origem Chamada
                              ,pr_insitapr    in crawlim.insitapr%type --> Decisão (Dependente do Retorno da Análise)
                              --------> OUT <--------
                              ,pr_cdcritic    out pls_integer          --> Codigo da critica
                              ,pr_dscritic    out varchar2             --> Descricao da critica
                              ) is
BEGIN
  ----------------------------------------------------------------------------------
  --
  -- Procedure: pc_efetivar_proposta
  -- Sistema  : CRED
  -- Sigla    : TELA_ATENDA_DSCTO_TIT
  -- Autor    : Gustavo Guedes de Sene - Company: GFT
  -- Data     : Criação: 22/02/2018
  --
  -- Dados referentes ao programa:
  --  Esse procedimento é chamado nos arquivos do progress bo30
  --
  -- Frequencia:
  -- Objetivo  : Efetivar a proposta de limite de desconto de títulos fazendo a mesma virar um contrato
  -- 
  --
  -- Histórico de Alterações:
  --  22/02/2018 - Versão inicial
  --  10/04/2018 - Alterado atualização da tabela de contrato craplim pela tabela de proposta crawlim. 
  --               Adicionado o insert na tabela craplim, pois quando confirmar a proposta de limite, 
  --               deve-se gerar um contrato. (Paulo Penteado (GFT))
  --
  --  23/08/2018 - Alteraçao na procedure pc_efetivar_proposta / Registrar na tabela de histórico de alteraçao 
  --               de contrato de limite (Andrew Albuquerque - GFT)
  --
  ----------------------------------------------------------------------------------
DECLARE
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

   -- Variavel de criticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida   exception;
   vr_retorna_msg exception;

   -- Variaveis auxiliares
   vr_nrdolote     craplot.nrdolote%type;
   vr_rowid_log    rowid;
   vr_flcraplim    BOOLEAN;
   vr_dsmotivo     VARCHAR2(60);
   -- Variáveis incluídas
   vr_des_erro      varchar2(3);                           -- 'OK' / 'NOK'
   vr_cdbattar      crapbat.cdbattar%type := 'DSTCONTRPF'; -- Default = Pessoa Física
   vr_cdtarifa      craptar.cdtarifa%type;
   vr_cdhistor      crapfvl.cdhistor%type;
   vr_cdhisest      crapfvl.cdhisest%type;
   vr_vltarifa      crapfco.vlmaxtar%type;
   vr_dtdivulg      crapfco.dtdivulg%type;
   vr_dtvigenc      crapfco.dtvigenc%type;
   vr_cdfvlcop      crapfco.cdfvlcop%type;
   vr_rowid_craplat rowid;

   -- PL Tables
   vr_tab_impress_coop     rati0001.typ_tab_impress_coop;
   vr_tab_impress_rating   rati0001.typ_tab_impress_rating;
   vr_tab_impress_risco_cl rati0001.typ_tab_impress_risco;
   vr_tab_impress_risco_tl rati0001.typ_tab_impress_risco;
   vr_tab_impress_assina   rati0001.typ_tab_impress_assina;
   vr_tab_efetivacao       rati0001.typ_tab_efetivacao;
   vr_tab_ratings          rati0001.typ_tab_ratings;
   vr_tab_crapras          rati0001.typ_tab_crapras;
   vr_tab_erro             gene0001.typ_tab_erro;

   --     Verifica Conta (Cadastro de associados)
   cursor cr_crapass is
   select dtelimin
         ,cdsitdtl
         ,cdagenci
         ,inpessoa
         ,nrdconta
   from   crapass
   where  crapass.cdcooper = pr_cdcooper
   and    crapass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;

   --     Busca capa do lote
   cursor cr_craplot is
   select nvl(max(nrdolote), 0) + 1
   from   craplot
   where  cdcooper = pr_cdcooper
   and    dtmvtolt = rw_crapdat.dtmvtolt
   and    cdagenci = pr_cdagenci
   and    cdbccxlt = 700;
   
   cursor cr_crawlim is
   select nvl(lim.nrctrmnt,0) nrctrmnt
         ,lim.vllimite
         ,lim.cddlinha
         ,lim.insitapr
		 ,lim.idcobope
   from   crawlim lim
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrctrlim = pr_nrctrlim;
   rw_crawlim cr_crawlim%rowtype;
   
   cursor cr_craplim is
   select lim.cdcooper
         ,lim.nrdconta
         ,lim.nrctrlim
         ,lim.tpctrlim
         ,lim.vllimite		 
   from   craplim lim
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrctrlim = rw_crawlim.nrctrmnt;
   rw_craplim cr_craplim%rowtype;

BEGIN
   --    Verifica se a data esta cadastrada
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_saida;
   end   if;
   close btch0001.cr_crapdat;

   -- Incluir nome do modulo logado
   gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT'
                             ,pr_action => null);

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
         close cr_crawlim;
         vr_dscritic := 'Proposta de limite de desconto de título não encontado. Conta ' || pr_nrdconta || ' proposta ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_crawlim;
   
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   vr_flcraplim := cr_craplim%FOUND;
   close cr_craplim;
   
   --  Quando o campo nrctrmnt for zero, significa que a proposta é a principal de criação do contrato do limite. Neste momento deve-se
   --  inserir o contrato do limite.
   --  Caso contrário, se tiver preenchido, significa que é uma proposta de alteração de valores. Neste momento deve-se atualizar o valor
   --  do contrato do limite.
   if  rw_crawlim.nrctrmnt = 0 then
       
       pc_inserir_contrato_limite(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 ,pr_dscritic => vr_dscritic );

       if  vr_cdcritic > 0  or vr_dscritic is not null then
           raise vr_exc_saida;
       end if;

       --    Verifica se ja existe lote criado
       open  cr_craplot;
       fetch cr_craplot into vr_nrdolote;
       close cr_craplot;

       -- Se não, cria novo lote
       begin
          insert into craplot(cdcooper
                             ,dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,tplotmov
                             ,nrseqdig
                             ,qtcompln
                             ,qtinfoln
                             ,vlcompcr
                             ,vlinfocr
                             ,cdoperad)
                      values (pr_cdcooper
                             ,rw_crapdat.dtmvtolt
                             ,pr_cdagenci
                             ,700
                             ,vr_nrdolote
                             ,35 -- Título
                             ,1
                             ,1
                             ,1
                             ,rw_crawlim.vllimite
                             ,rw_crawlim.vllimite
                             ,pr_cdoperad);
       exception
          when others then
               vr_dscritic := 'Erro ao inserir capa do lote. ' || sqlerrm;
               raise vr_exc_saida;
       end;

       -- Cria lancamento de contratos de descontos.
       begin
          insert into crapcdc(dtmvtolt
                             ,cdagenci
                             ,cdbccxlt
                             ,nrdolote
                             ,nrdconta
                             ,nrctrlim
                             ,vllimite
                             ,nrseqdig
                             ,cdcooper
                             ,tpctrlim)
                      values (rw_crapdat.dtmvtolt
                             ,pr_cdagenci
                             ,700
                             ,vr_nrdolote
                             ,pr_nrdconta
                             ,pr_nrctrlim
                             ,rw_crawlim.vllimite
                             ,1
                             ,pr_cdcooper
                             ,pr_tpctrlim);
       exception
          when others then
               vr_dscritic := 'Erro ao criar lancamento de contratos de descontos. ' || sqlerrm;
               raise vr_exc_saida;
       end;

       open  cr_crapass;
       fetch cr_crapass into rw_crapass;
       close cr_crapass;

       if  rw_crapass.inpessoa = 1 then
           vr_cdbattar := 'DSTCONTRPF'; -- Pessoa Física
       else
           vr_cdbattar := 'DSTCONTRPJ'; -- Pessoa Jurídica
       end if;

       -- Buscar valores da tarifa vigente
       tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                                            ,pr_cdbattar => vr_cdbattar    --> Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                            ,pr_cdtarifa => vr_cdtarifa    --> Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                            ,pr_vllanmto => rw_crawlim.vllimite    --> Valor Lancamento
                                            ,pr_cdprogra => 'ATENDA'       --> Codigo Programa
                                             --
                                            ,pr_cdhistor => vr_cdhistor    --> Codigo Historico
                                            ,pr_cdhisest => vr_cdhisest    --> Historico Estorno
                                            ,pr_vltarifa => vr_vltarifa    --> Valor tarifa
                                            ,pr_dtdivulg => vr_dtdivulg    --> Data Divulgacao
                                            ,pr_dtvigenc => vr_dtvigenc    --> Data Vigencia
                                            ,pr_cdfvlcop => vr_cdfvlcop    --> Codigo faixa valor cooperativa
                                            ,pr_cdcritic => vr_cdcritic    --> Codigo Critica
                                            ,pr_dscritic => vr_dscritic    --> Descricao Critica
                                            ,pr_tab_erro => vr_tab_erro ); --> Tabela de retorno de erros

       if  vr_cdcritic > 0 or trim(vr_dscritic) is not null then
           if  vr_tab_erro.count() > 0 then
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
           else
               vr_cdcritic:= 0;
               vr_dscritic:= 'Nao foi possivel carregar a tarifa.';
           end if;
           raise vr_exc_saida;
       end if;

       -- Criar lançamento automático da tarifa
       tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                       ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data Lancamento
                                       ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                       ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                       ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                       ,pr_cdagenci => 1                     --> Codigo Agencia
                                       ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                       ,pr_nrdolote => 8452                  --> Numero do lote
                                       ,pr_tpdolote => 1                     --> Tipo do lote (35 - Título)
                                       ,pr_nrdocmto => 0                     --> Numero do documento
                                       ,pr_nrdctabb => pr_nrdconta           --> Numero da conta
                                       ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta, '99999999') --> Numero da conta integracao
                                       ,pr_cdpesqbb => ''                    --> Codigo pesquisa
                                       ,pr_cdbanchq => 0                     --> Codigo Banco Cheque
                                       ,pr_cdagechq => 0                     --> Codigo Agencia Cheque
                                       ,pr_nrctachq => 0                     --> Numero Conta Cheque
                                       ,pr_flgaviso => false                 --> Flag aviso
                                       ,pr_tpdaviso => 0                     --> Tipo aviso
                                       ,pr_cdfvlcop => vr_cdfvlcop           --> Codigo cooperativa
                                       ,pr_inproces => 1                     --> Indicador processo 1 = Online
                                        --
                                       ,pr_rowid_craplat => vr_rowid_craplat --> Rowid do lancamento tarifa
                                       ,pr_tab_erro      => vr_tab_erro      --> Tabela retorno erro
                                       ,pr_cdcritic      => vr_cdcritic      --> Codigo Critica
                                       ,pr_dscritic      => vr_dscritic);    --> Descricao Critica

       if  vr_cdcritic > 0 or trim(vr_dscritic) is not null then
           if  vr_tab_erro.count() > 0 then
               vr_cdcritic:= vr_tab_erro(vr_tab_erro.first).cdcritic;
               vr_dscritic:= vr_tab_erro(vr_tab_erro.first).dscritic;
           else
               vr_cdcritic:= 0;
               vr_dscritic:= 'Erro no lancamento da tarifa de proposta de limite de desconto de titulo';
           end if;
           raise vr_exc_saida;
       end if;

       -- Gera Rating
       rati0001.pc_gera_rating(pr_cdcooper => pr_cdcooper                         --> Codigo Cooperativa
                              ,pr_cdagenci => pr_cdagenci                         --> Codigo Agencia
                              ,pr_nrdcaixa => pr_nrdcaixa                         --> Numero Caixa
                              ,pr_cdoperad => pr_cdoperad                         --> Codigo Operador
                              ,pr_nmdatela => 'ATENDA'                            --> Nome da tela
                              ,pr_idorigem => pr_idorigem                         --> Identificador Origem
                              ,pr_nrdconta => pr_nrdconta                         --> Numero da Conta
                              ,pr_idseqttl => 1                                   --> Sequencial do Titular
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt                 --> Data de movimento
                              ,pr_dtmvtopr => rw_crapdat.dtmvtopr                 --> Data do próximo dia útil
                              ,pr_inproces => rw_crapdat.inproces                 --> Situação do processo
                              ,pr_tpctrrat => 3                                   --> Tipo Contrato Rating (2-Cheque / 3-Titulo)
                              ,pr_nrctrrat => pr_nrctrlim                         --> Numero Contrato Rating
                              ,pr_flgcriar => 1                                   --> Criar rating
                              ,pr_flgerlog => 1                                   -->  Identificador de geração de log
                              ,pr_tab_rating_sing => vr_tab_crapras               --> Registros gravados para rating singular
                              ,pr_tab_impress_coop => vr_tab_impress_coop         --> Registro impressão da Cooperado
                              ,pr_tab_impress_rating => vr_tab_impress_rating     --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina => vr_tab_impress_assina     --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao => vr_tab_efetivacao             --> Registro dos itens da efetivação
                              ,pr_tab_ratings  => vr_tab_ratings                  --> Informacoes com os Ratings do Cooperado
                              ,pr_tab_crapras  => vr_tab_crapras                  --> Tabela com os registros processados
                              ,pr_tab_erro => vr_tab_erro                         --> Tabela de retorno de erro
                              ,pr_des_reto => vr_des_erro);                       --> Ind. de retorno OK/NOK

       --  Em caso de erro
       if  vr_des_erro <> 'OK' then
           vr_cdcritic:= vr_tab_erro(0).cdcritic;
           vr_dscritic:= vr_tab_erro(0).dscritic;
           raise vr_exc_saida;
           return;
       end if;

       -- awae: Gerar histórico de Liberação de Proposta.
       vr_dsmotivo := 'LIBERAÇÃO DE LIMITE';
       
       -- Efetua os inserts para apresentacao na tela VERLOG
       gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => ' '
                           ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                           ,pr_dstransa => 'Efetivação de proposta de limite de desconto de títulos.'
                           ,pr_dttransa => trunc(sysdate)
                           ,pr_flgtrans => 1
                           ,pr_hrtransa => to_char(sysdate,'SSSSS')
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'ATENDA'
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_rowid_log);

   else
       if  NOT vr_flcraplim then
             vr_dscritic := 'Não foi encontrado um contrato de limite de desconto de título associado a proposta. Conta ' || pr_nrdconta || ' proposta ' || pr_nrctrlim;
             raise vr_exc_saida;
       end   if;
       
       begin
          update craplim lim
          set    vllimite = rw_crawlim.vllimite
                ,cddlinha = rw_crawlim.cddlinha
          where  lim.cdcooper = rw_craplim.cdcooper
          and    lim.nrdconta = rw_craplim.nrdconta
          and    lim.tpctrlim = rw_craplim.tpctrlim
          and    lim.nrctrlim = rw_craplim.nrctrlim;
       exception
          when others then
               vr_dscritic := 'Erro ao atualizar o valor e/ou linha de desconto do contrato de limite de desconto de título: '||sqlerrm;
               raise vr_exc_saida;
       end;
       
       IF (rw_crawlim.vllimite > rw_craplim.vllimite) THEN
         vr_dsmotivo := 'MAJORAÇÃO DE LIMITE';
       ELSE
         vr_dsmotivo := 'MANUTENÇÃO DE LIMITE';
       END IF;
       
   end if;

   -- Atualiza a Proposta de Limite de Desconto de Título
   begin
      update crawlim lim
      set    insitlim = 2
            ,insitest = 3
            ,insitapr = nvl(pr_insitapr, case when rw_crawlim.insitapr = 0 then 3 else insitapr end)
            ,qtrenova = 0
            ,dtinivig = rw_crapdat.dtmvtolt
            ,dtfimvig = (rw_crapdat.dtmvtolt + lim.qtdiavig)
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
   exception
      when others then
           vr_dscritic := 'Erro ao atualizar a proposta de limite de desconto de título. ' || sqlerrm;
           raise vr_exc_saida;
   end;

   -- awae: Gerar histórico de Majoração/manutenção de Proposta.
   pc_gravar_hist_alt_limite(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrlim => pr_nrctrlim
                            ,pr_tpctrlim => pr_tpctrlim
                            ,pr_dsmotivo => vr_dsmotivo
                            ,pr_cdcritic => vr_cdcritic 
                            ,pr_dscritic => vr_dscritic 
                            );
   if  vr_cdcritic > 0 or trim(vr_dscritic) is not null then
      raise vr_exc_saida;
   end if;
   -- Se possui cobertura vinculada
   IF rw_crawlim.idcobope > 0 AND vr_flcraplim = FALSE THEN
        -- Chama bloqueio/desbloqueio da garantia
        BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_idcobertura    => rw_crawlim.idcobope
                                            ,pr_inbloq_desbloq => 'B'
                                            ,pr_cdoperador     => '1'
                                            ,pr_vldesbloq      => 0
                                            ,pr_flgerar_log    => 'S'
                                            ,pr_dscritic       => vr_dscritic);
        -- Se houve erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
   END IF;

   
   --  Caso seja uma proposta de majoração, ou seja, se o valor da proposta for maior que o do contrato, E caso a 
   --  esteira não esteja em contingencia, então deve enviar a efetivação da proposta para o Ibratan
   IF  ( ((rw_crawlim.vllimite > rw_craplim.vllimite) AND vr_flcraplim = TRUE ) OR vr_flcraplim = FALSE ) AND
       NOT fn_contigencia_motor_esteira(pr_cdcooper => pr_cdcooper) AND 
       (rw_crawlim.insitapr <> 1) THEN
       este0003.pc_efetivar_limite_esteira(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctrlim => pr_nrctrlim
                                          ,pr_tpctrlim => pr_tpctrlim
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_cdoperad => pr_cdoperad
                                          ,pr_cdorigem => 9 --Esteira
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

       IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
           vr_dscritic := 'Erro ao enviar a efetivação da proposta para o Ibratan: '||vr_dscritic;
           RAISE vr_exc_saida;
       END IF;
   END IF;

   COMMIT;

EXCEPTION
   when vr_exc_saida then
        if  vr_cdcritic <> 0 then
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        ROLLBACK;

   when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_efetivar_proposta: ' || sqlerrm;

        ROLLBACK;
END;
END pc_efetivar_proposta;


PROCEDURE pc_efetivar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Contrato
                                  ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  /*----------------------------------------------------------------------------------
   Procedure: pc_efetivar_proposta_web
   Sistema  : CRED
   Sigla    : TELA_ATENDA_DSCTO_TIT
   Autor    : Gustavo Guedes de Sene - Company: GFT
   Data     : Criação: 22/02/2018    Ultima atualização: 10/04/2018
  
   Dados referentes ao programa:
  
   Frequencia:
   Objetivo  :

   Histórico de Alterações:
    22/02/2018 - Versão inicial
    13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta
                 somente se tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT))
    10/04/2018 - Alterado atualização da tabela de contrato craplim pela tabela de proposta crawlim (Paulo Penteado (GFT))
    
  ----------------------------------------------------------------------------------*/
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

   -- Variavel de criticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida   exception;
   vr_retorna_msg exception;

   -- Variaveis de log
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_cdagenci_ass varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

   -- Variaveis auxiliares
   vr_vlmaxleg     crapcop.vlmaxleg%type;
   vr_vlmaxutl     crapcop.vlmaxutl%type;
   vr_vlminscr     crapcop.vlcnsscr%type;
   vr_par_nrdconta integer;
   vr_par_dsctrliq varchar2(1000);
   vr_par_vlutiliz number;
   vr_qtctarel     integer;
   vr_flggrupo     integer;
   vr_nrdgrupo     integer;
   vr_dsdrisco     varchar2(2);
   vr_gergrupo     varchar2(1000);
   vr_dsdrisgp     varchar2(1000);
   vr_mensagem_01  varchar2(1000);
   vr_mensagem_02  varchar2(1000);
   vr_mensagem_03  varchar2(1000);
   vr_mensagem_04  varchar2(1000);
   vr_mensagem_05  varchar2(1000); -- Mensagem que informa se o Processo de Análise Automática (IBRATAN) está em Contingência
   vr_tab_grupo    geco0001.typ_tab_crapgrp;
   vr_valor        crawlim.vllimite%type;
   vr_index        integer;
   vr_str_grupo    varchar2(32767) := '';
   vr_vlutilizado  varchar2(100) := '';
   vr_vlexcedido   varchar2(100) := '';
   vr_em_contingencia_ibratan boolean;

   cursor cr_crapcop is
   select vlmaxleg
         ,vlmaxutl
         ,vlcnsscr
   from   crapcop
   where  cdcooper = vr_cdcooper;
   rw_crapcop cr_crapcop%rowtype;

   cursor cr_crawlim is
   select vllimite
         ,insitlim
   from   crawlim
   where  cdcooper = vr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := NULL;
   
   -- Extrai os dados vindos do XML
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
   if  vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   pc_validar_efetivacao_proposta(pr_cdcooper          => vr_cdcooper
                                 ,pr_nrdconta          => pr_nrdconta
                                 ,pr_nrctrlim          => pr_nrctrlim
                                 ,pr_cdagenci          => vr_cdagenci_ass
                                 ,pr_tab_crapdat       => rw_crapdat
                                 ,pr_cdcritic          => vr_cdcritic
                                 ,pr_dscritic          => vr_dscritic);

   if  vr_cdcritic > 0 or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_cdagenci := nvl(nullif(vr_cdagenci, 0), vr_cdagenci_ass);

   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   if    cr_crawlim%notfound then
         close cr_crawlim;
         vr_cdcritic := 484;
         raise vr_exc_saida;
   end   if;
   close cr_crawlim;

   -- Verificar se a esteira e/ou motor estão em contigencia e armazenar na variavel
   vr_em_contingencia_ibratan := fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);

   --  1º Passo: Executamos a Operação = 0 para verificar se existe alguma inconsistência para emitir mensagem de
   --  alerta, e solicitar confirmação do usuário para prosseguir com a confirmação do novo limite
   if  pr_cddopera = 0 then
       -- Inicializa variaveis
       vr_vlmaxleg     := 0;
       vr_vlmaxutl     := 0;
       vr_vlminscr     := 0;
       vr_par_nrdconta := pr_nrdconta;
       vr_par_dsctrliq := ' ';
       vr_par_vlutiliz := 0;
       vr_qtctarel     := 0;

       open  cr_crapcop;
       fetch cr_crapcop into rw_crapcop;
       if    cr_crapcop%found then
             vr_vlmaxleg := rw_crapcop.vlmaxleg;
             vr_vlmaxutl := rw_crapcop.vlmaxutl;
             vr_vlminscr := rw_crapcop.vlcnsscr;
       end   if;
       close cr_crapcop;

       -- Verifica se tem grupo economico em formacao
       geco0001.pc_busca_grupo_associado(pr_cdcooper => vr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_flggrupo => vr_flggrupo
                                        ,pr_nrdgrupo => vr_nrdgrupo
                                        ,pr_gergrupo => vr_gergrupo
                                        ,pr_dsdrisgp => vr_dsdrisgp);
       --  Se tiver grupo economico em formacao
       if  vr_gergrupo is not null then
           vr_mensagem_01 := vr_gergrupo || ' Confirma?';
       end if;

       --  Se conta pertence a um grupo
       if  vr_flggrupo = 1 then
           geco0001.pc_calc_endivid_grupo(pr_cdcooper  => vr_cdcooper
                                         ,pr_cdagenci  => vr_cdagenci
                                         ,pr_nrdcaixa  => 0
                                         ,pr_cdoperad  => vr_cdoperad
                                         ,pr_nmdatela  => vr_nmdatela
                                         ,pr_idorigem  => 1
                                         ,pr_nrdgrupo  => vr_nrdgrupo
                                         ,pr_tpdecons  => true
                                         ,pr_dsdrisco  => vr_dsdrisco
                                         ,pr_vlendivi  => vr_par_vlutiliz
                                         ,pr_tab_grupo => vr_tab_grupo
                                         ,pr_cdcritic  => vr_cdcritic
                                         ,pr_dscritic  => vr_dscritic);

           if  vr_cdcritic > 0 or vr_dscritic is not null then
               raise vr_exc_saida;
           end if;

           if  vr_vlmaxutl > 0 then
               --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
               if  rw_crawlim.vllimite > vr_par_vlutiliz then
                   vr_valor := rw_crawlim.vllimite;
               else
                   vr_valor := vr_par_vlutiliz;
               end if;

               --  Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
               if  vr_valor > vr_vlmaxutl then
                   vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||'.';
               end if;

               --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
               if  vr_valor > vr_vlmaxleg then
                   vr_mensagem_03 := 'Valor Legal Excedido';
                   vr_vlutilizado := to_char(vr_par_vlutiliz,'999G999G990D00');
                   vr_vlexcedido  := to_char((vr_valor - vr_vlmaxutl),'999G999G990D00');

                   -- Abre tabela do grupo
                   vr_str_grupo := '<grupo>';
                   vr_qtctarel  := 0;
                   vr_index     := vr_tab_grupo.first;

                   while vr_index is not null loop
                         -- Popula tabela do grupo
                         vr_str_grupo := vr_str_grupo || '<conta>' ||
                                         to_char(gene0002.fn_mask_conta((vr_tab_grupo(vr_index).nrctasoc)))
                                         || '</conta>';
                         vr_index     := vr_tab_grupo.next(vr_index);
                         vr_qtctarel  := vr_qtctarel + 1;
                   end   loop;

                   -- Encerra tabela grupo
                   vr_str_grupo := vr_str_grupo || '</grupo><qtctarel>' || vr_qtctarel || '</qtctarel>';
               end if;

               --  Verifica se o valor é maior que o valor da consulta SCR
               if  vr_valor > vr_vlminscr then
                   vr_mensagem_04 := 'Efetue consulta no SCR.';
               end if;
           end if;

       else --  Se conta nao pertence a um grupo
           gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                                    ,pr_tpdecons    => 1
                                    ,pr_dsctrliq    => vr_par_dsctrliq
                                    ,pr_cdprogra    => vr_nmdatela
                                    ,pr_nrdconta    => vr_par_nrdconta
                                    ,pr_tab_crapdat => rw_crapdat
                                    ,pr_inusatab    => true
                                    ,pr_vlutiliz    => vr_par_vlutiliz
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);

           --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
           if  vr_vlmaxutl > 0 then
               if  rw_crawlim.vllimite > vr_par_vlutiliz then
                   vr_valor := rw_crawlim.vllimite;
               else
                   vr_valor := vr_par_vlutiliz;
               end if;

               -- Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
               if  vr_valor > vr_vlmaxutl then
                   vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
               end if;

               --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
               if  vr_valor > vr_vlmaxleg then
                   vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
               end if;

               --  Verifica se o valor é maior que o valor da consulta SCR
               if  vr_valor > vr_vlminscr then
                   vr_mensagem_04 := 'Efetue consulta no SCR.';
               end if;
           end if;
       end if;

       --  Verificar se o tanto o motor quanto a esteria estão em contingencia para mostrar a mensagem de alerta, sou seja, mostrar
       --  mensagem de alerta somente se o motor E a esteira estiverem em contingencia.
       if fn_contigencia_motor_esteira(pr_cdcooper => vr_cdcooper) or (rw_crawlim.insitlim = 1) then
           vr_mensagem_05 := 'Atenção: Para efetivar é necessário ter efetuado a análise manual do limite! Confirma análise do limite?';
       end if;

       --  Se houver alguma Mensagem/Inconsistência, emitir mensagem para o usuario
       if  vr_mensagem_01 is not null or vr_mensagem_02 is not null or vr_mensagem_03 is not null or
           vr_mensagem_04 is not null or vr_mensagem_05 is not null then

           -- Criar cabecalho do XML
           pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>' ||
                                          '<Msg>' ||
                                              '<msg_01>' || vr_mensagem_01 || '</msg_01>' ||
                                              '<msg_02>' || vr_mensagem_02 || '</msg_02>' ||
                                              '<msg_03>' || vr_mensagem_03 || '</msg_03>' ||
                                              '<msg_04>' || vr_mensagem_04 || '</msg_04>' ||
                                              '<msg_05>' || vr_mensagem_05 || '</msg_05>' ||
                                                            vr_str_grupo   ||
                                              '<vlutil>' || vr_vlutilizado || '</vlutil>' ||
                                              '<vlexce>' || vr_vlexcedido  || '</vlexce>' ||
                                          '</Msg></Root>');

       -- Se não houver nenhuma Mensagem/Inconsistência, efetuar o processo de Confirmação do novo Limite normalmente
       else
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- Título
                               ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => null -- Decisão = Retorno da IBRATAN
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

           if  vr_dscritic is not null then
               raise vr_exc_saida;
           end if;

           pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
       end if;

   --  2º Passo: Se houve alguma Mensagem/Inconsistência e o Operador Ayllos confirmou (ou seja, clicou em "SIM" ou "OK"),
   --  efetuar o processo de Confirmação do novo Limite.
   --  Se houver Contigência de Motor e/ou Esteira, será efetuada a Confirmação do novo Limite na situação de Contigência.
   else
       if  vr_em_contingencia_ibratan then
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- Título
                               ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => 3 -- Decisão = APROVADO (CONTINGENCIA)      
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
           
           if  vr_dscritic is not null then
               raise vr_exc_saida;
           end if;
       else
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- Título
                               ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => null -- Decisão = Retorno da IBRATAN
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
           
           if  vr_dscritic is not null then
               raise vr_exc_saida;
           end if;
       end if;

       pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
   end if;

EXCEPTION
   when vr_exc_saida then
        pr_des_erro := 'NOK';
        if  vr_cdcritic <> 0 then
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

   when others then
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_efetivar_proposta_web: ' || sqlerrm;

        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_efetivar_proposta_web;


PROCEDURE pc_cancelar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> Código do Operador
                              ,pr_idorigem    in integer               --> Identificador Origem Chamada
                              ,pr_cdcritic    out pls_integer          --> Codigo da critica
                              ,pr_dscritic    out varchar2             --> Descricao da critica
                              ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_cancelar_proposta
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para cancelar uma proposta de limite de desconto de titulo.

    Alteração : 12/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis auxiliares
   vr_rowid_log    rowid;
   vr_insitapr     number;
   
   cursor cr_crawlim is
   select lim.insitlim
         ,lim.insitest
   from   crawlim lim
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   close cr_crawlim; 

   -- Verifica se a situação está Anulada
   -- PRJ 438 - Paulo Martins - Mouts - INICIO
   if  rw_crawlim.insitlim = 9 then
       vr_dscritic := 'Esta Proposta esta "Anulada"';
       raise vr_exc_saida;
   end if; 
   -- PRJ 438 - Paulo Martins - Mouts - FIM

   --  Verifica se a situação está 'Ativo' ou 'Cancelado'
   if  rw_crawlim.insitlim in (2,3) then
       vr_dscritic := 'Para esta operação, a situação da Proposta não deve ser "Ativa"';-- ou "Cancelada".';
       raise vr_exc_saida;
   end if;

   if  fn_em_contingencia_ibratan(pr_cdcooper => pr_cdcooper) then
       vr_insitapr := 6; -- Rejeitado com contingencia
   else
       vr_insitapr := null;
   end if;

   begin
      update crawlim lim
      set    insitlim = 3 -- cancelado
            ,insitest = 3 -- analise finalizada
            ,insitapr = nvl(vr_insitapr, insitapr)
            ,dtrejeit = trunc(sysdate)
            ,hrrejeit = to_char(sysdate,'SSSSS')
            ,cdoperej = pr_cdoperad
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
   exception
      when others then
           vr_dscritic := 'Erro ao cancelar a proposta de limite de desconto de título. ' || sqlerrm;
           raise vr_exc_saida;
   end;

   -- Efetua os inserts para apresentacao na tela VERLOG
   gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_dscritic => ' '
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                       ,pr_dstransa => 'Cancelamento da Proposta de Limite de Desconto de Títulos.'
                       ,pr_dttransa => trunc(sysdate)
                       ,pr_flgtrans => 1
                       ,pr_hrtransa => to_char(sysdate,'SSSSS')
                       ,pr_idseqttl => 1
                       ,pr_nmdatela => 'ATENDA'
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdrowid => vr_rowid_log);

EXCEPTION
   when vr_exc_saida then
        if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

   when others then
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_cancelar_proposta: ' || sqlerrm;

END pc_cancelar_proposta;


PROCEDURE pc_cancelar_proposta_web(pr_nrdconta in  crapass.nrdconta%type --> Número da Conta
                                  ,pr_nrctrlim in  crawlim.nrctrlim%type --> Contrato
                                  ,pr_xmllog   in  varchar2              --> XML com informacoes de LOG
                                  ,pr_cdcritic out pls_integer           --> Codigo da critica
                                  ,pr_dscritic out varchar2              --> Descricao da critica
                                  ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                  ,pr_des_erro out varchar2              --> Erros do processo
                                  ) is
BEGIN
  ----------------------------------------------------------------------------------
  -- Procedure: pc_cancelar_proposta_web
  -- Sistema  : CRED
  -- Sigla    : TELA_ATENDA_DSCTO_TIT
  -- Autor    : Gustavo Guedes de Sene - Company: GFT
  -- Data     : Criação: 01/03/2018    Ultima atualização: 01/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  :
  --
  --
  -- Histórico de Alterações:
  --  01/03/2018 - Criação
  --  10/04/2018 - Adicionado a procedure pc_cancelar_proposta. Renomeado esta para
  --               pc_cancelar_proposta_web (Paulo Penteado (GFT))
  --
  ----------------------------------------------------------------------------------
DECLARE
   -- Variavel de criticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida   exception;
   vr_retorna_msg exception;

   -- Variaveis de log
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN
   pr_nmdcampo := NULL;
   -- Incluir nome do modulo logado
   gene0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT'
                             ,pr_action => null);

   -- Extrai os dados vindos do XML
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   if  vr_dscritic is not null then
       raise vr_exc_saida;
   end if;
   
   pc_cancelar_proposta(pr_cdcooper => vr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrctrlim => pr_nrctrlim
                       ,pr_tpctrlim => 3
                       ,pr_cdoperad => vr_cdoperad
                       ,pr_idorigem => vr_idorigem
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
   pr_des_erro := 'OK';

   COMMIT;

EXCEPTION
   when vr_exc_saida then
        if  vr_cdcritic <> 0 then
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        end if;
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

   when others then
        pr_des_erro := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_cancelar_proposta_web: ' || sqlerrm;

        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
END;
END pc_cancelar_proposta_web;


PROCEDURE pc_retorno_proposta_autom(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                   ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                   ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                   ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                                   ,pr_cdoperad    in crapope.cdoperad%type --> Código do Operador
                                   ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                                   ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                                   ,pr_idorigem    in integer               --> Identificador Origem Chamada
                                   ,pr_cdcritic    out pls_integer          --> Codigo da critica
                                   ,pr_dscritic    out varchar2             --> Descricao da critica
                                   ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_retorno_proposta_autom
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para efetivar ou cancelar uma proposta de majoração automaticamente após o retorno da análise
                do ibratan.

    Alteração : 12/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;
   
   cursor cr_crawlim is
   select nvl(lim.nrctrmnt,0) nrctrmnt
         ,lim.insitlim
         ,lim.insitapr
   from   crawlim lim
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_crawlim cr_crawlim%rowtype;

BEGIN
   open  cr_crawlim;
   fetch cr_crawlim into rw_crawlim;
   close cr_crawlim; 
   
   --  se trata-se de um contrato de majoração
   if  rw_crawlim.nrctrmnt > 0 then
       --    se retornou da análise do ibratan como Aprovada, efetivar a proposta
       if    rw_crawlim.insitlim = 5 then
             pc_efetivar_proposta(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_insitapr => null
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic );

             if  vr_cdcritic > 0  or vr_dscritic is not null then
                 raise vr_exc_saida;
             end if;

       --    se retornou da análise do ibratan como Não Aprovada, cancelar a proposta
       elsif (rw_crawlim.insitlim = 6 OR rw_crawlim.insitlim = 8) AND rw_crawlim.insitapr = 4 then
             pc_cancelar_proposta(pr_cdcooper => pr_cdcooper

                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic );

             if  vr_cdcritic > 0  or vr_dscritic is not null then
                 raise vr_exc_saida;
             end if;
       end   if;
   end if;

EXCEPTION
   when vr_exc_saida then
        if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

   when others then
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_retorno_proposta_autom: ' || sqlerrm;

END pc_retorno_proposta_autom;


PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  crawlim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  crawlim.tpctrlim%type --> Tipo de contrato do limite
                              ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                              ,pr_dtmovito in  varchar2              --> Data do movimento atual
                              ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                              ,pr_cdcritic out pls_integer           --> Codigo da critica
                              ,pr_dscritic out varchar2              --> Descricao da critica
                              ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                              ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                              ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                              ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_analisar_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Dados referentes ao programa:
    Tipo do envestimento I - inclusao Proposta
                         D - Derivacao Proposta
                         A - Alteracao Proposta
                         N - Alterar Numero Proposta
                         C - Cancelar Proposta
                         E - Efetivar Proposta

    Caso a proposta já tenha sido enviada para a Esteira iremos considerar uma Alteracao.
    Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela ainda nao foi a Esteira

    Frequencia: Sempre que for chamado

    Objetivo  : Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.

    Alteração : 28/02/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   vr_dtmvtolt DATE;


   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN

   pr_des_erro := pr_xmllog; -- somente para não haver hint, caso for usado, pode remover essa linha
   pr_des_erro := 'OK';
   pr_nmdcampo := null;

   vr_dtmvtolt := to_date(pr_dtmovito, 'DD/MM/RRRR');

   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   if  vr_dscritic is not null then
       raise vr_exc_saida;
   end if;


   este0003.pc_enviar_proposta_esteira(pr_cdcooper => vr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_tpenvest => pr_tpenvest
                                      ,pr_nrctrlim => pr_nrctrlim
                                      ,pr_tpctrlim => pr_tpctrlim
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dtmvtolt => vr_dtmvtolt
                                      ,pr_dsmensag => vr_dsmensag
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_des_erro => pr_des_erro);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;
   

   pc_retorno_proposta_autom(pr_cdcooper => vr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrlim => pr_nrctrlim
                            ,pr_tpctrlim => pr_tpctrlim
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   --dbms_output.put_line(vr_dsmensag);
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>'||htf.escape_sc(vr_dsmensag)||'</dsmensag></Root>');

   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;


       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_analisar_proposta: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;

end pc_analisar_proposta;


PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  crawlim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  crawlim.tpctrlim%type --> Tipo de contrato do limite
                                   ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                   ,pr_dtmovito in  varchar2              -- crapdat.dtmvtolt%type  --> Data do movimento atual
                                   ,pr_xmllog   in  varchar2              --> XML com informações de LOG
                                   ,pr_cdcritic out pls_integer           --> Codigo da critica
                                   ,pr_dscritic out varchar2              --> Descricao da critica
                                   ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_enviar_proposta_manual
    Sistema  : Cred
    Sigla    : TELA_ATENDA_LIMDESCTIT
    Autor    : Paulo Penteado (GFT) 
    Data     : Março/2018
   
    Dados referentes ao programa:
   
    Frequencia: Sempre que for chamado
    
    Objetivo  : Procedure para enviar a analise para esteira após confirmação de senha
   
    Alteração : 05/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   vr_dtmvtolt DATE;
   
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);
     
   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN

   pr_des_erro := pr_xmllog; -- somente para não haver hint, caso for usado, pode remover essa linha
   pr_des_erro := 'OK';
   pr_nmdcampo := null;

   vr_dtmvtolt := to_date(pr_dtmovito, 'DD/MM/RRRR');

   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   este0003.pc_enviar_analise_manual(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_cdorigem => vr_idorigem
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrctrlim => pr_nrctrlim
                                    ,pr_tpctrlim => pr_tpctrlim
                                    ,pr_dtmvtolt => vr_dtmvtolt
                                    ,pr_nmarquiv => null
                                    ,vr_flgdebug => 'N'
                                    ,pr_dsmensag => vr_dsmensag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_des_erro => pr_des_erro );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_dsmensag := replace(replace(vr_dsmensag, '<b>', '\"'), '</b>', '\"');
   vr_dsmensag := replace(replace(vr_dsmensag, '<br>', ' '), '<BR>', ' ');
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>' || vr_dsmensag || '</dsmensag></Root>');

   
   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;
        
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
        
  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_enviar_proposta_manual: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_enviar_proposta_manual;

  
PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic  OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS          --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_renovar_lim_desc_titulo
    Sistema : Ayllos Web
    Autor   : Leonardo Oliveira (GFT)
    Data    : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para renovar limite de desconto de titulos.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variavel de criticas
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

      CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_nrdconta IN craplim.nrdconta%TYPE     --> Número da Conta
                       ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> Número do Contrato                    
                       
        SELECT craplim.vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.nrctrlim = pr_nrctrlim
           AND craplim.tpctrlim = 3; -- Limite de crédito de desconto de titulo
    rw_craplim cr_craplim%ROWTYPE;
    
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
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
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Consultar o limite de credito
      OPEN cr_craplim(pr_cdcooper => vr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctrlim => pr_nrctrlim);
      FETCH cr_craplim INTO rw_craplim;

      -- Verifica se o limite de credito existe
      IF cr_craplim%NOTFOUND THEN
        CLOSE cr_craplim;
        vr_dscritic := 'Associado não possui proposta de limite de desconto titulo.';
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_craplim;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Chama rotina de renovação
      LIMI0001.pc_renovar_lim_desc_titulo(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_vllimite => rw_craplim.vllimite
                                         ,pr_nrctrlim => pr_nrctrlim
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdoperad => vr_cdoperad
                                         ,pr_nmdatela => vr_nmdatela
                                         ,pr_cddlinha => pr_cddlinha
                                         ,pr_idorigem => vr_idorigem
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>ok</Dados></Root>');

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        pr_des_erro := 'NOK';
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_renovar_lim_desc_titulo: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_renovar_lim_desc_titulo;
  
PROCEDURE pc_alterar_proposta_manutencao(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_cdoperad    in crapope.cdoperad%type --> Código do Operador
                                        ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                                        ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                                        ,pr_idorigem    in integer               --> Identificador Origem Chamada
                                        ,pr_dsmensag    out varchar2             --> Mensagem enviada para tela
                                        ,pr_cdcritic    out pls_integer          --> Codigo da critica
                                        ,pr_dscritic    out varchar2             --> Descricao da critica
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_alterar_proposta_manutencao
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para alterar as informações de uma proposta de manutenção do contrato de limite

    Alteração : 25/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;
   
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis auxiliares
   vr_rowid_log    rowid;
   
   vr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
   vr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052 para CECRED
   
   cursor cr_crapldc is
   select nvl(ldc.flgstlcr,0) flgstlcr
   from   crapldc ldc 
   where  ldc.cdcooper = pr_cdcooper   
   AND    ldc.cddlinha = pr_cddlinha   
   AND    ldc.tpdescto = 3;
   rw_crapldc cr_crapldc%rowtype;
   
   cursor cr_craplim is
   select lim.vllimite
   from   craplim lim
         ,crawlim pro
   where  lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pro.nrctrmnt
   and    lim.tpctrlim = pr_tpctrlim
   and    pro.cdcooper = pr_cdcooper
   and    pro.nrdconta = pr_nrdconta
   and    pro.nrctrlim = pr_nrctrlim
   and    pro.tpctrlim = pr_tpctrlim;
   rw_craplim cr_craplim%rowtype;

   -- Verifica Conta (Cadastro de associados)
   cursor cr_crapass is
   select inpessoa
   from   crapass
   where  crapass.cdcooper = pr_cdcooper
   and    crapass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;
   
BEGIN
   open  cr_crapldc;
   fetch cr_crapldc into rw_crapldc;
   if    cr_crapldc%notfound then
         close cr_crapldc;
         vr_dscritic := 'Linha de desconto de título não cadastrada.';
         raise vr_exc_saida;
   else
         --  Verifica se a linha de credito esta liberada
         if  rw_crapldc.flgstlcr = 0 then
             vr_dscritic := 'Operação não permitida, linha de desconto '||pr_cddlinha||' bloqueada.';
             raise vr_exc_saida;
         end if;
   end   if;
   close cr_crapldc;

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   close cr_craplim; 
   
    --    Verifica se a data esta cadastrada
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_saida;
   end   if;
   close btch0001.cr_crapdat;
   
    --    Puxa o tipo de pessoa
   open  cr_crapass;
   fetch cr_crapass into rw_crapass;
   if    cr_crapass%notfound then
         close cr_crapass;
         vr_cdcritic := 9;
         raise vr_exc_saida;
   end   if;
   close cr_crapass;
   
    cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de operação
                                                 pr_nrdcaixa, --Número do caixa
                                                 pr_cdoperad, --Operador
                                                 rw_crapdat.dtmvtolt, -- Data da Movimentação
                                                 pr_idorigem, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 vr_tab_dados_dsctit,
                                                 vr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
     if  vr_cdcritic > 0  or vr_dscritic is not null then
        raise vr_exc_saida;
     end if;                                            
    
    /*LIMITE MAXIMO EXCEDIDO*/
    if pr_vllimite > vr_tab_dados_dsctit(1).vllimite then
        vr_dscritic := 'Limite máximo excedido.';
        raise vr_exc_saida;
    end if;                     
   
   begin
      update crawlim lim
      set    vllimite = pr_vllimite
            ,cddlinha = pr_cddlinha
            ,insitlim = 1
            ,insitest = 0
            ,dtenvest = null
            ,hrenvest = 0
            ,cdopeste = ' '
            ,insitapr = 0
            ,dtaprova = null
            ,hraprova = 0
            ,cdopeapr = null
      where  lim.cdcooper = pr_cdcooper
      and    lim.nrdconta = pr_nrdconta
      and    lim.nrctrlim = pr_nrctrlim
      and    lim.tpctrlim = pr_tpctrlim;
      
      pr_dsmensag := 'Proposta de majoração alterada com sucesso.';
   exception
      when others then
           vr_dscritic := 'Erro na alteração da proposta de manutenção do limite de desconto de título. ' || sqlerrm;
           raise vr_exc_saida;
   end;
   
   --  se o valor do limite informado na alteração for menor que o valor do contrato ativo, então deve-se efetivar a proposta
   if  pr_vllimite < rw_craplim.vllimite then
       pc_efetivar_proposta(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctrlim => pr_nrctrlim
                           ,pr_tpctrlim => pr_tpctrlim
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_idorigem => pr_idorigem
                           ,pr_insitapr => null
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic );

       if  vr_cdcritic > 0  or vr_dscritic is not null then
           raise vr_exc_saida;
       end if;
       
       pr_dsmensag := 'Proposta de majoração alterada e efetivada com sucesso.';
   end if;

   -- Efetua os inserts para apresentacao na tela VERLOG
   gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_dscritic => ' '
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                       ,pr_dstransa => 'Alteração da Proposta de Manutenção de Limite de Desconto de Títulos.'
                       ,pr_dttransa => trunc(sysdate)
                       ,pr_flgtrans => 1
                       ,pr_hrtransa => to_char(sysdate,'SSSSS')
                       ,pr_idseqttl => 1
                       ,pr_nmdatela => 'ATENDA'
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdrowid => vr_rowid_log);

EXCEPTION
   when vr_exc_saida then
        if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;        
   when others then
        pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_alterar_proposta_manutencao: ' || sqlerrm;

END pc_alterar_proposta_manutencao;

PROCEDURE pc_alterar_proposta_manute_web(pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                         -- OUT
                                        ,pr_cdcritic out pls_integer          --> Codigo da critica
                                        ,pr_dscritic out varchar2             --> Descric?o da critica
                                        ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                        ,pr_des_erro out varchar2             --> Erros do processo
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_alterar_proposta_manutencao
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para alterar as informações de uma proposta de manutenção do contrato de limite

    Alteração : 25/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

   vr_dsmensag varchar2(10000);

BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := null;
   
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_alterar_proposta_manutencao(pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrlim => pr_nrctrlim
                                 ,pr_tpctrlim => pr_tpctrlim
                                 ,pr_vllimite => pr_vllimite
                                 ,pr_cddlinha => pr_cddlinha
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_dsmensag => vr_dsmensag
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;
   
   pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                  '<Root><dsmensag>'||vr_dsmensag||'</dsmensag></Root>');
   
   COMMIT;

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                        
       ROLLBACK;

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_alterar_proposta_manute_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                        
       ROLLBACK;

END pc_alterar_proposta_manute_web;
      

PROCEDURE pc_obtem_dados_proposta(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_tpctrlim           in crawlim.tpctrlim%type   --> Tipo de contrato de Limite
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_proposta out typ_tab_dados_proposta --> Saida com os dados do empréstimo
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_dados_proposta
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Objetivo  : Procedure para carregar as informações da proposta na type

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;

   vr_idxdados pls_integer;
   vr_dtpropos date;
   
   rw_crapdat  btch0001.cr_crapdat%rowtype;

   cursor cr_crawlim is
   select lim.dtpropos
         ,case when nvl(lim.nrctrmnt,0) > 0 then lim.nrctrmnt
               else ctr.nrctrlim
          end nrctrmnt
         ,lim.nrctrlim
         ,lim.vllimite
         ,lim.qtdiavig
         ,lim.cddlinha
         ,lim.insitlim
         ,case lim.insitlim when 1 then 'EM ESTUDO'
                            when 2 then 'ATIVA'
                            when 3 then 'CANCELADA'
                            when 5 then 'APROVADA'
                            when 6 then 'NAO APROVADA'
                            when 8 then 'EXPIRADA DECURSO DE PRAZO'
                            when 9 then 'ANULADA' -- PRJ438 -- Paulo Martins (Mouts)
                            else        'DIFERENTE'
          end dssitlim
         ,lim.insitest
         ,case lim.insitest when 0 then 'NAO ENVIADO'
                            when 1 then 'ENVIADA ANALISE AUTOMATICA'
                            when 2 then 'ENVIADA ANALISE MANUAL'
                            when 3 then 'ANALISE FINALIZADA'
                            when 4 then 'EXPIRADA'
                            else        'DIFERENTE'
          end dssitest
         ,lim.insitapr
         ,case lim.insitapr when 0 then 'NAO ANALISADO'
                            when 1 then 'APROVADA AUTOMATICAMENTE'
                            when 2 then 'APROVADA MANUAL'
                            when 3 then 'APROVADA'
                            when 4 then 'REJEITADA MANUAL'
                            when 5 then 'REJEITADA AUTOMATICAMENTE'
                            when 6 then 'REJEITADA'
                            when 7 then 'NAO ANALISADA'
                            when 8 then 'REFAZER'
                            else        'DIFERENTE'
          end dssitapr
         ,case when nvl(lim.nrctrmnt,0) > 0 then 1
               else 0
          end inctrmnt
   from   crawlim lim
     left outer join craplim ctr on (ctr.nrctrlim = lim.nrctrlim and
                                     ctr.tpctrlim = lim.tpctrlim and
                                     ctr.nrdconta = lim.nrdconta and
                                     ctr.cdcooper = lim.cdcooper)
   where  case --   mostrar propostas em situações de analise (em estudo) ou canceladas dentro de x dias
               when lim.insitlim in (1,3,5,6,8) and lim.dtpropos >= vr_dtpropos then 1
               --   mostrar somente a última proposta ativa
               when lim.insitlim = 2 and
                    lim.nrctrlim = (select max(lim_ativo.nrctrlim)
                                    from   crawlim lim_ativo
                                    where  lim_ativo.insitlim = 2
                                    and    lim_ativo.tpctrlim = pr_tpctrlim
                                    and    lim_ativo.nrdconta = pr_nrdconta
                                    and    lim_ativo.cdcooper = pr_cdcooper
                                    and    lim_ativo.dtpropos = (select max(lim_ativo.dtpropos)
                                                                 from   crawlim lim_ativo
                                                                 where  lim_ativo.insitlim = 2
                                                                 and    lim_ativo.tpctrlim = pr_tpctrlim
                                                                 and    lim_ativo.nrdconta = pr_nrdconta
                                                                 and    lim_ativo.cdcooper = pr_cdcooper)) then 1
               --   mostrar todas as demais
               when lim.insitlim in (4,7,9) then 1 -- Incluído 9 - PRJ 438 -- Paulo Martins - Mouts
               else 0
          end = 1
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper
   order  by case when lim.insitlim = 1 then -3
                  when lim.insitlim = 5 then -2
                  when lim.insitlim = 6 then -1
                  when lim.insitlim = 8 then -1
                  else lim.insitlim
             end
           , lim.nrctrmnt
           , lim.nrctrlim;
   rw_crawlim cr_crawlim%rowtype;
     
BEGIN
   vr_cdcritic := 0;
   vr_dscritic := null;

   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_erro;
   end   if;
   close btch0001.cr_crapdat;

   vr_dtpropos := rw_crapdat.dtmvtolt -90;

   open  cr_crawlim;
   loop
         fetch cr_crawlim into rw_crawlim;
         exit  when cr_crawlim%notfound;

         vr_idxdados := pr_tab_dados_proposta.count() + 1;

         pr_tab_dados_proposta(vr_idxdados).dtpropos := rw_crawlim.dtpropos;
         pr_tab_dados_proposta(vr_idxdados).nrctrlim := rw_crawlim.nrctrlim;
         pr_tab_dados_proposta(vr_idxdados).vllimite := rw_crawlim.vllimite;
         pr_tab_dados_proposta(vr_idxdados).qtdiavig := rw_crawlim.qtdiavig;
         pr_tab_dados_proposta(vr_idxdados).cddlinha := rw_crawlim.cddlinha;
         pr_tab_dados_proposta(vr_idxdados).nrctrmnt := rw_crawlim.nrctrmnt;
         
         pr_tab_dados_proposta(vr_idxdados).dssitlim := rw_crawlim.dssitlim;
         pr_tab_dados_proposta(vr_idxdados).dssitest := rw_crawlim.dssitest;
         pr_tab_dados_proposta(vr_idxdados).dssitapr := rw_crawlim.dssitapr;
         
         pr_tab_dados_proposta(vr_idxdados).insitlim := rw_crawlim.insitlim;
         pr_tab_dados_proposta(vr_idxdados).insitest := rw_crawlim.insitest;
         pr_tab_dados_proposta(vr_idxdados).insitapr := rw_crawlim.insitapr;
         
         pr_tab_dados_proposta(vr_idxdados).inctrmnt := rw_crawlim.inctrmnt;

         pr_qtregist := nvl(pr_qtregist,0) + 1;
   end   loop;
   close cr_crawlim;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

   when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro pc_obtem_dados_proposta: ' || sqlerrm, chr(13)),chr(10));
END pc_obtem_dados_proposta;


PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                      -- OUT
                                     ,pr_cdcritic out pls_integer          --> Codigo da critica
                                     ,pr_dscritic out varchar2             --> Descric?o da critica
                                     ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                     ,pr_des_erro out varchar2             --> Erros do processo
                                     ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_dados_proposta_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Objetivo  : Procedure para carregar as informações da proposta na tela

    Alteração : 26/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_proposta typ_tab_dados_proposta;
   vr_qtregist           number;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);


BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := NULL;
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_obtem_dados_proposta(pr_cdcooper           => vr_cdcooper
                          ,pr_nrdconta           => pr_nrdconta
                          ,pr_tpctrlim           => 3
                          ,pr_qtregist           => vr_qtregist
                          ,pr_tab_dados_proposta => vr_tab_dados_proposta
                          ,pr_cdcritic           => vr_cdcritic
                          ,pr_dscritic           => vr_dscritic
                          );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;


   vr_des_xml        := null;
   vr_texto_completo := null;
   vr_index          := vr_tab_dados_proposta.first;
   
   dbms_lob.createtemporary(vr_des_xml, true);
   dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
   
   pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                  '<Dados qtregist="' || vr_qtregist ||'" >');

   while vr_index is not null loop
         pc_escreve_xml('<inf>' ||
                           '<dtpropos>'|| to_char(vr_tab_dados_proposta(vr_index).dtpropos, 'DD/MM/RRRR') ||'</dtpropos>'||
                           '<nrctrlim>'|| vr_tab_dados_proposta(vr_index).nrctrlim ||'</nrctrlim>'||
                           '<vllimite>'|| to_char(vr_tab_dados_proposta(vr_index).vllimite, 'FM999G999G999G990D00') ||'</vllimite>'||
                           '<qtdiavig>'|| vr_tab_dados_proposta(vr_index).qtdiavig ||'</qtdiavig>'||
                           '<cddlinha>'|| vr_tab_dados_proposta(vr_index).cddlinha ||'</cddlinha>'||
                           '<nrctrmnt>'|| nullif(vr_tab_dados_proposta(vr_index).nrctrmnt,0) ||'</nrctrmnt>'||
                           '<dssitlim>'|| vr_tab_dados_proposta(vr_index).dssitlim ||'</dssitlim>'||
                           '<dssitest>'|| vr_tab_dados_proposta(vr_index).dssitest ||'</dssitest>'||
                           '<dssitapr>'|| vr_tab_dados_proposta(vr_index).dssitapr ||'</dssitapr>'||
                           '<insitlim>'|| vr_tab_dados_proposta(vr_index).insitlim ||'</insitlim>'||
                           '<insitest>'|| vr_tab_dados_proposta(vr_index).insitest ||'</insitest>'||
                           '<insitapr>'|| vr_tab_dados_proposta(vr_index).insitapr ||'</insitapr>'||
                           '<inctrmnt>'|| vr_tab_dados_proposta(vr_index).inctrmnt ||'</inctrmnt>'||
                        '</inf>');

       vr_index := vr_tab_dados_proposta.next(vr_index);
   end loop;

   pc_escreve_xml ('</Dados></Root>',true);

   pr_retxml := xmltype.createxml(vr_des_xml);

   -- Liberando a memória alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_dados_proposta_web: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_dados_proposta_web;


PROCEDURE pc_obtem_proposta_aciona(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                  ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_nrctrlim           in crawlim.nrctrlim%type   --> Numero do Contrato do Limite
                                  ,pr_tpctrlim           in crawlim.tpctrlim%type   --> Tipo de contrato de Limite
                                  ,pr_nrctrmnt           in crawlim.tpctrlim%type   --> Numero da proposta do Limite
                                  ,pr_qtregist           out integer                --> Qtde total de registros
                                  ,pr_tab_dados_proposta out typ_tab_dados_proposta --> Saida com os dados do empréstimo
                                  ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                  ,pr_dscritic           out varchar2               --> Descricao da critica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_proposta_aciona
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para carregar as informações da proposta na type para filtro na tela de detalhes do acionamento

    Alteração : 11/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;

   vr_idxdados pls_integer;
   
   cursor cr_crawlim is
   select lim.nrctrlim
         ,lim.nrctrmnt
         ,lim.dtpropos
         ,lim.vllimite
         ,lim.cddlinha
   from   crawlim lim
   where  lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper
   and    pr_nrctrmnt  = 0
   
   union  all
   
   select lim.nrctrlim
         ,lim.nrctrmnt
         ,lim.dtpropos
         ,lim.vllimite
         ,lim.cddlinha
   from   crawlim lim
   where  lim.nrctrmnt = decode(pr_nrctrmnt, 0, pr_nrctrlim, pr_nrctrmnt)
   and    lim.nrctrlim = decode(pr_nrctrmnt, 0, lim.nrctrlim, pr_nrctrlim)
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper;
   rw_crawlim cr_crawlim%rowtype;
   
BEGIN
   vr_cdcritic := 0;
   vr_dscritic := null;
   
   open  cr_crawlim;
   loop
         fetch cr_crawlim into rw_crawlim;
         exit  when cr_crawlim%notfound;
         
         vr_idxdados := pr_tab_dados_proposta.count() + 1;
         
         pr_tab_dados_proposta(vr_idxdados).dtpropos := rw_crawlim.dtpropos;
         pr_tab_dados_proposta(vr_idxdados).nrctrlim := rw_crawlim.nrctrlim;
         pr_tab_dados_proposta(vr_idxdados).vllimite := rw_crawlim.vllimite;
         pr_tab_dados_proposta(vr_idxdados).cddlinha := rw_crawlim.cddlinha;
         pr_tab_dados_proposta(vr_idxdados).nrctrmnt := rw_crawlim.nrctrmnt;
         
         pr_qtregist := nvl(pr_qtregist,0) + 1;
   end   loop;
   close cr_crawlim;

EXCEPTION
   when vr_exc_erro then
        if  nvl(vr_cdcritic,0) <> 0 and trim(vr_dscritic) is null then
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        else
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
        end if;

   when others then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace('Erro pc_obtem_proposta_aciona: ' || sqlerrm, chr(13)),chr(10));
END pc_obtem_proposta_aciona;


PROCEDURE pc_obtem_proposta_aciona_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                      ,pr_nrctrlim in crawlim.nrctrlim%type --> Numero do Contrato do Limite
                                      ,pr_nrctrmnt in crawlim.tpctrlim%type --> Numero da proposta do Limite
                                      ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                       -- OUT
                                      ,pr_cdcritic out pls_integer          --> Codigo da critica
                                      ,pr_dscritic out varchar2             --> Descric?o da critica
                                      ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                      ,pr_des_erro out varchar2             --> Erros do processo
                                      ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_proposta_aciona_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para carregar as informações da proposta na tela de detalhes do acionamento

    Alteração : 11/04/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_proposta typ_tab_dados_proposta;
   vr_qtregist           number;
   vr_index              pls_integer;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);

BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := NULL;
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_obtem_proposta_aciona(pr_cdcooper           => vr_cdcooper
                           ,pr_nrdconta           => pr_nrdconta
                           ,pr_nrctrlim           => pr_nrctrlim
                           ,pr_tpctrlim           => 3
                           ,pr_nrctrmnt           => pr_nrctrmnt
                           ,pr_qtregist           => vr_qtregist
                           ,pr_tab_dados_proposta => vr_tab_dados_proposta
                           ,pr_cdcritic           => vr_cdcritic
                           ,pr_dscritic           => vr_dscritic);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;


   vr_des_xml        := null;
   vr_texto_completo := null;
   vr_index          := vr_tab_dados_proposta.first;
   
   dbms_lob.createtemporary(vr_des_xml, true);
   dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
   
   pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                  '<Dados qtregist="' || vr_qtregist ||'" >');

   while vr_index is not null loop
         pc_escreve_xml('<proposta_aciona>' ||
                           '<nrctrlim>'|| vr_tab_dados_proposta(vr_index).nrctrlim ||'</nrctrlim>'||
                           '<vllimite>'|| to_char(vr_tab_dados_proposta(vr_index).vllimite, 'FM999G999G999G990D00') ||'</vllimite>'||
                           '<cddlinha>'|| vr_tab_dados_proposta(vr_index).cddlinha ||'</cddlinha>'||
                           '<dtpropos>'|| to_char(vr_tab_dados_proposta(vr_index).dtpropos, 'DD/MM/RRRR') ||'</dtpropos>'||
                           '<nrctrmnt>'|| vr_tab_dados_proposta(vr_index).nrctrmnt ||'</nrctrmnt>'||
                        '</proposta_aciona>');

       vr_index := vr_tab_dados_proposta.next(vr_index);
   end loop;

   pc_escreve_xml ('</Dados></Root>',true);

   pr_retxml := xmltype.createxml(vr_des_xml);

   -- Liberando a memória alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_proposta_aciona_web: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_proposta_aciona_web;


  PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da Movimentação
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN crapcob.dtvencto%TYPE  --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                  ,pr_dtemissa IN crapbdt.dtmvtolt%TYPE DEFAULT NULL --> Filtro data de Emissao do borderô
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) is

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulos
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT) / Andrew Albuquerque (GFT)
    Data     : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que filtra os titulos na tela de inclusao de bordero

    Alteração : ??/03/2018 - Criação Luis Fernando (GFT) / Andrew Albuquerque (GFT)
                15/05/2018 - Adicionado o parâmetro pr_dt
                15/05/2018 - Adicionado os parâmetros pr_dtemissa, pr_nriniseq e pr_nrregist (Paulo Penteado (GFT))
                09/08/2018 - Problema com titulos que estavam não aparecendo quando resgatado. (Vitor Shimada Assanuma (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   vr_qtprzmaxpj number; -- Prazo Máximo PJ (Em dias)
   vr_qtprzmaxpf number; -- Prazo Máximo PF (Em dias)
   
   vr_qtprzminpj number; -- Prazo Mínimo PJ (Em dias)
   vr_qtprzminpf number; -- Prazo Mínimo PF (Em dias)
   
   vr_vlminsacpj number; -- Valor mínimo permitido por título PJ
   vr_vlminsacpf number; -- Valor mínimo permitido por título PF
   vr_dtvencto    DATE;
   vr_idtabtitulo PLS_INTEGER;

   pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
   pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
   
   vr_countpag    INTEGER := 1 ; -- contador para controlar a paginacao
   
   vr_tab_criticas dsct0003.typ_tab_critica;
   -- Tratamento de erros
   vr_exc_erro exception;
       
      CURSOR cr_crapcob IS
      SELECT rownum numero_linha,
                  cob.progress_recid, -- numero sequencial do titulo (verificar a utilidade
             cob.cdcooper,
             cob.nrdconta,
             cob.nrctremp, -- numero do contrato de limite.
             cob.nrcnvcob, -- convênio
             cob.nrdocmto, -- nr. boleto
             cob.nrinssac, -- cpf/cnpj do Pagador (Antigo SACADO)
             sab.nmdsacad, -- nome do pagador (o campo NMDSACAD da crapcob não está preenchido...)
             cob.dtvencto, -- data de vencimento
             cob.dtmvtolt, -- data de movimento
             cob.vltitulo,  -- valor do título
             cob.nrnosnum, -- nosso numero 
             cob.flgregis, -- flag registrado.
             cob.cdtpinsc,  -- Codigo do tipo da inscricao do sacado(0-nenhum/1-CPF/2-CNPJ)
             nvl((
                SELECT 
                   decode(inpossui_criticas,1,'S','N')
                FROM 
                   tbdsct_analise_pagador tap 
                WHERE tap.cdcooper=cob.cdcooper AND tap.nrdconta=cob.nrdconta AND tap.nrinssac=cob.nrinssac
             ),'A') AS dssituac, -- Situacao do pagador com critica ou nao
             cob.nrdctabb,
             cob.cdbandoc
        FROM cecred.crapcob cob -- titulos
       INNER JOIN cecred.crapsab sab -- dados do sacado, para pegar o nome do sacado corretamente
          ON sab.nrinssac = cob.nrinssac 
         AND sab.cdcooper = cob.cdcooper
         AND sab.nrdconta = cob.nrdconta
         -- Regras Fixas
       WHERE cob.nrdconta = pr_nrdconta
         AND cob.cdcooper = pr_cdcooper
         AND cob.flgregis > 0 -- Indicador de Registro CIP (0-Sem registro CIP/ 1-Registro Online/ 2-Registro offline)
         AND cob.incobran = 0
         -- regras da TAB052
         -- Valor da tabela crapcob (vltitulo) está menor do que o valor que está na tab052 (Valor mínimo permitido por título) - vlmintgc 
         AND cob.vltitulo >= decode(cob.cdtpinsc, 1, vr_vlminsacpf, vr_vlminsacpj)
         -- Prazo calculado entre a data de inclusão e o vencimento é menor do que está na tab052 (prazo mínimo) qtprzmin
       AND (cob.dtvencto - pr_dtmvtolt) >= decode(cob.cdtpinsc, 1, vr_qtprzminpf, vr_qtprzminpj)
         -- Prazo calculado entre a data de inclusão e o vencimento é maior do que está na tab052 (prazo máximo) qtprzmax
       AND (cob.dtvencto - pr_dtmvtolt) <= decode(cob.cdtpinsc, 1, vr_qtprzmaxpf, vr_qtprzmaxpj)

         -- Filtros Variáveis - Tela
         AND (cob.nrinssac = pr_nrinssac OR nvl(pr_nrinssac,0)=0)
         AND (cob.vltitulo = pr_vltitulo OR nvl(pr_vltitulo,0)=0)
         AND (cob.dtvencto = vr_dtvencto OR vr_dtvencto IS NULL)
       AND (cob.dtmvtolt = pr_dtemissa OR pr_dtemissa IS NULL)
         AND (cob.nrnosnum LIKE '%'||pr_nrnosnum||'%' OR nvl(pr_nrnosnum,0)=0) -- o campo correto para "Nosso Número"
       ;
         rw_crapcob cr_crapcob%ROWTYPE;
         
        
    /*Cursor para verificar se boleto já nao esta em outro bordero*/   
    CURSOR cr_craptdb (pr_nrdocmto IN craptdb.nrdocmto%TYPE, pr_nrdctabb IN craptdb.nrdctabb%TYPE, pr_nrcnvcob IN craptdb.nrcnvcob%TYPE, pr_nrborder IN craptdb.nrborder%TYPE) IS
     SELECT 
        craptdb.nrdocmto,
        craptdb.nrborder,
        craptdb.insitapr,
        CASE WHEN (SELECT COUNT(1) FROM craptdb INNER JOIN crapbdt ON craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
          WHERE craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = pr_cdcooper
            AND craptdb.nrdocmto = pr_nrdocmto
            AND craptdb.nrdctabb = pr_nrdctabb
            AND craptdb.nrcnvcob = pr_nrcnvcob
            AND craptdb.nrborder <> nvl(pr_nrborder,0)
            AND craptdb.dtresgat IS NULL
            AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
            AND craptdb.insitapr = 0) > 0 THEN 1 ELSE 0 END AS fl_aberto, --Somente titulos aprovados
        CASE WHEN (SELECT COUNT(1) FROM craptdb INNER JOIN crapbdt ON craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
          WHERE craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = pr_cdcooper
            AND craptdb.nrdocmto = pr_nrdocmto
            AND craptdb.nrdctabb = pr_nrdctabb
            AND craptdb.nrcnvcob = pr_nrcnvcob
            AND craptdb.dtresgat IS NULL
            AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
            AND craptdb.insitapr = 1) > 0 THEN 1 ELSE 0 END AS fl_aprovado, --Somente titulos aprovados
         CASE WHEN (SELECT COUNT(1) FROM craptdb 
           WHERE craptdb.nrdconta = pr_nrdconta
             AND craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdocmto = pr_nrdocmto
             AND craptdb.nrdctabb = pr_nrdctabb
             AND craptdb.nrcnvcob = pr_nrcnvcob
             AND craptdb.dtresgat IS NULL
             AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
             AND craptdb.nrborder = pr_nrborder) > 0 THEN 1 ELSE 0 END AS fl_bordero --Somente titulos aprovados
     FROM
        craptdb
        INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
     WHERE
        craptdb.nrdconta = pr_nrdconta
        AND craptdb.cdcooper = pr_cdcooper
        AND craptdb.nrdocmto = pr_nrdocmto
        AND craptdb.nrdctabb = pr_nrdctabb
        AND craptdb.nrcnvcob = pr_nrcnvcob
        AND craptdb.dtresgat IS NULL
        AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
        -- Retirar os titulos que ja foram aprovados em algum bordero
   ;rw_craptdb cr_craptdb%ROWTYPE;
   BEGIN
     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
   
      pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursos
     
      vr_dtvencto := null;
       IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := pr_dtvencto;
       END IF;
      --carregando os dados de prazo limite da TAB052 
       -- BUSCAR O PRAZO PARA PESSOA FISICA
      cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de operação
                                                 pr_nrdcaixa, --Número do caixa
                                                 pr_cdoperad, --Operador
                                                 pr_dtmvtolt, -- Data da Movimentação
                                                 pr_idorigem, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 1, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpf := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpf := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpf := pr_tab_dados_dsctit(1).vlminsac;

      -- BUSCAR O PRAZO PARA PESSOA JURÍDICA
      cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de operação
                                                 pr_nrdcaixa, --Número do caixa
                                                 pr_cdoperad, --Operador
                                                 pr_dtmvtolt, -- Data da Movimentação
                                                 pr_idorigem, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 2, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpj := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpj := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpj := pr_tab_dados_dsctit(1).vlminsac;
      
      -- abrindo cursos de títulos
      OPEN cr_crapcob;
      LOOP
        FETCH cr_crapcob INTO rw_crapcob;
        EXIT WHEN cr_crapcob%NOTFOUND;
        IF rw_crapcob.dssituac = 'N' THEN
          vr_tab_criticas.delete;
          dsct0003.pc_calcula_restricao_titulo(pr_cdcooper => rw_crapcob.cdcooper
                          ,pr_nrdconta => rw_crapcob.nrdconta
                          ,pr_nrdocmto => rw_crapcob.nrdocmto
                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                          ,pr_nrdctabb => rw_crapcob.nrdctabb
                          ,pr_cdbandoc => rw_crapcob.cdbandoc
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;
          IF (vr_tab_criticas.count>0) THEN
            rw_crapcob.dssituac := 'S';
          END IF;
        END IF;
        /*verifica se já nao está em outro bordero*/
       open cr_craptdb (pr_nrdocmto=>rw_crapcob.nrdocmto, pr_nrdctabb => rw_crapcob.nrdctabb, pr_nrcnvcob => rw_crapcob.nrcnvcob, pr_nrborder => pr_nrborder);
         fetch cr_craptdb into rw_craptdb;
         if  cr_craptdb%NOTFOUND 
            OR (cr_craptdb%found AND rw_craptdb.nrborder IS NOT NULL AND (rw_craptdb.fl_bordero = 1 OR rw_craptdb.fl_aprovado = 0) AND rw_craptdb.fl_aberto = 0 ) THEN
            IF (pr_nriniseq + pr_nrregist)=0 OR (vr_countpag >= pr_nriniseq AND vr_countpag < (pr_nriniseq + pr_nrregist)) THEN
              vr_idtabtitulo := pr_tab_dados_titulos.count + 1;
              pr_tab_dados_titulos(vr_idtabtitulo).progress_recid := rw_crapcob.progress_recid;
              pr_tab_dados_titulos(vr_idtabtitulo).cdcooper       := rw_crapcob.cdcooper;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdconta       := rw_crapcob.nrdconta;
              pr_tab_dados_titulos(vr_idtabtitulo).nrctremp       := rw_crapcob.nrctremp;
              pr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob       := rw_crapcob.nrcnvcob;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdocmto       := rw_crapcob.nrdocmto;
              pr_tab_dados_titulos(vr_idtabtitulo).nrinssac       := rw_crapcob.nrinssac;
              pr_tab_dados_titulos(vr_idtabtitulo).nmdsacad       := rw_crapcob.nmdsacad;
              pr_tab_dados_titulos(vr_idtabtitulo).dtvencto       := rw_crapcob.dtvencto;
              pr_tab_dados_titulos(vr_idtabtitulo).vltitulo       := rw_crapcob.vltitulo;
              pr_tab_dados_titulos(vr_idtabtitulo).nrnosnum       := rw_crapcob.nrnosnum;
              pr_tab_dados_titulos(vr_idtabtitulo).flgregis       := rw_crapcob.flgregis;
              pr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc       := rw_crapcob.cdtpinsc;
              pr_tab_dados_titulos(vr_idtabtitulo).dssituac       := rw_crapcob.dssituac;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdctabb       := rw_crapcob.nrdctabb;
              pr_tab_dados_titulos(vr_idtabtitulo).cdbandoc       := rw_crapcob.cdbandoc;
            END IF;
            vr_countpag := vr_countpag + 1;  
         end if;
         
       close cr_craptdb;
      END LOOP;
      pr_qtregist := nvl(vr_countpag,0);

    EXCEPTION
      WHEN vr_exc_erro THEN
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_cdcritic := 0;
           pr_dscritic := 'erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_buscar_titulos ' ||sqlerrm;
                                  
  END pc_buscar_titulos_bordero;
  
  PROCEDURE pc_buscar_titulos_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS
    -- variaveis de retorno
    vr_tab_dados_titulos typ_tab_dados_titulos;

    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_qtregist         number;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_dtvencto crapcob.dtvencto%TYPE;
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
      
      vr_dtvencto := NULL;
      IF pr_dtvencto IS NOT NULL THEN
        vr_dtvencto := to_date(pr_dtvencto,'DD/MM/RRRR');
      END IF;

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      pc_buscar_titulos_bordero(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_nrdconta => pr_nrdconta --> Número da Conta
                               ,pr_cdagenci => vr_cdagenci --> Agencia de operação
                               ,pr_nrdcaixa => vr_nrdcaixa --> Número do caixa
                               ,pr_cdoperad => vr_cdoperad --> Operador
                               ,pr_dtmvtolt => vr_dtmvtolt --> Data da Movimentação
                               ,pr_idorigem => vr_idorigem --> Identificação de origem
                               ,pr_nrinssac => pr_nrinssac --> Filtro de Inscricao do Pagador
                               ,pr_vltitulo => pr_vltitulo --> Filtro de Valor do titulo
                               ,pr_dtvencto => vr_dtvencto --> Filtro de Data de vencimento
                               ,pr_nrnosnum => pr_nrnosnum --> Filtro de Nosso Numero
                               ,pr_nrctrlim => pr_nrctrlim --> Contrato
                               ,pr_insitlim => pr_insitlim --> Status
                               ,pr_tpctrlim => pr_tpctrlim --> Tipo de desconto
                               ,pr_nrborder => pr_nrborder --> Numero do bordero
                               ,pr_nriniseq => pr_nriniseq --> Paginação Inicial
                               ,pr_nrregist => pr_nrregist --> Quantidade de Registros
                               --------> OUT <-------
                               ,pr_qtregist          => vr_qtregist --> Quantidade de registros encontrados
                               ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                               ,pr_cdcritic          => vr_cdcritic --> Código da crítica
                               ,pr_dscritic          => vr_dscritic --> Descrição da crítica
                       );
      
    
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');
                     
      -- ler os registros de titulos e incluir no xml
      vr_index := vr_tab_dados_titulos.first;
      WHILE (vr_index is not null) LOOP
            pc_escreve_xml('<inf>'||
                              '<progress_recid>' || vr_tab_dados_titulos(vr_index).progress_recid || '</progress_recid>' ||
                              '<cdcooper>' || vr_tab_dados_titulos(vr_index).cdcooper || '</cdcooper>' ||
                              '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titulos(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                              '<nrctremp>' || vr_tab_dados_titulos(vr_index).nrctremp || '</nrctremp>' ||
                              '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                              '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                              '<nrinssac>' || vr_tab_dados_titulos(vr_index).nrinssac || '</nrinssac>' ||
                              '<nmdsacad>' || htf.escape_sc(vr_tab_dados_titulos(vr_index).nmdsacad) || '</nmdsacad>' ||
                              '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                              '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                              '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                              '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                              '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                              '<dssituac>' || vr_tab_dados_titulos(vr_index).dssituac || '</dssituac>' || 
                              '<nrdctabb>' || vr_tab_dados_titulos(vr_index).nrdctabb || '</nrdctabb>' || 
                              '<cdbandoc>' || vr_tab_dados_titulos(vr_index).cdbandoc || '</cdbandoc>' || 
                           '</inf>'
                          );
          /* buscar proximo */
        vr_qtregist := vr_qtregist + 1;
          vr_index := vr_tab_dados_titulos.next(vr_index);
      end LOOP;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_titulos_bordero_web;
    
    PROCEDURE pc_busca_dados_limite (pr_nrdconta IN craplim.nrdconta%TYPE
                                     ,pr_cdcooper IN craplim.cdcooper%TYPE
                                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                                     ,pr_insitlim IN craplim.insitlim%TYPE
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                     --------> OUT <--------
                                     ,pr_tab_dados_limite   out  typ_tab_dados_limite --> Tabela de retorno
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_limite
      Sistema  : Cred
      Sigla    : TELA_ATENDA_DSCTO_TIT
      Autor    : Luis Fernando (GFT) / 
      Data     : Março/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que lista os dados do contrato de limite
    ---------------------------------------------------------------------------------------------------------------------*/
      
      vr_vlutiliz    NUMBER;
      vr_qtutiliz    INTEGER;
      
       -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro

       -- Tratamento de erros
       vr_exc_erro exception;
       
       --TAB
       pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
       pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
       
      CURSOR cr_crapass IS
        SELECT
          crapass.inpessoa
        FROM
          crapass
        WHERE
          crapass.nrdconta = pr_nrdconta
          AND crapass.cdcooper = pr_cdcooper;
      rw_crapass cr_crapass%rowtype;
      
      CURSOR cr_craplim IS      
        SELECT 
          craplim.dtpropos,
          craplim.dtinivig,
          craplim.nrctrlim,
          craplim.vllimite,
          craplim.qtdiavig,
          craplim.cddlinha,
          craplim.tpctrlim,
          craplim.dtfimvig
        FROM 
          craplim
        where 
          craplim.cdcooper = pr_cdcooper
          AND craplim.tpctrlim = pr_tpctrlim
          AND craplim.nrdconta = pr_nrdconta
          AND craplim.insitlim = pr_insitlim
        ;
      rw_craplim cr_craplim%rowtype;
        
      CURSOR cr_craptdb IS
        SELECT 
             SUM(craptdb.vlsldtit) AS vlutiliz,
             count(1) AS qtutiliz
        FROM
             craptdb
             INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                                    crapcob.nrdconta = craptdb.nrdconta AND
                                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                    crapcob.nrdocmto = craptdb.nrdocmto
        WHERE 
             craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdconta = pr_nrdconta
             AND (craptdb.insittit=4 OR (craptdb.insittit=2 AND craptdb.dtdpagto=pr_dtmvtolt));
      rw_craptdb cr_craptdb%rowtype;
      BEGIN
        GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
        
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        IF (cr_crapass%NOTFOUND) THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Cooperado não cadastrado';
          raise vr_exc_erro;
        END IF;
        
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF (cr_craplim%NOTFOUND) THEN
         CLOSE cr_craplim;
         vr_dscritic := 'Conta não possui contrato de limite ativo.';
         raise vr_exc_erro;
        END IF;
        
        OPEN cr_craptdb;
        FETCH cr_craptdb INTO rw_craptdb;
        IF (cr_craptdb%NOTFOUND) THEN
           vr_vlutiliz := 0;
           vr_qtutiliz := 0;
        ELSE
           vr_vlutiliz := rw_craptdb.vlutiliz;
           vr_qtutiliz := rw_craptdb.qtutiliz;
        END IF;

      --carregando os dados de prazo limite da TAB052 
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 null, --Agencia de operação
                                                 null, --Número do caixa
                                                 null, --Operador
                                                 pr_dtmvtolt, -- Data da Movimentação
                                                 null, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      
        pr_tab_dados_limite(0).dtpropos := rw_craplim.dtpropos;
        pr_tab_dados_limite(0).dtinivig := rw_craplim.dtinivig;
        pr_tab_dados_limite(0).nrctrlim := rw_craplim.nrctrlim;
        pr_tab_dados_limite(0).vllimite := rw_craplim.vllimite;
        pr_tab_dados_limite(0).qtdiavig := rw_craplim.qtdiavig;
        pr_tab_dados_limite(0).cddlinha := rw_craplim.cddlinha;
        pr_tab_dados_limite(0).tpctrlim := rw_craplim.tpctrlim;
        pr_tab_dados_limite(0).vlutiliz := vr_vlutiliz;
        pr_tab_dados_limite(0).qtutiliz := vr_qtutiliz;
        pr_tab_dados_limite(0).dtfimvig := rw_craplim.dtfimvig;
        pr_tab_dados_limite(0).pctolera := pr_tab_dados_dsctit(1).pctolera;

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite ' ||sqlerrm;
    END pc_busca_dados_limite;
       
    PROCEDURE pc_busca_dados_limite_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo do contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Situacao do Contrato
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  ) IS
    /* -------------------------------------------------------------------------------------------------------
    - Alterações
    -   09/08/2018 - Vitor Shimada Assanuma (GFT) - Inclusão do paramentro da TAB052 de QtdMaxTit.
    -   15/08/2018 - Vitor Shimada Assanuma (GFT) - Incluso verificação (RAISE) caso não ache o contrato ativo.
    -
     ------------------------------------------------------------------------------------------------------- */
    pr_tab_dados_limite  typ_tab_dados_limite;          --> retorna dos dados
    vr_dtmvtolt          crapdat.dtmvtolt%TYPE;
    
    /* tratamento de erro */
    vr_exc_erro exception;
  
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- Cursor para buscar o tipo de pessoa.
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 
        crapass.inpessoa
      FROM 
        crapass
      WHERE 
        crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
        
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;

    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

    BEGIN
     pr_des_erro := 'OK';
     pr_nmdcampo := NULL;
     vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
 
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
                              
       pc_busca_dados_limite (pr_nrdconta,
                              vr_cdcooper,
                              pr_tpctrlim,
                              pr_insitlim,
                              vr_dtmvtolt,
                              ----OUT----
                              pr_tab_dados_limite,
                              vr_cdcritic,
                              vr_dscritic
                             );
      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF;
                             
       -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
       OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
       FETCH cr_crapass INTO rw_crapass;
       CLOSE cr_crapass;
       -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
       dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de operação
                                            NULL, --Número do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimentação
                                            NULL, --Identificação de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF;
 
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');
                     
      -- ler o resultado da busca do contrato de limite e incluir no xml
            pc_escreve_xml('<inf>'||
                              '<dtpropos>' || to_char(pr_tab_dados_limite(0).dtpropos,'dd/mm/rrrr') || '</dtpropos>' ||
                              '<dtinivig>' || to_char(pr_tab_dados_limite(0).dtinivig,'dd/mm/rrrr') || '</dtinivig>' ||
                              '<nrctrlim>' || pr_tab_dados_limite(0).nrctrlim || '</nrctrlim>' ||
                              '<vllimite>' || pr_tab_dados_limite(0).vllimite || '</vllimite>' ||
                              '<qtdiavig>' || pr_tab_dados_limite(0).qtdiavig || '</qtdiavig>' ||
                              '<cddlinha>' || pr_tab_dados_limite(0).cddlinha || '</cddlinha>' ||
                              '<tpctrlim>' || pr_tab_dados_limite(0).tpctrlim || '</tpctrlim>' ||
                              '<vlutiliz>' || pr_tab_dados_limite(0).vlutiliz || '</vlutiliz>' ||
                              '<qtutiliz>' || pr_tab_dados_limite(0).qtutiliz || '</qtutiliz>' ||
                              '<dtfimvig>' || to_char(pr_tab_dados_limite(0).dtfimvig,'dd/mm/rrrr') || '</dtfimvig>' ||
                              '<pctolera>' || pr_tab_dados_limite(0).pctolera || '</pctolera>' ||
                              '<qtmaxtit>' || vr_tab_dados_dsctit(1).qtmxtbay || '</qtmaxtit>' ||
                           '</inf>'
                          );
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_busca_dados_limite_web;    

  PROCEDURE pc_prepara_titulos_resumo (pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_titulos  out  typ_tab_dados_titulos --> Tabela de retorno de titulos
                                 ,pr_tab_pagadores      out  typ_tab_dados_pagador --> Tabela de retorno de pagadores
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_prepara_titulos
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Janeiro/2019

    Objetivo  : Procedure para carregar as informações dos titulos selecionados prestes a serem incluidos no bordero.
                Destaca também os pagadores agrupados desses títulos para consulta de Biro e analise de pagadores
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;
   BEGIN
    DECLARE
      vr_idtabtitulo INTEGER;
      vr_tab_cobs  gene0002.typ_split;
      vr_tab_chaves  gene0002.typ_split;
      vr_index     INTEGER;
      
      vr_aux       NUMBER;
    BEGIN 
    
       vr_tab_cobs := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                 pr_delimit => ',');
                                                 
       vr_idtabtitulo:=0;
       IF vr_tab_cobs.count() > 0 THEN
         /*Traz 1 linha para cada cobrança sendo selecionada*/
         vr_index := vr_tab_cobs.first;
         while vr_index is not null loop
           -- Pega a lsita de chaves por titulo
           vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => vr_tab_cobs(vr_index),
                                                 pr_delimit => ';');
           IF (vr_tab_chaves.count() > 0) THEN
             open cr_crapcob (pr_cdcooper,
                              pr_nrdconta,
                              vr_tab_chaves(4), -- Conta
                              vr_tab_chaves(3), -- Convenio
                              vr_tab_chaves(2), -- Conta base do banco
                              vr_tab_chaves(1)  -- Codigo do banco
                              );
             fetch cr_crapcob INTO rw_crapcob;
             IF (cr_crapcob%FOUND) THEN
               pr_tab_dados_titulos(vr_idtabtitulo).cdcooper := rw_crapcob.cdcooper;
               pr_tab_dados_titulos(vr_idtabtitulo).nrdconta := rw_crapcob.nrdconta;
               pr_tab_dados_titulos(vr_idtabtitulo).nrctremp := rw_crapcob.nrctremp;
               pr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob := rw_crapcob.nrcnvcob;
               pr_tab_dados_titulos(vr_idtabtitulo).nrdocmto := rw_crapcob.nrdocmto;
               pr_tab_dados_titulos(vr_idtabtitulo).nrinssac := rw_crapcob.nrinssac;
               pr_tab_dados_titulos(vr_idtabtitulo).nmdsacad := rw_crapcob.nmdsacad;
               pr_tab_dados_titulos(vr_idtabtitulo).dtvencto := rw_crapcob.dtvencto;
               pr_tab_dados_titulos(vr_idtabtitulo).dtmvtolt := rw_crapcob.dtmvtolt;
               pr_tab_dados_titulos(vr_idtabtitulo).vltitulo := rw_crapcob.vltitulo;
               pr_tab_dados_titulos(vr_idtabtitulo).nrnosnum := rw_crapcob.nrnosnum;
               pr_tab_dados_titulos(vr_idtabtitulo).flgregis := rw_crapcob.flgregis;
               pr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc := rw_crapcob.cdtpinsc;
               pr_tab_dados_titulos(vr_idtabtitulo).vldpagto := rw_crapcob.vldpagto;
               pr_tab_dados_titulos(vr_idtabtitulo).cdbandoc := rw_crapcob.cdbandoc;
               pr_tab_dados_titulos(vr_idtabtitulo).nrdctabb := rw_crapcob.nrdctabb;
               pr_tab_dados_titulos(vr_idtabtitulo).dtdpagto := rw_crapcob.dtdpagto;
               pr_tab_dados_titulos(vr_idtabtitulo).nrborder := rw_crapcob.nrborder;
               pr_tab_dados_titulos(vr_idtabtitulo).dtlibbdt := rw_crapcob.dtlibbdt;
               pr_tab_pagadores(rw_crapcob.nrinssac).nrinssac := rw_crapcob.nrinssac;
               pr_tab_pagadores(rw_crapcob.nrinssac).nrdconta := rw_crapcob.nrdconta;
               pr_tab_pagadores(rw_crapcob.nrinssac).cdcooper := rw_crapcob.cdcooper;
               pr_tab_pagadores(rw_crapcob.nrinssac).nrcepsac := rw_crapcob.nrcepsac;
               pr_tab_pagadores(rw_crapcob.nrinssac).inpessoa := rw_crapcob.cdtpinsc;
               pr_tab_pagadores(rw_crapcob.nrinssac).vlttitbd := nvl(pr_tab_pagadores(rw_crapcob.nrinssac).vlttitbd,0) + rw_crapcob.vltitulo;
               vr_idtabtitulo := vr_idtabtitulo + 1;
             END IF;
             close cr_crapcob;
           END IF;
           vr_index := vr_tab_cobs.next(vr_index);
         end loop;
       END IF;
       pr_qtregist := vr_idtabtitulo;

    EXCEPTION
      WHEN vr_exc_erro THEN
           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_prepara_titulos_resumo ' ||SQLERRM;
    END;
    
  END pc_prepara_titulos_resumo;


  PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_calcpagador        IN INT DEFAULT 1           --> Define se calcula o pagador 
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_listar_titulos_resumo
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Março/2018    

    Objetivo  : Procedure para carregar as informações dos titulos selecionados prestes a serem incluidos no bordero.
                17/01/2019 - Melhoria na procedure para realizar calculo apenas 1 vez por cpf
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   vr_tab_dados_pagador typ_tab_dados_pagador;
   -- Tratamento de erros
   vr_exc_erro exception;
   vr_aux NUMBER;
   BEGIN
    DECLARE
      vr_index     LONG;
    BEGIN 
       pc_prepara_titulos_resumo(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_chave => pr_chave
                                ,pr_qtregist => pr_qtregist
                                ,pr_tab_dados_titulos => pr_tab_dados_titulos
                                ,pr_tab_pagadores => vr_tab_dados_pagador
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
      
       IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic is NOT NULL) THEN
         RAISE vr_exc_erro;
       END IF;
         
       IF (pr_calcpagador = 1 AND vr_tab_dados_pagador.count > 0) THEN
         vr_index := vr_tab_dados_pagador.first;
         while vr_index is not null LOOP
               /*Faz calculo de liquidez e concentracao e atualiza as criticas*/
           DSCT0002.pc_atualiza_calculos_pagador ( pr_cdcooper => vr_tab_dados_pagador(vr_index).cdcooper
                                                  ,pr_nrdconta => vr_tab_dados_pagador(vr_index).nrdconta 
                                                  ,pr_nrinssac => vr_tab_dados_pagador(vr_index).nrinssac 
                                                     --------------> OUT <--------------
                                                     ,pr_pc_cedpag  => vr_aux
                                                     ,pr_qtd_cedpag => vr_aux
                                                     ,pr_pc_conc    => vr_aux
                                                     ,pr_qtd_conc   => vr_aux
                                                     ,pr_cdcritic   => vr_cdcritic
                                                     ,pr_dscritic   => vr_dscritic
                                    );
           IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic is NOT NULL) THEN
             RAISE vr_exc_erro;
           END IF;
               
           vr_index := vr_tab_dados_pagador.next(vr_index);
         END LOOP;
        END IF;
       pr_qtregist := pr_qtregist;

    EXCEPTION
      WHEN vr_exc_erro THEN
           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo ' ||SQLERRM;
    END;
    END pc_listar_titulos_resumo ;
    
    PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS

      -- variaveis de retorno
      vr_tab_dados_titulos typ_tab_dados_titulos;

      -- criticas
      vr_tab_criticas dsct0003.typ_tab_critica;

      /* tratamento de erro */
      vr_exc_erro exception;
    
      vr_qtregist         number;
      vr_index_critica    pls_integer;
      
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
     
      -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
     vr_situacao char(1);
     vr_nrinssac crapcob.nrinssac%TYPE;
     
      BEGIN
        pr_des_erro := 'OK';
        pr_nmdcampo := NULL;
        gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                                , pr_cdcooper => vr_cdcooper
                                , pr_nmdatela => vr_nmdatela
                                , pr_nmeacao  => vr_nmeacao
                                , pr_cdagenci => vr_cdagenci
                                , pr_nrdcaixa => vr_nrdcaixa
                                , pr_idorigem => vr_idorigem
                                , pr_cdoperad => vr_cdoperad
                                , pr_dscritic => vr_dscritic);

        pc_listar_titulos_resumo(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                         ,pr_nrdconta => pr_nrdconta --> Número da Conta
                         ,pr_chave => pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                         --------> OUT <--------
                         ,pr_qtregist => vr_qtregist --> Quantidade de registros encontrados
                         ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                         ,pr_cdcritic => vr_cdcritic --> Código da crítica
                         ,pr_dscritic => vr_dscritic --> Descrição da crítica
                         );
        
        -- inicializar o clob
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- inicilizar as informaçoes do xml
        vr_texto_completo := null;
        
        pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                       '<root><dados qtregist="' || vr_qtregist ||'" >');
                       
        -- ler os registros de titulos e incluir no xml
        vr_index := vr_tab_dados_titulos.first;
        while vr_index is not null LOOP
              SELECT (nvl((SELECT 
                              decode(inpossui_criticas,1,'S','N')
                              FROM 
                               tbdsct_analise_pagador tap 
                            WHERE tap.cdcooper=vr_cdcooper AND tap.nrdconta=pr_nrdconta AND tap.nrinssac=vr_tab_dados_titulos(vr_index).nrinssac
                         ),'A')) INTO vr_situacao FROM DUAL ; -- Situacao do pagador com critica ou nao
              IF (vr_situacao = 'N') THEN
                vr_tab_criticas.delete;
                dsct0003.pc_calcula_restricao_titulo(pr_cdcooper => vr_tab_dados_titulos(vr_index).cdcooper
                                ,pr_nrdconta => vr_tab_dados_titulos(vr_index).nrdconta
                                ,pr_nrdocmto => vr_tab_dados_titulos(vr_index).nrdocmto
                                ,pr_nrcnvcob => vr_tab_dados_titulos(vr_index).nrcnvcob
                                ,pr_nrdctabb => vr_tab_dados_titulos(vr_index).nrdctabb
                                ,pr_cdbandoc => vr_tab_dados_titulos(vr_index).cdbandoc
                                ,pr_tab_criticas => vr_tab_criticas
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_erro;
                END IF;
                IF (vr_tab_criticas.count>0) THEN
                  vr_situacao := 'S';
                END IF;
              END IF;
              vr_nrinssac := vr_tab_dados_titulos(vr_index).nrinssac;
              
              pc_escreve_xml('<titulos>'||
                                '<progress_recid>' || vr_tab_dados_titulos(vr_index).progress_recid || '</progress_recid>' ||
                                '<cdcooper>' || vr_tab_dados_titulos(vr_index).cdcooper || '</cdcooper>' ||
                                '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titulos(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                                '<nrctremp>' || vr_tab_dados_titulos(vr_index).nrctremp || '</nrctremp>' ||
                                '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                                '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                                '<nrinssac>' || vr_tab_dados_titulos(vr_index).nrinssac || '</nrinssac>' ||
                                '<nmdsacad>' || htf.escape_sc(vr_tab_dados_titulos(vr_index).nmdsacad) || '</nmdsacad>' ||
                                '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                                '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                                '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                                '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                                '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                                '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                                '<dssituac>' || vr_situacao || '</dssituac>' || 
                                '<sitibrat>' || DSCT0003.fn_spc_serasa(pr_cdcooper=>vr_cdcooper,pr_nrdconta=>pr_nrdconta,pr_nrcpfcgc=>vr_nrinssac) || '</sitibrat>' || 
                                '<cdbandoc>' || vr_tab_dados_titulos(vr_index).cdbandoc || '</cdbandoc>' ||
                                '<nrdctabb>' || vr_tab_dados_titulos(vr_index).nrdctabb || '</nrdctabb>' ||
                             '</titulos>'
                            );
            /* buscar proximo */
            vr_index := vr_tab_dados_titulos.next(vr_index);
        end loop;
        vr_tab_criticas.delete;
        /*Verifica as criticas do Cedente*/
        DSCT0003.pc_calcula_restricao_cedente(pr_cdcooper=>vr_cdcooper
                                      ,pr_nrdconta=>pr_nrdconta
                                      ,pr_cdagenci=>vr_cdagenci
                                      ,pr_nrdcaixa=>vr_nrdcaixa
                                      ,pr_cdoperad=>vr_cdoperad
                                      ,pr_nmdatela=>vr_nmdatela
                                      ,pr_idorigem=>vr_idorigem
                                      ,pr_idseqttl=>0
                                      ,pr_tab_criticas=>vr_tab_criticas
                                      ,pr_cdcritic=>vr_cdcritic
                                      ,pr_dscritic=>vr_dscritic
                                      );
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        IF (vr_tab_criticas.count > 0) THEN
          pc_escreve_xml('<cedente>');
          vr_index_critica := vr_tab_criticas.first;
          WHILE vr_index_critica IS NOT NULL LOOP
            pc_escreve_xml('<critica>'||
                              '<dsc>' || vr_tab_criticas(vr_index_critica).dscritica || '</dsc>'||
                              '<vlr>' || vr_tab_criticas(vr_index_critica).dsdetres || '</vlr>'||
                           '</critica>');    
            vr_index_critica := vr_tab_criticas.next(vr_index_critica);
          END LOOP;
          pc_escreve_xml('</cedente>');
        END IF;
        vr_tab_criticas.delete;
        /*Verifica as criticas do Bordero*/
        DSCT0003.pc_calcula_restricao_bordero(pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_tot_titulos => vr_qtregist
                                      ,pr_tab_criticas=>vr_tab_criticas
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      );
        IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        IF (vr_tab_criticas.count > 0) THEN
          pc_escreve_xml('<bordero>');
          vr_index_critica := vr_tab_criticas.first;
          WHILE vr_index_critica IS NOT NULL LOOP
            pc_escreve_xml('<critica>'||
                              '<dsc>' || vr_tab_criticas(vr_index_critica).dscritica || '</dsc>'||
                              '<vlr>' || vr_tab_criticas(vr_index_critica).dsdetres || '</vlr>'||
                           '</critica>');    
            vr_index_critica := vr_tab_criticas.next(vr_index_critica);
          END LOOP;
          pc_escreve_xml('</bordero>');
        END IF;
        
        pc_escreve_xml ('</dados></root>',true);
        pr_retxml := xmltype.createxml(vr_des_xml);

        /* liberando a memória alocada pro clob */
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      exception
        when vr_exc_erro then
             /*  se foi retornado apenas código */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descriçao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo_web ' ||sqlerrm;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_listar_titulos_resumo_web;
    

PROCEDURE pc_solicita_biro_bordero(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrinssac  IN crapcob.nrinssac%TYPE --> Numero de inscricao do sacado
                                  ,pr_vlttitbd  IN NUMBER                --> Valor total dos titulos do pagador para o novo bordero
                                  ,pr_inpessoa  IN crapsab.cdtpinsc%TYPE 
                                  ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                  ,pr_nrcepsac  IN crapsab.nrcepsac%TYPE                                  
                                  ,pr_cdoperad  IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_solicita_biro_bordero
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Procedure para realizar a consulta do biros dos pagadores de um bordero no Ibratan

    Alteração : 18/05/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
  vr_dscritic varchar2(1000);        --> Desc. Erro

  -- Tratamento de erros
  vr_exc_erro exception;

BEGIN
  sspc0001.pc_solicita_cons_bordero_biro(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrinssac => pr_nrinssac
                                        ,pr_vlttitbd => pr_vlttitbd
                                        ,pr_nrctrlim => pr_nrctrlim
                                        ,pr_inpessoa => pr_inpessoa
                                        ,pr_nrcepsac => pr_nrcepsac
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

  IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
  END IF;

EXCEPTION
  WHEN vr_exc_erro then
       IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       ELSE
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
       END IF;

  WHEN OTHERS then
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro geral na rotina pc_solicita_biro_bordero: '||SQLERRM;
END pc_solicita_biro_bordero;


PROCEDURE pc_solicita_biro_bordero_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE     --> Contrato de bordero                 
                                  ,pr_chave    IN varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_solicita_biro_bordero_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018

    Objetivo  : Procedure para realizar a consulta do biros dos pagadores de um bordero no Ibratan

    Alteração : 28/03/2018 - Criação (Paulo Penteado (GFT))
                18/05/2018 - Transformado a procedure em _web (Paulo Penteado (GFT)) 

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
   vr_tab_pagadores     tela_atenda_dscto_tit.typ_tab_dados_pagador;
   vr_qtregist          number;
   vr_index             LONG;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);
   fl_erro_biro BOOLEAN;

BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := NULL;
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_prepara_titulos_resumo(pr_cdcooper          => vr_cdcooper
                           ,pr_nrdconta          => pr_nrdconta
                           ,pr_chave             => pr_chave
                           ,pr_qtregist          => vr_qtregist
                           ,pr_tab_dados_titulos => vr_tab_dados_titulos
                           ,pr_tab_pagadores     => vr_tab_pagadores
                           ,pr_cdcritic          => vr_cdcritic
                           ,pr_dscritic          => vr_dscritic );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_index := vr_tab_pagadores.first;
   fl_erro_biro := FALSE;
   while vr_index is not null LOOP
         pc_solicita_biro_bordero(pr_cdcooper => vr_cdcooper
                                                 ,pr_nrdconta => pr_nrdconta
                                                 ,pr_nrinssac => vr_tab_pagadores(vr_index).nrinssac
                                                 ,pr_vlttitbd => vr_tab_pagadores(vr_index).vlttitbd
                                                 ,pr_nrctrlim => pr_nrctrlim
                                                 ,pr_inpessoa => vr_tab_pagadores(vr_index).inpessoa
                                                 ,pr_nrcepsac => vr_tab_pagadores(vr_index).nrcepsac
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

         --  Caso não consiga conexao ou der erro no biro, nao parar a execucao, tratar somente depois do loop
         if  vr_cdcritic > 0  or vr_dscritic is not null then
             fl_erro_biro := true;
         end if;

         vr_index := vr_tab_pagadores.next(vr_index);
   end   loop;
   
   --Caso tenha algum erro durante o BIRO levanta a exception
   if fl_erro_biro then
      raise vr_exc_saida;
   end if;
   
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>Ok</dsmensag></Root>');

EXCEPTION
  when vr_exc_saida then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_solicita_biro_bordero_web: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_solicita_biro_bordero_web;

PROCEDURE pc_analise_pagador_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE     --> Contrato de bordero                 
                                  ,pr_chave    IN varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_analise_pagador_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Janeiro/2019

    Objetivo  : Procedure para realizar a consulta de todos os pagadores dos títulos que não entraram no job noturno

    Alteração :
    
  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
   vr_tab_pagadores     tela_atenda_dscto_tit.typ_tab_dados_pagador;
   vr_qtregist          number;
   vr_index             LONG;

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_erro exception;

   -- Variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);
   
  CURSOR cr_analise_pagador (pr_nrinssac crapsab.nrinssac%TYPE)  IS
  SELECT 1
  FROM   tbdsct_analise_pagador tap 
  WHERE  tap.cdcooper = vr_cdcooper
  AND    tap.nrdconta = pr_nrdconta
  AND    tap.nrinssac = pr_nrinssac;
  rw_analise_pagador cr_analise_pagador%rowtype;
  

BEGIN
   pr_des_erro := 'OK';
   pr_nmdcampo := NULL;
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_prepara_titulos_resumo(pr_cdcooper          => vr_cdcooper
                           ,pr_nrdconta          => pr_nrdconta
                           ,pr_chave             => pr_chave
                           ,pr_qtregist          => vr_qtregist
                           ,pr_tab_dados_titulos => vr_tab_dados_titulos
                           ,pr_tab_pagadores     => vr_tab_pagadores
                           ,pr_cdcritic          => vr_cdcritic
                           ,pr_dscritic          => vr_dscritic );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_erro;
   end if;

   vr_index := vr_tab_pagadores.first;
   WHILE vr_index IS NOT NULL LOOP
     
     OPEN  cr_analise_pagador(pr_nrinssac => vr_tab_pagadores(vr_index).nrinssac);
     FETCH cr_analise_pagador INTO rw_analise_pagador;
     IF    cr_analise_pagador%NOTFOUND THEN
           dsct0002.pc_efetua_analise_pagador(pr_cdcooper => vr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_nrinssac => vr_tab_pagadores(vr_index).nrinssac
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
            IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
               CLOSE cr_analise_pagador;
               RAISE vr_exc_erro;
           END IF;
     END   IF;
     CLOSE cr_analise_pagador;
     vr_index := vr_tab_pagadores.next(vr_index);
   END LOOP;
   
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>Ok</dsmensag></Root>');

EXCEPTION
  when vr_exc_erro then
       -- Se possui código de crítica e não foi informado a descrição
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descrição da crítica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_analise_pagador_web: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_analise_pagador_web;


PROCEDURE pc_insere_bordero(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                           ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Conta do associado
                           ,pr_tpctrlim          IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite
                           ,pr_insitlim          IN craplim.insitlim%TYPE --> Situação do contrato de limite
                           ,pr_dtmvtolt          IN crapdat.dtmvtolt%TYPE --> Tipo de registro de datas
                           ,pr_cdoperad          IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                           ,pr_cdagenci          IN crapass.cdagenci%TYPE --> Codigo da agencia
                           ,pr_nrdcaixa          IN craperr.nrdcaixa%TYPE --> Numero Caixa
                           ,pr_nmdatela          IN craplgm.nmdatela%TYPE --> Nome da tela.
                           ,pr_idorigem          IN VARCHAR2              --> Identificador Origem pagamento
                           ,pr_idseqttl          IN INTEGER 
                           ,pr_dtmvtopr          IN crapdat.dtmvtolt%TYPE --> Proxima data de movimento.
                           ,pr_inproces          IN crapdat.inproces%TYPE --> Indicador processo
                           ,pr_tab_dados_titulos IN typ_tab_dados_titulos --> Titulos para desconto
                           ,pr_tab_borderos     OUT typ_tab_borderos      --> Dados do borderô inserido
                           ,pr_dsmensag         OUT VARCHAR2              --> Mensagem
                           ,pr_cdcritic         OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic         OUT VARCHAR2              --> Descricao da critica
                           ) IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_insere_bordero
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Maio/2018

    Objetivo  : Procedure para realizar a inclusão do borderô

    Alteração : 18/05/2018 - Criação, separado da procedure pc_insere_bordero_web (Paulo Penteado (GFT))
                15/06/2018 - Retorno se o bordero teve criticas ou nao ao inserir. [Vitor Shimada Assanuma (GFT)]
                23/08/2018 - Inserção do bordero com risco 2 (A) [Vitor Shimada Assanuma (GFT)]
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
   vr_dscritic VARCHAR2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro EXCEPTION;
   
   -- Variaveis para carregamento e validacoes de dados   
   vr_cddlinha craplim.cddlinha%TYPE;
   vr_flg_criou_lot boolean;
   vr_nrdolote craplot.nrdolote%TYPE;
   vr_nrborder crapbdt.nrborder%TYPE;
   vr_index        INTEGER;
   vr_vldtit       NUMBER;
   vr_qtregist     NUMBER;
    
   vr_indrestr     INTEGER;
   vr_ind_inpeditivo  INTEGER;
   vr_tab_erro        GENE0001.typ_tab_erro;
   vr_tab_retorno_analise DSCT0003.typ_tab_retorno_analise;

   vr_idtabtitulo INTEGER;
    
     pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
     pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
       
    /*Contrato do limite*/
    CURSOR cr_craplim IS      
      SELECT 
        craplim.dtpropos,
        craplim.dtinivig,
        craplim.nrctrlim,
        craplim.vllimite,
        craplim.qtdiavig,
        craplim.cddlinha,
        craplim.tpctrlim,
        craplim.dtfimvig,
        (SELECT SUM(craptdb.vlsldtit) 
           FROM
             craptdb
           INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                    crapcob.cdbandoc = craptdb.cdbandoc AND
                                                    crapcob.nrdctabb = craptdb.nrdctabb AND
                                                    crapcob.nrdconta = craptdb.nrdconta AND
                                                    crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                    crapcob.nrdocmto = craptdb.nrdocmto
              WHERE 
                   craptdb.cdcooper = craplim.cdcooper
                   AND craptdb.nrdconta = craplim.nrdconta
                 --AND craptdb.nrctrlim = craplim.nrctrlim
                 AND (craptdb.insittit=4 OR (craptdb.insittit=2 AND craptdb.dtdpagto=pr_dtmvtolt))
        )AS vlutiliz
      FROM 
        craplim
      where 
      craplim.cdcooper = pr_cdcooper
        AND craplim.tpctrlim = pr_tpctrlim
        AND craplim.nrdconta = pr_nrdconta
        AND craplim.insitlim = pr_insitlim
      ;
    rw_craplim cr_craplim%rowtype;
    
    CURSOR cr_crapass IS
       SELECT
          crapass.inpessoa
       FROM
          crapass
       WHERE
          crapass.nrdconta = pr_nrdconta
        AND crapass.cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%rowtype;
      
      
    /*Linha de crédito*/
    CURSOR cr_crapldc IS
      SELECT 
        cddlinha,
        txmensal
      FROM 
        crapldc
      WHERE
      crapldc.cdcooper = pr_cdcooper 
        AND crapldc.cddlinha = vr_cddlinha 
        AND crapldc.tpdescto = 3;
     rw_crapldc cr_crapldc%rowtype;
    
    /*CURSOR para verificar se o titulo ja nao foi usado em algum bordero*/
    CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE,
                       pr_nrdconta IN craptdb.nrdconta%TYPE, 
                       pr_nrdocmto IN craptdb.nrdocmto%TYPE, 
                       pr_cdbandoc IN craptdb.cdbandoc%TYPE,
                       pr_nrcnvcob IN craptdb.nrcnvcob%TYPE,
                       pr_nrdctabb IN craptdb.nrdctabb%TYPE
                       )
     IS
       SELECT
          craptdb.nrdocmto,
          craptdb.nrborder,
          craptdb.insitapr
       FROM
          craptdb
          INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
       WHERE
          craptdb.nrdconta = pr_nrdconta
          AND craptdb.cdcooper = pr_cdcooper
          AND craptdb.nrdocmto = pr_nrdocmto
          AND craptdb.cdbandoc = pr_cdbandoc
          AND craptdb.nrdctabb = pr_nrdctabb
          AND craptdb.nrcnvcob = pr_nrcnvcob
          AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
          AND craptdb.dtresgat IS NULL;
    rw_craptdb cr_craptdb%rowtype;
          
   BEGIN
      /*VERIFICA SE O CONTRATO EXISTE E AINDA ESTÁ ATIVO*/
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF (cr_craplim%NOTFOUND) THEN
        CLOSE cr_craplim;
        vr_dscritic := 'Contrato não encontrado.';
        raise vr_exc_erro;
      END IF;
      CLOSE cr_craplim;
      vr_cddlinha := rw_craplim.cddlinha;
        
      OPEN cr_crapldc;
      FETCH cr_crapldc INTO rw_crapldc;
      IF (cr_crapldc%NOTFOUND) THEN
         CLOSE cr_crapldc;   
         vr_dscritic := 'Linha de crédito não encontrada.';
         raise vr_exc_erro;
      END IF;
      CLOSE cr_crapldc;
        
     IF (rw_craplim.dtfimvig <pr_dtmvtolt) THEN
         vr_dscritic := 'A vigência do contrato deve ser maior que a data de movimentação do sistema.';
       raise vr_exc_erro;
     END IF;
     
     OPEN cr_crapass;
     FETCH cr_crapass INTO rw_crapass;
     IF (cr_crapass%NOTFOUND) THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Cooperado não cadastrado';
        raise vr_exc_erro;
     END IF;
     CLOSE cr_crapass;

      --carregando os dados de prazo limite da TAB052 
     dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 null, --Agencia de operação
                                                 null, --Número do caixa
                                                 null, --Operador
                                                 pr_dtmvtolt, -- Data da Movimentação
                                                 null, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
     
    /*VERIFICA SE O VALOR DOS BOLETOS SÃO > QUE O DISPONIVEL NO CONTRATO*/
      vr_index := pr_tab_dados_titulos.first;
      vr_vldtit := 0;
      vr_idtabtitulo := 0;
      vr_qtregist := 0;
      WHILE vr_index IS NOT NULL LOOP
            /*Antes de realizar a inclusão deverá validar se algum título já foi selecionado em algum outro 
            borderô com situação diferente de “não aprovado” ou “prazo expirado”*/
           open cr_craptdb (pr_nrdconta=>pr_nrdconta,
                                 pr_cdcooper=>pr_cdcooper,
                                 pr_nrdocmto=>pr_tab_dados_titulos(vr_index).nrdocmto,
                                 pr_cdbandoc=>pr_tab_dados_titulos(vr_index).cdbandoc,
                                 pr_nrcnvcob=>pr_tab_dados_titulos(vr_index).nrcnvcob,
                                 pr_nrdctabb=>pr_tab_dados_titulos(vr_index).nrdctabb
                              );
             fetch cr_craptdb into rw_craptdb;
             if  cr_craptdb%found AND rw_craptdb.insitapr <> 2 then
			   CLOSE cr_craptdb;
               vr_dscritic := 'Título ' ||rw_craptdb.nrdocmto || ' já selecionado em outro borderô';
               RAISE vr_exc_erro;
             end if;
           close cr_craptdb;
          vr_vldtit := vr_vldtit + pr_tab_dados_titulos(vr_index).vltitulo;
          vr_idtabtitulo := vr_idtabtitulo+1;
          vr_index  := pr_tab_dados_titulos.next(vr_index);
          vr_qtregist := vr_qtregist + 1;
      END   LOOP;

      /*VERIFICAR SE O VALOR TOTAL DOS TITULOS NAO PASSAO O DISPONIVEL DO CONTRATO*/
      IF (vr_vldtit> ((rw_craplim.vllimite+(rw_craplim.vllimite*pr_tab_dados_dsctit(1).pctolera/100))-rw_craplim.vlutiliz)) THEN
        vr_dscritic := 'O Total de títulos selecionados supera o valor disponível no contrato.';
        raise vr_exc_erro;
      END IF;

      /*Insere um lote novo*/
      vr_flg_criou_lot:=false;
      WHILE NOT vr_flg_criou_lot
     LOOP
      -- Rotina para criar lote e bordero
      vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                                ,pr_nmdcampo => 'NRDOLOTE'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper)|| ';' 
                                             || pr_dtmvtolt || ';'
                                             || TO_CHAR(pr_cdagenci)|| ';'
                                             || '700');
      -- Rotina para criar número de bordero por cooperativa
      vr_nrborder := fn_sequence(pr_nmtabela => 'CRAPBDT'
                                ,pr_nmdcampo => 'NRBORDER'
                                ,pr_dsdchave => TO_CHAR(pr_cdcooper));
                                
      BEGIN
        -- Insere registro na craplot
        INSERT INTO craplot (dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,qtinfoln
                            ,qtcompln
                            ,vlcompcr
                            ,vlinfodb                          
                            ,vlinfocr
                            ,tplotmov
                            ,dtmvtopg
                            ,cdoperad
                            ,cdhistor
                            ,cdbccxpg
                            ,cdcooper                          
                            ,qtinfocc
                            ,qtinfoci
                            ,vlinfoci                                                    
                            ,vlinfocc
                            ,qtinfocs
                            ,vlinfocs
							,vlcompdb)
                      VALUES(pr_dtmvtolt
                            ,pr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,vr_idtabtitulo
                            ,vr_idtabtitulo
                            ,vr_vldtit
                            ,vr_vldtit
                            ,vr_vldtit
                            ,34
                            ,NULL
                            ,pr_cdoperad
                            ,vr_nrborder
                            ,0
                            ,pr_cdcooper
                            ,0
                            ,0
                            ,0
                            ,0
                            ,0
                            ,0
							,vr_vldtit);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          CONTINUE;
        WHEN OTHERS THEN
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir novo lote ' || SQLERRM;
          -- Levanta exceção
          RAISE vr_exc_erro;
      END;
      
      vr_flg_criou_lot := TRUE;
    END LOOP;
    

        /*INSERE UM NOVO BORDERÔ*/
    INSERT INTO crapbdt
           (/*01*/ nrborder
           ,/*02*/ nrctrlim
           ,/*03*/ cdoperad
           ,/*04*/ dtmvtolt
           ,/*05*/ cdagenci
           ,/*06*/ cdbccxlt
           ,/*07*/ nrdolote
           ,/*08*/ nrdconta
           ,/*09*/ dtlibbdt
           ,/*10*/ cdopelib
           ,/*11*/ insitbdt
           ,/*12*/ hrtransa
           ,/*13*/ txmensal
           ,/*14*/ cddlinha
           ,/*15*/ cdcooper
           ,/*16*/ flgdigit
           ,/*17*/ progress_recid
           ,/*18*/ cdopeori
           ,/*19*/ cdageori
           ,/*20*/ dtinsori
           ,/*21*/ cdopcolb
           ,/*22*/ cdopcoan
           ,/*23*/ dtrefatu
           ,/*24*/ nrseqtdb
           ,/*25*/ flverbor
           ,/*26*/ nrinrisc )
    VALUES (/*01*/ vr_nrborder
           ,/*02*/ rw_craplim.nrctrlim
           ,/*03*/ pr_cdoperad
           ,/*04*/ pr_dtmvtolt
           ,/*05*/ pr_cdagenci
           ,/*06*/ 700
           ,/*07*/ vr_nrdolote
           ,/*08*/ pr_nrdconta
           ,/*09*/ NULL
           ,/*10*/ NULL
           ,/*11*/ 1        -- A principio o status inicial é EM ESTUDO
           ,/*12*/ to_char(SYSDATE, 'SSSSS')
           ,/*13*/ rw_crapldc.txmensal
           ,/*14*/ rw_craplim.cddlinha
           ,/*15*/ pr_cdcooper
           ,/*16*/ NULL
           ,/*17*/ NULL
           ,/*18*/ pr_cdoperad
           ,/*19*/ pr_cdagenci
           ,/*20*/ SYSDATE
           ,/*21*/ pr_cdoperad
           ,/*22*/ pr_cdagenci
           ,/*23*/ NULL
           ,/*24*/ vr_qtregist
           ,/*25*/ 1 
           ,/*26*/ 2);

      pr_tab_borderos(1).nrborder := vr_nrborder;
                
      /*INSERE OS TITULOS DO PONTEIRO vr_tab_dados_titulos*/
      vr_index:= pr_tab_dados_titulos.first;
      vr_idtabtitulo := 0;
      WHILE vr_index IS NOT NULL LOOP
          vr_idtabtitulo := vr_idtabtitulo+1;
          INSERT INTO 
                 craptdb
                 (nrdconta,
                  dtvencto,
                  nrseqdig,
                  cdoperad,
                  nrdocmto,
                  nrctrlim,
                  nrborder,
                  vlliquid,
                  dtlibbdt,
                  cdcooper,
                  cdbandoc,
                  nrdctabb,
                  nrcnvcob,
                  cdoperes,
                  dtresgat,
                  vlliqres,
                  vltitulo,
                  insittit,
                  nrinssac,
                  dtdpagto,
                  progress_recid,
                  dtdebito,
                  dtrefatu,
                  nrtitulo
                 )
                 VALUES(pr_nrdconta,
                 pr_tab_dados_titulos(vr_index).dtvencto,
                 vr_idtabtitulo,
                 pr_cdoperad,
                 pr_tab_dados_titulos(vr_index).nrdocmto,
                 rw_craplim.nrctrlim,
                 vr_nrborder,
                 pr_tab_dados_titulos(vr_index).vldpagto,
                 null,
                 pr_cdcooper,
                 pr_tab_dados_titulos(vr_index).cdbandoc,
                 pr_tab_dados_titulos(vr_index).nrdctabb,
                 pr_tab_dados_titulos(vr_index).nrcnvcob,
                 null,
                 null,
                 null,
                 pr_tab_dados_titulos(vr_index).vltitulo,
                 0,
                 pr_tab_dados_titulos(vr_index).nrinssac,
                 pr_tab_dados_titulos(vr_index).dtdpagto,
                 null,
                 null,
                 null,
                 vr_idtabtitulo
                 );
          vr_index  := pr_tab_dados_titulos.next(vr_index);
      END   LOOP;
    
      DSCT0003.pc_efetua_analise_bordero (pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_cdoperad => pr_cdoperad
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_idorigem => pr_idorigem
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_dtmvtopr => pr_dtmvtopr
                                      ,pr_inproces => pr_inproces
                                      ,pr_nrborder => vr_nrborder
                                      ,pr_inrotina => 1
                                      ,pr_flgerlog => FALSE
                                      ,pr_insborde => 1
                                      --------> OUT <--------
                                      ,pr_indrestr => vr_indrestr --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                      ,pr_ind_inpeditivo => vr_ind_inpeditivo  --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro => vr_tab_erro --  OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise => vr_tab_retorno_analise --OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic => vr_cdcritic          --> Código da crítica
                                      ,pr_dscritic => vr_dscritic             --> Descriçao da crítica
                                      );
                                      
       IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;
       
       -- Retorno se teve restrição
       pr_tab_borderos(1).flrestricao := vr_indrestr;
       
       IF (vr_indrestr = 0) THEN
          pr_dsmensag := 'Borderô n ' || vr_nrborder || ' criado com sucesso. Borderô sem críticas, aprovado automaticamente!';
       ELSE 
          pr_dsmensag := 'Borderô n ' || vr_nrborder || ' criado com sucesso.';
       END IF;

EXCEPTION
  WHEN vr_exc_erro THEN
       IF  nvl(vr_cdcritic,0) <> 0 AND TRIM(vr_dscritic) IS NULL THEN
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       ELSE
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
       END IF;

  WHEN OTHERS THEN
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro geral na rotina pc_insere_bordero: '||SQLERRM;
    END pc_insere_bordero ;
    

  PROCEDURE pc_insere_bordero_web(pr_tpctrlim IN craplim.tpctrlim%TYPE --> Tipo de contrato
                                 ,pr_insitlim IN craplim.insitlim%TYPE --> Situacao do contrato
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                 ,pr_chave    IN VARCHAR2              --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de movimentacao 
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_insere_bordero_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Março/2018    

    Objetivo  : Procedure para Inserir todos os titulos selecionados no bordero

    Alteração : ??/03/2018 - Criação (Luis Fernando (GFT))
                18/05/2018 - Transformado a procedure em _web (Paulo Penteado (GFT)) 
                15/06/2018 - Retorno se o bordero teve criticas ou nao e o numero ao inserir. [Vitor Shimada Assanuma (GFT)]

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_titulos typ_tab_dados_titulos;
  vr_tab_borderos      typ_tab_borderos;
  vr_qtregist          NUMBER;
  vr_dtmvtolt          DATE;
  vr_dtmvtopr          DATE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000);        --> Desc. Erro
  vr_dsmensag VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

  -- rowid tabela de log
  vr_nrdrowid ROWID;
      
  -- variaveis de entrada vindas no xml
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  BEGIN
    pr_des_erro := 'OK';
    pr_nmdcampo := NULL;
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
     
    pc_listar_titulos_resumo(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta --> Número da Conta
                         ,pr_chave => pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                            --------> OUT <--------
                         ,pr_qtregist => vr_qtregist --> Quantidade de registros encontrados
                         ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                         ,pr_cdcritic => vr_cdcritic --> Código da crítica
                         ,pr_dscritic => vr_dscritic --> Descrição da crítica
                          );
                            
    vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
    
    --Selecionar dados da data
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se encontrar
    IF BTCH0001.cr_crapdat%FOUND THEN
      vr_dtmvtopr:= rw_crapdat.dtmvtopr;
    END IF;
    CLOSE btch0001.cr_crapdat;
                            
                            
    pc_insere_bordero(pr_cdcooper          => vr_cdcooper
                     ,pr_nrdconta          => pr_nrdconta
                     ,pr_tpctrlim          => pr_tpctrlim
                     ,pr_insitlim          => pr_insitlim
                     ,pr_dtmvtolt          => vr_dtmvtolt
                     ,pr_cdoperad          => vr_cdoperad
                     ,pr_cdagenci          => vr_cdagenci
                     ,pr_nrdcaixa          => vr_nrdcaixa
                     ,pr_nmdatela          => vr_nmdatela
                     ,pr_idorigem          => vr_idorigem
                     ,pr_idseqttl          => 1
                     ,pr_dtmvtopr          => vr_dtmvtopr
                     ,pr_inproces          => 0
                     ,pr_tab_dados_titulos => vr_tab_dados_titulos
                     ,pr_tab_borderos      => vr_tab_borderos
                     ,pr_dsmensag          => vr_dsmensag
                     ,pr_cdcritic          => vr_cdcritic
                     ,pr_dscritic          => vr_dscritic );

    IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    -- Chamar geração de LOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => vr_dsmensag
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                          
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                   '<Root>'||
                                      '<Dados>' ||
                                        '<inf>'         || vr_dsmensag                    || '</inf>'         ||
                                        '<nrborder>'    || vr_tab_borderos(1).nrborder    || '</nrborder>'    ||
                                        '<flrestricao>' || vr_tab_borderos(1).flrestricao || '</flrestricao>' ||
                                      '</Dados>'||
                                   '</Root>');

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    WHEN OTHERS THEN
         pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_insere_bordero_web ' ||sqlerrm;
         pr_des_erro := 'NOK';
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
  END pc_insere_bordero_web ;
    
  PROCEDURE pc_detalhes_tit_bordero(pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_nrborder           in crapbdt.nrborder%type   --> Numero do bordero
                               ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                               ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscrição do sacado
                               ,pr_nmdsacad           out crapsab.nmdsacad%TYPE   --> Nome do Sacado
                               ,pr_tab_dados_biro     out  typ_tab_dados_biro    --> Tabela de retorno biro
                               ,pr_tab_dados_detalhe  out  typ_tab_dados_detalhe --> Tabela de retorno detalhe
                               ,pr_tab_dados_critica  out  typ_tab_dados_critica --> Tabela de retorno critica
                               ,pr_cdcritic           out pls_integer            --> Codigo da critica
                               ,pr_dscritic           out varchar2               --> Descricao da critica
                               ) is

    ---------------------------------------------------------------------------------------------------------------------
    --
    -- Procedure: pc_detalhes_tit_bordero
    -- Sistema  : CRED
    -- Sigla    : TELA_ATENDA_DSCTO_TIT
    -- Autor    : Gustavo Sene (GFT)
    -- Data     : Criação: Março/2018  Ultima atualização: 30/03/2018
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Obter os detalhes do Pagador do Título selecionado na composição do Borderô
    --
    -- Histórico de Alterações:
    --  29/03/2018 - Versão inicial
    --  03/05/2018 - Vitor Shimada Assanuma - Alterado a regra de CNAE, adicionado funcao DSCT0003.fn_calcula_cnae()
    --  30/05/2018 - Vitor Shimada Assanuma - Inserção da verificação se o borderô é antigo e tratamento de erro
    --  09/07/2018 - Vitor Shimada Assanuma - Validação de críticas repetidas
    --  13/08/2018 - Luis Fernando (GFT) - Adicionados mais parametros no calculo de liquidez
    ---------------------------------------------------------------------------------------------------------------------
   
    ----------------> VARIÁVEIS <----------------
    
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic        varchar2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        exception;

    -- Demais tipos e variáveis
    vr_idtabcritica      integer;  
    --  
    vr_idtabtitulo       INTEGER;
    vr_nrinssac            crapcob.nrinssac%TYPE;
	
	vr_qtcarpag  NUMBER;
    vr_qttliqcp  NUMBER;
    vr_vltliqcp  NUMBER;
    vr_pcmxctip  NUMBER;
    vr_qtmitdcl  INTEGER;
    vr_vlmintcl  NUMBER;
    vr_dtmvtolt_de crapdat.dtmvtolt%TYPE;
    vr_dtmvtolt_ate crapdat.dtmvtolt%TYPE;
	
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
    
    -- criticas
    vr_tab_criticas dsct0003.typ_tab_critica;
    ----------------> CURSORES <----------------
    -- Associado
    CURSOR cr_crapass IS
    SELECT 
      inpessoa
    FROM 
      crapass ass
    WHERE 
      nrdconta = pr_nrdconta
      AND cdcooper = pr_cdcooper;
    rw_crapass cr_crapass%ROWTYPE;
    -- Pagador
    cursor cr_crapsab is
    SELECT nrinssac,
           nmdsacad
    from crapsab
    where cdcooper = pr_cdcooper
    AND nrinssac = vr_nrinssac
    AND nrdconta = pr_nrdconta;
    rw_crapsab cr_crapsab%rowtype;
    
    -- Titulos (Boletos de Cobrança)
    cursor cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE
                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                   ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                   ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) is
    select cob.cdcooper, 
           cob.nrdconta,
           cob.nrinssac,
           cob.nrnosnum,
           cob.cdtpinsc, -- Tipo Pesso do Pagador (0-Nenhum/1-CPF/2-CNPJ)
           cob.nrdocmto,
           cob.nrcnvcob,
           cob.nrdctabb,
           cob.cdbandoc
    from   crapcob cob
    where  cob.cdcooper = pr_cdcooper -- Cooperativa
    and    cob.nrdconta = pr_nrdconta -- Conta
    AND    cob.nrdocmto = pr_nrdocmto
    AND    cob.nrcnvcob = pr_nrcnvcob
    AND    cob.nrdctabb = pr_nrdctabb
    AND    cob.cdbandoc = pr_cdbandoc
    and    cob.incobran=0
    ;
    --
    rw_crapcob cr_crapcob%rowtype;  


    -- Cursor de verificar se o bordero é antigo
    CURSOR cr_crapbdt IS
      SELECT DISTINCT bdt.nrborder,bdt.flverbor, bdt.insitbdt
      FROM crapbdt bdt 
      WHERE  bdt.nrdconta = pr_nrdconta 
          AND bdt.cdcooper = pr_cdcooper
          AND bdt.nrborder = pr_nrborder

    ;rw_crapbdt cr_crapbdt%ROWTYPE;

      CURSOR cr_crapcbd IS
        SELECT crapcbd.nrconbir,
               crapcbd.nrseqdet,
               TO_CHAR(crapcbd.dtreapro,'dd/mm/yyyy') dtreapro  -- Marcelo Telles Coelho - Mouts - 25/04/2019 - RITM0050653
          FROM crapcbd
         WHERE crapcbd.cdcooper = pr_cdcooper
           AND crapcbd.nrdconta = pr_nrdconta 
           AND crapcbd.nrcpfcgc = vr_nrinssac
           AND crapcbd.inreterr = 0  -- Nao houve erros
         ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente
       rw_crapcbd  cr_crapcbd%rowtype; 
       
      -- Cursor sobre as pendencias financeiras existentes
      CURSOR cr_craprpf(pr_nrconbir craprpf.nrconbir%TYPE,
                        pr_nrseqdet craprpf.nrseqdet%TYPE) IS
        SELECT innegati,
               dsnegati,
               decode(qtnegati,0,NULL,qtnegati) qtnegati,
               decode(qtnegati,0,NULL,vlnegati) vlnegati,
               dtultneg
          FROM (SELECT 1 innegati,
                       'REFIN' dsnegati,
                       MAX(craprpf.qtnegati) qtnegati,
                       MAX(craprpf.vlnegati) vlnegati,
                       MAX(craprpf.dtultneg) dtultneg
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 1
                UNION ALL
                SELECT 2,
                       'PEFIN' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 2
                UNION ALL
                SELECT 3,
                       'Protesto' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 3
                UNION ALL
                SELECT 4,
                       'Ação Judicial' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 4
                UNION ALL
                SELECT 5,
                       'Participação falência' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 5
                UNION ALL
                SELECT 6,
                       'Cheque sem fundo' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 6
                UNION ALL
                SELECT 7,
                       'Cheque Sust./Extrav.' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 7
                UNION ALL
                SELECT 8,
                       'SERASA' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 8
                UNION ALL
                SELECT 9,
                       'SPC' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 9);
                   
       rw_craprpf cr_craprpf%rowtype; 
       -- Cursor genérico de calendário
       rw_crapdat btch0001.cr_crapdat%rowtype;

       -- Variaveis de retorno 
       pr_qtd_cedpag   NUMBER(25,2);
       pr_qtd_conc     NUMBER(25,2);
       pr_qtd_geral    NUMBER(25,2);
       -- Variaveis de retorno 
       vr_liqpagcd     NUMBER(25,2);
       vr_concpaga     NUMBER(25,2);
       vr_liqgeral     NUMBER(25,2);
       
       vr_tab_chaves  gene0002.typ_split;
	   CURSOR cr_liquidez_pagador (pr_dtmvtolt_de  IN crapdat.dtmvtolt%TYPE
                                  ,pr_dtmvtolt_ate IN crapdat.dtmvtolt%TYPE
                                  ,pr_vlmintcl     IN NUMBER   DEFAULT 0
                                  ,pr_qtcarpag     IN NUMBER) IS
         SELECT COUNT(1) AS qtd_titulos,
                (SUM(CASE
                         WHEN (dtdpagto IS NOT NULL AND nrdconta_tit IS NULL AND
                              (dtdpagto <= (dtvencto + pr_qtcarpag))) THEN
                          vltitulo
                         ELSE
                          0
                       END) / SUM(vltitulo)) * 100 AS pc_cedpag
           FROM (SELECT cob.dtdpagto,
                        tit.nrdconta nrdconta_tit,
                        cob.dtvencto,
                        cob.vltitulo
                   FROM crapcob cob -- Titulos do Bordero
                  INNER JOIN crapceb ceb
                     ON cob.cdcooper = ceb.cdcooper
                    AND cob.nrdconta = ceb.nrdconta
                    AND cob.nrcnvcob = ceb.nrconven
                   LEFT JOIN craptit tit
                     ON tit.cdcooper = cob.cdcooper
                    AND tit.dtmvtolt = cob.dtdpagto
                    AND tit.nrdconta = cob.nrdconta
                    AND cob.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                    AND cob.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                    AND cob.nrdocmto = substr(upper(tit.dscodbar), 34, 9)
                    AND tit.cdbandst = 85
                    AND tit.cdagenci IN (90,91)
                  WHERE cob.dtvencto  BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
                    AND cob.cdcooper = pr_cdcooper
                    AND cob.nrdconta = pr_nrdconta
                    AND cob.nrinssac = pr_nrinssac
                    AND cob.vltitulo >= nvl(pr_vlmintcl,0)
                    AND cob.cdbanpag = 85
                  UNION ALL
                 SELECT cob.dtdpagto,
                        NULL nrdconta_tit,
                        cob.dtvencto,
                        cob.vltitulo
                   FROM crapcob cob -- Titulos do Bordero
                  INNER JOIN crapceb ceb
                     ON cob.cdcooper = ceb.cdcooper
                    AND cob.nrdconta = ceb.nrdconta
                    AND cob.nrcnvcob = ceb.nrconven
                  WHERE cob.dtvencto BETWEEN pr_dtmvtolt_de AND pr_dtmvtolt_ate -- No intervalo de data da liquidez
                    AND cob.cdcooper = pr_cdcooper
                    AND cob.nrdconta = pr_nrdconta
                    AND cob.nrinssac = pr_nrinssac
                    AND cob.vltitulo >= nvl(pr_vlmintcl,0)
                    AND cob.cdbanpag <> 85);
       rw_liquidez_pagador cr_liquidez_pagador%ROWTYPE;
  BEGIN 
       vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                  pr_delimit => ';');
       
        -- Verifica se o bordero é antigo, caso for dar erro de não ter informações.
        OPEN cr_crapbdt();
        FETCH cr_crapbdt into rw_crapbdt;
        CLOSE cr_crapbdt;
        IF rw_crapbdt.flverbor = 0 THEN
          vr_dscritic := 'Não há informações a serem exibidas.';
          RAISE vr_exc_erro;
        END IF;
     
      --    Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      open cr_crapcob (vr_tab_chaves(4), -- Conta
                         vr_tab_chaves(3), -- Convenio
                         vr_tab_chaves(2), -- Conta base do banco
                         vr_tab_chaves(1)  -- Codigo do banco
                        );
      fetch cr_crapcob into rw_crapcob;
      vr_nrinssac := rw_crapcob.nrinssac;
        CLOSE cr_crapcob;

      open cr_crapsab;
      fetch cr_crapsab into rw_crapsab;
      pr_nrinssac:=rw_crapsab.nrinssac;
      pr_nmdsacad:=rw_crapsab.nmdsacad;
        CLOSE cr_crapsab;
		
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
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
      
      OPEN cr_liquidez_pagador(pr_dtmvtolt_de  => vr_dtmvtolt_de
                              ,pr_dtmvtolt_ate => vr_dtmvtolt_ate
                              ,pr_vlmintcl     => vr_vlmintcl
                              ,pr_qtcarpag     => vr_qtcarpag);
      FETCH cr_liquidez_pagador INTO rw_liquidez_pagador;
      CLOSE cr_liquidez_pagador;
      
      IF (rw_liquidez_pagador.qtd_titulos < vr_qtmitdcl OR (nvl(rw_liquidez_pagador.pc_cedpag,0) = 0 AND rw_liquidez_pagador.qtd_titulos = 0)) THEN
        pr_tab_dados_detalhe(0).qtparcmi := 1; -- Nao atende o criterio de titulos (mostra "-" na tela)
      ELSE
        pr_tab_dados_detalhe(0).qtparcmi := 2;
      END IF; 
	  
      -- Caso o bordero esteja liberado ou liquidado, deve carregar as criticas da CRAPABT
      IF rw_crapbdt.insitbdt IN (3,4,5)  THEN -- liquidado ou liberado
        pr_tab_dados_detalhe(0).concpaga := '0';
        pr_tab_dados_detalhe(0).liqpagcd := '100,00';
        pr_tab_dados_detalhe(0).liqgeral := '100,00';
        
         --concentracao
        OPEN dsct0003.cr_crapabt(pr_cdcooper=>pr_cdcooper,
                             pr_nrborder=>rw_crapbdt.nrborder,
                             pr_cdcritica=>18,
                             pr_nrdconta=>rw_crapcob.nrdconta,
                             pr_cdbandoc=>rw_crapcob.cdbandoc,
                             pr_nrdctabb=>rw_crapcob.nrdctabb,
                             pr_nrdocmto=>rw_crapcob.nrdocmto);
        FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
        IF (dsct0003.cr_crapabt%FOUND) THEN
          pr_tab_dados_detalhe(0).concpaga := dsct0003.rw_abt.dsdetres;
      END IF; 
        CLOSE dsct0003.cr_crapabt;
        --liquidez pagador
        OPEN dsct0003.cr_crapabt(pr_cdcooper=>pr_cdcooper,
                             pr_nrborder=>rw_crapbdt.nrborder,
                             pr_cdcritica=>19,
                             pr_nrdconta=>rw_crapcob.nrdconta,
                             pr_cdbandoc=>rw_crapcob.cdbandoc,
                             pr_nrdctabb=>rw_crapcob.nrdctabb,
                             pr_nrdocmto=>rw_crapcob.nrdocmto);
        FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
        IF (dsct0003.cr_crapabt%FOUND) THEN
          pr_tab_dados_detalhe(0).liqpagcd := dsct0003.rw_abt.dsdetres;
        END IF;
        CLOSE dsct0003.cr_crapabt;
        --liquidez Geral
        OPEN dsct0003.cr_crapabt(pr_cdcooper=>pr_cdcooper,
                             pr_nrborder=>rw_crapbdt.nrborder,
                             pr_cdcritica=>20,
                             pr_nrdconta=>rw_crapcob.nrdconta,
                             pr_cdbandoc=>rw_crapcob.cdbandoc,
                             pr_nrdctabb=>rw_crapcob.nrdctabb,
                             pr_nrdocmto=>rw_crapcob.nrdocmto);
        FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
        IF (dsct0003.cr_crapabt%FOUND) THEN
          pr_tab_dados_detalhe(0).liqgeral := dsct0003.rw_abt.dsdetres;
        END IF;
        CLOSE dsct0003.cr_crapabt;
        
      vr_idtabcritica := 0;
        --Criticas de pagador
        OPEN dsct0003.cr_crapabt(pr_cdcooper=>pr_cdcooper,
                             pr_nrborder=>rw_crapbdt.nrborder,
                             pr_tpcritica=>1,
                             pr_nrdconta=>rw_crapcob.nrdconta,
                             pr_cdbandoc=>rw_crapcob.cdbandoc,
                             pr_nrdctabb=>rw_crapcob.nrdctabb,
                             pr_nrdocmto=>rw_crapcob.nrdocmto);
        LOOP
          FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
          EXIT WHEN dsct0003.cr_crapabt%NOTFOUND;
            pr_tab_dados_critica(vr_idtabcritica).dsc := dsct0003.rw_abt.dscritica;
            pr_tab_dados_critica(vr_idtabcritica).vlr := dsct0003.rw_abt.dsdetres;
           vr_idtabcritica := vr_idtabcritica + 1;
        END LOOP;
        CLOSE dsct0003.cr_crapabt;
        --Criticas de titulo
        OPEN dsct0003.cr_crapabt(pr_cdcooper=>pr_cdcooper,
                             pr_nrborder=>rw_crapbdt.nrborder,
                             pr_tpcritica=>3,
                             pr_nrdconta=>rw_crapcob.nrdconta,
                             pr_cdbandoc=>rw_crapcob.cdbandoc,
                             pr_nrdctabb=>rw_crapcob.nrdctabb,
                             pr_nrdocmto=>rw_crapcob.nrdocmto);
        LOOP
          FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
          EXIT WHEN dsct0003.cr_crapabt%NOTFOUND;
            pr_tab_dados_critica(vr_idtabcritica).dsc := dsct0003.rw_abt.dscritica;
            pr_tab_dados_critica(vr_idtabcritica).vlr := dsct0003.rw_abt.dsdetres;
           vr_idtabcritica := vr_idtabcritica + 1;
        END LOOP;
        CLOSE dsct0003.cr_crapabt;
        
      --> DETALHES (BORDERO)
      open cr_crapcbd;
      fetch cr_crapcbd into rw_crapcbd;
      IF (cr_crapcbd%FOUND) THEN
        vr_idtabtitulo:=0;
        open cr_craprpf (pr_nrconbir=>rw_crapcbd.nrconbir,pr_nrseqdet=>rw_crapcbd.nrseqdet);
        LOOP
            fetch cr_craprpf into rw_craprpf;
               EXIT WHEN cr_craprpf%NOTFOUND;
               pr_tab_dados_biro(vr_idtabtitulo).dsnegati := rw_craprpf.dsnegati;
               pr_tab_dados_biro(vr_idtabtitulo).qtnegati := rw_craprpf.qtnegati;
               pr_tab_dados_biro(vr_idtabtitulo).vlnegati := rw_craprpf.vlnegati;
               pr_tab_dados_biro(vr_idtabtitulo).dtultneg := rw_craprpf.dtultneg;
               vr_idtabtitulo := vr_idtabtitulo + 1;
        END LOOP;      
      END IF; 
      ELSE -- bordero ainda esta aberto
        
        --> DETALHES (BORDERO)
        open cr_crapcbd;
        fetch cr_crapcbd into rw_crapcbd;
        IF (cr_crapcbd%FOUND) THEN
          vr_idtabtitulo:=0;
          open cr_craprpf (pr_nrconbir=>rw_crapcbd.nrconbir,pr_nrseqdet=>rw_crapcbd.nrseqdet);
          LOOP
              fetch cr_craprpf into rw_craprpf;
                 EXIT WHEN cr_craprpf%NOTFOUND;
                 pr_tab_dados_biro(vr_idtabtitulo).dsnegati := rw_craprpf.dsnegati;
                 pr_tab_dados_biro(vr_idtabtitulo).qtnegati := rw_craprpf.qtnegati;
                 pr_tab_dados_biro(vr_idtabtitulo).vlnegati := rw_craprpf.vlnegati;
                 pr_tab_dados_biro(vr_idtabtitulo).dtultneg := rw_craprpf.dtultneg;
                 vr_idtabtitulo := vr_idtabtitulo + 1;
          END LOOP;      
        END IF; 
         
        /*Faz calculo de liquidez e concentracao e atualiza as criticas*/
        DSCT0002.pc_atualiza_calculos_pagador( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta     => pr_nrdconta
                                                ,pr_nrinssac     => vr_nrinssac
                                                ,pr_dtmvtolt_de  => rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                                                ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                                ,pr_qtcarpag     => vr_tab_dados_dsctit(1).cardbtit_c
                                                ,pr_qtmitdcl     => vr_tab_dados_dsctit(1).qtmitdcl
                                                ,pr_vlmintcl     => vr_tab_dados_dsctit(1).vlmintcl
                                               --------------> OUT <--------------
                                               ,pr_pc_cedpag    => vr_liqpagcd
                                               ,pr_qtd_cedpag   => pr_qtd_cedpag
                                               ,pr_pc_conc      => vr_concpaga
                                               ,pr_qtd_conc     => pr_qtd_conc
                                               ,pr_cdcritic     => vr_cdcritic
                                               ,pr_dscritic     => vr_dscritic
                              );

        -- Faz os calculos de liquidez
        DSCT0003.pc_retorna_liquidez_geral(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dtmvtolt_de =>  rw_crapdat.dtmvtolt - vr_tab_dados_dsctit(1).qtmesliq*30
                           ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                           ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                           ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                           ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                           -- OUT --
                           ,pr_pc_geral     => vr_liqgeral
                           ,pr_qtd_geral    => pr_qtd_geral);
                           
        pr_tab_dados_detalhe(0).liqpagcd := to_char(vr_liqpagcd);
        pr_tab_dados_detalhe(0).concpaga := to_char(vr_concpaga);
        pr_tab_dados_detalhe(0).liqgeral := to_char(vr_liqgeral);
              
      vr_idtabcritica := 0;

        DSCT0003.pc_calcula_restricao_pagador(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrinssac => vr_nrinssac
                          ,pr_cdbandoc=>vr_tab_chaves(1)
                          ,pr_nrdctabb=>vr_tab_chaves(2)
                          ,pr_nrcnvcob=>vr_tab_chaves(3)
                          ,pr_nrdocmto=>vr_tab_chaves(4)
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
        -- Caso tenha erro
        IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        IF (vr_tab_criticas.count > 0) THEN
          vr_index := vr_tab_criticas.first;
          WHILE vr_index IS NOT NULL LOOP  
            pr_tab_dados_critica(vr_idtabcritica).dsc := vr_tab_criticas(vr_index).dscritica;
            pr_tab_dados_critica(vr_idtabcritica).vlr := to_char(vr_tab_criticas(vr_index).dsdetres);
            vr_index := vr_tab_criticas.next(vr_index);
           vr_idtabcritica := vr_idtabcritica + 1;
          END LOOP;
        END IF;
              
        vr_tab_criticas.delete;
              
        DSCT0003.pc_calcula_restricao_titulo(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdbandoc=>vr_tab_chaves(1)
                          ,pr_nrdctabb=>vr_tab_chaves(2)
                          ,pr_nrcnvcob=>vr_tab_chaves(3)
                          ,pr_nrdocmto=>vr_tab_chaves(4)
                          ,pr_tab_criticas => vr_tab_criticas
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);
        -- Caso tenha erro
        IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        IF (vr_tab_criticas.count > 0) THEN
          vr_index := vr_tab_criticas.first;
          WHILE vr_index IS NOT NULL LOOP  
            pr_tab_dados_critica(vr_idtabcritica).dsc := vr_tab_criticas(vr_index).dscritica;
            pr_tab_dados_critica(vr_idtabcritica).vlr := to_char(vr_tab_criticas(vr_index).dsdetres);
            vr_index := vr_tab_criticas.next(vr_index);
           vr_idtabcritica := vr_idtabcritica + 1;
          END LOOP;
        END IF;
    END IF;
    --
    pr_tab_dados_detalhe(0).dtreapro := rw_crapcbd.dtreapro; -- Marcelo Telles Coelho - Mouts - 25/04/2019 - RITM0050653
    EXCEPTION
      WHEN vr_exc_erro THEN
           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_detalhes_tit_bordero ' ||SQLERRM;
  end pc_detalhes_tit_bordero;
      
      
  procedure pc_detalhes_tit_bordero_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                        ,pr_nrborder    in crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_chave       in varchar2              --> lista de 'nosso numero' a ser pesquisado
                                        ,pr_xmllog      in varchar2              --> xml com informações de log
                                         --------> out <--------
                                        ,pr_cdcritic out pls_integer             --> código da crítica
                                        ,pr_dscritic out varchar2                --> descrição da crítica
                                        ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                        ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                        ,pr_des_erro out varchar2                --> erros do processo
                                      ) is

    -- variaveis de retorno
        
    vr_tab_dados_biro         typ_tab_dados_biro;
    vr_tab_dados_detalhe      typ_tab_dados_detalhe;
    vr_tab_dados_critica      typ_tab_dados_critica;
    vr_nrinssac          crapsab.nrinssac%TYPE;
    vr_nmdsacad          crapsab.nmdsacad%TYPE;

    /* tratamento de erro */
    vr_exc_erro exception;
      
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);        
        
    vr_index_biro    pls_integer;
    vr_index_critica pls_integer;
        
    -- variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> cód. erro
     vr_dscritic varchar2(1000);        --> desc. erro
         
   
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

                           
                           
      pc_detalhes_tit_bordero(vr_cdcooper    --> código da cooperativa
                       ,pr_nrdconta          --> número da conta
                       ,pr_nrborder          --> Numero do bordero
                       ,pr_chave          --> lista de 'nosso numero' a ser pesquisado
                       --------> out <--------
                       ,vr_nrinssac          --> Inscricao do sacado
                       ,vr_nmdsacad          --> Nome do sacado
                       ,vr_tab_dados_biro    -->  retorno do biro
                       ,vr_tab_dados_detalhe -->  retorno dos detalhes
                       ,vr_tab_dados_critica --> retorno das criticas
                       ,vr_cdcritic          --> código da crítica
                       ,vr_dscritic          --> descrição da crítica
                       );
          
      -- Caso tenha erro
      IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
          
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados  >');
                         
      pc_escreve_xml('<pagador>'||
                         '<nrinssac>'||vr_nrinssac||'</nrinssac>'||
                         '<nmdsacad>'||htf.escape_sc(vr_nmdsacad)||'</nmdsacad>'||
                    '</pagador>');
      
     -- ler os registros de biro e incluir no xml
      vr_index_biro := vr_tab_dados_biro.first;
      
      pc_escreve_xml('<biro>');
      while vr_index_biro is not null loop  
          pc_escreve_xml('<craprpf>' || 
                          '<dsnegati>' || vr_tab_dados_biro(vr_index_biro).dsnegati || '</dsnegati>' ||
                          '<qtnegati>' || vr_tab_dados_biro(vr_index_biro).qtnegati || '</qtnegati>' ||
                          '<vlnegati>' || vr_tab_dados_biro(vr_index_biro).vlnegati || '</vlnegati>' ||
                          '<dtultneg>' || to_char(vr_tab_dados_biro(vr_index_biro).dtultneg,'DD/MM/RRRR') || '</dtultneg>' ||
                        '</craprpf>'
                  );
          /* buscar proximo */
          vr_index_biro := vr_tab_dados_biro.next(vr_index_biro);
      end loop;
      pc_escreve_xml('</biro>');
          
      -- ler os registros de detalhe e incluir no xml

      pc_escreve_xml('<detalhe>'||
                        '<concpaga>'  || vr_tab_dados_detalhe(0).concpaga || '</concpaga>' ||
                        '<liqpagcd>'  || vr_tab_dados_detalhe(0).liqpagcd || '</liqpagcd>' ||
                        '<liqgeral>'  || vr_tab_dados_detalhe(0).liqgeral || '</liqgeral>' ||
                        '<dtreapro>'  || vr_tab_dados_detalhe(0).dtreapro || '</dtreapro>' || -- Marcelo Telles Coelho - Mouts - 25/04/2019 - RITM0050653
						'<qtparcmi>'  || vr_tab_dados_detalhe(0).qtparcmi || '</qtparcmi>' ||
                     '</detalhe>'
      );
          
          
      -- ler os registros de detalhe e incluir no xml
      vr_index_critica := vr_tab_dados_critica.first;
      pc_escreve_xml('<criticas>');
      
      WHILE vr_index_critica IS NOT NULL LOOP
            
            pc_escreve_xml('<critica>'|| 
                             '<dsc>' || vr_tab_dados_critica(vr_index_critica).dsc || '</dsc>' ||
                             '<vlr>' || vr_tab_dados_critica(vr_index_critica).vlr || '</vlr>' ||
                             '</critica>');
            /* buscar proximo */
            vr_index_critica := vr_tab_dados_critica.next(vr_index_critica);
      end loop;
      pc_escreve_xml('</criticas>');
          
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
          
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- carregar xml padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                           '<root><erro>' || pr_dscritic || '</erro></root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_detalhes_tit_bordero_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- carregar xml padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                           '<root><erro>' || pr_dscritic || '</erro></root>');
  end pc_detalhes_tit_bordero_web;




  PROCEDURE pc_buscar_tit_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Paginação - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Paginação - Número de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_tit_bordero   out  typ_tab_tit_bordero --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) is

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulos
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Leonardo Oliveira (GFT)
    Data     : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que busca os detalhes e restrições do titulo do borderô
    
    Alteração : 
              09/04/2018 - Adicionados novos campos na lista de titulos - Luis Fernando (GFT)
              21/07/2018 - Adicionado opção de paginação. Utilizado na dsct0004 do IB (Paulo Penteado GFT)
              19/09/2018 - Adicionado retorno da descrição da situação do titulo dssittit (Paulo Penteado GFT)
              05/11/2018 - Adicionado retorno de valor prejuízo e inprejuz (Lucas Negoseki GFT)
  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   vr_index        INTEGER;
   vr_nrinssac    number;
   
   vr_tab_criticas dsct0003.typ_tab_critica;
   vr_situacao char(1);   
   vr_ibratan char(1);
   vr_cdbircon crapbir.cdbircon%TYPE;
   vr_dsbircon crapbir.dsbircon%TYPE;
   vr_cdmodbir crapmbr.cdmodbir%TYPE;
   vr_dsmodbir crapmbr.dsmodbir%TYPE;
   restricao_cnae BOOLEAN;
   
   vr_countpag    INTEGER := 1; -- contador para controlar a paginacao
   
   vr_tab_tit_bordero        cecred.dsct0002.typ_tab_tit_bordero; --> retorna titulos do bordero
   vr_tab_tit_bordero_restri cecred.dsct0002.typ_tab_bordero_restri; --> retorna restrições do titulos do bordero
   
   -- Tratamento de erros
   vr_exc_erro exception;
        
   vr_taxamensal NUMBER;
   vr_vldjuros NUMBER;
   vr_qtd_dias INTEGER;
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;
   
   CURSOR cr_crapcbd IS
     SELECT crapcbd.nrconbir,
           crapcbd.nrseqdet
      FROM crapcbd
     WHERE crapcbd.cdcooper = pr_cdcooper
       AND crapcbd.nrdconta = pr_nrdconta 
       AND crapcbd.nrcpfcgc = vr_nrinssac
       AND crapcbd.inreterr = 0  -- Nao houve erros
     ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente
   rw_crapcbd  cr_crapcbd%rowtype;
   
   BEGIN
     --    Verifica se a data esta cadastrada
     OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH btch0001.cr_crapdat into rw_crapdat;

     IF    btch0001.cr_crapdat%NOTFOUND THEN
           CLOSE btch0001.cr_crapdat;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
           RAISE vr_exc_erro;
     END IF;
     CLOSE btch0001.cr_crapdat;
     
     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
   
     pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursos
     
     --carregando os dados de prazo limite da TAB052 
     -- BUSCAR O PRAZO PARA PESSOA FISICA
     dsct0002.pc_busca_titulos_bordero (
                                     pr_cdcooper                => pr_cdcooper
                                     ,pr_nrborder               => pr_nrborder
                                     ,pr_nrdconta               => pr_nrdconta   
                                     ,pr_tab_tit_bordero        => vr_tab_tit_bordero --> retorna titulos do bordero
                                     ,pr_tab_tit_bordero_restri => vr_tab_tit_bordero_restri --> retorna restrições do titulos do bordero
                                     ,pr_cdcritic               => vr_cdcritic          --> Código da crítica
                                     ,pr_dscritic               => vr_dscritic);          --> Descrição da crítica
                                     
      if  vr_cdcritic > 0  or vr_dscritic is not null then
         raise vr_exc_erro;
      end if;
      
      SELECT txmensal INTO vr_taxamensal FROM crapbdt WHERE nrborder = pr_nrborder AND cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta;
      
      vr_index := vr_tab_tit_bordero.first;
      -- abrindo cursos de títulos
       WHILE vr_index IS NOT NULL LOOP
         IF (pr_nriniseq + pr_nrregist)=0 OR (vr_countpag >= pr_nriniseq AND vr_countpag < (pr_nriniseq + pr_nrregist)) THEN
              /*Verifica se o valor líquido do título é 0, se for calcula*/
              IF (vr_tab_tit_bordero(vr_index).vlliquid=0) THEN
                IF  rw_crapdat.dtmvtolt > vr_tab_tit_bordero(vr_index).dtvencto THEN
                    vr_qtd_dias := rw_crapdat.dtmvtolt - vr_tab_tit_bordero(vr_index).dtvencto;
                    --vr_qtd_dias := ccet0001.fn_diff_datas(vr_tab_tit_bordero(vr_index).dtvencto,rw_crapdat.dtmvtolt);
                ELSE
                    vr_qtd_dias := vr_tab_tit_bordero(vr_index).dtvencto -  rw_crapdat.dtmvtolt;
                END IF;
                vr_vldjuros := vr_tab_tit_bordero(vr_index).vltitulo * vr_qtd_dias * ((vr_taxamensal / 100) / 30);
                vr_tab_tit_bordero(vr_index).vlliquid := ROUND((vr_tab_tit_bordero(vr_index).vltitulo - vr_vldjuros),2);
              END IF;
              SELECT (nvl((SELECT 
                              decode(inpossui_criticas,1,'S','N')
                              FROM 
                               tbdsct_analise_pagador tap 
                            WHERE tap.cdcooper=pr_cdcooper AND tap.nrdconta=pr_nrdconta AND tap.nrinssac=vr_tab_tit_bordero(vr_index).nrinssac
                         ),'A')) INTO vr_situacao FROM DUAL ; -- Situacao do pagador com critica ou nao
              
              vr_tab_criticas.delete;
              dsct0003.pc_calcula_restricao_titulo(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => vr_tab_tit_bordero(vr_index).nrdconta
                              ,pr_nrdocmto => vr_tab_tit_bordero(vr_index).nrdocmto
                              ,pr_nrcnvcob => vr_tab_tit_bordero(vr_index).nrcnvcob
                              ,pr_nrdctabb => vr_tab_tit_bordero(vr_index).nrdctabb
                              ,pr_cdbandoc => vr_tab_tit_bordero(vr_index).cdbandoc
                              ,pr_tab_criticas => vr_tab_criticas
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
              IF nvl(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
                 RAISE vr_exc_erro;
              END IF;
              IF (vr_tab_criticas.count>0) THEN
                vr_situacao := 'S';
              END IF;

              open cr_crapcbd;
              fetch cr_crapcbd into rw_crapcbd;
              IF (cr_crapcbd%NOTFOUND) THEN
                vr_ibratan := 'A';
              ELSE
                SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir,rw_crapcbd.nrseqdet,vr_cdbircon,vr_dsbircon,vr_cdmodbir,vr_dsmodbir,vr_ibratan);
              END IF;
              close cr_crapcbd;
              
             pr_tab_tit_bordero(vr_index).nrdctabb := vr_tab_tit_bordero(vr_index).nrdctabb;
             pr_tab_tit_bordero(vr_index).nrcnvcob := vr_tab_tit_bordero(vr_index).nrcnvcob;
             pr_tab_tit_bordero(vr_index).nrinssac := vr_tab_tit_bordero(vr_index).nrinssac;
             pr_tab_tit_bordero(vr_index).cdbandoc := vr_tab_tit_bordero(vr_index).cdbandoc;
             pr_tab_tit_bordero(vr_index).nrdconta := vr_tab_tit_bordero(vr_index).nrdconta;
             pr_tab_tit_bordero(vr_index).nrdocmto := vr_tab_tit_bordero(vr_index).nrdocmto;
             pr_tab_tit_bordero(vr_index).dtvencto := vr_tab_tit_bordero(vr_index).dtvencto;
             pr_tab_tit_bordero(vr_index).dtlibbdt := vr_tab_tit_bordero(vr_index).dtlibbdt;
             pr_tab_tit_bordero(vr_index).dtdpagto := vr_tab_tit_bordero(vr_index).dtdpagto;
             pr_tab_tit_bordero(vr_index).nossonum := vr_tab_tit_bordero(vr_index).nossonum;
             pr_tab_tit_bordero(vr_index).vltitulo := vr_tab_tit_bordero(vr_index).vltitulo;
             pr_tab_tit_bordero(vr_index).vlliquid := vr_tab_tit_bordero(vr_index).vlliquid;
             pr_tab_tit_bordero(vr_index).vlsldtit := vr_tab_tit_bordero(vr_index).vlsldtit;
             pr_tab_tit_bordero(vr_index).inprejuz := vr_tab_tit_bordero(vr_index).inprejuz;
             pr_tab_tit_bordero(vr_index).vlsdprej := vr_tab_tit_bordero(vr_index).vlsdprej;
             pr_tab_tit_bordero(vr_index).nmsacado := vr_tab_tit_bordero(vr_index).nmsacado;
             pr_tab_tit_bordero(vr_index).insittit := vr_tab_tit_bordero(vr_index).insittit;
             pr_tab_tit_bordero(vr_index).insitapr := vr_tab_tit_bordero(vr_index).insitapr;
             pr_tab_tit_bordero(vr_index).flgregis := vr_tab_tit_bordero(vr_index).flgregis;
             pr_tab_tit_bordero(vr_index).nrctrdsc := vr_tab_tit_bordero(vr_index).nrctrdsc;
             pr_tab_tit_bordero(vr_index).dssituac := vr_situacao;
             pr_tab_tit_bordero(vr_index).sitibrat := vr_ibratan;
             pr_tab_tit_bordero(vr_index).dssittit := vr_tab_tit_bordero(vr_index).dssittit;
         END IF;
         vr_countpag := vr_countpag + 1; 
            
             vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;

       pr_qtregist := vr_countpag-1;

    EXCEPTION
      WHEN vr_exc_erro THEN
           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_tit_bordero ' ||SQLERRM;
                                  
END pc_buscar_tit_bordero;
  
PROCEDURE pc_buscar_tit_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS
    /*
     * Alterações:
     *  23/07/2018 - Vitor Shimada Assanuma: Inserção de tratativa de Não vencido quando Resgatado.
     *  05/11/2018 - Lucas Negoseki GFT: Alterado Saldo Devedor para valor prejuizo quando em prejuízo.
     */
    -- variaveis de retorno
    vr_tab_tit_bordero typ_tab_tit_bordero;

    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_qtregist         number;
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    vr_dssittit VARCHAR2(100);
    
    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%rowtype;
    
    vr_tit_vencido INTEGER;
    
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      pc_buscar_tit_bordero(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_idorigem => vr_idorigem
                           ,pr_nrborder => pr_nrborder
                       --------> OUT <--------
                           ,pr_qtregist => vr_qtregist
                           ,pr_tab_tit_bordero => vr_tab_tit_bordero
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic );
      
      --    Leitura do calendário da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');
                     
      -- ler os registros de titulos e incluir no xml
      vr_index := vr_tab_tit_bordero.first;
                             
      while vr_index is not null LOOP
            vr_tit_vencido := 0;
            vr_dssittit    := vr_tab_tit_bordero(vr_index).dssittit;
            
            --Verifica se o titulo está vencido
            IF (vr_tab_tit_bordero(vr_index).insittit NOT IN (1,2,3))
             AND (gene0005.fn_valida_dia_util(vr_cdcooper, vr_tab_tit_bordero(vr_index).dtvencto) < rw_crapdat.dtmvtolt) THEN
              vr_tit_vencido := 1;
              
              IF vr_tab_tit_bordero(vr_index).insitapr <> 2 THEN
                vr_dssittit := 'Vencido';
              END IF;
            END IF;
            
            --Ajusta saldo devedor para saldo prejuizo
            IF vr_tab_tit_bordero(vr_index).inprejuz = 1 THEN
               vr_tab_tit_bordero(vr_index).vlsldtit := vr_tab_tit_bordero(vr_index).vlsdprej;
            END IF;
            
            pc_escreve_xml('<titulo>'||
                              '<cdbandoc>' || vr_tab_tit_bordero(vr_index).cdbandoc || '</cdbandoc>' || --FIELD cdbandoc LIKE craptdb.cdbandoc
                              '<nrdconta>' || vr_tab_tit_bordero(vr_index).nrdconta || '</nrdconta>' || --FIELD nrdconta LIKE craptdb.nrdconta
                              '<nrdocmto>' || vr_tab_tit_bordero(vr_index).nrdocmto || '</nrdocmto>' || --FIELD nrdocmto LIKE craptdb.nrdocmto
                              '<dtvencto>' || to_char(vr_tab_tit_bordero(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' || --FIELD dtvencto LIKE craptdb.dtvencto
                              '<dtlibbdt>' || to_char(vr_tab_tit_bordero(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' || --FIELD dtlibbdt LIKE craptdb.dtlibbdt
                              '<nrinssac>' || vr_tab_tit_bordero(vr_index).nrinssac || '</nrinssac>' || --FIELD nrinssac LIKE craptdb.nrinssac
                              '<nrcnvcob>' || vr_tab_tit_bordero(vr_index).nrcnvcob || '</nrcnvcob>' || --FIELD nrcnvcob LIKE craptdb.nrcnvcob
                              '<nrdctabb>' || vr_tab_tit_bordero(vr_index).nrdctabb || '</nrdctabb>' || --FIELD nrdctabb LIKE craptdb.nrdctabb
                              '<vltitulo>' || vr_tab_tit_bordero(vr_index).vltitulo || '</vltitulo>' || --FIELD vltitulo LIKE craptdb.vltitulo
                              '<vlliquid>' || vr_tab_tit_bordero(vr_index).vlliquid || '</vlliquid>' || --FIELD vlliquid LIKE craptdb.vlliquid
                              '<nossonum>' || vr_tab_tit_bordero(vr_index).nossonum || '</nossonum>' || --FIELD nossonum AS CHAR
                              '<nmsacado>' || htf.escape_sc(vr_tab_tit_bordero(vr_index).nmsacado) || '</nmsacado>' || --FIELD nmsacado AS CHAR
                              '<insittit>' || vr_tab_tit_bordero(vr_index).insittit || '</insittit>' || --FIELD insittit LIKE craptdb.insittit
                              '<flgregis>' || vr_tab_tit_bordero(vr_index).flgregis || '</flgregis>' || --FIELD flgregis AS LOG  FORMAT "REGISTRADA/SEM REGISTRO"
                              '<insitapr>' || vr_tab_tit_bordero(vr_index).insitapr || '</insitapr>' || --FIELD insitapr LIKE craptdb.insitapr
                              '<tvencido>' || vr_tit_vencido                        || '</tvencido>' || -- Verifica a partir do calendario de feriados se esta vencido ou nao
                              '<vlsldtit>' || vr_tab_tit_bordero(vr_index).vlsldtit || '</vlsldtit>' || --Saldo devedor do título
                              '<nrctrdsc>' || vr_tab_tit_bordero(vr_index).nrctrdsc || '</nrctrdsc>' || --Numero de contrato Cyber
                              '<dssittit>' || vr_dssittit || '</dssittit>' || --FIELD dssittit LIKE descrição da craptdb.insittit
                           '</titulo>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_tit_bordero.next(vr_index);
      end loop;
      
      OPEN dsct0003.cr_crapabt(pr_cdcooper=>vr_cdcooper,pr_nrborder=>pr_nrborder,pr_tpcritica=>4);
      pc_escreve_xml('<cedente>');
      LOOP
        FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
             EXIT WHEN dsct0003.cr_crapabt%NOTFOUND;
             pc_escreve_xml('<critica>'||
                              '<dsc>' || dsct0003.rw_abt.dscritica || '</dsc>'||
                              '<vlr>' || dsct0003.rw_abt.dsdetres || '</vlr>'||
                           '</critica>');    
          
      END LOOP;
      pc_escreve_xml('</cedente>');
      CLOSE dsct0003.cr_crapabt;
      
      OPEN dsct0003.cr_crapabt(pr_cdcooper=>vr_cdcooper,pr_nrborder=>pr_nrborder,pr_tpcritica=>2);
      pc_escreve_xml('<bordero>');
      LOOP
        FETCH dsct0003.cr_crapabt into dsct0003.rw_abt;
             EXIT WHEN dsct0003.cr_crapabt%NOTFOUND;
             pc_escreve_xml('<critica>'||
                              '<dsc>' || dsct0003.rw_abt.dscritica || '</dsc>'||
                              '<vlr>' || dsct0003.rw_abt.dsdetres || '</vlr>'||
                           '</critica>');    
          
      END LOOP;
      pc_escreve_xml('</bordero>');
      CLOSE dsct0003.cr_crapabt;

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_tit_bordero_web;
    
    PROCEDURE pc_buscar_dados_bordero_web (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_dtmvtolt IN VARCHAR2 --> Data de movimentação do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_dados_bordero_web
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Março/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que busca os dados do bordero e de seus titulos  e monta o xml para a tela 
    Alterações
      -   09/08/2018 - Vitor Shimada Assanuma (GFT) - Inclusão do paramentro da TAB052 de QtdMaxTit.
      -   15/08/2018 - Vitor Shimada Assanuma (GFT) - Remoção do NrCtrLimite na pesquisa da Bdt e alteração da mensagem quando não contratos 
                            ativo é diferente do contrato do borderô clicado.
  ---------------------------------------------------------------------------------------------------------------------*/


    /* tratamento de erro */
    vr_exc_erro EXCEPTION;
    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_qtregist NUMBER;
    vr_vltitulo NUMBER;
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    
    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro
    
    -- Variaveis de tratamento do retorno
    vr_tab_dados_limite  typ_tab_dados_limite;          --> retorna dos dados do contrato
    vr_tab_tit_bordero typ_tab_tit_bordero;             --> retorna os dados dos titulos do bordero
    
   -- Pegar os dados do bordero
    CURSOR cr_crapbdt IS      
      SELECT 
        crapbdt.nrborder,
        crapbdt.nrctrlim,
        crapbdt.insitbdt,
        crapbdt.cdoperad,
        crapbdt.insitapr
      FROM 
        crapbdt
      where 
        crapbdt.cdcooper = vr_cdcooper
        AND crapbdt.nrdconta = pr_nrdconta
        AND crapbdt.nrborder = pr_nrborder
      ;
    rw_crapbdt cr_crapbdt%rowtype;

    -- Cursor para buscar o tipo de pessoa.
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 
        crapass.inpessoa
      FROM 
        crapass
      WHERE 
        crapass.cdcooper = pr_cdcooper
        AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
        
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
    
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      /*Busca dados do contrato ativo*/
      pc_busca_dados_limite (pr_nrdconta
                                     ,vr_cdcooper
                                     ,3 -- desconto de titulo
                                     ,2 -- apenas ativo
                                     ,vr_dtmvtolt
                                     --------> OUT <--------
                                     ,vr_tab_dados_limite
                                     ,vr_cdcritic
                                     ,vr_dscritic
                            );
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;       
      /*Dados do Bordero*/
      open cr_crapbdt;
      fetch cr_crapbdt into rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        CLOSE cr_crapbdt;
        vr_dscritic := 'Borderô inválido';
        raise vr_exc_erro;
      END IF;
      IF (rw_crapbdt.nrctrlim<>vr_tab_dados_limite(0).nrctrlim) THEN
        vr_dscritic := 'O contrato deste borderô não se encontra mais ativo.';
        raise vr_exc_erro;
      END IF;
      IF (rw_crapbdt.insitbdt>2 OR rw_crapbdt.insitapr=7) THEN -- 1 = Em estudo, 2 = Analisado -- insitapr 7 = Prazo Expirado
        vr_dscritic := 'Apenas borderôs em estudo e aprovados podem ser alterados';
        raise vr_exc_erro;
      END IF;
      
      /*Buscar Titulos do Bordero*/
      pc_buscar_tit_bordero(pr_cdcooper => vr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_idorigem => vr_idorigem
                           ,pr_nrborder => pr_nrborder
                       --------> OUT <--------
                           ,pr_qtregist => vr_qtregist
                           ,pr_tab_tit_bordero => vr_tab_tit_bordero
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic );
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;       
      
      -- busca os dados do associado/cooperado para só então encontrar seus dados na tabela de parâmetros
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;
      -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
      dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                            NULL, --Agencia de operação
                                            NULL, --Número do caixa
                                            NULL, --Operador
                                            NULL, -- Data da Movimentação
                                            NULL, --Identificação de origem
                                            1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                            rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                            vr_tab_dados_dsctit,
                                            vr_tab_cecred_dsctit,
                                            vr_cdcritic,
                                            vr_dscritic);
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      /*Passou nas validações do bordero, do contrato e listou titulos. Começa a montar o xml*/
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados  >');
                         
      pc_escreve_xml('<contrato>'||
                          '<dtpropos>' || to_char(vr_tab_dados_limite(0).dtpropos,'dd/mm/rrrr') || '</dtpropos>' ||
                          '<dtinivig>' || to_char(vr_tab_dados_limite(0).dtinivig,'dd/mm/rrrr') || '</dtinivig>' ||
                          '<nrctrlim>' || vr_tab_dados_limite(0).nrctrlim || '</nrctrlim>' ||
                          '<vllimite>' || vr_tab_dados_limite(0).vllimite || '</vllimite>' ||
                          '<qtdiavig>' || vr_tab_dados_limite(0).qtdiavig || '</qtdiavig>' ||
                          '<cddlinha>' || vr_tab_dados_limite(0).cddlinha || '</cddlinha>' ||
                          '<tpctrlim>' || vr_tab_dados_limite(0).tpctrlim || '</tpctrlim>' ||
                          '<vlutiliz>' || vr_tab_dados_limite(0).vlutiliz || '</vlutiliz>' ||
                          '<qtutiliz>' || vr_tab_dados_limite(0).qtutiliz || '</qtutiliz>' ||
                          '<dtfimvig>' || to_char(vr_tab_dados_limite(0).dtfimvig,'dd/mm/rrrr') || '</dtfimvig>' ||
                          '<pctolera>' || vr_tab_dados_limite(0).pctolera || '</pctolera>' ||
                    '</contrato>');
                    
      pc_escreve_xml('<titulos qtregist="' || vr_qtregist ||'">');   
      -- ler os registros de titulos e incluir no xml
      vr_index := vr_tab_tit_bordero.first;
      vr_vltitulo := 0;
      while vr_index is not null loop    
            pc_escreve_xml('<titulo>'||
                              '<cdbandoc>' || vr_tab_tit_bordero(vr_index).cdbandoc || '</cdbandoc>' || 
                              '<nrdconta>' || vr_tab_tit_bordero(vr_index).nrdconta || '</nrdconta>' || 
                              '<nrdocmto>' || vr_tab_tit_bordero(vr_index).nrdocmto || '</nrdocmto>' || 
                              '<dtvencto>' || to_char(vr_tab_tit_bordero(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' || 
                              '<dtlibbdt>' || to_char(vr_tab_tit_bordero(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' || 
                              '<nrinssac>' || vr_tab_tit_bordero(vr_index).nrinssac || '</nrinssac>' || 
                              '<nrcnvcob>' || vr_tab_tit_bordero(vr_index).nrcnvcob || '</nrcnvcob>' || 
                              '<nrdctabb>' || vr_tab_tit_bordero(vr_index).nrdctabb || '</nrdctabb>' || 
                              '<vltitulo>' || vr_tab_tit_bordero(vr_index).vltitulo || '</vltitulo>' || 
                              '<vlliquid>' || vr_tab_tit_bordero(vr_index).vlliquid || '</vlliquid>' || 
                              '<nossonum>' || vr_tab_tit_bordero(vr_index).nossonum || '</nossonum>' || 
                              '<nmsacado>' || htf.escape_sc(vr_tab_tit_bordero(vr_index).nmsacado) || '</nmsacado>' || 
                              '<insittit>' || vr_tab_tit_bordero(vr_index).insittit || '</insittit>' || 
                              '<flgregis>' || vr_tab_tit_bordero(vr_index).flgregis || '</flgregis>' || 
                              '<dssituac>' || vr_tab_tit_bordero(vr_index).dssituac || '</dssituac>' || 
                              '<sitibrat>' || vr_tab_tit_bordero(vr_index).sitibrat || '</sitibrat>' || 
                              '<nrnosnum>' || vr_tab_tit_bordero(vr_index).nossonum || '</nrnosnum>' ||
                           '</titulo>'
                          );
          vr_vltitulo := vr_vltitulo+vr_tab_tit_bordero(vr_index).vltitulo;
          /* buscar proximo */
          vr_index := vr_tab_tit_bordero.next(vr_index);
      end loop;
      pc_escreve_xml('</titulos>');
      
      /*Dados do bordero*/
      pc_escreve_xml('<bordero>' ||
                          '<nrborder>' || rw_crapbdt.nrborder || '</nrborder>' ||
                          '<insitbdt>' || rw_crapbdt.insitbdt || '</insitbdt>' ||
                          '<qttitulo>' || vr_qtregist || '</qttitulo>' ||
                          '<vltitulo>' || vr_vltitulo || '</vltitulo>' ||
                          '<cdoperad>' || rw_crapbdt.cdoperad || '</cdoperad>' ||
                          '<qtmaxtit>' || vr_tab_dados_dsctit(1).qtmxtbay || '</qtmaxtit>' ||
                     '</bordero>');
      
                  
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);
      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_dados_bordero_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_dados_bordero_web;
    
    PROCEDURE pc_validar_titulos_alteracao (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_dtmvtolt IN VARCHAR2 --> Data de movimentação do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS
    
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_titulos_alteracao
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018    

    Objetivo  : Procedure para retestar os titulos do borderô que está sendo alterado

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   vr_tab_dados_titulos    typ_tab_dados_titulos;
   vr_dtmvtolt DATE;
   -- variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);
   
   -- Tratamento de erros
   vr_exc_erro exception;
   
   --Tab052
   pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
   pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
   vr_qtprzmaxpj number; -- Prazo Máximo PJ (Em dias)
   vr_qtprzmaxpf number; -- Prazo Máximo PF (Em dias)
   
   vr_qtprzminpj number; -- Prazo Mínimo PJ (Em dias)
   vr_qtprzminpf number; -- Prazo Mínimo PF (Em dias)
   
   vr_vlminsacpj number; -- Valor mínimo permitido por título PJ
   vr_vlminsacpf number; -- Valor mínimo permitido por título PF
       
   vr_idtabtitulo INTEGER;
   vr_tab_cobs  gene0002.typ_split;
   vr_tab_chaves  gene0002.typ_split;
   vr_index     INTEGER;
          
   CURSOR cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE, pr_nrdctabb IN crapcob.nrdctabb%TYPE, pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
      select  
         cob.cdcooper,
         cob.nrdconta,
         cob.nrctremp,
         cob.nrcnvcob,
         cob.nrdocmto,
         cob.nrinssac,
         sab.nmdsacad,
         cob.dtvencto,
         cob.dtmvtolt,
         cob.vltitulo,
         cob.nrnosnum,
         cob.flgregis,
         cob.cdtpinsc,
         cob.vldpagto,
         cob.cdbandoc,
         cob.nrdctabb,
         cob.dtdpagto,
         tdb.nrborder,
         tdb.dtlibbdt,
         cob.incobran
        from   crapcob cob 
          INNER JOIN cecred.crapsab sab ON sab.nrinssac = cob.nrinssac AND
										   sab.cdcooper = cob.cdcooper AND
										   sab.nrdconta = cob.nrdconta  
          INNER JOIN craptdb tdb ON cob.cdcooper = tdb.cdcooper AND 
                                           cob.cdbandoc = tdb.cdbandoc AND  
                                           cob.nrdctabb = tdb.nrdctabb AND  
                                           cob.nrdconta = tdb.nrdconta AND  
                                           cob.nrcnvcob = tdb.nrcnvcob AND  
                                           cob.nrdocmto = tdb.nrdocmto  
       where  cob.nrdconta = pr_nrdconta
         and    cob.cdcooper = vr_cdcooper
         AND    cob.nrcnvcob = pr_nrcnvcob
         AND    cob.cdbandoc = pr_cdbandoc
         AND    cob.nrdctabb = pr_nrdctabb
         AND    cob.nrdocmto = pr_nrdocmto
       ;
       rw_crapcob cr_crapcob%rowtype;

    BEGIN 
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);


      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      --carregando os dados de prazo e valor da TAB052 
       -- BUSCAR O PRAZO PARA PESSOA FISICA
      cecred.dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                                 vr_cdagenci, --Agencia de operação
                                                 vr_nrdcaixa, --Número do caixa
                                                 vr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimentação
                                                 vr_idorigem, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 1, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpf := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpf := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpf := pr_tab_dados_dsctit(1).vlminsac;

      -- BUSCAR O PRAZO PARA PESSOA JURÍDICA
      cecred.dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                                 vr_cdagenci, --Agencia de operação
                                                 vr_nrdcaixa, --Número do caixa
                                                 vr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimentação
                                                 vr_idorigem, --Identificação de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                 2, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpj := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpj := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpj := pr_tab_dados_dsctit(1).vlminsac;
      
      
      vr_tab_cobs := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                 pr_delimit => ',');
                                                 
       
      vr_idtabtitulo:=0;
      IF vr_tab_cobs.count() > 0 THEN
        /*Traz 1 linha para cada cobrança sendo selecionada*/
        vr_index := vr_tab_cobs.first;
        while vr_index is not null loop
          -- Pega a lsita de chaves por titulo
          vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => vr_tab_cobs(vr_index),
                                                pr_delimit => ';');
          IF (vr_tab_chaves.count() > 0) THEN
            open cr_crapcob (vr_tab_chaves(4), -- Conta
                             vr_tab_chaves(3), -- Convenio
                             vr_tab_chaves(2), -- Conta base do banco
                             vr_tab_chaves(1)  -- Codigo do banco
                             );
            fetch cr_crapcob INTO rw_crapcob;
            IF (cr_crapcob%FOUND) THEN
              vr_tab_dados_titulos(vr_idtabtitulo).cdcooper := rw_crapcob.cdcooper;
              vr_tab_dados_titulos(vr_idtabtitulo).nrdconta := rw_crapcob.nrdconta;
              vr_tab_dados_titulos(vr_idtabtitulo).nrctremp := rw_crapcob.nrctremp;
              vr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob := rw_crapcob.nrcnvcob;
              vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto := rw_crapcob.nrdocmto;
              vr_tab_dados_titulos(vr_idtabtitulo).nrinssac := rw_crapcob.nrinssac;
              vr_tab_dados_titulos(vr_idtabtitulo).nmdsacad := rw_crapcob.nmdsacad;
              vr_tab_dados_titulos(vr_idtabtitulo).dtvencto := rw_crapcob.dtvencto;
              vr_tab_dados_titulos(vr_idtabtitulo).dtmvtolt := rw_crapcob.dtmvtolt;
              vr_tab_dados_titulos(vr_idtabtitulo).vltitulo := rw_crapcob.vltitulo;
              vr_tab_dados_titulos(vr_idtabtitulo).nrnosnum := rw_crapcob.nrnosnum;
              vr_tab_dados_titulos(vr_idtabtitulo).flgregis := rw_crapcob.flgregis;
              vr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc := rw_crapcob.cdtpinsc;
              vr_tab_dados_titulos(vr_idtabtitulo).vldpagto := rw_crapcob.vldpagto;
              vr_tab_dados_titulos(vr_idtabtitulo).cdbandoc := rw_crapcob.cdbandoc;
              vr_tab_dados_titulos(vr_idtabtitulo).nrdctabb := rw_crapcob.nrdctabb;
              vr_tab_dados_titulos(vr_idtabtitulo).dtdpagto := rw_crapcob.dtdpagto;
              vr_tab_dados_titulos(vr_idtabtitulo).nrborder := rw_crapcob.nrborder;
              vr_tab_dados_titulos(vr_idtabtitulo).dtlibbdt := rw_crapcob.dtlibbdt;
              vr_tab_dados_titulos(vr_idtabtitulo).incobran := rw_crapcob.incobran;
              /*Verifica se o titulo é registrado*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).flgregis=0) THEN
                vr_dscritic:= 'Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser registrado.';
                raise vr_exc_erro;
              END IF;
              /*Verifica se o status do titulos é diferente de em aberto*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).incobran<>0) THEN
                vr_dscritic:= 'Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve estar em aberto.';
                raise vr_exc_erro;
              END IF;
              /*Testes da tab052 para PF*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc=1) THEN
                /*Verifica se o valor minimo do titulo entra na regra da tab052*/
                IF (vr_tab_dados_titulos(vr_idtabtitulo).vltitulo<vr_vlminsacpf) THEN
                  vr_dscritic:= 'Valor do Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ter valor maior que o mínimo perimitido da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo é maior que o prazo mínimo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)<vr_qtprzminpf) THEN
                  vr_dscritic:= 'Vencimento do Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser maior que o prazo mínimo da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo é menor que o prazo máximo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)>vr_qtprzmaxpf) THEN
                  vr_dscritic:= 'Vencimento do ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser menor que o prazo máximo da TAB052.';
                  raise vr_exc_erro;
                END IF;
              /*Testes da tab052 para PJ*/
              ELSE 
                /*Verifica se o valor minimo do titulo entra na regra da tab052*/
                IF (vr_tab_dados_titulos(vr_idtabtitulo).vltitulo<vr_vlminsacpj) THEN
                   vr_dscritic:= 'Valor do Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ter valor maior que o mínimo perimitido da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo é maior que o prazo mínimo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)<vr_qtprzminpj) THEN
                  vr_dscritic:= 'Vencimento do Título ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser maior que o prazo mínimo da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo é menor que o prazo máximo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)>vr_qtprzmaxpj) THEN
                  vr_dscritic:= 'Vencimento do ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser menor que o prazo máximo da TAB052.';
                  raise vr_exc_erro;
                END IF;
              END IF;
            END IF;
            vr_idtabtitulo := vr_idtabtitulo + 1;
            close cr_crapcob;
          END IF;
          vr_index := vr_tab_cobs.next(vr_index);
        end loop;
      END IF;
                
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_validar_titulos_alteracao ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');            
    END pc_validar_titulos_alteracao;
    
  PROCEDURE pc_altera_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                                   ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                                   ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                   ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                   ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao
                                   ,pr_nrborder           in crapbdt.nrborder%type   --> Borderô sendo alterado
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                    ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                   ) is
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_altera_bordero
      Sistema  : Ayllos
      Sigla    : TELA_ATENDA_DSCTO_TIT
      Autor    : Luis Fernando (GFT)
      Data     : Abril/2018    

      Objetivo  : Procedure para Alterar os títulos de um borderô
      Alterações:
        - 13/08/2018 - Vitor Shimada Assanuma (GFT) - Verificar se o título foi resgatado na alteração.
        - 06/11/2018 - Fabio dos Santos (GFT) - Inclusao da chamada do InterrompeFluxo da Esteira, na pc_altera_bordero
        - 31/01/2019 - Cássia de Oliveira (GFT) - Alteração no registro de LOG

    ---------------------------------------------------------------------------------------------------------------------*/
     -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

     -- Tratamento de erros
     vr_exc_erro exception;
     
    -- rowid tabela de log
    vr_nrdrowid ROWID;
      
     -- Variaveis para carregamento e validacoes de dados   
     vr_cddlinha craplim.cddlinha%TYPE;
     vr_index        INTEGER;
     vr_vldtit       NUMBER;
     vr_dtmvtolt     DATE;
     vr_qtregist     NUMBER;
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
      vr_inseriu boolean;
      
       --TAB
       pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
       pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
         
      vr_dtmvtopr DATE;
      rw_crapdat  btch0001.rw_crapdat%TYPE;
      vr_indrestr     INTEGER;
      vr_ind_inpeditivo  INTEGER;
       vr_tab_erro        GENE0001.typ_tab_erro;
       vr_tab_retorno_analise DSCT0003.typ_tab_retorno_analise;
       
     -- Contrato do limite 
      CURSOR cr_craplim IS      
        SELECT 
          craplim.dtpropos,
          craplim.dtinivig,
          craplim.nrctrlim,
          craplim.vllimite,
          craplim.qtdiavig,
          craplim.cddlinha,
          craplim.tpctrlim,
          craplim.dtfimvig,
          (SELECT SUM(craptdb.vlsldtit) 
             FROM
               craptdb
             INNER JOIN crapcob ON crapcob.cdcooper = craptdb.cdcooper AND
                                                      crapcob.cdbandoc = craptdb.cdbandoc AND
                                                      crapcob.nrdctabb = craptdb.nrdctabb AND
                                                      crapcob.nrdconta = craptdb.nrdconta AND
                                                      crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                                      crapcob.nrdocmto = craptdb.nrdocmto
                WHERE 
                     craptdb.cdcooper = craplim.cdcooper
                     AND craptdb.nrdconta = craplim.nrdconta
                     AND craptdb.nrctrlim = craplim.nrctrlim
                     AND (craptdb.insittit=4 OR (craptdb.insittit=2 AND craptdb.dtdpagto=vr_dtmvtolt))
          )AS vlutiliz
        FROM 
          craplim
        where 
          craplim.cdcooper = vr_cdcooper
          AND craplim.tpctrlim = pr_tpctrlim
          AND craplim.nrdconta = pr_nrdconta
          AND craplim.insitlim = pr_insitlim
        ;
      rw_craplim cr_craplim%rowtype;
      
      CURSOR cr_crapass IS
         SELECT
            crapass.inpessoa
         FROM
            crapass
         WHERE
            crapass.nrdconta = pr_nrdconta
            AND crapass.cdcooper = vr_cdcooper;
      rw_crapass cr_crapass%rowtype;
        
        
      -- Linha de crédito
      CURSOR cr_crapldc IS
        SELECT 
          cddlinha,
          txmensal
        FROM 
          crapldc
        WHERE
          crapldc.cdcooper = vr_cdcooper 
          AND crapldc.cddlinha = vr_cddlinha 
          AND crapldc.tpdescto = 3;
       rw_crapldc cr_crapldc%rowtype;
      
      -- Verificar se o titulo ja nao foi usado em algum bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE,
                         pr_nrdconta IN craptdb.nrdconta%TYPE, 
                         pr_nrdocmto IN craptdb.nrdocmto%TYPE, 
                         pr_cdbandoc IN craptdb.cdbandoc%TYPE,
                         pr_nrcnvcob IN craptdb.nrcnvcob%TYPE,
                         pr_nrdctabb IN craptdb.nrdctabb%TYPE
                         )
       IS
         SELECT
            craptdb.nrdocmto,
            craptdb.nrborder
         FROM
            craptdb
            INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
         WHERE
            craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = pr_cdcooper
            AND craptdb.nrdocmto = pr_nrdocmto
            AND craptdb.cdbandoc = pr_cdbandoc
            AND craptdb.nrdctabb = pr_nrdctabb
            AND craptdb.nrcnvcob = pr_nrcnvcob
            AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
            AND craptdb.insitapr = 1
            AND craptdb.dtresgat IS NULL
            ;
      rw_craptdb cr_craptdb%rowtype;
      
      -- Bordero sendo alterado
      CURSOR cr_crapbdt IS
         SELECT
             *
         FROM
             crapbdt
         WHERE
             crapbdt.nrborder = pr_nrborder
             AND crapbdt.cdcooper = vr_cdcooper
             AND crapbdt.nrdconta = pr_nrdconta;
       rw_crapbdt cr_crapbdt%ROWTYPE;
       
       type tpy_ref_cob is ref cursor;
       cr_tab_cob       tpy_ref_cob;
       vr_sql       varchar2(32767);
       vr_idtabtitulo INTEGER;
       vr_tab_dados_titulos typ_tab_dados_titulos;
       vr_tab_titulos_excluir typ_tab_dados_titulos;
       vr_chave       varchar2(32767);
       vr_achoutit INTEGER;
     BEGIN
        pr_des_erro := 'OK';
        pr_nmdcampo := NULL;
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                  , pr_cdcooper => vr_cdcooper
                                  , pr_nmdatela => vr_nmdatela
                                  , pr_nmeacao  => vr_nmeacao
                                  , pr_cdagenci => vr_cdagenci
                                  , pr_nrdcaixa => vr_nrdcaixa
                                  , pr_idorigem => vr_idorigem
                                  , pr_cdoperad => vr_cdoperad
                                  , pr_dscritic => vr_dscritic);
                                  
        -- VERIFICA SE O CONTRATO EXISTE E AINDA ESTÁ ATIVO
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF (cr_craplim%NOTFOUND) THEN
          CLOSE cr_craplim;
          vr_dscritic := 'Contrato não encontrado ou inativo.';
          raise vr_exc_erro;
        END IF;
        vr_cddlinha := rw_craplim.cddlinha;
          
        OPEN cr_crapldc;
        FETCH cr_crapldc INTO rw_crapldc;
        IF (cr_crapldc%NOTFOUND) THEN
           CLOSE cr_crapldc;
           vr_dscritic := 'Linha de crédito não encontrada.';
           raise vr_exc_erro;
        END IF;
          
       vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
       IF (rw_craplim.dtfimvig <vr_dtmvtolt) THEN
           vr_dscritic := 'A vigência do contrato deve ser maior que a data de movimentação do sistema.';
         raise vr_exc_erro;
       END IF;
       
       OPEN cr_crapass;
       FETCH cr_crapass INTO rw_crapass;
       IF (cr_crapass%NOTFOUND) THEN
          CLOSE cr_crapass;
          vr_dscritic := 'Cooperado não cadastrado';
          raise vr_exc_erro;
       END IF;

        --carregando os dados de prazo limite da TAB052 
       dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                                   null, --Agencia de operação
                                                   null, --Número do caixa
                                                   null, --Operador
                                                   vr_dtmvtolt, -- Data da Movimentação
                                                   null, --Identificação de origem
                                                   1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                                   rw_crapass.inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                                   pr_tab_dados_dsctit,
                                                   pr_tab_cecred_dsctit,
                                                   vr_cdcritic,
                                                   vr_dscritic);
       
        pc_listar_titulos_resumo(pr_cdcooper => vr_cdcooper --> Cooperativa
                         ,pr_nrdconta => pr_nrdconta --> Número da Conta
                         ,pr_chave => pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                         --------> OUT <--------
                         ,pr_qtregist => vr_qtregist --> Quantidade de registros encontrados
                         ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                         ,pr_cdcritic => vr_cdcritic --> Código da crítica
                         ,pr_dscritic => vr_dscritic --> Descrição da crítica
                         );
                         
      /*VERIFICA SE O VALOR DOS BOLETOS SÃO > QUE O DISPONIVEL NO CONTRATO*/
        vr_index := vr_tab_dados_titulos.first;
        vr_vldtit := 0;
        WHILE vr_index IS NOT NULL LOOP
              /*Antes de realizar a inclusão deverá validar se algum título já foi selecionado em algum outro 
              borderô com situação diferente de “não aprovado” ou “prazo expirado”*/
            vr_vldtit := vr_vldtit + vr_tab_dados_titulos(vr_index).vltitulo;
             open cr_craptdb (pr_nrdconta=>pr_nrdconta,
                                   pr_cdcooper=>vr_cdcooper,
                                   pr_nrdocmto=>vr_tab_dados_titulos(vr_index).nrdocmto,
                                   pr_cdbandoc=>vr_tab_dados_titulos(vr_index).cdbandoc,
                                   pr_nrcnvcob=>vr_tab_dados_titulos(vr_index).nrcnvcob,
                                   pr_nrdctabb=>vr_tab_dados_titulos(vr_index).nrdctabb
                              );
               fetch cr_craptdb into rw_craptdb;
               if cr_craptdb%found then
                 IF rw_craptdb.nrborder<>pr_nrborder THEN
                   vr_dscritic := 'Título ' ||rw_craptdb.nrdocmto || ' já selecionado em outro borderô';
                   RAISE vr_exc_erro;
                 ELSE 
                   vr_tab_dados_titulos.delete(vr_index);
                 END IF;
               end if;
             close cr_craptdb;
            vr_index  := vr_tab_dados_titulos.next(vr_index);
        END LOOP;

        /*VERIFICAR SE O VALOR TOTAL DOS TITULOS NAO PASSAO O DISPONIVEL DO CONTRATO*/
        IF (vr_vldtit> ((rw_craplim.vllimite+(rw_craplim.vllimite*pr_tab_dados_dsctit(1).pctolera/100))-rw_craplim.vlutiliz)) THEN
          vr_dscritic := 'O Total de títulos selecionados supera o valor disponível no contrato.';
          raise vr_exc_erro;
        END IF;
        
        /*Passou nas validações todas, começa a fazer as respectivas alterações*/
        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;
        IF cr_crapbdt%NOTFOUND THEN
          CLOSE cr_crapbdt;
          vr_dscritic := 'Ocorreu um erro ao carregar o borderô para alteração';
          raise vr_exc_erro;
        END IF;
        IF (rw_crapbdt.insitbdt>2) THEN
          vr_dscritic := 'Borderô deve estar Em estudo ou Aprovado';
          raise vr_exc_erro;
        END IF;
        
        -- Chamar geração de LOG
        gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Alteracao do Bordero ' || pr_nrborder
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
        
        
        /*
        IF (rw_crapbdt.cdoperad<>vr_cdoperad) THEN
          vr_dscritic := 'Operador deve ser o mesmo que criou o borderô';
          raise vr_exc_erro;
        END IF;
        */
        /*Altera os dados necessários do lote*/
        UPDATE
            craplot
        SET
            craplot.qtinfoln = vr_qtregist,
            craplot.vlinfodb = vr_vldtit,
            craplot.vlinfocr = vr_vldtit,
            craplot.vlcompcr = vr_vldtit,
            craplot.vlcompdb = vr_vldtit,
            craplot.qtcompln = vr_qtregist
        WHERE
            craplot.cdbccxlt = 700
            AND craplot.nrdolote = rw_crapbdt.nrdolote
            AND craplot.cdcooper = rw_crapbdt.cdcooper
            AND craplot.tplotmov = 34
            AND craplot.dtmvtolt = vr_dtmvtolt --Altera o lote apenas se a data de movimentacao seja a mesma do lote
        ;
        
        vr_chave := replace(pr_chave,',',''',''');
        /*Remove títulos do bordero que foram removidos da tela de seleção de titulos na alteração*/
        vr_sql := 'SELECT cdcooper,nrdconta,nrcnvcob,nrdocmto FROM '||
                     ' craptdb '||
                     ' WHERE '||
                       ' craptdb.nrborder = :nrborder ' || 
                       ' AND craptdb.nrdconta =  :nrdconta ' ||
                       ' AND craptdb.cdcooper = :cdcooper ' ||
                       ' AND ((craptdb.cdbandoc||'';''||craptdb.nrdctabb||'';''||craptdb.nrcnvcob||'';''||craptdb.nrdocmto) '||	
                                              ' NOT IN ('''||vr_chave||''')) ';
       vr_idtabtitulo:=0;
       open  cr_tab_cob 
       for   vr_sql 
       using pr_nrborder, pr_nrdconta, vr_cdcooper;
       loop
             fetch cr_tab_cob into vr_tab_titulos_excluir(vr_idtabtitulo).cdcooper,
                                        vr_tab_titulos_excluir(vr_idtabtitulo).nrdconta,
                                        vr_tab_titulos_excluir(vr_idtabtitulo).nrcnvcob,
                                        vr_tab_titulos_excluir(vr_idtabtitulo).nrdocmto
                                        ;
             exit  when cr_tab_cob%notfound;
                 DELETE FROM 
                   craptdb
                 WHERE 
                   craptdb.cdcooper = vr_tab_titulos_excluir(vr_idtabtitulo).cdcooper
                   AND craptdb.nrdconta = vr_tab_titulos_excluir(vr_idtabtitulo).nrdconta
                   AND craptdb.nrcnvcob = vr_tab_titulos_excluir(vr_idtabtitulo).nrcnvcob
                   AND craptdb.nrdocmto = vr_tab_titulos_excluir(vr_idtabtitulo).nrdocmto;
                  
                 gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Titulo'
                                          ,pr_dsdadant => ''
                                          ,pr_dsdadatu => 'Excluindo o titulo ' || 
                                           				  vr_tab_titulos_excluir(vr_idtabtitulo).nrdconta || ' ' ||
                                           				  vr_tab_titulos_excluir(vr_idtabtitulo).nrcnvcob || ' ' || 
                                                          vr_tab_titulos_excluir(vr_idtabtitulo).nrdocmto);
                 
             vr_idtabtitulo:=vr_idtabtitulo+1;
       end   loop;
       close cr_tab_cob;
        
        /*INSERE OS TITULOS DO PONTEIRO vr_tab_dados_titulos*/
        vr_index:= vr_tab_dados_titulos.first;
        vr_idtabtitulo := rw_crapbdt.nrseqtdb;
        WHILE vr_index IS NOT NULL LOOP
           SELECT COUNT(*) INTO vr_achoutit FROM craptdb 
                   WHERE cdcooper =  vr_cdcooper 
                   AND nrdconta = pr_nrdconta 
                   AND nrborder = pr_nrborder 
                   AND nrdocmto = vr_tab_dados_titulos(vr_index).nrdocmto
                   AND cdbandoc = vr_tab_dados_titulos(vr_index).cdbandoc
                   AND nrdctabb = vr_tab_dados_titulos(vr_index).nrdctabb
                   AND nrcnvcob = vr_tab_dados_titulos(vr_index).nrcnvcob
            ;
            IF vr_achoutit = 0 THEN
            vr_idtabtitulo := vr_idtabtitulo+1;
            INSERT INTO 
                   craptdb
                   (nrdconta,
                    dtvencto,
                    nrseqdig,
                    cdoperad,
                    nrdocmto,
                    nrctrlim,
                    nrborder,
                    vlliquid,
                    dtlibbdt,
                    cdcooper,
                    cdbandoc,
                    nrdctabb,
                    nrcnvcob,
                    cdoperes,
                    dtresgat,
                    vlliqres,
                    vltitulo,
                    insittit,
                    nrinssac,
                    dtdpagto,
                    progress_recid,
                    dtdebito,
                    dtrefatu,
                    nrtitulo
                   )
                   VALUES(pr_nrdconta,
                   vr_tab_dados_titulos(vr_index).dtvencto,
                   vr_idtabtitulo,
                   vr_cdoperad,
                   vr_tab_dados_titulos(vr_index).nrdocmto,
                   rw_craplim.nrctrlim,
                   pr_nrborder,
                   vr_tab_dados_titulos(vr_index).vldpagto,
                   null,
                   vr_cdcooper,
                   vr_tab_dados_titulos(vr_index).cdbandoc,
                   vr_tab_dados_titulos(vr_index).nrdctabb,
                   vr_tab_dados_titulos(vr_index).nrdctabb,
                   null,
                   null,
                   null,
                   vr_tab_dados_titulos(vr_index).vltitulo,
                   0,
                   vr_tab_dados_titulos(vr_index).nrinssac,
                   vr_tab_dados_titulos(vr_index).dtdpagto,
                   null,
                   null,
                   null,
                   vr_idtabtitulo
                   );
                   
                 gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'Titulo'
                                          ,pr_dsdadant => ''
                                          ,pr_dsdadatu => 'Incluindo o titulo ' || 
                                           vr_tab_dados_titulos(vr_index).nrdconta || ' ' ||
                                           vr_tab_dados_titulos(vr_index).nrcnvcob || ' ' || 
                                           vr_tab_dados_titulos(vr_index).nrdocmto);
              vr_inseriu := true;
            END IF;
            vr_index  := vr_tab_dados_titulos.next(vr_index);
        END   LOOP;

           UPDATE
              crapbdt
           SET
              crapbdt.insitbdt = 1, --Em Estudo
              crapbdt.insitapr = 0,
              crapbdt.dtenvmch = NULL,
              crapbdt.nrseqtdb = vr_idtabtitulo,
              crapbdt.dtanabor = NULL, -- Limpa a data de analise, pois necessita nova analise
              crapbdt.cdoperad = vr_cdoperad
           WHERE
              crapbdt.nrborder = pr_nrborder
              AND crapbdt.cdcooper = vr_cdcooper
              AND crapbdt.nrdconta = pr_nrdconta
           ;

       

        -- Se encontrar
        open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        fetch btch0001.cr_crapdat into rw_crapdat;
        IF BTCH0001.cr_crapdat%FOUND THEN
          vr_dtmvtopr:= rw_crapdat.dtmvtopr;
        END IF;
        CLOSE btch0001.cr_crapdat;  
        
        
        ESTE0006.pc_interrompe_proposta_bdt_est(pr_cdcooper => vr_cdcooper,
                                                 pr_cdagenci => vr_cdagenci,
                                                 pr_cdoperad => vr_cdoperad,
                                                 pr_cdorigem => vr_idorigem,
                                                 pr_nrdconta => pr_nrdconta,
                                                 pr_nrborder => pr_nrborder,
                                                 pr_dtmvtolt => vr_dtmvtolt,
                                                 pr_cdcritic => vr_cdcritic,
                                                 pr_dscritic => vr_dscritic);
                                                 
        IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic is NOT null then
          /* buscar a descriçao */
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          raise vr_exc_erro;
        end if;
        
        DSCT0003.pc_efetua_analise_bordero (pr_cdcooper => vr_cdcooper
                                        ,pr_cdagenci => vr_cdagenci
                                        ,pr_nrdcaixa => vr_nrdcaixa
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_nmdatela => vr_nmdatela
                                        ,pr_idorigem => vr_idorigem
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_dtmvtolt => vr_dtmvtolt
                                        ,pr_dtmvtopr => vr_dtmvtopr
                                        ,pr_inproces => 0
                                        ,pr_nrborder => pr_nrborder
                                        ,pr_inrotina => 1
                                        ,pr_flgerlog => FALSE
                                        ,pr_insborde => 1
                                        --------> OUT <--------
                                        ,pr_indrestr => vr_indrestr --> Indica se Gerou Restrição (0 - Sem Restrição / 1 - Com restrição)
                                        ,pr_ind_inpeditivo => vr_ind_inpeditivo  --> Indica se o Resultado é Impeditivo para Realizar Liberação. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                        ,pr_tab_erro => vr_tab_erro --  OUT GENE0001.typ_tab_erro --> Tabela Erros
                                        ,pr_tab_retorno_analise => vr_tab_retorno_analise --OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                        ,pr_cdcritic => vr_cdcritic          --> Código da crítica
                                        ,pr_dscritic => vr_dscritic             --> Descriçao da crítica
                                      );

        IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic is NOT null then
          /* buscar a descriçao */
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;

        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Dados><inf>Borderô n' || pr_nrborder || ' alterado com sucesso.</inf></Dados></Root>');

      exception
        when vr_exc_erro then
             /*  se foi retornado apenas código */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descriçao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        when others then
             /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_altera_bordero ' ||sqlerrm;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
             pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            ROLLBACK;
    END pc_altera_bordero ;

    PROCEDURE pc_resgate_titulo_bordero_web (pr_nrctrlim   IN crapbdt.nrctrlim%TYPE  --> Numero do contrato
                                       ,pr_nrdconta    IN crapbdt.nrdconta%TYPE  --> Numero da conta
                                       ,pr_dtmvtolt    IN VARCHAR2  --> Data Movimento
                                       ,pr_dtmvtoan    IN VARCHAR2  --> Data anterior do movimento
                                       ,pr_dtresgat    IN VARCHAR2  --> Data do resgate
                                       ,pr_inproces    IN crapdat.inproces%TYPE  --> Indicador processo
                                       ,pr_chave       in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                       ,pr_xmllog      in varchar2              --> xml com informações de log
                                       --------> out <--------
                                       ,pr_cdcritic out pls_integer             --> código da crítica
                                       ,pr_dscritic out varchar2                --> descrição da crítica
                                       ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                       ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                       ,pr_des_erro out varchar2                --> erros do processo
                                       ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_resgate_titulo_bordero_web
      Sistema  : Ayllos
      Sigla    : TELA_ATENDA_DSCTO_TIT
      Autor    : Luis Fernando (GFT)
      Data     : Abril/2018

      Objetivo  : Procedure para os resgates dos títulos chamada pelo Ayllos WEB
      Alterações:
         - 13/08/2018 - Vitor Shimada Assanuma (GFT) - Remoção da verificação do contrato ativo.
    ---------------------------------------------------------------------------------------------------------------------*/
                                       

       -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro

       vr_dtmvtolt     DATE;
       vr_dtmvtoan     DATE;
       vr_dtresgat     DATE;
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
      
      -- Tratamento de erros
      vr_exc_erro exception;
     
      vr_nrborder crapbdt.nrborder%TYPE;
      
      /*Cooperado*/
      CURSOR cr_crapass IS
         SELECT
            crapass.inpessoa
         FROM
            crapass
         WHERE
            crapass.nrdconta = pr_nrdconta
            AND crapass.cdcooper = vr_cdcooper;
      rw_crapass cr_crapass%rowtype;
        
      /*Linha de crédito*/
      
      /*CURSOR do bordero sendo alterado*/
      CURSOR cr_crapbdt IS
         SELECT
             *
         FROM
             crapbdt
         WHERE
             crapbdt.nrborder = vr_nrborder
             AND crapbdt.cdcooper = vr_cdcooper
             AND crapbdt.nrdconta = pr_nrdconta;
      rw_crapbdt cr_crapbdt%ROWTYPE;
      
      /*Títulos sendo resgatados*/ 
      vr_tab_titulos         PAGA0001.typ_tab_titulos;
      vr_tab_dados_titulos typ_tab_dados_titulos;

      vr_idtabtitulo INTEGER;
      vr_tab_cobs  gene0002.typ_split;
      vr_tab_chaves  gene0002.typ_split;
      vr_index     INTEGER;
      
      /*Busca os titulos do bordero ja inclusos e retesta*/      
      CURSOR cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE, pr_nrdctabb IN crapcob.nrdctabb%TYPE, pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
        select
          cob.cdbandoc,
          cob.nrcnvcob,
          cob.nrdconta,
          cob.nrdocmto,
          tdb.vltitulo,
          cob.flgregis,
          tdb.dtvencto,
          tdb.insittit,
          tdb.nrborder,
          cob.nrdctabb
        from   crapcob cob
          INNER JOIN craptdb  tdb ON cob.cdcooper = tdb.cdcooper AND
                                                         cob.cdbandoc = tdb.cdbandoc AND
                                                         cob.nrdctabb = tdb.nrdctabb AND
                                                         cob.nrdconta = tdb.nrdconta AND
                                                         cob.nrcnvcob = tdb.nrcnvcob AND
                                                         cob.nrdocmto = tdb.nrdocmto
        where
          cob.nrdconta = pr_nrdconta
          and    cob.cdcooper = vr_cdcooper
          AND    cob.nrcnvcob = pr_nrcnvcob
          AND    cob.cdbandoc = pr_cdbandoc
          AND    cob.nrdctabb = pr_nrdctabb
          AND    cob.nrdocmto = pr_nrdocmto
          and    tdb.insittit = 4 ;
          
         rw_crapcob cr_crapcob%rowtype;

      BEGIN                 
         pr_des_erro := 'OK';     
         pr_nmdcampo := NULL;           
         gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                 ,pr_cdcooper => vr_cdcooper
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_nmeacao  => vr_nmeacao
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
                                          
         OPEN cr_crapass;
         FETCH cr_crapass INTO rw_crapass;
         IF (cr_crapass%NOTFOUND) THEN
            CLOSE cr_crapass;
            vr_dscritic := 'Cooperado não cadastrado';
            raise vr_exc_erro;
         END IF;

         
         --lista todos os boleto a serem resgatados
                     
         vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
         vr_dtmvtoan := to_date(pr_dtmvtoan, 'DD/MM/RRRR');
         vr_dtresgat := to_date(pr_dtresgat, 'DD/MM/RRRR');
         
         
       vr_tab_cobs := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                 pr_delimit => ',');
                                                 
       vr_idtabtitulo:=0;
       IF vr_tab_cobs.count() > 0 THEN
         /*Traz 1 linha para cada cobrança sendo selecionada*/
         vr_index := vr_tab_cobs.first;
         while vr_index is not null loop
           -- Pega a lsita de chaves por titulo
           vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => vr_tab_cobs(vr_index),
                                                 pr_delimit => ';');
           IF (vr_tab_chaves.count() > 0) THEN
             open cr_crapcob (vr_tab_chaves(4), -- Conta
                              vr_tab_chaves(3), -- Convenio
                              vr_tab_chaves(2), -- Conta base do banco
                              vr_tab_chaves(1)  -- Codigo do banco
                              );
             fetch cr_crapcob INTO rw_crapcob;
             IF (cr_crapcob%FOUND) THEN
               vr_tab_dados_titulos(vr_idtabtitulo).nrdconta := rw_crapcob.nrdconta;
               vr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob := rw_crapcob.nrcnvcob;
               vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto := rw_crapcob.nrdocmto;
               vr_tab_dados_titulos(vr_idtabtitulo).vltitulo := rw_crapcob.vltitulo;
               vr_tab_dados_titulos(vr_idtabtitulo).cdbandoc := rw_crapcob.cdbandoc;
               vr_tab_dados_titulos(vr_idtabtitulo).nrdctabb := rw_crapcob.nrdctabb;
               vr_tab_dados_titulos(vr_idtabtitulo).nrborder := rw_crapcob.nrborder;
               
               IF (vr_tab_dados_titulos(vr_idtabtitulo).dtvencto<vr_dtmvtolt) THEN
                 vr_dscritic := 'Título ' || vr_tab_dados_titulos(0).nrdocmto || ' está vencido ';
                 raise vr_exc_erro;
               END IF;
               IF (vr_tab_dados_titulos(vr_idtabtitulo).insittit<>4) THEN
                 vr_dscritic := 'Título ' || vr_tab_dados_titulos(0).nrdocmto || ' não está liberado ';
                 raise vr_exc_erro; 
               END IF;
               /*Carrega o bordero do titulo selecionado*/
               vr_nrborder := vr_tab_dados_titulos(vr_idtabtitulo).nrborder;
               OPEN cr_crapbdt;
               FETCH cr_crapbdt INTO rw_crapbdt;
               IF (cr_crapbdt%NOTFOUND) THEN
                  CLOSE cr_crapbdt;
                  vr_dscritic := 'Borderô ' || vr_nrborder || ' não cadastrado';
                  raise vr_exc_erro;
               END IF;
               close cr_crapbdt;
                 
               vr_tab_titulos(1).cdbandoc := vr_tab_dados_titulos(vr_idtabtitulo).cdbandoc;
               vr_tab_titulos(1).nrcnvcob := vr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob;
               vr_tab_titulos(1).nrdctabb := vr_tab_dados_titulos(vr_idtabtitulo).nrdctabb;
               vr_tab_titulos(1).nrdconta := vr_tab_dados_titulos(vr_idtabtitulo).nrdconta;
               vr_tab_titulos(1).nrdocmto := vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto;
               vr_tab_titulos(1).vltitulo := vr_tab_dados_titulos(vr_idtabtitulo).vltitulo;
               vr_tab_titulos(1).flgregis := vr_tab_dados_titulos(vr_idtabtitulo).flgregis = 1;
                 
               --> Efetuar resgate de titulos de um determinado bordero 
               DSCT0001.pc_efetua_resgate_tit_bord ( pr_cdcooper    => vr_cdcooper  --> Codigo Cooperativa
                                                     ,pr_cdagenci    => rw_crapbdt.cdagenci        --> Codigo Agencia do bordero de desconto
                                                     ,pr_nrdcaixa    => vr_nrdcaixa                        --> Numero Caixa
                                                     ,pr_cdoperad    => vr_cdoperad                --> Codigo operador
                                                     ,pr_dtmvtolt    => rw_crapbdt.dtmvtolt        --> Data Movimento do bordero de desconto
                                                     ,pr_dtmvtoan    => vr_dtmvtoan        --> Data anterior do movimento
                                                     ,pr_inproces    => pr_inproces        --> Indicador processo
                                                     ,pr_dtresgat    => vr_dtresgat        --> Data do resgate
                                                     ,pr_idorigem    => vr_idorigem        --> Identificador Origem pagamento
                                                     ,pr_nrdconta    => pr_nrdconta        --> Numero da conta
                                                     ,pr_cdbccxlt    => rw_crapbdt.cdbccxlt        --> codigo do banco
                                                     ,pr_nrdolote    => rw_crapbdt.nrdolote        --> Numero do lote do bordero de desconto                                       
                                                     ,pr_tab_titulos => vr_tab_titulos             --> Titulos a serem resgatados
                                                     ---- OUT ----
                                                     ,pr_cdcritic    => vr_cdcritic                --> Codigo Critica
                                                     ,pr_dscritic    => vr_dscritic                --> Descricao Critica
                                                     );
               IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                  RAISE vr_exc_erro;
               END IF;
             END IF;
             close cr_crapcob;
           END IF;
           vr_index := vr_tab_cobs.next(vr_index);
         end loop;
       END IF;
       pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                                   '<Root><Dados>Títulos resgatados com sucesso</Dados></Root>');
       exception
           when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       when others then
            /* montar descriçao de erro nao tratado */
            pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_resgate_titulo_bordero_web ' ||sqlerrm;
            pr_des_erro := 'NOK';
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_resgate_titulo_bordero_web;
    
    PROCEDURE pc_buscar_titulos_resgate (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data da Movimentação
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN crapcob.dtvencto%TYPE  --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Borderô
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) IS
      /* ------------------------------------------------------------------------------------------------------------------
      *   Alterações
      * -------------------------------------------------------------------------------------------------------------------
      *   13/08/2018 - Vitor Shimada Assanuma - Retirada a regra de número de contrato de limite na pesquisa.
      --------------------------------------------------------------------------------------------------------------------- */
      
      -- Variável de críticas
      vr_dscritic    VARCHAR2(1000);        --> Desc. Erro
      vr_dtvencto    DATE;
      vr_idtabtitulo PLS_INTEGER;
      
      -- Tratamento de erros
      vr_exc_erro exception;
      
      --CURSOR dos titulos que podem ser resgatados conforme o filtro
      CURSOR cr_craptdb IS
        SELECT cob.progress_recid, -- numero sequencial do titulo (verificar a utilidade
             cob.cdcooper,
             cob.nrdconta,
             cob.nrctremp, -- numero do contrato de limite.
             cob.nrcnvcob, -- convênio
             cob.nrdocmto, -- nr. boleto
             cob.nrinssac, -- cpf/cnpj do Pagador (Antigo SACADO)
             sab.nmdsacad, -- nome do pagador (o campo NMDSACAD da crapcob não está preenchido...)
             cob.dtvencto, -- data de vencimento
             cob.dtmvtolt, -- data de movimento
             cob.vltitulo,  -- valor do título
             cob.nrnosnum, -- nosso numero 
             cob.flgregis, -- flag registrado.
             cob.cdtpinsc,  -- Codigo do tipo da inscricao do sacado(0-nenhum/1-CPF/2-CNPJ)
             tdb.nrborder,   -- Número do Borderô
             cob.cdbandoc,
             cob.nrdctabb
        FROM crapcob cob -- titulos
             INNER JOIN crapsab sab ON sab.nrinssac = cob.nrinssac
								   AND sab.cdcooper = cob.cdcooper
								   AND sab.nrdconta = cob.nrdconta
             INNER JOIN craptdb tdb ON cob.cdcooper = tdb.cdcooper AND
                                                    cob.cdbandoc = tdb.cdbandoc AND
                                                    cob.nrdctabb = tdb.nrdctabb AND
                                                    cob.nrdconta = tdb.nrdconta AND
                                                    cob.nrcnvcob = tdb.nrcnvcob AND
                                                    cob.nrdocmto = tdb.nrdocmto
             INNER JOIN crapbdt bdt ON bdt.cdcooper=tdb.cdcooper AND bdt.nrdconta=tdb.nrdconta AND bdt.nrborder=tdb.nrborder
        -- Regras Fixas
        WHERE cob.nrdconta = pr_nrdconta
         AND cob.cdcooper = pr_cdcooper
         AND cob.flgregis > 0 -- Indicador de Registro CIP (0-Sem registro CIP/ 1-Registro Online/ 2-Registro offline)
         -- Filtros Variáveis - Tela
         AND (cob.nrinssac = pr_nrinssac OR nvl(pr_nrinssac,0)=0)
         AND (cob.vltitulo = pr_vltitulo OR nvl(pr_vltitulo,0)=0)
         AND (cob.dtvencto = vr_dtvencto OR vr_dtvencto IS NULL)
         AND (cob.nrnosnum LIKE '%'||pr_nrnosnum||'%' OR nvl(pr_nrnosnum,0)=0) -- o campo correto para "Nosso Número"
         AND (tdb.nrborder = pr_nrborder OR nvl(pr_nrborder,0)=0)
         AND tdb.insittit = 4
         AND bdt.insitbdt = 3
         AND tdb.dtvencto > pr_dtmvtolt
--         AND tdb.nrctrlim = pr_nrctrlim
       GROUP BY
         cob.progress_recid,
         cob.cdcooper,
         cob.nrdconta,
         cob.nrctremp,
         cob.nrcnvcob,
         cob.nrdocmto,
         cob.nrinssac,
         sab.nmdsacad,
         cob.dtvencto,
         cob.dtmvtolt,
         cob.vltitulo,
         cob.nrnosnum,
         cob.flgregis,
         cob.cdtpinsc,
         tdb.nrborder,
         cob.cdbandoc,
         cob.nrdctabb;
         rw_craptdb cr_craptdb%ROWTYPE;
      
      BEGIN
        vr_dtvencto := null;
        IF (pr_dtvencto IS NOT NULL ) THEN
           vr_dtvencto := pr_dtvencto;
           -- Caso a data de vencimento colocada seja menor a data atual -48h
           IF (vr_dtvencto - 2) <= pr_dtmvtolt THEN
             vr_dscritic := 'Operação não permitida. Prazo para resgate excedido.';
             RAISE vr_exc_erro;
        END IF;
        END IF;
        
        pr_qtregist := 0;
        -- abrindo cursos de títulos
        OPEN cr_craptdb;
        LOOP
          FETCH cr_craptdb INTO rw_craptdb;
          EXIT WHEN cr_craptdb%NOTFOUND;
              pr_qtregist := pr_qtregist+1;
              vr_idtabtitulo := pr_tab_dados_titulos.count + 1;
              pr_tab_dados_titulos(vr_idtabtitulo).progress_recid := rw_craptdb.progress_recid;
              pr_tab_dados_titulos(vr_idtabtitulo).cdcooper       := rw_craptdb.cdcooper;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdconta       := rw_craptdb.nrdconta;
              pr_tab_dados_titulos(vr_idtabtitulo).nrctremp       := rw_craptdb.nrctremp;
              pr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob       := rw_craptdb.nrcnvcob;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdocmto       := rw_craptdb.nrdocmto;
              pr_tab_dados_titulos(vr_idtabtitulo).nrinssac       := rw_craptdb.nrinssac;
              pr_tab_dados_titulos(vr_idtabtitulo).nmdsacad       := rw_craptdb.nmdsacad;
              pr_tab_dados_titulos(vr_idtabtitulo).dtvencto       := rw_craptdb.dtvencto;
              pr_tab_dados_titulos(vr_idtabtitulo).vltitulo       := rw_craptdb.vltitulo;
              pr_tab_dados_titulos(vr_idtabtitulo).nrnosnum       := rw_craptdb.nrnosnum;
              pr_tab_dados_titulos(vr_idtabtitulo).flgregis       := rw_craptdb.flgregis;
              pr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc       := rw_craptdb.cdtpinsc;
              pr_tab_dados_titulos(vr_idtabtitulo).nrborder       := rw_craptdb.nrborder;
              pr_tab_dados_titulos(vr_idtabtitulo).cdbandoc       := rw_craptdb.cdbandoc;
              pr_tab_dados_titulos(vr_idtabtitulo).nrdctabb       := rw_craptdb.nrdctabb;
        END LOOP;

      EXCEPTION
        WHEN vr_exc_erro THEN
           pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_resgate ' ||SQLERRM;                              
    END pc_buscar_titulos_resgate;
    
    PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Borderô
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS

    -- variaveis de retorno
    vr_tab_dados_titulos typ_tab_dados_titulos;

    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_qtregist         number;
    vr_dtmvtolt DATE;
    vr_dtvencto DATE;
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');

      vr_dtvencto := null;
      IF pr_dtvencto IS NOT NULL THEN
        vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
      END IF;

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

      pc_buscar_titulos_resgate(vr_cdcooper  --> Código da Cooperativa
                       ,pr_nrdconta --> Número da Conta
                       ,vr_cdagenci --> Agencia de operação
                       ,vr_nrdcaixa --> Número do caixa
                       ,vr_cdoperad --> Operador
                       ,vr_dtmvtolt --> Data da Movimentação
                       ,vr_idorigem --> Identificação de origem
                       ,pr_nrinssac --> Filtro de Inscricao do Pagador
                       ,pr_vltitulo --> Filtro de Valor do titulo
                       ,vr_dtvencto --> Filtro de Data de vencimento
                       ,pr_nrnosnum --> Filtro de Nosso Numero
                       ,pr_nrctrlim --> Contrato
                       ,pr_nrborder --> Borderô
                       ,pr_insitlim --> Status
                       ,pr_tpctrlim --> Tipo de desconto
                       --------> OUT <--------
                       ,vr_qtregist --> Quantidade de registros encontrados
                       ,vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                       ,vr_cdcritic --> Código da crítica
                       ,vr_dscritic --> Descrição da crítica
                       );
      
      -- Caso tenha alguma crítica
      IF (nvl(vr_cdcritic,0) > 0) OR (vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');
                     
      -- ler os registros de titulos e incluir no xml
      vr_index := vr_tab_dados_titulos.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<progress_recid>' || vr_tab_dados_titulos(vr_index).progress_recid || '</progress_recid>' ||
                              '<cdcooper>' || vr_tab_dados_titulos(vr_index).cdcooper || '</cdcooper>' ||
                              '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titulos(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                              '<nrctremp>' || vr_tab_dados_titulos(vr_index).nrctremp || '</nrctremp>' ||
                              '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                              '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                              '<nrinssac>' || vr_tab_dados_titulos(vr_index).nrinssac || '</nrinssac>' ||
                              '<nmdsacad>' || htf.escape_sc(vr_tab_dados_titulos(vr_index).nmdsacad) || '</nmdsacad>' ||
                              '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                              '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                              '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                              '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                              '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                              '<nrborder>' || vr_tab_dados_titulos(vr_index).nrborder || '</nrborder>' || 
                              '<cdbandoc>' || vr_tab_dados_titulos(vr_index).cdbandoc || '</cdbandoc>' || 
                              '<nrdctabb>' || vr_tab_dados_titulos(vr_index).nrdctabb || '</nrdctabb>' ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_titulos.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_resgate_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_titulos_resgate_web;
    
    PROCEDURE pc_titulos_resumo_resgatar_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS

      -- variaveis de retorno
      vr_tab_dados_titulos typ_tab_dados_titulos;

      /* tratamento de erro */
      vr_exc_erro exception;
    
      vr_qtregist         number;
      
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
     
      -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
      BEGIN
        pr_des_erro := 'OK';
        pr_nmdcampo := NULL;
        gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                                , pr_cdcooper => vr_cdcooper
                                , pr_nmdatela => vr_nmdatela
                                , pr_nmeacao  => vr_nmeacao
                                , pr_cdagenci => vr_cdagenci
                                , pr_nrdcaixa => vr_nrdcaixa
                                , pr_idorigem => vr_idorigem
                                , pr_cdoperad => vr_cdoperad
                                , pr_dscritic => vr_dscritic);

        pc_listar_titulos_resumo(pr_cdcooper => vr_cdcooper --> Cooperativa
                         ,pr_nrdconta => pr_nrdconta --> Número da Conta
                         ,pr_chave => pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                         --------> OUT <--------
                         ,pr_qtregist => vr_qtregist --> Quantidade de registros encontrados
                         ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                         ,pr_cdcritic => vr_cdcritic --> Código da crítica
                         ,pr_dscritic => vr_dscritic --> Descrição da crítica
                         );
        
        -- inicializar o clob
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- inicilizar as informaçoes do xml
        vr_texto_completo := null;
        
        pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                       '<root><dados qtregist="' || vr_qtregist ||'" >');
                       
        -- ler os registros de titulos e incluir no xml
        vr_index := vr_tab_dados_titulos.first;
        while vr_index is not null loop
              pc_escreve_xml('<inf>'||
                                '<progress_recid>' || vr_tab_dados_titulos(vr_index).progress_recid || '</progress_recid>' ||
                                '<cdcooper>' || vr_tab_dados_titulos(vr_index).cdcooper || '</cdcooper>' ||
                                '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titulos(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                                '<nrctremp>' || vr_tab_dados_titulos(vr_index).nrctremp || '</nrctremp>' ||
                                '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                                '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                                '<nrinssac>' || vr_tab_dados_titulos(vr_index).nrinssac || '</nrinssac>' ||
                                '<nmdsacad>' || htf.escape_sc(vr_tab_dados_titulos(vr_index).nmdsacad) || '</nmdsacad>' ||
                                '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                                '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                                '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                                '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                                '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                                '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                                '<nrborder>' || vr_tab_dados_titulos(vr_index).nrborder || '</nrborder>' || 
                                '<dtlibbdt>' || to_char(vr_tab_dados_titulos(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||  
                                '<cdbandoc>' || vr_tab_dados_titulos(vr_index).cdbandoc || '</cdbandoc>' ||
                                '<nrdctabb>' || vr_tab_dados_titulos(vr_index).nrdctabb || '</nrdctabb>' ||
                             '</inf>'
                            );
            /* buscar proximo */
            vr_index := vr_tab_dados_titulos.next(vr_index);
        end loop;
        pc_escreve_xml ('</dados></root>',true);
        pr_retxml := xmltype.createxml(vr_des_xml);

        /* liberando a memória alocada pro clob */
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      exception
        when vr_exc_erro then
             /*  se foi retornado apenas código */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descriçao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_titulos_resumo_resgatar_web ' ||sqlerrm;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_titulos_resumo_resgatar_web;

    PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                                 ,pr_cdcooper IN crapbdt.cdcooper%TYPE
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                                     --------> OUT <--------
                                 ,pr_qtregist OUT INTEGER
                                 ,pr_tab_borderos   out  typ_tab_borderos --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_borderos
      Sistema  : Cred
      Sigla    : TELA_ATENDA_DSCTO_TIT
      Autor    : Alex Sandro (GFT) /
      Data     : Abril/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que lista os borderos
    ---------------------------------------------------------------------------------------------------------------------*/

      vr_dt_aux_dtmvtolt DATE;
      vr_dt_aux_dtlibbdt DATE;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
      vr_dscritic varchar2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_erro exception;


      vr_idxbordero PLS_INTEGER;

      vr_qt_titulo NUMBER;
      vr_vl_titulo NUMBER;

      vr_qt_apr NUMBER;
      vr_vl_apr NUMBER;

      ---------->>> CURSORES <<<----------
      --> Buscar bordero de desconto de titulo
      CURSOR cr_crapbdt IS
       SELECT BDT.DTMVTOLT,
       BDT.NRDCONTA,
       BDT.NRCTRLIM,
       BDT.INSITBDT,
       BDT.DTLIBBDT,
       BDT.NRBORDER,
       BDT.CDCOOPER,
       BDT.INSITAPR,
       BDT.DTULTPAG,
       BDT.DTLIQPRJ,

       CASE BDT.INSITBDT WHEN 1 THEN 'EM ESTUDO'
                         WHEN 2 THEN 'ANALISADO'
                         WHEN 3 THEN 'LIBERADO'
                         WHEN 4 THEN 'LIQUIDADO'
                         WHEN 5 THEN 'REJEITADO'
                         ELSE        'PROBLEMA'
       END DSSITBDT,
       COUNT(1) over() qtregistro,
       --  0-Aguardando Análise, 1-Aguardando Checagem, 2-Checagem, 3-Aprovado Automaticamente, 4-Aprovado, 5-Não aprovado, 6-Enviado Esteira, 7-Prazo expirado';
       CASE BDT.INSITAPR WHEN 0 THEN 'AGUARDANDO ANALISE'
                         WHEN 1 THEN 'AGUARDANDO CHECAGEM'
                         WHEN 2 THEN 'CHECAGEM'
                         WHEN 3 THEN 'APROVADO AUTOMATICAMENTE'
                         WHEN 4 THEN 'APROVADO'
                         WHEN 5 THEN 'NAO APROVADO'
                         WHEN 6 THEN 'ENVIADO ESTEIRA'
                         WHEN 7 THEN 'PRAZO EXPIRADO'
                         ELSE        'PROBLEMA'
       END DSINSITAPR,
       BDT.INPREJUZ
       FROM CRAPBDT BDT
       WHERE
       BDT.CDCOOPER = pr_cdcooper
       AND BDT.NRDCONTA = pr_nrdconta
       ORDER BY NRBORDER DESC;
      rw_crapbdt cr_crapbdt%ROWTYPE;


      -- Buscar os títulos
      CURSOR cr_craptdb(pr_cdcooper craptdb.cdcooper%TYPE
                     ,pr_nrdconta craptdb.nrdconta%TYPE
                     ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT --craptdb.cdbanchq,
             craptdb.vltitulo,
             craptdb.insitapr
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrborder = pr_nrborder;

      BEGIN

        -- Incluir nome do modulo logado
        GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);

        pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursor


        vr_dt_aux_dtmvtolt := pr_dtmvtolt - 120;
        vr_dt_aux_dtlibbdt := pr_dtmvtolt - 60;

        -- abrindo cursos de títulos
        OPEN  cr_crapbdt;
        LOOP
               FETCH cr_crapbdt INTO rw_crapbdt;
               EXIT  WHEN cr_crapbdt%NOTFOUND;


               pr_qtregist := pr_qtregist + 1;
               vr_idxbordero := pr_tab_borderos.count + 1;

                IF (rw_crapbdt.dtmvtolt <= vr_dt_aux_dtmvtolt AND ( rw_crapbdt.insitbdt IN(1,2))) THEN
                  CONTINUE;
                END IF;


               IF (rw_crapbdt.dtlibbdt is not null and (rw_crapbdt.dtultpag <= vr_dt_aux_dtlibbdt OR rw_crapbdt.dtliqprj <= vr_dt_aux_dtlibbdt) AND ( rw_crapbdt.insitbdt IN(4))) THEN
                  CONTINUE;
               END IF;

               -- Reseta os valores
               vr_qt_titulo := 0;
               vr_vl_titulo := 0;

               vr_qt_apr := 0;
               vr_vl_apr := 0;


               -- Buscar os titulos
               FOR rw_craptdb IN cr_craptdb(pr_cdcooper => rw_crapbdt.cdcooper
                                            ,pr_nrdconta => rw_crapbdt.nrdconta
                                            ,pr_nrborder => rw_crapbdt.nrborder) LOOP

                    vr_qt_titulo := vr_qt_titulo + 1;
                    vr_vl_titulo := vr_vl_titulo + rw_craptdb.vltitulo;

                    IF(rw_craptdb.insitapr = 1)THEN
                        vr_qt_apr := vr_qt_apr + 1;
                        vr_vl_apr := vr_vl_apr + rw_craptdb.vltitulo;
                    END IF;

               END LOOP;


               pr_tab_borderos(vr_idxbordero).dtmvtolt := rw_crapbdt.dtmvtolt;
               pr_tab_borderos(vr_idxbordero).nrborder := rw_crapbdt.nrborder;
               pr_tab_borderos(vr_idxbordero).nrdconta := rw_crapbdt.nrdconta;
               pr_tab_borderos(vr_idxbordero).nrctrlim := rw_crapbdt.nrctrlim;
               pr_tab_borderos(vr_idxbordero).dssitbdt := rw_crapbdt.dssitbdt;
               pr_tab_borderos(vr_idxbordero).aux_qttottit := vr_qt_titulo;
               pr_tab_borderos(vr_idxbordero).aux_vltottit := vr_vl_titulo;
               pr_tab_borderos(vr_idxbordero).aux_qtsitapr := vr_qt_apr;
               pr_tab_borderos(vr_idxbordero).aux_vlsitapr := vr_vl_apr;
               pr_tab_borderos(vr_idxbordero).dtlibbdt := rw_crapbdt.dtlibbdt;
               pr_tab_borderos(vr_idxbordero).dsinsitapr :=  rw_crapbdt.dsinsitapr;
               pr_tab_borderos(vr_idxbordero).inprejuz   :=  rw_crapbdt.inprejuz;


        END LOOP;
        CLOSE  cr_crapbdt;

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_borderos ' ||sqlerrm;
    END pc_busca_borderos;




    PROCEDURE pc_busca_borderos_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  ) IS


    vr_tab_borderos  typ_tab_borderos;          --> retorna dos dados
    vr_index pls_integer;
    vr_dtmvtolt      crapdat.dtmvtolt%TYPE;


    /* tratamento de erro */
    vr_exc_erro exception;

    vr_qtregist         number;

    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);


    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro


    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');

      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

       pc_busca_borderos (pr_nrdconta,
                          vr_cdcooper,
                          vr_dtmvtolt,
                          ----OUT----
                          vr_qtregist,
                          vr_tab_borderos,
                          vr_cdcritic,
                          vr_dscritic
                          );

      IF (nvl(vr_cdcritic,0) <> 0 OR  vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
      END IF;
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');


      -- ler os registros de titulos e incluir no xml


      vr_index := vr_tab_borderos.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<dtmvtolt>'     || TO_CHAR(vr_tab_borderos(vr_index).dtmvtolt, 'DD/MM/RRRR')   || '</dtmvtolt>' ||
                              '<nrborder>'     || vr_tab_borderos(vr_index).nrborder                          || '</nrborder>'          ||
                              '<nrctrlim>'     || vr_tab_borderos(vr_index).nrctrlim                          || '</nrctrlim>' ||

                              '<aux_qttottit>' || vr_tab_borderos(vr_index).aux_qttottit                      || '</aux_qttottit>' ||
                              '<aux_vltottit>' || vr_tab_borderos(vr_index).aux_vltottit                      || '</aux_vltottit>' ||

                              '<aux_qtsitapr>' || vr_tab_borderos(vr_index).aux_qtsitapr                      || '</aux_qtsitapr>' ||
                              '<aux_vlsitapr>' || vr_tab_borderos(vr_index).aux_vlsitapr                      || '</aux_vlsitapr>' ||

                              '<dssitbdt>'     || vr_tab_borderos(vr_index).dssitbdt                          || '</dssitbdt>' ||
                              '<dsinsitapr>'   || vr_tab_borderos(vr_index).dsinsitapr                        || '</dsinsitapr>'  ||
                              '<dtlibbdt>'     || TO_CHAR(vr_tab_borderos(vr_index).dtlibbdt, 'DD/MM/RRRR')   || '</dtlibbdt>'  ||
                              '<inprejuz>'     || vr_tab_borderos(vr_index).inprejuz                          || '</inprejuz>'  ||

                           '</inf>'
            );
            vr_index := vr_tab_borderos.next(vr_index);
      end loop;

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas código */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descriçao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_borderos_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_busca_borderos_web;
    
  PROCEDURE pc_contingencia_ibratan_web(pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_contingencia_ibratan_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018    

    Objetivo  : Procedure para retornar se a esteira e o motor de crédito estão em contingencia

    Alteração :

  ---------------------------------------------------------------------------------------------------------------------*/

  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000);        --> Desc. Erro
  vr_dsmensag VARCHAR2(10000);

  -- Tratamento de erros
  vr_exc_erro EXCEPTION;

  -- variaveis de entrada vindas no xml
  vr_cdcooper INTEGER;
  vr_cdoperad VARCHAR2(100);
  vr_nmdatela VARCHAR2(100);
  vr_nmeacao  VARCHAR2(100);
  vr_cdagenci VARCHAR2(100);
  vr_nrdcaixa VARCHAR2(100);
  vr_idorigem VARCHAR2(100);

  vr_flctgest BOOLEAN; --se a esteira esta em contingencia
  vr_flctgmot BOOLEAN; --se o motor esta em contingencia

  BEGIN
    pr_des_erro := 'OK';
    pr_nmdcampo := NULL;
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
     
    ESTE0003.pc_verifica_contigenc_esteira(pr_cdcooper=>vr_cdcooper,
                                           pr_flctgest=>vr_flctgest,
                                           pr_dsmensag=>vr_dsmensag,
                                           pr_dscritic=>vr_dscritic);

    IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    ESTE0003.pc_verifica_contigenc_motor(pr_cdcooper=>vr_cdcooper,
                                           pr_flctgmot=>vr_flctgmot,
                                           pr_dsmensag=>vr_dsmensag,
                                           pr_dscritic=>vr_dscritic);
                                           
    IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
    END IF;
    
    vr_des_xml        := null;
    vr_texto_completo := NULL;
    
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                   '<Dados>');
                   pc_escreve_xml('<flctgest>'|| CASE WHEN vr_flctgest THEN 1 ELSE 0 END || '</flctgest>'||
                                  '<flctgmot>'|| CASE WHEN vr_flctgmot THEN 1 ELSE 0 END || '</flctgmot>');
    pc_escreve_xml ('</Dados></Root>',true);
    pr_retxml := xmltype.createxml(vr_des_xml);

    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         pr_des_erro := 'NOK';
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_contingencia_ibratan_web ' ||sqlerrm;
         pr_des_erro := 'NOK';
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
         ROLLBACK;
  END pc_contingencia_ibratan_web ;

  PROCEDURE pc_busca_dados_titulo(pr_cdcooper     IN craptdb.cdcooper%TYPE
                                 ,pr_nrdconta     IN crapass.nrdconta%TYPE --> conta do associado
                                 ,pr_nrborder     IN crapbdt.nrborder%TYPE --> numero do bordero
                                 ,pr_chave        IN VARCHAR2              --> lista de 'nosso numero' a ser pesquisado
                                 ,pr_tab_titulo   OUT  typ_tab_titulo --> Tabela de retorno
                                 ,pr_cdcritic     OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic     OUT VARCHAR2              --> Descrição da crítica
                                 ) IS 
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_titulo
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 14/08/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Listar as informações de um título
      Alterações:
        - 04/09/2018 - Vitor Shimada Assanuma (GFT) - Fix dos dias de atraso
        - 15/10/2018 - Vitor Shimada Assanuma (GFT) - Valor pago somando as multa, mora e IOF
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro exception;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> cód. erro
    vr_dscritic varchar2(1000);        --> desc. erro
    
    -- Variavel para guardar a chave quebrada
    vr_tab_chave  gene0002.typ_split;
    
    -- Cursor de data
    rw_crapdat  btch0001.rw_crapdat%TYPE;
    
    -- Cursor do título
    CURSOR cr_craptdb (pr_nrdocmto IN craptdb.nrdocmto%TYPE, 
                       pr_nrcnvcob IN craptdb.nrcnvcob%TYPE,
                       pr_nrdctabb IN craptdb.nrdctabb%TYPE,
                       pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
      SELECT 
        (tdb.vltitulo - tdb.vlsldtit + tdb.vlpagmta + tdb.vlpagmra + tdb.vlpagiof) AS vlpago
       ,(tdb.vlmtatit - tdb.vlpagmta) AS vlmulta
       ,(tdb.vlmratit - tdb.vlpagmra) AS vlmora
       ,(tdb.vliofcpl - tdb.vlpagiof) AS vliof
       ,tdb.vlsldtit + (tdb.vlmtatit - tdb.vlpagmta) + (tdb.vlmratit - tdb.vlpagmra)+ (tdb.vliofcpl - tdb.vlpagiof) AS vlpagar
       ,tdb.*
       ,cob.nrnosnum
       ,ttc.nrctrdsc
       ,sab.cdtpinsc
       ,sab.nmdsacad
       ,bdt.dtliqprj
       ,bdt.dtprejuz
       ,bdt.inprejuz
       ,bdt.vlaboprj
       ,bdt.qtdirisc
      FROM
        craptdb tdb
        INNER JOIN crapbdt bdt
          ON bdt.cdcooper = tdb.cdcooper AND bdt.nrborder = tdb.nrborder
        INNER JOIN crapcob cob 
          ON tdb.cdcooper = cob.cdcooper AND tdb.nrdconta = cob.nrdconta AND tdb.nrdocmto = cob.nrdocmto AND tdb.cdbandoc = cob.cdbandoc AND tdb.nrdctabb = cob.nrdctabb AND tdb.nrcnvcob = cob.nrcnvcob
        INNER JOIN crapsab sab
          ON tdb.cdcooper = sab.cdcooper AND tdb.nrdconta = sab.nrdconta AND tdb.nrinssac = sab.nrinssac          
        LEFT JOIN tbdsct_titulo_cyber ttc
          ON tdb.cdcooper = ttc.cdcooper AND tdb.nrdconta = ttc.nrdconta AND tdb.nrborder = ttc.nrborder AND tdb.nrtitulo = ttc.nrtitulo
      WHERE tdb.cdcooper = pr_cdcooper
        AND tdb.nrdconta = pr_nrdconta
        AND tdb.nrborder = pr_nrborder
        AND tdb.nrdocmto = pr_nrdocmto
        AND tdb.nrdctabb = pr_nrdctabb
        AND tdb.nrcnvcob = pr_nrcnvcob
    ;
    rw_craptdb cr_craptdb%ROWTYPE;
  BEGIN
    --    Leitura do calendário da cooperativa
    OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    -- Tab de chaves
    vr_tab_chave := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                 pr_delimit => ';');   
       
    -- Abre o cursor de títulos                                          
    OPEN cr_craptdb (vr_tab_chave(4), -- Conta
                     vr_tab_chave(3), -- Convenio
                     vr_tab_chave(2), -- Conta base do banco
                     vr_tab_chave(1)  -- Codigo do banco
                     );
    FETCH cr_craptdb INTO rw_craptdb;                                                                            
    CLOSE cr_craptdb;
    
    -- Insere os dados na type
    pr_tab_titulo(0).vltitulo := rw_craptdb.vltitulo;
    pr_tab_titulo(0).dtvencto := rw_craptdb.dtvencto;
    pr_tab_titulo(0).vlpago   := rw_craptdb.vlpago;
    pr_tab_titulo(0).vlmulta  := rw_craptdb.vlmulta;
    pr_tab_titulo(0).vlmora   := rw_craptdb.vlmora;
    pr_tab_titulo(0).vliof    := rw_craptdb.vliof;
    pr_tab_titulo(0).vlpagar  := rw_craptdb.vlpagar;
    pr_tab_titulo(0).nossonum := rw_craptdb.nrnosnum;
    pr_tab_titulo(0).nrctrdsc := rw_craptdb.nrctrdsc;
    pr_tab_titulo(0).nrinssac := rw_craptdb.nrinssac;
    pr_tab_titulo(0).nmdsacad := rw_craptdb.nmdsacad;
    pr_tab_titulo(0).cdtpinsc := rw_craptdb.cdtpinsc;
    pr_tab_titulo(0).diasatr  := ccet0001.fn_diff_datas(rw_craptdb.dtvencto, rw_crapdat.dtmvtolt);
    -- Caso o titulo não esteja vencido ou esteja pago, zera os dias de atraso
    IF pr_tab_titulo(0).diasatr < 0 OR rw_craptdb.dtdpagto IS NOT NULL OR rw_craptdb.dtdebito IS NOT NULL THEN
      pr_tab_titulo(0).diasatr := 0;
    END IF;
    pr_tab_titulo(0).diasprz  := ccet0001.fn_diff_datas(rw_craptdb.dtlibbdt, rw_craptdb.dtvencto);
    pr_tab_titulo(0).dtvencto := rw_craptdb.dtvencto;
    pr_tab_titulo(0).dtliqprj := rw_craptdb.dtliqprj;
    pr_tab_titulo(0).dtprejuz := rw_craptdb.dtprejuz;
    pr_tab_titulo(0).inprejuz := rw_craptdb.inprejuz;
    pr_tab_titulo(0).vlaboprj := rw_craptdb.vlaboprj;
    pr_tab_titulo(0).vljraprj := rw_craptdb.vljraprj;
    pr_tab_titulo(0).vljrmprj := rw_craptdb.vljrmprj;
    pr_tab_titulo(0).vlpgjmpr := rw_craptdb.vlpgjmpr;
    pr_tab_titulo(0).vlpgmupr := rw_craptdb.vlpgmupr;
    pr_tab_titulo(0).vlprejuz := rw_craptdb.vlprejuz;
    pr_tab_titulo(0).vlsdprej := rw_craptdb.vlsdprej;
    pr_tab_titulo(0).vlsprjat := rw_craptdb.vlsprjat;
    pr_tab_titulo(0).vlttjmpr := rw_craptdb.vlttjmpr;
    pr_tab_titulo(0).vlttmupr := rw_craptdb.vlttmupr;
    
    EXCEPTION
        WHEN vr_exc_erro THEN
           pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
           pr_cdcritic := 0;
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_titulo ' ||SQLERRM; 
  END pc_busca_dados_titulo;

  PROCEDURE pc_busca_dados_titulo_web (pr_nrdconta    IN crapass.nrdconta%TYPE --> conta do associado
                                      ,pr_nrborder    IN crapbdt.nrborder%TYPE --> numero do bordero
                                      ,pr_chave       IN VARCHAR2              --> lista de 'nosso numero' a ser pesquisado
                                      ,pr_xmllog      IN VARCHAR2              --> xml com informações de log
                                      --------> out <--------
                                      ,pr_cdcritic OUT PLS_INTEGER             --> código da crítica
                                      ,pr_dscritic OUT VARCHAR2                --> descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY xmltype       --> arquivo de retorno do xml
                                      ,pr_nmdcampo OUT VARCHAR2                --> nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2                --> erros do processo
                                     )IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_titulo_web
      Sistema  : 
      Sigla    : CRED
      Autor    : Vitor Shimada Assanuma (GFT)
      Data     : 14/08/2018
      Frequencia: Sempre que for chamado
      Objetivo  : Listar as informações de um título
      Alterações:
        - 24/08/2018 - Vitor Shimada Assanuma (GFT) - Inserção dos campos de prejuizo
    ---------------------------------------------------------------------------------------------------------------------*/
    -- Tratamento de erro
    vr_exc_erro exception;
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> cód. erro
    vr_dscritic varchar2(1000);        --> desc. erro
        
    -- Variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);   
    
    vr_tab_titulo typ_tab_titulo;
   
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      -- Extrai os dados
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);
                              
     -- Busca os dados do titulo                              
     pc_busca_dados_titulo(pr_cdcooper    => vr_cdcooper
                          ,pr_nrdconta    => pr_nrdconta
                          ,pr_nrborder    => pr_nrborder
                          ,pr_chave       => pr_chave
                          -- OUT --
                          ,pr_tab_titulo => vr_tab_titulo
                          ,pr_cdcritic   => vr_cdcritic
                          ,pr_dscritic   => vr_dscritic);
     IF (vr_dscritic IS NOT NULL) THEN
        raise vr_exc_erro;
     END IF;
      
      -- Inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      
      -- Inicilizar as informaçoes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados>');   
      pc_escreve_xml(
                     '<vltitulo>' || to_char(vr_tab_titulo(0).vltitulo, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vltitulo>' ||
                     '<vlpago>'   || to_char(vr_tab_titulo(0).vlpago,   'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlpago>'   ||
                     '<vlmulta>'  || to_char(vr_tab_titulo(0).vlmulta,  'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlmulta>'  ||
                     '<vlmora>'   || to_char(vr_tab_titulo(0).vlmora,   'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlmora>'   ||
                     '<vliof>'    || to_char(vr_tab_titulo(0).vliof,    'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vliof>'    ||
                     '<vlpagar>'  || to_char(vr_tab_titulo(0).vlpagar,  'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlpagar>'  ||
                     '<nmdsacad>' || htf.escape_sc(vr_tab_titulo(0).nmdsacad)                   || '</nmdsacad>' ||
                     '<diasatr>'  || vr_tab_titulo(0).diasatr                                   || '</diasatr>'  ||
                     '<diasprz>'  || vr_tab_titulo(0).diasprz                                   || '</diasprz>'  ||
                     '<nossonum>' || vr_tab_titulo(0).nossonum                                  || '</nossonum>' ||
                     '<nrinssac>' || vr_tab_titulo(0).nrinssac                                  || '</nrinssac>' ||
                     '<nrctrdsc>' || vr_tab_titulo(0).nrctrdsc                                  || '</nrctrdsc>' ||
                     '<cdtpinsc>' || vr_tab_titulo(0).cdtpinsc                                  || '</cdtpinsc>' ||
                     '<dtvencto>' || to_char(vr_tab_titulo(0).dtvencto, 'DD/MM/RRRR')           || '</dtvencto>' ||
                     '<dtliqprj>' || to_char(vr_tab_titulo(0).dtliqprj, 'DD/MM/RRRR')             || '</dtliqprj>' ||
                     '<dtprejuz>' || to_char(vr_tab_titulo(0).dtprejuz, 'DD/MM/RRRR')             || '</dtprejuz>' ||
                     '<inprejuz>' || vr_tab_titulo(0).inprejuz                                    || '</inprejuz>' ||
                     '<vlaboprj>' || to_char(vr_tab_titulo(0).vlaboprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlaboprj>' ||
                     '<vljraprj>' || to_char(vr_tab_titulo(0).vljraprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vljraprj>' ||
                     '<vljrmprj>' || to_char(vr_tab_titulo(0).vljrmprj, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vljrmprj>' ||
                     '<vlpgjmpr>' || to_char(vr_tab_titulo(0).vlpgjmpr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlpgjmpr>' ||
                     '<vlpgmupr>' || to_char(vr_tab_titulo(0).vlpgmupr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlpgmupr>' ||
                     '<vlprejuz>' || to_char(vr_tab_titulo(0).vlprejuz, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlprejuz>' ||
                     '<vlsdprej>' || to_char(vr_tab_titulo(0).vlsdprej, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlsdprej>' ||
                     '<vlsprjat>' || to_char(vr_tab_titulo(0).vlsprjat, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlsprjat>' ||
                     '<vlttjmpr>' || to_char(vr_tab_titulo(0).vlttjmpr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlttjmpr>' ||
                     '<vlttmupr>' || to_char(vr_tab_titulo(0).vlttmupr, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '',.''') || '</vlttmupr>' 
                     );                                       
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);                     
    EXCEPTION 
      WHEN vr_exc_erro THEN 
           -- Se foi retornado apenas código busca a descrição
           IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN 
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           -- Variavel de erro recebe erro ocorrido
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN 
           -- Montar descriçao de erro nao tratado
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_titulo_web ' ||sqlerrm;
           pr_des_erro := 'NOK';
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');                              
  END pc_busca_dados_titulo_web;


PROCEDURE pc_busca_motivos_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                     ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                     ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                     ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                     ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                     ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo

    /* .............................................................................
    
    Programa: pc_busca_motivos_anulacao
    Sistema : Rotinas referentes ao PRJ438
    Sigla   : 
    Autor   : Paulo Martins (Mouts)
    Data    : Agosto/18.                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Buscar todos os motivos de anulação de emprestimos e limite de crédito
    
    Observacao: -----
    ..............................................................................*/
                                     
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;        
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    
  BEGIN
  
      EMPR0001.pc_busca_motivos_anulacao(pr_tpproduto    => pr_tpproduto, 
                                         pr_nrdconta     => pr_nrdconta, 
                                         pr_nrctrato     => pr_nrctrato, 
                                         pr_tpctrlim     => pr_tpctrlim, 
                                         pr_xmllog       => pr_xmllog, 
                                         pr_cdcritic     => vr_cdcritic, 
                                         pr_dscritic     => vr_dscritic, 
                                         pr_retxml       => pr_retxml, 
                                         pr_nmdcampo     => pr_nmdcampo, 
                                         pr_des_erro     => pr_des_erro);
                                        
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;                                          
  
  EXCEPTION
    WHEN vr_exc_saida THEN
        
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
        
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    WHEN OTHERS THEN
        
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_ATENDA_DSCTO_TIT.pc_busca_motivos_anulacao: ' || SQLERRM;
        
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
                                                                      
  END pc_busca_motivos_anulacao;
  PROCEDURE pc_grava_motivo_anulacao(pr_tpproduto IN tbcadast_motivo_anulacao.tpproduto%TYPE --> Tipo do produto
                                    ,pr_nrdconta  IN tbmotivo_anulacao.nrdconta%TYPE
                                    ,pr_nrctrato  IN tbmotivo_anulacao.nrctrato%TYPE
                                    ,pr_tpctrlim  IN tbmotivo_anulacao.tpctrlim%TYPE
                                    ,pr_cdmotivo  IN VARCHAR2
                                    ,pr_dsmotivo  IN VARCHAR2 
                                    ,pr_dsobservacao IN VARCHAR2                                   
                                    ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2 --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo  

    /* .............................................................................
    
    Programa: pc_grava_motivos_anulacao
    Sistema : Rotinas referentes ao PRJ438
    Sigla   : 
    Autor   : Paulo Martins (Mouts)
    Data    : Agosto/18.                    Ultima atualizacao: --/--/----
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Gravar o motivo de anulação de emprestimos e limite de crédito informado em tela 
    
    Observacao: -----
    ..............................................................................*/                                    
                                    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;        
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
                                           
  BEGIN
  
      EMPR0001.pc_grava_motivo_anulacao(pr_tpproduto    => pr_tpproduto, 
                                        pr_nrdconta     => pr_nrdconta, 
                                        pr_nrctrato     => pr_nrctrato, 
                                        pr_tpctrlim     => pr_tpctrlim, 
                                        pr_cdmotivo     => pr_cdmotivo, 
                                        pr_dsmotivo     => pr_dsmotivo, 
                                        pr_dsobservacao => pr_dsobservacao, 
                                        pr_xmllog       => pr_xmllog, 
                                        pr_cdcritic     => vr_cdcritic, 
                                        pr_dscritic     => vr_dscritic, 
                                        pr_retxml       => pr_retxml, 
                                        pr_nmdcampo     => pr_nmdcampo, 
                                        pr_des_erro     => pr_des_erro);
                                        
      -- Se retornou alguma crítica
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;                                          
  
  EXCEPTION
    WHEN vr_exc_saida THEN
        
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
        
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');      
    WHEN OTHERS THEN
        
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_ATENDA_DSCTO_TIT.pc_grava_motivo_anulacao: ' || SQLERRM;
        
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');  
  END pc_grava_motivo_anulacao;   

  PROCEDURE pc_busca_hist_alt_limite (pr_cdcooper  IN craplim.cdcooper%TYPE
                                     ,pr_nrdconta  IN craplim.nrdconta%TYPE
                                     ,pr_tpctrlim  IN craplim.tpctrlim%TYPE
                                     ,pr_nrctrlim  IN craplim.nrctrlim%TYPE DEFAULT 0
                                     --------> OUT <--------
                                     ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                     ,pr_tab_dados_hist   out  typ_tab_hist_alt_limites --> Tabela de retorno
                                     ,pr_cdcritic  OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic  OUT VARCHAR2              --> Descrição da crítica
                                     ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_busca_hist_alt_limite
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Andrew Albuquerque (GFT)
    Data     : Agosto/2018

    Objetivo  : Procedure para carregar as informações de histório de alteração de limte para a type.

    Alteração : 22/08/2018 - Criação (Andrew Albuquerque - GFT)
  ---------------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic    VARCHAR2(1000);        --> Desc. Erro
      vr_dtvencto    DATE;
      vr_idtabhist PLS_INTEGER;

      -- Tratamento de erros
      vr_exc_erro exception;
      
      -- Cursor para busca dos históricos de alteração limites na tabela nova (TROCAR quando passar a existir).
      CURSOR cr_hist_alt_lim (pr_cdcooper craplim.cdcooper%TYPE
                             ,pr_nrdconta craplim.nrdconta%TYPE
                             ,pr_tpctrlim craplim.tpctrlim%TYPE DEFAULT 0
                             ,pr_nrctrlim craplim.nrctrlim%TYPE) IS
        SELECT l.idhistaltlim, 
               l.cdcooper, 
               l.nrdconta, 
               l.tpctrlim, 
               l.nrctrlim,
               l.dtinivig, 
               l.dtfimvig,
               l.vllimite, 
               l.insitlim,
               case l.insitlim when 1 then 'EM ESTUDO'
                  when 2 then 'ATIVA'
                  when 3 then 'CANCELADA'
                  when 5 then 'APROVADA'
                  when 6 then 'NAO APROVADA'
                  else        'DIFERENTE'
               end as dssitlim,
               l.dhalteracao, 
               l.dsmotivo
          FROM tbdsct_hist_alteracao_limite l
         WHERE l.cdcooper = pr_cdcooper
           AND l.nrdconta = pr_nrdconta
           AND l.nrctrlim = decode(nvl(pr_nrctrlim,0), 0, l.nrctrlim, pr_nrctrlim) -- para trazer todos os contratos da conta.
           AND l.tpctrlim = pr_tpctrlim
         ORDER by l.dtinivig desc, idhistaltlim desc; 

      rw_hist_alt_lim cr_hist_alt_lim%ROWTYPE;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);

      pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursor
      
      -- abrindo o cursor de histório
      OPEN cr_hist_alt_lim (pr_cdcooper   => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_tpctrlim => pr_tpctrlim
                             ,pr_nrctrlim => pr_nrctrlim);
                             
      LOOP
        FETCH cr_hist_alt_lim INTO rw_hist_alt_lim;
        EXIT WHEN cr_hist_alt_lim%NOTFOUND;
            pr_qtregist := pr_qtregist+1;
            vr_idtabhist := pr_tab_dados_hist.count + 1;
            pr_tab_dados_hist(vr_idtabhist).idhistaltlim := rw_hist_alt_lim.idhistaltlim;
            pr_tab_dados_hist(vr_idtabhist).cdcooper     := rw_hist_alt_lim.cdcooper;
            pr_tab_dados_hist(vr_idtabhist).nrdconta     := rw_hist_alt_lim.nrdconta;
            pr_tab_dados_hist(vr_idtabhist).tpctrlim     := rw_hist_alt_lim.tpctrlim;
            pr_tab_dados_hist(vr_idtabhist).nrctrlim     := rw_hist_alt_lim.nrctrlim;
            pr_tab_dados_hist(vr_idtabhist).dtinivig     := rw_hist_alt_lim.dtinivig;
            pr_tab_dados_hist(vr_idtabhist).dtfimvig     := rw_hist_alt_lim.dtfimvig;
            pr_tab_dados_hist(vr_idtabhist).vllimite     := rw_hist_alt_lim.vllimite;
            pr_tab_dados_hist(vr_idtabhist).insitlim     := rw_hist_alt_lim.insitlim;
            pr_tab_dados_hist(vr_idtabhist).dssitlim     := rw_hist_alt_lim.dssitlim;
            pr_tab_dados_hist(vr_idtabhist).dhalteracao  := rw_hist_alt_lim.dhalteracao;
            pr_tab_dados_hist(vr_idtabhist).dsmotivo     := rw_hist_alt_lim.dsmotivo;
      END LOOP;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
           IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_tit_bordero ' ||SQLERRM;
    END;
  END pc_busca_hist_alt_limite;

  PROCEDURE pc_busca_hist_alt_limite_web (pr_nrdconta  IN craplim.nrdconta%TYPE
                                         ,pr_tpctrlim  IN craplim.tpctrlim%TYPE
                                         ,pr_nrctrlim  IN craplim.nrctrlim%TYPE
                                         ,pr_xmllog    IN VARCHAR2              --> xml com informações de log
                                         --------> OUT <--------
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                         ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2              --> Erros do processo 
                                         ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_busca_hist_alt_limite_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Andrew Albuquerque (GFT)
    Data     : Agosto/2018

    Objetivo  : Procedure para carregar as informações de histório de alteração de limte na tela.

    Alteração : 22/08/2018 - Criação (Andrew Albuquerque - GFT)
  ---------------------------------------------------------------------------------------------------------------------*/
  BEGIN
    DECLARE
      -- variáveis de retorno 
      vr_tab_dados_hist typ_tab_hist_alt_limites;
      vr_qtregist number;

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%type;
      vr_dscritic varchar2(10000);

      -- Tratamento de erros
      vr_exc_saida exception;

      -- Variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      
      -- buscando os parâmetros genéricos de forma padrão.
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      

      -- buscando os dados de histório de alteração de limites.
      pc_busca_hist_alt_limite(pr_cdcooper       => vr_cdcooper
                              ,pr_nrdconta       => pr_nrdconta
                              ,pr_tpctrlim       => pr_tpctrlim
                              ,pr_nrctrlim       => pr_nrctrlim
                              ,pr_qtregist       => vr_qtregist
                              ,pr_tab_dados_hist => vr_tab_dados_hist
                              ,pr_cdcritic       => vr_cdcritic
                              ,pr_dscritic       => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;

      vr_des_xml        := null;
      vr_texto_completo := null;
      vr_index          := vr_tab_dados_hist.first;

      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?> <Root>' ||
                    '<Dados qtregist="' || vr_qtregist ||'" >');

      WHILE vr_index IS NOT NULL LOOP
           pc_escreve_xml('<inf>' ||
                             '<idhistaltlim>' ||	vr_tab_dados_hist(vr_index).idhistaltlim || '</idhistaltlim>' ||
                             '<cdcooper>' ||    	vr_tab_dados_hist(vr_index).cdcooper     || '</cdcooper>' ||
                             '<nrdconta>' ||    	vr_tab_dados_hist(vr_index).nrdconta     || '</nrdconta>' ||
                             '<tpctrlim>' ||    	vr_tab_dados_hist(vr_index).tpctrlim     || '</tpctrlim>' ||
                             '<nrctrlim>' ||    	vr_tab_dados_hist(vr_index).nrctrlim     || '</nrctrlim>' ||
                             '<dtinivig>' ||    	to_char(vr_tab_dados_hist(vr_index).dtinivig, 'DD/MM/RRRR') || '</dtinivig>' ||
                             '<dtfimvig>' ||    	to_char(vr_tab_dados_hist(vr_index).dtfimvig, 'DD/MM/RRRR') || '</dtfimvig>' ||
                             '<vllimite>' ||    	to_char(vr_tab_dados_hist(vr_index).vllimite, 'FM999G999G999G990D00') || '</vllimite>' ||
                             '<insitlim>' ||    	vr_tab_dados_hist(vr_index).insitlim     || '</insitlim>' ||
                             '<dssitlim>' ||    	vr_tab_dados_hist(vr_index).dssitlim     || '</dssitlim>' ||
                             '<dhalteracao>' || 	to_char(vr_tab_dados_hist(vr_index).dhalteracao, 'DD/MM/RRRR')  || '</dhalteracao>' ||
                             '<dsmotivo>' ||    	vr_tab_dados_hist(vr_index).dsmotivo     || '</dsmotivo>' ||
                          '</inf>');

         vr_index := vr_tab_dados_hist.next(vr_index);
      END LOOP;

      pc_escreve_xml ('</Dados></Root>',true);

      pr_retxml := xmltype.createxml(vr_des_xml);

      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_saida THEN
           -- Se possui código de crítica e não foi informado a descrição
           IF  vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
               -- Busca descrição da crítica
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           END IF;

           -- Atribui exceção para os parametros de crítica
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := vr_dscritic;
           pr_des_erro := 'NOK';
           pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                            '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
           -- Atribui exceção para os parametros de crítica
           pr_cdcritic := vr_cdcritic;
           pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_busca_hist_alt_limite_web: ' || sqlerrm;
           pr_des_erro := 'NOK';
           pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                            '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;
  END pc_busca_hist_alt_limite_web;
  
  
  PROCEDURE pc_gravar_hist_alt_limite(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                     ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                     ,pr_nrctrlim  IN crawlim.nrctrlim%type --> Contrato
                                     ,pr_tpctrlim  IN crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                     ,pr_dsmotivo  IN tbdsct_hist_alteracao_limite.dsmotivo%TYPE --> Motivo da alteração
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                     ) IS
    /*---------------------------------------------------------------------------------------------------------
      Programa : pc_gravar_hist_alt_limite
      Sistema  : Ayllos
      Sigla    : 
      Autor    : Paulo Penteado (GFT)
      Data     : Agosto/2018
  
      Objetivo  : Gravar as informações de histórico de alteração do limite
  
      Alteração : 22/08/2018 - Criação (Paulo Penteado (GFT))
                  04/09/2018 - Alteração do type de retorno dos históricos de limite, e da data de inclusão quando é 
                               Cancelamento de Limite (Andrew Albuquerque - GFT)  
                  08/10/2018 - Alteração para pegar da data da cooperativa e não SYSDATE
                  11/10/2018 - Alteração para mostrar a data de fim do contrato da CRAPLIM e não da CRAWLIM
                  16/01/2019 - Adicionado tratamento no conteúdo da data inicio de vigência. Quando for contrato cancelado e não tiver 
                               a data de cancelamento preenchida deve considerar a data de inicio de vigência ou data da proposta, pois
                               quando se cancela um contrato pelo processo de renovação automática não preenche a data de cacelamento,
                               somento troca a situção (Paulo Penteado GFT)
    ----------------------------------------------------------------------------------------------------------*/
  
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    
    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;
    
    CURSOR cr_crawlim IS
    SELECT NVL(NVL(ctr.dtinivig, mnt.dtinivig), pro.dtpropos) dtinivig
          ,NVL(ctr.dtfimvig, mnt.dtfimvig) dtfimvig
          ,pro.vllimite
          ,NVL(ctr.insitlim, pro.insitlim) insitlim
          ,case when nvl(pro.nrctrmnt,0) > 0 then pro.nrctrmnt
             else pro.nrctrlim 
           end nrctrlim_nvl
          ,pro.nrctrlim
          ,pro.nrctrmnt
      FROM crawlim pro -- Proposta do Limite (pro)
      -- Contrato Principal do Limite (ctr)
      LEFT JOIN craplim ctr ON ctr.cdcooper = pro.cdcooper
                           AND ctr.nrdconta = pro.nrdconta
                           AND ctr.nrctrlim = pro.nrctrLIM
                           AND ctr.tpctrlim = pro.tpctrlim
      -- Contrato de Majoração/Manutenção do Limite (mnt)
      LEFT JOIN craplim mnt ON mnt.cdcooper = pro.cdcooper
                           AND mnt.nrdconta = pro.nrdconta
                           AND mnt.nrctrlim = pro.nrctrMNT
                           AND mnt.tpctrlim = pro.tpctrlim
     WHERE pro.cdcooper = pr_cdcooper
       AND pro.nrdconta = pr_nrdconta
       AND pro.tpctrlim = pr_tpctrlim
       AND pro.nrctrlim = pr_nrctrlim;
    rw_crawlim cr_crawlim%ROWTYPE;
     
  BEGIN
    OPEN  cr_crawlim;
    FETCH cr_crawlim into rw_crawlim;
    IF cr_crawlim%notfound then
      CLOSE cr_crawlim;
      vr_cdcritic := 484;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawlim;

    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);    
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    END IF;
    CLOSE BTCH0001.cr_crapdat;
    
    BEGIN
      INSERT INTO cecred.tbdsct_hist_alteracao_limite
             (/*01*/ cdcooper
             ,/*02*/ nrdconta
             ,/*03*/ tpctrlim
             ,/*04*/ nrctrlim
             ,/*05*/ dtinivig
             ,/*06*/ dtfimvig
             ,/*07*/ vllimite
             ,/*08*/ insitlim
             ,/*09*/ dhalteracao
             ,/*10*/ dsmotivo)
      VALUES (/*01*/ pr_cdcooper
             ,/*02*/ pr_nrdconta
             ,/*03*/ pr_tpctrlim
             ,/*04*/ rw_crawlim.nrctrlim_nvl
             ,/*05*/ rw_crawlim.dtinivig
             ,/*06*/ decode(rw_crawlim.insitlim, 3,rw_crapdat.dtmvtolt,rw_crawlim.dtfimvig) -- Se for Cancelamento, fim é a mesma data de Alteração.
             ,/*07*/ rw_crawlim.vllimite
             ,/*08*/ rw_crawlim.insitlim
             ,/*09*/ rw_crapdat.dtmvtolt
             ,/*10*/ pr_dsmotivo);
    EXCEPTION
      WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir o histórico de alteração do contrato de limite '||SQLERRM;
           RAISE vr_exc_erro;
    END; 
    
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro then
      IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
  
    WHEN OTHERS THEN
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := 'Erro geral na rotina TELA_ATENDA_DSCTO_TIT.pc_gravar_hist_alt_limite: '||SQLERRM;
      ROLLBACK;
  END pc_gravar_hist_alt_limite; 

END TELA_ATENDA_DSCTO_TIT;
/
