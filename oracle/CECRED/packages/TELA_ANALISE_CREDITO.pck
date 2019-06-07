create or replace package cecred.TELA_ANALISE_CREDITO is

/* Tabelas para armazenar os retornos dos bir�s, titulos e detalhes*/

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
        ,CASE WHEN tdb.insittit = 2 AND tdb.dtdpagto > gene0005.fn_valida_dia_util(tdb.cdcooper, tdb.dtvencto) THEN 
                  'Pago ap�s vencimento'
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
                          p_idCampo in NUMBER DEFAULT 0) return varchar2;
                          
function fn_le_json_motor_auto_aprov(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in number) return clob;

                          
function fn_getNivelRisco(p_nivelRisco in number) return varchar2;

FUNCTION fn_avalista_cooperado(pr_nrdconta in number) return Varchar2;

PROCEDURE pc_consulta_consultas(pr_cdcooper IN crapass.cdcooper%TYPE  --> Cooperativa
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
                                  pr_cdcritic OUT PLS_INTEGER, --> C�digo da cr�tica
                                  pr_dscritic OUT VARCHAR2     --> Descri��o da cr�tica
                                 );

PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                         ,pr_tpproduto IN number                      --> Produto
                                         ,pr_nrcontrato IN crawepr.nrctremp%TYPE      --> N�mero contrato emprestimo
                                         ,pr_xmllog    IN VARCHAR2           --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                         ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                         ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);

PROCEDURE pc_job_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                      ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                      ,pr_tpproduto IN number                      --> Produto
                                      ,pr_nrctremp  IN crawepr.nrctremp%TYPE       --> N�mero contrato emprestimo
                                      ,pr_dscritic OUT VARCHAR2);                  --> Descricao da critica

PROCEDURE pc_gera_dados_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number);

PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number                      --> N�mero contrato
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

  PROCEDURE pc_consulta_garantia_operacao (pr_cdcooper crapass.cdcooper%TYPE
                                          ,pr_nrdconta crapass.nrdconta%TYPE
                                          ,pr_nrctremp crawepr.nrctremp%TYPE
                                          ,pr_tpproduto in number
                                          ,pr_chamador in varchar2 default 'O' -- Opera��es busca nas crap e P= Propostas nas W
                                          ,pr_retorno  OUT number
                                          ,pr_retxml   IN OUT NOCOPY xmltype);                              

  PROCEDURE pc_consulta_scr(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                           ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                           ,pr_nrctrato IN NUMBER                        --> Numero do contrato
                           ,pr_persona  IN Varchar2
                           ,pr_nrcpfcgc IN crapass.nrcpfcgc%type       --> CPFCGC
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

/*Propostas para Cart�o de Cr�dito*/
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


  -- Subrotina para escrever texto na vari�vel CLOB do XML
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

/*Para buscar as cr�ticas do border�*/                               
PROCEDURE pc_listar_titulos_resumo(pr_cdcooper           in crapcop.cdcooper%type   --> Cooperativa conectada
                                  ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                  ,pr_chave              in VARCHAR2                --> Lista de 'nosso numero' a ser pesquisado
                                  ,pr_qtregist           out integer                --> Qtde total de registros
                                  ,pr_tab_dados_titulos  out  typ_tab_dados_titulos --> Tabela de retorno
                                  ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                  ,pr_dscritic           out varchar2               --> Descricao da critica
                                  );
                                 
/*Para buscar as cr�ticas do border�*/
PROCEDURE pc_listar_titulos_resumo_web (pr_cdcooper           in crapcop.cdcooper%TYPE
                                       ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                       ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
                                       --------> OUT <--------
                                       ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                       ,pr_dscritic OUT VARCHAR2              --> Descri��o da cr�tica
                                       ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                                      );


PROCEDURE pc_consulta_bordero_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                
                                ,pr_dsxmlret IN OUT CLOB);

end TELA_ANALISE_CREDITO;
/
create or replace package body cecred.TELA_ANALISE_CREDITO is

  ------- --------------------------------------------------------------------
  --
  --  Programa : TELA_ANALISE_CREDITO
  --  Sistema  : Aimaro/Ibratan
  --  Autor    : Equipe Mouts
  --  Data     : Mar�o/2019                 Ultima atualizacao: 06/06/2019
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar consultas para analise de credito
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
    
  /*
  C�digo do segmento de produto de cr�dito
  0 � CDC Diversos,
  1 � CDC Ve�culos,
  2 � Empr�stimos /Financiamentos,
  3 � Desconto Cheques � Limite,
  4 � Desconto Cheques - Border�,
  5 � Desconto T�tulo � Limite,
  6 � Desconto de T�tulos � Border�,
  7 � Cart�o de Cr�dito,
  8 � Limite de Cr�dito (Conta),
  9 � Consignado,
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

  --vr_xml xmltype; -- XML que sera enviado
  vr_des_xml         clob; --para os titulos do bordero
  vr_texto_completo  varchar2(32600);

  vr_xml CLOB; -- XML que sera enviado
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
  vr_idorigem number := 1;

  vr_nmdcampo          VARCHAR2(250);
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
          fn_tag('Valor da Opera��o',to_char(e.vlemprst,'999g999g990d00')) valor_emprestimo,
          fn_tag('Valor das Parcelas',to_char(e.vlpreemp,'999g999g990d00')) valor_prestacoes,
          fn_tag('Quantidade de Parcelas',e.qtpreemp) qtd_parcelas,
          fn_tag('Linha de Cr�dito',e.cdlcremp||' - '||lcr.dslcremp) linha,
          fn_tag('Finalidade',e.cdfinemp||' - '||fin.dsfinemp) finalidade,
          fn_tag('CET',e.percetop || '%') cet,
    --     garantia
    --     total Opera��es de Cr�dito
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
    --     total Opera��es de Cr�dito
           e.vlemprst,
           e.cdcooper,
           e.nrdconta,
           e.nrctremp,
           decode(e.insitapr,0,'N�o Analisado',1,'Aprovado',2,'N�o aprovado',3,'Restri��o',4,'Refazer',5,'Derivar',6,'Erro') decisao,
           decode(e.insitest,0,'N�o Enviada',1,'Enviada An�lise Autom�tica',2,'Enviada An�lise Manual',3,'An�lise Finalizada',4,'Expirado') situacao,
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
           e.nrliquid),'-') contratos, -- Inclu�do nrliquid que corresponde ao contratos de CC liquidados
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
        ,fn_tag('PA',age.cdagenci||'-'||age.nmresage) pa -- N�mero do PA e nome do PA         
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
         fn_tag('Situa��o da Conta',CADA0004.fn_dssitdct(pr_cdsitdct => a.cdsitdct)) situacao_conta,
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
           --,fn_tag('Tipo de Conta','Jur�dica') tipoconta
           ,fn_tag('Tipo de Conta',CADA0004.fn_dstipcta (pr_inpessoa => a.inpessoa, pr_cdtipcta => a.cdtipcta)) tipoconta
           ,fn_tag('Situa��o da Conta',CADA0004.fn_dssitdct(pr_cdsitdct => a.cdsitdct)) situacao_conta
           ,fn_tag('PA',age.cdagenci||'-'||age.nmresage) pa -- N�mero do PA e nome do PA
           ,fn_tag('Raz�o Social',a.nmprimtl) rsocial -- Raz�o Social
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

   /* 1.2 Cursor Patrim�nios Resid�ncia PJ */
   cursor c_patrimonio_pj_reside (pr_nrdconta crapass.nrdconta%type
                                 ,pr_cdcooper crapass.cdcooper%type
                                 ,pr_dtmvtolt crapdat.dtmvtolt%type) is
    select vlalugue
          ,fn_tag('Tipo de Im�vel',tipoimovel) tipoimovel
          ,fn_tag('Tempo de Resid�ncia',temporeside) temporeside
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
    select fn_tag('Faturamento M�dio Bruto M�s',to_char(round(((
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
           ,fn_tag('Concentra��o de Faturamento em �nico Cliente',jfn.perfatcl||' %') perfatcl --Concentracao Fat Unico Cliente
    from crapjfn jfn    where jfn.cdcooper = pr_cdcooper --Viacredi
    and   jfn.nrdconta = pr_nrdconta;
    r_dados_comerciais_fat c_dados_comerciais_fat%rowtype;

    /*Dados Comerciais*/
    CURSOR c_dados_comerciaisI(pr_nrcpf in number) IS
      SELECT fn_tag('Natureza da Ocupa��o',p.cdnatureza_ocupacao||' - '||o.dsnatocp) natureza_ocupacao,
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
      SELECT fn_tag('Tipo de Contrato de Trabalho',decode(r.tpcontrato_trabalho,1,'Permanente',2,'Tempor�rio/Terceiro',3,'Sem V�nculo',4,'Autonomo')) tipo_contrato_trab,
             fn_tag('Tempo de Empresa',decode(r.dtadmissao, null, '-', trunc((months_between(rw_crapdat.dtmvtolt, r.dtadmissao))/12)||' anos e '||
             trunc(mod(months_between(trunc(rw_crapdat.dtmvtolt), r.dtadmissao), 12))||' meses ')) tempoempresa,
             fn_tag('Sal�rio',to_char(r.vlrenda,'999g999g990d00')) vlrenda,
             fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(e.nrcpfcgc,case when e.nrcpfcgc > 11 then 2 else 1 end)) nrcpfcgc,
             fn_tag('Nome da Empresa',emp.nmpessoa) empresa
        FROM tbcadast_pessoa_renda r,
             tbcadast_pessoa e,
             tbcadast_pessoa emp
       WHERE r.idpessoa = pr_idpessoa
         AND r.idpessoa_fonte_renda = emp.idpessoa (+) --bug 20860, 21563
         AND r.idpessoa = e.idpessoa; --bug 20645
    r_dados_comerciaisII c_dados_comerciaisII%ROWTYPE;

    CURSOR c_gncdocp (pr_cddocupa IN gncdocp.cdocupa%type) IS
    SELECT fn_tag('Ocupa��o',gncdocp.cdocupa||' - '||gncdocp.rsdocupa) rsdocupa
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

   /*Endere�o residencial pessoa f�sica*/ --bug 19588
   cursor c_endereco_residencial(pr_idpessoa in number) is
   select fn_tag('Aluguel (Despesa)',decode(t.tpimovel,3,to_char(t.vldeclarado,'999g999g990d00'),0)) aluguel,
          fn_tag('Tipo de Im�vel',este0002.fn_des_incasprp(t.tpimovel)) tipoImovel,
          --fn_tag('Tempo de Resid�ncia',t.dtinicio_residencia)||' - '||
          fn_tag('Tempo de Resid�ncia',trunc((months_between(rw_crapdat.dtmvtolt,t.dtinicio_residencia))/12)||' anos e '||
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
     and s.persocio > 0; -- Somente com participa��o societaria      
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

    /*Para constru��o das tabelas*/
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
    vr_tab_tabela_secundaria typ_tab_tabela; --Tabela adicional de cr�ticas para o border� de desconto de t�tulos

/*Registro para armazenar os risco*/
  TYPE typ_rec_dados_risco
    IS RECORD ( nrdconta      crapass.nrdconta%TYPE,
                nrcpfcgc      crapass.nrcpfcgc%TYPE,
                nrctrato      crapepr.nrctremp%TYPE,
                riscoincl     VARCHAR2(1),
                riscogrpo     VARCHAR2(1),
                rating        VARCHAR2(1),
                riscoatraso   VARCHAR2(1),
                riscorefin    VARCHAR2(1),
                riscoagrav    VARCHAR2(1),
                riscomelhor   VARCHAR2(1),
                riscooperac   VARCHAR2(1),
                riscocpf      VARCHAR2(1),
                riscofinal    VARCHAR2(1),
                qtdiaatraso   NUMBER,
                nrgreconomi   NUMBER,
                tpregistro    VARCHAR2(100));

  TYPE typ_tab_dados_riscos IS TABLE OF typ_rec_dados_risco INDEX BY PLS_INTEGER;      
    

    --Variaveis para Garantia da aplica��o
    vr_permingr         NUMBER := 0;
    vr_vlgarnec         VARCHAR2(100):=0;
    vr_inaplpro         VARCHAR2(100):=0;
    vr_vlaplpro         VARCHAR2(100):=0;
    vr_inpoupro         VARCHAR2(100):=0;
    vr_vlpoupro         VARCHAR2(100):=0;
    vr_inresaut         VARCHAR2(100):=0;
    vr_nrctater         VARCHAR2(100):=0;
    vr_inaplter         VARCHAR2(100):=0;
    vr_inpouter         VARCHAR2(100):=0;    

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

  /*Primeira coluna � o t�tulo*/
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
  /*Para colunas onde o default � Zero, e n�o precisa ser apresentado como Zero*/
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
Descri��o: Abrir, ler e retornar valor de uma tag em especifico dentro do retorno do motor
*/
function fn_le_json_motor(p_cdcooper in number,
                          p_nrdconta in number,
                          p_nrdcontrato in number,
                          p_tagFind in varchar2,
                          p_hasDoisPontos in boolean,
                          p_idCampo in NUMBER DEFAULT 0
                          ) return varchar2 is 
                         
    -- Verificar se PA utilza o CRM
    CURSOR cr_motor (prc_cdcooper IN crapage.cdcooper%TYPE,
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

   vr_obj      cecred.json := json(); -- Objeto de leitura JSON
   vr_obj_analise cecred.json := json(); -- Analise (tag) JSON
   vr_obj_mensagensDeAnalise cecred.json := json();
   vr_objFor cecred.json := json();
   
   vr_obj_lst  json_list := json_list(); -- Lista para loop
   vr_length number;
   
   vr_split GENE0002.typ_split;
  BEGIN
  vr_retorno := '-';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
  CLOSE cr_motor;
    
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
        IF p_idCampo >= 0 THEN
               vr_split := GENE0002.fn_quebra_string(vr_retorno,':');
               if vr_split.count > 0 then
                  vr_retorno := vr_split(2);
               end if;
         ELSE
           vr_retorno := TRIM(SUBSTR(vr_retorno, INSTR(vr_retorno,':',-1)+1));
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
  
/*Aceita express�o regular para buscar os dados*/
function fn_le_json_motor_regex(p_cdcooper in number,
                                p_nrdconta in number,
                                p_nrdcontrato in number,
                                p_tagFind in varchar2,
                                p_hasDoisPontos in boolean,
                                p_idCampo in NUMBER DEFAULT 0
                                ) return varchar2 is 
                         
    CURSOR cr_motor (prc_cdcooper IN crapage.cdcooper%TYPE,
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

   vr_obj      cecred.json := json(); -- Objeto de leitura JSON
   vr_obj_analise cecred.json := json(); -- Analise (tag) JSON
   vr_obj_mensagensDeAnalise cecred.json := json();
   vr_objFor cecred.json := json();
   
   vr_obj_lst  json_list := json_list(); -- Lista para loop
   vr_length number;
   
   vr_split GENE0002.typ_split;
  BEGIN
  vr_retorno := '-';
  
  open cr_motor(p_cdcooper,p_nrdconta,p_nrdcontrato);
  fetch cr_motor into rw_motor;
  CLOSE cr_motor;
    
  vr_json := convert(to_char(rw_motor.dsconteudo_requisicao), 'us7ascii', 'utf8');--'WE8ISO8859P1');
  
  --Atribuir json ao objeto:
  vr_obj := json(vr_json);
  
  --Atrivuir analises index ao objeto
  vr_obj_analise := json(vr_obj.get('analises').to_char());
  
  -- Atribuir valores json da tag mensagensDeAnalise ao lista de objetos
  vr_obj_lst := json_list(vr_obj_analise.get('mensagensDeAnalise').to_char());
   FOR vr_idx IN 1..vr_obj_lst.count() LOOP
       --Ler index
         vr_objFor := json( vr_obj_lst.get(vr_idx));

         vr_texto := vr_objFor.get('texto').to_char();
         
         if REGEXP_INSTR(LOWER(vr_texto),LOWER(p_tagFind)) > 0 then
            vr_retorno := vr_texto;
            
            if INSTR(vr_retorno,'"') > 0  then
               vr_retorno := SUBSTR(vr_retorno, 0, LENGTH(vr_retorno) - 1);
               vr_retorno := SUBSTR(vr_retorno, 2, LENGTH(vr_retorno));
            end if;
            
            if p_hasDoisPontos = true then
        IF p_idCampo >= 0 THEN
               vr_split := GENE0002.fn_quebra_string(vr_retorno,':');
               if vr_split.count > 0 then
                  vr_retorno := vr_split(2);
               end if;
         ELSE
           vr_retorno := TRIM(SUBSTR(vr_retorno, INSTR(vr_retorno,':',-1)+1));
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

/*Para os casos onde houve aprova��o autom�tica mas o limite sugerido foi alterado*/
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
  
  FUNCTION fn_garantia_proposta(pr_cdcooper crapass.cdcooper%TYPE
                               ,pr_nrdconta crapass.nrdconta%TYPE
                               ,pr_nrctremp crawepr.nrctremp%TYPE
                               ,pr_nrdcontaavt1 crawepr.nrctaav1%TYPE
                               ,pr_nrdcontaavt2 crawepr.nrctaav2%TYPE
                               ,pr_chamador in varchar2
                               ,pr_tpproduto in number) return varchar is
                               
  cursor c_alienacao is
    select case
           when dscatbem in ('CASA','GALPAO','APARTAMENTO','TERRENO') then 'Im�vel'
           when dscatbem in ('AUTOMOVEL','CAMINHAO','MOTO','OUTROS VEICULOS') then 'Ve�culos' 
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
                               
  vr_retxml xmltype;
  vr_retorno_xml varchar2(250);
  --
  vr_garantia    varchar2(250);
  vr_terceiro    varchar2(250);
  vr_alienacao   varchar2(250);
  vr_avalista    varchar2(250);
  
  vr_retorno number(1);
  vr_tpcontrato number(1);
                                 
  BEGIN

    pc_consulta_garantia_operacao(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_tpproduto => pr_tpproduto
                                 ,pr_chamador => pr_chamador
                                 ,pr_retorno  => vr_retorno
                                 ,pr_retxml   => vr_retxml);
                             
      if vr_retorno = 0 then
        vr_garantia := 'Sem Garantia';
      elsif vr_retorno = 2 then --Produto n�o possui contrato ativo 
         return '-'; 
      elsif vr_retorno = 1 then
        
    /* Extrai dados do XML */
      vr_permingr := vr_retxml.extract('//Dados/permingr/node()').getstringval();--Garantia Sugerida %
      vr_vlgarnec := vr_retxml.extract('//Dados/vlgarnec/node()').getstringval();--Garantia Sugerida Valor
      vr_inaplpro := vr_retxml.extract('//Dados/inaplpro/node()').getstringval();--Flag Aplica��o
      vr_inpoupro := vr_retxml.extract('//Dados/inpoupro/node()').getstringval();--Flag Poupan�a Programada
      vr_inresaut := vr_retxml.extract('//Dados/inresaut/node()').getstringval();--Resgate Automatico
      vr_inaplter := vr_retxml.extract('//Dados/inaplter/node()').getstringval();
      vr_inpouter := vr_retxml.extract('//Dados/inpouter/node()').getstringval();
        /*Verifica��o*/
        if vr_inaplpro = 1 then
          vr_garantia := 'Aplica��o Pr�pria';
        elsif vr_inpoupro = 1 then
          vr_garantia := 'Poupan�a Programada';
        elsif vr_inresaut = 1 then
          vr_garantia := 'Resgate Autom�tica';
        elsif vr_inaplter = 1 then
          vr_garantia := 'Aplica��o Terceiro';
        elsif vr_inpouter = 1 then
          vr_garantia := 'Poupan�a Terceiro';
        end if;        
      end if;                              

      --
      IF pr_nrdcontaavt1 > 0 and pr_nrdcontaavt2 = 0 THEN
       vr_avalista := 'Avalista ' || fn_avalista_cooperado(pr_nrdcontaavt1);
      ELSIF pr_nrdcontaavt1 = 0 and pr_nrdcontaavt2 > 0 THEN
       vr_avalista := 'Avalista ' || fn_avalista_cooperado(pr_nrdcontaavt2);
      ELSIF pr_nrdcontaavt1 > 0 and pr_nrdcontaavt2 > 0 THEN 
       vr_avalista := 'Primeiro Avalista ' ||fn_avalista_cooperado(pr_nrdcontaavt1) ||' e Segundo Avalista '||fn_avalista_cooperado(pr_nrdcontaavt2); 
      END IF;
      
      -- Verifica Avalistas N�o cooperados
      IF pr_nrdcontaavt1 = 0 or pr_nrdcontaavt2 = 0 THEN
        --
        open c_avalista_terceiro;--(vr_tpcontrato);
         fetch c_avalista_terceiro into r_avalista_terceiro;
          if c_avalista_terceiro%found then
            vr_terceiro := 'Avalista n�o cooperado';
          end if;
        close c_avalista_terceiro;
      END IF;
      
      -- Aliena��es
      open c_alienacao;
       fetch c_alienacao into vr_alienacao;
      close c_alienacao;   

      if vr_alienacao is not null then
        vr_retorno_xml := vr_alienacao;
      end if;             
      --
      if vr_avalista is not null then
        if vr_retorno_xml is null then
          vr_retorno_xml := vr_avalista;
        else  
          vr_retorno_xml := vr_retorno_xml||' - '||vr_avalista;
        end if;
      end if;   
      --
      if vr_terceiro is not null then
        if vr_retorno_xml is null then
          vr_retorno_xml := vr_terceiro;
        else
          vr_retorno_xml := vr_retorno_xml||' - '||vr_terceiro;
        end if;  
      end if;        
      --
      if nvl(vr_garantia,'NULO') != 'Sem Garantia' then
        if vr_retorno_xml is null then
          vr_retorno_xml := vr_garantia;
        else
          vr_retorno_xml := vr_retorno_xml||' - '||vr_garantia;
        end if;  
      elsif vr_garantia = 'Sem Garantia' and vr_terceiro is null and vr_alienacao is null and vr_avalista is null then 
        vr_retorno_xml := vr_garantia;
      end if;
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
        <cdcooper>'||pr_cdcooper||'</cdcooper>
        <cdagenci>0</cdagenci>
        <nrdcaixa>0</nrdcaixa>
        <idorigem>5</idorigem>
        <cdoperad>1</cdoperad>
      </params>
    </Root>';    

      return vr_retorno;
      
  END;

  FUNCTION fn_avalista_cooperado(pr_nrdconta in number) return Varchar2 is
  begin
    
  
    if pr_nrdconta > 0 then
      return gene0002.fn_mask_conta(pr_nrdconta);
    else
      return 'N�o Cooperado';
    end if;  
   
  end;

-- Busca a sequencia da consulta do biro para a Tela �nica
 /*Utilizada apenas para retornar informa��es para a categoria SCR (QTD_INST, QTD_FINANC, etc...) */
PROCEDURE pc_busca_consulta_biro(pr_cdcooper IN  crapass.cdcooper%TYPE, --> Codigo da cooperativa de emprestimo
                                 pr_nrdconta IN  crapass.nrdconta%TYPE, --> Numero da conta de emprestimo
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
         AND crapcbd.cdbircon <> 4 --N�o considerar BOA VISTA (BV apenas para SCORE)
         AND crapmbr.nrordimp <> 0 -- Descosiderar Bacen
         AND crapcbd.inreterr = 0  -- Nao houve erros
         AND crapcbc.nrconbir = crapcbd.nrconbir
         AND crapcbc.inprodut <> 7
       ORDER BY crapcbd.dtconbir DESC, crapcbd.qtopescr; -- Buscar a consulta mais recente
  
  BEGIN
    -- Inclus�o nome do m�dulo logado - 12/07/2018 - Chamado 663304
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

PROCEDURE pc_consulta_analise_creditoweb(pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                        ,pr_tpproduto IN number                      --> Produto
                                        ,pr_nrcontrato IN crawepr.nrctremp%TYPE      --> N�mero contrato emprestimo
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
    Data    : Mar�o/2019                 Ultima atualizacao:

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
                                , pr_dsxmlret => pr_retxml);     --> Descri��o da cr�tica*/

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
                                       ,pr_nrctrato  IN number) IS                  --> N�mero Contrato

  /* .............................................................................

    Programa: pc_gera_dados_analise_credito
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Mar�o/2019                 Ultima atualizacao: 02/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar as informa��es para consulta em analise de credito

    Alteracoes:
  ..............................................................................*/


    CURSOR c_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type)  IS
     SELECT c.idpessoa_relacao
       FROM tbcadast_pessoa_relacao c
      WHERE c.idpessoa = pr_idpessoa
        and c.tprelacao = 1; -- 1 = C�njuge
    r_conjuge c_conjuge%rowtype;

    CURSOR c_avalistas_epr is
    SELECT e.nrctaav1,
           e.nrctaav2
      FROM crawepr e
     WHERE e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctrato;
       r_avalistas_epr c_avalistas_epr%rowtype;

    CURSOR c_avalistas_limit_dec_tit is       
    SELECT w.nrctaav1,
           w.nrctaav2
     FROM  crawlim w
     WHERE w.cdcooper = pr_cdcooper
     AND   w.nrdconta = pr_nrdconta
     AND   w.nrctrlim = pr_nrctrato;       
    --
    r_avalistas_limit_dec_tit c_avalistas_limit_dec_tit%rowtype; 
     

  /*Grupo Economico*/
  CURSOR c_grupo_economico(pr_cdcooper in tbcc_grupo_economico.cdcooper%type,
                           pr_nrdconta in tbcc_grupo_economico.nrdconta%type) is
    
  select g.cdcooper,
         g.nrdconta
    from tbcc_grupo_economico_integ g
   where g.dtexclusao is null
     and g.idgrupo in (select gei.idgrupo
                         from tbcc_grupo_economico gei --alterado GE rubens--19-05-2019
                        where gei.nrdconta = pr_nrdconta
                          and gei.cdcooper = pr_cdcooper);
                          
  r_grupo_economico c_grupo_economico%rowtype;

  /*Vers�o*/
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
      vr_string_contas := vr_string_contas||fn_tag_table('Cooperativa;N�mero da Conta;PA;Abertura',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_string_contas := vr_string_contas||fn_tag_table('Cooperativa;N�mero da Conta;PA;Abertura',vr_tab_tabela);
    end if;

     vr_string_contas := vr_string_contas||'</linhas>
                                            </valor>
                                            </campo>';

    if vr_outras_contas = true then
     vr_string_contas := vr_string_contas||'<campo>'||
                                            '<nome>Opera��es de outras contas</nome>'||
                                            '<tipo>info</tipo>'||
                                            '<valor>Proponente possui outras contas, suas opera��es est�o listadas em Opera��es.</valor>'||
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

        /*PROPOSTA CARTAO DE CR�DITO*/
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

      /*Opera��es para todas as personas*/
      
      vr_string_persona := vr_string_persona||'<categoria>'||
                                              '<tituloTela>Opera��es</tituloTela>'||
                                              '<tituloFiltro>operacoes</tituloFiltro>'||
                                              '<subcategorias>';
      
      vr_xml_aux := null;
      /*Opera��es proponente*/
      pc_consulta_operacoes(pr_cdcooper  => pr_cdcooper
                          , pr_nrdconta  => pr_nrdconta
                          , pr_dtmvtolt  => rw_crapdat.dtmvtolt
                          , pr_nrctrato  => vr_nrctrato_principal
                          , pr_cdcritic  => vr_cdcritic
                          , pr_dscritic  => vr_dscritic
                          , pr_dsxmlret  => vr_xml_aux);

      vr_string_persona := vr_string_persona||vr_xml_aux;
      --vr_string_persona := vr_string_persona||'</subcategorias></categoria>';


      /*Opera��es Outras Contas*/
      for r_contas in c_contas(pr_cdcooper,pr_nrcpfcgc) loop
        if pr_nrdconta != r_contas.nrdconta then
        /*
        separa��o por contas
        */
/*        vr_string_persona := vr_string_persona||'<subcategoria>
                                                  <separador>
                                                      <tituloTela>Opera��es da conta '||r_contas.nrdconta||'</tituloTela>
                                                  </separador>
                                                 </subcategoria>';
                                                 */
        vr_string_persona := concat(vr_string_persona,'<subcategoria>
                                                        <separador>
                                                            <tituloTela>Opera��es da conta '||r_contas.nrdconta||'</tituloTela>
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
      -- SUBCATEGORIA Resumo das Informa��es do Titular

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
    -- Se n�o encontrar
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

    -- Consultar informa��es proponente
    if c_pessoa%isopen then
       close c_pessoa;
    end if;
    open c_pessoa(pr_cdcooper,pr_nrdconta);
     fetch c_pessoa into r_pessoa;
      if c_pessoa%notfound then
        close c_pessoa;
        vr_dscritic := 'N�o encontrado os dados do proponente :'||pr_nrdconta;
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

              pc_gera_dados_persona(pr_persona => 'C�njuge',
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

      /*INFORMA��O AVALISTA*/
      if pr_tpproduto = c_emprestimo then
        open c_avalistas_epr;
         fetch c_avalistas_epr into r_avalistas_epr;
          if c_avalistas_epr%found then
             /*Avalista 1*/
             if r_avalistas_epr.nrctaav1 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_epr.nrctaav1);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
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
                  if c_pessoa%found then
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
      elsif pr_tpproduto = c_limite_desc_titulo then
        open c_avalistas_limit_dec_tit;
         fetch c_avalistas_limit_dec_tit into r_avalistas_limit_dec_tit;
          if c_avalistas_limit_dec_tit%found then
             /*Avalista 1*/
             if r_avalistas_limit_dec_tit.nrctaav1 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_limit_dec_tit.nrctaav1);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if r_avalistas_limit_dec_tit.nrctaav1 > 0 and r_avalistas_limit_dec_tit.nrctaav2 > 0 then
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
             if r_avalistas_limit_dec_tit.nrctaav2 > 0 then
                open c_pessoa(pr_cdcooper,r_avalistas_limit_dec_tit.nrctaav2);
                 fetch c_pessoa into r_pessoa;
                  if c_pessoa%found then
                    if r_avalistas_limit_dec_tit.nrctaav1 > 0 and r_avalistas_limit_dec_tit.nrctaav2 > 0 then
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
         close c_avalistas_limit_dec_tit;
        
      end if;
      /*FIM-INFORMA��O AVALISTA*/

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
                     

      /*Gravar informa��es */
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
                                        ,pr_nrctremp  IN crawepr.nrctremp%TYPE       --> N�mero contrato emprestimo
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
  -- Bloco PLSQL para chamar a execu��o paralela do pc_crps414
  vr_dsplsql VARCHAR2(4000);
  -- Job name dos processos criados
  vr_jobname VARCHAR2(100);

  vr_dscritic crapcri.dscritic%TYPE;

  BEGIN
    -- Montar o prefixo do c�digo do programa para o jobname
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
          -- Acionar rotina para deriva��o automatica em  paralelo
      vr_dsplsql := 'BEGIN'||chr(13)
                     || '  TELA_ANALISE_CREDITO.pc_gera_dados_analise_credito(pr_cdcooper => '||pr_cdcooper ||chr(13)
                     || '                                                    ,pr_nrdconta => '||pr_nrdconta ||chr(13)
                     || '                                                    ,pr_tpproduto => '||pr_tpproduto||chr(13)
                     || '                                                    ,pr_nrctrato => '||pr_nrctremp||chr(13)
                     || '                                                    );'||chr(13)
                     || 'END;';
      -- Faz a chamada ao programa paralelo atraves de JOB
      gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper  --> C�digo da cooperativa
                            ,pr_cdprogra  => 'TELA_ANALISE_CREDITO' --> C�digo do programa
                            ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                            ,pr_dthrexe   => SYSDATE  + 1/1440 --> Executar ap�s 1 minuto
                            ,pr_interva   => null         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                            ,pr_jobname   => vr_jobname   --> Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);
      -- Testar saida com erro
      IF vr_dscritic IS NOT NULL THEN
        -- Adicionar ao LOG e continuar o processo
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3,
                                   pr_ind_tipo_log => 2,
                                   pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss')
                                                   || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para an�lise de cr�dito. '
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
                                                 || ' - TELA_ANALISE_CREDITO --> Erro ao gerar dados para an�lise de cr�dito. '
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

      -- Incrementa o m�s
      vr_dtinicio := ADD_MONTHS(vr_dtinicio, 1);

    END LOOP;

    vr_string := fn_tag('M�dia de Cr�ditos Recebidos no Trimestre',TO_CHAR(ROUND(vr_vltrimestre/3,2),'999g999g990d00'))||
                 fn_tag('M�dia de Cr�ditos Recebidos no Semestre',TO_CHAR(ROUND(vr_vlsemestre/6,2),'999g999g990d00'));

    pr_XmlOut := vr_string;

  END pc_lista_cred_recebidos;


  PROCEDURE pc_consulta_analise_credito(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
                                       ,pr_nrdconta  IN crawepr.nrdconta%TYPE       --> Conta
                                       ,pr_tpproduto IN number                      --> Produto
                                       ,pr_nrctrato  IN number                      --> N�mero contrato
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Codigo da critica
                                       ,pr_dscritic OUT VARCHAR2           --> Descricao da critica
                                       ,pr_dsxmlret IN OUT NOCOPY xmltype) IS  --> Arquivo de retorno do XML

    /* .............................................................................

    Programa:  pc_consulta_analise_credito
    Sistema : Aimaro/Ibratan
    Autor   : Paulo Martins
    Data    : Mar�o/2019                 Ultima atualizacao:

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
      pr_dscritic := 'Dados para esta proposta n�o foram encontrados!';
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
                   '<dscritic>Dados cadastrais n�o encontrado!</dscritic>'||
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
                          '<tituloTela>Patrim�nio</tituloTela>'||
                          '<campos>';
  /*Aluguel (Despesa):
  Tipo de Im�vel:
  Tempo de Resid�ncia:
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
  Livre de �nus:
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
    vr_string := vr_string||fn_tag_table('Descri��o do Bem;Livre de �nus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  else
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    vr_string := vr_string||fn_tag_table('Descri��o do Bem;Livre de �nus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
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
  Livre de �nus:
  resposta em %
  Qtd. Parcela:
  Valor:*/
      /*Apresentado em tabela*/
      vr_string := vr_string||'<campo>
                               <nome>Bens C�njuge Co-Respons�vel</nome>
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
        vr_string := vr_string||fn_tag_table('Bens;Livre de �nus;Quantidade de Parcela;Valor',vr_tab_tabela);
      else
        vr_tab_tabela(1).coluna1 := '-';
        vr_tab_tabela(1).coluna2 := '-';
        vr_tab_tabela(1).coluna3 := '-';
        vr_tab_tabela(1).coluna4 := '-';
        --vr_tab_tabela(1).coluna5 := '-';
        vr_string := vr_string||fn_tag_table('Bens;Livre de �nus;Quantidade de Parcela;Valor',vr_tab_tabela);
      end if;

       vr_string := vr_string||'</linhas>
                                </valor>
                                </campo>';

       vr_string := vr_string||'</campos></subcategoria>';
   end if;
  close c_cjg_coresponsavel;

--Comerciais
  /*Natureza da Ocupa��o:                             Ocupa��o:
  Tipo de Contrato de Trabalho:
  Empresa:
  Cargo:
  Tempo de Empresa: Formato m�s/ano
  Sal�rio:
  Total de Outros Rendimentos:                                 Origem:
  Recebe benef�cio ou sal�rio na cooperativa? Resposta Sim ou N�o Extrato da Conta Corrente
  Mostrar as rendas autom�ticas para consulta (novo)
  Mostrar a m�dia de cr�ditos recebidos no semestre e trimestre para consulta (novo)
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

   --Rendimentos autom�ticos
   vr_string := vr_string||'<campo>
                            <nome>Rendas Autom�ticas</nome>
                            <tipo>table</tipo>
                            <valor>
                            <linhas>';

   pc_busca_rendas_aut(pr_cdcooper,pr_nrdconta,vr_string_aux);

   vr_string := vr_string||vr_string_aux||'</linhas>
                                </valor>
                                </campo>';
   /*Movimenta��o trimestre e semestre*/
   vr_string_aux := NULL;
   pc_lista_cred_recebidos(pr_cdcooper,pr_nrdconta,vr_string_aux);
   vr_string := vr_string||vr_string_aux;

   vr_string := vr_string||'<campo>
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
    Data    : Mar�o/2019                 Ultima atualizacao: 23/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consultar as informa��es do cadastro PJ

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
                                 '<valor>Dados Cadastrais - n�o encontrados</valor>'||
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
                          '<tituloTela>Patrim�nio</tituloTela>';

  open c_patrimonio_pj_reside (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
   fetch c_patrimonio_pj_reside into r_patrimonio_pj;
    if c_patrimonio_pj_reside%notfound then
      --N�o encontrou, n�o gera cr�tica mas cria TAG campos para apresentar a pr�xima tabela
      vr_string := vr_string||'<campos>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string||'<campos>';
      
      if (upper(r_patrimonio_pj.tpimovel) = 'ALUGADO') then
        vr_string := vr_string||fn_tag('Aluguel (Despesa)',to_char(r_patrimonio_pj.vlalugue,'999g999g990d00'));
      else
        vr_string := vr_string||fn_tag('Aluguel (Despesa)',0);
      end if;
      
      vr_string := vr_string || r_patrimonio_pj.tipoimovel||
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
    vr_string := vr_string||fn_tag_table('Descri��o do Bem;Livre de �nus;Quantidade de Parcela;Valor da Parcela;Valor do Bem',vr_tab_tabela);
  else
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_string := vr_string||fn_tag_table('Bens;Livre de �nus;Quantidade de Parcela;Valor',vr_tab_tabela);
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
                                 '<valor>Dados Comerciais Faturamento - n�o encontrado</valor>'||
                                '</campo>';
    else
      /*Gera Tags Xml*/
      vr_string := vr_string||'<campos>'||
                   r_dados_comerciais_fat.vlrmedfatbru||
                   r_dados_comerciais_fat.perfatcl;
    end if;

    /*Movimenta��o trimestre e semestre*/
    vr_string_aux := NULL;
    pc_lista_cred_recebidos(pr_cdcooper,pr_nrdconta,vr_string_aux);
    vr_string := vr_string||vr_string_aux;

   vr_string := vr_string||'<campo>
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
    Data    : Mar�o/2019                 Ultima atualizacao: 09/05/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para consultar as garantias do proponente PF ou PJ

    Alteracoes: 30/05/2019 - Ajuste na mascara e correcao do texto do label.
                             Bug 22092 - PRJ438 - Gabriel Marcos (Mouts).
                             
                31/05/2019 - Ordem de apresentacao de informacoes da Aba Garantia.
                             Story 21804 - PRJ438 - Gabriel Marcos (Mouts).
                             
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
  vr_nrdconta             crapass.nrdconta%TYPE;
  --vr_saldocotas_conjuge   crapcot.vldcotas%TYPE;
  vr_vldcotas             VARCHAR2(100);
  --Saldo M�dio
  vr_saldo_mes        NUMBER;
  vr_saldo_trimestre  NUMBER;
  vr_saldo_semestre   NUMBER;
  --Aplica��es
  vr_vldaplica        NUMBER;
  vr_index            NUMBER:=1;
  vr_index_aval       NUMBER:=1;

  vr_isinterv         boolean:=FALSE; --controle quando deve chamar tabela interveniente
  vr_inpessoaI        number:=1; --Tipo de pessoa do interveniente

  vr_mostra_veiculos   boolean := false;
  vr_mostra_maqui_equi boolean := false;
  vr_mostra_imoveis    boolean := false;
  vr_retorno_xml       number(1);
  vr_tpctrato_garantia number;
  vr_null              VARCHAR2(200);
  
    vr_nrctremp        NUMBER;
    vr_contas_chq      VARCHAR2(1000) := ' '; --para contas avalisadas de cheque
    vr_nmprimtl        VARCHAR2(1000);
    vr_vldivida        VARCHAR2(1000);
    vr_tpdcontr        VARCHAR2(1000);
    vr_qtmesdec        NUMBER;
    vr_qtpreemp        NUMBER;
    vr_qtprecal        NUMBER;
    vr_qtregist        NUMBER;
    vr_axnrcont        VARCHAR2(1000);
    vr_axnrcpfc        VARCHAR2(1000);
  

  --tabela para os avalistas
  vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
    vr_clob_ret        CLOB;
    vr_clob_msg        CLOB;
    vr_xmltype         xmlType;
    vr_parser          xmlparser.Parser;
    vr_doc             xmldom.DOMDocument;
  
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

  /* 4.1 Garantia Pessoal Pessoa F�sica - com base em b1wgen0075.busca-dados*/
  cursor c_garantia_pessoal_pf (pr_nrdconta crapass.nrdconta%type
                               ,pr_cdcooper crapass.cdcooper%type)is
  select fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta --N�mero da conta
        ,fn_tag('Tipo de Pessoa','F�sica') tipopessoa
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
        ,fn_tag('N�mero',d.nrendere) nr -- Nr. endere�o
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
  and   a.inpessoa = 1 --Pessoa F�sica
  and   d.tpendass = 10; --Residencial
  r_garantia_pessoal_pf c_garantia_pessoal_pf%ROWTYPE;

  /* Garantia Pessoal Juridica */
  CURSOR c_garantia_juridica (pr_nrdconta crapass.nrdconta%type
                             ,pr_cdcooper crapass.cdcooper%type)is
    SELECT fn_tag('Conta',gene0002.fn_mask_conta(a.nrdconta)) conta
          ,fn_tag('Tipo de Pessoa','Juridica') tipopessoa
          ,fn_tag('CNPJ',gene0002.fn_mask_cpf_cnpj(a.nrcpfcgc,2)) cnpj
          ,fn_tag('Raz�o Social',a.nmprimtl) nome
          ,fn_tag('Data de Abertura da Empresa',to_char(j.dtiniatv,'DD/MM/YYYY')) abertura
          ,fn_tag('Faturamento M�dio Mensal',(select to_char(round(((jfn.vlrftbru##1 +
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
                            decode(jfn.vlrftbru##12,0,0,1)),2),'999g999g990d00')
                  from crapjfn jfn
                  where jfn.cdcooper = pr_cdcooper
                  and   jfn.nrdconta = pr_nrdconta)) fatmedmensal --Soma tudo e divide pelos meses que tem lan�amento
            ,fn_tag('CEP',gene0002.fn_mask_cep(d.nrcepend)) cep
            ,fn_tag('Rua',d.dsendere) rua
            ,fn_tag('Complemento',d.complend) complemento
            ,fn_tag('N�mero',d.nrendere) numero
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
    and   a.inpessoa = 2 --Pessoa Jur�dica
    and   d.tpendass = 9;
    r_garantia_juridica c_garantia_juridica%ROWTYPE;

  /* Verifica se tem C�njuge*/
  CURSOR c_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type)  IS
   SELECT c.idpessoa_relacao
     FROM tbcadast_pessoa_relacao c
    WHERE c.idpessoa = pr_idpessoa
      and c.tprelacao = 1; -- 1 = C�njuge

  /* Busca CPF do C�njuge para verificar se � cooperado*/
  CURSOR c_buscacpf_conjuge(pr_idpessoa in tbcadast_pessoa.idpessoa%type) IS
    SELECT c.nrcpfcgc
      FROM tbcadast_pessoa c
    WHERE c.idpessoa = pr_idpessoa
    AND   c.nrcpfcgc <> 0;

  /* C�njuge n�o cooperado*/
  CURSOR c_consultaconjuge_naocoop(pr_cdcooper crapcop.cdcooper%TYPE
                                  ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta C�njuge',0) conta
         ,fn_tag('CPF C�njuge',gene0002.fn_mask_cpf_cnpj(nvl(nrcpfcjg,0),1)) cpf
         ,fn_tag('Nome C�njuge',nmconjug) nome
         ,fn_tag('Rendimento Mensal C�njuge', nvl(vlsalari,0)) rendimento
         ,fn_tag('Endividamento C�njuge',0) endiv
   FROM crapcje
   WHERE cdcooper = pr_cdcooper
     AND nrdconta = pr_nrdconta
     AND idseqttl = 1;
  r_consultaconjuge_naocoop c_consultaconjuge_naocoop%ROWTYPE;

  /* C�njuge cooperado*/
  CURSOR c_consultaconjuge_coop (pr_cdcooper crapcop.cdcooper%TYPE
                                ,pr_nrdconta crapass.nrdconta%type) IS
   SELECT fn_tag('Conta C�njuge',gene0002.fn_mask_conta(j.nrctacje)) conta
         ,fn_tag('CPF C�njuge',gene0002.fn_mask_cpf_cnpj(t.nrcpfcgc,1)) cpf
         ,fn_tag('Nome C�njuge',t.nmextttl) nome
         ,fn_tag('Rendimentos C�njuge',to_char((t.vlsalari + t.vldrendi##1),'999g999g990d00')) rendimentos
         ,fn_tag('Endividamento C�njuge',to_char((SELECT Nvl(Sum(vlvencto),0)
                                   FROM crapvop v
                                   WHERE nrcpfcgc = t.nrcpfcgc
                                     AND dtrefere = (SELECT Max(dtrefere)
                                                     FROM crapvop
                                                     --WHERE nrcpfcgc = v.nrcpfcgc
                                                     )),'999g999g990d00')) endiv
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
    SELECT fn_tag('Capital C�njuge',to_char(nvl(vldcotas,0),'999g999g990d00'))
     FROM crapcot
    WHERE cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;

  /* Task 16201 - Consulta Aliena��o Fiduci�ria (Ve�culo, Moto, Outros Ve�culos, Caminh�o)*/
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

  /* 16369 - Consultar Aliena��o Fiduciaria (M�quina e Equipamento) */
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

  /* Task 16370 - Consultar Aliena��o Fiduciaria (Imoveis) */
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
SELECT gene0002.fn_mask_conta(Decode(a.nrdconta,NULL,0,a.nrdconta)) conta
          ,CASE WHEN LENGTH(v.nrcpfcgc) > 11 then 'JUR�DICA' else 'F�SICA' END inpessoa
          ,CASE WHEN LENGTH(v.nrcpfcgc) > 11 then 2 else 1 END inpessoaInterv
          ,gene0002.fn_mask_cpf_cnpj(v.nrcpfcgc, (CASE WHEN 
                                                    LENGTH(v.nrcpfcgc) > 11 then 2 else 1
                                                 END)
                                                 ) cpf
          ,v.nmdavali nome
          ,(SELECT dsnacion FROM crapnac WHERE cdnacion = v.cdnacion) nacionalidade
          ,a.dtnasctl datanasc
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

  cursor c_dados_aval_nao_coop(pr_nrcpfcgc in crapavt.nrcpfcgc%type,
                               pr_tpctrato in crapavt.tpctrato%type)  is
  select decode(anc.inpessoa,1,'F�sica',2,'Jur�dica','-') inpessoa,
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
     and anc.tpctrato = pr_tpctrato; -- Avalista n�o cooperado  
  --
  r_dados_aval_nao_coop c_dados_aval_nao_coop%rowtype;     

  FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode)RETURN VARCHAR2 IS
  BEGIN
    RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
  END fn_getValue;

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

  /* Loop do periodo do mes, do dia 1 ate a data do movimento anterior. N�o considerar s�bados domingos e feriados
     Somat�rio dos valores dividido pelo n�mero de dias uteis */
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
    END;

    /* Busca saldo semestre */
    BEGIN
      SELECT Round((vlsmstre##1 + vlsmstre##2 + vlsmstre##3 + vlsmstre##4 + vlsmstre##5 + vlsmstre##6) /6 ,2)
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

  /*Identifica qual produto est� rodando para identificar os avalistas*/
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
  DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
                               ,pr_cdagenci => 0  --> C�digo da agencia
                               ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                               ,pr_cdoperad => 1  --> C�digo do Operador
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
                               ,pr_cdcritic          => vr_cdcritic          --> C�digo da cr�tica
                               ,pr_dscritic          => vr_dscritic);        --> Descri��o da cr�tica
                               
                                 
  
  /*Se tiver avalistas*/
  IF vr_tab_dados_avais.count > 0 THEN
    
  /* Separa a garantia pessoal pois n�o � obrigat�ria */
  vr_string_garantia_pessoal := vr_string_garantia_pessoal || '<subcategoria>'||
                                                              '<tituloTela>Garantia Pessoal</tituloTela><campos>';    
  LOOP
    
    vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
    '<campo><nome>AVALISTA '||vr_index_aval||'</nome><tipo>info</tipo><valor>'||
    fn_avalista_cooperado(vr_tab_dados_avais(vr_index_aval).nrctaava)||'</valor></campo>';
  
    /* 4.1 Garantia Avalista Pessoa F�sica */
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
                       r_garantia_pessoal_pf.estado; --Este block n�o fecha com </campos> pois ainda faltam os dados do CJG

        /*Salva o ID da pessoa para verificar estado civil no proximo passo*/
        vr_idpessoa := r_garantia_pessoal_pf.idpessoa;
      elsif vr_tab_dados_avais(vr_index_aval).nrctaava = 0 then -- Neste caso Avalista n�o � cooperado
        Open c_dados_aval_nao_coop(vr_tab_dados_avais(vr_index_aval).nrcpfcgc,vr_tpctrato_garantia);
         fetch c_dados_aval_nao_coop into r_dados_aval_nao_coop;
          if c_dados_aval_nao_coop%found then
             vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                                           fn_tag('Tipo de Pessoa',r_dados_aval_nao_coop.inpessoa)||
                                           fn_tag('CPF',r_dados_aval_nao_coop.nrcpfcgc)||
                                           fn_tag('Nome',r_dados_aval_nao_coop.nmdavali)||
                                           fn_tag('Nacionalidade',r_dados_aval_nao_coop.dsnatura)||
                                           fn_tag('Data de Nascimento',r_dados_aval_nao_coop.dtnascto)||
                                           fn_tag('Renda',to_char(r_dados_aval_nao_coop.vlrenmes,'999g999g990d00'))||
                                           fn_tag('CEP',r_dados_aval_nao_coop.nrcepend)||
                                           fn_tag('Rua',r_dados_aval_nao_coop.dsendres##1)||
                                           fn_tag('Complemento',r_dados_aval_nao_coop.complend)||
                                           fn_tag('N�mero',r_dados_aval_nao_coop.nrendere)||
                                           fn_tag('Cidade',r_dados_aval_nao_coop.nmcidade)||
                                           fn_tag('Bairro',r_dados_aval_nao_coop.dsendres##2)|| -- Bairro
                                           fn_tag('Estado',r_dados_aval_nao_coop.cdufresd);
          end if;
        close c_dados_aval_nao_coop;
      end if;
    close c_garantia_pessoal_pf;

    /* Fim Garantia Pessoal*/

    /* Se tiver C�njuge busca idPessoaConjuge */
    open c_conjuge(vr_idpessoa);
     fetch c_conjuge into vr_idpessoa_conjuge;
      if c_conjuge%found then

        vr_string_garantia_pessoal := vr_string_garantia_pessoal ||
        '<campo><nome>C�njuge</nome><tipo>info</tipo><valor></valor></campo>';

        /* Possui c�njuge, busca CPF*/
        open c_buscacpf_conjuge (vr_idpessoa_conjuge);
         fetch c_buscacpf_conjuge into vr_cpfconjuge;
          if c_buscacpf_conjuge%found then

            /* Verifica se � cooperado atrav�s do CPF - consulta crapass*/
            open c_verifica_conjuge_coop(vr_cpfconjuge);
             fetch c_verifica_conjuge_coop into r_verifica_conjuge_coop;
              if c_verifica_conjuge_coop%notfound then

                /* C�njuge n�o � cooperado*/
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
                /* C�njuge � cooperado*/
                OPEN c_consultaconjuge_coop (pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
                FETCH c_consultaconjuge_coop INTO r_consultaconjuge_coop;
                  IF c_consultaconjuge_coop%FOUND THEN
                  /* Dados do C�njuge cooperado*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                               r_consultaconjuge_coop.conta||
                               r_consultaconjuge_coop.cpf||
                               r_consultaconjuge_coop.nome||
                               r_consultaconjuge_coop.rendimentos||
                               r_consultaconjuge_coop.endiv;

                  --Salva conta do C�njuge para buscar capital
                  vr_nrdcontacjg := r_consultaconjuge_coop.nrdcontacjg;

                END IF;

                /* Busca Cotas Capital*/
                OPEN c_consulta_valor_capital(pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_nrdcontacjg);
                 FETCH c_consulta_valor_capital into vr_vldcotas;
                  IF c_consulta_valor_capital%NOTFOUND THEN
                      vr_string_garantia_pessoal := vr_string_garantia_pessoal || fn_tag('Capital C�njuge','-');
                  ELSE
                    vr_string_garantia_pessoal := vr_string_garantia_pessoal||vr_vldcotas;
                  END IF;
                close c_consulta_valor_capital;

                /* Consulta Saldos M�dios (Mensal, Trimestral e Semestral) */
                pc_consulta_saldo_medio(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => vr_nrdcontacjg
                                       ,pr_saldo_mes => vr_saldo_mes
                                       ,pr_saldo_trimestre => vr_saldo_trimestre
                                       ,pr_saldo_semestre => vr_saldo_semestre);
                /*Cria XML Mes Atual*/
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo M�dio Mes atual C�njuge',to_char(vr_saldo_mes,'999g999g990d00'));
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal||fn_tag('Saldo M�dio Trimestral C�njuge',to_char(vr_saldo_trimestre,'999g999g990d00'));
                  vr_string_garantia_pessoal := vr_string_garantia_pessoal
                                             ||fn_tag('Saldo M�dio Semestral C�njuge',
                                                             case when vr_saldo_semestre > 0 then to_char(vr_saldo_semestre,'999g999g990d00') else '-' end);

                /* Carrega o valor das aplica��es PF e PJ */
                pc_busca_dados_atenda(pr_cdcooper => vr_cdcooper_principal,
                                      pr_nrdconta => vr_nrdcontacjg);
                

                /*Aplica��es*/                      
                vr_string_garantia_pessoal:=vr_string_garantia_pessoal||fn_tag('Aplicacoes C�njuge',to_char(vr_tab_valores_conta(1).vlsldapl,'999g999g990d00'));
                
                /*Poupan�a programada*/
                 vr_string_garantia_pessoal:=vr_string_garantia_pessoal||fn_tag('Poupan�a Programada',to_char(vr_tab_valores_conta(1).vlsldppr,'999g999g990d00'));

                /* Co-responsabilidade */
                vr_string_garantia_pessoal := vr_string_garantia_pessoal||'<campo>
                                         <nome>Co-responsabilidade</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
                vr_index := 0;
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

    -- Buscar informa��es do XML retornado
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
        -- Sair se o nodo n�o for elemento
        IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;
        --
        -- Tratar leitura dos dados do SEGCAB (Header)
        IF vr_node_name = 'aval' THEN
          -- Buscar todos os filhos deste n�
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
            -- Sair se o nodo n�o for elemento
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
                 vr_index := vr_index+1;
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
      -- FIM - Buscar informa��es do XML retornado
      --

      FOR R1 IN 1..vr_index LOOP
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
            /* Busca s� o nome pois n�o encontrou pelo CPF */
            OPEN c_consultaconjuge_naocoop (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => vr_tab_dados_avais(vr_index_aval).nrctaava);
            FETCH c_consultaconjuge_naocoop INTO r_consultaconjuge_naocoop;
              IF c_consultaconjuge_naocoop%FOUND THEN
              /* Gera Tags Xml Dados do C�njuge n�o cooperado */
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
      end if; /* End if --> verifica se tem C�njuge*/
    close c_conjuge;

  else
    /* 4.1a Garantia Pessoa Pessoa Jur�dica */
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
             vr_string_garantia_pessoal := vr_string_garantia_pessoal||
                                           fn_tag('Tipo de Pessoa',r_dados_aval_nao_coop.inpessoa)||
                                           fn_tag('CPF',r_dados_aval_nao_coop.nrcpfcgc)||
                                           fn_tag('Nome',r_dados_aval_nao_coop.nmdavali)||
                                           --fn_tag('Nacionalidade',r_dados_aval_nao_coop.dsnatura)||
                                           fn_tag('Data de Nascimento',r_dados_aval_nao_coop.dtnascto)||
                                           fn_tag('Faturamento',to_char(r_dados_aval_nao_coop.vlrenmes,'999g999g990d00'))||
                                           fn_tag('CEP',r_dados_aval_nao_coop.nrcepend)||
                                           fn_tag('Rua',r_dados_aval_nao_coop.dsendres##1)||
                                           fn_tag('Complemento',r_dados_aval_nao_coop.complend)||
                                           fn_tag('N�mero',r_dados_aval_nao_coop.nrendere)||
                                           fn_tag('Cidade',r_dados_aval_nao_coop.nmcidade)||
                                           fn_tag('Bairro',r_dados_aval_nao_coop.dsendres##2)|| -- Bairro
                                           fn_tag('Estado',r_dados_aval_nao_coop.cdufresd);
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
  vr_string_garantia_pessoal := vr_string_garantia_pessoal||'</campos></subcategoria>';
  end if;

  /* 4.2 - Aplica��es - Task 16173 */

  pc_consulta_garantia_operacao(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrctremp => pr_nrctrato
                               ,pr_tpproduto => pr_tpproduto
                               ,pr_chamador => 'P'
                               ,pr_retorno   => vr_retorno_xml
                               ,pr_retxml   => pr_retxml);
                                 
  /* Extrai dados do XML */
  if vr_retorno_xml = 1 then
  BEGIN
    vr_permingr := pr_retxml.extract('//Dados/permingr/node()').getstringval();--Garantia Sugerida %
    vr_vlgarnec := pr_retxml.extract('//Dados/vlgarnec/node()').getstringval();--Garantia Sugerida Valor
    --
    vr_inaplpro := pr_retxml.extract('//Dados/inaplpro/node()').getstringval();--Flag Aplica��o
    vr_vlaplpro := pr_retxml.extract('//Dados/vlaplpro/node()').getstringval();--Saldo Aplica��o
    vr_inpoupro := pr_retxml.extract('//Dados/inpoupro/node()').getstringval();--Flag Poupan�a Programada
    vr_vlpoupro := pr_retxml.extract('//Dados/vlpoupro/node()').getstringval();--Saldo Poupan�a Programada
    vr_inresaut := pr_retxml.extract('//Dados/inresaut/node()').getstringval();--Resgate Automatico

    vr_nrctater := pr_retxml.extract('//Dados/nrctater/node()').getstringval();
    vr_inaplter := pr_retxml.extract('//Dados/inaplter/node()').getstringval();
    vr_inpouter := pr_retxml.extract('//Dados/inpouter/node()').getstringval();
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao consultar Garantia da proposta.';
  END;
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 or vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then
  vr_string := vr_string||'<subcategoria>'||
                          '<tituloTela>Garantia Aplica��o</tituloTela>'||
                          '<campos>';
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 then
  vr_string := vr_string ||'<campo>
                             <tipo>h3</tipo>
                             <valor>Opera��o</valor>
                            </campo>';
  
  
  vr_string := vr_string || fn_tag('Garantia Sugerida',
                            case when vr_permingr > 0 then vr_permingr || '%' else '-' end);
  vr_string := vr_string || fn_tag('Garantia Sugerida Valor', 
                            case when vr_vlgarnec not like '0%' then vr_vlgarnec else '-' end);
  end if;                          
  if vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then                      
    vr_string := vr_string ||'<campo>
                               <tipo>h3</tipo>
                               <valor>Aplica��o Pr�pria</valor>
                              </campo>';     
  end if;                                                   
  --
  if vr_inaplpro = 1 then
    vr_string := vr_string || fn_tag('Aplica��o', case when vr_inaplpro = 0 Then '-' Else 'Sim' end);
    vr_string := vr_string || fn_tag('Saldo Dispon�vel Aplica��o', 
                              case when vr_vlaplpro not like '0%' then vr_vlaplpro else '-' end);
  end if;              

  if vr_inpoupro = 1 then              
    vr_string := vr_string || fn_tag('Poupan�a Programada',case when vr_inpoupro =0 Then '-' Else 'Sim' end);
    vr_string := vr_string || fn_tag('Saldo Dispon�vel Poupan�a',
                              case when vr_vlpoupro not like '0%' then vr_vlpoupro else '-' end);
  end if;
  
  if vr_inaplpro = 1 or  vr_inpoupro = 1 then    
    vr_string := vr_string || fn_tag('Resgate Autom�tico',case when vr_inresaut =0 Then 'N�o' Else 'Sim' end);                              
  end if;
                            
  --
  if vr_inaplter = 1 then  
  vr_string := vr_string ||'<campo>
                             <tipo>h3</tipo>
                             <valor>Aplica��o de Terceiro</valor>
                            </campo>';    
  
  --Terceiro
  vr_string := vr_string || fn_tag('Conta Terceiro',gene0002.fn_mask_conta(vr_nrctater));

  vr_string := vr_string || fn_tag('Aplica��o',case when vr_inaplter =0 Then '-' Else 'Sim' end);
  end if;
  if vr_inpouter = 1 then
  vr_string := vr_string || fn_tag('Poupan�a Programada',case when vr_inpouter =0 Then '-' Else 'Sim' end);
  end if;
  if vr_permingr > 0 or vr_vlgarnec > 0 or vr_inaplpro = 1 or  vr_inpoupro= 1 or vr_inresaut = 1 then
  --Fim
  vr_string := vr_String || '</campos></subcategoria>';
  end if;

  /*Bug 19842 - Regra para apresentar garantia pessoal apenas quando necess�rio*/
  if (length(vr_string_garantia_pessoal) > 0) then
    vr_string := vr_string_cabec || vr_string  || vr_string_garantia_pessoal;
  else
    vr_string := vr_string_cabec || vr_string;
  end if;

  /* Fim do 4.2 - Aplica��es*/
  /* 4.3 GARANTIA REAL */
  
  
  /*Validar se deve mostrar ou n�o as tabelas de aliena��o*/
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

    vr_string := vr_string||'<subcategoria>
                            <tituloTela>Alienac�o Fiduci�ria</tituloTela>
                            <campos>';

  /* 4.3.1 - Aliena��o Fiduciaria - Im�veis */
   if vr_mostra_imoveis = true then
   vr_string := vr_string||'<campo>
                            <nome>Im�veis (Casa, Apartamento, Terreno, Galp�o)</nome>
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
    vr_string := vr_string||fn_tag_table('Classifica��o;Categoria;Valor de Mercado;Valor de Venda;Descri��o;�rea �til;�rea Total;Matr�cula;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado',vr_tab_tabela);
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

    vr_string := vr_string||fn_tag_table('Classifica��o;Categoria;Valor de Mercado;Valor de Venda;Descri��o;�rea �til;�rea Total;Matr�cula;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';
  end if;
  /* FIM 4.3.1 - Aliena��o Fiduciaria - Im�veis */
  
  /* 4.3.2 - Aliena��o Fiduci�ria - Veiculos */

   /*Intervenientes apresentados em tabela*/
   if vr_mostra_veiculos = true then
   vr_string := vr_string||'<campo>
                            <nome>Ve�culo</nome>
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
    vr_string := vr_string||fn_tag_table('Tipo Veiculo;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;N�mero Placa;Renavam;Chassi;Tipo de Chassi;Ano de F�brica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
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
    vr_string := vr_string||fn_tag_table('Tipo Veiculo;Marca;Modelo;Valor de Mercado;Valor Fipe;UF Placa;N�mero Placa;Renavam;Chassi;Tipo de Chassi;Ano de F�brica;Ano do Modelo;Cor;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';
   end if;

   /* FIM 4.3.2 - Aliena��o Fiduci�ria - Veiculos */


   /* 4.3.3 - Aliena��o Fiduci�ria - Maquina e Equipamento */
   
   if vr_mostra_maqui_equi = true then
   /*TABELA*/
   vr_string := vr_string||'<campo>
                            <nome>M�quina e Equipamento</nome>
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
     vr_tab_tabela(vr_index).coluna8 := to_char(r_alienacoes.valormercado,'999g999g990d00');
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
    vr_string := vr_string||fn_tag_table('Categoria;Descri��o;Marca;Modelo;Nota Fiscal;N�mero de S�rie;Ano de Fabrica��o;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
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
    vr_string := vr_string||fn_tag_table('Categoria;Descri��o;Marca;Modelo;Nota Fiscal;N�mero de S�rie;Ano de Fabrica��o;Valor de Mercado;CPF/CNPJ Interveniente',vr_tab_tabela);
  end if;

   vr_string := vr_string||'</linhas>
                            </valor>
                            </campo>';
  end if;

  /* FIM 4.3.3 - Aliena��o Fiduci�ria - Maquina e Equipamento */

  vr_string := vr_string||'</campos></subcategoria>';

  end if; -- FIM MOSTRAR ALIENA��O

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
     
     vr_string := vr_string||'<subcategoria>
                              <tituloTela>Proposta n�o possui Garantias</tituloTela>
                              <campos>
                               <campo>
                                <nome>N�o possui</nome>
                                <tipo>string</tipo>
                                <valor>Dados</valor>
                               </campo>
                              </campos></subcategoria>';       
    
   end if;

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
       vr_tab_tabela(vr_index).coluna6 := CASE WHEN r_interveniente.datanasc IS NOT NULL
                                          THEN to_char(r_interveniente.datanasc,'DD/MM/YYYY')  ELSE '-' END;
       --Endere�o
       vr_tab_tabela(vr_index).coluna7 := r_interveniente.cep;
       vr_tab_tabela(vr_index).coluna8 := r_interveniente.rua;
       vr_tab_tabela(vr_index).coluna9 := r_interveniente.complemento;
       vr_tab_tabela(vr_index).coluna10 := r_interveniente.nr;
       vr_tab_tabela(vr_index).coluna11 := r_interveniente.cidade;
       vr_tab_tabela(vr_index).coluna12 := r_interveniente.bairro;
       vr_tab_tabela(vr_index).coluna13 := r_interveniente.estado;
       --Dados do C�njuge do Interveniente
       vr_tab_tabela_secundaria(vr_index).coluna1 := r_interveniente.cpfcong;
       vr_tab_tabela_secundaria(vr_index).coluna2 := r_interveniente.nomecong;
       vr_tab_tabela_secundaria(vr_index).coluna3 := gene0002.fn_mask_conta(r_interveniente.nrdcontacjg);
       
     else
       /*Interveniente PJ*/
       vr_tab_tabela(vr_index).coluna1 := r_interveniente.conta;
       vr_tab_tabela(vr_index).coluna2 := r_interveniente.inpessoa;
       vr_tab_tabela(vr_index).coluna3 := r_interveniente.cpf;
       vr_tab_tabela(vr_index).coluna4 := r_interveniente.nome;
       vr_tab_tabela(vr_index).coluna5 := '-'; --PJ n�o tem nacionalidade
       vr_tab_tabela(vr_index).coluna6 := CASE WHEN r_interveniente.datanasc IS NOT NULL
                                          THEN to_char(r_interveniente.datanasc,'DD/MM/YYYY')  ELSE '-' END;
       vr_tab_tabela(vr_index).coluna7 := r_interveniente.cep;
       vr_tab_tabela(vr_index).coluna8 := r_interveniente.rua;
       vr_tab_tabela(vr_index).coluna9 := r_interveniente.complemento;
       vr_tab_tabela(vr_index).coluna10 := r_interveniente.nr;
       vr_tab_tabela(vr_index).coluna11 := r_interveniente.cidade;
       vr_tab_tabela(vr_index).coluna12 := r_interveniente.bairro;
       vr_tab_tabela(vr_index).coluna13 := r_interveniente.estado;
     end if;
     vr_index := vr_index+1;

  end loop;

  if vr_tab_tabela.COUNT > 0 then
    /*Interveniente PF*/
    if (vr_inpessoaI = 1) then
       vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF / CNPJ;Nome;Nacionalidade;Data de: Abertura da Empresa / Nascimento;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado',vr_tab_tabela);
       vr_string_cong := vr_string_cong || fn_tag_table('CPF do C�njuge;Nome do C�njuge;Conta do C�njuge',vr_tab_tabela_secundaria);
    /*Interveniente PJ*/
    else
       vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF / CNPJ;Nome;Nacionalidade;Data de: Abertura da Empresa / Nascimento;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado',vr_tab_tabela);
    end if;
  
  else
    /*Tabela Vazia Pessoa Fisica*/
    if (r_pessoa.inpessoa = 1) then
      vr_tab_tabela(1).coluna1 := '-'; vr_tab_tabela(1).coluna2 := '-'; vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-'; vr_tab_tabela(1).coluna5 := '-'; vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-'; vr_tab_tabela(1).coluna8 := '-'; vr_tab_tabela(1).coluna9 := '-';
      vr_tab_tabela(1).coluna10 := '-'; vr_tab_tabela(1).coluna11 := '-'; vr_tab_tabela(1).coluna12 := '-';
      vr_tab_tabela(1).coluna13 := '-';
      vr_tab_tabela(1).coluna14 := '-'; vr_tab_tabela(1).coluna15 := '-'; vr_tab_tabela(1).coluna16 := '-';
      vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF;Nome;Nacionalidade;Data de Nascimento;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado;Cpf do C�njuge;Nome do C�njuge;Conta do C�njuge',vr_tab_tabela);
    else /*Tabela vazia Pessoa Juridica*/
      vr_tab_tabela(1).coluna1 := '-'; vr_tab_tabela(1).coluna2 := '-'; vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-'; vr_tab_tabela(1).coluna5 := '-'; vr_tab_tabela(1).coluna6 := '-';
      vr_tab_tabela(1).coluna7 := '-'; vr_tab_tabela(1).coluna8 := '-'; vr_tab_tabela(1).coluna9 := '-';
      vr_tab_tabela(1).coluna10 := '-'; vr_tab_tabela(1).coluna11 := '-'; vr_tab_tabela(1).coluna12 := '-';
      vr_string := vr_string||fn_tag_table('Conta;Tipo;CPF;Raz�o Social;Data de Abertuda da Empresa;CEP;Rua;Complemento;N�mero;Cidade;Bairro;Estado',vr_tab_tabela);
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

  /* Procedure para carregar dados da garantia da opera��o */
  PROCEDURE pc_consulta_garantia_operacao (pr_cdcooper crapass.cdcooper%TYPE
                                          ,pr_nrdconta crapass.nrdconta%TYPE
                                          ,pr_nrctremp crawepr.nrctremp%TYPE
                                          ,pr_tpproduto in number
                                          ,pr_chamador in varchar2 default 'O' -- Opera��es busca nas crap e P= Propostas nas W
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
    FROM  crawepr w
    WHERE w.cdcooper = pr_cdcooper
    AND   w.nrdconta = pr_nrdconta
    AND   w.nrctremp = pr_nrctremp;
  r_busca_dados_proposta c_busca_dados_proposta%ROWTYPE;

  /*Busca dados do limite quando n�o for Emprestimo e Financiamento bug 20391*/
  CURSOR c_busca_dados_lim_desctit IS
    SELECT w.cddlinha --linha
          ,w.idcobefe --id efetivacao
          ,w.vllimite
    FROM  crawlim w
    WHERE w.cdcooper = pr_cdcooper
    AND   w.nrdconta = pr_nrdconta
    AND   w.nrctrlim = pr_nrctremp;
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

  /* 4.2 - Task 16173 - Consultar Garantia Opera��es */
  PROCEDURE pc_busca_dados_garantia(pr_cdcooper     IN crapcop.cdcooper%TYPE
                          ,pr_idcobert     IN tbgar_cobertura_operacao.idcobertura%TYPE --> Identificador da cobertura
                          ,pr_nrdconta     IN crapadt.nrdconta%TYPE --> Numero da conta
                          ,pr_tpctrato     IN crapadt.tpctrato%TYPE --> Tipo do contrato
                          ,pr_codlinha     IN INTEGER --> Codigo da linha
                          ,pr_cdfinemp     IN INTEGER --> C�digo da finalidade
                          ,pr_vlropera     IN NUMBER --> Valor da operacao
                          ,pr_dsctrliq     IN VARCHAR2 --> Lista de contratos a liquidar separados por ";"
                          ,pr_retxml       IN OUT NOCOPY xmltype) IS --> Arquivo de retorno do XML
                                   
                                     
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
                             pr_dscritic => vr_dscritic, 
                             pr_retxml   => pr_retxml, 
                             pr_nmdcampo => vr_nmdcampo, 
                             pr_des_erro => vr_dscritic);

  END pc_busca_dados_garantia;

  BEGIN

    /*Se o produto for Emprestimo e Financiamento*/
    if (pr_tpproduto = c_emprestimo) then
  
  /* Busca dados da proposta de emprestimo */
  open c_busca_dados_proposta;
  fetch c_busca_dados_proposta into r_busca_dados_proposta;
       if c_busca_dados_proposta%found then

  pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                 pr_idcobert => r_busca_dados_proposta.idcobefe,
                 pr_nrdconta => pr_nrdconta,
                 pr_tpctrato => 90,
                 pr_codlinha => r_busca_dados_proposta.cdlcremp,
                 pr_cdfinemp => r_busca_dados_proposta.cdfinemp,
                 pr_vlropera => r_busca_dados_proposta.vlemprst,
                 pr_dsctrliq => pr_dsctrliq,
                 pr_retxml   => pr_retxml);
         if r_busca_dados_proposta.idcobefe > 0 then
          pr_retorno := 1;
         else
          pr_retorno := 0;
         end if;
       else  
          pr_retorno := 2; -- N�o existe produto
       end if;
      close c_busca_dados_proposta;
      
    elsif (pr_tpproduto = c_desconto_titulo) then
      open c_busca_dados_lim_desctit;
       fetch c_busca_dados_lim_desctit into r_busca_dados_lim_desctit;

       if c_busca_dados_lim_desctit%found then
        
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                        pr_idcobert => r_busca_dados_lim_desctit.idcobefe,
                        pr_nrdconta => pr_nrdconta,
                        pr_tpctrato => 3, --limite de desconto de t�tulo
                        pr_codlinha => r_busca_dados_lim_desctit.cddlinha,
                        pr_cdfinemp => 0,
                        pr_vlropera => r_busca_dados_lim_desctit.vllimite,
                        pr_dsctrliq => pr_dsctrliq,
                        pr_retxml   => pr_retxml);

         if r_busca_dados_lim_desctit.idcobefe > 0 then
          pr_retorno := 1;
         else
          pr_retorno := 0;
       end if;
       else  
         pr_retorno := 2; -- N�o existe produto
       end if;
      close c_busca_dados_lim_desctit; 
    elsif pr_tpproduto = c_desconto_cheque then
      open c_busca_desconto_cheque;
       fetch c_busca_desconto_cheque into r_busca_desconto_cheque;

       if c_busca_desconto_cheque%found then
        
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_desconto_cheque.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 2, 
                                 pr_codlinha => r_busca_desconto_cheque.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_desconto_cheque.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_retxml   => pr_retxml);

         if r_busca_desconto_cheque.idcobefe > 0 then
          pr_retorno := 1;
    else
      pr_retorno := 0;  
         end if;
       else  
        pr_retorno := 2; -- N�o existe produto
       end if;
       close c_busca_desconto_cheque;       
    elsif pr_tpproduto = c_limite_desc_titulo then
     if pr_chamador = 'O' then
      open c_busca_limite_credito;
       fetch c_busca_limite_credito into r_busca_limite_credito;

       if c_busca_limite_credito%found then
        
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_limite_credito.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 1, 
                                 pr_codlinha => r_busca_limite_credito.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_limite_credito.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_retxml   => pr_retxml);

         if r_busca_limite_credito.idcobefe > 0 then
          pr_retorno := 1;
         else 
          pr_retorno := 0;          
         end if;
       else
         pr_retorno := 2; -- N�o existe produto
       end if;
       close c_busca_limite_credito;       
     elsif pr_chamador = 'P' then
      open c_busca_dados_lim_desctit;
       fetch c_busca_dados_lim_desctit into r_busca_dados_lim_desctit;

       if c_busca_dados_lim_desctit%found then
        
         pc_busca_dados_garantia(pr_cdcooper => pr_cdcooper,
                                 pr_idcobert => r_busca_dados_lim_desctit.idcobefe,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_tpctrato => 1, 
                                 pr_codlinha => r_busca_dados_lim_desctit.cddlinha,
                                 pr_cdfinemp => 0,
                                 pr_vlropera => r_busca_dados_lim_desctit.vllimite,
                                 pr_dsctrliq => pr_dsctrliq,
                                 pr_retxml   => pr_retxml);

         if r_busca_dados_lim_desctit.idcobefe > 0 then
          pr_retorno := 1;
         else 
          pr_retorno := 0;          
    end if;
       else
         pr_retorno := 2; -- N�o existe produto
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
    Data    : Mar�o/2019                 Ultima atualizacao:

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
 
  /*Bug 21583  - Busca apenas pelo n�mero nrconbir, pois s�o dois registros na crapcbd e apenas o 
    primeiro grava como reaproveitamento. */
  CURSOR c_crapcbd(pr_nrconbir crapcbd.nrconbir%type,
                   pr_nrcpfcgc crapcbd.nrcpfcgc%type) is
   SELECT fn_tag('Data da Consulta', to_char(crapcbd.dtconbir,'DD/MM/YYYY')) dataconsulta, --bug 20392
          --fn_tag('Reaproveitamento', decode(NVL(crapcbd.inreapro,0),0,'N�o','Sim')) reaproveitamento,
          fn_tag('Data-base Bacen', to_char(crapcbd.dtreapro,'DD/MM/YYYY')) databasebacen, -- Data base bacen
          fn_tag('Quantidade de Opera��es', NVL(temp.qtopescr,crapcbd.qtopescr)) qtoperacoes, -- Qt. Opera��es
          fn_tag('Quantidade de Institui��es Financeiras', NVL(temp.qtifoper,crapcbd.qtifoper)) qtifs, -- Qt. IFs
          fn_tag('Opera��o do Sistema Financeiro Nacional (Endividamento)', to_char(NVL(temp.vltotsfn,crapcbd.vltotsfn),'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
          fn_tag('Opera��es Vencidas', to_char(NVL(temp.vlopescr,crapcbd.vlopescr),'999g999g990d00')) vencidas, -- Op.Vencidas
          fn_tag('Opera��es de Preju�zo', to_char(NVL(temp.vlprejui,crapcbd.vlprejui),'999g999g990d00')) prejuizo,  -- Op.Preju�zo
          fn_tag('Opera��es Vencidas nos �ltimos 12 meses', to_char(NVL(crapcbd.vlprejme,temp.vlopesme),'999g999g990d00')) vencidas12meses, -- Op.Vencidas ultimos 12 meses
          fn_tag('Opera��es de Preju�zo nos �ltimos 12 meses', to_char(NVL(crapcbd.vlopesme,temp.vlprejme),'999g999g990d00')) prejuizo12meses,  -- Op.Preju�zo ultimos 12 meses
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
    
  /*Leitura do XML de retorno do motor apenas para o proponente e produtos (Empr�stimo e Limite Desconto Titulo*/
  IF ( pr_persona = 'Proponente' AND vr_tpproduto_principal in(c_emprestimo, c_limite_desc_titulo) ) THEN
    
    -- Resumo das Informa��es do Titular             
    vr_string := vr_string || '<subcategoria>'||
                              '<tituloTela>Resumo das Informa��es do Titular</tituloTela>'||
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
    vr_string := vr_string||r_crapcbd.dataconsulta ||
                            --r_crapcbd.reaproveitamento||
                            --r_crapcbd.databasebacen||
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
      vr_string := vr_string||
                   fn_tag('Data da Consulta', '-') ||
                   --fn_tag('Reaproveitamento', '-') ||
                   --fn_tag('Data-base Bacen', '-') ||
                   fn_tag('Quantidade de Opera��es', '-') ||
                   fn_tag('Quantidade de Institui��es Financeiras', '-') ||
                   fn_tag('Opera��o do Sistema Financeiro Nacional (Endividamento)','-') ||
                   fn_tag('Opera��es Vencidas', '-') ||
                   fn_tag('Opera��es de Preju�zo', '-') ||
                   fn_tag('Opera��es Vencidas nos �ltimos 12 meses', '-') ||
                   fn_tag('Opera��es de Preju�zo nos �ltimos 12 meses', '-')||
                   fn_tag('Comprometimento de renda', '-');
    END IF;
    -- PF
    IF(r_pessoa.inpessoa = 1) AND vr_existe THEN
        -- Procurar pelos poss�veis nomes para o campo que existe no JSON
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
    
    vr_string := vr_string||'</campos></subcategoria>';
    -- Fim Resumo das Informa��es do Titular               
    
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
  Data    : Mar�o/2019                 Ultima atualizacao:

  Dados referentes ao programa:

  Frequencia: Sempre que for chamado

  Objetivo  : Consulta SCR

  Alteracoes:
..............................................................................*/

vr_string varchar2(4000);
vr_existe BOOLEAN;

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
         fn_tag('Quantidade de Opera��es', opf.qtopesfn) qtoperacoes, -- Qt. Opera��es
         fn_tag('Quantidade de Institui��es Financeiras', opf.qtifssfn) qtifs, -- Qt. IFs
         fn_tag('Opera��o do Sistema Financeiro Nacional (Endividamento)', to_char(SUM(vop.vlvencto),'999g999g990d00')) endividamento, -- OP. SFN (Endividamento)
         fn_tag('Opera��es Vencidas', SUM(CASE WHEN vop.cdvencto BETWEEN 205 AND 290 THEN vop.vlvencto ELSE 0 END)) vencidas, -- Op.Vencidas
         fn_tag('Opera��es de Preju�zo', SUM(CASE WHEN vop.cdvencto BETWEEN 310 AND 330 THEN vop.vlvencto ELSE 0 END)) prejuizo  -- Op.Preju�zo
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
select fn_tag('Opera��es Vencidas(at� 12 meses)', to_char(sum(vop.vlvencto),'999g999g990d00')) operacoesVencidas 
     from crapvop vop, crapass a
   where vop.cdvencto >= 220 and vop.cdvencto <= 270 -- Vencidos at� 12 meses
     and a.nrcpfcgc = vop.nrcpfcgc
     and vop.dtrefere = (select max(dtrefere) from crapopf)
     and a.nrcpfcgc = pr_nrcpfcgc
     group by a.nrdconta;
r_crapvop c_crapvop%rowtype;     
  
BEGIN

  vr_cdcritic := 0;
  vr_dscritic := null;

  -- SCR
  -- Resumo das Informa��es do Titular             
  vr_string := vr_string || '<subcategoria>'||
                            '<tituloTela>Resumo das Informa��es do Titular</tituloTela>'||
                            '<campos>';  
    
                 
  open c_crapopf;
    fetch c_crapopf into r_crapopf;
      if c_crapopf%notfound then
          vr_string := vr_string || '<campo>'||
                                    '<nome>Informa��o</nome>'||
                                    '<tipo>info</tipo>'||
                                    '<valor>N�o foi encontrado dados do SCR</valor>'||
                                    '</campo>';
      else
        open c_consulta_scr(r_crapopf.nrcpfcgc);
          fetch c_consulta_scr into r_consulta_scr;
            if c_consulta_scr%found then
                
              /*Gera Tags Xml*/
              vr_string := vr_string||
                         --  r_consulta_scr.databasebacen||
                           r_consulta_scr.qtoperacoes||
                           r_consulta_scr.qtifs||
                           r_consulta_scr.endividamento||
                           r_consulta_scr.vencidas||
                           r_consulta_scr.prejuizo;
        ELSE
          vr_string := vr_string||
                      -- fn_tag('--', '-') ||
                       fn_tag('Quantidade de Opera��es', '-') ||
                       fn_tag('Quantidade de Institui��es Financeiras', '-')||
                       fn_tag('Opera��o do Sistema Financeiro Nacional (Endividamento)', '-') ||
                       fn_tag('Opera��es Vencidas', '-' ) ||
                       fn_tag('Opera��es de Preju�zo', '-');
            
            end if;
        close c_consulta_scr;
          
        open c_crapvop(r_crapopf.nrcpfcgc);
          fetch c_crapvop into r_crapvop;
            if c_crapvop%found then
                
              /*Gera Tags Xml*/
              vr_string := vr_string||
                           r_crapvop.operacoesvencidas;
            ELSE
              vr_string := vr_string||
              fn_tag('Opera��es Vencidas(at� 12 meses)', '-');
            end if;
        close c_crapvop;
        
        vr_string := vr_string||'</campos></subcategoria>';
        -- Fim Resumo das Informa��es do Titular   
        
        vr_string := vr_string || '<subcategoria>'||
                                  '<tituloTela>SCR</tituloTela>'||
                                  '<campos>';   
        vr_existe := FALSE;  
        FOR r_modalidades IN c_modalidades(r_crapopf.nrcpfcgc) LOOP
          vr_existe := TRUE;
          vr_tab_tabela.delete;

          vr_string := vr_string||'<campo>
                                   <nome>Modalidade: '  || r_modalidades.cdmodali || ' - ' ||r_modalidades.dsmodali ||'</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';

          -- 31 dias a 60 dias
          r_vencimento_120.vencimento := NULL;
          open c_vencimento_120(r_modalidades.nrcpfcgc,r_modalidades.cdmodali);
           fetch c_vencimento_120 into r_vencimento_120;

             vr_tab_tabela(1).coluna1 := nvl(r_vencimento_120.vencimento, 0);

          close c_vencimento_120;
            
          -- 61 dias a 60 dias
          r_vencimento_130.vencimento := NULL;
          open c_vencimento_130(r_modalidades.nrcpfcgc,r_modalidades.cdmodali);
           fetch c_vencimento_130 into r_vencimento_130;

             vr_tab_tabela(1).coluna2 := nvl(r_vencimento_130.vencimento, 0);

          close c_vencimento_130;

          vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);

          vr_string := vr_string||'</linhas>
                                   </valor>
                                   </campo>';

        END LOOP;
        -- se nao encontrou modalidade
        IF NOT vr_existe THEN
          vr_tab_tabela.delete;

          vr_string := vr_string||'<campo>
                                   <nome>Modalidade</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';
          vr_tab_tabela(1).coluna1 := '-';
          vr_tab_tabela(1).coluna2 := '-';
          vr_string := vr_string||fn_tag_table('31 dias a 60 dias;61 dias a 90 dias',vr_tab_tabela);
          vr_string := vr_string||'</linhas>
                                   </valor>
                                   </campo>';
      end if;
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
   /*Categoria Opera��es*/

   vr_dsxmlret             CLOB;
   vr_string               CLOB;

   PROCEDURE pc_busca_borderos (pr_nrdconta IN crapbdt.nrdconta%TYPE
                               ,pr_cdcooper IN crapbdt.cdcooper%TYPE) IS
    /*---------------------------------------------------------------------------------------------------------------------
      Programa: pc_busca_borderos
      Sistema : Aimaro/Ibratan
      Autor   : Mateus Zimmermann (Mouts)
      Data    : Mar�o/2019

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


      -- Buscar os t�tulos
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

        -- abrindo cursor de t�tulos
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
                                         
                 OPEN cr_crapcco (pr_cdcooper => rw_crapbdt.cdcooper
                                 ,pr_nrcnvcob => rw_craptdb.nrcnvcob);
                  FETCH cr_crapcco INTO rw_crapcco;
                  IF cr_crapcco%FOUND THEN
                      
                      IF rw_crapcco.flgregis = 1 THEN            
                          vr_vl_tot_borderos := vr_vl_tot_borderos + rw_craptdb.vlsldtit;
                          vr_qt_tot_titulos := vr_qt_tot_titulos + 1;
                      END IF;
                  
                  END IF;
                  CLOSE cr_crapcco;                        

             END LOOP;

        END LOOP;
        CLOSE  cr_crapbdt;

        vr_string := vr_string ||
                   '<subcategoria>'||
                   '<tituloTela>Rotativos Ativos - Produto B�rdero de Desconto de T�tulo</tituloTela>'||
                   '<campos>';

        vr_string := vr_string || fn_tag('Quantidade Total de Border�s', vr_qt_tot_borderos)||
                                  fn_tag('Quantidade Total de Boletos', vr_qt_tot_titulos)||
                                  fn_tag('Valor Total de Border�s', to_char(vr_vl_tot_borderos,'999g999g990d00'));

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
      Data    : Mar�o/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que lista as propostas ativas
    ---------------------------------------------------------------------------------------------------------------------*/
      
      -- V�riaveis
      vr_index     NUMBER;  
      aux_qtmesdec NUMBER;
      aux_qtpreemp NUMBER;
      aux_qtprecal NUMBER;
      tot_vlsdeved NUMBER;
      tot_vlpreemp NUMBER;
      tot_qtprecal NUMBER;
      vr_dspontualidade VARCHAR2(30) := 'Sem Atrasos';
      vr_liquidar VARCHAR2(15);
      vr_lista_contratos_liquidados VARCHAR2(100) := '';
      vr_vlsdeved NUMBER;
      vr_risco_inclusao VARCHAR2(5) := '';
      
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
      
      --Indicador de utiliza��o da tabela
      vr_inusatab BOOLEAN;
      vr_nrctaava1_aux number := 0;
      vr_nrctaava2_aux number := 0;
    
      ---------->>> CURSORES <<<----------
      CURSOR cr_crapris (pr_nrctremp IN crapris.nrctremp%TYPE) IS
        SELECT CASE
                 WHEN max(qtdiaatr) = 0   THEN 'Sem Atrasos'
                 WHEN max(qtdiaatr) <= 60 THEN 'At� 60 dias'
                 WHEN max(qtdiaatr) > 60  THEN 'Mais 60 dias ou renegocia��es'
               END dspontualidade
          FROM crapris
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtrefere <= LAST_DAY(rw_crapdat.dtmvtolt)
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
      
      -- Calend�rio da cooperativa selecionada
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
                           ,pr_cdagenci       => 0                      --> C�digo da ag�ncia
                           ,pr_nrdcaixa       => 0                      --> N�mero do caixa
                           ,pr_cdoperad       => 1                      --> C�digo do operador
                           ,pr_nmdatela       => 'TELA_UNICA'               --> Nome datela conectada
                           ,pr_idorigem       => 5                      --> Indicador da origem da chamada
                           ,pr_nrdconta       => pr_nrdconta            --> Conta do associado
                           ,pr_idseqttl       => 1                      --> Sequencia de titularidade da conta
                           ,pr_rw_crapdat     => rw_crapdat             --> Vetor com dados de par�metro (CRAPDAT)
                           ,pr_dtcalcul       => ''                     --> Data solicitada do calculo
                           ,pr_nrctremp       => 0                      --> N�mero contrato empr�stimo
                           ,pr_cdprogra       => 0                      --> Programa conectado
                           ,pr_inusatab       => vr_inusatab            --> Indicador de utiliza��o da tabela
                           ,pr_flgerlog       => 'N'                    --> Gerar log S/N
                           ,pr_flgcondc       => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                           ,pr_nmprimtl       => ''                     --> Nome Primeiro Titular
                           ,pr_tab_parempctl  => vr_dstextab_parempctl  --> Dados tabela parametro
                           ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                           ,pr_nriniseq       => 1                      --> Numero inicial da paginacao
                           ,pr_nrregist       => 9999                   --> Numero de registros por pagina
                           ,pr_qtregist       => vr_qtregist            --> Qtde total de registros
                           ,pr_tab_dados_epr  => vr_tab_dados_epr       --> Saida com os dados do empr�stimo
                           ,pr_des_reto       => vr_des_reto            --> Retorno OK / NOK
                           ,pr_tab_erro       => vr_tab_erro);          --> Tabela com poss�ves erros
                           
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

                  OPEN cr_crapris (pr_nrctremp => vr_tab_dados_epr(i).nrctremp);
                  FETCH cr_crapris INTO rw_crapris;
                  IF cr_crapris%FOUND THEN
                     vr_dspontualidade := rw_crapris.dspontualidade;
                  END IF;
                  CLOSE cr_crapris;
                  
                  -- Resetar a variavel
                  vr_garantia := '-';

                  --> listar avalistas de contratos
                  DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
                                      ,pr_cdagenci => 0  --> C�digo da agencia
                                      ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                                      ,pr_cdoperad => 1  --> C�digo do Operador
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
                                      ,pr_cdcritic          => vr_cdcritic          --> C�digo da cr�tica
                                      ,pr_dscritic          => vr_dscritic);        --> Descri��o da cr�tica
                                      
                  IF vr_tab_dados_avais.exists(1) THEN
                     vr_nrctaava1_aux := vr_tab_dados_avais(1).nrctaava;
                  END IF;
                  
                  IF vr_tab_dados_avais.exists(2) THEN
                     vr_nrctaava2_aux := vr_tab_dados_avais(2).nrctaava;
                  END IF;                                      
                                   
                  vr_garantia := '-';   
                  IF vr_tab_dados_avais.exists(1)  THEN                    
                    vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,vr_tab_dados_epr(i).nrctremp,vr_nrctaava1_aux,vr_nrctaava2_aux,'P',c_emprestimo);   
                  END IF;
                  -- Liquidar  
                  vr_liquidar := INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp));
                  IF INSTR(vr_lista_contratos_liquidados, to_char(vr_tab_dados_epr(i).nrctremp)) > 0 THEN
                      vr_liquidar := 'Sim';
                  ELSE
                      vr_liquidar := 'N�o';
                  END IF;
                         
                  tot_vlsdeved := tot_vlsdeved + vr_tab_dados_epr(i).vlsdeved;
                  tot_vlpreemp := tot_vlpreemp + vr_tab_dados_epr(i).vlpreemp;
                  tot_qtprecal := tot_qtprecal + aux_qtprecal;
                  
                  vr_vlsdeved := vr_tab_dados_epr(i).vlsdeved + vr_tab_dados_epr(i).vliofcpl + vr_tab_dados_epr(i).vlmrapar + vr_tab_dados_epr(i).vlmtapar; 
                 
                  -- Busca calend�rio para a cooperativa selecionada
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
                  vr_tab_tabela(vr_index).coluna2 := vr_risco_inclusao; -- Risco Inclus�o
                  vr_tab_tabela(vr_index).coluna3 := trim(to_char(vr_vlsdeved,'999g999g990d00')); -- Saldo Devedor
                  vr_tab_tabela(vr_index).coluna4 := substr(trim(vr_tab_dados_epr(i).dspreapg), 1, 11); -- Presta��es
                  vr_tab_tabela(vr_index).coluna5 := to_char(vr_tab_dados_epr(i).vlpreemp,'999g999g990d00'); -- Valor Presta��es
                  vr_tab_tabela(vr_index).coluna6 := to_char(aux_qtprecal,'fm990d0000'); -- Atraso/Parcela
                  vr_tab_tabela(vr_index).coluna7 := vr_tab_dados_epr(i).dsfinemp; -- Finalidade
                  vr_tab_tabela(vr_index).coluna8 := vr_tab_dados_epr(i).dslcremp; -- Linha de Cr�dito
                  vr_tab_tabela(vr_index).coluna9 := trim(to_char(vr_tab_dados_epr(i).txmensal,'990D000000')); -- Taxa
                  vr_tab_tabela(vr_index).coluna10 := vr_garantia; -- Garantia
                  vr_tab_tabela(vr_index).coluna11 := vr_liquidar; -- Liquidar
                  vr_tab_tabela(vr_index).coluna12 := CASE WHEN vr_dspontualidade IS NOT NULL THEN vr_dspontualidade ELSE 'Sem Atrasos' END; -- Pontualidade
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
          IF vr_tab_dados_epr.COUNT() > 1 THEN
            
              vr_tab_tabela(vr_index).coluna1 := '&lt;b&gt;TOTAL&lt;/b&gt;';
              vr_tab_tabela(vr_index).coluna2 := '-';
              vr_tab_tabela(vr_index).coluna3 := case when tot_vlsdeved > 0 then 
                                                    to_char(tot_vlsdeved,'999g999g990d00') else '-' end; -- Saldo Devedor
              vr_tab_tabela(vr_index).coluna4 := '-';
              vr_tab_tabela(vr_index).coluna5 := case when tot_vlpreemp > 0 then
                                                    to_char(tot_vlpreemp,'999g999g990d00') else '-' end; -- Valor Presta��es
              vr_tab_tabela(vr_index).coluna6 := case when tot_qtprecal > 0 then
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
              vr_tab_tabela(1).coluna12 := '-';
          END IF;
          
          vr_string := vr_string || '<subcategoria>'||
                                    '<tituloTela>Opera��es de Cr�dito Ativas - Empr�stimo e Financiamento</tituloTela>'||
                                    '<campos>';
          
          vr_string := vr_string||'<campo>
                                   <nome>Propostas Ativas</nome>
                                   <tipo>table</tipo>
                                   <valor>
                                   <linhas>';

          vr_string := vr_string||fn_tag_table('Contrato;Risco Inclus�o;Saldo Devedor;Presta��es;Valor Presta��es;Atraso/Parcela;Finalidade;Linha de Cr�dito;Taxa;Garantia;Liquidar;Pontualidade', vr_tab_tabela);

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
      Data    : Mar�o/2019

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
              
            vr_tab_tabela(vr_index).coluna1 := to_char(rw_crapcns.vlrcarta,'999g999g990d00'); -- Valor da carta do cons�rcio
            vr_tab_tabela(vr_index).coluna2 := rw_crapcns.qtparpag; -- Parcelas pagas
            vr_tab_tabela(vr_index).coluna3 := rw_crapcns.qtparres; -- Parcelas restantes
            vr_tab_tabela(vr_index).coluna4 := to_char(rw_crapcns.vlparcns,'999g999g990d00'); -- Valor parcela
            
            vr_index := vr_index + 1;

        END LOOP;
        
        vr_string := vr_string || 
                   '<subcategoria>'||
                   '<tituloTela>Opera��es de Cr�dito Ativas - Cons�rcio</tituloTela>'||
                   '<campos>';
                   
        IF vr_tab_tabela.COUNT > 0 THEN
          
            vr_string := vr_string || fn_tag('Tem cons�rcio ativo na cooperativa', 'Sim');
            
            vr_string := vr_string||'<campo>
                                     <nome>Cons�rcios Ativos</nome>
                                     <tipo>table</tipo>
                                     <valor>
                                     <linhas>';
            
            vr_string := vr_string||fn_tag_table('Valor da Carta;Parcelas Pagas;Parcelas Restantes;Valor da Parcela', vr_tab_tabela);
            
            vr_string := vr_string||'</linhas>
                                     </valor>
                                     </campo>';
            
        ELSE
          
            vr_string := vr_string || fn_tag('Tem cons�rcio ativo na cooperativa', 'N�o');
            
            vr_tab_tabela(1).coluna1 := '-'; -- Valor da carta do cons�rcio
            vr_tab_tabela(1).coluna2 := '-'; -- Parcelas pagas
            vr_tab_tabela(1).coluna3 := '-'; -- Parcelas restantes
            vr_tab_tabela(1).coluna4 := '-'; -- Valor parcela
            
            vr_string := vr_string||'<campo>
                                     <nome>Cons�rcios Ativos</nome>
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
      Data    : Mar�o/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que busca as informa��es de plano de capital
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
        pr_dscritic := 'Empresa do associado n�o encontrada!';
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
      fn_tag('Dep�sito � Vista',TO_CHAR(vr_vlstotal,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
                   
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
                --|| fn_tag('Atualiza��o Autom�tica'     ,vr_dstipcor)
                --|| fn_tag('Debitar Em'                 ,vr_dsdebitar_em)
                --|| fn_tag('Quantidade de Presta��es'   ,vr_qtpremax)
                --|| fn_tag('Data de In�cio'             ,TO_CHAR(vr_dtdpagto,'dd/mm/yyyy'))
                --|| fn_tag('Data da �ltima Atualiza��o' ,TO_CHAR(vr_dtultcor,'dd/mm/yyyy'))
                --|| fn_tag('Data da Pr�xima Atualiza��o',TO_CHAR(vr_dtprocor,'dd/mm/yyyy'))
                --|| fn_tag('Tipo de Autoriza��o'        ,vr_tpautori);
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
      Data    : Mar�o/2019

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Procedure que busca as m�dias de deposito a vista
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
                              ,pr_cdagenci => NULL         --> N�o gerar log
                              ,pr_nrdcaixa => NULL         --> N�o gerar log
                              ,pr_cdoperad => NULL         --> N�o gerar log
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_idorigem => 5
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => 'TELA_UNICA'
                              ,pr_flgerlog => 0            --> N�o gerar log
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
                 '<tituloTela>Resumo da Conta - M�dias</tituloTela>'||
                 '<campos>';*/

      vr_string := vr_string ||'<campo>
                                <tipo>h3</tipo>
                                <valor>M�dias</valor>
                                </campo>';                 
                 
    /*FOR I IN 1..vr_tab_medias.count() LOOP
      vr_string := vr_string
                || fn_tag(vr_tab_medias(I).periodo,vr_tab_medias(I).vlsmstre);
    END LOOP;*/
    --
    FOR I IN 1..vr_tab_comp_medias.COUNT() LOOP
      vr_string := vr_string
                --|| fn_tag('M�s Atual'                     ,TO_CHAR(vr_tab_comp_medias(I).vltsddis,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                || fn_tag('Trimestre'                     ,TO_CHAR(vr_tab_comp_medias(I).vlsmdtri,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                || fn_tag('Semestre'                      ,TO_CHAR(vr_tab_comp_medias(I).vlsmdsem,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
                --|| fn_tag('M�dia Negativa do M�s'         ,TO_CHAR(vr_tab_comp_medias(I).vlsmnmes,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                --|| fn_tag('M�dia Negativa Especial do M�s',TO_CHAR(vr_tab_comp_medias(I).vlsmnesp,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                --|| fn_tag('M�dia Saques sem Bloqueio'     ,TO_CHAR(vr_tab_comp_medias(I).vlsmnblq,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))
                --|| fn_tag('Dias �teis no M�s'             ,vr_tab_comp_medias(I).qtdiaute)
                --|| fn_tag('Dias �teis Decorridos'         ,vr_tab_comp_medias(I).qtdiauti);
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
      Objetivo  : Procedure que busca valores de aplica��es
    ---------------------------------------------------------------------------------------------------------------------*/  
    
    vr_vlsldtot number := 0;
    vr_vlsldrgt number := 0;
    
  begin
  
     vr_cdcritic := null;
     vr_dscritic := null;
     
     vr_string := vr_string ||'<campo>
                               <tipo>h3</tipo>
                               <valor>Aplica��es</valor>
                               </campo>';  
                               
    -- Buscar dados da atenda 
    pc_busca_dados_atenda(pr_cdcooper => pr_cdcooper,
                          --bug 19891 pr_nrdconta => vr_nrdconta_principal);
                          pr_nrdconta => pr_nrdconta);
    --                               
    
    vr_vlsldtot := vr_tab_valores_conta(1).vlsldapl;
    vr_vlsldrgt := vr_tab_valores_conta(1).vlsldppr;

    
     
/*     APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper   --> C�digo da Cooperativa
                                       ,pr_cdoperad => '1'           --> C�digo do Operador
                                       ,pr_nmdatela => 'TELA_ANALISE_CREDITO'   --> Nome da Tela
                                       ,pr_idorigem => 1   --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA
                                       ,pr_nrdconta => pr_nrdconta   --> N�mero da Conta
                                       ,pr_idseqttl => 1   --> Titular da Conta
                                       ,pr_nraplica => 0             --> N�mero da Aplica��o / Par�metro Opcional
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt   --> Data de Movimento
                                       ,pr_cdprodut => 0             --> C�digo do Produto -�> Par�metro Opcional
                                       ,pr_idblqrgt => 1             --> Identificador de Bloqueio de Resgate (1 � Todas / 2 � Bloqueadas / 3 � Desbloqueadas)
                                       ,pr_idgerlog => 0             --> Identificador de Log (0 � N�o / 1 � Sim)
                                       ,pr_vlsldtot => vr_vlsldtot   --> Saldo Total da Aplica��o
                                       ,pr_vlsldrgt => vr_vlsldrgt   --> Saldo Total para Resgate
                                       ,pr_cdcritic => vr_cdcritic   --> C�digo da cr�tica
                                       ,pr_dscritic => vr_dscritic); --> Descri��o da cr�tica*/
                                       
     vr_string := vr_string||fn_tag('Total de Aplica��es',to_char(vr_vlsldtot,'999g999g990d00'))||                                    
                             fn_tag('Total Poupan�a Programada',to_char(vr_vlsldrgt,'999g999g990d00'));
                             
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
                 '<tituloTela>�ltimas 4 Opera��es Liquidadas - Empr�stimos e Financiamentos</tituloTela>'||
                 '<campos>';
    vr_string := vr_string||'<campo>
                             <nome>Empr�stimo/Financiamento</nome>
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
    vr_string := vr_string||fn_tag_table('Contrato;Valor da Opera��o;Presta��es;Finalidade;Linha de Cr�dito;Liquida��o;Pontualidade'
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
      Objetivo  : Procedure que busca os contratos que a conta da pessoa � avalista
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
            ,s.vldsaldo saldodeved
            ,c.nrctrlim contrato
            ,c.cddlinha || '-'||l.dsdlinha as linha
      FROM CRAPLIM c,
           crapldc l,
           crapsdv s
      WHERE c.cdcooper = l.cdcooper
      AND   c.cddlinha = L.CDDLINHA
      AND   s.cdcooper = l.cdcooper
      AND   s.nrdconta = c.nrdconta
      and   s.nrctrato = c.nrctrlim
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
                                         ,pr_nmdatela => 'TELA_UNICA'
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

    -- Buscar informa��es do XML retornado
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
        -- Sair se o nodo n�o for elemento
        IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;
        --
        -- Tratar leitura dos dados do SEGCAB (Header)
        IF vr_node_name = 'aval' THEN
          -- Buscar todos os filhos deste n�
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
            -- Sair se o nodo n�o for elemento
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
      -- FIM - Buscar informa��es do XML retornado
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
              pr_dscritic := 'Falha ao obter dados do empr�stimo. '||SQLERRM;
            END IF;
            RAISE vr_exc_erro;
          END IF;
  
          --
            FOR j IN 1 .. vr_tab_dados_epr.count() LOOP
              vr_qtmesdec := vr_tab_dados_epr(j).qtmesdec - vr_tab_dados_epr(j).qtprecal;
              vr_qtpreemp := vr_tab_dados_epr(j).qtpreemp - vr_tab_dados_epr(j).qtprecal;
            
            IF vr_qtmesdec > vr_qtpreemp  THEN
              vr_qtprecal := vr_qtpreemp;
            ELSE
              vr_qtprecal := vr_qtmesdec;
            END IF;
            
            IF vr_qtprecal < 0 THEN 
              vr_qtprecal := 0;
            END IF;
              
              --Pega os dados da tabela de emprestimos
              vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;                                       --Saldo Devedor
              vr_tab_tabela(vr_index).coluna3 := REPLACE(REPLACE(SUBSTR(vr_tab_dados_epr(j).dspreapg,5,11),',0000',''),'/',' / '); --Prest. Pagas/Total
              vr_tab_tabela(vr_index).coluna4 := vr_tab_dados_epr(j).vlpreemp;                                  --Presta��es
              vr_tab_tabela(vr_index).coluna5 := vr_tab_dados_epr(j).vltotpag;                                  --Atraso / Parcela
              vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(j).dsfinemp;                                  --Finalidade
              vr_tab_tabela(vr_index).coluna7 := vr_tab_dados_epr(j).dslcremp;                                  --Linha de Cr�dito
              vr_tab_tabela(vr_index).coluna8 := 'Aval conta ' -- Bug 20848
                                                || trim(gene0002.fn_mask_conta(vr_tab_dados_epr(j).nrdconta))
                                            || ' '
                                              || CASE WHEN vr_tab_dados_epr(j).inprejuz = 1 THEN '*' END;       --Responsabilidade
          END LOOP;

          /* DESCONTO DE TITULO */  
          ELSIF (vr_tab_aval(i).tpdcontr = 'DT') THEN
            
            /*Busca saldo devedor do desconto de t�tulo */
            OPEN c_busca_saldo_deved_dsctit(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                           ,pr_nrctrato => vr_tab_aval(i).nrctremp);
                                           
             fetch c_busca_saldo_deved_dsctit into r_busca_saldo_deved_dsctit;
             if c_busca_saldo_deved_dsctit%found then
             
               vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
               --Quando for desconto de t�tulo n�o tem presta��o e atraso/parcela bug19838
               vr_tab_tabela(vr_index).coluna3 := '-';
               vr_tab_tabela(vr_index).coluna4 := '-';
               vr_tab_tabela(vr_index).coluna5 := '-';
               
               vr_tab_tabela(vr_index).coluna6 := r_busca_saldo_deved_dsctit.dsfinalidade;
               vr_tab_tabela(vr_index).coluna7 := r_busca_saldo_deved_dsctit.dsdlinha;
               vr_tab_tabela(vr_index).coluna8 := 'Aval conta '|| trim(gene0002.fn_mask_conta(r_busca_saldo_deved_dsctit.nrdconta));
             
             end if;
            
            close c_busca_saldo_deved_dsctit;
            
            
          /* LIMITE DE CR�DITO EMPRESARIAL*/  
          ELSIF (vr_tab_aval(i).tpdcontr = 'LM') THEN
            
            /*Busca linha de cr�dito, os outros campos n�o precisa */
            OPEN c_busca_dados_limite_emp(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => vr_tab_aval(i).nrdconta
                                         ,pr_nrctrato => vr_tab_aval(i).nrctremp);
                                           
             fetch c_busca_dados_limite_emp into r_busca_dados_limite_emp;
             if c_busca_dados_limite_emp%found then
             
               --Quando for desconto de t�tulo n�o tem presta��o e atraso/parcela bug19838
               vr_tab_tabela(vr_index).coluna2 := vr_tab_aval(i).vldivida;
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
             vr_tab_tabela(vr_index).coluna2 := to_char(r_busca_dados_descchq.saldodeved,'999g999g990d00');
             --Quando for desconto de cheque n�o tem presta��o nem atraso/parcela nem finalidade
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
      vr_tab_tabela(1).coluna8 := '-';
    END IF;
    --
    vr_string := vr_string||fn_tag_table('Contrato;Saldo Devedor;Prest. Pagas / Total;Valor das Presta��es;Atraso Parcela;Finalidade;Linha de Cr�dito;Responsabilidade'
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
  
PROCEDURE pc_busca_riscos (pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
  Objetivo  : Procedure que busca os riscos das Ocorr�ncias
  
  Alteracoes: 30/05/2019 - Alterado nome de subcategoria de ocorrencias para risco.
                           Story 21955 - Sprint 11 - Gabriel Marcos (Mouts).

              04/06/2019 - Adicionado Nivel de risco em: Operacoes > Ocorrencias. 
                           Bug 22209 - PRJ438 - Gabriel Marcos (Mouts).                             
                           
---------------------------------------------------------------------------------------------------------------------*/

  --Vari�veis
  pr_retxml XMLTYPE;
  vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
  vr_dscritic VARCHAR2(1000);        --> Desc. Erro
  vr_nmdcampo VARCHAR2(100);
  vr_des_erro VARCHAR2(1000);
  pr_xmllog   VARCHAR2(1000);
  
  --Tabela para armazenar os riscos
  vr_tab_riscos       typ_tab_dados_riscos;
  
  vr_xmltype          xmlType;
  vr_parser           xmlparser.Parser;
  vr_doc              xmldom.DOMDocument;
  vr_index            NUMBER;
  
  -- Root
  vr_node_root        xmldom.DOMNodeList;
  vr_item_root        xmldom.DOMNode;
  vr_elem_root        xmldom.DOMElement;
  -- SubItens
  vr_node_list        xmldom.DOMNodeList;
  vr_node_name        VARCHAR2(100);
  vr_item_node        xmldom.DOMNode;
  vr_elem_node        xmldom.DOMElement;
  -- SubItens da AVAL
  vr_node_list_risco  xmldom.DOMNodeList;
  vr_node_name_risco  VARCHAR2(100);
  vr_item_node_risco  xmldom.DOMNode;
  vr_valu_node_risco  xmldom.DOMNode;
  -- Vari�veis do XML
  vr_nrdconta         NUMBER;
  vr_nrcpfcgc         NUMBER;
  vr_nrctrato         NUMBER;
  vr_riscoincl        VARCHAR2(1);
  vr_riscogrpo        VARCHAR2(1);
  vr_rating           VARCHAR2(1);
  vr_riscoatraso      VARCHAR2(1);
  vr_riscorefin       VARCHAR2(1);
  vr_riscoagrav       VARCHAR2(1);
  vr_riscomelhor      VARCHAR2(1);
  vr_riscooperac      VARCHAR2(1);
  vr_riscocpf         VARCHAR2(1);
  vr_riscofinal       VARCHAR2(1);
  vr_qtdiaatraso      NUMBER;
  vr_nrgreconomi      NUMBER;
  vr_tpregistro       VARCHAR2(100);                      

      -- Cadastro de Risco -> Campos: nivel de risco e justificativa (tela CADRIS)
  CURSOR cr_cadris IS
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
 rw_cadris cr_cadris%ROWTYPE;

  FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode)RETURN VARCHAR2 IS
  BEGIN
    RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
  END fn_getValue;
  
BEGIN
  
  /*Cria um XML padr�o para enviar como entrada para a package*/
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
  
  -- Buscar informa��es do XML retornado
  -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
  BEGIN
    IF pr_retxml IS NOT NULL THEN
      
      vr_xmltype := pr_retxml;
      vr_parser  := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc     := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);
      --
      -- Buscar nodo AVAL
      vr_node_root := xmldom.getElementsByTagName(vr_doc,'Contas');
      vr_item_root := xmldom.item(vr_node_root, 0);
      vr_elem_root := xmldom.makeElement(vr_item_root);
      --
      -- Faz o get de toda a lista ROOT
      vr_node_list := xmldom.getChildrenByTagName(vr_elem_root,'*');
      --
      vr_index := 0;
      vr_tab_riscos.DELETE;
      --
      -- Percorrer os elementos
      FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
        -- Buscar o item atual
        vr_item_node := xmldom.item(vr_node_list, i);
        -- Captura o nome e tipo do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);
        --
        -- Sair se o nodo n�o for elemento
        IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;
        --
        -- Tratar leitura dos dados do (Header)
        IF vr_node_name = 'Conta' THEN
          -- Buscar todos os filhos deste n�
          vr_elem_node := xmldom.makeElement(vr_item_node);
          -- Faz o get de toda a lista de folhas
          vr_node_list_risco := xmldom.getChildrenByTagName(vr_elem_node,'*');
          --
          vr_nrdconta := NULL;
          --
          -- Percorrer os elementos
          FOR i IN 0..xmldom.getLength(vr_node_list_risco)-1 LOOP
            -- Buscar o item atual
            vr_item_node_risco := xmldom.item(vr_node_list_risco, i);
            -- Captura o nome e tipo do nodo
            vr_node_name_risco := xmldom.getNodeName(vr_item_node_risco);
            -- Sair se o nodo n�o for elemento
            IF xmldom.getNodeType(vr_item_node_risco) <> xmldom.ELEMENT_NODE THEN
              CONTINUE;
            END IF;

            IF vr_node_name_risco = 'numero_conta' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_nrdconta  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'cpf_cnpj' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_nrcpfcgc  := fn_getValue(vr_valu_node_risco);
            END IF;            

            IF vr_node_name_risco = 'contrato' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_nrctrato  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'risco_inclusao' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscoincl  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'risco_grupo' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscogrpo  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'rating' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_rating  := fn_getValue(vr_valu_node_risco);
            END IF;
            
            IF vr_node_name_risco = 'risco_atraso' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscoatraso  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'risco_refin' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscorefin  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'risco_agravado' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscoagrav  := fn_getValue(vr_valu_node_risco);
            END IF;        

            IF vr_node_name_risco = 'risco_melhora' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscomelhor  := fn_getValue(vr_valu_node_risco);
            END IF;
            
            IF vr_node_name_risco = 'risco_operacao' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscooperac  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'risco_cpf' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscocpf  := fn_getValue(vr_valu_node_risco);
            END IF;
            
            IF vr_node_name_risco = 'risco_final' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_riscofinal  := fn_getValue(vr_valu_node_risco);
            END IF;

            IF vr_node_name_risco = 'qtd_dias_atraso' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_qtdiaatraso  := fn_getValue(vr_valu_node_risco);
            END IF;
            
            IF vr_node_name_risco = 'numero_gr_economico' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_nrgreconomi  := fn_getValue(vr_valu_node_risco);
            END IF;
            
            IF vr_node_name_risco = 'tipo_registro' THEN
              vr_valu_node_risco := xmldom.getFirstChild(vr_item_node_risco);
              vr_tpregistro  := fn_getValue(vr_valu_node_risco);
            END IF;            
            
            END LOOP;
          --
          IF vr_nrdconta IS NOT NULL THEN
            vr_index := vr_index+1;
            --
            --Alimenta a tabela de riscos
            vr_tab_riscos(vr_index).nrdconta := NVL(vr_nrdconta,0);
            vr_tab_riscos(vr_index).nrcpfcgc := NVL(vr_nrcpfcgc,0);
            vr_tab_riscos(vr_index).nrctrato := NVL(vr_nrctrato,0);
            vr_tab_riscos(vr_index).riscoincl := NVL(vr_riscoincl,'-');
            vr_tab_riscos(vr_index).riscogrpo := NVL(vr_riscogrpo,'-');
            vr_tab_riscos(vr_index).rating := NVL(vr_rating,'-');
            vr_tab_riscos(vr_index).riscoatraso := NVL(vr_riscoatraso,'-');
            vr_tab_riscos(vr_index).riscorefin := NVL(vr_riscorefin,'-');
            vr_tab_riscos(vr_index).riscoagrav := NVL(vr_riscoagrav,'-');
            vr_tab_riscos(vr_index).riscomelhor := NVL(vr_riscomelhor,'-');
            vr_tab_riscos(vr_index).riscooperac := NVL(vr_riscooperac,'-');
            vr_tab_riscos(vr_index).riscocpf := NVL(vr_riscocpf,'-');
            vr_tab_riscos(vr_index).riscofinal := NVL(vr_riscofinal,'-');
            vr_tab_riscos(vr_index).qtdiaatraso := NVL(vr_qtdiaatraso,0);
            vr_tab_riscos(vr_index).nrgreconomi := NVL(vr_nrgreconomi,0);
            vr_tab_riscos(vr_index).tpregistro := NVL(vr_tpregistro,'-');
          END IF;
        END IF;
      END LOOP;
      END IF;
      -- FIM - Buscar informa��es do XML retornado
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  
  /*Itera e extrai os dados da tabela de riscos para a tabela que ser� apresentada*/
  IF vr_tab_riscos.COUNT() > 0 THEN
    vr_index := 1;
    FOR i IN 1..vr_tab_riscos.COUNT() LOOP
      vr_tab_tabela(vr_index).coluna1  := gene0002.fn_mask_cpf_cnpj(vr_tab_riscos(vr_index).nrcpfcgc,
                                       CASE WHEN length(vr_tab_riscos(vr_index).nrcpfcgc) > 11 THEN 2 ELSE 1 END);
      vr_tab_tabela(vr_index).coluna2  := gene0002.fn_mask_conta(vr_tab_riscos(vr_index).nrdconta);
      vr_tab_tabela(vr_index).coluna3  := gene0002.fn_mask_contrato(vr_tab_riscos(vr_index).nrctrato);
      vr_tab_tabela(vr_index).coluna4 := vr_tab_riscos(vr_index).tpregistro;
      vr_tab_tabela(vr_index).coluna5  := vr_tab_riscos(vr_index).riscoincl;
      vr_tab_tabela(vr_index).coluna6  := vr_tab_riscos(vr_index).rating;
      vr_tab_tabela(vr_index).coluna7  := vr_tab_riscos(vr_index).riscoatraso;
      vr_tab_tabela(vr_index).coluna8  := vr_tab_riscos(vr_index).riscorefin;
      vr_tab_tabela(vr_index).coluna9  := vr_tab_riscos(vr_index).riscoagrav;
      vr_tab_tabela(vr_index).coluna10 := vr_tab_riscos(vr_index).riscomelhor;
      vr_tab_tabela(vr_index).coluna11 := vr_tab_riscos(vr_index).riscooperac;
      vr_tab_tabela(vr_index).coluna12 := vr_tab_riscos(vr_index).riscocpf;
      vr_tab_tabela(vr_index).coluna13  := vr_tab_riscos(vr_index).riscogrpo;
      vr_tab_tabela(vr_index).coluna14 := vr_tab_riscos(vr_index).riscofinal;
      vr_tab_tabela(vr_index).coluna15 := vr_tab_riscos(vr_index).qtdiaatraso;
      vr_tab_tabela(vr_index).coluna16 := vr_tab_riscos(vr_index).nrgreconomi;
      
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
               
  --N�vel de Risco - APENAS PARA O PROPONENTE
  --if (pr_persona = 'Proponente') then
  -- Se as contas forem iguais eh o proponente
  if vr_nrdconta_principal = pr_nrdconta then
    if vr_tpproduto_principal = c_emprestimo then
      open c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctrato_principal);
      fetch c_proposta_epr into r_proposta_epr;
      vr_string := vr_string||tela_analise_credito.fn_tag('N�vel de Risco da Proposta',r_proposta_epr.dsnivris);
      close c_proposta_epr;
    end if;
  end if;
                        
  --
  /*Apresentado em tabela*/
  vr_string := vr_string||'<campo>
                           <nome>Riscos</nome>
                           <tipo>table</tipo>
                           <valor>
                           <linhas>'; 
  --
  vr_string := vr_string||fn_tag_table('CPF/CNPJ;Conta;N�mero Contrato;Tipo Contrato;Risco Inclus�o;Rating;Risco Atraso;Risco Refinanciamento;Risco Agravado;Risco Melhora;Risco Opera��o;Risco CPF;Risco Grupo Econ�mico;Risco Final;Quantidade Dias Atraso;N�mero Grupo Econ�mico'
              ,vr_tab_tabela);
  vr_string := vr_string||'</linhas>
                           </valor>
                           </campo>';

   --Mostrar o agravamento de risco pelo controle:     
   open cr_cadris;
    fetch cr_cadris into rw_cadris;
      vr_string := vr_string||tela_analise_credito.fn_tag('Agravamento de Risco pelo Controle',
                                             fn_getNivelRisco(rw_cadris.cdnivel_risco));
      vr_string := vr_string||tela_analise_credito.fn_tag('Justificativa',rw_cadris.dsjustificativa); 
   close cr_cadris;
  --
  vr_string := vr_string||'</campos></subcategoria>';

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
      -- M�dias
      pc_medias(pr_cdcooper => pr_cdcooper
               ,pr_nrdconta => pr_nrdconta
               ,pr_dtmvtolt => pr_dtmvtolt
               ,pr_cdcritic => pr_cdcritic
               ,pr_dscritic => pr_dscritic);
      -- Aplica��es
      pc_aplicacoes(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_cdcritic => pr_cdcritic
                   ,pr_dscritic => pr_dscritic);

      
      --3.2 Opera��es de Cr�dito Ativas
       --3.2.1 Produto Empr�stimo e Financiamento 
      pc_busca_propostas_ativas(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
                                 
      /*--3.2.2 Produto B�rdero de Desconto de 
      pc_busca_borderos(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);*/
                       
       --3.2.2 Produto Cons�rcio - Verificar se vamos trazer
      pc_busca_consorcio(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);

      --3.3 Rotativos Ativos
      --3.3.1 Modalidade Limite de Cr�dito:   
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
      
        -- Modalidade desconto de Produto B�rdero de Desconto de T�tulo
        -- User Story 21153:Categoria Opera��es Subcategoria Opera��es de Cr�dito Ativas - Produto B�rdero de Desconto de Cheque
        pc_consulta_bordero_chq(pr_cdcooper => pr_cdcooper       --> Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --> Conta
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic                            
                               ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);     
       --3.3.3 Modalidade Desconto de  T�tulo 
        pc_consulta_desc_titulo(pr_cdcooper => pr_cdcooper       --> Cooperativa
                               ,pr_nrdconta => pr_nrdconta       --> Conta
                               ,pr_cdcritic => pr_cdcritic
                               ,pr_dscritic => pr_dscritic                               
                               ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);
                                               
       --3.3.4 Produto B�rdero de Desconto de 
       pc_busca_borderos(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
                                               
       --3.3.5 Modalidade Cart�o de Cr�dito 
        pc_modalidade_car_cred(pr_cdcooper => pr_cdcooper       --> Cooperativa
                              ,pr_nrdconta => pr_nrdconta       --> Conta
                              ,pr_cdcritic => pr_cdcritic
                              ,pr_dscritic => pr_dscritic                              
                              ,pr_dsxmlret => vr_xml);
                                
                               pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                              pr_texto_completo => vr_string,
                                              pr_texto_novo     => vr_xml,
                                              pr_fecha_xml      => TRUE);
      --3.4 Lan�amentos Futuros
        pc_consulta_lanc_futuro(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);
                                
      --3.5 �ltimas 4 Opera��es Liquidadas
      
      --3.5.1Produto Empr�stimos e Financiamentos 
       pc_emprestimos_liquidados(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic);      
      
      --3.5.2 Produto Border� de Desconto de T�tulos
         pc_consulta_bordero(pr_cdcooper => pr_cdcooper       --> Cooperativa
                            ,pr_nrdconta => pr_nrdconta       --> Conta
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic                            
                            ,pr_dsxmlret => vr_xml);
                                
                                pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                                               pr_fecha_xml      => TRUE);
                                
      --3.6 �ltimas 4 Opera��es Altera��es 
      
      --3.6.1 Produto Limite de Cr�dito 
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
                                    
      --3.6.3 Produto Limite de Desconto de T�tulo
        pc_consulta_lim_desc_tit(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                ,pr_nrdconta => pr_nrdconta       --> Conta
                                ,pr_cdcritic => pr_cdcritic
                                ,pr_dscritic => pr_dscritic                                
                                ,pr_dsxmlret => vr_xml);  
                                
                                 pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                                pr_texto_completo => vr_string,
                                                pr_texto_novo     => vr_xml,
                                                pr_fecha_xml      => TRUE);                                    

      --3.6.4  Produto Cart�o de Cr�dito 
        pc_consulta_hist_cartaocredito(pr_cdcooper => pr_cdcooper       --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta       --> Conta
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic                                      
                                      ,pr_dsxmlret => vr_xml);  

         pc_escreve_xml(pr_xml            => vr_dsxmlret,
                                               pr_texto_completo => vr_string,
                                               pr_texto_novo     => vr_xml,
                     pr_fecha_xml      => TRUE);

      --3.6 Hist�rico do Associado --- S�o as informa��es de Opera��es
      
      --3.7 Co-responsabilidade:
      pc_co_responsabilidade(pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_dtmvtolt => pr_dtmvtolt
                            ,pr_cdcritic => pr_cdcritic
                            ,pr_dscritic => pr_dscritic);  

              pc_escreve_xml(pr_xml            => vr_dsxmlret,
                             pr_texto_completo => vr_string,
                             pr_texto_novo     => null, -- Valor de pc_co_responsabilidade j� esta na String
                             pr_fecha_xml      => TRUE);                                  

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
          pr_dscritic := 'Erro TELA_ANALISE_CREDITO.PC_CONSULTA_OPERACOES - '||SQLERRM;
          vr_string := '<categoria>'||
                           '<tituloTela>Opera��es</tituloTela>'||
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

  PROCEDURE pc_mensagem_motor(pr_cdcooper  IN crawepr.cdcooper%TYPE       --> Cooperativa
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
    CURSOR cr_motor (prc_cdcooper IN crapage.cdcooper%TYPE,
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
            and e.cdorigem   = 9
            and e.cdoperad   = 'MOTOR'
            and e.dsoperacao NOT LIKE '%ERRO%'
            and e.dsoperacao NOT LIKE '%DESCONHECIDA%'
            and e.nrdconta   = prc_nrdconta
            and e.nrctrprp   = prc_nrctrprp
            and a.nrdconta   = e.nrdconta
            ORDER BY e.dhacionamento DESC;  
    -- vari�veis   
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
      vr_index := 0;
      vr_tab_tabela.delete;     
      FOR rw_motor IN cr_motor(pr_cdcooper,
                                pr_nrdconta,
                                pr_nrctrato) LOOP
        vr_string_xml := '<subcategoria>'||
                                 '<tituloTela>Retorno da An�lise do Motor</tituloTela>'||
                                 '<campos>';
        vr_string_xml := vr_string_xml||'<campo>
                                         <nome>Mensagens</nome>
                                         <tipo>table</tipo>
                                         <valor>
                                         <linhas>';
                        
        BEGIN
          -- Efetuar cast para JSON
          vr_obj := json(rw_motor.dsconteudo_requisicao);
          vr_index :=  vr_index + 1; 
        
          IF vr_obj.exist('resultadoAnaliseRegra') THEN
            vr_tab_tabela(vr_index).coluna1 := 'Resultado da Avaliac�o: '|| initcap(REPLACE(gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('resultadoAnaliseRegra').to_char(),'"'),'"'),'\u','\'))),'DERIVAR','An�lise Manual'));
          END IF;                   
          -- Se existe o objeto de analise
          IF vr_obj.exist('analises') THEN
            vr_obj_anl := json(vr_obj.get('analises').to_char());
            -- Se existe a lista de mensagens
            IF vr_obj_anl.exist('mensagensDeAnalise') THEN
               vr_obj_lst := json_list(vr_obj_anl.get('mensagensDeAnalise').to_char());
               -- Para cada mensagem
               FOR vr_idx IN 1..vr_obj_lst.count() LOOP
                 BEGIN
                   vr_obj_msg := json( vr_obj_lst.get(vr_idx)); 
   
                   -- Se encontrar o atributo texto e tipo
                   IF vr_obj_msg.exist('texto') AND vr_obj_msg.exist('tipo') THEN
                     vr_desmens := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_msg.get('texto').to_char(),'"'),'"'),'\u','\')));
                     vr_destipo := REPLACE(RTRIM(LTRIM(vr_obj_msg.get('tipo').to_char(),'"'),'"'),'ERRO','REPROVAR');
                   END IF; 
                   --
                   IF vr_destipo <> 'DETALHAMENTO' THEN
                     vr_index :=  vr_index + 1; 
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
            -- Ignorar se o conteudo nao for JSON n�o conseguiremos ler as mensagens
            null;
        END;
        
        vr_string_xml := vr_string_xml||fn_tag_table(NULL,vr_tab_tabela);

        vr_string_xml := vr_string_xml||'</linhas>
                                         </valor>
                                         </campo>';         
        
        vr_string_xml := vr_string_xml||'</campos></subcategoria>';
        EXIT; -- executar somente uma vez   
      END LOOP;

     pr_dsxmlret := vr_string_xml;
    
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro pc_mensagem_motor: '||sqlerrm; 
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
    Data    : Mar�o/2019                 Ultima atualizacao: 17/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta do proponente para o produto limite desconto de t�tulo

    Alteracoes:
  ..............................................................................*/

  vr_dsxmlret CLOB;
  vr_dsxml_mensagem CLOB;
  vr_string      CLOB;

  --Data para consultar a proposta
  rw_crapdat  btch0001.cr_crapdat%rowtype;

  /* Dados da Solicita��o - Proposta do Proponente - Task 16167 */
  cursor c_limites_desconto_titulos (pr_cdcooper IN crapcop.cdcooper%TYPE
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
   select fn_tag('Valor Limite Solicitado',to_char(lim.vllimite,'999g999g990d00')) vllimite
         ,fn_tag('Contrato',gene0002.fn_mask_contrato(lim.nrctrlim)) nctrlim
         ,fn_tag('Linha Desconto',(select dsdlinha from crapldc
                                   where  cdcooper = lim.cdcooper
                                   and    cddlinha = lim.cddlinha
                                   and    tpdescto = 3)) dsdlinha
         ,fn_tag('Valor M�dio Titulos',(select to_char(vlmedchq,'999g999g990d00')
                                        from crapprp
                                        where cdcooper = lim.cdcooper
                                        and   nrdconta = lim.nrdconta
                                        and   nrctrato = lim.nrctrlim)) vlmedtit
         ,case lim.insitlim when 1 then fn_tag('Situa��o Proposta','EM ESTUDO')
                            when 2 then fn_tag('Situa��o Proposta','ATIVA')
                            when 3 then fn_tag('Situa��o Proposta','CANCELADA')
                            when 5 then fn_tag('Situa��o Proposta','APROVADA')
                            when 6 then fn_tag('Situa��o Proposta','N�O APROVADA')
                            when 8 then fn_tag('Situa��o Proposta','EXPIRADA DECURSO DE PRAZO')
                            when 9 then fn_tag('Situa��o Proposta','ANULADA')
                            else        fn_tag('Situa��o Proposta','DIFERENTE')
          end dssitlim
         ,case lim.insitest when 0 then fn_tag('Situa��o An�lise','N�O ENVIADO')
                            when 1 then fn_tag('Situa��o An�lise','ENVIADA ANALISE AUTOM�TICA')
                            when 2 then fn_tag('Situa��o An�lise','ENVIADA ANALISE MANUAL')
                            when 3 then fn_tag('Situa��o An�lise','AN�LISE FINALIZADA')
                            when 4 then fn_tag('Situa��o An�lise','EXPIRADA')
                            else        fn_tag('Situa��o An�lise','DIFERENTE')
          end dssitest
         ,case lim.insitapr when 0 then fn_tag('Decis�o','N�O ANALISADO')
                            when 1 then fn_tag('Decis�o','APROVADA AUTOMATICAMENTE')
                            when 2 then fn_tag('Decis�o','APROVADA MANUAL')
                            when 3 then fn_tag('Decis�o','APROVADA')
                            when 4 then fn_tag('Decis�o','REJEITADA MANUAL')
                            when 5 then fn_tag('Decis�o','REJEITADA AUTOMATICAMENTE')
                            when 6 then fn_tag('Decis�o','REJEITADA')
                            when 7 then fn_tag('Decis�o','N�O ANALISADA')
                            when 8 then fn_tag('Decis�o','REFAZER')
                            else        fn_tag('Decis�o','DIFERENTE')
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
                          '<tituloTela>Limite de Desconto de T�tulo</tituloTela>';

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
    Data    : Mar�o/2019                 Ultima atualizacao: 08/05/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta emprestimo

    Alteracoes: 31/05/2019 - Alterado Rubens Lima
                             Novo c�lculo Endividamento Total Fluxo.
                             Story 21378
                31/05/2019 - Inclus�o apresenta��o das Liquida��es - Paulo Martins
                
                04/06/2019 - Corrigir calculo de envididamento total.
                             Bug 22205 - PRJ438 - Gabriel Marcos (Mouts).

  ..............................................................................*/
          
  /*Busca o n�mero do tipo de garantia conforme b1wgen0002*/

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
    SELECT c.dtlibera, c.vlemprst, c.idfiniof
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
     
    CURSOR c_busca_contrato_cc_liquidar IS 
     SELECT nrliquid,
            dtmvtolt
     FROM crawepr
     WHERE cdcooper = pr_cdcooper
     AND   nrdconta = pr_nrdconta
     AND   nrctremp = pr_nrctrato;
    r_busca_contrato_cc_liquidar c_busca_contrato_cc_liquidar%ROWTYPE;
     
    /*Busca o limite do �ltimo cart�o criado*/
    CURSOR c_busca_limite_cartao_cc IS
     SELECT vllimcrd
     FROM crawcrd c
     WHERE c.cdcooper = pr_cdcooper
     AND   c.nrdconta = pr_nrdconta
     AND   c.insitcrd = 4  -- Em uso
     AND   c.progress_recid = (select max(progress_recid)
                               from crawcrd
                                where cdcooper = c.cdcooper
                               and   nrdconta = c.nrdconta
                               and   insitcrd = c.insitcrd);
    
    /*Propostas da conta com a situa��o Aprovado para calculo do valor financiado de todas*/
    CURSOR c_busca_proposta_andamento IS
     SELECT nrctremp
     FROM crawepr c
     WHERE cdcooper = pr_cdcooper
     AND  nrdconta = pr_nrdconta
     AND  nrctremp <> pr_nrctrato
     AND  insitapr = 1 --Aprovado
     AND vlempori > 0
     AND nrctremp NOT IN (SELECT nrctremp
                          FROM crapepr
                          WHERE cdcooper = c.cdcooper
                          AND   nrdconta = c.nrdconta);
     
  --Vari�veis
  vr_totvlfinanc NUMBER;
  vr_nrctremp    NUMBER;
  vr_vlfinanc_andamento NUMBER;
  
  vr_dsxmlret CLOB;  
  vr_dsxml_mensagem CLOB;    
  vr_string_contrato_epr CLOB;      
  vr_string_aux CLOB;  
  vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
  vr_vlutiliz NUMBER;
  vr_vllimcred NUMBER;
  vr_nrgarope NUMBER;
  vr_vlendtot NUMBER; --Endividamento total do fluxo
  
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
  vr_idfiniof            number;
  vr_vliofepr            number;
  vr_vlrtarif_ret        number;
  vr_avalista1_aux       number := 0;
  vr_avalista2_aux       number := 0;
  vr_liquidacoes         varchar2(32000);
  vr_index               number := 0;
  vr_total_liquidacoes   number(25,2) :=0;
  
  --Rowtype para calcular os empr�stimos aprovados
  r_proposta_epr2 c_proposta_epr%ROWTYPE;
  
  begin
  
   -- Criar documento XML
   dbms_lob.createtemporary(vr_dsxmlret, TRUE);
   dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
                      
    --> listar avalistas de contratos
    DSCT0002.pc_lista_avalistas ( pr_cdcooper => pr_cdcooper  --> C�digo da Cooperativa
                        ,pr_cdagenci => 0  --> C�digo da agencia
                        ,pr_nrdcaixa => 0  --> Numero do caixa do operador
                        ,pr_cdoperad => 1  --> C�digo do Operador
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
                        ,pr_cdcritic          => vr_cdcritic          --> C�digo da cr�tica
                        ,pr_dscritic          => vr_dscritic);        --> Descri��o da cr�tica
                                          
    IF vr_tab_dados_avais.exists(1) THEN
      vr_avalista1_aux := vr_tab_dados_avais(1).nrctaava;
    END IF;
                      
    IF vr_tab_dados_avais.exists(2) THEN
      vr_avalista2_aux := vr_tab_dados_avais(2).nrctaava;
    END IF;   
    
    /*Garantia da proposta*/
    vr_garantia := '-';
    vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,pr_nrctrato,vr_avalista1_aux,vr_avalista2_aux,'P',c_emprestimo);    
    -- Fim Garantia

  
   vr_string_contrato_epr := '<subcategoria>'||
                             '<tituloTela>Proposta</tituloTela>'||
                             '<campos>';
                             
   open c_proposta_epr(pr_cdcooper,pr_nrdconta,pr_nrctrato);
    fetch c_proposta_epr into r_proposta_epr;
    
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
      vr_vlfinanc := r_proposta_epr.vlemprst;

      if r_proposta_epr.idfiniof = 1 then
         vr_vlfinanc := vr_vlfinanc + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);          
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
    
   /*Valor dispon�vel em -> busca data e calcular o saldo descontando o valor das liquida��es bug 20969*/
    
   OPEN cr_crawepr;
    FETCH cr_crawepr INTO r_crwepr;
    IF cr_crawepr%FOUND THEN 
      
    vr_string_contrato_epr := vr_string_contrato_epr||'<campo>
                                                       <nome>Liquida��es</nome>
                                                       <tipo>table</tipo>
                                                       <valor>
                                                       <linhas>';
      
    BEGIN  
    vr_index := 0;
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
                             ,pr_cdagenci       => 0                      --> C�digo da ag�ncia
                             ,pr_nrdcaixa       => 0                      --> N�mero do caixa
                             ,pr_cdoperad       => 1                      --> C�digo do operador
                             ,pr_nmdatela       => 'TELA_UNICA'               --> Nome datela conectada
                             ,pr_idorigem       => 5                      --> Indicador da origem da chamada
                             ,pr_nrdconta       => pr_nrdconta            --> Conta do associado
                             ,pr_idseqttl       => 1                      --> Sequencia de titularidade da conta
                             ,pr_rw_crapdat     => rw_crapdat             --> Vetor com dados de par�metro (CRAPDAT)
                             ,pr_dtcalcul       => ''                     --> Data solicitada do calculo
                             ,pr_nrctremp       => r1.ctrliq              --> N�mero contrato empr�stimo
                             ,pr_cdprogra       => 0                      --> Programa conectado
                             ,pr_inusatab       => vr_inusatab            --> Indicador de utiliza��o da tabela
                             ,pr_flgerlog       => 'N'                    --> Gerar log S/N
                             ,pr_flgcondc       => FALSE                  --> Mostrar emprestimos liquidados sem prejuizo
                             ,pr_nmprimtl       => ''                     --> Nome Primeiro Titular
                             ,pr_tab_parempctl  => vr_dstextab_parempctl  --> Dados tabela parametro
                             ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                             ,pr_nriniseq       => 1                      --> Numero inicial da paginacao
                             ,pr_nrregist       => 9999                   --> Numero de registros por pagina
                             ,pr_qtregist       => vr_qtregist            --> Qtde total de registros
                             ,pr_tab_dados_epr  => vr_tab_dados_epr       --> Saida com os dados do empr�stimo
                             ,pr_des_reto       => vr_des_reto            --> Retorno OK / NOK
                             ,pr_tab_erro       => vr_tab_erro);          --> Tabela com poss�ves erros
        
        vr_totslddeved := vr_totslddeved + vr_tab_dados_epr(1).vlsdeved;
        vr_idfiniof := vr_idfiniof + vr_tab_dados_epr(1).idfiniof;

        if vr_index = 0 then
          vr_index := 1;
        else 
          vr_index := vr_index+1;          
        end if; -- Necess�rio pela valida��o de liquida��o CC 
                
        /*Carrega dados do emprestimo*/
        vr_tab_tabela(vr_index).coluna1 := vr_tab_dados_epr(1).cdlcremp;
        vr_tab_tabela(vr_index).coluna2 := vr_tab_dados_epr(1).cdfinemp;
        vr_tab_tabela(vr_index).coluna3 := vr_tab_dados_epr(1).nrctremp;
        vr_tab_tabela(vr_index).coluna4 := to_char(vr_tab_dados_epr(1).dtmvtolt,'dd/mm/rrrr');
        vr_tab_tabela(vr_index).coluna5 := to_char(vr_tab_dados_epr(1).vlemprst,'999g999g990d00');
        vr_tab_tabela(vr_index).coluna6 := vr_tab_dados_epr(1).qtpreemp;
        vr_tab_tabela(vr_index).coluna7 := to_char(vr_tab_dados_epr(1).vlpreemp,'999g999g990d00');
        vr_tab_tabela(vr_index).coluna8 := to_char(round(vr_tab_dados_epr(1).vlsdeved,2),'999g999g990d00');
        vr_tab_tabela(vr_index).coluna9 := 'PP';
        vr_total_liquidacoes := vr_total_liquidacoes + round(vr_tab_dados_epr(1).vlsdeved,2);
        
    END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        vr_totslddeved := 0;
    END;
    
    
      /*Valor empr�stimo - Total saldo devedor*/
      vr_totslddeved := r_crwepr.vlemprst - vr_totslddeved;
      
      /*Quando n�o financiar IOF, descontar IOF + Tarifa - bug 20969*/
      if r_crwepr.idfiniof = 0 then
        vr_totslddeved := vr_totslddeved - vr_vlrdoiof - vr_vlrtarif;
      end if;
      
    /*Verifica ainda se precisa descontar dep�sito a vista da conta corrente*/
    OPEN c_busca_contrato_cc_liquidar;
     FETCH c_busca_contrato_cc_liquidar INTO r_busca_contrato_cc_liquidar;
     
     IF c_busca_contrato_cc_liquidar%FOUND THEN
       /*Busca dados da atenta e salva em tabela*/
       pc_busca_dados_atenda(pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => pr_nrdconta);
       /*Dep�sito com valor negativo, deve descontar*/
       IF (vr_tab_valores_conta(1).vlstotal < 0) and  r_busca_contrato_cc_liquidar.nrliquid > 0 THEN
         vr_totslddeved := vr_totslddeved + vr_tab_valores_conta(1).vlstotal;
         
         /*Informa��es para liquida��es*/
        if vr_index = 0 then
          vr_index := 1;
        else 
          vr_index := vr_index+1;          
        end if;         
        vr_tab_tabela(vr_index).coluna1 := '-';
        vr_tab_tabela(vr_index).coluna2 := '-';
        vr_tab_tabela(vr_index).coluna3 := r_busca_contrato_cc_liquidar.nrliquid;
        vr_tab_tabela(vr_index).coluna4 := to_char(r_busca_contrato_cc_liquidar.dtmvtolt,'dd/mm/rrrr');
        vr_tab_tabela(vr_index).coluna5 := '-';
        vr_tab_tabela(vr_index).coluna6 := '-';
        vr_tab_tabela(vr_index).coluna7 := '-';
        vr_tab_tabela(vr_index).coluna8 := round(abs(vr_tab_valores_conta(1).vlstotal),2);
        vr_tab_tabela(vr_index).coluna9 := 'CC';
        vr_total_liquidacoes := vr_total_liquidacoes+round(abs(vr_tab_valores_conta(1).vlstotal),2);
       END IF;
     END IF;
    CLOSE c_busca_contrato_cc_liquidar;
    
    /*Tabela liquida��es*/    
    if vr_tab_tabela.COUNT > 0 then
      /*Total de liquida��es*/
      vr_index := vr_index+1;
      vr_tab_tabela(vr_index).coluna1 := '-';
      vr_tab_tabela(vr_index).coluna2 := '-';
      vr_tab_tabela(vr_index).coluna3 := '-';
      vr_tab_tabela(vr_index).coluna4 := '-';
      vr_tab_tabela(vr_index).coluna5 := '-';
      vr_tab_tabela(vr_index).coluna6 := '-';
      vr_tab_tabela(vr_index).coluna7 := 'Total';
      vr_tab_tabela(vr_index).coluna8 := vr_total_liquidacoes;
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
    
    vr_liquidacoes := vr_liquidacoes||'</linhas>
                                       </valor>
                                       </campo>';
    
    vr_string_contrato_epr := vr_string_contrato_epr||vr_liquidacoes;
     
      
      vr_string_contrato_epr := vr_string_contrato_epr||fn_tag('Valor Dispon�vel em '||to_char(r_crwepr.dtlibera,'DD/MM/YYYY'),
                                to_char(vr_totslddeved,'999g999g990d00'));       
    END IF;                          
   CLOSE cr_crawepr;

   /*
   Carregar os dados de opera��es de cr�dito + valor da proposta + limite de cart�o de cr�dito
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
                           
   /*Carrega o valor do cart�o de cr�dito*/
   OPEN c_busca_limite_cartao_cc;
    FETCH c_busca_limite_cartao_cc INTO vr_vllimcred;
   CLOSE c_busca_limite_cartao_cc;
   
   /*Acumular Proposta em andamento com Situa��o Analise Finalizada e Decis�o Aprovada (VALOR FINANCIADO)*/
     
     /*Para cada proposta*/
     OPEN c_busca_proposta_andamento;
       LOOP
       FETCH c_busca_proposta_andamento INTO vr_nrctremp;
       EXIT WHEN c_busca_proposta_andamento%NOTFOUND;
         /*Buscar valor acumulado e calcular*/
         OPEN c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctremp);
         FETCH c_proposta_epr into r_proposta_epr2;
    
         /*IOF - TARIFA - VALOR EMPRESTIMO*/
         vr_dscatbem := '';
         FOR rw_crapbpr IN cr_crapbpr LOOP
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

    SELECT decode(cdusolcr,2,0,cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
               tpctrato
               into 
               vr_cdusolcr,
               vr_tpctrato
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = r_proposta_epr2.cdlcremp;
                                       
     -- Calcula tarifa
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
                               ,pr_dscritic => vr_dscritic);
          
      vr_vlrtarif := ROUND(nvl(vr_vlrtarif,0),2) + nvl(vr_vlrtares,0) + nvl(vr_vltarbem,0);
      vr_vlfinanc_andamento := r_proposta_epr2.vlemprst;
        
      if r_proposta_epr2.idfiniof = 1 then
         vr_vlfinanc_andamento := vr_vlfinanc_andamento + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);          
      end if;

      close c_proposta_epr;  
       
       END LOOP;
     CLOSE c_busca_proposta_andamento;

   /*C�lculo do Endividamento total do fluxo*/
   vr_vlendtot := NVL(vr_vlfinanc_andamento,0) + --Proposta Esteira
                  NVL(vr_vlfinanc,0) + -- Financiado
                  NVL(vr_vlutiliz,0) +
                  NVL(vr_vllimcred,0); --Cart�o de Cr�dito
                           
   --vr_string_contrato_epr := vr_string_contrato_epr||fn_tag('Endividamento Total do Fluxo',to_char(vr_vlendtot,'999g999g990d00'));       
    
   vr_string_contrato_epr := vr_string_contrato_epr||'</campos></subcategoria>';     
   vr_string_aux := null;
   pc_mensagem_motor(pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_nrctrato => pr_nrctrato,
                     pr_cdcritic => pr_cdcritic,
                     pr_dscritic => pr_dscritic,
                     pr_dsxmlret => vr_string_aux);    
   IF vr_string_aux IS NOT NULL THEN
     vr_string_contrato_epr := vr_string_contrato_epr||vr_string_aux;
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
    Data    : Mar�o/2019                 Ultima atualizacao: 03/06/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Consulta proposta para Cart�o de Cr�dito

    Alteracoes: Consulta Cart�o Anterior.
  ..............................................................................*/
                                    
  --Vari�veis
  vr_string        VARCHAR2(32767) := NULL;
  vr_vllimsgrd     CLOB; --limite sugerido
  vr_dstipcart     VARCHAR2(100); --descri��o do tipo cart�o
  vr_qtcartadc     NUMBER := 0;
  vr_dsxml_mensagem CLOB;

  /*Busca dados cart�o*/
  CURSOR c_busca_dados_cartao_cc IS
    SELECT c.vllimcrd vllimativo
          ,a.nmresadm categorianova
    FROM crawcrd c
        ,crapadc a
    WHERE c.cdcooper = a.cdcooper
    AND   c.cdadmcrd = a.cdadmcrd
    AND   c.cdcooper = pr_cdcooper
    AND   c.nrdconta = pr_nrdconta
    AND   c.nrctrcrd = pr_nrctrato;
    r_busca_dados_cartao_cc c_busca_dados_Cartao_cc%ROWTYPE;

  /*Busca hist�rico de altera��o de limite*/
  CURSOR c_historico_credito (pr_nrdconta crapass.nrdconta%TYPE
                             ,pr_cdcooper crapass.cdcooper%TYPE) IS
      SELECT 
             atu.vllimite_anterior
            ,TRUNC(atu.dtalteracao) dtalteracao
        FROM tbcrd_limite_atualiza atu
            ,crapadc a
       WHERE a.cdcooper = atu.cdcooper
         AND a.cdadmcrd = atu.cdadmcrd 
         AND atu.cdcooper       = pr_cdcooper
         AND atu.nrdconta       = pr_nrdconta
         AND atu.nrproposta_est IS NOT NULL
         AND atu.tpsituacao     = 3 /* Concluido com sucesso */         
         AND atu.dtalteracao = (SELECT max(dtalteracao)
                                    FROM tbcrd_limite_atualiza lim
                                   WHERE lim.cdcooper       = atu.cdcooper
                                     AND lim.nrdconta       = atu.nrdconta
                                     AND lim.nrconta_cartao = atu.nrconta_cartao
                                     AND lim.nrproposta_est = atu.nrproposta_est)
       ORDER BY idatualizacao DESC;
   r_historico_credico c_historico_credito%ROWTYPE;
                                      
   /*Dados do cart�o em uso: Categoria Anterior, Limite Ativo
    Quando o proponente tiver mais de um cart�o de cr�dito , por exemplo Ailos Cl�ssico e Ailos Debito
    trazer para a tela �nica sempre a informa��o do cart�o de credito e com a titularidade do proponente.*/
   CURSOR c_busca_dados_cartao_uso (pr_cdcooper crawcrd.cdcooper%TYPE
                                   ,pr_nrdconta crawcrd.nrdconta%TYPE) IS
    SELECT a.nmresadm --Categoria Anterior
          ,c.vllimcrd --Limite Ativo
    FROM crawcrd c
        ,crapadc a
    WHERE c.cdcooper = a.cdcooper
    AND   c.cdadmcrd = a.cdadmcrd
    AND   c.nrdconta = pr_nrdconta
    AND   c.cdcooper = pr_cdcooper
    AND   c.insitcrd=4 --Em uso
    ORDER BY C.VLLIMCRD DESC; 
    r_busca_dados_cartao_uso c_busca_dados_cartao_uso%ROWTYPE;
                                      
  BEGIN
    
       vr_string := '<subcategoria>'||
                    '<tituloTela>Produto Cart�o de Cr�dito</tituloTela>'||
                    '<campos>';

     /*Busca dados do cart�o solicitado*/
     OPEN c_busca_dados_cartao_cc;
      FETCH c_busca_dados_cartao_cc INTO r_busca_dados_cartao_cc;
       vr_dstipcart := r_busca_dados_cartao_cc.categorianova;
    CLOSE c_busca_dados_cartao_cc;
    
     /*Busca categoria do cart�o anterior (EM USO)*/ 
     OPEN c_busca_dados_cartao_uso (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta);
      FETCH c_busca_dados_cartao_uso INTO r_busca_dados_cartao_uso;
     CLOSE c_busca_dados_cartao_uso;
    
    /*Classifica o tipo do cart�o*/
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
    
    /*Busca limite sugerido do motor*/
    BEGIN
      vr_vllimsgrd := fn_le_json_motor_auto_aprov(p_cdcooper      => pr_cdcooper
                                                 ,p_nrdconta      => pr_nrdconta
                                                 ,p_nrdcontrato   => pr_nrctrato 
                                                 ,p_tagFind       => vr_dstipcart
                                                 ,p_hasDoisPontos => false
                                                 ,p_idCampo       => 0);
      /*Extrai valor num�rico do texto*/
      vr_vllimsgrd := regexp_substr(vr_vllimsgrd,'[[:digit:]].+');
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    
    /*Busca quantidade de cart�o adicional*/
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
      
    OPEN c_historico_credito(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta);
     FETCH c_historico_credito INTO r_historico_credico;                            
    CLOSE c_historico_credito;
     
     vr_string := vr_string || fn_tag('Proposta', gene0002.fn_mask_contrato(pr_nrctrato));
       vr_string := vr_string || fn_tag('Valor de Limite Solicitado',to_char(r_busca_dados_cartao_cc.vllimativo,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Nova Categoria','AILOS '||vr_dstipcart);

       vr_string := vr_string || fn_tag('Quantidade de Cart�o Adicional',vr_qtcartadc);
       vr_string := vr_string || fn_tag('Valor do Limite Sugerido', vr_vllimsgrd);
   
       vr_string := vr_string || fn_tag('Valor do Limite Ativo', to_char(r_busca_dados_cartao_uso.vllimcrd,'999g999g990d00'));
     vr_string := vr_string || fn_tag('Valor do Limite Anterior', to_char(r_historico_credico.vllimite_anterior,'999g999g990d00'));
       vr_string := vr_string || fn_tag('Categoria Anterior',r_busca_dados_cartao_uso.nmresadm);
     vr_string := vr_string || fn_tag('�ltima Data da Altera��o do Limite',to_char(r_historico_credico.dtalteracao,'DD/MM/YYYY'));

    IF (vr_string IS NOT NULL) THEN
      vr_string := vr_string||'</campos></subcategoria>';
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
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_proposta_cc: '||sqlerrm;     
  END;
  
/* Proposta Border� Desconto de T�tulos*/  
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

    Objetivo  : Consulta proposta do border� de desconto de t�tulos

    Alteracoes: Adequa��es na rotina para ler as informa��es de forma correta,
                21/05/2018 - Rafael Monteir (Mouts) 
                
                30/05/2019 - Remover linha Taxa Anual e coluna Convenio.
                             Story 21826 (Sprint 11) - PRJ438 - Gabriel Marcos (Mouts).

                05/06/2019 - Retorno diferente de nulo (nada consta) deve ser considerado
                             como restricao, mesmo que o valor negativado seja igual a zero.
                             Bug 22256 - PRJ438 - Gabriel Marcos (Mouts).

    TODO's: Valor liquido � valor calculado.
  ..............................................................................*/

  /*Proposta do border�*/
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

  /* T�tulos do Border� */
  cursor c_consulta_tits_bordero (pr_nrctrato IN craptdb.nrctrlim%TYPE,
                                  pr_nrborder IN craptdb.nrborder%TYPE) IS
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
        ,(select case when count(1)>0 then 'Sim' else 'N�o' end
         from crapabt r
         where r.cdcooper = t.cdcooper
         and   r.nrdconta = t.nrdconta
         and   r.nrborder = t.nrborder
         and   r.dsrestri is not null) restricoes
        --Informa��es adicionais para buscar a crr�tica
        ,c.nrdctabb
        ,c.cdbandoc
        ,c.nrinssac --cpf/cnpj sem forma��o para buscar o volume carteira
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
                        
  TYPE typ_rec_pagadores IS RECORD
   (nrinssac number);
   
  TYPE typ_tab_pagadores IS TABLE OF typ_rec_pagadores INDEX BY BINARY_INTEGER;

  vr_tab_pagadores typ_tab_pagadores;
  
  

  vr_existe_pagador BOOLEAN;
                        
  --Vari�veis
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
  
  --Percentuais de concentra��o dos titulos do border�
  vr_perc_concentracao VARCHAR2(100);
  vr_perc_liquidez_vl  VARCHAR2(100);
  vr_perc_liquidez_qt  VARCHAR2(100);
  
  --Para calculo do valor l�quido do titulo
  vr_qtd_dias       NUMBER;
  vr_vldjuros       NUMBER; 
  --Para verificar as taxas de acordo com a vers�o do bordero
  vr_rel_txdiaria    NUMBER;
  --vr_rel_txdanual    NUMBER;

  vr_vlliquid_total  craptdb.vlliquid%type := 0;
  --
  vr_tab_dados_biro         TELA_ATENDA_DSCTO_TIT.typ_tab_dados_biro;
  vr_tab_dados_detalhe      TELA_ATENDA_DSCTO_TIT.typ_tab_dados_detalhe;  
  vr_tab_dados_critica      TELA_ATENDA_DSCTO_TIT.typ_tab_dados_critica;
  vr_nrinssac          crapsab.nrinssac%TYPE;
  vr_nmdsacad          crapsab.nmdsacad%TYPE;  
  vr_tem_restricao BOOLEAN;
  vr_contador_restricao NUMBER;
                                         
BEGIN

  vr_string := '<subcategoria>'||
               '<tituloTela>Border� de Desconto de T�tulos</tituloTela>';

  open c_consulta_prop_desc_titulo;
    fetch c_consulta_prop_desc_titulo into r_consulta_prop_desc_titulo;
    if c_consulta_prop_desc_titulo%NOTFOUND then
      null;
    else
      
      -- Se for bordero novo utiliza Juros Simples, sen�o Juros Composto
      if (r_consulta_prop_desc_titulo.flverbor = 1) then
        vr_rel_txdiaria := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) / 30) * 100,7); 
        --vr_rel_txdanual := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) * 12) * 100,6); 
      ELSE
        vr_rel_txdiaria := apli0001.fn_round(((r_consulta_prop_desc_titulo.txmensal / 100) / 30) * 100,7);                    
        --vr_rel_txdanual := apli0001.fn_round((power(1 + (r_consulta_prop_desc_titulo.txmensal / 100), 12) - 1) * 100,6);
      end if;
    
      vr_string := vr_string || '<campos>'||
                           fn_tag('Data da Proposta',to_char(r_consulta_prop_desc_titulo.dtmvtolt,'DD/MM/YYYY'))||
                           fn_tag('Border�',r_consulta_prop_desc_titulo.nrborder)||
                           fn_tag('Contrato',gene0002.fn_mask_contrato(r_consulta_prop_desc_titulo.nrctrlim))||
                           --fn_tag('Taxa Anual',trim(to_char(vr_rel_txdanual,'990d999'))|| '%')||
                           fn_tag('Taxa Mensal',trim(to_char(r_consulta_prop_desc_titulo.txmensal,'990d999'))|| '%')||
                           fn_tag('Taxa Di�ria',trim(to_char(vr_rel_txdiaria,'990d999'))|| '%');
    
   vr_index := 1;
   vr_idx_secundar := 1;
   vr_index2 := 0; --para a tabela de criticas
   
   vr_tab_tabela.delete;
   vr_tab_tabela_secundaria.delete;


   /*Monta cabe�alho da tabela com as cr�ticas dos t�tulos do border�*/
   vr_string_critica := vr_string_critica||'<campo>
                                             <nome>Cr�ticas dos T�tulos</nome>
                                             <tipo>table</tipo>
                                             <valor>
                                             <linhas>';
  vr_contador_restricao := 0;
   --Para cada t�tulo da proposta
  FOR r_titulos in c_consulta_tits_bordero(pr_nrctrato => r_consulta_prop_desc_titulo.nrctrlim,
                                           pr_nrborder => r_consulta_prop_desc_titulo.nrborder) LOOP 

    IF (vr_index = 1) THEN

     /*Monta a tabela com os t�tulos dos border�s*/
     vr_string_aux := vr_string_aux||'<campo>
                                      <nome>T�tulos do Border�</nome>
                                      <tipo>table</tipo>
                                      <valor>
                                      <linhas>';
    END IF;
   
    vr_tab_tabela(vr_index).coluna1 := r_titulos.nrdocmto;
    vr_tab_tabela(vr_index).coluna2 := r_titulos.nrnosnum;
    vr_tab_tabela(vr_index).coluna3 := r_titulos.nmdsacad;
    vr_tab_tabela(vr_index).coluna4 := r_titulos.cpfcgc;
    vr_tab_tabela(vr_index).coluna5 := to_char(r_titulos.dtvencto,'DD/MM/YYYY');
    vr_tab_tabela(vr_index).coluna6 := to_char(r_titulos.vltitulo,'999g999g990d00');
    
    /*Verifica se o valor l�quido do t�tulo � 0, se for calcula*/
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
    --vr_tab_tabela(vr_index).coluna10 := r_titulos.restricoes;
    
    /*Limpa a chave*/
    vr_chave := NULL;
    
    /*Consulta volume carteira a vencer em rela��o ao sacado*/    
    open c_titulos_a_vencer(r_titulos.nrinssac);
      fetch c_titulos_a_vencer into vr_val_venc;
      if c_titulos_a_vencer%found then
        vr_tab_tabela(vr_index).coluna11 := to_char(vr_val_venc,'999g999g990d00');
      else
        vr_tab_tabela(vr_index).coluna11 := 0;
      end if;    
    close c_titulos_a_vencer;    

    TELA_ATENDA_DSCTO_TIT.pc_detalhes_tit_bordero(pr_cdcooper    --> c�digo da cooperativa
                           ,pr_nrdconta          --> n�mero da conta
                           ,r_consulta_prop_desc_titulo.nrborder --> Numero do bordero
                           ,r_titulos.chave              --> lista de 'nosso numero' a ser pesquisado
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
    --IF (nvl(vr_cdcritic, 0) > 0) OR vr_dscritic IS NOT NULL THEN
    --  RAISE vr_exc_erro;
    --END IF;                                  
    
    /*Valida��o para n�o repetir o pagador*/
    vr_existe_pagador := FALSE;
    vr_index_biro := vr_tab_pagadores.first;
    
    WHILE vr_index_biro IS NOT NULL LOOP
      /*Se o pagador j� foi contabilizado, sai do la�o*/
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

      BEGIN
        vr_tem_restricao := FALSE;
        vr_index_biro := vr_tab_dados_biro.first;
        WHILE vr_index_biro IS NOT NULL LOOP  
          IF vr_tab_dados_biro(vr_index_biro).vlnegati IS NOT NULL THEN
            --vr_contador_restricao := vr_contador_restricao + 1;
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
    -- Agora v� se tem cr�ticas
    BEGIN
      
      vr_nrdocmto := vr_nrinssac;
      vr_idx_criticas  := vr_tab_dados_critica.first;
                                                           
      WHILE vr_idx_criticas IS NOT NULL LOOP
          
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna1 := r_titulos.nrnosnum;           
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna2 := vr_tab_dados_critica(vr_idx_criticas).dsc;
        vr_tab_tabela_secundaria(vr_idx_secundar).coluna3 := vr_tab_dados_critica(vr_idx_criticas).vlr; --vlr da cr�tica

        vr_idx_secundar := vr_idx_secundar + 1;
        vr_idx_criticas := vr_tab_dados_critica.next(vr_idx_criticas);
      END LOOP;
      --
      IF (vr_tab_tabela_secundaria.count > 0) THEN
        vr_tab_tabela(vr_index).coluna10 := 'Sim';
      ELSE
        vr_tab_tabela(vr_index).coluna10 := 'N�o';
      END IF;
     
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := SQLERRM;
    END;

   
    BEGIN
      vr_perc_concentracao := vr_tab_dados_detalhe(0).concpaga;
      vr_perc_liquidez_vl  := vr_tab_dados_detalhe(0).liqpagcd;
      vr_perc_liquidez_qt  := vr_tab_dados_detalhe(0).liqgeral;
            
      --se iniciar com v�rgula concatena um 0 a esquerda
      vr_tab_tabela(vr_index).coluna12 := case when substr(vr_perc_concentracao,1,1) = ',' 
                                          then 0 || vr_perc_concentracao || '%'
                                          else      vr_perc_concentracao || '%' end;
      vr_tab_tabela(vr_index).coluna13 := vr_perc_liquidez_vl|| '%';
      vr_tab_tabela(vr_index).coluna14 := vr_perc_liquidez_qt|| '%'; 

    EXCEPTION
      WHEN OTHERS THEN
        vr_tab_tabela(vr_index).coluna12 := '-';
        vr_tab_tabela(vr_index).coluna13 := '-';
        vr_tab_tabela(vr_index).coluna14 := '-';
    END;
    /*Incrementa o �ndice*/
    vr_index := vr_index+1;    
  END LOOP;
  --
  IF vr_tab_tabela_secundaria.count > 0 THEN
    vr_string_critica := vr_string_critica || fn_tag_table('Nosso N�mero;
                                                            Cr�tica;
                                                            Valor',vr_tab_tabela_secundaria);    
  ELSE
    vr_tab_tabela_secundaria(1).coluna1 := '-';
    vr_tab_tabela_secundaria(1).coluna2 := '-';
    vr_tab_tabela_secundaria(1).coluna3 := '-';
    vr_string_critica := vr_string_critica || fn_tag_table('Nosso N�mero;
                                                            Cr�tica;
                                                            Valor',
                                                            vr_tab_tabela_secundaria);

      
  END IF;        
  vr_string_critica := vr_string_critica||'</linhas></valor></campo>';
  vr_string_critica := vr_string_critica||'</campos>';  
  --
   /*Monta a tabela dos titulos*/
   IF vr_tab_tabela.COUNT > 0 THEN
     /*Gera Tags Xml*/
     vr_string_aux := vr_string_aux||fn_tag_table('Boleto N�mero;
                                                   Nosso N�mero;
                                                   Nome Pagador;
                                                   CPF/CNPJ do Pagador;
                                                   Data de Vencimento;
                                                   Valor do T�tulo;
                                                   Valor L�quido;
                                                   Prazo;
                                                   Restri��es;
                                                   Cr�ticas;
                                                   Volume Carteira a Vencer;
                                                   % Concentra��o por Pagador;
                                                   % Liquidez do Pagador com a Cedente;
                                                   % Liquidez Geral',
                                                   vr_tab_tabela);
     vr_string_aux := vr_string_aux||'</linhas></valor></campo>';
   ELSE
     vr_tab_tabela(1).coluna1  := '-'; -- Boleto N�mero
     vr_tab_tabela(1).coluna2  := '-'; -- Nosso N�mero
     vr_tab_tabela(1).coluna3  := '-'; -- Nome Pagador
     vr_tab_tabela(1).coluna4  := '-'; -- CPF/CNPJ do Pagador
     vr_tab_tabela(1).coluna5  := '-'; -- Data de Vencimento
     vr_tab_tabela(1).coluna6  := '-'; -- Valor do T�tulo
     vr_tab_tabela(1).coluna7  := '-'; -- Valor L�quido
     vr_tab_tabela(1).coluna8  := '-'; -- Prazo
     vr_tab_tabela(1).coluna9  := '-'; -- Restri��es
     vr_tab_tabela(1).coluna10 := '-'; -- Cr�ticas
     vr_tab_tabela(1).coluna11 := '-'; -- Volume Carteira a Vencer
     vr_tab_tabela(1).coluna12 := '-'; -- % Concentra��o por Pagador
     vr_tab_tabela(1).coluna13 := '-'; -- % Liquidez do Pagador com a Cedente
     vr_tab_tabela(1).coluna14 := '-'; -- % Liquidez Geral

     vr_string_aux := vr_string_aux||fn_tag_table('Boleto N�mero;
                                                   Nosso N�mero;
                                                   Nome Pagador;
                                                   CPF/CNPJ do Pagador;
                                                   Data de Vencimento;
                                                   Valor do T�tulo;
                                                   Valor L�quido;
                                                   Prazo;
                                                   Restri��es;
                                                   Cr�ticas;
                                                   Volume Carteira a Vencer;
                                                   % Concentra��o por Pagador;
                                                   % Liquidez do Pagador com a Cedente;
                                                   % Liquidez Geral',
                                                   vr_tab_tabela);
     vr_string_aux := vr_string_aux||'</linhas></valor></campo>';
   END IF;



  END IF;
    
  CLOSE c_consulta_prop_desc_titulo;
  
  vr_string := vr_string ||fn_tag('Quantidade de T�tulos',r_consulta_prop_desc_titulo.qtdtitulos)||
                           fn_tag('Valor',TO_CHAR(r_consulta_prop_desc_titulo.vltitulo,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor L�quido',TO_CHAR(vr_vlliquid_total,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Valor M�dio',TO_CHAR(r_consulta_prop_desc_titulo.vlmedio,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''))||
                           fn_tag('Restri��es',vr_contador_restricao);

  vr_string := vr_string || vr_string_aux;
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
      
      -- Resetar a variavel
      vr_garantia := '-';
      vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,r_proposta_out_epr.nrctremp,r_proposta_out_epr.nrctaav1,r_proposta_out_epr.nrctaav2,'P',c_emprestimo); 
      
      vr_tab_tabela(vr_index).coluna1  := to_char(r_proposta_out_epr.dtproposta,'DD/MM/YYYY');
      vr_tab_tabela(vr_index).coluna2  := gene0002.fn_mask_contrato(r_proposta_out_epr.contrato);
      vr_tab_tabela(vr_index).coluna3  := trim(to_char(r_proposta_out_epr.valor_emprestimo,'999g999g990d00'));
      vr_tab_tabela(vr_index).coluna4  := to_char(r_proposta_out_epr.valor_prestacoes,'999g999g990d00');    
      vr_tab_tabela(vr_index).coluna5  := r_proposta_out_epr.qtd_parcelas;         
      vr_tab_tabela(vr_index).coluna6  := r_proposta_out_epr.linha;     
      vr_tab_tabela(vr_index).coluna7  := r_proposta_out_epr.finalidade;
      vr_tab_tabela(vr_index).coluna8  := r_proposta_out_epr.contratos;
      vr_tab_tabela(vr_index).coluna9  := vr_garantia;
      vr_tab_tabela(vr_index).coluna10 := r_proposta_out_epr.decisao;
      vr_tab_tabela(vr_index).coluna11 := CASE WHEN r_proposta_out_epr.situacao IS NOT NULL THEN
                                          r_proposta_out_epr.situacao ELSE '-' END;
      
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
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Presta��es;Quantidade de Parcelas;Linha de Cr�dito;Finalidade;Liquidar;Garantia;Situa��o;Decis�o',vr_tab_tabela);
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
      vr_string_outros_epr := vr_string_outros_epr||fn_tag_table('Data;Contrato;Valor;Valor das Presta��es;Quantidade de Parcelas;Linha de Cr�dito;Finalidade;Liquidar;Garantia;Situa��o;Decis�o',vr_tab_tabela);
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
                                 ,pr_persona  IN VARCHAR2
                                 ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica
                                 ,pr_dsxmlret OUT CLOB) is

                   
    /* .............................................................................
    Programa: pc_consulta_consultas
    Sistema : Aimaro/Ibratan
    Autor   : Bruno Luiz Katzjarowski - Mout's 
    Data    : Mar�o/2019                 Ultima atualizacao: 30/05/2019
    
    Alteracoes: 03/06/2019 - Adicionado logica para apresentar data de consulta do
                             motor para produto cartoes e empretimos. Demais caem na
                             regra ja existente do orgao de protecao de credito.
                             Story 21252 - Sprint 11 - Gabriel Marcos (Mouts).
                             
                04/06/2019 - Alterado nome Valor do Adiantamento para Valor de 
                             Adiantamento � Depositantes.
                             Bug 22214 - PRJ438 - Gabriel Marcos (Mouts).
                             
                04/06/2019 - Alterado nome Lista de Participacao para Lista de 
                             Controle Societ�rio.
                             Story 22208 - Sprint 11 - Gabriel Marcos (Mouts).
                             
  ..............................................................................*/                               

   /* Verifica se a conta j� teve prejuizo */
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
             a.dtfimest IS NULL; -- Is null -> N�o regularizado
   rw_chequesdevolvidos cr_chequesdevolvidos%rowtype;
   
   -- Quantidade de cheques devolvidos Linhas: 11 12 13 (Aimaro --> Atenda --> Ocorrencias, tab principal -> Campo "Devolvu��es"
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
                     a.dtiniest >= (select trunc(add_months(c.dtmvtolt, -5),'MM') dtOld from crapdat c where c.cdcooper = a.cdcooper) and
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
    
    /*Escore quando n�o Proponente*/
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

    /*Busca Score Comportamental dos �ltimos 6 Meses*/
    CURSOR cr_tbcrd_score(pr_cdcooper      crapcop.cdcooper%TYPE
                         ,pr_inpessoa      crapass.inpessoa%TYPE
                         ,pr_nrdconta      crapass.nrdconta%TYPE) IS
      SELECT sco.cdmodelo
            ,csc.dsmodelo
            ,to_char(sco.dtbase,'dd/mm/rrrr') dtbase
            ,sco.nrscore_alinhado
            ,sco.dsclasse_score
            ,nvl(sco.dsexclusao_principal,'-') dsexclusao_principal
            ,decode(sco.flvigente,1,'Vigente','N�o vigente') dsvigente
            ,row_number() over (partition By sco.cdmodelo
                                    order by sco.flvigente DESC, sco.dtbase DESC) nrseqreg
        FROM tbcrd_score sco
            ,tbcrd_carga_score csc
            ,crapass ass
       WHERE csc.cdmodelo      = sco.cdmodelo
         AND csc.dtbase        = sco.dtbase
         AND ass.cdcooper      = sco.cdcooper
         AND ass.nrcpfcnpj_base  = sco.nrcpfcnpjbase
         AND sco.cdcooper      = pr_cdcooper
         AND sco.tppessoa      = pr_inpessoa
         AND ass.nrdconta      = pr_nrdconta
         AND sco.dtbase >=     TRUNC( add_months(rw_crapdat.dtmvtolt,-6),'MM') 
       ORDER BY sco.flvigente DESC
               ,sco.dtbase DESC;                         
                         
    rw_score cr_tbcrd_score%ROWTYPE;  
    
   /*Busca data da consulta do bir�*/
   CURSOR c_busca_data_cons_biro (pr_nrconbir IN craprsc.nrconbir%TYPE
                              ,pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
    SELECT MAX(NVL(c.dtreapro,c.dtconbir)) dtconbir
    FROM crapcbd c
    WHERE c.nrconbir = pr_nrconbir
    AND   c.nrseqdet = pr_nrseqdet;
   vr_dt_cons_biro DATE;

    /*Busca data da consulta no bir� e se tem cr�tica para persona diferente de Proponente*/
    CURSOR c_busca_restri (pr_nrconbir IN craprsc.nrconbir%TYPE
                              ,pr_nrseqdet IN craprsc.nrseqdet%TYPE) IS
      SELECT NVL(c.dtreapro,c.dtconbir) dtconbir
            ,p.qtnegati qtnegati
      FROM crapcbd c
--          ,craprsc r
          ,craprpf p
      WHERE 1=1
      --AND c.nrconbir = r.nrconbir
      --AND   c.nrseqdet = r.nrseqdet 
      AND   c.nrconbir = p.nrconbir 
      AND   c.nrseqdet = p.nrseqdet
      AND   c.nrconbir = pr_nrconbir
      --AND   c.nrseqdet = pr_nrseqdet
      ORDER BY 1 DESC;
      r_busca_restri c_busca_restri%ROWTYPE;
      
   /* Lista de participa��o */
   CURSOR c_busca_participacao (pr_nrconbir crapcbd.nrconbir%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE) IS
     SELECT distinct c.nrcpfcgc --Documento
            ,nmtitcon   --Nome / Raz�o Social
            ,c.dtentsoc --Data de In�cio
            ,to_char(c.percapvt,'990D99') percapvt --Percentual do Capital Votante
            ,to_char(c.pertotal,'990D99') pertotal --Percentual de Participa��o
     FROM crapcbd c
          ,crapass a
           ,crapavt s
      WHERE a.cdcooper = 1
     AND  a.cdcooper = c.cdcooper
       AND  c.cdcooper = s.cdcooper
     AND a.nrcpfcgc = c.nrcpfcgc 
     AND c.nrconbir = pr_nrconbir --Bir� consultado
       AND  c.intippes in (4,5)
       AND  s.tpctrato = 6 /*procurad*/ 
       AND  s.nrdconta = pr_nrdconta  
       AND  s.nrcpfcgc = c.nrcpfcgc 
       AND  s.nrctremp = 0
       AND  s.persocio > 0; 
   r_busca_participacao c_busca_participacao%ROWTYPE;
    
   /*Lista de anota��es negativas - �rg�o de Prote��o ao Cr�dito*/
   CURSOR c_busca_orgao_prot_cred (pr_nrconbir craprpf.nrconbir%TYPE
                                  ,pr_nrseqdet craprpf.nrseqdet%TYPE) IS
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
                   'D�vida Vencida' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
              FROM craprpf
             WHERE craprpf.nrconbir = pr_nrconbir
               AND craprpf.nrseqdet = pr_nrseqdet
               AND craprpf.innegati = 10
            UNION ALL
            SELECT 11,
                   'Inadimpl�ncia' dsnegati,
                   MAX(craprpf.qtnegati),
                   MAX(craprpf.vlnegati),
                   MAX(craprpf.dtultneg)
              FROM craprpf
             WHERE craprpf.nrconbir = pr_nrconbir
               AND craprpf.nrseqdet = pr_nrseqdet
               AND craprpf.innegati = 11)
            Order by to_number(1) desc;
   r_busca_orgao_prot_cred c_busca_orgao_prot_cred%ROWTYPE;                               

  /*Pefin(1), Refin(2), D�vida Vencida no SPC e Serasa (3)*/
  CURSOR c_busca_pefin_refin (pr_nrconbir crapprf.nrconbir%TYPE
                             ,pr_nrseqdet crapprf.nrseqdet%TYPE
                             ,pr_inpefref NUMBER) IS
    SELECT to_char(dtvencto,'DD/MM/YYYY') data
          ,dsmtvreg modalidade
          ,to_char(vlregist,'999g999g990d00') valor
          ,dsinstit origem  
     FROM crapprf r
     WHERE nrconbir = pr_nrconbir
       AND nrseqdet = pr_nrseqdet
       AND NVL(inpefref,0) = NVL(pr_inpefref,0) --Pefin 1, Refin 2, 3 Divida Vencida, 0 Pefin e Refin PJ
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
   AND   nrseqdet = pr_nrseqdet;
  r_busca_protestos c_busca_protestos%ROWTYPE;
    
  /*Consulta A��es*/
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
   AND   nrseqdet = pr_nrseqdet;
  r_busca_acoes c_busca_acoes%ROWTYPE;
  
  /*Consulta Recupera��es, Fal�ncias, Concordata*/
  CURSOR c_busca_craprpf (pr_nrconbir crapprf.nrconbir%TYPE
                         ,pr_nrseqdet crapprf.nrseqdet%TYPE) IS
    SELECT dtultneg data
          ,vlnegati valor
    FROM craprpf
   WHERE nrconbir = pr_nrconbir
   AND   nrseqdet = pr_nrseqdet
   AND   innegati = 5;
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
   AND   cdcooper = pr_cdcooper;
   vr_dtdscore DATE; --data o score boa vista

 
   vr_string_operacoes CLOB;  --XML de retorno
   vr_index number;   --Index
   v_haspreju varchar2(10); -- Retorno teve preju
   
   v_rtReadJson        VARCHAR2(1000) := NULL;
   v_somaValores       NUMBER;
   v_count             NUMBER;
   v_ehnumero NUMBER;
   vr_dtconsspc        DATE;
   vr_dssitdct         VARCHAR2(20);
   vr_dsrestricao      VARCHAR2(30);
   vr_inicio           NUMBER; --temp
   vr_temrestri         NUMBER:=0;
  
  /*Busca o score da crapass quando n�o for proponente*/
  FUNCTION fn_busca_score(pr_cdcooper crapcop.cdcooper%TYPE
                         ,pr_nrdconta crapass.nrdconta%TYPE) RETURN VARCHAR2 IS
   vr_retorno crapass.dsdscore%TYPE;
  BEGIN
    SELECT dsdscore
    INTO vr_retorno
    FROM crapass
    WHERE cdcooper = pr_cdcooper
    AND   nrdconta = pr_nrdconta;
    
    return vr_retorno;
  EXCEPTION
    WHEN OTHERS THEN
    return '-';
  END ;

  BEGIN
  
  --Buscar biro de consulta (PROCEDURE_LOCAL) correto que cont�m as qtds
  pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta,
                         pr_nrconbir => vr_nrconbir,
                         pr_nrseqdet => vr_nrseqdet);
  
  /*Informa��es Cadastrais*/
  --Abertura da tag de Subcategoria -> Informa��es Cadastrais
  vr_string_operacoes := '<subcategoria>'||
                           '<tituloTela>Informa��es Cadastrais</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>informacoes_cadastrais</tituloFiltro>'|| -- ID da subcategoria
                           '<campos>'; -- Abertura da tag de campos da subcategoria  
 
  
  /* Quando o Proponente tiver Empr�stimo ou Desc. T�tulo */
  IF (pr_persona = 'Proponente') AND vr_tpproduto_principal in (c_emprestimo,c_limite_desc_titulo) then

      /*CONSULTA JSON --> Para empr�stimo ou desconto de t�tulo busca express�o no motor*/
      v_rtReadJson := fn_le_json_motor_regex(p_cdcooper => pr_cdcooper,
                                             p_nrdconta => pr_nrdconta,
                                             p_nrdcontrato => pr_nrcontrato, 
                                             p_tagFind => '(proponente).+(possui).+(restri)', --Palavras com �|� substituir por ? o caracter
                                             p_hasDoisPontos =>  false,
                                             p_idCampo => 0);
                                             
      -- Busca data de consulta (motor) para ver se tem restri��o
      open cr_dtconsulta (pr_cdcooper
                         ,pr_nrdconta
                         ,pr_nrcontrato);
      fetch cr_dtconsulta into rw_dtconsulta;
      close cr_dtconsulta;

      --Sem Restri��o
      IF nvl(v_rtReadJson,'-') = '-' THEN
        vr_string_operacoes := vr_string_operacoes||
                               fn_tag('Situa��o','Sem Restri��o.'||' Consulta em: '||
                               case when rw_dtconsulta.dhacionamento is not null 
                                    then to_char(rw_dtconsulta.dhacionamento,'DD/MM/YYYY')
                                    else 'SEM CONSULTA' end);
      ELSE
      --Com Restri��o
        vr_temrestri :=1;
        vr_string_operacoes := vr_string_operacoes||
                               fn_tag('Situa��o','Com Restri��o.'||' Consulta em: '||
                               case when rw_dtconsulta.dhacionamento is not null 
                                    then to_char(rw_dtconsulta.dhacionamento,'DD/MM/YYYY')
                                    else 'SEM CONSULTA' end);
      END if;

    /* OUTRAS PERSONAS, busca consultando o registro do hist�rico */
    else
       /*Verifica quando foi a �ltima consulta na CONSCR*/
       OPEN c_busca_data_cons_biro (pr_nrconbir => vr_nrconbir
                               ,pr_nrseqdet => vr_nrseqdet);
        FETCH c_busca_data_cons_biro INTO vr_dt_cons_biro;
       CLOSE c_busca_data_cons_biro;       
       
       OPEN c_busca_restri (pr_nrconbir => vr_nrconbir
                           ,pr_nrseqdet => vr_nrseqdet);

        FETCH c_busca_restri INTO r_busca_restri;

        IF c_busca_restri%FOUND THEN
          
            IF (r_busca_restri.qtnegati > 0 ) THEN
              vr_temrestri := 1;--tem restri��o
              vr_dsrestricao := 'Com Restri��o.';
            ELSE
              vr_dsrestricao := 'Sem Restri��o.';
            END IF;
          
          vr_string_operacoes := vr_string_operacoes||
                              fn_tag('Situa��o',vr_dsrestricao||' Consulta em: '||
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
                              fn_tag('Situa��o','Sem Restri��o'||' Consulta em: '||
                              case when vr_dt_cons_biro is not null --data consulta boa vista
                                then to_char(vr_dt_cons_biro,'DD/MM/YYYY')
                              else 'SEM CONSULTA' end);  
        END IF;

       CLOSE c_busca_restri;

    END IF;
  
    --Se tem restri��o, monta a tabela do resumo
    if (vr_temrestri = 1 ) then
      
      /*RESUMO ANOTA��ES NEGATIVAS - Consulta ao �rg�os de Prote��o ao Cr�dito*/
      vr_string_operacoes := vr_string_operacoes||'<campo>
                                                    <nome>Resumo Anota��es Negativas</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
      /*PJ tem: Pefin, Protesto, Refin, A��es, Recupera��es, D�vida Vencida
        PF tem: SPC, Pefin, Protesto, Refin, A��es, D�vida Vencida */
  
       vr_index := 1;
       vr_tab_tabela.delete;
       FOR r_craprpf IN c_busca_orgao_prot_cred(pr_nrconbir => vr_nrconbir, pr_nrseqdet => vr_nrseqdet) LOOP
        
        IF (pr_inpessoa = 2 AND r_craprpf.dsnegati IN ('SPC','SERASA')) THEN
          CONTINUE;
        END IF;
       
        IF (pr_inpessoa = 1) AND r_craprpf.dsnegati IN ('Participa��o fal�ncia','SERASA') THEN
          CONTINUE;
        END IF;
     
        vr_tab_tabela(vr_index).coluna1 := r_craprpf.dsnegati; --Anota��es
        vr_tab_tabela(vr_index).coluna2 := r_craprpf.qtnegati; --Quantidade
        vr_tab_tabela(vr_index).coluna3 := case when r_craprpf.vlnegati IS NOT NULL
                                           then to_char(r_craprpf.vlnegati,'999g999g990d00') else '-' end; --Valor
        vr_tab_tabela(vr_index).coluna4 := case when r_craprpf.dtultneg IS NOT NULL
                                           then to_char(r_craprpf.dtultneg,'DD/MM/YYYY') else '-' end; --Data �ltima
        vr_index := vr_index+1;
       end loop;
	
    if vr_tab_tabela.COUNT > 0 then
      /*Gera Tags Xml*/
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Anota��es;Quantidade;Valor;Data �ltima',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Anota��es;Quantidade;Valor;Data �ltima',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  

   /*Registro SPC - Somente para PF*/
   IF (pr_inpessoa = 1) THEN
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
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Tipo;Institui��o;Cidade;UF;Registro;Vencimento;Valor;Motivo',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-'; 
      vr_tab_tabela(1).coluna7 := '-'; 
      vr_tab_tabela(1).coluna8 := '-';     
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Tipo;Institui��o;Cidade;UF;Registro;Vencimento;Valor;Motivo',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  
   END IF;

   /*PEFIN - DETALHE*/

   /*OBS: PJ tem Pefin e Refin separados. 
     PF tem os dois juntos e o valor de INPEFREF � null*/
   IF (pr_inpessoa = 1) THEN
     vr_string_operacoes := vr_string_operacoes||'<campo>
                                                    <nome>PEFIN e REFIN- (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
   ELSE
     vr_string_operacoes := vr_string_operacoes||'<campo>
                                                    <nome>PEFIN - (Ocorr�ncias mais recentes - at� cinco)</nome>
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
        vr_index := vr_index+1;
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
    vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Modalidade;Valor;Origem',vr_tab_tabela);
  ELSE
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
  END IF;

  vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                </valor>
                                                </campo>';                                                  

 /*PROTESTOS*/
  vr_string_operacoes := vr_string_operacoes||'<campo>
                                                <nome>PROTESTO - (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
  vr_index := 0;
  vr_tab_tabela.delete;
     
  OPEN c_busca_protestos(pr_nrconbir => vr_nrconbir
                         ,pr_nrseqdet => vr_nrseqdet);
  LOOP                       
    FETCH c_busca_protestos INTO r_busca_protestos;
    EXIT WHEN vr_index = 5;     
    IF c_busca_protestos%FOUND THEN
      vr_index := vr_index+1;
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
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Valor;Cidade;UF',vr_tab_tabela);
    else
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  
   
   /*REFIN - DETALHE - Apenas para o PJ. PF j� carregou junto com o PEFIN*/
   IF (pr_inpessoa = 2) THEN
     vr_index := 0;
     vr_tab_tabela.delete;
     
      vr_string_operacoes := vr_string_operacoes||'<campo>
                                                    <nome>REFIN - (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                    <tipo>table</tipo>
                                                    <valor>
                                                    <linhas>';
       vr_index := 0;
       vr_tab_tabela.delete;
       
       OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                               ,pr_nrseqdet => vr_nrseqdet
                               ,pr_inpefref => 2); -- REFIN
        LOOP
        FETCH c_busca_pefin_refin INTO r_busca_pefin_refin;
        
          EXIT WHEN VR_INDEX > 5;
          IF c_busca_pefin_refin%FOUND THEN
            vr_index := vr_index+1;
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
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Modalidade;Valor;Origem',vr_tab_tabela);
      else
        --vr_tab_tabela(1).coluna1 := '-';
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
      end if;

     vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                    </valor>
                                                    </campo>';                                                  
   END IF;
  
   /*A��ES - Para PF e PJ*/
    vr_string_operacoes := vr_string_operacoes||'<campo>
                                                  <nome>A��ES - (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
     vr_index := 0;
     vr_tab_tabela.delete;
     
     OPEN c_busca_acoes(pr_nrconbir => vr_nrconbir
                       ,pr_nrseqdet => vr_nrseqdet);
      LOOP                       
        FETCH c_busca_acoes INTO r_busca_acoes;
        EXIT WHEN vr_index = 5;     
        IF c_busca_acoes%FOUND THEN
          vr_index := vr_index+1;
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
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  
  
  /*DIVIDA VENCIDA - DETALHE*/
   vr_string_operacoes := vr_string_operacoes||'<campo>
                                                 <nome>D�VIDA VENCIDA - (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                 <tipo>table</tipo>
                                                 <valor>
                                                 <linhas>';
    vr_index := 0;
    vr_tab_tabela.delete;
     
    OPEN c_busca_pefin_refin(pr_nrconbir => vr_nrconbir
                            ,pr_nrseqdet => vr_nrseqdet
                            ,pr_inpefref => 3); -- DIVIDA VENCIDA
     LOOP                       
       FETCH c_busca_pefin_refin INTO r_busca_pefin_refin;
       EXIT WHEN vr_index = 5;     
       IF c_busca_pefin_refin%FOUND THEN
         vr_index := vr_index+1;
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
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Valor;Origem',vr_tab_tabela);
    else
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  

   /*RECUPERA��ES, FAL�NCIA E CONCORDATA - apenas para PJ*/
   IF (pr_inpessoa = 2) THEN
     vr_string_operacoes := vr_string_operacoes||'<campo>
                                                  <nome>RECUPERA��ES, FAL�NCIA E CONCORDATA - (Ocorr�ncias mais recentes - at� cinco)</nome>
                                                  <tipo>table</tipo>
                                                  <valor>
                                                  <linhas>';
     vr_index := 0;
     vr_tab_tabela.delete;
     
     OPEN c_busca_craprpf(pr_nrconbir => vr_nrconbir
                         ,pr_nrseqdet => vr_nrseqdet);
      LOOP                       
        FETCH c_busca_craprpf INTO r_busca_craprpf;
        EXIT WHEN vr_index = 5;     
        IF c_busca_craprpf%FOUND THEN
          vr_index := vr_index+1;
          vr_tab_tabela(vr_index).coluna1 := r_busca_craprpf.data;
          vr_tab_tabela(vr_index).coluna2 := r_busca_craprpf.valor;
        ELSE
          EXIT;
        END IF;
      END LOOP;
      
     CLOSE c_busca_craprpf;

      if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('Data;Valor',vr_tab_tabela);
      else
        vr_string_operacoes := vr_string_operacoes||fn_tag_table('NADA CONSTA',vr_tab_tabela);
      end if;

     vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';                                                  
   END IF;

  /*BUSCA_JSON -> Patrim�nio Pessoal Livre e Percep��o Geral Empresa somente para Proponente*/
  IF (pr_persona = 'Proponente') THEN
    
    --Patrim�nio Pessoal Livre
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
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrim�nio Pessoal Livre',
                  v_rtReadJson);
    END; 
    IF v_ehnumero IS NOT NULL THEN
      -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
      FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                    3,
                                    9,
                                    v_ehnumero) LOOP                                            
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Patrim�nio Pessoal Livre',
                     v_rtReadJson || ' - '||rw_craprad.dsseqite);   
      END LOOP;
    END IF;  
  
    IF r_pessoa.inpessoa IN (2,3) THEN -- Jur�dica
      --Percepcao geral da empresa
      v_rtReadJson := fn_le_json_motor(p_cdcooper => pr_cdcooper,
                                       p_nrdconta => pr_nrdconta,
                                       p_nrdcontrato => pr_nrcontrato, 
                                       p_tagFind => 'percepcaoGeralEmpresa', --Palavras com �|� substituir por ? o caracter
                                       p_hasDoisPontos =>  true,
                                       p_idCampo => 0);
      v_ehnumero := NULL;
      BEGIN
        v_ehnumero := to_number(v_rtReadJson);     
      EXCEPTION
        WHEN OTHERS THEN
         v_ehnumero := NULL;
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Percep��o Geral da Empresa',
                    v_rtReadJson);
      END;
      IF v_ehnumero IS NOT NULL THEN
        -- Codigos obtidos da rotina b1wgen0048 - tela contas inf. adicionais
        FOR rw_craprad IN cr_craprad (pr_cdcooper,
                                      3,
                                      11,
                                      v_ehnumero) LOOP
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Percep��o Geral da Empresa',
                              v_rtReadJson|| ' - ' || rw_craprad.dsseqite);
        END LOOP;
      END IF;
                                 
      END IF;
   END IF;   

  /*Fim da Subcategoria de RESUMO DE ANOTA��ES NEGATIVAS*/
  END IF; --Fim da tabela do Resumo de Anota��es  
  vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';
   
  
  /*Ocorr�ncias*/
  vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                           '<tituloTela>Ocorr�ncias</tituloTela>'|| -- Titulo da subcategoira
                           '<tituloFiltro>ocorrencias</tituloFiltro>'|| -- ID da subcategoria
                           '<campos>'; 
                            
  --Montar Valores Somente com conta estourada na data                          
  open c_ad(pr_cdcooper,rw_crapdat.dtmvtoan,pr_nrdconta);
   fetch c_ad into r_ad;
    if r_ad.adiantamento_depositante > 0 then
  --Qtd de Adiantamento a Depositantes:
  open cr_ultimoEstouro;
     fetch cr_ultimoEstouro into rw_ultimoEstouro;
     --vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Adiantamento a Depositantes',rw_ultimoEstouro.Qtdiaest);
  close cr_ultimoEstouro;     
 
   --Valor do Estouro:
   vr_string_operacoes := vr_string_operacoes
                       ||tela_analise_credito.fn_tag('Valor de Adiantamento � Depositantes',TO_CHAR(rw_ultimoEstouro.Vlestour,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));  
    else                           
       vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Valor de Adiantamento','-');   
    end if;
  --CL:
  open c_dias_estouros;
   fetch c_dias_estouros into r_dias_estouros;  
  -- Cr�dito L�quido/(dd) - BUG 20967
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('CL',nvl(r_dias_estouros.qtdriclq,0)||' (dd) '||nvl(to_char(r_dias_estouros.dtdsdclq,'dd/mm/rrrr'),'-'));
  --Quantidade de Estouros:

    vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Quantidade de Estouros',nvl(r_dias_estouros.qtddtdev,0));
  close c_dias_estouros; 


  close c_ad; 
                            
                         
  --Mostrar a M�dia de Estouros dos �ltimos 6 meses
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
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('M�dia de Estouros dos �ltimos 6 meses',
                                                                            to_char(TRUNC(v_somaValores,2)));       
  --A�conta j� causou preju�zo na cooperativa:
   open cr_prejuizo(pr_cdcooper,pr_nrdconta);
   fetch cr_prejuizo into rw_prejuizo;
   if cr_prejuizo%found then
     v_haspreju := 'Sim';
   else
     v_haspreju := 'N�o';
   end if;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('A conta j� causou prejuizo na cooperativa',v_haspreju);                                         
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
   
    --Valor Total a Regularizar no CCF�
   open cr_totalccf(pr_cdcooper, pr_nrdconta);
   fetch cr_totalccf into rw_totalccf;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Valor total a Regularizar no CCF',TO_CHAR(rw_totalccf.vltotalestouro,'fm9g999g999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.'''));
   close cr_totalccf;
   --Data da �ltima Devolu��o:�
   open cr_dtultimadevolu(pr_cdcooper, pr_nrdconta);
   fetch cr_dtultimadevolu into rw_dtultimadevolu;
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Data da �ltima Devolu��o',rw_dtultimadevolu.dtultimadevolu);
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
   
   /*bug 21588 - Quando n�o for proponente, busca do Contas>Org. Prote��o ao Cr�dito*/
   IF (pr_persona <> 'Proponente') then
     v_rtReadJson := fn_busca_score (pr_cdcooper => pr_cdcooper,
                                     pr_nrdconta => pr_nrdconta);
   ELSE
      /*Busca do JSON apenas quando n�o for cart�o de cr�dito, sen�o tamb�m busca local*/
      IF (vr_tpproduto_principal <> c_cartao) THEN
        v_rtReadJson := fn_le_json_motor_regex(p_cdcooper => pr_cdcooper,
                                         p_nrdconta => pr_nrdconta,
                                         p_nrdcontrato => pr_nrcontrato, 
                                               p_tagFind => '(proponente).+(bvs).+(score)', --Palavras com �|� substituir por ? o caracter
                                               p_hasDoisPontos =>  false,
                                         p_idCampo => 0);
       /*Para o Score, fatia o texto iniciando ap�s o �ltimo : de tras para frente*/
       vr_inicio := INSTR(v_rtReadJson, ':', -1);
       v_rtReadJson := SUBSTR(v_rtReadJson,vr_inicio);
       
       /*Remove os caracteres inv�lidos \u00BF do JSON*/
       v_rtReadJson := REPLACE(v_rtReadJson,'\u00BF','');
       
       /*Tratamento para o Score quando falta o caractere � (BAIX�SSIMO, ALT�SSIMO)*/
       IF (v_rtReadJson like ('%ALTSSIMO%') or v_rtReadJson like '%BAIXSSIMO%') THEN
       v_rtReadJson := REPLACE(v_rtReadJson,'SSIMO','�SSIMO');     
       END IF;
     
      ELSE
        v_rtReadJson := fn_busca_score (pr_cdcooper => pr_cdcooper,
                                        pr_nrdconta => pr_nrdconta);
      END IF;                                     
                                       
   END IF;                                       
   vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Score',v_rtReadJson);   
   
   --Buscar biro de consulta
     pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrconbir => vr_nrconbir,
                            pr_nrseqdet => vr_nrseqdet);
   
   --Pontua��o BVS:
   if (pr_persona = 'Proponente') then
     open c_crapesc(vr_nrconbir, pr_inpessoa);
      fetch c_crapesc into r_crapesc;
       if c_crapesc%found then
        vr_string_operacoes := vr_string_operacoes||
                            tela_analise_credito.fn_tag('Pontua��o',to_char(r_crapesc.vlpontua,'999g999g990d0'));   
       else
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Pontua��o','-');   
       end if;
     close c_crapesc;
   --Pontua��o Serasa para demais
   else
     open c_busca_escore_local (pr_cdcooper => pr_cdcooper
                               ,pr_nrconbir => vr_nrconbir
                               ,pr_nrcpfcgc => pr_nrcpfcgc
                               ,pr_nrseqdet => vr_nrseqdet);
      FETCH c_busca_escore_local INTO r_busca_escore_local;
      
      if c_busca_escore_local%FOUND THEN
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Pontua��o',r_busca_escore_local.vlpontua);
      ELSE
        vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('Pontua��o','-');
      END IF;
      
     close c_busca_escore_local;  
   end if;
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';   
      
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
   
   --N�vel de Risco - APENAS PARA O PROPONENTE
   if (pr_persona = 'Proponente') then
     if vr_tpproduto_principal = c_emprestimo then
       open c_proposta_epr(pr_cdcooper,pr_nrdconta,vr_nrctrato_principal);
        fetch c_proposta_epr into r_proposta_epr;
          vr_string_operacoes := vr_string_operacoes||tela_analise_credito.fn_tag('N�vel de Risco',r_proposta_epr.dsnivris);
       close c_proposta_epr;
     end if;
   end if;
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';*/
  
  /*Score Interno*/
  
  --Score Comportamental�
  
  --Ser� apresentado os �ltimos 6 meses
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Score Comportamental</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>score_comportamental</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria
   
   vr_string_operacoes := vr_string_operacoes||'<campo>
                                                <nome>Score Comportamental dos �ltimos 6 meses</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
   vr_index := 1;
   vr_tab_tabela.delete;
   for rw_score in cr_tbcrd_score(pr_cdcooper,pr_inpessoa,pr_nrdconta) loop
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
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Modelo;Data;Classe;Pontua��o;Exclus�o Principal;Situa��o',vr_tab_tabela);
    else
      vr_tab_tabela(1).coluna1 := '-';
      vr_tab_tabela(1).coluna2 := '-';
      vr_tab_tabela(1).coluna3 := '-';
      vr_tab_tabela(1).coluna4 := '-';
      vr_tab_tabela(1).coluna5 := '-';
      vr_tab_tabela(1).coluna6 := '-';                        
      vr_string_operacoes := vr_string_operacoes||fn_tag_table('Modelo;Data;Classe;Pontua��o;Exclus�o Principal;Situa��o',vr_tab_tabela);
    end if;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';  
   
   
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';                                                  

  /*Lista de participa��o para PJ - BUG 21396*/
  IF (pr_inpessoa = 2 and (pr_persona = 'Proponente' or
                           pr_persona like '%Avalista%')) THEN
    
  --Ser� apresentado os �ltimos 6 meses
   vr_string_operacoes := vr_string_operacoes||'<subcategoria>'||
                            '<tituloTela>Participa��o</tituloTela>'|| -- Titulo da subcategoira
                            '<tituloFiltro>participacao</tituloFiltro>'|| -- ID da subcategoria
                            '<campos>'; -- Abertura da tag de campos da subcategoria
   
   vr_string_operacoes := vr_string_operacoes||'<campo>
                                                <nome>Lista de Controle Societ�rio</nome>
                                                <tipo>table</tipo>
                                                <valor>
                                                <linhas>';
   vr_index := 0;
   vr_tab_tabela.delete;
   
   OPEN c_busca_participacao(pr_nrconbir => vr_nrconbir,
                             pr_nrdconta => pr_nrdconta);
    LOOP
    FETCH c_busca_participacao INTO r_busca_participacao;
    
    IF c_busca_participacao%FOUND THEN
      vr_index := vr_index + 1;
      vr_tab_tabela(vr_index).coluna1 := gene0002.fn_mask_cpf_cnpj(r_busca_participacao.nrcpfcgc,
                                         CASE WHEN LENGTH(r_busca_participacao.nrcpfcgc) > 11 THEN 2 ELSE 1 END);
      vr_tab_tabela(vr_index).coluna2 := r_busca_participacao.nmtitcon;
      vr_tab_tabela(vr_index).coluna3 := case when 
               r_busca_participacao.dtentsoc is not null then to_char(r_busca_participacao.dtentsoc,'DD/MM/YYYY') else '-' end;
      vr_tab_tabela(vr_index).coluna4 := trim(r_busca_participacao.percapvt ||'%');
      vr_tab_tabela(vr_index).coluna5 := trim(r_busca_participacao.pertotal ||'%');
    ELSE
      EXIT;
    END IF; 
    END LOOP;  
      
   CLOSE c_busca_participacao;

   IF vr_tab_tabela.COUNT > 0 THEN
    /*Gera Tags Xml*/
    vr_string_operacoes := vr_string_operacoes||fn_tag_table('Documento;Nome / Raz�o Social;Data de In�cio;Percentual de Capital Votante;Percentual de Participa��o',vr_tab_tabela);
   ELSE
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    vr_string_operacoes := vr_string_operacoes||fn_tag_table('Documento;Nome / Raz�o Social;Data de In�cio;Percentual de Capital Votante;Percentual de Participa��o',vr_tab_tabela);
   END IF;

   vr_string_operacoes := vr_string_operacoes||'</linhas>
                                                  </valor>
                                                  </campo>';  
   vr_string_operacoes := vr_string_operacoes||'</campos></subcategoria>';
  END IF;
   
   
   
   
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
                                  pr_cdcritic OUT PLS_INTEGER, --> C�digo da cr�tica
                                  pr_dscritic OUT VARCHAR2     --> Descri��o da cr�tica
                                 ) IS
    /* .............................................................................

    Programa: pc_gera_token_ibratan
    Sistema : Aimaro/Ibratan
    Autor   : Bruno Luiz Katzjarowski - Mout's
    Data    : Mar�o/2019                 Ultima atualizacao:

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

    -- Se n�o encontrou PA
    IF cr_crapage%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapage;
        -- Gerar cr�tica
        vr_cdcritic := 962;
        vr_dscritic := '';
        -- Levantar exce��o
      RAISE vr_exc_erro;
    END IF;

    -- Fechar cursor
    CLOSE cr_crapage;

    /* Verificar existencia de operador */
    OPEN cr_crapope(vr_cdcooper,
                    vr_cdoperad);

    FETCH cr_crapope INTO rw_crapope;

    -- Se n�o encontrou registro de operador
    IF cr_crapope%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapope;
        -- Gerar cr�tica
        vr_cdcritic := 67;
        vr_dscritic := '';
        -- Levantar exce��o
        RAISE vr_exc_erro;
    END IF;

    -- Fechar cursor
    CLOSE cr_crapope;
    
    --Se token esta nulo gera, caso contr�rio utiliza o token j� gerado
    if trim(rw_crapope.cddsenha) is null then
    -- Gera o codigo do token
    vr_dstoken := substr(dbms_random.random,1,10);
--    vr_dstoken := upper(vr_cdoperad);--'teste';

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
    
    else
      pr_dstoken := rw_crapope.cddsenha;
    end if;


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

      --ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral pc_gera_token_ibratan: ' || SQLERRM;
      pr_dstoken := NULL;

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

  -- Subrotina para escrever texto na vari�vel CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Vari�vel CLOB onde ser� inclu�do o texto
                           pr_texto_completo in out nocopy clob,  --> Vari�vel para armazenar o texto at� ser inclu�do no CLOB
                           pr_texto_novo in clob,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se � o �ltimo texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml (Com base em pc_escreve_xml)
      Autor:
      Data:                                       �ltima atualiza��o:

    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy clob,
                           pr_texto_novo clob) is
    begin
      -- Tenta concatenar o novo texto ap�s o texto antigo (vari�vel global da package)
      pr_texto_completo := pr_texto_completo || pr_texto_novo;
    exception when value_error then
      if pr_xml is null then
        pr_xml := pr_texto_completo;
      else
        --dbms_lob.writeappend(pr_xml, length(pr_texto_completo),pr_texto_completo);
        -- Estamos em Teste na utiliza��o do append
        dbms_lob.append(dest_lob => pr_xml, src_lob => pr_texto_completo);
        pr_texto_completo := null;
      end if;
    end;
    --
  begin
    
    -- Incluir nome do m�dulo logado - Chamado 660322 18/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'pc_escreve_xml');
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o �ltimo texto do arquivo, inclui no CLOB
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
           vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFER�NCIA - ' || vr_referenc || '&lt;/b&gt;';
           vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';

           vr_vltotmes := 0;
         END IF;

         vr_referenc :=  LPAD(TO_CHAR(vr_mesatual),2,'0')||'/'||TO_CHAR(rw_tbfolha_lanaut.dtmvtolt,'RRRR');

         vr_contlan := vr_contlan + 1;
         vr_mesante := vr_mesatual;
      END IF;

      --Data, valor e hist�rico
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
       vr_tab_tabela(vr_index).coluna2 := '&lt;b&gt;TOTAL DA REFER�NCIA - ' || vr_referenc || '&lt;/b&gt;';
       vr_tab_tabela(vr_index).coluna3 := '&lt;b&gt;' || TO_CHAR(vr_vltotmes,'fm9g999g999g999g999g990d00') || '&lt;/b&gt;';
    END IF;

    if vr_tab_tabela.COUNT > 0 then
        /*Gera Tags Xml*/
        vr_string := vr_string||fn_tag_table('Data;Descri��o;Valor',vr_tab_tabela);
    else
       vr_tab_tabela(1).coluna1 := '-';
       vr_tab_tabela(1).coluna2 := '-';
       vr_tab_tabela(1).coluna3 := '-';
       vr_string := vr_string||fn_tag_table('Data;Descri��o;Valor',vr_tab_tabela);
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
    Data    : Mar�o/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para recuperar o historico do cartao de credito.

    Alteracoes:
  ..............................................................................*/
  
  
  /*Consulta Historico Cartao de Credito*/      
  cursor c_consulta_hist_cartao is                           
  SELECT to_char(atu.dtalteracao,'DD/MM/YYYY')  dtretorno
           , DECODE(atu.cdcanal, 14, 'AUTOM�TICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , nvl(atu.nrproposta_est,0) nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Conclu�do'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em An�lise'
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
           , DECODE(atu.cdcanal, 14, 'AUTOM�TICA'   /* SAS */
                                   , 'MANUAL' )   dstipatu
           , atu.vllimite_anterior
           , atu.vllimite_alterado
           , nvl(atu.nrproposta_est,0) nrproposta_est
           , atu.tpsituacao
           , DECODE(atu.tpsituacao,1,'1 - Pendente'
                                  ,2,'2 - Enviado ao Bancoob'
                                  ,3,'3 - Conclu�do'
                                  ,4,'4 - Erro'
                                  ,6,'6 - Em An�lise'
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
    
   /* Cursor para buscar os cart�es quando n�o existir hist�rico */
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
                   '<tituloTela>�ltimas 4 Opera��es Alteradas - Cart�o de Cr�dito</tituloTela>'||
                   '<campos>';
                   
  vr_string := vr_string ||'<campo>
                              <nome>Produto Cart�o de Cr�dito</nome>
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
  
  /*Bug 20887 - Quando n�o houver hist�rico de altera��es, retornar as majora��es*/
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
      vr_string := vr_string||fn_tag_table('Data da Proposta;Proposta;Situa��o;Valor Limite',vr_tab_tabela);
    ELSE
    vr_string := vr_string||fn_tag_table('Data da Altera��o;Proposta;Situa��o;Valor Anterior;Valor Atualizado',vr_tab_tabela);
    END IF;
  ELSE
    
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    --vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Data da Altera��o;Proposta;Situa��o;Valor Anterior;Valor Atualizado',vr_tab_tabela);
    
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
    select l.vllimite,l.nrctrlim,l.cddlinha,l.nrgarope,l.nrctaav1,l.nrctaav2
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
        
    cursor c_media_liquidez is 
     select c.dtlibera,insitchq,c.vlcheque 
       from crapcdb c
      where c.cdcooper = pr_cdcooper
        and c.nrdconta = pr_nrdconta
        and c.dtlibera between TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM') and rw_crapdat.dtmvtolt;
        --and c.dtlibbdc is not null;  Validado Valor com a Marje -- Dados conforme B.I. 04/06/2019 -- Paulo Martins
             
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
    
    vr_garantia := '-';
    vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,r_limite_desc_chq.nrctrlim,r_limite_desc_chq.nrctaav1,r_limite_desc_chq.nrctaav2,'O',c_desconto_cheque); --Desconto de Cheque
    
    vr_string := vr_string||fn_tag('Garantia',vr_garantia);
    
    --M�dia e Liquidez
    wrk_qtd_tit_liquidado := 0;
    wrk_qtd_tit_total     := 0;
    for r_media_liquidez in c_media_liquidez loop -- 6 Meses
         
       wrk_valor := wrk_valor + r_media_liquidez.vlcheque;
               
       /*Boletos descontados que foram liquidados 
        nos �ltimos 06 meses / Boletos emitidos no �ltimos 06 meses *100 = 
       (Indicador atual do Aimaro);*/
       if r_media_liquidez.insitchq = 2 then
         wrk_qtd_tit_liquidado := wrk_qtd_tit_liquidado + 1;
         wrk_qtd_tit_total     := wrk_qtd_tit_total + 1;
       else
         wrk_qtd_tit_total     := wrk_qtd_tit_total + 1;  
       end if;
               
     end loop;  
     
     begin
       wrk_valor := (wrk_valor/wrk_qtd_tit_total);
       wrk_liquidez := ((wrk_qtd_tit_liquidado/wrk_qtd_tit_total) * 100);
     exception when zero_divide then
       wrk_valor := 0;
       wrk_liquidez := 0;
     end;
        
    --M�dia e Liquidez                   
    vr_string := vr_string||fn_tag('M�dia de Desconto do Semestre',
                 case when wrk_valor > 0 then to_char(wrk_valor,'999g999g990d00') else '-' end);
     --Retirado para posterior libera��o
/*    vr_string := vr_string||fn_tag('Liquidez do Semestre',
                 case when wrk_liquidez > 0 then nvl(to_char(wrk_liquidez),'-')||'%' else '-' end);*/
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
  
PROCEDURE pc_consulta_bordero_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
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

    Objetivo  : Rotina para retornar dados do Border� desconto de Cheque.

    Alteracoes:
  ..............................................................................*/
    
      -- Tratamento de erros
      vr_exc_erro exception;

      vr_flgverbor INTEGER;
      vr_string_bdc CLOB;
      vr_dsxmlret CLOB;
      vr_dstexto CLOB;
      
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
             vr_qt_tot_cheques := rw_crapcdb.valor_total_cheques;
           end if;
       close cr_crapcdb;
       
       open cr_crapcdb_borderos;
         fetch cr_crapcdb_borderos into rw_crapcdb_borderos;
           if cr_crapcdb_borderos%found then
             vr_qt_tot_borderos := rw_crapcdb_borderos.total_borderos;
           end if;
       close cr_crapcdb_borderos;

        vr_string_bdc := vr_string_bdc ||'<subcategoria>'||
                                         '<tituloTela>Rotativos Ativos - Produto B�rdero de Desconto de Cheque</tituloTela>'||
                                         '<campos>';
                                          --Retirado para posterior libera��o
        vr_string_bdc := vr_string_bdc || --fn_tag('Quantidade Total de Border�s', vr_qt_tot_borderos)||
                                          fn_tag('Quantidade Total de Cheques', vr_vl_tot_borderos)||
                                          fn_tag('Valor Total de Border�s', to_char(vr_qt_tot_cheques,'999g999g990d00'));

        vr_string_bdc := vr_string_bdc||'</campos></subcategoria>';   

        -- Encerrar a tag raiz
        pc_escreve_xml(pr_xml => vr_dsxmlret,
                      pr_texto_completo => vr_dstexto,
                      pr_texto_novo => vr_string_bdc,
                      pr_fecha_xml => TRUE); 
                                    
    -- Cria o XML a ser retornado
        pr_dsxmlret := vr_dsxmlret; 
    
  exception
  WHEN OTHERS THEN
    pr_cdcritic := 0;
    pr_dscritic := 'Erro pc_consulta_bordero_chq: '||sqlerrm;     
                                
  end pc_consulta_bordero_chq;  
  
  PROCEDURE pc_consulta_lim_desc_chq(pr_cdcooper IN crapass.cdcooper%TYPE       --> Cooperativa
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE       --> Conta
                                    ,pr_cdcritic OUT PLS_INTEGER                  --> Codigo da critica
                                    ,pr_dscritic OUT VARCHAR2                     --> Descricao da critica                                    
                                    ,pr_dsxmlret IN OUT CLOB) IS
     
    /* .............................................................................

    Programa: pc_consulta_lim_desc_chq
    Sistema : Aimaro/Ibratan
    Autor   : Leonardo Zippert - Mout's 
    Data    : Mar�o/2019                 Ultima atualizacao:

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
                          <tituloTela>�ltimas 4 Opera��es Alteradas - Desconto de Cheques</tituloTela>
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
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Vig�ncia;Limite;Situa��o;Data do Cancelamento',vr_tab_tabela);
  else
    
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Vig�ncia;Limite;Situa��o;Data do Cancelamento',vr_tab_tabela);
    
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
    Data    : Mar�o/2019                 Ultima atualizacao:

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
      --and insitlim = 3 --  not in (1,2) -- Pegar Somente Cancelados ou outros...
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
                          <tituloTela>Hist�rico Desconto de T�tulos</tituloTela>
                        <campos>
                        <campo>
                                 <nome>Limite Desconto de T�tulo</nome>
                                 <tipo>table</tipo>
                        <valor>
                         <linhas>';*/
   
    vr_string := vr_string ||'<subcategoria>
                          <tituloTela>�ltimas 4 Opera��es Alteradas - Desconto de T�tulos</tituloTela>
                        <campos>
                            <campo>
                              <nome>Produto Limite de Desconto de T�tulo</nome>
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
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Fim Vig�ncia;Limite;Situa��o;Motivo;Data da Situa��o',vr_tab_tabela);

  else
    
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    vr_tab_tabela(1).coluna6 := '-';
    vr_tab_tabela(1).coluna7 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Fim Vig�ncia;Limite;Situa��o;Motivo;Data da Situa��o',vr_tab_tabela);
    
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
    Data    : Mar�o/2019                 Ultima atualizacao:

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
                              <tituloTela>�ltimas 4 Opera��es Alteradas - Limite de Cr�dito</tituloTela>
                        <campos>
                        <campo>
                              <nome>Produto Limite de Cr�dito</nome>
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
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Fim Vig�ncia;Limite;Situa��o;Motivo',vr_tab_tabela);

  else
    
    vr_tab_tabela(1).coluna1 := '-';
    vr_tab_tabela(1).coluna2 := '-';
    vr_tab_tabela(1).coluna3 := '-';
    vr_tab_tabela(1).coluna4 := '-';
    vr_tab_tabela(1).coluna5 := '-';
    vr_tab_tabela(1).coluna6 := '-';
    
    vr_string := vr_string||fn_tag_table('Contrato;In�cio Vig�ncia;Fim Vig�ncia;Limite;Situa��o;Motivo',vr_tab_tabela);
    
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
   vr_des_reto         VARCHAR2(100);
   
   -- variaveis de retorno
   vr_tab_saldos     EXTR0001.typ_tab_saldos;
   vr_tab_libera_epr EXTR0001.typ_tab_libera_epr;
   vr_tab_erro       gene0001.typ_tab_erro;                                 
    
  begin
    
     extr0001.pc_carrega_dep_vista(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => NULL         --> N�o gerar log
                                   ,pr_nrdcaixa => NULL         --> N�o gerar log
                                   ,pr_cdoperad => NULL         --> N�o gerar log
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_idorigem => 5
                                   ,pr_idseqttl => 1
                                   ,pr_nmdatela => 'TELA_UNICA'
                                   ,pr_flgerlog => 0            --> N�o gerar log
                                   ,pr_tab_saldos => vr_tab_saldos
                                   ,pr_tab_libera_epr => vr_tab_libera_epr
                                   ,pr_des_reto => vr_des_reto
                                   ,pr_tab_erro => vr_tab_erro);

     vr_string_lm := vr_string_lm || '<subcategoria>'||
                                     '<tituloTela>Rotativos Ativos - Modalidade Limite de Cr�dito</tituloTela>'||
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
           vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,r_busca_limites.nrctrlim,r_busca_limites.nrctaav1,r_busca_limites.nrctaav2,'O',c_limite_desc_titulo); 

          end if;
        close c_busca_data;

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

           -- 3.2 - Garantia - 
           vr_string_lm := vr_string_lm || fn_tag('Garantia',vr_garantia);

           -- 4: media de utilizacao - Garantia - Media. Neg. Esp. do mes
           vr_string_lm := vr_string_lm || fn_tag('M�dia Negativa de Utiliza��o do M�s',TRIM(TO_CHAR(ROUND(garantia_vlsmnesp,2),'999g999g990d00')));

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
    Data    : Mar�o/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para recuperar o historico do cartao de credito dos ult. 3 meses.

    Alteracoes:
  ..............................................................................*/
   
    /*Busca os dados do cart�o quando PF*/
    cursor c_busca_cartao is
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and insitcrd IN (2,3,4)
       and flgprcrd = 1
       and cdadmcrd <> 16;

    /*Busca os dados do cart�o quandi PJ (Busca primeiro cart�o. Valores iguais / limite compartilhado) */
    cursor c_busca_cartao_pj is
      select vllimcrd, dddebito, dddebant, nrctrcrd, nrcrcard
       from crawcrd
       where cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and insitcrd IN (2,3,4)
       and cdadmcrd <> 17
       and rownum <=1;
       
     /*Busca se � PF ou PJ para saber qual cursor abrir*/
     cursor c_busca_tipo_pessoa is
       select c.inpessoa
       from crapass c
       where c.cdcooper = pr_cdcooper
       and   c.nrdconta = pr_nrdconta;
    
    -- Removido pois ser� uma melhoria da pr�xima sprint   
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
   -- Removido pois ser� uma melhoria da pr�xima sprint   
   --flg_lancamento boolean := false;
   
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
                             <tituloTela>Rotativos Ativos - Modalidade Cart�o de Cr�dito</tituloTela>
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
        
        vr_string := vr_string || fn_tag('Cart�o',to_char(r_cartao.nrcrcard,'9999g9999g9999g9999'));
        vr_string := vr_string || fn_tag('Limite de Cr�dito',to_char(r_cartao.vllimcrd,'999g999g990d00'));
        
        -- Removido pois ser� uma melhoria da pr�xima sprint
        /*for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('M�dia das �ltimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('M�dia das �ltimas 3 faturas','-');
        end if;*/
        
        vr_string := vr_string || fn_tag('Dia Vencimento',to_char(r_cartao.dddebito));
        vr_string := vr_string || fn_tag('Dia Vencimento 2� Via',to_char(r_cartao.dddebant));      
        
        vr_index := vr_index + 1;
        
      end loop;
    else
      
      for r_cartao in c_busca_cartao_pj loop
        
        vr_string := vr_string || fn_tag('Cart�o',to_char(r_cartao.nrcrcard,'9999g9999g9999g9999'));
        vr_string := vr_string || fn_tag('Limite de Cr�dito',to_char(r_cartao.vllimcrd,'999g999g990d00'));
        
        -- Removido pois ser� uma melhoria da pr�xima sprint
        /*for r_faturas in c_busca_lancamentos(r_cartao.nrctrcrd) loop
          vr_string := vr_string || fn_tag('M�dia das �ltimas 3 faturas',to_char(r_faturas.media_cartao,'999g999g990d00'));
          flg_lancamento := true;
        end loop;
        
        if not flg_lancamento then
            vr_string := vr_string || fn_tag('M�dia das �ltimas 3 faturas','-');
        end if;*/
        
        vr_string := vr_string || fn_tag('Dia Vencimento',to_char(r_cartao.dddebito));
        vr_string := vr_string || fn_tag('Dia Vencimento 2� Via',to_char(r_cartao.dddebant));      
        
        vr_index := vr_index + 1;
        
      end loop;
      
    end if;
    /*Se n�o encontrou dados, monta uma categoria vazia bug 20672*/
    if (vr_index = 0) then
      vr_string := vr_string || fn_tag('Cart�o','-');
      vr_string := vr_string || fn_tag('Limite de Cr�dito','-');
      vr_string := vr_string || fn_tag('M�dia das �ltimas 3 faturas','-');
      vr_string := vr_string || fn_tag('Dia Vencimento','-');
      vr_string := vr_string || fn_tag('Dia Vencimento 2� Via','-');
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
    Data    : Mar�o/2019                 Ultima atualizacao: 29/04/2019

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
                         WHEN 5 THEN 'N�O APROVADO'
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
         
         -- variaveis
   vr_string CLOB;
   vr_dsxmlret CLOB;
   vr_dstexto CLOB;     

      BEGIN
        
      -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
    vr_string := vr_string||'<subcategoria>
                          <tituloTela>�ltimas 4 Opera��es Liquidadas - Border�s de Desconto de T�tulos</tituloTela>
                        <campos>
                        <campo>
                                 <nome>�ltimos Border�s Liquidados</nome>
                                 <tipo>table</tipo>
                        <valor>
                         <linhas>';
                            
    vr_tab_tabela.delete;

        vr_dt_aux_dtmvtolt := trunc(rw_crapdat.dtmvtolt) - 120;
        vr_dt_aux_dtlibbdt := trunc(rw_crapdat.dtmvtolt) - 60;

        -- abrindo cursos de t�tulos
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
               vr_tab_tabela(vr_idxbordero).coluna9 := to_char(rw_crapbdt.dtlibbdt,'DD/MM/YYYY');
             --  vr_tab_tabela(vr_idxbordero).coluna11 :=  rw_crapbdt.dsinsitapr;
             --  vr_tab_tabela(vr_idxbordero).coluna12   :=  rw_crapbdt.inprejuz;

        END LOOP;
        CLOSE  cr_crapbdt;
        
        
    if vr_tab_tabela.count > 0 then
    /*Gera Tags Xml*/
    vr_string := vr_string||fn_tag_table('Data Proposta;B�rdero;Contrato;Quantidade de T�tulos;Valor;Quantidade Aprovado;Valor Aprovado;Situa��o;Data Libera��o',vr_tab_tabela);

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
    
    vr_string := vr_string||fn_tag_table('Data Proposta;B�rdero;Contrato;Quantidade de T�tulos;Valor;Quantidade Aprovado;Valor Aprovado;Situa��o;Data Libera��o',vr_tab_tabela);
    
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
    Data    : Mar�o/2019                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Recupera a media dos ultimos 6 meses para desconto de titulo/bordero.

    Alteracoes: 30/05/2019 - Apresentar simbolo de % na tela unica para o campo Liquidez.
                             Bug 22071 - PRJ438 - Gabriel Marcos (Mouts).
                             
  ..............................................................................*/
     
      cursor c1 is
      select tit.vltitulo, -- valor
             tit.insitapr, -- 1 aprovado
             bdt.insitbdt  -- 4 Liquidado
        from crapbdt bdt,
             craptdb tit
       where bdt.cdcooper = pr_cdcooper
         and bdt.nrdconta = pr_nrdconta
         and bdt.insitapr in (3,4) -- Aprovados e Aprovados Automativamente
         and bdt.dtlibbdt between TRUNC(add_months(rw_crapdat.dtmvtolt,-6),'MM') -- Primeiro dia de 6 meses atr�s
                                  and rw_crapdat.dtmvtolt
         and bdt.cdcooper = tit.cdcooper -- Bug 22097  -- Paulo
         and bdt.nrdconta = tit.nrdconta -- Bug 22097                                    
         and bdt.nrborder = tit.nrborder
       order by bdt.nrborder desc;     
     
     r1 c1%rowtype;
  
     
     pr_tab_borderos TELA_ATENDA_DSCTO_TIT.typ_tab_borderos;
     pr_cdcritic PLS_INTEGER;
     pr_dscritic varchar2(4000);
     pr_qtregist INTEGER;
  
     wrk_valor number(25,2) := 0;
     wrk_qtd_tit_liquidado pls_integer := 0;
     wrk_qtd_tit_total pls_integer := 0;
     wrk_liquidez number(25,2) := 0;
     wrk_qtd_geral number;
     vr_inpessoa crapass.inpessoa%type;
     
     vr_tab_dados_dsctit    dsct0002.typ_tab_dados_dsctit; -- retorno da TAB052 para Cooperativa e Cobran�a Registrada
     vr_tab_cecred_dsctit   dsct0002.typ_tab_cecred_dsctit;     
     
   begin
      
      --Busca inpessoa
      select inpessoa 
        into vr_inpessoa
        from crapass a
       where a.cdcooper = pr_cdcooper
         and a.nrdconta = pr_nrdconta;
      
     
      -- Busca os Par�metros para o Cooperado e Cobran�a Com Registro
      dsct0002.pc_busca_parametros_dsctit(pr_cdcooper, --pr_cdcooper,
                                          NULL, --Agencia de opera��o
                                          NULL, --N�mero do caixa
                                          NULL, --Operador
                                          NULL, -- Data da Movimenta��o
                                          NULL, --Identifica��o de origem
                                          1, --pr_tpcobran: 1-REGISTRADA / 0-N�O REGISTRADA
                                          vr_inpessoa, --1-PESSOA F�SICA / 2-PESSOA JUR�DICA
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
                  
        wrk_valor := wrk_valor + r1.vltitulo;
        wrk_qtd_tit_total := wrk_qtd_tit_total + 1; 
         
      end loop;
     
     begin
       wrk_valor := (wrk_valor/wrk_qtd_tit_total); -- M�dia Calculada com base no total de t�tulos aprovador- Paulo
     exception when zero_divide then
       wrk_valor := 0;
     end;
     
     pr_out_media_tit := to_char(wrk_valor,'999g999g990d00');  
     pr_out_liquidez  := case when wrk_liquidez > 0 then to_char(round(wrk_liquidez,2))||'%' end;

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
    Data    : Mar�o/2019                 Ultima atualizacao: 29/04/2019

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para recuperar descontos de titulo.

    Alteracoes:
  ..............................................................................*/
    
    wrk_tab_dados_limite   TELA_ATENDA_DSCTO_TIT.typ_tab_dados_limite;
    wrk_cdcritica PLS_INTEGER;
    wrk_dscerro VARCHAR2(4000);
    
   /*Recupera a garantia do desconto de t�tulo*/
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
     SELECT l.nrctaav1,l.nrctaav2
       FROM craplim l
      WHERE l.cdcooper = pr_cdcooper
        AND l.nrdconta = pr_nrdconta
        AND l.nrctrlim = pr_nrctrlim;
      --
      r_avalistas c_avalistas%rowtype;
   
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
                              <tituloTela>Rotativos Ativos - Modalidade Desconto de T�tulo</tituloTela>
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
    
     pc_busca_media_titulo(pr_cdcooper,pr_nrdconta,vr_med_tit,vr_liquidez);
     vr_garantia := '-'; 
     
     open c_avalistas(wrk_tab_dados_limite(0).nrctrlim);
      fetch c_avalistas into r_avalistas;
     close c_avalistas;
     vr_garantia := '-';
     vr_garantia := fn_garantia_proposta(pr_cdcooper,pr_nrdconta,wrk_tab_dados_limite(0).nrctrlim,r_avalistas.nrctaav1,r_avalistas.nrctaav2,'O',c_desconto_titulo); 
      
     vr_string := vr_string || fn_tag('Limite',to_char(wrk_tab_dados_limite(0).vllimite,'999g999g990d00'));
     vr_string := vr_string || fn_tag('Saldo Utilizado',to_char(wrk_tab_dados_limite(0).vlutiliz,'999g999g990d00'));
     vr_string := vr_string || fn_tag('Garantia',vr_garantia); --bug 20410
     vr_string := vr_string || fn_tag('M�dia de Desconto do Semestre',vr_med_tit);
     vr_string := vr_string || fn_tag('Liquidez',vr_liquidez);
      
    else
           
     vr_string := vr_string || fn_tag('Limite','-');
     vr_string := vr_string || fn_tag('Saldo Utilizado','-');
     vr_string := vr_string || fn_tag('Garantia','-');
     vr_string := vr_string || fn_tag('M�dia de Desconto do Semestre','-');
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
    Data    : Mar�o/2019                 Ultima atualizacao:

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
     
     wrk_menor_data DATE := to_date('31/12/9999','DD/MM/YYYY');
     wrk_data_compara DATE;
     wrk_index_order number;
     vr_index2 number := 1;
     wrk_saida boolean := false;
     wrk_total number;
     vr_total_valor    NUMBER := 0; --STORY 22155
                              
   begin
     
     -- Criar documento XML
    dbms_lob.createtemporary(vr_dsxmlret, TRUE);
    dbms_lob.open(vr_dsxmlret, dbms_lob.lob_readwrite);
    
  
    vr_string := vr_string||'<subcategoria>
                              <tituloTela>Lan�amentos Futuros</tituloTela>
                            <campos>
                            <campo>
                               <nome>Informa��es de Lan�amentos Futuros</nome>
                               <tipo>table</tipo>
                               <valor>
                             <linhas>';
    
     wrk_date_ini := TRUNC(rw_crapdat.dtmvtolt, 'MONTH'); -- Recebe primeiro dia do mes corrente
     
     -- Se hoje for dia 01 entao so trago os lancamentos do mes atual
     -- Senao retorno o mes atual e o mes seguinte...
     /*Mostrar o m�s atual e o todo o m�s seguinte: Descri��o e valor 
     (Quando o m�s atual for dia 01 n�o ser� necess�rio mostrar o m�s seguinte)*/
     if wrk_date_ini = trunc(rw_crapdat.dtmvtolt) then
       wrk_date_fim := trunc(LAST_DAY(rw_crapdat.dtmvtolt));
     else
       wrk_date_fim := trunc(LAST_DAY(ADD_MONTHS(rw_crapdat.dtmvtolt,1)));
     end if;
     wrk_lancamentos.delete;
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
                                     ,pr_indebcre => null--'D'              -- Debito/Credito
                                     ,pr_des_reto => wrk_tab_erro                          --Retorno OK ou NOK
                                     ,pr_tab_erro => wrk_tab_erros             --Tabela Retorno Erro
                                     ,pr_tab_totais_futuros => wrk_totais  --Vetor para o retorno das informa��es
                                     ,pr_tab_lancamento_futuro => wrk_lancamentos);
     
     
     
     vr_index := 1;
     vr_tab_tabela.delete;
     vr_tab_tabela_secundaria.delete;
     
     if wrk_lancamentos.count > 0 then
     for vr_index in wrk_lancamentos.first .. wrk_lancamentos.last loop
     
       vr_tab_tabela(vr_index).coluna1 := to_char(wrk_lancamentos(vr_index).dtmvtolt,'DD/MM/YYYY');
       vr_tab_tabela(vr_index).coluna2 := wrk_lancamentos(vr_index).dshistor;
       vr_tab_tabela(vr_index).coluna3 := wrk_lancamentos(vr_index).nrdocmto;
       vr_tab_tabela(vr_index).coluna4 := wrk_lancamentos(vr_index).indebcre;
       vr_tab_tabela(vr_index).coluna5 := trim(to_char(wrk_lancamentos(vr_index).vllanmto,'999g999g990d00'));
       /*Acumula o valor total*/
       vr_total_valor := vr_total_valor + NVL(wrk_lancamentos(vr_index).vllanmto,0);
  
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
               wrk_menor_data := wrk_data_compara;
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
         
         /*Exclui registro j� armazenado*/
         wrk_lancamentos.delete(wrk_index_order);
         
         /*Volta o indice para come�ar tudo denovo*/
         vr_index := 0;

         /*Incremente indice nova tabela*/
         vr_index2 := vr_index2 + 1;
         
         wrk_menor_data := to_date('31/12/9999','DD/MM/YYYY');
         
       end if;
       
       /*Condi��o de sa�da*/
       if (wrk_lancamentos.count = 0 OR vr_index > wrk_total) then
         wrk_saida := true;
       end if;
       
       vr_index := vr_index + 1;
    
       end loop;
     end if;
     
    -- Colocar a linha de Totais
    IF vr_tab_tabela_secundaria.COUNT() > 1 THEN
        vr_index := vr_tab_tabela_secundaria.COUNT() + 1;            
        vr_tab_tabela_secundaria(vr_index).coluna1 := '&lt;b&gt;TOTAL&lt;/b&gt;';
        vr_tab_tabela_secundaria(vr_index).coluna2 := '-';
        vr_tab_tabela_secundaria(vr_index).coluna3 := '-';
        vr_tab_tabela_secundaria(vr_index).coluna4 := '-';
        vr_tab_tabela_secundaria(vr_index).coluna5 := case when vr_total_valor > 0 then
                                              to_char(vr_total_valor,'999g999g990d00') else '-' end;
              
    END IF;   
   
     
    if vr_tab_tabela_secundaria.count > 0 then
      /*Gera Tags Xml*/
      vr_string := vr_string||fn_tag_table('Data D�bito;Hist�rico;Documento;D/C;Valor',vr_tab_tabela_secundaria);

    else
      
      vr_tab_tabela_secundaria(1).coluna1 := '-';
      vr_tab_tabela_secundaria(1).coluna2 := '-';
      vr_tab_tabela_secundaria(1).coluna3 := '-';
      vr_tab_tabela_secundaria(1).coluna4 := '-';
      vr_tab_tabela_secundaria(1).coluna5 := '-';
      
      vr_string := vr_string||fn_tag_table('Data D�bito;Hist�rico;Documento;D/C;Valor',vr_tab_tabela_secundaria);
      
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
           /* montar descri�ao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo ' ||SQLERRM;
    END;
    END pc_listar_titulos_resumo ;
  
PROCEDURE pc_listar_titulos_resumo_web (pr_cdcooper           in crapcop.cdcooper%TYPE
                                       ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                       ,pr_chave              in VARCHAR2                --> Lista de 'chaves' de titulos a serem pesquisado
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
    
      -- Vari�vel de cr�ticas
       vr_cdcritic crapcri.cdcritic%type; --> C�d. Erro
       vr_dscritic varchar2(1000);        --> Desc. Erro
       
     vr_situacao char(1);
     vr_nrinssac crapcob.nrinssac%TYPE;
     
   -- Vari�veis para armazenar as informa��es em XML
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

        pc_listar_titulos_resumo(pr_cdcooper  --> C�digo da Cooperativa
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
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        when others then
             /* montar descri�ao de erro nao tratado */
             pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_listar_titulos_resumo_web ' ||sqlerrm;
             pr_des_erro := 'NOK';
             -- Carregar XML padrao para variavel de retorno
              pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                             '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END pc_listar_titulos_resumo_web;      
    
end TELA_ANALISE_CREDITO;
/
