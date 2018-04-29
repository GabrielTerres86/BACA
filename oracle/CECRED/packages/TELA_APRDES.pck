create or replace package cecred.TELA_APRDES is
 /* ---------------------------------------------------------------------------------------------------------------
  
    Programa : TELA_APRDES
    Sistema  : Cred
    Autor    : Luis Fernando (GFT)
    Data     : 24/04/2018
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que chamado
   Objetivo  : Package contendo as procedures da tela APRDES (Mesa de Checagem)

 */  
  /*Tabela de retorno dos titulos do bordero*/
  TYPE typ_rec_dados_borderos
       IS RECORD (nrborder crapbdt.nrborder%TYPE,
                  nrdconta crapbdt.nrdconta%TYPE,
                  vlborder NUMBER,
                  cdoperad crapbdt.cdoperad%TYPE,
                  insitbdt crapbdt.insitbdt%TYPE,
                  insitapr crapbdt.insitapr%TYPE
                  );

  TYPE typ_tab_dados_borderos IS TABLE OF typ_rec_dados_borderos INDEX BY BINARY_INTEGER;
  
  /*Tabela de retorno dos titulos do bordero*/
  TYPE typ_rec_dados_titulos
       IS RECORD (nmdsacad crapsab.nmdsacad%TYPE,
                  nrcelsac crapsab.nrcelsac%TYPE,
                  nrnosnum crapcob.nrnosnum%TYPE,
                  vltitulo craptdb.vltitulo%TYPE,
                  dtvencto craptdb.dtvencto%TYPE,
                  nrliqpag NUMBER,
                  nrconcen NUMBER,
                  flgcritdb CHAR(1),
                  nrborder craptdb.nrborder%TYPE,
                  nrdconta craptdb.nrdconta%TYPE,
                  nrcnvcob craptdb.nrcnvcob%TYPE,
                  nrdocmto craptdb.nrdocmto%TYPE,
                  nrdctabb craptdb.nrdctabb%TYPE,
                  cdbandoc craptdb.cdbandoc%TYPE,
                  insitmch craptdb.insitmch%TYPE
                  );

  TYPE typ_tab_dados_titulos IS TABLE OF typ_rec_dados_titulos INDEX BY BINARY_INTEGER;
  
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
  
  
  
  /*Tabela de retorno dos dados obtidos para as criticas*/
  TYPE typ_reg_dados_parecer IS RECORD(
       nmoperad             crapope.nmoperad%TYPE,
       dtparecer            tbdsct_parecer_titulo.dtparecer%TYPE,
       dsparecer            tbdsct_parecer_titulo.dsparecer%TYPE
  );
  TYPE typ_tab_dados_parecer IS TABLE OF typ_reg_dados_parecer INDEX BY BINARY_INTEGER;

  FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper craptdb.cdcooper%TYPE
                                        ,pr_nrdconta craptdb.nrdconta%TYPE
                                        ,pr_nrinssac crapcob.nrinssac%TYPE
                                        ) RETURN NUMBER;
                                        
  FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper craptdb.cdcooper%TYPE
                                        ,pr_nrdconta craptdb.nrdconta%TYPE
                                        ,pr_nrinssac crapcob.nrinssac%TYPE
                                        ,pr_cdtpinsc crapcob.cdtpinsc%TYPE
                                        ) RETURN NUMBER;
                                        
  PROCEDURE pc_buscar_bordero (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtborini IN VARCHAR2                --> Data de início de busca do bordero
                             ,pr_dtborfim IN VARCHAR2                --> Data final de busca do bordero
                             -->OUT<--
                             ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                             ,pr_tab_dados_bordero OUT typ_tab_dados_borderos         --> Resultado da consulta
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             );
  PROCEDURE pc_buscar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtborini IN VARCHAR2                --> Data de início de busca do bordero
                             ,pr_dtborfim IN VARCHAR2                --> Data final de busca do bordero
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );
                             
  PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

  PROCEDURE pc_verifica_status_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

 PROCEDURE pc_atualiza_checagem_operador (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

 PROCEDURE pc_conclui_checagem (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_titulos IN VARCHAR2   --> Número do Borderô                             
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );
                             
 PROCEDURE pc_inserir_parecer(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_titulos IN VARCHAR2   --> Número do Borderô                             
                             ,pr_dsparecer IN tbdsct_parecer_titulo.dsparecer%TYPE --> Insere parecer
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );
                             
 PROCEDURE pc_detalhes_titulo_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                        ,pr_nrborder           in crapbdt.nrborder%TYPE   --> Número do bordero
                                        ,pr_chave              in VARCHAR2                --> Chave do titulo
                                        ,pr_xmllog      in varchar2              --> xml com informações de log
                                         --------> out <--------
                                        ,pr_cdcritic out pls_integer             --> código da crítica
                                        ,pr_dscritic out varchar2                --> descrição da crítica
                                        ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                        ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                        ,pr_des_erro out varchar2                --> erros do processo
                                         );
end TELA_APRDES;
/
create or replace package body cecred.TELA_APRDES is
 /* ---------------------------------------------------------------------------------------------------------------
  
    Programa : TELA_APRDES
    Sistema  : Cred
    Autor    : Luis Fernando (GFT)
    Data     : 24/04/2018
  
   Dados referentes ao programa:
  
   Frequencia: Sempre que chamado
   Objetivo  : Package contendo as procedures da tela APRDES (Mesa de Checagem)
    
 */
 
 -- Variáveis para armazenar as informações em XML
 vr_des_xml         clob;
 vr_texto_completo  varchar2(32600);
 vr_index           pls_integer;
 
 FUNCTION fn_busca_situacao_bordero (pr_insitbdt crapbdt.insitbdt%TYPE) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_busca_situacao_bordero
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a descrição dos status do borderô.
  ---------------------------------------------------------------------------------------------------------------------*/
   BEGIN 
     RETURN (
       CASE 
         WHEN pr_insitbdt=1 THEN 'Em Estudo'
         WHEN pr_insitbdt=2 THEN 'Analisado'
         WHEN pr_insitbdt=3 THEN 'Liberado'
         WHEN pr_insitbdt=4 THEN 'Liquidado'
         WHEN pr_insitbdt=5 THEN 'Rejeitado'
       END
     );
 END fn_busca_situacao_bordero;
 
 FUNCTION fn_busca_decisao_bordero (pr_insitapr crapbdt.insitapr%TYPE) RETURN VARCHAR2 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_busca_decisao_bordero
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a descrição das decisoes do borderô.
  ---------------------------------------------------------------------------------------------------------------------*/
   BEGIN
     RETURN (
       CASE 
         WHEN pr_insitapr=0 THEN 'Aguardando Análise'
         WHEN pr_insitapr=1 THEN 'Aguardando Checagem'
         WHEN pr_insitapr=2 THEN 'Checagem'
         WHEN pr_insitapr=3 THEN 'Aprovado Automaticamente'
         WHEN pr_insitapr=4 THEN 'Aprovado'
         WHEN pr_insitapr=5 THEN 'Não aprovado'
         WHEN pr_insitapr=6 THEN 'Enviado Esteira'
         WHEN pr_insitapr=7 THEN 'Prazo expirado'
       END
     );
     
 END fn_busca_decisao_bordero;
   
 FUNCTION fn_concentracao_titulo_pagador (pr_cdcooper craptdb.cdcooper%TYPE
                                        ,pr_nrdconta craptdb.nrdconta%TYPE
                                        ,pr_nrinssac crapcob.nrinssac%TYPE
                                        ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_concentracao_titulo_pagador
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a porcentagem de concentracaoo de titulos daquele pagador
  ---------------------------------------------------------------------------------------------------------------------*/
  cursor cr_concentracao is -- Percentual de Concentração de Títulos por Pagador  
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
      nrinssac = pr_nrinssac
      AND nrdconta = pr_nrdconta;
   rw_concentracao cr_concentracao%rowtype;
   BEGIN
     open  cr_concentracao;
     fetch cr_concentracao into rw_concentracao;
     IF (cr_concentracao%NOTFOUND) THEN
       return 0;
     END IF;
     return rw_concentracao.pe_conc;    
 END fn_concentracao_titulo_pagador;
   
 FUNCTION fn_liquidez_pagador_cedente (pr_cdcooper craptdb.cdcooper%TYPE
                                        ,pr_nrdconta craptdb.nrdconta%TYPE
                                        ,pr_nrinssac crapcob.nrinssac%TYPE
                                        ,pr_cdtpinsc crapcob.cdtpinsc%TYPE
                                        ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_liquidez_pagador_cedente
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a porcentagem de liquidez do pagador contra o cedente
  ---------------------------------------------------------------------------------------------------------------------*/
  
    -- Títulos Descontados com vencimento dentro do período
   cursor cr_craptdb_desc is
   select count(1) qttitulo, nvl(sum(tdb.vltitulo), 0) vltitulo
   from   crapsab sab -- Pagador
         ,craptdb tdb -- Titulos do Bordero
         ,crapbdt dbt -- Bordero de Titulos
   where  sab.nrinssac = pr_nrinssac
   and    sab.cdtpinsc = pr_cdtpinsc
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
   where  sab.nrinssac  = pr_nrinssac
    and    sab.cdtpinsc  = pr_cdtpinsc 
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
 
   -- Controle
   vr_vlliquidez NUMBER;
   BEGIN
     ----> DETALHES (LIQUIDEZ DO PAGADOR COM O CEDENTE)
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
     return vr_vlliquidez;
 END fn_liquidez_pagador_cedente;
 
 FUNCTION fn_liquidez_geral (pr_cdcooper craptdb.cdcooper%TYPE
                                        ,pr_nrdconta craptdb.nrdconta%TYPE
                                        ,pr_nrinssac crapcob.nrinssac%TYPE
                                        ,pr_cdtpinsc crapcob.cdtpinsc%TYPE
                                        ) RETURN NUMBER IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : fn_liquidez_geral
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna a porcentagem de liquidez geral
  ---------------------------------------------------------------------------------------------------------------------*/
   
    -- Percentual Liquidez Geral
    --
    -- Títulos Descontados com vencimento dentro do período
    cursor cr_craptdb_desc_geral is
    select count(1) qttitulo, nvl(sum(tdb.vltitulo), 0) vltitulo
    from   crapsab sab
          ,craptdb tdb -- Titulos contidos do Bordero de desconto de titulos
          ,crapbdt dbt -- Cadastro de borderos de descontos de titulos
    where  sab.nrinssac = pr_nrinssac
     and    sab.cdtpinsc = pr_cdtpinsc
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
    where  sab.nrinssac = pr_nrinssac
     and    sab.cdtpinsc = pr_cdtpinsc
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
 
   -- Controle
   vr_vlliquidez NUMBER;
   BEGIN
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

          vr_vlliquidez := (rw_craptdb_npag_geral.vltitulo / rw_craptdb_desc_geral.vltitulo) * 100;
      end if;
      
     return vr_vlliquidez;
 END fn_liquidez_geral;
 
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
 
 PROCEDURE pc_buscar_bordero (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtborini IN VARCHAR2                --> Data de início de busca do bordero
                             ,pr_dtborfim IN VARCHAR2                --> Data final de busca do bordero
                             -->OUT<--
                             ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                             ,pr_tab_dados_bordero OUT typ_tab_dados_borderos         --> Resultado da consulta
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_bordero
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna os borderões passíveis de checagem quando passado filtros
  ---------------------------------------------------------------------------------------------------------------------*/
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    vr_exc_erro EXCEPTION;
    -- Datas
    vr_dtborini DATE;
    vr_dtborfim DATE;
    
    vr_possui_filtro integer;
    vr_index PLS_INTEGER;
    -- Cursor para trazer os borderôs que possuem titulos a serem verificados na mesa de checagem
    CURSOR cr_crapbdt IS
    	SELECT
          nrborder,
          nrdconta,
          (
           SELECT 
             sum(vltitulo) 
           FROM 
             craptdb 
           WHERE 
             craptdb.nrborder = crapbdt.nrborder AND craptdb.cdcooper = crapbdt.cdcooper AND craptdb.nrdconta = crapbdt.nrdconta
           ) AS vlborder,
          cdoperad,
          insitbdt,
          insitapr
      FROM
           crapbdt
      WHERE
           crapbdt.cdcooper = pr_cdcooper
           AND (crapbdt.insitbdt = 1 OR  vr_possui_filtro=1 ) -- em estudo
           AND ((crapbdt.insitapr = 1 OR crapbdt.insitapr = 2) OR (vr_possui_filtro=1 AND crapbdt.dtenvmch IS NOT NULL)) -- Aguardando checagem e checagem
           AND crapbdt.nrborder = nvl(pr_nrborder,crapbdt.nrborder)
           AND (vr_dtborini IS NULL OR crapbdt.dtmvtolt >= vr_dtborini)
           AND (vr_dtborfim IS NULL OR crapbdt.dtmvtolt <= vr_dtborfim)
           AND crapbdt.nrdconta = nvl(pr_nrdconta,crapbdt.nrdconta)
      ;
    rw_crapbdt cr_crapbdt%rowtype;
    BEGIN
      vr_dtborini := null;
      vr_possui_filtro := 0;
      IF (pr_dtborini IS NOT NULL ) THEN
        vr_possui_filtro:=1;
        vr_dtborini := to_date(pr_dtborini, 'DD/MM/RRRR');
      END IF;
      vr_dtborfim := null;
      IF (pr_dtborfim IS NOT NULL ) THEN
        vr_possui_filtro:=1;
        vr_dtborfim := to_date(pr_dtborfim, 'DD/MM/RRRR');
      END IF;
      IF (pr_nrborder IS NOT NULL OR pr_nrdconta IS NOT NULL) THEN
        vr_possui_filtro:=1;
      END IF;
      pr_qtregist := 0;
      OPEN cr_crapbdt;
      LOOP
        FETCH cr_crapbdt INTO rw_crapbdt;
        EXIT WHEN cr_crapbdt%NOTFOUND;
        pr_qtregist:=pr_qtregist+1;
        vr_index := pr_tab_dados_bordero.count+1;
        pr_tab_dados_bordero(vr_index).nrborder := rw_crapbdt.nrborder;
        pr_tab_dados_bordero(vr_index).nrdconta := rw_crapbdt.nrdconta;
        pr_tab_dados_bordero(vr_index).vlborder := rw_crapbdt.vlborder;
        pr_tab_dados_bordero(vr_index).cdoperad := rw_crapbdt.cdoperad;
        pr_tab_dados_bordero(vr_index).insitbdt := rw_crapbdt.insitbdt;
        pr_tab_dados_bordero(vr_index).insitapr := rw_crapbdt.insitapr;
      END LOOP;
      
      IF (pr_qtregist=0) THEN
        vr_dscritic := 'Não foram encontrados borderôs';
        raise vr_exc_erro;
      END IF;
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
       pr_dscritic := replace(replace('Erro pc_buscar_bordero: ' || sqlerrm, chr(13)),chr(10));
 END pc_buscar_bordero;
 
 PROCEDURE pc_buscar_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtborini IN VARCHAR2                --> Data de início de busca do bordero
                             ,pr_dtborfim IN VARCHAR2                --> Data final de busca do bordero
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS
                             
    -- variaveis de retorno
    vr_tab_dados_borderos typ_tab_dados_borderos;

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

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
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

      pc_buscar_bordero(vr_cdcooper         --> Código da Cooperativa
                        ,pr_nrdconta        --> Número da Conta
                        ,pr_nrborder        --> Número do Borderô
                        ,pr_dtborini        --> Data de início de busca do bordero
                        ,pr_dtborfim        --> Data final de busca do bordero
                        --------> OUT <--------
                        ,vr_qtregist        --> Quantidade de registros encontrados
                        ,vr_tab_dados_borderos --> Tabela de retorno dos títulos encontrados
                        ,vr_cdcritic        --> Código da crítica
                        ,vr_dscritic        --> Descrição da crítica
                        );
      
      IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
        raise vr_exc_erro;
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
      vr_index := vr_tab_dados_borderos.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<nrborder>' || vr_tab_dados_borderos(vr_index).nrborder || '</nrborder>' ||
                              '<nrdconta>' || vr_tab_dados_borderos(vr_index).nrdconta || '</nrdconta>' ||
                              '<vlborder>' || vr_tab_dados_borderos(vr_index).vlborder || '</vlborder>' ||
                              '<dsctrlim>' || 'Desconto de Título' || '</dsctrlim>' ||
                              '<dsinsbdt>' || fn_busca_situacao_bordero(vr_tab_dados_borderos(vr_index).insitbdt) || '</dsinsbdt>' ||
                              '<dsinsapr>' || fn_busca_decisao_bordero(vr_tab_dados_borderos(vr_index).insitapr) || '</dsinsapr>' ||
                              '<insitbdt>' || vr_tab_dados_borderos(vr_index).insitbdt || '</insitbdt>' ||
                              '<insitapr>' || vr_tab_dados_borderos(vr_index).insitapr || '</insitapr>' ||
                              '<cdoperad>' || nvl(vr_tab_dados_borderos(vr_index).cdoperad,'Internet') || '</cdoperad>' || --caso não tenha, mostrar 'internet'
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_borderos.next(vr_index);
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
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_buscar_bordero_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   
 END pc_buscar_bordero_web;
 
 PROCEDURE pc_buscar_titulos_resgate (pr_cdcooper IN craptdb.cdcooper%TYPE --> Cooperativa
                                      ,pr_nrdconta IN craptdb.nrdconta%TYPE --> Número da Conta
                                      ,pr_nrborder IN crapbdt.nrborder%TYPE --> Número do boleto
                                      -->OUT<--
                                      ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                                      ,pr_tab_dados_titulos OUT typ_tab_dados_titulos         --> Resultado da consulta
                                      ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulos_resgate
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna os títulos passíveis de análise na esteira de determinado bordero
  ---------------------------------------------------------------------------------------------------------------------*/
   -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   vr_exc_erro EXCEPTION;
    
   CURSOR cr_craptdb IS
     SELECT
          sab.nmdsacad,
          sab.nrcelsac,
          cob.nrnosnum,
          tdb.vltitulo,
          tdb.dtvencto,
          fn_liquidez_pagador_cedente(pr_cdcooper,pr_nrdconta,sab.nrinssac,sab.cdtpinsc) AS nrliqpag,
          fn_concentracao_titulo_pagador(pr_cdcooper,pr_nrdconta,sab.nrinssac) AS nrconcen,
          nvl((SELECT 
                  decode(inpossui_criticas,1,'S','N')
                  FROM 
                   tbdsct_analise_pagador tap 
                WHERE tap.cdcooper=tdb.cdcooper AND tap.nrdconta=tdb.nrdconta AND tap.nrinssac=sab.nrinssac
           ),'A') flgcritdb,
          tdb.nrborder,
          tdb.nrdconta,
          tdb.nrcnvcob,
          tdb.nrdocmto,
          tdb.nrdctabb,
          tdb.cdbandoc,
          tdb.insitmch
     FROM
          craptdb tdb
          INNER JOIN crapcob cob ON cob.cdcooper = tdb.cdcooper AND
                                                    cob.cdbandoc = tdb.cdbandoc AND
                                                    cob.nrdctabb = tdb.nrdctabb AND
                                                    cob.nrdconta = tdb.nrdconta AND
                                                    cob.nrcnvcob = tdb.nrcnvcob AND
                                                    cob.nrdocmto = tdb.nrdocmto
          INNER JOIN crapsab sab ON tdb.cdcooper = sab.cdcooper AND tdb.nrinssac=sab.nrinssac AND tdb.nrdconta = sab.nrdconta
     WHERE
          tdb.cdcooper = pr_cdcooper
          AND tdb.nrdconta = pr_nrdconta
          AND tdb.nrborder = pr_nrborder
          AND tdb.flgenvmc = 1 -- Apenas os enviados para mesa de checagem
     ;
     rw_craptdb cr_craptdb%ROWTYPE;
     
     vr_index PLS_INTEGER;
   BEGIN
     pr_qtregist := 0 ;
     OPEN cr_craptdb;
     LOOP
       	FETCH cr_craptdb INTO rw_craptdb;
        EXIT WHEN cr_craptdb%NOTFOUND;
          pr_qtregist := pr_qtregist + 1;
          vr_index := pr_tab_dados_titulos.count + 1;
          pr_tab_dados_titulos(vr_index).nmdsacad := rw_craptdb.nmdsacad;
          pr_tab_dados_titulos(vr_index).nrcelsac := rw_craptdb.nrcelsac;
          pr_tab_dados_titulos(vr_index).nrnosnum := rw_craptdb.nrnosnum;
          pr_tab_dados_titulos(vr_index).vltitulo := rw_craptdb.vltitulo;
          pr_tab_dados_titulos(vr_index).dtvencto := rw_craptdb.dtvencto;
          pr_tab_dados_titulos(vr_index).nrliqpag := rw_craptdb.nrliqpag;
          pr_tab_dados_titulos(vr_index).nrconcen := rw_craptdb.nrconcen;
          pr_tab_dados_titulos(vr_index).flgcritdb:= rw_craptdb.flgcritdb;      
          pr_tab_dados_titulos(vr_index).nrborder := rw_craptdb.nrborder;
          pr_tab_dados_titulos(vr_index).nrdconta := rw_craptdb.nrdconta;
          pr_tab_dados_titulos(vr_index).nrcnvcob := rw_craptdb.nrcnvcob;
          pr_tab_dados_titulos(vr_index).nrdocmto := rw_craptdb.nrdocmto;
          pr_tab_dados_titulos(vr_index).nrdctabb := rw_craptdb.nrdctabb;
          pr_tab_dados_titulos(vr_index).cdbandoc := rw_craptdb.cdbandoc;
          pr_tab_dados_titulos(vr_index).insitmch := rw_craptdb.insitmch;
     END LOOP;
     
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
           pr_dscritic := 'erro nao tratado na tela_atenda_dscto_tit.pc_buscar_titulos_resgate ' ||sqlerrm;
           
 END pc_buscar_titulos_resgate; 
 
 PROCEDURE pc_buscar_titulos_resgate_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
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

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
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

      pc_buscar_titulos_resgate(vr_cdcooper         --> Código da Cooperativa
                        ,pr_nrdconta        --> Número da Conta
                        ,pr_nrborder        --> Número do Borderô
                        --------> OUT <--------
                        ,vr_qtregist        --> Quantidade de registros encontrados
                        ,vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                        ,vr_cdcritic        --> Código da crítica
                        ,vr_dscritic        --> Descrição da crítica
                        );
      
      IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
        raise vr_exc_erro;
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
                              '<nmdsacad>' || vr_tab_dados_titulos(vr_index).nmdsacad || '</nmdsacad>' ||
                              '<nrcelsac>' || vr_tab_dados_titulos(vr_index).nrcelsac || '</nrcelsac>' ||
                              '<nrnosnum>' || vr_tab_dados_titulos(vr_index).nrnosnum || '</nrnosnum>' ||
                              '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                              '<dtvencto>' ||to_char( vr_tab_dados_titulos(vr_index).dtvencto,'dd/mm/rrrr') || '</dtvencto>' ||
                              '<nrliqpag>' || vr_tab_dados_titulos(vr_index).nrliqpag || '</nrliqpag>' ||
                              '<nrconcen>' || vr_tab_dados_titulos(vr_index).nrconcen || '</nrconcen>' ||
                              '<flgcritdb>' || vr_tab_dados_titulos(vr_index).flgcritdb || '</flgcritdb>' ||
                              '<nrborder>' || vr_tab_dados_titulos(vr_index).nrborder || '</nrborder>' ||
                              '<nrdconta>' || vr_tab_dados_titulos(vr_index).nrdconta || '</nrdconta>' ||
                              '<nrcnvcob>' || vr_tab_dados_titulos(vr_index).nrcnvcob || '</nrcnvcob>' ||
                              '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                              '<nrdctabb>' || vr_tab_dados_titulos(vr_index).nrdctabb || '</nrdctabb>' ||
                              '<cdbandoc>' || vr_tab_dados_titulos(vr_index).cdbandoc || '</cdbandoc>' ||
                              '<insitmch>' || vr_tab_dados_titulos(vr_index).insitmch || '</insitmch>' ||
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
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_buscar_titulos_resgate_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   
 END pc_buscar_titulos_resgate_web;
 
 PROCEDURE pc_verifica_status_bordero_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_verifica_status_bordero_web
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna os dados do bordero, incluindo se algum operador esta alterandoo
  ---------------------------------------------------------------------------------------------------------------------*/
                             
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
    -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   CURSOR cr_crapbdt IS
     SELECT
          crapbdt.nrborder,
          crapbdt.nrdconta,
          crapbdt.insitbdt,
          crapbdt.insitapr,
          crapope.nmoperad,
          crapope.cdoperad,
          crapbdt.dtenvmch
     FROM
          crapbdt
          LEFT JOIN crapope ON crapope.cdcooper = crapbdt.cdcooper AND crapope.cdoperad = crapbdt.cdopeapr
     WHERE
          crapbdt.nrborder = pr_nrborder
          AND crapbdt.nrdconta = pr_nrdconta
          AND crapbdt.cdcooper = vr_cdcooper;
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

     IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
       raise vr_exc_erro;
     END IF;
     -- inicializar o clob
     vr_des_xml := null;
     dbms_lob.createtemporary(vr_des_xml, true);
     dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     -- inicilizar as informaçoes do xml
     vr_texto_completo := null;
     
     OPEN cr_crapbdt;
     FETCH cr_crapbdt INTO rw_crapbdt;
     IF (cr_crapbdt%NOTFOUND) THEN
       vr_dscritic := 'Erro ao encontrar o borderô';
       raise vr_exc_erro;
     END IF;
     pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                    '<root><dados>');
                    
     -- ler os registros de titulos e inclui
     pc_escreve_xml('<bordero>'||
                      '<nrborder>' || rw_crapbdt.nrborder || '</nrborder>' ||
                      '<nrdconta>' || rw_crapbdt.nrdconta || '</nrdconta>' ||
                      '<insitbdt>' || rw_crapbdt.insitbdt || '</insitbdt>' ||
                      '<insitapr>' || rw_crapbdt.insitapr || '</insitapr>' ||
                      '<nmoperad>' || rw_crapbdt.nmoperad || '</nmoperad>' ||
                      '<cdoperad>' || rw_crapbdt.cdoperad || '</cdoperad>' ||
                      '<dsinsbdt>' || fn_busca_situacao_bordero(rw_crapbdt.insitbdt) || '</dsinsbdt>' ||
                      '<dsinsapr>' || fn_busca_decisao_bordero(rw_crapbdt.insitapr) || '</dsinsapr>' ||
                      '<dtenvmch>' || to_char(rw_crapbdt.dtenvmch,'dd/mm/rrrr') || '</dtenvmch>' ||
                    '</bordero>'
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
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_buscar_titulos_resgate_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   
 END pc_verifica_status_bordero_web;
 
 PROCEDURE pc_atualiza_checagem_operador (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_atualiza_checagem_operador
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que atualiza no bordero o operador que esta fazendo a checagem
  ---------------------------------------------------------------------------------------------------------------------*/
                             
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
    -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   
   CURSOR cr_crapbdt IS
     SELECT
          crapbdt.nrborder,
          crapbdt.nrdconta,
          crapbdt.insitbdt,
          crapbdt.insitapr
     FROM
          crapbdt
     WHERE
          crapbdt.nrborder = pr_nrborder
          AND crapbdt.nrdconta = pr_nrdconta
          AND crapbdt.cdcooper = vr_cdcooper;
   rw_crapbdt cr_crapbdt%rowtype;
   
   CURSOR cr_crapope (pr_cdoperad crapope.cdoperad%TYPE) IS
     SELECT
          crapope.cdoperad,
          crapope.nmoperad
     FROM
          crapope
     WHERE 
          crapope.cdcooper = vr_cdcooper
          AND crapope.cdoperad = pr_cdoperad;
   rw_crapope cr_crapope%rowtype;
   
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

     IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
       raise vr_exc_erro;
     END IF;
     -- inicializar o clob
     vr_des_xml := null;
     dbms_lob.createtemporary(vr_des_xml, true);
     dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     -- inicilizar as informaçoes do xml
     vr_texto_completo := null;
     
     OPEN cr_crapbdt;
     FETCH cr_crapbdt INTO rw_crapbdt;
     IF (cr_crapbdt%NOTFOUND) THEN
       vr_dscritic := 'Erro ao encontrar o borderô';
       raise vr_exc_erro;
     END IF;
     IF (rw_crapbdt.insitbdt=1) THEN -- Bordero está aguardando análise
       UPDATE 
        crapbdt
       SET
        crapbdt.cdopeapr = vr_cdoperad,
        crapbdt.insitapr = 2 -- Bordero vai para Checagem
       WHERE
        crapbdt.nrborder = pr_nrborder
        AND crapbdt.nrdconta = pr_nrdconta
        AND crapbdt.cdcooper = vr_cdcooper;
     END IF;
     
     OPEN cr_crapope (vr_cdoperad);
     FETCH cr_crapope INTO rw_crapope;
     
     
     pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                    '<root><dados>');
                    
     -- ler os registros de titulos e inclui
     pc_escreve_xml('<operador>' ||
                         '<nmoperad>' || rw_crapope.nmoperad || '</nmoperad>' ||
                    '</operador>');
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
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_buscar_titulos_resgate_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   
 END pc_atualiza_checagem_operador;
 
 PROCEDURE pc_conclui_checagem (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_titulos IN VARCHAR2   --> Número do Borderô                             
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_conclui_checagem
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Conclui o processo da mesa de checagem, atualiza o bordero e os titulos
  ---------------------------------------------------------------------------------------------------------------------*/
                             
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
    -- Variável de críticas
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   vr_des_erro VARCHAR2(1000);        --> Desc. Erro
   -- Splits de strings   
   vr_tab_cobs  gene0002.typ_split;
   vr_tab_chaves  gene0002.typ_split;
   vr_idtabtitulo number;
   
   -- Update do bordero
   vr_insitbdt crapbdt.insitbdt%TYPE;
   vr_insitapr crapbdt.insitapr%TYPE;
   vr_dtaprova crapbdt.dtaprova%TYPE;
   vr_hraprova crapbdt.hraprova%TYPE;
   vr_cdopeapr crapbdt.cdopeapr%TYPE;
   rw_crapdat  btch0001.rw_crapdat%TYPE;
   vr_em_contingencia_ibratan BOOLEAN;
   vr_aprovar BOOLEAN;
   
   -- Criticas diferentes da do CNAE
   CURSOR cr_craptdb_restri  IS
     SELECT 
       count(1) as totcrit
     FROM 
       craptdb tdb
       INNER JOIN crapabt abt
             ON abt.nrborder = tdb.nrborder
             AND abt.cdcooper = tdb.cdcooper
             AND abt.nrdconta = tdb.nrdconta
             AND abt.nrdocmto = tdb.nrdocmto
     WHERE tdb.cdcooper = vr_cdcooper
         AND tdb.nrdconta = pr_nrdconta
         AND tdb.nrborder = pr_nrborder
         AND (abt.nrseqdig <> 59);
     rw_craptdb_restri cr_craptdb_restri%ROWTYPE;
                                
   CURSOR cr_crapbdt IS
     SELECT
          crapbdt.nrborder,
          crapbdt.nrdconta,
          crapbdt.insitbdt,
          crapbdt.insitapr
     FROM
          crapbdt
     WHERE
          crapbdt.nrborder = pr_nrborder
          AND crapbdt.nrdconta = pr_nrdconta
          AND crapbdt.cdcooper = vr_cdcooper;
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

     IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
       raise vr_exc_erro;
     END IF;
     -- inicializar o clob
     vr_des_xml := null;
     dbms_lob.createtemporary(vr_des_xml, true);
     dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
     -- inicilizar as informaçoes do xml
     vr_texto_completo := null;
     
     OPEN cr_crapbdt;
     FETCH cr_crapbdt INTO rw_crapbdt;
     IF (cr_crapbdt%NOTFOUND) THEN
       vr_dscritic := 'Erro ao encontrar o borderô';
       raise vr_exc_erro;
     END IF;
     
     vr_tab_cobs := gene0002.fn_quebra_string(pr_string  => pr_titulos,
                                                 pr_delimit => ',');
                                                 
     vr_idtabtitulo:=0;
     IF vr_tab_cobs.count() > 0 THEN
       /*Traz 1 linha para cada titulo sendo alterado*/
       vr_index := vr_tab_cobs.first;
       while vr_index is not null loop
         -- Pega a lsita de chaves por titulo
         vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => vr_tab_cobs(vr_index),
                                               pr_delimit => ';');
         IF (vr_tab_chaves.count() > 0) THEN
           UPDATE
            craptdb
           SET
            craptdb.insitmch = decode(vr_tab_chaves(5),'S',1,2),
            craptdb.insitapr = decode(vr_tab_chaves(5),'S',1,2),
            craptdb.cdoriapr = 1
           WHERE
            craptdb.nrborder = pr_nrborder
            AND craptdb.nrdocmto = vr_tab_chaves(4) -- Codigo do boleto
            AND craptdb.nrdctabb = vr_tab_chaves(2) -- Conta base do Banco
            AND craptdb.nrcnvcob = vr_tab_chaves(3) -- Convenio
            AND craptdb.cdbandoc = vr_tab_chaves(1) -- Codigo do Banco
            AND craptdb.nrdconta = pr_nrdconta
            AND craptdb.cdcooper = vr_cdcooper
           ;
           IF (vr_tab_chaves(5)='S') THEN
              vr_aprovar := TRUE;
           END IF;
         END IF;
         vr_index := vr_tab_cobs.next(vr_index);
       end loop;
     END IF;
     
     /*Verifica se aprovou ao menos 1 titulo*/
     vr_dtaprova := rw_crapdat.dtmvtolt;
     vr_hraprova := to_char(SYSDATE, 'SSSSS');
     vr_cdopeapr := vr_cdoperad;
     IF (vr_aprovar) THEN
       /*Atualizar o bordero*/    
       open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
       fetch btch0001.cr_crapdat into rw_crapdat;
       /*Analisa pra onde manda o bordero*/
       OPEN cr_craptdb_restri;
       FETCH cr_craptdb_restri INTO rw_craptdb_restri;
       /*Nao possui criticas diferentes do CNAE, aprova!*/
       IF (cr_craptdb_restri%NOTFOUND OR rw_craptdb_restri.totcrit=0) THEN
         vr_insitbdt := 2;
         vr_insitapr := 4;
       /*Criticas diferentes do CNAE, envia para a esteira*/
       ELSE
         /*!Verifica contingencia*/
         vr_em_contingencia_ibratan := tela_atenda_dscto_tit.fn_em_contingencia_ibratan(pr_cdcooper => vr_cdcooper);
         IF (vr_em_contingencia_ibratan) THEN --em Contingência Aprova
           vr_insitbdt := 2;
           vr_insitapr := 4;
         ELSE
           vr_insitapr := 6;
           dsct0003.pc_envia_esteira (pr_cdcooper => vr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_nrborder => pr_nrborder
                               ,pr_cdagenci => vr_cdagenci
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               --------- OUT ---------
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_des_erro => vr_des_erro
                               ); 
         END IF;
       END IF;
     ELSE /*Nenhum titulo aprovado muda a decisao para nao aprovado*/
       vr_insitbdt := 1;
       vr_insitapr := 5;
     END IF;
     /*FAZ O UPDATE NO BORDERO SETANDO CONFORME AS VARIAVEIS.. SE O INSITBDT FOR 6 IGNORA O UPDATE NO BORDERO*/
     IF (vr_insitapr<>6) THEN
       UPDATE 
        crapbdt
       SET
         insitbdt = vr_insitbdt,
         insitapr = vr_insitapr,
         dtaprova = vr_dtaprova,
         hraprova = vr_hraprova,
         cdopeapr = vr_cdopeapr
       WHERE
         crapbdt.nrborder = pr_nrborder
         AND crapbdt.nrdconta = pr_nrdconta
         AND crapbdt.cdcooper = vr_cdcooper
       ;  
     END IF;
     
     pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                    '<root><dados>');
     -- ler os registros de titulos e inclui
     IF (vr_insitbdt=2) THEN
       IF (vr_insitapr=4 AND vr_em_contingencia_ibratan) THEN
         pc_escreve_xml('Borderô analisado. Esteria de crédito em contingência');
       ELSE
         pc_escreve_xml('Borderô analisado e aprovado com sucesso');
       END IF;
     ELSE 
       IF (vr_insitbdt=1) THEN
         pc_escreve_xml('Borderô não Aprovado.');
       ELSE 
         IF (vr_insitbdt=6) THEN
           pc_escreve_xml('Borderô analisado com sucesso. Processou seguiu para esteria de crédito');
         END IF;
       END IF;
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
           
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      when others then
           /* montar descriçao de erro nao tratado */
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_conclui_checagem ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
   
 END pc_conclui_checagem;
 
 PROCEDURE pc_inserir_parecer(pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_titulos IN VARCHAR2   --> Número do Borderô                             
                             ,pr_dsparecer IN tbdsct_parecer_titulo.dsparecer%TYPE --> Insere parecer
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_inserir_parecer
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Inserir os pareceres dos titulos do bordero na mesa de checagem
  ---------------------------------------------------------------------------------------------------------------------*/
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
    
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    vr_des_erro VARCHAR2(1000);        --> Desc. Erro
  
    vr_tab_chaves  gene0002.typ_split;
    
    
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

       IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN 
         raise vr_exc_erro;
       END IF;
       -- inicializar o clob
       vr_des_xml := null;
       dbms_lob.createtemporary(vr_des_xml, true);
       dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
       -- inicilizar as informaçoes do xml
       vr_texto_completo := null;  
      
      vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => pr_titulos,
                                               pr_delimit => ';');
         IF (vr_tab_chaves.count() > 0) THEN
           
            INSERT INTO tbdsct_parecer_titulo parecer(
                   parecer.cdcooper,
                   parecer.nrdconta,
                   parecer.nrborder,
                   parecer.cdbandoc,
                   parecer.nrdctabb,
                   parecer.nrcnvcob,
                   parecer.nrdocmto,
                   parecer.dsparecer,
                   parecer.dtparecer,
                   parecer.hrparecer,
                   parecer.cdoperad
            )VALUES(
                    vr_cdcooper,
                    pr_nrdconta,
                    pr_nrborder,
                    vr_tab_chaves(1), -- Codigo do Banco
                    vr_tab_chaves(2), -- Conta base do Banco
                    vr_tab_chaves(3), -- Convenio
                    vr_tab_chaves(4), -- Codigo do boleto        
                    pr_dsparecer,
                    trunc(sysdate),
                    to_char(sysdate,'SSSSS'),
                    vr_cdoperad   
            );
            
         END IF;
         
         pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                    '<root><dados>');
         -- ler os registros de titulos e inclui
        
         pc_escreve_xml('Descrição do parecer inserido com sucesso!');
         
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
           pr_dscritic := 'erro nao tratado na tela_aprdes.pc_conclui_checagem ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
 END pc_inserir_parecer;

 PROCEDURE pc_detalhes_titulo (pr_cdcooper       in crapcop.cdcooper%type   --> Cooperativa conectada
                                         ,pr_nrdconta           in crapass.nrdconta%type   --> Conta do associado
                                         ,pr_nrborder           in crapbdt.nrborder%TYPE   --> Número do bordero
                                         ,pr_chave              in VARCHAR2                --> Chave do titulo
                                         ,pr_nrinssac           out crapsab.nrinssac%TYPE   --> Inscrição do sacado
                                         ,pr_nmdsacad           out crapsab.nmdsacad%TYPE   --> Nome do Sacado
                                         ,pr_tab_dados_biro     out  typ_tab_dados_biro    --> Tabela de retorno biro
                                         ,pr_tab_dados_detalhe  out  typ_tab_dados_detalhe --> Tabela de retorno detalhe
                                         ,pr_tab_dados_critica  out  typ_tab_dados_critica --> Tabela de retorno critica
                                         ,pr_tab_dados_parecer  out  typ_tab_dados_parecer --> Tabela de retorno parecer
                                         ,pr_cdcritic           out pls_integer            --> Codigo da critica
                                         ,pr_dscritic           out varchar2               --> Descricao da critica
                                         ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_detalhes_titulo
    Sistema  : CRED
    Sigla    : TELA_APRDES
    Autor    : Luis Fernando (GFT)
    Data     : Abril/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Traz os dados do titulo com restricoes, criticas e os pareceres
  ---------------------------------------------------------------------------------------------------------------------*/
  
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
   
    -- Titulos (Boletos de Cobrança)
    CURSOR cr_crapcob (pr_nrdocmto IN crapcob.nrdocmto%TYPE,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE, pr_nrdctabb IN crapcob.nrdctabb%TYPE, pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS 
    SELECT cob.cdcooper, 
           cob.nrdconta,
           cob.nrinssac,
           cob.nrnosnum,
           cob.cdtpinsc, -- Tipo Pesso do Pagador (0-Nenhum/1-CPF/2-CNPJ)
           sab.nmdsacad
    FROM   crapcob cob
           INNER JOIN crapsab sab ON sab.nrinssac=cob.nrinssac AND sab.cdtpinsc=cob.cdtpinsc
    WHERE  cob.cdcooper = pr_cdcooper -- Cooperativa
          AND cob.nrdconta = pr_nrdconta
          AND cob.cdbandoc = pr_cdbandoc
          AND cob.nrdctabb = pr_nrdctabb
          AND cob.nrcnvcob = pr_nrcnvcob
          AND cob.nrdocmto = pr_nrdocmto
    AND    cob.incobran=0;
    rw_crapcob cr_crapcob%rowtype; 
   
   CURSOR cr_tbdsct_parecer_titulo (pr_nrdocmto IN crapcob.nrdocmto%TYPE,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE, pr_nrdctabb IN crapcob.nrdctabb%TYPE, pr_cdbandoc IN crapcob.cdbandoc%TYPE) IS
     SELECT
          tbdsct_parecer_titulo.dsparecer,
          tbdsct_parecer_titulo.dtparecer,
          crapope.nmoperad
     FROM
          tbdsct_parecer_titulo
          INNER JOIN crapope ON  tbdsct_parecer_titulo.cdoperad=crapope.cdoperad AND tbdsct_parecer_titulo.cdcooper=crapope.cdcooper
     WHERE
          tbdsct_parecer_titulo.cdcooper = pr_cdcooper
          AND tbdsct_parecer_titulo.nrdconta = pr_nrdconta
          AND tbdsct_parecer_titulo.nrborder = pr_nrborder
          AND tbdsct_parecer_titulo.cdbandoc = pr_cdbandoc
          AND tbdsct_parecer_titulo.nrdctabb = pr_nrdctabb
          AND tbdsct_parecer_titulo.nrcnvcob = pr_nrcnvcob
          AND tbdsct_parecer_titulo.nrdocmto = pr_nrdocmto
     ORDER BY tbdsct_parecer_titulo.dtparecer DESC
          ;
    rw_tbdsct_parecer_titulo cr_tbdsct_parecer_titulo%ROWTYPE;
   
   
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
   vr_tab_chaves  gene0002.typ_split;
   vr_index     PLS_INTEGER;
    
   BEGIN
      vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => pr_chave,
                                             pr_delimit => ';');
      OPEN cr_crapcob(vr_tab_chaves(4), -- Conta
                       vr_tab_chaves(3), -- Convenio
                       vr_tab_chaves(2), -- Conta base do banco
                       vr_tab_chaves(1)  -- Codigo do banco
                       );
      FETCH cr_crapcob INTO rw_crapcob;

      vr_nrinssac := rw_crapcob.nrinssac;
      vr_cdtpinsc := rw_crapcob.cdtpinsc;
      pr_nrinssac := rw_crapcob.nrinssac;
      pr_nmdsacad := rw_crapcob.nmdsacad;
      
      --> Lista de pareceres
      OPEN cr_tbdsct_parecer_titulo (vr_tab_chaves(4), -- Conta
                       vr_tab_chaves(3), -- Convenio
                       vr_tab_chaves(2), -- Conta base do banco
                       vr_tab_chaves(1)  -- Codigo do banco
                       );
      vr_index:=0;
      LOOP
      FETCH cr_tbdsct_parecer_titulo INTO rw_tbdsct_parecer_titulo;
      EXIT WHEN cr_tbdsct_parecer_titulo%NOTFOUND;
           pr_tab_dados_parecer(vr_index).dsparecer := rw_tbdsct_parecer_titulo.dsparecer;
           pr_tab_dados_parecer(vr_index).nmoperad  := rw_tbdsct_parecer_titulo.nmoperad;
           pr_tab_dados_parecer(vr_index).dtparecer := rw_tbdsct_parecer_titulo.dtparecer;
           vr_index:=vr_index+1;
      END LOOP;
      CLOSE cr_tbdsct_parecer_titulo;
      
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
      
      --> Preenche liquidez e concentração
      pr_tab_dados_detalhe(0).liqpagcd := fn_liquidez_pagador_cedente(pr_cdcooper,pr_nrdconta,vr_nrinssac,vr_cdtpinsc);
      pr_tab_dados_detalhe(0).concpaga := fn_concentracao_titulo_pagador(pr_cdcooper,pr_nrdconta,vr_nrinssac);
      pr_tab_dados_detalhe(0).liqgeral := fn_liquidez_geral(pr_cdcooper,pr_nrdconta,vr_nrinssac,vr_cdtpinsc);
      
      --> CRÍTICAS DO PAGADOR (JOB - ANÁLISE PAGADOR)
      vr_idtabcritica := 0;
      OPEN  cr_analise_pagador;
      FETCH cr_analise_pagador INTO rw_analise_pagador;
      CLOSE cr_analise_pagador;                   
      
      IF rw_analise_pagador.inpossui_criticas > 0 THEN

        -- qtremessa_cartorio -> Crítica: Qtd Remessa em Cartório acima do permitido. (Ref. TAB052: qtremcrt).
        IF rw_analise_pagador.qtremessa_cartorio > 0 THEN
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd Remessa em Cartório acima do permitido'; 
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qtremessa_cartorio;
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        END IF;
              
        -- qttit_protestados -> Crítica: Qtd de Títulos Protestados acima do permitido. (Ref. TAB052: qttitprt).
        if rw_analise_pagador.qttit_protestados > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd de Títulos Protestados acima do permitido'; 
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qttit_protestados; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- qttit_naopagos -> Crítica: Qtd de Títulos Não Pagos pelo Pagador acima do permitido. (Ref. TAB052: qtnaopag).
        if rw_analise_pagador.qttit_naopagos > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Qtd de Títulos Não Pagos pelo Pagador acima do permitido';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.qttit_naopagos; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- pemin_liquidez_qt -> Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos).  (Ref. TAB052: qttliqcp).
        if rw_analise_pagador.pemin_liquidez_qt > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Qtd. de Títulos)';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.pemin_liquidez_qt; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- pemin_liquidez_vl -> Crítica: Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos).  (Ref. TAB052: vltliqcp).
        if rw_analise_pagador.pemin_liquidez_vl > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Mínimo de Liquidez Cedente x Pagador abaixo do permitido (Valor dos Títulos)';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.pemin_liquidez_vl; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
             
        -- peconcentr_maxtit -> Crítica: Perc. Concentração Máxima Permitida de Títulos excedida. (Ref. TAB052: pcmxctip).
        if rw_analise_pagador.peconcentr_maxtit > 0.0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Perc. Concentração Máxima Permitida de Títulos excedida';
           pr_tab_dados_critica(vr_idtabcritica).varper := rw_analise_pagador.peconcentr_maxtit; 
           pr_tab_dados_critica(vr_idtabcritica).varint := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- inemitente_conjsoc -> Crítica: Emitente é Cônjuge/Sócio do Pagador (0 = Não / 1 = Sim). (Ref. TAB052: flemipar).
        if rw_analise_pagador.inemitente_conjsoc > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Emitente é Cônjuge/Sócio do Pagador.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.inemitente_conjsoc;
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        end if;
              
        -- inpossui_titdesc -> Crítica: Cooperado possui Títulos Descontados na Conta deste Pagador  (0 = Não / 1 = Sim). (Ref. TAB052: flpdctcp).
        if rw_analise_pagador.inpossui_titdesc > 0 then
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Cooperado possui Títulos Descontados na Conta deste Pagador.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.inpossui_titdesc; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        END IF;
              
        -- invalormax_cnae -> Crítica: Valor Máximo Permitido por CNAE excedido (0 = Não / 1 = Sim). (Ref. TAB052: vlmxprat).
        IF rw_analise_pagador.invalormax_cnae > 0 THEN
           pr_tab_dados_critica(vr_idtabcritica).dsc := 'Valor Máximo Permitido por CNAE excedido.';
           pr_tab_dados_critica(vr_idtabcritica).varint := rw_analise_pagador.invalormax_cnae; 
           pr_tab_dados_critica(vr_idtabcritica).varper := 0;
           vr_idtabcritica := vr_idtabcritica + 1;
        END IF;
      END IF;

 END pc_detalhes_titulo;
 
 PROCEDURE pc_detalhes_titulo_web (pr_nrdconta    in crapass.nrdconta%type --> conta do associado
                                        ,pr_nrborder           in crapbdt.nrborder%TYPE   --> Número do bordero
                                        ,pr_chave              in VARCHAR2                --> Chave do titulo
                                        ,pr_xmllog      in varchar2              --> xml com informações de log
                                         --------> out <--------
                                        ,pr_cdcritic out pls_integer             --> código da crítica
                                        ,pr_dscritic out varchar2                --> descrição da crítica
                                        ,pr_retxml   in out nocopy xmltype       --> arquivo de retorno do xml
                                        ,pr_nmdcampo out varchar2                --> nome do campo com erro
                                        ,pr_des_erro out varchar2                --> erros do processo
                                         ) IS
 
    -- variaveis de retorno       
    vr_tab_dados_biro         typ_tab_dados_biro;
    vr_tab_dados_detalhe      typ_tab_dados_detalhe;
    vr_tab_dados_critica      typ_tab_dados_critica;
    vr_tab_dados_parecer      typ_tab_dados_parecer;
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
        
    vr_index_biro    pls_integer;
    vr_index_detalhe pls_integer;
    vr_index_critica pls_integer;
    vr_index_parecer pls_integer;
        
    -- variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> cód. erro
    vr_dscritic varchar2(1000);        --> desc. erro
         
    -- variaveis para verificar criticas e situacao
    vr_ibratan integer;
    vr_situacao char(1);
   
    -- variabel tab valor critica
    vr_tag_crit varchar2(1000);        --> desc. erro
    
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

                           
                           
      pc_detalhes_titulo(vr_cdcooper    --> código da cooperativa
                       ,pr_nrdconta     --> Numero da Conta
                       ,pr_nrborder     --> Numero do Bordero
                       ,pr_chave        --> Chave unica do titulo
                       --------> out <--------
                       ,vr_nrinssac          --> Inscricao do sacado
                       ,vr_nmdsacad          --> Nome do sacado
                       ,vr_tab_dados_biro    -->  retorno do biro
                       ,vr_tab_dados_detalhe -->  retorno dos detalhes
                       ,vr_tab_dados_critica --> retorno das criticas
                       ,vr_tab_dados_parecer --> retorno das parecer
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
                        '<concpaga>'  || vr_tab_dados_detalhe(0).concpaga || '</concpaga>' ||
                        '<liqpagcd>'  || vr_tab_dados_detalhe(0).liqpagcd || '</liqpagcd>'  ||
                        '<liqgeral>'  || vr_tab_dados_detalhe(0).liqgeral || '</liqgeral>' ||
                     '</detalhe>'
      );
      
      
      -- ler os registros do parecer e incluir no xml
      vr_index_parecer := vr_tab_dados_parecer.first;
      pc_escreve_xml('<pareceres>');
      while vr_index_parecer is not null loop  
          pc_escreve_xml('<parecer>');
          pc_escreve_xml('<dsparecer>' || vr_tab_dados_parecer(vr_index_parecer).dsparecer || '</dsparecer>');
          pc_escreve_xml('<nmoperad>' || vr_tab_dados_parecer(vr_index_parecer).nmoperad || '</nmoperad>');
          pc_escreve_xml('<dtparecer>' || to_char(vr_tab_dados_parecer(vr_index_parecer).dtparecer,'dd/mm/rrrr') || '</dtparecer>');
          vr_index_parecer := vr_tab_dados_parecer.next(vr_index_parecer);
          pc_escreve_xml('</parecer>');
      end loop;
      pc_escreve_xml('</pareceres>');
          
          
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
 
 
 END pc_detalhes_titulo_web;
 
end TELA_APRDES;
/
