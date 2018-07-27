CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------

    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Mar�o - 2018                 Ultima atualizacao: 01/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de T�tulos dentro da ATENDA

    Alteracoes: 01/03/2018 - Cria��o (Paulo Penteado (GFT))
                02/03/2018 - Inclus�o da Fun��o    fn_em_contingencia_ibratan (Gustavo Sene (GFT))
                02/03/2018 - Inclus�o da Procedure pc_confirmar_novo_limite   (Gustavo Sene (GFT))
                02/03/2018 - Inclus�o da Procedure pc_negar_proposta          (Gustavo Sene (GFT))
                13/03/2018 - Alterado alerta de confirma��o quando ocorre contingencia. Teremos que mostrar o alerta somente se 
                   tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT) KE00726701-276)
                23/03/2018 - Inclus�o da Procedure pc_buscar_titulos          (Andrew Albuquerque (GFT))
                26/03/2018 - Inclus�o da Procedure pc_buscar_titulos_web      (Andrew Albuquerque (GFT))
                26/03/2018 - Inclus�o da Procedure pc_busca_dados_limite e pc_busca_dados_limite_web (Luis Fernando (GFT))
                26/03/2018 - Inclus�o da procedure pc_obtem_dados_proposta_web (Paulo Penteado (GFT))
                02/04/2018 - Inclus�o do record 'typ_rec_tit_bordero' e das procedures 'pc_buscar_tit_bordero' e 'pc_buscar_tit_bordero_web' para listar e buscar detalhes e restri��es dos titulos do border� (Leonardo Oliveira (GFT))
                04/04/2018 - Ajuste no retorno das cr�ticas na opera��o 'pc_detalhes_tit_bordero' (Leonardo Oliveira (GFT)) 
        26/04/2018 - Ajuste no retorno das propostas 'pc_obtem_dados_proposta_web' (Leonardo Oliveira (GFT))
  ---------------------------------------------------------------------------------------------------------------------*/

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
                  nmsacado crapsab.nmdsacad%TYPE,
                  flgregis crapcob.flgregis%TYPE,
                  insittit craptdb.insittit%TYPE,
                  insitapr craptdb.insitapr%TYPE,
                  nrctrdsc tbdsct_titulo_cyber.nrctrdsc%TYPE,
                  dssituac CHAR(1),
                  sitibrat CHAR(1));

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
        dtlibbdt       craptdb.dtlibbdt%TYPE
        );
  
  TYPE typ_tab_dados_titulos IS TABLE OF typ_reg_dados_titulos INDEX BY BINARY_INTEGER;
  
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
  
/*Tabela que armazena as informa��es da proposta de limite de desconto de titulo*/
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
     flrestricao    INTEGER

);
TYPE typ_tab_borderos IS TABLE OF typ_reg_borderos INDEX BY BINARY_INTEGER;


  --     buscar informa��es dos titulos/boletos (utilizado em outras package)
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
        ,nvl((SELECT decode(inpossui_criticas,1,'S','N')
              FROM   tbdsct_analise_pagador tap 
              WHERE  tap.cdcooper = cob.cdcooper
              AND    tap.nrdconta = cob.nrdconta
              AND    tap.nrinssac = cob.nrinssac),'A') AS dssituac
        ,COUNT(1) over() qtregist 
  FROM   crapcob cob 
         INNER JOIN crapsab sab ON sab.nrinssac = cob.nrinssac AND 
                                   sab.cdtpinsc = cob.cdtpinsc AND 
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


--> Fun��o que retorna se o Servi�o IBRATAN est� em Contig�ncia ou N�o.
FUNCTION fn_em_contingencia_ibratan (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

FUNCTION fn_contigencia_esteira(pr_cdcooper IN crapcop.cdcooper%TYPE ) RETURN BOOLEAN;

--> Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrctrlim IN crawlim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN crawlim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  );

PROCEDURE pc_efetivar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> C�digo da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> C�digo do Operador
                              ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                              ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                              ,pr_idorigem    in integer               --> Identificador Origem Chamada
                              ,pr_insitapr    in crawlim.insitapr%type --> Decis�o (Dependente do Retorno da An�lise)
                              --------> OUT <--------
                              ,pr_cdcritic    out pls_integer          --> Codigo da critica
                              ,pr_dscritic    out varchar2             --> Descricao da critica
                              );


PROCEDURE pc_efetivar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                  ,pr_nrctrlim  IN crawlim.nrctrlim%TYPE --> Contrato
                                  ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo


PROCEDURE pc_cancelar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
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
                              ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
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
                                   ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
                                   ,pr_cdcritic out pls_integer           --> Codigo da critica
                                   ,pr_dscritic out varchar2              --> Descricao da critica
                                   ,pr_retxml   in  out nocopy xmltype    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo out varchar2              --> Nome do campo com erro
                                   ,pr_des_erro out varchar2              --> Erros do processo OK ou NOK
                                   );

PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> C�digo da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_alterar_proposta_manute_web(pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
                                         -- OUT
                                        ,pr_cdcritic out pls_integer          --> Codigo da critica
                                        ,pr_dscritic out varchar2             --> Descric?o da critica
                                        ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                        ,pr_des_erro out varchar2);           --> Erros do processo

PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
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
                                      ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
                                       -- OUT
                                      ,pr_cdcritic out pls_integer          --> Codigo da critica
                                      ,pr_dscritic out varchar2             --> Descric?o da critica
                                      ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                      ,pr_des_erro out varchar2             --> Erros do processo
                                      );
                                      
PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de opera��o
                                  ,pr_nrdcaixa IN INTEGER                --> N�mero do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_idorigem IN INTEGER                --> Identifica��o de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                  ,pr_dtemissa IN crapbdt.dtmvtolt%TYPE DEFAULT NULL --> Filtro data de Emissao do border�
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer       --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
	  
PROCEDURE pc_buscar_titulos_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> N�mero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype     --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

PROCEDURE pc_busca_dados_limite (pr_nrdconta IN craplim.nrdconta%TYPE
                                   ,pr_cdcooper IN craplim.cdcooper%TYPE
                                   ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                                   ,pr_insitlim IN craplim.insitlim%TYPE
                                   ,pr_dtmvtolt IN VARCHAR2
                                   --------> OUT <--------
                                   ,pr_tab_dados_limite   out  typ_tab_dados_limite --> Tabela de retorno
                                   ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                   ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                   );
                                   
PROCEDURE pc_busca_dados_limite_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo do contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Situacao do Contrato
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  );
                                     
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_chave           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 );
                                 
PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                );
                                
PROCEDURE pc_solicita_biro_bordero(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento(Boleto)
                                  ,pr_cdbandoc  IN crapcob.cdbandoc%TYPE --> Codigo do banco/caixa
                                  ,pr_nrdctabb  IN crapcob.nrdctabb%TYPE --> Numero da conta base no banco
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                  ,pr_nrinssac  IN crapcob.nrinssac%TYPE --> Numero de inscricao do sacado
                                  ,pr_cdoperad  IN crapcob.cdoperad%TYPE --> Operador que solicitou a consulta
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                  );
                                
PROCEDURE pc_solicita_biro_bordero_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_chave    in varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> C�digo da cr�tica
                                  ,pr_dscritic out varchar2             --> Descri��o da cr�tica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  );
                                  
PROCEDURE pc_insere_bordero(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                           ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Conta do associado
                           ,pr_tpctrlim          IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite
                           ,pr_insitlim          IN craplim.insitlim%TYPE --> Situa��o do contrato de limite
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
                           ,pr_tab_borderos     OUT typ_tab_borderos      --> Dados do border� inserido
                           ,pr_dsmensag         OUT VARCHAR2              --> Mensagem
                           ,pr_cdcritic         OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic         OUT VARCHAR2              --> Descricao da critica
                           );
                                  
PROCEDURE pc_insere_bordero_web(pr_tpctrlim IN craplim.tpctrlim%TYPE --> Tipo de contrato
                                 ,pr_insitlim IN craplim.insitlim%TYPE --> Situacao do contrato
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                 ,pr_chave    IN VARCHAR2              --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de movimentacao 
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                 );
                                 
PROCEDURE pc_detalhes_tit_bordero(pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                             ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                             ,pr_nrborder   IN crapbdt.nrborder%TYPE
                             ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                             ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscri��o do sacado
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
                                      ,pr_xmllog      in varchar2              --> xml com informa��es de log
                                       --------> out <--------
                                      ,pr_cdcritic out pls_integer             --> c�digo da cr�tica
                                      ,pr_dscritic out varchar2                --> descri��o da cr�tica
                                      ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                      ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                      ,pr_des_erro out varchar2                --> erros do processo
                                    );

PROCEDURE pc_buscar_tit_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de opera��o
                                  ,pr_nrdcaixa IN INTEGER                --> N�mero do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_idorigem IN INTEGER                --> Identifica��o de origem
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_tit_bordero   out  typ_tab_tit_bordero --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  );
                               
PROCEDURE pc_buscar_tit_bordero_web (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                );               
      

PROCEDURE pc_buscar_dados_bordero_web (
                                pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                ,pr_dtmvtolt IN VARCHAR2 --> Data de movimenta��o do sistema
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );                      
  
PROCEDURE pc_validar_titulos_alteracao (
                                pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                ,pr_dtmvtolt IN VARCHAR2 --> Data de movimenta��o do sistema
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );
PROCEDURE pc_altera_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                               ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                               ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao
                               ,pr_nrborder           in crapbdt.nrborder%type   --> Border� sendo alterado
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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
                               ,pr_xmllog      in varchar2              --> xml com informa��es de log
                               --------> out <--------
                               ,pr_cdcritic out pls_integer             --> c�digo da cr�tica
                               ,pr_dscritic out varchar2                --> descri��o da cr�tica
                               ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                               ,pr_nmdcampo out varchar2                --> nome do campo com erro
                               ,pr_des_erro out varchar2                --> erros do processo
                               );
                               
PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Border�
                                ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                --------> OUT <--------
                                ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                              );
                              
PROCEDURE pc_titulos_resumo_resgatar_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                              ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                              ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                              ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                            );

PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                                 ,pr_cdcooper IN crapbdt.cdcooper%TYPE
                                 ,pr_dtmvtolt IN VARCHAR2
                                     --------> OUT <--------
                                 ,pr_qtregist OUT INTEGER
                                 ,pr_tab_borderos   out  typ_tab_borderos --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                 );

PROCEDURE pc_busca_borderos_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  );

PROCEDURE pc_contingencia_ibratan_web(pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                 );
                                 
END TELA_ATENDA_DSCTO_TIT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Mar�o - 2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela Limite Desconto de T�tulos dentro da ATENDA

    Alteracoes: 
      01/03/2018 - Cria��o: Paulo Penteado (GFT) / Gustavo Sene (GFT)
      02/03/2018 - Inclus�o da Fun��o    fn_em_contingencia_ibratan (Gustavo Sene (GFT))
      02/03/2018 - Inclus�o da Procedure pc_confirmar_novo_limite   (Gustavo Sene (GFT))
      02/03/2018 - Inclus�o da Procedure pc_negar_proposta          (Gustavo Sene (GFT))
      13/03/2018 - Alterado alerta de confirma��o quando ocorre contingencia. Teremos que mostrar o alerta somente se 
                   tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT) KE00726701-276)
      23/03/2018 - Inclus�o da Procedure pc_buscar_titulos          (Andrew Albuquerque (GFT))
      26/03/2018 - Inclus�o da Procedure pc_buscar_titulos_web      (Andrew Albuquerque (GFT))
      26/03/2018 - Inclus�o da Procedure pc_busca_dados_limite e pc_busca_dados_limite_web (Luis Fernando (GFT))
      26/03/2018 - Adicionado as procedures pc_obtem_dados_proposta, pc_obtem_dados_proposta_web, pc_inserir_contrato_limite.
                   Alterado as procedures pc_confirmar_novo_limite e pc_negar_proposta. Altera��es necess�rias para adapta��o 
                   do processo de cria��o de proposta de limite de desconto de t�tulos (Paulo Penteado (GFT) KE00726701-304)
      13/04/2018 - Criadas funcionalidades de inclus�o, altera��o e resgate de border�es (Luis Fernando (GFT)
      23/04/2018 - Altera��o para que quando seja adicionado um titulo ao bordero, alterar o status do bordero para 'Em estudo' (Vitor (GFT))
      25/04/2018 - Alterado o calculo das porcentagens da Liquidez (Vitor (GFT))
      21/05/2018 - Adicionada procedure para trazer se a esteira e o motor est�o em contingencia (Luis Fernando (GFT))
  ---------------------------------------------------------------------------------------------------------------------*/


   -- Vari�veis para armazenar as informa��es em XML
   vr_des_xml         clob;
   vr_texto_completo  varchar2(32600);
   vr_index           pls_integer;

   -- Variaveis para verifica��o de contigencia de esteira e motor
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

    Objetivo  : Procedure para verificar e tanto o motor quanto a esteira est�o em conting�ncia

    Altera��o : 26/04/2018 - Cria��o (Paulo Penteado (GFT))

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

    Objetivo  : Procedure para verificar  a esteira em conting�ncia

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
    Data     : Mar�o/2018

    Frequencia: Sempre que for chamado

    Objetivo  : Fun��o que retorna se o Servi�o IBRATAN est� em Contig�ncia ou N�o.

    Altera��o : 01/03/2018 - Cria��o (Gustavo Sene (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

  vr_inobriga varchar2(1);

  -- Vari�veis de cr�ticas
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

  if vr_inobriga = 'N' then -- Se an�lise IBRATAN n�o obrigat�ria
    return TRUE;  --> Em Conting�ncia
  else                      -- Se an�lise IBRATAN obrigat�ria
    return FALSE; --> N�o est� em Conting�ngia
  end if;

END fn_em_contingencia_ibratan;


-- Rotina para escrever texto na vari�vel CLOB do XML
PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                        , pr_fecha_xml in boolean default false
                        ) is
BEGIN
   gene0002.pc_escreve_xml( vr_des_xml
                          , vr_texto_completo
                          , pr_des_dados
                          , pr_fecha_xml );
END;


PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrctrlim IN crawlim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN crawlim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Mar�o/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.

    Altera��o : 28/02/2018 - Cria��o (Paulo Penteado (GFT))
                10/04/2018 - Substituido a tabela craplim pela cralim (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
         vr_dscritic := 'Esta proposta foi inclu�da no processo antigo. Favor cancela-la e incluir novamente atrav�s do novo processo.';
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


PROCEDURE pc_validar_efetivacao_proposta(pr_cdcooper          in crapcop.cdcooper%type     --> C�digo da Cooperativa
                                        ,pr_nrdconta          in crapass.nrdconta%type     --> N�mero da Conta
                                        ,pr_nrctrlim          in crawlim.nrctrlim%type     --> Contrato
                                        ,pr_cdagenci          out crapass.cdagenci%type    --> Codigo da agencia
                                        ,pr_tab_crapdat       out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic          out pls_integer              --> C�digo da cr�tica
                                        ,pr_dscritic          out varchar2                 --> Descri��o da cr�tica
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_confirm_novo_limite
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Sene (GFT)
    Data     : Mar�o/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para valida��o de informa��es ante de efetuar a confirma��o do novo limite

    Altera��o : 03/03/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Informa��es de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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

   --  Verifica se a conta est� em prejuizo
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
           vr_dscritic := 'Para esta opera��o, a Decis�o deve ser "Aprovada Automaticamente" ou "Aprovada Manual".';
           raise vr_exc_saida;
       end if;
   end if;

   if  rw_crawlim.insitlim not in (1,5) then
       vr_dscritic := 'Para esta opera��o, a situa��o da proposta deve ser "Em estudo" ou "Aprovada".';
       raise vr_exc_saida;
   end if;

   --    Verifica se ja existe um contrato ativo caso efetive uma proposta principal
   if  rw_crawlim.nrctrmnt = 0 then
       open  cr_craplim;
       fetch cr_craplim into rw_craplim;
       if    cr_craplim%found then
             close cr_craplim;
             vr_dscritic := 'Efetiva��o de proposta n�o permitida! O contrato ' ||rw_craplim.nrctrlim || ' j� ativo deve ser cancelado primeiro.';
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


PROCEDURE pc_inserir_contrato_limite(pr_cdcooper in crapcop.cdcooper%type --> C�digo da Cooperativa
                                    ,pr_nrdconta in crapass.nrdconta%type --> N�mero da Conta
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
    Data     : Mar�o/2018

    Objetivo  : Procedure para carregar as informa��es da proposta na type

    Altera��o : 26/03/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
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
      -- inserir o registro do contrato de limite de desconto de t�tulo de acordo com a proposta
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
             ,/*52*/ ininadim )
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
             ,/*52*/ rw_crawlim.ininadim );
   exception
      when others then
           vr_dscritic := 'Erro ao inserir o contrato de limite de desconto de t�tulo: '||sqlerrm;
           raise vr_exc_saida;
   end; 
EXCEPTION
   when vr_exc_saida then
        pr_dscritic := vr_dscritic;

   when others then
        pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_inserir_contrato_limite: ' || sqlerrm;

END pc_inserir_contrato_limite;


PROCEDURE pc_efetivar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> C�digo da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> C�digo do Operador
                              ,pr_cdagenci    in crapass.cdagenci%type --> Codigo da agencia
                              ,pr_nrdcaixa    in craperr.nrdcaixa%type --> Numero Caixa
                              ,pr_idorigem    in integer               --> Identificador Origem Chamada
                              ,pr_insitapr    in crawlim.insitapr%type --> Decis�o (Dependente do Retorno da An�lise)
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
  -- Data     : Cria��o: 22/02/2018
  --
  -- Dados referentes ao programa:
  --  Esse procedimento � chamado nos arquivos do progress bo30
  --
  -- Frequencia:
  -- Objetivo  : Efetivar a proposta de limite de desconto de t�tulos fazendo a mesma virar um contrato
  -- 
  --
  -- Hist�rico de Altera��es:
  --  22/02/2018 - Vers�o inicial
  --  10/04/2018 - Alterado atualiza��o da tabela de contrato craplim pela tabela de proposta crawlim. 
  --               Adicionado o insert na tabela craplim, pois quando confirmar a proposta de limite, 
  --               deve-se gerar um contrato. (Paulo Penteado (GFT))
  --
  ----------------------------------------------------------------------------------
DECLARE
   -- Informa��es de data do sistema
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

   -- Vari�veis inclu�das
   vr_des_erro      varchar2(3);                           -- 'OK' / 'NOK'
   vr_cdbattar      crapbat.cdbattar%type := 'DSTCONTRPF'; -- Default = Pessoa F�sica
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
         vr_dscritic := 'Proposta de limite de desconto de t�tulo n�o encontado. Conta ' || pr_nrdconta || ' proposta ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_crawlim;
   
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   vr_flcraplim := cr_craplim%FOUND;
   close cr_craplim;
   
   --  Quando o campo nrctrmnt for zero, significa que a proposta � a principal de cria��o do contrato do limite. Neste momento deve-se
   --  inserir o contrato do limite.
   --  Caso contr�rio, se tiver preenchido, significa que � uma proposta de altera��o de valores. Neste momento deve-se atualizar o valor
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

       -- Se n�o, cria novo lote
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
                             ,35 -- T�tulo
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
           vr_cdbattar := 'DSTCONTRPF'; -- Pessoa F�sica
       else
           vr_cdbattar := 'DSTCONTRPJ'; -- Pessoa Jur�dica
       end if;

       -- Buscar valores da tarifa vigente
       tari0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                                            ,pr_cdbattar => vr_cdbattar    --> Codigo da sigla da tarifa (CRAPBAT) - Ao popular este par�metro o pr_cdtarifa n�o � necess�rio
                                            ,pr_cdtarifa => vr_cdtarifa    --> Codigo da Tarifa (CRAPTAR) - Ao popular este par�metro o pr_cdbattar n�o � necess�rio
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

       -- Criar lan�amento autom�tico da tarifa
       tari0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                       ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data Lancamento
                                       ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                       ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                       ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                       ,pr_cdagenci => 1                     --> Codigo Agencia
                                       ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                       ,pr_nrdolote => 8452                  --> Numero do lote
                                       ,pr_tpdolote => 1                     --> Tipo do lote (35 - T�tulo)
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
                              ,pr_dtmvtopr => rw_crapdat.dtmvtopr                 --> Data do pr�ximo dia �til
                              ,pr_inproces => rw_crapdat.inproces                 --> Situa��o do processo
                              ,pr_tpctrrat => 3                                   --> Tipo Contrato Rating (2-Cheque / 3-Titulo)
                              ,pr_nrctrrat => pr_nrctrlim                         --> Numero Contrato Rating
                              ,pr_flgcriar => 1                                   --> Criar rating
                              ,pr_flgerlog => 1                                   -->  Identificador de gera��o de log
                              ,pr_tab_rating_sing => vr_tab_crapras               --> Registros gravados para rating singular
                              ,pr_tab_impress_coop => vr_tab_impress_coop         --> Registro impress�o da Cooperado
                              ,pr_tab_impress_rating => vr_tab_impress_rating     --> Registro itens do Rating
                              ,pr_tab_impress_risco_cl => vr_tab_impress_risco_cl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOCL
                              ,pr_tab_impress_risco_tl => vr_tab_impress_risco_tl --> Registro Nota e risco do cooperado naquele Rating - PROVISAOTL
                              ,pr_tab_impress_assina => vr_tab_impress_assina     --> Assinatura na impressao do Rating
                              ,pr_tab_efetivacao => vr_tab_efetivacao             --> Registro dos itens da efetiva��o
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

       -- Efetua os inserts para apresentacao na tela VERLOG
       gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => ' '
                           ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                           ,pr_dstransa => 'Efetiva��o de proposta de limite de desconto de t�tulos.'
                           ,pr_dttransa => trunc(sysdate)
                           ,pr_flgtrans => 1
                           ,pr_hrtransa => to_char(sysdate,'SSSSS')
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'ATENDA'
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_rowid_log);

   else
       if  NOT vr_flcraplim then
             vr_dscritic := 'N�o foi encontrado um contrato de limite de desconto de t�tulo associado a proposta. Conta ' || pr_nrdconta || ' proposta ' || pr_nrctrlim;
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
               vr_dscritic := 'Erro ao atualizar o valor e/ou linha de desconto do contrato de limite de desconto de t�tulo: '||sqlerrm;
               raise vr_exc_saida;
       end;
   end if;

   -- Atualiza a Proposta de Limite de Desconto de T�tulo
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
           vr_dscritic := 'Erro ao atualizar a proposta de limite de desconto de t�tulo. ' || sqlerrm;
           raise vr_exc_saida;
   end;

   --  Caso seja uma proposta de majora��o, ou seja, se o valor da proposta for maior que o do contrato, E caso a 
   --  esteira n�o esteja em contingencia, ent�o deve enviar a efetiva��o da proposta para o Ibratan
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
           vr_dscritic := 'Erro ao enviar a efetiva��o da proposta para o Ibratan: '||vr_dscritic;
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


PROCEDURE pc_efetivar_proposta_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
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
   Data     : Cria��o: 22/02/2018    Ultima atualiza��o: 10/04/2018
  
   Dados referentes ao programa:
  
   Frequencia:
   Objetivo  :

   Hist�rico de Altera��es:
    22/02/2018 - Vers�o inicial
    13/03/2018 - Alterado alerta de confirma��o quando ocorre contingencia. Teremos que mostrar o alerta
                 somente se tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT))
    10/04/2018 - Alterado atualiza��o da tabela de contrato craplim pela tabela de proposta crawlim (Paulo Penteado (GFT))
    
  ----------------------------------------------------------------------------------*/
   -- Informa��es de data do sistema
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
   vr_mensagem_05  varchar2(1000); -- Mensagem que informa se o Processo de An�lise Autom�tica (IBRATAN) est� em Conting�ncia
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

   -- Verificar se a esteira e/ou motor est�o em contigencia e armazenar na variavel
   vr_em_contingencia_ibratan := fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);

   --  1� Passo: Executamos a Opera��o = 0 para verificar se existe alguma inconsist�ncia para emitir mensagem de
   --  alerta, e solicitar confirma��o do usu�rio para prosseguir com a confirma��o do novo limite
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
               --  Verifica se o valor limite � maior que o valor da divida e pega o maior valor
               if  rw_crawlim.vllimite > vr_par_vlutiliz then
                   vr_valor := rw_crawlim.vllimite;
               else
                   vr_valor := vr_par_vlutiliz;
               end if;

               --  Verifica se o valor � maior que o valor maximo utilizado pelo associado nos emprestimos
               if  vr_valor > vr_vlmaxutl then
                   vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||'.';
               end if;

               --  Verifica se o valor � maior que o valor legal a ser emprestado pela cooperativa
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

               --  Verifica se o valor � maior que o valor da consulta SCR
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

           --  Verifica se o valor limite � maior que o valor da divida e pega o maior valor
           if  vr_vlmaxutl > 0 then
               if  rw_crawlim.vllimite > vr_par_vlutiliz then
                   vr_valor := rw_crawlim.vllimite;
               else
                   vr_valor := vr_par_vlutiliz;
               end if;

               -- Verifica se o valor � maior que o valor maximo utilizado pelo associado nos emprestimos
               if  vr_valor > vr_vlmaxutl then
                   vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
               end if;

               --  Verifica se o valor � maior que o valor legal a ser emprestado pela cooperativa
               if  vr_valor > vr_vlmaxleg then
                   vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
                                     to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                     to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
               end if;

               --  Verifica se o valor � maior que o valor da consulta SCR
               if  vr_valor > vr_vlminscr then
                   vr_mensagem_04 := 'Efetue consulta no SCR.';
               end if;
           end if;
       end if;

       --  Verificar se o tanto o motor quanto a esteria est�o em contingencia para mostrar a mensagem de alerta, sou seja, mostrar
       --  mensagem de alerta somente se o motor E a esteira estiverem em contingencia.
       if fn_contigencia_motor_esteira(pr_cdcooper => vr_cdcooper) or (rw_crawlim.insitlim = 1) then
           vr_mensagem_05 := 'Aten��o: Para efetivar � necess�rio ter efetuado a an�lise manual do limite! Confirma an�lise do limite?';
       end if;

       --  Se houver alguma Mensagem/Inconsist�ncia, emitir mensagem para o usuario
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

       -- Se n�o houver nenhuma Mensagem/Inconsist�ncia, efetuar o processo de Confirma��o do novo Limite normalmente
       else
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- T�tulo
                               ,pr_cdoperad => vr_cdoperad   --> C�digo do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => null -- Decis�o = Retorno da IBRATAN
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

           if  vr_dscritic is not null then
               raise vr_exc_saida;
           end if;

           pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
       end if;

   --  2� Passo: Se houve alguma Mensagem/Inconsist�ncia e o Operador Ayllos confirmou (ou seja, clicou em "SIM" ou "OK"),
   --  efetuar o processo de Confirma��o do novo Limite.
   --  Se houver Contig�ncia de Motor e/ou Esteira, ser� efetuada a Confirma��o do novo Limite na situa��o de Contig�ncia.
   else
       if  vr_em_contingencia_ibratan then
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- T�tulo
                               ,pr_cdoperad => vr_cdoperad   --> C�digo do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => 3 -- Decis�o = APROVADO (CONTINGENCIA)      
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
           
           if  vr_dscritic is not null then
               raise vr_exc_saida;
           end if;
       else
           pc_efetivar_proposta(pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctrlim => pr_nrctrlim
                               ,pr_tpctrlim => 3 -- T�tulo
                               ,pr_cdoperad => vr_cdoperad   --> C�digo do Operador
                               ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                               ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                               ,pr_insitapr => null -- Decis�o = Retorno da IBRATAN
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


PROCEDURE pc_cancelar_proposta(pr_cdcooper    in crapcop.cdcooper%type --> C�digo da Cooperativa
                              ,pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                              ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                              ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                              ,pr_cdoperad    in crapope.cdoperad%type --> C�digo do Operador
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

    Altera��o : 12/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
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

   --  Verifica se a situa��o est� 'Ativo' ou 'Cancelado'
   if  rw_crawlim.insitlim in (2,3) then
       vr_dscritic := 'Para esta opera��o, a situa��o da Proposta n�o deve ser "Ativa"';-- ou "Cancelada".';
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
           vr_dscritic := 'Erro ao cancelar a proposta de limite de desconto de t�tulo. ' || sqlerrm;
           raise vr_exc_saida;
   end;

   -- Efetua os inserts para apresentacao na tela VERLOG
   gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_dscritic => ' '
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                       ,pr_dstransa => 'Cancelamento da Proposta de Limite de Desconto de T�tulos.'
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


PROCEDURE pc_cancelar_proposta_web(pr_nrdconta in  crapass.nrdconta%type --> N�mero da Conta
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
  -- Data     : Cria��o: 01/03/2018    Ultima atualiza��o: 01/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  :
  --
  --
  -- Hist�rico de Altera��es:
  --  01/03/2018 - Cria��o
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


PROCEDURE pc_retorno_proposta_autom(pr_cdcooper    in crapcop.cdcooper%type --> C�digo da Cooperativa
                                   ,pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                                   ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                   ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                                   ,pr_cdoperad    in crapope.cdoperad%type --> C�digo do Operador
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

    Objetivo  : Procedure para efetivar ou cancelar uma proposta de majora��o automaticamente ap�s o retorno da an�lise
                do ibratan.

    Altera��o : 12/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
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
   
   --  se trata-se de um contrato de majora��o
   if  rw_crawlim.nrctrmnt > 0 then
       --    se retornou da an�lise do ibratan como Aprovada, efetivar a proposta
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

       --    se retornou da an�lise do ibratan como N�o Aprovada, cancelar a proposta
       elsif rw_crawlim.insitlim = 6 and rw_crawlim.insitapr = 4 then
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
                              ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
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
    Data     : Mar�o/2018

    Dados referentes ao programa:
    Tipo do envestimento I - inclusao Proposta
                         D - Derivacao Proposta
                         A - Alteracao Proposta
                         N - Alterar Numero Proposta
                         C - Cancelar Proposta
                         E - Efetivar Proposta

    Caso a proposta j� tenha sido enviada para a Esteira iremos considerar uma Alteracao.
    Caso a proposta tenho sido reprovada pelo Motor, iremos considerar envio pois ela ainda nao foi a Esteira

    Frequencia: Sempre que for chamado

    Objetivo  : Procedure para validar a analise de limite, n�o permitir efetuar analise para limites antigos.

    Altera��o : 28/02/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   vr_dtmvtolt DATE;


   -- Vari�vel de cr�ticas
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

   pr_des_erro := pr_xmllog; -- somente para n�o haver hint, caso for usado, pode remover essa linha
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
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;


       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;

  when others then
       -- Atribui exce��o para os parametros de cr�tica
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
                                   ,pr_xmllog   in  varchar2              --> XML com informa��es de LOG
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
    Data     : Mar�o/2018
   
    Dados referentes ao programa:
   
    Frequencia: Sempre que for chamado
    
    Objetivo  : Procedure para enviar a analise para esteira ap�s confirma��o de senha
   
    Altera��o : 05/03/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   vr_dtmvtolt DATE;
   
   -- Vari�vel de cr�ticas
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

   pr_des_erro := pr_xmllog; -- somente para n�o haver hint, caso for usado, pode remover essa linha
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
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;
        
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
        
  when others then
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_enviar_proposta_manual: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_enviar_proposta_manual;

  
PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> C�digo da Linha
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
    Data    : Mar�o/2018

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
      
      IF vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      
      -- Chama rotina de renova��o
      LIMI0001.pc_renovar_lim_desc_titulo(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_vllimite => pr_vllimite
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

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_renovar_lim_desc_titulo: ' || SQLERRM;

        -- Carregar XML padr�o para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_renovar_lim_desc_titulo;
  
PROCEDURE pc_alterar_proposta_manutencao(pr_cdcooper    in crapcop.cdcooper%type --> C�digo da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_cdoperad    in crapope.cdoperad%type --> C�digo do Operador
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

    Objetivo  : Procedure para alterar as informa��es de uma proposta de manuten��o do contrato de limite

    Altera��o : 25/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Informa��es de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;
   
   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type;
   vr_dscritic varchar2(10000);

   -- Tratamento de erros
   vr_exc_saida exception;

   -- Variaveis auxiliares
   vr_rowid_log    rowid;
   
   vr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
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
         vr_dscritic := 'Linha de desconto de t�tulo n�o cadastrada.';
         raise vr_exc_saida;
   else
         --  Verifica se a linha de credito esta liberada
         if  rw_crapldc.flgstlcr = 0 then
             vr_dscritic := 'Opera��o n�o permitida, linha de desconto '||pr_cddlinha||' bloqueada.';
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
                                                 pr_cdagenci, --Agencia de opera��o
                                                 pr_nrdcaixa, --N�mero do caixa
                                                 pr_cdoperad, --Operador
                                                 rw_crapdat.dtmvtolt, -- Data da Movimenta��o
                                                 pr_idorigem, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                 vr_tab_dados_dsctit,
                                                 vr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
     if  vr_cdcritic > 0  or vr_dscritic is not null then
        raise vr_exc_saida;
     end if;                                            
    
    /*LIMITE MAXIMO EXCEDIDO*/
    if pr_vllimite > vr_tab_dados_dsctit(1).vllimite then
        vr_dscritic := 'Limite m�ximo excedido.';
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
      
      pr_dsmensag := 'Proposta de majora��o alterada com sucesso.';
   exception
      when others then
           vr_dscritic := 'Erro na altera��o da proposta de manuten��o do limite de desconto de t�tulo. ' || sqlerrm;
           raise vr_exc_saida;
   end;
   
   --  se o valor do limite informado na altera��o for menor que o valor do contrato ativo, ent�o deve-se efetivar a proposta
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
       
       pr_dsmensag := 'Proposta de majora��o alterada e efetivada com sucesso.';
   end if;

   -- Efetua os inserts para apresentacao na tela VERLOG
   gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                       ,pr_cdoperad => pr_cdoperad
                       ,pr_dscritic => ' '
                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                       ,pr_dstransa => 'Altera��o da Proposta de Manuten��o de Limite de Desconto de T�tulos.'
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

PROCEDURE pc_alterar_proposta_manute_web(pr_nrdconta    in crapass.nrdconta%type --> N�mero da Conta
                                        ,pr_nrctrlim    in crawlim.nrctrlim%type --> Contrato
                                        ,pr_tpctrlim    in crawlim.tpctrlim%type --> Tipo de contrato de Limite
                                        ,pr_vllimite    in crawlim.vllimite%type --> Valor da manutencao
                                        ,pr_cddlinha    in crawlim.cddlinha%type --> Codigo da linha de desconto
                                        ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
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

    Objetivo  : Procedure para alterar as informa��es de uma proposta de manuten��o do contrato de limite

    Altera��o : 25/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
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
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                        
       ROLLBACK;

  when others then
       -- Atribui exce��o para os parametros de cr�tica
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
                                 ,pr_tab_dados_proposta out typ_tab_dados_proposta --> Saida com os dados do empr�stimo
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_dados_proposta
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Mar�o/2018

    Objetivo  : Procedure para carregar as informa��es da proposta na type

    Altera��o : 26/03/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
   where  case --   mostrar propostas em situa��es de analise (em estudo) e canceladas dentro de x dias
               when lim.insitlim in (1,3,5,6) and lim.dtpropos >= vr_dtpropos then 1
               --   mostrar somente a �ltima proposta ativa
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
               when lim.insitlim in (4,7) then 1
               else 0
          end = 1
   and    lim.tpctrlim = pr_tpctrlim
   and    lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper
   order  by case when lim.insitlim = 1 then -3
                  when lim.insitlim = 5 then -2
                  when lim.insitlim = 6 then -1
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
                                     ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
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
    Data     : Mar�o/2018

    Objetivo  : Procedure para carregar as informa��es da proposta na tela

    Altera��o : 26/03/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_proposta typ_tab_dados_proposta;
   vr_qtregist           number;

   -- Vari�vel de cr�ticas
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

   -- Liberando a mem�ria alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  when vr_exc_saida then
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_dados_proposta_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_dados_proposta_web;


PROCEDURE pc_obtem_proposta_aciona(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                  ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_nrctrlim           in crawlim.nrctrlim%type   --> Numero do Contrato do Limite
                                  ,pr_tpctrlim           in crawlim.tpctrlim%type   --> Tipo de contrato de Limite
                                  ,pr_nrctrmnt           in crawlim.tpctrlim%type   --> Numero da proposta do Limite
                                  ,pr_qtregist           out integer                --> Qtde total de registros
                                  ,pr_tab_dados_proposta out typ_tab_dados_proposta --> Saida com os dados do empr�stimo
                                  ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                  ,pr_dscritic           out varchar2               --> Descricao da critica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_obtem_proposta_aciona
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Abril/2018

    Objetivo  : Procedure para carregar as informa��es da proposta na type para filtro na tela de detalhes do acionamento

    Altera��o : 11/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
                                      ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
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

    Objetivo  : Procedure para carregar as informa��es da proposta na tela de detalhes do acionamento

    Altera��o : 11/04/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_proposta typ_tab_dados_proposta;
   vr_qtregist           number;
   vr_index              pls_integer;

   -- Vari�vel de cr�ticas
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

   -- Liberando a mem�ria alocada pro CLOB
   dbms_lob.close(vr_des_xml);
   dbms_lob.freetemporary(vr_des_xml);

EXCEPTION
  when vr_exc_saida then
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_proposta_aciona_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_proposta_aciona_web;


  PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de opera��o
                                  ,pr_nrdcaixa IN INTEGER                --> N�mero do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_idorigem IN INTEGER                --> Identifica��o de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Numero do bordero
                                  ,pr_dtemissa IN crapbdt.dtmvtolt%TYPE DEFAULT NULL --> Filtro data de Emissao do border�
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ) is

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulos
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT) / Andrew Albuquerque (GFT)
    Data     : Mar�o/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que filtra os titulos na tela de inclusao de bordero

    Altera��o : ??/03/2018 - Cria��o Luis Fernando (GFT) / Andrew Albuquerque (GFT)
                15/05/2018 - Adicionado o par�metro pr_dt
                15/05/2018 - Adicionado os par�metros pr_dtemissa, pr_nriniseq e pr_nrregist (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   vr_qtprzmaxpj number; -- Prazo M�ximo PJ (Em dias)
   vr_qtprzmaxpf number; -- Prazo M�ximo PF (Em dias)
   
   vr_qtprzminpj number; -- Prazo M�nimo PJ (Em dias)
   vr_qtprzminpf number; -- Prazo M�nimo PF (Em dias)
   
   vr_vlminsacpj number; -- Valor m�nimo permitido por t�tulo PJ
   vr_vlminsacpf number; -- Valor m�nimo permitido por t�tulo PF

   vr_dtmvtolt    DATE;
   vr_dtvencto    DATE;
   vr_idtabtitulo PLS_INTEGER;

   pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
   pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
   
   vr_countpag    INTEGER := 1 ; -- contador para controlar a paginacao
   -- Tratamento de erros
   vr_exc_erro exception;
       
    CURSOR cr_crapcob IS
      SELECT rownum numero_linha,
                  cob.progress_recid, -- numero sequencial do titulo (verificar a utilidade
           cob.cdcooper,
           cob.nrdconta,
           cob.nrctremp, -- numero do contrato de limite.
           cob.nrcnvcob, -- conv�nio
           cob.nrdocmto, -- nr. boleto
           cob.nrinssac, -- cpf/cnpj do Pagador (Antigo SACADO)
           sab.nmdsacad, -- nome do pagador (o campo NMDSACAD da crapcob n�o est� preenchido...)
           cob.dtvencto, -- data de vencimento
           cob.dtmvtolt, -- data de movimento
           cob.vltitulo,  -- valor do t�tulo
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
       AND sab.cdtpinsc = cob.cdtpinsc
       AND sab.cdcooper = cob.cdcooper
       AND sab.nrdconta = cob.nrdconta
       -- Regras Fixas
     WHERE cob.nrdconta = pr_nrdconta
       AND cob.cdcooper = pr_cdcooper
       AND cob.flgregis > 0 -- Indicador de Registro CIP (0-Sem registro CIP/ 1-Registro Online/ 2-Registro offline)
       AND cob.incobran = 0
       -- regras da TAB052
       -- Valor da tabela crapcob (vltitulo) est� menor do que o valor que est� na tab052 (Valor m�nimo permitido por t�tulo) - vlmintgc 
       AND cob.vltitulo >= decode(cob.cdtpinsc, 1, vr_vlminsacpf, vr_vlminsacpj)
       -- Prazo calculado entre a data de inclus�o e o vencimento � menor do que est� na tab052 (prazo m�nimo) qtprzmin
       AND (cob.dtvencto - vr_dtmvtolt) >= decode(cob.cdtpinsc, 1, vr_qtprzminpf, vr_qtprzminpj)
       -- Prazo calculado entre a data de inclus�o e o vencimento � maior do que est� na tab052 (prazo m�ximo) qtprzmax
       AND (cob.dtvencto - vr_dtmvtolt) <= decode(cob.cdtpinsc, 1, vr_qtprzmaxpf, vr_qtprzmaxpj)

       -- Filtros Vari�veis - Tela
       AND (cob.nrinssac = pr_nrinssac OR nvl(pr_nrinssac,0)=0)
       AND (cob.vltitulo = pr_vltitulo OR nvl(pr_vltitulo,0)=0)
       AND (cob.dtvencto = vr_dtvencto OR vr_dtvencto IS NULL)
       AND (cob.dtmvtolt = pr_dtemissa OR pr_dtemissa IS NULL)
       AND (cob.nrnosnum LIKE '%'||pr_nrnosnum||'%' OR nvl(pr_nrnosnum,0)=0) -- o campo correto para "Nosso N�mero"
       ;
       rw_crapcob cr_crapcob%ROWTYPE;
         
        
    /*Cursor para verificar se boleto j� nao esta em outro bordero*/   
    CURSOR cr_craptdb (pr_nrdocmto IN craptdb.nrdocmto%TYPE, pr_nrdctabb IN craptdb.nrdctabb%TYPE, pr_nrcnvcob IN craptdb.nrcnvcob%TYPE, pr_nrborder IN craptdb.nrborder%TYPE) IS
     SELECT 
        craptdb.nrdocmto,
        craptdb.nrborder,
        craptdb.insitapr,
        CASE WHEN (SELECT nrdocmto FROM craptdb INNER JOIN crapbdt ON craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
          WHERE craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = pr_cdcooper
            AND craptdb.nrdocmto = pr_nrdocmto
            AND craptdb.nrdctabb = pr_nrdctabb
            AND craptdb.nrcnvcob = pr_nrcnvcob
            AND craptdb.nrborder <> nvl(pr_nrborder,0)
            AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
            AND craptdb.insitapr = 0) IS NOT NULL THEN 1 ELSE 0 END AS fl_aberto, --Somente titulos aprovados
        CASE WHEN (SELECT nrdocmto FROM craptdb INNER JOIN crapbdt ON craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
          WHERE craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = pr_cdcooper
            AND craptdb.nrdocmto = pr_nrdocmto
            AND craptdb.nrdctabb = pr_nrdctabb
            AND craptdb.nrcnvcob = pr_nrcnvcob
            AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
            AND craptdb.insitapr = 1) IS NOT NULL THEN 1 ELSE 0 END AS fl_aprovado, --Somente titulos aprovados
         CASE WHEN (SELECT nrborder FROM craptdb 
           WHERE craptdb.nrdconta = pr_nrdconta
             AND craptdb.cdcooper = pr_cdcooper
             AND craptdb.nrdocmto = pr_nrdocmto
             AND craptdb.nrdctabb = pr_nrdctabb
             AND craptdb.nrcnvcob = pr_nrcnvcob
             AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
             AND craptdb.nrborder = pr_nrborder) IS NOT NULL THEN 1 ELSE 0 END AS fl_bordero --Somente titulos aprovados
     FROM
        craptdb
        INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
     WHERE
        craptdb.nrdconta = pr_nrdconta
        AND craptdb.cdcooper = pr_cdcooper
        AND craptdb.nrdocmto = pr_nrdocmto
        AND craptdb.nrdctabb = pr_nrdctabb
        AND craptdb.nrcnvcob = pr_nrcnvcob
        AND crapbdt.insitbdt <= 4  -- borderos que estao em estudo, analisados, liberados, liquidados
        -- Retirar os titulos que ja foram aprovados em algum bordero
   ;rw_craptdb cr_craptdb%ROWTYPE;
   BEGIN
     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
   
      pr_qtregist:= 0; -- zerando a vari�vel de quantidade de registros no cursos
     
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      vr_dtvencto := null;
       IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
       END IF;
      --carregando os dados de prazo limite da TAB052 
       -- BUSCAR O PRAZO PARA PESSOA FISICA
      cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de opera��o
                                                 pr_nrdcaixa, --N�mero do caixa
                                                 pr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimenta��o
                                                 pr_idorigem, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 1, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpf := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpf := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpf := pr_tab_dados_dsctit(1).vlminsac;

      -- BUSCAR O PRAZO PARA PESSOA JUR�DICA
      cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de opera��o
                                                 pr_nrdcaixa, --N�mero do caixa
                                                 pr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimenta��o
                                                 pr_idorigem, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 2, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpj := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpj := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpj := pr_tab_dados_dsctit(1).vlminsac;
      
      -- abrindo cursos de t�tulos
      OPEN cr_crapcob;
      LOOP
        FETCH cr_crapcob INTO rw_crapcob;
        EXIT WHEN cr_crapcob%NOTFOUND;
        IF rw_crapcob.dssituac = 'N' THEN
           IF DSCT0003.fn_calcula_cnae(rw_crapcob.cdcooper
                                   ,rw_crapcob.nrdconta
                                   ,rw_crapcob.nrdocmto
                                   ,rw_crapcob.nrcnvcob
                                   ,rw_crapcob.nrdctabb
                                   ,rw_crapcob.cdbandoc) THEN
              rw_crapcob.dssituac := 'S';
           END IF;
        END IF;
        /*verifica se j� nao est� em outro bordero*/
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
      pr_qtregist := nvl(vr_idtabtitulo,0);

    EXCEPTION
      WHEN OTHERS THEN
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_buscar_titulos ' ||sqlerrm;
                                  
  END pc_buscar_titulos_bordero;
  
  PROCEDURE pc_buscar_titulos_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> N�mero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

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

      pc_buscar_titulos_bordero(pr_cdcooper => vr_cdcooper  --> C�digo da Cooperativa
                               ,pr_nrdconta => pr_nrdconta --> N�mero da Conta
                               ,pr_cdagenci => vr_cdagenci --> Agencia de opera��o
                               ,pr_nrdcaixa => vr_nrdcaixa --> N�mero do caixa
                               ,pr_cdoperad => vr_cdoperad --> Operador
                               ,pr_dtmvtolt => pr_dtmvtolt --> Data da Movimenta��o
                               ,pr_idorigem => vr_idorigem --> Identifica��o de origem
                               ,pr_nrinssac => pr_nrinssac --> Filtro de Inscricao do Pagador
                               ,pr_vltitulo => pr_vltitulo --> Filtro de Valor do titulo
                               ,pr_dtvencto => pr_dtvencto --> Filtro de Data de vencimento
                               ,pr_nrnosnum => pr_nrnosnum --> Filtro de Nosso Numero
                               ,pr_nrctrlim => pr_nrctrlim --> Contrato
                               ,pr_insitlim => pr_insitlim --> Status
                               ,pr_tpctrlim => pr_tpctrlim --> Tipo de desconto
                               ,pr_nrborder => pr_nrborder --> Numero do bordero
                               ,pr_nriniseq => pr_nriniseq --> Pagina��o Inicial
                               ,pr_nrregist => pr_nrregist --> Quantidade de Registros
                               --------> OUT <-------
                               ,pr_qtregist          => vr_qtregist --> Quantidade de registros encontrados
                               ,pr_tab_dados_titulos => vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                               ,pr_cdcritic          => vr_cdcritic --> C�digo da cr�tica
                               ,pr_dscritic          => vr_dscritic --> Descri��o da cr�tica
                       );
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_titulos_bordero_web;
    
    PROCEDURE pc_busca_dados_limite (pr_nrdconta IN craplim.nrdconta%TYPE
                                     ,pr_cdcooper IN craplim.cdcooper%TYPE
                                     ,pr_tpctrlim IN craplim.tpctrlim%TYPE
                                     ,pr_insitlim IN craplim.insitlim%TYPE
                                     ,pr_dtmvtolt IN VARCHAR2
                                     --------> OUT <--------
                                     ,pr_tab_dados_limite   out  typ_tab_dados_limite --> Tabela de retorno
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                     ) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa : pc_busca_dados_limite
      Sistema  : Cred
      Sigla    : TELA_ATENDA_DSCTO_TIT
      Autor    : Luis Fernando (GFT) / 
      Data     : Mar�o/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que lista os dados do contrato de limite
    ---------------------------------------------------------------------------------------------------------------------*/
      
      vr_dtmvtolt    DATE;
      vr_vlutiliz    NUMBER;
      vr_qtutiliz    INTEGER;
      
       -- Vari�vel de cr�ticas
       vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
             SUM(craptdb.vltitulo) AS vlutiliz,
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
             AND (craptdb.insittit=4 OR (craptdb.insittit=2 AND craptdb.dtdpagto=vr_dtmvtolt));
      rw_craptdb cr_craptdb%rowtype;
      BEGIN
        GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
        
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
        
        OPEN cr_crapass;
        FETCH cr_crapass INTO rw_crapass;
        IF (cr_crapass%NOTFOUND) THEN
          vr_dscritic := 'Cooperado n�o cadastrado';
          raise vr_exc_erro;
        END IF;
        
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF (cr_craplim%NOTFOUND) THEN
         vr_dscritic := 'Conta n�o possui contrato de limite ativo.';
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
                                                 null, --Agencia de opera��o
                                                 null, --N�mero do caixa
                                                 null, --Operador
                                                 vr_dtmvtolt, -- Data da Movimenta��o
                                                 null, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
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
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite ' ||sqlerrm;
    END pc_busca_dados_limite;
       
    PROCEDURE pc_busca_dados_limite_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo do contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Situacao do Contrato
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  ) IS
         
    
    pr_tab_dados_limite  typ_tab_dados_limite;          --> retorna dos dados
    
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

    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

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
                              
       pc_busca_dados_limite (pr_nrdconta,
                              vr_cdcooper,
                              pr_tpctrlim,
                              pr_insitlim,
                              pr_dtmvtolt,
                              ----OUT----
                              pr_tab_dados_limite,
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
      -- inicilizar as informa�oes do xml
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
                           '</inf>'
                          );
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_busca_dados_limite_web;    


  PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
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
    Data     : Mar�o/2018    

    Objetivo  : Procedure para carregar as informa��es dos titulos selecionados prestes a serem incluidos no bordero.

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
         /*Traz 1 linha para cada cobran�a sendo selecionada*/
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
               /*Faz calculo de liquidez e concentracao e atualiza as criticas*/
               DSCT0002.pc_atualiza_calculos_pagador ( pr_cdcooper => rw_crapcob.cdcooper
                                                      ,pr_nrdconta => rw_crapcob.nrdconta 
                                                      ,pr_nrinssac => rw_crapcob.nrinssac 
                                                     --------------> OUT <--------------
                                                     ,pr_pc_cedpag  => vr_aux
                                                     ,pr_qtd_cedpag => vr_aux
                                                     ,pr_pc_conc    => vr_aux
                                                     ,pr_qtd_conc   => vr_aux
                                                     ,pr_pc_geral   => vr_aux
                                                     ,pr_qtd_geral  => vr_aux
                                                     ,pr_cdcritic   => vr_cdcritic
                                                     ,pr_dscritic   => vr_dscritic
                                    );
               
               vr_idtabtitulo := vr_idtabtitulo + 1;
             END IF;
             close cr_crapcob;
           END IF;
           vr_index := vr_tab_cobs.next(vr_index);
         end loop;
       END IF;
       pr_qtregist := vr_idtabtitulo;
    END;
    END pc_listar_titulos_resumo ;
    
    PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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
     
      -- Vari�vel de cr�ticas
       vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
     -- Variaveis para verificar criticas e situacao
     vr_ibratan char(1);
     vr_situacao char(1);
     vr_nrinssac crapcob.nrinssac%TYPE;
     vr_cdbircon crapbir.cdbircon%TYPE;
     vr_dsbircon crapbir.dsbircon%TYPE;
     vr_cdmodbir crapmbr.cdmodbir%TYPE;
     vr_dsmodbir crapmbr.dsmodbir%TYPE;
     restricao_cnae BOOLEAN;

    CURSOR cr_crapcbd IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapcbd
       WHERE crapcbd.cdcooper = vr_cdcooper
         AND crapcbd.nrdconta = pr_nrdconta 
         AND crapcbd.nrcpfcgc = vr_nrinssac
         AND crapcbd.inreterr = 0  -- Nao houve erros
       ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente
     rw_crapcbd  cr_crapcbd%rowtype;
     
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

        pc_listar_titulos_resumo(vr_cdcooper  --> C�digo da Cooperativa
                           ,pr_nrdconta --> N�mero da Conta
                           ,pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                           --------> OUT <--------
                           ,vr_qtregist --> Quantidade de registros encontrados
                           ,vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                           ,vr_cdcritic --> C�digo da cr�tica
                           ,vr_dscritic --> Descri��o da cr�tica
                         );
        
        -- inicializar o clob
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- inicilizar as informa�oes do xml
        vr_texto_completo := null;
        
        pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                       '<root><dados qtregist="' || vr_qtregist ||'" >');
                       
        -- ler os registros de titulos e incluir no xml
        vr_index := vr_tab_dados_titulos.first;
        while vr_index is not null LOOP
              --Testa se o titulo possui restricao de CNAE
              restricao_cnae := DSCT0003.fn_calcula_cnae(vr_tab_dados_titulos(vr_index).cdcooper
                                                     ,vr_tab_dados_titulos(vr_index).nrdconta
                                                     ,vr_tab_dados_titulos(vr_index).nrdocmto
                                                     ,vr_tab_dados_titulos(vr_index).nrcnvcob
                                                     ,vr_tab_dados_titulos(vr_index).nrdctabb
                                                     ,vr_tab_dados_titulos(vr_index).cdbandoc);
              vr_situacao := CASE WHEN restricao_cnae THEN 'S' ELSE 'N' END;

              --Caso j� tenha restricao do CNAE nao precisa verificar as outras para colocar a flag
              IF NOT restricao_cnae THEN
              SELECT (nvl((SELECT 
                              decode(inpossui_criticas,1,'S','N')
                              FROM 
                               tbdsct_analise_pagador tap 
                            WHERE tap.cdcooper=vr_cdcooper AND tap.nrdconta=pr_nrdconta AND tap.nrinssac=vr_tab_dados_titulos(vr_index).nrinssac
                         ),'A')) INTO vr_situacao FROM DUAL ; -- Situacao do pagador com critica ou nao
              END IF;
              vr_nrinssac := vr_tab_dados_titulos(vr_index).nrinssac;
              
              open cr_crapcbd;
              fetch cr_crapcbd into rw_crapcbd;
              IF (cr_crapcbd%NOTFOUND) THEN
                vr_ibratan := 'A';
              ELSE
                SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir,rw_crapcbd.nrseqdet,vr_cdbircon,vr_dsbircon,vr_cdmodbir,vr_dsmodbir,vr_ibratan);
              END IF;
              close cr_crapcbd;
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
                                '<sitibrat>' || vr_ibratan  || '</sitibrat>' || 
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

        /* liberando a mem�ria alocada pro clob */
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      exception
        when vr_exc_erro then
             /*  se foi retornado apenas c�digo */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descri�ao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo_web ' ||sqlerrm;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_listar_titulos_resumo_web;
    

PROCEDURE pc_solicita_biro_bordero(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                  ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta do associado
                                  ,pr_nrdocmto  IN crapcob.nrdocmto%TYPE --> Numero do documento(Boleto)
                                  ,pr_cdbandoc  IN crapcob.cdbandoc%TYPE --> Codigo do banco/caixa
                                  ,pr_nrdctabb  IN crapcob.nrdctabb%TYPE --> Numero da conta base no banco
                                  ,pr_nrcnvcob  IN crapcob.nrcnvcob%TYPE --> Numero do convenio de cobranca
                                  ,pr_nrinssac  IN crapcob.nrinssac%TYPE --> Numero de inscricao do sacado
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

    Altera��o : 18/05/2018 - Cria��o (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
  -- Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
  vr_dscritic varchar2(1000);        --> Desc. Erro

  -- Tratamento de erros
  vr_exc_erro exception;

  CURSOR cr_analise_pagador IS
  SELECT 1
  FROM   tbdsct_analise_pagador tap 
  WHERE  tap.cdcooper = pr_cdcooper
  AND    tap.nrdconta = pr_nrdconta
  AND    tap.nrinssac = pr_nrinssac;
  rw_analise_pagador cr_analise_pagador%rowtype;

BEGIN
  OPEN  cr_analise_pagador;
  FETCH cr_analise_pagador INTO rw_analise_pagador;
  IF    cr_analise_pagador%NOTFOUND THEN
        dsct0002.pc_efetua_analise_pagador(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrinssac => pr_nrinssac
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);

        IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
            CLOSE cr_analise_pagador;
            RAISE vr_exc_erro;
        END IF;
  END   IF;
  CLOSE cr_analise_pagador;
         
  sspc0001.pc_solicita_cons_bordero_biro(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdocmto => pr_nrdocmto
                                        ,pr_cdbandoc => pr_cdbandoc
                                        ,pr_nrdctabb => pr_nrdctabb
                                        ,pr_nrcnvcob => pr_nrcnvcob
                                        ,pr_inprodut => 7
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
                                  ,pr_chave    in varchar2              --> Lista de chaves dos titulos a serem pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> C�digo da cr�tica
                                  ,pr_dscritic out varchar2             --> Descri��o da cr�tica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_solicita_biro_bordero_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Mar�o/2018

    Objetivo  : Procedure para realizar a consulta do biros dos pagadores de um bordero no Ibratan

    Altera��o : 28/03/2018 - Cria��o (Paulo Penteado (GFT))
                18/05/2018 - Transformado a procedure em _web (Paulo Penteado (GFT)) 

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
   vr_qtregist          number;
   vr_index             pls_integer;

   -- Vari�vel de cr�ticas
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
   fl_erro_biro boolean;

BEGIN
   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);
                           
   pc_listar_titulos_resumo(pr_cdcooper          => vr_cdcooper
                           ,pr_nrdconta          => pr_nrdconta
                           ,pr_chave             => pr_chave
                           ,pr_qtregist          => vr_qtregist
                           ,pr_tab_dados_titulos => vr_tab_dados_titulos
                           ,pr_cdcritic          => vr_cdcritic
                           ,pr_dscritic          => vr_dscritic );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_index := vr_tab_dados_titulos.first;
   fl_erro_biro := false;
   while vr_index is not null LOOP
         pc_solicita_biro_bordero(pr_cdcooper => vr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrdocmto => vr_tab_dados_titulos(vr_index).nrdocmto
                                               ,pr_cdbandoc => vr_tab_dados_titulos(vr_index).cdbandoc
                                               ,pr_nrdctabb => vr_tab_dados_titulos(vr_index).nrdctabb
                                               ,pr_nrcnvcob => vr_tab_dados_titulos(vr_index).nrcnvcob
                                 ,pr_nrinssac => vr_tab_dados_titulos(vr_index).nrinssac
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

         --  Caso n�o consiga conexao ou der erro no biro, nao parar a execucao, tratar somente depois do loop
         if  vr_cdcritic > 0  or vr_dscritic is not null then
             fl_erro_biro := true;
         end if;

         vr_index := vr_tab_dados_titulos.next(vr_index);
   end   loop;
   
   --Caso tenha algum erro durante o BIRO levanta a exception
   if fl_erro_biro then
      raise vr_exc_saida;
   end if;
   
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>Ok</dsmensag></Root>');

EXCEPTION
  when vr_exc_saida then
       -- Se possui c�digo de cr�tica e n�o foi informado a descri��o
       if  vr_cdcritic <> 0 and trim(vr_dscritic) is null then
           -- Busca descri��o da cr�tica
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
       end if;

       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := vr_dscritic;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exce��o para os parametros de cr�tica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_solicita_biro_bordero_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_solicita_biro_bordero_web;


PROCEDURE pc_insere_bordero(pr_cdcooper          IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                           ,pr_nrdconta          IN crapass.nrdconta%TYPE --> Conta do associado
                           ,pr_tpctrlim          IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite
                           ,pr_insitlim          IN craplim.insitlim%TYPE --> Situa��o do contrato de limite
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
                           ,pr_tab_borderos     OUT typ_tab_borderos      --> Dados do border� inserido
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

    Objetivo  : Procedure para realizar a inclus�o do border�

    Altera��o : 18/05/2018 - Cria��o, separado da procedure pc_insere_bordero_web (Paulo Penteado (GFT))
                15/06/2018 - Retorno se o bordero teve criticas ou nao ao inserir. [Vitor Shimada Assanuma (GFT)]
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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
        (SELECT SUM(craptdb.vltitulo) 
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
      
      
    /*Linha de cr�dito*/
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
          AND crapbdt.insitbdt <= 4;  -- borderos que estao em estudo, analisados, liberados, liquidados
    rw_craptdb cr_craptdb%rowtype;
          
BEGIN
      /*VERIFICA SE O CONTRATO EXISTE E AINDA EST� ATIVO*/
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF (cr_craplim%NOTFOUND) THEN
        vr_dscritic := 'Contrato n�o encontrado.';
        raise vr_exc_erro;
      END IF;
      CLOSE cr_craplim;
      vr_cddlinha := rw_craplim.cddlinha;
        
      OPEN cr_crapldc;
      FETCH cr_crapldc INTO rw_crapldc;
      IF (cr_crapldc%NOTFOUND) THEN
         vr_dscritic := 'Linha de cr�dito n�o encontrada.';
         raise vr_exc_erro;
      END IF;
      CLOSE cr_crapldc;
        
     IF (rw_craplim.dtfimvig <pr_dtmvtolt) THEN
         vr_dscritic := 'A vig�ncia do contrato deve ser maior que a data de movimenta��o do sistema.';
       raise vr_exc_erro;
     END IF;
     
     OPEN cr_crapass;
     FETCH cr_crapass INTO rw_crapass;
     IF (cr_crapass%NOTFOUND) THEN
        vr_dscritic := 'Cooperado n�o cadastrado';
        raise vr_exc_erro;
     END IF;
     CLOSE cr_crapass;

      --carregando os dados de prazo limite da TAB052 
     dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 null, --Agencia de opera��o
                                                 null, --N�mero do caixa
                                                 null, --Operador
                                                 pr_dtmvtolt, -- Data da Movimenta��o
                                                 null, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
     
    /*VERIFICA SE O VALOR DOS BOLETOS S�O > QUE O DISPONIVEL NO CONTRATO*/
      vr_index := pr_tab_dados_titulos.first;
      vr_vldtit := 0;
      vr_idtabtitulo := 0;
      vr_qtregist := 0;
      WHILE vr_index IS NOT NULL LOOP
            /*Antes de realizar a inclus�o dever� validar se algum t�tulo j� foi selecionado em algum outro 
            border� com situa��o diferente de �n�o aprovado� ou �prazo expirado�*/
           open cr_craptdb (pr_nrdconta=>pr_nrdconta,
                                 pr_cdcooper=>pr_cdcooper,
                                 pr_nrdocmto=>pr_tab_dados_titulos(vr_index).nrdocmto,
                                 pr_cdbandoc=>pr_tab_dados_titulos(vr_index).cdbandoc,
                                 pr_nrcnvcob=>pr_tab_dados_titulos(vr_index).nrcnvcob,
                                 pr_nrdctabb=>pr_tab_dados_titulos(vr_index).nrdctabb
                              );
             fetch cr_craptdb into rw_craptdb;
             if  cr_craptdb%found AND rw_craptdb.insitapr <> 2 then
               vr_dscritic := 'T�tulo ' ||rw_craptdb.nrdocmto || ' j� selecionado em outro border�';
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
        vr_dscritic := 'O Total de t�tulos selecionados supera o valor dispon�vel no contrato.';
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
      -- Rotina para criar n�mero de bordero por cooperativa
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
                            ,vlinfocs)
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
                            ,0);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          CONTINUE;
        WHEN OTHERS THEN
          -- Gera cr�tica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir novo lote ' || SQLERRM;
          -- Levanta exce��o
          RAISE vr_exc_erro;
      END;
      
      vr_flg_criou_lot := TRUE;
    END LOOP;
    

        /*INSERE UM NOVO BORDER�*/
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
           ,/*25*/ flverbor )
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
           ,/*11*/ 1        -- A principio o status inicial � EM ESTUDO
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
           ,/*25*/ 1 );

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
                 pr_tab_dados_titulos(vr_index).nrdctabb,
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
                                      ,pr_indrestr => vr_indrestr --> Indica se Gerou Restri��o (0 - Sem Restri��o / 1 - Com restri��o)
                                      ,pr_ind_inpeditivo => vr_ind_inpeditivo  --> Indica se o Resultado � Impeditivo para Realizar Libera��o. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                      ,pr_tab_erro => vr_tab_erro --  OUT GENE0001.typ_tab_erro --> Tabela Erros
                                      ,pr_tab_retorno_analise => vr_tab_retorno_analise --OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                      ,pr_cdcritic => vr_cdcritic          --> C�digo da cr�tica
                                      ,pr_dscritic => vr_dscritic             --> Descri�ao da cr�tica
                                      );
                                      
       IF  vr_cdcritic > 0  OR TRIM(vr_dscritic) IS NOT NULL THEN
         RAISE vr_exc_erro;
       END IF;
       
       -- Retorno se teve restri��o
       pr_tab_borderos(1).flrestricao := vr_indrestr;
       
       IF (vr_indrestr = 0) THEN
          pr_dsmensag := 'Border� n ' || vr_nrborder || ' criado com sucesso. Border� sem cr�ticas, aprovado automaticamente!';
       ELSE 
          pr_dsmensag := 'Border� n ' || vr_nrborder || ' criado com sucesso.';
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
END pc_insere_bordero;


  PROCEDURE pc_insere_bordero_web(pr_tpctrlim IN craplim.tpctrlim%TYPE --> Tipo de contrato
                                 ,pr_insitlim IN craplim.insitlim%TYPE --> Situacao do contrato
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta do associado
                                 ,pr_chave    IN VARCHAR2              --> Lista de 'chaves' de titulos a serem pesquisado
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data de movimentacao 
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_insere_bordero_web
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Mar�o/2018    

    Objetivo  : Procedure para Inserir todos os titulos selecionados no bordero

    Altera��o : ??/03/2018 - Cria��o (Luis Fernando (GFT))
                18/05/2018 - Transformado a procedure em _web (Paulo Penteado (GFT)) 
                15/06/2018 - Retorno se o bordero teve criticas ou nao e o numero ao inserir. [Vitor Shimada Assanuma (GFT)]

  ---------------------------------------------------------------------------------------------------------------------*/
  vr_tab_dados_titulos typ_tab_dados_titulos;
  vr_tab_borderos      typ_tab_borderos;
  vr_qtregist          NUMBER;
  vr_dtmvtolt          DATE;
  vr_dtmvtopr          DATE;
  -- Cursor gen�rico de calend�rio
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  -- Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
     
    pc_listar_titulos_resumo(vr_cdcooper          --> C�digo da Cooperativa
                            ,pr_nrdconta          --> N�mero da Conta
                            ,pr_chave             --> Lista de 'nosso numero' a ser pesquisado
                            --------> OUT <--------
                            ,vr_qtregist          --> Quantidade de registros encontrados
                            ,vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                            ,vr_cdcritic          --> C�digo da cr�tica
                            ,vr_dscritic );       --> Descri��o da cr�tica
                            
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
    
    -- Chamar gera��o de LOG
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

            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    WHEN OTHERS THEN
         pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_insere_bordero_web ' ||sqlerrm;
         
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
  END pc_insere_bordero_web ;
    
  PROCEDURE pc_detalhes_tit_bordero(pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_nrborder           in crapbdt.nrborder%type   --> Numero do bordero
                               ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                               ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscri��o do sacado
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
    -- Data     : Cria��o: Mar�o/2018  Ultima atualiza��o: 30/03/2018
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Obter os detalhes do Pagador do T�tulo selecionado na composi��o do Border�
    --
    -- Hist�rico de Altera��es:
    --  29/03/2018 - Vers�o inicial
    --  03/05/2018 - Vitor Shimada Assanuma - Alterado a regra de CNAE, adicionado funcao DSCT0003.fn_calcula_cnae()
    --  30/05/2018 - Vitor Shimada Assanuma - Inser��o da verifica��o se o border� � antigo e tratamento de erro
    --  09/07/2018 - Vitor Shimada Assanuma - Valida��o de cr�ticas repetidas
    ---------------------------------------------------------------------------------------------------------------------
   
    ----------------> VARI�VEIS <----------------
    
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%type; --> C�d. Erro
    vr_dscritic        varchar2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        exception;

    -- Demais tipos e vari�veis
    vr_idtabcritica      integer;  
    --  
    vr_idtabtitulo       INTEGER;
    vr_nrinssac            crapcob.nrinssac%TYPE;
    vr_tab_dados_dsctit    cecred.dsct0002.typ_tab_dados_dsctit;
    vr_tab_cecred_dsctit   cecred.dsct0002.typ_tab_cecred_dsctit;
    
    -- criticas
    vr_tab_criticas dsct0003.typ_tab_critica;
    ----------------> CURSORES <----------------
    -- Pagador
    cursor cr_crapsab is
    SELECT *
    from crapsab
    where cdcooper = pr_cdcooper
    AND nrinssac = vr_nrinssac
    AND nrdconta = pr_nrdconta;
    rw_crapsab cr_crapsab%rowtype;
    
    -- Titulos (Boletos de Cobran�a)
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

           
    -- Cursor de verificar se o bordero � antigo
    CURSOR cr_crapbdt IS
      SELECT DISTINCT bdt.nrborder,bdt.flverbor, bdt.insitbdt
      FROM crapbdt bdt 
      WHERE  bdt.nrdconta = pr_nrdconta 
          AND bdt.cdcooper = pr_cdcooper
          AND bdt.nrborder = pr_nrborder
          
    ;rw_crapbdt cr_crapbdt%ROWTYPE;

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
                       'A��o Judicial' dsnegati,
                       MAX(craprpf.qtnegati),
                       MAX(craprpf.vlnegati),
                       MAX(craprpf.dtultneg)
                  FROM craprpf
                 WHERE craprpf.nrconbir = pr_nrconbir
                   AND craprpf.nrseqdet = pr_nrseqdet
                   AND craprpf.innegati = 4
                UNION ALL
                SELECT 5,
                       'Participa��o fal�ncia' dsnegati,
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
       
       /*Carrega as criticas do border*/
       
       /*
       CURSOR cr_crapabt(pr_nrdocmto IN crapcob.nrdocmto%TYPE
                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                   ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                   ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
         SELECT 
           *
         FROM 
           crapabt abt
         WHERE
           abt.cdcooper = pr_cdcooper
           AND abt.nrdconta = pr_nrdconta
           AND abt.nrborder = vr_nrborder
           AND ((abt.nrdocmto = 0 AND abt.cdbandoc = 0 AND abt.nrcnvcob = 0) OR (abt.nrdocmto=pr_nrdocmto AND abt.cdbandoc = pr_cdbandoc AND abt.nrcnvcob = pr_nrcnvcob AND abt.nrdctabb=pr_nrdctabb))
       ;
       rw_crapabt cr_crapabt%ROWTYPE;
       */
       /* Verifica se as criticas da tabela de pagador j� foram inseridas na ABT */
       /*
       CURSOR cr_crapabt_duppes(pr_nrdocmto IN crapcob.nrdocmto%TYPE
                   ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                   ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                   ,pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
         SELECT 
            CASE WHEN abt.nrseqdig = 10 THEN 1 ELSE 0 END AS qtnaopag,
            CASE WHEN abt.nrseqdig = 52 THEN 1 ELSE 0 END AS pcmxctip,
            CASE WHEN abt.nrseqdig = 90 THEN 1 ELSE 0 END AS qtremcrt,
            CASE WHEN abt.nrseqdig = 91 THEN 1 ELSE 0 END AS qttitprt
         FROM  crapabt abt
         WHERE   abt.cdcooper = pr_cdcooper 
             AND abt.nrdconta = pr_nrdconta
             AND abt.nrborder = pr_nrborder
             AND abt.nrdocmto=pr_nrdocmto AND abt.cdbandoc = pr_cdbandoc AND abt.nrcnvcob = pr_nrcnvcob AND abt.nrdctabb=pr_nrdctabb
       ;rw_crapabt_duppes cr_crapabt_duppes%ROWTYPE;
       */
       
       -- Cursor gen�rico de calend�rio
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
  BEGIN 
       vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                                  pr_delimit => ';');
       
        -- Verifica se o bordero � antigo, caso for dar erro de n�o ter informa��es.
        OPEN cr_crapbdt();
        FETCH cr_crapbdt into rw_crapbdt;
        CLOSE cr_crapbdt;
        IF rw_crapbdt.flverbor = 0 THEN
          vr_dscritic := 'N�o h� informa��es a serem exibidas.';
          RAISE vr_exc_erro;
        END IF;
     
      --    Leitura do calend�rio da cooperativa
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
        DSCT0002.pc_busca_parametros_dsctit(pr_cdcooper          => pr_cdcooper
                                   ,pr_cdagenci          => null -- N�o utiliza dentro da procedure
                                   ,pr_nrdcaixa          => null -- N�o utiliza dentro da procedure
                                   ,pr_cdoperad          => null -- N�o utiliza dentro da procedure
                                   ,pr_dtmvtolt          => null -- N�o utiliza dentro da procedure
                                   ,pr_idorigem          => null -- N�o utiliza dentro da procedure
                                   ,pr_tpcobran          => 1    -- Tipo de Cobran�a: 0 = Sem Registro / 1 = Com Registro
                                   ,pr_inpessoa          => rw_crapsab.cdtpinsc
                                   ,pr_tab_dados_dsctit  => vr_tab_dados_dsctit  --> Tabela contendo os parametros da cooperativa
                                   ,pr_tab_cecred_dsctit => vr_tab_cecred_dsctit --> Tabela contendo os parametros da cecred
                                   ,pr_cdcritic          => vr_cdcritic
                                   ,pr_dscritic          => vr_dscritic);

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
                                               --------------> OUT <--------------
                                               ,pr_pc_cedpag    => vr_liqpagcd
                                               ,pr_qtd_cedpag   => pr_qtd_cedpag
                                               ,pr_pc_conc      => vr_concpaga
                                               ,pr_qtd_conc     => pr_qtd_conc
                                               ,pr_pc_geral     => vr_liqgeral
                                               ,pr_qtd_geral    => pr_qtd_geral
                                               ,pr_cdcritic     => vr_cdcritic
                                               ,pr_dscritic     => vr_dscritic
                              );
           
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
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
  end pc_detalhes_tit_bordero;
      
      
  procedure pc_detalhes_tit_bordero_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                        ,pr_nrborder    in crapbdt.nrborder%TYPE --> numero do bordero
                                        ,pr_chave       in varchar2              --> lista de 'nosso numero' a ser pesquisado
                                        ,pr_xmllog      in varchar2              --> xml com informa��es de log
                                         --------> out <--------
                                        ,pr_cdcritic out pls_integer             --> c�digo da cr�tica
                                        ,pr_dscritic out varchar2                --> descri��o da cr�tica
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
        
    -- vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> c�d. erro
     vr_dscritic varchar2(1000);        --> desc. erro
         

    begin
      gene0004.pc_extrai_dados( pr_xml      => pr_retxml
                              , pr_cdcooper => vr_cdcooper
                              , pr_nmdatela => vr_nmdatela
                              , pr_nmeacao  => vr_nmeacao
                              , pr_cdagenci => vr_cdagenci
                              , pr_nrdcaixa => vr_nrdcaixa
                              , pr_idorigem => vr_idorigem
                              , pr_cdoperad => vr_cdoperad
                              , pr_dscritic => vr_dscritic);

                           
                           
      pc_detalhes_tit_bordero(vr_cdcooper    --> c�digo da cooperativa
                       ,pr_nrdconta          --> n�mero da conta
                       ,pr_nrborder          --> Numero do bordero
                       ,pr_chave          --> lista de 'nosso numero' a ser pesquisado
                       --------> out <--------
                       ,vr_nrinssac          --> Inscricao do sacado
                       ,vr_nmdsacad          --> Nome do sacado
                       ,vr_tab_dados_biro    -->  retorno do biro
                       ,vr_tab_dados_detalhe -->  retorno dos detalhes
                       ,vr_tab_dados_critica --> retorno das criticas
                       ,vr_cdcritic          --> c�digo da cr�tica
                       ,vr_dscritic          --> descri��o da cr�tica
                       );
          
      -- Caso tenha erro
      IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
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
                        '<liqpagcd>'  || vr_tab_dados_detalhe(0).liqpagcd || '</liqpagcd>'  ||
                        '<liqgeral>'  || vr_tab_dados_detalhe(0).liqgeral || '</liqgeral>' ||
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
          
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
               
           -- carregar xml padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                           '<root><erro>' || pr_dscritic || '</erro></root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_detalhes_tit_bordero_web ' ||sqlerrm;
           -- carregar xml padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                           '<root><erro>' || pr_dscritic || '</erro></root>');
  end pc_detalhes_tit_bordero_web;




  PROCEDURE pc_buscar_tit_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de opera��o
                                  ,pr_nrdcaixa IN INTEGER                --> N�mero do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_idorigem IN INTEGER                --> Identifica��o de origem
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_nriniseq IN NUMBER DEFAULT 0       --> Pagina��o - Inicio de sequencia
                                  ,pr_nrregist IN NUMBER DEFAULT 0       --> Pagina��o - N�mero de registros
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_tit_bordero   out  typ_tab_tit_bordero --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ) is

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulos
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Leonardo Oliveira (GFT)
    Data     : Mar�o/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que busca os detalhes e restri��es do titulo do border�
    
    Altera��o : 
              09/04/2018 - Adicionados novos campos na lista de titulos - Luis Fernando (GFT)
              21/07/2018 - Adicionado op��o de pagina��o. Utilizado na dsct0004 do IB (Paulo Penteado GFT)

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   vr_index        INTEGER;
   vr_nrinssac    number;
   vr_situacao char(1);   
   vr_ibratan char(1);
   vr_cdbircon crapbir.cdbircon%TYPE;
   vr_dsbircon crapbir.dsbircon%TYPE;
   vr_cdmodbir crapmbr.cdmodbir%TYPE;
   vr_dsmodbir crapmbr.dsmodbir%TYPE;
   restricao_cnae BOOLEAN;
   
   vr_countpag    INTEGER := 1; -- contador para controlar a paginacao
   
   vr_tab_tit_bordero        cecred.dsct0002.typ_tab_tit_bordero; --> retorna titulos do bordero
   vr_tab_tit_bordero_restri cecred.dsct0002.typ_tab_bordero_restri; --> retorna restri��es do titulos do bordero
   
   -- Tratamento de erros
   vr_exc_erro exception;
        
   vr_taxamensal NUMBER;
   vr_vldjuros NUMBER;
   vr_qtd_dias INTEGER;
   -- Informa��es de data do sistema
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
   
     pr_qtregist:= 0; -- zerando a vari�vel de quantidade de registros no cursos
     
     --carregando os dados de prazo limite da TAB052 
     -- BUSCAR O PRAZO PARA PESSOA FISICA
     dsct0002.pc_busca_titulos_bordero (
                                     pr_cdcooper                => pr_cdcooper
                                     ,pr_nrborder               => pr_nrborder
                                     ,pr_nrdconta               => pr_nrdconta   
                                     ,pr_tab_tit_bordero        => vr_tab_tit_bordero --> retorna titulos do bordero
                                     ,pr_tab_tit_bordero_restri => vr_tab_tit_bordero_restri --> retorna restri��es do titulos do bordero
                                     ,pr_cdcritic               => vr_cdcritic          --> C�digo da cr�tica
                                     ,pr_dscritic               => vr_dscritic);          --> Descri��o da cr�tica
                                     
      if  vr_cdcritic > 0  or vr_dscritic is not null then
         raise vr_exc_erro;
      end if;
      
      SELECT txmensal INTO vr_taxamensal FROM crapbdt WHERE nrborder = pr_nrborder AND cdcooper = pr_cdcooper AND nrdconta = pr_nrdconta;
      
      vr_index := vr_tab_tit_bordero.first;
      -- abrindo cursos de t�tulos
       WHILE vr_index IS NOT NULL LOOP
         IF (pr_nriniseq + pr_nrregist)=0 OR (vr_countpag >= pr_nriniseq AND vr_countpag < (pr_nriniseq + pr_nrregist)) THEN
              /*Verifica se o valor l�quido do t�tulo � 0, se for calcula*/
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
              
              vr_nrinssac := vr_tab_tit_bordero(vr_index).nrinssac;
              
              IF vr_situacao = 'N' THEN
                 --Testa se o titulo possui restricao de CNAE
                restricao_cnae := DSCT0003.fn_calcula_cnae(pr_cdcooper
                                                       ,vr_tab_tit_bordero(vr_index).nrdconta
                                                       ,vr_tab_tit_bordero(vr_index).nrdocmto
                                                       ,vr_tab_tit_bordero(vr_index).nrcnvcob
                                                       ,vr_tab_tit_bordero(vr_index).nrdctabb
                                                       ,vr_tab_tit_bordero(vr_index).cdbandoc);
                vr_situacao := CASE WHEN restricao_cnae THEN 'S' ELSE 'N' END;
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
             pr_tab_tit_bordero(vr_index).nmsacado := vr_tab_tit_bordero(vr_index).nmsacado;
             pr_tab_tit_bordero(vr_index).insittit := vr_tab_tit_bordero(vr_index).insittit;
             pr_tab_tit_bordero(vr_index).insitapr := vr_tab_tit_bordero(vr_index).insitapr;
             pr_tab_tit_bordero(vr_index).flgregis := vr_tab_tit_bordero(vr_index).flgregis;
             pr_tab_tit_bordero(vr_index).nrctrdsc := vr_tab_tit_bordero(vr_index).nrctrdsc;
             pr_tab_tit_bordero(vr_index).dssituac := vr_situacao;
             pr_tab_tit_bordero(vr_index).sitibrat := vr_ibratan;
         END IF;
         vr_countpag := vr_countpag + 1; 
            
         vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;

       pr_qtregist := vr_countpag-1;

    EXCEPTION
      WHEN OTHERS THEN
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_buscar_tit_bordero ' ||sqlerrm;
                                  
END pc_buscar_tit_bordero;
  
PROCEDURE pc_buscar_tit_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS
    /*
     * Altera��es:
     *  23/07/2018 - Vitor Shimada Assanuma: Inser��o de tratativa de N�o vencido quando Resgatado.
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
    
    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%rowtype;
    
    vr_tit_vencido INTEGER;
    
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
      
      --    Leitura do calend�rio da cooperativa
      OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat into rw_crapdat;
      CLOSE btch0001.cr_crapdat;

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_qtregist ||'" >');
                     
      -- ler os registros de titulos e incluir no xml
      vr_index := vr_tab_tit_bordero.first;
                             
      while vr_index is not null LOOP
            vr_tit_vencido := 0;
            
            --Verifica se o titulo est� vencido
            IF (vr_tab_tit_bordero(vr_index).insittit NOT IN (1,2,3))
             AND (gene0005.fn_valida_dia_util(vr_cdcooper, vr_tab_tit_bordero(vr_index).dtvencto) < rw_crapdat.dtmvtolt) THEN
              vr_tit_vencido := 1;
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
                              '<vlsldtit>' || vr_tab_tit_bordero(vr_index).vlsldtit || '</vlsldtit>' || --Saldo devedor do t�tulo
                              '<nrctrdsc>' || vr_tab_tit_bordero(vr_index).nrctrdsc || '</nrctrdsc>' || --Numero de contrato Cyber
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_buscar_titulos_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_tit_bordero_web;
    
    PROCEDURE pc_buscar_dados_bordero_web (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
                                  ,pr_dtmvtolt IN VARCHAR2 --> Data de movimenta��o do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                ) IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_dados_bordero_web
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Mar�o/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure que busca os dados do bordero e de seus titulos  e monta o xml para a tela 

  ---------------------------------------------------------------------------------------------------------------------*/


    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_qtregist         number;
    vr_vltitulo         number;
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
    
    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro
    
    -- Variaveis de tratamento do retorno
    vr_nrctrlim integer;
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
        AND crapbdt.nrctrlim = vr_nrctrlim
      ;
    rw_crapbdt cr_crapbdt%rowtype;

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

      /*Busca dados do contrato ativo*/
      pc_busca_dados_limite (pr_nrdconta
                                     ,vr_cdcooper
                                     ,3 -- desconto de titulo
                                     ,2 -- apenas ativo
                                     ,pr_dtmvtolt
                                     --------> OUT <--------
                                     ,vr_tab_dados_limite
                                     ,vr_cdcritic
                                     ,vr_dscritic
                            );
      IF (vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL) THEN
         raise vr_exc_erro;
      END IF;       
      vr_nrctrlim := vr_tab_dados_limite(0).nrctrlim;
      /*Dados do Bordero*/
      open cr_crapbdt;
      fetch cr_crapbdt into rw_crapbdt;
      IF (cr_crapbdt%NOTFOUND) THEN
        vr_dscritic := 'Border� inv�lido';
        raise vr_exc_erro;
      END IF;
      IF (rw_crapbdt.nrctrlim<>vr_tab_dados_limite(0).nrctrlim) THEN
        vr_dscritic := 'O contrato do border� difere do contrato ativo';
        raise vr_exc_erro;
      END IF;
      IF (rw_crapbdt.insitbdt>2 OR rw_crapbdt.insitapr=7) THEN -- 1 = Em estudo, 2 = Analisado -- insitapr 7 = Prazo Expirado
        vr_dscritic := 'Apenas border�es em estudo e aprovados podem ser alterados';
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
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
      vr_texto_completo := null;
      
      /*Passou nas valida��es do bordero, do contrato e listou titulos. Come�a a montar o xml*/
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
                     '</bordero>');
      
                  
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);
      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_buscar_dados_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_dados_bordero_web;
    
    PROCEDURE pc_validar_titulos_alteracao (
                                  pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_dtmvtolt IN VARCHAR2 --> Data de movimenta��o do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

    Objetivo  : Procedure para retestar os titulos do border� que est� sendo alterado

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Vari�vel de cr�ticas
   vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
   vr_qtprzmaxpj number; -- Prazo M�ximo PJ (Em dias)
   vr_qtprzmaxpf number; -- Prazo M�ximo PF (Em dias)
   
   vr_qtprzminpj number; -- Prazo M�nimo PJ (Em dias)
   vr_qtprzminpf number; -- Prazo M�nimo PF (Em dias)
   
   vr_vlminsacpj number; -- Valor m�nimo permitido por t�tulo PJ
   vr_vlminsacpf number; -- Valor m�nimo permitido por t�tulo PF
       
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
          INNER JOIN cecred.crapsab sab ON sab.nrinssac = cob.nrinssac AND sab.cdtpinsc = cob.cdtpinsc AND sab.cdcooper = cob.cdcooper AND sab.nrdconta = cob.nrdconta  
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
                                                 vr_cdagenci, --Agencia de opera��o
                                                 vr_nrdcaixa, --N�mero do caixa
                                                 vr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimenta��o
                                                 vr_idorigem, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 1, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                 pr_tab_dados_dsctit,
                                                 pr_tab_cecred_dsctit,
                                                 vr_cdcritic,
                                                 vr_dscritic);
      vr_qtprzmaxpf := pr_tab_dados_dsctit(1).qtprzmax;
      vr_qtprzminpf := pr_tab_dados_dsctit(1).qtprzmin;
      vr_vlminsacpf := pr_tab_dados_dsctit(1).vlminsac;

      -- BUSCAR O PRAZO PARA PESSOA JUR�DICA
      cecred.dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                                 vr_cdagenci, --Agencia de opera��o
                                                 vr_nrdcaixa, --N�mero do caixa
                                                 vr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimenta��o
                                                 vr_idorigem, --Identifica��o de origem
                                                 1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                 2, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
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
        /*Traz 1 linha para cada cobran�a sendo selecionada*/
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
              /*Verifica se o titulo � registrado*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).flgregis=0) THEN
                vr_dscritic:= 'T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser registrado.';
                raise vr_exc_erro;
              END IF;
              /*Verifica se o status do titulos � diferente de em aberto*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).incobran<>0) THEN
                vr_dscritic:= 'T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve estar em aberto.';
                raise vr_exc_erro;
              END IF;
              /*Testes da tab052 para PF*/
              IF (vr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc=1) THEN
                /*Verifica se o valor minimo do titulo entra na regra da tab052*/
                IF (vr_tab_dados_titulos(vr_idtabtitulo).vltitulo<vr_vlminsacpf) THEN
                  vr_dscritic:= 'Valor do T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ter valor maior que o m�nimo perimitido da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo � maior que o prazo m�nimo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)<vr_qtprzminpf) THEN
                  vr_dscritic:= 'Vencimento do T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser maior que o prazo m�nimo da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo � menor que o prazo m�ximo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)>vr_qtprzmaxpf) THEN
                  vr_dscritic:= 'Vencimento do ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser menor que o prazo m�ximo da TAB052.';
                  raise vr_exc_erro;
                END IF;
              /*Testes da tab052 para PJ*/
              ELSE 
                /*Verifica se o valor minimo do titulo entra na regra da tab052*/
                IF (vr_tab_dados_titulos(vr_idtabtitulo).vltitulo<vr_vlminsacpj) THEN
                   vr_dscritic:= 'Valor do T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ter valor maior que o m�nimo perimitido da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo � maior que o prazo m�nimo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)<vr_qtprzminpj) THEN
                  vr_dscritic:= 'Vencimento do T�tulo ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser maior que o prazo m�nimo da TAB052.';
                  raise vr_exc_erro;
                END IF;
                /*Verifica se o vencimento do titulo � menor que o prazo m�ximo da tab052*/
                IF ((vr_tab_dados_titulos(vr_idtabtitulo).dtvencto - vr_dtmvtolt)>vr_qtprzmaxpj) THEN
                  vr_dscritic:= 'Vencimento do ' || vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto || ' deve ser menor que o prazo m�ximo da TAB052.';
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
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_validar_titulos_alteracao ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');            
    END pc_validar_titulos_alteracao;
    
  PROCEDURE pc_altera_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                                   ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                                   ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                   ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                   ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao
                                   ,pr_nrborder           in crapbdt.nrborder%type   --> Border� sendo alterado
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                    --------> OUT <--------
                                    ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

      Objetivo  : Procedure para Alterar os t�tulos de um border�

    ---------------------------------------------------------------------------------------------------------------------*/
     -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
      
      vr_dslog        VARCHAR2(4000);
       --TAB
       pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
       pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
      
      vr_dtmvtopr DATE;
      rw_crapdat  btch0001.rw_crapdat%TYPE;
      vr_indrestr     INTEGER;
      vr_ind_inpeditivo  INTEGER;
       vr_tab_erro        GENE0001.typ_tab_erro;
       vr_tab_retorno_analise DSCT0003.typ_tab_retorno_analise;
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
          (SELECT SUM(craptdb.vltitulo) 
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
        
        
      /*Linha de cr�dito*/
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
            ;
      rw_craptdb cr_craptdb%rowtype;
      
      /*CURSOR do bordero sendo alterado*/
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
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                  , pr_cdcooper => vr_cdcooper
                                  , pr_nmdatela => vr_nmdatela
                                  , pr_nmeacao  => vr_nmeacao
                                  , pr_cdagenci => vr_cdagenci
                                  , pr_nrdcaixa => vr_nrdcaixa
                                  , pr_idorigem => vr_idorigem
                                  , pr_cdoperad => vr_cdoperad
                                  , pr_dscritic => vr_dscritic);
                                  
        /*VERIFICA SE O CONTRATO EXISTE E AINDA EST� ATIVO*/
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF (cr_craplim%NOTFOUND) THEN
          vr_dscritic := 'Contrato n�o encontrado ou inativo.';
          raise vr_exc_erro;
        END IF;
        vr_cddlinha := rw_craplim.cddlinha;
          
        OPEN cr_crapldc;
        FETCH cr_crapldc INTO rw_crapldc;
        IF (cr_crapldc%NOTFOUND) THEN
           vr_dscritic := 'Linha de cr�dito n�o encontrada.';
           raise vr_exc_erro;
        END IF;
          
       vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
       IF (rw_craplim.dtfimvig <vr_dtmvtolt) THEN
           vr_dscritic := 'A vig�ncia do contrato deve ser maior que a data de movimenta��o do sistema.';
         raise vr_exc_erro;
       END IF;
       
       OPEN cr_crapass;
       FETCH cr_crapass INTO rw_crapass;
       IF (cr_crapass%NOTFOUND) THEN
          vr_dscritic := 'Cooperado n�o cadastrado';
          raise vr_exc_erro;
       END IF;

        --carregando os dados de prazo limite da TAB052 
       dsct0002.pc_busca_parametros_dsctit(vr_cdcooper, --pr_cdcooper,
                                                   null, --Agencia de opera��o
                                                   null, --N�mero do caixa
                                                   null, --Operador
                                                   vr_dtmvtolt, -- Data da Movimenta��o
                                                   null, --Identifica��o de origem
                                                   1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                                   rw_crapass.inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
                                                   pr_tab_dados_dsctit,
                                                   pr_tab_cecred_dsctit,
                                                   vr_cdcritic,
                                                   vr_dscritic);
       
        pc_listar_titulos_resumo(vr_cdcooper  --> C�digo da Cooperativa
                         ,pr_nrdconta --> N�mero da Conta
                         ,pr_chave    --> Lista de 'chaves' de titulos a serem pesquisado
                         --------> OUT <--------
                         ,vr_qtregist --> Quantidade de registros encontrados
                         ,vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                         ,vr_cdcritic --> C�digo da cr�tica
                         ,vr_dscritic --> Descri��o da cr�tica
                         );
                         
      /*VERIFICA SE O VALOR DOS BOLETOS S�O > QUE O DISPONIVEL NO CONTRATO*/
        vr_index := vr_tab_dados_titulos.first;
        vr_vldtit := 0;
        WHILE vr_index IS NOT NULL LOOP
              /*Antes de realizar a inclus�o dever� validar se algum t�tulo j� foi selecionado em algum outro 
              border� com situa��o diferente de �n�o aprovado� ou �prazo expirado�*/
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
                   vr_dscritic := 'T�tulo ' ||rw_craptdb.nrdocmto || ' j� selecionado em outro border�';
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
          vr_dscritic := 'O Total de t�tulos selecionados supera o valor dispon�vel no contrato.';
          raise vr_exc_erro;
        END IF;
        
        /*Passou nas valida��es todas, come�a a fazer as respectivas altera��es*/
        OPEN cr_crapbdt;
        FETCH cr_crapbdt INTO rw_crapbdt;
        IF cr_crapbdt%NOTFOUND THEN
          vr_dscritic := 'Ocorreu um erro ao carregar o border� para altera��o';
          raise vr_exc_erro;
        END IF;
        IF (rw_crapbdt.insitbdt>2) THEN
          vr_dscritic := 'Border� deve estar Em estudo ou Aprovado';
          raise vr_exc_erro;
        END IF;
        IF (rw_crapbdt.cdoperad<>vr_cdoperad) THEN
          vr_dscritic := 'Operador deve ser o mesmo que criou o border�';
          raise vr_exc_erro;
        END IF;
        
        /*Altera os dados necess�rios do lote*/
        UPDATE
            craplot
        SET
            craplot.qtinfoln = vr_qtregist,
            craplot.vlinfodb = vr_vldtit,
            craplot.vlinfocr = vr_vldtit,
            craplot.vlcompcr = vr_vldtit,
            craplot.qtcompln = vr_qtregist
        WHERE
            craplot.cdbccxlt = 700
            AND craplot.nrdolote = rw_crapbdt.nrdolote
            AND craplot.cdcooper = rw_crapbdt.cdcooper
            AND craplot.tplotmov = 34
            AND craplot.dtmvtolt = vr_dtmvtolt --Altera o lote apenas se a data de movimentacao seja a mesma do lote
        ;
        
        vr_dslog := pr_dtmvtolt || ' ' || ' Operador ' || vr_cdoperad || ' Alterou o bordero ' ||pr_nrborder ;
        
        vr_chave := replace(pr_chave,',',''',''');
        /*Remove t�tulos do bordero que foram removidos da tela de sele��o de titulos na altera��o*/
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
                  
                 vr_dslog := vr_dslog || ' Excluindo o titulo ' || 
                                           vr_tab_titulos_excluir(vr_idtabtitulo).nrdconta || ' ' ||
                                           vr_tab_titulos_excluir(vr_idtabtitulo).nrcnvcob || ' ' || 
                                           vr_tab_titulos_excluir(vr_idtabtitulo).nrdocmto || ' ';
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
                 vr_dslog := vr_dslog || ' Incluindo o titulo ' || 
                                           vr_tab_dados_titulos(vr_index).nrdconta || ' ' ||
                                           vr_tab_dados_titulos(vr_index).nrcnvcob || ' ' || 
                                           vr_tab_dados_titulos(vr_index).nrdocmto || ' ';
              vr_inseriu := true;
            END IF;
            vr_index  := vr_tab_dados_titulos.next(vr_index);
        END   LOOP;

 --       IF vr_inseriu  THEN
           UPDATE
              crapbdt
           SET
              crapbdt.insitbdt = 1, --Em Estudo
              crapbdt.insitapr = 0,
              crapbdt.dtenvmch = NULL,
              crapbdt.nrseqtdb = vr_idtabtitulo,
              crapbdt.dtanabor = NULL -- Limpa a data de analise, pois necessita nova analise
           WHERE
              crapbdt.nrborder = pr_nrborder
              AND crapbdt.cdcooper = vr_cdcooper
              AND crapbdt.nrdconta = pr_nrdconta
           ;
/*        ELSE
           UPDATE
              crapbdt
           SET
              insitbdt = 1, --Em Estudo
              insitapr = 0
           WHERE
              crapbdt.nrborder = pr_nrborder
              AND crapbdt.cdcooper = vr_cdcooper
              AND crapbdt.nrdconta = pr_nrdconta
        END IF;*/

        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || 'DESCTO_TIT' || ' --> '
                                                   || vr_dslog
                                  ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',vr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));

        -- Chamar gera��o de LOG
       gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => vr_dscritic
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Border� n ' || pr_nrborder || ' alterado com sucesso.'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
                        
        -- Se encontrar
        open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        fetch btch0001.cr_crapdat into rw_crapdat;
        IF BTCH0001.cr_crapdat%FOUND THEN
          vr_dtmvtopr:= rw_crapdat.dtmvtopr;
        END IF;
        CLOSE btch0001.cr_crapdat;  
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
                                        ,pr_indrestr => vr_indrestr --> Indica se Gerou Restri��o (0 - Sem Restri��o / 1 - Com restri��o)
                                        ,pr_ind_inpeditivo => vr_ind_inpeditivo  --> Indica se o Resultado � Impeditivo para Realizar Libera��o. (0 - Sem Impedimentos / 1 - Com Impedimentos)
                                        ,pr_tab_erro => vr_tab_erro --  OUT GENE0001.typ_tab_erro --> Tabela Erros
                                        ,pr_tab_retorno_analise => vr_tab_retorno_analise --OUT typ_tab_retorno_analise --> Detalhes Finais da Analise do Bordero.
                                        ,pr_cdcritic => vr_cdcritic          --> C�digo da cr�tica
                                        ,pr_dscritic => vr_dscritic             --> Descri�ao da cr�tica
                                      );

        IF  nvl(vr_cdcritic,0) > 0 OR vr_dscritic is NOT null then
          /* buscar a descri�ao */
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
             
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Dados><inf>Border� n' || pr_nrborder || ' alterado com sucesso.</inf></Dados></Root>');

      exception
        when vr_exc_erro then
             /*  se foi retornado apenas c�digo */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descri�ao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            ROLLBACK;
        when others then
             /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_altera_bordero ' ||sqlerrm;
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
                                       ,pr_xmllog      in varchar2              --> xml com informa��es de log
                                       --------> out <--------
                                       ,pr_cdcritic out pls_integer             --> c�digo da cr�tica
                                       ,pr_dscritic out varchar2                --> descri��o da cr�tica
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

      Objetivo  : Procedure para os resgates dos t�tulos chamada pelo Ayllos WEB

    ---------------------------------------------------------------------------------------------------------------------*/
                                       

       -- Vari�vel de cr�ticas
       vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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
          craplim.dtfimvig
        FROM 
          craplim
        where 
          craplim.cdcooper = vr_cdcooper
          AND craplim.tpctrlim = 3
          AND craplim.nrdconta = pr_nrdconta
          AND craplim.nrctrlim = pr_nrctrlim
        ;
      rw_craplim cr_craplim%rowtype;
      
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
        
      /*Linha de cr�dito*/
      
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
      
      /*T�tulos sendo resgatados*/ 
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
         gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                 ,pr_cdcooper => vr_cdcooper
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_nmeacao  => vr_nmeacao
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
                                          
          /*VERIFICA SE O CONTRATO EXISTE E AINDA EST� ATIVO*/
         OPEN cr_craplim;
         FETCH cr_craplim INTO rw_craplim;
         IF (cr_craplim%NOTFOUND) THEN
           vr_dscritic := 'Contrato n�o encontrado.';
           raise vr_exc_erro;
         END IF;
         
         OPEN cr_crapass;
         FETCH cr_crapass INTO rw_crapass;
         IF (cr_crapass%NOTFOUND) THEN
            vr_dscritic := 'Cooperado n�o cadastrado';
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
         /*Traz 1 linha para cada cobran�a sendo selecionada*/
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
                 vr_dscritic := 'T�tulo ' || vr_tab_dados_titulos(0).nrdocmto || ' est� vencido ';
                 raise vr_exc_erro;
               END IF;
               IF (vr_tab_dados_titulos(vr_idtabtitulo).insittit<>4) THEN
                 vr_dscritic := 'T�tulo ' || vr_tab_dados_titulos(0).nrdocmto || ' n�o est� liberado ';
                 raise vr_exc_erro; 
               END IF;
               /*Carrega o bordero do titulo selecionado*/
               vr_nrborder := vr_tab_dados_titulos(vr_idtabtitulo).nrborder;
               OPEN cr_crapbdt;
               FETCH cr_crapbdt INTO rw_crapbdt;
               IF (cr_crapbdt%NOTFOUND) THEN
                  vr_dscritic := 'Border� ' || vr_nrborder || ' n�o cadastrado';
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
                                                   '<Root><Dados>T�tulos resgatados com sucesso</Dados></Root>');
       exception
           when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
             
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       when others then
            /* montar descri�ao de erro nao tratado */
            pr_dscritic := 'erro nao tratado na tela_titcto.pc_resgate_titulo_bordero_web ' ||sqlerrm;
            -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_resgate_titulo_bordero_web;
    
    PROCEDURE pc_buscar_titulos_resgate (pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de opera��o
                                  ,pr_nrdcaixa IN INTEGER                --> N�mero do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_idorigem IN INTEGER                --> Identifica��o de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Border�
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  --------> OUT <--------
                                  ,pr_qtregist         out integer         --> Quantidade de registros encontrados
                                  ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ) IS
      
      -- Vari�vel de cr�ticas
      vr_dscritic varchar2(1000);        --> Desc. Erro
      
      vr_dtmvtolt    DATE;
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
             cob.nrcnvcob, -- conv�nio
             cob.nrdocmto, -- nr. boleto
             cob.nrinssac, -- cpf/cnpj do Pagador (Antigo SACADO)
             sab.nmdsacad, -- nome do pagador (o campo NMDSACAD da crapcob n�o est� preenchido...)
             cob.dtvencto, -- data de vencimento
             cob.dtmvtolt, -- data de movimento
             cob.vltitulo,  -- valor do t�tulo
             cob.nrnosnum, -- nosso numero 
             cob.flgregis, -- flag registrado.
             cob.cdtpinsc,  -- Codigo do tipo da inscricao do sacado(0-nenhum/1-CPF/2-CNPJ)
             tdb.nrborder,   -- N�mero do Border�
             cob.cdbandoc,
             cob.nrdctabb
        FROM crapcob cob -- titulos
             INNER JOIN crapsab sab ON sab.nrinssac = cob.nrinssac 
                                                 AND sab.cdtpinsc = cob.cdtpinsc
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
         -- Filtros Vari�veis - Tela
         AND (cob.nrinssac = pr_nrinssac OR nvl(pr_nrinssac,0)=0)
         AND (cob.vltitulo = pr_vltitulo OR nvl(pr_vltitulo,0)=0)
         AND (cob.dtvencto = vr_dtvencto OR vr_dtvencto IS NULL)
         AND (cob.nrnosnum LIKE '%'||pr_nrnosnum||'%' OR nvl(pr_nrnosnum,0)=0) -- o campo correto para "Nosso N�mero"
         AND (tdb.nrborder = pr_nrborder OR nvl(pr_nrborder,0)=0)
         AND tdb.insittit = 4
         AND bdt.insitbdt = 3
         AND tdb.dtvencto > vr_dtmvtolt
         AND tdb.nrctrlim = pr_nrctrlim
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
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
        vr_dtvencto := null;
        IF (pr_dtvencto IS NOT NULL ) THEN
           vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
           -- Caso a data de vencimento colocada seja menor a data atual -48h
           IF (vr_dtvencto - 2) <= vr_dtmvtolt THEN
             vr_dscritic := 'Opera��o n�o permitida. Prazo para resgate excedido.';
             RAISE vr_exc_erro;
           END IF;
        END IF;
        
        pr_qtregist := 0;
        -- abrindo cursos de t�tulos
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
          pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
             /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_buscar_titulos_resgate ' ||sqlerrm;                              
    END pc_buscar_titulos_resgate;
    
    PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimenta��o
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Border�
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

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

      pc_buscar_titulos_resgate(vr_cdcooper  --> C�digo da Cooperativa
                       ,pr_nrdconta --> N�mero da Conta
                       ,vr_cdagenci --> Agencia de opera��o
                       ,vr_nrdcaixa --> N�mero do caixa
                       ,vr_cdoperad --> Operador
                       ,pr_dtmvtolt --> Data da Movimenta��o
                       ,vr_idorigem --> Identifica��o de origem
                       ,pr_nrinssac --> Filtro de Inscricao do Pagador
                       ,pr_vltitulo --> Filtro de Valor do titulo
                       ,pr_dtvencto --> Filtro de Data de vencimento
                       ,pr_nrnosnum --> Filtro de Nosso Numero
                       ,pr_nrctrlim --> Contrato
                       ,pr_nrborder --> Border�
                       ,pr_insitlim --> Status
                       ,pr_tpctrlim --> Tipo de desconto
                       --------> OUT <--------
                       ,vr_qtregist --> Quantidade de registros encontrados
                       ,vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                       ,vr_cdcritic --> C�digo da cr�tica
                       ,vr_dscritic --> Descri��o da cr�tica
                       );
      
      -- Caso tenha alguma cr�tica
      IF (nvl(vr_cdcritic,0) > 0) OR (vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informa�oes do xml
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

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_resgate_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_titulos_resgate_web;
    
    PROCEDURE pc_titulos_resumo_resgatar_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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
     
      -- Vari�vel de cr�ticas
       vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
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

        pc_listar_titulos_resumo(vr_cdcooper  --> C�digo da Cooperativa
                         ,pr_nrdconta  --> Conta do associado
                         ,pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
                         --------> OUT <--------
                         ,vr_qtregist --> Quantidade de registros encontrados
                         ,vr_tab_dados_titulos --> Tabela de retorno dos t�tulos encontrados
                         ,vr_cdcritic --> C�digo da cr�tica
                         ,vr_dscritic --> Descri��o da cr�tica
                         );
        
        -- inicializar o clob
        vr_des_xml := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        -- inicilizar as informa�oes do xml
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

        /* liberando a mem�ria alocada pro clob */
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
        
      exception
        when vr_exc_erro then
             /*  se foi retornado apenas c�digo */
             if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
                 /* buscar a descri�ao */
                 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             end if;
             /* variavel de erro recebe erro ocorrido */
             pr_cdcritic := nvl(vr_cdcritic,0);
             pr_dscritic := vr_dscritic;
             
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_titulos_resumo_resgatar_web ' ||sqlerrm;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_titulos_resumo_resgatar_web;

    PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                                 ,pr_cdcooper IN crapbdt.cdcooper%TYPE
                                 ,pr_dtmvtolt IN VARCHAR2
                                     --------> OUT <--------
                                 ,pr_qtregist OUT INTEGER
                                 ,pr_tab_borderos   out  typ_tab_borderos --> Tabela de retorno
                                 ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
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

      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
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

       CASE BDT.INSITBDT WHEN 1 THEN 'EM ESTUDO'
                         WHEN 2 THEN 'ANALISADO'
                         WHEN 3 THEN 'LIBERADO'
                         WHEN 4 THEN 'LIQUIDADO'
                         WHEN 5 THEN 'REJEITADO'
                         ELSE        'PROBLEMA'
       END DSSITBDT,
       COUNT(1) over() qtregistro,
       --  0-Aguardando An�lise, 1-Aguardando Checagem, 2-Checagem, 3-Aprovado Automaticamente, 4-Aprovado, 5-N�o aprovado, 6-Enviado Esteira, 7-Prazo expirado';
       CASE BDT.INSITAPR WHEN 0 THEN 'AGUARDANDO ANALISE'
                         WHEN 1 THEN 'AGUARDANDO CHECAGEM'
                         WHEN 2 THEN 'CHECAGEM'
                         WHEN 3 THEN 'APROVADO AUTOMATICAMENTE'
                         WHEN 4 THEN 'APROVADO'
                         WHEN 5 THEN 'NAO APROVADO'
                         WHEN 6 THEN 'ENVIADO ESTEIRA'
                         WHEN 7 THEN 'PRAZO EXPIRADO'
                         ELSE        'PROBLEMA'
       END DSINSITAPR
       FROM CRAPBDT BDT
       WHERE
       BDT.CDCOOPER = pr_cdcooper
       AND BDT.NRDCONTA = pr_nrdconta
       ORDER BY NRBORDER DESC;
      rw_crapbdt cr_crapbdt%ROWTYPE;


      -- Buscar os t�tulos
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

        pr_qtregist:= 0; -- zerando a vari�vel de quantidade de registros no cursor


        vr_dt_aux_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/YYYY') - 120;
        vr_dt_aux_dtlibbdt := to_date(pr_dtmvtolt, 'DD/MM/YYYY') - 90;

        -- abrindo cursos de t�tulos
        OPEN  cr_crapbdt;
        LOOP
               FETCH cr_crapbdt INTO rw_crapbdt;
               EXIT  WHEN cr_crapbdt%NOTFOUND;


               pr_qtregist := pr_qtregist + 1;
               vr_idxbordero := pr_tab_borderos.count + 1;

                IF (rw_crapbdt.dtmvtolt <= vr_dt_aux_dtmvtolt AND ( rw_crapbdt.insitbdt IN(1,2))) THEN
                  CONTINUE;
                END IF;


               IF (rw_crapbdt.dtlibbdt is not null and rw_crapbdt.dtmvtolt <= vr_dt_aux_dtlibbdt AND ( rw_crapbdt.insitbdt IN(4))) THEN
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


        END LOOP;
        CLOSE  cr_crapbdt;

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_borderos ' ||sqlerrm;
    END pc_busca_borderos;




    PROCEDURE pc_busca_borderos_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data de movimentacao do sistema
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informa��es de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                  ) IS


    vr_tab_borderos  typ_tab_borderos;          --> retorna dos dados
    vr_index pls_integer;


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


    -- Vari�vel de cr�ticas
     vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro


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

       pc_busca_borderos (pr_nrdconta,
                          vr_cdcooper,
                          pr_dtmvtolt,
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
      -- inicilizar as informa�oes do xml
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

                           '</inf>'
            );
            vr_index := vr_tab_borderos.next(vr_index);
      end loop;

      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a mem�ria alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    exception
      when vr_exc_erro then
           /*  se foi retornado apenas c�digo */
           if  nvl(vr_cdcritic,0) > 0 and vr_dscritic is null then
               /* buscar a descri�ao */
               vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
           end if;
           /* variavel de erro recebe erro ocorrido */
           pr_cdcritic := nvl(vr_cdcritic,0);
           pr_dscritic := vr_dscritic;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_borderos_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_busca_borderos_web;
    
  PROCEDURE pc_contingencia_ibratan_web(pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                 --------> OUT <--------
                                 ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                 ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
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

    Objetivo  : Procedure para retornar se a esteira e o motor de cr�dito est�o em contingencia

    Altera��o :

  ---------------------------------------------------------------------------------------------------------------------*/

  -- Vari�vel de cr�ticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
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

    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);

  EXCEPTION
    WHEN vr_exc_erro THEN
         IF  nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         pr_cdcritic := nvl(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;

         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
         ROLLBACK;
    WHEN OTHERS THEN
         pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_contingencia_ibratan_web ' ||sqlerrm;
         
         pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
         ROLLBACK;
  END pc_contingencia_ibratan_web ;

END TELA_ATENDA_DSCTO_TIT;
/
