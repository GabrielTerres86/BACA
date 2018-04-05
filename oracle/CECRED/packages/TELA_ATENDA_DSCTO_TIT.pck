CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------

    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 01/03/2018

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
                  nossonum VARCHAR2(50),
                  vltitulo craptdb.vltitulo%TYPE,
                  vlliquid craptdb.vlliquid%TYPE,
                  nmsacado crapsab.nmdsacad%TYPE,
                  flgregis crapcob.flgregis%TYPE,
                  insittit craptdb.insittit%TYPE);

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
        dtdpagto       crapcob.dtdpagto%TYPE
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
        qtutiliz    INTEGER
        
  );

  TYPE typ_tab_dados_limite IS TABLE OF typ_reg_dados_limite INDEX BY BINARY_INTEGER;
  
/*Tabela que armazena as informações da proposta de limite de desconto de titulo*/
type typ_reg_dados_proposta is record
     (nrdconta       craplim.nrdconta%type
     ,insitlim       craplim.insitlim%type
     ,dtpropos       craplim.dtpropos%type
     ,dtinivig       craplim.dtinivig%type
     ,inbaslim       craplim.inbaslim%type
     ,vllimite       craplim.vllimite%type
     ,nrctrlim       craplim.nrctrlim%type
     ,cdmotcan       craplim.cdmotcan%type
     ,dtfimvig       craplim.dtfimvig%type
     ,qtdiavig       craplim.qtdiavig%type
     ,cdoperad       craplim.cdoperad%type
     ,dsencfin##1    craplim.dsencfin##1%type
     ,dsencfin##2    craplim.dsencfin##2%type
     ,dsencfin##3    craplim.dsencfin##3%type
     ,flgimpnp       craplim.flgimpnp%type
     ,nrctaav1       craplim.nrctaav1%type
     ,nrctaav2       craplim.nrctaav2%type
     ,dsendav1##1    craplim.dsendav1##1%type
     ,dsendav1##2    craplim.dsendav1##2%type
     ,dsendav2##1    craplim.dsendav2##1%type
     ,dsendav2##2    craplim.dsendav2##2%type
     ,nmdaval1       craplim.nmdaval1%type
     ,nmdaval2       craplim.nmdaval2%type
     ,dscpfav1       craplim.dscpfav1%type
     ,dscpfav2       craplim.dscpfav2%type
     ,nmcjgav1       craplim.nmcjgav1%type
     ,nmcjgav2       craplim.nmcjgav2%type
     ,dscfcav1       craplim.dscfcav1%type
     ,dscfcav2       craplim.dscfcav2%type
     ,tpctrlim       craplim.tpctrlim%type
     ,qtrenova       craplim.qtrenova%type
     ,cddlinha       craplim.cddlinha%type
     ,dtcancel       craplim.dtcancel%type
     ,cdopecan       craplim.cdopecan%type
     ,cdcooper       craplim.cdcooper%type
     ,qtrenctr       craplim.qtrenctr%type
     ,cdopelib       craplim.cdopelib%type
     ,nrgarope       craplim.nrgarope%type
     ,nrinfcad       craplim.nrinfcad%type
     ,nrliquid       craplim.nrliquid%type
     ,nrpatlvr       craplim.nrpatlvr%type
     ,idquapro       craplim.idquapro%type
     ,nrperger       craplim.nrperger%type
     ,vltotsfn       craplim.vltotsfn%type
     ,flgdigit       craplim.flgdigit%type
     ,dtrenova       craplim.dtrenova%type
     ,tprenova       craplim.tprenova%type
     ,dsnrenov       craplim.dsnrenov%type
     ,nrconbir       craplim.nrconbir%type
     ,dtconbir       craplim.dtconbir%type
     ,inconcje       craplim.inconcje%type
     ,cdopeori       craplim.cdopeori%type
     ,cdageori       craplim.cdageori%type
     ,dtinsori       craplim.dtinsori%type
     ,cdopeexc       craplim.cdopeexc%type
     ,cdageexc       craplim.cdageexc%type
     ,dtinsexc       craplim.dtinsexc%type
     ,dtrefatu       craplim.dtrefatu%type
     ,insitblq       craplim.insitblq%type
     ,insitest       craplim.insitest%type
     ,dtenvest       craplim.dtenvest%type
     ,hrenvest       craplim.hrenvest%type
     ,cdagenci       craplim.cdagenci%type
     ,hrinclus       craplim.hrinclus%type
     ,dtdscore       craplim.dtdscore%type
     ,dsdscore       craplim.dsdscore%type
     ,cdopeste       craplim.cdopeste%type
     ,flgaprvc       craplim.flgaprvc%type
     ,dtenefes       craplim.dtenefes%type
     ,dsprotoc       craplim.dsprotoc%type
     ,dtaprova       craplim.dtaprova%type
     ,insitapr       craplim.insitapr%type
     ,cdopeapr       craplim.cdopeapr%type
     ,hraprova       craplim.hraprova%type
     ,dtmanute       craplim.dtmanute%type
     ,dtenvmot       craplim.dtenvmot%type
     ,hrenvmot       craplim.hrenvmot%type
     ,dsnivris       craplim.dsnivris%type
     ,dsobscmt       craplim.dsobscmt%type
     ,dtrejeit       craplim.dtrejeit%type
     ,hrrejeit       craplim.hrrejeit%type
     ,cdoperej       craplim.cdoperej%type
     ,ininadim       craplim.ininadim%type
     ,dssitlim       varchar2(100)
     ,dssitest       varchar2(100)
     ,dssitapr       varchar2(100) );

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
     concpaga        number,
     liqpagcd        number,
     liqgeral        number
);
TYPE typ_tab_dados_detalhe IS TABLE OF typ_reg_dados_detalhe INDEX BY BINARY_INTEGER;
  
  
/*Tabela de retorno dos dados obtidos para as criticas*/
TYPE typ_reg_dados_critica IS RECORD(
     dsc                   VARCHAR2(225),
     varint               NUMBER(5), -- numero
     varper               NUMBER(5,2) --percentual
);

TYPE typ_tab_dados_critica IS TABLE OF typ_reg_dados_critica INDEX BY BINARY_INTEGER;  

--> Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.
PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                   --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  );

--> Procedure para validação de informações ante de efetuar a confirmação do novo limite
PROCEDURE pc_validar_confirm_novo_limite(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in craplim.nrctrlim%type --> Contrato
                                        ,pr_vllimite    in craplim.vllimite%type --> Valor do limite de desconto
                                         --------> OUT <--------
                                        ,pr_cdagenci    out crapass.cdagenci%type --> Codigo da agencia
                                        ,pr_tab_crapdat out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic    out pls_integer          --> Código da crítica
                                        ,pr_dscritic    out varchar2             --> Descrição da crítica
                                        );

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
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


--> Função que retorna se o Serviço IBRATAN está em Contigência ou Não.
FUNCTION fn_em_contingencia_ibratan(pr_cdcooper IN crapcop.cdcooper%TYPE)
  RETURN BOOLEAN;


PROCEDURE pc_confirmar_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                       --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo


PROCEDURE pc_confirmar_novo_limite(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim    IN craplim.nrctrlim%TYPE --> Contrato
                                  ,pr_tpctrlim    IN craplim.tpctrlim%TYPE --> Tipo de contrato de limite(2-Cheque / 3-Titulo)
                                  ,pr_vllimite    IN craplim.vllimite%TYPE --> Valor do Limite
                                  ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Código do Operador
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Codigo da Agencia
                                  ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                  ,pr_idorigem    IN INTEGER               --> Identificador Origem Chamada
                                  ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE --> Tipo de registro de datas
                                  ,pr_insitapr    IN craplim.insitapr%TYPE    --> Decisão (Dependente do Retorno da Análise)                                  
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                  );


PROCEDURE pc_negar_proposta(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                           ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                           ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                            --------> OUT <--------
                           ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
  

PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
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
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_cddlinha  IN crapldc.cddlinha%TYPE --> Código da Linha
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      --------> OUT <--------
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
                                      
PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
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
                                   ,pr_dtmvtolt IN VARCHAR2
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
                                      
PROCEDURE pc_obtem_dados_proposta_web(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                     ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                      -- OUT
                                     ,pr_cdcritic out pls_integer          --> Codigo da critica
                                     ,pr_dscritic out varchar2             --> Descric?o da critica
                                     ,pr_retxml   in out nocopy xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                     ,pr_des_erro out varchar2             --> Erros do processo
                                     );
                                     
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                 ,pr_qtregist           out integer                --> Qtde total de registros
                                 ,pr_tab_dados_titulos   out  typ_tab_dados_titulos --> Tabela de retorno
                                 ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                 ,pr_dscritic           out varchar2               --> Descricao da critica
                                 );
                                 
PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                   ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                );
                                
PROCEDURE pc_solicita_biro_bordero(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrnosnum in varchar2              --> Lista de 'nosso numero' a ser pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  );
                                  
PROCEDURE pc_insere_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                                 ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                 ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao 
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
                             ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                             ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscrição do sacado
                             ,pr_nmdsacad           out crapsab.nmdsacad%TYPE   --> Nome do Sacado
                             ,pr_tab_dados_biro     out  typ_tab_dados_biro    --> Tabela de retorno biro
                             ,pr_tab_dados_detalhe  out  typ_tab_dados_detalhe --> Tabela de retorno detalhe
                             ,pr_tab_dados_critica  out  typ_tab_dados_critica --> Tabela de retorno critica
                             ,pr_cdcritic           out pls_integer            --> Codigo da critica
                             ,pr_dscritic           out varchar2               --> Descricao da critica
                             );

procedure pc_detalhes_tit_bordero_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                      ,pr_nrnosnum    in varchar2              --> lista de 'nosso numero' a ser pesquisado
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
                                  --------> PARMAS <--------
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
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
      
                                  
END TELA_ATENDA_DSCTO_TIT;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_DSCTO_TIT IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_ATENDA_DSCTO_TIT
    Sistema  : Ayllos Web
    Autor    : Paulo Penteado (GFT) / Gustavo Sene (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 01/03/2018

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
  ---------------------------------------------------------------------------------------------------------------------*/

PROCEDURE pc_validar_data_proposta(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de contrato de limite(2-Cheque e 3-Titulo)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 28/02/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Procedure para validar a analise de limite, não permitir efetuar analise para limites antigos.

    Alteração : 28/02/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;

   vr_dtviglim date;

   --> Buscar Contrato de limite
   cursor cr_craplim is
   select 1
   from   craplim lim
   where  lim.dtpropos < vr_dtviglim
   and    lim.cdcooper = pr_cdcooper
   and    lim.nrdconta = pr_nrdconta
   and    lim.nrctrlim = pr_nrctrlim
   and    lim.tpctrlim = pr_tpctrlim;
   rw_craplim cr_craplim%rowtype;

BEGIN
   vr_dtviglim := to_date(gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                   ,pr_cdcooper => 0
                                                   ,pr_cdacesso => 'DT_VIG_LIMITE_DESC_TIT'), 'DD/MM/RRRR');

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%found then
         close cr_craplim;
         vr_dscritic := 'Esta proposta foi incluída no processo antigo. Favor cancela-la e incluir novamente através do novo processo.';
         raise vr_exc_erro;
   end   if;
   close cr_craplim;

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


PROCEDURE pc_validar_confirm_novo_limite(pr_cdcooper    in crapcop.cdcooper%type --> Código da Cooperativa
                                        ,pr_nrdconta    in crapass.nrdconta%type --> Número da Conta
                                        ,pr_nrctrlim    in craplim.nrctrlim%type --> Contrato
                                        ,pr_vllimite    in craplim.vllimite%type --> Valor do limite de desconto
                                         --------> OUT <--------
                                        ,pr_cdagenci    out crapass.cdagenci%type --> Codigo da agencia
                                        ,pr_tab_crapdat out btch0001.rw_crapdat%type --> Tipo de registro de datas
                                        ,pr_cdcritic    out pls_integer          --> Código da crítica
                                        ,pr_dscritic    out varchar2             --> Descrição da crítica
                                        ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_validar_confirm_novo_limite
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Sene (GFT)
    Data     : Março/2018                   Ultima atualizacao: 03/03/2018

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
   and    tpctrlim = 3; -- 3 = Título
   rw_crapcdc cr_crapcdc%rowtype;

   -- Verifica limite
   cursor cr_craplim is
   select nrctrlim
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    tpctrlim = 3
   and    insitlim = 2;
   rw_craplim cr_craplim%rowtype;

   --     Verifica limite
   cursor cr_craplim_ctr is
   select insitlim
         ,insitest
         ,insitapr
         ,vllimite
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = 3; -- 3 = Título
   rw_craplim_ctr cr_craplim_ctr%rowtype;

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

   --    Verifica se ja existe lancamento
   open  cr_crapcdc;
   fetch cr_crapcdc into rw_crapcdc;
   if    cr_crapcdc%found then
         close cr_crapcdc;
         vr_cdcritic := 92;
         raise vr_exc_saida;
   end   if;
   close cr_crapcdc;

   --    Verifica se ja existe limite ativo
   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%found then
         close cr_craplim;
         vr_dscritic:= 'O contrato ' ||rw_craplim.nrctrlim || ' deve ser cancelado primeiro.';
         raise vr_exc_saida;
   end   if;
   close cr_craplim;

   --    Verifica se ja existe limite ativo
   open  cr_craplim_ctr;
   fetch cr_craplim_ctr into rw_craplim_ctr;
   if    cr_craplim_ctr%notfound then
         close cr_craplim_ctr;
         vr_cdcritic := 484;
         raise vr_exc_saida;
   end   if;
   close cr_craplim_ctr;

   --  Verifica se a situação do Limite está 'Em Estudo' ou 'Aprovado'
   if  rw_craplim_ctr.insitlim NOT IN (1,5) then
       vr_dscritic := 'Para esta operação, as Situações do Limite devem ser: "Em Estudo" ou "Aprovado".';
       raise vr_exc_saida;
   end if;

   --  Verifica se a situação da Análise está 'Não Enviado' ou 'Análise Finalizada'
   if  rw_craplim_ctr.insitest NOT IN (0,3) then
       vr_dscritic := 'Para esta operação, as Situações da Análise devem ser: "Não Enviado" ou "Análise Finalizada".';
       raise vr_exc_saida;
   end if;

   --  Verifica se o limite está diferente do registro
   if  rw_craplim_ctr.vllimite <> pr_vllimite then
       vr_cdcritic := 91;
       raise vr_exc_saida;
   end if;

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
       pr_dscritic := replace(replace('Erro pc_validar_data_proposta: ' || sqlerrm, chr(13)),chr(10));

END pc_validar_confirm_novo_limite;

PROCEDURE pc_analisar_proposta(pr_tpenvest in varchar2               --> Tipo do envio esteira
                              ,pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                              ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
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
    Programa : pc_validar_data_proposta
    Sistema  : Cred
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 28/02/2018

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

   gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                           ,pr_cdcooper => vr_cdcooper
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nmeacao  => vr_nmeacao
                           ,pr_cdagenci => vr_cdagenci
                           ,pr_nrdcaixa => vr_nrdcaixa
                           ,pr_idorigem => vr_idorigem
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => vr_dscritic);

   este0003.pc_enviar_proposta_esteira(pr_cdcooper => vr_cdcooper
                                      ,pr_cdagenci => vr_cdagenci
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_idorigem => vr_idorigem
                                      ,pr_tpenvest => pr_tpenvest
                                      ,pr_nrctrlim => pr_nrctrlim
                                      ,pr_tpctrlim => pr_tpctrlim
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_dtmovito => pr_dtmovito
                                      ,pr_dsmensag => vr_dsmensag
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_des_erro => pr_des_erro);

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_dsmensag := replace(replace(vr_dsmensag, '<b>', '\"'), '</b>', '\"');
   vr_dsmensag := replace(replace(vr_dsmensag, '<br>', ' '), '<BR>', ' ');
   pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><dsmensag>' || vr_dsmensag || '</dsmensag></Root>');
   dbms_output.put_line(vr_dsmensag);

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
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_analisar_proposta: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_analisar_proposta;


FUNCTION fn_em_contingencia_ibratan (pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS

  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_em_contingencia_ibratan
    Sistema  : CRED
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Gustavo Guedes de Sene (GFT)
    Data     : Março/2018                   Ultima atualizacao: 01/03/2018

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
  este0003.pc_obrigacao_analise_automatic(pr_cdcooper => pr_cdcooper
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


PROCEDURE pc_confirmar_novo_limite_web(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
                                      ,pr_cddopera  IN INTEGER               --> Resposta de confirmacao
                                      ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                                      ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
BEGIN
  /*----------------------------------------------------------------------------------
   Procedure: pc_confirmar_novo_limite_web
   Sistema  : CRED
   Sigla    : TELA_ATENDA_DSCTO_TIT
   Autor    : Gustavo Guedes de Sene - Company: GFT
   Data     : Criação: 22/02/2018    Ultima atualização: 22/02/2018
  
   Dados referentes ao programa:
  
   Frequencia:
   Objetivo  :

   Histórico de Alterações:
    22/02/2018 - Versão inicial
    13/03/2018 - Alterado alerta de confirmação quando ocorre contingencia. Teremos que mostrar o alerta
                 somente se tanto a esteira quanto o motor estiverem em contingencia (Paulo Penteado (GFT))
  ----------------------------------------------------------------------------------*/

  DECLARE

     -- Busca cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
     SELECT vlmaxleg
           ,vlmaxutl
           ,vlcnsscr
       FROM crapcop
      WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;

    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_cdagenci_ass VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis auxiliares
    vr_vlmaxleg     crapcop.vlmaxleg%TYPE;
    vr_vlmaxutl     crapcop.vlmaxutl%TYPE;
    vr_vlminscr     crapcop.vlcnsscr%TYPE;
    vr_par_nrdconta INTEGER;
    vr_par_dsctrliq VARCHAR2(1000);
    vr_par_vlutiliz NUMBER;
    vr_qtctarel     INTEGER;
    vr_flggrupo     INTEGER;
    vr_nrdgrupo     INTEGER;
    vr_dsdrisco     VARCHAR2(2);
    vr_gergrupo     VARCHAR2(1000);
    vr_dsdrisgp     VARCHAR2(1000);
    vr_mensagem_01  VARCHAR2(1000);
    vr_mensagem_02  VARCHAR2(1000);
    vr_mensagem_03  VARCHAR2(1000);
    vr_mensagem_04  VARCHAR2(1000);
    vr_mensagem_05  VARCHAR2(1000); -- Mensagem que informa se o Processo de Análise Automática (IBRATAN) está em Contingência
    vr_tab_grupo    geco0001.typ_tab_crapgrp;
    vr_valor        craplim.vllimite%TYPE;
    vr_index        INTEGER;
    vr_str_grupo    VARCHAR2(32767) := '';
    vr_vlutilizado  VARCHAR2(100) := '';
    vr_vlexcedido   VARCHAR2(100) := '';
    vr_em_contingencia_ibratan boolean;
    vr_flctgest     boolean;
    vr_flctgmot     boolean;

  BEGIN

    pr_des_erro := 'OK';

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
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
    --  Se ocorrer algum erro
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;


    pc_validar_confirm_novo_limite(pr_cdcooper    => vr_cdcooper
                                  ,pr_nrdconta    => pr_nrdconta
                                  ,pr_nrctrlim    => pr_nrctrlim
                                  ,pr_vllimite    => pr_vllimite
                                  ,pr_cdagenci    => vr_cdagenci_ass
                                  ,pr_tab_crapdat => rw_crapdat
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_dscritic    => vr_dscritic);
    --  Se ocorrer algum erro
    IF  vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
    END IF;


    vr_cdagenci := nvl(nullif(vr_cdagenci, 0), vr_cdagenci_ass);

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

        OPEN  cr_crapcop(vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        if    cr_crapcop%FOUND then
              vr_vlmaxleg := rw_crapcop.vlmaxleg;
              vr_vlmaxutl := rw_crapcop.vlmaxutl;
              vr_vlminscr := rw_crapcop.vlcnsscr;
        end   if;
        CLOSE cr_crapcop;

        -- Verifica se tem grupo economico em formacao
        GECO0001.pc_busca_grupo_associado(pr_cdcooper => vr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_flggrupo => vr_flggrupo
                                         ,pr_nrdgrupo => vr_nrdgrupo
                                         ,pr_gergrupo => vr_gergrupo
                                         ,pr_dsdrisgp => vr_dsdrisgp);
        -- Se tiver grupo economico em formacao
        IF  vr_gergrupo IS NOT NULL THEN
            vr_mensagem_01 := vr_gergrupo || ' Confirma?';
        END IF;

        --  Se conta pertence a um grupo
        IF  vr_flggrupo = 1 THEN
            geco0001.pc_calc_endivid_grupo(pr_cdcooper  => vr_cdcooper
                                          ,pr_cdagenci  => vr_cdagenci
                                          ,pr_nrdcaixa  => 0
                                          ,pr_cdoperad  => vr_cdoperad
                                          ,pr_nmdatela  => vr_nmdatela
                                          ,pr_idorigem  => 1
                                          ,pr_nrdgrupo  => vr_nrdgrupo
                                          ,pr_tpdecons  => TRUE
                                          ,pr_dsdrisco  => vr_dsdrisco
                                          ,pr_vlendivi  => vr_par_vlutiliz
                                          ,pr_tab_grupo => vr_tab_grupo
                                          ,pr_cdcritic  => vr_cdcritic
                                          ,pr_dscritic  => vr_dscritic);

            IF  vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;

            IF  vr_vlmaxutl > 0 THEN
                --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
                IF  pr_vllimite > vr_par_vlutiliz THEN
                    vr_valor := pr_vllimite;
                ELSE
                    vr_valor := vr_par_vlutiliz;
                END IF;

                --  Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
                IF  vr_valor > vr_vlmaxutl THEN
                    vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') ||'.';
                END IF;

                --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
                IF  vr_valor > vr_vlmaxleg THEN
                    vr_mensagem_03 := 'Valor Legal Excedido';
                    vr_vlutilizado := to_char(vr_par_vlutiliz,'999G999G990D00');
                    vr_vlexcedido  := to_char((vr_valor - vr_vlmaxutl),'999G999G990D00');

                    -- Abre tabela do grupo
                    vr_str_grupo := '<grupo>';
                    vr_qtctarel  := 0;
                    vr_index     := vr_tab_grupo.first;

                    WHILE vr_index IS NOT NULL LOOP
                          -- Popula tabela do grupo
                          vr_str_grupo := vr_str_grupo || '<conta>' ||
                                          to_char(gene0002.fn_mask_conta((vr_tab_grupo(vr_index).nrctasoc)))
                                          || '</conta>';
                          vr_index     := vr_tab_grupo.next(vr_index);
                          vr_qtctarel  := vr_qtctarel + 1;
                    END   LOOP;

                    -- Encerra tabela grupo
                    vr_str_grupo := vr_str_grupo || '</grupo><qtctarel>' || vr_qtctarel || '</qtctarel>';
                END IF;

                --  Verifica se o valor é maior que o valor da consulta SCR
                IF  vr_valor > vr_vlminscr THEN
                    vr_mensagem_04 := 'Efetue consulta no SCR.';
                END IF;
            END IF;

        ELSE --  Se conta nao pertence a um grupo
            gene0005.pc_saldo_utiliza(pr_cdcooper    => vr_cdcooper
                                     ,pr_tpdecons    => 1
                                     ,pr_dsctrliq    => vr_par_dsctrliq
                                     ,pr_cdprogra    => vr_nmdatela
                                     ,pr_nrdconta    => vr_par_nrdconta
                                     ,pr_tab_crapdat => rw_crapdat
                                     ,pr_inusatab    => TRUE
                                     ,pr_vlutiliz    => vr_par_vlutiliz
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);

            --  Verifica se o valor limite é maior que o valor da divida e pega o maior valor
            IF  vr_vlmaxutl > 0 THEN
                IF  pr_vllimite > vr_par_vlutiliz THEN
                    vr_valor := pr_vllimite;
                ELSE
                    vr_valor := vr_par_vlutiliz;
                END IF;

                -- Verifica se o valor é maior que o valor maximo utilizado pelo associado nos emprestimos
                IF  vr_valor > vr_vlmaxutl THEN
                    vr_mensagem_02 := 'Valores utilizados excedidos. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxutl),'999G999G990D00') || '.';
                END IF;

                --  Verifica se o valor é maior que o valor legal a ser emprestado pela cooperativa
                IF  vr_valor > vr_vlmaxleg THEN
                    vr_mensagem_03 := 'Valor legal excedido. Utilizado R$: ' ||
                                      to_char(vr_par_vlutiliz,'999G999G990D00') || '. Excedido R$: ' ||
                                      to_char((vr_valor - vr_vlmaxleg),'999G999G990D00') || '.';
                END IF;

                --  Verifica se o valor é maior que o valor da consulta SCR
                IF  vr_valor > vr_vlminscr THEN
                    vr_mensagem_04 := 'Efetue consulta no SCR.';
                END IF;
            END IF;
        END IF;

        --  Verificar se o tanto o motor quanto a esteria estão em contingencia para mostrar a mensagem de alerta, sou seja, mostrar
        --  mensagem de alerta somente se o motor E a esteira estiverem em contingencia.
        este0003.pc_verifica_contigenc_motor(pr_cdcooper => vr_cdcooper
                                            ,pr_flctgmot => vr_flctgmot
                                            ,pr_dsmensag => vr_mensagem_05 -- somente representativo para out
                                            ,pr_dscritic => vr_dscritic);

        este0003.pc_verifica_contigenc_esteira(pr_cdcooper => vr_cdcooper
                                              ,pr_flctgest => vr_flctgest
                                              ,pr_dsmensag => vr_mensagem_05 -- somente representativo para out
                                              ,pr_dscritic => vr_dscritic);

        if  vr_flctgest AND vr_flctgmot then
            vr_mensagem_05 := 'Atenção: Para confirmar é necessário ter efetuado a análise manual do limite! Confirma análise do limite?';
        end if;

        --  Se houver alguma Mensagem/Inconsistência, emitir mensagem para o usuario
        IF  vr_mensagem_01 IS NOT NULL OR vr_mensagem_02 IS NOT NULL OR vr_mensagem_03 IS NOT NULL OR
            vr_mensagem_04 IS NOT NULL OR vr_mensagem_05 IS NOT NULL THEN
            -- Criar cabecalho do XML
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>' ||
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
        ELSE
           pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => NULL -- Decisão = Retorno da IBRATAN
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
            --  Se ocorrer algum erro
            IF  vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
            END IF;

            -- Criar cabecalho do XML
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
        END IF;

    --  2º Passo: Se houve alguma Mensagem/Inconsistência e o Operador Ayllos confirmou (ou seja, clicou em "SIM" ou "OK"),
    --  efetuar o processo de Confirmação do novo Limite.
    --  Se houver Contigência de Motor e/ou Esteira, será efetuada a Confirmação do novo Limite na situação de Contigência.
    else
        if  vr_em_contingencia_ibratan then
           pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => 3 -- Decisão = APROVADO (CONTINGENCIA)      
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
          --  Se ocorrer algum erro
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;

        else
          pc_confirmar_novo_limite(pr_cdcooper => vr_cdcooper
                                 	 ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctrlim => pr_nrctrlim
                                   ,pr_tpctrlim => 3 -- Título
                                   ,pr_vllimite => pr_vllimite
                                   ,pr_cdoperad => vr_cdoperad   --> Código do Operador
                                   ,pr_cdagenci => vr_cdagenci   --> Codigo da Agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa   --> Numero Caixa
                                   ,pr_idorigem => vr_idorigem   --> Identificador Origem Chamada
                                   ,pr_tab_crapdat => rw_crapdat --> Data de Movimento
                                   ,pr_insitapr => NULL -- Decisão = Retorno da IBRATAN
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
          --  Se ocorrer algum erro
          IF  vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
          END IF;


        end if;

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
    end if;

  EXCEPTION
    WHEN vr_exc_saida THEN
      pr_des_erro := 'NOK';
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_confirma_novo_limite_web: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END;

END pc_confirmar_novo_limite_web;


PROCEDURE pc_confirmar_novo_limite(pr_cdcooper    IN crapcop.cdcooper%TYPE --> Código da Cooperativa
                                  ,pr_nrdconta    IN crapass.nrdconta%TYPE --> Número da Conta
                                  ,pr_nrctrlim    IN craplim.nrctrlim%TYPE --> Contrato
                                  ,pr_tpctrlim    IN craplim.tpctrlim%TYPE --> Tipo de contrato de Limite (2-Cheque / 3-Titulo)
                                  ,pr_vllimite    IN craplim.vllimite%TYPE --> Valor do Limite
                                  ,pr_cdoperad    IN crapope.cdoperad%TYPE --> Código do Operador
                                  ,pr_cdagenci    IN crapass.cdagenci%TYPE --> Codigo da agencia
                                  ,pr_nrdcaixa    IN craperr.nrdcaixa%TYPE --> Numero Caixa
                                  ,pr_idorigem    IN INTEGER               --> Identificador Origem Chamada
                                  ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE --> Tipo de registro de datas
                                  ,pr_insitapr    IN craplim.insitapr%TYPE    --> Decisão (Dependente do Retorno da Análise)
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                --> Descricao da critica
                                  ) IS


BEGIN

  ----------------------------------------------------------------------------------
  --
  -- Procedure: pc_confirmar_novo_limite
  -- Sistema  : CRED
  -- Sigla    : TELA_ATENDA_DSCTO_TIT
  -- Autor    : Gustavo Guedes de Sene - Company: GFT
  -- Data     : Criação: 22/02/2018    Ultima atualização: 22/02/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia:
  -- Objetivo  :
  --
  --
  -- Histórico de Alterações:
  --  22/02/2018 - Versão inicial
  --
  --
  ----------------------------------------------------------------------------------

  DECLARE

   --     Verifica limite
   cursor cr_craplim is
   select 1
          -- idcobope
   from   craplim
   where  cdcooper = pr_cdcooper
   and    nrdconta = pr_nrdconta
   and    nrctrlim = pr_nrctrlim
   and    tpctrlim = pr_tpctrlim; -- 3 = Título
   rw_craplim cr_craplim%rowtype;



    -- Verifica Conta (Cadastro de associados)
    CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin
            ,cdsitdtl
            ,cdagenci
            ,inpessoa
            ,nrdconta
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;


    -- Busca capa do lote
    CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                      ,pr_cdagenci IN craplot.cdagenci%TYPE) IS
      SELECT nvl(MAX(nrdolote), 0) + 1
        FROM craplot
       WHERE cdcooper = pr_cdcooper
         AND dtmvtolt = pr_dtmvtolt
         AND cdagenci = pr_cdagenci
         AND cdbccxlt = 700;


    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;


    -- Variaveis auxiliares
    vr_nrdolote     craplot.nrdolote%TYPE;
    vr_rowid_log    ROWID;


    -- Variáveis incluídas
    vr_des_erro      VARCHAR2(3);                           -- 'OK' / 'NOK'
    vr_cdbattar      crapbat.cdbattar%TYPE := 'DSTCONTRPF'; -- Default = Pessoa Física
    vr_cdtarifa      craptar.cdtarifa%TYPE;
    vr_cdhistor      crapfvl.cdhistor%TYPE;
    vr_cdhisest      crapfvl.cdhisest%TYPE;
    vr_vltarifa      crapfco.vlmaxtar%TYPE;
    vr_dtdivulg      crapfco.dtdivulg%TYPE;
    vr_dtvigenc      crapfco.dtvigenc%TYPE;
    vr_cdfvlcop      crapfco.cdfvlcop%TYPE;
    vr_rowid_craplat ROWID;

    -- PL Tables
    vr_tab_impress_coop     RATI0001.typ_tab_impress_coop;
    vr_tab_impress_rating   RATI0001.typ_tab_impress_rating;
    vr_tab_impress_risco_cl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_risco_tl RATI0001.typ_tab_impress_risco;
    vr_tab_impress_assina   RATI0001.typ_tab_impress_assina;
    vr_tab_efetivacao       RATI0001.typ_tab_efetivacao;
    vr_tab_ratings          RATI0001.typ_tab_ratings;
    vr_tab_crapras          RATI0001.typ_tab_crapras;
    vr_tab_erro             GENE0001.typ_tab_erro;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
                              ,pr_action => NULL);

   open  cr_craplim;
   fetch cr_craplim into rw_craplim;
   if    cr_craplim%notfound then
         close cr_craplim;
        vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Contrato: ' || pr_nrctrlim;
         raise vr_exc_saida;
   end   if;
   close cr_craplim;


      -- Verifica se ja existe lote criado
      OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                     ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                     ,pr_cdagenci => pr_cdagenci);
      FETCH cr_craplot INTO vr_nrdolote;
      CLOSE cr_craplot;

      -- Se não, cria novo lote
      BEGIN
        INSERT INTO craplot (cdcooper
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
                     VALUES (pr_cdcooper
                            ,pr_tab_crapdat.dtmvtolt
                            ,pr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,35 -- Título
                            ,1
                            ,1
                            ,1
                            ,pr_vllimite
                            ,pr_vllimite
                            ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao inserir capa do lote. ' || SQLERRM;
        RAISE vr_exc_saida;
      END;


      -- Atualiza Limite de Desconto de Título
      BEGIN
        UPDATE craplim
           SET insitlim = 2 -- Situação do Limite = ATIVO
              ,insitest = 3
              ,insitapr = nvl(pr_insitapr, insitapr) -- Decisão (Depende do Retorno da Análise...)
              ,qtrenova = 0
              ,dtinivig = pr_tab_crapdat.dtmvtolt
              ,dtfimvig = (pr_tab_crapdat.dtmvtolt + craplim.qtdiavig)
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = pr_tpctrlim; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

/*
      -- Efetuar o bloqueio de possíveis coberturas vinculadas ao limite anterior
      BLOQ0001.pc_bloq_desbloq_cob_operacao(pr_nmdatela       => 'ATENDA'
                                           ,pr_idcobertura    => rw_craplim.idcobope
                                           ,pr_inbloq_desbloq => 'B'
                                           ,pr_cdoperador     => pr_cdoperad
                                           ,pr_flgerar_log    => 'S'
                                           ,pr_dscritic       => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
*/

      -- Cria lancamento de contratos de descontos.
      BEGIN
        INSERT INTO crapcdc (dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,nrdconta
                            ,nrctrlim
                            ,vllimite
                            ,nrseqdig
                            ,cdcooper
                            ,tpctrlim)
                     VALUES (pr_tab_crapdat.dtmvtolt
                            ,pr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,pr_nrdconta
                            ,pr_nrctrlim
                            ,pr_vllimite
                            ,1
                            ,pr_cdcooper
                            ,pr_tpctrlim); -- Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao criar lancamento de contratos de descontos. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      OPEN  cr_crapass(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattar := 'DSTCONTRPF'; -- Pessoa Física
      ELSE
        vr_cdbattar := 'DSTCONTRPJ'; -- Pessoa Jurídica
      END IF;

      -- Buscar valores da tarifa vigente
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper => pr_cdcooper    --> Codigo Cooperativa
                                           ,pr_cdbattar => vr_cdbattar    --> Codigo da sigla da tarifa (CRAPBAT) - Ao popular este parâmetro o pr_cdtarifa não é necessário
                                           ,pr_cdtarifa => vr_cdtarifa    --> Codigo da Tarifa (CRAPTAR) - Ao popular este parâmetro o pr_cdbattar não é necessário
                                           ,pr_vllanmto => pr_vllimite    --> Valor Lancamento
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


      -- Criar lançamento automático da tarifa
      TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper           --> Codigo Cooperativa
                                      ,pr_nrdconta => pr_nrdconta           --> Numero da Conta
                                      ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt           --> Data Lancamento
                                      ,pr_cdhistor => vr_cdhistor           --> Codigo Historico
                                      ,pr_vllanaut => vr_vltarifa           --> Valor lancamento automatico
                                      ,pr_cdoperad => pr_cdoperad           --> Codigo Operador
                                      ,pr_cdagenci => 1                     --> Codigo Agencia
                                      ,pr_cdbccxlt => 100                   --> Codigo banco caixa
                                      ,pr_nrdolote => 8452                  --> Numero do lote
                                      ,pr_tpdolote => 1                     --> Tipo do lote (35 - Título)
                                      ,pr_nrdocmto => 0                     --> Numero do documento
                                      ,pr_nrdctabb => pr_nrdconta           --> Numero da conta
                                      ,pr_nrdctitg => to_char(pr_nrdconta, '99999999') --> Numero da conta integracao
                                      ,pr_cdpesqbb => ''                    --> Codigo pesquisa
                                      ,pr_cdbanchq => 0                     --> Codigo Banco Cheque
                                      ,pr_cdagechq => 0                     --> Codigo Agencia Cheque
                                      ,pr_nrctachq => 0                     --> Numero Conta Cheque
                                      ,pr_flgaviso => FALSE                 --> Flag aviso
                                      ,pr_tpdaviso => 0                     --> Tipo aviso
                                      ,pr_cdfvlcop => vr_cdfvlcop           --> Codigo cooperativa
                                      ,pr_inproces => 1                     --> Indicador processo 1 = Online
                                       --
                                      ,pr_rowid_craplat => vr_rowid_craplat --> Rowid do lancamento tarifa
                                      ,pr_tab_erro      => vr_tab_erro      --> Tabela retorno erro
                                      ,pr_cdcritic      => vr_cdcritic      --> Codigo Critica
                                      ,pr_dscritic      => vr_dscritic);    --> Descricao Critica


      -- Gera Rating
      rati0001.pc_gera_rating(pr_cdcooper => pr_cdcooper                         --> Codigo Cooperativa
                             ,pr_cdagenci => pr_cdagenci                         --> Codigo Agencia
                             ,pr_nrdcaixa => pr_nrdcaixa                         --> Numero Caixa
                             ,pr_cdoperad => pr_cdoperad                         --> Codigo Operador
                             ,pr_nmdatela => 'ATENDA'                            --> Nome da tela
                             ,pr_idorigem => pr_idorigem                         --> Identificador Origem
                             ,pr_nrdconta => pr_nrdconta                         --> Numero da Conta
                             ,pr_idseqttl => 1                                   --> Sequencial do Titular
                             ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt             --> Data de movimento
                             ,pr_dtmvtopr => pr_tab_crapdat.dtmvtopr             --> Data do próximo dia útil
                             ,pr_inproces => pr_tab_crapdat.inproces             --> Situação do processo
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


      -- Em caso de erro
      IF vr_des_erro <> 'OK' THEN

        vr_cdcritic:= vr_tab_erro(0).cdcritic;
        vr_dscritic:= vr_tab_erro(0).dscritic;

        RAISE vr_exc_saida;
        RETURN;

      END IF;


      -- Efetua os inserts para apresentacao na tela VERLOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                          ,pr_dstransa => 'Confirmar Novo limite de desconto de títulos.'
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_rowid_log);


    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      ROLLBACK;

    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_confirma_novo_limite_web: ' || SQLERRM;

      ROLLBACK;
  END;

END pc_confirmar_novo_limite;


PROCEDURE pc_negar_proposta(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                           ,pr_nrctrlim  IN craplim.nrctrlim%TYPE --> Contrato
                           ,pr_xmllog    IN VARCHAR2              --> XML com informacoes de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2              --> Descricao da critica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
BEGIN

  ----------------------------------------------------------------------------------
  --
  -- Procedure: pc_negar_proposta
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
  --
  --
  ----------------------------------------------------------------------------------

  DECLARE
    -- Verifica limite
    CURSOR cr_craplim_ctr (pr_cdcooper IN crapcop.cdcooper%TYPE
                          ,pr_nrdconta IN crapass.nrdconta%TYPE
                          ,pr_nrctrlim IN crapcdc.nrctrlim%TYPE) IS
      SELECT insitlim
            ,insitest
        FROM craplim
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 3; -- 3 = Título
    rw_craplim_ctr cr_craplim_ctr%ROWTYPE;

    -- Informações de data do sistema
    -- Variavel de criticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Tratamento de erros
    vr_exc_saida   EXCEPTION;
    vr_retorna_msg EXCEPTION;

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis auxiliares
    vr_rowid_log    ROWID;

    -- PL Tables
    vr_tab_erro             GENE0001.typ_tab_erro;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DESCTO'
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
    -- Se ocorrer algum erro
    IF vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_saida;
    END IF;


    OPEN cr_craplim_ctr(vr_cdcooper, pr_nrdconta, pr_nrctrlim);
    FETCH cr_craplim_ctr INTO rw_craplim_ctr;
    CLOSE cr_craplim_ctr;

    -- Verifica se a situação do Limite está 'Em Estudo' ou 'Não Aprovado'
    IF rw_craplim_ctr.insitlim not in (1,6) THEN
      vr_dscritic := 'Para esta operação, as Situações do Limite devem ser: "Em Estudo" ou "Não Aprovado".';
      RAISE vr_exc_saida;
    END IF;

    -- Verifica se a situação da Análise está 'Não Enviado' ou 'Análise Finalizada'
    IF rw_craplim_ctr.insitest not in (0,3) THEN
      vr_dscritic := 'Para esta operação, as Situações da Análise devem ser: "Não Enviado" ou "Análise Finalizada".';
      RAISE vr_exc_saida;
    END IF;

    -- Se o serviço IBRATAN está em Contingência...
    IF fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper) THEN

      -- Rejeita Limite de Desconto de Título (Em Contingência)
      BEGIN
        UPDATE craplim
           SET insitlim = 7 -- Situação do Limite  = REJEITADO
              ,insitest = 3
              ,insitapr = 6 -- Decisão             = REJEITADO CONTINGENCIA
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 3; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao rejeitar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    -- Se o serviço IBRATAN não está em Contingência...
    ELSE

      -- Rejeita Limite de Desconto de Título (Sem Contingência)
      BEGIN
        UPDATE craplim
           SET insitlim = 7 -- Situação do Limite  = REJEITADO
              ,insitest = 3
         WHERE cdcooper = vr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrlim = pr_nrctrlim
           AND tpctrlim = 3; -- 3 = Título
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao rejeitar limite de desconto de título. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

    END IF;
    --

    -- Em caso de erro
    IF pr_des_erro <> 'OK' THEN

      vr_cdcritic:= vr_tab_erro(0).cdcritic;
      vr_dscritic:= vr_tab_erro(0).dscritic;

      RAISE vr_exc_saida;
      RETURN;

    END IF;

    -- Efetua os inserts para apresentacao na tela VERLOG
    gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem)
                        ,pr_dstransa => 'Confirmar Rejeição do Limite de Desconto de Títulos.'
                        ,pr_dttransa => trunc(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => to_char(SYSDATE,'SSSSS')
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_rowid_log);

    -- Criar cabecalho do XML
    pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');


    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      END IF;
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrao para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela pc_negar_limite_desc_titulo: ' || SQLERRM;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;

END pc_negar_proposta;

PROCEDURE pc_enviar_proposta_manual(pr_nrctrlim in  craplim.nrctrlim%type --> Numero do Contrato do Limite.
                                   ,pr_tpctrlim in  craplim.tpctrlim%type --> Tipo de contrato do limite
                                   ,pr_nrdconta in  crapass.nrdconta%type --> Conta do associado
                                   ,pr_dtmovito in  varchar2	             -- crapdat.dtmvtolt%type  --> Data do movimento atual
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
    Data     : Março/2018                   Ultima atualizacao: 05/03/2018
   
    Dados referentes ao programa:
   
    Frequencia: Sempre que for chamado
    
    Objetivo  : Procedure para enviar a analise para esteira após confirmação de senha
   
    Alteração : 05/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/

   vr_dsmensag varchar2(32767);
   
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
                                    ,pr_dtmvtolt => pr_dtmovito
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
   dbms_output.put_line(vr_dsmensag);
   
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
       pr_dscritic := 'Erro nao tratado na ESTE0003.pc_enviar_proposta_manual: ' || sqlerrm;
       pr_des_erro := 'NOK';
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       rollback;
end pc_enviar_proposta_manual;

  
PROCEDURE pc_renovar_lim_desc_titulo(pr_nrdconta  IN crapass.nrdconta%TYPE --> Número da Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite  IN craplim.vllimite%TYPE --> Valor do limite de desconto
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
    Data    : Março/2018                 Ultima atualizacao: 

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
      vr_cddlinha VARCHAR2(100);
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

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_renovar_lim_desc_titulo;

  PROCEDURE pc_buscar_titulos_bordero(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                  ,pr_cdagenci IN INTEGER                --> Agencia de operação
                                  ,pr_nrdcaixa IN INTEGER                --> Número do caixa
                                  ,pr_cdoperad IN VARCHAR2               --> Operador
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data da Movimentação
                                  ,pr_idorigem IN INTEGER                --> Identificação de origem
                                  ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> Filtro de Tela de Inscricao do Pagador
                                  ,pr_vltitulo IN crapcob.vltitulo%TYPE  --> Filtro de Tela de Valor do titulo
                                  ,pr_dtvencto IN VARCHAR2               --> Filtro de Tela de Data de vencimento
                                  ,pr_nrnosnum IN crapcob.nrnosnum%TYPE  --> Filtro de Tela de Nosso Numero
                                  ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                  ,pr_insitlim IN craplim.insitlim%TYPE  --> Status
                                  ,pr_tpctrlim IN craplim.tpctrlim%TYPE  --> Tipo de desconto
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

   vr_dtmvtolt    DATE;
   vr_dtvencto    DATE;
   vr_idtabtitulo PLS_INTEGER;

   pr_tab_dados_dsctit cecred.dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052
   pr_tab_cecred_dsctit cecred.dsct0002.typ_tab_cecred_dsctit; -- retorno da TAB052
   -- Tratamento de erros
   vr_exc_erro exception;
       
      CURSOR cr_crapcob IS
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
             nvl((
                SELECT 
                   decode(inpossui_criticas,1,'S','N')
                FROM 
                   tbdsct_analise_pagador tap 
                WHERE tap.cdcooper=cob.cdcooper AND tap.nrdconta=cob.nrdconta AND tap.nrinssac=cob.nrinssac
             ),'A') AS dssituac -- Situacao do pagador com critica ou nao
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
         -- Valor da tabela crapcob (vltitulo) está menor do que o valor que está na tab052 (Valor mínimo permitido por título) - vlmintgc 
         AND cob.vltitulo >= decode(cob.cdtpinsc, 1, vr_vlminsacpf, vr_vlminsacpj)
         -- Prazo calculado entre a data de inclusão e o vencimento é menor do que está na tab052 (prazo mínimo) qtprzmin
         AND (cob.dtvencto - vr_dtmvtolt) >= decode(cob.cdtpinsc, 1, vr_qtprzminpf, vr_qtprzminpj)
         -- Prazo calculado entre a data de inclusão e o vencimento é maior do que está na tab052 (prazo máximo) qtprzmax
         AND (cob.dtvencto - vr_dtmvtolt) <= decode(cob.cdtpinsc, 1, vr_qtprzmaxpf, vr_qtprzmaxpj)

         -- Filtros Variáveis - Tela
         AND (cob.nrinssac = pr_nrinssac OR nvl(pr_nrinssac,0)=0)
         AND (cob.vltitulo = pr_vltitulo OR nvl(pr_vltitulo,0)=0)
         AND (cob.dtvencto = vr_dtvencto OR vr_dtvencto IS NULL)
         AND (cob.nrnosnum LIKE '%'||pr_nrnosnum||'%' OR nvl(pr_nrnosnum,0)=0) -- o campo correto para "Nosso Número"
       ;
         rw_crapcob cr_crapcob%ROWTYPE;
         
        
    /*Cursor para verificar se boleto já nao esta em outro bordero*/   
    CURSOR cr_craptdb (pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
     SELECT	
        nrdocmto
     FROM
        craptdb
        INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
     WHERE
        craptdb.nrdconta = pr_nrdconta
        AND craptdb.cdcooper = pr_cdcooper
        AND craptdb.nrdocmto = pr_nrdocmto
        AND crapbdt.insitbdt <= 4 ; -- borderos que estao em estudo, analisados, liberados, liquidados
   rw_craptdb cr_craptdb%ROWTYPE;
   BEGIN
     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
   
      pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursos
     
      vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      vr_dtvencto := null;
       IF (pr_dtvencto IS NOT NULL ) THEN
         vr_dtvencto := to_date(pr_dtvencto, 'DD/MM/RRRR');
       END IF;
      --carregando os dados de prazo limite da TAB052 
       -- BUSCAR O PRAZO PARA PESSOA FISICA
      cecred.dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                                 pr_cdagenci, --Agencia de operação
                                                 pr_nrdcaixa, --Número do caixa
                                                 pr_cdoperad, --Operador
                                                 vr_dtmvtolt, -- Data da Movimentação
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
                                                 vr_dtmvtolt, -- Data da Movimentação
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
        /*verifica se já nao está em outro bordero*/
       open cr_craptdb (pr_nrdocmto=>rw_crapcob.nrdocmto);
         fetch cr_craptdb into rw_craptdb;
         if  cr_craptdb%notfound then
            pr_qtregist := pr_qtregist+1;
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
         end if;
       close cr_craptdb;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
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
  
    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;
    
    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
      end;

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

      pc_buscar_titulos_bordero(vr_cdcooper  --> Código da Cooperativa
                       ,pr_nrdconta --> Número da Conta
                       ,vr_cdagenci --> Agencia de operação
                       ,vr_nrdcaixa --> Número do caixa
                       ,vr_cdoperad --> Operador
                       ,pr_dtmvtolt --> Data da Movimentação
                       ,vr_idorigem --> Identificação de origem
                       ,pr_nrinssac --> Filtro de Inscricao do Pagador
                       ,pr_vltitulo --> Filtro de Valor do titulo
                       ,pr_dtvencto --> Filtro de Data de vencimento
                       ,pr_nrnosnum --> Filtro de Nosso Numero
                       ,pr_nrctrlim --> Contrato
                       ,pr_insitlim --> Status
                       ,pr_tpctrlim --> Tipo de desconto
                       --------> OUT <--------
                       ,vr_qtregist --> Quantidade de registros encontrados
                       ,vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                       ,vr_cdcritic --> Código da crítica
                       ,vr_dscritic --> Descrição da crítica
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
                              '<nmdsacad>' || vr_tab_dados_titulos(vr_index).nmdsacad || '</nmdsacad>' ||
                              '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                              '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                              '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                              '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                              '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                              '<dssituac>' || vr_tab_dados_titulos(vr_index).dssituac || '</dssituac>' ||	
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
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_buscar_titulos_web ' ||sqlerrm;
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
      
      vr_dtmvtolt    DATE;
      vr_vlutiliz    NUMBER;
      vr_qtutiliz    INTEGER;
      vr_nrctrlim    craplim.nrctrlim%TYPE;
      
       -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro

       -- Tratamento de erros
       vr_exc_erro exception;
       
      CURSOR cr_craplim IS      
        SELECT 
          craplim.dtpropos,
          craplim.dtinivig,
          craplim.nrctrlim,
          craplim.vllimite,
          craplim.qtdiavig,
          craplim.cddlinha,
          craplim.tpctrlim
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
             AND craptdb.nrctrlim = vr_nrctrlim
             AND (craptdb.insittit=4 OR (craptdb.insittit=2 AND craptdb.dtdpagto=vr_dtmvtolt));
      rw_craptdb cr_craptdb%rowtype;
      BEGIN
        GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
        
        vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
        
        OPEN cr_craplim;
        FETCH cr_craplim INTO rw_craplim;
        IF (cr_craplim%NOTFOUND) THEN
         vr_dscritic := 'Conta não possui contrato de limite ativo.';
         raise vr_exc_erro;
        END IF;
        vr_nrctrlim := rw_craplim.nrctrlim;
        
        OPEN cr_craptdb;
        FETCH cr_craptdb INTO rw_craptdb;
        IF (cr_craptdb%NOTFOUND) THEN
           vr_vlutiliz := 0;
           vr_qtutiliz := 0;
        ELSE
           vr_vlutiliz := rw_craptdb.vlutiliz;
           vr_qtutiliz := rw_craptdb.qtutiliz;
        END IF;
        
        pr_tab_dados_limite(0).dtpropos := rw_craplim.dtpropos;
        pr_tab_dados_limite(0).dtinivig := rw_craplim.dtinivig;
        pr_tab_dados_limite(0).nrctrlim := rw_craplim.nrctrlim;
        pr_tab_dados_limite(0).vllimite := rw_craplim.vllimite;
        pr_tab_dados_limite(0).qtdiavig := rw_craplim.qtdiavig;
        pr_tab_dados_limite(0).cddlinha := rw_craplim.cddlinha;
        pr_tab_dados_limite(0).tpctrlim := rw_craplim.tpctrlim;
        pr_tab_dados_limite(0).vlutiliz := vr_vlutiliz;
        pr_tab_dados_limite(0).qtutiliz := vr_qtutiliz;

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
         
    
    pr_tab_dados_limite  typ_tab_dados_limite;          --> retorna dos dados
    
    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;
    
    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
      end;

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
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_busca_dados_limite_web;
      
  PROCEDURE pc_obtem_dados_proposta(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                   ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                   ,pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato de Limite
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
      Data     : Março/2018                   Ultima atualizacao: 26/03/2018

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
     select lim.nrctrlim
           ,lim.dtpropos
           ,lim.vllimite
           ,lim.dtinivig
           ,lim.qtdiavig
           ,lim.cddlinha
           ,lim.insitlim
           ,lim.insitest
           ,lim.insitapr
           ,case lim.insitlim when 1 then 'EM ESTUDO'
                              when 2 then 'EFETIVADA'
                              when 3 then 'CANCELADA'
                              when 5 then 'APROVADA'
                              when 6 then 'NAO APROVADA'
                              else        'DIFERENTE'
            end dssitlim
           ,case lim.insitest when 0 then 'NAO ENVIADO'
                              when 1 then 'ENVIADA ANALISE AUTOMATICA'
                              when 2 then 'ENVIADA ANALISE MANUAL'
                              when 3 then 'ANALISE FINALIZADA'
                              when 4 then 'EXPIRADO'
                              else        'DIFERENTE'
            end dssitest
           ,case lim.insitapr when 0 then 'NAO ANALISADO'
                              when 1 then 'APROVADO AUTOMATICAMENTE'
                              when 2 then 'APROVADO MANUAL'
                              when 3 then 'APROVADA'
                              when 4 then 'REJEITADO MANUAL'
                              when 5 then 'REJEITADO AUTOMATICAMENTE'
                              when 6 then 'REJEITADO'
                              when 7 then 'NAO ANALISADO'
                              when 8 then 'REFAZER'
                              else        'DIFERENTE'
            end dssitapr
     from   crawlim lim
     where  (lim.dtpropos >= vr_dtpropos OR insitlim=2)
     and    lim.tpctrlim  = pr_tpctrlim
     and    lim.nrdconta  = pr_nrdconta
     and    lim.cdcooper  = pr_cdcooper;
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
           pr_tab_dados_proposta(vr_idxdados).dssitlim := rw_crawlim.dssitlim;
           pr_tab_dados_proposta(vr_idxdados).dssitest := rw_crawlim.dssitest;
           pr_tab_dados_proposta(vr_idxdados).dssitapr := rw_crawlim.dssitapr;
           
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
    Data     : Março/2018                   Ultima atualizacao: 26/03/2018

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

   -- Variáveis para armazenar as informações em XML
   vr_des_xml         clob;
   vr_texto_completo  varchar2(32600);
   vr_index           pls_integer;

   --------------------------- SUBROTINAS INTERNAS --------------------------
   -- Subrotina para escrever texto na variável CLOB do XML
   PROCEDURE pc_escreve_xml(pr_des_dados in varchar2
                           ,pr_fecha_xml in boolean default false
                           ) IS
   BEGIN
      gene0002.pc_escreve_xml(vr_des_xml
                             ,vr_texto_completo
                             ,pr_des_dados
                             ,pr_fecha_xml);
   END;

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
                           '<dssitlim>'|| vr_tab_dados_proposta(vr_index).dssitlim ||'</dssitlim>'||
                           '<dssitest>'|| vr_tab_dados_proposta(vr_index).dssitest ||'</dssitest>'||
                           '<dssitapr>'|| vr_tab_dados_proposta(vr_index).dssitapr ||'</dssitapr>'||
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
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_dados_proposta_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

END pc_obtem_dados_proposta_web;
    
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper          in crapcop.cdcooper%type   --> Cooperativa conectada
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
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

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;
   BEGIN
    DECLARE
      type tpy_ref_cob is ref cursor;
      cr_tab_cob       tpy_ref_cob;
      rw_cob       typ_tab_dados_titulos;
      vr_sql       varchar2(32767);
      vr_idtabtitulo INTEGER;

    BEGIN 
       vr_sql := 'select ' ||
                   'cob.cdcooper,'||
                   'cob.nrdconta,'||
                   'cob.nrctremp,'||
                   'cob.nrcnvcob,'||
                   'cob.nrdocmto,'||
                   'cob.nrinssac,'||
                   'sab.nmdsacad,'||
                   'cob.dtvencto,'||
                   'cob.dtmvtolt,'||
                   'cob.vltitulo,'||
                   'cob.nrnosnum,'||
                   'cob.flgregis,'||
                   'cob.cdtpinsc '||
                 ' from   crapcob cob '||
                   ' INNER JOIN cecred.crapsab sab ON sab.nrinssac = cob.nrinssac AND sab.cdtpinsc = cob.cdtpinsc AND sab.cdcooper = cob.cdcooper AND sab.nrdconta = cob.nrdconta ' ||
                 'where  cob.flgregis > 0 '||
                 'and    cob.incobran = 0 '||
                 'and    cob.nrnosnum in ('||pr_nrnosnum||') '||
                 'and    cob.nrdconta = :nrdconta '||
                 'and    cob.cdcooper = :cdcooper ';
                 
       vr_idtabtitulo:=0;
       open  cr_tab_cob 
       for   vr_sql 
       using pr_nrdconta
            ,pr_cdcooper;
       loop
             fetch cr_tab_cob into pr_tab_dados_titulos(vr_idtabtitulo).cdcooper,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrdconta,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrctremp,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrdocmto,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrinssac,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nmdsacad,
                                        pr_tab_dados_titulos(vr_idtabtitulo).dtvencto,
                                        pr_tab_dados_titulos(vr_idtabtitulo).dtmvtolt,
                                        pr_tab_dados_titulos(vr_idtabtitulo).vltitulo,
                                        pr_tab_dados_titulos(vr_idtabtitulo).nrnosnum,
                                        pr_tab_dados_titulos(vr_idtabtitulo).flgregis,
                                        pr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc
                                        ;
             exit  when cr_tab_cob%notfound;
             vr_idtabtitulo:=vr_idtabtitulo+1;
       end   loop;
       close cr_tab_cob;
       pr_qtregist := vr_idtabtitulo;
    END;
    END pc_listar_titulos_resumo ;
    
    PROCEDURE pc_listar_titulos_resumo_web (pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                   ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
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
    
      vr_tab_erro         gene0001.typ_tab_erro;
      vr_qtregist         number;
      vr_des_reto varchar2(3);
      
      -- variaveis de entrada vindas no xml
      vr_cdcooper integer;
      vr_cdoperad varchar2(100);
      vr_nmdatela varchar2(100);
      vr_nmeacao  varchar2(100);
      vr_cdagenci varchar2(100);
      vr_nrdcaixa varchar2(100);
      vr_idorigem varchar2(100);

      -- variáveis para armazenar as informaçoes em xml
      vr_des_xml        clob;
      vr_texto_completo varchar2(32600);
      vr_index          PLS_INTEGER;
      
      -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
     -- Variaveis para verificar criticas e situacao
     vr_ibratan char(1);
     vr_situacao char(1);
     vr_nrinssac crapcob.nrinssac%TYPE;
     vr_cdbircon crapbir.cdbircon%TYPE;
     vr_dsbircon crapbir.dsbircon%TYPE;
     vr_cdmodbir crapmbr.cdmodbir%TYPE;
     vr_dsmodbir crapmbr.dsmodbir%TYPE;

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
     
        procedure pc_escreve_xml( pr_des_dados in varchar2
                                , pr_fecha_xml in boolean default false
                                ) is
        begin
          gene0002.pc_escreve_xml( vr_des_xml
                                 , vr_texto_completo
                                 , pr_des_dados
                                 , pr_fecha_xml );
        end;

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

        pc_listar_titulos_resumo(vr_cdcooper  --> Código da Cooperativa
                         ,pr_nrdconta --> Número da Conta
                         ,pr_nrnosnum --> Lista de 'nosso numero' a ser pesquisado
                         --------> OUT <--------
                         ,vr_qtregist --> Quantidade de registros encontrados
                         ,vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                         ,vr_cdcritic --> Código da crítica
                         ,vr_dscritic --> Descrição da crítica
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
              SELECT (nvl((SELECT 
                              decode(inpossui_criticas,1,'S','N')
                              FROM 
                               tbdsct_analise_pagador tap 
                            WHERE tap.cdcooper=vr_cdcooper AND tap.nrdconta=pr_nrdconta AND tap.nrinssac=vr_tab_dados_titulos(vr_index).nrinssac
                         ),'A')) INTO vr_situacao FROM DUAL ; -- Situacao do pagador com critica ou nao
              
              vr_nrinssac := vr_tab_dados_titulos(vr_index).nrinssac;
              
              open cr_crapcbd;
              fetch cr_crapcbd into rw_crapcbd;
              IF (cr_crapcbd%NOTFOUND) THEN
                vr_ibratan := 'A';
              ELSE
                SSPC0001.pc_verifica_situacao(rw_crapcbd.nrconbir,rw_crapcbd.nrseqdet,vr_cdbircon,vr_dsbircon,vr_cdmodbir,vr_dsmodbir,vr_ibratan);
              END IF;
              close cr_crapcbd;
              pc_escreve_xml('<inf>'||
                                '<progress_recid>' || vr_tab_dados_titulos(vr_index).progress_recid || '</progress_recid>' ||
                                '<cdcooper>' || vr_tab_dados_titulos(vr_index).cdcooper || '</cdcooper>' ||
                                '<nrdconta>' || TRIM(gene0002.fn_mask(vr_tab_dados_titulos(vr_index).nrdconta,'zzzz.zzz.z')) || '</nrdconta>' ||
                                '<nrctremp>' || vr_tab_dados_titulos(vr_index).nrctremp || '</nrctremp>' ||
                                '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                                '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                                '<nrinssac>' || vr_tab_dados_titulos(vr_index).nrinssac || '</nrinssac>' ||
                                '<nmdsacad>' || vr_tab_dados_titulos(vr_index).nmdsacad || '</nmdsacad>' ||
                                '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                                '<dtmvtolt>' || to_char(vr_tab_dados_titulos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                                '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                                '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                                '<flgregis>' || vr_tab_dados_titulos(vr_index).flgregis || '</flgregis>' ||
                                '<cdtpinsc>' || vr_tab_dados_titulos(vr_index).cdtpinsc || '</cdtpinsc>' ||
                                '<dssituac>' || vr_situacao || '</dssituac>' ||	
                                '<sitibrat>' || vr_ibratan  || '</sitibrat>' ||	
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
             
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descriçao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_titcto.pc_listar_titulos_resumo_web ' ||sqlerrm;
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_listar_titulos_resumo_web;
    
PROCEDURE pc_solicita_biro_bordero(pr_nrdconta in crapass.nrdconta%type --> Conta do associado
                                  ,pr_nrnosnum in varchar2              --> Lista de 'nosso numero' a ser pesquisado
                                  ,pr_xmllog   in varchar2              --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic out pls_integer          --> Código da crítica
                                  ,pr_dscritic out varchar2             --> Descrição da crítica
                                  ,pr_retxml   in out nocopy xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo out varchar2             --> Nome do campo com erro
                                  ,pr_des_erro out varchar2             --> Erros do processo
                                  ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_solicita_biro_bordero
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Paulo Penteado (GFT)
    Data     : Março/2018                   Ultima atualizacao: 28/03/2018

    Objetivo  : Procedure para realizar a consulta do biros dos pagadores de um bordero no Ibratan

    Alteração : 28/03/2018 - Criação (Paulo Penteado (GFT))

  ---------------------------------------------------------------------------------------------------------------------*/
   vr_tab_dados_titulos tela_atenda_dscto_tit.typ_tab_dados_titulos;
   vr_qtregist          number;
   vr_index             pls_integer;

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

   -- Variáveis para armazenar as informações em XML
   vr_des_xml         clob;
   vr_texto_completo  varchar2(32600);
   
   cursor cr_analise_pagador(pr_nrinssac crapcob.nrinssac%type) is
   select 1
   from   tbdsct_analise_pagador tap 
   where  tap.cdcooper = vr_cdcooper
   and    tap.nrdconta = pr_nrdconta
   and    tap.nrinssac = pr_nrinssac;
   rw_analise_pagador cr_analise_pagador%rowtype;

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
                           ,pr_nrnosnum          => pr_nrnosnum
                           ,pr_qtregist          => vr_qtregist
                           ,pr_tab_dados_titulos => vr_tab_dados_titulos
                           ,pr_cdcritic          => vr_cdcritic
                           ,pr_dscritic          => vr_dscritic );

   if  vr_cdcritic > 0  or vr_dscritic is not null then
       raise vr_exc_saida;
   end if;

   vr_index := vr_tab_dados_titulos.first;
   while vr_index is not null loop
   
         open  cr_analise_pagador(vr_tab_dados_titulos(vr_index).nrinssac);
         fetch cr_analise_pagador into rw_analise_pagador;
         if    cr_analise_pagador%notfound then

               dsct0002.pc_efetua_analise_pagador(pr_cdcooper => vr_cdcooper
                                                 ,pr_nrdconta => pr_nrdconta
                                                 ,pr_nrinssac => vr_tab_dados_titulos(vr_index).nrinssac
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);

               if  vr_cdcritic > 0  or vr_dscritic is not null then
                   raise vr_exc_saida;
               end if;
               
         end   if;
         close cr_analise_pagador;
         
         sspc0001.
                  pc_solicita_cons_bordero_biro(pr_cdcooper => vr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrnosnum => vr_tab_dados_titulos(vr_index).nrnosnum
                                               ,pr_inprodut => 7
                                               ,pr_cdoperad => vr_cdoperad
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic);

         if  vr_cdcritic > 0  or vr_dscritic is not null then
             raise vr_exc_saida;
         end if;

         vr_index := vr_tab_dados_titulos.next(vr_index);
   end   loop;

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
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  when others then
       -- Atribui exceção para os parametros de crítica
       pr_cdcritic := vr_cdcritic;
       pr_dscritic := 'Erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_obtem_dados_proposta_web: ' || sqlerrm;
       pr_retxml   := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                        '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
END pc_solicita_biro_bordero;

  PROCEDURE pc_insere_bordero(pr_tpctrlim           in craplim.tpctrlim%type   --> Tipo de contrato
                                 ,pr_insitlim           in craplim.insitlim%type   --> Situacao do contrato
                                 ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                 ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                 ,pr_dtmvtolt           in VARCHAR2                --> Data de movimentacao 
                                  ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                  --------> OUT <--------
                                  ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                 ) is
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_insere_bordero
    Sistema  : Ayllos
    Sigla    : TELA_ATENDA_DSCTO_TIT
    Autor    : Luis Fernando (GFT)
    Data     : Março/2018    

    Objetivo  : Procedure para Inserir todos os titulos selecionados no bordero

  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro

   -- Tratamento de erros
   vr_exc_erro exception;
   
   -- Variaveis para carregamento e validacoes de dados   
   vr_cddlinha craplim.cddlinha%TYPE;
   vr_flg_criou_lot boolean;
   vr_nrdolote craplot.nrdolote%TYPE;
   vr_nrborder crapbdt.nrborder%TYPE;
   vr_index        INTEGER;
   vr_vldtit       NUMBER;
   vr_dtmvtolt     DATE;
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);
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

    /*Linha de crédito*/
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
    CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%TYPE,pr_nrdconta IN craptdb.nrdconta%TYPE, pr_nrdocmto IN craptdb.nrdocmto%TYPE)
     IS
       SELECT
          nrdocmto
       FROM
          craptdb
          INNER JOIN crapbdt ON  craptdb.nrborder=crapbdt.nrborder AND craptdb.cdcooper=crapbdt.cdcooper
       WHERE
          craptdb.nrdconta = pr_nrdconta
          AND craptdb.cdcooper = pr_cdcooper
          AND craptdb.nrdocmto = pr_nrdocmto
          AND crapbdt.insitbdt <= 4 ; -- borderos que estao em estudo, analisados, liberados, liquidados
    rw_craptdb cr_craptdb%rowtype;
          
            
     type tpy_ref_cob is ref cursor;
     cr_tab_cob       tpy_ref_cob;
     rw_cob       typ_tab_dados_titulos;
     vr_sql       varchar2(32767);
     vr_idtabtitulo INTEGER;
     vr_tab_dados_titulos typ_tab_dados_titulos;
    
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
                                
      /*VERIFICA SE O CONTRATO EXISTE E AINDA ESTÁ ATIVO*/
      OPEN cr_craplim;
      FETCH cr_craplim INTO rw_craplim;
      IF (cr_craplim%NOTFOUND) THEN
        vr_dscritic := 'Contrato não encontrado.';
        raise vr_exc_erro;
      END IF;
      vr_cddlinha := rw_craplim.cddlinha;
        
      OPEN cr_crapldc;
      FETCH cr_crapldc INTO rw_crapldc;
      IF (cr_crapldc%NOTFOUND) THEN
         vr_dscritic := 'Linha de crédito não encontrada.';
         raise vr_exc_erro;
      END IF;
        
     vr_dtmvtolt := to_date(pr_dtmvtolt, 'DD/MM/RRRR');
     IF (rw_craplim.dtfimvig <vr_dtmvtolt) THEN
         vr_dscritic := 'A vigência do contrato deve ser maior que a data de movimentação do sistema.';
       raise vr_exc_erro;
     END IF;
     /*PREENCHE OS DADOS DAS COBRANCAS PASSADAS POR PARAMETRO*/
     vr_sql := 'select ' ||
                   'cob.cdcooper,'||
                   'cob.nrdconta,'||
                   'cob.nrctremp,'||
                   'cob.nrcnvcob,'||
                   'cob.nrdocmto,'||
                   'cob.nrinssac,'||
                   'sab.nmdsacad,'||
                   'cob.dtvencto,'||
                   'cob.dtmvtolt,'||
                   'cob.vltitulo,'||
                   'cob.nrnosnum,'||
                   'cob.flgregis,'||
                   'cob.cdtpinsc,'||
                   'cob.vldpagto,'||
                   'cob.cdbandoc,'||
                   'cob.nrdctabb,'||
                   'cob.dtdpagto '||
                 ' from   crapcob cob '||
                   ' INNER JOIN cecred.crapsab sab ON sab.nrinssac = cob.nrinssac AND sab.cdtpinsc = cob.cdtpinsc AND sab.cdcooper = cob.cdcooper AND sab.nrdconta = cob.nrdconta ' ||
                 'where  cob.flgregis > 0 '||
                 'and    cob.incobran = 0 '||
                 'and    cob.nrnosnum in ('||pr_nrnosnum||') '||
                 'and    cob.nrdconta = :nrdconta '||
                 'and    cob.cdcooper = :cdcooper ';
                 
       vr_idtabtitulo:=0;
       open  cr_tab_cob 
       for   vr_sql 
       using pr_nrdconta
            ,vr_cdcooper;
       loop
             fetch cr_tab_cob into vr_tab_dados_titulos(vr_idtabtitulo).cdcooper,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrdconta,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrctremp,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrcnvcob,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrdocmto,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrinssac,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nmdsacad,
                                        vr_tab_dados_titulos(vr_idtabtitulo).dtvencto,
                                        vr_tab_dados_titulos(vr_idtabtitulo).dtmvtolt,
                                        vr_tab_dados_titulos(vr_idtabtitulo).vltitulo,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrnosnum,
                                        vr_tab_dados_titulos(vr_idtabtitulo).flgregis,
                                        vr_tab_dados_titulos(vr_idtabtitulo).cdtpinsc,
                                        vr_tab_dados_titulos(vr_idtabtitulo).vldpagto,
                                        vr_tab_dados_titulos(vr_idtabtitulo).cdbandoc,
                                        vr_tab_dados_titulos(vr_idtabtitulo).nrdctabb,
                                        vr_tab_dados_titulos(vr_idtabtitulo).dtdpagto
                                        ;
             exit  when cr_tab_cob%notfound;
             vr_idtabtitulo:=vr_idtabtitulo+1;
       end   loop;
       close cr_tab_cob;

    /*VERIFICA SE O VALOR DOS BOLETOS SÃO > QUE O DISPONIVEL NO CONTRATO*/
      vr_index:= vr_tab_dados_titulos.first;
      WHILE vr_index IS NOT NULL LOOP
            /*Antes de realizar a inclusão deverá validar se algum título já foi selecionado em algum outro 
            borderô com situação diferente de “não aprovado” ou “prazo expirado”*/
           open cr_craptdb (pr_nrdconta=>pr_nrdconta,pr_cdcooper=>vr_cdcooper,pr_nrdocmto=>vr_tab_dados_titulos(vr_index).nrdocmto);
             fetch cr_craptdb into rw_craptdb;
             if  cr_craptdb%found then
               vr_dscritic := 'Título ' ||rw_craptdb.nrdocmto || ' já selecionado em outro borderô';
               RAISE vr_exc_erro;
             end if;
           close cr_craptdb;
          vr_vldtit := vr_vldtit + vr_tab_dados_titulos(vr_index).vltitulo;
          vr_index  := vr_tab_dados_titulos.next(vr_index);
      END   LOOP;

      /*VERIFICAR SE O VALOR TOTAL DOS TITULOS NAO PASSAO O DISPONIVEL DO CONTRATO*/
      IF (vr_vldtit> (rw_craplim.vllimite-rw_craplim.vlutiliz)) THEN
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
                                ,pr_dsdchave => TO_CHAR(vr_cdcooper)|| ';' 
                                             || pr_dtmvtolt || ';'
                                             || TO_CHAR(vr_cdagenci)|| ';'
                                             || '700');
      -- Rotina para criar número de bordero por cooperativa
      vr_nrborder := fn_sequence(pr_nmtabela => 'CRAPBDT'
                                ,pr_nmdcampo => 'NRBORDER'
                                ,pr_dsdchave => TO_CHAR(vr_cdcooper));
                                
      BEGIN
        -- Insere registro na craplot
        INSERT INTO craplot (dtmvtolt
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,qtinfoln
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
                      VALUES(vr_dtmvtolt
                            ,vr_cdagenci
                            ,700
                            ,vr_nrdolote
                            ,vr_idtabtitulo
                            ,vr_vldtit
                            ,vr_vldtit
                            ,34
                            ,NULL
                            ,vr_cdoperad
                            ,vr_nrborder
                            ,0
                            ,vr_cdcooper
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
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao inserir novo lote ' || SQLERRM;
          -- Levanta exceção
          RAISE vr_exc_erro;
      END;
      
      vr_flg_criou_lot := TRUE;
    END LOOP;
    
    BEGIN
        /*INSERE UM NOVO BORDERÔ*/
        INSERT INTO
               crapbdt
               (nrborder,
                nrctrlim,
                cdoperad,
                dtmvtolt,
                cdagenci,
                cdbccxlt,
                nrdolote,
                nrdconta,
                dtlibbdt,
                cdopelib,
                insitbdt,
                hrtransa,
                txmensal,
                cddlinha,
                cdcooper,
                flgdigit,
                PROGRESS_RECID,
                cdopeori,
                cdageori,
                dtinsori,
                cdopcolb,
                cdopcoan,
                dtrefatu
                )
                VALUES(vr_nrborder,
                rw_craplim.nrctrlim,
                vr_cdoperad,
                vr_dtmvtolt,
                vr_cdagenci,
                700,
                vr_nrdolote,
                pr_nrdconta,
                null,
                null,
                1,        -- A principio o status inicial é EM ESTUDO
                to_char(SYSDATE, 'SSSSS'),
                rw_crapldc.txmensal,
                rw_craplim.cddlinha,
                vr_cdcooper,
                null,
                null,
                vr_cdoperad,
                vr_cdagenci,
                sysdate,
                vr_cdoperad,
                vr_cdagenci,
                null
                );
                
      /*INSERE OS TITULOS DO PONTEIRO vr_tab_dados_titulos*/
      vr_index:= vr_tab_dados_titulos.first;
      WHILE vr_index IS NOT NULL LOOP
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
                  dtrefatu
                 )
                 VALUES(pr_nrdconta,
                 vr_tab_dados_titulos(vr_index).dtvencto,
                 vr_idtabtitulo,
                 vr_cdoperad,
                 vr_tab_dados_titulos(vr_index).nrdocmto,
                 rw_craplim.nrctrlim,
                 vr_nrborder,
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
                 null
                 );
          vr_index  := vr_tab_dados_titulos.next(vr_index);
      END   LOOP;
    
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Dados><inf>Borderô n' || vr_nrborder || ' criado com sucesso.</inf></Dados></Root>');
   END;
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
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_busca_dados_limite_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
           pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END pc_insere_bordero ;
    
  PROCEDURE pc_detalhes_tit_bordero(pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                               ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                               ,pr_nrnosnum           in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
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
    --
    --
    ---------------------------------------------------------------------------------------------------------------------
   
    ----------------> VARIÁVEIS <----------------
    
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic        varchar2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        exception;

    -- Demais tipos e variáveis
    vr_idtabbiro         integer;
    vr_idtabdetalhe      integer;
    vr_idtabcritica      integer;  
    --  
    vr_vlliquidez          number;
    vr_qtliquidez          number;
    vr_idtabtitulo       INTEGER;
    vr_cdtpinsc            crapcob.cdtpinsc%TYPE;
    vr_nrinssac            crapcob.nrinssac%TYPE;
    vr_nrconbir            craprpf.nrconbir%TYPE;
    vr_nrseqdet            craprpf.nrseqdet%TYPE;
    ----------------> CURSORES <----------------
    -- Pagador
    cursor cr_crapsab is
    SELECT *
    from crapsab
    where cdcooper = pr_cdcooper
    AND nrinssac = vr_nrinssac
    AND nrdconta = pr_nrdconta;
    rw_crapsab cr_crapsab%rowtype;
    
    -- Titulos (Boletos de Cobrança)
    cursor cr_crapcob is 
    select cob.cdcooper, 
           cob.nrdconta,
           cob.nrinssac,
           cob.nrnosnum,
           cob.cdtpinsc -- Tipo Pesso do Pagador (0-Nenhum/1-CPF/2-CNPJ)
    from   crapcob cob
    where  cob.cdcooper = pr_cdcooper -- Cooperativa
    and    cob.nrdconta = pr_nrdconta -- Conta
    and    cob.nrnosnum = pr_nrnosnum -- "Nosso Número"
    and    cob.incobran=0
    ;
    --
    rw_crapcob cr_crapcob%rowtype;  

    -- Percentual de Concentração de Títulos por Pagador	 
    cursor cr_concentracao is
    select * from (
        select nrdconta,
               nrinssac,
              (totalporpagador*100/(sum(totalporpagador) over(partition by nrdconta))) pe_conc
        from ( select nrdconta,
                      nrinssac,
                      count(1) as totalporpagador
               from   crapcob
               where  cdcooper = pr_cdcooper
               and    crapcob.flgregis = 1
               and    crapcob.incobran = 0
               and    crapcob.dtdpagto is null
               and    crapcob.nrdconta = pr_nrdconta
               group  by nrdconta,
                         crapcob.nrinssac
               order  by crapcob.nrdconta
             )
           
        group  by nrdconta,
                  nrinssac,
                  totalporpagador
    )
    where
      nrinssac = vr_nrinssac
      AND nrdconta = pr_nrdconta;
    rw_concentracao cr_concentracao%rowtype;


    -- Percentual Liquidez do Pagador com o Cedente
    --
    -- Títulos Descontados com vencimento dentro do período
    cursor cr_craptdb_desc is
    select count(1) qttitulo, nvl(sum(tdb.vltitulo), 0) vltitulo
    from   crapsab sab -- Pagador
          ,craptdb tdb -- Titulos do Bordero
          ,crapbdt dbt -- Bordero de Titulos
    where  sab.nrinssac = vr_nrinssac
    and    sab.cdtpinsc = vr_cdtpinsc
    and    sab.cdcooper = pr_cdcooper
    and    sab.nrdconta = pr_nrdconta
    and    tdb.dtresgat is null
    and    tdb.dtlibbdt is not null -- Somente os titulos que realmente foram descontados
    and    tdb.nrborder = dbt.nrborder
    and    tdb.nrdconta = dbt.nrdconta
    and    tdb.cdcooper = dbt.cdcooper
    and    dbt.nrdconta = pr_nrdconta
    and    dbt.cdcooper = pr_cdcooper
    --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
    and    not exists( select 1
                       from   craptit tit
                       where  tit.cdcooper = tdb.cdcooper
                       and    tit.dtmvtolt = tdb.dtdpagto
                       and    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                       and    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                       and    tit.cdbandst = 85
                       and    tit.cdagenci in (90,91) );
    rw_craptdb_desc cr_craptdb_desc%rowtype;

    -- Títulos Não Pagos com vencimento dentro do período
    cursor cr_craptdb_npag is
    select count(1) AS qttitulo, nvl(sum(tdb.vltitulo),0) AS vltitulo
    from   crapsab sab
          ,craptdb tdb
          ,crapbdt dbt
    where  sab.nrinssac  = vr_nrinssac
     and    sab.cdtpinsc  = vr_cdtpinsc 
    and    sab.cdcooper  = tdb.cdcooper
    and    sab.nrdconta  = tdb.nrdconta
    and    tdb.dtresgat  is null
    and    tdb.dtlibbdt  is not null
    and    tdb.dtvencto <= nvl(tdb.dtdpagto, trunc(sysdate))
    and    tdb.nrborder = dbt.nrborder
    and    tdb.nrdconta = dbt.nrdconta
    and    tdb.cdcooper = dbt.cdcooper
    and    dbt.nrdconta = pr_nrdconta
    and    dbt.cdcooper = pr_cdcooper
    --     Não considerar como título pago, os liquidados em conta corrente do cedente, ou seja, pagos pelo próprio emitente
    and    not exists( select 1
                       from   craptit tit
                       where  tit.cdcooper = tdb.cdcooper
                       and    tit.dtmvtolt = tdb.dtdpagto
                       and    tdb.nrdconta = substr(upper(tit.dscodbar), 26, 8)
                       and    tdb.nrcnvcob = substr(upper(tit.dscodbar), 20, 6)
                       and    tit.cdbandst = 85
                       and    tit.cdagenci in (90,91));
    rw_craptdb_npag cr_craptdb_npag%rowtype;


    -- Percentual Liquidez Geral
    --
    -- Títulos Descontados com vencimento dentro do período
    cursor cr_craptdb_desc_geral is
    select count(1) qttitulo, nvl(sum(tdb.vltitulo), 0) vltitulo
    from   crapsab sab
          ,craptdb tdb -- Titulos contidos do Bordero de desconto de titulos
          ,crapbdt dbt -- Cadastro de borderos de descontos de titulos
    where  sab.nrinssac = vr_nrinssac
     and    sab.cdtpinsc = vr_cdtpinsc
    and    sab.cdcooper = pr_cdcooper
    and    sab.nrdconta = pr_nrdconta
    and    tdb.dtresgat is null
    and    tdb.dtlibbdt is not null -- Somente os titulos que realmente foram descontados
    and    tdb.nrborder = dbt.nrborder
    and    tdb.nrdconta = dbt.nrdconta
    and    tdb.cdcooper = dbt.cdcooper
    and    dbt.nrdconta = pr_nrdconta
    and    dbt.cdcooper = pr_cdcooper;
    rw_craptdb_desc_geral cr_craptdb_desc_geral%rowtype;

    -- Títulos Não Pagos com vencimento dentro do período
    cursor cr_craptdb_npag_geral is
    select count(1) qttitulo, nvl(sum(tdb.vltitulo),0) vltitulo
    from   crapsab sab
          ,craptdb tdb
          ,crapbdt dbt
    where  sab.nrinssac = vr_nrinssac
     and    sab.cdtpinsc = vr_cdtpinsc
    and    sab.cdcooper  = tdb.cdcooper
    and    sab.nrdconta  = tdb.nrdconta
    and    tdb.dtresgat  is null
    and    tdb.dtlibbdt  is not null
    and    tdb.dtvencto <= nvl(tdb.dtdpagto, trunc(sysdate))
    and    tdb.nrborder = dbt.nrborder
    and    tdb.nrdconta = dbt.nrdconta
    and    tdb.cdcooper = dbt.cdcooper
    and    dbt.nrdconta = pr_nrdconta
    and    dbt.cdcooper = pr_cdcooper;
    rw_craptdb_npag_geral cr_craptdb_npag_geral%rowtype;

    --  Críticas Pagador (Job - Análise Diária)
    cursor cr_analise_pagador is 
      select *
      from   tbdsct_analise_pagador
      where  cdcooper = pr_cdcooper 
      and    nrdconta = pr_nrdconta 
    AND  nrinssac = vr_nrinssac;
    rw_analise_pagador cr_analise_pagador%rowtype;

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
                   AND craprpf.innegati = 7);
                   
       rw_craprpf cr_craprpf%rowtype; 

  BEGIN 
      open cr_crapcob;
      fetch cr_crapcob into rw_crapcob;
      vr_nrinssac := rw_crapcob.nrinssac;
      
      open cr_crapsab;
      fetch cr_crapsab into rw_crapsab;
      pr_nrinssac:=rw_crapsab.nrinssac;
      pr_nmdsacad:=rw_crapsab.nmdsacad;
      
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
         
         
      --> DETALHES (CONCENTRAÇÃO)
      open  cr_concentracao;
      fetch cr_concentracao into rw_concentracao;
      close cr_concentracao;
      pr_tab_dados_detalhe(0).concpaga := rw_concentracao.pe_conc;

      --> DETALHES (LIQUIDEZ DO PAGADOR COM O CEDENTE)
      --  Valor Total Descontado com vencimento dentro do período
      open  cr_craptdb_desc;
      fetch cr_craptdb_desc into rw_craptdb_desc;
      close cr_craptdb_desc;
              
      --  Se não houver desconto, liquidez é 100%
      if  rw_craptdb_desc.qttitulo = 0 then
          vr_vlliquidez := 100;
      else 
          -- Valor Total descontado pago com atraso e não pagos
          open  cr_craptdb_npag;
          fetch cr_craptdb_npag into rw_craptdb_npag;
          close cr_craptdb_npag;
          vr_vlliquidez := (rw_craptdb_npag.qttitulo / rw_craptdb_desc.qttitulo) * 100;
      end if;
      pr_tab_dados_detalhe(0).liqpagcd := vr_vlliquidez;

      --> DETALHES (LIQUIDEZ GERAL)
      --  Valor Total Descontado com vencimento dentro do período
      open  cr_craptdb_desc_geral;
      fetch cr_craptdb_desc_geral into rw_craptdb_desc_geral;
      close cr_craptdb_desc_geral;
              
      --  Se não houver desconto, liquidez é 100%
      if  rw_craptdb_desc_geral.qttitulo = 0 then
          vr_vlliquidez := 100;
      else 
          -- Valor Total descontado pago com atraso e não pagos
          open  cr_craptdb_npag_geral;
          fetch cr_craptdb_npag_geral into rw_craptdb_npag_geral;
          close cr_craptdb_npag_geral;

          vr_vlliquidez := (rw_craptdb_npag_geral.vltitulo / rw_craptdb_npag_geral.vltitulo) * 100;
      end if;

      pr_tab_dados_detalhe(0).liqgeral := vr_vlliquidez;

      --> CRÍTICAS DO PAGADOR (JOB - ANÁLISE PAGADOR)
      vr_idtabcritica := 0;
      open  cr_analise_pagador;
      fetch cr_analise_pagador into rw_analise_pagador;
      close cr_analise_pagador;                   

      if rw_analise_pagador.inpossui_criticas > 0 then

        -- qtremessa_cartorio	-> Crítica: Qtd Remessa em Cartório acima do permitido. (Ref. TAB052: qtremcrt).
        if rw_analise_pagador.qtremessa_cartorio > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd Remessa em Cartório acima do permitido'; 
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qtremessa_cartorio;
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- qttit_protestados -> Crítica: Qtd de Títulos Protestados acima do permitido. (Ref. TAB052: qttitprt).
        if rw_analise_pagador.qttit_protestados > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd de Títulos Protestados acima do permitido'; 
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qttit_protestados; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- qttit_naopagos	-> Crítica: Qtd de Títulos Não Pagos pelo Pagador acima do permitido. (Ref. TAB052: qtnaopag).
        if rw_analise_pagador.qttit_naopagos > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd de Títulos Não Pagos pelo Pagador acima do permitido';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qttit_naopagos; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- pemin_liquidez_qt ->	Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos).  (Ref. TAB052: qttliqcp).
        if rw_analise_pagador.pemin_liquidez_qt > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos)';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.pemin_liquidez_qt; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- pemin_liquidez_vl ->	Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos).  (Ref. TAB052: vltliqcp).
        if rw_analise_pagador.pemin_liquidez_vl > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos)';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.pemin_liquidez_vl; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
             
        -- peconcentr_maxtit ->	Crítica: Perc. Concentração Máxima Permitida de Títulos excedida. (Ref. TAB052: pcmxctip).
        if rw_analise_pagador.peconcentr_maxtit > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Concentração Máxima Permitida de Títulos excedida';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.peconcentr_maxtit; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- inemitente_conjsoc	-> Crítica: Emitente é Cônjuge/Sócio do Pagador (0 = Não / 1 = Sim). (Ref. TAB052: flemipar).
        if rw_analise_pagador.inemitente_conjsoc > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Emitente é Cônjuge/Sócio do Pagador.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.inemitente_conjsoc;
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- inpossui_titdesc	-> Crítica: Cooperado possui Títulos Descontados na Conta deste Pagador  (0 = Não / 1 = Sim). (Ref. TAB052: flpdctcp).
        if rw_analise_pagador.inpossui_titdesc > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Cooperado possui Títulos Descontados na Conta deste Pagador.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.inpossui_titdesc; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- invalormax_cnae ->	Crítica: Valor Máximo Permitido por CNAE excedido (0 = Não / 1 = Sim). (Ref. TAB052: vlmxprat).
        if rw_analise_pagador.invalormax_cnae > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Valor Máximo Permitido por CNAE excedido.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.invalormax_cnae; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
      end if;  

  end pc_detalhes_tit_bordero;
      
      
  procedure pc_detalhes_tit_bordero_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                        ,pr_nrnosnum    in varchar2              --> lista de 'nosso numero' a ser pesquisado
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
      
    vr_tab_erro         gene0001.typ_tab_erro;
    vr_des_reto varchar2(3);
        
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
   -- vr_index          pls_integer;
        
        
    vr_index_biro    pls_integer;
    vr_index_detalhe pls_integer;
    vr_index_critica pls_integer;
        
    -- variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> cód. erro
     vr_dscritic varchar2(1000);        --> desc. erro
         
   -- variaveis para verificar criticas e situacao
   vr_ibratan integer;
   vr_situacao char(1);
   
   -- variabel tab valor critica
   vr_tag_crit varchar2(1000);        --> desc. erro

       
      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
      end;

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

                           
                           
      pc_detalhes_tit_bordero(vr_cdcooper    --> código da cooperativa
                       ,pr_nrdconta          --> número da conta
                       ,pr_nrnosnum          --> lista de 'nosso numero' a ser pesquisado
                       --------> out <--------
                       ,vr_nrinssac          --> Inscricao do sacado
                       ,vr_nmdsacad          --> Nome do sacado
                       ,vr_tab_dados_biro    -->  retorno do biro
                       ,vr_tab_dados_detalhe -->  retorno dos detalhes
                       ,vr_tab_dados_critica --> retorno das criticas
                       ,vr_cdcritic          --> código da crítica
                       ,vr_dscritic          --> descrição da crítica
                       );
          
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
                         '<nmdsacad>'||vr_nmdsacad||'</nmdsacad>'||
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
                        '<concpaga>' 	|| vr_tab_dados_detalhe(0).concpaga || '</concpaga>' ||
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
                             '<int>' || vr_tab_dados_critica(vr_index_critica).varint || '</int>' ||
                             '<per>' || to_char(
                                     vr_tab_dados_critica(vr_index_critica).varper,
                                      'FM999G999G999G990D00')|| '</per>' ||
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
               
           -- carregar xml padrao para variavel de retorno
            pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="iso-8859-1" ?> ' ||
                                           '<root><erro>' || pr_dscritic || '</erro></root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_detalhes_tit_bordero_web ' ||sqlerrm;
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
                                  --------> PARMAS <--------
                                  ,pr_nrborder IN crapbdt.nrborder%TYPE  --> numero do bordero
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

  ---------------------------------------------------------------------------------------------------------------------*/

   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   vr_index        INTEGER;
   vr_dtmvtolt    DATE;
   
   vr_tab_tit_bordero        cecred.dsct0002.typ_tab_tit_bordero; --> retorna titulos do bordero
   vr_tab_tit_bordero_restri cecred.dsct0002.typ_tab_bordero_restri; --> retorna restrições do titulos do bordero
   
   -- Tratamento de erros
   vr_exc_erro exception;
     
   /* Busca dados do boleto de cobranca */ 
       CURSOR cr_tbdsct_analise_pagador(
               pr_cdcooper IN tbdsct_analise_pagador.cdcooper%TYPE  --> Código da Cooperativa
              ,pr_nrdconta IN tbdsct_analise_pagador.nrdconta%TYPE  --> Número da Conta
              ,pr_nrinssac IN tbdsct_analise_pagador.nrinssac%TYPE
                           ) IS
            SELECT * FROM 
                   tbdsct_analise_pagador 
            WHERE 
                   tbdsct_analise_pagador.cdcooper = pr_cdcooper AND
                   tbdsct_analise_pagador.nrdconta = pr_nrdconta AND
                   tbdsct_analise_pagador.nrinssac = pr_nrinssac;
                   
       rw_tbdsct_analise_pagador cr_tbdsct_analise_pagador%ROWTYPE;
   
   BEGIN
     -- Incluir nome do modulo logado
     GENE0001.pc_informa_acesso(pr_module => 'TELA_ATENDA_DSCTO_TIT',pr_action => NULL);
   
     pr_qtregist:= 0; -- zerando a variável de quantidade de registros no cursos
     

    
     --carregando os dados de prazo limite da TAB052 
     -- BUSCAR O PRAZO PARA PESSOA FISICA
     cecred.dsct0002.pc_busca_titulos_bordero (
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
      
      vr_index := vr_tab_tit_bordero.first;
      -- abrindo cursos de títulos
       WHILE vr_index IS NOT NULL LOOP
         
             pr_qtregist:= pr_qtregist+1;
             /*
             OPEN cr_tbdsct_analise_pagador(
                  pr_cdcooper,
                  pr_nrdconta,
                  vr_tab_tit_bordero(vr_index).nrinssac);
             FETCH cr_tbdsct_analise_pagador INTO rw_tbdsct_analise_pagador;
             CLOSE cr_tbdsct_analise_pagador;
             */
             pr_tab_tit_bordero(vr_index).nrdctabb := vr_tab_tit_bordero(vr_index).nrdctabb;
             pr_tab_tit_bordero(vr_index).nrcnvcob := vr_tab_tit_bordero(vr_index).nrcnvcob;
             pr_tab_tit_bordero(vr_index).nrinssac := vr_tab_tit_bordero(vr_index).nrinssac;
             pr_tab_tit_bordero(vr_index).cdbandoc := vr_tab_tit_bordero(vr_index).cdbandoc;
             pr_tab_tit_bordero(vr_index).nrdconta := vr_tab_tit_bordero(vr_index).nrdconta;
             pr_tab_tit_bordero(vr_index).nrdocmto := vr_tab_tit_bordero(vr_index).nrdocmto;
             pr_tab_tit_bordero(vr_index).dtvencto := vr_tab_tit_bordero(vr_index).dtvencto;
             pr_tab_tit_bordero(vr_index).dtlibbdt := vr_tab_tit_bordero(vr_index).dtlibbdt;
             pr_tab_tit_bordero(vr_index).nossonum := vr_tab_tit_bordero(vr_index).nossonum;
             pr_tab_tit_bordero(vr_index).vltitulo := vr_tab_tit_bordero(vr_index).vltitulo;
             pr_tab_tit_bordero(vr_index).vlliquid := vr_tab_tit_bordero(vr_index).vlliquid;
             pr_tab_tit_bordero(vr_index).nmsacado := vr_tab_tit_bordero(vr_index).nmsacado;
             pr_tab_tit_bordero(vr_index).insittit := vr_tab_tit_bordero(vr_index).insittit;
             pr_tab_tit_bordero(vr_index).flgregis := vr_tab_tit_bordero(vr_index).flgregis;
            
             --crapcob.flgregis
             vr_index := vr_tab_tit_bordero.next(vr_index);
       END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na TELA_ATENDA_DSCTO_TIT.pc_buscar_tit_bordero ' ||sqlerrm;
                                  
END pc_buscar_tit_bordero;
  
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
                                ) IS

    -- variaveis de retorno
    vr_tab_tit_bordero typ_tab_tit_bordero;

    /* tratamento de erro */
    vr_exc_erro exception;
  
    vr_tab_erro         gene0001.typ_tab_erro;
    vr_qtregist         number;
    vr_des_reto varchar2(3);
    
    -- variaveis de entrada vindas no xml
    vr_cdcooper integer;
    vr_cdoperad varchar2(100);
    vr_nmdatela varchar2(100);
    vr_nmeacao  varchar2(100);
    vr_cdagenci varchar2(100);
    vr_nrdcaixa varchar2(100);
    vr_idorigem varchar2(100);

    -- variáveis para armazenar as informaçoes em xml
    vr_des_xml        clob;
    vr_texto_completo varchar2(32600);
    vr_index          PLS_INTEGER;
    
    -- Variável de críticas
     vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
     vr_dscritic varchar2(1000);        --> Desc. Erro

      procedure pc_escreve_xml( pr_des_dados in varchar2
                              , pr_fecha_xml in boolean default false
                              ) is
      begin
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
      end;

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

      pc_buscar_tit_bordero(vr_cdcooper  --> Código da Cooperativa
                       ,pr_nrdconta --> Número da Conta
                       ,vr_cdagenci --> Agencia de operação
                       ,vr_nrdcaixa --> Número do caixa
                       ,vr_cdoperad --> Operador
                       ,vr_idorigem --> Identificação de origem
                        --------> PARMAS <--------
                       ,pr_nrborder --> numero do bordero
                       --------> OUT <--------
                       ,vr_qtregist --> Quantidade de registros encontrados
                       ,vr_tab_tit_bordero --> Tabela de retorno dos títulos encontrados
                       ,vr_cdcritic --> Código da crítica
                       ,vr_dscritic --> Descrição da crítica
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
      vr_index := vr_tab_tit_bordero.first;
      while vr_index is not null loop    
            pc_escreve_xml('<inf>'||
                              '<cdbandoc>' || vr_tab_tit_bordero(vr_index).cdbandoc || '</cdbandoc>' || --FIELD cdbandoc LIKE craptdb.cdbandoc
                              '<nrdconta>' || vr_tab_tit_bordero(vr_index).nrdconta || '</nrdconta>' || --FIELD nrdconta LIKE craptdb.nrdconta
                              '<nrdocmto>' || vr_tab_tit_bordero(vr_index).nrdocmto || '</nrdocmto>' || --FIELD nrdocmto LIKE craptdb.nrdocmto
                              '<dtvencto>' || vr_tab_tit_bordero(vr_index).dtvencto || '</dtvencto>' || --FIELD dtvencto LIKE craptdb.dtvencto
                              '<dtlibbdt>' || vr_tab_tit_bordero(vr_index).dtlibbdt || '</dtlibbdt>' || --FIELD dtlibbdt LIKE craptdb.dtlibbdt
                              '<nrinssac>' || vr_tab_tit_bordero(vr_index).nrinssac || '</nrinssac>' || --FIELD nrinssac LIKE craptdb.nrinssac
                              '<nrcnvcob>' || vr_tab_tit_bordero(vr_index).nrcnvcob || '</nrcnvcob>' || --FIELD nrcnvcob LIKE craptdb.nrcnvcob
                              '<nrdctabb>' || vr_tab_tit_bordero(vr_index).nrdctabb || '</nrdctabb>' || --FIELD nrdctabb LIKE craptdb.nrdctabb
                              '<vltitulo>' || vr_tab_tit_bordero(vr_index).vltitulo || '</vltitulo>' || --FIELD vltitulo LIKE craptdb.vltitulo
                              '<vlliquid>' || vr_tab_tit_bordero(vr_index).vlliquid || '</vlliquid>' || --FIELD vlliquid LIKE craptdb.vlliquid
                              '<nossonum>' || vr_tab_tit_bordero(vr_index).nossonum || '</nossonum>' || --FIELD nossonum AS CHAR
                              '<nmsacado>' || vr_tab_tit_bordero(vr_index).nmsacado || '</nmsacado>' || --FIELD nmsacado AS CHAR
                              '<insittit>' || vr_tab_tit_bordero(vr_index).insittit || '</insittit>' || --FIELD insittit LIKE craptdb.insittit
                              '<flgregis>' || vr_tab_tit_bordero(vr_index).flgregis || '</flgregis>' || --FIELD flgregis AS LOG  FORMAT "REGISTRADA/SEM REGISTRO"
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_tit_bordero.next(vr_index);
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
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_titcto.pc_buscar_titulos_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_buscar_tit_bordero_web;
   






END TELA_ATENDA_DSCTO_TIT;
/
