create or replace package cecred.TELA_ANALISE_CREDITO is

/* Tabelas para armazenar os retornos dos birôs, titulos e detalhes*/

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
);
TYPE typ_tab_dados_detalhe IS TABLE OF typ_reg_dados_detalhe INDEX BY BINARY_INTEGER;
  
/*Tabela de retorno dos dados obtidos para as criticas*/
TYPE typ_reg_dados_critica IS RECORD(
     dsc                   VARCHAR2(225),
     vlr               VARCHAR(225) -- numero
);

TYPE typ_tab_dados_critica IS TABLE OF typ_reg_dados_critica INDEX BY BINARY_INTEGER;  

  --TempTable para retornar valores para tela Atenda (Antigo b1wgen0001tt.i/tt-valores_conta)
  TYPE typ_rec_valores_conta
    IS RECORD ( vlsldcap NUMBER(32,8),
                vlsldepr NUMBER(32,8),
                vlsldapl NUMBER(32,8),
                vlsldinv NUMBER(32,8),
                vlsldppr NUMBER(32,8),
                vlstotal NUMBER(32,8),
                vllimite NUMBER(32,8),
                qtfolhas NUMBER(32,8),
                qtconven NUMBER(32,8),
                flgocorr INTEGER,
                dssitura VARCHAR2(100),
                vllautom NUMBER(32,8),
                dssitnet VARCHAR2(100),
                vltotpre NUMBER(32,8),
                vltotccr NUMBER(32,8),
                qtcarmag INTEGER,
                qttotseg NUMBER(18),
                vltotseg NUMBER(32,8),
                vltotdsc NUMBER(32,8),
                flgbloqt INTEGER,
                vllimite_saque tbtaa_limite_saque.vllimite_saque%TYPE,
                pacote_tarifa BOOLEAN,
                vldevolver NUMBER(32,8),
                insituacprvd tbprevidencia_conta.insituac%TYPE,
                idportab NUMBER,
                insitapi NUMBER);
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

  
  /* Utilizado para carregar os dados da atenda para ser reutilizados */
  vr_tab_cabec             CADA0004.typ_tab_cabec;
  vr_tab_comp_cabec        CADA0004.typ_tab_comp_cabec;     
  vr_tab_valores_conta     CADA0004.typ_tab_valores_conta; 
  vr_tab_crapobs           CADA0004.typ_tab_crapobs;
  vr_tab_mensagens_atenda  CADA0004.typ_tab_mensagens_atenda; 
  
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

FUNCTION fn_tag(pr_nome in varchar2,
                pr_valor in varchar2)  return varchar2;

FUNCTION fn_zeroToNull(p_valor in number) return varchar2;

function fn_le_json_motor(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in number) return varchar2;
                          
function fn_le_json_motor_auto_aprov(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in number) return clob;

                          
function fn_getNivelRisco(p_nivelRisco in number) return varchar2;

PROCEDURE pc_consulta_consultas(pr_cdcooper IN crapass.cdcooper%TYPE  --> Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                           ,pr_nrcontrato IN crawepr.nrctremp%TYPE       --> Nr contrato
                           ,pr_inpessoa  IN crapass.inpessoa%TYPE
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                           ,pr_dsxmlret OUT CLOB);   

PROCEDURE pc_gera_token_ibratan(pr_cdcooper IN crapope.cdcooper%TYPE, --> cooperativa
                                  pr_cdagenci IN crapope.cdagenci%TYPE, --> Agencia
                                  pr_cdoperad IN crapope.cdoperad%TYPE, --> Operador
                                  pr_dstoken  OUT VARCHAR2, --> Token
                                  pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                  pr_dscritic OUT VARCHAR2     --> Descrição da crítica
                                 );

PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                         ,pr_tpproduto IN number                      --> Produto
                                         ,pr_nrcontrato IN crawepr.nrctremp%TYPE      --> Número contrato emprestimo
                                         ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_job_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                      ,pr_tpproduto IN number                      --> Produto
                                      ,pr_nrctremp  IN crawepr.nrctremp%TYPE       --> Número contrato emprestimo
                                      ,pr_dscritic OUT VARCHAR2);                  --> Descricao da critica

PROCEDURE pc_gera_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number);

PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number                      --> Número contrato
                                       ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                                       ,pr_dsxmlret IN OUT NOCOPY xmltype);

  PROCEDURE pc_consulta_cadastro_pf(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE --> IDPESSOA
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_cadastro_pj(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB);

        --> Arquivo de retorno do XML

  PROCEDURE pc_consulta_garantia(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_nrctrato IN crawepr.nrctremp%TYPE       --> Contrato
                                ,pr_tpproduto IN NUMBER                     --> Tipo de Produto
                                ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                ,pr_dsxmlret IN OUT CLOB);

  PROCEDURE pc_consulta_scr(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                           ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                           ,pr_persona  IN Varchar2
                           ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                           ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                           ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_scr2(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                            ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                            ,pr_dsxmlret OUT varchar2);                           

  PROCEDURE pc_consulta_operacoes(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                                 ,pr_nrctrato  in crawepr.nrctremp%type
                                 ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB);

  PROCEDURE pc_consulta_proposta_epr(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                    ,pr_nrctrato  IN number
                                    ,pr_inpessoa  IN crapass.inpessoa%TYPE                                    
                                    ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                    ,pr_dsxmlret  OUT CLOB);
                                    
PROCEDURE pc_consulta_proposta_limite(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                     ,pr_dsxmlret IN OUT CLOB);                                    

/*Propostas para Cartão de Crédito*/
PROCEDURE pc_consulta_proposta_cc(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                 ,pr_nrctrato  IN number
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret  OUT CLOB);

PROCEDURE pc_consulta_proposta_bordero (pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                         ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                         ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                         ,pr_dsxmlret IN OUT CLOB);

PROCEDURE pc_consulta_outras_pro_epr(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
                           
   PROCEDURE pc_consulta_hist_cartaocredito(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                           ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                           ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                           ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                              
                                           ,pr_dsxmlret IN OUT CLOB);
   
   PROCEDURE pc_consulta_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB);                          
   
   PROCEDURE pc_consulta_lim_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB);
                                
   procedure pc_consulta_lim_desc_tit(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB); 
                                
   PROCEDURE pc_consulta_lim_cred(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB);                            
    
  
  PROCEDURE pc_modalidade_lim_credito(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB);                                                           
    
   PROCEDURE pc_modalidade_car_cred(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                      
                                   ,pr_dsxmlret IN OUT CLOB);
                                
   PROCEDURE pc_consulta_bordero (pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                 ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                    
                                 ,pr_dsxmlret IN OUT CLOB );

   PROCEDURE pc_busca_rendas_aut(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE
                                ,pr_xmlRenda OUT VARCHAR2);   

   PROCEDURE pc_consulta_desc_titulo (pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB );                            

   PROCEDURE pc_consulta_lanc_futuro (pr_cdcooper IN crapass.cdcooper%TYPE 
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica                                        
                                     ,pr_dsxmlret IN OUT CLOB ); 

/*Para buscar as críticas do borderô*/                               
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                  ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                  ,pr_qtregist           out integer                --> Qtde total de registros
                                  ,pr_tab_dados_titulos  out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                  ,pr_dscritic           out varchar2               --> Descricao da critica
                                  );
                                 
/*Para buscar as críticas do borderô*/
PROCEDURE pc_listar_titulos_resumo_web (pr_cdcooper           in crapcop.cdcooper%TYPE
                                       ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                       ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                       --------> OUT <--------
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );

procedure pc_detalhes_tit_bordero_web (pr_cdcooper    IN crapcop.cdcooper%TYPE
                                      ,pr_nrdconta    in crapass.nrdconta%type --> conta do associado
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


end TELA_ANALISE_CREDITO;
/
create or replace package body cecred.TELA_ANALISE_CREDITO is

  ------- --------------------------------------------------------------------
  --
  --  Programa : TELA_ANALISE_CREDITO
  --  Sistema  : Aimaro/Ibratan
  --  Autor    : Equipe Mouts
  --  Data     : Março/2019                 Ultima atualizacao: 01/05/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar consultas para analise de credito
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
    
  /*
   0 – CDC Diversos
   1 – CDC Veículos 
   2 – Empréstimos /Financiamentos 
   3 – Desconto Cheques 
   4 – Desconto Títulos 
   5 – Cartão de Crédito 
   6 – Limite de Crédito
  */
  c_emprestimo      constant number(1):= 2;
  c_cartao          constant number(1):= 5;
  c_limite          constant number(1):= 6;
  c_desconto_titulo constant number(1):= 4;  

    /*Globais*/
  vr_nrdconta_principal   crapass.nrdconta%type;
  vr_cdcooper_principal   crapass.cdcooper%type;
  vr_tpproduto_principal  number(2);
  vr_nrctrato_principal   number(10);
  vr_nrcpfcgc_principal   crapass.nrcpfcgc%type;

  --vr_xml xmltype; -- XML que sera enviado
  vr_des_xml         clob; --para os titulos do bordero
  vr_texto_completo  varchar2(32600);

  vr_xml CLOB; -- XML que sera enviado
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  vr_idorigem number := 1;

  vr_garantia          VARCHAR2(250);
  vr_flconven          INTEGER;
  vr_des_reto          VARCHAR2(100);
  vr_tab_erro          gene0001.typ_tab_erro;

   CURSOR c_pessoa_por_id(pr_idpessoa in number) IS
   SELECT a.cdcooper
         ,a.nrdconta
         ,a.inpessoa
         ,a.nrcpfcgc
         ,a.inprejuz
     FROM crapass a,
          tbcadast_pessoa p
    WHERE p.idpessoa = pr_idpessoa
      AND a.nrcpfcgc = p.nrcpfcgc
      AND a.dtdemiss is null; --bug 19602
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
          fn_tag('Valor da Operação',to_char(e.vlemprst,'999g999g990d00')) valor_emprestimo,
          fn_tag('Valor das Parcelas',to_char(e.vlpreemp,'999g999g990d00')) valor_prestacoes,
          fn_tag('Quantidade de Parcelas',e.qtpreemp) qtd_parcelas,
          fn_tag('Linha de Crédito',e.cdlcremp||' - '||lcr.dslcremp) linha,
          fn_tag('Finalidade',e.cdfinemp||' - '||fin.dsfinemp) finalidade,
          fn_tag('CET',e.percetop || '%') cet,
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
          nvl(e.idfiniof,0) idfiniof,
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
           e.cdlcremp||' - '||lcr.dslcremp linha,
           e.cdfinemp||' - '||fin.dsfinemp finalidade,
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
           fn_zeroToNull(e.nrctrliq##10)),'-') contratos,
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
         fn_tag('Idade',trunc((months_between(rw_crapdat.dtmvtolt, a.dtnasctl))/12)||' anos') idade,
         fn_tag('CPF',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,1)) cpf_tag,
         fn_tag('Estado Civil',ec.dsestcvl) estado_civil,
         fn_tag('Naturalidade',tl.dsnatura) dsnatura ,
         fn_tag('Tempo de Cooperativa',trunc((months_between(rw_crapdat.dtmvtolt, a.dtmvtolt))/12)||' anos e '||
         trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt), a.dtmvtolt), 12))||' meses ') tempocoop, -- Bug 20750 -- estava dtadmiss - Paulo
         a.nrcpfcgc cpf,
         a.cdsitdct,
         fn_tag('Tipo de Conta',CADA0004.fn_dstipcta (pr_inpessoa => a.inpessoa, pr_cdtipcta => a.cdtipcta)) tipoconta,
         fn_tag('Situação da Conta',CADA0004.fn_dssitdct(pr_cdsitdct => a.cdsitdct)) situacao_conta,
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
    select fn_tag('Aluguel (Despesa)',to_char(vlalugue,'999g999g990d00')) vlalugue
          ,fn_tag('Tipo de Imóvel',tipoimovel) tipoimovel
          ,fn_tag('Tempo de Residência',temporeside) temporeside
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
      SELECT fn_tag('Natureza da Ocupação',p.cdnatureza_ocupacao||' - '||o.dsnatocp) natureza_ocupacao,
             fn_tag('Cargo',p.dsprofissao) profissao,
             fn_tag('Justificativa',p.dsjustific_outros_rend) jusrendimento,
             p.idpessoa
        FROM vwcadast_pessoa_fisica p,
             gncdnto o
       WHERE p.nrcpf = pr_nrcpf
         AND p.cdnatureza_ocupacao = o.cdnatocp;
    r_dados_comerciaisI c_dados_comerciaisI%ROWTYPE;

     /*Dados Comerciais*/
    CURSOR c_dados_comerciaisII (pr_idpessoa tbcadast_pessoa.idpessoa%TYPE )IS
      SELECT fn_tag('Tipo de Contrato de Trabalho',decode(r.tpcontrato_trabalho,1,'Permanente',2,'Temporário/Terceiro',3,'Sem Vínculo',4,'Autonomo')) tipo_contrato_trab,
             fn_tag('Tempo de Empresa',trunc((months_between(rw_crapdat.dtmvtolt, r.dtadmissao))/12)||' anos e '||
             trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt), r.dtadmissao), 12))||' meses ') tempoempresa,
             fn_tag('Salário',to_char(r.vlrenda,'999g999g990d00')) vlrenda,
             fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(e.nrcpfcgc,case when e.nrcpfcgc > 11 then 2 else 1 end)) nrcpfcgc,
             fn_tag('Nome da Empresa',emp.nmpessoa) empresa
        FROM tbcadast_pessoa_renda r,
             tbcadast_pessoa e,
             tbcadast_pessoa emp
       WHERE r.idpessoa = pr_idpessoa
         AND r.idpessoa_fonte_renda = emp.idpessoa --bug 20860
         AND r.idpessoa = e.idpessoa; --bug 20645
    r_dados_comerciaisII c_dados_comerciaisII%ROWTYPE;

    CURSOR c_gncdocp (pr_cddocupa IN gncdocp.cdocupa%type) IS
    SELECT fn_tag('Ocupação',gncdocp.cdocupa||' - '||gncdocp.rsdocupa) rsdocupa
      FROM gncdocp
      WHERE gncdocp.cdocupa = pr_cddocupa;
    r_gncdocp c_gncdocp%ROWTYPE;    
    

    --> buscar dados da renda complementar
    CURSOR c_renda_compl(pr_idpessoa tbcadast_pessoa.idpessoa%TYPE )IS
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
          fn_tag('Tipo de Imóvel',este0002.fn_des_incasprp(t.tpimovel)) tipoImovel,
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
  select s.nrcpfcgc
    from crapavt s
   where s.cdcooper = pr_cdcooper
     and s.tpctrato = 6 /*procurad*/ 
     and s.nrdconta = pr_nrdconta  
     and s.nrctremp = 0
     and s.persocio > 0; -- Somente com participação societaria      
  r_socios c_socios%rowtype;      
  
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
  CURSOR c_outras_contas(pr_cdcooper in number,
                         p_nrcpfcgc in crapass.nrcpfcgc%type) IS
   SELECT a.nrdconta,
          p.idpessoa,
          a.nrcpfcgc,
          a.inprejuz,
          a.inpessoa
     FROM crapass a,
          tbcadast_pessoa p
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrcpfcgc = p_nrcpfcgc
      AND a.dtdemiss is null
      AND a.nrcpfcgc = p.nrcpfcgc;
  r_outras_contas c_outras_contas%rowtype;    

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

    vr_tab_tabela typ_tab_tabela;
    vr_tab_tabela_secundaria typ_tab_tabela; --Tabela adicional de críticas para o borderô de desconto de títulos

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
                      pr_dados in typ_tab_tabela) return varchar2 is
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
    FOR i IN vr_titulo.FIRST..vr_titulo.LAST LOOP
        vr_retorno := vr_retorno || '<coluna>' || vr_titulo(i) || '</coluna>';
    END LOOP;
  END IF;
  vr_retorno := vr_retorno||'</colunas></linha>';

  FOR vr_index IN 1..vr_tabela.COUNT LOOP
    vr_retorno := vr_retorno||'<linha><colunas>';
    vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna1||'</coluna>';
    if vr_tabela(vr_index).coluna2 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna2||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna3 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna3||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna4 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna4||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna5 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna5||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna6 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna6||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna7 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna7||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna8 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna8||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna9 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna9||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna10 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna10||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna11 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna11||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna12 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna12||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna13 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna13||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna14 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna14||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna15 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna15||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna16 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna16||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna17 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna17||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna18 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna18||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna19 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna19||'</coluna>';
    end if;
    if vr_tabela(vr_index).coluna20 is not null then
      vr_retorno := vr_retorno||'<coluna>'||vr_tabela(vr_index).coluna20||'</coluna>';
    end if;
    vr_retorno := vr_retorno||'</colunas></linha>';
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
                          p_idCampo in number) return varchar2 is 
                         
    -- Verificar se PA utilza o CRM
    CURSOR cr_motor (prc_cdcooper IN crapage.cdcooper%TYPE,
                       prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                       prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS
         SELECT e.dsconteudo_requisicao, a.inpessoa, a.nrdconta
         FROM tbgen_webservice_aciona e, crapass a
         WHERE e.cdcooper = prc_cdcooper
         and a.cdcooper = e.cdcooper --incluido rubens
         and e.cdorigem = 9
         and e.cdoperad = 'MOTOR'
         and e.dsoperacao NOT LIKE '%ERRO%'
         and e.dsoperacao NOT LIKE '%DESCONHECIDA%'
         and e.nrdconta = prc_nrdconta
         and e.nrctrprp = prc_nrctrprp
         and a.nrdconta = e.nrdconta;
         --and a.inpessoa = 2;
         
    rw_motor cr_motor%ROWTYPE;
    
   vr_json clob;
   vr_retorno clob;
   vr_texto varchar2(4000);

   vr_obj      cecred.json := json(); -- Objeto de leitura JSON
   vr_obj_analise cecred.json := json(); -- Analise (tag) JSON
   vr_obj_mensagensDeAnalise cecred.json := json();
   vr_objFor cecred.json := json();
   
   vr_obj_lst  json_list := json_list(); -- Lista para loop
   vr_length number;
   
   vr_split GENE0002.typ_split;
  BEGIN
  vr_retorno := '';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
    
  vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8');--'WE8ISO8859P1');
  
  --vr_retorno := vr_json;
  
  --Atribuir json ao objeto:
  vr_obj := json(vr_json);
  
  --Atrivuir analises index ao objeto
  vr_obj_analise := json(vr_obj.get('analises').to_char());
  
  -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
  vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
   FOR vr_idx IN 1..vr_obj_lst.count() LOOP
       --Ler index
         vr_objFor := json( vr_obj_lst.get(vr_idx));
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
               vr_split := GENE0002.fn_quebra_string(vr_retorno,':');
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
              return '-';
  END fn_le_json_motor;
  
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
  CURSOR cr_motor (prc_cdcooper IN crapage.cdcooper%TYPE,
                   prc_nrdconta IN tbgen_webservice_aciona.nrdconta%TYPE,
                   prc_nrctrprp IN tbgen_webservice_aciona.nrctrprp%TYPE) IS

   SELECT e.dsconteudo_requisicao
   FROM tbgen_webservice_aciona e
   WHERE e.cdcooper = prc_cdcooper
   AND   e.cdoperad = 'MOTOR'
   AND   e.dsoperacao NOT LIKE '%ERRO%'
   AND   e.dsoperacao NOT LIKE '%DESCONHECIDA%'
   AND   e.nrdconta = prc_nrdconta
   AND   e.nrctrprp = prc_nrctrprp;
   rw_motor cr_motor%ROWTYPE;
    
   vr_json clob;
   vr_retorno clob;
   vr_texto varchar2(4000);

   vr_obj      cecred.json := json(); -- Objeto de leitura JSON
   vr_obj_analise cecred.json := json(); -- Analise (tag) JSON
   vr_objFor cecred.json := json();
   
   vr_obj_lst  json_list := json_list(); -- Lista para loop
   
   vr_split GENE0002.typ_split;
  BEGIN
  vr_retorno := '';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
    
  vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8');--'WE8ISO8859P1');
  
  --vr_retorno := vr_json;
  
  --Atribuir json ao objeto:
  vr_obj := json(vr_json);
  
  --Atrivuir analises index ao objeto
  vr_obj_analise := json(vr_obj.get('analises').to_char());
  
  -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
  vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
   FOR vr_idx IN 1..vr_obj_lst.count() LOOP
       --Ler index
         vr_objFor := json( vr_obj_lst.get(vr_idx));
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
               vr_split := GENE0002.fn_quebra_string(vr_retorno,':');
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

PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
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
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
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
           e.nrctaav2
      FROM crawepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctrato;
       r_avalistas_epr c_avalistas_epr%rowtype;

  /*Grupo Economico*/
  CURSOR c_grupo_economico(pr_cdcooper in tbcc_grupo_economico.cdcooper%type,
                           pr_nrdconta in tbcc_grupo_economico.nrdconta%type) is
    
  select g.cdcooper,
         g.nrdconta
    from tbcc_grupo_economico_integ g
   where g.dtexclusao is null
     and g.idgrupo in (select gei.idgrupo
                         from tbcc_grupo_economico gei
                        where gei.nrdconta = pr_nrdconta
                          and gei.cdcooper = pr_cdcooper);
                          
  r_grupo_economico c_grupo_economico%rowtype;

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
  vr_nrfiltro number;

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

      if (pr_inpessoa = 1) then
        /* Consulta Cadastro PF*/
        pc_consulta_cadastro_pf(pr_cdcooper => pr_cdcooper ,
                                pr_nrdconta => pr_nrdconta,
                                pr_idpessoa => pr_idpessoa,
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
        if (pr_tpproduto = c_limite) then
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
                            pr_inpessoa  => pr_inpessoa,
                            pr_nrcpfcgc => pr_nrcpfcgc,
                            pr_cdcritic => vr_cdcritic, 
                            pr_dscritic => vr_dscritic , 
                            pr_dsxmlret => vr_xml_aux);
                            
      vr_string_persona := vr_string_persona||vr_xml_aux;
      vr_string_persona := vr_string_persona||'</subcategorias></categoria>';                       
      
      vr_string_persona := vr_string_persona||'</categorias></persona>';

      pr_xmlOut := vr_string_persona;
  end;  


  begin

    /*Carrega chaves principais*/
    vr_nrdconta_principal   := pr_nrdconta;
    vr_cdcooper_principal   := pr_cdcooper;
    vr_tpproduto_principal  := pr_tpproduto;
    vr_nrctrato_principal   := pr_nrctrato;


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
      
        
      /*FIM-PROPONENTE*/

      /*CONJUGE*/

      --Buscar conjuge
      open c_conjuge(r_pessoa.idpessoa);
       fetch c_conjuge into r_conjuge;
        if c_conjuge%found then
          open c_pessoa_por_id(r_conjuge.idpessoa_relacao);
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
                                    /*pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic, */

        pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                pr_texto_completo => vr_string_completa,
                                      pr_texto_novo     => vr_xml,
                                pr_fecha_xml      => TRUE);

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
                  if c_pessoa%notfound then
                    close c_pessoa;
                    /*Message erro*/
                  else

                    if r_avalistas_epr.nrctaav1 > 0 and r_avalistas_epr.nrctaav2 > 0 then
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
                                          /*pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic, */

        pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                pr_texto_completo => vr_string_completa,
                                pr_texto_novo     => vr_xml,
                                pr_fecha_xml      => TRUE);

                  end if;
                  close c_pessoa;
             end if;
             /*Avalista 2*/
             if r_avalistas_epr.nrctaav2 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_epr.nrctaav2);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%notfound then
                    close c_pessoa;
                    /*Message erro*/
                  else
                    if r_avalistas_epr.nrctaav1 > 0 and r_avalistas_epr.nrctaav2 > 0 then
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

      end if;
          end if;
        close c_avalistas_epr;
      end if;
      /*FIM-INFORMAÇÃO AVALISTA*/

      /*GRUPO-ECONOMICO*/
      vr_nrfiltro := 0;
      for r_grupo_economico in c_grupo_economico(pr_cdcooper,pr_nrdconta) loop
        if r_grupo_economico.nrdconta != pr_nrdconta then
        open c_pessoa(r_grupo_economico.cdcooper,r_grupo_economico.nrdconta);
         fetch c_pessoa into r_pessoa;
          if c_pessoa%found then

            vr_nrfiltro := vr_nrfiltro+1;
            vr_filtro := '_'||to_char(vr_nrfiltro);
            pc_gera_dados_persona(pr_persona => 'GE '||r_grupo_economico.nrdconta,
                                  pr_persona_filtro => 'grupo'||vr_filtro,
                                  pr_cdcooper => r_grupo_economico.cdcooper,
                                  pr_nrdconta => r_grupo_economico.nrdconta,
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
      /*FIM-GRUPO-ECONOMICO*/
      

      /*QUADRO SOCIETARIO*/
      vr_nrfiltro := 0;
      for r_socios in c_socios(pr_cdcooper,pr_nrdconta) loop
         -- Buscar informações da conta com o cpf  
         for r_outras_contas in c_outras_contas(pr_cdcooper,r_socios.nrcpfcgc) loop

            vr_nrfiltro := vr_nrfiltro+1;
            vr_filtro := '_'||to_char(vr_nrfiltro);
            pc_gera_dados_persona(pr_persona => 'QS '||r_outras_contas.nrdconta,
                                  pr_persona_filtro => 'quadro'||vr_filtro,
                                  pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => r_outras_contas.nrdconta,
                                  pr_idpessoa => r_outras_contas.idpessoa,
                                  pr_nrcpfcgc => r_outras_contas.nrcpfcgc,
                                  pr_inpessoa => r_outras_contas.inpessoa,
                                  pr_xmlOut => vr_xml);

                                  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                  pr_texto_completo => vr_string_completa,
                                  pr_texto_novo     => vr_xml,
                                  pr_fecha_xml      => TRUE);

          end loop;
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
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                               || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados proc principal. '
                                               || ', erro: '||substr(sqlerrm,1,255),
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                 pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));     

  end pc_gera_dados_analise_credito;

  PROCEDURE pc_job_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
     WHERE owner         = 'CECRED'
       AND job_name   LIKE '%'||pr_jobname||'%'
       AND JOB_ACTION LIKE '%pr_cdcooper => '||pr_cdcooper||'%'
       AND JOB_ACTION LIKE '%pr_nrdconta => '||pr_nrdconta||'%'
       AND JOB_ACTION LIKE '%pr_tpproduto => '||pr_tpproduto||'%'
       AND JOB_ACTION LIKE '%pr_nrctrato => '||pr_nrctrato||'%';
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
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> Código da cooperativa
                            ,pr_cdprogra  => 'TELA_ANALISE_CREDITO' --> Código do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSDATE  + 1/1440 --> Executar após 1 minuto
                            ,pr_interva   => null         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Adicionar ao LOG e continuar o processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2,
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                   || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para análise de crédito. '
                                                   || ', erro: '||vr_dscritic,
                                   pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                                                pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
      END IF;
    ELSE
      CLOSE cr_verifica_job;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro ao gerar Job: '||sqlerrm;
      -- Adicionar ao LOG e continuar o processo
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                 pr_ind_tipo_log => 2,
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                 || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para análise de crédito. '
                                                 || ', erro: '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
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
         AND INSTR(pr_cdhistor,';'||craplcm.cdhistor||';') > 0;
    rw_craplcm_cred cr_craplcm%ROWTYPE;
    rw_craplcm_debi cr_craplcm%ROWTYPE;

    -- Variaveis de log
    vr_cdhistor_cred crapprm.dsvlrprm%TYPE;
    vr_cdhistor_debi crapprm.dsvlrprm%TYPE;

    -- Variaveis gerais
    vr_dtinicio DATE;
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
    vr_dtinicio := TRUNC(ADD_MONTHS(rw_crapdat.dtmvtolt,-6),'MM');

    -- Efetua loop sobre os meses de busca
    FOR x IN 1..6 LOOP

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
        vr_vltrimestre := NVL(vr_vltrimestre,0) + (NVL(rw_craplcm_cred.valor,0) - NVL(rw_craplcm_debi.valor,0));
      END IF;

      -- Efetua a somatoria do semestre
      IF x <= 6 THEN
        vr_vlsemestre := NVL(vr_vlsemestre,0) + (NVL(rw_craplcm_cred.valor,0) - NVL(rw_craplcm_debi.valor,0));
      END IF;

      -- Incrementa o mês
      vr_dtinicio := ADD_MONTHS(vr_dtinicio, 1);

    END LOOP;

    vr_string := fn_tag('Média de Créditos Recebidos no Trimestre',TO_CHAR(ROUND(vr_vltrimestre/3,2),'999g999g990d00'))||
                 fn_tag('Média de Créditos Recebidos no Semestre',TO_CHAR(ROUND(vr_vlsemestre/6,2),'999g999g990d00'));

    pr_XmlOut := vr_string;

  END pc_lista_cred_recebidos;


  PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
      pr_cdcritic := 0;
      pr_dscritic := 'Erro - pc_consulta_analise_credito: '||sqlerrm;
  END;

  PROCEDURE pc_consulta_cadastro_pf(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_idpessoa IN tbcadast_pessoa.idpessoa%TYPE --> IDPESSOA
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB) IS      --> Arquivo de retorno do XML

  CURSOR c_cjg_coresponsavel(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                            ,pr_nrctrato IN crapprp.nrdconta%TYPE       --> Conta
                            ,pr_tpctrato IN crapprp.tpctrato%TYPE) is
  select co.nrdconta
    from crapprp co
   where co.cdcooper = pr_cdcooper
     and co.nrctrato = pr_nrctrato
     and co.tpctrato = pr_tpctrato;
  r_cjg_coresponsavel c_cjg_coresponsavel%rowtype;

  vr_dsxmlret CLOB;
  
  vr_totalRendimentoOutros number; -- bruno - dados comerciais

  vr_string      CLOB;
  vr_string_aux  CLOB;
  vr_index       NUMBER := 1;

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
                   r_cadastro.nome||
                   --a.dtnasctl,
                   r_cadastro.idade||
                   r_cadastro.cpf_tag||
                   r_cadastro.estado_civil||
                   r_cadastro.dsnatura||
                   --todo: utilizar CRAPDAT para calcular data
                   r_cadastro.tempocoop;
    end if;
   close c_cadastro;


  vr_string := vr_string||'</campos></subcategoria>';

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
  vr_string := vr_string||'<campo>
                           <nome>Bens</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
  vr_index := 1;
  vr_tab_tabela.delete;
  for r_bens in c_bens(pr_cdcooper,pr_nrdconta) loop
   vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
   vr_tab_tabela(vr_index).coluna2 := r_bens.persemon || '%';
   vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
   vr_tab_tabela(vr_index).coluna4 := trim(to_char(r_bens.vlprebem,'999g999g990d00'));   
   vr_tab_tabela(vr_index).coluna5 := to_char(r_bens.vlrdobem,'999g999g990d00');
   vr_index := vr_index+1;
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

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

   vr_string := vr_string||'</campos></subcategoria>';

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
      vr_string := vr_string||'<campo>
                               <nome>Bens Cônjuge Co-Responsável</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';
      vr_index := 1;
      vr_tab_tabela.delete;
      for r_bens in c_bens(pr_cdcooper,r_cjg_coresponsavel.nrdconta) loop
       vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
       vr_tab_tabela(vr_index).coluna2 := r_bens.persemon || '%';
       vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
       vr_tab_tabela(vr_index).coluna4 := to_char(r_bens.vlrdobem,'999g999g990d00');
       --vr_tab_tabela(vr_index).coluna5 := r_bens.vlprebem;
       vr_index := vr_index+1;
      end loop;

      if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string := vr_string||fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor',vr_tab_tabela);
      else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        --vr_tab_tabela(1).coluna5 := '-';
        vr_string := vr_string||fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor',vr_tab_tabela);
      end if;

       vr_string := vr_string||'</linhas>
                                </valor>
                                </campo>';

       vr_string := vr_string||'</campos></subcategoria>';
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
                       r_dados_comerciaisII.tipo_contrato_trab||
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
  vr_string := vr_string||'<campo>
                           <nome>Outros Rendimentos</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
   vr_index := 1;
  vr_tab_tabela.delete;
  vr_totalRendimentoOutros := 0; -- Bruno Dados Comerciais
  for r_renda_compl in c_renda_compl(pr_idpessoa) loop --bug 19597
   vr_tab_tabela(vr_index).coluna1 := r_renda_compl.dscodigo;
   vr_tab_tabela(vr_index).coluna2 := to_char(r_renda_compl.vlrenda,'999g999g990d00');
   vr_index := vr_index+1;
   vr_totalRendimentoOutros := vr_totalRendimentoOutros + r_renda_compl.vlrenda; -- Bruno - Dados Comerciais
  end loop;
  
  
  
  --vr_totalRendimentoOutros

  if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Tipo de Renda;Valor',vr_tab_tabela);
    
    vr_string := vr_string||'<linha><colunas>'
                          ||'<coluna>&lt;b&gt;Total&lt;/b&gt;</coluna>'
                          ||'<coluna>'||to_char(vr_totalRendimentoOutros,'999g999g990d00')||'</coluna>'
                          ||'</colunas></linha>'; -- bruno - Dados Comerciais
  else
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_string := vr_string||fn_tag_table('Tipo de Renda;Valor',vr_tab_tabela);
    end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

   /*Justificativa do Rendimento*/
   vr_string := vr_string||r_dados_comerciaisI.Jusrendimento;

   --Rendimentos automáticos
   vr_string := vr_string||'<campo>
                            <nome>Rendas Automáticas</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';

   pc_busca_rendas_aut(pr_cdcooper,pr_nrdconta,vr_string_aux);

   vr_string := vr_string||vr_string_aux||'</linhas>
                                </valor>
                                </campo>';
   /*Movimentação trimestre e semestre*/
   vr_string_aux := NULL;
   pc_lista_cred_recebidos(pr_cdcooper,pr_nrdconta,vr_string_aux);
   vr_string := vr_string||vr_string_aux;

   vr_string := vr_string||'<campo>
                             <nome>Consulta IR</nome>
                             <tipo>info</tipo>
                             <valor>Para os dados utilize o DigiDoc.</valor>
                            </campo>';
   
      /* Dossie Digidoc*/
   vr_string := vr_string||'<campo>'||
                           '<nome>Abrir Dossiê DigiDoc</nome>'||
                           '<tipo>link</tipo>'||
                           '<valor>http://0303hmlged01/smartshare/Cliente/ViewerExterno.aspx?'||
                           'pkey=G7o9A&amp;' ||
                           'CPF/CNPJ='||
                            gene0002.fn_mask_cpf_cnpj(r_cadastro.cpf,1) ||
                           '</valor>'||
                           '</campo>';

   vr_string := vr_string||'</campos>';

   -- Encerrar a tag raiz
   pc_escreve_xml(pr_xml            => vr_dsxmlret,
                  pr_texto_completo => vr_string,
                  pr_texto_novo     => '</subcategoria>',
                  pr_fecha_xml      => TRUE);

   pr_dsxmlret := vr_dsxmlret;

  EXCEPTION
   WHEN OTHERS THEN
     pr_cdcritic := 0;
     pr_dscritic := 'Erro pc_consulta_cadastro_pf: '||sqlerrm;
  END;



  PROCEDURE pc_consulta_cadastro_pj(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                   ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                   ,pr_dsxmlret OUT CLOB) IS      --> Arquivo de retorno do XML
  /* .............................................................................

    Programa: pc_consulta_cadastro_pj
    Sistema : Aimaro/Ibratan
    Autor   : Rubens Lima
    Data    : Março/2019                 Ultima atualizacao: 23/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consultar as informações do cadastro PJ

    Alteracoes:
  ..............................................................................*/

  vr_dsxmlret    CLOB;

  vr_dstexto     CLOB;
  vr_string      CLOB;
  vr_string_aux  CLOB;
  vr_index       NUMBER := 1;

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

  vr_string := vr_string||'</subcategoria>';
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
      vr_string := vr_string||'<campos>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string||'<campos>'||
                   r_patrimonio_pj.vlalugue||
                   r_patrimonio_pj.tipoimovel||
                   r_patrimonio_pj.temporeside;
    end if;
  close c_patrimonio_pj_reside;

  /*Bens apresentados em tabela*/
  vr_string := vr_string||'<campo>
                           <nome>Bens</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>';
  vr_index := 1;
  vr_tab_tabela.delete;
  for r_bens in c_bens_pj(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta) loop
   vr_tab_tabela(vr_index).coluna1 := r_bens.dsrelbem;
   vr_tab_tabela(vr_index).coluna2 := r_bens.persemon;
   vr_tab_tabela(vr_index).coluna3 := r_bens.qtprebem;
   vr_tab_tabela(vr_index).coluna4 := trim(to_char(r_bens.vlprebem,'999g999g990d00'));
   vr_tab_tabela(vr_index).coluna5 := to_char(r_bens.vlrdobem,'999g999g990d00');
   vr_index := vr_index+1;
  end loop;

  if vr_tab_tabela.COUNT > 0 then
    /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Descrição do Bem;Livre de Ônus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  else
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_string := vr_string||fn_tag_table('Bens;Livre de Ônus;Quantidade de Parcela;Valor',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

   vr_string := vr_string||'</campos></subcategoria>';

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
      vr_string := vr_string||'<campos>'||
                   r_dados_comerciais_fat.vlrmedfatbru||
                   r_dados_comerciais_fat.perfatcl;
    end if;

    /*Movimentação trimestre e semestre*/
    vr_string_aux := NULL;
    pc_lista_cred_recebidos(pr_cdcooper,pr_nrdconta,vr_string_aux);
    vr_string := vr_string||vr_string_aux;

   /* Dossie Digidoc*/
   vr_string := vr_string||'<campo>'||
                           '<nome>Abrir Dossiê DigiDoc</nome>'||
                           '<tipo>link</tipo>'||
                           '<valor>http://0303hmlged01/smartshare/Cliente/ViewerExterno.aspx?'||
                           'pkey=G7o9A&amp;' ||
                           'CPF/CNPJ='|| gene0002.fn_mask_cpf_cnpj(r_cadastro_pj.cnpj_sem_format , 2) ||
                           '</valor>'||
                           '</campo>';

   close c_dados_comerciais_fat;

   vr_string := vr_string || '</campos>';

   vr_string := vr_string||'</subcategoria>';
   /* Fim Dados Comerciais de Faturamento */

  -- Escrever no XML
  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                 pr_texto_completo => vr_dstexto,
                 pr_texto_novo     => vr_string,
                 pr_fecha_xml      => TRUE);

  pr_dsxmlret := vr_dsxmlret;
 EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_cadastro_pj: '||sqlerrm;  

 END pc_consulta_cadastro_pj;

  
PROCEDURE pc_consulta_garantia(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
    Data    : Março/2019                 Ultima atualizacao: 09/05/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consultar as garantias do proponente PF ou PJ

    Alteracoes:
  ..............................................................................*/

  vr_dsxmlret             CLOB;
  vr_dstexto              CLOB;
  vr_string               CLOB;
  vr_string_cong          CLOB;
  vr_string_garantia_pessoal        CLOB;
  vr_string_cabec         CLOB;
  pr_retxml               xmltype;


  vr_idpessoa_conjuge     tbcadast_pessoa.idpessoa%TYPE;
  vr_idpessoa             tbcadast_pessoa.idpessoa%TYPE;
  vr_nrdcontacjg          crapass.nrdconta%TYPE;
  vr_cpfconjuge           crapcje.nrcpfcjg%TYPE;
  --vr_saldocotas_conjuge   crapcot.vldcotas%TYPE;
  vr_vldcotas             VARCHAR2(100);
  --Saldo Médio
  vr_saldo_mes        NUMBER;
  vr_saldo_trimestre  NUMBER;
  vr_saldo_semestre   NUMBER;
  --Aplicações
  vr_vldaplica        NUMBER;
  vr_index            NUMBER:=1;
  vr_index_aval       NUMBER:=1;

  --Variaveis para Garantia da aplicação
  vr_permingr         number;
  vr_vlgarnec         VARCHAR2(100):=0;
  vr_inaplpro         VARCHAR2(100):=0;
  vr_vlaplpro         VARCHAR2(100):=0;
  vr_inpoupro         VARCHAR2(100):=0;
  vr_vlpoupro         VARCHAR2(100):=0;
  vr_inresaut         VARCHAR2(100):=0;
  vr_nrctater         VARCHAR2(100):=0;
  vr_inaplter         VARCHAR2(100):=0;
  vr_inpouter         VARCHAR2(100):=0;

  vr_isinterv         boolean:=FALSE; --controle quando deve chamar tabela interveniente
  vr_inpessoaI        number:=1; --Tipo de pessoa do interveniente

  --tabela para os avalistas
  vr_tab_dados_avais dsct0002.typ_tab_dados_avais;

  /* 4.1 Garantia Pessoal Pessoa Física - com base em b1wgen0075.busca-dados*/
  cursor c_garantia_pessoal_pf (pr_nrdconta crapass.nrdconta%type
                               ,pr_cdcooper crapass.cdcooper%type)is
  select fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta --Número da conta
        ,fn_tag('Tipo de Pessoa','Física') tipopessoa
        ,fn_tag('CPF',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,1)) cpf --CPF
        ,fn_tag('Nome',a.nmprimtl) nome --Nome
        ,fn_tag('Nacionalidade',(select dsnacion from crapnac where cdnacion = a.cdnacion)) dsnacion --nacionalidade
        ,fn_tag('Data de Nascimento',to_char(a.dtnasctl,'DD/MM/YYYY')) datanasc     --Data de Nascimento
        ,fn_tag('Renda',to_char((select vlsalari + vldrendi##1 + vldrendi##2 + vldrendi##3 + vldrendi##4
                                 from crapttl
                                 where nrdconta = a.nrdconta
                                 and idseqttl =1
                                 and cdcooper = a.cdcooper),'999g999g990d00')) renda
        ,fn_tag('CEP',gene0002.fn_mask_cep(d.nrcepend)) cep -- Cep
        ,fn_tag('Rua',d.dsendere) rua -- Rua
        ,fn_tag('Complemento',d.complend) complemento --Complemento
        ,fn_tag('Número',d.nrendere) nr -- Nr. endereço
        ,fn_tag('Cidade',d.nmcidade) cidade -- Cidade
        ,fn_tag('Bairro',d.nmbairro) bairro --Bairo
        ,fn_tag('Estado',d.cdufende) estado --UF
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
  CURSOR c_garantia_juridica (pr_nrdconta crapass.nrdconta%type
                             ,pr_cdcooper crapass.cdcooper%type)is
    SELECT fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta
          ,fn_tag('Tipo de Pessoa','Juridica') tipopessoa
          ,fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,2)) cnpj
          ,fn_tag('Razão Social',a.nmprimtl) nome
          ,fn_tag('Data de Abertura da Empresa',to_char(j.dtiniatv,'DD/MM/YYYY')) abertura
          ,fn_tag('Faturamento Médio Mensal',(select to_char(round(((jfn.vlrftbru##1 +
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
                          jfn.vlrftbru##12)) /
                           decode(jfn.vlrftbru##1,0,0,1) +
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
                            decode(jfn.vlrftbru##12,0,0,1),2),'999g999g990d00')
                  from crapjfn jfn
                  where jfn.cdcooper = pr_cdcooper
                  and   jfn.nrdconta = pr_nrdconta)) fatmedmensal --Soma tudo e divide pelos meses que tem lançamento
            ,fn_tag('CEP',gene0002.fn_mask_cep(d.nrcepend)) cep
            ,fn_tag('Rua',d.dsendere) rua
            ,fn_tag('Complemento',d.complend) complemento
            ,fn_tag('Número',d.nrendere) numero
            ,fn_tag('Cidade',d.nmcidade) cidade
            ,fn_tag('Bairro',d.nmbairro) bairro
            ,fn_tag('Estado',d.cdufende) uf
    FROM crapass a
        ,crapjur j
        ,crapenc d
    WHERE a.cdcooper = j.cdcooper
    AND   a.nrdconta = j.nrdconta
    AND   a.cdcooper = d.cdcooper
    AND   a.nrdconta = d.nrdconta
    AND   a.cdcooper = pr_cdcooper
    AND   a.nrdconta = pr_nrdconta
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
    AND   c.nrcpfcgc <> 0;

  /* Cônjuge não cooperado*/
  CURSOR c_consultaconjuge_naocoop(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta Cônjuge',0) conta
         ,fn_tag('CPF Cônjuge',gene0002.fn_mask_cpf_cnpj(nvl(nrcpfcjg,0),1)) cpf
         ,fn_tag('Nome Cônjuge',nmconjug) nome
         ,fn_tag('Rendimento Mensal Cônjuge', nvl(vlsalari,0)) rendimento
         ,fn_tag('Endividamento Cônjuge',0) endiv
   FROM crapcje
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND idseqttl = 1;
  r_consultaconjuge_naocoop c_consultaconjuge_naocoop%ROWTYPE;

  /* Cônjuge cooperado*/
  CURSOR c_consultaconjuge_coop (pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta Cônjuge',gene0002.fn_mask_conta(j.nrctacje)) conta
         ,fn_tag('CPF Cônjuge',gene0002.fn_mask_cpf_cnpj(t.nrcpfcgc,1)) cpf
         ,fn_tag('Nome Cônjuge',t.nmextttl) nome
         ,fn_tag('Rendimentos Cônjuge',to_char((t.vlsalari + t.vldrendi##1),'999g999g990d00')) rendimentos
         ,fn_tag('Endividamento Cônjuge',to_char((SELECT Nvl(Sum(vlvencto),0)
                                   FROM crapvop v
                                   WHERE nrcpfcgc = t.nrcpfcgc
                                     AND dtrefere = (SELECT Max(dtrefere)
                                                     FROM crapvop
                                                     WHERE nrcpfcgc = v.nrcpfcgc)),'999g999g990d00')) endiv
         ,j.nrctacje nrdcontacjg --sem formatacao para passar para o proximo cursor
   FROM crapcje j,
        crapttl t
   WHERE j.nrctacje = t.nrdconta
   AND   j.cdcooper = t.cdcooper
   AND   j.nrdconta <> t.nrdconta
   AND   j.cdcooper = pr_cdcooper
   AND   t.idseqttl = 1
   AND   j.nrdconta = pr_nrdconta;
   r_consultaconjuge_coop c_consultaconjuge_coop%ROWTYPE;

  /* */
  CURSOR c_verifica_conjuge_coop(pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
    select a.nrdconta
     from crapass a
    where a.nrcpfcgc = pr_nrcpfcgc
    and rownum<=1;
  r_verifica_conjuge_coop c_verifica_conjuge_coop%ROWTYPE;


  /*Cursor para buscar o valor de Capital */
  cursor c_consulta_valor_capital (pr_cdcooper crapcop.cdcooper%TYPE
                               ,pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT fn_tag('Capital Cônjuge',to_char(nvl(vldcotas,0),'999g999g990d00'))
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
          ,tpchassi tipochassi
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

  /*Interveniente Anuente PJ*/
  cursor c_consulta_interv_anuente (pr_cdcooper IN crapcop.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT gene0002.fn_mask_conta(Decode(a.nrdconta,NULL,0,a.nrdconta)) conta
          ,decode(a.inpessoa,1,'Física',2,'Jurídica') inpessoa
          ,a.inpessoa inpessoaInterv
          ,gene0002.fn_mask_cpf_cnpj(v.nrcpfcgc, (CASE WHEN 
                                                    LENGTH(v.nrcpfcgc) > 11 then 2 else 1
                                                 END)
                                                 ) cpf
          ,v.nmdavali nome
          ,(SELECT dsnacion FROM crapnac WHERE cdnacion = v.cdnacion) nacionalidade
          ,Decode(a.dtnasctl,NULL,'-',a.dtnasctl) datanasc
          ,gene0002.fn_mask_cep(v.nrcepend) CEP
          ,v.dsendres##1 rua
          ,decode(v.complend,null,'-',v.complend) complemento
          ,v.nrendere nr
          ,v.nmcidade cidade
          ,v.dsendres##2 bairro
          ,v.cdufresd estado
          ,gene0002.fn_mask_cpf_cnpj(v.nrcpfcjg,1) cpfcong
          ,v.nmconjug nomecong
          ,(SELECT nrdconta
              FROM crapass
              WHERE nrcpfcgc = v.nrcpfcjg
              AND   dtdemiss IS NULL
              AND   cdcooper = v.cdcooper) nrdcontacjg
    FROM crapavt v,
         crapass a
    WHERE v.nrcpfcgc = a.nrcpfcgc (+)
    AND   v.cdcooper = a.cdcooper (+)
    AND   a.dtdemiss IS NULL
    AND v.nrdconta = pr_nrdconta
    AND v.cdcooper = pr_cdcooper
    and v.nrctremp = pr_nrctrato;

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

/* Busca saldos depositos mes atual, semestre e trimestre */
  PROCEDURE pc_consulta_saldo_medio (pr_cdcooper        IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta        IN crapass.nrdconta%TYPE
                                    ,pr_saldo_mes       IN OUT NUMBER
                                    ,pr_saldo_trimestre IN OUT NUMBER
                                    ,pr_saldo_semestre  IN OUT NUMBER) IS

    vr_saldo_mes        NUMBER;
    vr_saldo_trimestre  NUMBER;
    vr_saldo_semestre   NUMBER;
    vr_nrmes            NUMBER;

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
      AND f.dtferiad BETWEEN Trunc(pr_dtmvtolt,'MM') AND pr_dtmvtoan
      AND s.cdcooper = pr_cdcooper
      AND s.nrdconta = pr_nrdconta
      AND s.dtmvtolt <> f.dtferiad
      AND s.dtmvtolt BETWEEN Trunc(pr_dtmvtolt,'MM') AND pr_dtmvtoan
      AND To_Char(dtmvtolt,'D') NOT IN (1,7);

  BEGIN

    /* Salva numero do mes JAN=1, FEV=2, ...*/
    vr_nrmes := To_Char(rw_crapdat.dtmvtolt,'MM');

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

      IF (vr_nrmes IN (1,7)) THEN
        BEGIN

          SELECT Round((vlsmstre##4 + vlsmstre##5 + vlsmstre##6)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      ELSIF (vr_nrmes IN (2,8)) THEN
        BEGIN

          SELECT Round((vlsmstre##1 + vlsmstre##6 + vlsmstre##5)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      ELSIF (vr_nrmes IN (3,9)) THEN
        BEGIN

          SELECT Round((vlsmstre##2 + vlsmstre##1 + vlsmstre##6)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      ELSIF (vr_nrmes IN (4,10)) THEN
        BEGIN

          SELECT Round((vlsmstre##3 + vlsmstre##2 + vlsmstre##1)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      ELSIF (vr_nrmes IN (5,11)) THEN
        BEGIN

          SELECT Round((vlsmstre##4 + vlsmstre##3 + vlsmstre##2)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      ELSE /* 6 ou 12*/
        BEGIN

          SELECT Round((vlsmstre##5 + vlsmstre##4 + vlsmstre##3)/3,2)
            INTO vr_saldo_trimestre
            FROM crapsld
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta;
        END;

      END IF;

    EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      NULL;

    END;

    /* Busca saldo semestre */
    BEGIN
      SELECT Round((vlsmstre##1 + vlsmstre##2 + vlsmstre##3 + vlsmstre##4 + vlsmstre##5 + vlsmstre##6) /6 ,2)
        INTO vr_saldo_semestre
        FROM crapsld
        WHERE cdcooper = pr_cdcooper
          AND nrdconta = pr_nrdconta;
    EXCEPTION
    WHEN OTHERS THEN
      /* Tratar erro */
      NULL;
    END;

  --Retornos
  pr_saldo_mes       := vr_saldo_mes;
  pr_saldo_trimestre := vr_saldo_trimestre;
  pr_saldo_semestre  := vr_saldo_semestre;

  EXCEPTION
    WHEN Others THEN
      NULL;
  END pc_consulta_saldo_medio;

  /* Busca Aplicações */
  PROCEDURE pc_carrega_aplicacoes ( pr_nrdconta  IN crapass.nrdconta%TYPE   --> Conta do associado
                                   ,pr_cdcooper  IN crapcop.cdcooper%TYPE
                                   ,pr_dtmvtolt  IN VARCHAR2                --> Data do movimento
                                   ,pr_flgerlog  IN VARCHAR2                --> Gerar log S/N
                                    -- OUT
                                   ,pr_vlsldapl OUT NUMBER
                                   ,pr_cdcritic OUT PLS_INTEGER             --> Codigo da critica
                                   ,pr_dscritic OUT VARCHAR2) IS            --> Erros do processo

  /* .............................................................................

       Programa: pc_carrega_aplicacoes
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   :
       Data    :                                                    Ultima atualizacao:

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Chamada para ayllosWeb(mensageria)
                   Procedure para carregar dos dados para a TELA_ANALISE_CREDITO

    ............................................................................. */
    -------------------> VARIAVEIS <----------------------
    vr_cdcritic          INTEGER;
    vr_dscritic          VARCHAR2(1000);
    vr_exc_erro          EXCEPTION;

    vr_tab_valores_conta typ_tab_valores_conta;

    -- Variaveis de entrada vindas no xml

    vr_cdoperad          VARCHAR2(100);
    vr_cdagenci          VARCHAR2(100);
    vr_nrdcaixa          VARCHAR2(100);



  PROCEDURE pc_carrega_dados_atenda( pr_cdcooper IN crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo de agencia
                                    ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Codigo do operador
                                    ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da tela
                                    ,pr_idorigem IN INTEGER                --> Identificado de oriem
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequencial do titular
                                    ,pr_flgerlog IN VARCHAR2               --> identificador se deve gerar log S-Sim e N-Nao

                                    ---------- OUT --------

                                    ,pr_tab_valores_conta OUT typ_tab_valores_conta  --> Retorna os valores para a tela ATENDA
                                    ,pr_des_reto          OUT VARCHAR2               --> OK ou NOK
                                    ,pr_tab_erro          OUT gene0001.typ_tab_erro) IS

    ---------------> CURSORES <-----------------
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --------------> TempTable <-----------------
    vr_tab_saldo_rdca         APLI0001.typ_tab_saldo_rdca;

    --------------> VARIAVEIS <-----------------
    vr_cdcritic     INTEGER;
    vr_dscritic     VARCHAR2(1000);
    vr_exc_erro     EXCEPTION;
    vr_tab_erro     gene0001.typ_tab_erro;
    vr_des_reto     VARCHAR2(100);

    vr_dsorigem     VARCHAR2(50);
    vr_dstransa     VARCHAR2(200);
    vr_nrdrowid     ROWID;

    vr_nrdconta     crapass.nrdconta%TYPE;
    vr_vlsldtot     NUMBER   := 0;
    vr_ind          BINARY_INTEGER;
    vr_vlsldapl     NUMBER   := 0;
    vr_vlsldrgt     NUMBER   := 0;
    vr_idxval       PLS_INTEGER;

    BEGIN
    -- Atribuir numero de conta
    vr_nrdconta := pr_nrdconta;

    pr_tab_valores_conta.delete;

    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    vr_dstransa := 'Obter dados para tela ATENDA.';

    -- Leitura do calendário da cooperativa, para alguns procedimentos que precisam
    -- receber como parametro
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    --Obtem Dados Aplicacoes
    APLI0002.pc_obtem_dados_aplicacoes (pr_cdcooper    => pr_cdcooper          --Codigo Cooperativa
                                       ,pr_cdagenci    => pr_cdagenci          --Codigo Agencia
                                       ,pr_nrdcaixa    => pr_nrdcaixa          --Numero do Caixa
                                       ,pr_cdoperad    => pr_cdoperad          --Codigo Operador
                                       ,pr_nmdatela    => pr_nmdatela          --Nome da Tela
                                       ,pr_idorigem    => pr_idorigem          --Origem dos Dados
                                       ,pr_nrdconta    => vr_nrdconta          --Numero da Conta do Associado
                                       ,pr_idseqttl    => pr_idseqttl          --Sequencial do Titular
                                       ,pr_nraplica    => 0                    --Numero da Aplicacao
                                       ,pr_cdprogra    => pr_nmdatela          --Nome da Tela
                                       ,pr_flgerlog    => 0 /*FALSE*/          --Imprimir log
                                       ,pr_dtiniper    => NULL                 --Data Inicio periodo
                                       ,pr_dtfimper    => NULL                 --Data Final periodo
                                       ,pr_vlsldapl    => vr_vlsldtot          --Saldo da Aplicacao
                                       ,pr_tab_saldo_rdca  => vr_tab_saldo_rdca    --Tipo de tabela com o saldo RDCA
                                       ,pr_des_reto    => vr_des_reto          --Retorno OK ou NOK
                                       ,pr_tab_erro    => vr_tab_erro);        --Tabela de Erros
    --Se retornou erro
    IF vr_des_reto = 'NOK' THEN
      --Se possuir erro na temp-table
      IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
          vr_dscritic := 'Não foi possível carregar o aplicações.';
      END IF;

      -- Limpar tabela de erros
      vr_tab_erro.DELETE;

      RAISE vr_exc_erro;
    END IF;

    -- loop sobre a tabela de saldo
    vr_ind := vr_tab_saldo_rdca.first;
    WHILE vr_ind IS NOT NULL LOOP
      -- Somar o valor de resgate
      vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_ind).sldresga;

      vr_ind := vr_tab_saldo_rdca.next(vr_ind);
    END LOOP;

    --> Buscar saldo das aplicacoes
    APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> Código da Cooperativa
                                      ,pr_cdoperad => pr_cdoperad   --> Código do Operador
                                      ,pr_nmdatela => pr_nmdatela   --> Nome da Tela
                                      ,pr_idorigem => pr_idorigem   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                      ,pr_nrdconta => vr_nrdconta   --> Número da Conta
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

    IF nvl(vr_cdcritic,0) <> 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;

    --> Cria TEMP-TABLE com valores referente a conta
    vr_idxval := pr_tab_valores_conta.count + 1;
    pr_tab_valores_conta(vr_idxval).vlsldapl := vr_vlsldapl;

    pr_des_reto := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';

    WHEN OTHERS THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro na rotina CADA0004_RL.pc_carrega_dados_atenda: '||SQLERRM;
      -- Gerar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate
                                                             ,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      pr_des_reto := 'NOK';
  END pc_carrega_dados_atenda;


  BEGIN

    --> Carregar dos dados para a tela ATENDA
    pc_carrega_dados_atenda ( pr_cdcooper => pr_cdcooper  --> Codigo da cooperativa
                              ,pr_cdagenci => vr_cdagenci  --> Codigo de agencia
                              ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa
                              ,pr_cdoperad => vr_cdoperad  --> Codigo do operador
                              ,pr_nmdatela => 'ATENDA'  --> Nome da tela
                              ,pr_idorigem => 1  --> Identificado de oriem
                              ,pr_nrdconta => pr_nrdconta  --> Numero da conta
                              ,pr_idseqttl => 1  --> Sequencial do titular
                              ,pr_flgerlog => pr_flgerlog  --> identificador se deve gerar log S-Sim e N-Nao
                              ---------- OUT --------
                              ,pr_tab_valores_conta => vr_tab_valores_conta  --> Retorna os valores para a tela ATENDA
                              ,pr_des_reto          => vr_des_reto           --> OK ou NOK
                              ,pr_tab_erro          => vr_tab_erro);

   -- dbms_output.put_line('vlsldapl '||vr_tab_valores_conta(1).vlsldapl);

    pr_vlsldapl := vr_tab_valores_conta(1).vlsldapl;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      --Variavel de erro recebe erro ocorrido
      pr_cdcritic := nvl(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN

      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_carrega_aplicacoes ' ||
                     SQLERRM;
  END pc_carrega_aplicacoes;

  /* Procedure para carregar dados da garantia da operação */
  PROCEDURE pc_consulta_garantia_operacao (pr_cdcooper crapass.cdcooper%TYPE
                                          ,pr_nrdconta crapass.nrdconta%TYPE
                                          ,pr_nrctremp crawepr.nrctremp%TYPE
                                          ,pr_retxml   IN OUT NOCOPY xmltype) IS
  /* .............................................................................

       Programa: pc_carrega_aplicacoes
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
    FROM  crawepr w
    WHERE w.cdcooper = pr_cdcooper
    AND   w.nrdconta = pr_nrdconta
    AND   w.nrctremp = pr_nrctremp;
  r_busca_dados_proposta c_busca_dados_proposta%ROWTYPE;

  /*Busca dados do limite quando não for Emprestimo e Financiamento bug 20391*/
  CURSOR c_busca_dados_lim_desctit IS
    SELECT w.cddlinha --linha
          ,w.idcobefe --id efetivacao
          ,w.vllimite
    FROM  crawlim w
    WHERE w.cdcooper = pr_cdcooper
    AND   w.nrdconta = pr_nrdconta
    AND   w.nrctrlim = pr_nrctremp;
  r_busca_dados_lim_desctit c_busca_dados_lim_desctit%ROWTYPE;

  /* 4.2 - Task 16173 - Consultar Garantia Operações */
  PROCEDURE pc_busca_dados(pr_cdcooper     IN crapcop.cdcooper%TYPE
                          ,pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_codlinha     IN INTEGER --> Codigo da linha
                          ,pr_cdfinemp     IN INTEGER --> Código da finalidade
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                          ,pr_retxml       IN OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
  BEGIN

    /* .............................................................................

    Programa: pc_busca_dados
    Sistema : Ayllos Web
    Autor   :
    Data    :                         Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados para tela GAROPC.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Seleciona dados da Linha de Credito
      CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE
                       ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.permingr
              ,craplcr.tpctrato
              ,craplcr.dslcremp deslinha
          FROM craplcr
         WHERE craplcr.cdcooper = pr_cdcooper
           AND craplcr.cdlcremp = pr_cdlcremp;

    -- Verificar se finalidade é de CDC
    CURSOR cr_crapfin(pr_cdcooper IN craplcr.cdcooper%TYPE
             ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
        SELECT 1
        FROM crapfin fin
       WHERE fin.cdcooper = pr_cdcooper
         AND fin.cdfinemp = pr_cdfinemp
         AND (upper(fin.dsfinemp) LIKE '%CDC%' OR upper(fin.dsfinemp) LIKE '%C DC%');
    rw_crapfin cr_crapfin%ROWTYPE;

      -- Seleciona dados da Linha de Credito Rotativo
      CURSOR cr_craplrt(pr_cdcooper IN craplrt.cdcooper%TYPE
                       ,pr_cddlinha IN craplrt.cddlinha%TYPE) IS
        SELECT craplrt.permingr
              ,craplrt.tpctrato
              ,craplrt.dsdlinha deslinha
          FROM craplrt
         WHERE craplrt.cdcooper = pr_cdcooper
           AND craplrt.cddlinha = pr_cddlinha;

      -- Seleciona dados da Linha de Desconto
      CURSOR cr_crapldc(pr_cdcooper IN crapldc.cdcooper%TYPE
                       ,pr_cddlinha IN crapldc.cddlinha%TYPE
                       ,pr_tpdescto IN crapldc.tpdescto%TYPE) IS
        SELECT crapldc.permingr
              ,crapldc.tpctrato
              ,crapldc.dsdlinha deslinha
          FROM crapldc
         WHERE crapldc.cdcooper = pr_cdcooper
           AND crapldc.cddlinha = pr_cddlinha
           AND crapldc.tpdescto = pr_tpdescto;
      rw_linha cr_crapldc%ROWTYPE;

      -- Seleciona parametro de configuracao geral
      CURSOR cr_param(pr_cdcooper IN crapldc.cdcooper%TYPE) IS
        SELECT tpg.inresgate_automatico
              ,tpg.peminimo_cobertura
              ,tpg.qtdias_atraso_permitido
          FROM tbgar_parame_geral tpg
         WHERE tpg.cdcooper = pr_cdcooper;
      rw_param cr_param%ROWTYPE;

      -- Seleciona garantias para operacoes de credito
      CURSOR cr_cobertura(pr_idcobert IN tbgar_cobertura_operacao.idcobertura%TYPE) IS
        SELECT tco.inresgate_automatico
              ,tco.perminimo
              ,tco.inaplicacao_propria
              ,tco.inpoupanca_propria
              ,tco.nrconta_terceiro
              ,tco.inaplicacao_terceiro
              ,tco.inpoupanca_terceiro
              ,tco.cdoperador_desbloq
              ,tco.dtdesbloq
              ,tco.vldesbloq
          FROM tbgar_cobertura_operacao tco
         WHERE tco.idcobertura = pr_idcobert;
      rw_cobertura cr_cobertura%ROWTYPE;

      -- Seleciona associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nmprimtl
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      -- Seleciona operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT crapope.nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;


      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis locais
      vr_blnachou                BOOLEAN;
      vr_permingr                NUMBER;
      vr_vlgarnec                NUMBER;
      vr_lablinha                VARCHAR2(25);
      vr_labgaran                VARCHAR2(25);
      vr_vlsaldo_aplica          NUMBER;
      vr_vlsaldo_poupa           NUMBER;
      vr_vlsaldo_aplica_terceiro NUMBER;
      vr_vlsaldo_poup_terceiro   NUMBER;
      vr_inresgate_permitido     INTEGER;
      vr_inresgate_automatico    INTEGER;
      vr_qtdias_atraso_permitido INTEGER;
      vr_inaplicacao_propria     NUMBER;
      vr_inpoupanca_propria      NUMBER;
      vr_nrconta_terceiro        NUMBER;
      vr_nmprimtl_terceiro       crapass.nmprimtl%TYPE;
      vr_inaplicacao_terceiro    NUMBER;
      vr_inpoupanca_terceiro     NUMBER;
      vr_desdesbloq              VARCHAR2(200);
      vr_dtdesbloq               DATE;
      vr_cdoperador_desbloq      VARCHAR2(10);
      vr_vldesbloq               NUMBER;
      vr_flgfincdc               NUMBER := 0;

    BEGIN

      -- Se for Emprestimo/Financiamento
      IF pr_tpctrato = 90 THEN
        -- Seleciona dados da Linha de Credito
        OPEN cr_craplcr(pr_cdcooper => pr_cdcooper
                       ,pr_cdlcremp => pr_codlinha);
        FETCH cr_craplcr INTO rw_linha;
        vr_blnachou := cr_craplcr%FOUND;
        CLOSE cr_craplcr;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Crédito, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;

    -- Verificar se finalidade é de CDC
    OPEN cr_crapfin(pr_cdcooper => pr_cdcooper
                       ,pr_cdfinemp => pr_cdfinemp);
        FETCH cr_crapfin INTO rw_crapfin;

        -- Se encontrou
        IF cr_crapfin%FOUND THEN
      -- Encontrou finalidade de CDC
      vr_flgfincdc := 1;
    END IF;
    CLOSE cr_crapfin;
      -- Se for Cheque Especial
      ELSIF pr_tpctrato = 1 THEN
        -- Seleciona dados da Linha de Credito Rotativo
        OPEN cr_craplrt(pr_cdcooper => pr_cdcooper
                       ,pr_cddlinha => pr_codlinha);
        FETCH cr_craplrt INTO rw_linha;
        vr_blnachou := cr_craplrt%FOUND;
        CLOSE cr_craplrt;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Crédito Rotativo, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;

      -- Se for Desconto Cheques ou Desconto Titulos
      ELSE
        -- Seleciona dados da Linha de Desconto
        OPEN cr_crapldc(pr_cdcooper => pr_cdcooper
                       ,pr_cddlinha => pr_codlinha
                       ,pr_tpdescto => pr_tpctrato);
        FETCH cr_crapldc INTO rw_linha;
        vr_blnachou := cr_crapldc%FOUND;
        CLOSE cr_crapldc;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Problema na checagem da Linha de Desconto, favor preencher uma linha correta!';
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Seleciona parametro de configuracao geral
      OPEN cr_param(pr_cdcooper => pr_cdcooper);
      FETCH cr_param INTO rw_param;
      vr_blnachou := cr_param%FOUND;
      CLOSE cr_param;
      -- Se NAO achou
      IF NOT vr_blnachou THEN
        vr_dscritic := 'Problema na recuperação da parametrização geral, operação não poderá ser continuada!';
        RAISE vr_exc_erro;
      END IF;

      -- Carrega os parametros gerais
      vr_permingr := rw_param.peminimo_cobertura;
      vr_inresgate_permitido := rw_param.inresgate_automatico;
      vr_qtdias_atraso_permitido := rw_param.qtdias_atraso_permitido;

      -- Se NAO for Limite de Credito ou Emprestimo/Financiamento
      IF NOT pr_tpctrato IN (1, 90) THEN
        vr_inresgate_permitido := 0;
        vr_qtdias_atraso_permitido := 0;
      END IF;

      -- Se for uma linha com Modelo = 4 (Aplicacao)
      IF rw_linha.tpctrato = 4 THEN
        vr_permingr := rw_linha.permingr;
        vr_labgaran := 'Garantia Obrigatória:';
        -- Se for inclusao e parametro geral de resgate for sim
/*        IF pr_tipaber = 'I' AND vr_inresgate_permitido = 1 THEN
           vr_inresgate_automatico := 0;
        END IF;
*/      ELSE
        vr_labgaran := 'Garantia Sugerida:';
        vr_inresgate_permitido := 0;
      END IF;

      if (pr_idcobert <> 0) THEN
        -- Seleciona garantias para operacoes de credito
        OPEN cr_cobertura(pr_idcobert => pr_idcobert);
        FETCH cr_cobertura INTO rw_cobertura;
        vr_blnachou := cr_cobertura%FOUND;
        CLOSE cr_cobertura;
        -- Se NAO achou
        IF NOT vr_blnachou THEN
          vr_dscritic := 'Erro ao buscar Cobertura cadastrada anteriormente, favor tentar novamente!';
          RAISE vr_exc_erro;
        END IF;

        -- Carrega as variaveis
        vr_inresgate_automatico := rw_cobertura.inresgate_automatico;
        vr_inaplicacao_propria  := rw_cobertura.inaplicacao_propria;
        vr_inpoupanca_propria   := rw_cobertura.inpoupanca_propria;
        vr_nrconta_terceiro     := rw_cobertura.nrconta_terceiro;
        vr_inaplicacao_terceiro := rw_cobertura.inaplicacao_terceiro;
        vr_inpoupanca_terceiro  := rw_cobertura.inpoupanca_terceiro;
        vr_cdoperador_desbloq   := rw_cobertura.cdoperador_desbloq;
        vr_dtdesbloq            := rw_cobertura.dtdesbloq;
        vr_vldesbloq            := NVL(rw_cobertura.vldesbloq,0);
    IF rw_linha.tpctrato <> 4 THEN
           vr_permingr             := rw_cobertura.perminimo;
    END IF;


          -- Se houve desbloqueio
          IF vr_vldesbloq > 0 THEN

            -- Seleciona operador
            OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => vr_cdoperador_desbloq);
            FETCH cr_crapope INTO rw_crapope;
            CLOSE cr_crapope;

            vr_desdesbloq := '*** Liberação de R$ '
                          || TO_CHAR(vr_vldesbloq,'FM999G999G999G990D00')
                          || ' em ' || TO_CHAR(vr_dtdesbloq,'DD/MM/RRRR')
                          || ' por ' || vr_cdoperador_desbloq || '-'
                          || rw_crapope.nmoperad;
          END IF;

      END IF; --idcobert=0

      -- Valor da garantia necessaria
      vr_vlgarnec := pr_vlropera * (vr_permingr / 100);

      -- Busca os saldos da conta
      BLOQ0001.pc_retorna_saldos_conta(pr_cdcooper       => pr_cdcooper
                                      ,pr_nrdconta       => pr_nrdconta
                                      ,pr_tpctrato       => pr_tpctrato
                                      ,pr_nrctaliq       => pr_nrdconta
                                      ,pr_dsctrliq       => pr_dsctrliq
                                      ,pr_vlsaldo_aplica => vr_vlsaldo_aplica
                                      ,pr_vlsaldo_poupa  => vr_vlsaldo_poupa
                                      ,pr_dscritic       => vr_dscritic);
      -- Se ocorreu erro
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Seta conta de terceiro
      vr_nrconta_terceiro := NVL(vr_nrconta_terceiro,0);

      -- Se possui conta de terceiro
      IF vr_nrconta_terceiro > 0 THEN
        -- Busca os saldos da conta do terceiro
        BLOQ0001.pc_retorna_saldos_conta(pr_cdcooper       => pr_cdcooper
                                        ,pr_nrdconta       => vr_nrconta_terceiro
                                        ,pr_tpctrato       => pr_tpctrato
                                        ,pr_nrctaliq       => pr_nrdconta
                                        ,pr_dsctrliq       => pr_dsctrliq
                                        ,pr_vlsaldo_aplica => vr_vlsaldo_aplica_terceiro
                                        ,pr_vlsaldo_poupa  => vr_vlsaldo_poup_terceiro
                                        ,pr_dscritic       => vr_dscritic);
        -- Se ocorreu erro
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Seleciona associado
        OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => vr_nrconta_terceiro);
        FETCH cr_crapass INTO vr_nmprimtl_terceiro;
        CLOSE cr_crapass;
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
                            ,pr_tag_nova => 'vloperac'
                            ,pr_tag_cont => pr_vlropera
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'lintpctr'
                            ,pr_tag_cont => rw_linha.tpctrato
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'labgaran'
                            ,pr_tag_cont => vr_labgaran
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'lablinha'
                            ,pr_tag_cont => vr_lablinha
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'deslinha'
                            ,pr_tag_cont => rw_linha.deslinha
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'permingr'
                            ,pr_tag_cont => TO_CHAR(vr_permingr,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlgarnec'
                            ,pr_tag_cont => TO_CHAR(vr_vlgarnec,'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'desbloqu'
                            ,pr_tag_cont => TRIM(vr_desdesbloq)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inaplpro'
                            ,pr_tag_cont => NVL(vr_inaplicacao_propria,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlaplpro'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_aplica,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inpoupro'
                            ,pr_tag_cont => NVL(vr_inpoupanca_propria,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpoupro'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_poupa,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inresaut'
                            ,pr_tag_cont => NVL(vr_inresgate_automatico,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inresper'
                            ,pr_tag_cont => vr_inresgate_permitido
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'diatrper'
                            ,pr_tag_cont => vr_qtdias_atraso_permitido
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inaplter'
                            ,pr_tag_cont => NVL(vr_inaplicacao_terceiro,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlaplter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_aplica_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'inpouter'
                            ,pr_tag_cont => NVL(vr_inpoupanca_terceiro,0)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'vlpouter'
                            ,pr_tag_cont => TO_CHAR(NVL(vr_vlsaldo_poup_terceiro,0),'FM999G999G999G990D00')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nrctater'
                            ,pr_tag_cont => (CASE WHEN vr_nrconta_terceiro > 0 THEN vr_nrconta_terceiro ELSE '' END)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmctater'
                            ,pr_tag_cont => (CASE WHEN vr_nrconta_terceiro > 0 THEN vr_nmprimtl_terceiro ELSE '' END)
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'flgfincdc'
                            ,pr_tag_cont => nvl(vr_flgfincdc,0)
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
        pr_dscritic := 'Erro geral na rotina da tela GAROPC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_dados;

  BEGIN

    /*Se o produto for Emprestimo e Financiamento*/
    if (pr_tpproduto = 2) then
  
  /* Busca dados da proposta de emprestimo */
  open c_busca_dados_proposta;
  fetch c_busca_dados_proposta into r_busca_dados_proposta;
       if c_busca_dados_proposta%found then

  pc_busca_dados(pr_cdcooper => pr_cdcooper,
                 pr_idcobert => r_busca_dados_proposta.idcobefe,
                 pr_nrdconta => pr_nrdconta,
                 pr_tpctrato => 90,
                 pr_codlinha => r_busca_dados_proposta.cdlcremp,
                 pr_cdfinemp => r_busca_dados_proposta.cdfinemp,
                 pr_vlropera => r_busca_dados_proposta.vlemprst,
                 pr_dsctrliq => pr_dsctrliq,
                 pr_retxml   => pr_retxml);

       end if;
      close c_busca_dados_proposta;
      
    else
      open c_busca_dados_lim_desctit;
       fetch c_busca_dados_lim_desctit into r_busca_dados_lim_desctit;

       if c_busca_dados_lim_desctit%found then
        
         pc_busca_dados(pr_cdcooper => pr_cdcooper,
                        pr_idcobert => r_busca_dados_lim_desctit.idcobefe,
                        pr_nrdconta => pr_nrdconta,
                        pr_tpctrato => 3, --limite de desconto de título
                        pr_codlinha => r_busca_dados_lim_desctit.cddlinha,
                        pr_cdfinemp => 0,
                        pr_vlropera => r_busca_dados_lim_desctit.vllimite,
                        pr_dsctrliq => pr_dsctrliq,
                        pr_retxml   => pr_retxml);

       end if;

       
      close c_busca_dados_lim_desctit; 
    end if;

  END pc_consulta_garantia_operacao;

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

  /* Separa a garantia pessoal pois não é obrigatória */
  vr_string_garantia_pessoal := vr_string_garantia_pessoal || '<subcategoria>'||
                                                              '<tituloTela>Garantia Pessoal</tituloTela><campos>';

  /*Verifica se o contrato possui avalistas*/
  DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagenci => 0  --> Código da agencia
                               ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                               ,pr_cdoperad => 1  --> Código do Operador
                               ,pr_nmdatela => 'ATENDA'  --> Nome da tela
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
                               ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica
  
  /*Se tiver avalistas*/
  IF vr_tab_dados_avais.count > 0 THEN
  LOOP
    
    vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
    '<campo><nome>AVALISTA '||vr_index_aval||'</nome><tipo>info</tipo><valor>'||
    vr_tab_dados_avais(vr_index_aval).nrctaava||'</valor></campo>';
  
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

      end if;
    close c_garantia_pessoal_pf;

    /* Fim Garantia Pessoal*/

    /* Se tiver Cônjuge busca idPessoaConjuge */
    open c_conjuge(vr_idpessoa);
     fetch c_conjuge into vr_idpessoa_conjuge;
      if c_conjuge%found then

        vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
        '<campo><nome>Cônjuge</nome><tipo>info</tipo><valor></valor></campo>';

        /* Possui cônjuge, busca CPF*/
        open c_buscacpf_conjuge (vr_idpessoa_conjuge);
         fetch c_buscacpf_conjuge into vr_cpfconjuge;
          if c_buscacpf_conjuge%found then

            /* Verifica se é cooperado através do CPF - consulta crapass*/
            open c_verifica_conjuge_coop(vr_cpfconjuge);
             fetch c_verifica_conjuge_coop into r_verifica_conjuge_coop;
              if c_verifica_conjuge_coop%notfound then

                /* Cônjuge não é cooperado*/
                OPEN c_consultaconjuge_naocoop (pr_cdcooper => pr_cdcooper
                                                 ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
                FETCH c_consultaconjuge_naocoop INTO r_consultaconjuge_naocoop;
                  IF c_consultaconjuge_naocoop%FOUND THEN
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                               r_consultaconjuge_naocoop.conta||
                               r_consultaconjuge_naocoop.cpf||
                               r_consultaconjuge_naocoop.nome||
                               r_consultaconjuge_naocoop.rendimento||
                               r_consultaconjuge_naocoop.endiv;
                END IF;
                CLOSE c_consultaconjuge_naocoop;

              else
                /* Cônjuge é cooperado*/
                OPEN c_consultaconjuge_coop (pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
                FETCH c_consultaconjuge_coop INTO r_consultaconjuge_coop;
                  IF c_consultaconjuge_coop%FOUND THEN
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
                      vr_string_garantia_pessoal := vr_string_garantia_pessoal || fn_tag('Capital Cônjuge','-');
                  ELSE
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal||vr_vldcotas;
                  END IF;
                close c_consulta_valor_capital;

                /* Consulta Saldos Médios (Mensal, Trimestral e Semestral) */
                pc_consulta_saldo_medio(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => vr_nrdcontacjg
                                       ,pr_saldo_mes => vr_saldo_mes
                                       ,pr_saldo_trimestre => vr_saldo_semestre
                                       ,pr_saldo_semestre => vr_saldo_semestre);
                /*Cria XML Mes Atual*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo Médio Mes atual Cônjuge',vr_saldo_mes);
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo Médio Trimestral Cônjuge',vr_saldo_trimestre);
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal
                                             ||fn_tag('Saldo Médio Semestral Cônjuge',
                                                             case when vr_saldo_semestre > 0 then to_char(vr_saldo_semestre,'999g999g990d00') else '-' end);

                /* Carrega o valor das aplicações PF e PJ */
                pc_carrega_aplicacoes(pr_nrdconta => vr_nrdcontacjg,
                                      pr_cdcooper => pr_cdcooper,
                                      pr_dtmvtolt => null,
                                      pr_flgerlog => null,
                                      pr_vlsldapl => vr_vldaplica,
                                      pr_cdcritic => vr_cdcritic,
                                      pr_dscritic => vr_dscritic);

                vr_string_garantia_pessoal:=vr_string_garantia_pessoal||fn_tag('Aplicacoes Cônjuge',vr_vldaplica);

                /* Co-responsabilidade */
                vr_string_garantia_pessoal := vr_string_garantia_pessoal||'<campo>
                                         <nome>Co-responsabilidade</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
                vr_index := 1;
                vr_tab_tabela.delete;
                for r_correspo in c_contas_avalisadas(pr_cdcooper => pr_cdcooper
                                                       ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava) loop
                 vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(r_correspo.nrctravd);
                 vr_tab_tabela(vr_index).coluna2 := gene0002.fn_mask_conta(r_correspo.nrctaavd);
                 vr_tab_tabela(vr_index).coluna3 := r_correspo.nmprimtl;
                 vr_index := vr_index+1;
                end loop;

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

  vr_string_garantia_pessoal := vr_string_garantia_pessoal||'</campos></subcategoria>';

  /* 4.2 - Aplicações - Task 16173 */

  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Garantia Aplicação</tituloTela>'||
                          '<campos>';

  pc_consulta_garantia_operacao(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctrato
                               ,pr_retxml   => pr_retxml);
  /* Extrai dados do XML */
  BEGIN
    vr_permingr := pr_retxml.extract('//Dados/permingr/node()').getstringval();--Garantia Sugerida %
    vr_vlgarnec := pr_retxml.extract('//Dados/vlgarnec/node()').getstringval();--Garantia Sugerida Valor
    --
    vr_inaplpro := pr_retxml.extract('//Dados/inaplpro/node()').getstringval();--Flag Aplicação
    vr_vlaplpro := pr_retxml.extract('//Dados/vlaplpro/node()').getstringval();--Saldo Aplicação
    vr_inpoupro := pr_retxml.extract('//Dados/inpoupro/node()').getstringval();--Flag Poupança Programada
    vr_vlpoupro := pr_retxml.extract('//Dados/vlpoupro/node()').getstringval();--Saldo Poupança Programada
    vr_inresaut := pr_retxml.extract('//Dados/inresaut/node()').getstringval();--Resgate Automatico

    vr_nrctater := pr_retxml.extract('//Dados/nrctater/node()').getstringval();
    vr_inaplter := pr_retxml.extract('//Dados/inaplter/node()').getstringval();
    vr_inpouter := pr_retxml.extract('//Dados/inpouter/node()').getstringval();
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END;
  /* Gera os campos do XML*/
  vr_string := vr_string ||'<campo>
                             <tipo>h3</tipo>
                             <valor>Operação</valor>
                            </campo>';
  
  
  vr_string := vr_string || fn_tag('Garantia Sugerida',
                            case when vr_permingr > 0 then vr_permingr || '%' else '-' end);
  vr_string := vr_string || fn_tag('Garantia Sugerida Valor', 
                            case when vr_vlgarnec not like '0%' then vr_vlgarnec else '-' end);
                            
  vr_string := vr_string ||'<campo>
                             <tipo>h3</tipo>
                             <valor>Aplicação Própria</valor>
                            </campo>';                            
  --
  vr_string := vr_string || fn_tag('Aplicação', case when vr_inaplpro = 0 Then '-' Else 'Sim' end);
  vr_string := vr_string || fn_tag('Saldo Disponível Aplicação', 
                            case when vr_vlaplpro not like '0%' then vr_vlaplpro else '-' end);
  vr_string := vr_string || fn_tag('Poupança Programada',case when vr_inpoupro =0 Then '-' Else 'Sim' end);
  vr_string := vr_string || fn_tag('Saldo Disponível Poupança',
                            case when vr_vlpoupro not like '0%' then vr_vlpoupro else '-' end);
  vr_string := vr_string || fn_tag('Resgate Automático',case when vr_inresaut =0 Then '-' Else 'Sim' end);
  --
  vr_string := vr_string ||'<campo>
                             <tipo>h3</tipo>
                             <valor>Aplicação de Terceiro</valor>
                            </campo>';    
  
  --Terceiro
  vr_string := vr_string || fn_tag('Conta Terceiro',gene0002.fn_mask_conta(vr_nrctater));
  vr_string := vr_string || fn_tag('Aplicação',case when vr_inaplter =0 Then '-' Else 'Sim' end);
  vr_string := vr_string || fn_tag('Poupança Programada',case when vr_inpouter =0 Then '-' Else 'Sim' end);

  --Fim
  vr_string := vr_String || '</campos></subcategoria>';

  /*Bug 19842 - Regra para apresentar garantia pessoal apenas quando necessário*/
  if (length(vr_string_garantia_pessoal) > 0) then
    vr_string := vr_string_cabec || vr_string_garantia_pessoal || vr_string;
  else
    vr_string := vr_string_cabec || vr_string;
  end if;

  /* Fim do 4.2 - Aplicações*/
  /* 4.3 GARANTIA REAL */

  /* 4.3.1 - Alienação Fiduciária - Veiculos */
    vr_string := vr_string||'<subcategoria>
                            <tituloTela>Alienacão Fiduciária</tituloTela>
                            <campos>';

   /*Intervenientes apresentados em tabela*/
   vr_string := vr_string||'<campo>
                            <nome>Veículo</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
   vr_index := 1;
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
     vr_tab_tabela(vr_index).coluna4 := to_char(r_alienacoes.valormercado,'999g999g990d00');
     vr_tab_tabela(vr_index).coluna5 := to_char(r_alienacoes.valorfipe,'999g999g990d00');
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
     vr_index := vr_index+1;

  end loop;

  if vr_tab_tabela.COUNT > 0 then
    vr_string := vr_string||fn_tag_table('Tipo Veiculo;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;Número Placa;Renavam;Chassi;Tipo de Chassi;Ano de Fábrica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
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
    vr_string := vr_string||fn_tag_table('Tipo Veiculo;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;Número Placa;Renavam;Chassi;Tipo de Chassi;Ano de Fábrica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

   /*TABELA*/
   vr_string := vr_string||'<campo>
                            <nome>Máquina e Equipamento</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
   vr_index := 1;
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
     vr_tab_tabela(vr_index).coluna8 := to_char(r_alienacoes.valormercado,'999g999g9990d00');
     vr_tab_tabela(vr_index).coluna9 := gene0002.fn_mask_cpf_cnpj(
                                                  r_alienacoes.cpfbem,
                                                    CASE WHEN 
                                                      LENGTH(r_alienacoes.cpfbem) > 11 THEN 2 ELSE 1
                                                    END
                                                    );
     
     vr_index := vr_index+1;
  end loop;

  if vr_tab_tabela.COUNT > 0 then
    /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Categoria;Descrição;Marca;Modelo;Nota;Número de Série;Ano do Modelo;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
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
    vr_string := vr_string||fn_tag_table('Categoria;Descrição;Marca;Modelo;Nota;Número de Série;Ano do Modelo;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

  -- vr_string := vr_string||'</campos></subcategoria>';

  /* FIM 4.3.2 - Alienação Fiduciária - Maquina e Equipamento */

  /* 4.3.3 - Alienação Fiduciaria - Imóveis */
/*   vr_string := vr_string||'<subcategoria>
                            <tituloTela>Alienacao Fiduciaria</tituloTela>
                            <campos>';
*/
   vr_string := vr_string||'<campo>
                            <nome>Imóveis (Casa, Apartamento, Terreno, Galpão)</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';
   vr_index := 1;
   vr_tab_tabela.delete;
  for r_alienacoes in c_busca_alienacao_imoveis (pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_nrctpro  => pr_nrctrato) loop

    vr_tab_tabela(vr_index).coluna1 := r_alienacoes.classificacao;
    vr_tab_tabela(vr_index).coluna2 := r_alienacoes.categoria;
    vr_tab_tabela(vr_index).coluna3 := to_char(r_alienacoes.valormercado,'999g999g990d00'); --bug 20565
    vr_tab_tabela(vr_index).coluna4 := to_char(r_alienacoes.valorvenda,'999g999g990d00');   --bug 20565
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

  vr_index := vr_index+1;

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

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';

  vr_string := vr_string||'</campos></subcategoria>';

  /* FIM 4.3.3 - Alienação Fiduciaria - Imóveis */

  /* INTERVENIENTE ANUENTE */

  /* Chama interveniente quando categoria correta*/
  if (vr_isinterv) then
    vr_string := vr_string||'<subcategoria>
                             <tituloTela>Interveniente Anuente</tituloTela>
                             <campos>';

    /*Intervenientes apresentados em tabela*/
    vr_string := vr_string||'<campo>
                             <nome>Interveniente Anuente</nome>
                             <tipo>table</tipo>
                             <valor>
                             <linhas>';

    vr_string_cong := '<campo>
                       <nome>Conjuge do Interveniente</nome>
                       <tipo>table</tipo>
                       <valor>
                       <linhas>';

    vr_index := 1;
    vr_tab_tabela.delete;
    vr_tab_tabela_secundaria.delete;

    for r_interveniente in c_consulta_interv_anuente(pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => pr_nrdconta) loop
    vr_inpessoaI := r_interveniente.inpessoainterv;

     /*Interveniente PF*/
     if (vr_inpessoaI = 1) then
       vr_tab_tabela(vr_index).coluna1 := r_interveniente.conta;
       vr_tab_tabela(vr_index).coluna2 := r_interveniente.inpessoa;
       vr_tab_tabela(vr_index).coluna3 := r_interveniente.cpf;
       vr_tab_tabela(vr_index).coluna4 := r_interveniente.nome;
       vr_tab_tabela(vr_index).coluna5 := r_interveniente.nacionalidade;
       vr_tab_tabela(vr_index).coluna6 := r_interveniente.datanasc;
       --Endereço
       vr_tab_tabela(vr_index).coluna7 := r_interveniente.cep;
       vr_tab_tabela(vr_index).coluna8 := r_interveniente.rua;
       vr_tab_tabela(vr_index).coluna9 := r_interveniente.complemento;
       vr_tab_tabela(vr_index).coluna10 := r_interveniente.nr;
       vr_tab_tabela(vr_index).coluna11 := r_interveniente.cidade;
       vr_tab_tabela(vr_index).coluna12 := r_interveniente.bairro;
       vr_tab_tabela(vr_index).coluna13 := r_interveniente.estado;
       --Dados do Cônjuge do Interveniente
       vr_tab_tabela_secundaria(vr_index).coluna1 := r_interveniente.cpfcong;
       vr_tab_tabela_secundaria(vr_index).coluna2 := r_interveniente.nomecong;
       vr_tab_tabela_secundaria(vr_index).coluna3 := gene0002.fn_mask_conta(r_interveniente.nrdcontacjg);
       
     else
       /*Interveniente PJ*/
       vr_tab_tabela(vr_index).coluna1 := r_interveniente.conta;
       vr_tab_tabela(vr_index).coluna2 := r_interveniente.inpessoa;
       vr_tab_tabela(vr_index).coluna3 := r_interveniente.cpf;
       vr_tab_tabela(vr_index).coluna4 := r_interveniente.nome;
       vr_tab_tabela(vr_index).coluna5 := r_interveniente.datanasc;
       vr_tab_tabela(vr_index).coluna6 := r_interveniente.cep;
       vr_tab_tabela(vr_index).coluna7 := r_interveniente.rua;
       vr_tab_tabela(vr_index).coluna8 := r_interveniente.complemento;
       vr_tab_tabela(vr_index).coluna9 := r_interveniente.nr;
       vr_tab_tabela(vr_index).coluna10 := r_interveniente.cidade;
       vr_tab_tabela(vr_index).coluna11 := r_interveniente.bairro;
       vr_tab_tabela(vr_index).coluna12 := r_interveniente.estado;
     end if;
     vr_index := vr_index+1;

  end loop;

  if vr_tab_tabela.COUNT > 0 then
    /*Interveniente PF*/
    if (vr_inpessoaI = 1) then
       vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF;Nome;Nacionalidade;Data de Nascimento;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado',vr_tab_tabela);
       vr_string_cong := vr_string_cong || fn_tag_table('CPF do Cônjuge;Nome do Cônjuge;Conta do Cônjuge',vr_tab_tabela_secundaria);
    /*Interveniente PJ*/
    else
       vr_string := vr_string||fn_tag_table('Conta;Tipo;CNPJ;Nome;Data de Abertura da Empresa;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado',vr_tab_tabela);
    end if;
  
  else
    /*Tabela Vazia Pessoa Fisica*/
    if (r_pessoa.inpessoa = 1) then
      vr_tab_tabela(1).coluna1 := '-'; vr_tab_tabela(1).coluna2 := '-'; vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-'; vr_tab_tabela(1).coluna5 := '-'; vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-'; vr_tab_tabela(1).coluna8 := '-'; vr_tab_tabela(1).coluna9 := '-';
      vr_tab_tabela(1).coluna10 := '-'; vr_tab_tabela(1).coluna11 := '-'; vr_tab_tabela(1).coluna12 := '-';
      vr_tab_tabela(1).coluna13 := '-';
      --vr_tab_tabela(1).coluna14 := '-'; vr_tab_tabela(1).coluna15 := '-'; vr_tab_tabela(1).coluna16 := '-';
      vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF;Nome;Nacionalidade;Data de Nascimento;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado;Cpf do Cônjuge;Nome do Cônjuge;Conta do Cônjuge',vr_tab_tabela);
    else /*Tabela vazia Pessoa Juridica*/
      vr_tab_tabela(1).coluna1 := '-'; vr_tab_tabela(1).coluna2 := '-'; vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-'; vr_tab_tabela(1).coluna5 := '-'; vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-'; vr_tab_tabela(1).coluna8 := '-'; vr_tab_tabela(1).coluna9 := '-';
      vr_tab_tabela(1).coluna10 := '-'; vr_tab_tabela(1).coluna11 := '-'; vr_tab_tabela(1).coluna12 := '-';
      vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF;Razão Social;Data de Abertuda da Empresa;CEP;Rua;Complemento;Número;Cidade;Bairro;Estado',vr_tab_tabela);
    end if;

  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';
   --Inclui dados do cong
   IF vr_tab_tabela_secundaria.count > 0 THEN
     vr_string := vr_string || vr_string_cong;
     vr_string := vr_string||'</linhas>
                              </valor>
                              </campo>';

   END IF;

   
   vr_string := vr_string || '</campos>';

  vr_string := vr_string||'</subcategoria>';
  end if; --vr_isinterv=true

  -- Escrever no XML
  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                 pr_texto_completo => vr_dstexto,
                 pr_texto_novo     => vr_string,
                 pr_fecha_xml      => TRUE);

  -- Cria o XML a ser retornado
  pr_dsxmlret := vr_dsxmlret;
  
 EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_garantia: '||sqlerrm;  
  END pc_consulta_garantia;


  PROCEDURE pc_consulta_scr(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                           ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                           ,pr_persona  IN Varchar2
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
 
  CURSOR c_crapcbd(pr_nrconbir crapass.nrcpfcgc%type,
                   pr_nrseqdet crapvop.cdmodali%type) is
   SELECT fn_tag('Data da Consulta', to_char(crapcbd.dtconbir,'DD/MM/YYYY')) dataconsulta, --bug 20392
           fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'Não','Sim')) reaproveitamento,
           fn_tag('Data-base Bacen', to_char(crapcbd.dtreapro,'DD/MM/YYYY')) databasebacen, -- Data base bacen
           fn_tag('Quantidade de Operações', NVL(temp.qtopescr,crapcbd.qtopescr)) qtoperacoes, -- Qt. Operações
           fn_tag('Quantidade de Instituições Financeiras', NVL(temp.qtifoper,crapcbd.qtifoper)) qtifs, -- Qt. IFs
           fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', to_char(NVL(temp.vltotsfn,crapcbd.vltotsfn),'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
           fn_tag('Operações Vencidas', to_char(NVL(temp.vlopescr,crapcbd.vlopescr),'999g999g990d00')) vencidas, -- Op.Vencidas
           fn_tag('Operações de Prejuízo', to_char(NVL(temp.vlprejui,crapcbd.vlprejui),'999g999g990d00')) prejuizo,  -- Op.Prejuízo
           fn_tag('Operações Vencidas nos últimos 12 meses', to_char(NVL(crapcbd.vlprejme,temp.vlopesme),'999g999g990d00')) vencidas12meses, -- Op.Vencidas ultimos 12 meses
           fn_tag('Operações de Prejuízo nos últimos 12 meses', to_char(NVL(crapcbd.vlopesme,temp.vlprejme),'999g999g990d00')) prejuizo12meses  -- Op.Prejuízo ultimos 12 meses
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
         AND crapcbd.nrseqdet = pr_nrseqdet
         AND crapbir.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdbircon = crapcbd.cdbircon
         AND crapmbr.cdmodbir = crapcbd.cdmodbir
         AND crapcbd.cdcooper = temp.cdcooper (+)
         AND crapcbd.nrdconta = temp.nrdconta (+);         
  r_crapcbd c_crapcbd%rowtype;
  --
  CURSOR cr_modalidade(pr_nrconbir crapass.nrcpfcgc%type,
                       pr_nrseqdet crapvop.cdmodali%type) IS
    SELECT 'Modalidade - '||a.cdmodbir||' - '||REPLACE(SUBSTR(to_char(a.xmlmodal),2,INSTR(to_char(a.xmlmodal),'>')-2),'_',' ') Modalidade
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_31D_60D'||'>[^<]*'),'<'||'VPERCVE_31D_60D'||'>',null),'.',',') VPERCVE_31D_60D
          ,REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_61D_90D'||'>[^<]*'),'<'||'VPERCVE_61D_90D'||'>',null),'.',',') VPERCVE_61D_90D
     FROM tbgen_modalidade_biro a
    WHERE a.nrconbir = pr_nrconbir--2735256
      AND a.nrseqdet = pr_nrseqdet;                       
/*    SELECT a.nrcpfcgc
          ,SUBSTR(LPAD(a.cdmodbir,4,0),1,2) cdmodali
          ,b.dsmodali
          ,SUM(REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_31D_60D'||'>[^<]*'),'<'||'VPERCVE_31D_60D'||'>',null),'.',',')) VPERCVE_31D_60D
          ,SUM(REPLACE(REPLACE(regexp_substr(to_char(a.xmlmodal),'<'||'VPERCVE_61D_90D'||'>[^<]*'),'<'||'VPERCVE_61D_90D'||'>',null),'.',',')) VPERCVE_61D_90D
      FROM tbgen_modalidade_biro a
          ,gnmodal b
     WHERE a.nrconbir = pr_nrconbir
       AND a.nrseqdet = pr_nrseqdet
       AND b.cdmodali = SUBSTR(LPAD(a.cdmodbir,4,0),1,2)
     GROUP by a.nrcpfcgc
          ,SUBSTR(LPAD(a.cdmodbir,4,0),1,2)
          ,b.dsmodali
     ORDER BY SUBSTR(LPAD(a.cdmodbir,4,0),1,2);*/
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
    
    --Leitura do XML de retorno do motor apenas para o proponente     
    if pr_persona = 'Proponente' then                 
    
    -- Resumo das Informações do Titular             
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>Resumo das Informações do Titular</tituloTela>'||
                               '<campos>';             
                 
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    
    OPEN c_crapcbd(pr_nrconbir => vr_nrconbir,
                   pr_nrseqdet => vr_nrseqdet);
     FETCH c_crapcbd INTO r_crapcbd;
    CLOSE c_crapcbd;  
    
    vr_string := vr_string||r_crapcbd.dataconsulta ||
                            r_crapcbd.reaproveitamento||
                            r_crapcbd.databasebacen||
                            r_crapcbd.qtoperacoes||
                            r_crapcbd.qtifs||
                            r_crapcbd.endividamento||
                            r_crapcbd.vencidas||
                            r_crapcbd.prejuizo||
                            r_crapcbd.vencidas12meses||
                            r_crapcbd.prejuizo12meses;
    
    -- PF
    IF(r_pessoa.inpessoa = 1) THEN
        -- Procurar pelos possíveis nomes para o campo que existe no JSON
        -- comprometimento de renda acima do permitido
/*        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'comprometimento de renda:',
                                                              p_hasDoisPontos =>  true,
                                                              p_idCampo       => 0);
        
        IF v_rtReadJson IS NULL THEN*/
          
            -- Valor do comprometimento da renda
        IF vr_tpproduto_principal IN (2,6) THEN
	        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'Valor do comprometimento da renda',
                                                              p_hasDoisPontos =>  true,
                                                              p_idCampo       => 0);    
          
        --END IF;
        
          IF v_rtReadJson <> '-' THEN
            IF vr_tpproduto_principal = 2 THEN -- emprestimo
              v_rtReadJson := to_char(
                                      ROUND(
                                            to_number(
                                                      REPLACE(
                                                      substr(v_rtReadJson, 1, length(v_rtReadJson) - 1),'.',','
                                                             )
                                                     )
                                         ,2)
                                      )|| '%';
             
            ELSIF vr_tpproduto_principal = 6 THEN -- limite desconto de titulo
              v_rtReadJson := substr(v_rtReadJson, 1, length(v_rtReadJson) - 1);
              BEGIN
                v_rtReadJson := to_char(round(to_number(REPLACE(v_rtReadJson,'.',','))* 100,2) || '%');
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
            
          END IF;      
        END IF;
        vr_string := vr_string||tela_analise_credito.fn_tag('Comprometimento de renda', v_rtReadJson);
    
    ELSE
        
        -- faturamento comprometido acima do permitido
        v_rtReadJson := tela_analise_credito.fn_le_json_motor(p_cdcooper      => pr_cdcooper,
                                                              p_nrdconta      => pr_nrdconta,
                                                              p_nrdcontrato   => pr_nrctrato, 
                                                              p_tagFind       => 'faturamento comprometido acima do permitido',
                                                              p_hasDoisPontos =>  false,
                                                              p_idCampo       => 0);
                                                              
        IF v_rtReadJson <> '-' THEN
          if instr(v_rtReadJson,'%.') > 0 then
          v_rtReadJson := substr(v_rtReadJson,56);
          else
          v_rtReadJson := substr(v_rtReadJson, 56);
          v_rtReadJson := to_char(round(to_number(REPLACE(v_rtReadJson,'.',','))* 100,2) || '%');
          end if;
        END IF;
        
        vr_string := vr_string||tela_analise_credito.fn_tag('Faturamento comprometido acima do permitido', v_rtReadJson);                                                             
    
    END IF;                        
    
    vr_string := vr_string||'</campos></subcategoria>';
    -- Fim Resumo das Informações do Titular               
    
    -- SCR
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>SCR</tituloTela>'||
                              '<campos>';
                              
    vr_tab_tabela.delete;
    FOR rw_nrconbir IN cr_nrconbir LOOP
      FOR rw_modalidade IN cr_modalidade(pr_nrconbir => rw_nrconbir.nrconbir,
                                         pr_nrseqdet => rw_nrconbir.nrseqdet)
      LOOP

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
    END LOOP;
    --
    vr_string := vr_string||'</campos>';
    -- Fim SCR
    else
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

  PROCEDURE pc_consulta_scr2(pr_cdcooper IN crapass.cdcooper%TYPE         --> Cooperativa
                            ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                            ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                            ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                            ,pr_dsxmlret OUT varchar2) IS                 --> Arquivo de retorno do XML
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

vr_string varchar2(4000);

  cursor c_crapopf is
  select opf.nrcpfcgc
     from crapass a,
          crapopf opf
   where a.cdcooper   = pr_cdcooper
     and a.nrdconta   = pr_nrdconta
     and opf.nrcpfcgc = a.nrcpfcgc
     and opf.dtrefere >= (select max(dtrefere) from crapopf);
r_crapopf c_crapopf%rowtype;

cursor c_consulta_scr(pr_nrcpfcgc crapass.nrcpfcgc%type) is
  select fn_tag('Data-base Bacen', to_char(opf.dtrefere,'DD/MM/YYYY')) databasebacen, -- Data base bacen
         fn_tag('Quantidade de Operações', opf.qtopesfn) qtoperacoes, -- Qt. Operações
         fn_tag('Quantidade de Instituições Financeiras', opf.qtifssfn) qtifs, -- Qt. IFs
         fn_tag('Operação do Sistema Financeiro Nacional (Endividamento)', to_char(SUM(vop.vlvencto),'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
         fn_tag('Operações Vencidas', SUM(CASE WHEN vop.cdvencto BETWEEN 205 AND 290 THEN vop.vlvencto ELSE 0 END)) vencidas, -- Op.Vencidas
         fn_tag('Operações de Prejuízo', SUM(CASE WHEN vop.cdvencto BETWEEN 310 AND 330 THEN vop.vlvencto ELSE 0 END)) prejuizo  -- Op.Prejuízo
    from crapopf opf,
         crapvop vop
   where opf.nrcpfcgc = pr_nrcpfcgc
     and opf.dtrefere >= (select max(dtrefere) from crapopf)
     and vop.nrcpfcgc = opf.nrcpfcgc
     and vop.dtrefere = opf.dtrefere
     group by opf.nrcpfcgc, opf.dtrefere, opf.qtopesfn, opf.qtifssfn;
r_consulta_scr c_consulta_scr%rowtype;

cursor c_modalidades(pr_nrcpfcgc crapass.nrcpfcgc%type) is
  select vop.nrcpfcgc,
         substr(vop.cdmodali,1,2) cdmodali,
         gnmodal.dsmodali,
         sum(vop.vlvencto) vencimento
     from crapvop vop,
          gnmodal
   where vop.nrcpfcgc = pr_nrcpfcgc
     and vop.dtrefere >= (select max(dtrefere) from crapopf)
     and gnmodal.cdmodali = substr(vop.cdmodali,1,2)
     group by vop.nrcpfcgc, gnmodal.dsmodali, substr(vop.cdmodali,1,2);
r_modalidades c_modalidades%rowtype;
  
-- 31 dias a 60 dias
cursor c_vencimento_120(pr_nrcpfcgc crapass.nrcpfcgc%type,
                        pr_cdmodali crapvop.cdmodali%type) is
  select vop.cdvencto,
         to_char(sum(vop.vlvencto),'999g999g990d00') vencimento
     from crapvop vop
   where vop.nrcpfcgc = pr_nrcpfcgc
     and vop.dtrefere = (select max(dtrefere) from crapopf)
     and substr(vop.cdmodali,1,2) = pr_cdmodali
     and vop.cdvencto = 120
     group by vop.cdvencto;
r_vencimento_120 c_vencimento_120%rowtype;
  
-- 61 dias a 60 dias
cursor c_vencimento_130(pr_nrcpfcgc crapass.nrcpfcgc%type,
                        pr_cdmodali crapvop.cdmodali%type) is
  select vop.cdvencto,
         to_char(sum(vop.vlvencto),'999g999g990d00') vencimento
     from crapvop vop
   where vop.nrcpfcgc = pr_nrcpfcgc
     and vop.dtrefere = (select max(dtrefere) from crapopf)
     and substr(vop.cdmodali,1,2) = pr_cdmodali
     and vop.cdvencto = 130
     group by vop.cdvencto;
r_vencimento_130 c_vencimento_130%rowtype;
  
 
cursor c_crapvop(pr_nrcpfcgc crapass.nrcpfcgc%type) is
select fn_tag('Operações Vencidas(até 12 meses)', to_char(sum(vop.vlvencto),'999g999g990d00')) operacoesVencidas 
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
  vr_string := vr_string || '<subcategoria>'||
                            '<tituloTela>Resumo das Informações do Titular</tituloTela>'||
                            '<campos>';  
    
                 
  open c_crapopf;
    fetch c_crapopf into r_crapopf;
      if c_crapopf%notfound then
          vr_string := vr_string || '<campo>'||
                                    '<nome>Informação</nome>'||
                                    '<tipo>info</tipo>'||
                                    '<valor>Não foi encontrado dados do SCR</valor>'||
                                    '</campo>';
      else
        open c_consulta_scr(r_crapopf.nrcpfcgc);
          fetch c_consulta_scr into r_consulta_scr;
            if c_consulta_scr%found then
                
              /*Gera Tags Xml*/
              vr_string := vr_string||
                           r_consulta_scr.databasebacen||
                           r_consulta_scr.qtoperacoes||
                           r_consulta_scr.qtifs||
                           r_consulta_scr.endividamento||
                           r_consulta_scr.vencidas||
                           r_consulta_scr.prejuizo;
            end if;
        close c_consulta_scr;
          
        open c_crapvop(r_crapopf.nrcpfcgc);
          fetch c_crapvop into r_crapvop;
            if c_crapvop%found then
                
              /*Gera Tags Xml*/
              vr_string := vr_string||
                           r_crapvop.operacoesvencidas;
            end if;
        close c_crapvop;
        
        vr_string := vr_string||'</campos></subcategoria>';
        -- Fim Resumo das Informações do Titular   
        
        vr_string := vr_string || '<subcategoria>'||
                                  '<tituloTela>SCR</tituloTela>'||
                                  '<campos>';   
          
        FOR r_modalidades IN c_modalidades(r_crapopf.nrcpfcgc) LOOP

          vr_tab_tabela.delete;

          vr_string := vr_string||'<campo>
                                   <nome>Modalidade: '  || r_modalidades.cdmodali || ' - ' ||r_modalidades.dsmodali ||'</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';

          -- 31 dias a 60 dias
          open c_vencimento_120(r_modalidades.nrcpfcgc,r_modalidades.cdmodali);
           fetch c_vencimento_120 into r_vencimento_120;

             vr_tab_tabela(1).coluna1 := nvl(r_vencimento_120.vencimento, 0);

          close c_vencimento_120;
            
          -- 61 dias a 60 dias
          open c_vencimento_130(r_modalidades.nrcpfcgc,r_modalidades.cdmodali);
           fetch c_vencimento_130 into r_vencimento_130;

             vr_tab_tabela(1).coluna2 := nvl(r_vencimento_130.vencimento, 0);

          close c_vencimento_130;

          vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);

          vr_string := vr_string||'</linhas>
                                   </valor>
                                   </campo>';

        END LOOP;
      end if;
  close c_crapopf;

  vr_string := vr_string||'</campos>';
  -- Fim SCR
  
  -- Cria o XML a ser retornado
  pr_dsxmlret := vr_string;
    
  EXCEPTION
  WHEN OTHERS THEN
    /* Tratar erro */
    pr_cdcritic := 0;
    pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_SCR - '||SQLERRM;
  END pc_consulta_scr2;
 
PROCEDURE pc_consulta_operacoes(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                               ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                               ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE       --> Data do movimeneto atual da cooperativa
                               ,pr_nrctrato  in crawepr.nrctremp%type
                               ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                               ,pr_dscritic OUT VARCHAR2                    --> Descricao da critica
                               ,pr_dsxmlret OUT CLOB) is
   /*Categoria Operações*/

   vr_dsxmlret             CLOB;
   vr_string               CLOB;

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
             craptdb.insitapr
        FROM craptdb
       WHERE craptdb.cdcooper = pr_cdcooper
         AND craptdb.nrdconta = pr_nrdconta
         AND craptdb.nrborder = pr_nrborder
         AND craptdb.insittit not in (0,2,3); --ignorar não processados, nem pagos nem baixados;

      BEGIN

        vr_flgverbor := DSCT0003.fn_virada_bordero(pr_cdcooper);

        vr_qt_tot_borderos := 0;
        vr_vl_tot_borderos := 0;
        vr_qt_tot_titulos  := 0;

        IF vr_flgverbor = 1 THEN

            vr_dt_aux_dtmvtolt := rw_crapdat.dtmvtolt - 120;
            vr_dt_aux_dtlibbdt := rw_crapdat.dtmvtolt - 90;

            -- abrindo cursor de títulos
            OPEN  cr_crapbdt;
            LOOP
                FETCH cr_crapbdt INTO rw_crapbdt;
                EXIT  WHEN cr_crapbdt%NOTFOUND;

                 IF (rw_crapbdt.dtmvtolt <= vr_dt_aux_dtmvtolt AND ( rw_crapbdt.insitbdt IN(1,2))) THEN
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

                 --Incremente total de títulos por borderô
                 vr_vl_tot_borderos := vr_vl_tot_borderos + rw_craptdb.vlsldtit;
                     vr_qt_tot_titulos := vr_qt_tot_titulos + 1;

                 END LOOP;

            END LOOP;
            CLOSE  cr_crapbdt;

        ELSE

            -- abrindo cursor de títulos
            OPEN  cr_crapbdt;
            LOOP
                   FETCH cr_crapbdt INTO rw_crapbdt;
                   EXIT  WHEN cr_crapbdt%NOTFOUND;

                /*
                    Borderos liberados ate 90 dias
                    Borderos liberados a mais de 90 dias com titulos pendentes
                    Todos os borderos nao liberados
                */
                IF  rw_crapbdt.dtlibbdt is not null  THEN
                    IF (rw_crapbdt.dtlibbdt < rw_crapdat.dtmvtolt - 90) AND
                        rw_crapbdt.insitbdt = 4                  THEN
                        CONTINUE;
                    END IF;
                 END IF;

                vr_qt_tot_borderos := vr_qt_tot_borderos + 1;

                FOR rw_craptdb IN cr_craptdb(pr_cdcooper => rw_crapbdt.cdcooper
                                            ,pr_nrdconta => rw_crapbdt.nrdconta
                                            ,pr_nrborder => rw_crapbdt.nrborder) LOOP

                 --Incremente total de títulos por borderô
                 vr_vl_tot_borderos := vr_vl_tot_borderos + rw_craptdb.vlsldtit;
                    vr_qt_tot_titulos := vr_qt_tot_titulos + 1;

                END LOOP;

            END LOOP;  /*  Fim da leitura do crapbdt  */
            CLOSE  cr_crapbdt;

        END IF;

        vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Operações de Crédito Ativas - Produto Bôrdero de Desconto de Título</tituloTela>'||
                   '<campos>';

        vr_string := vr_string || fn_tag('Quantidade Total de Borderôs', vr_qt_tot_borderos)||
                                  fn_tag('Quantidade Total de Boletos', vr_qt_tot_titulos)||
                                  fn_tag('Valor Total de Borderôs', to_char(vr_vl_tot_borderos,'999g999g990d00'));

        vr_string := vr_string||'</campos></subcategoria>';
        
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
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
      vr_index     NUMBER;  
      aux_qtmesdec NUMBER;
      aux_qtpreemp NUMBER;
      aux_qtprecal NUMBER;
      tot_vlsdeved NUMBER;
      tot_vlpreemp NUMBER;
      tot_qtprecal NUMBER;
      vr_garantia  VARCHAR2(250);
      vr_dspontualidade VARCHAR(30) := 'Sem Atrasos';
      vr_liquidar VARCHAR(15);
      vr_lista_contratos_liquidados VARCHAR(100) := '';
      
      -- variaveis de retorno
      vr_des_reto      VARCHAR2(3);
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_tab_erro      gene0001.typ_tab_erro;
      vr_qtregist      NUMBER;
      vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
      
      --Variaveis para busca de parametros
      vr_dstextab            craptab.dstextab%TYPE;
      vr_dstextab_parempctl  craptab.dstextab%TYPE;
      vr_dstextab_digitaliza craptab.dstextab%TYPE;
      
      --Indicador de utilização da tabela
      vr_inusatab BOOLEAN;
    
      ---------->>> CURSORES <<<----------
      CURSOR cr_craplem (pr_nrctremp IN craplem.nrctremp%TYPE) IS
        SELECT MAX(dtmvtolt) dtliquidacao
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           and EXISTS (SELECT 1
                         FROM craphis
                        WHERE cdcooper = 1
                          AND cdhistor = craplem.cdhistor
                          AND indebcre = 'C');
      rw_craplem cr_craplem%ROWTYPE;

      CURSOR cr_crapris (pr_nrctremp IN crapris.nrctremp%TYPE
                        ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT CASE
                 WHEN max(qtdiaatr) = 0   THEN 'Sem Atrasos'
                 WHEN max(qtdiaatr) <= 60 THEN 'Até 60 dias'
                 WHEN max(qtdiaatr) > 60  THEN 'Mais 60 dias ou renegociações'
               END dspontualidade
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtrefere <= LAST_DAY(pr_dtrefere)
           AND inddocto = 1;
      rw_crapris cr_crapris%ROWTYPE;
      
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
          
          empr0001.pc_obtem_dados_empresti
                           (pr_cdcooper       => pr_cdcooper            --> Cooperativa conectada
                           ,pr_cdagenci       => 0                      --> Código da agência
                           ,pr_nrdcaixa       => 0                      --> Número do caixa
                           ,pr_cdoperad       => 1                      --> Código do operador
                           ,pr_nmdatela       => 'ATENDA'               --> Nome datela conectada
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
                           ,pr_tab_erro       => vr_tab_erro);          --> Tabela com possíves erros
                           
          -- Garantia
          OPEN cr_crawepr;
          FETCH cr_crawepr INTO rw_crawepr;   
          CLOSE cr_crawepr;
          
          vr_lista_contratos_liquidados := rw_crawepr.lista_contratos_liquidados;
          vr_tab_tabela.delete;               
          
          IF vr_tab_dados_epr.COUNT() > 0 THEN
              tot_vlsdeved := 0;
              tot_vlpreemp := 0;
              tot_qtprecal := 0;
              vr_index := 1;
              FOR i IN 1 .. vr_tab_dados_epr.COUNT() LOOP
                
                  IF vr_tab_dados_epr(i).vlsdeved <= 0 THEN 
                     CONTINUE;
                  END IF;
                  
                  aux_qtmesdec := vr_tab_dados_epr(i).qtmesdec - vr_tab_dados_epr(i).qtprecal;
                  aux_qtpreemp := vr_tab_dados_epr(i).qtpreemp - vr_tab_dados_epr(i).qtprecal;
      
                  IF  aux_qtmesdec > aux_qtpreemp  THEN         
                      aux_qtprecal := aux_qtpreemp;
                  ELSE
                      aux_qtprecal := aux_qtmesdec;
                  END IF;
                         
                  IF  aux_qtprecal < 0 THEN 
                      aux_qtprecal := 0;
                  END IF;
                  
                  OPEN cr_craplem (pr_nrctremp => vr_tab_dados_epr(i).nrctremp);
                  FETCH cr_craplem INTO rw_craplem;
                  CLOSE cr_craplem;

                  OPEN cr_crapris (pr_nrctremp => vr_tab_dados_epr(i).nrctremp
                                  ,pr_dtrefere => rw_craplem.dtliquidacao);
                  FETCH cr_crapris INTO rw_crapris;
                  IF cr_crapris%FOUND THEN
                     vr_dspontualidade := rw_crapris.dspontualidade;
                  END IF;
                  CLOSE cr_crapris;
                  
                  -- Garantia
                  OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                  pr_nrdconta => pr_nrdconta,
                                  pr_nrctremp => vr_tab_dados_epr(i).nrctremp);
                  FETCH cr_crapbpr INTO rw_crapbpr;
                  
                  -- Resetar a variavel
                  vr_garantia := '-';

                  -- Se encontrou
                  IF cr_crapbpr%FOUND THEN
                     vr_garantia := 'Bem';
                  END IF;
                  CLOSE cr_crapbpr;
                  
                  --> listar avalistas de contratos
                  DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                      ,pr_cdagenci => 0  --> Código da agencia
                                      ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                                      ,pr_cdoperad => 1  --> Código do Operador
                                      ,pr_nmdatela => 'ATENDA'  --> Nome da tela
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
                                      ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica
                                      
                  IF vr_tab_dados_avais.exists(1) THEN
                     vr_garantia := 'Avalista ' || vr_tab_dados_avais(1).nrctaava;
                  END IF;
                  
                  IF vr_tab_dados_avais.exists(2) THEN
                     vr_garantia := 'Primeiro Avalista ' || vr_tab_dados_avais(1).nrctaava||' - '||'Segundo Avalista ' || vr_tab_dados_avais(2).nrctaava;
                  END IF;
                  
                  -- Liquidar  
                  vr_liquidar := INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp));
                  IF INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp)) > 0 THEN
                      vr_liquidar := 'Sim';
                  ELSE
                      vr_liquidar := 'Não';
                  END IF;
                         
                  tot_vlsdeved := tot_vlsdeved + vr_tab_dados_epr(i).vlsdeved;
                  tot_vlpreemp := tot_vlpreemp + vr_tab_dados_epr(i).vlpreemp;
                  tot_qtprecal := tot_qtprecal + aux_qtprecal;
              
                  vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(vr_tab_dados_epr(i).nrctremp); -- Contrato
                  vr_tab_tabela(vr_index).coluna2 := trim(to_char(vr_tab_dados_epr(i).vlsdeved,'999g999g990d00')); -- Saldo Devedor
                  vr_tab_tabela(vr_index).coluna3 := substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11); -- Prestações
                  vr_tab_tabela(vr_index).coluna4 := to_char(vr_tab_dados_epr(i).vlpreemp,'999g999g990d00'); -- Valor Prestações
                  vr_tab_tabela(vr_index).coluna5 := to_char(aux_qtprecal,'fm990d0000'); -- Atraso/Parcela
                  vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(i).dsfinemp; -- Finalidade
                  vr_tab_tabela(vr_index).coluna7 := vr_tab_dados_epr(i).dslcremp; -- Linha de Crédito
                  vr_tab_tabela(vr_index).coluna8 := trim(to_char(vr_tab_dados_epr(i).txmensal,'990D000000')); -- Taxa
                  vr_tab_tabela(vr_index).coluna9 := vr_garantia; -- Garantia
                  vr_tab_tabela(vr_index).coluna10 := vr_liquidar; -- Liquidar
                  vr_tab_tabela(vr_index).coluna11 := CASE WHEN vr_dspontualidade IS NOT NULL THEN vr_dspontualidade ELSE 'Sem Atrasos' END; -- Pontualidade
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
          END IF;
          
          -- Colocar a linha de Totais --bug 20882
          IF vr_tab_dados_epr.COUNT() > 1 THEN
            
              vr_tab_tabela(vr_index).coluna1 := '&lt;b&gt;TOTAL&lt;/b&gt;';
              vr_tab_tabela(vr_index).coluna2 := case when tot_vlsdeved > 0 then 
                                                    to_char(tot_vlsdeved,'999g999g990d00') else '-' end; -- Saldo Devedor
              vr_tab_tabela(vr_index).coluna3 := '-';
              vr_tab_tabela(vr_index).coluna4 := case when tot_vlpreemp > 0 then
                                                    to_char(tot_vlpreemp,'999g999g990d00') else '-' end; -- Valor Prestações
              vr_tab_tabela(vr_index).coluna5 := case when tot_qtprecal > 0 then
                                                    to_char(tot_qtprecal,'fm990d0000') else '-' end; -- Atraso/Parcelas
              
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
          END IF;
          
          vr_string := vr_string || '<subcategoria>'||
                                    '<tituloTela>Operações de Crédito Ativas - Produto Empréstimo e Financiamento</tituloTela>'||
                                    '<campos>';
          
          vr_string := vr_string||'<campo>
                                   <nome>Propostas Ativas</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';

          vr_string := vr_string||fn_tag_table('Contrato;Saldo Devedor;Prestações;Valor Prestações;Atraso/Parcela;Finalidade;Linha de Crédito;Taxa;Garantia;Liquidar;Pontualidade', vr_tab_tabela);

          vr_string := vr_string||'</linhas>
                                   </valor>
                                   </campo>';
                                   
          vr_string := vr_string||'</campos></subcategoria>';
          
       EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
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

      vr_index      NUMBER;

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
              
            vr_tab_tabela(vr_index).coluna1 := to_char(rw_crapcns.vlrcarta,'999g999g990d00'); -- Valor da carta do consórcio
            vr_tab_tabela(vr_index).coluna2 := rw_crapcns.qtparpag; -- Parcelas pagas
            vr_tab_tabela(vr_index).coluna3 := rw_crapcns.qtparres; -- Parcelas restantes
            vr_tab_tabela(vr_index).coluna4 := to_char(rw_crapcns.vlparcns,'999g999g990d00'); -- Valor parcela
            
            vr_index := vr_index + 1;

        END LOOP;
        
        vr_string := vr_string || 
                   '<subcategoria>'||
                   '<tituloTela>Operações de Crédito Ativas - Consórcio</tituloTela>'||
                   '<campos>';
                   
        IF vr_tab_tabela.COUNT > 0 THEN
          
            vr_string := vr_string || fn_tag('Tem consórcio ativo na cooperativa', 'Sim');
            
            vr_string := vr_string||'<campo>
                                     <nome>Consórcios Ativos</nome>
                                     <tipo>table</tipo>
                                     <valor>
                                     <linhas>';
            
            vr_string := vr_string||fn_tag_table('Valor da Carta;Parcelas Pagas;Parcelas Restantes;Valor da Parcela', vr_tab_tabela);
            
            vr_string := vr_string||'</linhas>
                                     </valor>
                                     </campo>';
            
        ELSE
          
            vr_string := vr_string || fn_tag('Tem consórcio ativo na cooperativa', 'Não');
            
            vr_tab_tabela(1).coluna1 := '-'; -- Valor da carta do consórcio
            vr_tab_tabela(1).coluna2 := '-'; -- Parcelas pagas
            vr_tab_tabela(1).coluna3 := '-'; -- Parcelas restantes
            vr_tab_tabela(1).coluna4 := '-'; -- Valor parcela
            
            vr_string := vr_string||'<campo>
                                     <nome>Consórcios Ativos</nome>
                                     <tipo>table</tipo>
                                     <valor>
                                     <linhas>';
            
            vr_string := vr_string||fn_tag_table('Valor da Carta;Parcelas Pagas;Parcelas Restantes;Valor da Parcela', vr_tab_tabela);
            
            vr_string := vr_string||'</linhas>
                                     </valor>
                                     </campo>';
        
        END IF;
                           
        vr_string := vr_string||'</campos></subcategoria>';
        
     EXCEPTION
          WHEN OTHERS THEN
            pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
            vr_string := vr_string||'<erros><erro>'||
                                    '<dscritic> PC_CONSULTA_CONSORCIO -> '||pr_dscritic||'</dscritic>'||
                                    '</erro></erros>';
                                          
  END pc_busca_consorcio; 
    
  ---------------------------------------------------------------
  PROCEDURE pc_plano_capital(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
    vr_exc_erro         EXCEPTION;
    
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
      vr_string := vr_string ||             
      fn_tag('Depósito à Vista',TO_CHAR(vr_vlstotal,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
                   
      vr_string := vr_string ||'<campo>
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
    END  IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic> PC_PLANO_CAPITAL ->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  END pc_plano_capital;
  ---------------------------------------------------------------
  PROCEDURE pc_medias (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
    vr_exc_erro         EXCEPTION;

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
                              ,pr_nmdatela => 'ATENDA'
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

      vr_string := vr_string ||'<campo>
                                <tipo>h3</tipo>
                                <valor>Médias</valor>
                                </campo>';                 
                 
    /*FOR I IN 1..vr_tab_medias.count() LOOP
      vr_string := vr_string
                || fn_tag(vr_tab_medias(I).periodo,vr_tab_medias(I).vlsmstre);
    END LOOP;*/
    --
    FOR I IN 1..vr_tab_comp_medias.COUNT() LOOP
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
    END  IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>PC_MEDIAS->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_medias - '||SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  END pc_medias;
  ---------------------------------------------------------------
  /*PROCEDURE pc_aplicacoes (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                          ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                          ,pr_cdcritic OUT PLS_INTEGER                 --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2) IS
    \*---------------------------------------------------------------------------------------------------------------------
      Programa: pc_aplicacoes
      Sistema : Aimaro/Ibratan
      Autor   : Marcelo Telles Coelho (Mouts)
      Data    : Março/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que busca as médias de aplicações
    ---------------------------------------------------------------------------------------------------------------------*\
    --
    -- Variaveis de trabalho
    vr_index            NUMBER;
    vr_vlbloque         NUMBER;
    vr_vlresblq         NUMBER;
    vr_vlbloque_aplica  NUMBER;
    vr_vlbloque_poupa   NUMBER;
    -- Tabelas de retorno da procedure PC_LISTA_APLICACOES
    vr_saldo_rdca       apli0001.typ_tab_saldo_rdca;
    -- Exceptions
    vr_exc_erro         EXCEPTION;

  BEGIN -- inicio
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    --
    apli0005.pc_lista_aplicacoes(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => 1
                                ,pr_nmdatela => 'ATENDA'
                                ,pr_idorigem => 5
                                ,pr_nrdcaixa => 0
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 1
                                ,pr_cdagenci => 0
                                ,pr_cdprogra => 0
                                ,pr_nraplica => 0
                                ,pr_cdprodut => 0
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_idconsul => 6
                                ,pr_idgerlog => 0
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic
                                ,pr_saldo_rdca => vr_saldo_rdca);
    --
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    --
\*    vr_string := vr_string ||
                 '<subcategoria>'||
                 '<tituloTela>Resumo da Conta - Aplicações</tituloTela>'||
                 '<campos>';*\
    --
    
    vr_string := vr_string ||'<campo>
                          <tipo>h3</tipo>
                          <valor>Aplicações</valor>
                          </campo>';
    
    \*Apresentado em tabela*\
    vr_string := vr_string||'<campo>
                             <nome>Aplicações</nome>
                             <tipo>table</tipo>
                             <valor>
                             <linhas>';

    IF vr_saldo_rdca.COUNT() > 0 THEN
      vr_index := 1;
      vr_tab_tabela.delete;
      --
      FOR i IN 0 .. vr_saldo_rdca.COUNT() - 1 LOOP
        vr_tab_tabela(vr_index).coluna1 := vr_saldo_rdca(i).dtmvtolt;
        vr_tab_tabela(vr_index).coluna2 := vr_saldo_rdca(i).dshistor;
        vr_tab_tabela(vr_index).coluna3 := vr_saldo_rdca(i).qtdiauti;
        vr_tab_tabela(vr_index).coluna4 := vr_saldo_rdca(i).vlaplica;
        vr_tab_tabela(vr_index).coluna5 := vr_saldo_rdca(i).dtvencto;
        vr_tab_tabela(vr_index).coluna6 := vr_saldo_rdca(i).vllanmto;
        vr_tab_tabela(vr_index).coluna7 := vr_saldo_rdca(i).vlsdrdad;
        vr_tab_tabela(vr_index).coluna8 := vr_saldo_rdca(i).dssitapl;
        vr_tab_tabela(vr_index).coluna9 := vr_saldo_rdca(i).dtcarenc;
        vr_tab_tabela(vr_index).coluna10:= vr_saldo_rdca(i).txaplmax;
        vr_tab_tabela(vr_index).coluna11:= vr_saldo_rdca(i).txaplmin;
        vr_tab_tabela(vr_index).coluna12:= vr_saldo_rdca(i).cddresga;
        vr_tab_tabela(vr_index).coluna13:= vr_saldo_rdca(i).dtresgat;
        vr_tab_tabela(vr_index).coluna14:= vr_saldo_rdca(i).nraplica;
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
      vr_tab_tabela(1).coluna10:= '-';
      vr_tab_tabela(1).coluna11:= '-';
      vr_tab_tabela(1).coluna12:= '-';
      vr_tab_tabela(1).coluna13:= '-';
      vr_tab_tabela(1).coluna14:= '-';
    END IF;
    --
    vr_string := vr_string||fn_tag_table('Data;Histórico;Car.;Valor;Vencto;Saldo;Sl Resg.;Sit;Dt Car.;Tx.Ctr.;Tx.Min.;Resg;Dt.Resg.;Nr.Aplicação'
                ,vr_tab_tabela);
    vr_string := vr_string||'</linhas>
                             </valor>
                             </campo>';
    --
    gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrcpfcgc => 0
                                    ,pr_cdtipmov => 0
                                    ,pr_cdmodali => 2
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_vlbloque => vr_vlbloque
                                    ,pr_vlresblq => vr_vlresblq
                                    ,pr_dscritic => pr_dscritic);
    --
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    --
    bloq0001.pc_calc_bloqueio_garantia(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_tpctrato => 0
                                      ,pr_nrctaliq => 0
                                      ,pr_dsctrliq => 0
                                      ,pr_vlsldapl => 0
                                      ,pr_vlblqapl => 0
                                      ,pr_vlsldpou => 0
                                      ,pr_vlblqpou => 0
                                      ,pr_vlbloque_aplica => vr_vlbloque_aplica
                                      ,pr_vlbloque_poupa  => vr_vlbloque_poupa
                                      ,pr_dscritic => pr_dscritic);
    --
    vr_string := vr_string
              || fn_tag('Valor Bloq.Judicial',TO_CHAR(NVL(vr_vlbloque,0)       ,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
              || fn_tag('Valor Bloq.Garantia',TO_CHAR(NVL(vr_vlbloque_aplica,0),'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
    --
    vr_string := vr_string||'</campos></subcategoria>';

  EXCEPTION
  WHEN vr_exc_erro THEN
    IF pr_cdcritic IS NOT NULL THEN
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END  IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>PC_APLICACOES ->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_aplicacoes - '||SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  END pc_aplicacoes;*/

  PROCEDURE pc_aplicacoes (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
     
     vr_string := vr_string ||'<campo>
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
                                       
     vr_string := vr_string||fn_tag('Total de Aplicações',to_char(vr_vlsldtot,'999g999g990d00'))||                                    
                             fn_tag('Total Poupança Programada',to_char(vr_vlsldrgt,'999g999g990d00'));
                             
     vr_string := vr_string||'</campos></subcategoria>';                                       
   
  EXCEPTION
  WHEN vr_exc_erro THEN
    IF pr_cdcritic IS NOT NULL THEN
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END  IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>PC_APLICACOES ->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_aplicacoes - '||SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  END pc_aplicacoes;
  ---------------------------------------------------------------
  PROCEDURE pc_emprestimos_liquidados (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
    vr_index            NUMBER;
    -- Exceptions
    vr_exc_erro         EXCEPTION;

  BEGIN -- inicio
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    vr_index    := 1;
    vr_tab_tabela.delete;
    --bug 19872
    FOR r1 IN ( SELECT *
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
      vr_tab_tabela(vr_index).coluna6 := TO_CHAR(rw_craplem.dtliquidacao,'dd/mm/yyyy');
      --
      OPEN cr_crapris (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => r1.nrctremp
                      ,pr_dtrefere => rw_craplem.dtliquidacao);
      FETCH cr_crapris INTO rw_crapris;
      --bug 19890
      IF cr_crapris%FOUND THEN
        vr_tab_tabela(vr_index).coluna7 := nvl(rw_crapris.dspontualidade,'Sem Atrasos');
      ELSE
        vr_tab_tabela(vr_index).coluna7 := 'Sem Atrasos';
      END IF;
      
      CLOSE cr_crapris;
     
      vr_index := vr_index + 1;
    END LOOP;
    --
    vr_string := vr_string ||
                 '<subcategoria>'||
                 '<tituloTela>Últimas 4 Operações Liquidadas - Produto Empréstimos e Financiamentos</tituloTela>'||
                 '<campos>';
    vr_string := vr_string||'<campo>
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
    vr_string := vr_string||'</linhas>
                             </valor>
                             </campo>';
    vr_string := vr_string||'</campos></subcategoria>';

  EXCEPTION
  WHEN vr_exc_erro THEN
    IF pr_cdcritic IS NOT NULL THEN
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END  IF;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>pc_emprestimos_liquidados->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_emprestimos_liquidados - '||SQLERRM;
    vr_string := vr_string||'<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros>';
  END pc_emprestimos_liquidados;
  ---------------------------------------------------------------
  PROCEDURE pc_co_responsabilidade (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
    vr_nrctremp        NUMBER;
    vr_nrdconta        NUMBER;
    vr_contas_chq      VARCHAR2(1000) := ' '; --para contas avalisadas de cheque
    vr_nmprimtl        VARCHAR2(1000);
    vr_vldivida        VARCHAR2(1000);
    vr_tpdcontr        VARCHAR2(1000);
    vr_index           NUMBER;
    vr_qtmesdec        NUMBER;
    vr_qtpreemp        NUMBER;
    vr_qtprecal        NUMBER;
    vr_qtregist        NUMBER;
    vr_axnrcont        VARCHAR2(1000);
    vr_axnrcpfc        VARCHAR2(1000);
    vr_nmdcampo        VARCHAR2(1000);
    vr_des_erro        VARCHAR2(1000);
    vr_clob_ret        CLOB;
    vr_clob_msg        CLOB;
    vr_xmltype         xmlType;
    vr_parser          xmlparser.Parser;
    vr_doc             xmldom.DOMDocument;
    --
    vr_dstextab_parempctl  craptab.dstextab%TYPE;
    vr_dstextab_digitaliza craptab.dstextab%TYPE;
    -- variaveis de retorno
    vr_tab_dados_epr   empr0001.typ_tab_dados_epr;
    vr_tab_erro        gene0001.typ_tab_erro;
    -- Root
    vr_node_root       xmldom.DOMNodeList;
    vr_item_root       xmldom.DOMNode;
    vr_elem_root       xmldom.DOMElement;
    -- SubItens
    vr_node_list       xmldom.DOMNodeList;
    vr_node_name       VARCHAR2(100);
    vr_item_node       xmldom.DOMNode;
    vr_elem_node       xmldom.DOMElement;
    -- SubItens da AVAL
    vr_node_list_aval  xmldom.DOMNodeList;
    vr_node_name_aval  VARCHAR2(100);
    vr_item_node_aval  xmldom.DOMNode;
    vr_valu_node_aval  xmldom.DOMNode;

    -- Tabelas
    vr_tab_aval        aval0001.typ_tab_contras;
    vr_rw_crapdat      btch0001.cr_crapdat%ROWTYPE;

    -- Exceptions
    vr_exc_erro         EXCEPTION;
    vr_des_reto         VARCHAR2(100);

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
      AND   s.cdlcremp = d.cdlcremp
      AND s.nrdconta = pr_nrdconta
      AND s.cdcooper = pr_cdcooper
      AND s.nrctrato = pr_nrctrato;
    r_busca_saldo_deved_dsctit c_busca_saldo_deved_dsctit%ROWTYPE;    
    
    /*Para a tabela de co-responsabilidade quando desconto de cheques*/
    CURSOR c_busca_dados_descchq (pr_nrdconta IN crapsdv.nrdconta%TYPE
                                 ,pr_cdcooper IN crapsdv.cdcooper%TYPE
                                 ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
      SELECT c.nrdconta
            ,c.vllimite saldodeved
            ,c.nrctrlim contrato
            ,c.cddlinha || '-'||l.dsdlinha as linha
      FROM CRAPLIM c,
           crapldc l
      WHERE c.cdcooper = l.cdcooper
      AND   c.cddlinha = L.CDDLINHA
      AND   c.nrdconta = pr_nrdconta
      AND   c.cdcooper = pr_cdcooper
      AND   c.nrctrlim = pr_nrctrlim
      AND   c.tpctrlim = 2
      AND   c.insitlim = 2
      AND   l.tpdescto = 2;
     r_busca_dados_descchq c_busca_dados_descchq%ROWTYPE;

    CURSOR c_busca_dados_limite_emp (pr_nrdconta IN crapsdv.nrdconta%TYPE
                                    ,pr_cdcooper IN crapsdv.cdcooper%TYPE
                                    ,pr_nrctrato IN crapsdv.nrctrato%TYPE) IS
    SELECT l.dsdlinha linhacred
          ,c.nrdconta
      FROM crapmcr c
          ,craplrt l
      WHERE c.cdcooper = l.cdcooper
      AND   c.cddlinha = l.cddlinha
      AND   c.CDCOOPER = pr_cdcooper
      AND   c.NRDCONTA = pr_nrdconta
      and   c.nrcontra = pr_nrctrato;
      r_busca_dados_limite_emp c_busca_dados_limite_emp%ROWTYPE;
      

    FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode)RETURN VARCHAR2 IS
    BEGIN
      RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
    END fn_getValue;
  BEGIN -- inicio
    pr_cdcritic := NULL;
    pr_dscritic := NULL;
    vr_rw_crapdat.dtmvtolt := pr_dtmvtolt;
    --
    aval0001.pc_busca_dados_contratos_car(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => NULL
                                         ,pr_nrdcaixa => NULL
                                         ,pr_idorigem => 5
                                         ,pr_dtmvtolt => NULL
                                         ,pr_nmdatela => 'ATENDA'
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
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc     := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);
      --
      -- Buscar nodo AVAL
      vr_node_root := xmldom.getElementsByTagName(vr_doc,'root');
      vr_item_root := xmldom.item(vr_node_root, 0);
      vr_elem_root := xmldom.makeElement(vr_item_root);
      --
      -- Faz o get de toda a lista ROOT
      vr_node_list := xmldom.getChildrenByTagName(vr_elem_root,'*');
      --
      vr_index := 0;
      vr_tab_aval.DELETE;
      --
      -- Percorrer os elementos
      FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
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
          vr_node_list_aval := xmldom.getChildrenByTagName(vr_elem_node,'*');
          --
          vr_nrdconta := NULL;
          --
          -- Percorrer os elementos
          FOR i IN 0..xmldom.getLength(vr_node_list_aval)-1 LOOP
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
              vr_nrctremp         := fn_getValue(vr_valu_node_aval);
            END IF;
            IF vr_node_name_aval = 'nrdconta' THEN
              -- Buscar valor da TAG
              vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
              vr_nrdconta  := fn_getValue(vr_valu_node_aval);
            END IF;
            IF vr_node_name_aval = 'nmprimtl' THEN
              vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
              vr_nmprimtl  := fn_getValue(vr_valu_node_aval);
            END IF;
            IF vr_node_name_aval = 'vldivida' THEN
              vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
              vr_vldivida  := fn_getValue(vr_valu_node_aval);
            END IF;
            IF vr_node_name_aval = 'tpdcontr' THEN
              vr_valu_node_aval := xmldom.getFirstChild(vr_item_node_aval);
              vr_tpdcontr  := fn_getValue(vr_valu_node_aval);
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
      vr_string := vr_string||'<campo>
                               <nome>Co-responsabilidade</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';
                               
      IF vr_tab_aval.COUNT() > 0 THEN
        vr_index := 1;

        FOR i IN 1..vr_tab_aval.COUNT() LOOP

          vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(vr_tab_aval(i).nrctremp);
          
          --se for contrato de emprestimo
          IF (vr_tab_aval(vr_index).tpdcontr = 'EP') THEN
     
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
              pr_dscritic := 'Falha ao obter dados do empréstimo. '||SQLERRM;
            END IF;
            RAISE vr_exc_erro;
          END IF;
  
          --
          FOR i IN 1 .. vr_tab_dados_epr.count() LOOP
            vr_qtmesdec := vr_tab_dados_epr(i).qtmesdec - vr_tab_dados_epr(i).qtprecal;
            vr_qtpreemp := vr_tab_dados_epr(i).qtpreemp - vr_tab_dados_epr(i).qtprecal;
            
            IF vr_qtmesdec > vr_qtpreemp  THEN
              vr_qtprecal := vr_qtpreemp;
            ELSE
              vr_qtprecal := vr_qtmesdec;
            END IF;
            
            IF vr_qtprecal < 0 THEN 
              vr_qtprecal := 0;
            END IF;
              
              --Pega os dados da tabela de emprestimos
            vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida||' - '||
                                               REPLACE(SUBSTR(vr_tab_dados_epr(i).dspreapg,5,11),',0000','');
            vr_tab_tabela(vr_index).coluna3 := vr_tab_dados_epr(i).vlpreemp;
            vr_tab_tabela(vr_index).coluna4 := vr_qtprecal;                                
            vr_tab_tabela(vr_index).coluna5 := vr_tab_dados_epr(i).dsfinemp;
            vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(i).dslcremp;
            vr_tab_tabela(vr_index).coluna7 := 'Aval conta ' -- Bug 20848
                                              || trim(gene0002.fn_mask_conta(vr_tab_dados_epr(i).nrdconta))
                                            || ' '
                                            || CASE WHEN vr_tab_dados_epr(i).inprejuz = 1 THEN '*' END;
          END LOOP;

          /* DESCONTO DE TITULO */  
          ELSIF (vr_tab_aval(vr_index).tpdcontr = 'DT') THEN
            
            /*Busca saldo devedor do desconto de título */
            OPEN c_busca_saldo_deved_dsctit(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                           ,pr_nrctrato => vr_tab_aval(i).nrctremp);
                                           
             fetch c_busca_saldo_deved_dsctit into r_busca_saldo_deved_dsctit;
             if c_busca_saldo_deved_dsctit%found then
             
               vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
               --Quando for desconto de título não tem prestação e atraso/parcela bug19838
               vr_tab_tabela(vr_index).coluna3 := '-';
               vr_tab_tabela(vr_index).coluna4 := '-';
               
               vr_tab_tabela(vr_index).coluna5 := r_busca_saldo_deved_dsctit.dsfinalidade;
               vr_tab_tabela(vr_index).coluna6 := r_busca_saldo_deved_dsctit.dsdlinha;
               vr_tab_tabela(vr_index).coluna7 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_saldo_deved_dsctit.nrdconta));
             
             end if;
            
            close c_busca_saldo_deved_dsctit;
            
          /* LIMITE DE CRÉDITO EMPRESARIAL*/  
          ELSIF (vr_tab_aval(vr_index).tpdcontr = 'LM') THEN
            
            /*Busca linha de crédito, os outros campos não precisa */
            OPEN c_busca_dados_limite_emp(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                         ,pr_nrctrato => vr_tab_aval(i).nrctremp);
                                           
             fetch c_busca_dados_limite_emp into r_busca_dados_limite_emp;
             if c_busca_dados_limite_emp%found then
             
               --Quando for desconto de título não tem prestação e atraso/parcela bug19838
               vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
               vr_tab_tabela(vr_index).coluna3 := '-';
               vr_tab_tabela(vr_index).coluna4 := '-';
               
               vr_tab_tabela(vr_index).coluna5 := '-';
               vr_tab_tabela(vr_index).coluna6 := r_busca_dados_limite_emp.linhacred;
               vr_tab_tabela(vr_index).coluna7 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_dados_limite_emp.nrdconta));
             
             end if;
            
            close c_busca_dados_limite_emp;
            
          END IF;
        
          --
          vr_index := vr_index + 1;
        
        END LOOP;
      
      /* Ao final, busca contratos de limite de desconto de cheque. bug 19838 */
      /*Para cada conta de avalista*/
      FOR r1 IN 1..vr_tab_aval.COUNT() LOOP

        /*Grava o numero do contrato para buscar somente uma vez*/
        IF (vr_contas_chq NOT LIKE '%'||vr_tab_aval(r1).nrdconta||'%') THEN
          vr_contas_chq := vr_contas_chq || vr_tab_aval(r1).nrctremp || ',';
          
          /*Abre o cursor*/
          OPEN c_busca_dados_descchq (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => vr_tab_aval(r1).nrdconta
                                     ,pr_nrctrlim => vr_tab_aval(r1).nrctremp);
           --
           FETCH c_busca_dados_descchq INTO r_busca_dados_descchq;
           IF c_busca_dados_descchq%FOUND THEN

             /*Monta a tabela*/
             vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_contrato(r_busca_dados_descchq.contrato);
             vr_tab_tabela(vr_index).coluna2 := to_char(r_busca_dados_descchq.saldodeved,'999g999g990d00');
             --Quando for desconto de cheque não tem prestação nem atraso/parcela nem finalidade
             vr_tab_tabela(vr_index).coluna3 := '-';
             vr_tab_tabela(vr_index).coluna4 := '-';
             vr_tab_tabela(vr_index).coluna5 := '-';
             -- 
             vr_tab_tabela(vr_index).coluna6 := r_busca_dados_descchq.linha;
             vr_tab_tabela(vr_index).coluna7 := 'Aval de '|| trim(gene0002.fn_mask_conta(r_busca_dados_descchq.nrdconta));

             
           END IF;
          CLOSE c_busca_dados_descchq;
          
        END IF;
        
         
      
      END LOOP;
      
        
      ELSE
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        vr_tab_tabela(1).coluna5 := '-';
        vr_tab_tabela(1).coluna6 := '-';
        vr_tab_tabela(1).coluna7 := '-';
      END IF;
    ELSE
      --
      vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Co-responsabilidade</tituloTela>'||
                   '<campos>';
      --
      /*Apresentado em tabela*/
      vr_string := vr_string||'<campo>
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
    END IF;
    --
    vr_string := vr_string||fn_tag_table('Contrato;Saldo Devedor;Prestações;Atraso/Parcela;Finalidade;Linha de Crédito;Responsabilidade'
                ,vr_tab_tabela);
    vr_string := vr_string||'</linhas>
                             </valor>
                             </campo>';
    --
    vr_string := vr_string||'</campos></subcategoria>';

  EXCEPTION
  WHEN vr_exc_erro THEN
    IF pr_cdcritic IS NOT NULL THEN
      pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
    END  IF;
    vr_string := vr_string||'<subcategoria>'||
                            '<tituloTela>Co-responsabilidade</tituloTela>'||
                            '<erros><erro>'||
                            '<dscritic>pc_co_responsabilidade ->'||pr_dscritic||'</dscritic>'||
                            '</erro></erros></subcategoria>';
  WHEN OTHERS THEN
    pr_dscritic := 'Erro PC_CONSULTA_OPERACOES - pc_co_responsabilidade - '||SQLERRM;
    vr_string := vr_string||'<subcategoria>'||
                            '<tituloTela>Co-responsabilidade</tituloTela>'||
                            '<erros><erro>'||
                            '<dscritic>'||pr_dscritic||'</dscritic>'||
                            '</erro></erros></subcategoria>';
  END pc_co_responsabilidade;
  ---------------------------------------------------------------
  
  
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
                                 
       --3.2.2 Produto Bôrdero de Desconto de 
      pc_busca_borderos(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
                       
       --3.2 .3 Produto Consórcio - Verificar se vamos trazer
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
                                                 pr_fecha_xml      => TRUE);           

       --3.3.2 Modalidade Desconto de  Cheques 
     
        pc_consulta_desc_chq(pr_cdcooper => pr_cdcooper       --> Cooperativa
                            ,pr_nrdconta => pr_nrdconta       --> Conta
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic                            
                            ,pr_dsxmlret => vr_xml);
                                
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);     
       --3.3.3 Modalidade Desconto de  Título 
        pc_consulta_desc_titulo(pr_cdcooper => pr_cdcooper       --> Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --> Conta
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic                               
                               ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);
       --3.3.4 Modalidade Cartão de Crédito 
        pc_modalidade_car_cred(pr_cdcooper => pr_cdcooper       --> Cooperativa
                              ,pr_nrdconta => pr_nrdconta       --> Conta
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic                              
                              ,pr_dsxmlret => vr_xml);
                                
                               pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                              pr_texto_completo => vr_string,
                                              pr_texto_novo     => vr_xml,
                                              pr_fecha_xml      => TRUE);
      --3.4 Lançamentos Futuros
        pc_consulta_lanc_futuro(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);
                                
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
                                               pr_fecha_xml      => TRUE);
                                
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
                            pr_fecha_xml      => TRUE);

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
                                               pr_fecha_xml      => TRUE);
                                    
      --3.6.3 Produto Limite de Desconto de Título
        pc_consulta_lim_desc_tit(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);  
                                
                                 pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                pr_texto_completo => vr_string,
                                                pr_texto_novo     => vr_xml,
                                                pr_fecha_xml      => TRUE);                                    

      --3.6.4  Produto Cartão de Crédito 
        pc_consulta_hist_cartaocredito(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta       --> Conta
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic                                      
                                      ,pr_dsxmlret => vr_xml);  

         pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                     pr_fecha_xml      => TRUE);

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
                             pr_fecha_xml      => TRUE);                                  

      pr_dsxmlret := vr_dsxmlret;
      
   EXCEPTION
        WHEN OTHERS THEN
          /* Tratar erro */
          pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
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


PROCEDURE pc_consulta_proposta_limite(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_nrctrato IN crawlim.nrctrlim%TYPE       --> Contrato
                                     ,pr_cdcritic OUT PLS_INTEGER                --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                   --> Descricao da critica
                                     ,pr_dsxmlret IN OUT CLOB) IS                --> Arquivo de retorno do XML
  /* .............................................................................

    Programa: pc_consulta_proposta
    Sistema : Aimaro/Ibratan
    Autor   : Rubens Lima
    Data    : Março/2019                 Ultima atualizacao: 17/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta do proponente para o produto limite desconto de título

    Alteracoes:
  ..............................................................................*/

  vr_dsxmlret CLOB;
  vr_dstexto     CLOB;
  vr_string      CLOB;

  --Data para consultar a proposta
  rw_crapdat  btch0001.cr_crapdat%rowtype;

  /* Dados da Solicitação - Proposta do Proponente - Task 16167 */
  cursor c_limites_desconto_titulos (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
   select fn_tag('Valor Limite Solicitado',to_char(lim.vllimite,'999g999g990d00')) vllimite
         ,fn_tag('Contrato',lim.nrctrlim) nctrlim
         ,fn_tag('Linha Desconto',(select dsdlinha from crapldc
                                   where  cdcooper = lim.cdcooper
                                   and    cddlinha = lim.cddlinha
                                   and    tpdescto = 3)) dsdlinha
         ,fn_tag('Valor Médio Titulos',(select to_char(vlmedchq,'999g999g990d00')
                                        from crapprp
                                        where cdcooper = lim.cdcooper
                                        and   nrdconta = lim.nrdconta
                                        and   nrctrato = lim.nrctrlim)) vlmedtit
         ,case lim.insitlim when 1 then fn_tag('Situação Proposta','EM ESTUDO')
                            when 2 then fn_tag('Situação Proposta','ATIVA')
                            when 3 then fn_tag('Situação Proposta','CANCELADA')
                            when 5 then fn_tag('Situação Proposta','APROVADA')
                            when 6 then fn_tag('Situação Proposta','NÃO APROVADA')
                            when 8 then fn_tag('Situação Proposta','EXPIRADA DECURSO DE PRAZO')
                            when 9 then fn_tag('Situação Proposta','ANULADA')
                            else        fn_tag('Situação Proposta','DIFERENTE')
          end dssitlim
         ,case lim.insitest when 0 then fn_tag('Situação Análise','NÃO ENVIADO')
                            when 1 then fn_tag('Situação Análise','ENVIADA ANALISE AUTOMÁTICA')
                            when 2 then fn_tag('Situação Análise','ENVIADA ANALISE MANUAL')
                            when 3 then fn_tag('Situação Análise','ANÁLISE FINALIZADA')
                            when 4 then fn_tag('Situação Análise','EXPIRADA')
                            else        fn_tag('Situação Análise','DIFERENTE')
          end dssitest
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
          end dssitapr
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
      vr_string := vr_string||
                  '<campos>'||
                     r_limites_desconto_titulos.vllimite||
                     r_limites_desconto_titulos.nctrlim||
                     r_limites_desconto_titulos.dsdlinha||
                     r_limites_desconto_titulos.vlmedtit||
                     --r_limites_desconto_titulos.dssitlim||
                     --r_limites_desconto_titulos.dssitest||
                     --r_limites_desconto_titulos.dssitapr||
                  '</campos>';
    end if;
  close c_limites_desconto_titulos;

  vr_string := vr_string||'</subcategoria>';

  -- Escrever no XML
  pc_escreve_xml(pr_xml            => vr_dsxmlret,
                 pr_texto_completo => vr_dstexto,
                 pr_texto_novo     => vr_string,
                 pr_fecha_xml      => TRUE);

  -- Cria o XML a ser retornado
  pr_dsxmlret := vr_dsxmlret;
  
 EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_limite: '||sqlerrm;   

  END;

  PROCEDURE pc_consulta_proposta_epr(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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

    Alteracoes:
  ..............................................................................*/
          
  /*Busca o número do tipo de garantia conforme b1wgen0002*/

  CURSOR c_busca_nrgarope IS
   SELECT nrgarope from crapprp
   WHERE cdcooper = pr_cdcooper
   AND   nrdconta = pr_nrdconta
   AND   nrctrato = pr_nrctrato;
   
  CURSOR c_busca_dsgarantia (pr_nrgarope craprad.nrseqite%TYPE) IS
   SELECT dsseqite
   FROM craprad
   WHERE cdcooper = pr_cdcooper
   AND nrtopico = 2
   AND nritetop = 2
   AND nrseqite = pr_nrgarope;   
    
   CURSOR cr_crapbpr IS 
      SELECT t.dscatbem
        FROM crapbpr t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctrpro = pr_nrctrato;
       rw_crapbpr cr_crapbpr%ROWTYPE;
       
   CURSOR cr_crawepr IS
    SELECT c.dtlibera, c.vlemprst
    FROM crawepr c
    WHERE c.cdcooper = pr_cdcooper
    AND   c.nrdconta = pr_nrdconta
    AND   c.nrctremp = pr_nrctrato;
    r_crwepr cr_crawepr%ROWTYPE;
    
    /*Lista dos contratos liquidados para buscar o saldo devedor*/
    CURSOR c_liquidacoes IS
     SELECT ctrliq
     FROM crawepr
     UNPIVOT (ctrliq FOR data IN (nrctrliq##1, nrctrliq##2, nrctrliq##3, nrctrliq##4, nrctrliq##5,
                                  nrctrliq##6, nrctrliq##7, nrctrliq##8, nrctrliq##9, nrctrliq##10))
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta
     AND   nrctremp = pr_nrctrato
     AND   ctrliq <> 0;
     
  --Variáveis
  vr_dsxmlret CLOB;  
  vr_string_contrato_epr CLOB;      
  vr_string_aux CLOB;  
  vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
  vr_vlutiliz NUMBER;
  vr_nrgarope NUMBER;
  
  vr_dscatbem       varchar2(1000);  
  vr_vlrdoiof       number;
  vr_vlrtarif       number;
  vr_vlrtares       number;
  vr_vltarbem       number;
  vr_vlpreclc       NUMBER := 0;                -- Parcela calcula
  vr_vliofpri       number;
  vr_vliofadi       number;
  vr_flgimune PLS_INTEGER;
  vr_cdhistor NUMBER := 0;                -- Historico
  vr_vlfinanc NUMBER := 0;
  vr_cdfvlcop crapfco.cdfvlcop%TYPE;
  
  vr_cdusolcr      craplcr.cdusolcr%type;
  vr_tpctrato      craplcr.tpctrato%type;
  vr_totslddeved   NUMBER :=0;
  
  vr_dstextab            craptab.dstextab%TYPE;
  vr_dstextab_parempctl  craptab.dstextab%TYPE;
  vr_dstextab_digitaliza craptab.dstextab%TYPE;
  vr_inusatab            BOOLEAN;
  vr_qtregist      NUMBER;
  vr_tab_dados_epr empr0001.typ_tab_dados_epr;
  
  begin
  
   -- Criar documento XML
   dbms_lob.createtemporary(vr_dsxmlret, TRUE);
   dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
   
   -- Inicio Garantia
    /* bug 20830 - busca conforme o progress */
    OPEN c_busca_nrgarope;
     FETCH c_busca_nrgarope INTO vr_nrgarope;
      /*Se encontrar número de garantia busca a descrição*/
      IF c_busca_nrgarope%FOUND THEN
        
        OPEN c_busca_dsgarantia(vr_nrgarope);
         FETCH c_busca_dsgarantia INTO vr_garantia;
        CLOSE c_busca_dsgarantia;
        
      END IF;
    CLOSE c_busca_nrgarope; 
    
                      
    --> listar avalistas de contratos
    DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                        ,pr_cdagenci => 0  --> Código da agencia
                        ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                        ,pr_cdoperad => 1  --> Código do Operador
                        ,pr_nmdatela => 'ATENDA'  --> Nome da tela
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
                        ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica
                                          
    IF vr_tab_dados_avais.exists(1) THEN
       vr_garantia := 'Avalista ' || vr_tab_dados_avais(1).nrctaava;
    END IF;
                      
    IF vr_tab_dados_avais.exists(2) THEN
       vr_garantia := 'Primeiro Avalista  ' || vr_tab_dados_avais(1).nrctaava||' - '||'Segundo Avalista ' || vr_tab_dados_avais(2).nrctaava;
    END IF;   
    -- Fim Garantia

  
   vr_string_contrato_epr := '<subcategoria>'||
                             '<tituloTela>Proposta</tituloTela>'||
                             '<campos>';
                             
   open c_proposta_epr(pr_cdcooper,pr_nrdconta,pr_nrctrato);
    fetch c_proposta_epr into r_proposta_epr;
    
     if r_proposta_epr.idfiniof = 1 then
       /*IOF - TARIFA - VALOR EMPRESTIMO*/
       FOR rw_crapbpr IN cr_crapbpr LOOP
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
                                       
      SELECT decode(cdusolcr,2,0,cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
             tpctrato
             into 
             vr_cdusolcr,
             vr_tpctrato
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = r_proposta_epr.cdlcremp;
                                          
                                       
       -- Calcula tarifa
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
                                 ,pr_dscritic => vr_dscritic);
          
        vr_vlrtarif := ROUND(nvl(vr_vlrtarif,0),2) + nvl(vr_vlrtares,0) + nvl(vr_vltarbem,0);
        vr_vlfinanc := r_proposta_epr.vlemprst + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);
          
          
        end if;
    
     /*IOF - TARIFA - VALOR EMPRESTIMO*/

      vr_string_contrato_epr := vr_string_contrato_epr||
                                r_proposta_epr.contrato||
                                r_proposta_epr.valor_emprestimo||
                                fn_tag('IOF',to_char(nvl(vr_vlrdoiof,0),'999g999g990d00'))||
                                fn_tag('Tarifa',to_char(nvl(vr_vlrtarif,0),'999g999g990d00'))||
                                fn_tag('Valor Financiado',to_char(nvl(vr_vlfinanc,0),'999g999g990d00'))||
                                r_proposta_epr.valor_prestacoes||    
                                r_proposta_epr.qtd_parcelas||         
                                r_proposta_epr.linha||      
                                r_proposta_epr.finalidade||
                                fn_tag('Garantia', vr_garantia)||
                                r_proposta_epr.cet;
   close c_proposta_epr;                     
    
   /*Valor disponível em -> busca data e calcular o saldo descontando o valor das liquidações bug 20969*/
    
   OPEN cr_crawepr;
    FETCH cr_crawepr INTO r_crwepr;
    IF cr_crawepr%FOUND THEN 
      
    BEGIN  
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
              
            empr0001.pc_obtem_dados_empresti
                             (pr_cdcooper       => pr_cdcooper            --> Cooperativa conectada
                             ,pr_cdagenci       => 0                      --> Código da agência
                             ,pr_nrdcaixa       => 0                      --> Número do caixa
                             ,pr_cdoperad       => 1                      --> Código do operador
                             ,pr_nmdatela       => 'ATENDA'               --> Nome datela conectada
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
                             ,pr_tab_erro       => vr_tab_erro);          --> Tabela com possíves erros
        
        vr_totslddeved := vr_totslddeved + vr_tab_dados_epr(1).vlsdeved;

    END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        vr_totslddeved := 0;
    END;
      /*Valor empréstimo - Total saldo devedor*/
      vr_totslddeved := r_crwepr.vlemprst - vr_totslddeved;
      
      vr_string_contrato_epr := vr_string_contrato_epr||fn_tag('Valor Disponível em '||to_char(r_crwepr.dtlibera,'DD/MM/YYYY'),
                                to_char(vr_totslddeved,'999g999g990d00'));       
    END IF;                          
   CLOSE cr_crawepr;

   /*
   Carregar os dados de operações de crédito + valor da proposta
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
                           
   vr_string_contrato_epr := vr_string_contrato_epr||fn_tag('Endividamento Total do Fluxo',to_char(r_proposta_epr.vlemprst+vr_vlutiliz,'999g999g990d00'));       
    
   vr_string_contrato_epr := vr_string_contrato_epr||'</campos></subcategoria>';     
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
                  pr_fecha_xml      => TRUE);  
  
   pr_dsxmlret := vr_dsxmlret;

 EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_epr: '||sqlerrm;    

  end;
  
PROCEDURE pc_consulta_proposta_cc (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                  ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                  ,pr_nrctrato  IN number
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                  
                                  ,pr_dsxmlret  OUT CLOB) IS
  /* .............................................................................

    Programa: pc_consulta_proposta_cc
    Sistema : Aimaro/Ibratan
    Autor   : Rubens Lima
    Data    : Março/2019                 Ultima atualizacao: 26/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta para Cartão de Crédito

    Alteracoes:
  ..............................................................................*/
                                    
  --Variáveis
  vr_vllimsol number;         --Limite Solicitado
  vr_vllimant number;         --Limite Anterior
--  vr_nmcatatu varchar2(100);  --Categoria Atual
  vr_nmcatant varchar2(100);  --Categoria Anterior
  vr_dtultatu date;           --Data da ultima alteração de limite
  --
  vr_index     number:=1;
  
  vr_string        VARCHAR2(32767) := NULL;
  vr_nrdcartao     CRAWCRD.NRCRCARD%TYPE; --bug 19906
  vr_vllimsgrd     CLOB; --limite sugerido
  vr_dstipcart     VARCHAR2(100); --descrição do tipo cartão
  vr_qtcartadc     NUMBER := 0;

  /*Busca dados cartão*/
  CURSOR c_busca_dados_cartao_cc IS
    SELECT c.vllimcrd vllimativo
          ,a.nmresadm categorianova
          ,c.nrcctitg 
          ,fn_tag('Proposta',c.NRCTRCRD) proposta
    FROM crawcrd c
        ,crapadc a
    WHERE c.cdcooper = a.cdcooper
    AND   c.cdadmcrd = a.cdadmcrd
    AND   c.cdcooper = pr_cdcooper
    AND   c.nrdconta = pr_nrdconta
    AND   c.nrctrcrd = pr_nrctrato;
    r_busca_dados_cartao_cc c_busca_dados_Cartao_cc%ROWTYPE;

  /*Busca histórico de alteração de limite*/
  CURSOR c_historico_credito (pr_nrdconta crapass.nrdconta%TYPE
                             ,pr_cdcooper crapass.cdcooper%TYPE
                             ,pr_nrdcartao crawcrd.nrcrcard%TYPE) IS
      SELECT 
             nvl(atu.vllimite_anterior, atu.vllimite_alterado) vllimite_anterior
           , atu.vllimite_alterado
           , atu.dtalteracao
           , atu.idatualizacao
           , a.nmresadm
        FROM tbcrd_limite_atualiza  atu
            ,crapadc a
       WHERE a.cdcooper = atu.cdcooper
         AND a.cdadmcrd = atu.cdadmcrd 
         AND atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrdcartao
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */
         and atu.nrproposta_est IS NULL
      UNION      
      SELECT 
             atu.vllimite_anterior
           , atu.vllimite_alterado
           , atu.dtalteracao
           , atu.idatualizacao
           , a.nmresadm
        FROM tbcrd_limite_atualiza atu
            ,crapadc a
       WHERE a.cdcooper = atu.cdcooper
         AND a.cdadmcrd = atu.cdadmcrd 
         AND atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrconta_cartao = pr_nrdcartao
         AND atu.nrproposta_est IS NOT NULL
         AND atu.dtalteracao = (SELECT max(dtalteracao)
                                    FROM tbcrd_limite_atualiza lim
                                   WHERE lim.cdcooper       = atu.cdcooper
                                     AND lim.nrdconta       = atu.nrdconta
                                     AND lim.nrconta_cartao = atu.nrconta_cartao
                                     AND lim.nrproposta_est = atu.nrproposta_est)
       ORDER BY idatualizacao DESC;
                                      
  BEGIN
    
    /*Busca dados novo cartão*/
    OPEN c_busca_dados_cartao_cc;
     FETCH c_busca_dados_cartao_cc INTO r_busca_dados_cartao_cc;
     
     IF c_busca_dados_cartao_cc%FOUND THEN

       vr_string := '<subcategoria>'||
                    '<tituloTela>Produto Cartão de Crédito</tituloTela>'||
                    '<campos>'||r_busca_dados_cartao_cc.proposta; -- Adicionado numero proposta
                    

       --categoria solicitada
       vr_dstipcart := r_busca_dados_cartao_cc.categorianova;
       --numero cartão
       vr_nrdcartao := r_busca_dados_cartao_cc.nrcctitg; --bug 19906

     END IF;
    
    CLOSE c_busca_dados_cartao_cc;
      
    
    /*Classifica o tipo do cartão*/
    IF (UPPER(vr_dstipcart) LIKE '%ESSENCIAL%') THEN
      vr_dstipcart := 'ESSENCIAL';
    ELSIF (UPPER(vr_dstipcart) LIKE '%PLATINUM%') THEN
      vr_dstipcart := 'PLATINUM';
    ELSIF (UPPER(vr_dstipcart) LIKE '%GOLD%') THEN
      vr_dstipcart := 'GOLD';
    ELSE
      vr_dstipcart := 'CLASSICO';
    END IF;
    
    /*Busca limite sugerido do motor*/
    BEGIN
      vr_vllimsgrd := fn_le_json_motor_auto_aprov(p_cdcooper      => pr_cdcooper
                                                 ,p_nrdconta      => pr_nrdconta
                                                 ,p_nrdcontrato   => pr_nrctrato 
                                                 ,p_tagFind       => vr_dstipcart
                                                 ,p_hasDoisPontos => false
                                                 ,p_idCampo       => 0);
      /*Extrai valor numérico do texto*/
      vr_vllimsgrd := regexp_substr(vr_vllimsgrd,'[[:digit:]].+');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    /*Busca quantidade de cartão adicional*/
    BEGIN
          SELECT count(1)
          INTO vr_qtcartadc
          FROM crawcrd c
          WHERE c.cdcooper = pr_cdcooper
          AND   c.nrdconta = pr_nrdconta
          AND   c.insitcrd = 4  --em uso
          AND   c.nrctrcrd <> pr_nrctrato;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
      
    /*Busca dados de histórico - houve alteração limite*/
    IF (vr_string IS NOT NULL) THEN

      FOR r1 IN c_historico_credito (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdcartao => vr_nrdcartao ) LOOP
     
        IF vr_index = 1 THEN
          vr_vllimsol := r1.vllimite_alterado;
          --vr_vllimatu := r1.vllimite_anterior;
          vr_dtultatu := r1.dtalteracao;
          vr_nmcatant := r1.nmresadm; --bug 20376
          vr_vllimant := r1.vllimite_anterior;
        ELSE
          vr_vllimant := r1.vllimite_anterior;  
        END IF;
        
         vr_index := vr_index+1;
        
         IF (vr_index >2) THEN
           EXIT;
         END IF;
      
      END LOOP;
    
     --Se tem dados de histórico
     IF (vr_index > 1) THEN
       --pega do histórico
       vr_string := vr_string || fn_tag('Valor de Limite Solicitado',to_char(vr_vllimsol,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Nova Categoria','AILOS '||vr_dstipcart);

       vr_string := vr_string || fn_tag('Quantidade de Cartão Adicional',vr_qtcartadc);
       vr_string := vr_string || fn_tag('Valor do Limite Sugerido', vr_vllimsgrd);
     
       vr_string := vr_string || fn_tag('Valor do Limite Ativo', to_char(r_busca_dados_cartao_cc.vllimativo,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Valor do Limite Anterior', to_char(vr_vllimant,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Categoria Anterior',vr_nmcatant);
       vr_string := vr_string || fn_tag('Última Alteração de Limite',to_char(vr_dtultatu,'DD/MM/YYYY'));

     --Não tem histórico de alteração
     ELSE
       vr_string := vr_string || fn_tag('Valor de Limite Solicitado',to_char(r_busca_dados_cartao_cc.vllimativo,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Nova Categoria','AILOS '||vr_dstipcart);

       vr_string := vr_string || fn_tag('Quantidade de Cartão Adicional',vr_qtcartadc);
       vr_string := vr_string || fn_tag('Valor do Limite Sugerido', vr_vllimsgrd);
   
       vr_string := vr_string || fn_tag('Valor do Limite Ativo', '-');
       vr_string := vr_string || fn_tag('Valor do Limite Anterior', '-');
       vr_string := vr_string || fn_tag('Categoria Anterior','-');
       vr_string := vr_string || fn_tag('Última Alteração de Limite','-');
       
     END IF;
     
    END IF; 

    IF (vr_string IS NOT NULL) THEN
      vr_string := vr_string||'</campos></subcategoria>';
    END IF;

    pr_dsxmlret := vr_string;
    
 EXCEPTION
  WHEN OTHERS THEN
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
    Data    : 05/04/2019                 Ultima atualizacao: 01/05/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta do borderô de desconto de títulos

    Alteracoes: 
    
    TODO's: Valor liquido é valor calculado.
  ..............................................................................*/

  /*Proposta do borderô*/
  cursor c_consulta_prop_desc_titulo is
    SELECT d.dtmvtolt
          ,d.nrborder
          ,d.nrctrlim
          ,d.vllimite
          ,d.txmensal as txmensal
          ,count(1) qtdtitulos
          ,sum(d.vltitulo) vltitulo
          ,sum(d.vlliquid) vlliquid
          ,sum(d.vltitulo) / count(1) vlmedio
          ,d.restricoes ||' RESTRIÇÃO (ÕES)' restricoes
          ,d.flverbor
    from
      (SELECT b.dtmvtolt
            ,b.nrborder
            ,b.nrctrlim
            ,w.vllimite
            ,b.txmensal
            ,t.vltitulo
            ,t.vlliquid
            ,(select count(1)
                     from crapabt r
                     where r.cdcooper = b.cdcooper
                     and   r.nrdconta = b.nrdconta
                     and   r.nrborder = b.nrborder
                     and   r.dsrestri is not null) restricoes
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
      and   b.nrctrlim = pr_nrctrato) d
    group by d.dtmvtolt
            ,d.nrborder
            ,d.nrctrlim
            ,d.vllimite
            ,d.txmensal
            ,d.restricoes
            ,d.flverbor;
  r_consulta_prop_desc_titulo c_consulta_prop_desc_titulo%ROWTYPE;

  /* Títulos do Borderô */
  cursor c_consulta_tits_bordero (pr_nrborder IN craptdb.nrborder%TYPE) IS
  /*b1wgen0030i.p*/                               
  select c.nrcnvcob
        ,c.nrdocmto 
        ,c.nrnosnum
        ,s.nmdsacad
        ,gene0002.fn_mask_cpf_cnpj(c.nrinssac,case when length(c.nrinssac) > 11 then 2 else 1 end) cpfcgc
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
  from craptdb t,
       crapcob c,
       crapsab s
  where t.cdcooper = c.cdcooper
  and   t.nrdconta = c.nrdconta
  and   c.nrdocmto = t.nrdocmto
  and   s.cdcooper = c.cdcooper
  and   s.nrdconta = c.nrdconta
  and   s.nrinssac = c.nrinssac
  and   t.cdcooper = pr_cdcooper
  and   t.nrdconta = pr_nrdconta
  and   t.nrctrlim = pr_nrctrato
  and   t.nrborder = pr_nrborder;
  
  /*Chave para pesquisa da crítica do título*/
  cursor c_consulta_chave (pr_nrborder craptdb.nrborder%TYPE
                          ,pr_nrdocmto craptdb.nrdocmto%TYPE) IS
    select c.cdbandoc || ';' ||
           c.nrdctabb || ';' ||
           c.nrcnvcob || ';' ||
           c.nrdocmto as chave
     from craptdb c
    where c.cdcooper = pr_cdcooper
    and   c.nrdconta = pr_nrdconta
    and   c.nrctrlim = pr_nrctrato
    and   c.nrborder = pr_nrborder
    and   c.nrdocmto = pr_nrdocmto;
    
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
                        
  --Variáveis
  vr_string         CLOB;
  vr_string_critica CLOB;
  vr_index          NUMBER;
  vr_index2         NUMBER;
  vr_str_criticas   CLOB;
  
  
  vr_chave          VARCHAR2(100);
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
  vr_perc_liquidez_qt  VARCHAR2(100);
  
  --Para calculo do valor líquido do titulo
  vr_qtd_dias       NUMBER;
  vr_vldjuros       NUMBER; 
  --Para verificar as taxas de acordo com a versão do bordero
  vr_rel_txdiaria    NUMBER;
  vr_rel_txdanual    NUMBER;

  vr_vlliquid_total  craptdb.vlliquid%type := 0;

                                         
begin

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
        vr_rel_txdanual := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) * 12) * 100,6); 
      ELSE
        vr_rel_txdiaria := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) / 30) * 100,7);                    
        vr_rel_txdanual := apli0001.fn_round((power(1 + (r_consulta_prop_desc_titulo.txmensal / 100), 12) - 1) * 100,6);
      end if;
    
      vr_string := vr_string || '<campos>'||
                           fn_tag('Data da Proposta',to_char(r_consulta_prop_desc_titulo.dtmvtolt,'DD/MM/YYYY'))||
                           fn_tag('Borderô',r_consulta_prop_desc_titulo.nrborder)||
                           fn_tag('Contrato',gene0002.fn_mask_contrato(r_consulta_prop_desc_titulo.nrctrlim))||
                           fn_tag('Limite',to_char(r_consulta_prop_desc_titulo.vllimite,'999g999g990d00'))||
                           fn_tag('Taxa Anual',trim(to_char(vr_rel_txdanual,'990d999'))|| '%')||
                           fn_tag('Taxa Mensal',trim(to_char(r_consulta_prop_desc_titulo.txmensal,'990d999'))|| '%')||
                           fn_tag('Taxa Diária',trim(to_char(vr_rel_txdiaria,'990d999'))|| '%');
    
   vr_index := 1;
   vr_index2 := 0; --para a tabela de criticas
   
   vr_tab_tabela.delete;
   vr_tab_tabela_secundaria.delete;

    /*Monta cabeçalho da tabela com as críticas dos títulos do borderô*/
    vr_string_critica := vr_string_critica||'<campo>
                                             <nome>Crítica dos Títulos</nome>
                                             <tipo>table</tipo>
                                             <valor>
                                             <linhas>';

   --Para cada título da proposta
   for r_titulos in c_consulta_tits_bordero(pr_nrborder => r_consulta_prop_desc_titulo.nrborder)  loop

    if (vr_index = 1) then

      /*Monta a tabela com os títulos dos borderôs*/
      vr_string := vr_string||'<campo>
                               <nome>Títulos do Borderô</nome>
                               <tipo>table</tipo>
                               <valor>
                               <linhas>';

    end if;
   
    vr_tab_tabela(vr_index).coluna1 := r_titulos.nrcnvcob;
    vr_tab_tabela(vr_index).coluna2 := r_titulos.nrdocmto;
    vr_tab_tabela(vr_index).coluna3 := r_titulos.nrnosnum;
    vr_tab_tabela(vr_index).coluna4 := r_titulos.nmdsacad;
    vr_tab_tabela(vr_index).coluna5 := r_titulos.cpfcgc;
    vr_tab_tabela(vr_index).coluna6 := to_char(r_titulos.dtvencto,'DD/MM/YYYY');
    vr_tab_tabela(vr_index).coluna7 := to_char(r_titulos.vltitulo,'999g999g990d00');
    
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
    vr_tab_tabela(vr_index).coluna8 := to_char(r_titulos.vlliquid,'999g999g990d00');
    vr_tab_tabela(vr_index).coluna9 := r_titulos.prazo;
    vr_tab_tabela(vr_index).coluna10 := r_titulos.restricoes;
    
    /*Limpa a chave*/
    vr_chave := NULL;
    
    /*Buscar a chave para pesquisar as críticas*/
    open c_consulta_chave (pr_nrborder => r_consulta_prop_desc_titulo.nrborder
                          ,pr_nrdocmto => r_titulos.nrdocmto);
    fetch c_consulta_chave into vr_chave;
    close c_consulta_chave;
    

  /*Consulta volume carteira a vencer em relação ao sacado*/    
  open c_titulos_a_vencer(r_titulos.nrinssac);
    fetch c_titulos_a_vencer into vr_val_venc;
    if c_titulos_a_vencer%found then
      vr_tab_tabela(vr_index).coluna12 := to_char(vr_val_venc,'999g999g990d00');
    else
      vr_tab_tabela(vr_index).coluna12 := 0;
    end if;    
  close c_titulos_a_vencer;
  
  /*Consulta informações pagador*/
  pc_detalhes_tit_bordero_web (pr_cdcooper
                              ,pr_nrdconta
                              ,r_consulta_prop_desc_titulo.nrborder
                              ,vr_chave
                              ,null
                               --------> out <--------
                              ,pr_cdcritic
                              ,pr_dscritic
                              ,pr_retxml
                              ,pr_nmdcampo
                              ,pr_des_erro);


  /* Extrai dados do XML */
  BEGIN
     vr_perc_concentracao := pr_retxml.extract('//detalhe/concpaga/node()').getstringval();
     vr_perc_liquidez_vl  := pr_retxml.extract('//detalhe/liqpagcd/node()').getstringval();
     vr_perc_liquidez_qt  := pr_retxml.extract('//detalhe/liqgeral/node()').getstringval();
     
     --se iniciar com vírgula concatena um 0 a esquerda
     vr_tab_tabela(vr_index).coluna13 := case when substr(vr_perc_concentracao,1,1) = ',' 
                                         then 0 || vr_perc_concentracao || '%'
                                         else      vr_perc_concentracao || '%' end;
     vr_tab_tabela(vr_index).coluna14 := vr_perc_liquidez_vl|| '%';
     vr_tab_tabela(vr_index).coluna15 := vr_perc_liquidez_qt|| '%';

  EXCEPTION
    WHEN OTHERS THEN
     vr_tab_tabela(vr_index).coluna13 := '-';
     vr_tab_tabela(vr_index).coluna14 := '-';
     vr_tab_tabela(vr_index).coluna15 := '-';
  END;
  
  --Agora vê se tem críticas
  BEGIN
    vr_nrdocmto := pr_retxml.extract('//pagador/nrinssac/node()').getstringval(); 
    
    --desta forma ainda pega só a primeira crítica
    vr_str_criticas  := pr_retxml.extract('//criticas/node()').getstringval(); --criticas array
    
    if length(vr_str_criticas) = 0 then
      tem_criticas := false;
    else
      tem_criticas := true;
    end if;

    while tem_criticas loop

      vr_pos_inic := instr(vr_str_criticas,'<dsc>') + 5;
      vr_tamanho  := instr(vr_str_criticas,'</dsc>') - vr_pos_inic;

      if (vr_pos_inic < vr_tamanho) then

        vr_index2 := vr_index2 + 1;

        vr_tab_tabela_secundaria(vr_index2).coluna1 := r_titulos.nrnosnum; --doc

        vr_dsc_critica := substr(vr_str_criticas,vr_pos_inic,vr_tamanho);
        vr_tab_tabela_secundaria(vr_index2).coluna2 := vr_dsc_critica; --dsc da crítica
        
        vr_pos_inic := instr(vr_str_criticas,'<vlr>') + 5;
        vr_tamanho  := instr(vr_str_criticas,'</vlr>') - vr_pos_inic;
        vr_vlr_critica := substr(vr_str_criticas,vr_pos_inic,vr_tamanho);
        vr_tab_tabela_secundaria(vr_index2).coluna3 := vr_vlr_critica; --vlr da crítica

      else
        tem_criticas := false; --condição de saída
      end if;
            
      --atualiza
      vr_str_criticas := substr(vr_str_criticas,vr_pos_inic + 18);

    end loop;
  
     IF (vr_index2 > 0) THEN
        vr_tab_tabela(vr_index).coluna11 := 'Sim';
   ELSE
       vr_tab_tabela(vr_index).coluna11 := 'Não';
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

   /*Incrementa o índice*/
   vr_index := vr_index+1;   

   END LOOP;

   /*Monta a tabela dos titulos*/
   IF vr_tab_tabela.COUNT > 0 THEN
     /*Gera Tags Xml*/
     vr_string := vr_string||fn_tag_table('Convênio;Boleto Número;Nosso Número;Nome Pagador;CPF/CNPJ do Pagador;Data de Vencimento;Valor do Título;Valor Líquido;Prazo;Restrições;Críticas;Volume Carteira a Vencer;% Concentração por Pagador;% Liquidez do Pagador com a Cedente;% Liquidez Geral',vr_tab_tabela);
     vr_string := vr_string||'</linhas></valor></campo>';
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
     vr_string := vr_string||fn_tag_table('Convênio;Boleto Número;Nosso Número;Nome Pagador;CPF/CNPJ do Pagador;Data de Vencimento;Valor do Título;Valor Líquido;Prazo;Restrições;Críticas;Volume Carteira a Vencer;% Concentração por Pagador;% Liquidez do Pagador com a Cedente;% Liquidez Geral',vr_tab_tabela);
     vr_string := vr_string||'</linhas></valor></campo>';
   END IF;


    /*Se tiver críticas traz uma tabela em formato lista com as críticas*/
    IF vr_tab_tabela_secundaria.COUNT >0 THEN

      vr_string_critica := vr_string_critica || fn_tag_table('Nosso Número;Crítica;Valor',vr_tab_tabela_secundaria);
      vr_string_critica := vr_string_critica || '</linhas></valor></campo>';

    ELSE

     vr_tab_tabela_secundaria(1).coluna1 := '-';
     vr_tab_tabela_secundaria(1).coluna2 := '-';
     vr_tab_tabela_secundaria(1).coluna3 := '-';
     vr_string_critica := vr_string_critica || fn_tag_table('Nosso Número;Crítica;Valor',vr_tab_tabela_secundaria);
     vr_string_critica := vr_string_critica||'</linhas></valor></campo>';
      
    END IF;
    
    vr_string_critica := vr_string_critica||'</campos>';

  END IF;
    
  close c_consulta_prop_desc_titulo;
  
  vr_string := vr_string ||fn_tag('Quantidade de Títulos',r_consulta_prop_desc_titulo.qtdtitulos)||
                           fn_tag('Valor',TO_CHAR(r_consulta_prop_desc_titulo.vltitulo,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor Líquido',TO_CHAR(vr_vlliquid_total,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor Médio',TO_CHAR(r_consulta_prop_desc_titulo.vlmedio,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Restrições',r_consulta_prop_desc_titulo.restricoes);

  
  vr_string := vr_string || vr_string_critica || '</subcategoria>';
  
  pr_dsxmlret := vr_string;

 EXCEPTION
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_bordero: '||sqlerrm;   

end;

PROCEDURE pc_consulta_outras_pro_epr(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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

   vr_string_outros_epr := vr_string_outros_epr||'<campo>
                                                   <nome>Outras Propostas em Andamento</nome>
                                                   <tipo>table</tipo>
                                                   <valor>
                                                   <linhas>';
   vr_index := 0;
   vr_tab_tabela.delete;                               
   for r_proposta_out_epr in c_proposta_out_epr(pr_cdcooper,pr_nrdconta) loop
    /*Somente as propostas em andamento diferente da atual*/ 
    if pr_nrctrato != r_proposta_out_epr.nrctremp then
      vr_index :=  vr_index+1; 
      
     -- Inicio Garantia
     OPEN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_nrctremp => r_proposta_out_epr.nrctremp);
                      --pr_nrctremp => pr_nrctrato); --bug 20569
      FETCH cr_crapbpr INTO rw_crapbpr;
                        
      -- Resetar a variavel
      vr_garantia := '-';

      -- Se encontrou
      IF cr_crapbpr%FOUND THEN
         vr_garantia := 'Bem';
      END IF;
      CLOSE cr_crapbpr;    
      
      IF trim(r_proposta_out_epr.nrctaav1) > 0 and trim(r_proposta_out_epr.nrctaav2) is null THEN
       vr_garantia := 'Avalista ' || r_proposta_out_epr.nrctaav1;
      ELSIF r_proposta_out_epr.nrctaav2 > 0 and trim(r_proposta_out_epr.nrctaav1) is null THEN
       vr_garantia := 'Avalista ' || r_proposta_out_epr.nrctaav2;
      ELSIF trim(r_proposta_out_epr.nrctaav2) > 0 and trim(r_proposta_out_epr.nrctaav1) > 0 THEN 
       vr_garantia := 'Avalistas ' ||r_proposta_out_epr.nrctaav1 ||'/'||r_proposta_out_epr.nrctaav2; 
      END IF;
      
      vr_tab_tabela(vr_index).coluna1 := to_char(r_proposta_out_epr.dtproposta,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna2 := gene0002.fn_mask_contrato(r_proposta_out_epr.contrato);
      vr_tab_tabela(vr_index).coluna3 := trim(to_char(r_proposta_out_epr.valor_emprestimo,'999g999g990d00'));
      vr_tab_tabela(vr_index).coluna4 := to_char(r_proposta_out_epr.valor_prestacoes,'999g999g990d00');    
      vr_tab_tabela(vr_index).coluna5 := r_proposta_out_epr.qtd_parcelas;         
      vr_tab_tabela(vr_index).coluna6 := r_proposta_out_epr.linha;     
      vr_tab_tabela(vr_index).coluna7 := r_proposta_out_epr.finalidade;
      vr_tab_tabela(vr_index).coluna8 := r_proposta_out_epr.contratos;
      vr_tab_tabela(vr_index).coluna9 := r_proposta_out_epr.situacao;
      vr_tab_tabela(vr_index).coluna10 := r_proposta_out_epr.decisao;
      vr_tab_tabela(vr_index).coluna11 := vr_garantia;
      
      vr_total_proposta := vr_total_proposta+r_proposta_out_epr.vlemprst;  
    end if;
   end loop;  

   --Total Ultima linha para montar o total
   if vr_tab_tabela.COUNT > 0 then
     vr_index :=  vr_index+1;      

     /**/
     vr_tab_tabela(vr_index).coluna1 := '-';
     vr_tab_tabela(vr_index).coluna2 := 'Total';
     vr_tab_tabela(vr_index).coluna3 := to_char(vr_total_proposta,'999g999g990d00');
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
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Prestações;Quantidade de Parcelas;Linha de Crédito;Finalidade;Liquidações;Situação;Decisão;Garantia',vr_tab_tabela);
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
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Prestações;Quantidade de Parcelas;Linha de Crédito;Finalidade;Liquidações;Situação;Decisão;Garantia',vr_tab_tabela);
    end if;
     
     vr_string_outros_epr := vr_string_outros_epr||'</linhas>
                                            </valor>
                                            </campo>';

/**/   
                   
   if pr_nrctrato > 0 then 
     vr_string_outros_epr := vr_string_outros_epr||'</campos></subcategoria>';     
   end if;  

   pr_dsxmlret := vr_string_outros_epr;
  
  exception
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_outras_pro_epr: '||sqlerrm; 
  end;

  PROCEDURE pc_consulta_consultas(pr_cdcooper IN crapass.cdcooper%TYPE  --> Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE         --> Conta
                                 ,pr_nrcontrato IN crawepr.nrctremp%TYPE 
                                 ,pr_inpessoa  IN crapass.inpessoa%TYPE
                                 ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE                                 
                                 ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB) is

                   
    /* .............................................................................
    Programa: pc_cria_categoria_consulta_proponente
    Sistema : Aimaro/Ibratan
    Autor   : Bruno Luiz Katzjarowski - Mout's 
    Data    : Março/2019                 Ultima atualizacao:
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
          from crapneg a, 
               crapope c WHERE 
          a.cdcooper = pr_cdcooper AND
          a.cdobserv in (12,13) AND 
          a.nrdconta = pr_nrdconta  AND
          c.cdcooper = a.cdcooper AND
          c.cdoperad = a.cdoperad;
   rw_dtultimadevolu cr_dtultimadevolu%rowtype;
   
   --Recuperar ultimo estouro
   cursor cr_ultimoEstouro is
          select * from crapneg a
          WHERE a.cdcooper = pr_cdcooper
            and a.nrdconta = pr_nrdconta
            and a.dtiniest = (select max(b.dtiniest) from crapneg b where a.nrdconta = b.nrdconta and a.cdcooper = b.cdcooper) 
            and a.cdhisest = 5  -- estouro
          order by a.dtiniest DESC;
   rw_ultimoEstouro cr_ultimoEstouro%rowtype;
   
   -- Recuperar todos os estouros dos ultimos 6 meses
   cursor cr_estouros6Meses is
          select * from crapneg a where
                     a.cdcooper = pr_cdcooper and
                     a.dtiniest >= (select trunc(add_months(c.dtmvtolt, -6),'MM') dtOld from crapdat c where c.cdcooper = a.cdcooper) and
                     a.nrdconta = pr_nrdconta and 
                     a.cdhisest = 5 ; -- estouro
   
   -- Cadastro de Risco -> Campos: nivel de risco e justificativa (tela CADRIS)
   cursor cr_cadris is
        SELECT tcc.nrdconta
              ,tcc.dsjustificativa
              ,ass.nmprimtl
              ,tcc.cdnivel_risco
          FROM tbrisco_cadastro_conta tcc,
               crapass ass
         WHERE tcc.cdcooper      = pr_cdcooper
           AND tcc.cdcooper      = ass.cdcooper
           AND tcc.nrdconta      = ass.nrdconta
           and ass.nrdconta      = pr_nrdconta;
   rw_cadris cr_cadris%rowtype;
   
   -- Dias estourados
   cursor c_dias_estouros is
    select s.qtddtdev,s.dtdsdclq,s.qtdriclq
      from crapsld s
     where s.cdcooper = pr_cdcooper
       and s.nrdconta = pr_nrdconta;
   r_dias_estouros c_dias_estouros%rowtype;      
   
   -- Risco Final
   	CURSOR c_risco_final(pr_cdcooper NUMBER
                        , pr_nrdconta NUMBER
                        , pr_dtmvtoan DATE) IS
    SELECT distinct RISC0004.fn_traduz_risco(ris.inrisco_final) risco_final
      FROM tbrisco_central_ocr ris
     WHERE ris.cdcooper = pr_cdcooper
       AND ris.nrdconta = pr_nrdconta
			 AND ris.dtrefere = pr_dtmvtoan;
    --    
   r_risco_final c_risco_final%rowtype;
    
  /*Adiantamento de depositante*/
  cursor c_ad(pr_cdcooper number,
              pr_dtmvtolt date,
              pr_nrdconta number) is
    SELECT abs(sda.vlsddisp) - abs(sda.vllimcre) adiantamento_depositante,
           sda.vllimcre,
           sda.vlsddisp
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper
     AND   sda.dtmvtolt = pr_dtmvtolt
     AND   sda.nrdconta = pr_nrdconta;
     r_ad c_ad%rowtype;             
    
    /*Escore BVS*/ 
    cursor c_crapesc(pr_nrconbir in number) is
    select dsescore,
           vlpontua,
           dsclassi
      from crapesc
     where nrconbir = pr_nrconbir
       and (dsescore like '%PF%' or
            dsescore like '%PJ%');
    r_crapesc c_crapesc%rowtype;  
    --
    CURSOR cr_craprad (pr_cdcooper IN craprad.cdcooper%TYPE,
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
    CURSOR cr_tbcrd_score(pr_cdcooper      crapcop.cdcooper%TYPE
                         ,pr_inpessoa      crapass.inpessoa%TYPE
                         ,pr_nrcpfcnpjbase tbcrd_score.nrcpfcnpjbase%TYPE) IS
      SELECT sco.cdmodelo
            ,csc.dsmodelo
            ,to_char(sco.dtbase,'dd/mm/rrrr') dtbase
            ,sco.nrscore_alinhado
            ,sco.dsclasse_score
            ,nvl(sco.dsexclusao_principal,'-') dsexclusao_principal
            ,decode(sco.flvigente,1,'Vigente','Não vigente') dsvigente
            ,row_number() over (partition By sco.cdmodelo
                                    order by sco.flvigente DESC, sco.dtbase DESC) nrseqreg          
        FROM tbcrd_score sco
            ,tbcrd_carga_score csc
       WHERE csc.cdmodelo      = sco.cdmodelo
         AND csc.dtbase        = sco.dtbase
         AND sco.cdcooper      = pr_cdcooper
         AND sco.tppessoa      = pr_inpessoa
         AND sco.nrcpfcnpjbase = pr_nrcpfcnpjbase
         AND sco.dtbase >=     TRUNC( add_months(rw_crapdat.dtmvtolt,-6),'MM') 
       ORDER BY sco.flvigente DESC
               ,sco.dtbase DESC;
    rw_score cr_tbcrd_score%ROWTYPE;  
    
   vr_string_operacoes CLOB;  --XML de retorno
   vr_index number;   --Index
   v_haspreju varchar2(10); -- Retorno teve preju
   
   v_rtReadJson varchar2(1000) := null;
   v_somaValores number;
   v_count number;
   v_ehnumero NUMBER;
  begin
  
  
  /*Informações Cadastrais*/
  --Abertura da tag de Subcategoria -> Informações Cadastrais
  vr_string_operacoes := '<subcategoria>'||
                           '<tituloTela>Informações Cadastrais</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>informacoes_cadastrais</tituloFiltro>'|| -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria  
  
  
  v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                   p_nrdconta => pr_nrdconta,
                                   p_nrdcontrato => pr_nrcontrato, 
                                   p_tagFind => 'possui restri', --Palavras com ã|õ substituir por ? o caracter
                                   p_hasDoisPontos =>  false,
                                   p_idCampo => 0);

   --Buscar detalhes
   sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrconbir => vr_nrconbir,
                                   pr_nrseqdet => vr_nrseqdet);                                   
  
  /*bug 20855*/
  IF nvl(v_rtReadJson,'-') = '-' THEN
    vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Situação','Sem Restrições');
  ELSE
     vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Situação','Com Restrições');
  END if;
    
     vr_string_operacoes := vr_string_operacoes||'<campo>
                                                  <nome>Registro SPC</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
     vr_index := 1;
     vr_tab_tabela.delete;
     for r_craprsc in c_craprsc(vr_nrconbir,vr_nrseqdet) loop
      vr_tab_tabela(vr_index).coluna1 := r_craprsc.inlocnac;
      vr_tab_tabela(vr_index).coluna2 := r_craprsc.dsinstit;
      vr_tab_tabela(vr_index).coluna3 := r_craprsc.nmcidade;
      vr_tab_tabela(vr_index).coluna4 := r_craprsc.cdufende;
      vr_tab_tabela(vr_index).coluna5 := to_char(r_craprsc.dtregist,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna6 := to_char(r_craprsc.dtvencto,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna7 := to_char(r_craprsc.vlregist,'999g999g999g990d00');
      vr_tab_tabela(vr_index).coluna8 := r_craprsc.dsmtvreg;
      vr_index := vr_index+1;
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

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  
  
  -- Bug: 20966 - Incluir para pessoa Fisica também
  IF r_pessoa.inpessoa = 1 THEN -- Fisica
    --
    --Patrimônio Pessoal Livre
    v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                     p_nrdconta => pr_nrdconta,
                                     p_nrdcontrato => pr_nrcontrato, 
                                     p_tagFind => 'patrimonioPessoalLivre',
                                     p_hasDoisPontos =>  true,
                                     p_idCampo => 0);
                                       
    v_ehnumero := NULL;
    BEGIN
      v_ehnumero := to_number(v_rtReadJson);     
    EXCEPTION
      WHEN OTHERS THEN
       v_ehnumero := NULL;
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                  v_rtReadJson);
    END; 
    IF v_ehnumero IS NOT NULL THEN
      -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
      FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                    3,
                                    9,
                                    v_ehnumero) LOOP                                            
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                     v_rtReadJson || ' - '||rw_craprad.dsseqite);   
      END LOOP;
    END IF;  
  --
  ELSIF r_pessoa.inpessoa IN (2,3) THEN -- Jurídica
      --Percepc?o geral da empresa
      v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                       p_nrdconta => pr_nrdconta,
                                       p_nrdcontrato => pr_nrcontrato, 
                                       p_tagFind => 'percepcaoGeralEmpresa', --Palavras com ã|õ substituir por ? o caracter
                                       p_hasDoisPontos =>  true,
                                       p_idCampo => 0);
      v_ehnumero := NULL;
      BEGIN
        v_ehnumero := to_number(v_rtReadJson);     
      EXCEPTION
        WHEN OTHERS THEN
         v_ehnumero := NULL;
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
                              v_rtReadJson|| ' - ' || rw_craprad.dsseqite);
        END LOOP;
      END IF;
      --
      --Patrimônio Pessoal Livre
      v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                       p_nrdconta => pr_nrdconta,
                                       p_nrdcontrato => pr_nrcontrato, 
                                       p_tagFind => 'patrimonioPessoalLivre',
                                       p_hasDoisPontos =>  true,
                                       p_idCampo => 0);
                                       
      v_ehnumero := NULL;
      BEGIN
        v_ehnumero := to_number(v_rtReadJson);     
      EXCEPTION
        WHEN OTHERS THEN
         v_ehnumero := NULL;
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                    v_rtReadJson);
      END; 
      IF v_ehnumero IS NOT NULL THEN
        -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
        FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                      3,
                                      9,
                                      v_ehnumero) LOOP                                            
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrimônio Pessoal Livre',
                       v_rtReadJson || ' - '||rw_craprad.dsseqite);   
        END LOOP;
      END IF;
                            
                               
   END IF;   
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';
   
  /*Ocorrências*/
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Ocorrências</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>ocorrencias</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; 
                            
  --Montar Valores Somente com conta estourada na data                          
  open c_ad(pr_cdcooper,rw_crapdat.dtmvtoan,pr_nrdconta);
   fetch c_ad into r_ad;
    if r_ad.adiantamento_depositante > 0 then
  --Qtd de Adiantamento a Depositantes:
  open cr_ultimoEstouro;
     fetch cr_ultimoEstouro into rw_ultimoEstouro;
     vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Adiantamento a Depositantes',
                                                                              rw_ultimoEstouro.Qtdiaest);
  close cr_ultimoEstouro;     
 
  --Quantidade de Estouros:
  open c_dias_estouros;
   fetch c_dias_estouros into r_dias_estouros;
    vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Estouros',nvl(r_dias_estouros.qtddtdev,0));
  close c_dias_estouros; 

   --Valor do Estouro:
   vr_string_operacoes := vr_string_operacoes
                       ||tela_analise_credito.fn_tag('Valor do Estouro',TO_CHAR(rw_ultimoEstouro.Vlestour,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));  
    else                           
       vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Adiantamento a Depositantes','-')||
                                                   tela_analise_credito.fn_tag('Quantidade de Estouros','-')||
                                                   tela_analise_credito.fn_tag('Valor do Estouro','-');   
    end if;
  close c_ad; 
                            
                         
  --Mostrar a Média de Estouros dos Últimos 6 meses
   v_somaValores := 0;       
   v_count := 0;               
   FOR item IN cr_estouros6Meses
   LOOP
       v_somaValores := v_somaValores + item.Vlestour;
       v_count := v_count + 1;
   END LOOP;
  
   if v_count > 0 then
      v_somaValores := v_somaValores/v_count;
   else 
      v_somaValores := 0;
   end if;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Média de Estouros dos Últimos 6 meses',
                                                                            to_char(TRUNC(v_somaValores,2)));       
  --CL:
  -- Crédito Líquido/(dd) - BUG 20967
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('CL',nvl(r_dias_estouros.qtdriclq,0)||'/'||
                                                                                                  nvl(to_char(r_dias_estouros.dtdsdclq,'dd/mm/rrrr'),'-'));
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
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';        
  
  /*CCF Interno*/
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Consulta do CCF Interna</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>consulta_ccfi</tituloFiltro>'|| -- ID da subcategoria
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

   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';  
  
  /*CCF Externa*/  
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Consulta do CCF Externa</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>consulta_ccfe</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria  
  --Banco:
  --Quantidade de Cheques:  
   vr_string_operacoes := vr_string_operacoes||'<campo>
                                                <nome>CCF Externa</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
   vr_index := 1;
   vr_tab_tabela.delete;
   for r_crapcsf in c_crapcsf(vr_nrconbir,vr_nrseqdet) loop
    vr_tab_tabela(vr_index).coluna1 := r_crapcsf.nmbanchq;
    --vr_tab_tabela(vr_index).coluna2 := r_crapcsf.vlcheque;
    vr_tab_tabela(vr_index).coluna2 := r_crapcsf.qtcheque;
    vr_index := vr_index+1;
   end loop;

    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Banco;Quantidade de Cheques',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Banco;Quantidade de Cheques',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';  

   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';                                                    
  
  /*Score de Mercado*/
   --Score:
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Score do Mercado</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>score_do_mercado</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria
   
  
      v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                       p_nrdconta => pr_nrdconta,
                                       p_nrdcontrato => pr_nrcontrato, 
                                       p_tagFind => 'descricaoScoreBVS',
                                       p_hasDoisPontos =>  true,
                                       p_idCampo => 0);
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Score',v_rtReadJson);   
   
   --Pontuação BVS:
   open c_crapesc(vr_nrconbir);
    fetch c_crapesc into r_crapesc;
     if c_crapesc%found then
      vr_string_operacoes := vr_string_operacoes||
                          tela_analise_credito.fn_tag('Pontuação',to_char(r_crapesc.vlpontua,'999g999g990d0'));   
     else
      vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Pontuação','-');   
     end if;
   close c_crapesc;
   
   
   --Situação da Conta:

   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';   
      
   /*Riscos*/
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Riscos</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>riscos</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria
   --Risco Final
   open c_risco_final(pr_cdcooper,pr_nrdconta,rw_crapdat.dtmvtoan);
    fetch c_risco_final into r_risco_final;
      vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Risco Final',nvl(r_risco_final.risco_final,'-'));
   close c_risco_final;
   
   --Nível de Risco
   if vr_tpproduto_principal = c_emprestimo then
     open c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctrato_principal);
      fetch c_proposta_epr into r_proposta_epr;
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Nível de Risco da Proposta de Empréstimo',r_proposta_epr.dsnivris);
     close c_proposta_epr;          
   end if;
   
   --Mostrar o agravamento de risco pelo controle:     
   open cr_cadris;
    fetch cr_cadris into rw_cadris;
      vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Agravamento de Risco pelo Controle',
                            fn_getNivelRisco(rw_cadris.cdnivel_risco));
      vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Justificativa',
                            rw_cadris.dsjustificativa); 
   close cr_cadris;
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';   
  
  /*Score Interno*/
  
  
  --Score Comportamental 
  
  --Será apresentado os últimos 6 meses
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Score Comportamental</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>score_comportamental</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria
   
   vr_string_operacoes := vr_string_operacoes||'<campo>
                                                <nome>Score Comportamental dos Ùltimos 6 meses</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
   vr_index := 1;
   vr_tab_tabela.delete;
   for rw_score in cr_tbcrd_score(pr_cdcooper,pr_inpessoa,pr_nrcpfcgc) loop
    vr_tab_tabela(vr_index).coluna1 := rw_score.dsmodelo;
    vr_tab_tabela(vr_index).coluna2 := rw_score.dtbase;
    vr_tab_tabela(vr_index).coluna3 := rw_score.dsclasse_score;
    vr_tab_tabela(vr_index).coluna4 := rw_score.nrscore_alinhado;
    vr_tab_tabela(vr_index).coluna5 := rw_score.dsexclusao_principal;
    vr_tab_tabela(vr_index).coluna6 := rw_score.dsvigente;
    vr_index := vr_index+1;
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

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';  
   
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';
   
   
   pr_dsxmlret := vr_string_operacoes;   
  exception
   when others then
    pr_cdcritic := 0;
    pr_dscritic := substr('Erro pc_consulta_consultas: '||sqlerrm,1,250);
  end pc_consulta_consultas;

  PROCEDURE pc_gera_token_ibratan(pr_cdcooper IN crapope.cdcooper%TYPE, --> cooperativa
                                  pr_cdagenci IN crapope.cdagenci%TYPE, --> Agencia
                                  pr_cdoperad IN crapope.cdoperad%TYPE, --> Operador
                                  pr_dstoken  OUT VARCHAR2, --> Token
                                  pr_cdcritic OUT PLS_INTEGER, --> Código da crítica
                                  pr_dscritic OUT VARCHAR2     --> Descrição da crítica
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
    -- Gera o codigo do token
    vr_dstoken := substr(dbms_random.random,1,10);

    -- Atualiza a tabela de senha do operador
    BEGIN
      UPDATE crapope
         SET cddsenha = vr_dstoken
       WHERE upper(cdoperad) = upper(vr_cdoperad);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar CRAPOPE: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    --
    -- Processamento OK, retorna Token
    pr_dstoken := vr_dstoken;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dstoken := NULL;
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic||' '||GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_gera_token_ibratan: ' || SQLERRM;
      pr_dstoken := NULL;

      ROLLBACK;
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
    GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
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
    vr_vltotmes DECIMAL(10,2);

    vr_referenc VARCHAR2(7);

    vr_string   CLOB;
    vr_index    number;

    --------------------------- SUBROTINAS INTERNAS --------------------------

    FUNCTION fn_busca_data_ret(pr_dtmvtolt crapdat.dtmvtolt%TYPE) RETURN DATE IS
    BEGIN
      RETURN ADD_MONTHS(  TO_DATE('01'||TO_CHAR(pr_dtmvtolt,'MM/RRRR'),'DD/MM/RRRR')   ,-3);
    END fn_busca_data_ret;

  BEGIN

    vr_contlan := 0; /*conta qtos meses*/

    vr_mesante := 0; /*jogada no loop pra saber qdo quebrou o mes*/
    vr_vltotmes:= 0; /*valor total dos lancamentos em cada mes*/

    vr_index := 0;
    vr_tab_tabela.delete;

    /* ler a tbfolha_lanaut pegar os ultimos 3 resultados da query
     ou se flultimo estiver ativa pegar apenas o ultimo*/
    FOR rw_tbfolha_lanaut IN cr_tbfolha_lanaut(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_dtmvtolt => fn_busca_data_ret(rw_crapdat.dtmvtolt))LOOP

      vr_mesatual := TO_NUMBER(TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'MM'));

      IF vr_mesante <> vr_mesatual THEN

         /*Cria o registro totalizador*/
         IF vr_vltotmes > 0 THEN

           /*VALOR TOTAL DO MES*/
           vr_index := vr_index+1;
           vr_tab_tabela(vr_index).coluna1 := '-';
           vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFERÊNCIA - ' || vr_referenc || '&lt;/b&gt;';
           vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';

           vr_vltotmes := 0;
         END IF;

         vr_referenc :=  LPAD(TO_CHAR(vr_mesatual),2,'0')||'/'||TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'RRRR');

         vr_contlan := vr_contlan + 1;
         vr_mesante := vr_mesatual;
      END IF;

      --Data, valor e histórico
      vr_index := vr_index+1;
      vr_tab_tabela(vr_index).coluna1 := TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'DD/MM/RRRR');
      vr_tab_tabela(vr_index).coluna2 := rw_tbfolha_lanaut.dshistor;
      vr_tab_tabela(vr_index).coluna3 := TO_CHAR(rw_tbfolha_lanaut.vlrenda,'fm9g999g999g999g999g990d00');

      vr_vltotmes := vr_vltotmes + rw_tbfolha_lanaut.vlrenda;

    END LOOP;

    /*Criar lancamento total para ultimo mes do loop*/
    IF vr_vltotmes > 0 THEN

       /*VALOR TOTAL DO MES E REFERENCIA*/
       vr_index := vr_index+1;
       vr_tab_tabela(vr_index).coluna1 := '-';
       vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFERÊNCIA - ' || vr_referenc || '&lt;/b&gt;';
       vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';
    END IF;

    if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string := vr_string||fn_tag_table('Data;Descrição;Valor',vr_tab_tabela);
    else
       vr_tab_tabela(1).coluna1 := '-';
       vr_tab_tabela(1).coluna2 := '-';
       vr_tab_tabela(1).coluna3 := '-';
       vr_string := vr_string||fn_tag_table('Data;Descrição;Valor',vr_tab_tabela);
    end if;
    pr_xmlRenda := vr_string;

  END pc_busca_rendas_aut; 
  
  PROCEDURE pc_consulta_hist_cartaocredito(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
       --  AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */
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
       WHERE atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
        -- AND atu.nrconta_cartao = pr_nrcctitg
         AND atu.nrproposta_est IS NOT NULL
         AND atu.dtalteracao = (SELECT max(dtalteracao) --bug 20705
                                    FROM tbcrd_limite_atualiza lim
                                   WHERE lim.cdcooper       = atu.cdcooper
                                     AND lim.nrdconta       = atu.nrdconta
                                     AND lim.nrconta_cartao = atu.nrconta_cartao
                                     AND lim.nrproposta_est = atu.nrproposta_est)
       ORDER BY idatualizacao DESC;
    
   /* Cursor para buscar os cartões quando não existir histórico */
   CURSOR c_busca_cartoes_cc IS
     select c.dtpropos
           ,c.nrctrcrd
           ,CASE WHEN c.dtcancel IS NOT NULL THEN 'CANCELADO' ELSE 
                 DECODE(c.insitcrd,0,'EM ESTUDO',1,'APROVADO',2,'SOLICITADO',3,'LIBERADO',4,'EM USO') END insitcrd
           ,c.vllimcrd
     from crawcrd c
     where cdcooper = pr_cdcooper
     and   nrdconta = pr_nrdconta
     order by dtpropos desc;  
   r_busca_cartoes_cc c_busca_cartoes_cc%ROWTYPE;
   
   vr_index number := 1; 
   
   -- variaveis
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;
   flg_majora BOOLEAN;
    
  begin
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Últimas 4 Operações Alteradas - Cartão de Crédito</tituloTela>'||
                   '<campos>';
                   
  vr_string := vr_string ||'<campo>
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
    vr_tab_tabela(vr_index).coluna4 := to_char(r_hist_cartao.vllimite_anterior,'999g999g990d00');
    vr_tab_tabela(vr_index).coluna5 := to_char(r_hist_cartao.vllimite_alterado,'999g999g990d00');
    
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
       
       vr_tab_tabela(vr_index).coluna1 := to_char(r_busca_cartoes_cc.dtpropos,'DD/MM/YYYY');
       vr_tab_tabela(vr_index).coluna2 := r_busca_cartoes_cc.nrctrcrd;
       vr_tab_tabela(vr_index).coluna3 := r_busca_cartoes_cc.insitcrd;
       vr_tab_tabela(vr_index).coluna4 := to_char(r_busca_cartoes_cc.vllimcrd,'999g999g990d00');
   
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
      vr_string := vr_string||fn_tag_table('Data da Proposta;Proposta;Situação;Valor Limite',vr_tab_tabela);
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
  
  vr_string := vr_string||'</linhas>
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
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_hist_cartaocredito: '||sqlerrm; 
  end pc_consulta_hist_cartaocredito;
  
  PROCEDURE pc_consulta_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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

    Alteracoes:
  ..............................................................................*/
    
    
    cursor c_limite_desc_chq is
    select l.vllimite,l.nrctrlim,l.cddlinha,l.nrgarope
      from craplim l
     where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and tpctrlim = 2  -- Linha de Cheque
       and insitlim = 2; -- Ativo   
     --
     r_limite_desc_chq c_limite_desc_chq%rowtype;  
     
    cursor c_bordero_cheques is 
    select c.vlcheque
      from crapcdb c
     where c.cdcooper = pr_cdcooper
       and c.nrdconta = pr_nrdconta
       and c.insitchq = 2
       and c.dtlibera > rw_crapdat.dtmvtolt;
        
    cursor c_media_liquidez(pr_dtmvtolt in crapdat.dtmvtolt%type) is 
     select to_char(c.dtlibera,'MM/RRRR') mesano ,insitchq,sum(c.vlcheque) total_valor
       from crapcdb c
      where c.cdcooper = pr_cdcooper
        and c.nrdconta = pr_nrdconta
        and c.dtlibera > pr_dtmvtolt
       group by to_char(c.dtlibera,'MM/RRRR'),insitchq;        
     r_media_liquidez c_media_liquidez%rowtype;
     
     -- variaveis
     vr_string CLOB;
     vr_dsxmlret CLOB;
     vr_dstexto CLOB;
                        
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
    
                            
    vr_string := vr_string||'<subcategoria>
                             <tituloTela>Rotativos Ativos - Modalidade Desconto de Cheques</tituloTela>
                             <campos>';                       

    open c_limite_desc_chq;
     fetch c_limite_desc_chq into r_limite_desc_chq;
      if c_limite_desc_chq%found then
         vr_string := vr_string||fn_tag('Limite',to_char(r_limite_desc_chq.vllimite,'999g999g990d00'));
      else
         vr_string := vr_string||fn_tag('Limite','-');
      end if;
    close c_limite_desc_chq;
    
    for r1 in c_bordero_cheques loop        
        
      vr_vldscchq := vr_vldscchq + r1.vlcheque;
      vr_qtdscchq := vr_qtdscchq + 1;
    
    end loop;  
      
    vr_string := vr_string||fn_tag('Saldo Utilizado',
                 case when vr_vldscchq >0 then to_char(vr_vldscchq,'999g999g990d00') else '-' end);
    
    --Garantia
    open c_busca_garantia(r_limite_desc_chq.nrgarope,pr_cdcooper);
     fetch c_busca_garantia into r_busca_garantia;
     --bug 19884
     if c_busca_garantia%found then
       vr_string := vr_string||fn_tag('Garantia',r_busca_garantia.dsseqite);
     else
       vr_string := vr_string||fn_tag('Garantia','-');
     end if;
    close c_busca_garantia;
    
    --Média e Liquidez
    wrk_idmedia := 0;
    for r_media_liquidez in c_media_liquidez(TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM')) loop -- 6 Meses
         
          -- recupera a media dos ultimos 6 meses...
          if r_media_liquidez.mesano between To_char(ADD_MONTHS(rw_crapdat.dtmvtolt,-6), 'MM/YYYY')
                                         and To_char(ADD_MONTHS(rw_crapdat.dtmvtolt,0), 'MM/YYYY') then
                
               wrk_valor := wrk_valor + r_media_liquidez.total_valor;
               wrk_idmedia := wrk_idmedia + 1;
               
               /*Boletos descontados que foram liquidados 
                nos últimos 06 meses / Boletos emitidos no últimos 06 meses *100 = 
               (Indicador atual do Aimaro);*/
               if r_media_liquidez.insitchq = 2 then
                 wrk_qtd_tit_liquidado := wrk_qtd_tit_liquidado + r_media_liquidez.total_valor;
                 wrk_qtd_tit_total     := wrk_qtd_tit_total + r_media_liquidez.total_valor;
               else
                 wrk_qtd_tit_total := wrk_qtd_tit_total + r_media_liquidez.total_valor;  
               end if;
               
           end if;     
     end loop;  
     
     begin
       wrk_valor := (wrk_valor/wrk_idmedia);
       wrk_liquidez := ((wrk_qtd_tit_liquidado/wrk_qtd_tit_total) * 100);
     exception when zero_divide then
       wrk_valor := 0;
       wrk_liquidez := 0;
     end;
        
    --Média e Liquidez                   
    vr_string := vr_string||fn_tag('Média de Desconto do Semestre',
                 case when vr_vldscchq > 0 then to_char(wrk_valor,'999g999g990d00') else '-' end);
    vr_string := vr_string||fn_tag('Liquidez do Semestre',
                 case when wrk_liquidez > 0 then nvl(to_char(wrk_liquidez),'-')||'%' else '-' end);
    vr_string := vr_string||'</campos></subcategoria>';             
                           
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                  pr_fecha_xml => TRUE); 
                  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret; 
    
  exception
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_desc_chq: '||sqlerrm;     
                                
  end pc_consulta_desc_chq;  
  
  PROCEDURE pc_consulta_lim_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;
                        
  begin
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  vr_string := vr_string ||'<subcategoria>
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
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_chq.dtinivig,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_chq.qtdiavig);
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_chq.vllimite,'999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_lim_chq.insitlim);
      vr_tab_tabela(vr_index).coluna6 := to_char(r_lim_chq.dtcancel,'DD/MM/YYYY');
      
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
  
  vr_string := vr_string||'</linhas>
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
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_desc_chq: '||sqlerrm;     
  end pc_consulta_lim_desc_chq; 
  
  
  
  PROCEDURE pc_consulta_lim_desc_tit(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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

    Alteracoes:
  ..............................................................................*/
    
    cursor c_limite_desc_tit is
      select c.nrctrlim, c.dtinivig, c.vllimite, c.dtfimvig, c.dhalteracao
            ,decode(c.insitlim,1,'Em Estudo',2,'Ativo', 3,'Cancelado','Outro') insitlim
            ,c.dsmotivo 
       from tbdsct_hist_alteracao_limite c
      where cdcooper = pr_cdcooper
      and nrdconta = pr_nrdconta
      and tpctrlim = 3 -- Linha de Titulo
      and insitlim = 3 --  not in (1,2) -- Pegar Somente Cancelados ou outros...
      order by dtinivig desc;

   vr_index number := 1; 
   
   -- variaveis
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;
                        
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
   
    vr_string := vr_string ||'<subcategoria>
                          <tituloTela>Últimas 4 Operações Alteradas - Desconto de Títulos</tituloTela>
                        <campos>
                            <campo>
                              <nome>Produto Limite de Desconto de Título</nome>
	                            <tipo>table</tipo>
                              <valor>
                         <linhas>';
                         
    vr_index := 1;
    vr_tab_tabela.delete;
    
    for r_lim_tit in c_limite_desc_tit loop
      
      vr_tab_tabela(vr_index).coluna1 := to_char(r_lim_tit.nrctrlim);
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_tit.dtinivig,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_tit.dtfimvig,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_tit.vllimite,'999g999g990d00');
      vr_tab_tabela(vr_index).coluna5 := to_char(r_lim_tit.insitlim);
      vr_tab_tabela(vr_index).coluna6 := to_char(r_lim_tit.dsmotivo);
      if trim(to_char(r_lim_tit.dhalteracao,'DD/MM/YYYY')) is not null then
        vr_tab_tabela(vr_index).coluna7 := to_char(r_lim_tit.dhalteracao,'DD/MM/YYYY');
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
  
  vr_string := vr_string||'</linhas>
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
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_desc_tit: '||sqlerrm; 
                                              
  end pc_consulta_lim_desc_tit;
  
  PROCEDURE pc_consulta_lim_cred(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;
                        
  begin
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
  
    vr_string := vr_string ||'<subcategoria>
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
      vr_tab_tabela(vr_index).coluna2 := to_char(r_lim_cred.dtinivig,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna3 := to_char(r_lim_cred.dtfimvig,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna4 := to_char(r_lim_cred.vllimite,'999g999g990d00');
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
  
  vr_string := vr_string||'</linhas>
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
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_lim_cred: '||sqlerrm;      
                                
  end pc_consulta_lim_cred;
  
  PROCEDURE pc_modalidade_lim_credito(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                     ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                     
                                     ,pr_dsxmlret IN OUT CLOB) IS

  -- cursor 3.3.1 a
    cursor c_busca_data is
    SELECT crt.vllimite, crt.nrgarope, crt.inbaslim, crld.vlsmnesp, crld.vlsddisp
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
   vr_des_reto         VARCHAR2(100);
   
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
                                   ,pr_nmdatela => 'ATENDA'
                                   ,pr_flgerlog => 0            --> Não gerar log
                                   ,pr_tab_saldos => vr_tab_saldos
                                   ,pr_tab_libera_epr => vr_tab_libera_epr
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => vr_tab_erro);

     vr_string_lm := vr_string_lm || '<subcategoria>'||
                                     '<tituloTela>Rotativos Ativos - Modalidade Limite de Crédito</tituloTela>'||
                                     '<campos>';
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

          end if;
        close c_busca_data;

        open c_busca_garantia(pr_nrgarope => r_busca_limites.nrgarope
                             ,pr_cdcooper => pr_cdcooper);
                             
         fetch c_busca_garantia into r_busca_garantia;
          if c_busca_garantia%found then

           rating_descricao := TRIM(TO_CHAR(r_busca_garantia.nrseqite)) || ' - ' || TRIM(TO_CHAR(r_busca_garantia.dsseqite));

          end if;
        close c_busca_garantia;

           -- 1 - limite
           vr_string_lm := vr_string_lm || fn_tag('Limite',TRIM(TO_CHAR(ROUND(garantia_vllimite,2),'999g999g990d00')));

           -- 2 - saldo utilizado
             -- teste de mesa
             --garantia_vllimite := 300;
             --saldo_disponivel  := -301;

           IF(saldo_total >= 0) THEN
               -- se o saldo for positivo, mostrar zero
               saldo_utilizado := 0;
           ELSE 
             -- se o saldo for negativo
             saldo_utilizado := saldo_total;
           END IF;  -- fim 2
           vr_string_lm := vr_string_lm || fn_tag('Saldo Utilizado',to_char(nvl(saldo_utilizado,0),'999g999g990d00'));

           -- 3 garantia
           -- 3.1 - Garantia - Valor do Limite
           /*if garantia_inbaslim = 1 THEN
              garantia_descnrga := TRIM(TO_CHAR(ROUND(garantia_vllimite,2),'999g999g990d00')) || ' COTAS DE CAPITAL';
           ELSE
              garantia_descnrga := TRIM(TO_CHAR(ROUND(garantia_vllimite,2),'999g999g990d00')) || ' CADASTRAL';
           END IF;*/
           --vr_string := vr_string || fn_tag('Valor do Limite',garantia_descnrga);

           -- 3.2 - Garantia - Rating
           vr_string_lm := vr_string_lm || fn_tag('Garantia',rating_descricao);

           -- 4: media de utilizacao - Garantia - Media. Neg. Esp. do mes
           vr_string_lm := vr_string_lm || fn_tag('Média de Utilização',TRIM(TO_CHAR(ROUND(garantia_vlsmnesp,2),'999g999g990d00')));

     vr_string_lm := vr_string_lm || '</campos></subcategoria>';      
     --
     pr_dsxmlret := vr_string_lm;
     --
  exception
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_modalidade_lim_credito: '||sqlerrm;  
  end pc_modalidade_lim_credito;
  
  PROCEDURE pc_modalidade_car_cred(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and insitcrd IN (2,3,4)
       and flgprcrd = 1;

    /*Busca os dados do cartão quandi PJ (Busca primeiro cartão. Valores iguais / limite compartilhado) */
    cursor c_busca_cartao_pj is
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and insitcrd IN (2,3,4)
       and rownum <=1;
       
     /*Busca se é PF ou PJ para saber qual cursor abrir*/
     cursor c_busca_tipo_pessoa is
       select c.inpessoa
       from crapass c
       where c.cdcooper = pr_cdcooper
       and   c.nrdconta = pr_nrdconta;
       
    cursor c_busca_lancamentos (pr_nrcontrato in tbcrd_fatura.nrcontrato%type) is
     select round(sum(vlfatura) / count(1), 2) as media_cartao
      from (
        select * 
        from tbcrd_fatura
        where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and nrcontrato = pr_nrcontrato
        order by dtvencimento desc
      ) where rownum <= 3;
    

   vr_index number := 0;
   flg_lancamento boolean := false;
   
   -- variaveis
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;
   vr_inpessoa NUMBER;
                        
  begin
    
    -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string||'<subcategoria>
                             <tituloTela>Rotativos Ativos - Modalidade Cartão de Crédito</tituloTela>
                             <campos>';
   
    vr_tab_tabela.delete;
    
    /*Busca o tipo de pessoa*/
    open c_busca_tipo_pessoa;
     fetch c_busca_tipo_pessoa into vr_inpessoa;
    close c_busca_tipo_pessoa;
    
    
    if (vr_inpessoa = 1) then
    
      for r_cartao in c_busca_cartao loop
        
        if vr_index > 0 then
            vr_string := vr_string||'<campo><tipo>hr</tipo></campo>';
        end if;
        
        vr_string := vr_string || fn_tag('Cartão',to_char(r_cartao.nrcrcard,'9999g9999g9999g9999'));
        vr_string := vr_string || fn_tag('Limite de Crédito',to_char(r_cartao.vllimcrd,'999g999g990d00'));
        
        for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('Média das últimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('Média das últimas 3 faturas','-');
        end if;
        
        vr_string := vr_string || fn_tag('Dia Vencimento',to_char(r_cartao.dddebito));
        vr_string := vr_string || fn_tag('Dia Vencimento 2ª Via',to_char(r_cartao.dddebant));      
        
        vr_index := vr_index + 1;
        
      end loop;
    else
      
      for r_cartao in c_busca_cartao_pj loop
        
        vr_string := vr_string || fn_tag('Cartão',to_char(r_cartao.nrcrcard,'9999g9999g9999g9999'));
        vr_string := vr_string || fn_tag('Limite de Crédito',to_char(r_cartao.vllimcrd,'999g999g990d00'));
        
        for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('Média das últimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('Média das últimas 3 faturas','-');
        end if;
        
        vr_string := vr_string || fn_tag('Dia Vencimento',to_char(r_cartao.dddebito));
        vr_string := vr_string || fn_tag('Dia Vencimento 2ª Via',to_char(r_cartao.dddebant));      
        
        vr_index := vr_index + 1;
        
      end loop;
      
    end if;
    /*Se não encontrou dados, monta uma categoria vazia bug 20672*/
    if (vr_index = 0) then
      vr_string := vr_string || fn_tag('Cartão','-');
      vr_string := vr_string || fn_tag('Limite de Crédito','-');
      vr_string := vr_string || fn_tag('Média das últimas 3 faturas','-');
      vr_string := vr_string || fn_tag('Dia Vencimento','-');
      vr_string := vr_string || fn_tag('Dia Vencimento 2ª Via','-');
    end if;
  
  vr_string := vr_string||'</campos></subcategoria>';
  
  -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                  pr_fecha_xml => TRUE); 
                  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;    
  exception
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_modalidade_car_cred: '||sqlerrm; 
  end pc_modalidade_car_cred; 
    
  
  PROCEDURE pc_consulta_bordero (pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;     

      BEGIN
        
      -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
    vr_string := vr_string||'<subcategoria>
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
        OPEN  cr_crapbdt;
        LOOP
               FETCH cr_crapbdt INTO rw_crapbdt;
               EXIT  WHEN cr_crapbdt%NOTFOUND;
               
               vr_idxbordero := vr_tab_tabela.count + 1;

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


               vr_tab_tabela(vr_idxbordero).coluna1 := to_char(rw_crapbdt.dtmvtolt,'DD/MM/YYYY');
               vr_tab_tabela(vr_idxbordero).coluna2 := to_char(rw_crapbdt.nrborder);
              -- vr_tab_tabela(vr_idxbordero).coluna3 := rw_crapbdt.nrdconta;
               vr_tab_tabela(vr_idxbordero).coluna3 := to_char(rw_crapbdt.nrctrlim);
               vr_tab_tabela(vr_idxbordero).coluna4 := to_char(vr_qt_titulo);
               vr_tab_tabela(vr_idxbordero).coluna5 := to_char(vr_vl_titulo,'999g999g990d00');
               vr_tab_tabela(vr_idxbordero).coluna6 := to_char(vr_qt_apr);
               vr_tab_tabela(vr_idxbordero).coluna7 := to_char(vr_vl_apr,'999g999g990d00');
               vr_tab_tabela(vr_idxbordero).coluna8 := to_char(rw_crapbdt.dssitbdt);
               vr_tab_tabela(vr_idxbordero).coluna9 := to_char(rw_crapbdt.dtlibbdt);
             --  vr_tab_tabela(vr_idxbordero).coluna11 :=  rw_crapbdt.dsinsitapr;
             --  vr_tab_tabela(vr_idxbordero).coluna12   :=  rw_crapbdt.inprejuz;

        END LOOP;
        CLOSE  cr_crapbdt;
        
        
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
  
  vr_string := vr_string||'</linhas>
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

    Alteracoes:
  ..............................................................................*/
     
     
     pr_tab_borderos TELA_ATENDA_DSCTO_TIT.typ_tab_borderos;
     pr_cdcritic PLS_INTEGER;
     pr_dscritic varchar2(4000);
     pr_qtregist INTEGER;
  
     wrk_idmedia pls_integer := 0;
     wrk_valor number(25,2) := 0;
     wrk_qtd_tit_liquidado pls_integer := 0;
     wrk_qtd_tit_total pls_integer := 0;
     wrk_liquidez number(25,2) := 0;
   begin
     
   
       TELA_ATENDA_DSCTO_TIT.pc_busca_borderos (pr_nrdconta => pr_nrdconta
                                 ,pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => TRUNC(add_months(rw_crapdat.dtmvtolt,-2),'MM') -- para fechar 180 dias
                                     --------> OUT <--------
                                 ,pr_qtregist => pr_qtregist
                                 ,pr_tab_borderos  => pr_tab_borderos --> Tabela de retorno
                                 ,pr_cdcritic => pr_cdcritic           --> Código da crítica
                                 ,pr_dscritic => pr_dscritic              --> Descrição da crítica
                                 );
     
   
     wrk_idmedia := 0;
     if pr_tab_borderos.count > 0 then
       
       for vr_idxbordero in pr_tab_borderos.first .. pr_tab_borderos.last loop
          -- recupera a media dos ultimos 6 meses...
          if pr_tab_borderos(vr_idxbordero).dtmvtolt
             between TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM') -- Primeiro dia de 6 meses atrás
                 and rw_crapdat.dtmvtolt then
                
               wrk_valor := wrk_valor + pr_tab_borderos(vr_idxbordero).aux_vltottit;
               wrk_idmedia := wrk_idmedia + 1;
               
               /*Boletos descontados que foram liquidados 
                nos últimos 06 meses / Boletos emitidos no últimos 06 meses *100 = 
               (Indicador atual do Aimaro);*/
               if pr_tab_borderos(vr_idxbordero).dssitbdt = 'LIQUIDADO' then
                 wrk_qtd_tit_liquidado := wrk_qtd_tit_liquidado + pr_tab_borderos(vr_idxbordero).aux_qttottit;
                 wrk_qtd_tit_total := wrk_qtd_tit_total + pr_tab_borderos(vr_idxbordero).aux_qttottit;
               else
                 wrk_qtd_tit_total := wrk_qtd_tit_total + pr_tab_borderos(vr_idxbordero).aux_qttottit;  
               end if;
               
           end if;     
       end loop;  
     end if;
     
     begin
       --wrk_valor := (wrk_valor/wrk_idmedia);
       wrk_valor := (wrk_valor/wrk_qtd_tit_total); -- Média Calculada com base no total de títulos - Paulo
       wrk_liquidez := ((wrk_qtd_tit_liquidado/wrk_qtd_tit_total) * 100);
     exception when zero_divide then
       wrk_valor := 0;
       wrk_liquidez := 0;
     end;
     
    -- return to_char(wrk_valor,'999g999g990d00');
     
     pr_out_media_tit := to_char(wrk_valor,'999g999g990d00');
     pr_out_liquidez := to_char(wrk_liquidez,'999g999g990d00');
   
   end pc_busca_media_titulo;
   
    PROCEDURE pc_consulta_desc_titulo (pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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
    
    wrk_tab_dados_limite   TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite;
    wrk_cdcritica PLS_INTEGER;
    wrk_dscerro VARCHAR2(4000);
    
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
   
   -- variaveis
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;     
   vr_med_tit varchar2(255);
   vr_liquidez varchar2(255);
   vr_dsseqite CRAPRAD.DSSEQITE%TYPE;
                           
   BEGIN
     
     -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
    vr_string := vr_string||'<subcategoria>
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
     open c_busca_garantia_desctit;
    fetch c_busca_garantia_desctit INTO vr_dsseqite;
    close c_busca_garantia_desctit;
    
     pc_busca_media_titulo(pr_cdcooper,pr_nrdconta,vr_med_tit,vr_liquidez);
      
     vr_string := vr_string || fn_tag('Contrato',to_char(gene0002.fn_mask_contrato(wrk_tab_dados_limite(0).nrctrlim)));
     vr_string := vr_string || fn_tag('Início Vigência',to_char(wrk_tab_dados_limite(0).dtinivig,'DD/MM/YYYY'));
     vr_string := vr_string || fn_tag('Limite',to_char(wrk_tab_dados_limite(0).vllimite,'999g999g990d00'));
     vr_string := vr_string || fn_tag('Saldo Utilizado',to_char(wrk_tab_dados_limite(0).vlutiliz,'999g999g990d00'));
     vr_string := vr_string || fn_tag('Garantia',vr_dsseqite); --bug 20410
     vr_string := vr_string || fn_tag('Média de Desconto do Semestre',vr_med_tit);
     vr_string := vr_string || fn_tag('Liquidez',vr_liquidez);
      
    else
           
     vr_string := vr_string || fn_tag('Contrato','-');
     vr_string := vr_string || fn_tag('Início Vigência','-');
     vr_string := vr_string || fn_tag('Limite','-');
     vr_string := vr_string || fn_tag('Saldo Utilizado','-');
     vr_string := vr_string || fn_tag('Garantia','-');
     vr_string := vr_string || fn_tag('Média de Desconto do Semestre','-');
     vr_string := vr_string || fn_tag('Liquidez','-');
      
    end if;
  
    vr_string := vr_string||' </campos></subcategoria>';
                            
    -- Encerrar a tag raiz
    pc_escreve_xml(pr_xml => vr_dsxmlret,
                  pr_texto_completo => vr_dstexto,
                  pr_texto_novo => vr_string,
                  pr_fecha_xml => TRUE); 
                  
    -- Cria o XML a ser retornado
    pr_dsxmlret := vr_dsxmlret;
   EXCEPTION
    WHEN OTHERS THEN
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
     vr_string CLOB;
     vr_dsxmlret CLOB;
     vr_dstexto CLOB;
     vr_index pls_integer;
     
     wrk_tab_erro varchar2(4000);
     wrk_tab_erros GENE0001.typ_tab_erro;
     wrk_totais EXTR0002.typ_tab_totais_futuros;
     wrk_lancamentos EXTR0002.typ_tab_lancamento_futuro;
                              
   begin
     
     -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string||'<subcategoria>
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
       wrk_date_fim := trunc(LAST_DAY(ADD_MONTHS(rw_crapdat.dtmvtolt,1)));
     end if;
     
     EXTR0002.pc_consulta_lancamento (pr_cdcooper => pr_cdcooper              --Codigo Cooperativa
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
                                     ,pr_indebcre => 'D'              -- Debito/Credito
                                     ,pr_des_reto => wrk_tab_erro                          --Retorno OK ou NOK
                                     ,pr_tab_erro => wrk_tab_erros             --Tabela Retorno Erro
                                     ,pr_tab_totais_futuros => wrk_totais  --Vetor para o retorno das informações
                                     ,pr_tab_lancamento_futuro => wrk_lancamentos);
     
     
     
     vr_index := 1;
     vr_tab_tabela.delete;
     
     if wrk_lancamentos.count > 0 then
     for vr_index in wrk_lancamentos.first .. wrk_lancamentos.last loop
     
     
       vr_tab_tabela(vr_index).coluna1 := to_char(wrk_lancamentos(vr_index).dtmvtolt,'DD/MM/YYYY');
       vr_tab_tabela(vr_index).coluna2 := trim(to_char(wrk_lancamentos(vr_index).vllanmto,'999g999g990d00'));
       vr_tab_tabela(vr_index).coluna3 := wrk_lancamentos(vr_index).nrdocmto;
       vr_tab_tabela(vr_index).coluna4 := wrk_lancamentos(vr_index).indebcre;
       vr_tab_tabela(vr_index).coluna5 := wrk_lancamentos(vr_index).dshistor;
  
     end loop;
   
   end if;
     
     
    if vr_tab_tabela.count > 0 then
      /*Gera Tags Xml*/
      vr_string := vr_string||fn_tag_table('Data Débito;Valor;Documento;D/C;Histórico',vr_tab_tabela);

    else
      
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      
      vr_string := vr_string||fn_tag_table('Data Débito;Valor;Documento;D/C;Histórico',vr_tab_tabela);
      
    end if;
    
    vr_string := vr_string||'</linhas>
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
    pr_cdcritic := 0;
    pr_dscritic := substr('Erro pc_consulta_lanc_futuro: '||sqlerrm,1,250);      
   end pc_consulta_lanc_futuro;    
   
    
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
      vr_idtabtitulo INTEGER;
      vr_tab_cobs  gene0002.typ_split;
      vr_tab_chaves  gene0002.typ_split;
      vr_index     INTEGER;
      
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
               /*Faz calculo de liquidez e concentracao e atualiza as criticas*/
/*               DSCT0002.pc_atualiza_calculos_pagador ( pr_cdcooper => rw_crapcob.cdcooper
                                                      ,pr_nrdconta => rw_crapcob.nrdconta 
                                                      ,pr_nrinssac => rw_crapcob.nrinssac 
                                                     --------------> OUT <--------------
                                                     ,pr_pc_cedpag  => vr_aux
                                                     ,pr_qtd_cedpag => vr_aux
                                                     ,pr_pc_conc    => vr_aux
                                                     ,pr_qtd_conc   => vr_aux
                                                     --,pr_pc_geral   => vr_aux
                                                     --,pr_qtd_geral  => vr_aux
                                                     ,pr_cdcritic   => vr_cdcritic
                                                     ,pr_dscritic   => vr_dscritic
                                    );*/
               
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
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo ' ||SQLERRM;
    END;
    END pc_listar_titulos_resumo ;
  
PROCEDURE pc_listar_titulos_resumo_web (pr_cdcooper           in crapcop.cdcooper%TYPE
                                       ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                       ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
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
    
      -- Variável de críticas
       vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
     vr_situacao char(1);
     vr_nrinssac crapcob.nrinssac%TYPE;
     
   -- Variáveis para armazenar as informações em XML
     vr_des_xml         clob;
     vr_texto_completo  varchar2(32600);
     vr_index           pls_integer;

     PROCEDURE pc_escreve_xml( pr_des_dados in varchar2
                             , pr_fecha_xml in boolean default false
                             ) is
     BEGIN
        gene0002.pc_escreve_xml( vr_des_xml
                               , vr_texto_completo
                               , pr_des_dados
                               , pr_fecha_xml );
     END;
     
      BEGIN
        pr_des_erro := 'OK';
        pr_nmdcampo := NULL;

        pc_listar_titulos_resumo(pr_cdcooper  --> Código da Cooperativa
                                ,pr_nrdconta --> Número da Conta
                                ,pr_chave   --> Lista de 'chaves' de titulos a serem pesquisado
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
        DSCT0003.pc_calcula_restricao_cedente(pr_cdcooper=>pr_cdcooper
                                             ,pr_nrdconta=>pr_nrdconta
                                             ,pr_cdagenci=>1
                                             ,pr_nrdcaixa=>1
                                             ,pr_cdoperad=>1
                                             ,pr_nmdatela=>'TELA_ANALISE_CREDITO'
                                             ,pr_idorigem=>1
                                             ,pr_idseqttl=>0
                                             ,pr_tab_criticas=>vr_tab_criticas
                                             ,pr_cdcritic=>vr_cdcritic
                                             ,pr_dscritic=>vr_dscritic);

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
        DSCT0003.pc_calcula_restricao_bordero(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_tot_titulos => vr_qtregist
                                             ,pr_tab_criticas=>vr_tab_criticas
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
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
    -- Autor    : 
    -- Data     : 
    --
    -- Frequencia: Sempre que chamado
    -- Objetivo  : Obter os detalhes do Pagador do Título selecionado na composição do Borderô
    --
    
    ---------------------------------------------------------------------------------------------------------------------
   
    ----------------> VARIÁVEIS <----------------
    
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic        varchar2(1000);        --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_erro        exception;

    -- Demais tipos e variáveis
    vr_idtabcritica      integer;  
    vr_index           pls_integer;
    --  
    vr_idtabtitulo       INTEGER;
    vr_nrinssac            crapcob.nrinssac%TYPE;
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

procedure pc_detalhes_tit_bordero_web (pr_cdcooper    in crapcop.cdcooper%TYPE
                                      ,pr_nrdconta    in crapass.nrdconta%type --> conta do associado
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
        
    vr_index_biro    pls_integer;
    vr_index_critica pls_integer;
        
    -- variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> cód. erro
    vr_dscritic varchar2(1000);        --> desc. erro
   
    BEGIN
      pr_des_erro := 'OK';
      pr_nmdcampo := NULL;
      
    vr_cdcooper := pr_cdcooper;  
      
    /*Dados de teste*/
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
          
      pc_write_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados  >');
                         
      pc_write_xml('<pagador>'||
                         '<nrinssac>'||vr_nrinssac||'</nrinssac>'||
                         '<nmdsacad>'||htf.escape_sc(vr_nmdsacad)||'</nmdsacad>'||
                    '</pagador>');
      
     -- ler os registros de biro e incluir no xml
      vr_index_biro := vr_tab_dados_biro.first;
      
      pc_write_xml('<biro>');
      while vr_index_biro is not null loop  
          pc_write_xml('<craprpf>' || 
                          '<dsnegati>' || vr_tab_dados_biro(vr_index_biro).dsnegati || '</dsnegati>' ||
                          '<qtnegati>' || vr_tab_dados_biro(vr_index_biro).qtnegati || '</qtnegati>' ||
                          '<vlnegati>' || vr_tab_dados_biro(vr_index_biro).vlnegati || '</vlnegati>' ||
                          '<dtultneg>' || to_char(vr_tab_dados_biro(vr_index_biro).dtultneg,'DD/MM/RRRR') || '</dtultneg>' ||
                        '</craprpf>'
                  );
          /* buscar proximo */
          vr_index_biro := vr_tab_dados_biro.next(vr_index_biro);
      end loop;
      pc_write_xml('</biro>');
          
      -- ler os registros de detalhe e incluir no xml

      pc_write_xml('<detalhe>'||
                        '<concpaga>'  || vr_tab_dados_detalhe(0).concpaga || '</concpaga>' ||
                        '<liqpagcd>'  || vr_tab_dados_detalhe(0).liqpagcd || '</liqpagcd>'  ||
                        '<liqgeral>'  || vr_tab_dados_detalhe(0).liqgeral || '</liqgeral>' ||
                        '<dtreapro>'  || vr_tab_dados_detalhe(0).dtreapro || '</dtreapro>' || -- Marcelo Telles Coelho - Mouts - 25/04/2019 - RITM0050653
                     '</detalhe>'
      );
          
          
      -- ler os registros de detalhe e incluir no xml
      vr_index_critica := vr_tab_dados_critica.first;
      pc_write_xml('<criticas>');
      
      WHILE vr_index_critica IS NOT NULL LOOP
            
            pc_write_xml('<critica>'|| 
                             '<dsc>' || vr_tab_dados_critica(vr_index_critica).dsc || '</dsc>' ||
                             '<vlr>' || vr_tab_dados_critica(vr_index_critica).vlr || '</vlr>' ||
                             '</critica>');
            /* buscar proximo */
            vr_index_critica := vr_tab_dados_critica.next(vr_index_critica);
      end loop;
      pc_write_xml('</criticas>');
          
      pc_write_xml ('</dados></root>',true);
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
    

end TELA_ANALISE_CREDITO;
/
