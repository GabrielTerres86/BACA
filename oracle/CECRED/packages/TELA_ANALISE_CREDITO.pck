create or replace package cecred.TELA_ANALISE_CREDITO is

  pr_nmdatela constant varchar(40) := 'TELA_ANALISE_CREDITO';

  /* Tabelas para armazenar os retornos dos birôs, titulos e detalhes*/

  -- TempTable para retornar valores para tela Atenda (Antigo b1wgen0001tt.i/tt-valores_conta)
  TYPE typ_rec_valores_conta
    IS RECORD ( vlsldcap NUMBER(32,8),
    vlsldepr       NUMBER(32, 8),
    vlsldapl       NUMBER(32, 8),
    vlsldinv       NUMBER(32, 8),
    vlsldppr       NUMBER(32, 8),
    vlstotal       NUMBER(32, 8),
    vllimite       NUMBER(32, 8),
    qtfolhas       NUMBER(32, 8),
    qtconven       NUMBER(32, 8),
    flgocorr       INTEGER,
    dssitura       VARCHAR2(100),
    vllautom       NUMBER(32, 8),
    dssitnet       VARCHAR2(100),
    vltotpre       NUMBER(32, 8),
    vltotccr       NUMBER(32, 8),
    qtcarmag       INTEGER,
    qttotseg       NUMBER(18),
    vltotseg       NUMBER(32, 8),
    vltotdsc       NUMBER(32, 8),
    flgbloqt       INTEGER,
    vllimite_saque tbtaa_limite_saque.vllimite_saque%TYPE,
    pacote_tarifa  BOOLEAN,
    vldevolver     NUMBER(32, 8),
    insituacprvd   tbprevidencia_conta.insituac%TYPE,
    idportab       NUMBER,
    insitapi       NUMBER);
  TYPE typ_tab_valores_conta IS TABLE OF typ_rec_valores_conta
    INDEX BY PLS_INTEGER;

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

  --Tipo de Registro para Empresas Participantes (b1wgen0080tt.i)
  TYPE typ_reg_crapepa IS
    RECORD (cdcooper crapepa.cdcooper%type
           ,nrdconta crapepa.nrdconta%type
           ,nrdocsoc crapepa.nrdocsoc%type
           ,nrctasoc crapepa.nrctasoc%type
           ,nmfansia crapepa.nmfansia%type
           ,nrinsest crapepa.nrinsest%type
           ,natjurid crapepa.natjurid%type
           ,dtiniatv crapepa.dtiniatv%type
           ,qtfilial crapepa.qtfilial%type
           ,qtfuncio crapepa.qtfuncio%type
           ,dsendweb crapepa.dsendweb%type
           ,cdseteco crapepa.cdseteco%type
           ,cdmodali crapepa.cdmodali%type
           ,cdrmativ crapepa.cdrmativ%type
           ,vledvmto crapepa.vledvmto%type
           ,dtadmiss crapepa.dtadmiss%type
           ,dtmvtolt crapepa.dtmvtolt%type
           ,persocio crapepa.persocio%type
           ,nmprimtl crapepa.nmprimtl%type
           ,cddconta VARCHAR2(1000)
           ,dsvalida VARCHAR2(1000)
           ,cdcpfcgc VARCHAR2(100)
           ,dsestcvl VARCHAR2(1000)
           ,nrdrowid ROWID
           ,nmseteco craptab.dstextab%type
           ,dsnatjur gncdntj.dsnatjur%type
           ,dsrmativ gnrativ.nmrmativ%type);  
           
  --Tipo de tabela de memoria para empresas participantes
  TYPE typ_tab_crapepa IS TABLE OF typ_reg_crapepa INDEX BY PLS_INTEGER;           

  
  /* Utilizado para carregar os dados da atenda para ser reutilizados */
  vr_tab_cabec            CADA0004.typ_tab_cabec;
  vr_tab_comp_cabec       CADA0004.typ_tab_comp_cabec;
  vr_tab_valores_conta    CADA0004.typ_tab_valores_conta;
  vr_tab_crapobs          CADA0004.typ_tab_crapobs;
  vr_tab_mensagens_atenda CADA0004.typ_tab_mensagens_atenda;

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
        ,CASE WHEN tdb.insittit = 2 AND tdb.dtdpagto > gene0005.fn_valida_dia_util(tdb.cdcooper, tdb.dtvencto) THEN 
              'Pago após vencimento'
              ELSE dsct0003.fn_busca_situacao_titulo(tdb.insittit, 1) 
          END dssittit
        ,nvl((SELECT decode(inpossui_criticas,1,'S','N')
                 FROM tbdsct_analise_pagador tap
                WHERE tap.cdcooper = cob.cdcooper
                  AND tap.nrdconta = cob.nrdconta
              AND    tap.nrinssac = cob.nrinssac),'A') AS dssituac
        ,COUNT(1) over() qtregist 
      FROM crapcob cob
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
     WHERE cob.flgregis > 0
       AND cob.incobran = 0
       AND cob.nrdconta = pr_nrdconta
       AND cob.cdcooper = pr_cdcooper
       AND cob.nrcnvcob = pr_nrcnvcob
       AND cob.cdbandoc = pr_cdbandoc
       AND cob.nrdctabb = pr_nrdctabb
       AND cob.nrdocmto = pr_nrdocmto;
  rw_crapcob cr_crapcob%rowtype;

FUNCTION fn_tag(pr_nome in varchar2,
                pr_valor in varchar2)  return varchar2;

FUNCTION fn_zeroToNull(p_valor in number) return varchar2;

function fn_le_json_motor(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in NUMBER DEFAULT 0) return varchar2;
                          
function fn_le_json_motor_auto_aprov(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in number) return clob;
  
                          
function fn_getNivelRisco(p_nivelRisco in number) return varchar2;

  FUNCTION fn_nao_cooperado(pr_nrdconta IN NUMBER) RETURN VARCHAR2;

  PROCEDURE pc_consulta_consultas(pr_cdcooper   IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                           ,pr_nrcontrato IN crawepr.nrctremp%TYPE       --> Nr contrato
                           ,pr_inpessoa  IN crapass.inpessoa%TYPE
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                           ,pr_persona  IN VARCHAR2
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                           ,pr_dsxmlret OUT CLOB); 

  PROCEDURE pc_gera_token_ibratan(pr_cdcooper IN crapope.cdcooper%TYPE, --> cooperativa
                                  pr_cdagenci IN crapope.cdagenci%TYPE, --> Agencia
                                  pr_cdoperad IN crapope.cdoperad%TYPE, --> Operador
                                  pr_dstoken  OUT VARCHAR2, --> Token
                                  pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                  pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  );
PROCEDURE pc_consulta_consultas_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE  --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                                     ,pr_nrcontrato IN crawepr.nrctremp%TYPE       --> Nr contrato
                                     ,pr_inpessoa  IN crapass.inpessoa%TYPE
                                     ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                     ,pr_persona  IN VARCHAR2
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                     ,pr_dsxmlret OUT CLOB);


  PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta   IN crawepr.nrdconta%TYPE --> Conta
                                        ,pr_tpproduto IN number                      --> Produto
                                         ,pr_nrcontrato IN crawepr.nrctremp%TYPE      --> Número contrato emprestimo
                                         ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_job_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                      ,pr_tpproduto IN number                      --> Produto
                                      ,pr_nrctremp  IN crawepr.nrctremp%TYPE       --> Número contrato emprestimo
                                      ,pr_dscritic OUT VARCHAR2);                  --> Descricao da critica

  PROCEDURE pc_gera_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number);

  PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number                      --> Número contrato
                                       ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                                       ,pr_dsxmlret IN OUT NOCOPY xmltype);

  PROCEDURE pc_consulta_cadastro_pf(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE --> IDPESSOA
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_cadastro_pj(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_cad_conjuge_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                         ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                         ,pr_dsxmlret OUT CLOB);               --> Arquivo de retorno do XML

  PROCEDURE pc_consulta_garantia(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_nrctrato IN crawepr.nrctremp%TYPE       --> Contrato
                                ,pr_tpproduto IN NUMBER                     --> Tipo de Produto
                                ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                ,pr_dsxmlret IN OUT CLOB);

  PROCEDURE pc_consulta_garantia_operacao (pr_cdcooper crapass.cdcooper%TYPE
                                          ,pr_nrdconta crapass.nrdconta%TYPE
                                          ,pr_nrctremp crawepr.nrctremp%TYPE
                                          ,pr_tpproduto in number
                                          ,pr_chamador in varchar2 default 'O' -- Operações busca nas crap e P= Propostas nas W
                                          ,pr_retorno  OUT number
                                          ,pr_retxml   IN OUT NOCOPY xmltype);                              

  PROCEDURE pc_consulta_scr(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                           ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                           ,pr_persona  IN Varchar2
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%type       --> CPFCGC
                           ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                           ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_scr2(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                            ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                            ,pr_dsxmlret OUT varchar2);  

PROCEDURE pc_consulta_scr_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                                 ,pr_persona  IN Varchar2
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%type       --> CPFCGC
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_scr_conj_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                                      ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE         --> CPFCGC
                                      ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                      ,pr_dsxmlret OUT CLOB);
  PROCEDURE pc_consulta_operacoes(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                                 ,pr_nrctrato  in crawepr.nrctremp%type
                                 ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB);


  PROCEDURE pc_consulta_proposta_epr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                    ,pr_nrctrato  IN number
                                    ,pr_inpessoa  IN crapass.inpessoa%TYPE                                    
                                    ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                    ,pr_dsxmlret  OUT CLOB);

  PROCEDURE pc_consulta_proposta_limite(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                     ,pr_dsxmlret IN OUT CLOB);                                    

  /*Propostas para Cartão de Crédito*/
  PROCEDURE pc_consulta_proposta_cc(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                 ,pr_nrctrato  IN number
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret  OUT CLOB);

  PROCEDURE pc_consulta_proposta_bordero(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                         ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                         ,pr_dsxmlret IN OUT CLOB);

  PROCEDURE pc_consulta_outras_pro_epr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                    ,pr_nrctrato  IN number
                                    ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                       
                                    ,pr_dsxmlret  OUT CLOB);


  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy clob,
                           pr_texto_novo in clob,
                           pr_fecha_xml in boolean default false);

  PROCEDURE pc_consulta_hist_cartaocredito(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                           ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                           ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                              
                                           ,pr_dsxmlret IN OUT CLOB);

  PROCEDURE pc_consulta_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB);                          

  PROCEDURE pc_consulta_lim_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB);

   procedure pc_consulta_lim_desc_tit(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB); 

  PROCEDURE pc_consulta_lim_cred(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB);                            
    

  PROCEDURE pc_modalidade_lim_credito(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB);                                                           

  PROCEDURE pc_modalidade_car_cred(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                      
                                   ,pr_dsxmlret IN OUT CLOB);

  PROCEDURE pc_consulta_bordero(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB );

   PROCEDURE pc_busca_rendas_aut(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_xmlRenda OUT VARCHAR2);   

  PROCEDURE pc_consulta_desc_titulo(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB ); 

  PROCEDURE pc_consulta_lanc_futuro(pr_cdcooper IN crapass.cdcooper%TYPE
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB ); 


  PROCEDURE pc_consulta_bordero_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB);
  
  PROCEDURE pc_insere_analise_cred_acessos(pr_cdcooper        IN NUMBER,
                                           pr_nrdconta        IN NUMBER,
                                           pr_cdoperador      IN varchar2,
                                           pr_nrcontrato      IN NUMBER,
                                           pr_tpproduto       IN NUMBER,
                                           pr_dhinicio_acesso IN VARCHAR2,
                                           pr_dhfim_acesso    IN VARCHAR2,
                                           pr_idanalise_contrato_acesso IN NUMBER,
                                           pr_xmllog    IN VARCHAR2,           
                                           pr_cdcritic OUT PLS_INTEGER,        
                                           pr_dscritic OUT VARCHAR2,           
                                           pr_retxml    IN OUT NOCOPY xmltype, 
                                           pr_nmdcampo OUT VARCHAR2,           
                                           pr_des_erro OUT VARCHAR2);

END TELA_ANALISE_CREDITO;
/
create or replace package body cecred.TELA_ANALISE_CREDITO is

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ANALISE_CREDITO
  --  Sistema  : Aimaro/Ibratan
  --  Autor    : Equipe Mouts
  --  Data     : Março/2019                 Ultima atualizacao: 25/07/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar consultas para analise de credito
  --
  -- Alteracoes: 12/06/2019 - Ajuste para zerar as váriaveis de Garantia de Aplicação 
  --                          antes de serem populadas (Mateus Z / Mouts)
  --
  --             13/06/2019 - Alterado Calculo do Saldo ADP. Implementado para buscar
  --                          do Zoom0001.pc_consultar_limite_adp (Rafael Ferreira / Mouts)
  ---------------------------------------------------------------------------

  /*
  Código do segmento de produto de crédito
  0 – CDC Diversos,
  1 – CDC Veículos,
  2 – Empréstimos /Financiamentos,
  3 – Desconto Cheques – Limite,
  4 – Desconto Cheques - Borderô,
  5 – Desconto Título – Limite,
  6 – Desconto de Títulos – Borderô,
  7 – Cartão de Crédito,
  8 – Limite de Crédito (Conta),
  9 – Consignado,
  10 - Rating
  */
  c_emprestimo      constant number(1):= 2;
  c_cartao          constant number(1):= 7;
  c_limite_desc_titulo constant number(1):= 5;
  c_desconto_titulo constant number(1):= 6;  
  c_desconto_cheque constant number(1):= 4;  

  /*Globais*/
  vr_nrdconta_principal   crapass.nrdconta%type;
  vr_cdcooper_principal   crapass.cdcooper%type;
  vr_tpproduto_principal  number(2);
  vr_nrctrato_principal   number(10);
  vr_nrcpfcgc_principal   crapass.nrcpfcgc%type;
  vr_parametros_principal VARCHAR2(200) := '';

  --vr_xml xmltype; -- XML que sera enviado
  vr_des_xml         clob; --para os titulos do bordero
  vr_texto_completo  varchar2(32600);

  vr_xml      CLOB; -- XML que sera enviado
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
  vr_idorigem number := 1;

  vr_nmdcampo VARCHAR2(250);
  vr_garantia VARCHAR2(250);
  vr_flconven INTEGER;
  vr_des_reto VARCHAR2(100);
  vr_tab_erro gene0001.typ_tab_erro;

   CURSOR c_pessoa_por_id(pr_idpessoa in number
                         ,pr_cdcooper in number) IS
   SELECT a.cdcooper
         ,a.nrdconta
         ,a.inpessoa
         ,a.nrcpfcgc
         ,a.inprejuz
     FROM crapass a,
          tbcadast_pessoa p
     WHERE p.idpessoa = pr_idpessoa
       AND a.nrcpfcgc = p.nrcpfcgc
       AND a.cdcooper = pr_cdcooper;
       --AND a.dtdemiss is null; --bug 19602 -- Retirado Spritt 15 - Homologação
      r_pessoa_por_id c_pessoa_por_id%rowtype;

  /*Chaves identificam a pessoa*/
   CURSOR c_pessoa(pr_cdcooper in crapass.cdcooper%type,
                   pr_nrdconta in crapass.nrdconta%type) IS
   SELECT a.nrdconta
         ,a.inpessoa
         ,a.nrcpfcgc
         ,p.idpessoa
         ,a.inprejuz
         ,a.dsdscore
     FROM crapass a,
          tbcadast_pessoa p
     WHERE nrdconta = pr_nrdconta
       AND cdcooper = pr_cdcooper
       AND a.nrcpfcgc = p.nrcpfcgc;
      r_pessoa c_pessoa%rowtype;

  /*Produto emprestimos*/
   CURSOR c_proposta_epr(pr_cdcooper in crapass.cdcooper%type,
                         pr_nrdconta in crapass.nrdconta%type,
                         pr_nrctremp in crawepr.nrctremp%type) IS
   select fn_tag('Contrato',gene0002.fn_mask_contrato(e.nrctremp)) contrato,
           fn_tag('Valor da Operação', to_char(e.vlemprst, '999g999g990d00')) valor_emprestimo,
           fn_tag('Valor das Parcelas', to_char(e.vlpreemp, '999g999g990d00')) valor_prestacoes,
           fn_tag('Quantidade de Parcelas', e.qtpreemp) qtd_parcelas,
           fn_tag('Linha de Crédito', e.cdlcremp || ' - ' || lcr.dslcremp) linha,
           fn_tag('Finalidade', e.cdfinemp || ' - ' || fin.dsfinemp) finalidade,
           fn_tag('CET', e.percetop || '%') cet,
           fn_tag('Cônjuge Co-responsável',decode(e.inconcje,1,'Sim','Não')) co_responsabilidade,
           --     garantia
           --     total Operações de Crédito
           e.cdcooper,
           e.nrdconta,
           e.nrctremp,
           e.vlemprst,
          TO_CHAR(NRCTRLIQ##1) || ',' || TO_CHAR(NRCTRLIQ##2) || ',' ||
          TO_CHAR(NRCTRLIQ##3) || ',' || TO_CHAR(NRCTRLIQ##4) || ',' ||
          TO_CHAR(NRCTRLIQ##5) || ',' || TO_CHAR(NRCTRLIQ##6) || ',' ||
          TO_CHAR(NRCTRLIQ##7) || ',' || TO_CHAR(NRCTRLIQ##8) || ',' ||
          TO_CHAR(NRCTRLIQ##9) || ',' || TO_CHAR(NRCTRLIQ##10) dsliquid,
           e.dsnivris,
           e.dtmvtolt,
           e.cdfinemp,
           e.cdlcremp,
           e.qtpreemp,
           e.vlpreemp,
           e.dtdpagto,
           e.dtlibera,
           e.tpemprst,
           e.dtcarenc,
           c.qtddias,
           nvl(e.idfiniof, 0) idfiniof,
          e.nrctrliq##1 || ',' ||
          e.nrctrliq##2 || ',' ||
          e.nrctrliq##3 || ',' ||
          e.nrctrliq##4 || ',' ||
          e.nrctrliq##5 || ',' ||
          e.nrctrliq##6 || ',' ||
          e.nrctrliq##7 || ',' ||
          e.nrctrliq##8 || ',' ||
          e.nrctrliq##9 || ',' ||
          e.nrctrliq##10 dsctrliq
      from crawepr e,
           craplcr lcr,
           crapfin fin,
           tbepr_posfix_param_carencia c
     where e.cdcooper = pr_cdcooper
       and e.nrdconta = pr_nrdconta
       and e.nrctremp = pr_nrctremp
       and lcr.cdcooper = e.cdcooper
       and lcr.cdlcremp = e.cdlcremp
       and fin.cdcooper = e.cdcooper
       and fin.cdfinemp = e.cdfinemp
       and e.idcarenc   = c.idcarencia(+);
   r_proposta_epr c_proposta_epr%rowtype;

  /*Produto emprestimos*/
   CURSOR c_proposta_out_epr(pr_cdcooper in crapass.cdcooper%type,
                             pr_nrdconta in crapass.nrdconta%type) IS
    select e.nrctremp contrato,
           e.vlemprst valor_emprestimo,
           e.vlpreemp valor_prestacoes,
           e.qtpreemp qtd_parcelas,
           e.cdlcremp || ' - ' || lcr.dslcremp linha,
           e.cdfinemp || ' - ' || fin.dsfinemp finalidade,
           e.percetop cet,
           --     garantia
           --     total Operações de Crédito
           e.vlemprst,
           e.cdcooper,
           e.nrdconta,
           e.nrctremp,
           decode(e.insitapr,0,'Não Analisado',1,'Aprovado',2,'Não aprovado',3,'Restrição',4,'Refazer',5,'Derivar',6,'Erro') decisao,
           decode(e.insitest,0,'Não Enviada',1,'Enviada Análise Automática',2,'Enviada Análise Manual',3,'Análise Finalizada',4,'Expirado') situacao,
           e.dtmvtolt dtproposta,
           nvl(trim(fn_zeroToNull(e.nrctrliq##1)||' '||
           fn_zeroToNull(e.nrctrliq##2)||' '||
           fn_zeroToNull(e.nrctrliq##3)||' '||
           fn_zeroToNull(e.nrctrliq##4)||' '||
           fn_zeroToNull(e.nrctrliq##5)||' '||
           fn_zeroToNull(e.nrctrliq##6)||' '||
           fn_zeroToNull(e.nrctrliq##7)||' '||
           fn_zeroToNull(e.nrctrliq##8)||' '||
           fn_zeroToNull(e.nrctrliq##9)||' '||
           fn_zeroToNull(e.nrctrliq##10)||' '||
           e.nrliquid),'-') contratos, -- Incluído nrliquid que corresponde ao contratos de CC liquidados
           e.nrctaav1,
           e.nrctaav2
      from crawepr e,
           craplcr lcr,
           crapfin fin
     where e.cdcooper = pr_cdcooper
       and e.nrdconta = pr_nrdconta
       and lcr.cdcooper = e.cdcooper
       and lcr.cdlcremp = e.cdlcremp
       and fin.cdcooper = e.cdcooper                    
       and fin.cdfinemp = e.cdfinemp
       and not exists (select 1
                         from crapepr p
                        where e.cdcooper = p.cdcooper
                          and e.nrdconta = p.nrdconta
                          and e.nrctremp = p.nrctremp);
   r_proposta_out_epr c_proposta_out_epr%rowtype;

  /*Cursores*/
  cursor c_cadastro(pr_cdcooper crapass.cdcooper%type,
                    pr_nrdconta crapass.nrdconta%type) is
  select fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta
        ,fn_tag('PA',age.cdagenci||'-'||age.nmresage) pa -- Número do PA e nome do PA         
        ,fn_tag('Nome',a.nmprimtl) nome,
           fn_tag('Idade', trunc((months_between(rw_crapdat.dtmvtolt, a.dtnasctl)) / 12) || ' anos') idade,
           fn_tag('CPF', gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc, 1)) cpf_tag,
           fn_tag('Estado Civil', ec.dsestcvl) estado_civil,
           fn_tag('Naturalidade', tl.dsnatura) dsnatura,
         fn_tag('Tempo de Cooperativa',trunc((months_between(rw_crapdat.dtmvtolt, a.dtmvtolt))/12)||' anos e '||
         trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt), a.dtmvtolt), 12))||' meses ') tempocoop, -- Bug 20750 -- estava dtadmiss - Paulo
           a.nrcpfcgc cpf,
           a.cdsitdct,
           fn_tag('Tipo de Conta', CADA0004.fn_dstipcta(pr_inpessoa => a.inpessoa, pr_cdtipcta => a.cdtipcta)) tipoconta,
           fn_tag('Situação da Conta', CADA0004.fn_dssitdct(pr_cdsitdct => a.cdsitdct)) situacao_conta,
           tl.cdocpttl
    from crapass a,
         crapage age,
         crapttl tl,
         gnetcvl ec
   where a.cdagenci = age.cdagenci
     and a.cdcooper = age.cdcooper
     and a.cdcooper = pr_cdcooper
     and a.nrdconta = pr_nrdconta
     and a.nrdconta = tl.nrdconta
     and a.cdcooper = tl.cdcooper
     and tl.cdestcvl = ec.cdestcvl
     and tl.idseqttl = 1;
   r_cadastro c_cadastro%rowtype;

  /* Cadastro Pessoa Juridica */
   cursor c_cadastro_pj (pr_nrdconta crapass.nrdconta%type
                        ,pr_cdcooper crapass.cdcooper%type
                        ,pr_dtmvtolt crapdat.dtmvtolt%type) is
     select
            fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta
           --,fn_tag('Tipo de Conta','Jurídica') tipoconta
           ,fn_tag('Tipo de Conta',CADA0004.fn_dstipcta (pr_inpessoa => a.inpessoa, pr_cdtipcta => a.cdtipcta)) tipoconta
           ,fn_tag('Situação da Conta',CADA0004.fn_dssitdct(pr_cdsitdct => a.cdsitdct)) situacao_conta
           ,fn_tag('PA',age.cdagenci||'-'||age.nmresage) pa -- Número do PA e nome do PA
           ,fn_tag('Razão Social',a.nmprimtl) rsocial -- Razão Social
           ,fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,2)) cnpj -- CNPJ
           ,fn_tag('Ramo de Atividade',gnr.nmrmativ) nmrmativ -- Ramo de atividade
           ,fn_tag('Tempo de Empresa',trunc((months_between(pr_dtmvtolt, nvl(jur.dtiniatv,pr_dtmvtolt)))/12)||' anos e '||
             trunc(mod(months_between(trunc(pr_dtmvtolt),nvl(jur.dtiniatv,pr_dtmvtolt)), 12))||' meses ') tempoempresa -- Tempo de Empresa
           ,fn_tag('Tempo de Cooperativa',trunc((months_between(pr_dtmvtolt, a.dtmvtolt))/12)||' anos e '||
             trunc(mod(months_between(trunc(pr_dtmvtolt), a.dtmvtolt), 12))||' meses ') tempocoop -- Tempo de Cooperativa
           ,a.nrcpfcgc cnpj_sem_format  
      from crapass a,
           crapage age,
           crapjur jur,
           gnrativ gnr
      where a.cdagenci = age.cdagenci
      and   jur.cdrmativ = gnr.cdrmativ
      and   a.cdcooper = jur.cdcooper
      and   age.cdcooper = a.cdcooper
      and   a.cdcooper = age.cdcooper
      and   a.nrdconta = jur.nrdconta
      and   a.cdcooper = pr_cdcooper
      and   a.inpessoa = 2 --Juridica
          --and   a.cdtipcta = 8 --Tipo de conta normal convenio
          --and   a.cdsitdct = 1 --Liberada
      and   a.nrdconta = pr_nrdconta;
  r_cadastro_pj c_cadastro_pj%ROWTYPE;

  /*Cursor Bens*/
   cursor c_bens(pr_cdcooper crapass.cdcooper%type,
                 pr_nrdconta crapass.nrdconta%type
                 ) is
   select b.dsrelbem,
          b.persemon,
          b.qtprebem,
          b.vlprebem,
          b.vlrdobem,
          null coluna6,
          null coluna7,
          null coluna8
     from crapbem b
    where b.cdcooper = pr_cdcooper
      and b.nrdconta = pr_nrdconta
      and b.idseqttl = 1;
   r_bens c_bens%rowtype;

  /* 1.2 Cursor Patrimônios Residência PJ */
   cursor c_patrimonio_pj_reside (pr_nrdconta crapass.nrdconta%type
                                 ,pr_cdcooper crapass.cdcooper%type
                                 ,pr_dtmvtolt crapdat.dtmvtolt%type) is
    select vlalugue
          ,fn_tag('Tipo de Imóvel',tipoimovel) tipoimovel
          ,fn_tag('Tempo de Residência',temporeside) temporeside
          ,tipoimovel tpimovel
     from
      (select enc.vlalugue
            ,decode(enc.incasprp,1,'Quitado',2,'Financiado',3,'Alugado',4,'Familiar',5,'Cedido') tipoimovel
            ,trunc((months_between(pr_dtmvtolt, enc.dtinires))/12)||' anos e '||
               trunc(mod(months_between(pr_dtmvtolt, enc.dtinires), 12))||' meses ' temporeside
      from crapenc enc
      where enc.cdcooper = pr_cdcooper
      and   enc.nrdconta = pr_nrdconta
      and   enc.dtinires is not null
      order by idseqttl)
    where rownum<=1;
    r_patrimonio_pj c_patrimonio_pj_reside%rowtype;

  /* 1.2.1 Cursor Bens PJ - Tabela*/
   cursor c_bens_pj (pr_nrdconta crapass.nrdconta%type
                    ,pr_cdcooper crapass.cdcooper%type) IS
     select b.dsrelbem,
           b.persemon || ' %' persemon,
           b.qtprebem,
           b.vlprebem,
           b.vlrdobem,
            null coluna6,
            null coluna7,
            null coluna8
       from crapbem b
      where b.cdcooper = pr_cdcooper
        and b.nrdconta = pr_nrdconta
        and b.idseqttl = 1;
  --   r_bens_pj c_bens_pj%rowtype;

  /* 1.3 Dados Comerciais - Faturamento PJ */
   cursor c_dados_comerciais_fat (pr_nrdconta crapass.nrdconta%type,
                                  pr_cdcooper crapass.cdcooper%type) is
    select fn_tag('Faturamento Médio Bruto Mês',to_char(round(((
            jfn.vlrftbru##1 +
            jfn.vlrftbru##2 +
            jfn.vlrftbru##3 +
            jfn.vlrftbru##4 +
            jfn.vlrftbru##5 +
            jfn.vlrftbru##6 +
            jfn.vlrftbru##7 +
            jfn.vlrftbru##8 +
            jfn.vlrftbru##9 +
            jfn.vlrftbru##10 +
            jfn.vlrftbru##11 +
            jfn.vlrftbru##12) / 
            (decode(jfn.vlrftbru##1,0,0,1) + 
             decode(jfn.vlrftbru##2,0,0,1) +
             decode(jfn.vlrftbru##3,0,0,1) +
             decode(jfn.vlrftbru##4,0,0,1) +
             decode(jfn.vlrftbru##5,0,0,1) +
             decode(jfn.vlrftbru##6,0,0,1) +
             decode(jfn.vlrftbru##7,0,0,1) +
             decode(jfn.vlrftbru##8,0,0,1) +
             decode(jfn.vlrftbru##9,0,0,1) +
             decode(jfn.vlrftbru##10,0,0,1) +
             decode(jfn.vlrftbru##11,0,0,1) +
             decode(jfn.vlrftbru##12,0,0,1))
            ),2),'999g999g990d00')) vlrmedfatbru --Faturamento Medio Bruto Mes
           ,fn_tag('Concentração de Faturamento em Único Cliente',jfn.perfatcl||' %') perfatcl --Concentracao Fat Unico Cliente
    from crapjfn jfn    where jfn.cdcooper = pr_cdcooper --Viacredi
    and   jfn.nrdconta = pr_nrdconta;
    r_dados_comerciais_fat c_dados_comerciais_fat%rowtype;

  /*Dados Comerciais*/
    CURSOR c_dados_comerciaisI(pr_nrcpf in number) IS
    SELECT fn_tag('Natureza da Ocupação', p.cdnatureza_ocupacao || ' - ' || o.dsnatocp) natureza_ocupacao,
           fn_tag('Cargo', p.dsprofissao) profissao,
           fn_tag('Justificativa', p.dsjustific_outros_rend) jusrendimento,
           p.idpessoa
        FROM vwcadast_pessoa_fisica p,
             gncdnto o
     WHERE p.nrcpf = pr_nrcpf
       AND p.cdnatureza_ocupacao = o.cdnatocp;
  r_dados_comerciaisI c_dados_comerciaisI%ROWTYPE;

  /*Dados Comerciais*/
  CURSOR c_dados_comerciaisII(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT fn_tag('Tipo de Contrato de Trabalho',decode(r.tpcontrato_trabalho,1,'Permanente',2,'Temporário/Terceiro',3,'Sem Vínculo',4,'Autonomo')) tipo_contrato_trab,
             fn_tag('Tempo de Empresa',decode(r.dtadmissao, null, '-', trunc((months_between(rw_crapdat.dtmvtolt, r.dtadmissao))/12)||' anos e '||
             trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt), r.dtadmissao), 12))||' meses ')) tempoempresa,
           fn_tag('Salário', to_char(r.vlrenda, '999g999g990d00')) vlrenda,
             fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(e.nrcpfcgc,case when e.nrcpfcgc > 11 then 2 else 1 end)) nrcpfcgc,
           fn_tag('Nome da Empresa', emp.nmpessoa) empresa
        FROM tbcadast_pessoa_renda r,
             tbcadast_pessoa e,
             tbcadast_pessoa emp
     WHERE r.idpessoa = pr_idpessoa
       AND r.idpessoa_fonte_renda = emp.idpessoa(+) --bug 20860, 21563
       AND r.idpessoa = e.idpessoa; --bug 20645
  r_dados_comerciaisII c_dados_comerciaisII%ROWTYPE;

    CURSOR c_gncdocp (pr_cddocupa IN gncdocp.cdocupa%type) IS
    SELECT fn_tag('Ocupação', gncdocp.cdocupa || ' - ' || gncdocp.rsdocupa) rsdocupa
      FROM gncdocp
     WHERE gncdocp.cdocupa = pr_cddocupa;
  r_gncdocp c_gncdocp%ROWTYPE;


  --> buscar dados da renda complementar
  CURSOR c_renda_compl(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE) IS
      SELECT r.nrseq_renda,
             r.tprenda,
             d.dscodigo,
             r.vlrenda
        FROM tbcadast_pessoa_rendacompl r,
             tbcadast_dominio_campo d
     WHERE r.idpessoa = pr_idpessoa
       AND d.nmdominio = 'TPRENDA'
       AND d.cddominio = r.tprenda;
  r_renda_compl c_renda_compl%ROWTYPE;

  /*Endereço residencial pessoa física*/ --bug 19588
   cursor c_endereco_residencial(pr_idpessoa in number) is
   select fn_tag('Aluguel (Despesa)',decode(t.tpimovel,3,to_char(t.vldeclarado,'999g999g990d00'),0)) aluguel,
           fn_tag('Tipo de Imóvel', este0002.fn_des_incasprp(t.tpimovel)) tipoImovel,
           --fn_tag('Tempo de Residência',t.dtinicio_residencia)||' - '||
          fn_tag('Tempo de Residência',trunc((months_between(rw_crapdat.dtmvtolt,t.dtinicio_residencia))/12)||' anos e '||
          trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt),t.dtinicio_residencia), 12))||' meses ') tempoResidenciaAnos
     from tbcadast_pessoa_endereco t
     where t.idpessoa   = pr_idpessoa
       and t.tpendereco = 10; -- Residencial
   r_endereco_residencial c_endereco_residencial%rowtype;

  /*Socios conta PJ*/
  cursor c_socios(pr_cdcooper in number,
                  pr_nrdconta in number) is
  select s.cdcooper,
         s.nrdctato,
         s.nrcpfcgc
    from crapavt s
   where s.cdcooper = pr_cdcooper
     and s.tpctrato = 6 /*procurad*/ 
     and s.nrdconta = pr_nrdconta  
     and s.nrctremp = 0
     and s.persocio > 0; -- Somente com participação societaria      
  r_socios c_socios%rowtype;      

  /*Tela contas representante/procurador*/
  cursor c_repproc(pr_cdcooper in number,
                   pr_nrdconta in number) is  
    select s.cdcooper,
         s.nrdconta,
         s.nrdctato, -- Socios
         s.nrcpfcgc
    from crapavt s
   where s.cdcooper = pr_cdcooper
     and s.tpctrato = 6 /*procurad*/
     and s.nrdconta = pr_nrdconta -- Empresa
     and s.nrctremp = 0;

  /*Contas por cpfcnpj*/
    CURSOR c_contas(pr_cdcooper in number,
                    p_nrcpfcgc in crapass.nrcpfcgc%type) IS
     SELECT c.nmrescop
           ,a.nrdconta
           ,a.cdagenci
           ,a.dtadmiss
           ,a.inprejuz
           ,a.nrcpfcgc
           ,p.idpessoa
       FROM crapass a,
            crapcop c,
            tbcadast_pessoa p
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrcpfcgc = p_nrcpfcgc
        AND a.dtdemiss is null
       AND a.cdcooper = c.cdcooper
       AND a.nrcpfcgc = p.nrcpfcgc;
    r_contas c_contas%rowtype;  
  /*Outras Contas*/
  CURSOR c_outras_contas_pj(pr_cdcooper in number,
                            pr_nrdctato in number) IS
   SELECT a.nrdconta
         ,a.cdagenci
         ,a.dtadmiss
         ,a.inprejuz
         ,a.nrcpfcgc
         ,p.idpessoa
         ,a.inpessoa
         ,avt.dsproftl
         ,to_char(avt.dtvalida,'dd/mm/rrrr') dtvalida
     FROM crapass a,
          tbcadast_pessoa p,
          crapavt avt
     WHERE a.dtdemiss is null
       AND a.inpessoa = 2 -- PJ
       AND a.nrdconta = avt.nrdconta
       AND a.cdcooper = avt.cdcooper
       AND a.nrcpfcgc = p.nrcpfcgc
       AND avt.tpctrato = 6     
       AND avt.nrdctato > 0       
       AND avt.nrdctato = pr_nrdctato
       AND avt.cdcooper = pr_cdcooper;
       
  r_outras_contas_pj c_outras_contas_pj%rowtype;
  
  CURSOR c_outras_contas_qtd(pr_cdcooper in number,
                             pr_nrdctato in crapass.nrcpfcgc%type) IS
   SELECT count(1) qtd
     FROM crapass a,
          tbcadast_pessoa p,
          crapavt avt
     WHERE a.dtdemiss is null
       AND a.inpessoa = 2 -- PJ
       AND a.nrdconta = avt.nrdconta
       AND a.cdcooper = avt.cdcooper
       AND a.nrcpfcgc = p.nrcpfcgc
       AND avt.tpctrato = 6     
       AND avt.nrdctato > 0       
       AND avt.nrdctato = pr_nrdctato; 

  --cursor 3.3.1 b
  cursor c_busca_garantia (   pr_nrgarope IN craprad.nrseqite%TYPE,
                              pr_cdcooper IN craprad.cdcooper%TYPE ) IS
    SELECT nrseqite, cdcooper, dsseqite
      FROM craprad
   WHERE nrseqite = pr_nrgarope AND
         cdcooper = pr_cdcooper AND
         nrtopico = 4 AND -- Era 2 - Bug 20753 -- Paulo
           nritetop = 2;
  r_busca_garantia c_busca_garantia%ROWTYPE;

  vr_exc_erro EXCEPTION;
  vr_cdcritic PLS_INTEGER;
  vr_dscritic VARCHAR2(4000);

  -- Cursor para verificar se tem bem   
  CURSOR cr_crapbpr (pr_cdcooper in crapass.cdcooper%type,
                     pr_nrdconta in crapass.nrdconta%type,
                    pr_nrctremp IN craplem.nrctremp%TYPE) IS
    SELECT 1
      FROM crapbpr
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctrpro = pr_nrctremp
       AND tpctrpro = 90
       AND flgalien = 1;
  rw_crapbpr cr_crapbpr%ROWTYPE;

  vr_nrconbir crapcbd.nrconbir%TYPE;
  vr_nrseqdet crapcbd.nrseqdet%TYPE;

  /*Consultas a Cheques sem fundo*/
  cursor c_crapcsf(pr_nrconbir crapass.nrcpfcgc%type,
                   pr_nrseqdet crapvop.cdmodali%type) is  
  select nmbanchq,
         vlcheque,
         qtcheque
    from crapcsf 
   where nrconbir = pr_nrconbir 
     and nrseqdet = pr_nrseqdet;

    r_crapcsf c_crapcsf%rowtype;
  /*Consulta a SPC*/
 cursor c_craprsc(pr_nrconbir crapass.nrcpfcgc%type,
                  pr_nrseqdet crapvop.cdmodali%type) is    
    select decode(spc.inlocnac,1,'Local',2,'Nacional') inlocnac,
         spc.dsinstit,
         spc.nmcidade,
         nvl(spc.cdufende,'-') cdufende,
         spc.dtregist,
         spc.dtvencto,
         spc.vlregist,
         spc.dsmtvreg 
    from craprsc spc 
   where nrconbir = pr_nrconbir
     and nrseqdet = pr_nrseqdet;  
    --
    r_craprsc c_craprsc%rowtype;  

  -- Cheques - pc_consulta_desc_chq
  CURSOR c_limite_desc_chq(pr_cdcooper crapass.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT l.vllimite, l.nrctrlim, l.cddlinha, l.nrgarope, l.nrctaav1, l.nrctaav2
      FROM craplim l
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND tpctrlim = 2 -- Linha de Cheque
       AND insitlim = 2; -- Ativo   
  r_limite_desc_chq c_limite_desc_chq%ROWTYPE;

  -- Cheques - pc_consulta_desc_chq
  CURSOR c_bordero_cheques(pr_cdcooper crapass.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT c.vlcheque
      FROM crapcdb c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.insitchq = 2
       AND c.dtlibera > rw_crapdat.dtmvtolt;
  
  -- Cheques - pc_consulta_desc_chq
  CURSOR c_media_liquidez(pr_cdcooper crapass.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT c.dtlibera, insitchq, c.vlcheque
      FROM crapcdb c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.dtlibera BETWEEN TRUNC(add_months(rw_crapdat.dtmvtolt, -6), 'MM') AND rw_crapdat.dtmvtolt;
  --and c.dtlibbdc is not null;  Validado Valor com a Marje -- Dados conforme B.I. 04/06/2019 -- Paulo Martins
  r_media_liquidez c_media_liquidez%ROWTYPE;
  
  /*Desconto de Titulos*/
  CURSOR c_limite_desc_tit(pr_cdcooper crapass.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT c.nrctrlim,
           c.dtinivig,
           c.vllimite,
           c.dtfimvig,
           c.dhalteracao,
           decode(c.insitlim, 1, 'Em Estudo', 2, 'Ativo', 3, 'Cancelado', 'Outro') insitlim,
           c.dsmotivo
      FROM tbdsct_hist_alteracao_limite c
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND tpctrlim = 3 -- Linha de Titulo
    --and insitlim = 3 --  not in (1,2) -- Pegar Somente Cancelados ou outros...
     ORDER BY dtinivig DESC;
  r_lim_tit c_limite_desc_tit%rowtype;

  /*Cônjuge não cooperado*/
  CURSOR c_conjuge_nao_coop (pr_cdcooper IN crapcop.cdcooper%TYPE,
                             pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT j.nmconjug
          ,j.nrcpfcjg
    FROM crapcje j
    WHERE cdcooper = pr_cdcooper
    AND   nrdconta = pr_nrdconta
    AND   nrdconta <> nrctacje;
    r_conjuge_nao_coop c_conjuge_nao_coop%ROWTYPE;                            
  /*Dados Cadastrais Cônjuge não cooperado*/
  CURSOR c_consulta_cad_conjuge_ncoop (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT j.nmconjug
          ,j.nrcpfcjg
          ,j.dtnasccj
     FROM crapcje j
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta
     AND   nrdconta <> nrctacje;
    r_consulta_cad_conjuge_ncoop c_consulta_cad_conjuge_ncoop%ROWTYPE;
   /*Dados Comerciais Cônjuge não cooperado*/
   CURSOR c_dados_comerciais_conj_ncoop (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                         pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT este0002.fn_des_cdnatopc(j.cdnatopc) ntocupacao
          ,este0002.fn_des_cdocupa(j.cdocpcje) ocupacao
          ,este0002.fn_des_tpcttrab(j.tpcttrab) vinculo
          ,j.nmextemp empresa
          ,j.dsproftl cargo
          ,j.dtadmemp
          ,j.vlsalari
     FROM crapcje j
     WHERE j.cdcooper = pr_cdcooper
     AND   j.nrdconta = pr_nrdconta
     AND   j.nrdconta <> nrctacje;
    r_dados_comerciais_conj_ncoop c_dados_comerciais_conj_ncoop%ROWTYPE;  

  /*Busca a classe de risco*/
  CURSOR c_busca_classe_risco_serasa (pr_nrconbir IN crapcbd.nrconbir%TYPE
                                     ,pr_nrseqdet IN crapcbd.nrseqdet%TYPE) IS
   SELECT c.dsclaris
    FROM crapcbd c
    WHERE c.nrconbir = pr_nrconbir
    AND   c.nrseqdet = pr_nrseqdet;
   vr_dsclaris crapcbd.dsclaris%TYPE;                                   

  /*Busca a probabilidade de inadimplência*/
  CURSOR c_busca_inadimplencia (pr_nrconbir IN crapcbd.nrconbir%TYPE
                               ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
   SELECT c.peinadim
    FROM crapcbd c
    WHERE c.nrconbir = pr_nrconbir
    AND   c.nrcpfcgc = pr_nrcpfcgc
    AND   c.peinadim IS NOT NULL;
   vr_peinadim crapcbd.peinadim%TYPE;
  /*Para construção das tabelas*/
  /* Tipo para armazenamento das colunas*/
    TYPE typ_rec_tabela IS
      RECORD(coluna1 varchar2(1000),
             coluna2 varchar2(1000),
             coluna3 varchar2(1000),
             coluna4 varchar2(1000),
             coluna5 varchar2(1000),
             coluna6 varchar2(1000),
             coluna7 varchar2(1000),
             coluna8 varchar2(1000),
             coluna9 varchar2(1000),
             coluna10 varchar2(1000),
             coluna11 varchar2(1000),
             coluna12 varchar2(1000),
             coluna13 varchar2(1000),
             coluna14 varchar2(1000),
             coluna15 varchar2(1000),
             coluna16 varchar2(1000),
             coluna17 varchar2(1000),
             coluna18 varchar2(1000),
             coluna19 varchar2(1000),
             coluna20 varchar2(1000));

    TYPE typ_tab_tabela IS
      TABLE OF typ_rec_tabela
      INDEX BY PLS_INTEGER;

  vr_tab_tabela            typ_tab_tabela;
  vr_tab_tabela_secundaria typ_tab_tabela; --Tabela adicional de críticas para o borderô de desconto de títulos

  /*Registro para armazenar os risco*/
  TYPE typ_rec_dados_risco
    IS RECORD ( nrdconta      crapass.nrdconta%TYPE,
    nrcpfcgc    crapass.nrcpfcgc%TYPE,
    nrctrato    crapepr.nrctremp%TYPE,
    riscoincl   VARCHAR2(1),
    riscogrpo   VARCHAR2(1),
    rating      VARCHAR2(1),
    riscoatraso VARCHAR2(1),
    riscorefin  VARCHAR2(1),
    riscoagrav  VARCHAR2(1),
    riscomelhor VARCHAR2(1),
    riscooperac VARCHAR2(1),
    riscocpf    VARCHAR2(1),
    riscofinal  VARCHAR2(1),
    qtdiaatraso NUMBER,
    nrgreconomi NUMBER,
    tpregistro  VARCHAR2(100));

  TYPE typ_tab_dados_riscos IS TABLE OF typ_rec_dados_risco INDEX BY PLS_INTEGER;


  --Variaveis para Garantia da aplicação
  vr_permingr NUMBER := 0;
  vr_vlgarnec VARCHAR2(100) := 0;
  vr_inaplpro VARCHAR2(100) := 0;
  vr_vlaplpro VARCHAR2(100) := 0;
  vr_inpoupro VARCHAR2(100) := 0;
  vr_vlpoupro VARCHAR2(100) := 0;
  vr_inresaut VARCHAR2(100) := 0;
  vr_nrctater VARCHAR2(100) := 0;
  vr_inaplter VARCHAR2(100) := 0;
  vr_inpouter VARCHAR2(100) := 0;

  /*Rafael Ferreira 13/06/19 Story 22373
  Variaveis de Retorno da package Zoom0001.pc_consultar_limite_adp
  Não são utilizados aqui, mas precisa receber o retorno do Zoom0001*/
  vr_tipo_adp     NUMBER(20);
  vr_data_adp     VARCHAR2(100);
  vr_contrato_adp NUMBER(20);
  vr_saldo_adp    NUMBER(32, 2);
  vr_cdcritic_adp PLS_INTEGER;
  vr_dscritic_adp VARCHAR2(1000);

  /*Rafael Ferreira 17/06/19 Story 21378
  Variaveis utilizadas para separar o Endividamento Total do Fluxo*/
  vr_saldo_devedor_empr NUMBER(25, 2) := 0;
  vr_vldscchq crapcdb.vlcheque%TYPE := 0;
  vr_vlutiliz_titulo NUMBER(25, 2) := 0;
  wrk_tab_limite_titulos TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite; -- Tabela para armazenar DEsconto de Títulos
  wrk_cdcritica_titulos PLS_INTEGER; -- Critica de Titulos
  wrk_dscerro_titulos   VARCHAR2(4000); -- Descrição Critica de Titulos

  FUNCTION fn_tag(pr_nome in varchar2,
                pr_valor in varchar2)  return varchar2 is
    /*Monta a Tag XML*/
  
vr_retorno varchar2(4000);

begin
  vr_retorno := '<campo>'||
                '<nome>'||pr_nome||'</nome>'||
                '<tipo>string</tipo>'||
                '<valor>'||nvl(trim(pr_valor),'-')||'</valor>'||
                '</campo>';
  return vr_retorno;
end;

FUNCTION fn_tag_table(pr_titulo in varchar2,
                      pr_dados in typ_tab_tabela) return CLOB is
    /*Monta o XML da tabela esperado pela tela
    criado 10 colunas, que pode ser ajustado conforme a necessidade*/
  
    vr_retorno CLOB;
    vr_tabela  typ_tab_tabela;
vr_index   number := 1;
    vr_titulo  gene0002.typ_split;
  
begin
  
    vr_tabela := pr_dados;
  
    vr_retorno := '<linha><colunas>'; -- Inicio
  
    /*Primeira coluna é o título*/
  vr_titulo := GENE0002.fn_quebra_string(pr_string  => pr_titulo,
                                                       pr_delimit => ';');
    IF vr_titulo.count > 0 THEN
      -- Listar todos os agendamentos que foram feitos
      FOR i IN vr_titulo.FIRST .. vr_titulo.LAST LOOP
        vr_retorno := vr_retorno || '<coluna>' || vr_titulo(i) || '</coluna>';
      END LOOP;
    END IF;
    vr_retorno := vr_retorno || '</colunas></linha>';
  
    FOR vr_index IN 1 .. vr_tabela.COUNT LOOP
      vr_retorno := vr_retorno || '<linha><colunas>';
      vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna1 || '</coluna>';
    if vr_tabela(vr_index).coluna2 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna2 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna3 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna3 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna4 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna4 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna5 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna5 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna6 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna6 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna7 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna7 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna8 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna8 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna9 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna9 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna10 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna10 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna11 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna11 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna12 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna12 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna13 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna13 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna14 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna14 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna15 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna15 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna16 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna16 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna17 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna17 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna18 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna18 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna19 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna19 || '</coluna>';
    end if;
    if vr_tabela(vr_index).coluna20 is not null then
        vr_retorno := vr_retorno || '<coluna>' || vr_tabela(vr_index).coluna20 || '</coluna>';
    end if;
      vr_retorno := vr_retorno || '</colunas></linha>';
    END LOOP;

  
    --DBMS_OUTPUT.put_line('vr_retorno: '||vr_retorno);
  
  return vr_retorno;
end;

function fn_zeroToNull(p_valor in number) return varchar2 is
    /*Para colunas onde o default é Zero, e não precisa ser apresentado como Zero*/
  begin
    if to_number(p_valor) = 0 then
      return '';
    else
      return p_valor;
    end if;
  end;

  /*
  Autor: Bruno Luiz Katzjarowski;
  Data: 02/04/2019;
  Descrição: Abrir, ler e retornar valor de uma tag em especifico dentro do retorno do motor
  */
function fn_le_json_motor(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in NUMBER DEFAULT 0
                          ) return varchar2 is 
  
    -- Verificar se PA utilza o CRM
    CURSOR cr_motor(prc_cdcooper IN crapage.cdcooper%TYPE,
                    prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                    prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
         SELECT e.dsconteudo_requisicao
               ,e.dhacionamento
               ,e.nrdconta
        FROM tbgen_webservice_aciona e
       WHERE e.cdcooper = prc_cdcooper
         AND e.nrdconta = prc_nrdconta
         AND e.nrctrprp = prc_nrctrprp
         and e.cdoperad = 'MOTOR'
         AND e.tpacionamento = 2 -- retorno
         and e.dsoperacao NOT LIKE '%ERRO%'
         and e.dsoperacao NOT LIKE '%DESCONHECIDA%'
            ORDER BY e.dhacionamento DESC
         ;
    --and a.inpessoa = 2;
  
    rw_motor cr_motor%ROWTYPE;
  
   vr_json clob;
   vr_retorno clob;
   vr_texto varchar2(4000);
  
    vr_obj                    cecred.json := json(); -- Objeto de leitura JSON
    vr_obj_analise            cecred.json := json(); -- Analise (tag) JSON
    vr_obj_mensagensDeAnalise cecred.json := json();
    vr_objFor                 cecred.json := json();
  
    vr_obj_lst json_list := json_list(); -- Lista para loop
   vr_length number;
  
    vr_split GENE0002.typ_split;
  BEGIN
    vr_retorno := '-';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
    CLOSE cr_motor;
  
    vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8'); --'WE8ISO8859P1');
  
    --vr_retorno := vr_json;
  
    --Atribuir json ao objeto:
    vr_obj := json(vr_json);
  
    --Atrivuir analises index ao objeto
    vr_obj_analise := json(vr_obj.get('analises').to_char());
  
    -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
    vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
    FOR vr_idx IN 1 .. vr_obj_lst.count() LOOP
      --Ler index
      vr_objFor := json(vr_obj_lst.get(vr_idx));
      /*
      Indexes:
         geradoPor
         id
         origem
         origemId
         texto
         tipo
      */
      vr_texto := vr_objFor.get('texto').to_char();
    
         if INSTR(LOWER(vr_texto),LOWER(p_tagFind)) > 0 then
        vr_retorno := vr_texto;
      
            if INSTR(vr_retorno,'"') > 0  then
          vr_retorno := SUBSTR(vr_retorno, 0, LENGTH(vr_retorno) - 1);
          vr_retorno := SUBSTR(vr_retorno, 2, LENGTH(vr_retorno));
            end if;
      
            if p_hasDoisPontos = true then
          IF p_idCampo >= 0 THEN
            vr_split := GENE0002.fn_quebra_string(vr_retorno, ':');
               if vr_split.count > 0 then
              vr_retorno := vr_split(2);
               end if;
          ELSE
            vr_retorno := TRIM(SUBSTR(vr_retorno, INSTR(vr_retorno, ':', -1) + 1));
            end if;
        END IF;
      
         end if;
      --vr_retorno := vr_retorno||' ----- '||vr_texto||' - '||to_char(hasStr);
    END LOOP;
  
    --vr_retorno := vr_json;
  
  return vr_retorno;
  EXCEPTION
    WHEN OTHERS THEN
              return '-';
  END fn_le_json_motor;

  /*Aceita expressão regular para buscar os dados*/
function fn_le_json_motor_regex(p_cdcooper in number,
                                p_nrdconta in number,
                                p_nrdcontrato in number,
                                p_tagFind in varchar2,
                                p_hasDoisPontos in boolean,
                                p_idCampo in NUMBER DEFAULT 0
                                ) return varchar2 is 
  
    CURSOR cr_motor(prc_cdcooper IN crapage.cdcooper%TYPE,
                    prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                    prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
         SELECT e.dsconteudo_requisicao
               ,e.dhacionamento
               ,e.nrdconta
        FROM tbgen_webservice_aciona e
       WHERE e.cdcooper = prc_cdcooper
         AND e.nrdconta = prc_nrdconta
         AND e.nrctrprp = prc_nrctrprp
         and e.cdoperad = 'MOTOR'
         AND e.tpacionamento = 2 -- retorno
         and e.dsoperacao NOT LIKE '%ERRO%'
         and e.dsoperacao NOT LIKE '%DESCONHECIDA%'
       ORDER BY e.dhacionamento DESC;
  
    rw_motor cr_motor%ROWTYPE;
  
   vr_json clob;
   vr_retorno clob;
   vr_texto varchar2(4000);
  
    vr_obj                    cecred.json := json(); -- Objeto de leitura JSON
    vr_obj_analise            cecred.json := json(); -- Analise (tag) JSON
    vr_obj_mensagensDeAnalise cecred.json := json();
    vr_objFor                 cecred.json := json();
  
    vr_obj_lst json_list := json_list(); -- Lista para loop
   vr_length number;
  
    vr_split GENE0002.typ_split;
  BEGIN
    vr_retorno := '-';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
    CLOSE cr_motor;
  
    vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8'); --'WE8ISO8859P1');
  
    --Atribuir json ao objeto:
    vr_obj := json(vr_json);
  
    --Atrivuir analises index ao objeto
    vr_obj_analise := json(vr_obj.get('analises').to_char());
  
    -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
    vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
    FOR vr_idx IN 1 .. vr_obj_lst.count() LOOP
      --Ler index
      vr_objFor := json(vr_obj_lst.get(vr_idx));
    
      vr_texto := vr_objFor.get('texto').to_char();
    
         if REGEXP_INSTR(LOWER(vr_texto),LOWER(p_tagFind)) > 0 then
        vr_retorno := vr_texto;
      
            if INSTR(vr_retorno,'"') > 0  then
          vr_retorno := SUBSTR(vr_retorno, 0, LENGTH(vr_retorno) - 1);
          vr_retorno := SUBSTR(vr_retorno, 2, LENGTH(vr_retorno));
            end if;
      
            if p_hasDoisPontos = true then
          IF p_idCampo >= 0 THEN
            vr_split := GENE0002.fn_quebra_string(vr_retorno, ':');
               if vr_split.count > 0 then
              vr_retorno := vr_split(2);
               end if;
          ELSE
            vr_retorno := TRIM(SUBSTR(vr_retorno, INSTR(vr_retorno, ':', -1) + 1));
            end if;
        END IF;
      
         end if;
      --vr_retorno := vr_retorno||' ----- '||vr_texto||' - '||to_char(hasStr);
    END LOOP;
  
    --vr_retorno := vr_json;
  
  return vr_retorno;
  EXCEPTION
    WHEN OTHERS THEN
              return '-';
  END fn_le_json_motor_regex;

  
function fn_getNivelRisco(p_nivelRisco in number) return varchar2 is
begin
     RETURN (
       CASE
         WHEN p_nivelRisco=2 THEN 'A'
         WHEN p_nivelRisco=3 THEN 'B'
         WHEN p_nivelRisco=4 THEN 'C'
         WHEN p_nivelRisco=5 THEN 'D'
         WHEN p_nivelRisco=6 THEN 'E'
         WHEN p_nivelRisco=7 THEN 'F'
         WHEN p_nivelRisco=8 THEN 'G'
         WHEN p_nivelRisco=9 THEN 'H'
       END);
end;  

  /*Para os casos onde houve aprovação automática mas o limite sugerido foi alterado*/
FUNCTION fn_le_json_motor_auto_aprov(p_cdcooper IN NUMBER
                                    ,p_nrdconta IN NUMBER
                                    ,p_nrdcontrato IN NUMBER
                                    ,p_tagFind IN VARCHAR2
                                    ,p_hasDoisPontos IN BOOLEAN
                                    ,p_idCampo IN NUMBER) RETURN CLOB IS 
  
    -- Verificar se PA utilza o CRM
    CURSOR cr_motor(prc_cdcooper IN crapage.cdcooper%TYPE,
                    prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                    prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
    
      SELECT e.dsconteudo_requisicao
        FROM tbgen_webservice_aciona e
       WHERE e.cdcooper = prc_cdcooper
         AND e.cdoperad = 'MOTOR'
         AND e.dsoperacao NOT LIKE '%ERRO%'
         AND e.dsoperacao NOT LIKE '%DESCONHECIDA%'
         AND e.nrdconta = prc_nrdconta
         AND e.nrctrprp = prc_nrctrprp;
    rw_motor cr_motor%ROWTYPE;
  
   vr_json clob;
   vr_retorno clob;
   vr_texto varchar2(4000);
  
    vr_obj         cecred.json := json(); -- Objeto de leitura JSON
    vr_obj_analise cecred.json := json(); -- Analise (tag) JSON
    vr_objFor      cecred.json := json();
  
    vr_obj_lst json_list := json_list(); -- Lista para loop
  
    vr_split GENE0002.typ_split;
  BEGIN
    vr_retorno := '';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
  
    vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8'); --'WE8ISO8859P1');
  
    --vr_retorno := vr_json;
  
    --Atribuir json ao objeto:
    vr_obj := json(vr_json);
  
    --Atrivuir analises index ao objeto
    vr_obj_analise := json(vr_obj.get('analises').to_char());
  
    -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
    vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
    FOR vr_idx IN 1 .. vr_obj_lst.count() LOOP
      --Ler index
      vr_objFor := json(vr_obj_lst.get(vr_idx));
      /*
      Indexes:
         geradoPor
         id
         origem
         origemId
         texto
         tipo
      */
      vr_texto := vr_objFor.get('texto').to_char();
    
         if INSTR(LOWER(vr_texto),LOWER(p_tagFind)) > 0 then
        vr_retorno := vr_texto;
      
            if INSTR(vr_retorno,'"') > 0  then
          vr_retorno := SUBSTR(vr_retorno, 0, LENGTH(vr_retorno) - 1);
          vr_retorno := SUBSTR(vr_retorno, 2, LENGTH(vr_retorno));
            end if;
      
            if p_hasDoisPontos = true then
          vr_split := GENE0002.fn_quebra_string(vr_retorno, ':');
               if vr_split.count > 0 then
            vr_retorno := vr_split(2);
               end if;
            end if;
      
         end if;
      --vr_retorno := vr_retorno||' ----- '||vr_texto||' - '||to_char(hasStr);
    END LOOP;
  
    --vr_retorno := vr_json;
  
  return vr_retorno;
  EXCEPTION
    WHEN OTHERS THEN
              return 'N/A';
  END fn_le_json_motor_auto_aprov;

  FUNCTION fn_garantia_proposta(pr_cdcooper crapass.cdcooper%TYPE
                               ,pr_nrdconta crapass.nrdconta%TYPE
                               ,pr_nrctremp crawepr.nrctremp%TYPE
                               ,pr_nrdcontaavt1 crawepr.nrctaav1%TYPE
                               ,pr_nrdcontaavt2 crawepr.nrctaav2%TYPE
                               ,pr_chamador in varchar2
                               ,pr_tpproduto in number
							   ,pr_quebralinha  IN BOOLEAN) return varchar is
  
    /* .............................................................................
      Programa: fn_garantia_proposta
      Sistema : Aimaro/Ibratan
      Autor   : Paulo Martins - Mout's 
      Data    : Março/2019                 Ultima atualizacao: 30/05/2019
      
      Alteracoes: 13/06/2019 - Adicionado '##br##' para quebra de linha entre as
                               garantias e adicionado o número da conta na 
                               garantia de aplicação Story 22202. Mateus Z (Mouts)                             
                               
    ..............................................................................*/
  
    cursor c_alienacao is
    select case
           when dscatbem in ('CASA','GALPAO','APARTAMENTO','TERRENO') then 'Imóvel'
           when dscatbem in ('AUTOMOVEL','CAMINHAO','MOTO','OUTROS VEICULOS') then 'Veículos' 
           when dscatbem =  'MAQUINA E EQUIPAMENTO' then 'Maquinas e Equipamentos'
         end garantia
       from crapbpr
   where cdcooper = pr_cdcooper
     and nrdconta = pr_nrdconta
     and nrctrpro = pr_nrctremp
     and flgalien = 1; 
  
  cursor c_avalista_terceiro is
   select 1
     from crapavt anc 
    where anc.cdcooper = pr_cdcooper
      and anc.nrdconta = pr_nrdconta
      and anc.nrctremp = pr_nrctremp
      and anc.tpctrato <> 9; -- Interveniente   
    r_avalista_terceiro c_avalista_terceiro%rowtype;                             
  
    vr_retxml      xmltype;
  vr_retorno_xml varchar2(250);
    --
  vr_garantia    varchar2(250);
  vr_terceiro    varchar2(250);
  vr_alienacao   varchar2(250);
  vr_avalista    varchar2(250);
    vr_separador VARCHAR2(10);
  
  vr_retorno number(1);
  vr_tpcontrato number(1);
  
  BEGIN
  
    IF pr_quebralinha THEN
      vr_separador := '##br##';
    ELSE
      vr_separador := ' - ';
    END IF;
  
   pc_consulta_garantia_operacao(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_tpproduto => pr_tpproduto
                                 ,pr_chamador => pr_chamador
                                 ,pr_retorno  => vr_retorno
                                 ,pr_retxml   => vr_retxml);
  
    vr_permingr := 0;
    vr_vlgarnec := 0;
    vr_inaplpro := 0;
    vr_vlaplpro := 0;
    vr_inpoupro := 0;
    vr_vlpoupro := 0;
    vr_inresaut := 0;
    vr_nrctater := 0;
    vr_inaplter := 0;
    vr_inpouter := 0;
  
      if vr_retorno = 0 then
      vr_garantia := 'Sem Garantia';
      elsif vr_retorno = 2 then --Produto não possui contrato ativo 
         return '-'; 
      elsif vr_retorno = 1 then
    
      /* Extrai dados do XML */
      vr_permingr := vr_retxml.extract('//Dados/permingr/node()').getstringval(); --Garantia Sugerida %
      vr_vlgarnec := vr_retxml.extract('//Dados/vlgarnec/node()').getstringval(); --Garantia Sugerida Valor
      vr_inaplpro := vr_retxml.extract('//Dados/inaplpro/node()').getstringval(); --Flag Aplicação
      vr_inpoupro := vr_retxml.extract('//Dados/inpoupro/node()').getstringval(); --Flag Poupança Programada
      vr_inresaut := vr_retxml.extract('//Dados/inresaut/node()').getstringval(); --Resgate Automatico
      vr_inaplter := vr_retxml.extract('//Dados/inaplter/node()').getstringval();
      vr_inpouter := vr_retxml.extract('//Dados/inpouter/node()').getstringval();
      vr_nrctater := vr_retxml.extract('//Dados/nrctater/node()').getstringval();
      /*Verificação*/
        if vr_inaplpro = 1 then
        vr_garantia := 'Aplicação Própria';
        elsif vr_inpoupro = 1 then
        vr_garantia := 'Poupança Programada';
        elsif vr_inresaut = 1 then
        vr_garantia := 'Resgate Automática';
        elsif vr_inaplter = 1 then
        vr_garantia := 'Aplicação Terceiro: ' || gene0002.fn_mask_conta(vr_nrctater);
        elsif vr_inpouter = 1 then
        vr_garantia := 'Poupança Terceiro: ' || gene0002.fn_mask_conta(vr_nrctater);
        end if;        
      end if;                              
  
    --
      IF pr_nrdcontaavt1 > 0 and pr_nrdcontaavt2 = 0 THEN
      vr_avalista := 'Avalista ' || fn_nao_cooperado(pr_nrdcontaavt1);
      ELSIF pr_nrdcontaavt1 = 0 and pr_nrdcontaavt2 > 0 THEN
      vr_avalista := 'Avalista ' || fn_nao_cooperado(pr_nrdcontaavt2);
      ELSIF pr_nrdcontaavt1 > 0 and pr_nrdcontaavt2 > 0 THEN 
      vr_avalista := 'Primeiro Avalista: ' || fn_nao_cooperado(pr_nrdcontaavt1) || vr_separador ||
                     ' Segundo Avalista: ' || fn_nao_cooperado(pr_nrdcontaavt2);
    END IF;
  
    -- Verifica Avalistas Não cooperados
      IF pr_nrdcontaavt1 = 0 or pr_nrdcontaavt2 = 0 THEN
      --
        open c_avalista_terceiro;--(vr_tpcontrato);
         fetch c_avalista_terceiro into r_avalista_terceiro;
          if c_avalista_terceiro%found then
        vr_terceiro := 'Avalista não cooperado';
          end if;
        close c_avalista_terceiro;
    END IF;
  
    -- Garantia de Aplicação
    IF nvl(vr_garantia, 'NULO') != 'Sem Garantia' THEN
      vr_retorno_xml := vr_garantia;
    END IF;
    -- Alienações
    for r_alienacao in c_alienacao loop
       if vr_alienacao is null then
         vr_alienacao := r_alienacao.garantia;
       else
         vr_alienacao := vr_alienacao||vr_separador||r_alienacao.garantia;
       end if;    
    end loop;
  
    IF vr_alienacao IS NOT NULL THEN
      IF vr_retorno_xml IS NULL THEN
        vr_retorno_xml := vr_alienacao;
      ELSE
        vr_retorno_xml := vr_retorno_xml || vr_separador || vr_alienacao;
      END IF;
    END IF;
    --
      if vr_avalista is not null then
        if vr_retorno_xml is null then
        vr_retorno_xml := vr_avalista;
        else  
        vr_retorno_xml := vr_retorno_xml || vr_separador || vr_avalista;
        end if;
      end if;   
    --
      if vr_terceiro is not null then
        if vr_retorno_xml is null then
        vr_retorno_xml := vr_terceiro;
        else
        vr_retorno_xml := vr_retorno_xml || vr_separador || vr_terceiro;
        end if;  
      end if;        
    --
    IF vr_garantia = 'Sem Garantia' AND vr_terceiro IS NULL AND vr_alienacao IS NULL AND vr_avalista IS NULL THEN
      vr_retorno_xml := vr_garantia;
    END IF;
    --
      return vr_retorno_xml;
        
  
  END;

  FUNCTION fn_param_mensageria(pr_cdcooper in number) RETURN varchar2 IS
  
   vr_retorno varchar2(4000);
  
  BEGIN
  
    vr_retorno := 
    '<?xml version="1.0" encoding="WINDOWS-1252"?>
    <Root>
      <Dados>
      </Dados>
      <params>
        <nmprogra>TELA_UNICA</nmprogra>
        <nmeacao>TELA_UNICA</nmeacao>
        <cdcooper>' || pr_cdcooper || '</cdcooper>
        <cdagenci>0</cdagenci>
        <nrdcaixa>0</nrdcaixa>
        <idorigem>5</idorigem>
        <cdoperad>1</cdoperad>
      </params>
    </Root>';
  
      return vr_retorno;
  
  END;

  FUNCTION fn_nao_cooperado(pr_nrdconta IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
  
    IF pr_nrdconta > 0 THEN
      RETURN TRIM(gene0002.fn_mask_conta(pr_nrdconta));
    ELSE
      RETURN 'Não Cooperado';
    END IF;
  
  END;

  -- Busca a sequencia da consulta do biro para a Tela Única
  /*Utilizada apenas para retornar informações para a categoria SCR (QTD_INST, QTD_FINANC, etc...) */
  PROCEDURE pc_busca_consulta_biro(pr_cdcooper IN crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                   pr_nrdconta IN crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
                                   pr_nrconbir OUT crapcbd.nrconbir%TYPE, --> Numero da consulta que foi realizada
                                 pr_nrseqdet OUT crapcbd.nrseqdet%TYPE) IS --> Sequencial dentro da consulta que foi realizada
    -- Cursor sobre os detalhes das consultas de biros
    CURSOR cr_crapcbd IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapmbr,
             crapcbd,
             crapass,
             crapcbc
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         AND crapcbd.cdcooper = crapass.cdcooper
         AND (crapcbd.nrdconta = crapass.nrdconta
          OR  crapcbd.nrcpfcgc = crapass.nrcpfcgc)
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapcbd.cdbircon <> 4 --Não considerar BOA VISTA (BV apenas para SCORE)
         AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
         AND crapcbd.inreterr = 0 -- Nao houve erros
         AND crapcbc.nrconbir = crapcbd.nrconbir
         AND crapcbc.inprodut <> 7
       ORDER BY crapcbd.dtconbir DESC, crapcbd.qtopescr; -- Buscar a consulta mais recente
  
  BEGIN
    -- Inclusão nome do módulo logado - 12/07/2018 - Chamado 663304
    GENE0001.pc_set_modulo(pr_module => 'SSPC0001', pr_action => 'SSPC0001.pc_busca_consulta_biro');
  
    -- Busca os detalhes das consultas de biros
    OPEN cr_crapcbd;
    FETCH cr_crapcbd INTO pr_nrconbir, pr_nrseqdet;
    CLOSE cr_crapcbd;
  END;

PROCEDURE pc_busca_dados_atenda(pr_cdcooper IN crapass.cdcooper%type,
                                pr_nrdconta IN crapass.nrdconta%type) IS 
  
    /* .............................................................................
    
    Programa:  consultaAnaliseCreditoWeb
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Abril/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar dados carregados na atenda
    
    Alteracoes: -----
    ..............................................................................*/
  BEGIN
  
     cada0004.pc_carrega_dados_atenda(pr_cdcooper => pr_cdcooper
                                    , pr_cdagenci => 0
                                    , pr_nrdcaixa => 100
                                    , pr_cdoperad => '1'
                                    , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    , pr_dtmvtopr => rw_crapdat.dtmvtopr
                                    , pr_dtmvtoan => rw_crapdat.dtmvtoan
                                    , pr_dtiniper => rw_crapdat.dtmvtolt
                                    , pr_dtfimper => rw_crapdat.dtmvtolt
                                    , pr_nmdatela => 'TELA_ANALISE_CREDITO'
                                    , pr_idorigem => 1
                                    , pr_nrdconta => pr_nrdconta
                                    , pr_idseqttl => 1
                                    , pr_nrdctitg => NULL
                                    , pr_inproces => NULL
                                    , pr_flgerlog => 0
                                     -- OUT
                                    , pr_flconven => vr_flconven
                                    , pr_tab_cabec => vr_tab_cabec
                                    , pr_tab_comp_cabec => vr_tab_comp_cabec
                                    , pr_tab_valores_conta => vr_tab_valores_conta
                                    , pr_tab_crapobs => vr_tab_crapobs
                                    , pr_tab_mensagens_atenda => vr_tab_mensagens_atenda
                                    , pr_dscritic => vr_dscritic
                                    , pr_des_reto => vr_des_reto
                                    , pr_tab_erro => vr_tab_erro);
  
  END;

  PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta   IN crawepr.nrdconta%TYPE --> Conta
                                        ,pr_tpproduto IN number                      --> Produto
                                        ,pr_nrcontrato IN crawepr.nrctremp%TYPE      --> Número contrato emprestimo
                                        ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                        ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS       --> Erros do processo
  BEGIN
  
    /* .............................................................................
    
    Programa:  consultaAnaliseCreditoWeb
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Março/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar XML com dados para analise de credito
    
    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
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
    
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'consultaAnaliseCreditoWeb'
                                ,pr_action => vr_nmeacao);
    
      -- Busca a data do sistema
      OPEN BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
    
      pc_consulta_analise_credito(pr_cdcooper => vr_cdcooper
                                , pr_nrdconta => pr_nrdconta
                                , pr_tpproduto => pr_tpproduto
                                , pr_nrctrato => pr_nrcontrato
                                , pr_cdcritic => vr_cdcritic
                                , pr_dscritic => vr_dscritic
                                , pr_dsxmlret => pr_retxml);     --> Descrição da crítica*/
    
      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;


    
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
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela consultaAnaliseCreditoWeb: ' || SQLERRM;
      
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  
  END pc_consulta_analise_creditoweb;

PROCEDURE pc_gera_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number) IS                  --> Número Contrato

  /* .............................................................................

    Programa: pc_gera_dados_analise_credito
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Março/2019                 Ultima atualizacao: 02/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar as informações para consulta em analise de credito

    Alteracoes:
  ..............................................................................*/


    CURSOR c_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type)  IS
     SELECT c.idpessoa_relacao
       FROM tbcadast_pessoa_relacao c
      WHERE c.idpessoa = pr_idpessoa
        and c.tprelacao = 1; -- 1 = Cônjuge
    r_conjuge c_conjuge%rowtype;

    CURSOR c_avalistas_epr is
    SELECT e.nrctaav1,
           e.nmdaval1,
           e.nrctaav2,
           e.nmdaval2
      FROM crawepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctrato;
       r_avalistas_epr c_avalistas_epr%rowtype;
       
  cursor c_avalista_naocoop(pr_nmdavali in varchar2) is
   select anc.nrcpfcgc
     from crapavt anc 
    where anc.cdcooper = pr_cdcooper
      and anc.nrdconta = pr_nrdconta
      and anc.nrctremp = pr_nrctrato
      and anc.nmdavali = pr_nmdavali
      and anc.tpctrato <> 9; -- Interveniente   
    r_avalista_naocoop c_avalista_naocoop%rowtype;      

    CURSOR c_avalistas_limit_dec_tit is       
    SELECT w.nrctaav1,
           w.nmdaval1,
           w.nrctaav2,
           w.nmdaval2
     FROM  crawlim w
     WHERE w.cdcooper = pr_cdcooper
     AND   w.nrdconta = pr_nrdconta
     AND   w.nrctrlim = pr_nrctrato;       
    --
    r_avalistas_limit_dec_tit c_avalistas_limit_dec_tit%rowtype; 
     

  cursor c_dados_aval_nao_coop(pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                               pr_tpctrato in crapavt.tpctrato%type)  is
  select decode(anc.inpessoa,1,'Física',2,'Jurídica','-') inpessoa,
         anc.nrcpfcgc,
         anc.nmdavali,
         n.dsnacion dsnatura,
         anc.dtnascto,
         anc.vlrenmes,
         anc.nrcepend,
         anc.dsendres##1,
         anc.complend,
         anc.nrendere,
         anc.nmcidade,
         anc.dsendres##2, -- Bairro
         anc.cdufresd,
         anc.tpctrato
    from crapavt anc,
         crapnac n
   where anc.cdcooper = pr_cdcooper
     and anc.nrdconta = pr_nrdconta
     and anc.nrctremp = pr_nrctrato

     and anc.nrcpfcgc = pr_nrcpfcgc
     and anc.cdnacion = n.cdnacion(+)
     and anc.tpctrato = pr_tpctrato; -- Avalista não cooperado  
  --
  r_dados_aval_nao_coop c_dados_aval_nao_coop%rowtype;    

  /*Busca o ID do Grupo Economico*/
  CURSOR c_grupo_economico(pr_cdcooper in tbcc_grupo_economico.cdcooper%type,
                           pr_nrdconta in tbcc_grupo_economico.nrdconta%type) is
 SELECT DISTINCT g.idgrupo
   FROM tbcc_grupo_economico g,
        tbcc_grupo_economico_integ i
  WHERE ( g.cdcooper = pr_cdcooper or i.cdcooper = pr_cdcooper)
    AND ( g.nrdconta = pr_nrdconta or i.nrdconta = pr_nrdconta )
    AND g.cdcooper = i.cdcooper
    AND g.idgrupo  = i.idgrupo
    AND i.dtexclusao is null;  
  r_grupo_economico c_grupo_economico%rowtype;
    
/*  select g.cdcooper,
         g.nrdconta
    from tbcc_grupo_economico_integ g
   where g.dtexclusao is null
     and g.idgrupo in (select gei.idgrupo
                         from tbcc_grupo_economico gei --alterado GE rubens--19-05-2019
                        where gei.nrdconta = pr_nrdconta
                          and gei.cdcooper = pr_cdcooper);*/
                          
  /*Busca os Integrantes do grupo*/
  CURSOR c_grupo_economico_integ (pr_cdcooper crapcop.cdcooper%TYPE
                                 ,pr_idgrupo number) IS
    SELECT nrdconta
          ,idgrupo
    FROM tbcc_grupo_economico_integ
    WHERE cdcooper = pr_cdcooper
    AND   idgrupo =  pr_idgrupo
    UNION ALL
    SELECT nrdconta
          ,idgrupo
    FROM tbcc_grupo_economico
    WHERE cdcooper = pr_cdcooper
    AND   idgrupo =  pr_idgrupo;  
  r_grupo_economico_integ c_grupo_economico_integ%ROWTYPE;

  /*Versão*/
  CURSOR c_versao_analise IS
  select nvl(max(nrversao_analise),0)+1
    from tbgen_analise_credito
   where cdcooper = pr_cdcooper
     and nrdconta = pr_nrdconta
     and tpproduto = pr_tpproduto
     and nrcontrato = pr_nrctrato
   group by cdcooper,nrdconta,tpproduto,nrcontrato;  

  vr_nrversao_analise number;

  vr_dscritic varchar2(250);

  vr_dsxmlret CLOB;

  vr_string_completa CLOB;
  vr_string          CLOB;

  vr_filtro varchar2(10);
  vr_filtro_qs varchar2(10);
  vr_nrfiltro number;
  vr_nrfiltro_qs number;
  vr_qtd_pf   number;
  vr_contasPJ varchar2(32000);
  vr_montaPersona boolean := true;

  ERRO_PRINCIPAL EXCEPTION;

procedure pc_gera_dados_persona(pr_persona in varchar2,
                                  pr_persona_filtro in varchar2,
                                  pr_cdcooper in number,
                                  pr_nrdconta in number,
                                  pr_idpessoa in number,
                                  pr_nrcpfcgc in number,
                                  pr_inpessoa in number,
                                  pr_xmlOut out CLOB) is

  vr_string_persona CLOB;
  vr_xml_aux CLOB;

  procedure pc_outras_contas(xmlOut out CLOB) is

   vr_string_contas CLOB;
   vr_index number;
   vr_outras_contas boolean := False;
  begin
   vr_string_contas := vr_string||'<subcategoria>'||
                                  '<tituloTela>Outras Contas</tituloTela>'||
                                  '<campos>';

   /*Apresentado em tabela*/
   vr_string_contas := vr_string_contas||'<campo>
                                         <nome>Contas</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
   vr_index := 1;
   vr_tab_tabela.delete;
   for r_contas in c_contas(pr_cdcooper,r_pessoa.nrcpfcgc) loop
    if r_contas.nrdconta != vr_nrdconta_principal then
    vr_tab_tabela(vr_index).coluna1 := r_contas.nmrescop;
    vr_tab_tabela(vr_index).coluna2 := r_contas.nrdconta;
    vr_tab_tabela(vr_index).coluna3 := r_contas.cdagenci;
    vr_tab_tabela(vr_index).coluna4 := r_contas.dtadmiss;
    vr_index := vr_index+1;
    end if;
   end loop;

    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_outras_contas := True;
      vr_string_contas := vr_string_contas||fn_tag_table('Cooperativa;Número da Conta;PA;Abertura',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_string_contas := vr_string_contas||fn_tag_table('Cooperativa;Número da Conta;PA;Abertura',vr_tab_tabela);
    end if;

     vr_string_contas := vr_string_contas||'</linhas>
                                            </valor>
                                            </campo>';

    if vr_outras_contas = true then
     vr_string_contas := vr_string_contas||'<campo>'||
                                            '<nome>Operações de outras contas</nome>'||
                                            '<tipo>info</tipo>'||
                                            '<valor>Proponente possui outras contas, suas operações estão listadas em Operações.</valor>'||
                                            '</campo>';  
    end if;                                                                                      

     vr_string_contas := vr_string_contas||'</campos></subcategoria>';

     xmlOut := vr_string_contas;

  end;


  begin

  vr_string_persona := '<persona>
                         <tituloTela>'||pr_persona||'</tituloTela>
                         <tituloFiltro>'||pr_persona_filtro||'</tituloFiltro>
                         <categorias>';

      vr_string_persona := vr_string_persona||
                     '<categoria>
                      <tituloTela>Cadastro</tituloTela>
                      <tituloFiltro>cadastro</tituloFiltro>
                      <subcategorias>';

      /*Persona é cooperada*/
      IF (pr_inpessoa = 1 AND pr_nrdconta <> 0) THEN
        /* Consulta Cadastro PF*/
        pc_consulta_cadastro_pf(pr_cdcooper => pr_cdcooper ,
                                pr_nrdconta => pr_nrdconta,
                                pr_idpessoa => pr_idpessoa,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_dsxmlret => vr_xml);

	    /* Consulta Cadastro Conjuge não cooperado*/
      ELSIF (pr_inpessoa = 1 AND pr_nrdconta = 0) THEN
        pc_consulta_cad_conjuge_ncoop(pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic,
                                      pr_dsxmlret => vr_xml);
      else
        /* Consulta Cadastro PJ*/
        pc_consulta_cadastro_pj(pr_cdcooper => pr_cdcooper ,
                                pr_nrdconta => pr_nrdconta,
                                pr_cdcritic => vr_cdcritic,
                                pr_dscritic => vr_dscritic,
                                pr_dsxmlret => vr_xml);
      end if;

      vr_string_persona := vr_string_persona||vr_xml;

      if pr_persona_filtro = 'proponente' then
        /*OUTRAS CONTAS*/
        vr_xml_aux := null;
        pc_outras_contas(vr_xml_aux);
        vr_string_persona := vr_string_persona||vr_xml_aux;
      end if;
      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';

      /* 2 - Consulta a Proposta do proponente */
      if (pr_persona = 'Proponente') then
        vr_string_persona := vr_string_persona ||'<categoria>'||
                                                 '<tituloTela>Proposta</tituloTela>'||
                                                 '<tituloFiltro>proposta</tituloFiltro>'||
                                                 '<subcategorias>';
        /*PROPOSTA LIMITE DESCONTO TITULO*/
        if (pr_tpproduto = c_limite_desc_titulo) then
          pc_consulta_proposta_limite(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctrato => pr_nrctrato
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsxmlret => vr_xml);

        /*PROPOSTA EMPRESTIMO*/
        elsif (pr_tpproduto = c_emprestimo) then

          pc_consulta_proposta_epr(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrctrato => vr_nrctrato_principal
                                  ,pr_inpessoa => pr_inpessoa
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic                                  
                                  ,pr_dsxmlret => vr_xml);

        /*PROPOSTA CARTAO DE CRÉDITO*/
        elsif (pr_tpproduto = c_cartao) then
          pc_consulta_proposta_cc(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctrato => pr_nrctrato
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic                                 
                                 ,pr_dsxmlret => vr_xml);

        /*PROPOSTA BORDERO DE DESCONTO DE TITULOS */
        elsif (pr_tpproduto = c_desconto_titulo) then
          pc_consulta_proposta_bordero(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrctrato => pr_nrctrato
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsxmlret => vr_xml);
        end if;

        vr_string_persona := vr_string_persona||vr_xml;
        vr_string_persona := vr_string_persona||'</subcategorias></categoria>';
        /* Fim da Proposta*/
      end if;

      /*Não executar para conjuge não cooperado*/
      IF (pr_nrdconta <> 0) THEN
      /*Operações para todas as personas*/
      
      vr_string_persona := vr_string_persona||'<categoria>'||
                                              '<tituloTela>Operações</tituloTela>'||
                                              '<tituloFiltro>operacoes</tituloFiltro>'||
                                              '<subcategorias>';
      
      vr_xml_aux := null;
      /*Operações proponente*/
      pc_consulta_operacoes(pr_cdcooper  => pr_cdcooper
                          , pr_nrdconta  => pr_nrdconta
                          , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                          , pr_nrctrato  => vr_nrctrato_principal
                          , pr_cdcritic  => vr_cdcritic
                          , pr_dscritic  => vr_dscritic
                          , pr_dsxmlret  => vr_xml_aux);

      vr_string_persona := vr_string_persona||vr_xml_aux;
      --vr_string_persona := vr_string_persona||'</subcategorias></categoria>';

      if substr(pr_persona,1,2) not in ('QS','GE') or substr(pr_persona,1,8) not in ('Conta PJ') then
      /*Operações Outras Contas*/
      for r_contas in c_contas(pr_cdcooper,pr_nrcpfcgc) loop
        if pr_nrdconta != r_contas.nrdconta then
        /*
        separação por contas
        */
/*        vr_string_persona := vr_string_persona||'<subcategoria>
                                                  <separador>
                                                      <tituloTela>Operações da conta '||r_contas.nrdconta||'</tituloTela>
                                                  </separador>
                                                 </subcategoria>';
                                                 */
        vr_string_persona := concat(vr_string_persona,'<subcategoria>
                                                        <separador>
                                                            <tituloTela>Operações da conta '||r_contas.nrdconta||'</tituloTela>
                                                        </separador>
                                                       </subcategoria>');                                         
                                                 
        vr_xml_aux := null;      
        pc_consulta_operacoes(pr_cdcooper  => pr_cdcooper
                            , pr_nrdconta  => r_contas.nrdconta
                            , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                            , pr_nrctrato  => vr_nrctrato_principal
                            , pr_cdcritic  => vr_cdcritic
                            , pr_dscritic  => vr_dscritic
                            , pr_dsxmlret  => vr_xml_aux);
        vr_string_persona := vr_string_persona||vr_xml_aux; 
        end if;                           
      end loop;
      end if;
      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';


      /* 4 - Garantia */
      if (pr_persona = 'Proponente') then
        pc_consulta_garantia(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrctrato => pr_nrctrato
                            ,pr_tpproduto => pr_tpproduto --bug 20391
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsxmlret => vr_xml);

        vr_string_persona := vr_string_persona||vr_xml;
        vr_string_persona := vr_string_persona||'</subcategorias></categoria>';
        /* Fim Garantia */
      end if;

      -- CATEGORIA SCR
      -- SUBCATEGORIA Resumo das Informações do Titular

      pc_consulta_scr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctrato => vr_nrctrato_principal,
                      pr_persona  => pr_persona,
                      pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                      pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic,
                      pr_dsxmlret => vr_xml);

      vr_string_persona := vr_string_persona||vr_xml;

      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';
      
      /*
      TODO: owner="bruno luiz katzjarowski"
      text="Fazer categoria de Consulta do proponente"
      */
      vr_string_persona := vr_string_persona||
               '<categoria>
                <tituloTela>Consulta</tituloTela>
                <tituloFiltro>consulta</tituloFiltro>
                <subcategorias>';

      pc_consulta_consultas(pr_cdcooper => pr_cdcooper, 
                            pr_nrdconta => pr_nrdconta,
                            pr_nrcontrato => vr_nrctrato_principal,
                            pr_inpessoa => pr_inpessoa,
                            pr_nrcpfcgc => pr_nrcpfcgc,
                            pr_persona  => pr_persona,
                            pr_cdcritic => vr_cdcritic, 
                            pr_dscritic => vr_dscritic , 
                            pr_dsxmlret => vr_xml_aux);
                            
      vr_string_persona := vr_string_persona||vr_xml_aux;
      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';                       
      
      /*Conjuge não cooperado*/
      ELSIF pr_nrdconta = 0 THEN
        /*Operações*/
        vr_string_persona := vr_string_persona ||
           '<categoria>
              <tituloTela>Operações</tituloTela>
              <tituloFiltro>operacoes</tituloFiltro>
              <subcategorias>
                  <subcategoria>
                      <tituloTela>Operações</tituloTela>
                      <tituloFiltro>operacoes</tituloFiltro>
                      <campos>
                          <campo>
                              <nome>Cônjuge Não Cooperado</nome>
                              <tipo>string</tipo>
                              <valor>Não possui dados para apresentação</valor>
                          </campo>
                      </campos>
                  </subcategoria>
                </subcategorias>
              </categoria>';
        /*SCR*/
        pc_consulta_scr_conj_ncoop(pr_cdcooper => pr_cdcooper,
                                   pr_nrcpfcgc => pr_nrcpfcgc, -->CPF do cônjuge
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic,
                                   pr_dsxmlret => vr_xml);
      vr_string_persona := vr_string_persona||vr_xml;
      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';
      /*Consultas*/
        vr_string_persona := vr_string_persona ||
           '<categoria>
              <tituloTela>Consulta</tituloTela>
              <tituloFiltro>consulta</tituloFiltro>
                            <subcategorias>';
       vr_xml := null;      
       pc_consulta_consultas_ncoop(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrcontrato => vr_nrctrato_principal,
                                   pr_inpessoa => 1,
                                   pr_nrcpfcgc => pr_nrcpfcgc,
                                   pr_persona  => pr_persona,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic ,
                                   pr_dsxmlret => vr_xml);
      
       vr_string_persona := vr_string_persona||vr_xml;

       vr_string_persona := vr_string_persona||vr_xml_aux;
       vr_string_persona := vr_string_persona||'</subcategorias></categoria>';       
      END IF;
      vr_string_persona := vr_string_persona||'</categorias></persona>';

      pr_xmlOut := vr_string_persona;
  end;  

  procedure pc_gera_dados_aval_nao_coop(pr_persona in varchar2,
                                        pr_persona_filtro in varchar2,
                                        pr_cdcooper in number,
                                        pr_nrdconta in number,
                                        pr_nrcpfcgc in number,
                                        pr_xmlOut out CLOB) is

  vr_string_cjg CLOB;
  vr_xml_aux CLOB;

  begin

      vr_string_cjg := '<persona>
                       <tituloTela>'||pr_persona||'</tituloTela>
                       <tituloFiltro>'||pr_persona_filtro||'</tituloFiltro>
                       <categorias>
                       <categoria>
                       <tituloTela>Cadastro</tituloTela>
                       <tituloFiltro>cadastro</tituloFiltro>
                       <subcategorias>
                        <subcategoria>
                          <tituloTela>Operações</tituloTela>
                            <tituloFiltro>operacoes</tituloFiltro>
                             <campos>';

      
      --Cadastro
      Open c_dados_aval_nao_coop(pr_nrcpfcgc, 
           CASE WHEN vr_tpproduto_principal = c_emprestimo THEN 1 ELSE 8 END); --1 = Emprestimo, --8 Desconto Título
       fetch c_dados_aval_nao_coop into r_dados_aval_nao_coop;
        if c_dados_aval_nao_coop%found then
          
           
        
           vr_string_cjg := vr_string_cjg||
                             fn_tag('Tipo de Pessoa',r_dados_aval_nao_coop.inpessoa)||
                             fn_tag('CPF',CASE WHEN r_dados_aval_nao_coop.nrcpfcgc IS NOT NULL THEN
                                gene0002.fn_mask_cpf_cnpj(r_dados_aval_nao_coop.nrcpfcgc,
                                CASE WHEN LENGTH(r_dados_aval_nao_coop.nrcpfcgc) > 11 THEN 2 ELSE 1 END) ELSE '-' END
                             )||
                             fn_tag('Nome',r_dados_aval_nao_coop.nmdavali)||
                             fn_tag('Nacionalidade',r_dados_aval_nao_coop.dsnatura)||
                             fn_tag('Data de Nascimento',TO_CHAR(r_dados_aval_nao_coop.dtnascto,'DD/MM/YYYY'))||
                             fn_tag('Renda',to_char(r_dados_aval_nao_coop.vlrenmes,'999g999g990d00'))||
                             fn_tag('CEP',gene0002.fn_mask_cep(r_dados_aval_nao_coop.nrcepend))||
                             fn_tag('Rua',r_dados_aval_nao_coop.dsendres##1)||
                             fn_tag('Complemento',r_dados_aval_nao_coop.complend)||
                             fn_tag('Número',r_dados_aval_nao_coop.nrendere)||
                             fn_tag('Cidade',r_dados_aval_nao_coop.nmcidade)||
                             fn_tag('Bairro',r_dados_aval_nao_coop.dsendres##2)|| -- Bairro
                             fn_tag('Estado',r_dados_aval_nao_coop.cdufresd);
        end if;
      close c_dados_aval_nao_coop;
      
      vr_string_cjg := vr_string_cjg||'</campos>
                                        </subcategoria> 
                                          </subcategorias>
                                            </categoria>';
       

      --Operações                 
      vr_string_cjg := vr_string_cjg||'<categoria>
                                        <tituloTela>Operações</tituloTela>
                                        <tituloFiltro>operacoes</tituloFiltro>
                                        <subcategorias>
                                            <subcategoria>
                                                <tituloTela>Operações</tituloTela>
                                                <tituloFiltro>operacoes</tituloFiltro>
                                                <campos>
                                                    <campo>
                                                        <nome>Avalista Não Cooperado</nome>
                                                        <tipo>string</tipo>
                                                        <valor>Não possui dados para apresentação</valor>
                                                    </campo>
                                                </campos>
                                            </subcategoria> 
                                          </subcategorias>
                                        </categoria>';


      -- CATEGORIA SCR
      pc_consulta_scr_ncoop(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctrato => vr_nrctrato_principal,
                            pr_persona  => pr_persona,
                            pr_nrcpfcgc => pr_nrcpfcgc,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_dsxmlret => vr_xml_aux);

      vr_string_cjg := vr_string_cjg||vr_xml_aux;

      vr_string_cjg := vr_string_cjg||'</subcategorias></categoria>';
      

      vr_string_cjg := vr_string_cjg||
               '<categoria>
                <tituloTela>Consulta</tituloTela>
                <tituloFiltro>consulta</tituloFiltro>
                <subcategorias>';
      vr_xml_aux := null;
      pc_consulta_consultas_ncoop(pr_cdcooper => pr_cdcooper, 
                                  pr_nrdconta => pr_nrdconta,
                                  pr_nrcontrato => vr_nrctrato_principal,
                                  pr_inpessoa => 1,
                                  pr_nrcpfcgc => pr_nrcpfcgc,
                                  pr_persona  => pr_persona,
                                  pr_cdcritic => vr_cdcritic, 
                                  pr_dscritic => vr_dscritic , 
                                  pr_dsxmlret => vr_xml_aux);
                            
      vr_string_cjg := vr_string_cjg||vr_xml_aux;
      vr_string_cjg := vr_string_cjg||'</subcategorias></categoria>';                       
      
      vr_string_cjg := vr_string_cjg||'</categorias></persona>';

      pr_xmlOut := vr_string_cjg;
      
  end pc_gera_dados_aval_nao_coop;

  begin

    /*Carrega chaves principais*/
    vr_nrdconta_principal   := pr_nrdconta;
    vr_cdcooper_principal   := pr_cdcooper;
    vr_tpproduto_principal  := pr_tpproduto;
    vr_nrctrato_principal   := pr_nrctrato;
    vr_parametros_principal := 'pr_cdcooper:'||pr_cdcooper
                             ||', pr_nrdconta:'||pr_nrdconta
                             ||', pr_nrctrato:'||pr_nrctrato
                             ||', pr_tpproduto:'||pr_tpproduto;


    --Carregar data do sistema
    OPEN  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := 'Problemas ao recuperar a data do sistema. Favor, entre em contato com seu PA!';
      RAISE ERRO_PRINCIPAL;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);


    /*Inicia o Arquivo XML*/
    vr_string_completa :=
    '<?xml version="1.0" encoding="ISO-8859-1"?><Root>
     <Dados>
      <data>'||to_char(sysdate,'DD/MM/RRRR HH24:MI:SS')||'</data>
      <personas>';

    /*PROPONENTE*/

    -- Consultar informações proponente
    if c_pessoa%isopen then
       close c_pessoa;
    end if;
    open c_pessoa(pr_cdcooper,pr_nrdconta);
     fetch c_pessoa into r_pessoa;
      if c_pessoa%notfound then
        close c_pessoa;
        vr_dscritic := 'Não encontrado os dados do proponente :'||pr_nrdconta;
        RAISE ERRO_PRINCIPAL;
      else

        vr_nrcpfcgc_principal := r_pessoa.nrcpfcgc;

        pc_gera_dados_persona(pr_persona => 'Proponente',
                              pr_persona_filtro => 'proponente',
                              pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta,
                              pr_idpessoa => r_pessoa.idpessoa,
                              pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                              pr_inpessoa => r_pessoa.inpessoa,
                              pr_xmlOut => vr_xml);

       pc_escreve_xml(pr_xml            => vr_dsxmlret,
                      pr_texto_completo => vr_string_completa,
                      pr_texto_novo     => vr_xml,
                      pr_fecha_xml      => TRUE);
      end if;
    close c_pessoa;
      
      /*CONTAS JURIDICAS*/
      --Sprint 15 - US 23910
      if r_pessoa.inpessoa = 1 then -- Se for pessoa Física
        open c_outras_contas_qtd(pr_cdcooper,pr_nrdconta);
         fetch c_outras_contas_qtd into vr_qtd_pf;
        close c_outras_contas_qtd;

        if vr_qtd_pf > 1 then
          vr_filtro := '_1';
        else
          vr_filtro := null;
        end if;
        
        vr_qtd_pf := 1;
        vr_nrfiltro_qs := 0;
        vr_contasPJ := null;
        for r_contas_pj in c_outras_contas_pj(pr_cdcooper,pr_nrdconta) loop
           --Carregar dados das contas PJ
           pc_gera_dados_persona(pr_persona => 'Conta PJ '||gene0002.fn_mask_conta(r_contas_pj.nrdconta),
                                 pr_persona_filtro => 'contapj'||vr_filtro,
                                 pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => r_contas_pj.nrdconta,
                                 pr_idpessoa => r_contas_pj.idpessoa,
                                 pr_nrcpfcgc => r_contas_pj.nrcpfcgc,
                                 pr_inpessoa => r_contas_pj.inpessoa,
                                 pr_xmlOut => vr_xml);

           pc_escreve_xml(pr_xml            => vr_dsxmlret,
                          pr_texto_completo => vr_string_completa,
                          pr_texto_novo     => vr_xml,
                          pr_fecha_xml      => TRUE);
           
           vr_qtd_pf := vr_qtd_pf+1;            
           vr_filtro := '_'||to_char(vr_qtd_pf);           
           
               
           /*QUADRO SOCIETARIO*/
           for r_socios in c_repproc(pr_cdcooper,r_contas_pj.nrdconta) loop
             open c_pessoa(r_socios.cdcooper, r_socios.nrdctato);
              fetch c_pessoa into r_pessoa;
               if c_pessoa%found and r_socios.nrdctato != pr_nrdconta then

                  vr_nrfiltro_qs := vr_nrfiltro_qs+1;
                  vr_filtro_qs := '_'||to_char(vr_nrfiltro_qs);
                  --Verificar contas que já estão no qs
                  if vr_contasPJ is not null then
                    if instr(vr_contasPJ,'#'||r_pessoa.nrdconta||'#') > 0 then
                      vr_montaPersona := false;
                    end if;
                
                  end if;
                  
                  if vr_montaPersona then
                    pc_gera_dados_persona(pr_persona => 'QS '||r_pessoa.nrdconta,
                                          pr_persona_filtro => 'quadro'||vr_filtro_qs,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => r_pessoa.nrdconta,
                                          pr_idpessoa => r_pessoa.idpessoa,
                                          pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                          pr_inpessoa => r_pessoa.inpessoa,
                                          pr_xmlOut => vr_xml);

                                          pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                          pr_texto_completo => vr_string_completa,
                                          pr_texto_novo     => vr_xml,
                                          pr_fecha_xml      => TRUE);
                  end if;                        
                  vr_montaPersona := true;
                  vr_contasPJ := vr_contasPJ||'#'||r_pessoa.nrdconta||'#';

               end if;
             close c_pessoa;
           end loop;
           /*FIM-QUADRO SOCIETARIO*/           
        end loop;
      end if;
        
      /*FIM - CONTAS JURIDICAS*/      

      /*CONJUGE*/

      --Buscar conjuge
      open c_conjuge(r_pessoa.idpessoa);
       fetch c_conjuge into r_conjuge;
        if c_conjuge%found then
          open c_pessoa_por_id(r_conjuge.idpessoa_relacao, pr_cdcooper);
           fetch c_pessoa_por_id into r_pessoa_por_id;
            if c_pessoa_por_id%found then

              pc_gera_dados_persona(pr_persona => 'Cônjuge',
                                    pr_persona_filtro => 'conjuge',
                                    pr_cdcooper => r_pessoa_por_id.cdcooper,
                                    pr_nrdconta => r_pessoa_por_id.nrdconta,
                                    pr_idpessoa => r_conjuge.idpessoa_relacao,
                                    pr_nrcpfcgc => r_pessoa_por_id.nrcpfcgc,
                                    pr_inpessoa => r_pessoa_por_id.inpessoa,
                                    pr_xmlOut => vr_xml);

                     pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                    pr_texto_completo => vr_string_completa,
                                    pr_texto_novo     => vr_xml,
                                    pr_fecha_xml      => TRUE);

            else
              /*PRJ 438 - Sprint 15 - Story 23669 - Cônjuge não cooperado*/
              OPEN c_conjuge_nao_coop (pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta);
               FETCH c_conjuge_nao_coop into r_conjuge_nao_coop;
               IF c_conjuge_nao_coop%FOUND THEN
                 pc_gera_dados_persona(pr_persona => 'Cônjuge',
                                       pr_persona_filtro => 'conjuge',
                                       pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => 0, --não possui conta
                                       pr_idpessoa => r_conjuge.idpessoa_relacao,
                                       pr_nrcpfcgc => r_conjuge_nao_coop.nrcpfcjg,
                                       pr_inpessoa => 1, --pessoa física
                                       pr_xmlOut => vr_xml);
                 pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                pr_texto_completo => vr_string_completa,
                                pr_texto_novo     => vr_xml,
                                pr_fecha_xml      => TRUE);
            end if;
              CLOSE c_conjuge_nao_coop;
            end if;
          close c_pessoa_por_id;
       end if;
      close c_conjuge;
      /*FIM-CONJUGE*/

      /*INFORMAÇÃO AVALISTA*/
      if pr_tpproduto = c_emprestimo then
        open c_avalistas_epr;
         fetch c_avalistas_epr into r_avalistas_epr;
          if c_avalistas_epr%found then
             /*Avalista 1*/
             if r_avalistas_epr.nrctaav1 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_epr.nrctaav1);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if (r_avalistas_epr.nrctaav1 > 0 or  trim(r_avalistas_epr.nmdaval1) is not null) and (r_avalistas_epr.nrctaav2 > 0 or trim(r_avalistas_epr.nmdaval2) is not null) then
                      vr_filtro := '_1';
                    else
                      vr_filtro := null;
                    end if;

                    pc_gera_dados_persona(pr_persona => 'Avalista '||r_avalistas_epr.nrctaav1,
                                          pr_persona_filtro => 'avalista'||vr_filtro,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => r_pessoa.nrdconta,
                                          pr_idpessoa => r_pessoa.idpessoa,
                                          pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                          pr_inpessoa => r_pessoa.inpessoa,
                                          pr_xmlOut => vr_xml);

                           pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                          pr_texto_completo => vr_string_completa,
                                          pr_texto_novo     => vr_xml,
                                          pr_fecha_xml      => TRUE);

                  end if;
                  close c_pessoa;
             elsif r_avalistas_epr.nrctaav1 = 0 then
              -- Avalista Não Cooperado
              open c_avalista_naocoop(r_avalistas_epr.nmdaval1);
               fetch c_avalista_naocoop into r_avalista_naocoop;
                if c_avalista_naocoop%found then

                    if ((r_avalistas_epr.nrctaav1 = 0 and trim(r_avalistas_epr.nmdaval1) is not null) or r_avalistas_epr.nrctaav1 > 0)
                   and ((r_avalistas_epr.nrctaav2 = 0 and trim(r_avalistas_epr.nmdaval2) is not null) or r_avalistas_epr.nrctaav2 > 0)then
                      vr_filtro := '_1';
                    else
                      vr_filtro := null;
                    end if;

                      pc_gera_dados_aval_nao_coop(pr_persona => 'Avalista 1 Não Coop.',
                                                  pr_persona_filtro => 'avalista'||vr_filtro,
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_nrcpfcgc => r_avalista_naocoop.nrcpfcgc,
                                                  pr_xmlOut => vr_xml);

                                   pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                  pr_texto_completo => vr_string_completa,
                                                  pr_texto_novo     => vr_xml,
                                                  pr_fecha_xml      => TRUE);


               end if;
              close c_avalista_naocoop;
                  
             end if;
             /*Avalista 2*/
             if r_avalistas_epr.nrctaav2 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_epr.nrctaav2);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if (r_avalistas_epr.nrctaav1 > 0 or  trim(r_avalistas_epr.nmdaval1) is not null) and (r_avalistas_epr.nrctaav2 > 0 or trim(r_avalistas_epr.nmdaval2) is not null) then
                      vr_filtro := '_2';
                    else
                      vr_filtro := null;
                    end if;
                    pc_gera_dados_persona(pr_persona => 'Avalista '||r_avalistas_epr.nrctaav2,
                                          pr_persona_filtro => 'avalista'||vr_filtro,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => r_pessoa.nrdconta,
                                          pr_idpessoa => r_pessoa.idpessoa,
                                          pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                          pr_inpessoa => r_pessoa.inpessoa,
                                          pr_xmlOut => vr_xml);
                                          /*pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic, */

                           pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                          pr_texto_completo => vr_string_completa,
                                          pr_texto_novo     => vr_xml,
                                          pr_fecha_xml      => TRUE);

                  end if;
                  close c_pessoa;
              elsif r_avalistas_epr.nrctaav2 = 0 then
              -- Avalista Não Cooperado
              open c_avalista_naocoop(r_avalistas_epr.nmdaval2);
               fetch c_avalista_naocoop into r_avalista_naocoop;
                if c_avalista_naocoop%found then

                      if ((r_avalistas_epr.nrctaav1 = 0 and trim(r_avalistas_epr.nmdaval1) is not null) or r_avalistas_epr.nrctaav1 > 0)
                     and ((r_avalistas_epr.nrctaav2 = 0 and trim(r_avalistas_epr.nmdaval2) is not null) or r_avalistas_epr.nrctaav2 > 0) then
                        vr_filtro := '_2';
                      else
                        vr_filtro := null;
                      end if;

                      pc_gera_dados_aval_nao_coop(pr_persona => 'Avalista 2 Não Coop.',
                                                  pr_persona_filtro => 'avalista'||vr_filtro,
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_nrcpfcgc => r_avalista_naocoop.nrcpfcgc,
                                                  pr_xmlOut => vr_xml);

                                   pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                  pr_texto_completo => vr_string_completa,
                                                  pr_texto_novo     => vr_xml,
                                                  pr_fecha_xml      => TRUE);


               end if;
              close c_avalista_naocoop;
             end if;
          end if;
        close c_avalistas_epr;
      
      elsif pr_tpproduto = c_limite_desc_titulo then
        open c_avalistas_limit_dec_tit;
         fetch c_avalistas_limit_dec_tit into r_avalistas_limit_dec_tit;
          if c_avalistas_limit_dec_tit%found then
             --Avalista 1
             if r_avalistas_limit_dec_tit.nrctaav1 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_limit_dec_tit.nrctaav1);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if (r_avalistas_limit_dec_tit.nrctaav1 > 0 or  trim(r_avalistas_limit_dec_tit.nmdaval1) is not null) and (r_avalistas_limit_dec_tit.nrctaav2 > 0 or trim(r_avalistas_limit_dec_tit.nmdaval2) is not null) then
                      vr_filtro := '_1';
                    else
                      vr_filtro := null;
                    end if;

                    pc_gera_dados_persona(pr_persona => 'Avalista '||r_avalistas_limit_dec_tit.nrctaav1,
                                          pr_persona_filtro => 'avalista'||vr_filtro,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => r_pessoa.nrdconta,
                                          pr_idpessoa => r_pessoa.idpessoa,
                                          pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                          pr_inpessoa => r_pessoa.inpessoa,
                                          pr_xmlOut => vr_xml);

                           pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                          pr_texto_completo => vr_string_completa,
                                          pr_texto_novo     => vr_xml,
                                          pr_fecha_xml      => TRUE);

                  end if;
                  close c_pessoa;
                  
             elsif r_avalistas_limit_dec_tit.nrctaav1 = 0 then
              -- Avalista Não Cooperado
              open c_avalista_naocoop(r_avalistas_limit_dec_tit.nmdaval1);
               fetch c_avalista_naocoop into r_avalista_naocoop;
                if c_avalista_naocoop%found then

                    if ((r_avalistas_limit_dec_tit.nrctaav1 = 0 and trim(r_avalistas_limit_dec_tit.nmdaval1) is not null) or r_avalistas_limit_dec_tit.nrctaav1 > 0)
                   and ((r_avalistas_limit_dec_tit.nrctaav2 = 0 and trim(r_avalistas_limit_dec_tit.nmdaval2) is not null) or r_avalistas_limit_dec_tit.nrctaav2 > 0)then
                      vr_filtro := '_1';
                    else
                      vr_filtro := null;
                    end if;

                    pc_gera_dados_aval_nao_coop(pr_persona => 'Avalista 1 Não Coop.',
                                                pr_persona_filtro => 'avalista'||vr_filtro,
                                                pr_cdcooper => pr_cdcooper,
                                                pr_nrdconta => pr_nrdconta,
                                                pr_nrcpfcgc => r_avalista_naocoop.nrcpfcgc,
                                                pr_xmlOut => vr_xml);

                    pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                   pr_texto_completo => vr_string_completa,
                                   pr_texto_novo     => vr_xml,
                                   pr_fecha_xml      => TRUE);

               end if;
              close c_avalista_naocoop;
                  
             end if;
             --Avalista 2
             if r_avalistas_limit_dec_tit.nrctaav2 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_limit_dec_tit.nrctaav2);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if (r_avalistas_limit_dec_tit.nrctaav1 > 0 or  trim(r_avalistas_limit_dec_tit.nmdaval1) is not null) and (r_avalistas_limit_dec_tit.nrctaav2 > 0 or trim(r_avalistas_limit_dec_tit.nmdaval2) is not null) then
                      vr_filtro := '_2';
                    else
                      vr_filtro := null;
                    end if;
                    pc_gera_dados_persona(pr_persona => 'Avalista '||r_avalistas_limit_dec_tit.nrctaav2,
                                          pr_persona_filtro => 'avalista'||vr_filtro,
                                          pr_cdcooper => pr_cdcooper,
                                          pr_nrdconta => r_pessoa.nrdconta,
                                          pr_idpessoa => r_pessoa.idpessoa,
                                          pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                          pr_inpessoa => r_pessoa.inpessoa,
                                          pr_xmlOut => vr_xml);


                            pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                           pr_texto_completo => vr_string_completa,
                                           pr_texto_novo     => vr_xml,
                                           pr_fecha_xml      => TRUE);

                  end if;
                  close c_pessoa;

              elsif r_avalistas_limit_dec_tit.nrctaav2 = 0 then
              -- Avalista Não Cooperado
              open c_avalista_naocoop(r_avalistas_limit_dec_tit.nmdaval2);
               fetch c_avalista_naocoop into r_avalista_naocoop;
                if c_avalista_naocoop%found then

                      if ((r_avalistas_limit_dec_tit.nrctaav1 = 0 and trim(r_avalistas_limit_dec_tit.nmdaval1) is not null) or r_avalistas_limit_dec_tit.nrctaav1 > 0)
                     and ((r_avalistas_limit_dec_tit.nrctaav2 = 0 and trim(r_avalistas_limit_dec_tit.nmdaval2) is not null) or r_avalistas_limit_dec_tit.nrctaav2 > 0) then
                        vr_filtro := '_2';
                      else
                        vr_filtro := null;
                      end if;

                      pc_gera_dados_aval_nao_coop(pr_persona => 'Avalista 2 Não Coop.',
                                                  pr_persona_filtro => 'avalista'||vr_filtro,
                                                  pr_cdcooper => pr_cdcooper,
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_nrcpfcgc => r_avalista_naocoop.nrcpfcgc,
                                                  pr_xmlOut => vr_xml);

                      pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                     pr_texto_completo => vr_string_completa,
                                     pr_texto_novo     => vr_xml,
                                     pr_fecha_xml      => TRUE);

               end if;
              close c_avalista_naocoop;
              end if;
            end if;
         close c_avalistas_limit_dec_tit; 
        
      end if;
      /*FIM-INFORMAÇÃO AVALISTA*/

      /*GRUPO-ECONOMICO*/
      vr_nrfiltro := 0;
      for r_grupo_economico in c_grupo_economico(pr_cdcooper,pr_nrdconta) loop
        for r_grupo_economico_integ in c_grupo_economico_integ (pr_cdcooper, r_grupo_economico.idgrupo) loop   

          if r_grupo_economico_integ.nrdconta != pr_nrdconta then

            open c_pessoa(pr_cdcooper, r_grupo_economico_integ.nrdconta);
             fetch c_pessoa into r_pessoa;
              if c_pessoa%found then

                vr_nrfiltro := vr_nrfiltro+1;
                vr_filtro := '_'||to_char(vr_nrfiltro);
                pc_gera_dados_persona(pr_persona => 'GE '||r_grupo_economico_integ.nrdconta,
                                      pr_persona_filtro => 'grupo'||vr_filtro,
                                      pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => r_grupo_economico_integ.nrdconta,
                                      pr_idpessoa => r_pessoa.idpessoa,
                                      pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                      pr_inpessoa => r_pessoa.inpessoa,
                                      pr_xmlOut => vr_xml);
                                      /*pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic, */

                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                        pr_texto_completo => vr_string_completa,
                                        pr_texto_novo     => vr_xml,
                                        pr_fecha_xml      => TRUE);

              end if;
              close c_pessoa;
          end if;
        end loop;
      end loop;
      /*FIM-GRUPO-ECONOMICO*/
      

      /*QUADRO SOCIETARIO*/
      vr_nrfiltro := 0;
      for r_socios in c_socios(pr_cdcooper,pr_nrdconta) loop
         open c_pessoa(r_socios.cdcooper, r_socios.nrdctato);
          fetch c_pessoa into r_pessoa;
           if c_pessoa%found then

              vr_nrfiltro := vr_nrfiltro+1;
              vr_filtro := '_'||to_char(vr_nrfiltro);
              pc_gera_dados_persona(pr_persona => 'QS '||r_pessoa.nrdconta,
                                    pr_persona_filtro => 'quadro'||vr_filtro,
                                    pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => r_pessoa.nrdconta,
                                    pr_idpessoa => r_pessoa.idpessoa,
                                    pr_nrcpfcgc => r_pessoa.nrcpfcgc,
                                    pr_inpessoa => r_pessoa.inpessoa,
                                    pr_xmlOut => vr_xml);

                                    pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                    pr_texto_completo => vr_string_completa,
                                    pr_texto_novo     => vr_xml,
                                    pr_fecha_xml      => TRUE);

           end if;          
         close c_pessoa;  
      end loop;      
      /*FIM-QUADRO SOCIETARIO*/   
      
      -- Encerrar a tag raiz
      pc_escreve_xml(pr_xml            => vr_dsxmlret,
                     pr_texto_completo => vr_string_completa,
                     pr_texto_novo     => '</personas></Dados></Root>',
                     pr_fecha_xml      => TRUE);
                     

      /*Gravar informações */
      open c_versao_analise;
       fetch c_versao_analise  into vr_nrversao_analise;
        if c_versao_analise%notfound then
         vr_nrversao_analise := 1;
        end if;
      close c_versao_analise;
      --
      begin
        insert into tbgen_analise_credito(cdcooper,
                                          nrdconta,
                                          nrcpfcgc,
                                          nrcontrato,
                                          nrversao_analise,
                                          dhinicio_analise,
                                          dtmvtolt,
                                          tpproduto,
                                          xmlanalise,
                                          dscritic) values(pr_cdcooper,
                                                           pr_nrdconta,
                                                           vr_nrcpfcgc_principal,
                                                           pr_nrctrato,
                                                           vr_nrversao_analise,
                                                           sysdate,
                                                           rw_crapdat.dtmvtolt,
                                                           pr_tpproduto,
                                                           vr_dsxmlret,
                                                           vr_dscritic);
                                                           commit;
      exception
        when others then
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
          vr_dscritic := 'Erro ao inserir tbgen_analise_credito '||sqlerrm;
          RAISE ERRO_PRINCIPAL;
      end;
  exception
   when ERRO_PRINCIPAL then
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                     pr_ind_tipo_log => 2,
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                               || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados proc principal. '
                                               || ', erro: '||substr(vr_dscritic,1,255),
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                     pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
   when others then
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                               || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados proc principal. '
                                               || ', erro: '||substr(sqlerrm,1,255),
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));     

  end pc_gera_dados_analise_credito;  

  PROCEDURE pc_job_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Cooperativa
                                        ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                        ,pr_tpproduto IN number                      --> Produto
                                        ,pr_nrctremp  IN crawepr.nrctremp%TYPE       --> Número contrato emprestimo
                                        ,pr_dscritic OUT VARCHAR2) IS                --> Descricao da critica
  
  CURSOR cr_verifica_job(pr_jobname   IN VARCHAR2
                        ,pr_cdcooper  IN crapass.cdcooper%TYPE
                        ,pr_nrdconta  IN crapass.nrdconta%TYPE
                        ,pr_tpproduto IN NUMBER
                        ,pr_nrctrato  IN NUMBER
                        ) IS
      SELECT DISTINCT 1
        FROM dba_scheduler_jobs
       WHERE owner = 'CECRED'
         AND job_name LIKE '%' || pr_jobname || '%'
         AND JOB_ACTION LIKE '%pr_cdcooper => ' || pr_cdcooper || '%'
         AND JOB_ACTION LIKE '%pr_nrdconta => ' || pr_nrdconta || '%'
         AND JOB_ACTION LIKE '%pr_tpproduto => ' || pr_tpproduto || '%'
         AND JOB_ACTION LIKE '%pr_nrctrato => ' || pr_nrctrato || '%';
    rw_verifica_job cr_verifica_job%ROWTYPE;
    --
    -- Bloco PLSQL para chamar a execução paralela do pc_crps414
    vr_dsplsql VARCHAR2(4000);
    -- Job name dos processos criados
    vr_jobname VARCHAR2(100);
  
    vr_dscritic crapcri.dscritic%TYPE;
  
  BEGIN
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'JBGEN_TELA_UNICA_$';
    OPEN cr_verifica_job (pr_jobname   => vr_jobname
                         ,pr_cdcooper  => pr_cdcooper
                         ,pr_nrdconta  => pr_nrdconta
                         ,pr_tpproduto => pr_tpproduto
                         ,pr_nrctrato  => pr_nrctremp);
    FETCH cr_verifica_job
      INTO rw_verifica_job;
    IF cr_verifica_job%NOTFOUND THEN
      CLOSE cr_verifica_job;
      -- Acionar rotina para derivação automatica em  paralelo
      vr_dsplsql := 'BEGIN'||chr(13)
                     || '  TELA_ANALISE_CREDITO.pc_gera_dados_analise_credito(pr_cdcooper => '||pr_cdcooper ||chr(13)
                     || '                                                    ,pr_nrdconta => '||pr_nrdconta ||chr(13)
                     || '                                                    ,pr_tpproduto => '||pr_tpproduto||chr(13)
                     || '                                                    ,pr_nrctrato => '||pr_nrctremp||chr(13)
                     || '                                                    );'||chr(13)
                     || 'END;';
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                            ,pr_cdprogra  => 'TELA_ANALISE_CREDITO' --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSDATE  + 1/1440 --> Executar após 1 minuto
                            ,pr_interva   => null         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            , pr_des_erro => vr_dscritic);
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Adicionar ao LOG e continuar o processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2,
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                   || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para análise de crédito. '
                                                   || ', erro: '||vr_dscritic,
                                   pr_nmarqlog => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                             pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      END IF;
    ELSE
      CLOSE cr_verifica_job;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_dscritic := 'Erro ao gerar Job: '||sqlerrm;
      -- Adicionar ao LOG e continuar o processo
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para análise de crédito. '
                                                 || ', erro: '||vr_dscritic,
                                 pr_nmarqlog => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                           pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
  END;


PROCEDURE pc_lista_cred_recebidos(pr_cdcooper IN crapass.cdcooper%TYPE
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                 ,pr_XmlOut   OUT VARCHAR2) IS            --> Nome do campo com erro

  
    -- Cursor sobre a tabela de lancamentos
    CURSOR cr_craplcm(pr_dtinicio IN crapdat.dtmvtolt%TYPE
                     ,pr_dtfim    IN crapdat.dtmvtolt%TYPE
                     ,pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_cdhistor IN crapprm.dsvlrprm%TYPE) IS
      SELECT sum(craplcm.vllanmto) valor
        FROM craplcm
       WHERE craplcm.dtmvtolt BETWEEN pr_dtinicio AND pr_dtfim
         AND craplcm.cdcooper = pr_cdcooper
         AND craplcm.nrdconta = pr_nrdconta
         AND INSTR(pr_cdhistor, ';' || craplcm.cdhistor || ';') > 0;
    rw_craplcm_cred cr_craplcm%ROWTYPE;
    rw_craplcm_debi cr_craplcm%ROWTYPE;
  
    -- Variaveis de log
    vr_cdhistor_cred crapprm.dsvlrprm%TYPE;
    vr_cdhistor_debi crapprm.dsvlrprm%TYPE;
  
    -- Variaveis gerais
    vr_dtinicio    DATE;
    vr_vltrimestre craplcm.vllanmto%TYPE;
    vr_vlsemestre  craplcm.vllanmto%TYPE;
    vr_string      CLOB;
  

  BEGIN
    -- historicos de creditos
    vr_cdhistor_cred := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper,
                                             pr_nmsistem => 'CRED',
                                                  pr_cdacesso => 'HIS_CRED_RECEBIDOS');
  
    -- historicos de debito (estorno)
    vr_cdhistor_debi := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper,
                                             pr_nmsistem => 'CRED',
                                                  pr_cdacesso => 'HIS_DEB_DESCONTADOS');
    -- Busca a data do sistema
    OPEN btch0001.cr_crapdat(pr_cdcooper);
  
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
  
    CLOSE btch0001.cr_crapdat;

  
    -- Atualiza a data de inicio da busca
    vr_dtinicio := TRUNC(ADD_MONTHS(rw_crapdat.dtmvtolt, -6), 'MM');
  
    -- Efetua loop sobre os meses de busca
    FOR x IN 1 .. 6 LOOP
    
      -- Busca o valor de credito do mes solicitado
      OPEN cr_craplcm(pr_dtinicio => vr_dtinicio
                     ,pr_dtfim    => LAST_DAY(vr_dtinicio)
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_cdhistor => vr_cdhistor_cred);
    
      FETCH cr_craplcm INTO rw_craplcm_cred;
    
      CLOSE cr_craplcm;
    
      -- Busca o valor de debito do mes solicitado
      OPEN cr_craplcm(pr_dtinicio => vr_dtinicio
                     ,pr_dtfim    => LAST_DAY(vr_dtinicio)
                     ,pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_cdhistor => vr_cdhistor_debi);
    
      FETCH cr_craplcm INTO rw_craplcm_debi;
    
      CLOSE cr_craplcm;

    
      -- Efetua a somatoria do trimestre
      IF x BETWEEN 4 AND 6 THEN
        vr_vltrimestre := NVL(vr_vltrimestre, 0) + (NVL(rw_craplcm_cred.valor, 0) - NVL(rw_craplcm_debi.valor, 0));
      END IF;
    
      -- Efetua a somatoria do semestre
      IF x <= 6 THEN
        vr_vlsemestre := NVL(vr_vlsemestre, 0) + (NVL(rw_craplcm_cred.valor, 0) - NVL(rw_craplcm_debi.valor, 0));
      END IF;
    
      -- Incrementa o mês
      vr_dtinicio := ADD_MONTHS(vr_dtinicio, 1);
    
    END LOOP;
  
    vr_string := fn_tag('Média de Créditos Recebidos no Trimestre',TO_CHAR(ROUND(vr_vltrimestre/3,2),'999g999g990d00'))||
                 fn_tag('Média de Créditos Recebidos no Semestre',TO_CHAR(ROUND(vr_vlsemestre/6,2),'999g999g990d00'));
  
    pr_XmlOut := vr_string;
  
  END pc_lista_cred_recebidos;


  PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number                      --> Número contrato
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                       ,pr_dsxmlret IN OUT NOCOPY xmltype) IS  --> Arquivo de retorno do XML
  
    /* .............................................................................
    
    Programa:  pc_consulta_analise_credito
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Março/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
    Objetivo  : Rotina para retornar XML com dados para analise de credito
    
    Alteracoes: -----
    ..............................................................................*/
    cursor c1 is 
        select a.xmlanalise
              ,a.dscritic
          from tbgen_analise_credito a
         where cdcooper = pr_cdcooper
           and nrdconta = pr_nrdconta
           and tpproduto = pr_tpproduto
           and nrcontrato = pr_nrctrato
           and a.nrversao_analise = (select max(nrversao_analise)
                                          from tbgen_analise_credito b
                                         where cdcooper = a.cdcooper
                                           and nrdconta = a.nrdconta
                                           and tpproduto = a.tpproduto
                                           and nrcontrato = a.nrcontrato
                                         group by cdcooper,nrdconta,tpproduto,nrcontrato);
       r1 c1%rowtype;
  
  vr_dsxmlret clob;
  
  BEGIN
  
   open c1;
    fetch c1 into r1;
     if c1%found then
      vr_dsxmlret := r1.xmlanalise;
      pr_dscritic := r1.dscritic;
     else
      pr_dscritic := 'Dados para esta proposta não foram encontrados!';
     end if;
   close c1;
    -- Cria o XML a ser retornado
    pr_dsxmlret := xmltype.createXML(xmlData => vr_dsxmlret);
  
  EXCEPTION
    when others then
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro - pc_consulta_analise_credito: '||sqlerrm;
  END;

  PROCEDURE pc_consulta_cadastro_pf(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE --> IDPESSOA
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB) IS      --> Arquivo de retorno do XML
  
    CURSOR c_cjg_coresponsavel(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                            ,pr_nrctrato IN crapprp.nrdconta%TYPE       --> Conta
                            ,pr_tpctrato IN crapprp.tpctrato%TYPE) is
  select co.nrdconta
    from crapprp co
   where co.cdcooper = pr_cdcooper
     and co.nrctrato = pr_nrctrato
     and co.tpctrato = pr_tpctrato;
  r_cjg_coresponsavel c_cjg_coresponsavel%rowtype;
  
  CURSOR c_contas_pj(pr_cdcooper in number,
                     pr_nrdctato in number) IS
   SELECT gene0002.fn_mask_conta(a.nrdconta) nrdconta
         ,avt.dsproftl
         ,to_char(avt.dtvalida,'dd/mm/rrrr') dtvalida
     FROM crapass a,
          tbcadast_pessoa p,
          crapavt avt
     WHERE a.dtdemiss is null
       AND a.inpessoa = 2 -- PJ
       AND a.nrdconta = avt.nrdconta
       AND a.cdcooper = avt.cdcooper
       AND a.nrcpfcgc = p.nrcpfcgc
       AND avt.tpctrato = 6     
       AND avt.nrdctato > 0       
       AND avt.nrdctato = pr_nrdctato
       AND avt.cdcooper = pr_cdcooper;  

    vr_dsxmlret CLOB;
  
  vr_totalRendimentoOutros number; -- bruno - dados comerciais
  
    vr_string     CLOB;
    vr_string_aux CLOB;
    vr_index      NUMBER := 1;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
  vr_string := '<subcategoria>'||
               '<tituloTela>Dados Cadastrais</tituloTela>'||
               '<campos>';
  
  open c_cadastro(pr_cdcooper,pr_nrdconta);
   fetch c_cadastro into r_cadastro;
    if c_cadastro%notfound then
      /*Message Erro*/
      vr_string := '<erros><erro>'||
                   '<dscritic>Dados cadastrais não encontrado!</dscritic>'||
                   '</erro></erros>';
    else
    
      /*Gera Tags Xml*/
      vr_string := vr_string||
                   r_cadastro.conta||
                   r_cadastro.tipoconta||
                   r_cadastro.situacao_conta||
                   r_cadastro.pa||
                   r_cadastro.nome ||
                  --a.dtnasctl,
                   r_cadastro.idade||
                   r_cadastro.cpf_tag||
                   r_cadastro.estado_civil||
                   r_cadastro.dsnatura||
                  --todo: utilizar CRAPDAT para calcular data
                   r_cadastro.tempocoop;
    end if;
   close c_cadastro;

   /*Montar tabela com as informações Representante Procurador*/
   vr_string := vr_string||'<campo>
                            <nome>Representante/Procurador das contas Jurídicas</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
      vr_index := 1;
      vr_tab_tabela.delete;
      for r_outras_contas_pj in c_contas_pj(pr_cdcooper,pr_nrdconta) loop
       vr_tab_tabela(vr_index).coluna1 := r_outras_contas_pj.nrdconta;
       vr_tab_tabela(vr_index).coluna2 := r_outras_contas_pj.dsproftl;
       vr_tab_tabela(vr_index).coluna3 := case when substr(r_outras_contas_pj.dtvalida,-4) = '9999' then 'INDETERMINADO' else r_outras_contas_pj.dtvalida end;
       vr_index := vr_index+1;
      end loop;

      if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string := vr_string||fn_tag_table('Conta PJ;Cargo;Vigência',vr_tab_tabela);
      else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_string := vr_string||fn_tag_table('Conta PJ;Cargo;Vigência',vr_tab_tabela);
      end if;

     vr_string := vr_string||'</linhas>
                              </valor>
                              </campo>';    
    
  
    vr_string := vr_string || '</campos></subcategoria>';
  
    /*Chaves para buscas*/
    /*open c_pessoa(pr_cdcooper,pr_nrdconta);
     fetch c_pessoa into r_pessoa;
    close c_pessoa;*/
  

    --Patrimonio
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Patrimônio</tituloTela>'||
                          '<campos>';
    /*Aluguel (Despesa):
    Tipo de Imóvel:
    Tempo de Residência:
    */
  open c_endereco_residencial(pr_idpessoa); --bug 19588
   fetch c_endereco_residencial into r_endereco_residencial;
    if c_endereco_residencial%found then
      /*Gera Tags Xml*/
      vr_string := vr_string||
                   r_endereco_residencial.aluguel||
                   r_endereco_residencial.tipoImovel||
                   r_endereco_residencial.tempoResidenciaAnos;
    end if;
   close c_endereco_residencial;

  
    /*
    Bens:
    Livre de Ônus:
    resposta em %
    Qtd. Parcela:
    Valor:*/
    /*Apresentado em tabela*/
    vr_string := vr_string || '<campo>
                           <nome>Bens</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
    vr_index  := 1;
    vr_tab_tabela.delete;
  for r_bens in c_bens(pr_cdcooper,pr_nrdconta) loop
      vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
      vr_tab_tabela(vr_index).coluna2 := r_bens.persemon || '%';
      vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
   vr_tab_tabela(vr_index).coluna4 := trim(to_char(r_bens.vlprebem,'999g999g990d00'));   
      vr_tab_tabela(vr_index).coluna5 := to_char(r_bens.vlrdobem, '999g999g990d00');
      vr_index := vr_index + 1;
  end loop;
  
  if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Descrição do Bem;Livre de Ônus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
    vr_string := vr_string||fn_tag_table('Descrição do Bem;Livre de Ônus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
  
    vr_string := vr_string || '</campos></subcategoria>';
  
    --Coresponsavel Somente PF
  open c_cjg_coresponsavel(r_proposta_epr.cdcooper,r_proposta_epr.nrdconta,r_proposta_epr.nrctremp);
   fetch c_cjg_coresponsavel into r_cjg_coresponsavel;
   if c_cjg_coresponsavel%found then
      /*
      Bens:
      Livre de Ônus:
      resposta em %
      Qtd. Parcela:
      Valor:*/
      /*Apresentado em tabela*/
      vr_string := vr_string || '<campo>
                               <nome>Bens Cônjuge Co-Responsável</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';
      vr_index  := 1;
      vr_tab_tabela.delete;
      for r_bens in c_bens(pr_cdcooper,r_cjg_coresponsavel.nrdconta) loop
        vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
        vr_tab_tabela(vr_index).coluna2 := r_bens.persemon || '%';
        vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
        vr_tab_tabela(vr_index).coluna4 := to_char(r_bens.vlrdobem, '999g999g990d00');
        --vr_tab_tabela(vr_index).coluna5 := r_bens.vlprebem;
        vr_index := vr_index + 1;
      end loop;
    
      if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string := vr_string || fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor', vr_tab_tabela);
      else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        --vr_tab_tabela(1).coluna5 := '-';
        vr_string := vr_string || fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor', vr_tab_tabela);
      end if;
    
      vr_string := vr_string || '</linhas>
                                </valor>
                                </campo>';
    
      vr_string := vr_string || '</campos></subcategoria>';
   end if;
  close c_cjg_coresponsavel;
  
    --Comerciais
    /*Natureza da Ocupação:                             Ocupação:
    Tipo de Contrato de Trabalho:
    Empresa:
    Cargo:
    Tempo de Empresa: Formato mês/ano
    Salário:
    Total de Outros Rendimentos:                                 Origem:
    Recebe benefício ou salário na cooperativa? Resposta Sim ou Não Extrato da Conta Corrente
    Mostrar as rendas automáticas para consulta (novo)
    Mostrar a média de créditos recebidos no semestre e trimestre para consulta (novo)
    Mostrar a  consulta do comprovante de renda e IR (novo)*/
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Dados Comerciais</tituloTela>'||
                          '<campos>';


  open c_dados_comerciaisI(r_cadastro.cpf);
   fetch c_dados_comerciaisI into r_dados_comerciaisI;
    if c_dados_comerciaisI%found then
      -- Dados segundo cursor
      open c_dados_comerciaisII(r_dados_comerciaisI.Idpessoa);
       fetch c_dados_comerciaisII into r_dados_comerciaisII;
        if c_dados_comerciaisII%found then
        /*Gera Tags Xml*/
          open c_gncdocp(r_cadastro.cdocpttl);
           fetch c_gncdocp into r_gncdocp;
          close c_gncdocp;
        --
          vr_string := vr_string||
                       r_dados_comerciaisI.natureza_ocupacao||
                       r_gncdocp.rsdocupa||
                     r_dados_comerciaisII.tipo_contrato_trab ||
                    --r_dados_comerciaisII.nrcpfcgc||
                       r_dados_comerciaisII.empresa||
                       r_dados_comerciaisI.Profissao||
                    --r_dados_comerciaisI.Jusrendimento||
                       r_dados_comerciaisII.tempoempresa||
                       r_dados_comerciaisII.vlrenda;
      
        end if;
       close c_dados_comerciaisII;
    end if;
   close c_dados_comerciaisI;
  
    --Renda complementar
    /*
    Tipo Renda:
    Valor:*/
    /*Apresentado em tabela*/
    vr_string := vr_string || '<campo>
                           <nome>Outros Rendimentos</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
    vr_index  := 1;
    vr_tab_tabela.delete;
    vr_totalRendimentoOutros := 0; -- Bruno Dados Comerciais
  for r_renda_compl in c_renda_compl(pr_idpessoa) loop --bug 19597
      vr_tab_tabela(vr_index).coluna1 := r_renda_compl.dscodigo;
      vr_tab_tabela(vr_index).coluna2 := to_char(r_renda_compl.vlrenda, '999g999g990d00');
      vr_index := vr_index + 1;
      vr_totalRendimentoOutros := vr_totalRendimentoOutros + r_renda_compl.vlrenda; -- Bruno - Dados Comerciais
  end loop;
  
  
  
    --vr_totalRendimentoOutros
  
  if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string := vr_string || fn_tag_table('Tipo de Renda;Valor', vr_tab_tabela);
    
    vr_string := vr_string||'<linha><colunas>'
                          ||'<coluna>Total</coluna>'
                          ||'<coluna>'||to_char(vr_totalRendimentoOutros,'999g999g990d00')||'</coluna>'
                          ||'</colunas></linha>'; -- bruno - Dados Comerciais
  else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_string := vr_string || fn_tag_table('Tipo de Renda;Valor', vr_tab_tabela);
    end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
  
    /*Justificativa do Rendimento*/
    vr_string := vr_string || r_dados_comerciaisI.Jusrendimento;
  
    --Rendimentos automáticos
    vr_string := vr_string || '<campo>
                            <nome>Rendas Automáticas</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
  
    pc_busca_rendas_aut(pr_cdcooper, pr_nrdconta, vr_string_aux);
  
    vr_string := vr_string || vr_string_aux || '</linhas>
                                </valor>
                                </campo>';
    /*Movimentação trimestre e semestre*/
    vr_string_aux := NULL;
    pc_lista_cred_recebidos(pr_cdcooper, pr_nrdconta, vr_string_aux);
    vr_string := vr_string || vr_string_aux;
  
    vr_string := vr_string || '<campo>
                             <nome>Consultar o comprovante de renda e IR</nome>
                             <tipo>info</tipo>
                             <valor>Imagem/Digidoc</valor>
                            </campo>';
  
    /* Dossie Digidoc*/
   vr_string := vr_string||'<campo>'||
                           '<nome>Imagem/Digidoc</nome>'||
                           '<tipo>link</tipo>'||
                           '<valor>http://GEDServidor/smartshare/Cliente/ViewerExterno.aspx?'||
                           'pkey=G7o9A&amp;' ||
                           'CPF/CNPJ='||
                            gene0002.fn_mask_cpf_cnpj(r_cadastro.cpf,1) ||
                           '</valor>'||
                           '</campo>';
  
    vr_string := vr_string || '</campos>';
  
    -- Encerrar a tag raiz
   pc_escreve_xml(pr_xml            => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo     => '</subcategoria>',
                   pr_fecha_xml => TRUE);
  
    pr_dsxmlret := vr_dsxmlret;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_cadastro_pf: '||sqlerrm;
  END;



  PROCEDURE pc_consulta_cadastro_pj(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB) IS      --> Arquivo de retorno do XML
    /* .............................................................................
    
      Programa: pc_consulta_cadastro_pj
      Sistema : Aimaro/Ibratan
      Autor   : Rubens Lima
      Data    : Março/2019                 Ultima atualizacao: 31/07/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para consultar as informações do cadastro PJ
    
      Alteracoes: PRJ438 - Sprint 15 - Inclusão da tabela de faturamento empresarial.
                           Rubens Lima - 31/07/2019 - Mouts
    ..............................................................................*/
   /*Busca os dados de faturamento empresarial*/
   CURSOR c_busca_dados_faturamento (pr_cdcooper IN crapcop.cdcooper%TYPE,
                                     pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT j.vlrftbru##1 valor
          ,j.mesftbru##1 mes
          ,j.anoftbru##1 ano    
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##2 
          ,j.mesftbru##2
          ,j.anoftbru##2     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##3 
          ,j.mesftbru##3
          ,j.anoftbru##3     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##4 
          ,j.mesftbru##4
          ,j.anoftbru##4     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##5 
          ,j.mesftbru##5
          ,j.anoftbru##5     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##6 
          ,j.mesftbru##6
          ,j.anoftbru##6     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##7 
          ,j.mesftbru##7
          ,j.anoftbru##7     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##8 
          ,j.mesftbru##8
          ,j.anoftbru##8     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##9 
          ,j.mesftbru##9
          ,j.anoftbru##9     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##10 
          ,j.mesftbru##10
          ,j.anoftbru##10     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##11 
          ,j.mesftbru##11
          ,j.anoftbru##11     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    UNION ALL
    SELECT j.vlrftbru##12 
          ,j.mesftbru##12
          ,j.anoftbru##12     
    FROM crapjfn j
    WHERE j.cdcooper = pr_cdcooper
    AND   j.nrdconta = pr_nrdconta
    ORDER BY 3 DESC, 2 DESC;
    r_busca_dados_faturamento c_busca_dados_faturamento%ROWTYPE;
  
    vr_dsxmlret CLOB;
  
    vr_dstexto    CLOB;
    vr_string     CLOB;
    vr_string_aux CLOB;
    vr_index      NUMBER := 1;
  
  BEGIN
  
    -- Buscar a data do movimento
    OPEN btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  
    -- Fechar o cursor
    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      RAISE vr_exc_erro;
    END IF;
  
    CLOSE btch0001.cr_crapdat;
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    /* 1.1 Dados Cadastrais*/
  vr_string := '<subcategoria>'||
               '<tituloTela>Dados Cadastrais</tituloTela>';
  
   open c_cadastro_pj(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
   fetch c_cadastro_pj into r_cadastro_pj;
    if c_cadastro_pj%notfound then
        vr_string := vr_string||'<campos><campo>'||
                                 '<nome>Dados Cadastrais</nome>'||
                                 '<tipo>string</tipo>'||
                                 '<valor>Dados Cadastrais - não encontrados</valor>'||
                                '</campo></campos>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string||'<campos>'||
                   r_cadastro_pj.conta||
                   r_cadastro_pj.tipoconta||
                   r_cadastro_pj.situacao_conta||
                   r_cadastro_pj.pa||
                   r_cadastro_pj.rsocial||
                   r_cadastro_pj.cnpj||
                   r_cadastro_pj.nmrmativ||
                   r_cadastro_pj.tempoempresa||
                   r_cadastro_pj.tempocoop||'</campos>';
    end if;
   close c_cadastro_pj;
  
    vr_string := vr_string || '</subcategoria>';
    /* Fim Dados Cadastrais*/
  
    /* 1.2 Patrimonios PJ */
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Patrimônio</tituloTela>';
  
  open c_patrimonio_pj_reside (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
   fetch c_patrimonio_pj_reside into r_patrimonio_pj;
    if c_patrimonio_pj_reside%notfound then
      --Não encontrou, não gera crítica mas cria TAG campos para apresentar a próxima tabela
      vr_string := vr_string || '<campos>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string || '<campos>';
    
      if (upper(r_patrimonio_pj.tpimovel) = 'ALUGADO') then
        vr_string := vr_string || fn_tag('Aluguel (Despesa)', to_char(r_patrimonio_pj.vlalugue, '999g999g990d00'));
      else
        vr_string := vr_string || fn_tag('Aluguel (Despesa)', 0);
      end if;
    
      vr_string := vr_string || r_patrimonio_pj.tipoimovel||
                   r_patrimonio_pj.temporeside;
    end if;
  close c_patrimonio_pj_reside;
  
    /*Bens apresentados em tabela*/
    vr_string := vr_string || '<campo>
                           <nome>Bens</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
    vr_index  := 1;
    vr_tab_tabela.delete;
  for r_bens in c_bens_pj(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta) loop
      vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
      vr_tab_tabela(vr_index).coluna2 := r_bens.persemon;
      vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
   vr_tab_tabela(vr_index).coluna4 := trim(to_char(r_bens.vlprebem,'999g999g990d00'));
      vr_tab_tabela(vr_index).coluna5 := to_char(r_bens.vlrdobem, '999g999g990d00');
      vr_index := vr_index + 1;
  end loop;
  
  if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Descrição do Bem;Livre de Ônus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_string := vr_string || fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor', vr_tab_tabela);
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
  
    vr_string := vr_string || '</campos></subcategoria>';
  
    /* Fim Patrimonios */
  
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Dados Comerciais</tituloTela>';
  
    /* 1.3 - Dados Comerciais - Faturamento */
  open c_dados_comerciais_fat (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta);
   fetch c_dados_comerciais_fat into r_dados_comerciais_fat;
    if c_dados_comerciais_fat%notfound then
        vr_string := vr_string||'<campos><campo>'||
                                 '<nome>Dados Comerciais Faturamento</nome>'||
                                 '<tipo>string</tipo>'||
                                 '<valor>Dados Comerciais Faturamento - não encontrado</valor>'||
                   '</campo>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string||'<campos>';

      /*TABELA - Faturamento*/
      vr_index  := 1;
      vr_tab_tabela.delete;
      OPEN c_busca_dados_faturamento (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => pr_nrdconta);
       LOOP
       FETCH c_busca_dados_faturamento INTO r_busca_dados_faturamento;
       EXIT WHEN c_busca_dados_faturamento%NOTFOUND;
       /*Enquanto tiver registros*/
       IF c_busca_dados_faturamento%FOUND THEN
         /*No primeiro laço monta as tags*/
         IF (vr_index = 1) THEN
           vr_string := vr_string || '<campo>
                                      <nome>Faturamento</nome>
                                      <tipo>table</tipo>
                                      <valor>
                                      <linhas>';
         END IF;
         /*Não gerar dados quando não houver lançamento*/
         IF (NVL(r_busca_dados_faturamento.mes,0)) > 0 THEN
           vr_tab_tabela(vr_index).coluna1 := r_busca_dados_faturamento.mes;
           vr_tab_tabela(vr_index).coluna2 := r_busca_dados_faturamento.ano;
           vr_tab_tabela(vr_index).coluna3 := 
           TO_CHAR(r_busca_dados_faturamento.valor,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''');
         END IF;
         vr_index := vr_index + 1;
       END IF;
      END LOOP;
      CLOSE c_busca_dados_faturamento;      
      /*Gera a tabela*/
      IF vr_tab_tabela.COUNT > 0 THEN
        vr_string := vr_string||fn_tag_table('Mês;Ano;Faturamento',vr_tab_tabela);
        vr_string := vr_string || '</linhas>
                                   </valor>
                                   </campo>';      
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_string := vr_string||fn_tag_table('Mês;Ano;Faturamento',vr_tab_tabela);
        vr_string := vr_string || '</linhas>
                                   </valor>
                                   </campo>';      
      END IF;
      vr_string := vr_string || r_dados_comerciais_fat.vlrmedfatbru||
                   r_dados_comerciais_fat.perfatcl;
    end if;
  
    /*Movimentação trimestre e semestre*/
    vr_string_aux := NULL;
    pc_lista_cred_recebidos(pr_cdcooper, pr_nrdconta, vr_string_aux);
    vr_string := vr_string || vr_string_aux;
  
    vr_string := vr_string || '<campo>
                             <nome>Consultar o comprovante de renda e IR</nome>
                             <tipo>info</tipo>
                             <valor>Imagem/Digidoc</valor>
                            </campo>';
  
    /* Dossie Digidoc*/
   vr_string := vr_string||'<campo>'||
                           '<nome>Imagem/DigiDoc</nome>'||
                           '<tipo>link</tipo>'||
                           '<valor>http://GEDServidor/smartshare/Cliente/ViewerExterno.aspx?'||
                           'pkey=G7o9A&amp;' ||
                           'CPF/CNPJ='|| gene0002.fn_mask_cpf_cnpj(r_cadastro_pj.cnpj_sem_format , 2) ||
                           '</valor>'||
                 '</campo>';
  
   close c_dados_comerciais_fat;
  
    vr_string := vr_string || '</campos>';
  
    vr_string := vr_string || '</subcategoria>';
    /* Fim Dados Comerciais de Faturamento */
  
    -- Escrever no XML
  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                 pr_texto_completo => vr_dstexto,
                 pr_texto_novo     => vr_string,
                   pr_fecha_xml => TRUE);
  
    pr_dsxmlret := vr_dsxmlret;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_cadastro_pj: '||sqlerrm;  
    
  END pc_consulta_cadastro_pj;

/*Sprint 15*/
PROCEDURE pc_consulta_cad_conjuge_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                       ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                                       ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                       ,pr_dsxmlret OUT CLOB) IS             --> Arquivo de retorno do XML
	/* .............................................................................
  Programa: pc_consulta_cad_conjuge_ncoop
  Sistema : Aimaro/Ibratan
  Autor   : Rubens Lima
  Data    : Agosto/2019                 Ultima atualizacao:
  Dados referentes ao programa:
  Frequencia: Sempre que for chamado
  Objetivo  : Consulta o cadastro de cônjuge não cooperado
  Alteracoes: 
  ..............................................................................*/
  vr_dsxmlret CLOB;
  vr_string     CLOB;
  
  BEGIN
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    vr_string := '<subcategoria>'||
                 '<tituloTela>Dados Cadastrais</tituloTela>'||
                 '<campos>';
    OPEN c_consulta_cad_conjuge_ncoop(pr_cdcooper,vr_nrdconta_principal);
     FETCH c_consulta_cad_conjuge_ncoop INTO r_consulta_cad_conjuge_ncoop;
     IF c_consulta_cad_conjuge_ncoop%FOUND THEN
        /*Gera Tags Xml*/
        vr_string := vr_string||
                     fn_tag('CPF', gene0002.fn_mask_cpf_cnpj(r_consulta_cad_conjuge_ncoop.nrcpfcjg,1))||
                     fn_tag('Nome',r_consulta_cad_conjuge_ncoop.nmconjug)||
                     fn_tag('Idade',trunc(months_between(rw_crapdat.dtmvtolt,
                                          r_consulta_cad_conjuge_ncoop.dtnasccj) / 12)|| ' anos');
     END IF;
    CLOSE c_consulta_cad_conjuge_ncoop;
    vr_string := vr_string || '</campos></subcategoria>';
    vr_string := vr_string||'<subcategoria>'||
                            '<tituloTela>Dados Comerciais</tituloTela>'||
                            '<campos>';
    -- Dados segundo cursor
    open c_dados_comerciais_conj_ncoop (pr_cdcooper, vr_nrdconta_principal);
     fetch c_dados_comerciais_conj_ncoop into r_dados_comerciais_conj_ncoop;
      if c_dados_comerciais_conj_ncoop%found then
      /*Gera Tags Xml*/
       vr_string := vr_string||
                    fn_tag('Natureza da Ocupação',r_dados_comerciais_conj_ncoop.ntocupacao)||
                    fn_tag('Ocupação',r_dados_comerciais_conj_ncoop.ocupacao)||
                    fn_tag('Tipo de Contrato de Trabalho',r_dados_comerciais_conj_ncoop.vinculo)||
                    fn_tag('Empresa',r_dados_comerciais_conj_ncoop.empresa)||
                    fn_tag('Cargo',r_dados_comerciais_conj_ncoop.cargo)||
                    fn_tag('Tempo de Empresa',NVL(trunc(months_between(rw_crapdat.dtmvtolt,
                                              r_dados_comerciais_conj_ncoop.dtadmemp) / 12),0)|| ' anos')||
                    fn_tag('Salario',TO_CHAR(r_dados_comerciais_conj_ncoop.vlsalari,
                                            'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')); 
      end if;
     vr_string := vr_string || '</campos>';
     close c_dados_comerciais_conj_ncoop;
     -- Encerrar a tag raiz
     pc_escreve_xml(pr_xml            => vr_dsxmlret,
                    pr_texto_completo => vr_string,
                    pr_texto_novo     => '</subcategoria>',
                    pr_fecha_xml => TRUE);
     pr_dsxmlret := vr_dsxmlret;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_cad_conjuge_ncoop: '||sqlerrm;
  END;
  PROCEDURE pc_consulta_garantia(pr_cdcooper  IN crapass.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                               ,pr_nrctrato IN crawepr.nrctremp%TYPE
                               ,pr_tpproduto IN NUMBER
                               ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                               ,pr_dsxmlret IN OUT CLOB) IS                --> Arquivo de retorno do XML
    /* .............................................................................
    
      Programa: pc_consulta_garantias
      Sistema : Aimaro/Ibratan
      Autor   : Rubens Lima
      Data    : Março/2019                 Ultima atualizacao: 12/06/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para consultar as garantias do proponente PF ou PJ
    
      Alteracoes: 30/05/2019 - Ajuste na mascara e correcao do texto do label.
                               Bug 22092 - PRJ438 - Gabriel Marcos (Mouts).
                               
                  31/05/2019 - Ordem de apresentacao de informacoes da Aba Garantia.
                               Story 21804 - PRJ438 - Gabriel Marcos (Mouts).
                               
                  12/06/2019 - Ordenação da tabela de Interveniente.
                               PRJ438 - Rubens Lima - (Mouts)
                               
                  17/06/2019 - Alterada a exibição do Interveniente de tabela para lista
                               PRJ438 - Jefferson - (Mouts)
                               
    ..............................................................................*/
  
    vr_dsxmlret                CLOB;
    vr_dstexto                 CLOB;
    vr_string                  CLOB;
    vr_string_cong             CLOB;
    vr_string_garantia_pessoal CLOB;
    vr_string_cabec            CLOB;
    pr_retxml                  xmltype;
  

    vr_idpessoa_conjuge tbcadast_pessoa.idpessoa%TYPE;
    vr_idpessoa         tbcadast_pessoa.idpessoa%TYPE;
    vr_nrdcontacjg      crapass.nrdconta%TYPE;
    vr_cpfconjuge       crapcje.nrcpfcjg%TYPE;
    vr_nrdconta         crapass.nrdconta%TYPE;
    --vr_saldocotas_conjuge   crapcot.vldcotas%TYPE;
    vr_vldcotas VARCHAR2(100);
    --Saldo Médio
    vr_saldo_mes       NUMBER;
    vr_saldo_trimestre NUMBER;
    vr_saldo_semestre  NUMBER;
    --Aplicações
    vr_vldaplica  NUMBER;
    vr_index      NUMBER := 1;
    vr_index_aval NUMBER := 1;
  
  vr_isinterv         boolean:=FALSE; --controle quando deve chamar tabela interveniente
  vr_inpessoaI        number:=1; --Tipo de pessoa do interveniente
  
  vr_mostra_veiculos   boolean := false;
  vr_mostra_maqui_equi boolean := false;
  vr_mostra_imoveis    boolean := false;
  vr_retorno_xml       number(1);
  vr_tpctrato_garantia number;
    vr_null              VARCHAR2(200);
  
    vr_nrctremp   NUMBER;
    vr_contas_chq VARCHAR2(1000) := ' '; --para contas avalisadas de cheque
    vr_nmprimtl   VARCHAR2(1000);
    vr_vldivida   VARCHAR2(1000);
    vr_tpdcontr   VARCHAR2(1000);
    vr_qtmesdec   NUMBER;
    vr_qtpreemp   NUMBER;
    vr_qtprecal   NUMBER;
    vr_qtregist   NUMBER;
    vr_axnrcont   VARCHAR2(1000);
    vr_axnrcpfc   VARCHAR2(1000);
  

    --tabela para os avalistas
    vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
    vr_tab_dados_avais_temp dsct0002.typ_tab_dados_avais;
    vr_nrctaav1             crawepr.nrctaav1%type;
    vr_nrctaav2             crawepr.nrctaav2%type;
    vr_clob_ret        CLOB;
    vr_clob_msg        CLOB;
    vr_xmltype         xmlType;
    vr_parser          xmlparser.Parser;
    vr_doc             xmldom.DOMDocument;
  
    -- Root
    vr_node_root xmldom.DOMNodeList;
    vr_item_root xmldom.DOMNode;
    vr_elem_root xmldom.DOMElement;
    -- SubItens
    vr_node_list xmldom.DOMNodeList;
    vr_node_name VARCHAR2(100);
    vr_item_node xmldom.DOMNode;
    vr_elem_node xmldom.DOMElement;
    -- SubItens da AVAL
    vr_node_list_aval xmldom.DOMNodeList;
    vr_node_name_aval VARCHAR2(100);
    vr_item_node_aval xmldom.DOMNode;
    vr_valu_node_aval xmldom.DOMNode;
  
    -- Tabelas
    vr_tab_aval   aval0001.typ_tab_contras;
    vr_rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    cursor c_nrctaav_crawepr(pr_cdcooper crawepr.cdcooper%type
                            ,pr_nrdconta crawepr.nrdconta%type
                            ,pr_nrctremp crawepr.nrctremp%type) is
      select nrctaav1, nrctaav2
        from crawepr
       where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta
         and nrctremp = pr_nrctremp;
  
    /* 4.1 Garantia Pessoal Pessoa Física - com base em b1wgen0075.busca-dados*/
  cursor c_garantia_pessoal_pf (pr_nrdconta crapass.nrdconta%type
                               ,pr_cdcooper crapass.cdcooper%type)is
  select fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta --Número da conta
        ,fn_tag('Tipo de Pessoa','Física') tipopessoa
        ,fn_tag('CPF',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,1)) cpf --CPF
            ,fn_tag('Nome', a.nmprimtl) nome --Nome
        ,fn_tag('Nacionalidade',(select dsnacion from crapnac where cdnacion = a.cdnacion)) dsnacion --nacionalidade
            ,fn_tag('Data de Nascimento', to_char(a.dtnasctl, 'DD/MM/YYYY')) datanasc --Data de Nascimento
        ,fn_tag('Renda',to_char((select vlsalari + vldrendi##1 + vldrendi##2 + vldrendi##3 + vldrendi##4
                                 from crapttl
                                 where nrdconta = a.nrdconta
                                 and idseqttl =1
                                 and cdcooper = a.cdcooper),'999g999g990d00')) renda
        ,fn_tag('CEP',gene0002.fn_mask_cep(d.nrcepend)) cep -- Cep
            ,fn_tag('Rua', d.dsendere) rua -- Rua
            ,fn_tag('Complemento', d.complend) complemento --Complemento
            ,fn_tag('Número', d.nrendere) nr -- Nr. endereço
            ,fn_tag('Cidade', d.nmcidade) cidade -- Cidade
            ,fn_tag('Bairro', d.nmbairro) bairro --Bairo
            ,fn_tag('Estado', d.cdufende) estado --UF
            ,p.idpessoa idPessoa
  from crapass a
      ,crapenc d
      ,tbcadast_pessoa p
  where a.cdcooper = d.cdcooper
  and   a.nrdconta = d.nrdconta
  and   a.nrcpfcgc = p.nrcpfcgc
  and   a.cdcooper = pr_cdcooper
  and   a.nrdconta = pr_nrdconta
  and   a.inpessoa = 1 --Pessoa Física
  and   d.tpendass = 10; --Residencial
    r_garantia_pessoal_pf c_garantia_pessoal_pf%ROWTYPE;
  
    /* Garantia Pessoal Juridica */
    CURSOR c_garantia_juridica(pr_nrdconta crapass.nrdconta%TYPE, pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT fn_tag('Conta', gene0002.fn_mask_conta(a.nrdconta)) conta,
             fn_tag('Tipo de Pessoa', 'Juridica') tipopessoa,
             fn_tag('CNPJ', gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc, 2)) cnpj,
             fn_tag('Razão Social', a.nmprimtl) nome,
             fn_tag('Data de Abertura da Empresa', to_char(j.dtiniatv, 'DD/MM/YYYY')) abertura,
             fn_tag('Faturamento Médio Mensal',
                    (SELECT to_char(round(((jfn.vlrftbru##1 + jfn.vlrftbru##2 + jfn.vlrftbru##3 + jfn.vlrftbru##4 +
                                           jfn.vlrftbru##5 + jfn.vlrftbru##6 + jfn.vlrftbru##7 + jfn.vlrftbru##8 +
                                           jfn.vlrftbru##9 + jfn.vlrftbru##10 + jfn.vlrftbru##11 + jfn.vlrftbru##12)) /
                                           (decode(jfn.vlrftbru##1, 0, 0, 1) + decode(jfn.vlrftbru##2, 0, 0, 1) +
                                           decode(jfn.vlrftbru##3, 0, 0, 1) + decode(jfn.vlrftbru##4, 0, 0, 1) +
                                           decode(jfn.vlrftbru##5, 0, 0, 1) + decode(jfn.vlrftbru##6, 0, 0, 1) +
                                           decode(jfn.vlrftbru##7, 0, 0, 1) + decode(jfn.vlrftbru##8, 0, 0, 1) +
                                           decode(jfn.vlrftbru##9, 0, 0, 1) + decode(jfn.vlrftbru##10, 0, 0, 1) +
                                           decode(jfn.vlrftbru##11, 0, 0, 1) + decode(jfn.vlrftbru##12, 0, 0, 1)), 2),
                                     '999g999g990d00')
                        FROM crapjfn jfn
                       WHERE jfn.cdcooper = pr_cdcooper
                         AND jfn.nrdconta = pr_nrdconta)) fatmedmensal --Soma tudo e divide pelos meses que tem lançamento
            ,
             fn_tag('CEP', gene0002.fn_mask_cep(d.nrcepend)) cep,
             fn_tag('Rua', d.dsendere) rua,
             fn_tag('Complemento', d.complend) complemento,
             fn_tag('Número', d.nrendere) numero,
             fn_tag('Cidade', d.nmcidade) cidade,
             fn_tag('Bairro', d.nmbairro) bairro,
             fn_tag('Estado', d.cdufende) uf
        FROM crapass a, crapjur j, crapenc d
       WHERE a.cdcooper = j.cdcooper
         AND a.nrdconta = j.nrdconta
         AND a.cdcooper = d.cdcooper
         AND a.nrdconta = d.nrdconta
         AND a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
    and   a.inpessoa = 2 --Pessoa Jurídica
    and   d.tpendass = 9;
    r_garantia_juridica c_garantia_juridica%ROWTYPE;
  
    /* Verifica se tem Cônjuge*/
  CURSOR c_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type)  IS
      SELECT c.idpessoa_relacao
        FROM tbcadast_pessoa_relacao c
       WHERE c.idpessoa = pr_idpessoa
      and c.tprelacao = 1; -- 1 = Cônjuge
  
    /* Busca CPF do Cônjuge para verificar se é cooperado*/
  CURSOR c_buscacpf_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type) IS
      SELECT c.nrcpfcgc
        FROM tbcadast_pessoa c
       WHERE c.idpessoa = pr_idpessoa
         AND c.nrcpfcgc <> 0;
  
    -- Cônjuge não cooperado > Titular cooperado
  CURSOR c_consultaconjuge_naocoop(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta Cônjuge',0) conta
         ,fn_tag('CPF Cônjuge',gene0002.fn_mask_cpf_cnpj(nvl(nrcpfcjg,0),1)) cpf
         ,fn_tag('Nome Cônjuge',nmconjug) nome
         ,fn_tag('Rendimento Mensal Cônjuge', to_char(nvl(vlsalari,0), '999g999g990d00')) rendimento
         ,fn_tag('Endividamento Cônjuge',0) endiv
         ,0 ctacje
        FROM crapcje
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND idseqttl = 1;
    r_consultaconjuge_naocoop c_consultaconjuge_naocoop%ROWTYPE;

    -- Cônjuge não cooperado > Titular não cooperado
  CURSOR c_consultacjgtit_naocoop(pr_cdcooper crapcop.cdcooper%TYPE
                                 ,pr_nrdconta crapass.nrdconta%type
                                 ,pr_nrctremp crapepr.nrctremp%type
                                 ,pr_nrcpfcgc crapass.nrcpfcgc%type) IS
   select fn_tag('Conta Cônjuge',0) conta
         ,fn_tag('CPF Cônjuge',gene0002.fn_mask_cpf_cnpj(nvl(nrcpfcjg,0),1)) cpf
         ,fn_tag('Nome Cônjuge',nmconjug) nome
         ,fn_tag('Rendimento Mensal Cônjuge', to_char(nvl(vlrencjg,0), '999g999g990d00')) rendimento
         ,fn_tag('Endividamento Cônjuge',0) endiv
         ,0 ctacje
        FROM crapavt
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp
         and nrcpfcgc = pr_nrcpfcgc;
    r_consultacjgtit_naocoop c_consultacjgtit_naocoop%ROWTYPE;
  
    /* Cônjuge cooperado*/
  CURSOR c_consultaconjuge_coop (pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta Cônjuge',gene0002.fn_mask_conta(t.nrdconta)) conta
         ,fn_tag('CPF Cônjuge',gene0002.fn_mask_cpf_cnpj(t.nrcpfcgc,1)) cpf
         ,fn_tag('Nome Cônjuge',t.nmextttl) nome
         ,fn_tag('Rendimentos Cônjuge',to_char((t.vlsalari + t.vldrendi##1),'999g999g990d00')) rendimentos
         ,fn_tag('Endividamento Cônjuge',to_char((SELECT Nvl(Sum(vlvencto),0)
                               FROM crapvop v
                              WHERE nrcpfcgc = t.nrcpfcgc
                                     AND dtrefere = (SELECT Max(dtrefere)
                                                  FROM crapvop
                                                --WHERE nrcpfcgc = v.nrcpfcgc
                                                     )),'999g999g990d00')) endiv
         ,t.nrdconta nrdcontacjg --sem formatacao para passar para o proximo cursor
   from crapttl t
  where t.cdcooper = pr_cdcooper
    AND t.idseqttl = 1
    AND t.nrdconta = pr_nrdconta;
    r_consultaconjuge_coop c_consultaconjuge_coop%ROWTYPE;
  
    /* */
    CURSOR c_verifica_conjuge_coop(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
    select a.nrdconta
     from crapass a
    where a.cdcooper = pr_cdcooper
    and a.nrcpfcgc = pr_nrcpfcgc
    and rownum<=1;
    r_verifica_conjuge_coop c_verifica_conjuge_coop%ROWTYPE;
  

    /*Cursor para buscar o valor de Capital */
  cursor c_consulta_valor_capital (pr_cdcooper crapcop.cdcooper%TYPE
                               ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT fn_tag('Capital Cônjuge', to_char(nvl(vldcotas, 0), '999g999g990d00'))
        FROM crapcot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
  
    /* Task 16201 - Consulta Alienação Fiduciária (Veículo, Moto, Outros Veículos, Caminhão)*/
  cursor c_busca_alienacao_veiculo (pr_cdcooper crapcop.cdcooper%TYPE
                                      ,pr_nrdconta crapass.nrdconta%TYPE
                                      ,pr_nrctpro  crapbpr.nrctrpro%TYPE) IS
    select dscatbem tipoveiculo
          ,dsmarbem marca
          ,dsbemfin modelo
          ,vlmerbem valormercado
          ,vlfipbem valorfipe
          ,ufdplaca ufplaca
          ,nrdplaca nrplaca
          ,nrrenava renavam
          ,dschassi chassi
          ,DECODE(tpchassi,1,'REMARCADO',2,'NORMAL') tipochassi --BUG 22152
          ,nranobem anofabrica
          ,nrmodbem anomodelo
          ,dscorbem cor
          ,nrcpfbem cpfbem
    from crapbpr
    where cdcooper = pr_cdcooper
    and   nrdconta = pr_nrdconta
    and   nrctrpro = pr_nrctpro
    and   flgalien = 1 -- bem alienado a proposta
    and   dscatbem in ('AUTOMOVEL','CAMINHAO','MOTO','OUTROS VEICULOS');
    r_busca_alienacao_veiculo c_busca_alienacao_veiculo%rowtype;
  
    /* 16369 - Consultar Alienação Fiduciaria (Máquina e Equipamento) */
  cursor c_busca_alienacao_maq_equip (pr_cdcooper crapcop.cdcooper%TYPE
                                     ,pr_nrdconta crapass.nrdconta%TYPE
                                     ,pr_nrctpro  crapbpr.nrctrpro%TYPE) IS
    select dscatbem categoria
          ,upper(dsmarceq) descricao
          ,dsmarbem marca
          ,dsbemfin modelo
          ,nrnotanf nota
          ,dschassi nrserie
          ,nrmodbem anomodelo
          ,vlmerbem valormercado
          ,nrcpfbem cpfbem
    from crapbpr
    where cdcooper = pr_cdcooper
    and   nrdconta = pr_nrdconta
    and   nrctrpro = pr_nrctrato
    and   flgalien = 1 -- bem alienado a proposta
    and   dscatbem = 'MAQUINA E EQUIPAMENTO';
    r_busca_alienacao_maq_equip c_busca_alienacao_maq_equip%rowtype;
  
    /* Task 16370 - Consultar Alienação Fiduciaria (Imoveis) */
  cursor c_busca_alienacao_imoveis (pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_nrdconta crapass.nrdconta%TYPE
                                   ,pr_nrctpro  crapbpr.nrctrpro%TYPE) IS
    select dsclassi classificacao
          ,dscatbem categoria
          ,vlmerbem valormercado
          ,vlrdobem valorvenda
          ,dsbemfin descricao
          ,vlareuti areautil
          ,vlaretot areatotal
          ,nrmatric matricula
          ,nrcepend cep
          ,dsendere rua
          ,dscompend complemento
          ,nrendere nr
          ,nmcidade cidade
          ,nmbairro bairro
          ,cdufende estado
    from crapbpr
    where cdcooper = pr_cdcooper
    and   nrdconta = pr_nrdconta
    and   nrctrpro = pr_nrctpro
    and   flgalien = 1 -- bem alienado a proposta
    and   dscatbem in ('CASA','GALPAO','APARTAMENTO','TERRENO');
    r_busca_alienacao_imoveis c_busca_alienacao_imoveis%rowtype;
  
    /*Interveniente Anuente PJ*/
  cursor c_consulta_interv_anuente (pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
SELECT CASE WHEN LENGTH(v.nrcpfcgc) > 11 then 'JURÍDICA' else 'FÍSICA' END inpessoa
          ,CASE WHEN LENGTH(v.nrcpfcgc) > 11 then 2 else 1 END inpessoaInterv
      ,v.nrcpfcgc cpf
          ,v.nmdavali nome
          ,(SELECT dsnacion FROM crapnac WHERE cdnacion = v.cdnacion) nacionalidade
          ,v.dtnascto nascimento_nao_coop
          ,gene0002.fn_mask_cep(v.nrcepend) CEP
          ,v.dsendres##1 rua
          ,decode(v.complend,null,'-',v.complend) complemento
          ,v.nrendere nr
          ,v.nmcidade cidade
          ,v.dsendres##2 bairro
          ,v.cdufresd estado
      ,v.nrcpfcjg cpfcong
          ,v.nmconjug nomecong
        FROM crapavt v
       WHERE v.cdcooper = pr_cdcooper
         AND v.nrdconta = pr_nrdconta
         AND v.nrctremp = pr_nrctrato
         AND v.tpctrato = 9; --Interveniente
  
    /*Busca dados da conta para a tabela de Intervenientes*/
  CURSOR c_busca_dados_conta (pr_cdcooper crapass.cdcooper%TYPE
                             ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
   SELECT a.nrdconta
         ,a.dtnasctl
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrcpfcgc = pr_nrcpfcgc
         AND a.dtdemiss IS NULL;
    r_busca_dados_conta c_busca_dados_conta%ROWTYPE;
  
    /*Busca número da conta do conjuge*/
  CURSOR c_busca_conta_conjuge (pr_cdcooper crapass.cdcooper%TYPE
                               ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT a.nrdconta
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrcpfcgc = pr_nrcpfcgc
         AND a.dtdemiss IS NULL;
  
    /* Task 16176 - Retornar contas que o avalista assina (Co-responsabilidade)*/
  cursor c_contas_avalisadas (pr_cdcooper crapass.cdcooper%TYPE
                             ,pr_nrdconta crapass.nrdconta%TYPE) IS
    select v.nrctravd
          ,v.nrctaavd
          ,nmprimtl
     from crapavl v,
          crapass a
    where v.cdcooper = a.cdcooper
    and   v.nrdconta = a.nrdconta
    and   v.cdcooper = pr_cdcooper
    and   v.nrdconta = pr_nrdconta;
  
  cursor c_dados_aval_nao_coop(pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                               pr_tpctrato in crapavt.tpctrato%type)  is
  select decode(anc.inpessoa,1,'Física',2,'Jurídica','-') inpessoa,
             gene0002.fn_mask_cpf_cnpj(nvl(anc.nrcpfcgc,0),anc.inpessoa) nrcpfcgc,
             anc.nmdavali,
             n.dsnacion dsnatura,
             anc.dtnascto,
             anc.vlrenmes,
             anc.nrcepend,
             anc.dsendres##1,
             anc.complend,
             anc.nrendere,
             anc.nmcidade,
             anc.dsendres##2, -- Bairro
             anc.cdufresd,
             anc.tpctrato,
             p.idpessoa
    from crapavt anc,
         crapnac n,
         tbcadast_pessoa p
   where anc.cdcooper = pr_cdcooper
     and anc.nrdconta = pr_nrdconta
     and anc.nrctremp = pr_nrctrato
     and anc.nrcpfcgc = pr_nrcpfcgc
     and anc.nrcpfcgc = p.nrcpfcgc
     and anc.cdnacion = n.cdnacion(+)
     and anc.tpctrato = pr_tpctrato; -- Avalista não cooperado  
    --
  r_dados_aval_nao_coop c_dados_aval_nao_coop%rowtype;     
  
    FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode) RETURN VARCHAR2 IS
    BEGIN
      RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
    END fn_getValue;
  
    /* Busca saldos depositos mes atual, semestre e trimestre */
  PROCEDURE pc_consulta_saldo_medio (pr_cdcooper        IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta        IN crapass.nrdconta%TYPE
                                    ,pr_saldo_mes       IN OUT NUMBER
                                    ,pr_saldo_trimestre IN OUT NUMBER
                                    ,pr_saldo_semestre  IN OUT NUMBER) IS
    
      vr_saldo_mes       NUMBER;
      vr_saldo_trimestre NUMBER;
      vr_saldo_semestre  NUMBER;
      vr_nrmes           NUMBER;
    
      /* Loop do periodo do mes, do dia 1 ate a data do movimento anterior. Não considerar sábados domingos e feriados
      Somatório dos valores dividido pelo número de dias uteis */
    CURSOR c_busca_saldomes_atual (pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%TYPE
                                  ,pr_dtmvtolt DATE
                                  ,pr_dtmvtoan DATE) IS
      
      SELECT Round(Sum(s.VLSDDISP) / Count(1) ,2)
      FROM crapsda s
          ,crapfer f
         WHERE s.cdcooper = f.cdcooper
           AND f.dtferiad BETWEEN Trunc(pr_dtmvtolt, 'MM') AND pr_dtmvtoan
           AND s.cdcooper = pr_cdcooper
           AND s.nrdconta = pr_nrdconta
           AND s.dtmvtolt <> f.dtferiad
           AND s.dtmvtolt BETWEEN Trunc(pr_dtmvtolt, 'MM') AND pr_dtmvtoan
           AND To_Char(dtmvtolt, 'D') NOT IN (1, 7);
    
    BEGIN
    
      /* Salva numero do mes JAN=1, FEV=2, ...*/
      vr_nrmes := To_Char(rw_crapdat.dtmvtolt, 'MM');
    
      /*Busca saldo mes atual*/
    OPEN c_busca_saldomes_atual(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_dtmvtoan => rw_crapdat.dtmvtoan);
     FETCH c_busca_saldomes_atual INTO vr_saldo_mes;
      IF c_busca_saldomes_atual%NOTFOUND THEN
        NULL;
        /* Raise erro */
      END IF;
      CLOSE c_busca_saldomes_atual;
    
      /* Busca saldo do trimestre de acordo com o mes da cooperativa */
      BEGIN
      
        IF (vr_nrmes IN (1, 7)) THEN
          BEGIN
          
            SELECT Round((vlsmstre##4 + vlsmstre##5 + vlsmstre##6) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
        ELSIF (vr_nrmes IN (2, 8)) THEN
          BEGIN
          
            SELECT Round((vlsmstre##1 + vlsmstre##6 + vlsmstre##5) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
        ELSIF (vr_nrmes IN (3, 9)) THEN
          BEGIN
          
            SELECT Round((vlsmstre##2 + vlsmstre##1 + vlsmstre##6) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
        ELSIF (vr_nrmes IN (4, 10)) THEN
          BEGIN
          
            SELECT Round((vlsmstre##3 + vlsmstre##2 + vlsmstre##1) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
        ELSIF (vr_nrmes IN (5, 11)) THEN
          BEGIN
          
            SELECT Round((vlsmstre##4 + vlsmstre##3 + vlsmstre##2) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
      ELSE /* 6 ou 12*/
          BEGIN
          
            SELECT Round((vlsmstre##5 + vlsmstre##4 + vlsmstre##3) / 3, 2)
              INTO vr_saldo_trimestre
              FROM crapsld
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta;
          END;
        
        END IF;
      END;
    
      /* Busca saldo semestre */
      BEGIN
        SELECT Round((vlsmstre##1 + vlsmstre##2 + vlsmstre##3 + vlsmstre##4 + vlsmstre##5 + vlsmstre##6) / 6, 2)
          INTO vr_saldo_semestre
          FROM crapsld
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      END;
    
      --Retornos
      pr_saldo_mes       := vr_saldo_mes;
      pr_saldo_trimestre := vr_saldo_trimestre;
      pr_saldo_semestre  := vr_saldo_semestre;
    
    EXCEPTION
    WHEN Others THEN
        NULL;
    END pc_consulta_saldo_medio;
  

    /* Inicio do programa principal */
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    /*Cabecalho da garantia da garantia */
  vr_string_cabec := vr_string_cabec||'<categoria>'||
                          '<tituloTela>Garantia</tituloTela>'||
                          '<tituloFiltro>garantia</tituloFiltro>'||
                          '<subcategorias>';
  
    /*Identifica qual produto está rodando para identificar os avalistas*/
  if (pr_tpproduto = c_limite_desc_titulo) then
      vr_tpctrato_garantia := 8;
  elsif (pr_tpproduto = c_desconto_cheque) then
      vr_tpctrato_garantia := 2;
  elsif (pr_tpproduto = c_cartao) then  
      vr_tpctrato_garantia := 4;
  elsif (pr_tpproduto = c_emprestimo) then  
      vr_tpctrato_garantia := 1;
  end if;

  
    /*Verifica se o contrato possui avalistas*/
    DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                               ,pr_cdagenci => 0  --> Código da agencia
                               ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                               ,pr_cdoperad => 1  --> Código do Operador
                               ,pr_nmdatela => 'TELA_UNICA'  --> Nome da tela
                               ,pr_idorigem => 5  --> Identificador de Origem
                               ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                               ,pr_idseqttl => 1  --> Sequencial do titular
                               ,pr_tpctrato => vr_tpctrato_garantia --> tipo do contrato da garantia
                               ,pr_nrctrato => pr_nrctrato  --> Numero do contrato
                               ,pr_nrctaav1 => 0  --> Numero da conta do primeiro avalista
                               ,pr_nrctaav2 => 0  --> Numero da conta do segundo avalista
                                --------> OUT <--------                                   
                               ,pr_tab_dados_avais   => vr_tab_dados_avais   --> retorna dados do avalista
                               ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                               , pr_dscritic => vr_dscritic); --> Descrição da crítica
                               
                                 
  
    /*Se tiver avalistas*/
    IF vr_tab_dados_avais.count > 0 THEN
      if vr_tab_dados_avais.count = 2 then
        begin
          open c_nrctaav_crawepr(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => pr_nrctrato);
          fetch c_nrctaav_crawepr into vr_nrctaav1, vr_nrctaav2;
          if c_nrctaav_crawepr%found then
            if (vr_nrctaav1 <> vr_tab_dados_avais(1).nrctaava) and
               (vr_nrctaav2 <> vr_tab_dados_avais(2).nrctaava) then
              vr_tab_dados_avais_temp := vr_tab_dados_avais;
              vr_tab_dados_avais(1) := vr_tab_dados_avais_temp(2);
              vr_tab_dados_avais(2) := vr_tab_dados_avais_temp(1);
            end if;
          end if;
          close c_nrctaav_crawepr;
        exception
          when others then
            null;
        end;
      end if;
    
      /* Separa a garantia pessoal pois não é obrigatória */
      vr_string_garantia_pessoal := vr_string_garantia_pessoal || '<subcategoria>' ||
                                    '<tituloTela>Garantia Pessoal</tituloTela><campos>';
      LOOP
      
    vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
    '<campo><nome>AVALISTA '||vr_index_aval||'</nome><tipo>info</tipo><valor>'||
    fn_nao_cooperado(vr_tab_dados_avais(vr_index_aval).nrctaava)||'</valor></campo>';
      
        /* 4.1 Garantia Avalista Pessoa Física */
    if (vr_tab_dados_avais(vr_index_aval).inpessoa = 1) then
        
    open c_garantia_pessoal_pf(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
     fetch c_garantia_pessoal_pf into r_garantia_pessoal_pf;
        if c_garantia_pessoal_pf%found then
            /*Gera Tags Xml*/
        vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                       r_garantia_pessoal_pf.conta||
                       r_garantia_pessoal_pf.tipopessoa||
                       r_garantia_pessoal_pf.cpf||
                       r_garantia_pessoal_pf.nome||
                       r_garantia_pessoal_pf.dsnacion||
                       r_garantia_pessoal_pf.datanasc||
                       r_garantia_pessoal_pf.renda||
                       r_garantia_pessoal_pf.cep||
                       r_garantia_pessoal_pf.rua||
                       r_garantia_pessoal_pf.complemento||
                       r_garantia_pessoal_pf.nr||
                       r_garantia_pessoal_pf.cidade||
                       r_garantia_pessoal_pf.bairro||
                                          r_garantia_pessoal_pf.estado; --Este block não fecha com </campos> pois ainda faltam os dados do CJG
          
            /*Salva o ID da pessoa para verificar estado civil no proximo passo*/
            vr_idpessoa := r_garantia_pessoal_pf.idpessoa;
      elsif vr_tab_dados_avais(vr_index_aval).nrctaava = 0 then -- Neste caso Avalista não é cooperado
        Open c_dados_aval_nao_coop(vr_tab_dados_avais(vr_index_aval).nrcpfcgc,vr_tpctrato_garantia);
         fetch c_dados_aval_nao_coop into r_dados_aval_nao_coop;
          if c_dados_aval_nao_coop%found then
              vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                            fn_tag('Tipo de Pessoa', r_dados_aval_nao_coop.inpessoa) ||
                                            fn_tag('CPF', r_dados_aval_nao_coop.nrcpfcgc) ||
                                            fn_tag('Nome', r_dados_aval_nao_coop.nmdavali) ||
                                            fn_tag('Nacionalidade', r_dados_aval_nao_coop.dsnatura) ||
                                            fn_tag('Data de Nascimento', r_dados_aval_nao_coop.dtnascto) ||
                                            fn_tag('Renda', to_char(r_dados_aval_nao_coop.vlrenmes, '999g999g990d00')) ||
                                            fn_tag('CEP', r_dados_aval_nao_coop.nrcepend) ||
                                            fn_tag('Rua', r_dados_aval_nao_coop.dsendres##1) ||
                                            fn_tag('Complemento', r_dados_aval_nao_coop.complend) ||
                                            fn_tag('Número', r_dados_aval_nao_coop.nrendere) ||
                                            fn_tag('Cidade', r_dados_aval_nao_coop.nmcidade) ||
                                            fn_tag('Bairro', r_dados_aval_nao_coop.dsendres##2) || -- Bairro
                                            fn_tag('Estado', r_dados_aval_nao_coop.cdufresd);
            vr_idpessoa := r_dados_aval_nao_coop.idpessoa;
          end if;
        close c_dados_aval_nao_coop;
      end if;
    close c_garantia_pessoal_pf;
        
          /* Fim Garantia Pessoal*/
        
          /* Se tiver Cônjuge busca idPessoaConjuge */
    open c_conjuge(vr_idpessoa);
     fetch c_conjuge into vr_idpessoa_conjuge;
      if c_conjuge%found then
                    
            /* Possui cônjuge, busca CPF*/
        open c_buscacpf_conjuge (vr_idpessoa_conjuge);
         fetch c_buscacpf_conjuge into vr_cpfconjuge;
          if c_buscacpf_conjuge%found then
            
              /* Verifica se é cooperado através do CPF - consulta crapass*/
            open c_verifica_conjuge_coop(pr_cdcooper => pr_cdcooper
                                        ,pr_nrcpfcgc => vr_cpfconjuge);
             fetch c_verifica_conjuge_coop into r_verifica_conjuge_coop;
              if c_verifica_conjuge_coop%notfound then

                -- Cônjuge não é cooperado > Titular cooperado
                if vr_tab_dados_avais(vr_index_aval).nrctaava > 0 then
                  OPEN c_consultaconjuge_naocoop (pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
                  FETCH c_consultaconjuge_naocoop INTO r_consultaconjuge_naocoop;
                  IF c_consultaconjuge_naocoop%FOUND THEN
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                                  '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor>'||fn_nao_cooperado(r_consultaconjuge_naocoop.ctacje)||'</valor></campo>';
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                                 r_consultaconjuge_naocoop.conta||
                                 r_consultaconjuge_naocoop.cpf||
                                 r_consultaconjuge_naocoop.nome||
                                 r_consultaconjuge_naocoop.rendimento ||
                                 r_consultaconjuge_naocoop.endiv;
                  END IF;
                  CLOSE c_consultaconjuge_naocoop;
                else -- Cônjuge não é cooperado > Titular não é cooperado
                  OPEN c_consultacjgtit_naocoop(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctremp => pr_nrctrato
                                               ,pr_nrcpfcgc => vr_tab_dados_avais(vr_index_aval).nrcpfcgc);
                  FETCH c_consultacjgtit_naocoop INTO r_consultacjgtit_naocoop;
                  IF c_consultacjgtit_naocoop%FOUND THEN
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                                  '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor>'||fn_nao_cooperado(r_consultacjgtit_naocoop.ctacje)||'</valor></campo>';
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                                                  r_consultacjgtit_naocoop.conta||
                                                  r_consultacjgtit_naocoop.cpf||
                                                  r_consultacjgtit_naocoop.nome||
                                                  r_consultacjgtit_naocoop.rendimento ||
                                                  r_consultacjgtit_naocoop.endiv;
                  END IF;
                  CLOSE c_consultacjgtit_naocoop;
                end if;
              
              else
                /* Cônjuge é cooperado*/
                OPEN c_consultaconjuge_coop (pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => r_verifica_conjuge_coop.nrdconta);--vr_tab_dados_avais(vr_index_aval).nrctaava);
                FETCH c_consultaconjuge_coop INTO r_consultaconjuge_coop;
                IF c_consultaconjuge_coop%FOUND THEN
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                                '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor>'||fn_nao_cooperado(r_consultaconjuge_coop.nrdcontacjg)||'</valor></campo>';
                  /* Dados do Cônjuge cooperado*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                               r_consultaconjuge_coop.conta||
                               r_consultaconjuge_coop.cpf||
                               r_consultaconjuge_coop.nome||
                               r_consultaconjuge_coop.rendimentos||
                               r_consultaconjuge_coop.endiv;
                
                  --Salva conta do Cônjuge para buscar capital
                  vr_nrdcontacjg := r_consultaconjuge_coop.nrdcontacjg;
                
                END IF;
              
                /* Busca Cotas Capital*/
                OPEN c_consulta_valor_capital(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_nrdcontacjg);
                 FETCH c_consulta_valor_capital into vr_vldcotas;
                IF c_consulta_valor_capital%NOTFOUND THEN
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal || fn_tag('Capital Cônjuge', '-');
                ELSE
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal || vr_vldcotas;
                END IF;
                close c_consulta_valor_capital;
              
                /* Consulta Saldos Médios (Mensal, Trimestral e Semestral) */
                pc_consulta_saldo_medio(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => vr_nrdcontacjg
                                       ,pr_saldo_mes => vr_saldo_mes
                                       ,pr_saldo_trimestre => vr_saldo_trimestre
                                       ,pr_saldo_semestre => vr_saldo_semestre);
                /*Cria XML Mes Atual*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo Médio Mes atual Cônjuge',to_char(vr_saldo_mes,'999g999g990d00'));
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo Médio Trimestral Cônjuge',to_char(vr_saldo_trimestre,'999g999g990d00'));
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal
                                             ||fn_tag('Saldo Médio Semestral Cônjuge',
                                                             case when vr_saldo_semestre > 0 then to_char(vr_saldo_semestre,'999g999g990d00') else '-' end);
              
                /* Carrega o valor das aplicações PF e PJ */
                pc_busca_dados_atenda(pr_cdcooper => vr_cdcooper_principal,
                                      pr_nrdconta => vr_nrdcontacjg);
                
              
                /*Aplicações*/
                vr_string_garantia_pessoal:=vr_string_garantia_pessoal||fn_tag('Aplicacoes Cônjuge',to_char(vr_tab_valores_conta(1).vlsldapl,'999g999g990d00'));
              
                /*Poupança programada*/
                 vr_string_garantia_pessoal:=vr_string_garantia_pessoal||fn_tag('Poupança Programada',to_char(vr_tab_valores_conta(1).vlsldppr,'999g999g990d00'));
              
                /* Co-responsabilidade */
                vr_string_garantia_pessoal := vr_string_garantia_pessoal||'<campo>
                                         <nome>Co-responsabilidade</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
                vr_index                   := 0;
                vr_tab_tabela.delete;
              
                aval0001.pc_busca_dados_contratos_car(pr_cdcooper => pr_cdcooper
                                                     ,pr_cdagenci => NULL
                                                     ,pr_nrdcaixa => NULL
                                                     ,pr_idorigem => 5
                                                     ,pr_dtmvtolt => NULL
                                                     ,pr_nmdatela => 'ATENDA'
                                                     ,pr_cdoperad => NULL
                                                     ,pr_nrdconta => vr_nrdcontacjg
                                                     ,pr_nrcpfcgc => NULL
                                                     ,pr_inproces => NULL
                                                     ,pr_nmprimtl => vr_null
                                                     ,pr_axnrcont => vr_null
                                                     ,pr_axnrcpfc => vr_null
                                                     ,pr_nmdcampo => vr_null
                                                     ,pr_des_erro => vr_null
                                                     ,pr_clob_ret => vr_clob_ret
                                                     ,pr_clob_msg => vr_clob_msg
                                                     ,pr_cdcritic => pr_cdcritic
                                                     ,pr_dscritic => pr_dscritic);
              
                -- Buscar informações do XML retornado
                -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
                vr_tab_tabela.delete;
                IF vr_clob_ret IS NOT NULL THEN
                  vr_xmltype := XMLType.createXML(vr_clob_ret);
                  vr_parser  := xmlparser.newParser;
                  xmlparser.parseClob(vr_parser, vr_xmltype.getClobVal());
                  vr_doc := xmlparser.getDocument(vr_parser);
                  xmlparser.freeParser(vr_parser);
                  --
                  -- Buscar nodo AVAL
                  vr_node_root := xmldom.getElementsByTagName(vr_doc, 'root');
                  vr_item_root := xmldom.item(vr_node_root, 0);
                  vr_elem_root := xmldom.makeElement(vr_item_root);
                  --
                  -- Faz o get de toda a lista ROOT
                  vr_node_list := xmldom.getChildrenByTagName(vr_elem_root, '*');
                  --
                  vr_index := 0;
                  vr_tab_aval.DELETE;
                  --
                  -- Percorrer os elementos
                  FOR i IN 0 .. xmldom.getLength(vr_node_list) - 1 LOOP
                    -- Buscar o item atual
                    vr_item_node := xmldom.item(vr_node_list, i);
                    -- Captura o nome e tipo do nodo
                    vr_node_name := xmldom.getNodeName(vr_item_node);
                    --
                    -- Sair se o nodo não for elemento
                    IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
                      CONTINUE;
                    END IF;
                    --
                    -- Tratar leitura dos dados do SEGCAB (Header)
                    IF vr_node_name = 'aval' THEN
                      -- Buscar todos os filhos deste nó
                      vr_elem_node := xmldom.makeElement(vr_item_node);
                      -- Faz o get de toda a lista de folhas da SEGCAB
                      vr_node_list_aval := xmldom.getChildrenByTagName(vr_elem_node, '*');
                      --
                      vr_nrdconta := NULL;
                      --
                      -- Percorrer os elementos
                      FOR i IN 0 .. xmldom.getLength(vr_node_list_aval) - 1 LOOP
                        -- Buscar o item atual
                        vr_item_node_aval := xmldom.item(vr_node_list_aval, i);
                        -- Captura o nome e tipo do nodo
                        vr_node_name_aval := xmldom.getNodeName(vr_item_node_aval);
                        -- Sair se o nodo não for elemento
                        IF xmldom.getNodeType(vr_item_node_aval) <> xmldom.ELEMENT_NODE THEN
                          CONTINUE;
                        END IF;
                        IF vr_node_name_aval = 'nrctremp' THEN
                          -- Buscar valor da TAG
                          vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                          vr_nrctremp       := fn_getValue(vr_valu_node_aval);
                        END IF;
                        IF vr_node_name_aval = 'nrdconta' THEN
                          -- Buscar valor da TAG
                          vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                          vr_nrdconta       := fn_getValue(vr_valu_node_aval);
                        END IF;
                        IF vr_node_name_aval = 'nmprimtl' THEN
                          vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                          vr_nmprimtl       := fn_getValue(vr_valu_node_aval);
                        END IF;
                        IF vr_node_name_aval = 'vldivida' THEN
                          vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                          vr_vldivida       := fn_getValue(vr_valu_node_aval);
                        END IF;
                        IF vr_node_name_aval = 'tpdcontr' THEN
                          vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                          vr_tpdcontr       := fn_getValue(vr_valu_node_aval);
                        END IF;
                      END LOOP;
                      --
                      IF vr_nrdconta IS NOT NULL THEN
                        vr_index := vr_index + 1;
                        --
                        vr_tab_aval(vr_index).nrdconta := vr_nrdconta;
                        vr_tab_aval(vr_index).nrctremp := vr_nrctremp;
                        vr_tab_aval(vr_index).tpdcontr := vr_tpdcontr;
                        vr_tab_aval(vr_index).nmprimtl := vr_nmprimtl;
                        vr_tab_aval(vr_index).vldivida := vr_vldivida;
                      END IF;
                    END IF;
                  END LOOP;
                END IF;
                -- FIM - Buscar informações do XML retornado
                --
              
                FOR R1 IN 1 .. vr_index LOOP
                  vr_tab_tabela(r1).coluna1 := gene0002.fn_mask_contrato(vr_tab_aval(r1).nrctremp);
                  vr_tab_tabela(r1).coluna2 := gene0002.fn_mask_conta(vr_tab_aval(r1).nrdconta);
                  vr_tab_tabela(r1).coluna3 := vr_tab_aval(r1).nmprimtl;
                END LOOP;
              


                if vr_tab_tabela.COUNT > 0 then
                  /*Gera Tags Xml*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag_table('Contrato;Conta;Nome',vr_tab_tabela);
                else
                  vr_tab_tabela(1).coluna1 := '-';
                  vr_tab_tabela(1).coluna2 := '-';
                  vr_tab_tabela(1).coluna3 := '-';
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag_table('Contrato;Conta;Nome',vr_tab_tabela);
                end if;
              
                 vr_string_garantia_pessoal := vr_string_garantia_pessoal||'</linhas>
                                          </valor>
                                          </campo>';
              
                CLOSE c_consultaconjuge_coop;
            end if;
            close c_verifica_conjuge_coop;
          else
              /* Busca só o nome pois não encontrou pelo CPF */
            OPEN c_consultaconjuge_naocoop (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
            FETCH c_consultaconjuge_naocoop INTO r_consultaconjuge_naocoop;
              IF c_consultaconjuge_naocoop%FOUND THEN
              vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                            '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor>'||fn_nao_cooperado(r_consultaconjuge_naocoop.ctacje)||'</valor></campo>';
                /* Gera Tags Xml Dados do Cônjuge não cooperado */
              vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                           r_consultaconjuge_naocoop.conta||
                           r_consultaconjuge_naocoop.cpf||
                           r_consultaconjuge_naocoop.nome||
                           r_consultaconjuge_naocoop.rendimento||
                           r_consultaconjuge_naocoop.endiv;
              END IF;
              CLOSE c_consultaconjuge_naocoop;
          end if;
        close c_buscacpf_conjuge;
      end if; /* End if --> verifica se tem Cônjuge*/
    close c_conjuge;
        
  else
          /* 4.1a Garantia Pessoa Pessoa Jurídica */
    open c_garantia_juridica(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
     fetch c_garantia_juridica into r_garantia_juridica;
        if c_garantia_juridica%FOUND then
            /*Gera Tags Xml*/
          vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                     r_garantia_juridica.conta||
                     r_garantia_juridica.tipopessoa||
                     r_garantia_juridica.cnpj||
                     r_garantia_juridica.nome||
                     r_garantia_juridica.abertura||
                     r_garantia_juridica.fatmedmensal||
                     r_garantia_juridica.cep||
                     r_garantia_juridica.rua||
                     r_garantia_juridica.complemento||
                     r_garantia_juridica.numero||
                     r_garantia_juridica.cidade||
                     r_garantia_juridica.bairro||
                     r_garantia_juridica.uf;
      else
        Open c_dados_aval_nao_coop(vr_tab_dados_avais(vr_index_aval).nrcpfcgc,vr_tpctrato_garantia);
         fetch c_dados_aval_nao_coop into r_dados_aval_nao_coop;
          if c_dados_aval_nao_coop%found then
              vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
                                            fn_tag('Tipo de Pessoa', r_dados_aval_nao_coop.inpessoa) ||
                                            fn_tag('CPF', r_dados_aval_nao_coop.nrcpfcgc) ||
                                            fn_tag('Nome', r_dados_aval_nao_coop.nmdavali) ||
                                           --fn_tag('Nacionalidade',r_dados_aval_nao_coop.dsnatura)||
                                            fn_tag('Data de Nascimento', r_dados_aval_nao_coop.dtnascto) ||
                                           fn_tag('Faturamento',to_char(r_dados_aval_nao_coop.vlrenmes,'999g999g990d00'))||
                                            fn_tag('CEP', r_dados_aval_nao_coop.nrcepend) ||
                                            fn_tag('Rua', r_dados_aval_nao_coop.dsendres##1) ||
                                            fn_tag('Complemento', r_dados_aval_nao_coop.complend) ||
                                            fn_tag('Número', r_dados_aval_nao_coop.nrendere) ||
                                            fn_tag('Cidade', r_dados_aval_nao_coop.nmcidade) ||
                                            fn_tag('Bairro', r_dados_aval_nao_coop.dsendres##2) || -- Bairro
                                            fn_tag('Estado', r_dados_aval_nao_coop.cdufresd);
          end if;
        close c_dados_aval_nao_coop;                       
      end if;
    close c_garantia_juridica;
        
        END IF; --end if inpessoa=1
      
        IF vr_tab_dados_avais.count > 1 AND vr_index_aval < 2 THEN
          vr_index_aval := vr_index_aval + 1;
        ELSE
          EXIT;
        END IF;
      
      END LOOP;
    END IF;
  
  if vr_tab_dados_avais.count > 0 then
      vr_string_garantia_pessoal := vr_string_garantia_pessoal || '</campos></subcategoria>';
  end if;
  
    /* 4.2 - Aplicações - Task 16173 */
  
  pc_consulta_garantia_operacao(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctrato
                               ,pr_tpproduto => pr_tpproduto
                               ,pr_chamador => 'P'
                               ,pr_retorno   => vr_retorno_xml
                               ,pr_retxml   => pr_retxml);
  
    vr_permingr := 0;
    vr_vlgarnec := 0;
    vr_inaplpro := 0;
    vr_vlaplpro := 0;
    vr_inpoupro := 0;
    vr_vlpoupro := 0;
    vr_inresaut := 0;
    vr_nrctater := 0;
    vr_inaplter := 0;
    vr_inpouter := 0;
  
    /* Extrai dados do XML */
  if vr_retorno_xml = 1 then
      BEGIN
        vr_permingr := pr_retxml.extract('//Dados/permingr/node()').getstringval(); --Garantia Sugerida %
        vr_vlgarnec := pr_retxml.extract('//Dados/vlgarnec/node()').getstringval(); --Garantia Sugerida Valor
        --
        vr_inaplpro := pr_retxml.extract('//Dados/inaplpro/node()').getstringval(); --Flag Aplicação
        vr_vlaplpro := pr_retxml.extract('//Dados/vlaplpro/node()').getstringval(); --Saldo Aplicação
        vr_inpoupro := pr_retxml.extract('//Dados/inpoupro/node()').getstringval(); --Flag Poupança Programada
        vr_vlpoupro := pr_retxml.extract('//Dados/vlpoupro/node()').getstringval(); --Saldo Poupança Programada
        vr_inresaut := pr_retxml.extract('//Dados/inresaut/node()').getstringval(); --Resgate Automatico
      
        vr_nrctater := pr_retxml.extract('//Dados/nrctater/node()').getstringval();
        vr_inaplter := pr_retxml.extract('//Dados/inaplter/node()').getstringval();
        vr_inpouter := pr_retxml.extract('//Dados/inpouter/node()').getstringval();
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
          pr_cdcritic := 0;
          pr_dscritic := 'Erro ao consultar Garantia da proposta.';
      END;
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 or vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Garantia Aplicação</tituloTela>'||
                          '<campos>';
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 then
      vr_string := vr_string || '<campo>
                             <tipo>h3</tipo>
                             <valor>Operação</valor>
                            </campo>';
    
  
      vr_string := vr_string || fn_tag('Garantia Sugerida',
                            case when vr_permingr > 0 then trim(to_char(vr_permingr,'990d99')) || '%' else '-' end);
      vr_string := vr_string || fn_tag('Garantia Sugerida Valor',
                            case when vr_vlgarnec not like '0' then vr_vlgarnec else '-' end);
  end if;                          
  if vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then                      
      vr_string := vr_string || '<campo>
                               <tipo>h3</tipo>
                               <valor>Aplicação Própria</valor>
                              </campo>';
  end if;                                                   
    --
  if vr_inaplpro = 1 then
    vr_string := vr_string || fn_tag('Aplicação', case when vr_inaplpro = 0 Then '-' Else 'Sim' end);
      vr_string := vr_string || fn_tag('Saldo Disponível Aplicação',
                              case when vr_vlaplpro not like '0%' then vr_vlaplpro else '-' end);
  end if;              
  
  if vr_inpoupro = 1 then              
    vr_string := vr_string || fn_tag('Poupança Programada',case when vr_inpoupro =0 Then '-' Else 'Sim' end);
      vr_string := vr_string || fn_tag('Saldo Disponível Poupança',
                              case when vr_vlpoupro not like '0%' then vr_vlpoupro else '-' end);
  end if;
  
  if vr_inaplpro = 1 or  vr_inpoupro = 1 then    
    vr_string := vr_string || fn_tag('Resgate Automático',case when vr_inresaut =0 Then 'Não' Else 'Sim' end);                              
  end if;
  
    --
  if vr_inaplter = 1 then  
      vr_string := vr_string || '<campo>
                             <tipo>h3</tipo>
                             <valor>Aplicação de Terceiro</valor>
                            </campo>';
    
      --Terceiro
      vr_string := vr_string || fn_tag('Conta Terceiro', gene0002.fn_mask_conta(vr_nrctater));
    
  vr_string := vr_string || fn_tag('Aplicação',case when vr_inaplter =0 Then '-' Else 'Sim' end);
  end if;
  if vr_inpouter = 1 then
  vr_string := vr_string || fn_tag('Poupança Programada',case when vr_inpouter =0 Then '-' Else 'Sim' end);
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 or vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then
      --Fim
      vr_string := vr_String || '</campos></subcategoria>';
  end if;
  
    /*Bug 19842 - Regra para apresentar garantia pessoal apenas quando necessário*/
  if (length(vr_string_garantia_pessoal) > 0) then
      vr_string := vr_string_cabec || vr_string || vr_string_garantia_pessoal;
  else
      vr_string := vr_string_cabec || vr_string;
  end if;
  
    /* Fim do 4.2 - Aplicações*/
    /* 4.3 GARANTIA REAL */
  
  
    /*Validar se deve mostrar ou não as tabelas de alienação*/
  open c_busca_alienacao_veiculo(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctpro  => pr_nrctrato);
  fetch c_busca_alienacao_veiculo into r_busca_alienacao_veiculo;
  if c_busca_alienacao_veiculo%found then
    vr_mostra_veiculos := true;
  end if;
  close c_busca_alienacao_veiculo;
    --
  open c_busca_alienacao_maq_equip(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctpro  => pr_nrctrato);
  fetch c_busca_alienacao_maq_equip into r_busca_alienacao_maq_equip;
  if c_busca_alienacao_maq_equip%found then
    vr_mostra_maqui_equi := true;
  end if;
  close c_busca_alienacao_maq_equip;
    --
  open c_busca_alienacao_imoveis(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctpro  => pr_nrctrato);
  fetch c_busca_alienacao_imoveis into r_busca_alienacao_imoveis;
  if c_busca_alienacao_imoveis%found then
    vr_mostra_imoveis := true;
  end if;
  close c_busca_alienacao_imoveis;
  
    /*FIM*/
  
    -- Somente Mostra se existir dados
  if vr_mostra_veiculos = true or
     vr_mostra_maqui_equi = true or
     vr_mostra_imoveis = true then
    
      vr_string := vr_string || '<subcategoria>
                            <tituloTela>Alienacão Fiduciária</tituloTela>
                            <campos>';
    
      /* 4.3.1 - Alienação Fiduciaria - Imóveis */
   if vr_mostra_imoveis = true then
        vr_string := vr_string || '<campo>
                            <nome>Imóveis (Casa, Apartamento, Terreno, Galpão)</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
        vr_index  := 1;
        vr_tab_tabela.delete;
  for r_alienacoes in c_busca_alienacao_imoveis (pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_nrctpro  => pr_nrctrato) loop
        
          vr_tab_tabela(vr_index).coluna1 := r_alienacoes.classificacao;
          vr_tab_tabela(vr_index).coluna2 := r_alienacoes.categoria;
          vr_tab_tabela(vr_index).coluna3 := to_char(r_alienacoes.valormercado, '999g999g990d00'); --bug 20565
          vr_tab_tabela(vr_index).coluna4 := to_char(r_alienacoes.valorvenda, '999g999g990d00'); --bug 20565
          vr_tab_tabela(vr_index).coluna5 := r_alienacoes.descricao;
          vr_tab_tabela(vr_index).coluna6 := r_alienacoes.areautil;
          vr_tab_tabela(vr_index).coluna7 := r_alienacoes.areatotal;
          vr_tab_tabela(vr_index).coluna8 := r_alienacoes.matricula;
          vr_tab_tabela(vr_index).coluna9 := r_alienacoes.cep;
          vr_tab_tabela(vr_index).coluna10 := r_alienacoes.rua;
          vr_tab_tabela(vr_index).coluna11 := r_alienacoes.complemento;
          vr_tab_tabela(vr_index).coluna12 := r_alienacoes.nr;
          vr_tab_tabela(vr_index).coluna13 := r_alienacoes.cidade;
          vr_tab_tabela(vr_index).coluna14 := r_alienacoes.bairro;
          vr_tab_tabela(vr_index).coluna15 := r_alienacoes.estado;
        
          vr_index := vr_index + 1;
        
  end loop;
      
  if vr_tab_tabela.COUNT > 0 then
          /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Classificação;Categoria;Valor de Mercado;Valor de Venda;Descrição;Área Útil;Área Total;Matrícula;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado',vr_tab_tabela);
  else
        
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
          vr_tab_tabela(1).coluna9 := '-';
          vr_tab_tabela(1).coluna10 := '-';
          vr_tab_tabela(1).coluna11 := '-';
          vr_tab_tabela(1).coluna12 := '-';
          vr_tab_tabela(1).coluna13 := '-';
          vr_tab_tabela(1).coluna14 := '-';
          vr_tab_tabela(1).coluna15 := '-';
        
    vr_string := vr_string||fn_tag_table('Classificação;Categoria;Valor de Mercado;Valor de Venda;Descrição;Área Útil;Área Total;Matrícula;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado',vr_tab_tabela);
  end if;
      
        vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
  end if;
      /* FIM 4.3.1 - Alienação Fiduciaria - Imóveis */
    
      /* 4.3.2 - Alienação Fiduciária - Veiculos */
    
      /*Intervenientes apresentados em tabela*/
   if vr_mostra_veiculos = true then
        vr_string := vr_string || '<campo>
                            <nome>Veículo</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
        vr_index  := 1;
        vr_tab_tabela.delete;
   for r_alienacoes in c_busca_alienacao_veiculo(pr_cdcooper => pr_cdcooper
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_nrctpro  => pr_nrctrato) loop
          --falta categoria
          vr_tab_tabela(vr_index).coluna1 := r_alienacoes.tipoveiculo;
        
          /*Se deve carregar tabela de interveniente anuente*/
     if (r_alienacoes.tipoveiculo in  ('AUTOMOVEL','CAMINHAO','MOTO','MAQUINA E EQUIPAMENTO','OUTROS VEICULOS')) then
          vr_isinterv := true;
     end if;
        
          vr_tab_tabela(vr_index).coluna2 := r_alienacoes.marca;
          vr_tab_tabela(vr_index).coluna3 := r_alienacoes.modelo;
          vr_tab_tabela(vr_index).coluna4 := to_char(r_alienacoes.valormercado, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna5 := to_char(r_alienacoes.valorfipe, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna6 := r_alienacoes.ufplaca;
          vr_tab_tabela(vr_index).coluna7 := r_alienacoes.nrplaca;
          vr_tab_tabela(vr_index).coluna8 := r_alienacoes.renavam;
          vr_tab_tabela(vr_index).coluna9 := r_alienacoes.chassi;
          vr_tab_tabela(vr_index).coluna10 := r_alienacoes.tipochassi;
          vr_tab_tabela(vr_index).coluna11 := r_alienacoes.anofabrica;
          vr_tab_tabela(vr_index).coluna12 := r_alienacoes.anomodelo;
          vr_tab_tabela(vr_index).coluna13 := r_alienacoes.cor;
     vr_tab_tabela(vr_index).coluna14 := gene0002.fn_mask_cpf_cnpj(
                                                  r_alienacoes.cpfbem,
                                                    CASE WHEN 
                                                      LENGTH(r_alienacoes.cpfbem) > 11 THEN 2 ELSE 1
                                                    END
                                                    );
          vr_index := vr_index + 1;
        
  end loop;
      
  if vr_tab_tabela.COUNT > 0 then
    vr_string := vr_string||fn_tag_table('Categoria;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;Número Placa;Renavam;Chassi;Tipo de Chassi;Ano de Fábrica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
  else
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
          vr_tab_tabela(1).coluna9 := '-';
          vr_tab_tabela(1).coluna10 := '-';
          vr_tab_tabela(1).coluna11 := '-';
          vr_tab_tabela(1).coluna12 := '-';
          vr_tab_tabela(1).coluna13 := '-';
          vr_tab_tabela(1).coluna14 := '-';
    vr_string := vr_string||fn_tag_table('Categoria;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;Número Placa;Renavam;Chassi;Tipo de Chassi;Ano de Fábrica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;
      
        vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
   end if;
    
      /* FIM 4.3.2 - Alienação Fiduciária - Veiculos */
    

      /* 4.3.3 - Alienação Fiduciária - Maquina e Equipamento */
    
   if vr_mostra_maqui_equi = true then
        /*TABELA*/
        vr_string := vr_string || '<campo>
                            <nome>Máquina e Equipamento</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
        vr_index  := 1;
        vr_tab_tabela.delete;
   for r_alienacoes in c_busca_alienacao_maq_equip (pr_cdcooper => pr_cdcooper
                                                   ,pr_nrdconta => pr_nrdconta
                                                   ,pr_nrctpro  => pr_nrctrato) loop
        
          vr_tab_tabela(vr_index).coluna1 := r_alienacoes.categoria;
        
          /*Se deve carregar tabela de interveniente anuente*/
     if (r_alienacoes.categoria in
                  ('AUTOMOVEL','CAMINHAO','MOTO','MAQUINA E EQUIPAMENTO','OUTROS VEICULOS')) then
          vr_isinterv := true;
     end if;
        
          vr_tab_tabela(vr_index).coluna2 := r_alienacoes.descricao;
          vr_tab_tabela(vr_index).coluna3 := r_alienacoes.marca;
          vr_tab_tabela(vr_index).coluna4 := r_alienacoes.modelo;
          vr_tab_tabela(vr_index).coluna5 := r_alienacoes.nota;
          vr_tab_tabela(vr_index).coluna6 := r_alienacoes.nrserie;
          vr_tab_tabela(vr_index).coluna7 := r_alienacoes.anomodelo;
          vr_tab_tabela(vr_index).coluna8 := to_char(r_alienacoes.valormercado, '999g999g990d00');
     vr_tab_tabela(vr_index).coluna9 := gene0002.fn_mask_cpf_cnpj(
                                                  r_alienacoes.cpfbem,
                                                    CASE WHEN 
                                                      LENGTH(r_alienacoes.cpfbem) > 11 THEN 2 ELSE 1
                                                    END
                                                    );
        
          vr_index := vr_index + 1;
  end loop;
      
  if vr_tab_tabela.COUNT > 0 then
          /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Categoria;Descrição;Marca;Modelo;Nota Fiscal;Número de Série;Ano de Fabricação;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
  else
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
          vr_tab_tabela(1).coluna9 := '-';
    vr_string := vr_string||fn_tag_table('Categoria;Descrição;Marca;Modelo;Nota Fiscal;Número de Série;Ano de Fabricação;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;
      
        vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>';
  end if;
    
      /* FIM 4.3.3 - Alienação Fiduciária - Maquina e Equipamento */
    
      vr_string := vr_string || '</campos></subcategoria>';
    
  end if; -- FIM MOSTRAR ALIENAÇÂO
  
  if vr_permingr = 0 and
     vr_vlgarnec = 0 and
     vr_inaplpro = 0 and
     vr_inpoupro = 0 and
     vr_inresaut = 0 and
     vr_mostra_veiculos = false and 
     vr_mostra_maqui_equi = false and 
     vr_mostra_imoveis = false and
     vr_isinterv = false and
     vr_string_garantia_pessoal is null
     then
    
      vr_string := vr_string || '<subcategoria>
                              <tituloTela>Proposta não possui Garantias</tituloTela>
                              <campos>
                               <campo>
                                <nome>Não possui</nome>
                                <tipo>string</tipo>
                                <valor>Dados</valor>
                               </campo>
                              </campos></subcategoria>';
    
   end if;
  
    /* INTERVENIENTE ANUENTE */
  
    /* Chama interveniente quando categoria correta*/
  if (vr_isinterv) then
      vr_string := vr_string || '<subcategoria>
                             <tituloTela>Interveniente Anuente</tituloTela>
                             <campos>';
    
      vr_index := 1;
      vr_tab_tabela.delete;
      vr_tab_tabela_secundaria.delete;
    
    for r_interveniente in c_consulta_interv_anuente(pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => pr_nrdconta) loop
        vr_inpessoaI := r_interveniente.inpessoainterv;
      
        /*Busca dados para a conta passando o CPF/CNPJ como parâmetro*/
     OPEN c_busca_dados_conta(pr_cdcooper => pr_cdcooper
                             ,pr_nrcpfcgc => r_interveniente.cpf);
     FETCH c_busca_dados_conta into r_busca_dados_conta;
        IF c_busca_dados_conta%NOTFOUND THEN
          r_busca_dados_conta.nrdconta := 0;
          r_busca_dados_conta.dtnasctl := r_interveniente.nascimento_nao_coop;
        END IF;
        CLOSE c_busca_dados_conta;
      
        vr_string := vr_string || '<campo>
                               <nome>Interveniente Anuente ' || vr_index ||
                     '</nome>
                               <tipo>info</tipo>
                               <valor>' || fn_nao_cooperado(r_busca_dados_conta.nrdconta) ||
                     '</valor></campo>';
      
        /*Interveniente PF*/
     if (vr_inpessoaI = 1) then
          vr_string := vr_string || fn_tag('Conta', fn_nao_cooperado(r_busca_dados_conta.nrdconta)) ||
                       fn_tag('Tipo de Pessoa', r_interveniente.inpessoa) ||
                       fn_tag('CPF', gene0002.fn_mask_cpf_cnpj(r_interveniente.cpf, 1)) ||
                       fn_tag('Nome', r_interveniente.nome) || fn_tag('Nacionalidade', r_interveniente.nacionalidade) ||
                       fn_tag('Data de Nascimento',
                              CASE
                                               WHEN r_busca_dados_conta.dtnasctl IS NOT NULL THEN
                                                to_char(r_busca_dados_conta.dtnasctl, 'DD/MM/YYYY')
                                               ELSE
                                                '-'
                               END) || fn_tag('CEP', r_interveniente.cep) || fn_tag('Rua', r_interveniente.rua) ||
                       fn_tag('Complemento', r_interveniente.complemento) || fn_tag('Número', r_interveniente.nr) ||
                       fn_tag('Cidade', r_interveniente.cidade) || fn_tag('Bairro', r_interveniente.bairro) ||
                       fn_tag('Estado', r_interveniente.estado);
        
          --Dados do Cônjuge do Interveniente
          vr_nrdcontacjg := NULL;
          OPEN c_busca_conta_conjuge(pr_cdcooper => pr_cdcooper, pr_nrcpfcgc => r_interveniente.cpfcong);
          FETCH c_busca_conta_conjuge
            INTO vr_nrdcontacjg;
          CLOSE c_busca_conta_conjuge;
        
          IF vr_nrdcontacjg IS NOT NULL THEN
            vr_string := vr_string || '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor>' ||
                         fn_nao_cooperado(vr_nrdcontacjg) || '</valor></campo>' ||
                         fn_tag('Conta', fn_nao_cooperado(vr_nrdcontacjg)) ||
                         fn_tag('CPF', gene0002.fn_mask_cpf_cnpj(r_interveniente.cpfcong, 1)) ||
                         fn_tag('Nome', r_interveniente.nomecong);
          END IF;
        ELSE
          /*Interveniente PJ*/
          vr_string := vr_string || fn_tag('Conta', fn_nao_cooperado(r_busca_dados_conta.nrdconta)) ||
                       fn_tag('Tipo de Natureza', r_interveniente.inpessoa) ||
                       fn_tag('CNPJ', gene0002.fn_mask_cpf_cnpj(r_interveniente.cpf, 2)) ||
                       fn_tag('Razão Social', r_interveniente.nome) ||
                       fn_tag('Data de Abertura da Empresa',
                              CASE
                                               WHEN r_busca_dados_conta.dtnasctl IS NOT NULL THEN
                                                to_char(r_busca_dados_conta.dtnasctl, 'DD/MM/YYYY')
                                               ELSE
                                                '-'
                               END) || fn_tag('CEP', r_interveniente.cep) || fn_tag('Rua', r_interveniente.rua) ||
                       fn_tag('Complemento', r_interveniente.complemento) || fn_tag('Número', r_interveniente.nr) ||
                       fn_tag('Cidade', r_interveniente.cidade) || fn_tag('Bairro', r_interveniente.bairro) ||
                       fn_tag('Estado', r_interveniente.estado);
        END IF;
        vr_index := vr_index + 1;
      
      END LOOP;
    
      vr_string := vr_string || '</campos>';
    
      vr_string := vr_string || '</subcategoria>';
  end if; --vr_isinterv=true
  
    -- Escrever no XML
  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                 pr_texto_completo => vr_dstexto,
                 pr_texto_novo     => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_garantia: '||sqlerrm;  
  END pc_consulta_garantia;

  /* Procedure para carregar dados da garantia da operação */
  PROCEDURE pc_consulta_garantia_operacao (pr_cdcooper crapass.cdcooper%TYPE
                                          ,pr_nrdconta crapass.nrdconta%TYPE
                                          ,pr_nrctremp crawepr.nrctremp%TYPE
                                          ,pr_tpproduto in number
                                          ,pr_chamador in varchar2 default 'O' -- Operações busca nas crap e P= Propostas nas W
                                          ,pr_retorno  OUT number
                                          ,pr_retxml   IN OUT NOCOPY xmltype) IS
    /* .............................................................................
    
       Programa: pc_consulta_garantia_operacao
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Rubens Lima
       Data    : 29/04/2019
    
       Dados referentes ao programa:
    
       Frequencia: Sempre que for chamado.
       Objetivo  : Chamada para ayllosWeb(mensageria)
                   Procedure para carregar dos dados para a TELA_ANALISE_CREDITO
    
    ............................................................................. */
  
  pr_dsctrliq number;
  
    /* Busca Dados da Proposta de Emprestimo */
    CURSOR c_busca_dados_proposta IS
      SELECT w.cdlcremp --linha
          ,w.cdfinemp --finalidade
          ,w.idcobefe --id efetivacao
          ,w.vlemprst --valor
        FROM crawepr w
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.nrctremp = pr_nrctremp;
    r_busca_dados_proposta c_busca_dados_proposta%ROWTYPE;
  
    /*Busca dados do limite quando não for Emprestimo e Financiamento bug 20391*/
    CURSOR c_busca_dados_lim_desctit IS
      SELECT w.cddlinha --linha
          ,w.idcobefe --id efetivacao
          ,w.vllimite
        FROM crawlim w
       WHERE w.cdcooper = pr_cdcooper
         AND w.nrdconta = pr_nrdconta
         AND w.nrctrlim = pr_nrctremp;
    r_busca_dados_lim_desctit c_busca_dados_lim_desctit%ROWTYPE;
  
  CURSOR c_busca_desconto_cheque is
    select l.cddlinha,
           l.idcobefe,
           l.vllimite
      from craplim l
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and nrctrlim = pr_nrctremp
       and tpctrlim = 2  -- Linha de Cheque
       and insitlim = 2; -- Ativo   
  r_busca_desconto_cheque c_busca_desconto_cheque%rowtype;        
  
  CURSOR c_busca_limite_credito is     
    SELECT crt.cddlinha,
           crt.idcobefe,
           crt.vllimite
        FROM craplim crt
       WHERE crt.nrdconta = pr_nrdconta
         AND crt.cdcooper = pr_cdcooper
         AND crt.nrctrlim = pr_nrctremp
         AND crt.insitlim = 2 --ativo       
         AND crt.tpctrlim = 1; --limite de credito               
    r_busca_limite_credito c_busca_limite_credito%ROWTYPE;
  
    /* 4.2 - Task 16173 - Consultar Garantia Operações */
  PROCEDURE pc_busca_dados_garantia(pr_cdcooper     IN crapcop.cdcooper%TYPE
                          ,pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_codlinha     IN INTEGER --> Codigo da linha
                          ,pr_cdfinemp     IN INTEGER --> Código da finalidade
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                          ,pr_dscritic     OUT VARCHAR2 
                          ,pr_retxml       IN OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
                                   
      vr_des_erro varchar2(4000);
    BEGIN
    
      pr_retxml := xmltype(fn_param_mensageria(pr_cdcooper));
    
  tela_garopc.pc_busca_dados(pr_idcobert => pr_idcobert, 
                             pr_tipaber  => 'C', -- Consulta
                             pr_nrdconta => pr_nrdconta, 
                             pr_tpctrato => pr_tpctrato, 
                             pr_codlinha => pr_codlinha, 
                             pr_cdfinemp => pr_cdfinemp, 
                             pr_vlropera => pr_vlropera, 
                             pr_dsctrliq => pr_dsctrliq, 
                             pr_xmllog   => null,
                             pr_cdcritic => vr_cdcritic, 
                             pr_dscritic => pr_dscritic, 
                             pr_retxml   => pr_retxml, 
                             pr_nmdcampo => vr_nmdcampo, 
                             pr_des_erro => vr_des_erro);
    
    END pc_busca_dados_garantia;
  
  BEGIN
  
    /*Se o produto for Emprestimo e Financiamento*/
    if (pr_tpproduto = c_emprestimo) then
    
      /* Busca dados da proposta de emprestimo */
  open c_busca_dados_proposta;
  fetch c_busca_dados_proposta into r_busca_dados_proposta;
       if c_busca_dados_proposta%found then
  vr_dscritic := null;    
  pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                          pr_idcobert => r_busca_dados_proposta.idcobefe,
                          pr_nrdconta => pr_nrdconta,
                          pr_tpctrato => 90,
                          pr_codlinha => r_busca_dados_proposta.cdlcremp,
                          pr_cdfinemp => r_busca_dados_proposta.cdfinemp,
                          pr_vlropera => r_busca_dados_proposta.vlemprst,
                          pr_dsctrliq => pr_dsctrliq,
                          pr_dscritic => vr_dscritic,
                          pr_retxml => pr_retxml);
         if r_busca_dados_proposta.idcobefe > 0 and vr_dscritic is null then
          pr_retorno := 1;
         else
          pr_retorno := 0;
         end if;
       else  
        pr_retorno := 2; -- Não existe produto
       end if;
      close c_busca_dados_proposta;
      
    elsif (pr_tpproduto = c_desconto_titulo) then
      open c_busca_dados_lim_desctit;
       fetch c_busca_dados_lim_desctit into r_busca_dados_lim_desctit;

       if c_busca_dados_lim_desctit%found then
         vr_dscritic := null;
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                        pr_idcobert => r_busca_dados_lim_desctit.idcobefe,
                        pr_nrdconta => pr_nrdconta,
                        pr_tpctrato => 3, --limite de desconto de título
                        pr_codlinha => r_busca_dados_lim_desctit.cddlinha,
                        pr_cdfinemp => 0,
                        pr_vlropera => r_busca_dados_lim_desctit.vllimite,
                        pr_dsctrliq => pr_dsctrliq,
                        pr_dscritic => vr_dscritic,
                        pr_retxml => pr_retxml);
      
         if r_busca_dados_lim_desctit.idcobefe > 0 and vr_dscritic is null then 
          pr_retorno := 1;
         else
          pr_retorno := 0;
       end if;
       else  
        pr_retorno := 2; -- Não existe produto
       end if;
      close c_busca_dados_lim_desctit; 
    elsif pr_tpproduto = c_desconto_cheque then
      open c_busca_desconto_cheque;
       fetch c_busca_desconto_cheque into r_busca_desconto_cheque;

       if c_busca_desconto_cheque%found then
         vr_dscritic := null;
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_desconto_cheque.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 2, 
                                 pr_codlinha => r_busca_desconto_cheque.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_desconto_cheque.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_dscritic => vr_dscritic,
                                 pr_retxml => pr_retxml);
      
         if r_busca_desconto_cheque.idcobefe > 0 and vr_dscritic is null then
          pr_retorno := 1;
    else
          pr_retorno := 0;
         end if;
       else  
        pr_retorno := 2; -- Não existe produto
       end if;
       close c_busca_desconto_cheque;       
    elsif pr_tpproduto = c_limite_desc_titulo then
     if pr_chamador = 'O' then
      open c_busca_limite_credito;
       fetch c_busca_limite_credito into r_busca_limite_credito;

       if c_busca_limite_credito%found then
         vr_dscritic := null;
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_limite_credito.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 1, 
                                 pr_codlinha => r_busca_limite_credito.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_limite_credito.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_dscritic => vr_dscritic,
                                  pr_retxml => pr_retxml);
        
         if r_busca_limite_credito.idcobefe > 0 and vr_dscritic is null then
            pr_retorno := 1;
         else 
            pr_retorno := 0;
         end if;
       else
          pr_retorno := 2; -- Não existe produto
       end if;
       close c_busca_limite_credito;       
     elsif pr_chamador = 'P' then
      open c_busca_dados_lim_desctit;
       fetch c_busca_dados_lim_desctit into r_busca_dados_lim_desctit;

       if c_busca_dados_lim_desctit%found then
         vr_dscritic := null;
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_dados_lim_desctit.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 1, 
                                 pr_codlinha => r_busca_dados_lim_desctit.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_dados_lim_desctit.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_dscritic => vr_dscritic,
                                 pr_retxml => pr_retxml);
        
         if r_busca_dados_lim_desctit.idcobefe > 0 and vr_dscritic is null then
            pr_retorno := 1;
         else 
            pr_retorno := 0;
         end if;
       else
          pr_retorno := 2; -- Não existe produto
       end if;
      close c_busca_dados_lim_desctit;        
     end if;        
    end if;
  
  END pc_consulta_garantia_operacao;

  PROCEDURE pc_consulta_scr(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                           ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                           ,pr_persona  IN Varchar2
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE         --> CPFCGC
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                           ,pr_dsxmlret OUT CLOB) IS                     --> Arquivo de retorno do XML
  /* .............................................................................

    Programa: pc_consulta_scr
    Sistema : Aimaro/Ibratan
    Autor   : Mateus Zimmermann (Mouts)
    Data    : Março/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta SCR

    Alteracoes:
      
           18/06/2019 - Inclusão das datas de Reaproveitamento e Base Bacen
                PJ438 - Jefferson - MoutS
           
  ..............................................................................*/

  vr_dsxmlret CLOB;
  vr_string   CLOB;
  vr_string_aux varchar2(32000);
  vr_nrconbir crapcbd.nrconbir%TYPE;
  vr_nrseqdet crapcbd.nrseqdet%TYPE;
  v_rtReadJson clob;
  vr_existe BOOLEAN := TRUE;
 
  /*Bug 21583  - Busca apenas pelo número nrconbir, pois são dois registros na crapcbd e apenas o 
    primeiro grava como reaproveitamento. */
  CURSOR c_crapcbd(pr_nrconbir crapcbd.nrconbir%type,
                   pr_nrcpfcgc crapcbd.nrcpfcgc%type) is
/*   select fn_tag('Data da Consulta', to_char(NVL(crapcbd.dtreapro,crapcbd.dtconbir), 'DD/MM/YYYY')) datareaproveitamento,
          fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'Não','Sim')) reaproveitamento,
          fn_tag('Data-base Bacen', CASE WHEN crapcbd.dtbaseba IS NOT NULL THEN to_char(crapcbd.dtbaseba, 'MM/YYYY') ELSE '-' END) databasebacen, -- Data base bacen
          fn_tag('Quantidade de Operações', NVL(temp.qtopescr,crapcbd.qtopescr)) qtoperacoes, -- Qt. Operações
          fn_tag('Quantidade de Instituições Financeiras', NVL(temp.qtifoper,crapcbd.qtifoper)) qtifs, -- Qt. IFs
          fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', to_char(NVL(temp.vltotsfn,crapcbd.vltotsfn),'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
          fn_tag('Operações Vencidas', to_char(NVL(temp.vlopescr,crapcbd.vlopescr),'999g999g990d00')) vencidas, -- Op.Vencidas
          fn_tag('Operações de Prejuízo', to_char(NVL(temp.vlprejui,crapcbd.vlprejui),'999g999g990d00')) prejuizo,  -- Op.Prejuízo
          fn_tag('Operações Vencidas nos últimos 12 meses', to_char(NVL(crapcbd.vlprejme,temp.vlopesme),'999g999g990d00')) vencidas12meses, -- Op.Vencidas ultimos 12 meses
          fn_tag('Operações de Prejuízo nos últimos 12 meses', to_char(NVL(crapcbd.vlopesme,temp.vlprejme),'999g999g990d00')) prejuizo12meses,  -- Op.Prejuízo ultimos 12 meses
          crapcbd.nrcpfcgc
        FROM crapbir,
             crapmbr,
             crapcbd,
             (SELECT cbd.qtopescr,
                     cbd.qtifoper,
                     cbd.vltotsfn,
                     cbd.vlopescr,
                     cbd.vlprejui,
                     cbd.vlprejme,
                     cbd.vlopesme,
                     cbd.cdcooper,
                     cbd.nrdconta
                FROM crapmbr mbr,
                     crapcbd cbd
               WHERE mbr.cdbircon = cbd.cdbircon
                 AND mbr.cdmodbir = cbd.cdmodbir
                 AND mbr.nrordimp = 0 -- Buscar somente o que for Bacen
                 AND cbd.inreterr = 0
                 AND cbd.nrconbir = (SELECT MAX(cbd2.nrconbir)
                                       FROM crapcbd cbd2
                                           ,crapmbr mbr2
                                      WHERE cbd2.nrdconta    = cbd.nrdconta
                                        AND cbd2.cdcooper    = cbd.cdcooper
                                        AND mbr2.cdbircon = cbd2.cdbircon
                                        AND mbr2.cdmodbir = cbd2.cdmodbir
                                        AND mbr2.nrordimp = 0 -- Buscar somente o que for Bacen
                                        AND cbd2.inreterr  = 0)) temp
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrcpfcgc = pr_nrcpfcgc
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapcbd.cdcooper = temp.cdcooper (+)
         AND crapcbd.nrdconta = temp.nrdconta (+)
         order by to_number(nrordimp); --bug 22113*/
   select fn_tag('Data da Consulta', to_char(NVL(crapcbd.dtreapro,crapcbd.dtconbir), 'DD/MM/YYYY')) datareaproveitamento,
          fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'Não','Sim')) reaproveitamento,
          fn_tag('Data-base Bacen', CASE WHEN crapcbd.dtbaseba IS NOT NULL THEN to_char(crapcbd.dtbaseba, 'MM/YYYY') ELSE '-' END) databasebacen, -- Data base bacen
          fn_tag('Quantidade de Operações', crapcbd.qtopescr) qtoperacoes, -- Qt. Operações
          fn_tag('Quantidade de Instituições Financeiras', crapcbd.qtifoper) qtifs, -- Qt. IFs
          fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', to_char(crapcbd.vltotsfn,'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
          fn_tag('Operações Vencidas', to_char(crapcbd.vlopescr,'999g999g990d00')) vencidas, -- Op.Vencidas
          fn_tag('Operações de Prejuízo', to_char(crapcbd.vlprejui,'999g999g990d00')) prejuizo,  -- Op.Prejuízo
          fn_tag('Operações Vencidas nos últimos 12 meses', to_char(crapcbd.vlprejme,'999g999g990d00')) vencidas12meses, -- Op.Vencidas ultimos 12 meses
          fn_tag('Operações de Prejuízo nos últimos 12 meses', to_char(crapcbd.vlopesme,'999g999g990d00')) prejuizo12meses,  -- Op.Prejuízo ultimos 12 meses
          crapcbd.nrcpfcgc
        FROM crapbir,
             crapmbr,
             crapcbd
       WHERE crapcbd.nrconbir = pr_nrconbir
         AND crapcbd.nrcpfcgc = pr_nrcpfcgc
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapcbd.Intippes IN (1,2,3) --1-Titular/ 2-Avalista/ 3-Conjuge
         order by to_number(nrordimp); --bug 22113
  r_crapcbd c_crapcbd%rowtype;
  --
  CURSOR cr_modalidade(prc_nrconbir tbgen_modalidade_biro.nrconbir%type,
                       prc_nrcpfcgc tbgen_modalidade_biro.nrcpfcgc%TYPE
                       ) IS
    SELECT DISTINCT 'Modalidade - '||a.cdmodbir||' - '||REPLACE(SUBSTR(to_char(a.xmlmodal),2,INSTR(to_char(a.xmlmodal),'>')-2),'_',' ') Modalidade
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_31D_60D'||'>[^<]*'),'<'||'VPERCVE_31D_60D'||'>',null),'.',',') VPERCVE_31D_60D
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_61D_90D'||'>[^<]*'),'<'||'VPERCVE_61D_90D'||'>',null),'.',',') VPERCVE_61D_90D
     FROM tbgen_modalidade_biro a
    WHERE a.nrconbir = prc_nrconbir--2735256
      --AND a.nrseqdet = pr_nrseqdet
      AND a.nrcpfcgc = prc_nrcpfcgc;
      
  --
  CURSOR cr_nrconbir IS
    SELECT cbd.nrconbir,
           MAX(cbd.nrseqdet) nrseqdet
      FROM crapcbd cbd
     WHERE cbd.nrconbir = (
                          SELECT MAX(cbd2.nrconbir)
                            FROM crapcbd cbd2
                           WHERE cbd2.cdcooper = pr_cdcooper
                             AND cbd2.nrdconta = pr_nrdconta
                          )
      GROUP BY cbd.nrconbir
      ;   
  
  --
  BEGIN

    vr_cdcritic := 0;
    vr_dscritic := null;

    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);

    vr_string := '<categoria>'||
                 '<tituloTela>SCR</tituloTela>'||
                 '<tituloFiltro>scr</tituloFiltro>'||
                 '<subcategorias>';
    
  /*Leitura do XML de retorno do motor apenas para o proponente e produtos (Empréstimo e Limite Desconto Titulo*/
  IF ( pr_persona = 'Proponente' AND vr_tpproduto_principal in(c_emprestimo, c_limite_desc_titulo) ) THEN
    
    -- Resumo das Informações do Titular             
    vr_string := vr_string || '<subcategoria>'||'<tituloTela>Resumo das Informações do Titular</tituloTela>'||
                               '<campos>';             
                 
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    
    OPEN c_crapcbd(pr_nrconbir => vr_nrconbir,
                   pr_nrcpfcgc => pr_nrcpfcgc);
                   --bug 21583 pr_nrseqdet => vr_nrseqdet);
     FETCH c_crapcbd INTO r_crapcbd;
    
    IF c_crapcbd%FOUND THEN
    CLOSE c_crapcbd;  
      vr_existe := TRUE;
    vr_string := vr_string||r_crapcbd.datareaproveitamento||
                            r_crapcbd.reaproveitamento||
                            r_crapcbd.databasebacen||
                            r_crapcbd.qtoperacoes||
                            r_crapcbd.qtifs||
                            r_crapcbd.endividamento||
                            r_crapcbd.vencidas||
                            r_crapcbd.prejuizo||
                            r_crapcbd.vencidas12meses||
                            r_crapcbd.prejuizo12meses;
    ELSE
      CLOSE c_crapcbd;
      vr_existe := FALSE;
      vr_string := vr_string || fn_tag('Data da Consulta', '-') ||
                   fn_tag('Reaproveitamento', '-') ||
                   fn_tag('Data-base Bacen', '-') ||
                   fn_tag('Quantidade de Operações', '-') ||
                   fn_tag('Quantidade de Instituições Financeiras', '-') ||
                   fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)','-') ||
                   fn_tag('Operações Vencidas', '-') ||
                   fn_tag('Operações de Prejuízo', '-') ||
                   fn_tag('Operações Vencidas nos últimos 12 meses', '-') ||
                   fn_tag('Operações de Prejuízo nos últimos 12 meses', '-')||
                   fn_tag('Comprometimento de renda', '-');
    END IF;
    -- PF
    IF(r_pessoa.inpessoa = 1) AND vr_existe THEN
        -- Procurar pelos possíveis nomes para o campo que existe no JSON
        -- comprometimento de renda acima do permitido

	        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'Valor do comprometimento da renda',
                                                              p_hasDoisPontos =>  true,
                                                              p_idCampo       => 0);    
      IF v_rtReadJson = '-' THEN
        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'percentual de endividamento sobre o valor da renda',
                                                              p_hasDoisPontos =>  TRUE,
                                                              p_idCampo       => 0);          
      END IF;                                                                  
      -- Cartao
      IF v_rtReadJson = '-' THEN
        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'renda comprometida acima do permitido',
                                                              p_hasDoisPontos =>  TRUE,
                                                              p_idCampo       => -1);          
      END IF;      
          
          IF v_rtReadJson <> '-' THEN
        v_rtReadJson := REPLACE(v_rtReadJson,'%','');
        IF vr_tpproduto_principal = 6 THEN -- bordero de credito
          v_rtReadJson := substr(v_rtReadJson, 1, length(v_rtReadJson) - 1);
          BEGIN
            v_rtReadJson := to_char(round(to_number(REPLACE(v_rtReadJson,'.',','))* 100,2),'999g999g990d00')|| '%';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;            
        ELSE
          
          IF (INSTR(REPLACE(v_rtReadJson,',','.'),'.',-1) - INSTR(REPLACE(v_rtReadJson,',','.'),'.')) > 0 THEN
                v_rtReadJson := to_char(
                                        ROUND(
                                              to_number(
                                                        REPLACE(
                                                        substr(v_rtReadJson, 1, length(v_rtReadJson) - 1),'.',','
                                                               )
                                                       )
                                           ,2)
                                      ,'999g999g990d00')|| '%';
           ELSE
                v_rtReadJson := to_char(
                                        ROUND(
                                              to_number(
                                                        REPLACE(
                                                        substr(v_rtReadJson, 1, length(v_rtReadJson)),'.',','
                                                               )
                                                       )
                                           ,2)
                                      ,'999g999g990d00')|| '%';               
          END IF;
        END IF;
            
      END IF;      
     
        vr_string := vr_string||tela_analise_credito.fn_tag('Comprometimento de renda', v_rtReadJson);
    
      ELSIF vr_existe THEN -- cnpj
        
        -- faturamento comprometido acima do permitido
        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                            p_tagFind       => 'percentual de endividamento sobre o valor da renda',
                                                            p_hasDoisPontos =>  TRUE,
                                                            p_idCampo       => 0);     

      IF v_rtReadJson = '-' THEN

        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'faturamento comprometido acima do permitido',
                                                            p_hasDoisPontos =>  TRUE,
                                                              p_idCampo       => 0);
        IF v_rtReadJson <> '-' THEN
          v_rtReadJson := TRIM(SUBSTR(v_rtReadJson, 
                          INSTR(v_rtReadJson,'permitido',-1)+9,
                          INSTR(SUBSTR(v_rtReadJson,INSTR(v_rtReadJson,'permitido',-1) + 9),',')-1
                          ));
        END IF;                                                               
      END IF;
      -- Cartao
      IF v_rtReadJson = '-' THEN
        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'renda comprometida acima do permitido',
                                                              p_hasDoisPontos =>  TRUE,
                                                              p_idCampo       => -1);          
      END IF;         
      -- Tratar valor de retorno                                                     
        IF v_rtReadJson <> '-' THEN
        v_rtReadJson := REPLACE(v_rtReadJson,'%','');
        IF vr_tpproduto_principal = 6 THEN -- limite de credito
          v_rtReadJson := substr(v_rtReadJson, 1, length(v_rtReadJson) - 1);
          BEGIN
              v_rtReadJson := to_char(round(to_number(REPLACE(v_rtReadJson,'.',','))* 100,2),'999g999g990d00')|| '%';
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;            
        ELSE
          IF (INSTR(REPLACE(v_rtReadJson,',','.'),'.',-1) - INSTR(REPLACE(v_rtReadJson,',','.'),'.')) > 0 THEN
            v_rtReadJson := to_char(
                                    ROUND(
                                          to_number(
                                                    REPLACE(
                                                    substr(v_rtReadJson, 1, length(v_rtReadJson) - 1),'.',','
                                                           )
                                                   )
                                       ,2)
                                  ,'999g999g990d00')|| '%';
          ELSE
            v_rtReadJson := to_char(
                                    ROUND(
                                          to_number(
                                                    REPLACE(
                                                    substr(v_rtReadJson, 1, length(v_rtReadJson)),'.',','
                                                           )
                                                   )
                                       ,2)
                                  ,'999g999g990d00')|| '%';               
          END IF;
      END IF;
    END IF;
        
      vr_string := vr_string||tela_analise_credito.fn_tag('Faturamento comprometido acima do permitido', v_rtReadJson);                                                             
    
  END IF;                        
    


    /*PRJ 438 - Sprint 15 - Story 23824*/
    --Somente PJ
    IF(r_pessoa.inpessoa > 1) THEN
      /*OPEN c_busca_classe_risco_serasa (pr_nrconbir => vr_nrconbir -- Retirado 18/09
                                       ,pr_nrseqdet => vr_nrseqdet);                                     
       FETCH c_busca_classe_risco_serasa INTO vr_dsclaris;
       IF c_busca_classe_risco_serasa%FOUND THEN
         vr_string := vr_string||fn_tag('Classe de risco do Serasa', vr_dsclaris);
       END IF;
      CLOSE c_busca_classe_risco_serasa;*/

      /*PRJ 438 - Sprint 15 - Story 23820*/
      OPEN c_busca_inadimplencia (pr_nrconbir => vr_nrconbir
                                 ,pr_nrcpfcgc => pr_nrcpfcgc);                                     
       FETCH c_busca_inadimplencia INTO vr_peinadim;
       IF c_busca_inadimplencia%FOUND THEN
         vr_string := vr_string||fn_tag('Probabilidade de Inadimplência', to_char(vr_peinadim,'990D00')  || ' %');
       END IF;
      CLOSE c_busca_inadimplencia;
    END IF;      
    vr_string := vr_string||'</campos></subcategoria>';
    -- Fim Resumo das Informações do Titular               
    
    -- SCR
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>SCR</tituloTela>'||
                              '<campos>';
                              
    vr_tab_tabela.delete;
      vr_existe := FALSE;
    --FOR rw_nrconbir IN cr_nrconbir LOOP
    FOR rw_modalidade IN cr_modalidade(prc_nrconbir => vr_nrconbir,
                                         prc_nrcpfcgc => r_crapcbd.nrcpfcgc)LOOP
        vr_existe := TRUE;
        --
        vr_string := vr_string||'<campo>
                                 <nome>' || rw_modalidade.modalidade ||'</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
        --
        vr_tab_tabela(1).coluna1 := to_char(nvl(rw_modalidade.vpercve_31d_60d, 0),'999g999g990d00');
        vr_tab_tabela(1).coluna2 := to_char(nvl(rw_modalidade.vpercve_61d_90d, 0),'999g999g990d00');
        --
        vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
        --
        vr_string := vr_string||'</linhas>
                                 </valor>
                                 </campo>';
      END LOOP;
    --END LOOP;
      IF NOT vr_existe THEN
        vr_string := vr_string||'<campo>
                                 <nome>' || 'Modalidade' ||'</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
    --
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        --
        vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
        --
        vr_string := vr_string||'</linhas>
                                 </valor>
                                 </campo>';        
      END IF;
      --
    vr_string := vr_string||'</campos>';
    -- Fim SCR
    ELSE -- Outra persona
      pc_consulta_scr2(pr_cdcooper => pr_cdcooper
                     , pr_nrdconta => pr_nrdconta
                     , pr_cdcritic => vr_cdcritic
                     , pr_dscritic => vr_dscritic
                     , pr_dsxmlret => vr_string_aux);
      vr_string := vr_string||vr_string_aux;         
                     
    end if;  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);

    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
    
    EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_SCR - '||SQLERRM;
      vr_string := '<categoria>'||
                       '<tituloTela>SCR</tituloTela>'||
                       '<tituloFiltro>scr</tituloFiltro>'||
                       '<subcategorias>'||
                             '<subcategoria>'||
                                 '<erros>'||
                                     '<erro>'||
                                         '<cdcritic>0</cdcritic>'||
                                         '<dscritic>'||pr_dscritic||'</dscritic>'||
                                     '</erro>'||
                                 '</erros>';
                                 
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);  
                  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;                                       

  END pc_consulta_scr;

  PROCEDURE pc_consulta_scr2(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Conta
                            ,pr_cdcritic OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2 --> Descricao da critica
                            ,pr_dsxmlret OUT varchar2) IS --> Arquivo de retorno do XML
    /* .............................................................................
    
      Programa: pc_consulta_scr
      Sistema : Aimaro/Ibratan
      Autor   : Mateus Zimmermann (Mouts)
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Consulta SCR
    
      Alteracoes:
    ..............................................................................*/
  
    vr_string CLOB;
    vr_existe BOOLEAN;
  
    cursor c_crapopf is
      select opf.nrcpfcgc,
             a.inpessoa
        from crapass a,
             crapopf opf
       where a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta
         and opf.nrcpfcgc = a.nrcpfcgc
         and opf.dtrefere >= (select max(dtrefere) from crapopf);
    r_crapopf c_crapopf%rowtype;
  
    cursor c_consulta_scr(pr_nrcpfcgc crapass.nrcpfcgc%type) is
      select fn_tag('Data-base Bacen', to_char(opf.dtrefere, 'DD/MM/YYYY')) databasebacen, -- Data base bacen
             fn_tag('Quantidade de Operações', opf.qtopesfn) qtoperacoes, -- Qt. Operações
             fn_tag('Quantidade de Instituições Financeiras', opf.qtifssfn) qtifs, -- Qt. IFs
             fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', to_char(SUM(vop.vlvencto), '999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
             fn_tag('Operações Vencidas', SUM(CASE WHEN vop.cdvencto BETWEEN 205 AND 290 THEN vop.vlvencto ELSE 0 END)) vencidas, -- Op.Vencidas
             fn_tag('Operações de Prejuízo', SUM(CASE WHEN vop.cdvencto BETWEEN 310 AND 330 THEN vop.vlvencto ELSE 0 END)) prejuizo -- Op.Prejuízo
        from crapopf opf,
             crapvop vop
       where opf.nrcpfcgc = pr_nrcpfcgc
         and opf.dtrefere >= (select max(dtrefere) from crapopf)
         and vop.nrcpfcgc = opf.nrcpfcgc
         and vop.dtrefere = opf.dtrefere
       group by opf.nrcpfcgc, opf.dtrefere, opf.qtopesfn, opf.qtifssfn;
    r_consulta_scr c_consulta_scr%rowtype;
  
    cursor c_modalidades(pr_nrcpfcgc crapass.nrcpfcgc%type) is
    select distinct substr(vop.cdmodali,1,2) cdmodali,
                    substr(vop.cdmodali,3,2) cdsubmod
      from crapvop vop
     where vop.nrcpfcgc = pr_nrcpfcgc
       and vop.dtrefere >= (select max(dtrefere) from crapopf)
       and vop.cdvencto in (120, 130) -- 31-60 61-90 
       order by substr(vop.cdmodali,1,2),substr(vop.cdmodali,3,2);    

    cursor c_modalidades_vencto(pr_nrcpfcgc crapass.nrcpfcgc%type,
                                pr_cdvencto crapvop.cdvencto%type,
                                pr_cdmodali gnsbmod.cdmodali%type,
                                pr_cdsubmod gnsbmod.cdmodali%type) is
    select s.cdmodali,
           to_char(s.cdsubmod) cdsubmod,
           s.dssubmod,
           to_char(nvl(sum(vop.vlvencto),0),'999g999g990d00') vencimento
        from crapvop vop,
           gnmodal m, --Modalidade
           gnsbmod s  -- Submodalidade
       where vop.nrcpfcgc = pr_nrcpfcgc
         and vop.dtrefere >= (select max(dtrefere) from crapopf)
       and m.cdmodali = substr(vop.cdmodali,1,2)
       and s.cdmodali = SUBSTR(vop.cdmodali,1,2)
       and s.cdsubmod = SUBSTR(vop.cdmodali,3,2)
       and vop.cdvencto = pr_cdvencto -- 120,130 -- 31-60 61-90
       and s.cdmodali = pr_cdmodali
       and s.cdsubmod = pr_cdsubmod
  group by s.cdmodali,
           vop.nrcpfcgc, 
           s.cdsubmod,
           s.dssubmod, 
           vop.cdvencto;           

    r_modalidades_vencto c_modalidades_vencto%rowtype;
  

/*    -- 31 dias a 60 dias
    cursor c_vencimento_120(pr_nrcpfcgc crapass.nrcpfcgc%type,
                            pr_cdmodali crapvop.cdmodali%type) is
      select vop.cdvencto,
             to_char(sum(vop.vlvencto), '999g999g990d00') vencimento
        from crapvop vop
       where vop.nrcpfcgc = pr_nrcpfcgc
         and vop.dtrefere = (select max(dtrefere) from crapopf)
         and substr(vop.cdmodali, 1, 2) = pr_cdmodali
         and vop.cdvencto = 120
       group by vop.cdvencto;
    r_vencimento_120 c_vencimento_120%rowtype;
  
    -- 61 dias a 60 dias
    cursor c_vencimento_130(pr_nrcpfcgc crapass.nrcpfcgc%type,
                            pr_cdmodali crapvop.cdmodali%type) is
      select vop.cdvencto,
             to_char(sum(vop.vlvencto), '999g999g990d00') vencimento
        from crapvop vop
       where vop.nrcpfcgc = pr_nrcpfcgc
         and vop.dtrefere = (select max(dtrefere) from crapopf)
         and substr(vop.cdmodali, 1, 2) = pr_cdmodali
         and vop.cdvencto = 130
       group by vop.cdvencto;
    r_vencimento_130 c_vencimento_130%rowtype;*/
  
 
    cursor c_crapvop(pr_nrcpfcgc crapass.nrcpfcgc%type) is
      select fn_tag('Operações Vencidas(até 12 meses)', to_char(sum(vop.vlvencto), '999g999g990d00')) operacoesVencidas
        from crapvop vop, crapass a
       where vop.cdvencto >= 220 and vop.cdvencto <= 270 -- Vencidos até 12 meses
         and a.nrcpfcgc = vop.nrcpfcgc
         and vop.dtrefere = (select max(dtrefere) from crapopf)
         and a.nrcpfcgc = pr_nrcpfcgc
       group by a.nrdconta;
    r_crapvop c_crapvop%rowtype;
  
  BEGIN
  
    vr_cdcritic := 0;
    vr_dscritic := null;
  
    -- SCR
    -- Resumo das Informações do Titular             
    vr_string := vr_string || '<subcategoria>' ||
                              '<tituloTela>Resumo das Informações do Titular</tituloTela>' ||
                 '<campos>';
  
                 
    open c_crapopf;
    fetch c_crapopf into r_crapopf;
    if c_crapopf%notfound then
      vr_string := vr_string || '<campo>' ||
                                '<nome>Informação</nome>' ||
                                '<tipo>info</tipo>' ||
                   '<valor>Não foi encontrado dados do SCR</valor>' ||
                   '</campo>';
    else
      open c_consulta_scr(r_crapopf.nrcpfcgc);
      fetch c_consulta_scr INTO r_consulta_scr;
      IF c_consulta_scr%FOUND THEN
      
        /*Gera Tags Xml*/
        vr_string := vr_string ||
                     r_consulta_scr.databasebacen||
                     r_consulta_scr.qtoperacoes || r_consulta_scr.qtifs || r_consulta_scr.endividamento ||
                     r_consulta_scr.vencidas || r_consulta_scr.prejuizo;



      ELSE
        vr_string := vr_string ||
                     fn_tag('Data-base Bacen', '-') ||
                     fn_tag('Quantidade de Operações', '-') || fn_tag('Quantidade de Instituições Financeiras', '-') ||

                     fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', '-') ||
                     fn_tag('Operações Vencidas', '-') || fn_tag('Operações de Prejuízo', '-');

      
      END IF;
      CLOSE c_consulta_scr;
    
      OPEN c_crapvop(r_crapopf.nrcpfcgc);
      FETCH c_crapvop INTO r_crapvop;
      IF c_crapvop%FOUND THEN
      
        /*Gera Tags Xml*/
        vr_string := vr_string || r_crapvop.operacoesvencidas;

      ELSE
        vr_string := vr_string || fn_tag('Operações Vencidas(até 12 meses)', '-');

      END IF;
      CLOSE c_crapvop;
    
    /*PRJ 438 - Sprint 15 - Story 23824*/
    if r_crapopf.inpessoa > 1 then -- Somente PJ
      OPEN c_busca_classe_risco_serasa (pr_nrconbir => vr_nrconbir
                                       ,pr_nrseqdet => vr_nrseqdet);                                     
       FETCH c_busca_classe_risco_serasa INTO vr_dsclaris;
       IF c_busca_classe_risco_serasa%FOUND THEN
         vr_string := vr_string||fn_tag('Classe de risco do Serasa', vr_dsclaris);
       END IF;
      CLOSE c_busca_classe_risco_serasa;

      /*PRJ 438 - Sprint 15 - Story 23820*/
      OPEN c_busca_inadimplencia (pr_nrconbir => vr_nrconbir
                                 ,pr_nrcpfcgc => r_crapopf.nrcpfcgc);                                     
       FETCH c_busca_inadimplencia INTO vr_peinadim;
       IF c_busca_inadimplencia%FOUND THEN
         vr_string := vr_string||fn_tag('Probabilidade de Inadimplência', vr_peinadim || ' %');
       END IF;
      CLOSE c_busca_inadimplencia;
    end if;
      vr_string := vr_string || '</campos></subcategoria>';
      -- Fim Resumo das Informações do Titular   
    
      vr_string := vr_string || '<subcategoria>' || '<tituloTela>SCR</tituloTela>' || '<campos>';


      vr_existe := FALSE;
      FOR r_modalidades IN c_modalidades(r_crapopf.nrcpfcgc) LOOP
        vr_existe := TRUE;
        vr_tab_tabela.delete;
      
        open c_modalidades_vencto(r_crapopf.nrcpfcgc,120,r_modalidades.cdmodali,r_modalidades.cdsubmod);
         fetch c_modalidades_vencto into r_modalidades_vencto;
          if c_modalidades_vencto%found then
            vr_tab_tabela(1).coluna1 := r_modalidades_vencto.vencimento;
          else
            vr_tab_tabela(1).coluna1 := '-';
          end if;
        close c_modalidades_vencto;
        
        open c_modalidades_vencto(r_crapopf.nrcpfcgc,130,r_modalidades.cdmodali,r_modalidades.cdsubmod);
         fetch c_modalidades_vencto into r_modalidades_vencto;
          if c_modalidades_vencto%found then
            vr_tab_tabela(1).coluna2 := r_modalidades_vencto.vencimento;
          else
            vr_tab_tabela(1).coluna2 := '-';
          end if;
        close c_modalidades_vencto;        

        vr_string := vr_string || '<campo>
                                   <nome>Modalidade: ' || r_modalidades_vencto.cdsubmod || ' - ' ||r_modalidades_vencto.dssubmod || '</nome>

                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';
      
        vr_string := vr_string || fn_tag_table('31 dias a 60 dias;61 dias a 90 dias', vr_tab_tabela);
      
        vr_string := vr_string || '</linhas>
                                   </valor>
                                   </campo>';
      END LOOP;
      
      -- se nao encontrou modalidade
      IF NOT vr_existe THEN
        vr_tab_tabela.delete;
      
        vr_string := vr_string || '<campo>
                                   <nome>Modalidade</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_string := vr_string || fn_tag_table('31 dias a 60 dias;61 dias a 90 dias', vr_tab_tabela);
        vr_string := vr_string || '</linhas>
                                   </valor>
                                   </campo>';
      END IF;
    END IF;
    CLOSE c_crapopf;
  
    vr_string := vr_string || '</campos>';
    -- Fim SCR
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_string;
  
  EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_SCR - ' || SQLERRM;
  END pc_consulta_scr2;

PROCEDURE pc_consulta_scr_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                               ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                               ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                               ,pr_persona  IN Varchar2
                               ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE         --> CPFCGC
                               ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                               ,pr_dsxmlret OUT CLOB) IS                     --> Arquivo de retorno do XML
  /* .............................................................................

    Programa: pc_consulta_scr
    Sistema : Aimaro/Ibratan
    Autor   : Mateus Zimmermann (Mouts)
    Data    : Março/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta SCR

    Alteracoes:
  ..............................................................................*/

  vr_dsxmlret CLOB;
  vr_string   CLOB;
  vr_string_aux varchar2(32000);
  vr_nrconbir crapcbd.nrconbir%TYPE;
  vr_nrseqdet crapcbd.nrseqdet%TYPE;
  v_rtReadJson clob;
  vr_existe BOOLEAN := TRUE;
 
  /*Bug 21583  - Busca apenas pelo número nrconbir, pois são dois registros na crapcbd e apenas o 
    primeiro grava como reaproveitamento. */
  CURSOR c_crapcbd(pr_nrconbir crapcbd.nrconbir%TYPE, pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) IS
   select fn_tag('Data da Consulta', to_char(crapcbd.dtreapro,'DD/MM/YYYY')) datareaproveitamento,
          fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'Não','Sim')) reaproveitamento,
          fn_tag('Data-base Bacen', CASE WHEN crapcbd.dtbaseba IS NOT NULL THEN to_char(crapcbd.dtbaseba, 'MM/YYYY') ELSE '-' END) databasebacen, -- Data base bacen
          fn_tag('Quantidade de Operações',crapcbd.qtopescr) qtoperacoes, -- Qt. Operações
          fn_tag('Quantidade de Instituições Financeiras',crapcbd.qtifoper) qtifs, -- Qt. IFs
          fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)',to_char(crapcbd.vltotsfn,'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
          fn_tag('Operações Vencidas', to_char(crapcbd.vlopescr,'999g999g990d00')) vencidas, -- Op.Vencidas
          fn_tag('Operações de Prejuízo', to_char(crapcbd.vlprejui,'999g999g990d00')) prejuizo,  -- Op.Prejuízo
          fn_tag('Operações Vencidas nos últimos 12 meses', to_char(crapcbd.vlprejme,'999g999g990d00')) vencidas12meses, -- Op.Vencidas ultimos 12 meses
          fn_tag('Operações de Prejuízo nos últimos 12 meses', to_char(crapcbd.vlopesme,'999g999g990d00')) prejuizo12meses  -- Op.Prejuízo ultimos 12 meses
     FROM crapcbd
    WHERE crapcbd.nrconbir = pr_nrconbir
      AND crapcbd.nrcpfcgc = pr_nrcpfcgc
      AND crapcbd.cdbircon = 3; -- SRC Bacen Completo
  r_crapcbd c_crapcbd%ROWTYPE;
  --
  CURSOR cr_modalidade(prc_nrconbir tbgen_modalidade_biro.nrconbir%type,
                       prc_nrcpfcgc tbgen_modalidade_biro.nrcpfcgc%TYPE
                       ) IS
    SELECT DISTINCT 'Modalidade - '||a.cdmodbir||' - '||REPLACE(SUBSTR(to_char(a.xmlmodal),2,INSTR(to_char(a.xmlmodal),'>')-2),'_',' ') Modalidade
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_31D_60D'||'>[^<]*'),'<'||'VPERCVE_31D_60D'||'>',null),'.',',') VPERCVE_31D_60D
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_61D_90D'||'>[^<]*'),'<'||'VPERCVE_61D_90D'||'>',null),'.',',') VPERCVE_61D_90D
     FROM tbgen_modalidade_biro a
    WHERE a.nrconbir = prc_nrconbir--2735256
      --AND a.nrseqdet = pr_nrseqdet
      AND a.nrcpfcgc = prc_nrcpfcgc
      
      ;                       
  --
  CURSOR cr_nrconbir IS
    SELECT cbd.nrconbir,
           MAX(cbd.nrseqdet) nrseqdet
      FROM crapcbd cbd
     WHERE cbd.nrconbir = (
                          SELECT MAX(cbd2.nrconbir)
                            FROM crapcbd cbd2
                           WHERE cbd2.cdcooper = pr_cdcooper
                             AND cbd2.nrdconta = pr_nrdconta
                          )
      GROUP BY cbd.nrconbir
      ;   
  
  --
  BEGIN

    vr_cdcritic := 0;
    vr_dscritic := null;

    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);

    vr_string := '<categoria>'||
                 '<tituloTela>SCR</tituloTela>'||
                 '<tituloFiltro>scr</tituloFiltro>'||
                 '<subcategorias>';
    
  /*Leitura do XML de retorno do motor apenas para o proponente e produtos (Empréstimo e Limite Desconto Titulo*/
  IF vr_tpproduto_principal in(c_emprestimo, c_limite_desc_titulo) THEN
    
    -- Resumo das Informações do Titular             
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>Resumo das Informações do Titular</tituloTela>'||
                               '<campos>';             
                 
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    
    OPEN c_crapcbd(pr_nrconbir => vr_nrconbir,
                   pr_nrcpfcgc => pr_nrcpfcgc);
                   --bug 21583 pr_nrseqdet => vr_nrseqdet);
     FETCH c_crapcbd INTO r_crapcbd;
    
    IF c_crapcbd%FOUND THEN
    CLOSE c_crapcbd;  
      vr_existe := TRUE;
    vr_string := vr_string || r_crapcbd.datareaproveitamento||
                 r_crapcbd.reaproveitamento||
                 r_crapcbd.databasebacen ||
                 r_crapcbd.qtoperacoes || r_crapcbd.qtifs || r_crapcbd.endividamento || r_crapcbd.vencidas ||
                 r_crapcbd.prejuizo || r_crapcbd.vencidas12meses || r_crapcbd.prejuizo12meses;
    ELSE
      CLOSE c_crapcbd;
      vr_existe := FALSE;
      vr_string := vr_string || fn_tag('Data da Consulta', '-') ||
                                fn_tag('Reaproveitamento', '-') ||
                                fn_tag('Data-base Bacen', '-') ||
                                fn_tag('Quantidade de Operações', '-') || fn_tag('Quantidade de Instituições Financeiras', '-') ||
                                fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)','-') ||
                                fn_tag('Operações Vencidas', '-') || fn_tag('Operações de Prejuízo', '-') ||
                                fn_tag('Operações Vencidas nos últimos 12 meses', '-') ||
                                fn_tag('Operações de Prejuízo nos últimos 12 meses', '-')||
                                fn_tag('Comprometimento de renda', '-');
    END IF;
    -- PF
    IF(r_pessoa.inpessoa = 1) AND vr_existe THEN
      /*Não localizado comprometimento de renda para Avalista não cooperada*/       
      vr_string := vr_string||tela_analise_credito.fn_tag('Comprometimento de renda', '-');
      vr_string := vr_string||tela_analise_credito.fn_tag('Faturamento comprometido acima do permitido', '-');                                                             
    
  END IF;                        
    
    vr_string := vr_string||'</campos></subcategoria>';
    -- Fim Resumo das Informações do Titular               
    
    -- SCR
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>SCR</tituloTela>'||
                              '<campos>';
                              
    vr_tab_tabela.delete;
      vr_existe := FALSE;
    --FOR rw_nrconbir IN cr_nrconbir LOOP
    FOR rw_modalidade IN cr_modalidade(prc_nrconbir => vr_nrconbir,
                                       prc_nrcpfcgc => pr_nrcpfcgc)LOOP
        vr_existe := TRUE;
        --
        vr_string := vr_string||'<campo>
                                 <nome>' || rw_modalidade.modalidade ||'</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
        --
        vr_tab_tabela(1).coluna1 := to_char(nvl(rw_modalidade.vpercve_31d_60d, 0),'999g999g990d00');
        vr_tab_tabela(1).coluna2 := to_char(nvl(rw_modalidade.vpercve_61d_90d, 0),'999g999g990d00');
        --
        vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
        --
        vr_string := vr_string||'</linhas>
                                 </valor>
                                 </campo>';
      END LOOP;
    --END LOOP;
      IF NOT vr_existe THEN
        vr_string := vr_string||'<campo>
                                 <nome>' || 'Modalidade' ||'</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
    --
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        --
        vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
        --
        vr_string := vr_string||'</linhas>
                                 </valor>
                                 </campo>';        
      END IF;
      --
    vr_string := vr_string||'</campos>';
                     
    end if;  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);

    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
    
    EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_SCR - '||SQLERRM;
      vr_string := '<categoria>'||
                       '<tituloTela>SCR</tituloTela>'||
                       '<tituloFiltro>scr</tituloFiltro>'||
                       '<subcategorias>'||
                             '<subcategoria>'||
                                 '<erros>'||
                                     '<erro>'||
                                         '<cdcritic>0</cdcritic>'||
                                         '<dscritic>'||pr_dscritic||'</dscritic>'||
                                     '</erro>'||
                                 '</erros>';
                                 
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);  
                  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;                                       

  END pc_consulta_scr_ncoop;

PROCEDURE pc_consulta_scr_conj_ncoop(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                                    ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE         --> CPFCGC
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                    ,pr_dsxmlret OUT CLOB) IS                     --> Arquivo de retorno do XML
  /* .............................................................................
    Programa: pc_consulta_scr_conj_ncoop
    Sistema : Aimaro/Ibratan
    Autor   : Rubens Lima (Mouts)
    Data    : Agosto/2019                 Ultima atualizacao: 
    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Consulta SCR do Cônjuge não cooperado
    Alteracoes:
  ..............................................................................*/
  vr_dsxmlret CLOB;
  vr_string   CLOB;
  --Variáveis para o birô
  vr_nrconbir crapcbd.nrconbir%TYPE;
  vr_nrseqdet crapcbd.nrseqdet%TYPE;
  --Exception
  vr_notfound EXCEPTION;
  /*Consulta se o conjuge faz parte da proposta (co-responsavel) */
  CURSOR c_busca_conjuge_biro (pr_cdcooper IN crapcop.cdcooper%TYPE,
                               pr_nrconbir IN crapcbd.nrconbir%TYPE,
                               pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
   SELECT 1 
    FROM tbgen_modalidade_biro
    WHERE nrconbir = pr_nrconbir
    AND   nrcpfcgc = pr_nrcpfcgc;                               
   r_busca_conjuge_biro c_busca_conjuge_biro%ROWTYPE;
  CURSOR c_crapcbd(pr_nrconbir crapcbd.nrconbir%TYPE, pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) IS
   SELECT fn_tag('Data da Consulta', to_char(crapcbd.dtreapro,'DD/MM/YYYY')) datareaproveitamento,
          fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'Não','Sim')) reaproveitamento,
          fn_tag('Data-base Bacen', CASE WHEN crapcbd.dtbaseba IS NOT NULL THEN to_char(crapcbd.dtbaseba, 'MM/YYYY') ELSE '-' END) databasebacen -- Data base bacen
     FROM crapcbd
    WHERE crapcbd.nrconbir = pr_nrconbir
      AND crapcbd.nrcpfcgc = pr_nrcpfcgc
      AND crapcbd.cdbircon = 3; -- SRC Bacen Completo
  r_crapcbd c_crapcbd%ROWTYPE;
  --
  CURSOR cr_modalidade(prc_nrconbir tbgen_modalidade_biro.nrconbir%type,
                       prc_nrcpfcgc tbgen_modalidade_biro.nrcpfcgc%TYPE
                       ) IS
    SELECT DISTINCT 'Modalidade - '||a.cdmodbir||' - '||REPLACE(SUBSTR(to_char(a.xmlmodal),2,INSTR(to_char(a.xmlmodal),'>')-2),'_',' ') Modalidade
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_31D_60D'||'>[^<]*'),'<'||'VPERCVE_31D_60D'||'>',null),'.',',') VPERCVE_31D_60D
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_61D_90D'||'>[^<]*'),'<'||'VPERCVE_61D_90D'||'>',null),'.',',') VPERCVE_61D_90D
     FROM tbgen_modalidade_biro a
    WHERE a.nrconbir = prc_nrconbir
      AND a.nrcpfcgc = prc_nrcpfcgc;
  --
  BEGIN
    vr_cdcritic := 0;
    vr_dscritic := null;
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    vr_string := '<categoria>'||
                 '<tituloTela>SCR</tituloTela>'||
                 '<tituloFiltro>scr</tituloFiltro>'||
                 '<subcategorias>';
    /*Busca o número do birô do titular*/
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => vr_nrdconta_principal,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    /*Verifica se o conjuge faz parte (co-participacao)*/
    OPEN c_busca_conjuge_biro (pr_cdcooper => pr_cdcooper,
                               pr_nrconbir => vr_nrconbir,
                               pr_nrcpfcgc => pr_nrcpfcgc);
     FETCH c_busca_conjuge_biro INTO r_busca_conjuge_biro;
     IF c_busca_conjuge_biro%NOTFOUND THEN
       RAISE vr_notfound;
     END IF;
    CLOSE c_busca_conjuge_biro;
    -- Resumo das Informações do Titular
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>Resumo das Informações do Cônjuge</tituloTela>'||
                               '<campos>';
    OPEN c_crapcbd(pr_nrconbir => vr_nrconbir,
                   pr_nrcpfcgc => vr_nrcpfcgc_principal);
     FETCH c_crapcbd INTO r_crapcbd;
    IF c_crapcbd%FOUND THEN
    CLOSE c_crapcbd;
      vr_string := vr_string || r_crapcbd.datareaproveitamento||
                                r_crapcbd.reaproveitamento||
                                r_crapcbd.databasebacen;
    END IF;
    vr_string := vr_string||'</campos></subcategoria>';
    -- Fim Resumo das Informações - É a mesma do titular
    -- SCR
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>SCR</tituloTela>'||
                              '<campos>';
    vr_tab_tabela.delete;
    FOR rw_modalidade IN cr_modalidade(prc_nrconbir => vr_nrconbir,
                                       prc_nrcpfcgc => pr_nrcpfcgc)LOOP
        vr_string := vr_string||'<campo>
                                 <nome>' || rw_modalidade.modalidade ||'</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
        --
        vr_tab_tabela(1).coluna1 := to_char(nvl(rw_modalidade.vpercve_31d_60d, 0),'999g999g990d00');
        vr_tab_tabela(1).coluna2 := to_char(nvl(rw_modalidade.vpercve_61d_90d, 0),'999g999g990d00');
        --
        vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
        --
        vr_string := vr_string||'</linhas>
                                 </valor>
                                 </campo>';
      END LOOP;
    vr_string := vr_string||'</campos>';
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
    EXCEPTION
    WHEN vr_notfound THEN
      vr_string := vr_string ||
                   '<subcategoria>
                        <tituloTela>Consulta</tituloTela>
                        <tituloFiltro>consula</tituloFiltro>
                        <campos>
                            <campo>
                                <nome>Cônjuge Não Cooperado</nome>
                                <tipo>string</tipo>
                                <valor>Não possui dados para apresentação</valor>
                            </campo>
                        </campos>';
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
    WHEN OTHERS THEN
      /* Tratar erro */
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_SCR - '||SQLERRM;
      vr_string := '<categoria>'||
                       '<tituloTela>SCR</tituloTela>'||
                       '<tituloFiltro>scr</tituloFiltro>'||
                       '<subcategorias>'||
                             '<subcategoria>'||
                                 '<erros>'||
                                     '<erro>'||
                                         '<cdcritic>0</cdcritic>'||
                                         '<dscritic>'||pr_dscritic||'</dscritic>'||
                                     '</erro>'||
                                 '</erros>';
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo => '</subcategoria>',
                  pr_fecha_xml => TRUE);
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  END pc_consulta_scr_conj_ncoop;
  PROCEDURE pc_consulta_operacoes(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                               ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                               ,pr_nrctrato  in crawepr.nrctremp%type
                               ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                               ,pr_dsxmlret OUT CLOB) is
    /*Categoria Operações*/
  
    vr_dsxmlret CLOB;
    vr_string   CLOB;
  
    /*Variáveis do totalizador das co-resnponsabilidade*/
    --Saldo Devedor, 
    vr_tot_saldo_devedor number(25,2) :=0;

    --Prest Pagas / Total, 
    vr_tot_prestacoes_pagas_empr number :=0;
    vr_tot_prestacoes_empr      number :=0;
    --Valor das Prestações.
    vr_tot_valor_prestacoes number(25,2) :=0;
    vr_tot_valor_atraso     number(25,2) :=0;

   PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                               ,pr_cdcooper IN crapbdt.cdcooper%TYPE) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_busca_borderos
        Sistema : Aimaro/Ibratan
        Autor   : Mateus Zimmermann (Mouts)
        Data    : Março/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que lista os borderos
        
        Alteracoes: 30/05/2019 - Editado nome de campo, e mudanca de ordem de apresentacao.
                                 Story 21164 - PRJ438 - Gabriel Marcos (Mouts).
      
      ---------------------------------------------------------------------------------------------------------------------*/
    
      vr_dt_aux_dtmvtolt DATE;
      vr_dt_aux_dtlibbdt DATE;
    
      -- Tratamento de erros
      vr_exc_erro exception;
    
      vr_qt_tot_borderos NUMBER;
      vr_vl_tot_borderos NUMBER;
      vr_qt_tot_titulos  NUMBER;
    
      vr_flgverbor INTEGER;
    
      ---------->>> CURSORES <<<----------
      --> Buscar bordero de desconto de titulo
      CURSOR cr_crapbdt IS
        SELECT bdt.dtmvtolt,
               bdt.nrdconta,
               bdt.nrctrlim,
               bdt.insitbdt,
               bdt.dtlibbdt,
               bdt.nrborder,
               bdt.cdcooper,
               bdt.insitapr
          FROM crapbdt bdt
       WHERE
            bdt.cdcooper = pr_cdcooper
           AND bdt.nrdconta = pr_nrdconta
           AND bdt.insitbdt = 3
         ORDER BY bdt.nrborder DESC;
      rw_crapbdt cr_crapbdt%ROWTYPE;
    

      -- Buscar os títulos
      CURSOR cr_craptdb(pr_cdcooper craptdb.cdcooper%TYPE
                       ,pr_nrdconta craptdb.nrdconta%TYPE
                       ,pr_nrborder craptdb.nrborder%TYPE) IS
      SELECT craptdb.vltitulo,
             craptdb.vlsldtit,
             craptdb.insitapr,
             craptdb.nrcnvcob
          FROM craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.nrdconta = pr_nrdconta
           AND craptdb.nrborder = pr_nrborder
         AND (craptdb.insittit = 4 
           OR craptdb.insittit = 2
          AND craptdb.dtdpagto = rw_crapdat.dtmvtolt);
    
      CURSOR cr_crapcco(pr_cdcooper craptdb.cdcooper%TYPE
                       ,pr_nrcnvcob craptdb.nrcnvcob%TYPE) IS
        SELECT crapcco.flgregis
          FROM crapcco
         WHERE crapcco.cdcooper = pr_cdcooper
           AND crapcco.nrconven = pr_nrcnvcob;
      rw_crapcco cr_crapcco%ROWTYPE;
    
    BEGIN
    
      vr_qt_tot_borderos := 0;
      vr_vl_tot_borderos := 0;
      vr_qt_tot_titulos  := 0;
    
      vr_dt_aux_dtmvtolt := rw_crapdat.dtmvtolt - 120;
      vr_dt_aux_dtlibbdt := rw_crapdat.dtmvtolt - 90;
    
      -- abrindo cursor de títulos
      OPEN cr_crapbdt;
      LOOP
            FETCH cr_crapbdt INTO rw_crapbdt;
        EXIT WHEN cr_crapbdt%NOTFOUND;
      
        IF (rw_crapbdt.dtmvtolt <= vr_dt_aux_dtmvtolt AND (rw_crapbdt.insitbdt IN (1, 2))) THEN
          CONTINUE;
        END IF;
      
             IF (rw_crapbdt.dtlibbdt is not null and rw_crapbdt.dtmvtolt <= vr_dt_aux_dtlibbdt AND ( rw_crapbdt.insitbdt IN(4))) THEN
          CONTINUE;
        END IF;
      
        vr_qt_tot_borderos := vr_qt_tot_borderos + 1;
      
        -- Buscar os titulos
             FOR rw_craptdb IN cr_craptdb(pr_cdcooper => rw_crapbdt.cdcooper
                                         ,pr_nrdconta => rw_crapbdt.nrdconta
                                         ,pr_nrborder => rw_crapbdt.nrborder) LOOP
        
                 OPEN cr_crapcco (pr_cdcooper => rw_crapbdt.cdcooper
                                 ,pr_nrcnvcob => rw_craptdb.nrcnvcob);
                  FETCH cr_crapcco INTO rw_crapcco;
          IF cr_crapcco%FOUND THEN
          
            IF rw_crapcco.flgregis = 1 THEN
              vr_vl_tot_borderos := vr_vl_tot_borderos + rw_craptdb.vlsldtit;
              vr_qt_tot_titulos  := vr_qt_tot_titulos + 1;
            END IF;
          
          END IF;
          CLOSE cr_crapcco;
        
        END LOOP;
      
      END LOOP;
      CLOSE cr_crapbdt;
    
        vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Rotativos Ativos - Produto Bôrdero de Desconto de Título</tituloTela>'||
                   '<campos>';
    
      vr_string := vr_string || fn_tag('Quantidade Total de Borderôs', vr_qt_tot_borderos) ||
                   fn_tag('Quantidade Total de Boletos', vr_qt_tot_titulos) ||
                   fn_tag('Valor Total de Borderôs', to_char(vr_vl_tot_borderos, '999g999g990d00'));
    
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - ' || SQLERRM;
        vr_string := vr_string||'<erros><erro>'||
                                '<dscritic> PC_BUSCA_BORDEROS -> '||pr_dscritic||'</dscritic>'||
                                '</erro></erros>';       
      
    END pc_busca_borderos;
  
  PROCEDURE pc_busca_propostas_ativas (pr_cdcooper IN crapepr.cdcooper%TYPE
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_busca_propostas_ativas
        Sistema : Aimaro/Ibratan
        Autor   : Mateus Zimmermann (Mouts)
        Data    : Março/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que lista as propostas ativas
      ---------------------------------------------------------------------------------------------------------------------*/
    
      -- Váriaveis
      vr_index                      NUMBER;
      tot_vlsdeved                  NUMBER;
      tot_vlpreemp                  NUMBER;
      tot_qtd_parcelas_atraso       NUMBER;
      tot_vl_parcelas_atraso        NUMBER;
      tot_qtd_prestacoe_pagas       NUMBER;
      tot_qtd_prestacoe             NUMBER;      
      vr_liquidar                   VARCHAR2(15);
      vr_lista_contratos_liquidados VARCHAR2(100) := '';
      vr_vlsdeved                   NUMBER;
      vr_risco_inclusao             VARCHAR2(5) := '';
    
      -- variaveis de retorno
      vr_des_reto        VARCHAR2(3);
      vr_tab_dados_epr   empr0001.typ_tab_dados_epr;
      vr_tab_erro        gene0001.typ_tab_erro;
      vr_qtregist        NUMBER;
      vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
    
      --Variaveis para busca de parametros
      vr_dstextab            craptab.dstextab%TYPE;
      vr_dstextab_parempctl  craptab.dstextab%TYPE;
      vr_dstextab_digitaliza craptab.dstextab%TYPE;
    
      --Indicador de utilização da tabela
      vr_inusatab      BOOLEAN;
      vr_nrctaava1_aux number := 0;
      vr_nrctaava2_aux number := 0;
    
      ---------->>> CURSORES <<<----------
      CURSOR cr_crawepr IS
        SELECT a.nrctrliq##1 || ',' ||
               a.nrctrliq##2 || ',' ||
               a.nrctrliq##3 || ',' ||
               a.nrctrliq##4 || ',' ||
               a.nrctrliq##5 || ',' ||
               a.nrctrliq##6 || ',' ||
               a.nrctrliq##7 || ',' ||
               a.nrctrliq##8 || ',' ||
               a.nrctrliq##9 || ',' ||
               a.nrctrliq##10 lista_contratos_liquidados
          FROM crawepr a
         WHERE a.cdcooper = pr_cdcooper
           AND a.nrdconta = pr_nrdconta
           AND a.nrctremp = pr_nrctrato;
      rw_crawepr cr_crawepr%ROWTYPE;
    
      -- Calendário da cooperativa selecionada
      CURSOR cr_dat IS
      SELECT (CASE WHEN TO_CHAR(trunc(dat.dtmvtolt), 'mm') = TO_CHAR(trunc(dat.dtmvtoan), 'mm')
                THEN dat.dtmvtoan
                ELSE dat.dtultdma END) dtmvtoan
          FROM crapdat dat
         WHERE dat.cdcooper = pr_cdcooper;
      rw_dat cr_dat%ROWTYPE;
    
      -- Dados dos riscos
      CURSOR cr_tbrisco_central(pr_nrctremp NUMBER
                              , pr_dtmvtoan DATE) IS
        SELECT RISC0004.fn_traduz_risco(ris.inrisco_inclusao) risco_inclusao
          FROM tbrisco_central_ocr ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.nrctremp = pr_nrctremp
           AND ris.dtrefere = pr_dtmvtoan;
      rw_tbrisco_central cr_tbrisco_central%ROWTYPE;
    
      /*Parcelas Vencidas*/
      CURSOR cr_crappep(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT count(1) qtd_parcelas
          FROM crappep
         WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp
               AND inliquid = 0 -- Não liquidada
               AND dtvencto <= rw_crapdat.dtmvtoan; -- Parcela Vencida      
        r_crappep cr_crappep%rowtype;
      

    BEGIN
    
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
        vr_inusatab := FALSE;
      ELSE
        IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
          --Nao usa tabela
          vr_inusatab := FALSE;
        ELSE
          --Nao usa tabela
          vr_inusatab := TRUE;
        END IF;
      END IF;
    
          empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => pr_cdcooper            --> Cooperativa conectada
                           ,pr_cdagenci       => 0                      --> Código da agência
                           ,pr_nrdcaixa       => 0                      --> Número do caixa
                           ,pr_cdoperad       => 1                      --> Código do operador
                           ,pr_nmdatela       => 'TELA_UNICA'               --> Nome datela conectada
                           ,pr_idorigem       => 5                      --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta            --> Conta do associado
                           ,pr_idseqttl       => 1                      --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => rw_crapdat             --> Vetor com dados de parâmetro (CRAPDAT)
                           ,pr_dtcalcul       => ''                     --> Data solicitada do calculo
                           ,pr_nrctremp       => 0                      --> Número contrato empréstimo
                           ,pr_cdprogra       => 0                      --> Programa conectado
                           ,pr_inusatab       => vr_inusatab            --> Indicador de utilização da tabela
                           ,pr_flgerlog       => 'N'                    --> Gerar log S/N
                           ,pr_flgcondc       => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                           ,pr_nmprimtl       => ''                     --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl  --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                           ,pr_nriniseq       => 1                      --> Numero inicial da paginacao
                           ,pr_nrregist       => 9999                   --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist            --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr       --> Saida com os dados do empréstimo
                           ,pr_des_reto       => vr_des_reto            --> Retorno OK / NOK
                                      , pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
    
      -- Garantia
      OPEN cr_crawepr;
          FETCH cr_crawepr INTO rw_crawepr;   
      CLOSE cr_crawepr;
    
      vr_lista_contratos_liquidados := rw_crawepr.lista_contratos_liquidados;
      vr_tab_tabela.delete;
    
      IF vr_tab_dados_epr.COUNT() > 0 THEN
        tot_vlsdeved := 0;
        tot_vlpreemp := 0;
        tot_qtd_parcelas_atraso :=0;
        tot_vl_parcelas_atraso  :=0;
        tot_qtd_prestacoe_pagas :=0;
        tot_qtd_prestacoe :=0;
        vr_index     := 1;
        FOR i IN 1 .. vr_tab_dados_epr.COUNT() LOOP
        
          IF vr_tab_dados_epr(i).vlsdeved <= 0 THEN
            CONTINUE;
          END IF;
        
          -- Resetar a variavel
          vr_garantia := '-';
        
          --> listar avalistas de contratos
          DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                      ,pr_cdagenci => 0  --> Código da agencia
                                      ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                                      ,pr_cdoperad => 1  --> Código do Operador
                                      ,pr_nmdatela => 'TELA_UNICA'  --> Nome da tela
                                      ,pr_idorigem => 5  --> Identificador de Origem
                                      ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                      ,pr_idseqttl => 1  --> Sequencial do titular
                                      ,pr_tpctrato => 1
                                      ,pr_nrctrato => vr_tab_dados_epr(i).nrctremp  --> Numero do contrato
                                      ,pr_nrctaav1 => 0  --> Numero da conta do primeiro avalista
                                      ,pr_nrctaav2 => 0  --> Numero da conta do segundo avalista
                                      --------> OUT <--------                                   
                                      ,pr_tab_dados_avais   => vr_tab_dados_avais   --> retorna dados do avalista
                                      ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                                     , pr_dscritic => vr_dscritic); --> Descrição da crítica
        
          IF vr_tab_dados_avais.exists(1) THEN
            vr_nrctaava1_aux := vr_tab_dados_avais(1).nrctaava;
          END IF;
        
          IF vr_tab_dados_avais.exists(2) THEN
            vr_nrctaava2_aux := vr_tab_dados_avais(2).nrctaava;
          END IF;
        
          vr_garantia := '-';
          IF vr_tab_dados_avais.exists(1) THEN
                    vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,vr_tab_dados_epr(i).nrctremp,vr_nrctaava1_aux,vr_nrctaava2_aux,'P',c_emprestimo, FALSE);   
          END IF;
          -- Liquidar  
          vr_liquidar := INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp));
          IF INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp)) > 0 THEN
            vr_liquidar := 'Sim';
          ELSE
            vr_liquidar := 'Não';
          END IF;
        
          open cr_crappep(vr_tab_dados_epr(i).nrctremp); --Bug 25739
           fetch cr_crappep into r_crappep;
             if cr_crappep%found then
               tot_qtd_parcelas_atraso := tot_qtd_parcelas_atraso+r_crappep.qtd_parcelas;
               tot_vl_parcelas_atraso  := tot_vl_parcelas_atraso+vr_tab_dados_epr(i).vltotpag;
             end if;
          close cr_crappep;
        
                  vr_vlsdeved := vr_tab_dados_epr(i).vlsdeved + vr_tab_dados_epr(i).vliofcpl + vr_tab_dados_epr(i).vlmrapar + vr_tab_dados_epr(i).vlmtapar; 
        
          tot_vlsdeved := tot_vlsdeved + vr_vlsdeved;
          tot_vlpreemp := tot_vlpreemp + vr_tab_dados_epr(i).vlpreemp;

          -- Busca calendário para a cooperativa selecionada
          OPEN cr_dat;
                  FETCH cr_dat INTO rw_dat;
          CLOSE cr_dat;
        
          -- Buscar o Risco Inclusao
                  OPEN cr_tbrisco_central (pr_nrctremp => vr_tab_dados_epr(i).nrctremp
                                          ,pr_dtmvtoan => rw_dat.dtmvtoan);
                  FETCH cr_tbrisco_central INTO rw_tbrisco_central;
          IF cr_tbrisco_central%FOUND THEN
            vr_risco_inclusao := rw_tbrisco_central.risco_inclusao;
          END IF;
          CLOSE cr_tbrisco_central;
        
          vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(vr_tab_dados_epr(i).nrctremp); -- Contrato
          vr_tab_tabela(vr_index).coluna2 := CASE WHEN vr_risco_inclusao IS NULL THEN '-' ELSE vr_risco_inclusao END; -- Risco Inclusão
          vr_tab_tabela(vr_index).coluna3 := trim(to_char(vr_vlsdeved,'999g999g990d00')); -- Saldo Devedor
          vr_tab_tabela(vr_index).coluna4 := substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11); -- Prestações
          
          --Totalizador prestações
          tot_qtd_prestacoe_pagas  := tot_qtd_prestacoe_pagas + to_number(substr(substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11),1,instr(substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11),'/')-1));
          tot_qtd_prestacoe        := tot_qtd_prestacoe       + to_number(substr(substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11),instr(substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11),'/')+1));
          
          vr_tab_tabela(vr_index).coluna5 := to_char(vr_tab_dados_epr(i).vlpreemp, '999g999g990d00'); -- Valor Prestações
         
          vr_tab_tabela(vr_index).coluna6 := CASE WHEN vr_tab_dados_epr(i).vltotpag > 0 THEN to_char(vr_tab_dados_epr(i).vltotpag,'999g999g990d00') ELSE '0' END; -- A pagar/Parcela
          --vr_tab_tabela(vr_index).coluna6 := CASE WHEN vr_tab_dados_epr(i).vltotpag > 0 THEN to_char(vr_tab_dados_epr(i).vltotpag,'999g999g990d00')||' / '||to_char(r_crappep.qtd_parcelas) ELSE '0 / 0' END; -- A pagar/Parcela
         
          vr_tab_tabela(vr_index).coluna7 := vr_tab_dados_epr(i).dsfinemp; -- Finalidade
          vr_tab_tabela(vr_index).coluna8 := vr_tab_dados_epr(i).dslcremp; -- Linha de Crédito
          vr_tab_tabela(vr_index).coluna9 := trim(to_char(vr_tab_dados_epr(i).txmensal,'990D000000')); -- Taxa
          vr_tab_tabela(vr_index).coluna10 := CASE WHEN vr_garantia IS NULL THEN '-' ELSE vr_garantia END; -- Garantia
          vr_tab_tabela(vr_index).coluna11 := CASE WHEN vr_liquidar IS NULL THEN '-' ELSE vr_liquidar END; -- Liquidar
          vr_tab_tabela(vr_index).coluna12 := CASE WHEN nvl(r_crappep.qtd_parcelas,0) =  0 THEN 'Sem Atrasos' ELSE 'Em Atraso' END; -- Pontualidade
          vr_index := vr_index + 1;
        
        END LOOP;
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
        vr_tab_tabela(1).coluna8 := '-';
        vr_tab_tabela(1).coluna9 := '-';
        vr_tab_tabela(1).coluna10 := '-';
        vr_tab_tabela(1).coluna11 := '-';
        vr_tab_tabela(1).coluna12 := '-';
      END IF;
    
      -- Colocar a linha de Totais --bug 20882
      IF vr_tab_tabela.COUNT() > 1 THEN
      
        vr_tab_tabela(vr_index).coluna1 := 'Total';
        vr_tab_tabela(vr_index).coluna2 := '-';
              vr_tab_tabela(vr_index).coluna3 := case when tot_vlsdeved > 0 then 
                                                    to_char(tot_vlsdeved,'999g999g990d00') else '-' end; -- Saldo Devedor
        vr_tab_tabela(vr_index).coluna4 := tot_qtd_prestacoe_pagas||' / '||tot_qtd_prestacoe;
        
        
              vr_tab_tabela(vr_index).coluna5 := case when tot_vlpreemp > 0 then
                                                    to_char(tot_vlpreemp,'999g999g990d00') else '-' end; -- Valor Prestações
        vr_tab_tabela(vr_index).coluna6 := case when tot_qtd_parcelas_atraso > 0 then
                                                     --to_char(tot_vl_parcelas_atraso,'999g999g990d00')||' / '||to_char(tot_qtd_parcelas_atraso) else '-' end; -- A pagar/Parcelas Retirado - Pedido Sirlei
                                                     to_char(tot_vl_parcelas_atraso,'999g999g990d00') else '-' end; -- A pagar/Parcelas
               
        vr_tab_tabela(vr_index).coluna7 := '-';
        vr_tab_tabela(vr_index).coluna8 := '-';
        vr_tab_tabela(vr_index).coluna9 := '-';
        vr_tab_tabela(vr_index).coluna10 := '-';
        vr_tab_tabela(vr_index).coluna11 := '-';
        vr_tab_tabela(vr_index).coluna12 := '-';
      
      END IF;
    
      -- Se a tabela estiver vazia
      IF vr_tab_tabela.COUNT() = 0 THEN
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
        vr_tab_tabela(1).coluna8 := '-';
        vr_tab_tabela(1).coluna9 := '-';
        vr_tab_tabela(1).coluna10 := '-';
        vr_tab_tabela(1).coluna11 := '-';
        vr_tab_tabela(1).coluna12 := '-';
      END IF;
    
      vr_string := vr_string || '<subcategoria>' ||
                                    '<tituloTela>Operações de Crédito Ativas - Empréstimo e Financiamento</tituloTela>'||
                                    '<campos>';
    
      vr_string := vr_string || '<campo>
                                   <nome>Propostas Ativas</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';
    
          vr_string := vr_string||fn_tag_table('Contrato;Risco Inclusão;Saldo Devedor;Prestações;Valor Prestações;Atraso a Pagar;Finalidade;Linha de Crédito;Taxa;Garantia;Liquidar;Pontualidade', vr_tab_tabela);
    
      vr_string := vr_string || '</linhas>
                                   </valor>
                                   </campo>';
    
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - ' || SQLERRM;
            vr_string := vr_string||'<erros><erro>'||
                                    '<dscritic> PC_BUSCA_BORDEROS -> '||pr_dscritic||'</dscritic>'||
                                    '</erro></erros>';                           
      
    END pc_busca_propostas_ativas;
  
  PROCEDURE pc_busca_consorcio(pr_cdcooper IN crapbdt.cdcooper%TYPE
                              ,pr_nrdconta IN crapbdt.nrdconta%TYPE) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_busca_consorcio
        Sistema : Aimaro/Ibratan
        Autor   : Mateus Zimmermann (Mouts)
        Data    : Março/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que lista os borderos
      ---------------------------------------------------------------------------------------------------------------------*/
    
      vr_index NUMBER;
    
      ---------->>> CURSORES <<<----------
      -- Buscar os consorcios
      CURSOR cr_crapcns IS
        SELECT crapcns.*
          FROM crapcns
         WHERE crapcns.cdcooper = pr_cdcooper
           AND crapcns.nrdconta = pr_nrdconta
           AND crapcns.flgativo = 1;
      rw_crapcns cr_crapcns%ROWTYPE;
    
    BEGIN
    
      vr_index := 1;
      vr_tab_tabela.delete;
      -- Buscar os consorcios       
      FOR rw_crapcns IN cr_crapcns LOOP
      
        vr_tab_tabela(vr_index).coluna1 := to_char(rw_crapcns.vlrcarta, '999g999g990d00'); -- Valor da carta do consórcio
        vr_tab_tabela(vr_index).coluna2 := rw_crapcns.qtparpag; -- Parcelas pagas
        vr_tab_tabela(vr_index).coluna3 := rw_crapcns.qtparres; -- Parcelas restantes
        vr_tab_tabela(vr_index).coluna4 := to_char(rw_crapcns.vlparcns, '999g999g990d00'); -- Valor parcela
      
        vr_index := vr_index + 1;
      
      END LOOP;
    
        vr_string := vr_string || 
                   '<subcategoria>'||
                   '<tituloTela>Operações de Crédito Ativas - Consórcio</tituloTela>'||
                   '<campos>';
    
      IF vr_tab_tabela.COUNT > 0 THEN
      
        vr_string := vr_string || fn_tag('Tem consórcio ativo na cooperativa', 'Sim');
      
        vr_string := vr_string || '<campo>
                                     <nome>Consórcios Ativos</nome>
                                     <tipo>table</tipo>
                                     <valor>
                                     <linhas>';
      
            vr_string := vr_string||fn_tag_table('Valor da Carta;Parcelas Pagas;Parcelas Restantes;Valor da Parcela', vr_tab_tabela);
      
        vr_string := vr_string || '</linhas>
                                     </valor>
                                     </campo>';
      
      ELSE
      
        vr_string := vr_string || fn_tag('Tem consórcio ativo na cooperativa', 'Não');
      
        vr_tab_tabela(1).coluna1 := '-'; -- Valor da carta do consórcio
        vr_tab_tabela(1).coluna2 := '-'; -- Parcelas pagas
        vr_tab_tabela(1).coluna3 := '-'; -- Parcelas restantes
        vr_tab_tabela(1).coluna4 := '-'; -- Valor parcela
      
        vr_string := vr_string || '<campo>
                                     <nome>Consórcios Ativos</nome>
                                     <tipo>table</tipo>
                                     <valor>
                                     <linhas>';
      
            vr_string := vr_string||fn_tag_table('Valor da Carta;Parcelas Pagas;Parcelas Restantes;Valor da Parcela', vr_tab_tabela);
      
        vr_string := vr_string || '</linhas>
                                     </valor>
                                     </campo>';
      
      END IF;
    
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - ' || SQLERRM;
            vr_string := vr_string||'<erros><erro>'||
                                    '<dscritic> PC_CONSULTA_CONSORCIO -> '||pr_dscritic||'</dscritic>'||
                                    '</erro></erros>';
      
    END pc_busca_consorcio;
  
    ---------------------------------------------------------------
    PROCEDURE pc_plano_capital(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                            ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                            ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                               ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_plano_capital
        Sistema : Aimaro/Ibratan
        Autor   : Marcelo Telles Coelho (Mouts)
        Data    : Março/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca as informações de plano de capital
      ---------------------------------------------------------------------------------------------------------------------*/
      --
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT *
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      --
    CURSOR cr_cdempres (pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
        SELECT cdempres
          FROM crapttl
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND idseqttl = 1
           AND pr_inpessoa = 1
        UNION
        SELECT cdempres
          FROM crapjur
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND pr_inpessoa = 2;
      rw_cdempres cr_cdempres%ROWTYPE;
      --
    CURSOR cr_crapemp (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_cdempres IN crapemp.cdempres%TYPE) IS
        SELECT *
          FROM crapemp
         WHERE cdcooper = pr_cdcooper
           AND cdempres = pr_cdempres;
      rw_crapemp cr_crapemp%ROWTYPE;
      --
    CURSOR cr_crappla (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT *
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
         and dtcancel is null; --bug 19828
      rw_crappla cr_crappla%ROWTYPE;
      --
    
    CURSOR cr_vlcapital(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    select vldcotas 
      from crapcot 
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta;
      --
    r_vlcapital cr_vlcapital%rowtype;
    
    
      --
      -- Variaveis de Trabalho
      vr_idexiste_crappla NUMBER;
      vr_vlprepla         NUMBER;
      -- Exceptions
      vr_exc_erro EXCEPTION;
    
    vr_vlstotal number;

    BEGIN -- inicio

      pr_dsxmlret := null;
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        pr_cdcritic := 9;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapass;
      --
      OPEN cr_cdempres (pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_inpessoa => rw_crapass.inpessoa);
      FETCH cr_cdempres INTO rw_cdempres;
      IF cr_cdempres%NOTFOUND THEN
        CLOSE cr_cdempres;
        pr_dscritic := 'Empresa do associado não encontrada!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_cdempres;
      --
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_cdempres => rw_cdempres.cdempres);
      FETCH cr_crapemp INTO rw_crapemp;
      IF cr_crapemp%NOTFOUND THEN
        CLOSE cr_crapemp;
        pr_cdcritic := 40;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapemp;
      --
      --
      vr_idexiste_crappla := 1;
      --
      OPEN cr_crappla (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crappla INTO rw_crappla;
      IF cr_crappla%NOTFOUND THEN
        vr_idexiste_crappla := 0;
      END IF;
      CLOSE cr_crappla;
      --
      IF vr_idexiste_crappla = 1 THEN
        -- Se associado possui um plano, carrega dados do mesmo
        vr_vlprepla := rw_crappla.vlprepla;
      ELSE
        vr_vlprepla := 0;
      END IF;
      --
      vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Resumo da Conta</tituloTela>'||
                   '<campos>';
    
      -- Buscar dados da atenda 
      pc_busca_dados_atenda(pr_cdcooper => vr_cdcooper_principal,
                            -- bug 19891 
                            --pr_nrdconta => vr_nrdconta_principal);            
                            pr_nrdconta => pr_nrdconta);
      --                               
      vr_vlstotal := vr_tab_valores_conta(1).vlstotal;
      vr_string   := vr_string ||
      fn_tag('Depósito à Vista',TO_CHAR(vr_vlstotal,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
    
      vr_string := vr_string || '<campo>
                                <tipo>h3</tipo>
                                <valor>Plano de Capital</valor>
                                </campo>';
    
      /*Valor do Capital*/
      open cr_vlcapital(pr_cdcooper,pr_nrdconta);
       fetch cr_vlcapital into r_vlcapital;     
      close cr_vlcapital;      
    
      -- Gera Tags Xml
      vr_string := vr_string
                  --|| fn_tag('Valor do Plano'             ,TO_CHAR(vr_vlprepla,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                || fn_tag('Capital'                    ,TO_CHAR(r_vlcapital.vldcotas,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))                
                || fn_tag('Plano de Cotas'             ,TO_CHAR(vr_vlprepla,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
      --|| fn_tag('Atualização Automática'     ,vr_dstipcor)
      --|| fn_tag('Debitar Em'                 ,vr_dsdebitar_em)
      --|| fn_tag('Quantidade de Prestações'   ,vr_qtpremax)
      --|| fn_tag('Data de Início'             ,TO_CHAR(vr_dtdpagto,'dd/mm/yyyy'))
      --|| fn_tag('Data da Última Atualização' ,TO_CHAR(vr_dtultcor,'dd/mm/yyyy'))
      --|| fn_tag('Data da Próxima Atualização',TO_CHAR(vr_dtprocor,'dd/mm/yyyy'))
      --|| fn_tag('Tipo de Autorização'        ,vr_tpautori);
      --vr_string := vr_string||'</campos></subcategoria>';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic IS NOT NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        END IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - ' || SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic> PC_PLANO_CAPITAL ->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
    END pc_plano_capital;
    ---------------------------------------------------------------
    PROCEDURE pc_medias(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                      ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                      ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                        ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_medias
        Sistema : Aimaro/Ibratan
        Autor   : Marcelo Telles Coelho (Mouts)
        Data    : Março/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca as médias de deposito a vista
      ---------------------------------------------------------------------------------------------------------------------*/
      -- Tabelas de retorno da procedure PC_CARREGA_MEDIAS
      vr_tab_medias      cecred.extr0001.typ_tab_medias;
      vr_tab_comp_medias cecred.extr0001.typ_tab_comp_medias;
      -- Exceptions
      vr_exc_erro EXCEPTION;
    
  BEGIN -- inicio
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      --
    extr0001.pc_carrega_medias(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => NULL         --> Não gerar log
                              ,pr_nrdcaixa => NULL         --> Não gerar log
                              ,pr_cdoperad => NULL         --> Não gerar log
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_idorigem => 5
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'TELA_UNICA'
                              ,pr_flgerlog => 0            --> Não gerar log
                              ,pr_tab_medias      => vr_tab_medias
                              ,pr_tab_comp_medias => vr_tab_comp_medias
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic);
      --
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      --
      /*  vr_string := vr_string ||
      '<subcategoria>'||
      '<tituloTela>Resumo da Conta - Médias</tituloTela>'||
      '<campos>';*/
    
      vr_string := vr_string || '<campo>
                                <tipo>h3</tipo>
                                <valor>Médias</valor>
                                </campo>';
    
      /*FOR I IN 1..vr_tab_medias.count() LOOP
        vr_string := vr_string
                  || fn_tag(vr_tab_medias(I).periodo,vr_tab_medias(I).vlsmstre);
      END LOOP;*/
      --
      FOR I IN 1 .. vr_tab_comp_medias.COUNT() LOOP
        vr_string := vr_string
                    --|| fn_tag('Mês Atual'                     ,TO_CHAR(vr_tab_comp_medias(I).vltsddis,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                || fn_tag('Trimestre'                     ,TO_CHAR(vr_tab_comp_medias(I).vlsmdtri,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                || fn_tag('Semestre'                      ,TO_CHAR(vr_tab_comp_medias(I).vlsmdsem,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
        --|| fn_tag('Média Negativa do Mês'         ,TO_CHAR(vr_tab_comp_medias(I).vlsmnmes,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
      --|| fn_tag('Média Negativa Especial do Mês',TO_CHAR(vr_tab_comp_medias(I).vlsmnesp,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
      --|| fn_tag('Média Saques sem Bloqueio'     ,TO_CHAR(vr_tab_comp_medias(I).vlsmnblq,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
      --|| fn_tag('Dias Úteis no Mês'             ,vr_tab_comp_medias(I).qtdiaute)
      --|| fn_tag('Dias Úteis Decorridos'         ,vr_tab_comp_medias(I).qtdiauti);
      END LOOP;
      --
      --vr_string := vr_string||'</campos></subcategoria>';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic IS NOT NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        END IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>PC_MEDIAS->'||pr_dscritic||'</dscritic>'||
                     '</erro></erros>';
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_medias - ' || SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                       '</erro></erros>';
    END pc_medias;
  

    PROCEDURE pc_aplicacoes(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                          ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                          ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_aplicacoes
        Sistema : Aimaro/Ibratan
        Autor   : Paulo Martins (Mouts)
        Data    : Abril/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca valores de aplicações
      ---------------------------------------------------------------------------------------------------------------------*/
    
    vr_vlsldtot number := 0;
    vr_vlsldrgt number := 0;
    
  begin
  
     vr_cdcritic := null;
     vr_dscritic := null;
    
      vr_string := vr_string || '<campo>
                               <tipo>h3</tipo>
                               <valor>Aplicações</valor>
                               </campo>';
    
      -- Buscar dados da atenda 
      pc_busca_dados_atenda(pr_cdcooper => pr_cdcooper,
                            --bug 19891 pr_nrdconta => vr_nrdconta_principal);
                            pr_nrdconta => pr_nrdconta);
      --                               
    
      vr_vlsldtot := vr_tab_valores_conta(1).vlsldapl;
      vr_vlsldrgt := vr_tab_valores_conta(1).vlsldppr;
    
    
     
      /*     APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
      ,pr_cdoperad => '1'           --> Código do Operador
      ,pr_nmdatela => 'TELA_ANALISE_CREDITO'   --> Nome da Tela
      ,pr_idorigem => 1   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
      ,pr_nrdconta => pr_nrdconta   --> Número da Conta
      ,pr_idseqttl => 1   --> Titular da Conta
      ,pr_nraplica => 0             --> Número da Aplicação / Parâmetro Opcional
      ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data de Movimento
      ,pr_cdprodut => 0             --> Código do Produto -–> Parâmetro Opcional
      ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas)
      ,pr_idgerlog => 0             --> Identificador de Log (0 – Não / 1 – Sim)
      ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplicação
      ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
      ,pr_cdcritic => vr_cdcritic   --> Código da crítica
      ,pr_dscritic => vr_dscritic); --> Descrição da crítica*/
    
      vr_string := vr_string || fn_tag('Total de Aplicações', to_char(vr_vlsldtot, '999g999g990d00')) ||
                   fn_tag('Total Poupança Programada', to_char(vr_vlsldrgt, '999g999g990d00'));
    
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic IS NOT NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        END IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>PC_APLICACOES ->'||pr_dscritic||'</dscritic>'||
                     '</erro></erros>';
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_aplicacoes - ' || SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                       '</erro></erros>';
    END pc_aplicacoes;
    ---------------------------------------------------------------
    PROCEDURE pc_emprestimos_liquidados(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                      ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                                        ) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_emprestimos_liquidados
        Sistema : Aimaro/Ibratan
        Autor   : Marcelo Telles Coelho (Mouts)
        Data    : Abril/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca emprestimos liquidados
      ---------------------------------------------------------------------------------------------------------------------*/
    CURSOR cr_crapfin (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT cdfinemp ||' - '||
             dsfinemp dsfinalidade
          FROM crapfin
         WHERE cdcooper = pr_cdcooper
           AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;
      --
    CURSOR cr_craplcr (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT cdlcremp ||' - '||
             dslcremp dslinha_credito
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
      --
    CURSOR cr_craplem (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT MAX(dtmvtolt) dtliquidacao
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
         and EXISTS (SELECT 1
                  FROM craphis
                 WHERE cdcooper = pr_cdcooper
                   AND cdhistor = craplem.cdhistor
                   AND indebcre = 'C');
      rw_craplem cr_craplem%ROWTYPE;
      --
    CURSOR cr_crapris (pr_cdcooper IN crapass.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_nrctremp IN crapris.nrctremp%TYPE
                      ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT CASE
               WHEN max(qtdiaatr) = 0   THEN 'Sem Atrasos'
               WHEN max(qtdiaatr) <= 60 THEN 'Ate 60 dias'
               WHEN max(qtdiaatr) > 60  THEN 'Mais 60 dias ou renegociacoes'
               END dspontualidade
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtrefere <= LAST_DAY(pr_dtrefere)
           AND inddocto = 1;
      rw_crapris cr_crapris%ROWTYPE;
      --
      -- Variaveis de trabalho
      vr_index NUMBER;
      -- Exceptions
      vr_exc_erro EXCEPTION;
    
  BEGIN -- inicio
      pr_cdcritic := NULL;
      pr_dscritic := NULL;
      vr_index    := 1;
      vr_tab_tabela.delete;
      --bug 19872
      FOR r1 IN (SELECT *
                  FROM (SELECT c.*, row_number() over (order by dtultpag desc) ordem
                           FROM crapepr c
                          WHERE c.cdcooper = pr_cdcooper
                            AND c.nrdconta = pr_nrdconta
                            AND c.inliquid = 1
                          ORDER BY ordem)
                         WHERE rownum <= 4) 
    LOOP
        vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(r1.nrctremp);
      vr_tab_tabela(vr_index).coluna2 := TO_CHAR(r1.vlemprst,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''');
      vr_tab_tabela(vr_index).coluna3 := r1.qtpreemp
                                      || '/'
                                      || TO_CHAR(r1.vlpreemp,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''');
        --
      OPEN cr_crapfin (pr_cdcooper => pr_cdcooper
                      ,pr_cdfinemp => r1.cdfinemp);
      FETCH cr_crapfin INTO rw_crapfin;
        CLOSE cr_crapfin;
        vr_tab_tabela(vr_index).coluna4 := rw_crapfin.dsfinalidade;
        --
      OPEN cr_craplcr (pr_cdcooper => pr_cdcooper
                      ,pr_cdlcremp => r1.cdlcremp);
      FETCH cr_craplcr INTO rw_craplcr;
        CLOSE cr_craplcr;
        vr_tab_tabela(vr_index).coluna5 := rw_craplcr.dslinha_credito;
        --
      OPEN cr_craplem (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => r1.nrctremp);
      FETCH cr_craplem INTO rw_craplem;
        CLOSE cr_craplem;
        vr_tab_tabela(vr_index).coluna6 := TO_CHAR(rw_craplem.dtliquidacao, 'dd/mm/yyyy');
        --
      OPEN cr_crapris (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => r1.nrctremp
                      ,pr_dtrefere => rw_craplem.dtliquidacao);
      FETCH cr_crapris INTO rw_crapris;
        --bug 19890
        IF cr_crapris%FOUND THEN
          vr_tab_tabela(vr_index).coluna7 := nvl(rw_crapris.dspontualidade, 'Sem Atrasos');
        ELSE
          vr_tab_tabela(vr_index).coluna7 := 'Sem Atrasos';
        END IF;
      
        CLOSE cr_crapris;
      
        vr_index := vr_index + 1;
      END LOOP;
      --
    vr_string := vr_string ||
                 '<subcategoria>'||
                   '<tituloTela>Últimas 4 Operações Liquidadas - Empréstimos e Financiamentos</tituloTela>' ||
                   '<campos>';
      vr_string := vr_string || '<campo>
                             <nome>Empréstimo/Financiamento</nome>
                             <tipo>table</tipo>
                             <valor>
                             <linhas>';
      --
      IF vr_tab_tabela.COUNT() = 0 THEN
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
      END IF;
      --
    vr_string := vr_string||fn_tag_table('Contrato;Valor da Operação;Prestações;Finalidade;Linha de Crédito;Liquidação;Pontualidade'
                ,vr_tab_tabela);
      vr_string := vr_string || '</linhas>
                             </valor>
                             </campo>';
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic IS NOT NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        END IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>pc_emprestimos_liquidados->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_emprestimos_liquidados - ' || SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                       '</erro></erros>';
    END pc_emprestimos_liquidados;
    ---------------------------------------------------------------
    PROCEDURE pc_co_responsabilidade(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                   ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                                   ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_co_responsabilidade
        Sistema : Aimaro/Ibratan
        Autor   : Marcelo Telles Coelho (Mouts)
        Data    : Abril/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca os contratos que a conta da pessoa é avalista
      ---------------------------------------------------------------------------------------------------------------------*/
      --
      -- Variaveis de trabalho
      vr_nrctremp   NUMBER;
      vr_nrdconta   NUMBER;
      vr_contas_chq VARCHAR2(1000) := ' '; --para contas avalisadas de cheque
      vr_nmprimtl   VARCHAR2(1000);
      vr_vldivida   VARCHAR2(1000);
      vr_tpdcontr   VARCHAR2(1000);
      vr_index      NUMBER;
      vr_qtmesdec   NUMBER;
      vr_qtpreemp   NUMBER;
      vr_qtprecal   NUMBER;
      vr_qtregist   NUMBER;
      vr_axnrcont   VARCHAR2(1000);
      vr_axnrcpfc   VARCHAR2(1000);
      vr_des_erro   VARCHAR2(1000);
      vr_clob_ret   CLOB;
      vr_clob_msg   CLOB;
      vr_xmltype    xmlType;
      vr_parser     xmlparser.Parser;
      vr_doc        xmldom.DOMDocument;
      --
      vr_dstextab_parempctl  craptab.dstextab%TYPE;
      vr_dstextab_digitaliza craptab.dstextab%TYPE;
      -- variaveis de retorno
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_tab_erro      gene0001.typ_tab_erro;
      -- Root
      vr_node_root xmldom.DOMNodeList;
      vr_item_root xmldom.DOMNode;
      vr_elem_root xmldom.DOMElement;
      -- SubItens
      vr_node_list xmldom.DOMNodeList;
      vr_node_name VARCHAR2(100);
      vr_item_node xmldom.DOMNode;
      vr_elem_node xmldom.DOMElement;
      -- SubItens da AVAL
      vr_node_list_aval xmldom.DOMNodeList;
      vr_node_name_aval VARCHAR2(100);
      vr_item_node_aval xmldom.DOMNode;
      vr_valu_node_aval xmldom.DOMNode;
    
      -- Tabelas
      vr_tab_aval   aval0001.typ_tab_contras;
      vr_rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
      -- Exceptions
      vr_exc_erro EXCEPTION;
      vr_des_reto VARCHAR2(100);
    
      /*Para a tabela de co-responsabilidade quando desconto de titulo*/
    CURSOR c_busca_saldo_deved_dsctit (pr_nrdconta IN crapsdv.nrdconta%TYPE
                                      ,pr_cdcooper IN crapsdv.cdcooper%TYPE
                                      ,pr_nrctrato IN crapsdv.nrctrato%TYPE) IS
      SELECT s.cdlcremp||'-'||s.dsdlinha dsdlinha
            ,s.nrdconta
            ,d.dslcremp dsfinalidade
       FROM CRAPSDV s
           ,craplcr d
         WHERE s.cdcooper = d.cdcooper
           AND s.cdlcremp = d.cdlcremp
           AND s.nrdconta = pr_nrdconta
           AND s.cdcooper = pr_cdcooper
           AND s.nrctrato = pr_nrctrato;
      r_busca_saldo_deved_dsctit c_busca_saldo_deved_dsctit%ROWTYPE;
    
      /*Para a tabela de co-responsabilidade quando desconto de cheques*/
    CURSOR c_busca_dados_descchq (pr_nrdconta IN crapsdv.nrdconta%TYPE
                                 ,pr_cdcooper IN crapsdv.cdcooper%TYPE
                                 ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
      SELECT c.nrdconta
            ,s.vldsaldo saldodeved
            ,c.nrctrlim contrato
            ,c.cddlinha || '-'||l.dsdlinha as linha
      FROM CRAPLIM c,
           crapldc l,
           crapsdv s
         WHERE c.cdcooper = l.cdcooper
           AND c.cddlinha = L.CDDLINHA
           AND s.cdcooper = l.cdcooper
           AND s.nrdconta = c.nrdconta
      and   s.nrctrato = c.nrctrlim
           AND c.nrdconta = pr_nrdconta
           AND c.cdcooper = pr_cdcooper
           AND c.nrctrlim = pr_nrctrlim
           AND c.tpctrlim = 2
           AND c.insitlim = 2
           AND l.tpdescto = 2;
      r_busca_dados_descchq c_busca_dados_descchq%ROWTYPE;
    
    CURSOR c_busca_dados_limite_emp (pr_nrdconta IN crapsdv.nrdconta%TYPE
                                    ,pr_cdcooper IN crapsdv.cdcooper%TYPE
                                    ,pr_nrctrato IN crapsdv.nrctrato%TYPE) IS
    SELECT l.dsdlinha linhacred
          ,c.nrdconta
      FROM crapmcr c
          ,craplrt l
         WHERE c.cdcooper = l.cdcooper
           AND c.cddlinha = l.cddlinha
           AND c.CDCOOPER = pr_cdcooper
           AND c.NRDCONTA = pr_nrdconta
      and   c.nrcontra = pr_nrctrato;
      r_busca_dados_limite_emp c_busca_dados_limite_emp%ROWTYPE;
    

      FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode) RETURN VARCHAR2 IS
      BEGIN
        RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
      END fn_getValue;
  BEGIN -- inicio
      pr_cdcritic            := NULL;
      pr_dscritic            := NULL;
      vr_rw_crapdat.dtmvtolt := pr_dtmvtolt;
      --
    aval0001.pc_busca_dados_contratos_car(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => NULL
                                         ,pr_nrdcaixa => NULL
                                         ,pr_idorigem => 5
                                         ,pr_dtmvtolt => NULL
                                         ,pr_nmdatela => pr_nmdatela--'TELA_UNICA'
                                         ,pr_cdoperad => NULL
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrcpfcgc => NULL
                                         ,pr_inproces => NULL
                                         ,pr_nmprimtl => vr_nmprimtl
                                         ,pr_axnrcont => vr_axnrcont
                                         ,pr_axnrcpfc => vr_axnrcpfc
                                         ,pr_nmdcampo => vr_nmdcampo
                                         ,pr_des_erro => vr_des_erro
                                         ,pr_clob_ret => vr_clob_ret
                                         ,pr_clob_msg => vr_clob_msg
                                         ,pr_cdcritic => pr_cdcritic
                                         ,pr_dscritic => pr_dscritic);
    
      -- Buscar informações do XML retornado
      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_tab_tabela.delete;
      IF vr_clob_ret IS NOT NULL THEN
        vr_xmltype := XMLType.createXML(vr_clob_ret);
        vr_parser  := xmlparser.newParser;
        xmlparser.parseClob(vr_parser, vr_xmltype.getClobVal());
        vr_doc := xmlparser.getDocument(vr_parser);
        xmlparser.freeParser(vr_parser);
        --
        -- Buscar nodo AVAL
        vr_node_root := xmldom.getElementsByTagName(vr_doc, 'root');
        vr_item_root := xmldom.item(vr_node_root, 0);
        vr_elem_root := xmldom.makeElement(vr_item_root);
        --
        -- Faz o get de toda a lista ROOT
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_root, '*');
        --
        vr_index := 0;
        vr_tab_aval.DELETE;
        --
        -- Percorrer os elementos
        FOR i IN 0 .. xmldom.getLength(vr_node_list) - 1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          --
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          --
          -- Tratar leitura dos dados do SEGCAB (Header)
          IF vr_node_name = 'aval' THEN
            -- Buscar todos os filhos deste nó
            vr_elem_node := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de folhas da SEGCAB
            vr_node_list_aval := xmldom.getChildrenByTagName(vr_elem_node, '*');
            --
            vr_nrdconta := NULL;
            --
            -- Percorrer os elementos
            FOR i IN 0 .. xmldom.getLength(vr_node_list_aval) - 1 LOOP
              -- Buscar o item atual
              vr_item_node_aval := xmldom.item(vr_node_list_aval, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_aval := xmldom.getNodeName(vr_item_node_aval);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_aval) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_aval = 'nrctremp' THEN
                -- Buscar valor da TAG
                vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                vr_nrctremp       := fn_getValue(vr_valu_node_aval);
              END IF;
              IF vr_node_name_aval = 'nrdconta' THEN
                -- Buscar valor da TAG
                vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                vr_nrdconta       := fn_getValue(vr_valu_node_aval);
              END IF;
              IF vr_node_name_aval = 'nmprimtl' THEN
                vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                vr_nmprimtl       := fn_getValue(vr_valu_node_aval);
              END IF;
              IF vr_node_name_aval = 'vldivida' THEN
                vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                vr_vldivida       := fn_getValue(vr_valu_node_aval);
              END IF;
              IF vr_node_name_aval = 'tpdcontr' THEN
                vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
                vr_tpdcontr       := fn_getValue(vr_valu_node_aval);
              END IF;
            END LOOP;
            --
            IF vr_nrdconta IS NOT NULL THEN
              vr_index := vr_index + 1;
              --
              vr_tab_aval(vr_index).nrdconta := vr_nrdconta;
              vr_tab_aval(vr_index).nrctremp := vr_nrctremp;
              vr_tab_aval(vr_index).tpdcontr := vr_tpdcontr;
              vr_tab_aval(vr_index).nmprimtl := vr_nmprimtl;
              vr_tab_aval(vr_index).vldivida := vr_vldivida;
            END IF;
          END IF;
        END LOOP;
        -- FIM - Buscar informações do XML retornado
        -- 
      vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Co-responsabilidade</tituloTela>'||
                   '<campos>';
        --
        /*Apresentado em tabela*/
        vr_string := vr_string || '<campo>
                               <nome>Co-responsabilidade</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';
      
        IF vr_tab_aval.COUNT() > 0 THEN
          vr_index := 1;
        
          FOR i IN 1 .. vr_tab_aval.COUNT() LOOP
          
            vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(vr_tab_aval(i).nrctremp);
          
            --se for contrato de emprestimo
            IF (vr_tab_aval(i).tpdcontr = 'EP') THEN
            
          empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper
                                          ,pr_cdagenci       => NULL
                                          ,pr_nrdcaixa       => NULL
                                          ,pr_cdoperad       => NULL
                                          ,pr_nmdatela       => NULL
                                          ,pr_idorigem       => NULL
                                          ,pr_nrdconta       => vr_tab_aval(i).nrdconta
                                          ,pr_idseqttl       => NULL
                                          ,pr_rw_crapdat     => vr_rw_crapdat
                                          ,pr_dtcalcul       => pr_dtmvtolt
                                          ,pr_nrctremp       => vr_tab_aval(i).nrctremp
                                          ,pr_cdprogra       => NULL
                                          ,pr_inusatab       => TRUE
                                          ,pr_flgerlog       => 0
                                          ,pr_flgcondc       => TRUE
                                          ,pr_nmprimtl       => NULL
                                          ,pr_tab_parempctl  => vr_dstextab_parempctl
                                          ,pr_tab_digitaliza => vr_dstextab_digitaliza
                                          ,pr_nriniseq       => NULL
                                          ,pr_nrregist       => NULL
                                          ,pr_qtregist       => vr_qtregist
                                          ,pr_tab_dados_epr  => vr_tab_dados_epr
                                          ,pr_des_reto       => vr_des_reto
                                          ,pr_tab_erro       => vr_tab_erro);
              --
              IF vr_des_reto = 'NOK' THEN
                IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                  pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
                  pr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                ELSE
                  pr_cdcritic := 0;
                  pr_dscritic := 'Falha ao obter dados do empréstimo. ' || SQLERRM;
                END IF;
                RAISE vr_exc_erro;
              END IF;
            
              --
              FOR j IN 1 .. vr_tab_dados_epr.count() LOOP
                vr_qtmesdec := vr_tab_dados_epr(j).qtmesdec - vr_tab_dados_epr(j).qtprecal;
                vr_qtpreemp := vr_tab_dados_epr(j).qtpreemp - vr_tab_dados_epr(j).qtprecal;
              
                IF vr_qtmesdec > vr_qtpreemp THEN
                  vr_qtprecal := vr_qtpreemp;
                ELSE
                  vr_qtprecal := vr_qtmesdec;
                END IF;
              
                IF vr_qtprecal < 0 THEN
                  vr_qtprecal := 0;
                END IF;
              
                --Pega os dados da tabela de emprestimos
                vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida; --Saldo Devedor
                vr_tot_saldo_devedor := vr_tot_saldo_devedor+to_number(replace(vr_tab_aval(i).vldivida,'.'));
              vr_tab_tabela(vr_index).coluna3 := REPLACE(REPLACE(SUBSTR(vr_tab_dados_epr(j).dspreapg,5,11),',0000',''),'/',' / '); --Prest. Pagas/Total
                
                vr_tot_prestacoes_pagas_empr := vr_tot_prestacoes_pagas_empr+to_number(substr(vr_tab_dados_epr(j).dspreapg,1,instr(vr_tab_dados_epr(j).dspreapg,'/')-1));
                vr_tot_prestacoes_empr       := vr_tot_prestacoes_empr+to_number(substr(vr_tab_dados_epr(j).dspreapg,instr(vr_tab_dados_epr(j).dspreapg,'/')+1,instr(vr_tab_dados_epr(j).dspreapg,'->')-instr(vr_tab_dados_epr(j).dspreapg,'/')-1));
                vr_tab_tabela(vr_index).coluna4 := vr_tab_dados_epr(j).vlpreemp; --Prestações
                vr_tot_valor_prestacoes := vr_tot_valor_prestacoes+vr_tab_dados_epr(j).vlpreemp;
                vr_tab_tabela(vr_index).coluna5 := to_char(vr_tab_dados_epr(j).vltotpag,'999g999g990d00'); --Atraso / Parcela
                vr_tot_valor_atraso     := vr_tot_valor_atraso+vr_tab_dados_epr(j).vltotpag;
                vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(j).dsfinemp; --Finalidade
                vr_tab_tabela(vr_index).coluna7 := vr_tab_dados_epr(j).dslcremp; --Linha de Crédito
                vr_tab_tabela(vr_index).coluna8 := 'Aval conta ' -- Bug 20848
                                                || trim(gene0002.fn_mask_conta(vr_tab_dados_epr(j).nrdconta))
                                            || ' '
                                              || CASE WHEN vr_tab_dados_epr(j).inprejuz = 1 THEN '*' END;       --Responsabilidade
              END LOOP;
            
              /* DESCONTO DE TITULO */
            ELSIF (vr_tab_aval(i).tpdcontr = 'DT') THEN
            
              /*Busca saldo devedor do desconto de título */
            OPEN c_busca_saldo_deved_dsctit(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                           ,pr_nrctrato => vr_tab_aval(i).nrctremp);
            
             fetch c_busca_saldo_deved_dsctit into r_busca_saldo_deved_dsctit;
             if c_busca_saldo_deved_dsctit%found then
              
                vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
                vr_tot_saldo_devedor := vr_tot_saldo_devedor+to_number(replace(vr_tab_aval(i).vldivida,'.'));
                --Quando for desconto de título não tem prestação e atraso/parcela bug19838
                vr_tab_tabela(vr_index).coluna3 := '-';
                vr_tab_tabela(vr_index).coluna4 := '-';
                vr_tab_tabela(vr_index).coluna5 := '-';
              
                vr_tab_tabela(vr_index).coluna6 := r_busca_saldo_deved_dsctit.dsfinalidade;
                vr_tab_tabela(vr_index).coluna7 := r_busca_saldo_deved_dsctit.dsdlinha;
               vr_tab_tabela(vr_index).coluna8 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_saldo_deved_dsctit.nrdconta));
             
             end if;
            
            close c_busca_saldo_deved_dsctit;
            
            
              /* LIMITE DE CRÉDITO EMPRESARIAL*/
            ELSIF (vr_tab_aval(i).tpdcontr = 'LM') THEN
            
              /*Busca linha de crédito, os outros campos não precisa */
            OPEN c_busca_dados_limite_emp(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                         ,pr_nrctrato => vr_tab_aval(i).nrctremp);
            
             fetch c_busca_dados_limite_emp into r_busca_dados_limite_emp;
             if c_busca_dados_limite_emp%found then
              
                --Quando for desconto de título não tem prestação e atraso/parcela bug19838
                vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
                vr_tot_saldo_devedor := vr_tot_saldo_devedor+to_number(replace(vr_tab_aval(i).vldivida,'.'));
                vr_tab_tabela(vr_index).coluna3 := '-';
                vr_tab_tabela(vr_index).coluna4 := '-';
                vr_tab_tabela(vr_index).coluna5 := '-';
              
                vr_tab_tabela(vr_index).coluna6 := '-';
                vr_tab_tabela(vr_index).coluna7 := r_busca_dados_limite_emp.linhacred;
               vr_tab_tabela(vr_index).coluna8 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_dados_limite_emp.nrdconta));
             
             end if;
            
            close c_busca_dados_limite_emp;
            
            ELSIF (vr_tab_aval(i).tpdcontr = 'DC') THEN
            
              /*Abre o cursor*/
          OPEN c_busca_dados_descchq (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                       ,pr_nrctrlim => vr_tab_aval(i).nrctremp);
              --
           FETCH c_busca_dados_descchq INTO r_busca_dados_descchq;
              IF c_busca_dados_descchq%FOUND THEN
              
                /*Monta a tabela*/
                vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(r_busca_dados_descchq.contrato);
                vr_tab_tabela(vr_index).coluna2 := to_char(r_busca_dados_descchq.saldodeved, '999g999g990d00');
                vr_tot_saldo_devedor := vr_tot_saldo_devedor + r_busca_dados_descchq.saldodeved;
                --Quando for desconto de cheque não tem prestação nem atraso/parcela nem finalidade
                vr_tab_tabela(vr_index).coluna3 := '-';
                vr_tab_tabela(vr_index).coluna4 := '-';
                vr_tab_tabela(vr_index).coluna5 := '-';
                vr_tab_tabela(vr_index).coluna6 := '-';
                -- 
                vr_tab_tabela(vr_index).coluna7 := r_busca_dados_descchq.linha;
               vr_tab_tabela(vr_index).coluna8 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_dados_descchq.nrdconta));
              
              END IF;
              CLOSE c_busca_dados_descchq;
            
            END IF;
            --
            vr_index := vr_index + 1;
          
          END LOOP;
        
          --Monta o totalizador
          vr_tab_tabela(vr_index).coluna1 := 'Total';
          vr_tab_tabela(vr_index).coluna2 := to_char(vr_tot_saldo_devedor, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna3 := to_char(vr_tot_prestacoes_pagas_empr||' / '||vr_tot_prestacoes_empr);
          vr_tab_tabela(vr_index).coluna4 := to_char(vr_tot_valor_prestacoes, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna5 := to_char(vr_tot_valor_atraso,'999g999g990d00');
          vr_tab_tabela(vr_index).coluna6 := '-';
          vr_tab_tabela(vr_index).coluna7 := '-';
          vr_tab_tabela(vr_index).coluna8 := '-';  
          
                    
        ELSE
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
        END IF;
      ELSE
        --
      vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Co-responsabilidade</tituloTela>'||
                   '<campos>';
        --
        /*Apresentado em tabela*/
        vr_string := vr_string || '<campo>
                               <nome>Co-responsabilidade</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';
        --
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
        vr_tab_tabela(1).coluna8 := '-';
      END IF;
      --
      
    vr_string := vr_string||fn_tag_table('Contrato;Saldo Devedor;Prest. Pagas / Total;Valor das Prestações;Atraso Parcela;Finalidade;Linha de Crédito;Responsabilidade'
                ,vr_tab_tabela);
      vr_string := vr_string || '</linhas>
                             </valor>
                             </campo>';
      --
      vr_string := vr_string || '</campos></subcategoria>';
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF pr_cdcritic IS NOT NULL THEN
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        END IF;
    vr_string := vr_string||'<subcategoria>'||
                            '<tituloTela>Co-responsabilidade</tituloTela>'||
                            '<erros><erro>'||
                            '<dscritic>pc_co_responsabilidade ->'||pr_dscritic||'</dscritic>'||
                     '</erro></erros></subcategoria>';
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_co_responsabilidade - ' || SQLERRM;
    vr_string := vr_string||'<subcategoria>'||
                            '<tituloTela>Co-responsabilidade</tituloTela>'||
                            '<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                       '</erro></erros></subcategoria>';
    END pc_co_responsabilidade;
    ---------------------------------------------------------------
  
    PROCEDURE pc_busca_riscos(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                          ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                          ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2) IS
      /*---------------------------------------------------------------------------------------------------------------------
        Programa: pc_busca_riscos
        Sistema : Aimaro/Ibratan
        Autor   : Rubens Lima (Mouts)
        Data    : Maio/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Procedure que busca os riscos das Ocorrências
        
        Alteracoes: 30/05/2019 - Alterado nome de subcategoria de ocorrencias para risco.
                                 Story 21955 - Sprint 11 - Gabriel Marcos (Mouts).
      
                    04/06/2019 - Adicionado Nivel de risco em: Operacoes > Ocorrencias. 
                                 Bug 22209 - PRJ438 - Gabriel Marcos (Mouts).                             
                                 
      ---------------------------------------------------------------------------------------------------------------------*/
    
      --Variáveis
      pr_retxml   XMLTYPE;
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
      vr_nmdcampo VARCHAR2(100);
      vr_des_erro VARCHAR2(1000);
      pr_xmllog   VARCHAR2(1000);
    
      --Tabela para armazenar os riscos
      vr_tab_riscos typ_tab_dados_riscos;
    
      vr_xmltype xmlType;
      vr_parser  xmlparser.Parser;
      vr_doc     xmldom.DOMDocument;
      vr_index   NUMBER;
    
      -- Root
      vr_node_root xmldom.DOMNodeList;
      vr_item_root xmldom.DOMNode;
      vr_elem_root xmldom.DOMElement;
      -- SubItens
      vr_node_list xmldom.DOMNodeList;
      vr_node_name VARCHAR2(100);
      vr_item_node xmldom.DOMNode;
      vr_elem_node xmldom.DOMElement;
      -- SubItens da AVAL
      vr_node_list_risco xmldom.DOMNodeList;
      vr_node_name_risco VARCHAR2(100);
      vr_item_node_risco xmldom.DOMNode;
      vr_valu_node_risco xmldom.DOMNode;
      -- Variáveis do XML
      vr_nrdconta    NUMBER;
      vr_nrcpfcgc    NUMBER;
      vr_nrctrato    NUMBER;
      vr_riscoincl   VARCHAR2(1);
      vr_riscogrpo   VARCHAR2(1);
      vr_rating      VARCHAR2(1);
      vr_riscoatraso VARCHAR2(1);
      vr_riscorefin  VARCHAR2(1);
      vr_riscoagrav  VARCHAR2(1);
      vr_riscomelhor VARCHAR2(1);
      vr_riscooperac VARCHAR2(1);
      vr_riscocpf    VARCHAR2(1);
      vr_riscofinal  VARCHAR2(1);
      vr_qtdiaatraso NUMBER;
      vr_nrgreconomi NUMBER;
      vr_tpregistro  VARCHAR2(100);
    
      -- Cadastro de Risco -> Campos: nivel de risco e justificativa (tela CADRIS)
      CURSOR cr_cadris IS
    SELECT tcc.nrdconta
          ,tcc.dsjustificativa
          ,ass.nmprimtl
          ,tcc.cdnivel_risco
      FROM tbrisco_cadastro_conta tcc,
           crapass ass
         WHERE tcc.cdcooper = pr_cdcooper
           AND tcc.cdcooper = ass.cdcooper
           AND tcc.nrdconta = ass.nrdconta
       and ass.nrdconta      = pr_nrdconta;
      rw_cadris cr_cadris%ROWTYPE;
    
      FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode) RETURN VARCHAR2 IS
      BEGIN
        RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
      END fn_getValue;
    
    BEGIN
    
      /*Cria um XML padrão para enviar como entrada para a package*/
      pr_retxml := xmltype(fn_param_mensageria(pr_cdcooper));
    
      /*Faz a chamada da package para buscar os dados*/
  TELA_ATENDA_OCORRENCIAS.pc_busca_dados_risco (pr_nrdconta => pr_nrdconta
                                               ,pr_cdcooper => pr_cdcooper
                                               ,pr_xmllog   => pr_xmllog
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => vr_dscritic
                                               ,pr_retxml   => pr_retxml
                                               ,pr_nmdcampo => vr_nmdcampo
                                               ,pr_des_erro => vr_des_erro);
    
      -- Buscar informações do XML retornado
      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      BEGIN
        IF pr_retxml IS NOT NULL THEN
        
          vr_xmltype := pr_retxml;
          vr_parser  := xmlparser.newParser;
          xmlparser.parseClob(vr_parser, vr_xmltype.getClobVal());
          vr_doc := xmlparser.getDocument(vr_parser);
          xmlparser.freeParser(vr_parser);
          --
          -- Buscar nodo AVAL
          vr_node_root := xmldom.getElementsByTagName(vr_doc, 'Contas');
          vr_item_root := xmldom.item(vr_node_root, 0);
          vr_elem_root := xmldom.makeElement(vr_item_root);
          --
          -- Faz o get de toda a lista ROOT
          vr_node_list := xmldom.getChildrenByTagName(vr_elem_root, '*');
          --
          vr_index := 0;
          vr_tab_riscos.DELETE;
          --
          -- Percorrer os elementos
          FOR i IN 0 .. xmldom.getLength(vr_node_list) - 1 LOOP
            -- Buscar o item atual
            vr_item_node := xmldom.item(vr_node_list, i);
            -- Captura o nome e tipo do nodo
            vr_node_name := xmldom.getNodeName(vr_item_node);
            --
            -- Sair se o nodo não for elemento
            IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
              CONTINUE;
            END IF;
            --
            -- Tratar leitura dos dados do (Header)
            IF vr_node_name = 'Conta' THEN
              -- Buscar todos os filhos deste nó
              vr_elem_node := xmldom.makeElement(vr_item_node);
              -- Faz o get de toda a lista de folhas
              vr_node_list_risco := xmldom.getChildrenByTagName(vr_elem_node, '*');
              --
              vr_nrdconta := NULL;
              --
              -- Percorrer os elementos
              FOR i IN 0 .. xmldom.getLength(vr_node_list_risco) - 1 LOOP
                -- Buscar o item atual
                vr_item_node_risco := xmldom.item(vr_node_list_risco, i);
                -- Captura o nome e tipo do nodo
                vr_node_name_risco := xmldom.getNodeName(vr_item_node_risco);
                -- Sair se o nodo não for elemento
                IF xmldom.getNodeType(vr_item_node_risco) <> xmldom.ELEMENT_NODE THEN
                  CONTINUE;
                END IF;
              
                IF vr_node_name_risco = 'numero_conta' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_nrdconta        := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'cpf_cnpj' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_nrcpfcgc        := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'contrato' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_nrctrato        := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_inclusao' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscoincl       := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_grupo' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscogrpo       := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'rating' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_rating          := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_atraso' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscoatraso     := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_refin' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscorefin      := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_agravado' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscoagrav      := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_melhora' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscomelhor     := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_operacao' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscooperac     := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_cpf' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscocpf        := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'risco_final' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_riscofinal      := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'qtd_dias_atraso' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_qtdiaatraso     := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'numero_gr_economico' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_nrgreconomi     := fn_getValue(vr_valu_node_risco);
                END IF;
              
                IF vr_node_name_risco = 'tipo_registro' THEN
                  vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
                  vr_tpregistro      := fn_getValue(vr_valu_node_risco);
                END IF;
              
              END LOOP;
              --
              IF vr_nrdconta IS NOT NULL THEN
                vr_index := vr_index + 1;
                --
                --Alimenta a tabela de riscos
                vr_tab_riscos(vr_index).nrdconta := NVL(vr_nrdconta, 0);
                vr_tab_riscos(vr_index).nrcpfcgc := NVL(vr_nrcpfcgc, 0);
                vr_tab_riscos(vr_index).nrctrato := NVL(vr_nrctrato, 0);
                vr_tab_riscos(vr_index).riscoincl := NVL(vr_riscoincl, '-');
                vr_tab_riscos(vr_index).riscogrpo := NVL(vr_riscogrpo, '-');
                vr_tab_riscos(vr_index).rating := NVL(vr_rating, '-');
                vr_tab_riscos(vr_index).riscoatraso := NVL(vr_riscoatraso, '-');
                vr_tab_riscos(vr_index).riscorefin := NVL(vr_riscorefin, '-');
                vr_tab_riscos(vr_index).riscoagrav := NVL(vr_riscoagrav, '-');
                vr_tab_riscos(vr_index).riscomelhor := NVL(vr_riscomelhor, '-');
                vr_tab_riscos(vr_index).riscooperac := NVL(vr_riscooperac, '-');
                vr_tab_riscos(vr_index).riscocpf := NVL(vr_riscocpf, '-');
                vr_tab_riscos(vr_index).riscofinal := NVL(vr_riscofinal, '-');
                vr_tab_riscos(vr_index).qtdiaatraso := NVL(vr_qtdiaatraso, 0);
                vr_tab_riscos(vr_index).nrgreconomi := NVL(vr_nrgreconomi, 0);
                vr_tab_riscos(vr_index).tpregistro := NVL(vr_tpregistro, '-');
              END IF;
            END IF;
          END LOOP;
        END IF;
        -- FIM - Buscar informações do XML retornado
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    
      /*Itera e extrai os dados da tabela de riscos para a tabela que será apresentada*/
      vr_tab_tabela.DELETE;
      IF vr_tab_riscos.COUNT() > 0 THEN
        vr_index := 1;
        FOR i IN 1 .. vr_tab_riscos.COUNT() LOOP
          vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_cpf_cnpj(vr_tab_riscos(vr_index).nrcpfcgc,
                                       CASE WHEN length(vr_tab_riscos(vr_index).nrcpfcgc) > 11 THEN 2 ELSE 1 END);
          vr_tab_tabela(vr_index).coluna2 := gene0002.fn_mask_conta(vr_tab_riscos(vr_index).nrdconta);
          vr_tab_tabela(vr_index).coluna3 := gene0002.fn_mask_contrato(vr_tab_riscos(vr_index).nrctrato);
          vr_tab_tabela(vr_index).coluna4 := CASE WHEN vr_tab_riscos(vr_index).tpregistro IS NULL THEN '-'
                                             ELSE vr_tab_riscos(vr_index).tpregistro END;
          vr_tab_tabela(vr_index).coluna5 := CASE WHEN vr_tab_riscos(vr_index).riscoincl IS NULL THEN '-'
                                             ELSE vr_tab_riscos(vr_index).riscoincl END;
          vr_tab_tabela(vr_index).coluna6 := CASE WHEN vr_tab_riscos(vr_index).rating IS NULL THEN '-' 
                                             ELSE vr_tab_riscos(vr_index).rating END;
          vr_tab_tabela(vr_index).coluna7 := CASE WHEN vr_tab_riscos(vr_index).riscoatraso IS NULL THEN '-'
                                             ELSE vr_tab_riscos(vr_index).riscoatraso END;
          vr_tab_tabela(vr_index).coluna8 := CASE WHEN vr_tab_riscos(vr_index).riscorefin IS NULL THEN '-'
                                             ELSE vr_tab_riscos(vr_index).riscorefin END;
          vr_tab_tabela(vr_index).coluna9 := CASE WHEN vr_tab_riscos(vr_index).riscoagrav IS NULL THEN '-'
                                             ELSE vr_tab_riscos(vr_index).riscoagrav END;
          vr_tab_tabela(vr_index).coluna10 := CASE WHEN vr_tab_riscos(vr_index).riscomelhor IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).riscomelhor END;
          vr_tab_tabela(vr_index).coluna11 := CASE WHEN vr_tab_riscos(vr_index).riscooperac IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).riscooperac END;
          vr_tab_tabela(vr_index).coluna12 := CASE WHEN vr_tab_riscos(vr_index).riscocpf IS NULL THEN '-' 
                                              ELSE vr_tab_riscos(vr_index).riscocpf END;
          vr_tab_tabela(vr_index).coluna13 := CASE WHEN vr_tab_riscos(vr_index).riscogrpo IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).riscogrpo END;
          vr_tab_tabela(vr_index).coluna14 := CASE WHEN vr_tab_riscos(vr_index).riscofinal IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).riscofinal END;
          vr_tab_tabela(vr_index).coluna15 := CASE WHEN vr_tab_riscos(vr_index).qtdiaatraso IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).qtdiaatraso END;
          vr_tab_tabela(vr_index).coluna16 := CASE WHEN vr_tab_riscos(vr_index).nrgreconomi IS NULL THEN '-'
                                              ELSE vr_tab_riscos(vr_index).nrgreconomi END;
          vr_index := vr_index + 1;
        
        END LOOP;
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
        vr_tab_tabela(1).coluna8 := '-';
        vr_tab_tabela(1).coluna9 := '-';
        vr_tab_tabela(1).coluna10 := '-';
        vr_tab_tabela(1).coluna11 := '-';
        vr_tab_tabela(1).coluna12 := '-';
        vr_tab_tabela(1).coluna13 := '-';
        vr_tab_tabela(1).coluna14 := '-';
        vr_tab_tabela(1).coluna15 := '-';
        vr_tab_tabela(1).coluna16 := '-';
      
      END IF;
    
  vr_string := vr_string ||
               '<subcategoria>'||
               '<tituloTela>Riscos</tituloTela>'||
               '<campos>';
    
      --Nível de Risco - APENAS PARA O PROPONENTE
      --if (pr_persona = 'Proponente') then
      -- Se as contas forem iguais eh o proponente
  if vr_nrdconta_principal = pr_nrdconta then
    if vr_tpproduto_principal = c_emprestimo then
      if c_proposta_epr%isopen then
        close c_proposta_epr;
      end if;
      open c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctrato_principal);
      fetch c_proposta_epr into r_proposta_epr;
          vr_string := vr_string || tela_analise_credito.fn_tag('Nível de Risco da Proposta', r_proposta_epr.dsnivris);
      close c_proposta_epr;
    end if;
  end if;
    
      --
      /*Apresentado em tabela*/
      vr_string := vr_string || '<campo>
                           <nome>Riscos</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
      --
  vr_string := vr_string||fn_tag_table('CPF/CNPJ;Conta;Número Contrato;Tipo Contrato;Risco Inclusão;Rating;Risco Atraso;Risco Refinanciamento;Risco Agravado;Risco Melhora;Risco Operação;Risco CPF;Risco Grupo Econômico;Risco Final;Quantidade Dias Atraso;Número Grupo Econômico'
              ,vr_tab_tabela);
      vr_string := vr_string || '</linhas>
                           </valor>
                           </campo>';
    
   --Mostrar o agravamento de risco pelo controle:     
   open cr_cadris;
    fetch cr_cadris into rw_cadris;
      vr_string := vr_string || tela_analise_credito.fn_tag('Agravamento de Risco pelo Controle',
                                                            fn_getNivelRisco(rw_cadris.cdnivel_risco));
      vr_string := vr_string || tela_analise_credito.fn_tag('Justificativa', rw_cadris.dsjustificativa);
   close cr_cadris;
      --
      vr_string := vr_string || '</campos></subcategoria>';
    
    END;
  
  
  
  begin -- Inicio pc_consulta_operacoes
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    --3.1 Resumo da Conta Caminho>
    -- Plano de Capital
      pc_plano_capital(pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_cdcritic => pr_cdcritic
                      ,pr_dscritic => pr_dscritic);
    -- Médias
      pc_medias(pr_cdcooper => pr_cdcooper
               ,pr_nrdconta => pr_nrdconta
               ,pr_dtmvtolt => pr_dtmvtolt
               ,pr_cdcritic => pr_cdcritic
               ,pr_dscritic => pr_dscritic);
      -- Aplicações
      pc_aplicacoes(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_cdcritic => pr_cdcritic
                   ,pr_dscritic => pr_dscritic);
              
  
    --3.2 Operações de Crédito Ativas
    --3.2.1 Produto Empréstimo e Financiamento 
      pc_busca_propostas_ativas(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
  
    /*--3.2.2 Produto Bôrdero de Desconto de 
    pc_busca_borderos(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);*/
  
    --3.2.2 Produto Consórcio - Verificar se vamos trazer
      pc_busca_consorcio(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
  
    --3.3 Rotativos Ativos
    --3.3.1 Modalidade Limite de Crédito:   
        pc_modalidade_lim_credito(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                 ,pr_nrdconta => pr_nrdconta       --> Conta
                                 ,pr_cdcritic => pr_cdcritic
                                 ,pr_dscritic => pr_dscritic                                 
                                 ,pr_dsxmlret => vr_xml);
  
                                  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                 pr_texto_completo => vr_string,
                                                 pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.3.2 Modalidade Desconto de  Cheques 
  
        pc_consulta_desc_chq(pr_cdcooper => pr_cdcooper       --> Cooperativa
                            ,pr_nrdconta => pr_nrdconta       --> Conta
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic                            
                            ,pr_dsxmlret => vr_xml);
  
                            pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                           pr_texto_completo => vr_string,
                                           pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    -- Modalidade desconto de Produto Bôrdero de Desconto de Título
    -- User Story 21153:Categoria Operações Subcategoria Operações de Crédito Ativas - Produto Bôrdero de Desconto de Cheque
        pc_consulta_bordero_chq(pr_cdcooper => pr_cdcooper       --> Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --> Conta
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic                            
                               ,pr_dsxmlret => vr_xml);
  
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
    --3.3.3 Modalidade Desconto de  Título 
        pc_consulta_desc_titulo(pr_cdcooper => pr_cdcooper       --> Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --> Conta
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic                               
                               ,pr_dsxmlret => vr_xml);
  
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.3.4 Produto Bôrdero de Desconto de 
       pc_busca_borderos(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
  
    --3.3.5 Modalidade Cartão de Crédito 
        pc_modalidade_car_cred(pr_cdcooper => pr_cdcooper       --> Cooperativa
                              ,pr_nrdconta => pr_nrdconta       --> Conta
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic                              
                              ,pr_dsxmlret => vr_xml);
  
                               pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                              pr_texto_completo => vr_string,
                                              pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
    --3.4 Lançamentos Futuros
        pc_consulta_lanc_futuro(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);
  
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.5 Últimas 4 Operações Liquidadas
  
    --3.5.1Produto Empréstimos e Financiamentos 
       pc_emprestimos_liquidados(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);      
  
    --3.5.2 Produto Borderô de Desconto de Títulos
         pc_consulta_bordero(pr_cdcooper => pr_cdcooper       --> Cooperativa
                            ,pr_nrdconta => pr_nrdconta       --> Conta
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic                            
                            ,pr_dsxmlret => vr_xml);
  
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.6 Últimas 4 Operações Alterações 
  
    --3.6.1 Produto Limite de Crédito 
        pc_consulta_lim_cred(pr_cdcooper => pr_cdcooper       --> Cooperativa
                            ,pr_nrdconta => pr_nrdconta       --> Conta
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic                            
                            ,pr_dsxmlret => vr_xml);
  
             pc_escreve_xml(pr_xml            => vr_dsxmlret,
                            pr_texto_completo => vr_string,
                            pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.6.2 Produto Limite de Desconto de Cheques
        pc_consulta_lim_desc_chq(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);  
    --
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.6.3 Produto Limite de Desconto de Título
        pc_consulta_lim_desc_tit(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);  
  
                                 pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                pr_texto_completo => vr_string,
                                                pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.6.4  Produto Cartão de Crédito 
        pc_consulta_hist_cartaocredito(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta       --> Conta
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic                                      
                                      ,pr_dsxmlret => vr_xml);  
  
         pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                   pr_fecha_xml => TRUE);
  
    --3.6 Histórico do Associado --- São as informações de Operações
  
    --3.7 Co-responsabilidade:
      pc_co_responsabilidade(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic);  
  
              pc_escreve_xml(pr_xml            => vr_dsxmlret,
                             pr_texto_completo => vr_string,
                             pr_texto_novo     => null, -- Valor de pc_co_responsabilidade já esta na String
                   pr_fecha_xml => TRUE);
  
    /*Tabela de riscos*/
      pc_busca_riscos(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_cdcritic => pr_cdcritic
                     ,pr_dscritic => pr_dscritic);  

      pc_escreve_xml(pr_xml            => vr_dsxmlret,
                     pr_texto_completo => vr_string,
                     pr_texto_novo     => null, 
                     pr_fecha_xml      => TRUE);                                  
      
      
      
  
    pr_dsxmlret := vr_dsxmlret;
  
  EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - ' || SQLERRM;
          vr_string := '<categoria>'||
                           '<tituloTela>Operações</tituloTela>'||
                           '<tituloFiltro>operacoes</tituloFiltro>'||
                           '<subcategorias>'||
                                 '<subcategoria>'||
                                     '<erros>'||
                                         '<erro>'||
                                             '<cdcritic>0</cdcritic>'||
                                             '<dscritic>'||pr_dscritic||'</dscritic>'||
                                         '</erro>'||
                                     '</erros>'||
                                 '</subcategoria>'||
                           '</subcategorias>'||
                       '</categoria>';
    
  end;

  PROCEDURE pc_mensagem_motor(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                             ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                             ,pr_nrctrato  IN number
                             ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                             ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                             ,pr_dsxmlret  OUT CLOB) is
    /* .............................................................................
    
    Programa:  pc_mensagem_motor
    Sistema : Aimaro
    Autor   : Rafael Muniz Monteiro
    Data    : Maio/2019                 Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado pelas procedures 
    
    Objetivo  : Rotina para retornar as mensagens de retorno do motor
    
    Alteracoes: -----    
    
    .............................................................................*/
  
    -- Cursores 
    CURSOR cr_motor(prc_cdcooper IN crapage.cdcooper%TYPE,
                    prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                    prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
         SELECT e.dsconteudo_requisicao,
                e.dhacionamento, 
                a.inpessoa, 
                a.nrdconta
           FROM tbgen_webservice_aciona e, 
                crapass a
       WHERE e.cdcooper = prc_cdcooper
            and a.cdcooper   = e.cdcooper --incluido rubens
            and e.cdorigem   in (9,5)
            and e.cdoperad   = 'MOTOR'
            and e.dsoperacao NOT LIKE '%ERRO%'
            and e.dsoperacao NOT LIKE '%DESCONHECIDA%'
            and e.nrdconta   = prc_nrdconta
            and e.nrctrprp   = prc_nrctrprp
            and a.nrdconta   = e.nrdconta
       ORDER BY e.dhacionamento DESC;
    -- variáveis   
    vr_string_xml CLOB;
    vr_index      NUMBER;
    -- Objetos para retorno das mensagens
    vr_obj      cecred.json := json();
    vr_obj_anl  cecred.json := json();
    vr_obj_lst  cecred.json_list := json_list();
    vr_obj_msg  cecred.json := json();
    vr_obj_clob CLOB;
    vr_destipo  VARCHAR2(1000);
    vr_desmens  VARCHAR2(4000);
    vr_dsmensag VARCHAR2(32767);
  
    --      
  BEGIN
  
    vr_string_xml := NULL;
    vr_index      := 0;
    vr_tab_tabela.delete;
      FOR rw_motor IN cr_motor(pr_cdcooper,
                                pr_nrdconta,
                                pr_nrctrato) LOOP
        vr_string_xml := '<subcategoria>'||
                                 '<tituloTela>Retorno da Análise do Motor</tituloTela>'||
                                 '<campos>';
      vr_string_xml := vr_string_xml || '<campo>
                                         <nome>Mensagens</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
    
      BEGIN
        -- Efetuar cast para JSON
        vr_obj   := json(rw_motor.dsconteudo_requisicao);
        vr_index := vr_index + 1;
      
        IF vr_obj.exist('resultadoAnaliseRegra') THEN
            vr_tab_tabela(vr_index).coluna1 := 'Resultado da Avaliacão: '|| initcap(REPLACE(gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('resultadoAnaliseRegra').to_char(),'"'),'"'),'\u','\'))),'DERIVAR','Análise Manual'));
        END IF;
        -- Se existe o objeto de analise
        IF vr_obj.exist('analises') THEN
          vr_obj_anl := json(vr_obj.get('analises').to_char());
          -- Se existe a lista de mensagens
          IF vr_obj_anl.exist('mensagensDeAnalise') THEN
            vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
            -- Para cada mensagem
            FOR vr_idx IN 1 .. vr_obj_lst.count() LOOP
              BEGIN
                vr_obj_msg := json(vr_obj_lst.get(vr_idx));
              
                -- Se encontrar o atributo texto e tipo
                IF vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                     vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                  vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(), '"'), '"'), 'ERRO', 'REPROVAR');
                END IF;
                --
                IF vr_destipo <> 'DETALHAMENTO' THEN
                  vr_index := vr_index + 1;
                  --vr_string_xml := vr_string_xml || fn_tag(vr_desmens, null);
                  vr_tab_tabela(vr_index).coluna1 := vr_desmens;
                END IF;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL; -- Ignorar essa linha
              END;
            END LOOP;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          -- Ignorar se o conteudo nao for JSON não conseguiremos ler as mensagens
            null;
      END;
    
      vr_string_xml := vr_string_xml || fn_tag_table('Mensagens', vr_tab_tabela);
    
      vr_string_xml := vr_string_xml || '</linhas>
                                         </valor>
                                         </campo>';
    
      vr_string_xml := vr_string_xml || '</campos></subcategoria>';
      EXIT; -- executar somente uma vez   
    END LOOP;
  
    pr_dsxmlret := vr_string_xml;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_mensagem_motor: '||sqlerrm; 
    end;

  PROCEDURE pc_consulta_proposta_limite(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                     ,pr_dsxmlret IN OUT CLOB) IS                --> Arquivo de retorno do XML
    /* .............................................................................
    
      Programa: pc_consulta_proposta
      Sistema : Aimaro/Ibratan
      Autor   : Rubens Lima
      Data    : Março/2019                 Ultima atualizacao: 12/06/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Consulta proposta do proponente para o produto limite desconto de título
    
      Alteracoes:
                  12/06/2019 - Adicionada busca da garantia da proposta
                               PRJ438 - Jefferson - (Mouts)
    ..............................................................................*/
  
    vr_dsxmlret       CLOB;
    vr_dsxml_mensagem CLOB;
    vr_string         CLOB;
  
    vr_garantia VARCHAR2(250);
  
    --Data para consultar a proposta
  rw_crapdat  btch0001.cr_crapdat%rowtype;
  
    /* Dados da Solicitação - Proposta do Proponente - Task 16167 */
    cursor c_limites_desconto_titulos(pr_cdcooper IN crapcop.cdcooper%TYPE
                                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      select fn_tag('Valor do Limite Solicitado', to_char(lim.vllimite, '999g999g990d00')) valor_limite
             ,fn_tag('Contrato', gene0002.fn_mask_contrato(lim.nrctrlim)) numero_contrato
             ,fn_tag('Linha de Desconto',(select dsdlinha from crapldc
                                   where  cdcooper = lim.cdcooper
                                   and    cddlinha = lim.cddlinha
                                   and    tpdescto = 3)) linha_desconto
             ,fn_tag('Valor Médio dos Titulos',(select to_char(vlmedchq,'999g999g990d00')
                                        from crapprp
                                        where cdcooper = lim.cdcooper
                                        and   nrdconta = lim.nrdconta
                                        and   nrctrato = lim.nrctrlim)) valor_medio_titulos
         ,case lim.insitlim when 1 then fn_tag('Situação Proposta','EM ESTUDO')
                            when 2 then fn_tag('Situação Proposta','ATIVA')
                            when 3 then fn_tag('Situação Proposta','CANCELADA')
                            when 5 then fn_tag('Situação Proposta','APROVADA')
                            when 6 then fn_tag('Situação Proposta','NÃO APROVADA')
                            when 8 then fn_tag('Situação Proposta','EXPIRADA DECURSO DE PRAZO')
                            when 9 then fn_tag('Situação Proposta','ANULADA')
                            else        fn_tag('Situação Proposta','DIFERENTE')
          end situacao_limite
         ,case lim.insitest when 0 then fn_tag('Situação Análise','NÃO ENVIADO')
                            when 1 then fn_tag('Situação Análise','ENVIADA ANALISE AUTOMÁTICA')
                            when 2 then fn_tag('Situação Análise','ENVIADA ANALISE MANUAL')
                            when 3 then fn_tag('Situação Análise','ANÁLISE FINALIZADA')
                            when 4 then fn_tag('Situação Análise','EXPIRADA')
                            else        fn_tag('Situação Análise','DIFERENTE')
          end situacao_esteira
         ,case lim.insitapr when 0 then fn_tag('Decisão','NÃO ANALISADO')
                            when 1 then fn_tag('Decisão','APROVADA AUTOMATICAMENTE')
                            when 2 then fn_tag('Decisão','APROVADA MANUAL')
                            when 3 then fn_tag('Decisão','APROVADA')
                            when 4 then fn_tag('Decisão','REJEITADA MANUAL')
                            when 5 then fn_tag('Decisão','REJEITADA AUTOMATICAMENTE')
                            when 6 then fn_tag('Decisão','REJEITADA')
                            when 7 then fn_tag('Decisão','NÃO ANALISADA')
                            when 8 then fn_tag('Decisão','REFAZER')
                            else        fn_tag('Decisão','DIFERENTE')
          end situacao_aprovacao
          ,lim.nrctrlim
          ,lim.nrctaav1
          ,lim.nrctaav2
   from   crawlim lim
   where  lim.nrdconta = pr_nrdconta
   and    lim.cdcooper = pr_cdcooper
   and    lim.nrctrlim = pr_nrctrato;
    r_limites_desconto_titulos c_limites_desconto_titulos%ROWTYPE;
  
  BEGIN
  
    vr_cdcritic := 0;
   vr_dscritic := null;
  
    /* Busca data da cooperativa */
   open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
   fetch btch0001.cr_crapdat into rw_crapdat;
   if    btch0001.cr_crapdat%notfound then
         close btch0001.cr_crapdat;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
         raise vr_exc_erro;
   end   if;
   close btch0001.cr_crapdat;

  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Limite de Desconto de Título</tituloTela>';
  
  open c_limites_desconto_titulos(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta);
   fetch c_limites_desconto_titulos into r_limites_desconto_titulos;
    if c_limites_desconto_titulos%found then
      vr_garantia := '-';
      vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,r_limites_desconto_titulos.nrctrlim,r_limites_desconto_titulos.nrctaav1,r_limites_desconto_titulos.nrctaav2,'P',c_limite_desc_titulo, TRUE);
    
      vr_string := vr_string||
                  '<campos>'||
                     r_limites_desconto_titulos.valor_limite||
                     r_limites_desconto_titulos.numero_contrato||
                     r_limites_desconto_titulos.linha_desconto||
                     r_limites_desconto_titulos.valor_medio_titulos||
                     fn_tag('Garantia',vr_garantia)||
                  --r_limites_desconto_titulos.situacao_limite||
                  --r_limites_desconto_titulos.situacao_esteira||
                  --r_limites_desconto_titulos.situacao_aprovacao||
                   '</campos>';
    end if;
  close c_limites_desconto_titulos;
  
    vr_string := vr_string || '</subcategoria>';
  
    vr_dsxml_mensagem := NULL;
  pc_mensagem_motor(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrato => pr_nrctrato,
                    pr_cdcritic => pr_cdcritic,
                    pr_dscritic => pr_dscritic,
                    pr_dsxmlret => vr_dsxml_mensagem);
    IF vr_dsxml_mensagem IS NOT NULL THEN
      pr_dsxmlret := vr_string || vr_dsxml_mensagem;
    ELSE
      pr_dsxmlret := vr_string;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_limite: '||sqlerrm;   
    
  END;

  PROCEDURE pc_consulta_proposta_epr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                    ,pr_nrctrato  IN number
                                    ,pr_inpessoa  IN crapass.inpessoa%TYPE                                    
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                                    ,pr_dsxmlret  OUT CLOB) is
  
    /* .............................................................................
    
      Programa: pc_consulta_proposta_epr
      Sistema : Aimaro/Ibratan
      Autor   : Paulo Martins
      Data    : Março/2019                 Ultima atualizacao: 08/05/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Consulta proposta emprestimo
    
      Alteracoes: 31/05/2019 - Alterado Rubens Lima
                               Novo cálculo Endividamento Total Fluxo.
                               Story 21378
                  31/05/2019 - Inclusão apresentação das Liquidações - Paulo Martins
                  
                  10/06/2019 - Corrigir calculo de envididamento total.
                               Bug 22259 - PRJ438 - Gabriel Marcos (Mouts).
    
    ..............................................................................*/
  
    /*Busca o número do tipo de garantia conforme b1wgen0002*/
  
    CURSOR c_busca_nrgarope IS
   SELECT nrgarope from crapprp
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrato = pr_nrctrato;
  
    CURSOR c_busca_dsgarantia(pr_nrgarope craprad.nrseqite%TYPE) IS
      SELECT dsseqite
        FROM craprad
       WHERE cdcooper = pr_cdcooper
         AND nrtopico = 2
         AND nritetop = 2
         AND nrseqite = pr_nrgarope;
  
    CURSOR cr_crapbpr(pr_nrctrato in crapbpr.nrctrpro%type) IS
      SELECT t.dscatbem
        FROM crapbpr t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctrpro = pr_nrctrato;
    rw_crapbpr cr_crapbpr%ROWTYPE;
  
    CURSOR cr_crawepr IS
      SELECT c.dtlibera, c.vlemprst, c.idfiniof
        FROM crawepr c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctrato;
    r_crwepr cr_crawepr%ROWTYPE;
  
    /*Lista dos contratos liquidados para buscar o saldo devedor*/
    CURSOR c_liquidacoes IS
      SELECT ctrliq
     FROM crawepr
     UNPIVOT (ctrliq FOR data IN (nrctrliq##1, nrctrliq##2, nrctrliq##3, nrctrliq##4, nrctrliq##5,
                                                nrctrliq##6, nrctrliq##7, nrctrliq##8, nrctrliq##9, nrctrliq##10))
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctrato
         AND ctrliq <> 0;
  
    CURSOR c_busca_contrato_cc_liquidar IS
     SELECT nrliquid,
            dtmvtolt
        FROM crawepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctrato;
    r_busca_contrato_cc_liquidar c_busca_contrato_cc_liquidar%ROWTYPE;
  
    /*Busca o limite do último cartão criado*/
    CURSOR c_busca_limite_cartao_cc IS
      SELECT vllimcrd
        FROM crawcrd c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.insitcrd = 4 -- Em uso
     AND   c.progress_recid = (select max(progress_recid)
                               from crawcrd
                                where cdcooper = c.cdcooper
                               and   nrdconta = c.nrdconta
                               and   insitcrd = c.insitcrd);
  
    /*Propostas da conta com a situação Aprovado para calculo do valor financiado de todas*/
    CURSOR c_busca_proposta_andamento IS
      SELECT nrctremp
        FROM crawepr c
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp <> pr_nrctrato
         AND insitapr = 1 --Aprovado
         --AND vlempori > 0 Retirado Paulo - 05/08/2019
         AND nrctremp NOT IN (SELECT nrctremp
                                FROM crapepr
                               WHERE cdcooper = c.cdcooper
                                 AND nrdconta = c.nrdconta);
  
    --Variáveis
    vr_totvlfinanc        NUMBER;
    vr_nrctremp           NUMBER;
    vr_vlfinanc_andamento NUMBER;
  
    vr_dsxmlret            CLOB;
    vr_dsxml_mensagem      CLOB;
    vr_string_contrato_epr CLOB;
    vr_string_aux          CLOB;
    vr_tab_dados_avais     dsct0002.typ_tab_dados_avais;
    vr_vlutiliz            NUMBER;
    vr_vllimcred           NUMBER;
    vr_nrgarope            NUMBER;
    vr_vlendtot            NUMBER; -- Endividamento total do fluxo
  vr_vlstotal number; -- Valor depositos a vista
  
  vr_dscatbem       varchar2(1000);  
  vr_vlrdoiof       number;
  vr_vlrtarif       number;
  vr_vlrtares       number;
  vr_vltarbem       number;
  vr_vlpreclc NUMBER := 0; -- Parcela calcula
  vr_vliofpri       number;
  vr_vliofadi       number;
  vr_flgimune PLS_INTEGER;
  vr_cdhistor NUMBER := 0; -- Historico
  vr_vlfinanc NUMBER := 0;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  
  vr_cdusolcr      craplcr.cdusolcr%type;
  vr_tpctrato      craplcr.tpctrato%type;
  vr_totslddeved NUMBER := 0;
  
  vr_dstextab            craptab.dstextab%TYPE;
  vr_dstextab_parempctl  craptab.dstextab%TYPE;
  vr_dstextab_digitaliza craptab.dstextab%TYPE;
  vr_inusatab            BOOLEAN;
  vr_qtregist            NUMBER;
  vr_tab_dados_epr       empr0001.typ_tab_dados_epr;
  vr_idfiniof            number;
  vr_vliofepr            number;
  vr_vlrtarif_ret        number;
  vr_avalista1_aux       number := 0;
  vr_avalista2_aux       number := 0;
  vr_liquidacoes         varchar2(32000);
  vr_index               number := 0;
  vr_idx                 number := 0;
  vr_total_liquidacoes   number(25,2) :=0;
  
  --Rowtype para calcular os empréstimos aprovados
  r_proposta_epr2 c_proposta_epr%ROWTYPE;
  vr_erro exception;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    --> listar avalistas de contratos
    DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                        ,pr_cdagenci => 0  --> Código da agencia
                        ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                        ,pr_cdoperad => 1  --> Código do Operador
                        ,pr_nmdatela => 'TELA_UNICA'  --> Nome da tela
                        ,pr_idorigem => 5  --> Identificador de Origem
                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                        ,pr_idseqttl => 1  --> Sequencial do titular
                        ,pr_tpctrato => 1
                        ,pr_nrctrato => pr_nrctrato  --> Numero do contrato
                        ,pr_nrctaav1 => 0  --> Numero da conta do primeiro avalista
                        ,pr_nrctaav2 => 0  --> Numero da conta do segundo avalista
                                --------> OUT <--------                                   
                        ,pr_tab_dados_avais   => vr_tab_dados_avais   --> retorna dados do avalista
                        ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                               , pr_dscritic => vr_dscritic); --> Descrição da crítica
  
    IF vr_tab_dados_avais.exists(1) THEN
      vr_avalista1_aux := vr_tab_dados_avais(1).nrctaava;
    END IF;
  
    IF vr_tab_dados_avais.exists(2) THEN
      vr_avalista2_aux := vr_tab_dados_avais(2).nrctaava;
    END IF;
  
    /*Garantia da proposta*/
    vr_garantia := '-';
    vr_garantia := fn_garantia_proposta(pr_cdcooper, pr_nrdconta, pr_nrctrato, vr_avalista1_aux, vr_avalista2_aux, 'P',
                                        c_emprestimo, TRUE);
    -- Fim Garantia
  
  
   vr_string_contrato_epr := '<subcategoria>'||
                             '<tituloTela>Proposta</tituloTela>'||
                             '<campos>';
                             
   open c_proposta_epr(pr_cdcooper,pr_nrdconta,pr_nrctrato);
    fetch c_proposta_epr into r_proposta_epr;
  
    /*IOF - TARIFA - VALOR EMPRESTIMO*/
    FOR rw_crapbpr IN cr_crapbpr(pr_nrctrato) LOOP
      vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
    END LOOP;
  
    -- Buscar iof
     TIOF0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctrato
                                 ,pr_dtmvtolt => r_proposta_epr.dtmvtolt
                                 ,pr_inpessoa => pr_inpessoa
                                 ,pr_cdfinemp => r_proposta_epr.cdfinemp
                                 ,pr_cdlcremp => r_proposta_epr.cdlcremp
                                 ,pr_qtpreemp => r_proposta_epr.qtpreemp
                                 ,pr_vlpreemp => r_proposta_epr.vlpreemp
                                 ,pr_vlemprst => r_proposta_epr.vlemprst
                                 ,pr_dtdpagto => r_proposta_epr.dtdpagto
                                 ,pr_dtlibera => r_proposta_epr.dtlibera
                                 ,pr_tpemprst => r_proposta_epr.tpemprst
                                 ,pr_dtcarenc        => r_proposta_epr.dtcarenc
                                 ,pr_qtdias_carencia => r_proposta_epr.qtddias
                                 ,pr_valoriof => vr_vlrdoiof
                                 ,pr_dscatbem => vr_dscatbem
                                 ,pr_idfiniof => r_proposta_epr.idfiniof
                                 ,pr_dsctrliq => r_proposta_epr.dsctrliq
                                 ,pr_idgravar => 'N'
                                 ,pr_vlpreclc => vr_vlpreclc
                                 ,pr_vliofpri => vr_vliofpri
                                 ,pr_vliofadi => vr_vliofadi
                                 ,pr_flgimune => vr_flgimune
                                 ,pr_dscritic => vr_dscritic);
  
    SELECT decode(cdusolcr, 2, 0, cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
           tpctrato
           into 
           vr_cdusolcr,
           vr_tpctrato
      FROM craplcr
     WHERE cdcooper = pr_cdcooper
       AND cdlcremp = r_proposta_epr.cdlcremp;
  
     --Buscar a tarifa da convresão progress (Paulo M- 05/08/2019)
     empr0018.pc_consulta_tarifa_emprst(pr_cdcooper => pr_cdcooper
                                      , pr_cdlcremp => r_proposta_epr.cdlcremp
                                      , pr_vlemprst => r_proposta_epr.vlemprst
                                      , pr_nrdconta => pr_nrdconta
                                      , pr_nrctremp => pr_nrctrato
                                      , pr_dscatbem => vr_dscatbem
                                      , pr_vlrtarif => vr_vlrtarif
                                      , pr_cdcritic => vr_dscritic
                                      , pr_des_erro => vr_dscritic
                                      , pr_des_reto => vr_des_reto
                                      , pr_tab_erro => vr_tab_erro);
                                      
     if vr_dscritic is not null then
       raise vr_erro;
     end if;                                 
                                      

/*    -- Calcula tarifa
     TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdlcremp => r_proposta_epr.cdlcremp
                               ,pr_vlemprst => r_proposta_epr.vlemprst
                               ,pr_cdusolcr => vr_cdusolcr
                               ,pr_tpctrato => vr_tpctrato
                               ,pr_dsbemgar => vr_dscatbem
                               ,pr_cdprogra => 'TELA_UNICA'
                               ,pr_flgemail => 'N'
                               ,pr_vlrtarif => vr_vlrtarif
                               ,pr_vltrfesp => vr_vlrtares
                               ,pr_vltrfgar => vr_vltarbem
                               ,pr_cdhistor => vr_cdhistor
                               ,pr_cdfvlcop => vr_cdfvlcop
                               ,pr_cdhisgar => vr_cdhistor
                               ,pr_cdfvlgar => vr_cdfvlcop 
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);*/
  
    vr_vlrtarif := ROUND(nvl(vr_vlrtarif, 0), 2) + nvl(vr_vlrtares, 0) + nvl(vr_vltarbem, 0);
    vr_vlfinanc := r_proposta_epr.vlemprst;
  
    if r_proposta_epr.idfiniof = 1 then
     vr_vlfinanc := vr_vlfinanc + nvl(vr_vlrdoiof, 0) + nvl(vr_vlrtarif, 0);
    end if;
  
    /*IOF - TARIFA - VALOR EMPRESTIMO*/
      vr_string_contrato_epr := vr_string_contrato_epr||
                                r_proposta_epr.contrato||
                                r_proposta_epr.valor_emprestimo||
                                fn_tag('IOF', to_char(nvl(vr_vlrdoiof, 0), '999g999g990d00')) ||
                                fn_tag('Tarifa', to_char(nvl(vr_vlrtarif, 0), '999g999g990d00')) ||
                                fn_tag('Valor Financiado', to_char(nvl(vr_vlfinanc, 0), '999g999g990d00')) ||
                                r_proposta_epr.valor_prestacoes||    
                                r_proposta_epr.qtd_parcelas||         
                                r_proposta_epr.linha||      
                                r_proposta_epr.finalidade||
                                fn_tag('Garantia', vr_garantia)||
                                r_proposta_epr.cet||
                                r_proposta_epr.co_responsabilidade;
   close c_proposta_epr;                     
  
    /*Valor disponível em -> busca data e calcular o saldo descontando o valor das liquidações bug 20969*/
  
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO r_crwepr;
    IF cr_crawepr%FOUND THEN
    
    vr_string_contrato_epr := vr_string_contrato_epr||'<campo>
                                                       <nome>Liquidações</nome>
                                                       <tipo>table</tipo>
                                                       <valor>
                                                       <linhas>';
    
      BEGIN
        vr_index := 0;
        vr_idx := 0;
        vr_saldo_devedor_empr := 0;
        vr_tab_tabela.delete;
        FOR r1 IN c_liquidacoes LOOP
        
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
            vr_inusatab := FALSE;
          ELSE
            IF SUBSTR(vr_dstextab, 1, 1) = '0' THEN
              --Nao usa tabela
              vr_inusatab := FALSE;
            ELSE
              --Nao usa tabela
              vr_inusatab := TRUE;
            END IF;
          END IF;
        
            empr0001.pc_obtem_dados_empresti
                             (pr_cdcooper       => pr_cdcooper            --> Cooperativa conectada
                             ,pr_cdagenci       => 0                      --> Código da agência
                             ,pr_nrdcaixa       => 0                      --> Número do caixa
                             ,pr_cdoperad       => 1                      --> Código do operador
                             ,pr_nmdatela       => 'TELA_UNICA'               --> Nome datela conectada
                             ,pr_idorigem       => 5                      --> Indicador da origem da chamada
                             ,pr_nrdconta       => pr_nrdconta            --> Conta do associado
                             ,pr_idseqttl       => 1                      --> Sequencia de titularidade da conta
                             ,pr_rw_crapdat     => rw_crapdat             --> Vetor com dados de parâmetro (CRAPDAT)
                             ,pr_dtcalcul       => ''                     --> Data solicitada do calculo
                             ,pr_nrctremp       => r1.ctrliq              --> Número contrato empréstimo
                             ,pr_cdprogra       => 0                      --> Programa conectado
                             ,pr_inusatab       => vr_inusatab            --> Indicador de utilização da tabela
                             ,pr_flgerlog       => 'N'                    --> Gerar log S/N
                             ,pr_flgcondc       => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                             ,pr_nmprimtl       => ''                     --> Nome Primeiro Titular
                             ,pr_tab_parempctl  => vr_dstextab_parempctl  --> Dados tabela parametro
                             ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                             ,pr_nriniseq       => 1                      --> Numero inicial da paginacao
                             ,pr_nrregist       => 9999                   --> Numero de registros por pagina
                             ,pr_qtregist       => vr_qtregist            --> Qtde total de registros
                             ,pr_tab_dados_epr  => vr_tab_dados_epr       --> Saida com os dados do empréstimo
                             ,pr_des_reto       => vr_des_reto            --> Retorno OK / NOK
                                          , pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
        
          vr_totslddeved := vr_totslddeved + vr_tab_dados_epr(1).vlsdeved;
          vr_idfiniof    := vr_idfiniof + vr_tab_dados_epr(1).idfiniof;
        
        if vr_index = 0 then
            vr_index := 1;
        else 
            vr_index := vr_index + 1;
        end if; -- Necessário pela validação de liquidação CC 
        
          /*Carrega dados do emprestimo*/
          vr_tab_tabela(vr_index).coluna1 := vr_tab_dados_epr(1).cdlcremp;
          vr_tab_tabela(vr_index).coluna2 := vr_tab_dados_epr(1).cdfinemp;
          vr_tab_tabela(vr_index).coluna3 := vr_tab_dados_epr(1).nrctremp;
          vr_tab_tabela(vr_index).coluna4 := to_char(vr_tab_dados_epr(1).dtmvtolt, 'dd/mm/rrrr');
          vr_tab_tabela(vr_index).coluna5 := to_char(vr_tab_dados_epr(1).vlemprst, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(1).qtpreemp;
          vr_tab_tabela(vr_index).coluna7 := to_char(vr_tab_dados_epr(1).vlpreemp, '999g999g990d00');
          vr_tab_tabela(vr_index).coluna8 := to_char(round(vr_tab_dados_epr(1).vlsdeved, 2), '999g999g990d00');
          vr_tab_tabela(vr_index).coluna9 := 'PP';
          vr_total_liquidacoes := vr_total_liquidacoes + round(vr_tab_dados_epr(1).vlsdeved, 2);
        
        END LOOP;
        empr0001.pc_obtem_dados_empresti
                         (pr_cdcooper       => pr_cdcooper            --> Cooperativa conectada
                         ,pr_cdagenci       => 0                      --> Código da agência
                         ,pr_nrdcaixa       => 0                      --> Número do caixa
                         ,pr_cdoperad       => 1                      --> Código do operador
                         ,pr_nmdatela       => 'TELA_UNICA'               --> Nome datela conectada
                         ,pr_idorigem       => 5                      --> Indicador da origem da chamada
                         ,pr_nrdconta       => pr_nrdconta            --> Conta do associado
                         ,pr_idseqttl       => 1                      --> Sequencia de titularidade da conta
                         ,pr_rw_crapdat     => rw_crapdat             --> Vetor com dados de parâmetro (CRAPDAT)
                         ,pr_dtcalcul       => ''                     --> Data solicitada do calculo
                         ,pr_nrctremp       => 0                      --> Número contrato empréstimo
                         ,pr_cdprogra       => 0                      --> Programa conectado
                         ,pr_inusatab       => vr_inusatab            --> Indicador de utilização da tabela
                         ,pr_flgerlog       => 'N'                    --> Gerar log S/N
                         ,pr_flgcondc       => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                         ,pr_nmprimtl       => ''                     --> Nome Primeiro Titular
                         ,pr_tab_parempctl  => vr_dstextab_parempctl  --> Dados tabela parametro
                         ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                         ,pr_nriniseq       => 1                      --> Numero inicial da paginacao
                         ,pr_nrregist       => 9999                   --> Numero de registros por pagina
                         ,pr_qtregist       => vr_qtregist            --> Qtde total de registros
                         ,pr_tab_dados_epr  => vr_tab_dados_epr       --> Saida com os dados do empréstimo
                         ,pr_des_reto       => vr_des_reto            --> Retorno OK / NOK
                                      , pr_tab_erro => vr_tab_erro); --> Tabela com possíves erros
        vr_idx := vr_tab_dados_epr.FIRST;
        WHILE vr_idx IS NOT NULL LOOP
          vr_saldo_devedor_empr := vr_saldo_devedor_empr + round(vr_tab_dados_epr(vr_idx).vlsdeved, 2);
          vr_idx := vr_tab_dados_epr.NEXT(vr_idx);
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_totslddeved := 0;
      END;
    
      /*Valor empréstimo - Total saldo devedor*/
      vr_totslddeved := r_crwepr.vlemprst - vr_totslddeved;
    
      /*Quando não financiar IOF, descontar IOF + Tarifa - bug 20969*/
      if r_crwepr.idfiniof = 0 then
        vr_totslddeved := vr_totslddeved - vr_vlrdoiof - vr_vlrtarif;
      end if;
    
      /*Verifica ainda se precisa descontar depósito a vista da conta corrente*/
      OPEN c_busca_contrato_cc_liquidar;
     FETCH c_busca_contrato_cc_liquidar INTO r_busca_contrato_cc_liquidar;
    
      IF c_busca_contrato_cc_liquidar%FOUND THEN
        /*Busca dados da atenta e salva em tabela*/
       pc_busca_dados_atenda(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta);
        /*Depósito com valor negativo, deve descontar*/
       IF (vr_tab_valores_conta(1).vlstotal < 0) and  r_busca_contrato_cc_liquidar.nrliquid > 0 THEN
          vr_totslddeved := vr_totslddeved + vr_tab_valores_conta(1).vlstotal;
        
          /*Informações para liquidações*/
        if vr_index = 0 then
            vr_index := 1;
        else 
            vr_index := vr_index + 1;
        end if;         
        
          -- Rafael Ferreira 13/06/19 Story 22373. Buscar Calculo do ADP do Atenda.
          BEGIN
            CECRED.ZOOM0001.pc_consultar_limite_adp(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta,
                                                    pr_tipo => vr_tipo_adp, pr_data => vr_data_adp,
                                                    pr_contrato => vr_contrato_adp, pr_saldo => vr_saldo_adp,
                                                    pr_cdcritic => vr_cdcritic_adp, pr_dscritic => vr_dscritic_adp);
          EXCEPTION
            WHEN others THEN  
              vr_saldo_adp := 0;
          END;
        
          vr_tab_tabela(vr_index).coluna1 := '-';
          vr_tab_tabela(vr_index).coluna2 := '-';
          vr_tab_tabela(vr_index).coluna3 := r_busca_contrato_cc_liquidar.nrliquid;
          vr_tab_tabela(vr_index).coluna4 := to_char(r_busca_contrato_cc_liquidar.dtmvtolt, 'dd/mm/rrrr');
          vr_tab_tabela(vr_index).coluna5 := '-';
          vr_tab_tabela(vr_index).coluna6 := '-';
          vr_tab_tabela(vr_index).coluna7 := '-';
          --vr_tab_tabela(vr_index).coluna8 := round(abs(vr_tab_valores_conta(1).vlstotal), 2);
          vr_tab_tabela(vr_index).coluna8 := to_char(round(vr_saldo_adp, 2), '999g999g990d00');
          vr_tab_tabela(vr_index).coluna9 := 'CC';
          vr_total_liquidacoes := vr_total_liquidacoes + vr_saldo_adp;
          vr_vlstotal := vr_tab_valores_conta(1).vlstotal;
        END IF;
      END IF;
      CLOSE c_busca_contrato_cc_liquidar;
    
      /*Tabela liquidações*/
    if vr_tab_tabela.COUNT > 0 then
        /*Total de liquidações*/
        vr_index := vr_index + 1;
        vr_tab_tabela(vr_index).coluna1 := 'Total';
        vr_tab_tabela(vr_index).coluna2 := '-';
        vr_tab_tabela(vr_index).coluna3 := '-';
        vr_tab_tabela(vr_index).coluna4 := '-';
        vr_tab_tabela(vr_index).coluna5 := '-';
        vr_tab_tabela(vr_index).coluna6 := '-';
        vr_tab_tabela(vr_index).coluna7 := '-';
        vr_tab_tabela(vr_index).coluna8 := to_char(round(vr_total_liquidacoes, 2), '999g999g990d00');
        vr_tab_tabela(vr_index).coluna9 := '-';
      
      
        /*Gera Tags Xml*/
      vr_liquidacoes := vr_liquidacoes||fn_tag_table('Linha;Finalidade;Contrato;Data;Emprestado;Parcelas;Valor;Saldo;Tipo',vr_tab_tabela);
    else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
        vr_tab_tabela(1).coluna8 := '-';
        vr_tab_tabela(1).coluna9 := '-';
      vr_liquidacoes := vr_liquidacoes||fn_tag_table('Linha;Finalidade;Contrato;Data;Emprestado;Parcelas;Valor;Saldo;Tipo',vr_tab_tabela);
    end if;    
    
      vr_liquidacoes := vr_liquidacoes || '</linhas>
                                       </valor>
                                       </campo>';
    
      vr_string_contrato_epr := vr_string_contrato_epr || vr_liquidacoes;
    
      
      vr_string_contrato_epr := vr_string_contrato_epr||fn_tag('Valor Disponível em '||to_char(r_crwepr.dtlibera,'DD/MM/YYYY'),
                                       to_char(vr_totslddeved, '999g999g990d00'));
    END IF;
    CLOSE cr_crawepr;
  
   /*
   Carregar os dados de operações de crédito + valor da proposta + limite de cartão de crédito
   */          
   gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                            ,pr_tpdecons    => 3
                            ,pr_cdagenci    => 1
                            ,pr_nrdcaixa    => 1
                            ,pr_cdoperad    => 1
                            ,pr_nrdconta    => pr_nrdconta
                            ,pr_nrcpfcgc    => 0
                            ,pr_idseqttl    => 1
                            ,pr_idorigem    => 5
                            ,pr_dsctrliq    => r_proposta_epr.dsliquid
                            ,pr_cdprogra    => 'TELA_ANALISE_CREDITO'
                            ,pr_tab_crapdat => rw_crapdat
                            ,pr_inusatab    => TRUE
                            ,pr_vlutiliz    => vr_vlutiliz
                            ,pr_cdcritic    => vr_cdcritic
                            ,pr_dscritic    => vr_dscritic);  
  
    /*Carrega o valor do cartão de crédito*/
    OPEN c_busca_limite_cartao_cc;
    FETCH c_busca_limite_cartao_cc INTO vr_vllimcred;
    CLOSE c_busca_limite_cartao_cc;
  
    /*Acumular Proposta em andamento com Situação Analise Finalizada e Decisão Aprovada (VALOR FINANCIADO)*/
  
    vr_vlfinanc_andamento := 0;
    vr_vlrdoiof           := 0;
    vr_vlrtarif           := 0;
    /*Para cada proposta*/
    OPEN c_busca_proposta_andamento;
    LOOP
       FETCH c_busca_proposta_andamento INTO vr_nrctremp;
      EXIT WHEN c_busca_proposta_andamento%NOTFOUND;
      /*Buscar valor acumulado e calcular*/
      OPEN c_proposta_epr(pr_cdcooper, pr_nrdconta, vr_nrctremp);
         FETCH c_proposta_epr into r_proposta_epr2;
    
      /*IOF - TARIFA - VALOR EMPRESTIMO*/
      vr_dscatbem := '';
      FOR rw_crapbpr IN cr_crapbpr(vr_nrctremp) LOOP
        vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
      END LOOP;
    
      -- Buscar iof
         TIOF0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => vr_nrctremp
                                     ,pr_dtmvtolt => r_proposta_epr2.dtmvtolt
                                     ,pr_inpessoa => pr_inpessoa
                                     ,pr_cdfinemp => r_proposta_epr2.cdfinemp
                                     ,pr_cdlcremp => r_proposta_epr2.cdlcremp
                                     ,pr_qtpreemp => r_proposta_epr2.qtpreemp
                                     ,pr_vlpreemp => r_proposta_epr2.vlpreemp
                                     ,pr_vlemprst => r_proposta_epr2.vlemprst
                                     ,pr_dtdpagto => r_proposta_epr2.dtdpagto
                                     ,pr_dtlibera => r_proposta_epr2.dtlibera
                                     ,pr_tpemprst => r_proposta_epr2.tpemprst
                                     ,pr_dtcarenc        => r_proposta_epr2.dtcarenc
                                     ,pr_qtdias_carencia => r_proposta_epr2.qtddias
                                     ,pr_valoriof => vr_vlrdoiof
                                     ,pr_dscatbem => vr_dscatbem
                                     ,pr_idfiniof => r_proposta_epr2.idfiniof
                                     ,pr_dsctrliq => r_proposta_epr2.dsctrliq
                                     ,pr_idgravar => 'N'
                                     ,pr_vlpreclc => vr_vlpreclc
                                     ,pr_vliofpri => vr_vliofpri
                                     ,pr_vliofadi => vr_vliofadi
                                     ,pr_flgimune => vr_flgimune
                                     ,pr_dscritic => vr_dscritic);
    
      SELECT decode(cdusolcr, 2, 0, cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
             tpctrato
               into 
               vr_cdusolcr,
               vr_tpctrato
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = r_proposta_epr2.cdlcremp;
    
     --Buscar a tarifa da convresão progress (Paulo M- 05/08/2019)
     empr0018.pc_consulta_tarifa_emprst(pr_cdcooper => pr_cdcooper
                                      , pr_cdlcremp => r_proposta_epr2.cdlcremp
                                      , pr_vlemprst => r_proposta_epr2.vlemprst
                                      , pr_nrdconta => pr_nrdconta
                                      , pr_nrctremp => r_proposta_epr2.Nrctremp
                                      , pr_dscatbem => vr_dscatbem
                                      , pr_vlrtarif => vr_vlrtarif
                                      , pr_cdcritic => vr_dscritic
                                      , pr_des_erro => vr_dscritic
                                      , pr_des_reto => vr_des_reto
                                      , pr_tab_erro => vr_tab_erro);         
/*      -- Calcula tarifa
     TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdlcremp => r_proposta_epr2.cdlcremp
                               ,pr_vlemprst => r_proposta_epr2.vlemprst
                               ,pr_cdusolcr => vr_cdusolcr
                               ,pr_tpctrato => vr_tpctrato
                               ,pr_dsbemgar => vr_dscatbem
                               ,pr_cdprogra => 'TELA_UNICA'
                               ,pr_flgemail => 'N'
                               ,pr_vlrtarif => vr_vlrtarif
                               ,pr_vltrfesp => vr_vlrtares
                               ,pr_vltrfgar => vr_vltarbem
                               ,pr_cdhistor => vr_cdhistor
                               ,pr_cdfvlcop => vr_cdfvlcop
                               ,pr_cdhisgar => vr_cdhistor
                               ,pr_cdfvlgar => vr_cdfvlcop 
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);*/
    
        --vr_vlrtarif           := ROUND(nvl(vr_vlrtarif, 0), 2) + nvl(vr_vlrtares, 0) + nvl(vr_vltarbem, 0);
        vr_vlfinanc_andamento := vr_vlfinanc_andamento+r_proposta_epr2.vlemprst;
    
      if r_proposta_epr2.idfiniof = 1 then
        vr_vlfinanc_andamento := vr_vlfinanc_andamento + nvl(vr_vlrdoiof, 0) + nvl(vr_vlrtarif, 0);
      end if;
    
      close c_proposta_epr;  
    
    END LOOP;
    CLOSE c_busca_proposta_andamento;

    vr_string_contrato_epr := vr_string_contrato_epr || '</campos></subcategoria>';
    
    -- Rafael Ferreira Story 21378 -- Endividamento Total do Fluxo
    vr_string_contrato_epr := vr_string_contrato_epr || '<subcategoria>' ||
                    '<tituloTela>Endividamento Total do Fluxo</tituloTela>' || '<campos>';      

    /*Armazena Limite Utilizado de Desconto de Cheque*/
    FOR rcheques IN c_bordero_cheques(pr_cdcooper, pr_nrdconta) LOOP
      vr_vldscchq := vr_vldscchq + rcheques.vlcheque;
    END LOOP;
    
    /*Armazena Valor de desconto de Título*/
    TELA_ATENDA_DSCTO_TIT.pc_busca_dados_limite(pr_nrdconta => pr_nrdconta, pr_cdcooper => pr_cdcooper,
                                                pr_tpctrlim => 3, -- Desconto Titulo
                                                pr_insitlim => 2, -- Ativos
                                                pr_dtmvtolt => NULL,
                                                --------> OUT <--------
                                                pr_tab_dados_limite => wrk_tab_limite_titulos,
                                                pr_cdcritic => wrk_cdcritica_titulos, pr_dscritic => wrk_dscerro_titulos);
    if wrk_tab_limite_titulos.count > 0 then
      vr_vlutiliz_titulo := wrk_tab_limite_titulos(0).vlutiliz;
    else
      vr_vlutiliz_titulo := 0;
    end if;
  
    /*Cálculo do Endividamento total do fluxo*/
    vr_vlendtot := round(nvl(vr_vlfinanc, 0),2) 
                 + round(nvl(vr_saldo_devedor_empr,0), 2) 
                 + round(nvl(vr_vlfinanc_andamento,0), 2) 
                 + round(nvl(vr_tab_valores_conta(1).vllimite,0), 2) 
                 + round(nvl(vr_vldscchq,0), 2) 
                 + round(vr_vlutiliz_titulo, 2) 
                 + round(NVL(vr_vllimcred, 0), 2) 
                 - round(nvl(vr_total_liquidacoes,0), 2);
  
  
    vr_string_contrato_epr := vr_string_contrato_epr || 
                              fn_tag('Proposta Atual', to_char(round(nvl(vr_vlfinanc, 0),2), '999g999g990d00'));
                              
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Saldo Devedor de Empréstimo', to_char(round(nvl(vr_saldo_devedor_empr,0), 2), '999g999g990d00'));
                              
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Proposta em andamento com Decisão Aprovada', to_char(round(nvl(vr_vlfinanc_andamento,0), 2), '999g999g990d00'));
  
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Limite de Crédito', to_char(round(nvl(vr_tab_valores_conta(1).vllimite,0), 2), '999g999g990d00'));
                              
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Valor Utilizado do Limite de Desconto de Cheque', to_char(round(nvl(vr_vldscchq,0), 2), '999g999g990d00'));
  
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Valor Utilizado do Limite de Desconto de Título', to_char(round(nvl(vr_vlutiliz_titulo,0), 2), '999g999g990d00'));

    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(+) Limite Cartão de Crédito', to_char(round(NVL(vr_vllimcred, 0), 2), '999g999g990d00'));
  
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('(-) Liquidações', to_char(round(nvl(vr_total_liquidacoes,0), 2), '999g999g990d00'));
                              
    vr_string_contrato_epr := vr_string_contrato_epr ||
                              fn_tag('Total', to_char(vr_vlendtot, '999g999g990d00'));

                              
    vr_string_contrato_epr := vr_string_contrato_epr || '</campos></subcategoria>';
   vr_string_aux := null;
   pc_mensagem_motor(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_nrctrato => pr_nrctrato,
                     pr_cdcritic => pr_cdcritic,
                     pr_dscritic => pr_dscritic,
                     pr_dsxmlret => vr_string_aux);    
    IF vr_string_aux IS NOT NULL THEN
      vr_string_contrato_epr := vr_string_contrato_epr || vr_string_aux;
    END IF;
  
   vr_string_aux := null;                     
   pc_consulta_outras_pro_epr(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrctrato => pr_nrctrato
                             ,pr_cdcritic => pr_cdcritic
                             ,pr_dscritic => pr_dscritic                             
                             ,pr_dsxmlret => vr_string_aux); 
  
    -- Escrever no XML
   pc_escreve_xml(pr_xml            => vr_dsxmlret,
                  pr_texto_completo => vr_string_contrato_epr,
                  pr_texto_novo     => vr_string_aux,
                   pr_fecha_xml => TRUE);
  
    pr_dsxmlret := vr_dsxmlret;
  
  EXCEPTION
    WHEN vr_erro THEN
       pr_cdcritic := 0;
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_epr: '||sqlerrm;    
    
  end;

  PROCEDURE pc_consulta_proposta_cc(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                  ,pr_nrctrato  IN number
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                  
                                  ,pr_dsxmlret  OUT CLOB) IS
    /* .............................................................................
    
      Programa: pc_consulta_proposta_cc
      Sistema : Aimaro/Ibratan
      Autor   : Rubens Lima
      Data    : Março/2019                 Ultima atualizacao: 15/07/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Consulta proposta para Cartão de Crédito
    
      Alteracoes: Consulta Cartão Anterior.
    ..............................................................................*/
  
    --Variáveis
    vr_string         VARCHAR2(32767) := NULL;
    vr_vllimsgrd      CLOB; --limite sugerido
    vr_dstipcart      VARCHAR2(100); --descrição do tipo cartão
    vr_qtcartadc      NUMBER := 0;
    vr_dsxml_mensagem CLOB;
    vr_limite_solicitado NUMBER;
  
    /*Busca dados cartão*/
    CURSOR c_busca_dados_cartao_cc IS
    SELECT c.vllimcrd vllimativo
          ,a.nmresadm categorianova
    FROM crawcrd c
        ,crapadc a
       WHERE c.cdcooper = a.cdcooper
         AND c.cdadmcrd = a.cdadmcrd
         AND c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctrcrd = pr_nrctrato;
    r_busca_dados_cartao_cc c_busca_dados_Cartao_cc%ROWTYPE;
  
    /*Busca histórico de alteração de limite*/
  CURSOR c_historico_credito (pr_nrdconta crapass.nrdconta%TYPE
                             ,pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT 
             atu.vllimite_anterior
            ,TRUNC(atu.dtalteracao) dtalteracao
        FROM tbcrd_limite_atualiza atu
            ,crapadc a
       WHERE a.cdcooper = atu.cdcooper
         AND a.cdadmcrd = atu.cdadmcrd
         AND atu.cdcooper = pr_cdcooper
         AND atu.nrdconta = pr_nrdconta
         --AND atu.nrproposta_est IS NOT NULL
         AND atu.tpsituacao = 3 /* Concluido com sucesso */
         AND atu.dtalteracao = (SELECT max(dtalteracao)
                                  FROM tbcrd_limite_atualiza lim
                                 WHERE lim.cdcooper = atu.cdcooper
                                   AND lim.nrdconta = atu.nrdconta
                                   AND lim.nrconta_cartao = atu.nrconta_cartao
                                   AND NVL(lim.nrproposta_est,0) = NVL(atu.nrproposta_est,0))
       ORDER BY idatualizacao DESC;
    r_historico_credico c_historico_credito%ROWTYPE;
    
    /*Busca valor solicitado na alteração do limite de crédito*/
    CURSOR c_alteracao_limite_credito IS
      SELECT atu.vllimite_alterado, a.nmresadm categorianova
        FROM tbcrd_limite_atualiza atu, crapadc a
       WHERE atu.cdcooper = pr_cdcooper
         AND atu.nrdconta = pr_nrdconta
         AND atu.cdcooper = a.cdcooper
         AND atu.cdadmcrd = a.cdadmcrd
         AND atu.nrproposta_est = pr_nrctrato --23558
         AND atu.tpsituacao = 6 /* Em Analise */
         AND atu.dtalteracao = (SELECT MAX(dtalteracao)
                                  FROM tbcrd_limite_atualiza lim
                                 WHERE lim.cdcooper = atu.cdcooper
                                   AND lim.nrdconta = atu.nrdconta
                                   AND lim.nrconta_cartao = atu.nrconta_cartao
                                   AND NVL(lim.nrproposta_est,0) = NVL(atu.nrproposta_est,0))
       ORDER BY idatualizacao DESC;
    r_alteracao_limite_credito c_alteracao_limite_credito%ROWTYPE;
  
    /*Dados do cartão em uso: Categoria Anterior, Limite Ativo
    Quando o proponente tiver mais de um cartão de crédito , por exemplo Ailos Clássico e Ailos Debito
    trazer para a tela única sempre a informação do cartão de credito e com a titularidade do proponente.*/
   CURSOR c_busca_dados_cartao_uso (pr_cdcooper crawcrd.cdcooper%TYPE
                                   ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
      SELECT a.nmresadm --Categoria Anterior
          ,c.vllimcrd --Limite Ativo
     FROM crawcrd c
         ,crapadc a
       WHERE c.cdcooper = a.cdcooper
         AND c.cdadmcrd = a.cdadmcrd
         AND c.nrdconta = pr_nrdconta
         AND c.cdcooper = pr_cdcooper
         AND c.insitcrd = 4 --Em uso
      ORDER BY C.DTPROPOS DESC;
    r_busca_dados_cartao_uso c_busca_dados_cartao_uso%ROWTYPE;
  
  BEGIN
  
       vr_string := '<subcategoria>'||
                    '<tituloTela>Produto Cartão de Crédito</tituloTela>'||
                    '<campos>';
  
    /*Busca dados do cartão solicitado*/
    OPEN c_busca_dados_cartao_cc;
      FETCH c_busca_dados_cartao_cc INTO r_busca_dados_cartao_cc;
      
    CLOSE c_busca_dados_cartao_cc;
  
    /*Busca categoria do cartão anterior (EM USO)*/
     OPEN c_busca_dados_cartao_uso (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta);
      FETCH c_busca_dados_cartao_uso INTO r_busca_dados_cartao_uso;
    CLOSE c_busca_dados_cartao_uso;
  
    /*Busca limite sugerido do motor*/
    BEGIN
      vr_vllimsgrd := fn_le_json_motor_auto_aprov(p_cdcooper => pr_cdcooper, p_nrdconta => pr_nrdconta,
                                                  p_nrdcontrato => pr_nrctrato, p_tagFind => vr_dstipcart,
                                                  p_hasDoisPontos => FALSE, p_idCampo => 0);
      /*Extrai valor numérico do texto*/
      vr_vllimsgrd := regexp_substr(vr_vllimsgrd, '[[:digit:]].+');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    /*Busca quantidade de cartão adicional - bug 23558*/
    BEGIN
      SELECT COUNT(1)
        INTO vr_qtcartadc
        FROM crawcrd c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.insitcrd = 4 --em uso
         AND NOT EXISTS (select 1
                         from tbcrd_limite_atualiza
                         where cdcooper = c.cdcooper
                         and   nrdconta = c.nrdconta
                         and   nrproposta_est = pr_nrctrato);

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    OPEN c_historico_credito(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
    FETCH c_historico_credito
      INTO r_historico_credico;
    CLOSE c_historico_credito;
    
    -- Verificar se o contrato da proposta de cartão é uma alteração de limite que está em análise
    OPEN c_alteracao_limite_credito;
    FETCH c_alteracao_limite_credito
      INTO r_alteracao_limite_credito;
      IF c_alteracao_limite_credito%FOUND THEN
          vr_limite_solicitado := r_alteracao_limite_credito.vllimite_alterado;
          vr_dstipcart := r_alteracao_limite_credito.categorianova;  
      ELSE
          vr_limite_solicitado := r_busca_dados_cartao_cc.vllimativo;
          vr_dstipcart := r_busca_dados_cartao_cc.categorianova;  
      END IF;
    CLOSE c_alteracao_limite_credito;
    
    /*Classifica o tipo do cartão*/
    IF (UPPER(vr_dstipcart) LIKE '%ESSENCIAL%') THEN
      vr_dstipcart := 'ESSENCIAL';
    ELSIF (UPPER(vr_dstipcart) LIKE '%PLATINUM%') THEN
      vr_dstipcart := 'PLATINUM';
    ELSIF (UPPER(vr_dstipcart) LIKE '%GOLD%') THEN
      vr_dstipcart := 'GOLD';
    ELSIF (UPPER(vr_dstipcart) LIKE '%EMPRESAS%') THEN
      vr_dstipcart := 'EMPRESAS';
    ELSE
      vr_dstipcart := 'CLASSICO';
    END IF;
  
    vr_string := vr_string || fn_tag('Proposta', gene0002.fn_mask_contrato(pr_nrctrato));
    vr_string := vr_string ||
                 fn_tag('Valor de Limite Solicitado', to_char(vr_limite_solicitado, '999g999g990d00'));
    vr_string := vr_string || fn_tag('Nova Categoria', 'AILOS ' || vr_dstipcart);
  
    vr_string := vr_string || fn_tag('Quantidade de Cartão Adicional', vr_qtcartadc);
    vr_string := vr_string || fn_tag('Valor do Limite Sugerido', vr_vllimsgrd);
  
    vr_string := vr_string ||
                 fn_tag('Valor do Limite Ativo', to_char(r_busca_dados_cartao_uso.vllimcrd, '999g999g990d00'));
    vr_string := vr_string ||
                 fn_tag('Valor do Limite Anterior', to_char(r_historico_credico.vllimite_anterior, '999g999g990d00'));
    vr_string := vr_string || fn_tag('Categoria Anterior', r_busca_dados_cartao_uso.nmresadm);
    vr_string := vr_string ||
                 fn_tag('Última Data da Alteração do Limite', to_char(r_historico_credico.dtalteracao, 'DD/MM/YYYY'));
  
    IF (vr_string IS NOT NULL) THEN
      vr_string := vr_string || '</campos></subcategoria>';
    END IF;
  
    vr_dsxml_mensagem := NULL;
    pc_mensagem_motor(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctrato => pr_nrctrato,
                      pr_cdcritic => pr_cdcritic,
                      pr_dscritic => pr_dscritic,
                      pr_dsxmlret => vr_dsxml_mensagem);
  
    IF vr_dsxml_mensagem IS NOT NULL THEN
      pr_dsxmlret := vr_string || vr_dsxml_mensagem;
    ELSE
      pr_dsxmlret := vr_string;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_cc: '||sqlerrm;     
  END;

  /* Proposta Borderô Desconto de Títulos*/
  PROCEDURE pc_consulta_proposta_bordero (pr_cdcooper IN crapass.cdcooper%TYPE        --> Cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                         ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                         ,pr_dsxmlret IN OUT CLOB) is
  /* .............................................................................

    Programa: pc_consulta_proposta_bordero
    Sistema : Aimaro/Ibratan
    Autor   : Rubens Lima
    Data    : 05/04/2019                 Ultima atualizacao: 25/07/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta do borderô de desconto de títulos

    Alteracoes: Adequações na rotina para ler as informações de forma correta,
                21/05/2018 - Rafael Monteir (Mouts) 
                
                30/05/2019 - Remover linha Taxa Anual e coluna Convenio.
                             Story 21826 (Sprint 11) - PRJ438 - Gabriel Marcos (Mouts).

                05/06/2019 - Retorno diferente de nulo (nada consta) deve ser considerado
                             como restricao, mesmo que o valor negativado seja igual a zero.
                             Bug 22256 - PRJ438 - Gabriel Marcos (Mouts).
                             
                14/06/2019 - Incluído Críticas do Cedente para o Borderô e as restrições de cada pagador.
                             Story 22427 (Sprint 13) - PRJ438 - Rubens Lima (Mouts).

  ..............................................................................*/

  /*Proposta do borderô*/
  cursor c_consulta_prop_desc_titulo is
    SELECT d.dtmvtolt
          ,d.nrborder
          ,d.nrctrlim
          ,d.txmensal as txmensal
          ,count(1) qtdtitulos
          ,sum(d.vltitulo) vltitulo
          ,sum(d.vlliquid) vlliquid
          ,sum(d.vltitulo) / count(1) vlmedio
          ,d.flverbor
    from
      (SELECT b.dtmvtolt
            ,b.nrborder
            ,b.nrctrlim
            ,b.txmensal
            ,t.vltitulo
            ,t.vlliquid
            ,b.flverbor 
      FROM   crapbdt b
            ,crawlim w
            ,craptdb t
      where b.cdcooper = w.cdcooper
      and   b.nrdconta = w.nrdconta
      and   t.cdcooper = b.cdcooper
      and   t.nrdconta = b.nrdconta
      and   t.nrborder = b.nrborder
      and   w.nrctrlim = b.nrctrlim
      and   b.insitbdt = 1 -- em estudo
      and   b.insitapr = 6 -- enviado para Analise
      and   w.cdcooper = pr_cdcooper
      and   w.nrdconta = pr_nrdconta
      and   b.nrborder = pr_nrctrato) d
    group by d.dtmvtolt
            ,d.nrborder
            ,d.nrctrlim
            ,d.txmensal
            ,d.flverbor;
  r_consulta_prop_desc_titulo c_consulta_prop_desc_titulo%ROWTYPE;

  /* Títulos do Borderô */
  cursor c_consulta_tits_bordero (pr_nrctrato IN craptdb.nrctrlim%TYPE,
                                  pr_nrborder IN craptdb.nrborder%TYPE) IS
  /*b1wgen0030i.p*/                               
  select c.nrcnvcob
        ,c.nrdocmto 
        ,c.nrnosnum
        ,s.nmdsacad
        ,c.nrinssac cpfcgc
        ,t.dtvencto
        ,t.vltitulo
        ,t.vlliquid
        ,c.dtvencto -(select d.dtmvtolt from crapdat d where d.cdcooper = c.cdcooper) prazo
        ,(select case when count(1)>0 then 'Sim' else 'Não' end
         from crapabt r
         where r.cdcooper = t.cdcooper
         and   r.nrdconta = t.nrdconta
         and   r.nrborder = t.nrborder
         and   r.dsrestri is not null) restricoes
        --Informações adicionais para buscar a crrítica
        ,c.nrdctabb
        ,c.cdbandoc
        ,c.nrinssac --cpf/cnpj sem formação para buscar o volume carteira
        ,t.cdbandoc || ';' ||
         t.nrdctabb || ';' ||
         t.nrcnvcob || ';' ||
         t.nrdocmto chave
  from craptdb t,
       crapcob c,
       crapsab s
  where t.cdcooper = pr_cdcooper
  and   t.nrdconta = pr_nrdconta
  and   t.nrctrlim = pr_nrctrato
  and   t.nrborder = pr_nrborder 
  and   c.cdcooper = t.cdcooper
  and   c.nrdconta = t.nrdconta
  and   c.nrdocmto = t.nrdocmto
  and   c.nrcnvcob = t.nrcnvcob
  and   s.cdcooper = c.cdcooper
  and   s.nrdconta = c.nrdconta
  and   s.nrinssac = c.nrinssac;
  
  /*Titulos a Vencer para para Volume Carteira Descontada*/
  cursor c_titulos_a_vencer (pr_nrinssac crapcob.nrinssac%TYPE) is
    select nvl(sum(c.vltitulo) - sum(vldpagto),0) as volCartVencer
    from crapcob c
    where  c.cdcooper = pr_cdcooper
    and    c.nrdconta = pr_nrdconta
    and    c.nrinssac = pr_nrinssac --cpf/cnpj do interveniente
    and    c.incobran <> 5 --Liquidado
    and    c.dtvencto > (select d.dtmvtolt
                        from crapdat d
                        where d.cdcooper = c.cdcooper);--data sistema
                        

  CURSOR c_busca_conta_pagador (pr_cdcooper crapass.cdcooper%TYPE
                               ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
   SELECT a.nrdconta
   FROM crapass a
   WHERE a.cdcooper = pr_cdcooper
   AND   a.nrcpfcgc = pr_nrcpfcgc;
   vr_nrdconta_pagador NUMBER;                           

  /*Busca críticas do cedente*/
  CURSOR c_busca_criticas_cedente IS
    SELECT 
      cri.dscritica,
      abt.dsdetres
    FROM 
      crapabt abt
      INNER JOIN tbdsct_criticas cri ON cri.cdcritica = abt.nrseqdig
    WHERE
      abt.cdcooper = pr_cdcooper
      AND abt.nrborder = pr_nrctrato --Número do borderô
      AND cri.tpcritica = 4;
  r_busca_criticas_cedente c_busca_criticas_cedente%ROWTYPE;  

  TYPE typ_rec_pagadores IS RECORD
   (nrinssac number
   ,nrdconta number
   ,chave    varchar2(30));
   
  TYPE typ_tab_pagadores IS TABLE OF typ_rec_pagadores INDEX BY BINARY_INTEGER;

  vr_tab_pagadores typ_tab_pagadores;

  

  vr_existe_pagador BOOLEAN;
                        
  --Variáveis
  vr_string         CLOB;
  vr_string_aux     CLOB;
  vr_string_critica CLOB;
  vr_index          NUMBER;
  vr_index2         NUMBER;
  vr_idx_criticas   NUMBER;
  vr_idx_secundar   NUMBER;
  vr_index_biro     NUMBER;

  vr_dsxml_mensagem CLOB;
  vr_dsxmlret CLOB;  
  
  pr_retxml         XMLTYPE;
  pr_nmdcampo       VARCHAR2(100);
  pr_des_erro       VARCHAR2(300);
  vr_val_venc       NUMBER;
                                         
  vr_nrdocmto       VARCHAR2(100);
  vr_pos_inic       NUMBER;
  vr_tamanho        NUMBER;
  vr_dsc_critica    VARCHAR2(100);
  vr_vlr_critica    VARCHAR2(100);
  
  --
  tem_criticas      BOOLEAN;
  
  --Percentuais de concentração dos titulos do borderô
  vr_perc_concentracao VARCHAR2(100);
  vr_perc_liquidez_vl  VARCHAR2(100);
  
  --Para calculo do valor líquido do titulo
  vr_qtd_dias       NUMBER;
  vr_vldjuros       NUMBER; 
  --Para verificar as taxas de acordo com a versão do bordero
  vr_rel_txdiaria   NUMBER;
  fmt_txdiaria      VARCHAR2(100);

  vr_vlliquid_total  craptdb.vlliquid%type := 0;
  --
  vr_tab_dados_biro         TELA_ATENDA_DSCTO_TIT.typ_tab_dados_biro;
  vr_tab_dados_detalhe      TELA_ATENDA_DSCTO_TIT.typ_tab_dados_detalhe;  
  vr_tab_dados_critica      TELA_ATENDA_DSCTO_TIT.typ_tab_dados_critica;
  vr_nrinssac          crapsab.nrinssac%TYPE;
  vr_nmdsacad          crapsab.nmdsacad%TYPE;  
  vr_tem_restricao BOOLEAN;
  vr_contador_restricao NUMBER;
  
  --Tabela para as críticas
  vr_tab_criticas dsct0003.typ_tab_critica;
  
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_chave    VARCHAR2(100); --bug 23498
  vr_nrborder crapbdt.nrborder%TYPE;
                                          
BEGIN

  vr_string := '<subcategoria>'||
               '<tituloTela>Borderô de Desconto de Títulos</tituloTela>';

  open c_consulta_prop_desc_titulo;
    fetch c_consulta_prop_desc_titulo into r_consulta_prop_desc_titulo;
    if c_consulta_prop_desc_titulo%NOTFOUND then
      null;
    else
      
      -- Se for bordero novo utiliza Juros Simples, senão Juros Composto
      if (r_consulta_prop_desc_titulo.flverbor = 1) then
        vr_rel_txdiaria := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) / 30) * 100,7); 
        --vr_rel_txdanual := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) * 12) * 100,6); 
      ELSE
        vr_rel_txdiaria := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) / 30) * 100,7);                    
        --vr_rel_txdanual := apli0001.fn_round((power(1 + (r_consulta_prop_desc_titulo.txmensal / 100), 12) - 1) * 100,6);
      end if;
    
    /*Bug 23548*/
    IF vr_rel_txdiaria < 1 THEN
      fmt_txdiaria := '0' || vr_rel_txdiaria;
    ELSE
      fmt_txdiaria := vr_rel_txdiaria;
    END IF;    
    
      vr_string := vr_string || '<campos>'||
                           fn_tag('Data da Proposta',to_char(r_consulta_prop_desc_titulo.dtmvtolt,'DD/MM/YYYY'))||
                           fn_tag('Borderô',r_consulta_prop_desc_titulo.nrborder)||
                           fn_tag('Contrato',gene0002.fn_mask_contrato(r_consulta_prop_desc_titulo.nrctrlim))||
                           --fn_tag('Taxa Anual',trim(to_char(vr_rel_txdanual,'990d999'))|| '%')||
                           fn_tag('Taxa Mensal',trim(to_char(r_consulta_prop_desc_titulo.txmensal,'990d999'))|| '%')||
                           fn_tag('Taxa Diária',fmt_txdiaria || '%');
    
   vr_index := 1;
   vr_idx_secundar := 1;
   vr_index2 := 0; --para a tabela de criticas
   
   vr_tab_tabela.delete;
   vr_tab_tabela_secundaria.delete;


   /*Monta cabeçalho da tabela com as críticas dos títulos do borderô*/
   vr_string_critica := vr_string_critica||'<campo>
                                             <nome>Críticas dos Títulos</nome>
                                             <tipo>table</tipo>
                                             <valor>
                                             <linhas>';
  vr_contador_restricao := 0;
   --Para cada título da proposta
  FOR r_titulos in c_consulta_tits_bordero(pr_nrctrato => r_consulta_prop_desc_titulo.nrctrlim,
                                           pr_nrborder => r_consulta_prop_desc_titulo.nrborder) LOOP 

    IF (vr_index = 1) THEN

     /*Monta a tabela com os títulos dos borderôs*/
     vr_string_aux := vr_string_aux||'<campo>
                                      <nome>Títulos do Borderô</nome>
                                      <tipo>table</tipo>
                                      <valor>
                                      <linhas>';
    END IF;
   
    vr_tab_tabela(vr_index).coluna1 := r_titulos.nrdocmto;
    vr_tab_tabela(vr_index).coluna2 := r_titulos.nrnosnum;
    vr_tab_tabela(vr_index).coluna3 := r_titulos.nmdsacad;
    vr_tab_tabela(vr_index).coluna4 := gene0002.fn_mask_cpf_cnpj(r_titulos.cpfcgc,case when length(r_titulos.cpfcgc) > 11 then 2 else 1 end);
    vr_tab_tabela(vr_index).coluna5 := to_char(r_titulos.dtvencto,'DD/MM/YYYY');
    vr_tab_tabela(vr_index).coluna6 := to_char(r_titulos.vltitulo,'999g999g990d00');
    
    /*Verifica se o valor líquido do título é 0, se for calcula*/
    BEGIN
      IF (r_titulos.vlliquid = 0) THEN
        
        IF  rw_crapdat.dtmvtolt > r_titulos.dtvencto THEN
          vr_qtd_dias := rw_crapdat.dtmvtolt - r_titulos.dtvencto;
        ELSE
          vr_qtd_dias := r_titulos.dtvencto -  rw_crapdat.dtmvtolt;
        END IF;
        
        vr_vldjuros := r_titulos.vltitulo * vr_qtd_dias * ((r_consulta_prop_desc_titulo.txmensal / 100) / 30);
        r_titulos.vlliquid := ROUND((r_titulos.vltitulo - vr_vldjuros),2);
        vr_vlliquid_total := vr_vlliquid_total+r_titulos.vlliquid;
        
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        null;
    END;
    
    vr_tab_tabela(vr_index).coluna7 := to_char(r_titulos.vlliquid,'999g999g990d00');
    vr_tab_tabela(vr_index).coluna8 := r_titulos.prazo;
    
    /*Limpa a chave*/
    vr_chave := NULL;
    
    /*Consulta volume carteira a vencer em relação ao sacado*/    
    open c_titulos_a_vencer(r_titulos.nrinssac);
      fetch c_titulos_a_vencer into vr_val_venc;
      if c_titulos_a_vencer%found then
        vr_tab_tabela(vr_index).coluna11 := to_char(vr_val_venc,'999g999g990d00');
      else
        vr_tab_tabela(vr_index).coluna11 := 0;
      end if;    
    close c_titulos_a_vencer;    

    TELA_ATENDA_DSCTO_TIT.pc_detalhes_tit_bordero(pr_cdcooper    --> código da cooperativa
                           ,pr_nrdconta          --> número da conta
                           ,r_consulta_prop_desc_titulo.nrborder --> Numero do bordero
                           ,r_titulos.chave              --> lista de 'nosso numero' a ser pesquisado
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
    --IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;                                  
    
    /*Validação para não repetir o pagador*/
    vr_existe_pagador := FALSE;
    vr_index_biro := vr_tab_pagadores.first;
    
    WHILE vr_index_biro IS NOT NULL LOOP
      /*Se o pagador já foi contabilizado, sai do laço*/
      IF ( vr_tab_pagadores(vr_index_biro).nrinssac =  vr_nrinssac) THEN
        vr_existe_pagador := TRUE;
        EXIT;
      END IF;

      IF (vr_tab_pagadores.count)-1 > vr_index_biro THEN 
        vr_index_biro := vr_index_biro + 1;
      ELSE
        EXIT;
      END IF;
    END LOOP;
    
    IF NOT vr_existe_pagador THEN
      IF vr_index_biro is null then
        vr_index_biro := 0;
        ELSE
        vr_index_biro := vr_index_biro + 1;           
      END IF;

      vr_tab_pagadores(vr_index_biro).nrinssac := vr_nrinssac;

      /*Busca a conta pelo CPF/CNPJ*/
      OPEN c_busca_conta_pagador(pr_cdcooper => pr_cdcooper
                                ,pr_nrcpfcgc => r_titulos.cpfcgc);
       FETCH c_busca_conta_pagador INTO vr_nrdconta_pagador;
       /*Grava a conta do pagador*/
       vr_tab_pagadores(vr_index_biro).nrdconta := vr_nrdconta_pagador;
      CLOSE c_busca_conta_pagador;
            
      vr_tab_pagadores(vr_index_biro).chave := r_titulos.chave;

      BEGIN
        vr_tem_restricao := FALSE;
        vr_index_biro := vr_tab_dados_biro.first;
        WHILE vr_index_biro IS NOT NULL LOOP  
          IF vr_tab_dados_biro(vr_index_biro).vlnegati IS NOT NULL THEN
            vr_tem_restricao := TRUE;
          END IF;
          vr_index_biro := vr_tab_dados_biro.next(vr_index_biro);
        END LOOP;      
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    END IF;
    
    IF vr_tem_restricao THEN
      vr_contador_restricao := vr_contador_restricao + 1;
      vr_tab_tabela(vr_index).coluna9 := 'Sim';
    ELSE
      vr_tab_tabela(vr_index).coluna9 := 'Nao';
    END IF; 
    --
    -- Agora vê se tem críticas
    BEGIN
      
      vr_nrdocmto := vr_nrinssac;
      vr_idx_criticas  := vr_tab_dados_critica.first;
                                                           
      WHILE vr_idx_criticas IS NOT NULL LOOP
          
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna1 := r_titulos.nrnosnum;           
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna2 := vr_tab_dados_critica(vr_idx_criticas).dsc;
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna3 := vr_tab_dados_critica(vr_idx_criticas).vlr; --vlr da crítica

        vr_idx_secundar := vr_idx_secundar + 1;
        vr_idx_criticas := vr_tab_dados_critica.next(vr_idx_criticas);
      END LOOP;
      --
      IF (vr_tab_tabela_secundaria.count > 0) THEN
        vr_tab_tabela(vr_index).coluna10 := 'Sim';
      ELSE
        vr_tab_tabela(vr_index).coluna10 := 'Não';
      END IF;
     
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        pr_dscritic := SQLERRM;
    END;

   
    BEGIN
      vr_perc_concentracao := vr_tab_dados_detalhe(0).concpaga;
      vr_perc_liquidez_vl  := vr_tab_dados_detalhe(0).liqpagcd;
            
      --se iniciar com vírgula concatena um 0 a esquerda
      vr_tab_tabela(vr_index).coluna12 := case when substr(vr_perc_concentracao,1,1) = ',' 
                                          then 0 || vr_perc_concentracao || '%'
                                          else      vr_perc_concentracao || '%' end;
      vr_tab_tabela(vr_index).coluna13 := vr_perc_liquidez_vl|| '%';

    EXCEPTION
      WHEN OTHERS THEN
        vr_tab_tabela(vr_index).coluna12 := '-';
        vr_tab_tabela(vr_index).coluna13 := '-';
    END;
    /*Incrementa o índice*/
    vr_index := vr_index+1;    
  END LOOP;
  --
  IF vr_tab_tabela_secundaria.count > 0 THEN
    vr_string_critica := vr_string_critica || fn_tag_table('Nosso Número;
                                                            Crítica;
                                                            Valor',vr_tab_tabela_secundaria);    
  ELSE
    vr_tab_tabela_secundaria(1).coluna1 := '-';
    vr_tab_tabela_secundaria(1).coluna2 := '-';
    vr_tab_tabela_secundaria(1).coluna3 := '-';
    vr_string_critica := vr_string_critica || fn_tag_table('Nosso Número;
                                                            Crítica;
                                                            Valor',
                                                            vr_tab_tabela_secundaria);

      
  END IF;        
  vr_string_critica := vr_string_critica||'</linhas></valor></campo>';
  vr_string_critica := vr_string_critica||'</campos>';  
  --
   /*Monta a tabela dos titulos*/
   IF vr_tab_tabela.COUNT > 0 THEN
     /*Gera Tags Xml*/
     vr_string_aux := vr_string_aux||fn_tag_table('Boleto Número;
                                                   Nosso Número;
                                                   Nome Pagador;
                                                   CPF/CNPJ do Pagador;
                                                   Data de Vencimento;
                                                   Valor do Título;
                                                   Valor Líquido;
                                                   Prazo;
                                                   Restrições;
                                                   Críticas;
                                                   Volume Carteira a Vencer;
                                                   % Concentração por Pagador;
                                                   % Liquidez do Pagador com a Cedente',
                                                   vr_tab_tabela);
     vr_string_aux := vr_string_aux||'</linhas></valor></campo>';
   ELSE
     vr_tab_tabela(1).coluna1  := '-'; -- Boleto Número
     vr_tab_tabela(1).coluna2  := '-'; -- Nosso Número
     vr_tab_tabela(1).coluna3  := '-'; -- Nome Pagador
     vr_tab_tabela(1).coluna4  := '-'; -- CPF/CNPJ do Pagador
     vr_tab_tabela(1).coluna5  := '-'; -- Data de Vencimento
     vr_tab_tabela(1).coluna6  := '-'; -- Valor do Título
     vr_tab_tabela(1).coluna7  := '-'; -- Valor Líquido
     vr_tab_tabela(1).coluna8  := '-'; -- Prazo
     vr_tab_tabela(1).coluna9  := '-'; -- Restrições
     vr_tab_tabela(1).coluna10 := '-'; -- Críticas
     vr_tab_tabela(1).coluna11 := '-'; -- Volume Carteira a Vencer
     vr_tab_tabela(1).coluna12 := '-'; -- % Concentração por Pagador
     vr_tab_tabela(1).coluna13 := '-'; -- % Liquidez do Pagador com a Cedente

     vr_string_aux := vr_string_aux||fn_tag_table('Boleto Número;
                                                   Nosso Número;
                                                   Nome Pagador;
                                                   CPF/CNPJ do Pagador;
                                                   Data de Vencimento;
                                                   Valor do Título;
                                                   Valor Líquido;
                                                   Prazo;
                                                   Restrições;
                                                   Críticas;
                                                   Volume Carteira a Vencer;
                                                   % Concentração por Pagador;
                                                   % Liquidez do Pagador com a Cedente',
                                                   vr_tab_tabela);
     vr_string_aux := vr_string_aux||'</linhas></valor></campo>';
   END IF;


  END IF;
    
  CLOSE c_consulta_prop_desc_titulo;
  
  vr_string := vr_string ||fn_tag('Quantidade de Títulos',r_consulta_prop_desc_titulo.qtdtitulos)||
                           fn_tag('Valor',TO_CHAR(r_consulta_prop_desc_titulo.vltitulo,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor Líquido',TO_CHAR(vr_vlliquid_total,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor Médio',TO_CHAR(r_consulta_prop_desc_titulo.vlmedio,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Restrições',vr_contador_restricao);


  /*Críticas do cedente*/
  vr_tab_tabela.delete;
  vr_index := 0;
  OPEN c_busca_criticas_cedente;
  LOOP
   FETCH c_busca_criticas_cedente INTO r_busca_criticas_cedente;
   EXIT WHEN c_busca_criticas_cedente%NOTFOUND;

     vr_index := vr_index + 1;
     
    /*Cabeçalho do primeiro registro*/
    IF (vr_index = 1) THEN
      vr_string := vr_string||'<campo>
                                <nome>Críticas do Cedente</nome>
                                <tipo>table</tipo>
                                <valor>
                                <linhas>';
    END IF;
    
    vr_tab_tabela(vr_index).coluna1 := r_busca_criticas_cedente.dscritica;
    vr_tab_tabela(vr_index).coluna2 := r_busca_criticas_cedente.dsdetres;
   
  END LOOP;
  IF (vr_index > 0) THEN
  vr_string := vr_string||fn_tag_table('Crítica;Valor',vr_tab_tabela);
  vr_string := vr_string||'</linhas></valor></campo>';    
  END IF;

  CLOSE c_busca_criticas_cedente;
  
  /*Incluí os títulos do borderô contidos na "vr_string_aux"*/
  vr_string := vr_string || vr_string_aux;


  /*RESTRITIVOS - Tabela com as restrições de cada pagador*/
  vr_index := 0;
  vr_index2 := 0;
  
  vr_tab_tabela.delete;
  IF vr_tab_pagadores.count > 0 THEN
    FOR r1 in vr_tab_pagadores.first .. vr_tab_pagadores.last LOOP
      /*Se for o primeiro registro, monta o cabeçalho*/  
      IF vr_index = 0 THEN
        vr_string := vr_string||'<campo>
                                 <nome>Restritivos por Pagador</nome>
                                 <tipo>table</tipo>
                                 <valor>
                                 <linhas>';
      END IF;
      
      vr_nrdconta  := vr_tab_pagadores(vr_index).nrdconta;
      vr_chave     := vr_tab_pagadores(vr_index).chave;
      vr_nrborder  := r_consulta_prop_desc_titulo.nrborder;
      
      /*Busca os detalhes dos títulos e suas restrições:
      REFIN, PEFIN, Protesto, Ação Judicial, Participação falência, Cheque sem fundo, Cheque Sust./Extrav., SERASA, SPC)*/
      TELA_ATENDA_DSCTO_TIT.pc_detalhes_tit_bordero(pr_cdcooper          --> código da cooperativa
                                                   ,pr_nrdconta          --> número da conta
                                                   ,vr_nrborder          --> Numero do bordero
                                                   ,vr_chave          --> lista de 'nosso numero' a ser pesquisado
                                                   --------> out <--------
                                                   ,vr_nrinssac          --> Inscricao do sacado
                                                   ,vr_nmdsacad          --> Nome do sacado
                                                   ,vr_tab_dados_biro    -->  retorno do biro
                                                   ,vr_tab_dados_detalhe -->  retorno dos detalhes
                                                   ,vr_tab_dados_critica --> retorno das criticas
                                                   ,vr_cdcritic          --> código da crítica
                                                   ,vr_dscritic          --> descrição da crítica
                                                   );
      
      /*Se tiver críticas*/
      IF (vr_tab_dados_biro.count > 0) THEN

        /*Iteração na tabela de críticas*/
        FOR R2 IN vr_tab_dados_biro.first .. vr_tab_dados_biro.last LOOP
          IF vr_tab_dados_biro(r2).qtnegati > 0 THEN
          --IF vr_tab_dados_biro(r2).vlnegati > 0 THEN --bug 23574       
            vr_index2 := vr_index2 + 1;
            vr_tab_tabela(vr_index2).coluna1 := vr_nmdsacad;
            vr_tab_tabela(vr_index2).coluna2 := vr_tab_dados_biro(r2).dsnegati;
            vr_tab_tabela(vr_index2).coluna3 := to_char(vr_tab_dados_biro(r2).vlnegati,'999g999g999g990d00');
            vr_tab_tabela(vr_index2).coluna4 := vr_tab_dados_biro(r2).qtnegati;
            vr_tab_tabela(vr_index2).coluna5 := to_char(vr_tab_dados_biro(r2).dtultneg,'DD/MM/RRRR');
            
          END IF;
        END LOOP;
        
      END IF;
      
      vr_index := vr_index + 1;
    END LOOP;
    vr_string := vr_string||fn_tag_table('Nome;Restritiva;Valor;Quantidade;Data da Ocorrência',vr_tab_tabela);
    vr_string := vr_string||'</linhas></valor></campo>';    
  END IF;
  /*Fim dos Restritivos*/
  
    
  
  
  vr_string := vr_string || vr_string_critica || '</subcategoria>';
  
  vr_dsxml_mensagem := NULL;
  pc_mensagem_motor(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrato => pr_nrctrato,
                    pr_cdcritic => pr_cdcritic,
                    pr_dscritic => pr_dscritic,
                    pr_dsxmlret => vr_dsxml_mensagem);
                    
  IF vr_dsxml_mensagem IS NOT NULL THEN
    -- Escrever no XML
  
    pr_dsxmlret := vr_string || vr_dsxml_mensagem;               
  ELSE
  pr_dsxmlret := vr_string;
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
    cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_bordero: '||sqlerrm;   

end;


  PROCEDURE pc_consulta_outras_pro_epr(pr_cdcooper IN crawepr.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                    ,pr_nrctrato  IN number
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                                    ,pr_dsxmlret  OUT CLOB) is
  
    /*Outras Propostas de emprestimo
    Deve possuir total das propostas
    
    */
    vr_string_outros_epr CLOB;
  vr_total_proposta crawepr.vlemprst%type := 0;
  vr_index   number;
    
  begin
  
  
   if pr_nrctrato > 0 then
   vr_string_outros_epr := '<subcategoria>'||
                             '<tituloTela>Outras Propostas em Andamento</tituloTela>'||
                              '<campos>';
    

   else  /* = 0 Esta sendo chamada das contas de socios*/
     vr_string_outros_epr := vr_string_outros_epr||    '<campo>'||
                                                       '<nome>'||'Conta'||'</nome>'||
                                                       '<tipo>string</tipo>'||
                                                       '<valor>'||pr_nrdconta||'</valor>'||
                                                       '</campo>';    
   end if;                            
  
    vr_string_outros_epr := vr_string_outros_epr || '<campo>
                                                   <nome>Outras Propostas em Andamento</nome>
                                                   <tipo>table</tipo>
                                                   <valor>
                                                   <linhas>';
    vr_index             := 0;
    vr_tab_tabela.delete;
   for r_proposta_out_epr in c_proposta_out_epr(pr_cdcooper,pr_nrdconta) loop
      /*Somente as propostas em andamento diferente da atual*/
    if pr_nrctrato != r_proposta_out_epr.nrctremp then
        vr_index := vr_index + 1;
      
        -- Resetar a variavel
        vr_garantia := '-';
        vr_garantia := fn_garantia_proposta(pr_cdcooper, pr_nrdconta, r_proposta_out_epr.nrctremp,
                                            r_proposta_out_epr.nrctaav1, r_proposta_out_epr.nrctaav2, 'P', c_emprestimo,
                                            FALSE);
      
        vr_tab_tabela(vr_index).coluna1 := to_char(r_proposta_out_epr.dtproposta, 'DD/MM/YYYY');
        vr_tab_tabela(vr_index).coluna2 := gene0002.fn_mask_contrato(r_proposta_out_epr.contrato);
      vr_tab_tabela(vr_index).coluna3  := trim(to_char(r_proposta_out_epr.valor_emprestimo,'999g999g990d00'));
        vr_tab_tabela(vr_index).coluna4 := to_char(r_proposta_out_epr.valor_prestacoes, '999g999g990d00');
        vr_tab_tabela(vr_index).coluna5 := r_proposta_out_epr.qtd_parcelas;
        vr_tab_tabela(vr_index).coluna6 := r_proposta_out_epr.linha;
        vr_tab_tabela(vr_index).coluna7 := r_proposta_out_epr.finalidade;
        vr_tab_tabela(vr_index).coluna8 := r_proposta_out_epr.contratos;
        vr_tab_tabela(vr_index).coluna9 := vr_garantia;
        vr_tab_tabela(vr_index).coluna10 := r_proposta_out_epr.decisao;
      vr_tab_tabela(vr_index).coluna11 := CASE WHEN r_proposta_out_epr.situacao IS NOT NULL THEN
                                          r_proposta_out_epr.situacao ELSE '-' END;
      
        vr_total_proposta := vr_total_proposta + r_proposta_out_epr.vlemprst;
    end if;
   end loop;  
  
    --Total Ultima linha para montar o total
   if vr_tab_tabela.COUNT > 0 then
      vr_index := vr_index + 1;
    
      /**/
      vr_tab_tabela(vr_index).coluna1 := 'Total';
      vr_tab_tabela(vr_index).coluna2 := '-';
      vr_tab_tabela(vr_index).coluna3 := to_char(vr_total_proposta, '999g999g990d00');
      vr_tab_tabela(vr_index).coluna4 := '-';
      vr_tab_tabela(vr_index).coluna5 := '-';
      vr_tab_tabela(vr_index).coluna6 := '-';
      vr_tab_tabela(vr_index).coluna7 := '-';
      vr_tab_tabela(vr_index).coluna8 := '-';
      vr_tab_tabela(vr_index).coluna9 := '-';
      vr_tab_tabela(vr_index).coluna10 := '-';
      vr_tab_tabela(vr_index).coluna11 := '-';
      /**/
   end if;
                                               
     
    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Prestações;Quantidade de Parcelas;Linha de Crédito;Finalidade;Liquidar;Garantia;Situação;Decisão',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-';
      vr_tab_tabela(1).coluna8 := '-';
      vr_tab_tabela(1).coluna9 := '-';
      vr_tab_tabela(1).coluna10 := '-';
      vr_tab_tabela(1).coluna11 := '-';
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Prestações;Quantidade de Parcelas;Linha de Crédito;Finalidade;Liquidar;Garantia;Situação;Decisão',vr_tab_tabela);
    end if;
  
    vr_string_outros_epr := vr_string_outros_epr || '</linhas>
                                            </valor>
                                            </campo>';
  
    /**/
  
   if pr_nrctrato > 0 then 
      vr_string_outros_epr := vr_string_outros_epr || '</campos></subcategoria>';
   end if;  
  
    pr_dsxmlret := vr_string_outros_epr;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_outras_pro_epr: '||sqlerrm; 
  end;

  PROCEDURE pc_consulta_consultas(pr_cdcooper   IN crapass.cdcooper%TYPE --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                                 ,pr_nrcontrato IN crawepr.nrctremp%TYPE 
                                 ,pr_inpessoa  IN crapass.inpessoa%TYPE
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                 ,pr_persona  IN VARCHAR2
                                 ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB) is

  
    /* .............................................................................
      Programa: pc_consulta_consultas
      Sistema : Aimaro/Ibratan
      Autor   : Bruno Luiz Katzjarowski - Mout's 
      Data    : Março/2019                 Ultima atualizacao: 18/06/2019
      
      Alteracoes: 03/06/2019 - Adicionado logica para apresentar data de consulta do
                               motor para produto cartoes e empretimos. Demais caem na
                               regra ja existente do orgao de protecao de credito.
                               Story 21252 - Sprint 11 - Gabriel Marcos (Mouts).
                               
                  04/06/2019 - Alterado nome Valor do Adiantamento para Valor de 
                               Adiantamento à Depositantes.
                               Bug 22214 - PRJ438 - Gabriel Marcos (Mouts).
                               
                  04/06/2019 - Alterado nome Lista de Participacao para Lista de 
                               Controle Societário.
                               Story 22208 - Sprint 11 - Gabriel Marcos (Mouts).
                               
                  13/06/2019 - Alterado cálculo do Adiantamento a Depositantes
                               para considerar os valores da Atenda
                               Story 22232 - Sprint 12 - Mateus Z (Mouts).             
                               
                  18/06/2019 - Incluído consulta do retorno do motor para as personas que 
                               estão contidas no PDF do retorno da Ibratan.
                               Story 21624 - PRJ438 - Rubens Lima           
                               
    ..............................................................................*/
  
    /* Verifica se a conta já teve prejuizo */
   CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                          pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS
      SELECT t.nrdconta
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;
  
    /*Adiantamento de depositante*/
  
     
    /* Soma valores do total de cheques devolvidos (CCF) */
   cursor cr_totalccf (pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                       pr_nrdconta tbcc_prejuizo.nrdconta%type)is
          select sum(a.vlestour) vltotalestouro from crapneg a, crapope c WHERE 
          a.cdcooper = pr_cdcooper AND
          a.cdobserv in (12,13) AND 
          a.nrdconta = pr_nrdconta  AND
          c.cdcooper = a.cdcooper AND
          c.cdoperad = a.cdoperad AND
          a.dtfimest IS NULL;
   rw_totalccf cr_totalccf%rowtype;
  
    /* Total de cheques devolvidos (CCF) */
   cursor cr_chequesdevolvidos (pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                    pr_nrdconta tbcc_prejuizo.nrdconta%type)is
          select count(1) totalrows from crapneg a, crapope c WHERE 
             a.cdcooper = pr_cdcooper AND
             a.cdobserv in (12,13)    AND 
             a.nrdconta = pr_nrdconta AND
             c.cdcooper = a.cdcooper  AND
             c.cdoperad = a.cdoperad  AND
             a.dtfimest IS NULL; -- Is null -> Não regularizado
   rw_chequesdevolvidos cr_chequesdevolvidos%rowtype;
  
    -- Quantidade de cheques devolvidos Linhas: 11 12 13 (Aimaro --> Atenda --> Ocorrencias, tab principal -> Campo "Devolvuções"
   cursor cr_chequesDevolvidos111213 is
          select count(a.nrdconta) chequesDevolvidos from crapneg a WHERE 
                           a.cdcooper = pr_cdcooper  AND
                           a.nrdconta = pr_nrdconta  AND
                           a.cdhisest = 1            AND
                           a.cdobserv IN (11,12,13)
                           group by a.nrdconta;
   rw_chequesDevolvidos111213 cr_chequesDevolvidos111213%rowtype;  
  
    /* Ultima data de cheque devolvido linhas 12 e 13 (CCF) */
   cursor cr_dtultimadevolu (pr_cdcooper tbcc_prejuizo.cdcooper%type, pr_nrdconta tbcc_prejuizo.nrdconta%type)is
        select to_char(max(a.dtiniest),'dd/mm/rrrr') dtultimadevolu 
          from crapneg a, crapope c
         WHERE a.cdcooper = pr_cdcooper
           AND a.cdobserv in (12,13)
           AND a.nrdconta = pr_nrdconta
           AND c.cdcooper = a.cdcooper
           AND c.cdoperad = a.cdoperad;
   rw_dtultimadevolu cr_dtultimadevolu%rowtype;
  
    -- Recuperar todos os estouros dos ultimos 6 meses
    cursor cr_estouros6Meses is
      select *
        from crapneg a
       where a.cdcooper = pr_cdcooper
         and a.dtiniest >=
             (select trunc(add_months(c.dtmvtolt, -5), 'MM') dtOld from crapdat c where c.cdcooper = a.cdcooper)
         and a.nrdconta = pr_nrdconta
         and a.cdhisest = 5; -- estouro
  
    -- Dias estourados
    cursor c_dias_estouros is
      select s.qtddtdev, s.dtdsdclq, s.qtdriclq
        from crapsld s
       where s.cdcooper = pr_cdcooper
         and s.nrdconta = pr_nrdconta;
    r_dias_estouros c_dias_estouros%rowtype;
  
    /*Escore BVS*/
    cursor c_crapesc(pr_nrconbir in number
                     ,pr_inpessoa crapass.inpessoa%TYPE) is
    select dsescore,
           vlpontua,
           dsclassi
      from crapesc
     where nrconbir = pr_nrconbir
       and dsescore = decode(pr_inpessoa, 1, 'SCORE PF 12M SEGM', 'SCORE CRED PJ 12');
    r_crapesc c_crapesc%rowtype;  
    --
  
    /*Escore quando não Proponente*/
    CURSOR c_busca_escore_local (pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_nrconbir crapcbd.nrconbir%TYPE
                                ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE
                                ,pr_nrseqdet crapcbd.nrseqdet%TYPE) IS
      SELECT e.vlpontua
      from crapesc e
          ,crapcbd c
          ,crapass a
      where  e.nrconbir = c.nrconbir
      and    e.nrseqdet = c.nrseqdet
      and    a.cdcooper  = pr_cdcooper
      and    a.nrcpfcgc = c.nrcpfcgc
      and    c.nrconbir = pr_nrconbir
      and    c.nrseqdet = pr_nrseqdet
      and    c.nrcpfcgc = pr_nrcpfcgc;
    r_busca_escore_local c_busca_escore_local%ROWTYPE;
  
    
    CURSOR cr_craprad(pr_cdcooper IN craprad.cdcooper%TYPE,
                      pr_nrtopico IN craprad.nrtopico%TYPE,
                      pr_nritetop IN craprad.nritetop%TYPE,
                      pr_nrseqite IN craprad.nrseqite%TYPE) IS
      SELECT r.dsseqite
        FROM craprad r
       WHERE r.cdcooper = pr_cdcooper
         AND r.nrtopico = pr_nrtopico
         AND r.nritetop = pr_nritetop
         AND r.nrseqite = pr_nrseqite
         ;
  
    /*Busca Score Comportamental dos Últimos 6 Meses*/
    CURSOR cr_tbcrd_score(pr_cdcooper      crapcop.cdcooper%TYPE
                         ,pr_inpessoa      crapass.inpessoa%TYPE
                         ,pr_nrdconta      crapass.nrdconta%TYPE) IS
      SELECT sco.cdmodelo
            ,csc.dsmodelo
            ,to_char(sco.dtbase,'dd/mm/rrrr') dtbase
            ,sco.nrscore_alinhado
            ,nvl(sco.dsclasse_score,'-') dsclasse_score
            ,nvl(sco.dsexclusao_principal,'-') dsexclusao_principal
            ,decode(sco.flvigente,1,'Vigente','Não vigente') dsvigente
            ,row_number() over (partition By sco.cdmodelo
                                    order by sco.flvigente DESC, sco.dtbase DESC) nrseqreg
        FROM tbcrd_score sco
            ,tbcrd_carga_score csc
            ,crapass ass
       WHERE csc.cdmodelo = sco.cdmodelo
         AND csc.dtbase = sco.dtbase
         AND ass.cdcooper = sco.cdcooper
         AND ass.nrcpfcnpj_base = sco.nrcpfcnpjbase
         AND sco.cdcooper = pr_cdcooper
         AND sco.tppessoa = pr_inpessoa
         AND ass.nrdconta = pr_nrdconta
         AND sco.dtbase >= TRUNC(add_months(rw_crapdat.dtmvtolt, -6), 'MM')
       ORDER BY sco.flvigente DESC
               ,sco.dtbase DESC;                         
  
    rw_score cr_tbcrd_score%ROWTYPE;
  
    /*Busca data da consulta do birô*/
    CURSOR c_busca_data_cons_biro(pr_nrconbir IN craprsc.nrconbir%TYPE, pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
      SELECT MAX(c.dtconbir) dtconbir
        FROM crapcbd c
       WHERE c.nrconbir = pr_nrconbir
         AND c.nrseqdet = pr_nrseqdet;
    vr_dt_cons_biro DATE;
  
    /*Busca data da consulta no birô e se tem crítica para persona diferente de Proponente*/
    CURSOR c_busca_restri (pr_nrconbir IN craprsc.nrconbir%TYPE
                              ,pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
      SELECT NVL(c.dtreapro, c.dtconbir) dtconbir
                 , p.qtnegati qtnegati
        FROM crapcbd c
             --          ,craprsc r
            ,craprpf p
       WHERE 1 = 1
            --AND c.nrconbir = r.nrconbir
            --AND   c.nrseqdet = r.nrseqdet 
         AND c.nrconbir = p.nrconbir
         AND c.nrseqdet = p.nrseqdet
         AND c.nrconbir = pr_nrconbir
         AND c.nrseqdet = pr_nrseqdet
         AND p.vlnegati > 0
       ORDER BY 1 DESC;
    r_busca_restri c_busca_restri%ROWTYPE;
  
    /* Lista de participação Aimaro */
   CURSOR c_busca_participacao_aimaro (pr_cdcooper crapass.cdcooper%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE) IS
      select pig.nrctasoc,
             case when pig.nrctasoc > 0 then a.nmprimtl else pig.nmprimtl end nome,
             case when pig.nrctasoc > 0 then gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,2) else gene0002.fn_mask_cpf_cnpj(pig.nrdocsoc,2) end cpfcgc,
             to_char(pig.persocio,'990D99') persocio
        from crapepa pig,
             crapass a
       where pig.cdcooper = pr_cdcooper 
         and pig.nrdconta = pr_nrdconta
         and pig.nrctasoc = a.nrdconta(+)
         and pig.cdcooper = a.cdcooper(+);            

    r_busca_participacao_aimaro c_busca_participacao_aimaro%ROWTYPE;
    
   CURSOR c_busca_participacao_motor (pr_nrconbir crapcbd.nrconbir%TYPE) IS
      SELECT distinct c.nrcpfcgc --Documento
                   ,c.nmtitcon --Nome / Razão Social
                     ,c.dtentsoc --Data de Início
                     ,to_char(c.percapvt, '990D99') percapvt --Percentual do Capital Votante
                     ,to_char(c.pertotal, '990D99') pertotal --Percentual de Participação
     FROM crapcbd c
        WHERE c.nrconbir = pr_nrconbir --Birô consultado
          AND c.intippes in (4,5);
    r_busca_participacao_motor c_busca_participacao_motor%ROWTYPE;    
  
    /*Lista de anotações negativas - Órgão de Proteção ao Crédito*/
    CURSOR c_busca_orgao_prot_cred(pr_nrconbir craprpf.nrconbir%TYPE
                                   , pr_nrseqdet craprpf.nrseqdet%TYPE) IS
    SELECT 
           dsnegati,
           decode(qtnegati,NULL,'Nada Consta',qtnegati) qtnegati,
           vlnegati,
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
                   'SERASA' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 8
              UNION ALL
            SELECT 7,
                   'SPC' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 9
              UNION ALL
            SELECT 10,
                   'Dívida Vencida' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 10
              UNION ALL
            SELECT 11,
                   'Inadimplência' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 11)
            Order by to_number(1) desc;
  
    /*Pefin(1), Refin(2), Dívida Vencida no SPC e Serasa (3)*/
  CURSOR c_busca_pefin_refin (pr_nrconbir crapprf.nrconbir%TYPE
                             ,pr_nrseqdet crapprf.nrseqdet%TYPE
                             ,pr_inpefref NUMBER) IS
    SELECT to_char(s.dtvencto,'DD/MM/YYYY') data
          ,r.dsmtvreg modalidade
          ,to_char(r.vlregist,'999g999g990d00') valor
          ,r.dsinstit origem  
        FROM crapprf r
            ,craprsc s
       WHERE r.nrconbir = s.nrconbir
       AND   r.nrseqdet = s.nrseqdet
       AND   r.vlregist = s.vlregist
       AND   r.nrconbir = pr_nrconbir
       AND   r.nrseqdet = pr_nrseqdet
       AND NVL(inpefref, 0) = NVL(pr_inpefref, 0) --Pefin 1, Refin 2, 3 Divida Vencida, 0 Pefin e Refin PJ       
       ORDER BY r.dtvencto DESC;

    r_busca_pefin_refin c_busca_pefin_refin%ROWTYPE;
  
   
    /*Consulta Protestos*/
  CURSOR c_busca_protestos (pr_nrconbir crapprf.nrconbir%TYPE
                           ,pr_nrseqdet crapprf.nrseqdet%TYPE) IS
   SELECT to_char(dtprotes,'DD/MM/YYYY') data
         ,to_char(vlprotes,'999g999g999g990d00') valor
         ,nmcidade cidade
         ,cdufende uf
        FROM CRAPPRT
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet;
    r_busca_protestos c_busca_protestos%ROWTYPE;
  
    /*Consulta Ações*/
  CURSOR c_busca_acoes (pr_nrconbir crapprf.nrconbir%TYPE
                       ,pr_nrseqdet crapprf.nrseqdet%TYPE) IS
   SELECT to_char(dtacajud,'DD/MM/YYYY') data
         ,dsnataca natureza
         ,to_char(vltotaca,'999g999g999g990d00') valor
         ,nrdistri distrito
         ,nrvaraca vara
         ,nmcidade cidade
         ,cdufende uf
        FROM CRAPABR
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet;
    r_busca_acoes c_busca_acoes%ROWTYPE;
  
    /*Consulta Recuperações, Falências, Concordata*/
  CURSOR c_busca_craprpf (pr_nrconbir crapprf.nrconbir%TYPE
                         ,pr_nrseqdet crapprf.nrseqdet%TYPE) IS
    SELECT dtultneg data
          ,vlnegati valor
        FROM craprpf
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet
         AND innegati = 5;
    r_busca_craprpf c_busca_craprpf%ROWTYPE;
  
    -- Select retorno motor (Rubens)
  cursor cr_dtconsulta (prc_cdcooper in tbgen_webservice_aciona.cdcooper%type
                       ,prc_nrdconta in tbgen_webservice_aciona.nrdconta%type
                       ,prc_nrctrprp in tbgen_webservice_aciona.nrctrprp%type) is 
      SELECT e.dhacionamento
        FROM tbgen_webservice_aciona e
       WHERE e.cdcooper = prc_cdcooper
         AND e.nrdconta = prc_nrdconta
         AND e.nrctrprp = prc_nrctrprp
         AND e.cdoperad = 'MOTOR'
         AND e.tpacionamento = 2 -- retorno
         AND e.dsoperacao NOT LIKE '%ERRO%'
         AND e.dsoperacao NOT LIKE '%DESCONHECIDA%';
  rw_dtconsulta cr_dtconsulta%rowtype;
  
    /*Busca data da consulta do SCORE (BOA VISTA)*/
  CURSOR c_busca_data_score (pr_cdcooper crapass.cdcooper%TYPE,
                             pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT a.dtdscore
        FROM crapass a
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;
    
    /*Busca sequêncial quando não é o proponente e está no birô*/
    CURSOR c_consulta_outras_personas (pr_nrconbir crapcbd.nrconbir%TYPE
                                      ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
     SELECT nrseqdet
     FROM crapcbd
     WHERE nrconbir = pr_nrconbir
     AND   nrcpfcgc = pr_nrcpfcgc
     ORDER BY NMTITCON;

    /*Busca sequêncial quando não é o proponente e NÃO está no birô*/
    CURSOR c_busca_cbd_historico (pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) IS
     SELECT nrconbir, nrseqdet
     FROM crapcbd
     WHERE cdcooper = pr_cdcooper
     AND   nrcpfcgc = pr_nrcpfcgc
     AND   dtconbir >= sysdate-180
     ORDER BY nrconbir DESC, nmtitcon;
  
    vr_string_operacoes CLOB; --XML de retorno
   vr_index number;   --Index
   v_haspreju varchar2(10); -- Retorno teve preju
  
    v_rtReadJson                VARCHAR2(1000) := NULL;
    v_somaValores               NUMBER;
    v_count                     NUMBER;
    v_ehnumero                  NUMBER;
    vr_dsrestricao              VARCHAR2(30);
    vr_inicio                   NUMBER; --temp
    vr_temrestri                NUMBER := 0;
    vr_adiantamento_depositante NUMBER;
  
    --
    vr_insitcon                 BOOLEAN:=FALSE; /*Se o cônjuge está presenta na consulta do PDF*/
    
    /*Busca o score da crapass quando não for proponente*/
  FUNCTION fn_busca_score(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
      vr_retorno crapass.dsdscore%TYPE;
    BEGIN
      SELECT dsdscore
        INTO vr_retorno
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    
    return vr_retorno;
    EXCEPTION
      WHEN OTHERS THEN
    return '-';
    END;
  
  BEGIN
    /*Buscar sequência do birô*/
    pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => vr_nrdconta_principal,
                           pr_nrconbir => vr_nrconbir,
                           pr_nrseqdet => vr_nrseqdet);
  
    /*Informações Cadastrais*/
    vr_string_operacoes := '<subcategoria>' || '<tituloTela>Informações Cadastrais</tituloTela>' || -- Titulo da subcategoira
                           '<tituloFiltro>informacoes_cadastrais</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria  
  
    /* Quando o Proponente tiver Empréstimo ou Desc. Título */
  IF (pr_persona = 'Proponente') AND vr_tpproduto_principal in (c_emprestimo,c_limite_desc_titulo) then
    
      /*CONSULTA JSON --> Para empréstimo ou desconto de título busca expressão no motor*/
      v_rtReadJson := fn_le_json_motor_regex(p_cdcooper => pr_cdcooper, p_nrdconta => pr_nrdconta,
                                             p_nrdcontrato => pr_nrcontrato,
                                             p_tagFind => '(proponente).+(possui).+(restri)', --Palavras com ã|õ substituir por ? o caracter
                                             p_hasDoisPontos => false,
                                             p_idCampo => 0);
    
      -- Busca data de consulta (motor) para ver se tem restrição
      open cr_dtconsulta (pr_cdcooper
                         ,pr_nrdconta
                         ,pr_nrcontrato);
      fetch cr_dtconsulta into rw_dtconsulta;
      close cr_dtconsulta;
    
      --Sem Restrição
      IF nvl(v_rtReadJson, '-') = '-' THEN
        vr_string_operacoes := vr_string_operacoes||
                               fn_tag('Situação','Sem Restrição.'||' Consulta em: '|| -- Retirado Boa Vista
                               --fn_tag('Situação','Sem Restrição.'||' Consulta Boa Vista em: '|| -- Retirado Boa Vista
                               case when rw_dtconsulta.dhacionamento is not null 
                                    then to_char(rw_dtconsulta.dhacionamento,'DD/MM/YYYY')
                                    else 'SEM CONSULTA' end);
      ELSE
        --Com Restrição
        vr_temrestri        := 1;
        vr_string_operacoes := vr_string_operacoes || fn_tag('Situação',
                                                             --'Com Restrição.'||' Consulta Boa Vista em: '|| case
                                                             'Com Restrição.'||' Consulta em: '|| case
                                                               when rw_dtconsulta.dhacionamento is not null then
                                    to_char(rw_dtconsulta.dhacionamento, 'DD/MM/YYYY')
                                    else 'SEM CONSULTA'end);


      END if;
    
      /* OUTRAS PERSONAS, QUANDO não estiver no retorno do birô (CRAPRPF) busca consultando o histórico */
    ELSE

      /*Verifica se a persona foi consultada e contém dados na CRAPRPF*/
      OPEN c_consulta_outras_personas (pr_nrconbir => vr_nrconbir
                                      ,pr_nrcpfcgc => pr_nrcpfcgc);
       FETCH c_consulta_outras_personas INTO vr_nrseqdet;
       IF c_consulta_outras_personas%NOTFOUND THEN
         vr_nrseqdet := NULL; 
         vr_insitcon := FALSE; /*Persona não estava na consulta*/
       ELSE
         vr_insitcon := TRUE;
       END IF;
      CLOSE c_consulta_outras_personas;
      
      /*Se a persona não estava na consulta pelo proponente, busca sua última consulta individual no CONSCR*/
      IF (vr_insitcon = FALSE) THEN
        OPEN c_busca_cbd_historico (pr_nrcpfcgc => pr_nrcpfcgc);
         FETCH c_busca_cbd_historico INTO vr_nrconbir, vr_nrseqdet ;
        CLOSE c_busca_cbd_historico;
      END IF;
      
      /*Verifica quando foi a última consulta na CONSCR*/
       OPEN c_busca_data_cons_biro (pr_nrconbir => vr_nrconbir
                               ,pr_nrseqdet => vr_nrseqdet);
        FETCH c_busca_data_cons_biro INTO vr_dt_cons_biro;
      CLOSE c_busca_data_cons_biro;
    
       OPEN c_busca_restri (pr_nrconbir => vr_nrconbir
                           ,pr_nrseqdet => vr_nrseqdet);
    
        FETCH c_busca_restri INTO r_busca_restri;
    
      IF c_busca_restri%FOUND THEN
      
        IF (r_busca_restri.qtnegati > 0) THEN
          vr_temrestri   := 1; --tem restrição
          vr_dsrestricao := 'Com Restrição.';
        ELSE
          vr_dsrestricao := 'Sem Restrição.';
        END IF;
      
          vr_string_operacoes := vr_string_operacoes||
                                fn_tag('Situação',vr_dsrestricao||' Consulta em: '||
                              --fn_tag('Situação',vr_dsrestricao||' Consulta Boa Vista em: '||
                              case when vr_dt_cons_biro is not null 
                                then to_char(vr_dt_cons_biro,'DD/MM/YYYY')
                              else 'SEM CONSULTA' end);  
      ELSE
      
        IF (vr_dt_cons_biro IS NULL) THEN
            OPEN c_busca_data_score (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta);
            FETCH c_busca_data_score INTO vr_dt_cons_biro;
          CLOSE c_busca_data_score;
        END IF;
      
          vr_string_operacoes := vr_string_operacoes||
                              fn_tag('Situação','Sem Restrição'||' Consulta em: '||
                              --fn_tag('Situação',vr_dsrestricao||' Consulta Boa Vista em: '||
                              case when vr_dt_cons_biro is not null --data consulta boa vista
                                then to_char(vr_dt_cons_biro,'DD/MM/YYYY')
                              else 'SEM CONSULTA' end);  
      END IF;
    
      CLOSE c_busca_restri;
    
    END IF;
  
    --Se tem restrição, monta a tabela do resumo
    if (vr_temrestri = 1 ) then
    
      /*RESUMO ANOTAÇÕES NEGATIVAS - Consulta ao Órgãos de Proteção ao Crédito*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>Resumo Anotações Negativas</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      /*PJ tem: Pefin, Protesto, Refin, Ações, Recuperações, Dívida Vencida
      PF tem: SPC, Pefin, Protesto, Refin, Ações, Dívida Vencida */
    
      vr_index := 1;
      vr_tab_tabela.delete;
      FOR r_craprpf IN c_busca_orgao_prot_cred(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet) LOOP
      
        IF (pr_inpessoa = 2 AND r_craprpf.dsnegati IN ('SPC', 'SERASA')) THEN
          CONTINUE;
        END IF;
      
        IF (pr_inpessoa = 1) AND r_craprpf.dsnegati IN ('Participação falência', 'SERASA') THEN
          CONTINUE;
        END IF;
      
        vr_tab_tabela(vr_index).coluna1 := r_craprpf.dsnegati; --Anotações
        vr_tab_tabela(vr_index).coluna2 := r_craprpf.qtnegati; --Quantidade
        vr_tab_tabela(vr_index).coluna3 := case when r_craprpf.vlnegati IS NOT NULL
                                           then to_char(r_craprpf.vlnegati,'999g999g990d00') else '-' end; --Valor
        vr_tab_tabela(vr_index).coluna4 := case when r_craprpf.dtultneg IS NOT NULL
                                           then to_char(r_craprpf.dtultneg,'DD/MM/YYYY') else '-' end; --Data Última
        vr_index := vr_index + 1;
       end loop;
    
    if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Anotações;Quantidade;Valor;Data Última',vr_tab_tabela);
    else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Anotações;Quantidade;Valor;Data Última',vr_tab_tabela);
    end if;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*Registro SPC - Somente para PF*/
      IF (pr_inpessoa = 1) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>Registro SPC</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
        vr_index            := 1;
        vr_tab_tabela.delete;
     for r_craprsc in c_craprsc(vr_nrconbir,vr_nrseqdet) loop
          vr_tab_tabela(vr_index).coluna1 := r_craprsc.inlocnac;
          vr_tab_tabela(vr_index).coluna2 := r_craprsc.dsinstit;
          vr_tab_tabela(vr_index).coluna3 := CASE WHEN r_craprsc.nmcidade IS NOT NULL THEN r_craprsc.nmcidade ELSE '-' END;
          vr_tab_tabela(vr_index).coluna4 := CASE WHEN r_craprsc.cdufende IS NOT NULL THEN r_craprsc.cdufende ELSE '-' END;
          vr_tab_tabela(vr_index).coluna5 := to_char(r_craprsc.dtregist, 'DD/MM/YYYY');
          vr_tab_tabela(vr_index).coluna6 := to_char(r_craprsc.dtvencto, 'DD/MM/YYYY');
          vr_tab_tabela(vr_index).coluna7 := to_char(NVL(r_craprsc.vlregist,0), '999g999g999g990d00');
          vr_tab_tabela(vr_index).coluna8 := r_craprsc.dsmtvreg;
          vr_index := vr_index + 1;
     end loop;
      
    if vr_tab_tabela.COUNT > 0 then
          /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Tipo;Instituição;Cidade;UF;Registro;Vencimento;Valor;Motivo',vr_tab_tabela);
    else
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Tipo;Instituição;Cidade;UF;Registro;Vencimento;Valor;Motivo',vr_tab_tabela);
    end if;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      END IF;
    
      /*PEFIN - DETALHE*/
    
      /*OBS: PJ tem Pefin e Refin separados. 
      PF tem os dois juntos e o valor de INPEFREF é null*/
      IF (pr_inpessoa = 1) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>PEFIN e REFIN- (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      ELSE
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>PEFIN - (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      
      END IF;
      vr_index := 0;
      vr_tab_tabela.delete;
    
      /*PF*/
      IF (pr_inpessoa = 1) THEN
     OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                             ,pr_nrseqdet => vr_nrseqdet
                             ,pr_inpefref => NULL); -- PEFIN PF
      
      ELSE
        /*PJ*/
     OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                             ,pr_nrseqdet => vr_nrseqdet
                             ,pr_inpefref => 1); -- PEFIN PJ
      END IF;
    
      LOOP
      FETCH c_busca_pefin_refin INTO r_busca_pefin_refin;
        EXIT WHEN vr_index = 5;
        IF c_busca_pefin_refin%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.modalidade;
          vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.valor;
          vr_tab_tabela(vr_index).coluna4 := r_busca_pefin_refin.origem;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_pefin_refin;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Modalidade;Valor;Origem', vr_tab_tabela);
      ELSE
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                </valor>
                                                </campo>';
    
      /*PROTESTOS*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>PROTESTO - (Ocorrências mais recentes - até cinco)</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
  OPEN c_busca_protestos(pr_nrconbir => vr_nrconbir
                         ,pr_nrseqdet => vr_nrseqdet);
      LOOP
    FETCH c_busca_protestos INTO r_busca_protestos;
        EXIT WHEN vr_index = 5;
        IF c_busca_protestos%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_protestos.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_protestos.valor;
          vr_tab_tabela(vr_index).coluna3 := r_busca_protestos.cidade;
          vr_tab_tabela(vr_index).coluna4 := r_busca_protestos.uf;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_protestos;
    
      /*Monta o XML de protestos*/
    if vr_tab_tabela.COUNT > 0 then
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor;Cidade;UF', vr_tab_tabela);
    else
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
    end if;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*REFIN - DETALHE - Apenas para o PJ. PF já carregou junto com o PEFIN*/
      IF (pr_inpessoa = 2) THEN
        vr_index := 0;
        vr_tab_tabela.delete;
      
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>REFIN - (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
        vr_index            := 0;
        vr_tab_tabela.delete;
      
       OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                               ,pr_nrseqdet => vr_nrseqdet
                               ,pr_inpefref => 2); -- REFIN
        LOOP
        FETCH c_busca_pefin_refin INTO r_busca_pefin_refin;
        
          EXIT WHEN VR_INDEX > 5;
          IF c_busca_pefin_refin%FOUND THEN
            vr_index := vr_index + 1;
            vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
            vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.modalidade;
            vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.valor;
            vr_tab_tabela(vr_index).coluna4 := r_busca_pefin_refin.origem;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      
        CLOSE c_busca_pefin_refin;
      
      if vr_tab_tabela.COUNT > 0 then
          /*Gera Tags Xml*/
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Modalidade;Valor;Origem', vr_tab_tabela);
      else
          --vr_tab_tabela(1).coluna1 := '-';
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      end if;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                    </valor>
                                                    </campo>';
      END IF;
    
      /*AÇÕES - Para PF e PJ*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>AÇÕES - (Ocorrências mais recentes - até cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
     OPEN c_busca_acoes(pr_nrconbir => vr_nrconbir
                       ,pr_nrseqdet => vr_nrseqdet);
      LOOP
        FETCH c_busca_acoes INTO r_busca_acoes;
        EXIT WHEN vr_index = 5;
        IF c_busca_acoes%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_acoes.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_acoes.natureza;
          vr_tab_tabela(vr_index).coluna3 := r_busca_acoes.valor;
          vr_tab_tabela(vr_index).coluna4 := r_busca_acoes.distrito;
          vr_tab_tabela(vr_index).coluna5 := r_busca_acoes.vara;
          vr_tab_tabela(vr_index).coluna6 := r_busca_acoes.cidade;
          vr_tab_tabela(vr_index).coluna7 := r_busca_acoes.uf;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_acoes;
    
    if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Natureza;Valor;Distrito;Vara;Cidade;UF',vr_tab_tabela);
    else
        --vr_tab_tabela(1).coluna1 := 'NADA CONSTA';
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
    end if;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*DIVIDA VENCIDA - DETALHE*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                 <nome>DÍVIDA VENCIDA - (Ocorrências mais recentes - até cinco)</nome>
                                                 <tipo>table</tipo>
                                                 <valor>
                                                 <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
    OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                            ,pr_nrseqdet => vr_nrseqdet
                            ,pr_inpefref => 3); -- DIVIDA VENCIDA
      LOOP
       FETCH c_busca_pefin_refin INTO r_busca_pefin_refin;
        EXIT WHEN vr_index = 5;
        IF c_busca_pefin_refin%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.valor;
          vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.origem;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_pefin_refin;
    
    if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor;Origem', vr_tab_tabela);
    else
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
    end if;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*RECUPERAÇÕES, FALÊNCIA E CONCORDATA - apenas para PJ*/
      IF (pr_inpessoa = 2) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>RECUPERAÇÕES, FALÊNCIA E CONCORDATA - (Ocorrências mais recentes - até cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
        vr_index            := 0;
        vr_tab_tabela.delete;
      
     OPEN c_busca_craprpf(pr_nrconbir => vr_nrconbir
                         ,pr_nrseqdet => vr_nrseqdet);
        LOOP
        FETCH c_busca_craprpf INTO r_busca_craprpf;
          EXIT WHEN vr_index = 5;
          IF c_busca_craprpf%FOUND THEN
            vr_index := vr_index + 1;
            vr_tab_tabela(vr_index).coluna1 := r_busca_craprpf.data;
            vr_tab_tabela(vr_index).coluna2 := r_busca_craprpf.valor;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      
        CLOSE c_busca_craprpf;
      
      if vr_tab_tabela.COUNT > 0 then
          /*Gera Tags Xml*/
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor', vr_tab_tabela);
      else
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      end if;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      END IF;
    
      END IF; --Fim da tabela do Resumo de Anotações  -- BUG 23430 -- Paulo
      /*BUSCA_JSON -> Patrimônio Pessoal Livre e Percepção Geral Empresa somente para Proponente*/
      IF (pr_persona = 'Proponente') THEN
      
        --Patrimônio Pessoal Livre
        v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                         p_nrdconta => pr_nrdconta,
                                         p_nrdcontrato => pr_nrcontrato,
                                         p_tagFind => 'patrimonioPessoalLivre',
                                         p_hasDoisPontos => true,
                                         p_idCampo => 0);
      
        v_ehnumero := NULL;
        BEGIN
          v_ehnumero := to_number(v_rtReadJson);
        EXCEPTION
          WHEN OTHERS THEN
            v_ehnumero          := NULL;
            vr_string_operacoes := vr_string_operacoes ||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                      v_rtReadJson);
        END;
        IF v_ehnumero IS NOT NULL THEN
          -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
      FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                    3,
                                    9,
                                    v_ehnumero) LOOP                                            
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                                                               v_rtReadJson || ' - ' || rw_craprad.dsseqite);
          END LOOP;
        END IF;
      
    IF r_pessoa.inpessoa IN (2,3) THEN -- Jurídica
          --Percepcao geral da empresa
          v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                           p_nrdconta => pr_nrdconta,
                                           p_nrdcontrato => pr_nrcontrato,
                                           p_tagFind => 'percepcaoGeralEmpresa', --Palavras com ã|õ substituir por ? o caracter
                                           p_hasDoisPontos => true,
                                           p_idCampo => 0);
          v_ehnumero   := NULL;
          BEGIN
            v_ehnumero := to_number(v_rtReadJson);
          EXCEPTION
            WHEN OTHERS THEN
              v_ehnumero          := NULL;
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Percepção Geral da Empresa',
                    v_rtReadJson);
          END;
          IF v_ehnumero IS NOT NULL THEN
            -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
        FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                      3,
                                      11,
                                      v_ehnumero) LOOP
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Percepção Geral da Empresa',
                                                                 v_rtReadJson || ' - ' || rw_craprad.dsseqite);
            END LOOP;
          END IF;
        
        END IF;
      END IF;
    
      /*Fim da Subcategoria de RESUMO DE ANOTAÇÕES NEGATIVAS*/
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*Ocorrências*/
  vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                           '<tituloTela>Ocorrências</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>ocorrencias</tituloFiltro>' || -- ID da subcategoria
                           '<campos>';
  
    -- Buscar dados da atenda 
    pc_busca_dados_atenda(pr_cdcooper => vr_cdcooper_principal,
                          -- bug 19891 
                          --pr_nrdconta => vr_nrdconta_principal);            
                          pr_nrdconta => pr_nrdconta);
    --                               
    vr_adiantamento_depositante := abs(vr_tab_valores_conta(1).vlstotal) - abs(vr_tab_valores_conta(1).vllimite);
  
    --Montar Valores Somente com conta estourada
    IF vr_adiantamento_depositante > 0 AND vr_tab_valores_conta(1).vlstotal < 0 THEN
      vr_string_operacoes := vr_string_operacoes ||
                             fn_tag('Valor de Adiantamento à Depositantes',
                                    TO_CHAR(vr_adiantamento_depositante, 'fm9g999g999g999g999g990d00',
                                             'NLS_NUMERIC_CHARACTERS='',.'''));
    ELSE
      vr_string_operacoes := vr_string_operacoes ||
                             tela_analise_credito.fn_tag('Valor de Adiantamento à Depositantes', '-');
    END IF;
    --CL:
  open c_dias_estouros;
   fetch c_dias_estouros into r_dias_estouros;  
    -- Crédito Líquido/(dd) - BUG 20967
    vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('CL',nvl(r_dias_estouros.qtdriclq, 0)|| ' (dd) ' ||nvl(to_char(r_dias_estouros.dtdsdclq, 'dd/mm/rrrr'), '-'));



    --Quantidade de Estouros:
  
    vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Estouros',nvl(r_dias_estouros.qtddtdev,0));

    close c_dias_estouros;
  
    --Mostrar a Média de Estouros dos Últimos 6 meses
    v_somaValores := 0;
    v_count       := 0;
   FOR item IN cr_estouros6Meses
   LOOP
      v_somaValores := v_somaValores + item.Vlestour;
      v_count       := v_count + 1;
    END LOOP;
  
   if v_count > 0 then
      v_somaValores := v_somaValores / v_count;
   else 
      v_somaValores := 0;
   end if;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Média de Estouros dos Últimos 6 meses',
                                                       to_char(TRUNC(v_somaValores, 2)));
    --A conta já causou prejuízo na cooperativa:
   open cr_prejuizo(pr_cdcooper,pr_nrdconta);
   fetch cr_prejuizo into rw_prejuizo;
   if cr_prejuizo%found then
      v_haspreju := 'Sim';
   else
      v_haspreju := 'Não';
   end if;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('A conta já causou prejuizo na cooperativa',v_haspreju);                                         
   close cr_prejuizo;
  
    --Quantidade de Cheques Devolvidos:
   open cr_chequesDevolvidos111213;
   fetch cr_chequesDevolvidos111213 into rw_chequesDevolvidos111213;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Cheques Devolvidos',
                                                       rw_chequesDevolvidos111213.Chequesdevolvidos);
   close cr_chequesDevolvidos111213;  
  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*CCF Interno*/
    vr_string_operacoes := vr_string_operacoes || '<subcategoria>' ||
                           '<tituloTela>Consulta do CCF Interna</tituloTela>' || -- Titulo da subcategoira
                           '<tituloFiltro>consulta_ccfi</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria
    --Quantidade de Cheques a Regularizar no CCF:
   open cr_chequesdevolvidos(pr_cdcooper, pr_nrdconta);
   fetch cr_chequesdevolvidos into rw_chequesdevolvidos;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Cheques a Regularizar no CCF',rw_chequesdevolvidos.totalrows);
   close cr_chequesdevolvidos;
  
    --Valor Total a Regularizar no CCF 
   open cr_totalccf(pr_cdcooper, pr_nrdconta);
   fetch cr_totalccf into rw_totalccf;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Valor total a Regularizar no CCF',TO_CHAR(rw_totalccf.vltotalestouro,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
   close cr_totalccf;
    --Data da Última Devolução: 
   open cr_dtultimadevolu(pr_cdcooper, pr_nrdconta);
   fetch cr_dtultimadevolu into rw_dtultimadevolu;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Data da Última Devolução',rw_dtultimadevolu.dtultimadevolu);
   close cr_dtultimadevolu;
  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*CCF Externa*/
    vr_string_operacoes := vr_string_operacoes || '<subcategoria>' ||
                           '<tituloTela>Consulta do CCF Externa</tituloTela>' || -- Titulo da subcategoira
                           '<tituloFiltro>consulta_ccfe</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria  
    --Banco:
    --Quantidade de Cheques:  
    vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>CCF Externa</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
    vr_index            := 1;
    vr_tab_tabela.delete;
   for r_crapcsf in c_crapcsf(vr_nrconbir,vr_nrseqdet) loop
      vr_tab_tabela(vr_index).coluna1 := r_crapcsf.nmbanchq;
      --vr_tab_tabela(vr_index).coluna2 := r_crapcsf.vlcheque;
      vr_tab_tabela(vr_index).coluna2 := r_crapcsf.qtcheque;
      vr_index := vr_index + 1;
   end loop;
  
    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes || fn_tag_table('Banco;Quantidade de Cheques', vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_string_operacoes := vr_string_operacoes || fn_tag_table('Banco;Quantidade de Cheques', vr_tab_tabela);
    end if;
  
    vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*Score de Mercado*/
    --Score:
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Score do Mercado</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>score_do_mercado</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria
  
    /*bug 21588 - Quando não for proponente, busca do Contas>Org. Proteção ao Crédito*/
   IF (pr_persona <> 'Proponente') then
     v_rtReadJson := fn_busca_score (pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta);
    ELSE
      /*Busca do JSON apenas quando não for cartão de crédito, senão também busca local*/
      IF (vr_tpproduto_principal <> c_cartao) THEN
        v_rtReadJson := fn_le_json_motor_regex(p_cdcooper => pr_cdcooper,
                                               p_nrdconta => pr_nrdconta,
                                               p_nrdcontrato => pr_nrcontrato,
                                               --p_tagFind => '(proponente).+(bvs).+(score)', --Palavras com ã|õ substituir por ? o caracter
                                               p_tagFind => 'descricaoScoreBVS', --BUG 23269    
                                               p_hasDoisPontos => false,
                                               p_idCampo => 0);
        /*Para o Score, fatia o texto iniciando após o último : de tras para frente*/
        vr_inicio    := INSTR(v_rtReadJson, ':', -1);
        v_rtReadJson := SUBSTR(v_rtReadJson, vr_inicio);
      
        /*Remove os caracteres inválidos \u00BF do JSON*/
        v_rtReadJson := REPLACE(v_rtReadJson, '\u00BF', '');
      
        /*Tratamento para o Score quando falta o caractere Í (BAIXÍSSIMO, ALTÍSSIMO)*/
       IF (v_rtReadJson like ('%ALTSSIMO%') or v_rtReadJson like '%BAIXSSIMO%') THEN
          v_rtReadJson := REPLACE(v_rtReadJson, 'SSIMO', 'ÍSSIMO');
        END IF;
      
      ELSE
        v_rtReadJson := fn_busca_score (pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta);
      END IF;
    
    END IF;
    vr_string_operacoes := vr_string_operacoes || tela_analise_credito.fn_tag('Score', v_rtReadJson);
  
    --Buscar biro de consulta
     pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrconbir => vr_nrconbir,
                           pr_nrseqdet => vr_nrseqdet);
  
    --Pontuação BVS:
   if (pr_persona = 'Proponente') then
     open c_crapesc(vr_nrconbir, pr_inpessoa);
      fetch c_crapesc into r_crapesc;
       if c_crapesc%found then
        vr_string_operacoes := vr_string_operacoes ||
                               tela_analise_credito.fn_tag('Pontuação', to_char(r_crapesc.vlpontua, '999g999g990d0'));
       else
        vr_string_operacoes := vr_string_operacoes || tela_analise_credito.fn_tag('Pontuação', '-');
       end if;
     close c_crapesc;
      --Pontuação Serasa para demais
   else
     open c_busca_escore_local (pr_cdcooper => pr_cdcooper
                               ,pr_nrconbir => vr_nrconbir
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_nrseqdet => vr_nrseqdet);
      FETCH c_busca_escore_local INTO r_busca_escore_local;
    
      if c_busca_escore_local%FOUND THEN
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Pontuação',r_busca_escore_local.vlpontua);
      ELSE
        vr_string_operacoes := vr_string_operacoes || tela_analise_credito.fn_tag('Pontuação', '-');
      END IF;
    
     close c_busca_escore_local;  
   end if;
  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*--Riscos
    vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                             '<tituloTela>Riscos</tituloTela>'|| -- Titulo da subcategoira
                             '<tituloFiltro>riscos</tituloFiltro>'|| -- ID da subcategoria
                             '<campos>'; -- Abertura da tag de campos da subcategoria
    --Risco Final
    open c_risco_final(pr_cdcooper,pr_nrdconta,rw_crapdat.dtmvtoan);
     fetch c_risco_final into r_risco_final;
       vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Risco Final',nvl(r_risco_final.risco_final,'-'));
    close c_risco_final;
    
    --Nível de Risco - APENAS PARA O PROPONENTE
    if (pr_persona = 'Proponente') then
      if vr_tpproduto_principal = c_emprestimo then
        open c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctrato_principal);
         fetch c_proposta_epr into r_proposta_epr;
           vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Nível de Risco',r_proposta_epr.dsnivris);
        close c_proposta_epr;
      end if;
    end if;
    
    vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';*/
  
    /*Score Interno*/
  
    --Score Comportamental 
  
    --Será apresentado os últimos 6 meses
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Score Comportamental</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>score_comportamental</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria
  
    vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>Score Comportamental dos Últimos 6 meses</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
    vr_index            := 1;
    vr_tab_tabela.delete;
   for rw_score in cr_tbcrd_score(pr_cdcooper,pr_inpessoa,pr_nrdconta) loop
      vr_tab_tabela(vr_index).coluna1 := rw_score.dsmodelo;
      vr_tab_tabela(vr_index).coluna2 := rw_score.dtbase;
      vr_tab_tabela(vr_index).coluna3 := rw_score.dsclasse_score;
      vr_tab_tabela(vr_index).coluna4 := rw_score.nrscore_alinhado;
      vr_tab_tabela(vr_index).coluna5 := rw_score.dsexclusao_principal;
      vr_tab_tabela(vr_index).coluna6 := rw_score.dsvigente;
      vr_index := vr_index + 1;
   end loop;
  
    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Modelo;Data;Classe;Pontuação;Exclusão Principal;Situação',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Modelo;Data;Classe;Pontuação;Exclusão Principal;Situação',vr_tab_tabela);
    end if;
  
    vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
  
    /*Lista de participação para PJ - BUG 21396*/
  IF (pr_inpessoa = 2 and (pr_persona = 'Proponente' or
                           pr_persona like '%Avalista%')) THEN
    
      --Será apresentado os últimos 6 meses
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Participação</tituloTela>'|| -- Titulo da subcategoira
                             '<tituloFiltro>participacao</tituloFiltro>' || -- ID da subcategoria
                             '<campos>'; -- Abertura da tag de campos da subcategoria
    
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>Lista de Participação Empresa - Aimaro</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
      OPEN c_busca_participacao_aimaro(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta);
      LOOP
       FETCH c_busca_participacao_aimaro INTO r_busca_participacao_aimaro;
        IF c_busca_participacao_aimaro%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_participacao_aimaro.nrctasoc;
          vr_tab_tabela(vr_index).coluna2 := r_busca_participacao_aimaro.nome;
          vr_tab_tabela(vr_index).coluna3 := r_busca_participacao_aimaro.cpfcgc;
          vr_tab_tabela(vr_index).coluna4 := trim(r_busca_participacao_aimaro.persocio ||'%');
        ELSE
          EXIT;
        END IF;
      END LOOP;

      CLOSE c_busca_participacao_aimaro;
      
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('Conta/dv;Razão Social;C.N.P.J;%Societário',vr_tab_tabela);
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('Conta/dv;Razão Social;C.N.P.J;%Societário',vr_tab_tabela);
      END IF;

      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      -- Lista com somente as informações do Motor
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>Lista de Controle Societário - Motor</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
      vr_index := 0;
      vr_tab_tabela.delete;

      OPEN c_busca_participacao_motor(pr_nrconbir => vr_nrconbir);
      LOOP
       FETCH c_busca_participacao_motor INTO r_busca_participacao_motor;
        IF c_busca_participacao_motor%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_cpf_cnpj(r_busca_participacao_motor.nrcpfcgc,CASE WHEN LENGTH(r_busca_participacao_motor.nrcpfcgc) > 11 THEN 2 ELSE 1 END);
          vr_tab_tabela(vr_index).coluna2 := r_busca_participacao_motor.nmtitcon;
          vr_tab_tabela(vr_index).coluna3 := case when r_busca_participacao_motor.dtentsoc is not null then to_char(r_busca_participacao_motor.dtentsoc,'DD/MM/YYYY') else '-' end;
          --vr_tab_tabela(vr_index).coluna4 := trim(r_busca_participacao_motor.percapvt ||'%');
          vr_tab_tabela(vr_index).coluna5 := trim(r_busca_participacao_motor.pertotal ||'%');
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_participacao_motor;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
    vr_string_operacoes := vr_string_operacoes||fn_tag_table('Documento;Nome / Razão Social;Data de Início;Percentual de Participação',vr_tab_tabela);
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
    vr_string_operacoes := vr_string_operacoes||fn_tag_table('Documento;Nome / Razão Social;Data de Início;Percentual de Participação',vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';
    END IF;
  
   
   
   
    pr_dsxmlret := vr_string_operacoes;
  exception
   when others then
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := substr('Erro pc_consulta_consultas: '||sqlerrm,1,250);
  end pc_consulta_consultas;

PROCEDURE pc_consulta_consultas_ncoop(pr_cdcooper   IN crapass.cdcooper%TYPE, --> Cooperativa
                                      pr_nrdconta   IN crapass.nrdconta%TYPE, --> Conta
                                      pr_nrcontrato IN crawepr.nrctremp%TYPE,
                                      pr_inpessoa   IN crapass.inpessoa%TYPE,
                                      pr_nrcpfcgc   IN crapass.nrcpfcgc%TYPE,
                                      pr_persona    IN VARCHAR2,
                                      pr_cdcritic   OUT PLS_INTEGER, --> Codigo da critica
                                      pr_dscritic   OUT VARCHAR2, --> Descricao da critica
                                      pr_dsxmlret   OUT CLOB) IS
  
    /* .............................................................................
      Programa: pc_consulta_consultas
      Sistema : Aimaro/Ibratan
      Autor   : Bruno Luiz Katzjarowski - Mout's 
      Data    : Março/2019                 Ultima atualizacao: 18/06/2019
      
      Alteracoes: 03/06/2019 - Adicionado logica para apresentar data de consulta do
                               motor para produto cartoes e empretimos. Demais caem na
                               regra ja existente do orgao de protecao de credito.
                               Story 21252 - Sprint 11 - Gabriel Marcos (Mouts).
                               
                  04/06/2019 - Alterado nome Valor do Adiantamento para Valor de 
                               Adiantamento à Depositantes.
                               Bug 22214 - PRJ438 - Gabriel Marcos (Mouts).
                               
                  04/06/2019 - Alterado nome Lista de Participacao para Lista de 
                               Controle Societário.
                               Story 22208 - Sprint 11 - Gabriel Marcos (Mouts).
                               
                  13/06/2019 - Alterado cálculo do Adiantamento a Depositantes
                               para considerar os valores da Atenda
                               Story 22232 - Sprint 12 - Mateus Z (Mouts).             
                               
                  18/06/2019 - Incluído consulta do retorno do motor para as personas que 
                               estão contidas no PDF do retorno da Ibratan.
                               Story 21624 - PRJ438 - Rubens Lima           
                               
    ..............................................................................*/
  
    /* Verifica se a conta já teve prejuizo */
    CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE, pr_nrdconta tbcc_prejuizo.nrdconta%TYPE) IS
      SELECT t.nrdconta
        FROM tbcc_prejuizo t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_prejuizo cr_prejuizo%ROWTYPE;
  
    /*Adiantamento de depositante*/
  
    /* Soma valores do total de cheques devolvidos (CCF) */
    CURSOR cr_totalccf(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE, pr_nrdconta tbcc_prejuizo.nrdconta%TYPE) IS
      SELECT SUM(a.vlestour) vltotalestouro
        FROM crapneg a, crapope c
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdobserv IN (11, 12, 13)
         AND a.nrdconta = pr_nrdconta
         AND c.cdcooper = a.cdcooper
         AND c.cdoperad = a.cdoperad
         AND a.dtfimest IS NULL;
    rw_totalccf cr_totalccf%ROWTYPE;
  
    /* Total de cheques devolvidos (CCF) */
    CURSOR cr_chequesdevolvidos(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE, pr_nrdconta tbcc_prejuizo.nrdconta%TYPE) IS
      SELECT COUNT(1) totalrows
        FROM crapneg a, crapope c
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdobserv IN (11, 12, 13)
         AND a.nrdconta = pr_nrdconta
         AND c.cdcooper = a.cdcooper
         AND c.cdoperad = a.cdoperad
         AND a.dtfimest IS NULL; -- Is null -> Não regularizado
    rw_chequesdevolvidos cr_chequesdevolvidos%ROWTYPE;
  
    -- Quantidade de cheques devolvidos Linhas: 11 12 13 (Aimaro --> Atenda --> Ocorrencias, tab principal -> Campo "Devolvuções"
    CURSOR cr_chequesDevolvidos111213 IS
      SELECT COUNT(a.nrdconta) chequesDevolvidos
        FROM crapneg a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrdconta = pr_nrdconta
         AND a.cdhisest = 1
         AND a.cdobserv IN (11, 12, 13)
       GROUP BY a.nrdconta;
    rw_chequesDevolvidos111213 cr_chequesDevolvidos111213%ROWTYPE;
  
    /* Ultima data de cheque devolvido linhas 11, 12 e 13 (CCF) */
    CURSOR cr_dtultimadevolu(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE, pr_nrdconta tbcc_prejuizo.nrdconta%TYPE) IS
      SELECT to_char(MAX(a.dtiniest), 'dd/mm/rrrr') dtultimadevolu
        FROM crapneg a, crapope c
       WHERE a.cdcooper = pr_cdcooper
         AND a.cdobserv IN (11, 12, 13)
         AND a.nrdconta = pr_nrdconta
         AND c.cdcooper = a.cdcooper
         AND c.cdoperad = a.cdoperad;
    rw_dtultimadevolu cr_dtultimadevolu%ROWTYPE;
  
    -- Recuperar todos os estouros dos ultimos 6 meses
    CURSOR cr_estouros6Meses IS
      SELECT *
        FROM crapneg a
       WHERE a.cdcooper = pr_cdcooper
         AND a.dtiniest >=
             (SELECT trunc(add_months(c.dtmvtolt, -5), 'MM') dtOld FROM crapdat c WHERE c.cdcooper = a.cdcooper)
         AND a.nrdconta = pr_nrdconta
         AND a.cdhisest = 5; -- estouro
  
    -- Dias estourados
    CURSOR c_dias_estouros IS
      SELECT s.qtddtdev, s.dtdsdclq, s.qtdriclq
        FROM crapsld s
       WHERE s.cdcooper = pr_cdcooper
         AND s.nrdconta = pr_nrdconta;
    r_dias_estouros c_dias_estouros%ROWTYPE;
  
    /*Escore BVS*/
    CURSOR c_crapesc(pr_nrconbir IN NUMBER, pr_inpessoa crapass.inpessoa%TYPE) IS
      SELECT dsescore, vlpontua, dsclassi
        FROM crapesc
       WHERE nrconbir = pr_nrconbir
         AND dsescore = decode(pr_inpessoa, 1, 'SCORE PF 12M SEGM', 'SCORE CRED PJ 12');
    r_crapesc c_crapesc%ROWTYPE;
    --
  
    /*Escore quando não Proponente*/
    CURSOR c_busca_escore_local(pr_cdcooper crapcop.cdcooper%TYPE,
                                pr_nrconbir crapcbd.nrconbir%TYPE,
                                pr_nrcpfcgc crapass.nrcpfcgc%TYPE,
                                pr_nrseqdet crapcbd.nrseqdet%TYPE) IS
      SELECT e.vlpontua
        FROM crapesc e, crapcbd c, crapass a
       WHERE e.nrconbir = c.nrconbir
         AND e.nrseqdet = c.nrseqdet
         AND a.cdcooper = pr_cdcooper
         AND a.nrcpfcgc = c.nrcpfcgc
         AND c.nrconbir = pr_nrconbir
         AND c.nrseqdet = pr_nrseqdet
         AND c.nrcpfcgc = pr_nrcpfcgc;
    r_busca_escore_local c_busca_escore_local%ROWTYPE;
  
    CURSOR cr_craprad(pr_cdcooper IN craprad.cdcooper%TYPE,
                      pr_nrtopico IN craprad.nrtopico%TYPE,
                      pr_nritetop IN craprad.nritetop%TYPE,
                      pr_nrseqite IN craprad.nrseqite%TYPE) IS
      SELECT r.dsseqite
        FROM craprad r
       WHERE r.cdcooper = pr_cdcooper
         AND r.nrtopico = pr_nrtopico
         AND r.nritetop = pr_nritetop
         AND r.nrseqite = pr_nrseqite;
  
    /*Busca Score Comportamental dos Últimos 6 Meses*/
    CURSOR cr_tbcrd_score(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_inpessoa crapass.inpessoa%TYPE,
                          pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT sco.cdmodelo,
             csc.dsmodelo,
             to_char(sco.dtbase, 'dd/mm/rrrr') dtbase,
             sco.nrscore_alinhado,
             sco.dsclasse_score,
             nvl(sco.dsexclusao_principal, '-') dsexclusao_principal,
             decode(sco.flvigente, 1, 'Vigente', 'Não vigente') dsvigente,
             row_number() over(PARTITION BY sco.cdmodelo ORDER BY sco.flvigente DESC, sco.dtbase DESC) nrseqreg
        FROM tbcrd_score sco, tbcrd_carga_score csc, crapass ass
       WHERE csc.cdmodelo = sco.cdmodelo
         AND csc.dtbase = sco.dtbase
         AND ass.cdcooper = sco.cdcooper
         AND ass.nrcpfcnpj_base = sco.nrcpfcnpjbase
         AND sco.cdcooper = pr_cdcooper
         AND sco.tppessoa = pr_inpessoa
         AND ass.nrdconta = pr_nrdconta
         AND sco.dtbase >= TRUNC(add_months(rw_crapdat.dtmvtolt, -6), 'MM')
       ORDER BY sco.flvigente DESC, sco.dtbase DESC;
  
    rw_score cr_tbcrd_score%ROWTYPE;
  
    /*Busca data da consulta do birô*/
    CURSOR c_busca_data_cons_biro(pr_nrconbir IN craprsc.nrconbir%TYPE, pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
      SELECT MAX(c.dtconbir) dtconbir
        FROM crapcbd c
       WHERE c.nrconbir = pr_nrconbir
         AND c.nrseqdet = pr_nrseqdet;
    vr_dt_cons_biro DATE;
  
    /*Busca data da consulta no birô e se tem crítica para persona diferente de Proponente*/
    CURSOR c_busca_restri(pr_nrconbir IN craprsc.nrconbir%TYPE, pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
      SELECT NVL(c.dtreapro, c.dtconbir) dtconbir, p.qtnegati qtnegati
        FROM crapcbd c
             --          ,craprsc r
            ,
             craprpf p
       WHERE 1 = 1
            --AND c.nrconbir = r.nrconbir
            --AND   c.nrseqdet = r.nrseqdet 
         AND c.nrconbir = p.nrconbir
         AND c.nrseqdet = p.nrseqdet
         AND c.nrconbir = pr_nrconbir
         AND c.nrseqdet = pr_nrseqdet
         AND p.vlnegati > 0
       ORDER BY 1 DESC;
    r_busca_restri c_busca_restri%ROWTYPE;
  
    /* Lista de participação */
    CURSOR c_busca_participacao(pr_nrconbir crapcbd.nrconbir%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT DISTINCT c.nrcpfcgc --Documento
                     ,
                      nmtitcon --Nome / Razão Social
                     ,
                      c.dtentsoc --Data de Início
                     ,
                      to_char(c.percapvt, '990D99') percapvt --Percentual do Capital Votante
                     ,
                      to_char(c.pertotal, '990D99') pertotal --Percentual de Participação
        FROM crapcbd c, crapass a, crapavt s
       WHERE a.cdcooper = 1
         AND a.cdcooper = c.cdcooper
         AND c.cdcooper = s.cdcooper
         AND a.nrcpfcgc = c.nrcpfcgc
         AND c.nrconbir = pr_nrconbir --Birô consultado
         AND c.intippes IN (4, 5)
         AND s.tpctrato = 6 /*procurad*/
         AND s.nrdconta = pr_nrdconta
         AND s.nrcpfcgc = c.nrcpfcgc
         AND s.nrctremp = 0
         AND s.persocio > 0;
    r_busca_participacao c_busca_participacao%ROWTYPE;
  
    /*Lista de anotações negativas - Órgão de Proteção ao Crédito*/
    CURSOR c_busca_orgao_prot_cred(pr_nrconbir craprpf.nrconbir%TYPE, pr_nrseqdet craprpf.nrseqdet%TYPE) IS
      SELECT dsnegati, decode(qtnegati, NULL, 'Nada Consta', qtnegati) qtnegati, vlnegati, dtultneg
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
              SELECT 2, 'PEFIN' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 2
              UNION ALL
              SELECT 3, 'Protesto' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 3
              UNION ALL
              SELECT 4, 'Ação Judicial' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
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
              SELECT 6, 'SERASA' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 8
              UNION ALL
              SELECT 7, 'SPC' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 9
              UNION ALL
              SELECT 10, 'Dívida Vencida' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 10
              UNION ALL
              SELECT 11, 'Inadimplência' dsnegati, MAX(craprpf.qtnegati), MAX(craprpf.vlnegati), MAX(craprpf.dtultneg)
                FROM craprpf
               WHERE craprpf.nrconbir = pr_nrconbir
                 AND craprpf.nrseqdet = pr_nrseqdet
                 AND craprpf.innegati = 11)
       ORDER BY to_number(1) DESC;
  
    /*Pefin(1), Refin(2), Dívida Vencida no SPC e Serasa (3)*/
    CURSOR c_busca_pefin_refin(pr_nrconbir crapprf.nrconbir%TYPE,
                               pr_nrseqdet crapprf.nrseqdet%TYPE,
                               pr_inpefref NUMBER) IS
      SELECT to_char(dtvencto, 'DD/MM/YYYY') data,
             dsmtvreg modalidade,
             to_char(vlregist, '999g999g990d00') valor,
             dsinstit origem
        FROM crapprf r
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet
         AND NVL(inpefref, 0) = NVL(pr_inpefref, 0) --Pefin 1, Refin 2, 3 Divida Vencida, 0 Pefin e Refin PJ
       ORDER BY r.dtvencto DESC;
    r_busca_pefin_refin c_busca_pefin_refin%ROWTYPE;
  
    /*Consulta Protestos*/
    CURSOR c_busca_protestos(pr_nrconbir crapprf.nrconbir%TYPE, pr_nrseqdet crapprf.nrseqdet%TYPE) IS
      SELECT to_char(dtprotes, 'DD/MM/YYYY') data,
             to_char(vlprotes, '999g999g999g990d00') valor,
             nmcidade cidade,
             cdufende uf
        FROM CRAPPRT
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet;
    r_busca_protestos c_busca_protestos%ROWTYPE;
  
    /*Consulta Ações*/
    CURSOR c_busca_acoes(pr_nrconbir crapprf.nrconbir%TYPE, pr_nrseqdet crapprf.nrseqdet%TYPE) IS
      SELECT to_char(dtacajud, 'DD/MM/YYYY') data,
             dsnataca natureza,
             to_char(vltotaca, '999g999g999g990d00') valor,
             nrdistri distrito,
             nrvaraca vara,
             nmcidade cidade,
             cdufende uf
        FROM CRAPABR
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet;
    r_busca_acoes c_busca_acoes%ROWTYPE;
  
    /*Consulta Recuperações, Falências, Concordata*/
    CURSOR c_busca_craprpf(pr_nrconbir crapprf.nrconbir%TYPE, pr_nrseqdet crapprf.nrseqdet%TYPE) IS
      SELECT dtultneg data, vlnegati valor
        FROM craprpf
       WHERE nrconbir = pr_nrconbir
         AND nrseqdet = pr_nrseqdet
         AND innegati = 5;
    r_busca_craprpf c_busca_craprpf%ROWTYPE;
  
    -- Select retorno motor (Rubens)
    CURSOR cr_dtconsulta(prc_cdcooper IN tbgen_webservice_aciona.cdcooper%TYPE,
                         prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                         prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
      SELECT e.dhacionamento
        FROM tbgen_webservice_aciona e
       WHERE e.cdcooper = prc_cdcooper
         AND e.nrdconta = prc_nrdconta
         AND e.nrctrprp = prc_nrctrprp
         AND e.cdoperad = 'MOTOR'
         AND e.tpacionamento = 2 -- retorno
         AND e.dsoperacao NOT LIKE '%ERRO%'
         AND e.dsoperacao NOT LIKE '%DESCONHECIDA%';
    rw_dtconsulta cr_dtconsulta%ROWTYPE;
  
    /*Busca data da consulta do SCORE (BOA VISTA)*/
    CURSOR c_busca_data_score(pr_cdcooper crapass.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT a.dtdscore
        FROM crapass a
       WHERE nrdconta = pr_nrdconta
         AND cdcooper = pr_cdcooper;
    
    /*Busca sequêncial quando não é o proponente e está no birô*/
    CURSOR c_consulta_outras_personas (pr_nrconbir crapcbd.nrconbir%TYPE
                                      ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
     SELECT nrseqdet
     FROM crapcbd
     WHERE nrconbir = pr_nrconbir
     AND   nrcpfcgc = pr_nrcpfcgc
     ORDER BY NMTITCON;

    /*Busca sequêncial quando não é o proponente e NÃO está no birô*/
    CURSOR c_busca_cbd_historico (pr_nrcpfcgc crapcbd.nrcpfcgc%TYPE) IS
     SELECT nrconbir, nrseqdet
     FROM crapcbd
     WHERE cdcooper = pr_cdcooper
     AND   nrcpfcgc = pr_nrcpfcgc
     AND   dtconbir >= sysdate-180
     ORDER BY nrconbir DESC, nmtitcon;
  
    vr_string_operacoes CLOB; --XML de retorno
    vr_index            NUMBER; --Index
    v_haspreju          VARCHAR2(10); -- Retorno teve preju
  
    v_rtReadJson                VARCHAR2(1000) := NULL;
    v_somaValores               NUMBER;
    v_count                     NUMBER;
    v_ehnumero                  NUMBER;
    vr_dsrestricao              VARCHAR2(30);
    vr_inicio                   NUMBER; --temp
    vr_temrestri                NUMBER := 0;
    vr_adiantamento_depositante NUMBER;
  
    --
    vr_insitcon                 BOOLEAN:=FALSE; /*Se o cônjuge está presenta na consulta do PDF*/
    
    /*Busca o score da crapass quando não for proponente*/
    FUNCTION fn_busca_score(pr_cdcooper crapcop.cdcooper%TYPE, pr_nrdconta crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
      vr_retorno crapass.dsdscore%TYPE;
    BEGIN
      SELECT dsdscore
        INTO vr_retorno
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    
      RETURN vr_retorno;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '-';
    END;
  
  BEGIN
    /*Buscar sequência do birô*/
    pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => vr_nrdconta_principal,
                           pr_nrconbir => vr_nrconbir,
                           pr_nrseqdet => vr_nrseqdet);
  
    /*Informações Cadastrais*/
    vr_string_operacoes := '<subcategoria>' || '<tituloTela>Informações Cadastrais</tituloTela>' || -- Titulo da subcategoira
                           '<tituloFiltro>informacoes_cadastrais</tituloFiltro>' || -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria  
  
    /* Quando o Proponente tiver Empréstimo ou Desc. Título */


      /*Verifica se a persona foi consultada e contém dados na CRAPRPF*/
      OPEN c_consulta_outras_personas (pr_nrconbir => vr_nrconbir
                                      ,pr_nrcpfcgc => pr_nrcpfcgc);
       FETCH c_consulta_outras_personas INTO vr_nrseqdet;
       IF c_consulta_outras_personas%NOTFOUND THEN
         vr_nrseqdet := NULL; 
         vr_insitcon := FALSE; /*Persona não estava na consulta*/
       ELSE
         vr_insitcon := TRUE;
       END IF;
      CLOSE c_consulta_outras_personas;
      
      /*Se a persona não estava na consulta pelo proponente, busca sua última consulta individual no CONSCR*/
      IF (vr_insitcon = FALSE) THEN
        OPEN c_busca_cbd_historico (pr_nrcpfcgc => pr_nrcpfcgc);
         FETCH c_busca_cbd_historico INTO vr_nrconbir, vr_nrseqdet ;
        CLOSE c_busca_cbd_historico;
      END IF;
      
      /*Verifica quando foi a última consulta na CONSCR*/
      OPEN c_busca_data_cons_biro(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet);
      FETCH c_busca_data_cons_biro
        INTO vr_dt_cons_biro;
      CLOSE c_busca_data_cons_biro;
    
      OPEN c_busca_restri(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet);
    
      FETCH c_busca_restri
        INTO r_busca_restri;
    
      IF c_busca_restri%FOUND THEN
      
        IF (r_busca_restri.qtnegati > 0) THEN
          vr_temrestri   := 1; --tem restrição
          vr_dsrestricao := 'Com Restrição.';
        ELSE
          vr_dsrestricao := 'Sem Restrição.';
        END IF;
      
        vr_string_operacoes := vr_string_operacoes || fn_tag('Situação',
                                                             --vr_dsrestricao || ' Consulta Boa Vista em: ' || CASE
                                                             vr_dsrestricao || ' Consulta em: ' || CASE
                                                                WHEN vr_dt_cons_biro IS NOT NULL THEN
                                                                 to_char(vr_dt_cons_biro, 'DD/MM/YYYY')
                                                                ELSE
                                                                 'SEM CONSULTA'
                                                              END);
      ELSE
      
        IF (vr_dt_cons_biro IS NULL) THEN
          OPEN c_busca_data_score(pr_cdcooper => pr_cdcooper, pr_nrdconta => pr_nrdconta);
          FETCH c_busca_data_score
            INTO vr_dt_cons_biro;
          CLOSE c_busca_data_score;
        END IF;
      
        vr_string_operacoes := vr_string_operacoes || fn_tag('Situação',
                                                             --'Sem Restrição' || ' Consulta Boa Vista em: ' || CASE
                                                               'Sem Restrição' || ' Consulta em: ' || CASE
                                                                WHEN vr_dt_cons_biro IS NOT NULL --data consulta boa vista
                                                                 THEN
                                                                 to_char(vr_dt_cons_biro, 'DD/MM/YYYY')
                                                                ELSE
                                                                 'SEM CONSULTA'
                                                              END);
      END IF;
    
      CLOSE c_busca_restri;
    
  
    --Se tem restrição, monta a tabela do resumo
    IF (vr_temrestri = 1) THEN
    
      /*RESUMO ANOTAÇÕES NEGATIVAS - Consulta ao Órgãos de Proteção ao Crédito*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>Resumo Anotações Negativas</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      /*PJ tem: Pefin, Protesto, Refin, Ações, Recuperações, Dívida Vencida
      PF tem: SPC, Pefin, Protesto, Refin, Ações, Dívida Vencida */
    
      vr_index := 1;
      vr_tab_tabela.delete;
      FOR r_craprpf IN c_busca_orgao_prot_cred(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet) LOOP
      
        IF (pr_inpessoa = 2 AND r_craprpf.dsnegati IN ('SPC', 'SERASA')) THEN
          CONTINUE;
        END IF;
      
        IF (pr_inpessoa = 1) AND r_craprpf.dsnegati IN ('Participação falência', 'SERASA') THEN
          CONTINUE;
        END IF;
      
        vr_tab_tabela(vr_index).coluna1 := r_craprpf.dsnegati; --Anotações
        vr_tab_tabela(vr_index).coluna2 := r_craprpf.qtnegati; --Quantidade
        vr_tab_tabela(vr_index).coluna3 := CASE
                                             WHEN r_craprpf.vlnegati IS NOT NULL THEN
                                              to_char(r_craprpf.vlnegati, '999g999g990d00')
                                             ELSE
                                              '-'
                                           END; --Valor
        vr_tab_tabela(vr_index).coluna4 := CASE
                                             WHEN r_craprpf.dtultneg IS NOT NULL THEN
                                              to_char(r_craprpf.dtultneg, 'DD/MM/YYYY')
                                             ELSE
                                              '-'
                                           END; --Data Última
        vr_index := vr_index + 1;
      END LOOP;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes ||
                               fn_tag_table('Anotações;Quantidade;Valor;Data Última', vr_tab_tabela);
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_string_operacoes := vr_string_operacoes ||
                               fn_tag_table('Anotações;Quantidade;Valor;Data Última', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*Registro SPC - Somente para PF*/
      IF (pr_inpessoa = 1) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>Registro SPC</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
        vr_index            := 1;
        vr_tab_tabela.delete;
        FOR r_craprsc IN c_craprsc(vr_nrconbir, vr_nrseqdet) LOOP
          vr_tab_tabela(vr_index).coluna1 := r_craprsc.inlocnac;
          vr_tab_tabela(vr_index).coluna2 := r_craprsc.dsinstit;
          vr_tab_tabela(vr_index).coluna3 := CASE WHEN r_craprsc.nmcidade IS NOT NULL THEN r_craprsc.nmcidade ELSE '-' END;
          vr_tab_tabela(vr_index).coluna4 := CASE WHEN r_craprsc.cdufende IS NOT NULL THEN r_craprsc.cdufende ELSE '-' END;
          vr_tab_tabela(vr_index).coluna5 := to_char(r_craprsc.dtregist, 'DD/MM/YYYY');
          vr_tab_tabela(vr_index).coluna6 := to_char(r_craprsc.dtvencto, 'DD/MM/YYYY');
          vr_tab_tabela(vr_index).coluna7 := to_char(NVL(r_craprsc.vlregist,0), '999g999g999g990d00');
          vr_tab_tabela(vr_index).coluna8 := r_craprsc.dsmtvreg;
          vr_index := vr_index + 1;
        END LOOP;
      
        IF vr_tab_tabela.COUNT > 0 THEN
          /*Gera Tags Xml*/
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Tipo;Instituição;Cidade;UF;Registro;Vencimento;Valor;Motivo',
                                                                     vr_tab_tabela);
        ELSE
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_tab_tabela(1).coluna3 := '-';
          vr_tab_tabela(1).coluna4 := '-';
          vr_tab_tabela(1).coluna5 := '-';
          vr_tab_tabela(1).coluna6 := '-';
          vr_tab_tabela(1).coluna7 := '-';
          vr_tab_tabela(1).coluna8 := '-';
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Tipo;Instituição;Cidade;UF;Registro;Vencimento;Valor;Motivo',
                                                                     vr_tab_tabela);
        END IF;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      END IF;
    
      /*PEFIN - DETALHE*/
    
      /*OBS: PJ tem Pefin e Refin separados. 
      PF tem os dois juntos e o valor de INPEFREF é null*/
      IF (pr_inpessoa = 1) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>PEFIN e REFIN- (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      ELSE
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>PEFIN - (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      
      END IF;
      vr_index := 0;
      vr_tab_tabela.delete;
    
      /*PF*/
      IF (pr_inpessoa = 1) THEN
        OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet, pr_inpefref => NULL); -- PEFIN PF
      
      ELSE
        /*PJ*/
        OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet, pr_inpefref => 1); -- PEFIN PJ
      END IF;
    
      LOOP
        FETCH c_busca_pefin_refin
          INTO r_busca_pefin_refin;
        EXIT WHEN vr_index = 5;
        IF c_busca_pefin_refin%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.modalidade;
          vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.valor;
          vr_tab_tabela(vr_index).coluna4 := r_busca_pefin_refin.origem;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_pefin_refin;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Modalidade;Valor;Origem', vr_tab_tabela);
      ELSE
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                </valor>
                                                </campo>';
    
      /*PROTESTOS*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                <nome>PROTESTO - (Ocorrências mais recentes - até cinco)</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
      OPEN c_busca_protestos(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet);
      LOOP
        FETCH c_busca_protestos
          INTO r_busca_protestos;
        EXIT WHEN vr_index = 5;
        IF c_busca_protestos%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_protestos.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_protestos.valor;
          vr_tab_tabela(vr_index).coluna3 := r_busca_protestos.cidade;
          vr_tab_tabela(vr_index).coluna4 := r_busca_protestos.uf;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_protestos;
    
      /*Monta o XML de protestos*/
      IF vr_tab_tabela.COUNT > 0 THEN
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor;Cidade;UF', vr_tab_tabela);
      ELSE
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*REFIN - DETALHE - Apenas para o PJ. PF já carregou junto com o PEFIN*/
      IF (pr_inpessoa = 2) THEN
        vr_index := 0;
        vr_tab_tabela.delete;
      
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                    <nome>REFIN - (Ocorrências mais recentes - até cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
        vr_index            := 0;
        vr_tab_tabela.delete;
      
        OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet, pr_inpefref => 2); -- REFIN
        LOOP
          FETCH c_busca_pefin_refin
            INTO r_busca_pefin_refin;
        
          EXIT WHEN VR_INDEX > 5;
          IF c_busca_pefin_refin%FOUND THEN
            vr_index := vr_index + 1;
            vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
            vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.modalidade;
            vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.valor;
            vr_tab_tabela(vr_index).coluna4 := r_busca_pefin_refin.origem;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      
        CLOSE c_busca_pefin_refin;
      
        IF vr_tab_tabela.COUNT > 0 THEN
          /*Gera Tags Xml*/
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Modalidade;Valor;Origem', vr_tab_tabela);
        ELSE
          --vr_tab_tabela(1).coluna1 := '-';
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
        END IF;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                    </valor>
                                                    </campo>';
      END IF;
    
      /*AÇÕES - Para PF e PJ*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>AÇÕES - (Ocorrências mais recentes - até cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
      OPEN c_busca_acoes(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet);
      LOOP
        FETCH c_busca_acoes
          INTO r_busca_acoes;
        EXIT WHEN vr_index = 5;
        IF c_busca_acoes%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_acoes.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_acoes.natureza;
          vr_tab_tabela(vr_index).coluna3 := r_busca_acoes.valor;
          vr_tab_tabela(vr_index).coluna4 := r_busca_acoes.distrito;
          vr_tab_tabela(vr_index).coluna5 := r_busca_acoes.vara;
          vr_tab_tabela(vr_index).coluna6 := r_busca_acoes.cidade;
          vr_tab_tabela(vr_index).coluna7 := r_busca_acoes.uf;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_acoes;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes ||
                               fn_tag_table('Data;Natureza;Valor;Distrito;Vara;Cidade;UF', vr_tab_tabela);
      ELSE
        --vr_tab_tabela(1).coluna1 := 'NADA CONSTA';
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*DIVIDA VENCIDA - DETALHE*/
      vr_string_operacoes := vr_string_operacoes || '<campo>
                                                 <nome>DÍVIDA VENCIDA - (Ocorrências mais recentes - até cinco)</nome>
                                                 <tipo>table</tipo>
                                                 <valor>
                                                 <linhas>';
      vr_index            := 0;
      vr_tab_tabela.delete;
    
      OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet, pr_inpefref => 3); -- DIVIDA VENCIDA
      LOOP
        FETCH c_busca_pefin_refin
          INTO r_busca_pefin_refin;
        EXIT WHEN vr_index = 5;
        IF c_busca_pefin_refin%FOUND THEN
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_pefin_refin.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_pefin_refin.valor;
          vr_tab_tabela(vr_index).coluna3 := r_busca_pefin_refin.origem;
        ELSE
          EXIT;
        END IF;
      END LOOP;
    
      CLOSE c_busca_pefin_refin;
    
      IF vr_tab_tabela.COUNT > 0 THEN
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor;Origem', vr_tab_tabela);
      ELSE
        vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
      END IF;
    
      vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
    
      /*RECUPERAÇÕES, FALÊNCIA E CONCORDATA - apenas para PJ*/
      IF (pr_inpessoa = 2) THEN
        vr_string_operacoes := vr_string_operacoes || '<campo>
                                                  <nome>RECUPERAÇÕES, FALÊNCIA E CONCORDATA - (Ocorrências mais recentes - até cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
        vr_index            := 0;
        vr_tab_tabela.delete;
      
        OPEN c_busca_craprpf(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet);
        LOOP
          FETCH c_busca_craprpf
            INTO r_busca_craprpf;
          EXIT WHEN vr_index = 5;
          IF c_busca_craprpf%FOUND THEN
            vr_index := vr_index + 1;
            vr_tab_tabela(vr_index).coluna1 := r_busca_craprpf.data;
            vr_tab_tabela(vr_index).coluna2 := r_busca_craprpf.valor;
          ELSE
            EXIT;
          END IF;
        END LOOP;
      
        CLOSE c_busca_craprpf;
      
        IF vr_tab_tabela.COUNT > 0 THEN
          /*Gera Tags Xml*/
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('Data;Valor', vr_tab_tabela);
        ELSE
          vr_string_operacoes := vr_string_operacoes || fn_tag_table('NADA CONSTA', vr_tab_tabela);
        END IF;
      
        vr_string_operacoes := vr_string_operacoes || '</linhas>
                                                  </valor>
                                                  </campo>';
      END IF;
    
      /*Fim da Subcategoria de RESUMO DE ANOTAÇÕES NEGATIVAS*/
    END IF; --Fim da tabela do Resumo de Anotações  
    vr_string_operacoes := vr_string_operacoes || '</campos></subcategoria>';

    pr_dsxmlret := vr_string_operacoes;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := substr('Erro pc_consulta_consultas_ncoop: ' || SQLERRM, 1, 250);
  END pc_consulta_consultas_ncoop;

  PROCEDURE pc_gera_token_ibratan(pr_cdcooper IN crapope.cdcooper%TYPE, --> cooperativa
                                  pr_cdagenci IN crapope.cdagenci%TYPE, --> Agencia
                                  pr_cdoperad IN crapope.cdoperad%TYPE, --> Operador
                                  pr_dstoken  OUT VARCHAR2, --> Token
                                  pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                  pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                  ) IS
    /* .............................................................................
    
      Programa: pc_gera_token_ibratan
      Sistema : Aimaro/Ibratan
      Autor   : Bruno Luiz Katzjarowski - Mout's
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para gravar token ibratan
    
      Alteracoes:
    ..............................................................................*/
  
    -- Verificar se PA utilza o CRM
    CURSOR cr_crapage (prc_cdcooper IN crapage.cdcooper%TYPE,
                       prc_cdagenci IN crapage.cdagenci%TYPE) IS
      SELECT /*age.flgutcrm*/0 flgutcrm
        FROM crapage age
       WHERE age.cdcooper = prc_cdcooper
         AND age.cdagenci = prc_cdagenci;
  
    rw_crapage cr_crapage%ROWTYPE;
  
    -- Verifcar acesso do operador ao CRM
    CURSOR cr_crapope (prc_cdcooper IN crapope.cdcooper%TYPE,
                       prc_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT ope.inutlcrm,
             ope.cddsenha
        FROM crapope ope
       WHERE ope.cdcooper = prc_cdcooper
         AND UPPER(ope.cdoperad) = UPPER(prc_cdoperad);
  
    rw_crapope cr_crapope%ROWTYPE;
    ---------------> VARIAVEIS <-----------------
    vr_dstoken  VARCHAR2(4000);
    vr_cdcooper crapope.cdcooper%TYPE;
    vr_cdagenci crapope.cdagenci%TYPE;
    vr_cdoperad crapope.cdoperad%TYPE;
  
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);
    vr_cdcritic PLS_INTEGER;
  BEGIN
    --Inicializar Variaveis
    vr_cdcritic := 0;
    vr_dscritic := NULL;
    vr_dstoken  := NULL;
  
    vr_cdcooper := pr_cdcooper;
    vr_cdagenci := pr_cdagenci;
    vr_cdoperad := pr_cdoperad;
  
    /* Verificar existencia de PA */
    OPEN cr_crapage(vr_cdcooper,
                    vr_cdagenci);
  
    FETCH cr_crapage INTO rw_crapage;
  
    -- Se não encontrou PA
    IF cr_crapage%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapage;
      -- Gerar crítica
      vr_cdcritic := 962;
      vr_dscritic := '';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
  
    -- Fechar cursor
    CLOSE cr_crapage;
  
    /* Verificar existencia de operador */
    OPEN cr_crapope(vr_cdcooper,
                    vr_cdoperad);
  
    FETCH cr_crapope INTO rw_crapope;
  
    -- Se não encontrou registro de operador
    IF cr_crapope%NOTFOUND THEN
      -- Fechar cursor
      CLOSE cr_crapope;
      -- Gerar crítica
      vr_cdcritic := 67;
      vr_dscritic := '';
      -- Levantar exceção
      RAISE vr_exc_erro;
    END IF;
  
    -- Fechar cursor
    CLOSE cr_crapope;
  
    --Se token esta nulo gera, caso contrário utiliza o token já gerado
    if trim(rw_crapope.cddsenha) is null then
      -- Gera o codigo do token
      vr_dstoken := substr(dbms_random.random, 1, 10);
      --    vr_dstoken := upper(vr_cdoperad);--'teste';
    
      -- Atualiza a tabela de senha do operador
      BEGIN
      UPDATE crapope
         SET cddsenha = vr_dstoken
       WHERE upper(cdoperad) = upper(vr_cdoperad);
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
          vr_dscritic := 'Erro ao atualizar CRAPOPE: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      --
      -- Processamento OK, retorna Token
      pr_dstoken := vr_dstoken;
    
    else
      pr_dstoken := rw_crapope.cddsenha;
    end if;

  
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dstoken := NULL;
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic || ' ' || GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
    
    --ROLLBACK;
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_gera_token_ibratan: ' || SQLERRM;
      pr_dstoken  := NULL;
    
    --ROLLBACK;
  END pc_gera_token_ibratan;
  --------------------------------------------------------------------------------------------------------------
  -- FIM pc_gera_token_ibratan
  --------------------------------------------------------------------------------------------------------------


PROCEDURE pc_write_xml( pr_des_dados in varchar2
                        , pr_fecha_xml in boolean default false
                        ) is
  BEGIN
   gene0002.pc_escreve_xml( vr_des_xml
                          , vr_texto_completo
                          , pr_des_dados
                          , pr_fecha_xml );
  END;

  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Variável CLOB onde será incluído o texto
                           pr_texto_completo in out nocopy clob,  --> Variável para armazenar o texto até ser incluído no CLOB
                           pr_texto_novo in clob,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se é o último texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml (Com base em pc_escreve_xml)
      Autor:
      Data:                                       Última atualização:
    
    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy clob,
                           pr_texto_novo clob) is
    begin
      -- Tenta concatenar o novo texto após o texto antigo (variável global da package)
      pr_texto_completo := pr_texto_completo || pr_texto_novo;
    exception when value_error then
      if pr_xml is null then
          pr_xml := pr_texto_completo;
      else
          --dbms_lob.writeappend(pr_xml, length(pr_texto_completo),pr_texto_completo);
          -- Estamos em Teste na utilização do append
          dbms_lob.append(dest_lob => pr_xml, src_lob => pr_texto_completo);
        pr_texto_completo := null;
      end if;
    end;
    --
  begin
  
    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_escreve_xml');
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o último texto do arquivo, inclui no CLOB
    if pr_fecha_xml then
      dbms_lob.append(pr_xml, pr_texto_completo);
      pr_texto_completo := null;
    end if;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  end;
    
PROCEDURE pc_busca_rendas_aut(pr_cdcooper IN crapass.cdcooper%TYPE
                             ,pr_nrdconta IN crapass.nrdconta%TYPE
                             ,pr_xmlRenda OUT VARCHAR2) IS

    CURSOR cr_tbfolha_lanaut(pr_cdcooper crapcop.cdcooper%TYPE
                            ,pr_nrdconta craplcm.nrdconta%TYPE
                            ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
      SELECT /*+ INDEX(lan TBFOLHA_LANAUT_IDX01) */ lan.vlrenda, lan.dtmvtolt, his.dshistor
        FROM tbfolha_lanaut lan, craphis his
       WHERE lan.cdcooper = pr_cdcooper
         AND lan.nrdconta = pr_nrdconta
         AND lan.dtmvtolt >= pr_dtmvtolt
         AND lan.cdcooper = his.cdcooper
         AND lan.cdhistor = his.cdhistor
       ORDER BY lan.dtmvtolt;
  
    vr_contlan  PLS_INTEGER;
    vr_mesatual PLS_INTEGER;
    vr_mesante  PLS_INTEGER;
    vr_vltotmes DECIMAL(10, 2);
  
    vr_referenc VARCHAR2(7);
  
    vr_string CLOB;
    vr_index    number;
  
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    FUNCTION fn_busca_data_ret(pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN DATE IS
    BEGIN
      RETURN ADD_MONTHS(TO_DATE('01' || TO_CHAR(pr_dtmvtolt, 'MM/RRRR'), 'DD/MM/RRRR'), -3);
    END fn_busca_data_ret;
  
  BEGIN
  
    vr_contlan := 0; /*conta qtos meses*/
  
    vr_mesante  := 0; /*jogada no loop pra saber qdo quebrou o mes*/
    vr_vltotmes := 0; /*valor total dos lancamentos em cada mes*/
  
    vr_index := 0;
    vr_tab_tabela.delete;
  
    /* ler a tbfolha_lanaut pegar os ultimos 3 resultados da query
    ou se flultimo estiver ativa pegar apenas o ultimo*/
    FOR rw_tbfolha_lanaut IN cr_tbfolha_lanaut(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_dtmvtolt => fn_busca_data_ret(rw_crapdat.dtmvtolt))LOOP
    
      vr_mesatual := TO_NUMBER(TO_CHAR(rw_tbfolha_lanaut.dtmvtolt, 'MM'));
    
      IF vr_mesante <> vr_mesatual THEN
      
        /*Cria o registro totalizador*/
        IF vr_vltotmes > 0 THEN
        
          /*VALOR TOTAL DO MES*/
          vr_index := vr_index + 1;
          vr_tab_tabela(vr_index).coluna1 := '-';
          vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFERÊNCIA - ' || vr_referenc || '&lt;/b&gt;';
           vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';
        
          vr_vltotmes := 0;
        END IF;
      
        vr_referenc := LPAD(TO_CHAR(vr_mesatual), 2, '0') || '/' || TO_CHAR(rw_tbfolha_lanaut.dtmvtolt, 'RRRR');
      
        vr_contlan := vr_contlan + 1;
        vr_mesante := vr_mesatual;
      END IF;
    
      --Data, valor e histórico
      vr_index := vr_index + 1;
      vr_tab_tabela(vr_index).coluna1 := TO_CHAR(rw_tbfolha_lanaut.dtmvtolt, 'DD/MM/RRRR');
      vr_tab_tabela(vr_index).coluna2 := rw_tbfolha_lanaut.dshistor;
      vr_tab_tabela(vr_index).coluna3 := TO_CHAR(rw_tbfolha_lanaut.vlrenda, 'fm9g999g999g999g999g990d00');
    
      vr_vltotmes := vr_vltotmes + rw_tbfolha_lanaut.vlrenda;
    
    END LOOP;
  
    /*Criar lancamento total para ultimo mes do loop*/
    IF vr_vltotmes > 0 THEN
    
      /*VALOR TOTAL DO MES E REFERENCIA*/
      vr_index := vr_index + 1;
      vr_tab_tabela(vr_index).coluna1 := '-';
      vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFERÊNCIA - ' || vr_referenc || '&lt;/b&gt;';
       vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';
    END IF;
  
    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string := vr_string || fn_tag_table('Data;Descrição;Valor', vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_string := vr_string || fn_tag_table('Data;Descrição;Valor', vr_tab_tabela);
    end if;
    pr_xmlRenda := vr_string;
  
  END pc_busca_rendas_aut;

  PROCEDURE pc_consulta_hist_cartaocredito(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                          ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                          ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                          ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                          
                                          ,pr_dsxmlret IN OUT CLOB) IS                --> Arquivo de retorno do XML
  
    /* .............................................................................
    
      Programa: pc_consulta_hist_cartaocredito
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar o historico do cartao de credito.
    
      Alteracoes:
    ..............................................................................*/
  
  
    /*Consulta Historico Cartao de Credito*/
  cursor c_consulta_hist_cartao is                           
  SELECT to_char(atu.dtalteracao,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMÁTICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , nvl(atu.nrproposta_est,0) nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Concluído'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em Análise'
                                  ,8,'8 - Efetivada') Situacao
           , atu.idatualizacao
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper = pr_cdcooper
         AND atu.nrdconta = pr_nrdconta
            --  AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.tpsituacao = 3 /* Concluido com sucesso */
         and atu.nrproposta_est IS NULL
      UNION
      SELECT to_char(atu.dtalteracao,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOMÁTICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , nvl(atu.nrproposta_est,0) nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Concluído'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em Análise'
                                  ,8,'8 - Efetivada') Situacao
           , atu.idatualizacao
        FROM tbcrd_limite_atualiza atu
       WHERE atu.cdcooper = pr_cdcooper
         AND atu.nrdconta = pr_nrdconta
            -- AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.nrproposta_est IS NOT NULL
         AND atu.dtalteracao = (SELECT max(dtalteracao) --bug 20705
                                  FROM tbcrd_limite_atualiza lim
                                 WHERE lim.cdcooper = atu.cdcooper
                                   AND lim.nrdconta = atu.nrdconta
                                   AND lim.nrconta_cartao = atu.nrconta_cartao
                                   AND lim.nrproposta_est = atu.nrproposta_est)
       ORDER BY idatualizacao DESC;
  
    /* Cursor para buscar os cartões quando não existir histórico */
    CURSOR c_busca_cartoes_cc IS
     select c.dtpropos
           ,c.nrctrcrd
           ,'CANCELADO' || ' - ' || 
                 DECODE(c.cdmotivo,1,'DEFEITO'
                                  ,2,'PERDA/ROUBO'
                                  ,3,'PELO SOCIO'
                                  ,4,'PELA COOP'
                                  ,5,'CANCELADO'
                                  ,6,'POR FRAUDE'
                                  ,7,'ALT.DT.VENC'
                                  ,8,'COMPROMETIDO'
                                  ,9,'DEVOLVIDO/DESTRUIDO'
                                  ,10,'REPOSTO/REIMPRESSO'
                                  ,11,'EXTRAVIADO') insitcrd
           ,c.vllimcrd
     from crawcrd c
     where cdcooper = pr_cdcooper
     and   nrdconta = pr_nrdconta
     and   dtcancel is not null -- Retornar apenas os cancelados
     order by dtpropos desc;  
    r_busca_cartoes_cc c_busca_cartoes_cc%ROWTYPE;
  
   vr_index number := 1; 
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
    flg_majora  BOOLEAN;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
  vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Últimas 4 Operações Alteradas - Cartão de Crédito</tituloTela>'||
                   '<campos>';
  
    vr_string := vr_string || '<campo>
                              <nome>Produto Cartão de Crédito</nome>
                              <tipo>table</tipo>
                              <valor>
                          <linhas>';
  
    
    vr_index := 1;
    vr_tab_tabela.delete;
  
  for r_hist_cartao in c_consulta_hist_cartao loop
    
      vr_tab_tabela(vr_index).coluna1 := to_char(r_hist_cartao.dtretorno); --to_char(r_hist_cartao.dtretorno,'dd/mm/yyyy');
      vr_tab_tabela(vr_index).coluna2 := to_char(r_hist_cartao.nrproposta_est);
      vr_tab_tabela(vr_index).coluna3 := r_hist_cartao.Situacao;
      vr_tab_tabela(vr_index).coluna4 := to_char(r_hist_cartao.vllimite_anterior, '999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_hist_cartao.vllimite_alterado, '999g999g990d00');
    
      vr_index := vr_index + 1;
    
      -- Somente os ultimos 4 Registros
      if vr_index > 4 then
        exit;
      end if;
    
  end loop;
  
    /*Bug 20887 - Quando não houver histórico de alterações, retornar as majorações*/
    IF vr_tab_tabela.count = 0 THEN
      OPEN c_busca_cartoes_cc;
      LOOP
     FETCH c_busca_cartoes_cc INTO r_busca_cartoes_cc;
      
        IF c_busca_cartoes_cc%FOUND THEN
        
          IF vr_index = 1 THEN
            flg_majora := TRUE;
          END IF;
        
          vr_tab_tabela(vr_index).coluna1 := to_char(r_busca_cartoes_cc.dtpropos, 'DD/MM/YYYY');
          vr_tab_tabela(vr_index).coluna2 := r_busca_cartoes_cc.nrctrcrd;
          vr_tab_tabela(vr_index).coluna3 := r_busca_cartoes_cc.insitcrd;
          vr_tab_tabela(vr_index).coluna4 := to_char(r_busca_cartoes_cc.vllimcrd, '999g999g990d00');
        
        END IF;
      
        vr_index := vr_index + 1;
      
        -- Somente os ultimos 4 Registros
     if vr_index > 4 then
      exit;
     end if;
      
      END LOOP;
    
      CLOSE c_busca_cartoes_cc;
    END IF;
  
    IF vr_tab_tabela.count > 0 THEN
      /*Gera Tags Xml*/
      IF flg_majora THEN
        vr_string := vr_string || fn_tag_table('Data da Proposta;Proposta;Situação;Valor Limite', vr_tab_tabela);
      ELSE
    vr_string := vr_string||fn_tag_table('Data da Alteração;Proposta;Situação;Valor Anterior;Valor Atualizado',vr_tab_tabela);
      END IF;
    ELSE
    
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      --vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Data da Alteração;Proposta;Situação;Valor Anterior;Valor Atualizado',vr_tab_tabela);
    
    END IF;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>
                            </campos></subcategoria>';
  
                           
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_hist_cartaocredito: '||sqlerrm; 
  end pc_consulta_hist_cartaocredito;

  PROCEDURE pc_consulta_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_desc_chq
      Sistema : Aimaro/Ibratan
      Autor   : Paulo Martins - Mout's 
      Data    : Abril/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para retornar dados do desconto de Cheque.
    
      Alteracoes: Rafael Ferreira (Mouts) 17/06/19
                  Alterada declaração dos cursores para o topo da Package para poder
                  usar eles no calculo do Endividamento Total do Fluxo.
                  
    ..............................................................................*/
  

  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
  
     vr_vldscchq crapcdb.vlcheque%type :=0;
     vr_qtdscchq number :=0;
     
     wrk_idmedia pls_integer := 0;
     wrk_valor number(25,2) := 0;
     wrk_qtd_tit_liquidado pls_integer := 0;
     wrk_qtd_tit_total pls_integer := 0;
     wrk_liquidez number(25,2) := 0;     
     
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string || '<subcategoria>
                             <tituloTela>Rotativos Ativos - Modalidade Desconto de Cheques</tituloTela>
                             <campos>';
  
    open c_limite_desc_chq(pr_cdcooper, pr_nrdconta);
     fetch c_limite_desc_chq into r_limite_desc_chq;
      if c_limite_desc_chq%found then
      vr_string := vr_string || fn_tag('Limite', to_char(r_limite_desc_chq.vllimite, '999g999g990d00'));
      else
      vr_string := vr_string || fn_tag('Limite', '-');
      end if;
    close c_limite_desc_chq;
  
    for r1 in c_bordero_cheques(pr_cdcooper, pr_nrdconta) loop
    
      vr_vldscchq := vr_vldscchq + r1.vlcheque;
      vr_qtdscchq := vr_qtdscchq + 1;
    
    end loop;  
  
    vr_string := vr_string || fn_tag('Saldo Utilizado',
                 case when vr_vldscchq >0 then to_char(vr_vldscchq,'999g999g990d00') else '-' end);
  
    vr_garantia := '-';
    vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,r_limite_desc_chq.nrctrlim,r_limite_desc_chq.nrctaav1,r_limite_desc_chq.nrctaav2,'O',c_desconto_cheque, FALSE); --Desconto de Cheque
  
    vr_string := vr_string || fn_tag('Garantia', vr_garantia);
  
    --Média e Liquidez
    wrk_qtd_tit_liquidado := 0;
    wrk_qtd_tit_total     := 0;
    for r_media_liquidez in c_media_liquidez(pr_cdcooper, pr_nrdconta) loop -- 6 Meses
    
      wrk_valor := wrk_valor + r_media_liquidez.vlcheque;
    
      /*Boletos descontados que foram liquidados 
       nos últimos 06 meses / Boletos emitidos no últimos 06 meses *100 = 
      (Indicador atual do Aimaro);*/
       if r_media_liquidez.insitchq = 2 then
        wrk_qtd_tit_liquidado := wrk_qtd_tit_liquidado + 1;
        wrk_qtd_tit_total     := wrk_qtd_tit_total + 1;
       else
        wrk_qtd_tit_total := wrk_qtd_tit_total + 1;
       end if;
               
     end loop;  
     
     begin
      wrk_valor    := (wrk_valor / wrk_qtd_tit_total);
      wrk_liquidez := ((wrk_qtd_tit_liquidado / wrk_qtd_tit_total) * 100);
     exception when zero_divide then
        wrk_valor    := 0;
        wrk_liquidez := 0;
     end;
  
    --Média e Liquidez                   
    vr_string := vr_string || fn_tag('Média de Desconto do Semestre',
                 case when wrk_valor > 0 then to_char(wrk_valor,'999g999g990d00') else '-' end);
    --Retirado para posterior liberação
    /*    vr_string := vr_string||fn_tag('Liquidez do Semestre',
    case when wrk_liquidez > 0 then nvl(to_char(wrk_liquidez),'-')||'%' else '-' end);*/
    vr_string := vr_string || '</campos></subcategoria>';
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_desc_chq: '||sqlerrm;     
    
  end pc_consulta_desc_chq;  

  PROCEDURE pc_consulta_bordero_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_desc_chq
      Sistema : Aimaro/Ibratan
      Autor   : Paulo Martins - Mout's 
      Data    : Junho/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para retornar dados do Borderô desconto de Cheque.
    
      Alteracoes:
    ..............................................................................*/
  
    -- Tratamento de erros
      vr_exc_erro exception;
  
    vr_flgverbor  INTEGER;
    vr_string_bdc CLOB;
    vr_dsxmlret   CLOB;
    vr_dstexto    CLOB;
  
    vr_qt_tot_borderos NUMBER;
    vr_vl_tot_borderos NUMBER;
    vr_qt_tot_cheques  NUMBER;
  
    -- Buscar os cheques
    CURSOR cr_crapcdb IS
      SELECT SUM(crapcdb.vlcheque) valor_total_cheques, 
             COUNT(*) qt_total_cheques
        FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
         AND crapcdb.nrdconta = pr_nrdconta
         AND crapcdb.insitchq = 2
         AND crapcdb.dtlibera > rw_crapdat.dtmvtolt;
    rw_crapcdb cr_crapcdb%ROWTYPE;
  
    CURSOR cr_crapcdb_borderos IS
      select count(nrborder) total_borderos
        from (
           select crapcdb.nrborder
             from crapcdb
            where crapcdb.cdcooper = pr_cdcooper
              and crapcdb.nrdconta = pr_nrdconta
              and crapcdb.dtlibera > rw_crapdat.dtmvtolt
        group by crapcdb.nrborder);
    rw_crapcdb_borderos cr_crapcdb_borderos%ROWTYPE;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
       open cr_crapcdb;
         fetch cr_crapcdb into rw_crapcdb;
           if cr_crapcdb%found then
      vr_vl_tot_borderos := rw_crapcdb.qt_total_cheques;
      vr_qt_tot_cheques  := rw_crapcdb.valor_total_cheques;
           end if;
       close cr_crapcdb;
  
       open cr_crapcdb_borderos;
         fetch cr_crapcdb_borderos into rw_crapcdb_borderos;
           if cr_crapcdb_borderos%found then
      vr_qt_tot_borderos := rw_crapcdb_borderos.total_borderos;
           end if;
       close cr_crapcdb_borderos;
  
    vr_string_bdc := vr_string_bdc || '<subcategoria>' ||
                                         '<tituloTela>Rotativos Ativos - Produto Bôrdero de Desconto de Cheque</tituloTela>'||
                                         '<campos>';
    --Retirado para posterior liberação
    vr_string_bdc := vr_string_bdc || --fn_tag('Quantidade Total de Borderôs', vr_qt_tot_borderos)||
                     fn_tag('Quantidade Total de Cheques', vr_vl_tot_borderos) ||
                     fn_tag('Valor Total de Borderôs', to_char(vr_qt_tot_cheques, '999g999g990d00'));
  
    vr_string_bdc := vr_string_bdc || '</campos></subcategoria>';
  
    -- Encerrar a tag raiz
        pc_escreve_xml(pr_xml => vr_dsxmlret,
                      pr_texto_completo => vr_dstexto,
                      pr_texto_novo => vr_string_bdc,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_bordero_chq: '||sqlerrm;     
    
  end pc_consulta_bordero_chq;  

  PROCEDURE pc_consulta_lim_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                                    ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_lim_desc_chq
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar o historico do limite de desconto de Cheque.
    
      Alteracoes:
    ..............................................................................*/
  
    
    cursor c_limite_desc_chq is
      select c.nrctrlim, c.dtinivig, c.qtdiavig, c.vllimite, c.dtcancel
            ,decode(insitlim,1,'Em Estudo',2,'Ativo', 3,'Cancelado','Outro') insitlim 
       from craplim c
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrdconta
      and tpctrlim = 2 -- Linha de Cheque
      and insitlim = 3 -- not in (1,2) -- Pegar Somente Cancelados ou outros...
      order by dtinivig desc;

   vr_index number := 1; 
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    vr_string := vr_string || '<subcategoria>
                          <tituloTela>Últimas 4 Operações Alteradas - Desconto de Cheques</tituloTela>
                        <campos>
                        <campo>
                              <nome>Produto Limite de Desconto de Cheques</nome>
                              <tipo>table</tipo>
                              <valor>
                         <linhas>';
  
    vr_index := 1;
    vr_tab_tabela.delete;
  
    for r_lim_chq in c_limite_desc_chq loop
    
      vr_tab_tabela(vr_index).coluna1 := to_char(r_lim_chq.nrctrlim);
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_chq.dtinivig, 'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_chq.qtdiavig);
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_chq.vllimite, '999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_lim_chq.insitlim);
      vr_tab_tabela(vr_index).coluna6 := to_char(r_lim_chq.dtcancel, 'DD/MM/YYYY');
    
      vr_index := vr_index + 1;
    
      -- Somente os ultimos 4 Registros
      if vr_index > 4 then
        exit;
      end if;
      
    end loop;
    
    if vr_tab_tabela.count > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Vigência;Limite;Situação;Data do Cancelamento',vr_tab_tabela);
  else
    
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Vigência;Limite;Situação;Data do Cancelamento',vr_tab_tabela);
    
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>
                            </campos></subcategoria>';
  
                           
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_desc_chq: '||sqlerrm;     
  end pc_consulta_lim_desc_chq; 
  
  

  PROCEDURE pc_consulta_lim_desc_tit(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                                    ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_lim_desc_tit
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar o historico do limite de desconto titulo.
    
      Alteracoes: Rafael Ferreira (Mouts) 17/06/19
                  Alterada declaração dos cursores para o topo da Package para poder
                  usar eles no calculo do Endividamento Total do Fluxo.
    ..............................................................................*/
  
    vr_index NUMBER := 1;
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    /*   vr_string := vr_string||'<subcategoria>
      <tituloTela>Histórico Desconto de Títulos</tituloTela>
    <campos>
    <campo>
             <nome>Limite Desconto de Título</nome>
             <tipo>table</tipo>
    <valor>
     <linhas>';*/
  
    vr_string := vr_string || '<subcategoria>
                          <tituloTela>Últimas 4 Operações Alteradas - Desconto de Títulos</tituloTela>
                        <campos>
                            <campo>
                              <nome>Produto Limite de Desconto de Título</nome>
                              <tipo>table</tipo>
                              <valor>
                         <linhas>';
  
    vr_index := 1;
    vr_tab_tabela.delete;
  
    for r_lim_tit in c_limite_desc_tit(pr_cdcooper, pr_nrdconta) loop
    
      vr_tab_tabela(vr_index).coluna1 := to_char(r_lim_tit.nrctrlim);
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_tit.dtinivig, 'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_tit.dtfimvig, 'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_tit.vllimite, '999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_lim_tit.insitlim);
      vr_tab_tabela(vr_index).coluna6 := to_char(r_lim_tit.dsmotivo);
      if trim(to_char(r_lim_tit.dhalteracao,'DD/MM/YYYY')) is not null then
        vr_tab_tabela(vr_index).coluna7 := to_char(r_lim_tit.dhalteracao, 'DD/MM/YYYY');
      else
        vr_tab_tabela(vr_index).coluna7 := '-';
      end if;
    
      vr_index := vr_index + 1;
    
      -- Somente os ultimos 4 Registros
      if vr_index > 4 then
        exit;
      end if;
      
    end loop;
    
    if vr_tab_tabela.count > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Fim Vigência;Limite;Situação;Motivo;Data da Situação',vr_tab_tabela);
    
  else
    
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Fim Vigência;Limite;Situação;Motivo;Data da Situação',vr_tab_tabela);
    
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>
                            </campos></subcategoria>';
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_desc_tit: '||sqlerrm; 
    
  end pc_consulta_lim_desc_tit;

  PROCEDURE pc_consulta_lim_cred(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_lim_cred
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar o historico do limite de Credito.
    
      Alteracoes:
    ..............................................................................*/
  
    /*    cursor c_limite_credito is
          select c.nrctrlim, c.dtinivig, c.vllimite, c.dtfimvig
                ,decode(c.insitlim,1,'Em Estudo',2,'Ativo', 3,'Cancelado','Outro') insitlim
                ,case c.cdmotcan when 1 then 'ALT. DE LIMITE'
                                   when 2 then 'PELO ASSOCIADO'
                                   when 3 then 'PELA COOPERATIVA'
                                   when 4 then 'TRANSFERENCIA C/C'
                                   else 'DIFERENTE' end dsmotivo
           from craplim c
          where cdcooper = pr_cdcooper
          and nrdconta = pr_nrdconta
          and tpctrlim = 1 -- Linha de Limite de credito
          and insitlim = 3 -- Pegar Somente Cancelados
          order by dtinivig desc;
    */
    --bug 19888
    cursor c_limite_credito is
    select x.*
          from (
        select c.nrctrlim
             , c.dtinivig
             , c.dtfimvig
             , c.vllimite
             , 'CANCELADO' insitlim
             , case c.cdmotcan when 1 then 'ALT. DE LIMITE'
                               when 2 then 'PELO ASSOCIADO'
                               when 3 then 'PELA COOPERATIVA'
                               when 4 then 'TRANSFERENCIA C/C'
                               else 'DIFERENTE' end dsmotivo
          from craplim c
             , crapope o
         where c.cdcooper = pr_cdcooper
           and c.nrdconta = pr_nrdconta
           and c.tpctrlim = 1            
           and c.insitlim = 3            
           and c.nrctrlim <> 0
       and o.cdcooper = c.cdcooper
       and o.cdoperad = c.cdoperad
        union
        select t.nrctrlim
             , x.dtinivig
             , x.dtfimvig
             , x.vllimite
             , 'MAJORACAO' insitlim
             , ('Limite - '||t.dsvalor_anterior||' --> '||t.dsvalor_novo) dsmotivo
          from craplim x
             , tblimcre_historico t
         where x.cdcooper = t.cdcooper
           and x.nrdconta = t.nrdconta
           and x.nrctrlim = t.nrctrlim
           and x.tpctrlim = t.tpctrlim
           and t.nmcampo  = 'vllimite'
           and t.cdcooper = pr_cdcooper
           and t.nrdconta = pr_nrdconta
           and t.tpctrlim = 1
           and t.nrctrlim <> 0
        union
        select t.nrctrlim
             , x.dtinivig
             , x.dtfimvig
             , x.vllimite
             , 'RENOVACAO' insitlim
             , ('Renovacao '||' - '||to_char(t.dhalteracao,'DD/MM/RRRR')) dsmotivo
          from craplim x
             , tblimcre_historico t
         where x.cdcooper = t.cdcooper
           and x.nrdconta = t.nrdconta
           and x.nrctrlim = t.nrctrlim
           and x.tpctrlim = t.tpctrlim
           and t.nmcampo  = 'dtrenova'
           and t.cdcooper = pr_cdcooper
           and t.nrdconta = pr_nrdconta
           and t.tpctrlim = 1
           and t.nrctrlim <> 0) x
        order
           by dtfimvig desc;
    


   vr_index number := 1; 
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    vr_string := vr_string || '<subcategoria>
                              <tituloTela>Últimas 4 Operações Alteradas - Limite de Crédito</tituloTela>
                        <campos>
                        <campo>
                              <nome>Produto Limite de Crédito</nome>
                              <tipo>table</tipo>
                              <valor>
                         <linhas>';
  
    vr_index := 1;
    vr_tab_tabela.delete;
  
    for r_lim_cred in c_limite_credito loop
    
      vr_tab_tabela(vr_index).coluna1 := to_char(gene0002.fn_mask_contrato(r_lim_cred.nrctrlim));
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_cred.dtinivig, 'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_cred.dtfimvig, 'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_cred.vllimite, '999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_lim_cred.insitlim);
      vr_tab_tabela(vr_index).coluna6 := to_char(r_lim_cred.dsmotivo);
    
      vr_index := vr_index + 1;
    
      -- Somente os ultimos 4 Registros
      if vr_index > 4 then
        exit;
      end if;
      
    end loop;
    
    if vr_tab_tabela.count > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Fim Vigência;Limite;Situação;Motivo',vr_tab_tabela);
    
  else
    
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;Início Vigência;Fim Vigência;Limite;Situação;Motivo',vr_tab_tabela);
    
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>
                            </campos></subcategoria>';
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_cred: '||sqlerrm;      
    
  end pc_consulta_lim_cred;

  PROCEDURE pc_modalidade_lim_credito(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                     
                                     ,pr_dsxmlret IN OUT CLOB) IS
  
    -- cursor 3.3.1 a
    cursor c_busca_data is
    SELECT crt.vllimite, crt.nrgarope, crt.inbaslim, crld.vlsmnesp, crld.vlsddisp,crt.nrctrlim,crt.NRCTAAV1,crt.NRCTAAV2
        FROM craplim crt
      LEFT OUTER JOIN crapsld crld ON (crld.nrdconta = crt.nrdconta and crld.cdcooper = crt.cdcooper)
     WHERE crt.nrdconta = pr_nrdconta AND
           crt.cdcooper = pr_cdcooper
         AND crt.insitlim = 2 --ativo       
         AND crt.tpctrlim = 1; --limite de credito               
    r_busca_limites c_busca_data%ROWTYPE;
  
   garantia_vllimite number; -- 3.3.1
    --garantia_inbaslim number; -- 3.3.1
   garantia_vlsmnesp number; -- 3.3.1
   saldo_total  number; -- 3.3.1
   saldo_utilizado   number; -- 3.3.1
    --garantia_descnrga varchar2(100); -- 3.3.1
   rating_descricao  varchar2(100); -- 3.3.1
  
   vr_string_lm clob;    
  
    -- variaveis de exception
    vr_des_reto VARCHAR2(100);
  
    -- variaveis de retorno
    vr_tab_saldos     EXTR0001.typ_tab_saldos;
    vr_tab_libera_epr EXTR0001.typ_tab_libera_epr;
    vr_tab_erro       gene0001.typ_tab_erro;
  
  begin
  
     extr0001.pc_carrega_dep_vista(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => NULL         --> Não gerar log
                                   ,pr_nrdcaixa => NULL         --> Não gerar log
                                   ,pr_cdoperad => NULL         --> Não gerar log
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_idorigem => 5
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'TELA_UNICA'
                                   ,pr_flgerlog => 0            --> Não gerar log
                                   ,pr_tab_saldos => vr_tab_saldos
                                   ,pr_tab_libera_epr => vr_tab_libera_epr
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => vr_tab_erro);
  
    vr_string_lm := vr_string_lm || '<subcategoria>' ||
                                     '<tituloTela>Rotativos Ativos - Modalidade Limite de Crédito</tituloTela>'||
                                     '<campos>';
  
    vr_garantia := '-';
  
    --chama cursor
        open c_busca_data;
         fetch c_busca_data into r_busca_limites;
          if c_busca_data%found then
    
      -- 1: LIMITE
      garantia_vllimite := r_busca_limites.vllimite;
    
      -- 3 GARANTIA valor do limite
      -- codigo inbaslim    1 = "COTAS DE CAPITAL"     ELSE    "CADASTRAL"
      -- garantia_inbaslim := r_busca_limites.inbaslim;
    
      -- SALDO
      IF vr_tab_saldos.count > 0 THEN
        saldo_total := vr_tab_saldos(0).vlstotal;
      END IF;
    
      -- 4 Media
      garantia_vlsmnesp := r_busca_limites.vlsmnesp;
    
      -- dbms_output.put_line(TRIM(TO_CHAR(r_busca_limites.inbaslim)));
      -- dbms_output.put_line(TRIM(TO_CHAR(r_busca_limites.vlsmnesp)));
      vr_garantia := '-';
      vr_garantia := fn_garantia_proposta(pr_cdcooper, pr_nrdconta, r_busca_limites.nrctrlim, r_busca_limites.nrctaav1, r_busca_limites.nrctaav2, 'O', c_limite_desc_titulo, FALSE);
    
          end if;
        close c_busca_data;
  
    -- 1 - limite
    vr_string_lm := vr_string_lm || fn_tag('Limite', TRIM(TO_CHAR(ROUND(garantia_vllimite, 2), '999g999g990d00')));
  
    -- 2 - saldo utilizado
    -- teste de mesa
    --garantia_vllimite := 300;
    --saldo_disponivel  := -301;
  
    IF (saldo_total >= 0) THEN
      -- se o saldo for positivo, mostrar zero
      saldo_utilizado := 0;
    ELSE
      -- se o saldo for negativo
      saldo_utilizado := saldo_total;
    END IF; -- fim 2
    vr_string_lm := vr_string_lm || fn_tag('Saldo Utilizado', to_char(nvl(saldo_utilizado, 0), '999g999g990d00'));
  
    -- 3 garantia
    -- 3.1 - Garantia - Valor do Limite
    /*if garantia_inbaslim = 1 THEN
       garantia_descnrga := TRIM(TO_CHAR(ROUND(garantia_vllimite,2),'999g999g990d00')) || ' COTAS DE CAPITAL';
    ELSE
       garantia_descnrga := TRIM(TO_CHAR(ROUND(garantia_vllimite,2),'999g999g990d00')) || ' CADASTRAL';
    END IF;*/
    --vr_string := vr_string || fn_tag('Valor do Limite',garantia_descnrga);
  
    -- 3.2 - Garantia - 
    vr_string_lm := vr_string_lm || fn_tag('Garantia', vr_garantia);
  
    -- 4: media de utilizacao - Garantia - Media. Neg. Esp. do mes
           vr_string_lm := vr_string_lm || fn_tag('Média Negativa de Utilização do Mês',TRIM(TO_CHAR(ROUND(garantia_vlsmnesp,2),'999g999g990d00')));
  
    vr_string_lm := vr_string_lm || '</campos></subcategoria>';
    --
    pr_dsxmlret := vr_string_lm;
    --
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_modalidade_lim_credito: '||sqlerrm;  
  end pc_modalidade_lim_credito;

  PROCEDURE pc_modalidade_car_cred(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                  ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                  
                                  ,pr_dsxmlret IN OUT CLOB) IS
  
    /* .............................................................................
    
      Programa: pc_modalidade_car_cred
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar o historico do cartao de credito dos ult. 3 meses.
    
      Alteracoes:
    ..............................................................................*/
  
    /*Busca os dados do cartão quando PF*/
    cursor c_busca_cartao is
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard, insitcrd, cdadmcrd, dtsol2vi
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       --and insitcrd IN (2,3,4,5)
       --and flgprcrd = 1
       and cdadmcrd <> 16
     order by progress_recid desc;
       /* P438 Sprint 17 - Adição do cartão BB*/
/*      union 
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard, insitcrd, cdadmcrd,dtsol2vi
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and insitcrd IN (4,5)
       and cdadmcrd >= 83 and cdadmcrd <= 88;*/
  
    /*Busca os dados do cartão quandi PJ (Busca primeiro cartão. Valores iguais / limite compartilhado) */
    cursor c_busca_cartao_pj is
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard, insitcrd ,cdadmcrd, dtsol2vi
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       --and insitcrd IN (2,3,4,5)
       and cdadmcrd <> 17
     order by progress_recid desc;
--       and rownum <=1;
  
    /*Busca se é PF ou PJ para saber qual cursor abrir*/
     cursor c_busca_tipo_pessoa is
       select c.inpessoa
       from crapass c
       where c.cdcooper = pr_cdcooper
       and   c.nrdconta = pr_nrdconta;
  
    /*Sprint 15 - US23823*/
    CURSOR cr_crdatraso (pr_cdcooper crapsnh.cdcooper%TYPE,
                         pr_nrdconta crapsnh.nrdconta%TYPE )IS
      SELECT * 
        FROM (SELECT atr.qtdias_atraso,
                     atr.vlsaldo_devedor
                FROM tbcrd_alerta_atraso atr
               WHERE atr.cdcooper = pr_cdcooper
                 AND atr.nrdconta = pr_nrdconta
                 ORDER BY atr.qtdias_atraso DESC, atr.vlsaldo_devedor DESC)
       WHERE rownum <= 1;        
       

    -- Removido pois será uma melhoria da próxima sprint   
    /*cursor c_busca_lancamentos (pr_nrcontrato in tbcrd_fatura.nrcontrato%type) is
    select round(sum(vlfatura) / count(1), 2) as media_cartao
     from (
       select * 
       from tbcrd_fatura
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and nrcontrato = pr_nrcontrato
       order by dtvencimento desc
     ) where rownum <= 3;*/
  

   vr_index number := 0;
    -- Removido pois será uma melhoria da próxima sprint   
    --flg_lancamento boolean := false;
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
    vr_inpessoa NUMBER;
    vr_qtdDiasAtrado NUMBER(5);
    vr_saldoDevedor NUMBER(25,2);
    vr_qtdiaatr INTEGER := 0;
    --
    vr_situacao VARCHAR2(20);
    vr_imp_dias_atraso boolean;

FUNCTION fn_retorna_situacao_cartao  (pr_insitcrd IN INTEGER,
                                      pr_dtsol2vi IN DATE,
                                      pr_cdadmcrd IN INTEGER) Return Varchar2 IS

  aux_dssitcrd varchar2(20);

BEGIN   
  IF (pr_insitcrd  = 4  AND 
      pr_dtsol2vi IS NOT NULL) OR
      pr_insitcrd  = 7  THEN 
      aux_dssitcrd:='Sol.2v';
  ELSIF pr_insitcrd = 0   THEN 
        aux_dssitcrd:='Estudo';
  ELSIF pr_insitcrd = 1   THEN 
        aux_dssitcrd:='Aprov.';
  ELSIF pr_insitcrd = 2   THEN 
        aux_dssitcrd:='Solic.';
  ELSIF pr_insitcrd = 3  THEN 
        aux_dssitcrd:='Liber.';
  ELSIF pr_insitcrd = 4 AND
        pr_cdadmcrd>= 83 AND pr_cdadmcrd <= 88 THEN 
        aux_dssitcrd:='Prc.BB';
  ELSIF pr_insitcrd = 4  THEN 
        aux_dssitcrd:='Em uso';
  ELSIF pr_insitcrd = 5  THEN
        IF (pr_cdadmcrd >=83 AND pr_cdadmcrd <= 88) OR 
           (pr_cdadmcrd >=10 AND pr_cdadmcrd <= 80) THEN 
           aux_dssitcrd:='Bloque';
        ELSE
           aux_dssitcrd:='Cancel';
        END IF;
  ELSIF pr_insitcrd = 6  THEN 
        IF pr_cdadmcrd >=10 AND pr_cdadmcrd <= 80  THEN 
           aux_dssitcrd:='Cancel';
        ELSE
           aux_dssitcrd:='Encer.';
        END IF;   
  ELSIF pr_insitcrd = 8  THEN 
        aux_dssitcrd:='Em Analise';
  ELSIF pr_insitcrd = 9  THEN 
        aux_dssitcrd:='Enviado Bancoob';
  ELSE 
        aux_dssitcrd:='??????';
  END IF;        

  RETURN aux_dssitcrd;

END;
  
  begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string || '<subcategoria>
                             <tituloTela>Rotativos Ativos - Modalidade Cartão de Crédito</tituloTela>
                             <campos>';
  
    vr_tab_tabela.delete;
  
    /*Busca o tipo de pessoa*/
    open c_busca_tipo_pessoa;
     fetch c_busca_tipo_pessoa into vr_inpessoa;
    close c_busca_tipo_pessoa;
    
    BEGIN
      vr_qtdiaatr := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 0,
                                               pr_cdacesso => 'QTD_DIAS_FAT_CRD_ATRASO');
    EXCEPTION
     WHEN OTHERS THEN
        vr_qtdiaatr := 0;
    END;
        
    --> Buscar alerta de atraso do cartao
    FOR rw_crdatraso IN cr_crdatraso( pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
      
      IF (rw_crdatraso.qtdias_atraso > 0) AND (rw_crdatraso.qtdias_atraso > vr_qtdiaatr) THEN
        vr_qtdDiasAtrado := rw_crdatraso.qtdias_atraso;
        vr_saldoDevedor  := rw_crdatraso.vlsaldo_devedor;
      END IF;
    END LOOP;    
    
    
    if (vr_inpessoa = 1) then
      vr_imp_dias_atraso := true;
      for r_cartao in c_busca_cartao loop
        
        if vr_index > 0 then
          vr_string := vr_string || '<campo><tipo>hr</tipo></campo>';
        end if;
      
        vr_string := vr_string || fn_tag('Cartão', to_char(r_cartao.nrcrcard, '9999g9999g9999g9999'));
        /* P438 Sprint 17 - Adição da coluna situação */
        vr_situacao:= fn_retorna_situacao_cartao (r_cartao.insitcrd
                                                 ,r_cartao.dtsol2vi 
                                                 ,r_cartao.cdadmcrd);
        vr_string := vr_string || fn_tag('Situação', vr_situacao);
        --
        vr_string := vr_string || fn_tag('Limite de Crédito', to_char(r_cartao.vllimcrd, '999g999g990d00'));
      
        -- Removido pois será uma melhoria da próxima sprint
        /*for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('Média das últimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('Média das últimas 3 faturas','-');
        end if;*/
      
        vr_string := vr_string || fn_tag('Dia Vencimento', to_char(r_cartao.dddebito));
        if vr_imp_dias_atraso then
          vr_imp_dias_atraso := false; -- Imprime somente no primeiro cartão
        vr_string := vr_string || fn_tag('Dias em atraso', to_char(vr_qtdDiasAtrado));  
          vr_string := vr_string || fn_tag('Valor do atraso', to_char(vr_saldoDevedor,'999g999g990d00')); 
        end if;  
        --vr_string := vr_string || fn_tag('Dia Vencimento 2ª Via', to_char(r_cartao.dddebant));
      
        vr_index := vr_index + 1;
      
      end loop;
    else
      vr_imp_dias_atraso := true;
      for r_cartao in c_busca_cartao_pj loop
      
        vr_string := vr_string || fn_tag('Cartão', to_char(r_cartao.nrcrcard, '9999g9999g9999g9999'));
        /* P438 Sprint 17 - Adição da coluna situação */
        vr_situacao:= fn_retorna_situacao_cartao (r_cartao.insitcrd
                                                 ,r_cartao.dtsol2vi 
                                                 ,r_cartao.cdadmcrd);
        vr_string := vr_string || fn_tag('Situação', vr_situacao);
        --        
        vr_string := vr_string || fn_tag('Limite de Crédito', to_char(r_cartao.vllimcrd, '999g999g990d00'));
      
        -- Removido pois será uma melhoria da próxima sprint
        /*for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('Média das últimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('Média das últimas 3 faturas','-');
        end if;*/
      
        vr_string := vr_string || fn_tag('Dia Vencimento', to_char(r_cartao.dddebito));
        if vr_imp_dias_atraso then
          vr_imp_dias_atraso := false; -- Imprime somente no primeiro cartão
          vr_string := vr_string || fn_tag('Dias em atraso', to_char(vr_qtdDiasAtrado));  
          vr_string := vr_string || fn_tag('Valor do atraso', to_char(vr_saldoDevedor,'999g999g990d00')); 
        end if;  
        --vr_string := vr_string || fn_tag('Dia Vencimento 2ª Via', to_char(r_cartao.dddebant));
      
        vr_index := vr_index + 1;
      
      end loop;
      
    end if;
    /*Se não encontrou dados, monta uma categoria vazia bug 20672*/
    if (vr_index = 0) then
      vr_string := vr_string || fn_tag('Cartão', '-');
      vr_string := vr_string || fn_tag('Situação','-');
      vr_string := vr_string || fn_tag('Limite de Crédito', '-');
      --vr_string := vr_string || fn_tag('Média das últimas 3 faturas', '-');
      vr_string := vr_string || fn_tag('Dia Vencimento', '-');
      vr_string := vr_string || fn_tag('Dias em atraso', '-');
      vr_string := vr_string || fn_tag('Valor do atraso', '-');
    end if;
  
    vr_string := vr_string || '</campos></subcategoria>';
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_modalidade_car_cred: '||sqlerrm; 
  end pc_modalidade_car_cred; 
    

  PROCEDURE pc_consulta_bordero(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB ) IS
    
  
  
    /* .............................................................................
    
      Programa: pc_consulta_bordero
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao: 29/04/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar 4 ultimos borderos liquidados.
    
      Alteracoes:
    ..............................................................................*/
  
    vr_dt_aux_dtmvtolt DATE;
    vr_dt_aux_dtlibbdt DATE;
  
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
      SELECT DTMVTOLT,
             NRDCONTA,
             NRCTRLIM,
             INSITBDT,
             DTLIBBDT,
             NRBORDER,
             CDCOOPER,
             INSITAPR,
       null DTULTPAG,
       null DTLIQPRJ,
             
       CASE INSITBDT WHEN 1 THEN 'EM ESTUDO'
                         WHEN 2 THEN 'ANALISADO'
                         WHEN 3 THEN 'LIBERADO'
                         WHEN 4 THEN 'LIQUIDADO'
                         WHEN 5 THEN 'REJEITADO'
                         ELSE        'PROBLEMA'
             END DSSITBDT,
             COUNT(1) over() qtregistro,
       CASE INSITAPR WHEN 0 THEN 'AGUARDANDO ANALISE'
                         WHEN 1 THEN 'AGUARDANDO CHECAGEM'
                         WHEN 2 THEN 'CHECAGEM'
                         WHEN 3 THEN 'APROVADO AUTOMATICAMENTE'
                         WHEN 4 THEN 'APROVADO'
                         WHEN 5 THEN 'NÃO APROVADO'
                         WHEN 6 THEN 'ENVIADO ESTEIRA'
                         WHEN 7 THEN 'PRAZO EXPIRADO'
                         ELSE        'PROBLEMA'
             END DSINSITAPR,
             1 INPREJUZ
      
  from (select * FROM CRAPBDT BDT
       WHERE
       BDT.CDCOOPER = pr_cdcooper
                 AND BDT.NRDCONTA = pr_nrdconta
       and BDT.INSITBDT = 4
               ORDER BY DTLIBBDT DESC) t
  where rownum <= 4;
  
  
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
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    vr_string := vr_string || '<subcategoria>
                          <tituloTela>Últimas 4 Operações Liquidadas - Borderôs de Desconto de Títulos</tituloTela>
                        <campos>
                        <campo>
                                 <nome>Últimos Borderôs Liquidados</nome>
                                 <tipo>table</tipo>
                        <valor>
                         <linhas>';
  
    vr_tab_tabela.delete;
  
    vr_dt_aux_dtmvtolt := trunc(rw_crapdat.dtmvtolt) - 120;
    vr_dt_aux_dtlibbdt := trunc(rw_crapdat.dtmvtolt) - 60;
  
    -- abrindo cursos de títulos
    OPEN cr_crapbdt;
    LOOP
               FETCH cr_crapbdt INTO rw_crapbdt;
      EXIT WHEN cr_crapbdt%NOTFOUND;
    
      vr_idxbordero := vr_tab_tabela.count + 1;
    
      IF (rw_crapbdt.dtmvtolt <= vr_dt_aux_dtmvtolt AND (rw_crapbdt.insitbdt IN (1, 2))) THEN
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
      
        IF (rw_craptdb.insitapr = 1) THEN
          vr_qt_apr := vr_qt_apr + 1;
          vr_vl_apr := vr_vl_apr + rw_craptdb.vltitulo;
        END IF;
      
      END LOOP;
    

      vr_tab_tabela(vr_idxbordero).coluna1 := to_char(rw_crapbdt.dtmvtolt, 'DD/MM/YYYY');
      vr_tab_tabela(vr_idxbordero).coluna2 := to_char(rw_crapbdt.nrborder);
      -- vr_tab_tabela(vr_idxbordero).coluna3 := rw_crapbdt.nrdconta;
      vr_tab_tabela(vr_idxbordero).coluna3 := to_char(rw_crapbdt.nrctrlim);
      vr_tab_tabela(vr_idxbordero).coluna4 := to_char(vr_qt_titulo);
      vr_tab_tabela(vr_idxbordero).coluna5 := to_char(vr_vl_titulo, '999g999g990d00');
      vr_tab_tabela(vr_idxbordero).coluna6 := to_char(vr_qt_apr);
      vr_tab_tabela(vr_idxbordero).coluna7 := to_char(vr_vl_apr, '999g999g990d00');
      vr_tab_tabela(vr_idxbordero).coluna8 := to_char(rw_crapbdt.dssitbdt);
      vr_tab_tabela(vr_idxbordero).coluna9 := to_char(rw_crapbdt.dtlibbdt, 'DD/MM/YYYY');
      --  vr_tab_tabela(vr_idxbordero).coluna11 :=  rw_crapbdt.dsinsitapr;
      --  vr_tab_tabela(vr_idxbordero).coluna12   :=  rw_crapbdt.inprejuz;
    
    END LOOP;
    CLOSE cr_crapbdt;
  
        
    if vr_tab_tabela.count > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Data Proposta;Bôrdero;Contrato;Quantidade de Títulos;Valor;Quantidade Aprovado;Valor Aprovado;Situação;Data Liberação',vr_tab_tabela);
    
  else
    
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-';
      vr_tab_tabela(1).coluna8 := '-';
      vr_tab_tabela(1).coluna9 := '-';
    
    vr_string := vr_string||fn_tag_table('Data Proposta;Bôrdero;Contrato;Quantidade de Títulos;Valor;Quantidade Aprovado;Valor Aprovado;Situação;Data Liberação',vr_tab_tabela);
    
  end if;
  
    vr_string := vr_string || '</linhas>
                            </valor>
                            </campo>
                            </campos></subcategoria>';
  
                
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  
    exception
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_bordero: '||sqlerrm;          
  END pc_consulta_bordero;

procedure pc_busca_media_titulo(pr_cdcooper IN crapass.cdcooper%TYPE 
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_out_media_tit out varchar2
                               ,pr_out_liquidez out varchar2) is
  
    /* .............................................................................
    
      Programa: pc_busca_media_titulo
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Recupera a media dos ultimos 6 meses para desconto de titulo/bordero.
    
      Alteracoes: 30/05/2019 - Apresentar simbolo de % na tela unica para o campo Liquidez.
                               Bug 22071 - PRJ438 - Gabriel Marcos (Mouts).
                               
    ..............................................................................*/
  
      cursor c1 is
      select tit.vltitulo, -- valor
             tit.insitapr, -- 1 aprovado
             bdt.insitbdt -- 4 Liquidado
        from crapbdt bdt,
             craptdb tit
       where bdt.cdcooper = pr_cdcooper
         and bdt.nrdconta = pr_nrdconta
         and bdt.insitapr in (3,4) -- Aprovados e Aprovados Automativamente
         and bdt.dtlibbdt between TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM') -- Primeiro dia de 6 meses atrás
                                  and rw_crapdat.dtmvtolt
         and bdt.cdcooper = tit.cdcooper -- Bug 22097  -- Paulo
         and bdt.nrdconta = tit.nrdconta -- Bug 22097                                    
         and bdt.nrborder = tit.nrborder
       order by bdt.nrborder desc;     
     
     r1 c1%rowtype;
  
  
    pr_tab_borderos TELA_ATENDA_DSCTO_TIT.typ_tab_borderos;
    pr_cdcritic     PLS_INTEGER;
     pr_dscritic varchar2(4000);
    pr_qtregist     INTEGER;
  
     wrk_valor number(25,2) := 0;
     wrk_qtd_tit_liquidado pls_integer := 0;
     wrk_qtd_tit_total pls_integer := 0;
     wrk_liquidez number(25,2) := 0;
     wrk_qtd_geral number;
     vr_inpessoa crapass.inpessoa%type;
  
    vr_tab_dados_dsctit  dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobrança Registrada
    vr_tab_cecred_dsctit dsct0002.typ_tab_cecred_dsctit;
  
   begin
  
    --Busca inpessoa
      select inpessoa 
        into vr_inpessoa
        from crapass a
       where a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta;
      
  
    -- Busca os Parâmetros para o Cooperado e Cobrança Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                          NULL, --Agencia de operação
                                          NULL, --Número do caixa
                                          NULL, --Operador
                                          NULL, -- Data da Movimentação
                                          NULL, --Identificação de origem
                                          1, --pr_tpcobran: 1-REGISTRADA / 0-NÃO REGISTRADA
                                          vr_inpessoa, --1-PESSOA FÍSICA / 2-PESSOA JURÍDICA
                                          vr_tab_dados_dsctit,
                                          vr_tab_cecred_dsctit,
                                          vr_cdcritic,
                                          vr_dscritic);
  
    -- Faz os calculos de liquidez
      DSCT0003.pc_retorna_liquidez_geral(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_dtmvtolt_de =>  TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM')
                                        ,pr_dtmvtolt_ate => rw_crapdat.dtmvtolt
                                        ,pr_qtcarpag => vr_tab_dados_dsctit(1).cardbtit_c
                                        ,pr_qtmitdcl => vr_tab_dados_dsctit(1).qtmitdcl
                                        ,pr_vlmintcl => vr_tab_dados_dsctit(1).vlmintcl
                                       -- OUT --
                                        ,pr_pc_geral     => wrk_liquidez
                                        ,pr_qtd_geral    => wrk_qtd_geral);                                          
     
  
    wrk_qtd_tit_total := 0;
  
      for r1 in c1 loop
    
      wrk_valor         := wrk_valor + r1.vltitulo;
      wrk_qtd_tit_total := wrk_qtd_tit_total + 1;
    
      end loop;
  
     begin
      wrk_valor := (wrk_valor / wrk_qtd_tit_total); -- Média Calculada com base no total de títulos aprovador- Paulo
     exception when zero_divide then
        wrk_valor := 0;
     end;
  
    pr_out_media_tit := to_char(wrk_valor, '999g999g990d00');
     pr_out_liquidez  := case when wrk_liquidez > 0 then to_char(round(wrk_liquidez,2))||'%' end;
  
   end pc_busca_media_titulo;

  PROCEDURE pc_consulta_desc_titulo(pr_cdcooper IN crapass.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                      ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                      ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                      
                                      ,pr_dsxmlret IN OUT CLOB ) IS
                               
  
    /* .............................................................................
    
      Programa: pc_consulta_desc_titulo
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao: 29/04/2019
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar descontos de titulo.
    
      Alteracoes:
    ..............................................................................*/
  
    wrk_tab_dados_limite TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite;
    wrk_cdcritica        PLS_INTEGER;
    wrk_dscerro          VARCHAR2(4000);
  
    /*Recupera a garantia do desconto de título*/
    --bug 20410
    CURSOR c_busca_garantia_desctit IS
     select g.dsseqite
     from craprad g,
          crawlim l,
          crapass a
     where l.cdcooper = g.cdcooper
     and   l.nrgarope = g.nrseqite 
     and   l.cdcooper = a.cdcooper
     and   l.nrdconta = a.nrdconta
     and   l.nrdconta = pr_nrdconta
     and   l.nrctrlim = wrk_tab_dados_limite(0).nrctrlim
     and   l.cdcooper = pr_cdcooper
     and   g.nritetop = 2
     and   g.nrtopico = case when a.inpessoa = 1 then 2 else 4 end;
  
     CURSOR c_avalistas(pr_nrctrlim in number) is
      SELECT l.nrctaav1, l.nrctaav2
        FROM craplim l
       WHERE l.cdcooper = pr_cdcooper
         AND l.nrdconta = pr_nrdconta
         AND l.nrctrlim = pr_nrctrlim;
    --
      r_avalistas c_avalistas%rowtype;
  
    -- variaveis
    vr_string   CLOB;
    vr_dsxmlret CLOB;
    vr_dstexto  CLOB;
   vr_med_tit varchar2(255);
   vr_liquidez varchar2(255);
    vr_dsseqite CRAPRAD.DSSEQITE%TYPE;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    vr_string := vr_string || '<subcategoria>
                              <tituloTela>Rotativos Ativos - Modalidade Desconto de Título</tituloTela>
                            <campos>';
  
    vr_tab_tabela.delete;
  
     TELA_ATENDA_DSCTO_TIT.pc_busca_dados_limite(pr_nrdconta => pr_nrdconta
                                     ,pr_cdcooper => pr_cdcooper
                                     ,pr_tpctrlim => 3 -- Desconto Titulo
                                     ,pr_insitlim => 2 -- Ativos
                                     ,pr_dtmvtolt => null
                                                --------> OUT <--------
                                     ,pr_tab_dados_limite => wrk_tab_dados_limite
                                     ,pr_cdcritic => wrk_cdcritica
                                     ,pr_dscritic => wrk_dscerro
                                     );
  
   if wrk_tab_dados_limite.count > 0 then     
    
      pc_busca_media_titulo(pr_cdcooper, pr_nrdconta, vr_med_tit, vr_liquidez);
      vr_garantia := '-';
    
     open c_avalistas(wrk_tab_dados_limite(0).nrctrlim);
      fetch c_avalistas into r_avalistas;
     close c_avalistas;
      vr_garantia := '-';
      vr_garantia := fn_garantia_proposta(pr_cdcooper, pr_nrdconta, wrk_tab_dados_limite(0).nrctrlim, r_avalistas.nrctaav1, r_avalistas.nrctaav2, 'O', c_desconto_titulo, FALSE);
    
      vr_string := vr_string || fn_tag('Limite', to_char(wrk_tab_dados_limite(0).vllimite, '999g999g990d00'));
      vr_string := vr_string || fn_tag('Saldo Utilizado', to_char(wrk_tab_dados_limite(0).vlutiliz, '999g999g990d00'));
      vr_string := vr_string || fn_tag('Garantia', vr_garantia); --bug 20410
      vr_string := vr_string || fn_tag('Média de Desconto do Semestre', vr_med_tit);
      vr_string := vr_string || fn_tag('Liquidez', vr_liquidez);
    
    else
    
      vr_string := vr_string || fn_tag('Limite', '-');
      vr_string := vr_string || fn_tag('Saldo Utilizado', '-');
      vr_string := vr_string || fn_tag('Garantia', '-');
      vr_string := vr_string || fn_tag('Média de Desconto do Semestre', '-');
      vr_string := vr_string || fn_tag('Liquidez', '-');
    
    end if;
  
    vr_string := vr_string || ' </campos></subcategoria>';
  
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro pc_consulta_desc_titulo: '||sqlerrm;         
   end pc_consulta_desc_titulo; 

   PROCEDURE pc_consulta_lanc_futuro (pr_cdcooper IN crapass.cdcooper%TYPE 
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                     
                                     ,pr_dsxmlret IN OUT CLOB ) IS
  
    /* .............................................................................
    
      Programa: pc_consulta_lanc_futuro
      Sistema : Aimaro/Ibratan
      Autor   : Leonardo Zippert - Mout's 
      Data    : Março/2019                 Ultima atualizacao:
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
    
      Objetivo  : Rotina para recuperar lancamentos futuros da conta.
    
      Alteracoes:
    ..............................................................................*/
  
         
    -- variaveis     
     wrk_date_ini date;
     wrk_date_fim date;
    vr_string    CLOB;
    vr_dsxmlret  CLOB;
    vr_dstexto   CLOB;
     vr_index pls_integer;
  
     wrk_tab_erro varchar2(4000);
    wrk_tab_erros   GENE0001.typ_tab_erro;
    wrk_totais      EXTR0002.typ_tab_totais_futuros;
    wrk_lancamentos EXTR0002.typ_tab_lancamento_futuro;
  
    wrk_menor_data   DATE := to_date('31/12/9999', 'DD/MM/YYYY');
    wrk_data_compara DATE;
     wrk_index_order number;
     vr_index2 number := 1;
     wrk_saida boolean := false;
     wrk_total number;
    vr_total_valor   NUMBER := 0; --STORY 22155
  
   begin
  
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string || '<subcategoria>
                              <tituloTela>Lançamentos Futuros</tituloTela>
                            <campos>
                            <campo>
                               <nome>Informações de Lançamentos Futuros</nome>
                               <tipo>table</tipo>
                               <valor>
                             <linhas>';
  
    wrk_date_ini := TRUNC(rw_crapdat.dtmvtolt, 'MONTH'); -- Recebe primeiro dia do mes corrente
  
    -- Se hoje for dia 01 entao so trago os lancamentos do mes atual
    -- Senao retorno o mes atual e o mes seguinte...
    /*Mostrar o mês atual e o todo o mês seguinte: Descrição e valor 
    (Quando o mês atual for dia 01 não será necessário mostrar o mês seguinte)*/
     if wrk_date_ini = trunc(rw_crapdat.dtmvtolt) then
      wrk_date_fim := trunc(LAST_DAY(rw_crapdat.dtmvtolt));
     else
      wrk_date_fim := trunc(LAST_DAY(ADD_MONTHS(rw_crapdat.dtmvtolt, 1)));
     end if;
    wrk_lancamentos.delete;
    EXTR0002.pc_consulta_lancamento(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                     ,pr_cdagenci => 9999              --Codigo Agencia
                                     ,pr_nrdcaixa => 1                            --Numero do Caixa
                                     ,pr_cdoperad => 1                           --Codigo Operador
                                     ,pr_nrdconta => pr_nrdconta              --Numero da Conta do Associado
                                     ,pr_idorigem => 1                            --Origem dos Dados
                                     ,pr_idseqttl => 1                            --Sequencial do Titular
                                     ,pr_nmdatela => 'TELA_ANALISE_CREDITO'                           --Nome da Tela
                                     ,pr_flgerlog => false                            --Imprimir log
                                     ,pr_dtiniper => wrk_date_ini--trunc(sysdate)                               -- Data inicio
                                     ,pr_dtfimper => wrk_date_fim --trunc(sysdate)                               -- Data final
                                     ,pr_indebcre => null--'D'              -- Debito/Credito
                                     ,pr_des_reto => wrk_tab_erro                          --Retorno OK ou NOK
                                     ,pr_tab_erro => wrk_tab_erros             --Tabela Retorno Erro
                                     ,pr_tab_totais_futuros => wrk_totais  --Vetor para o retorno das informações
                                   , pr_tab_lancamento_futuro => wrk_lancamentos);
  
     
     
    vr_index := 1;
    vr_tab_tabela.delete;
    vr_tab_tabela_secundaria.delete;
  
     if wrk_lancamentos.count > 0 then
     for vr_index in wrk_lancamentos.first .. wrk_lancamentos.last loop
      
        vr_tab_tabela(vr_index).coluna1 := to_char(wrk_lancamentos(vr_index).dtmvtolt, 'DD/MM/YYYY');
        vr_tab_tabela(vr_index).coluna2 := wrk_lancamentos(vr_index).dshistor;
        vr_tab_tabela(vr_index).coluna3 := wrk_lancamentos(vr_index).nrdocmto;
        vr_tab_tabela(vr_index).coluna4 := wrk_lancamentos(vr_index).indebcre;
       vr_tab_tabela(vr_index).coluna5 := trim(to_char(wrk_lancamentos(vr_index).vllanmto,'999g999g990d00'));
        /*Acumula o valor total*/
        vr_total_valor := vr_total_valor + NVL(wrk_lancamentos(vr_index).vllanmto, 0);
      
     end loop;
    
   end if;
  
    /*ordenar o vetor acima por data. bug 21251*/
    wrk_total := wrk_lancamentos.count;
     if (wrk_lancamentos.count > 0) then
       while not wrk_saida loop
      
        /*Testa se o registro foi excluido, se foi pula*/
         if vr_index <= wrk_total then
           begin
            wrk_data_compara := wrk_lancamentos(vr_index).dtmvtolt;
          
            /*Compara todas as datas para achar o menor elemento*/
             if ( wrk_data_compara <= wrk_menor_data ) then
              wrk_menor_data  := wrk_data_compara;
              wrk_index_order := vr_index; --grava o index da menor data
             end if;
          
           exception
             when others then
               if (vr_index < wrk_total) then
                vr_index := vr_index + 1;
                 continue;
               end if;
           end;
         end if;

      
        /*Quando chegar no fim*/
       if (vr_index = wrk_total) then
        
          /*Grava tabela ordenada*/
         vr_tab_tabela_secundaria(vr_index2).coluna1 := to_char(wrk_lancamentos(wrk_index_order).dtmvtolt,'DD/MM/YYYY');
          vr_tab_tabela_secundaria(vr_index2).coluna2 := wrk_lancamentos(wrk_index_order).dshistor;
          vr_tab_tabela_secundaria(vr_index2).coluna3 := wrk_lancamentos(wrk_index_order).nrdocmto;
          vr_tab_tabela_secundaria(vr_index2).coluna4 := wrk_lancamentos(wrk_index_order).indebcre;
         vr_tab_tabela_secundaria(vr_index2).coluna5 := trim(to_char(wrk_lancamentos(wrk_index_order).vllanmto,'999g999g990d00'));
        
          /*Exclui registro já armazenado*/
          wrk_lancamentos.delete(wrk_index_order);
        
          /*Volta o indice para começar tudo denovo*/
          vr_index := 0;
        
          /*Incremente indice nova tabela*/
          vr_index2 := vr_index2 + 1;
        
          wrk_menor_data := to_date('31/12/9999', 'DD/MM/YYYY');
        
       end if;
      
        /*Condição de saída*/
       if (wrk_lancamentos.count = 0 OR vr_index > wrk_total) then
         wrk_saida := true;
       end if;
      
        vr_index := vr_index + 1;
      
       end loop;
     end if;
  
    -- Colocar a linha de Totais
    IF vr_tab_tabela_secundaria.COUNT() >= 1 THEN
      vr_index := vr_tab_tabela_secundaria.COUNT() + 1;
      vr_tab_tabela_secundaria(vr_index).coluna1 := 'Total';
      vr_tab_tabela_secundaria(vr_index).coluna2 := '-';
      vr_tab_tabela_secundaria(vr_index).coluna3 := '-';
      vr_tab_tabela_secundaria(vr_index).coluna4 := '-';
        vr_tab_tabela_secundaria(vr_index).coluna5 := case when vr_total_valor > 0 then
                                              to_char(vr_total_valor,'999g999g990d00') else '-' end;
    
    END IF;
  
     
    if vr_tab_tabela_secundaria.count > 0 then
      /*Gera Tags Xml*/
      vr_string := vr_string || fn_tag_table('Data Débito;Histórico;Documento;D/C;Valor', vr_tab_tabela_secundaria);
    
    else
    
      vr_tab_tabela_secundaria(1).coluna1 := '-';
      vr_tab_tabela_secundaria(1).coluna2 := '-';
      vr_tab_tabela_secundaria(1).coluna3 := '-';
      vr_tab_tabela_secundaria(1).coluna4 := '-';
      vr_tab_tabela_secundaria(1).coluna5 := '-';
    
      vr_string := vr_string || fn_tag_table('Data Débito;Histórico;Documento;D/C;Valor', vr_tab_tabela_secundaria);
    
    end if;
  
    vr_string := vr_string || '</linhas>
                              </valor>
                              </campo>
                              </campos></subcategoria>';
  
                  
    
    -- Encerrar a tag raiz
      pc_escreve_xml(pr_xml => vr_dsxmlret,
                    pr_texto_completo => vr_dstexto,
                    pr_texto_novo => vr_string,
                   pr_fecha_xml => TRUE);
  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
   exception      
   when others then
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      pr_cdcritic := 0;
    pr_dscritic := substr('Erro pc_consulta_lanc_futuro: '||sqlerrm,1,250);      
   end pc_consulta_lanc_futuro;    
   
  PROCEDURE pc_insere_analise_cred_acessos(pr_cdcooper        IN NUMBER,
                                           pr_nrdconta        IN NUMBER,
                                           pr_cdoperador      IN varchar2,
                                           pr_nrcontrato      IN NUMBER,
                                           pr_tpproduto       IN NUMBER,
                                           pr_dhinicio_acesso IN VARCHAR2,
                                           pr_dhfim_acesso    IN VARCHAR2,
                                           pr_idanalise_contrato_acesso IN NUMBER,
                                           pr_xmllog    IN VARCHAR2,           
                                           pr_cdcritic OUT PLS_INTEGER,        
                                           pr_dscritic OUT VARCHAR2,           
                                           pr_retxml    IN OUT NOCOPY xmltype, 
                                           pr_nmdcampo OUT VARCHAR2,           
                                           pr_des_erro OUT VARCHAR2) IS       
    /* ..........................................................................
    
     Autor   : Rafael Ferreira
     Data    : 14/06/2019
    
     Dados referentes ao programa:
    
     Objetivo  : Inserir registros na tabela de Controle de acessos da Tela Única. Pj 438.
                 Se o PHP não passar o parametro pr_idanalise_contrato_acesso entende-se que é 
                 um registro novo, nesse caso faz insert e retorna neste mesmo parametro o id de 
                 acesso gerado.
                 Se o parametro pr_idanalise_contrato_acesso tiver valor na chamada da procedure,
                 entende-se que é um registro existente, então só é feito update na hora final de acesso.
    
     Alteracoes: 
           
    ..........................................................................*/

    v_idanalise_contrato cecred.tbgen_analise_credito.idanalise_contrato%TYPE;
    v_idanalise_contrato_acesso cecred.tbgen_analise_credito.idanalise_contrato%TYPE;

    exp_contrato_nao_encontrado EXCEPTION;
  BEGIN

    -- Busca o idanalise_contrato
    BEGIN
      SELECT MAX(cred.idanalise_contrato)
        INTO v_idanalise_contrato
        FROM cecred.tbgen_analise_credito cred
       WHERE cred.cdcooper = pr_cdcooper
         AND cred.nrdconta = pr_nrdconta
         AND cred.nrcontrato = pr_nrcontrato
         AND cred.tpproduto = pr_tpproduto;
    EXCEPTION
      WHEN others THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
        dbms_output.put_line(SQLERRM);
        RAISE exp_contrato_nao_encontrado;
    END;

    IF pr_idanalise_contrato_acesso IS NOT NULL THEN
    
      BEGIN
        UPDATE CECRED.tbgen_analise_credito_acessos
           SET DHFIM_ACESSO = to_date(pr_dhfim_acesso, 'DD/MM/YYYY HH24:mi:ss')
         WHERE idanalise_contrato_acesso = pr_idanalise_contrato_acesso;
         
         v_idanalise_contrato_acesso := pr_idanalise_contrato_acesso;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
          dbms_output.put_line(SQLERRM);
      END;
    
    ELSE
    
      BEGIN
        INSERT INTO CECRED.tbgen_analise_credito_acessos
          (IDANALISE_CONTRATO, CDCOOPER, CDOPERAD, DHINICIO_ACESSO, DHFIM_ACESSO)
        VALUES
          (v_idanalise_contrato, pr_cdcooper, pr_cdoperador, to_date(pr_dhinicio_acesso,'DD/MM/YYYY HH24:mi:ss'), to_date(pr_dhfim_acesso, 'DD/MM/YYYY HH24:mi:ss'))
        RETURNING idanalise_contrato_acesso INTO v_idanalise_contrato_acesso;
      
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
          dbms_output.put_line(SQLERRM);
          RAISE exp_contrato_nao_encontrado;
      END;
    
    END IF;
    
    commit;
    
    
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'idanalise_contrato_acesso',pr_tag_cont => v_idanalise_contrato_acesso,pr_des_erro => vr_dscritic); 
    
    /*Exception Geral*/
  EXCEPTION
    WHEN exp_contrato_nao_encontrado THEN
      pr_dscritic := 'Erro Contrato Não encontrado na TELA_ANALISE_CREDITO.pc_insere_analise_cred_acessos : ' || SQLERRM;
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      --cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);
      WHEN OTHERS THEN
        cecred.pc_internal_exception(pr_cdcooper => vr_cdcooper_principal, pr_compleme => vr_parametros_principal);

        --pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na TELA_ANALISE_CREDITO.pc_insere_analise_cred_acessos : ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_insere_analise_cred_acessos;


end TELA_ANALISE_CREDITO;
/
