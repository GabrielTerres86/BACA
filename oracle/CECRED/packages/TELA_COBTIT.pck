create or replace package cecred.TELA_COBTIT is
 /* ---------------------------------------------------------------------------------------------------------------

    Programa : TELA_COBTIT
    Sistema  : Cred
    Autor    : Luis Fernando (GFT)
    Data     : 22/05/2018

   Dados referentes ao programa:

   Frequencia: Sempre que chamado
   Objetivo  : Package contendo as procedures da tela COBTIT (Cobrança de títulos vencidos)

 */

  /*Tabela de retorno dos titulos do bordero*/
  TYPE typ_rec_dados_borderos
       IS RECORD (dtmvtolt crapbdt.dtmvtolt%TYPE,
                  nrborder crapbdt.nrborder%TYPE,
                  nrdconta crapbdt.nrdconta%TYPE,
                  qtaprova INTEGER,
                  vlaprova NUMBER,
                  qtvencid INTEGER,
                  vlvencid NUMBER,
                  nrctrlim crapbdt.nrctrlim%TYPE,
                  dtlibbdt crapbdt.dtlibbdt%TYPE,
                  flavalis INTEGER
                  );

  TYPE typ_tab_dados_borderos IS TABLE OF typ_rec_dados_borderos INDEX BY BINARY_INTEGER;
  
  /*Tabela de retorno dos titulos do log*/
  TYPE typ_rec_dados_log
       IS RECORD (dtaltera crapcol.dtaltera%TYPE,
                  hrtransa crapcol.hrtransa%TYPE,
                  dslogtit crapcol.dslogtit%TYPE,
                  cdoperad crapcol.cdoperad%TYPE,
                  nmoperad VARCHAR2(4000)
                  );

  TYPE typ_tab_dados_log IS TABLE OF typ_rec_dados_log INDEX BY BINARY_INTEGER;
  
  TYPE typ_rec_dados_feriados
       IS RECORD (dtferiad crapfer.dtferiad%TYPE
                 ,cdcooper crapfer.cdcooper%TYPE
                 ,tpferiad crapfer.tpferiad%TYPE
                 ,dsferiad crapfer.dsferiad%TYPE
                 );

  TYPE typ_tab_dados_feriados IS TABLE OF typ_rec_dados_feriados INDEX BY BINARY_INTEGER;
       
  TYPE typ_rec_dados_vencidos 
       IS RECORD (nrtitulo craptdb.nrtitulo%TYPE
                  ,nrborder craptdb.nrborder%TYPE
                  ,vlapagar NUMBER
                  );
  TYPE typ_tab_dados_vencidos IS TABLE OF typ_rec_dados_vencidos INDEX BY BINARY_INTEGER;
  
   --Tipo de Registro para Parametros da cobemp
  TYPE typ_reg_cobemp IS RECORD
    (nrconven       crapprm.dsvlrprm%TYPE
    ,nrdconta       crapprm.dsvlrprm%TYPE
    ,pzmaxvct       crapprm.dsvlrprm%TYPE
		,pzbxavct       crapprm.dsvlrprm%TYPE
		,vlrminpp       crapprm.dsvlrprm%TYPE
		,vlrmintr       crapprm.dsvlrprm%TYPE
		,dslinha1       crapprm.dsvlrprm%TYPE
		,dslinha2       crapprm.dsvlrprm%TYPE
		,dslinha3       crapprm.dsvlrprm%TYPE
		,dslinha4       crapprm.dsvlrprm%TYPE
		,dstxtsms       crapprm.dsvlrprm%TYPE
		,dstxtema       crapprm.dsvlrprm%TYPE
		,blqemibo       crapprm.dsvlrprm%TYPE
		,qtmaxbol       crapprm.dsvlrprm%TYPE
		,blqrsgcc       crapprm.dsvlrprm%TYPE
		,descprej       crapprm.dsvlrprm%TYPE);

	TYPE typ_reg_cde IS RECORD
		(cdcooper       tbrecup_cobranca.cdcooper%TYPE
		,cdagenci       crapass.cdagenci%TYPE
		,nrborder       tbrecup_cobranca.nrctremp%TYPE
		,nrdconta       tbrecup_cobranca.nrdconta%TYPE
		,nrcnvcob       tbrecup_cobranca.nrcnvcob%TYPE
		,nrdocmto       tbrecup_cobranca.nrboleto%TYPE
		,dtmvtolt       crapcob.dtmvtolt%TYPE
		,dtvencto       crapcob.dtvencto%TYPE
		,vlboleto       crapcob.vldpagto%TYPE
		,dtdpagto       crapcob.dtdpagto%TYPE
		,vldpagto       crapcob.vldpagto%TYPE
		,dstipenv       VARCHAR2(20)
		,cdopeenv       tbrecup_cobranca.cdoperad_envio%TYPE
		,dtdenvio       tbrecup_cobranca.dhenvio%TYPE
		,dsdenvio       VARCHAR(60)
		,dssituac       VARCHAR(20)
		,dtdbaixa       crapcob.dtdbaixa%TYPE
		,dsdemail       tbrecup_cobranca.dsemail%TYPE
		,dsdtelef       VARCHAR(20)
		,nmpescto       tbrecup_cobranca.nmcontato%TYPE
		,nrctacob       tbrecup_cobranca.nrdconta_cob%TYPE
    ,lindigit       VARCHAR(60)
    ,dsparcel       tbrecup_cobranca.dsparcelas%TYPE);

  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_cde IS TABLE OF typ_reg_cde INDEX BY BINARY_INTEGER;
  
  PROCEDURE pc_buscar_bordero_vencido (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimentacao
                             -->OUT<--
                             ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                             ,pr_tab_dados_bordero OUT typ_tab_dados_borderos         --> Resultado da consulta
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             );

 PROCEDURE pc_buscar_bordero_vencido_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nriniseq IN INTEGER                 --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER                 --> Numero de registros p/ paginaca
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

 PROCEDURE pc_listar_feriados_web (pr_dtmvtolt IN VARCHAR2  --> Data de movimentação atual
                             ,pr_dtfinal IN VARCHAR2                 --> Data final para checagem dos feriados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );

 PROCEDURE pc_buscar_titulo_vencido_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do Bordero
                                        ,pr_dtvencto IN VARCHAR2               --> Data de vencimento do boleto a ser gerado
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             );
             
 PROCEDURE pc_gerar_boleto_web (pr_nrdconta IN crapbdt.nrdconta%TYPE   --> Número da conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_nrtitulo IN VARCHAR2                --> Números e valores a serem pagos
                             ,pr_dtvencto IN VARCHAR2                --> Data de vencimento que o boleto será geradoleto a ser gerado
                             ,pr_nrcpfava IN  crapass.nrcpfcgc%TYPE  --> Cpf do avalisa. Null se for o proprio sacado
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                           );
                           
 PROCEDURE pc_lista_avalista_web (pr_nrdconta IN craplim.nrdconta%TYPE
                              ,pr_nrborder IN crapbdt.nrborder%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo 
                              );
                              
 PROCEDURE pc_verifica_gerar_boleto (pr_cdcooper IN crapcop.cdcooper%TYPE                   --> Cód. cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																	 	 ,pr_nrborder IN crapbdt.nrborder%TYPE                   --> Nr. do Bordero
                                     ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                                     );

 PROCEDURE pc_buscar_email_web(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_buscar_telefone_web(pr_nrdconta IN INTEGER
                              ,pr_flcelula IN INTEGER DEFAULT 0 --> Define se é apenas celular ou tudo           
                              ,pr_nriniseq IN INTEGER DEFAULT 1 --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER DEFAULT 15 --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);
                              
  PROCEDURE pc_lista_pa_web(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2);
                       
 PROCEDURE pc_buscar_boletos_web (pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0         --> PA
                              ,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0  --> Nr. do Bordero
                              ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
                              ,pr_dtbaixai IN VARCHAR2                                --> Data de baixa inicial
                              ,pr_dtbaixaf IN VARCHAR2                                --> Data de baixa final
                              ,pr_dtemissi IN VARCHAR2                                --> Data de emissão inicial
                              ,pr_dtemissf IN VARCHAR2                                --> Data de emissão final
                              ,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
                              ,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
                              ,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
                              ,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
                              ,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);                           --> Erros do processo
                              
  PROCEDURE pc_baixa_boleto_web(pr_nrdconta IN crapepr.nrdconta%TYPE  --> Nr. da conta
                              ,pr_nrborder IN crapepr.nrctremp%TYPE  --> Nr. do bordero
                              ,pr_nrctacob IN crapepr.nrdconta%TYPE  --> Nr. da conta cobrança
                              ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE  --> Nr. convenio
                              ,pr_nrdocmto IN crapcob.nrdocmto%TYPE  --> Nr. documento
                              ,pr_dtmvtolt IN VARCHAR2               --> Data de movimento
                              ,pr_dsjustif IN VARCHAR2               --> Justificativa de Baixa
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);            --> Erros do processo
                              
  PROCEDURE pc_gerar_pdf_boleto_web (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
                             ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
                             ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);    

  PROCEDURE pc_enviar_boleto_web (pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
																,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
																,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
																,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
																,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
																,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
																,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
																,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
																,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
																,pr_xmllog   IN VARCHAR2                                  --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER                              --> Código da crítica
																,pr_dscritic OUT VARCHAR2                                 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2                                 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2);
                                
  PROCEDURE pc_busca_texto_sms_web(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);                                                                
                              
  PROCEDURE pc_buscar_log_web(pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER
                         ,pr_nrcnvcob IN INTEGER
                         ,pr_nriniseq IN INTEGER                 --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER                 --> Numero de registros p/ paginaca
                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2);
end TELA_COBTIT;
/
create or replace package body cecred.TELA_COBTIT is
 /* ---------------------------------------------------------------------------------------------------------------

    Programa : TELA_COBTIT
    Sistema  : Cred
    Autor    : Luis Fernando (GFT)
    Data     : 22/05/2018

   Dados referentes ao programa:

   Frequencia: Sempre que chamado
   Objetivo  : Package contendo as procedures da tela COBTIT (Cobrança de títulos vencidos)

 */

 -- Variáveis para armazenar as informações em XML
 vr_des_xml         clob;
 vr_texto_completo  varchar2(32600);
 vr_index           pls_integer;

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

 PROCEDURE pc_buscar_bordero_vencido (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimentacao
                             -->OUT<--
                             ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                             ,pr_tab_dados_bordero OUT typ_tab_dados_borderos         --> Resultado da consulta
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_bordero_vencido
    Sistema  : CRED
    Sigla    : TELA_COBTIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna os borderos com ao menos um título vencido
  ---------------------------------------------------------------------------------------------------------------------*/
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    vr_exc_erro EXCEPTION;

    vr_possui_filtro integer;
    vr_index PLS_INTEGER;
    -- Cursor para trazer os borderôs que possuem titulos vencidos
    CURSOR cr_crapbdt IS
      SELECT * FROM (
        SELECT 
          bdt.dtmvtolt,
          bdt.nrctrlim,
          bdt.nrdconta,
          bdt.nrborder,
          (SELECT COUNT(1) FROM craptdb tdb WHERE tdb.nrborder = bdt.nrborder AND tdb.nrdconta=bdt.nrdconta AND tdb.cdcooper=bdt.cdcooper AND tdb.insitapr=1) AS qtaprova,
          (SELECT SUM(vltitulo) FROM craptdb tdb WHERE tdb.nrborder = bdt.nrborder AND tdb.nrdconta=bdt.nrdconta AND tdb.cdcooper=bdt.cdcooper AND tdb.insitapr=1) AS vlaprova,
          (SELECT COUNT(1) FROM craptdb tdb WHERE tdb.nrborder = bdt.nrborder AND tdb.nrdconta=bdt.nrdconta AND tdb.cdcooper=bdt.cdcooper AND tdb.insittit=4 AND tdb.dtvencto<pr_dtmvtolt) AS qtvencid,
          (SELECT SUM(vltitulo) FROM craptdb tdb WHERE tdb.nrborder = bdt.nrborder AND tdb.nrdconta=bdt.nrdconta AND tdb.cdcooper=bdt.cdcooper AND tdb.insittit=4 AND tdb.dtvencto<pr_dtmvtolt) AS vlvencid,
          bdt.dtlibbdt,
          CASE WHEN (SELECT COUNT(1) FROM craplim WHERE craplim.nrctrlim=bdt.nrctrlim AND craplim.cdcooper = bdt.cdcooper AND craplim.tpctrlim=3 AND (nrctaav1>0 OR nrctaav2>0 OR dscpfav1 IS NOT NULL  OR dscpfav2 IS NOT NULL)) >0 THEN
              1
            ELSE
              0
          END AS flavalis
        FROM 
          crapbdt bdt
        WHERE 
            bdt.cdcooper = pr_cdcooper
            AND bdt.nrdconta = pr_nrdconta
            AND dtlibbdt IS NOT NULL
      )
      WHERE 
        qtvencid >0
    ;
    rw_crapbdt cr_crapbdt%rowtype;
    
    BEGIN
      
      pr_qtregist := 0;
      OPEN cr_crapbdt;
      LOOP
        FETCH cr_crapbdt INTO rw_crapbdt;
        EXIT WHEN cr_crapbdt%NOTFOUND;
        pr_qtregist:=pr_qtregist+1;
        vr_index := pr_tab_dados_bordero.count+1;
        pr_tab_dados_bordero(vr_index).dtmvtolt := rw_crapbdt.dtmvtolt;
        pr_tab_dados_bordero(vr_index).nrborder := rw_crapbdt.nrborder;
        pr_tab_dados_bordero(vr_index).nrctrlim := rw_crapbdt.nrctrlim;
        pr_tab_dados_bordero(vr_index).nrdconta := rw_crapbdt.nrdconta;
        pr_tab_dados_bordero(vr_index).vlaprova := rw_crapbdt.vlaprova;
        pr_tab_dados_bordero(vr_index).qtaprova := rw_crapbdt.qtaprova;
        pr_tab_dados_bordero(vr_index).vlvencid := rw_crapbdt.vlvencid;
        pr_tab_dados_bordero(vr_index).qtvencid := rw_crapbdt.qtvencid;
        pr_tab_dados_bordero(vr_index).dtlibbdt := rw_crapbdt.dtlibbdt;
        pr_tab_dados_bordero(vr_index).flavalis := rw_crapbdt.flavalis;
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
       pr_dscritic := replace(replace('Erro pc_buscar_bordero_vencido: ' || sqlerrm, chr(13)),chr(10));
 END pc_buscar_bordero_vencido;

 PROCEDURE pc_buscar_bordero_vencido_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                             ,pr_nriniseq IN INTEGER                 --> Registro inicial da listagem
                             ,pr_nrregist IN INTEGER                 --> Numero de registros p/ paginaca
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
    
    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;

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
                              
      --    Verifica se a data esta cadastrada
      open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);

      fetch btch0001.cr_crapdat into rw_crapdat;
      if    btch0001.cr_crapdat%notfound then
            close btch0001.cr_crapdat;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
            raise vr_exc_erro;
      end   if;
      close btch0001.cr_crapdat;
      
      
      pc_buscar_bordero_vencido(vr_cdcooper         --> Código da Cooperativa
                        ,pr_nrdconta        --> Número da Conta
                        ,rw_crapdat.dtmvtolt        --> Data de movimentacao
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
                              '<dtmvtolt>' || to_char(vr_tab_dados_borderos(vr_index).dtmvtolt,'dd/mm/rrrr') || '</dtmvtolt>' ||
                              '<nrborder>' || vr_tab_dados_borderos(vr_index).nrborder || '</nrborder>' ||
                              '<nrdconta>' || vr_tab_dados_borderos(vr_index).nrdconta || '</nrdconta>' ||
                              '<vlaprova>' || vr_tab_dados_borderos(vr_index).vlaprova || '</vlaprova>' ||
                              '<qtaprova>' || vr_tab_dados_borderos(vr_index).qtaprova || '</qtaprova>' ||
                              '<qtvencid>' || vr_tab_dados_borderos(vr_index).qtvencid || '</qtvencid>' ||
                              '<vlvencid>' || vr_tab_dados_borderos(vr_index).vlvencid || '</vlvencid>' ||
                              '<nrctrlim>' || vr_tab_dados_borderos(vr_index).nrctrlim || '</nrctrlim>' ||
                              '<dtlibbdt>' || to_char(vr_tab_dados_borderos(vr_index).dtlibbdt,'dd/mm/rrrr') || '</dtlibbdt>' ||
                              '<flavalis>' || vr_tab_dados_borderos(vr_index).flavalis || '</flavalis>' ||
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
           pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_buscar_bordero_vencido_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

 END pc_buscar_bordero_vencido_web;
 
 PROCEDURE pc_listar_feriados (pr_cdcooper IN crapfer.cdcooper%TYPE
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
                              ,pr_dtfinal  IN DATE
                              ,pr_crapfer OUT typ_tab_dados_feriados) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_listar_feriados
    Sistema  : CRED
    Sigla    : TELA_COBTIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Retorna os feriados entre a data de movimentacao e a quantidade de dias a frente
  ---------------------------------------------------------------------------------------------------------------------*/

   CURSOR cr_crapfer IS
     SELECT
       dtferiad,
       cdcooper,
       tpferiad,
       dsferiad
     FROM 
       crapfer
     WHERE 
       crapfer.cdcooper = pr_cdcooper
       AND crapfer.dtferiad >= pr_dtmvtolt
       AND crapfer.dtferiad <= pr_dtfinal
     ORDER BY crapfer.dtferiad;
   rw_crapfer cr_crapfer%ROWTYPE;
   vr_index PLS_INTEGER;
   
   BEGIN
     vr_index := 0;
     OPEN cr_crapfer;
     LOOP
     FETCH cr_crapfer INTO rw_crapfer;
     EXIT WHEN cr_crapfer%NOTFOUND;
       pr_crapfer(vr_index).dtferiad := rw_crapfer.dtferiad;
       pr_crapfer(vr_index).cdcooper := rw_crapfer.cdcooper;
       pr_crapfer(vr_index).tpferiad := rw_crapfer.tpferiad;
       pr_crapfer(vr_index).dsferiad := rw_crapfer.dsferiad;
       vr_index := vr_index+1;
     END LOOP;
 END pc_listar_feriados;

 PROCEDURE pc_listar_feriados_web (pr_dtmvtolt IN VARCHAR2  --> Data de movimentação atual
                             ,pr_dtfinal IN VARCHAR2                 --> Data final para checagem dos feriados
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS

    -- variaveis de retorno
    vr_tab_dados_feriados typ_tab_dados_feriados;

    /* tratamento de erro */
    vr_exc_erro exception;

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
    
    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;
    
    --Tratamento de datas
    vr_dtmvtolt DATE;
    vr_dtfinal  DATE;
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
      
      vr_dtmvtolt:=to_date(pr_dtmvtolt, 'DD/MM/RRRR');
      vr_dtfinal:=to_date(pr_dtfinal, 'DD/MM/RRRR');
      pc_listar_feriados(vr_cdcooper
                        ,vr_dtmvtolt
                        ,vr_dtfinal
                        ,vr_tab_dados_feriados
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
      vr_index := vr_tab_dados_feriados.first;
      while vr_index is not null loop
            pc_escreve_xml('<inf>'||
                              '<dtferiad>' || to_char(vr_tab_dados_feriados(vr_index).dtferiad,'dd/mm/rrrr') || '</dtferiad>' ||
                              '<yyyymmdd>' || to_char(vr_tab_dados_feriados(vr_index).dtferiad,'rrrr/mm/dd') || '</yyyymmdd>' ||
                              '<cdcooper>' || vr_tab_dados_feriados(vr_index).cdcooper || '</cdcooper>' ||
                              '<tpferiad>' || vr_tab_dados_feriados(vr_index).tpferiad || '</tpferiad>' ||
                              '<dsferiad>' || vr_tab_dados_feriados(vr_index).dsferiad || '</dsferiad>' ||
                           '</inf>'
                          );
          /* buscar proximo */
          vr_index := vr_tab_dados_feriados.next(vr_index);
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
           pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_listar_feriados_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

 END pc_listar_feriados_web;
 
 PROCEDURE pc_buscar_titulo_vencido (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrdconta%TYPE   --> Número da conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimentacao
                             ,pr_dtvencto IN DATE                    --> Data de vencimento que o boleto será gerado
                             -->OUT<--
                             ,pr_qtregist  OUT NUMBER                  --> Quantidade de registros
                             ,pr_tab_dados_titulos OUT DSCT0003.typ_tab_tit_bordero         --> Resultado da consulta
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_buscar_titulo_vencido
    Sistema  : CRED
    Sigla    : TELA_COBTIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Função que retorna os titulos vencidos de determinado bordero
  ---------------------------------------------------------------------------------------------------------------------*/
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
    vr_dscritic varchar2(1000);        --> Desc. Erro
    vr_exc_erro EXCEPTION;

    vr_index PLS_INTEGER;
    -- Cursor dos titulos vencidos de um bordero usando a data de movimentacao atual do sistema
    CURSOR cr_craptdb IS
       SELECT  
           (vltitulo - vlsldtit) AS vlpago
           ,tdb.*
       FROM  craptdb tdb
       WHERE    tdb.dtresgat IS NULL      -- Nao resgatado
         AND    tdb.dtlibbdt IS NOT NULL
         AND    tdb.dtdpagto IS NULL      -- Nao pago
         AND    tdb.dtvencto < pr_dtmvtolt --Adicionado 360 apenas para teste, remover
         AND    tdb.nrborder = pr_nrborder
         AND    tdb.nrdconta = pr_nrdconta
         AND    tdb.cdcooper = pr_cdcooper
         AND    tdb.insittit = 4 
         
       ORDER BY tdb.dtvencto ASC, tdb.vltitulo DESC
       ;
    rw_craptdb cr_craptdb%rowtype;
    
    -- Variaveis auxiliares para os valores
    vr_vlmtatit craptdb.vlmtatit%TYPE;
    vr_vlmratit craptdb.vlmratit%TYPE;
    vr_vliofcpl craptdb.vliofcpl%TYPE;
    
    BEGIN
      pr_qtregist := 0;
      OPEN cr_craptdb;
      LOOP
        FETCH cr_craptdb INTO rw_craptdb;
        EXIT WHEN cr_craptdb%NOTFOUND;
        
        dsct0003.pc_calcula_atraso_tit(pr_cdcooper=>pr_cdcooper
                                 ,pr_nrdconta=>pr_nrdconta
                                 ,pr_nrborder=>pr_nrborder
                                 ,pr_cdbandoc=>rw_craptdb.cdbandoc
                                 ,pr_nrdctabb=>rw_craptdb.nrdctabb
                                 ,pr_nrcnvcob=>rw_craptdb.nrcnvcob
                                 ,pr_nrdocmto=>rw_craptdb.nrdocmto
                                 ,pr_dtmvtolt=>pr_dtvencto
                                 ,pr_qtdiaatr=>(pr_dtmvtolt - pr_dtvencto)
                                 ,pr_vlmtatit=>vr_vlmtatit
                                 ,pr_vlmratit=>vr_vlmratit
                                 ,pr_vlioftit=>vr_vliofcpl
                                 ,pr_cdcritic=>vr_cdcritic
                                 ,pr_dscritic=>vr_dscritic);
        
        pr_qtregist:=pr_qtregist+1;
        vr_index := pr_tab_dados_titulos.count+1;
        pr_tab_dados_titulos(vr_index).nrdocmto := rw_craptdb.nrdocmto;
        pr_tab_dados_titulos(vr_index).dtvencto := rw_craptdb.dtvencto;
        pr_tab_dados_titulos(vr_index).nrtitulo := rw_craptdb.nrtitulo;
        pr_tab_dados_titulos(vr_index).vltitulo := rw_craptdb.vltitulo;
        pr_tab_dados_titulos(vr_index).vlpago   := rw_craptdb.vlpago;
        pr_tab_dados_titulos(vr_index).vlmulta  := vr_vlmtatit-rw_craptdb.vlpagmta;
        pr_tab_dados_titulos(vr_index).vlmora   := vr_vlmratit-rw_craptdb.vlpagmra;
        pr_tab_dados_titulos(vr_index).vliof    := vr_vliofcpl-rw_craptdb.vlpagiof;
        pr_tab_dados_titulos(vr_index).vlsldtit := rw_craptdb.vlsldtit;
        pr_tab_dados_titulos(vr_index).vlpagar  := (rw_craptdb.vlsldtit + (vr_vlmtatit-rw_craptdb.vlpagmta) + (vr_vlmratit-rw_craptdb.vlpagmra)+ (vr_vliofcpl-rw_craptdb.vlpagiof));

      END LOOP;

      IF (pr_qtregist=0) THEN
        vr_dscritic := 'Não foram encontrados títulos';
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
       pr_dscritic := replace(replace('Erro pc_buscar_bordero_vencido: ' || sqlerrm, chr(13)),chr(10));
 END pc_buscar_titulo_vencido;

 PROCEDURE pc_buscar_titulo_vencido_web (pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                        ,pr_nrborder IN crapbdt.nrborder%TYPE  --> Número do Bordero
                                        ,pr_dtvencto IN VARCHAR2               --> Data de vencimento do boleto a ser gerado
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                             ) IS

    -- variaveis de retorno
    vr_tab_dados_titulos DSCT0003.typ_tab_tit_bordero;

    /* tratamento de erro */
    vr_exc_erro exception;

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
    
    -- Informações de data do sistema
    rw_crapdat  btch0001.rw_crapdat%TYPE;
    vr_dtvencto DATE;
    
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
                              
      --    Verifica se a data esta cadastrada
      open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      if    btch0001.cr_crapdat%notfound then
            close btch0001.cr_crapdat;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
            raise vr_exc_erro;
      end   if;
      close btch0001.cr_crapdat;
      
      vr_dtvencto:=to_date(pr_dtvencto, 'DD/MM/RRRR');
      
      pc_buscar_titulo_vencido(vr_cdcooper         --> Código da Cooperativa
                        ,pr_nrdconta        --> Número da Conta
                        ,pr_nrborder        --> Número do bordero
                        ,rw_crapdat.dtmvtolt--> Data de movimentacao
                        ,vr_dtvencto        --> Data de vencimento que o boleto será gerado
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
                           '<nrdocmto>' || vr_tab_dados_titulos(vr_index).nrdocmto || '</nrdocmto>' ||
                           '<dtvencto>' || to_char(vr_tab_dados_titulos(vr_index).dtvencto, 'DD/MM/RRRR') || '</dtvencto>' ||
                           '<nrtitulo>' || vr_tab_dados_titulos(vr_index).nrtitulo || '</nrtitulo>' ||
                           '<vltitulo>' || vr_tab_dados_titulos(vr_index).vltitulo || '</vltitulo>' ||
                           '<vlpago>'   || vr_tab_dados_titulos(vr_index).vlpago   || '</vlpago>'   ||
                           '<vlmulta>'  || vr_tab_dados_titulos(vr_index).vlmulta  || '</vlmulta>'  ||
                           '<vlmora>'   || vr_tab_dados_titulos(vr_index).vlmora   || '</vlmora>'   ||
                           '<vliof>'    || vr_tab_dados_titulos(vr_index).vliof    || '</vliof>'    ||
                           '<vlsldtit>' || vr_tab_dados_titulos(vr_index).vlsldtit || '</vlsldtit>' ||
                           '<vlpagar>'  || vr_tab_dados_titulos(vr_index).vlpagar  || '</vlpagar>'  ||
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
           pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_buscar_bordero_vencido_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

 END pc_buscar_titulo_vencido_web;
 
 PROCEDURE pc_gerar_boleto (pr_cdcooper IN crapbdt.cdcooper%TYPE   --> Código da cooperativa
                             ,pr_nrdconta IN crapbdt.nrdconta%TYPE   --> Número da conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_nrcpfava IN  crapass.nrcpfcgc%TYPE  --> Cpf do avalisa. Null se for o proprio sacado
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data de movimentacao
                             ,pr_dtvencto IN DATE                    --> Data de vencimento que o boleto será gerado
                             ,pr_titpagar IN typ_tab_dados_vencidos   --> Número do título,
                             ,pr_nmdatela IN VARCHAR2                    --> Nome da tela
                             ,pr_nmeacao  IN VARCHAR2                    --> Nome da ação
                             ,pr_cdagenci IN VARCHAR2                    --> Agencia de operação
                             ,pr_nrdcaixa IN VARCHAR2                    --> Número do caixa
                             ,pr_idorigem IN VARCHAR2                    --> Identificação de origem
                             ,pr_cdoperad IN VARCHAR2                    --> Operador
                             -->OUT<--
                             ,pr_nrboleto OUT INTEGER                     --> Número do boleto criado
                             ,pr_vltitulo OUT NUMBER                      --> Valor do titulo
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
   
                           ) IS
                           
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_gerar_boleto
    Sistema  : CRED
    Sigla    : TELA_COBTIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Gera boleto para os títulos vencidos selecionados 
  ---------------------------------------------------------------------------------------------------------------------*/
   --Variaveis de erro
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   vr_exc_erro EXCEPTION;
	 vr_des_erro VARCHAR2(3); --> Indicador erro      
    
    -- Cursor para trazer os borderôs que possuem titulos a serem verificados na mesa de checagem
   CURSOR cr_crapbdt IS
     SELECT 
       *
     FROM 
       crapbdt bdt
     WHERE 
         bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrborder = pr_nrborder
   ;
   rw_crapbdt cr_crapbdt%rowtype;
   
   -- Cursor do remetente
   CURSOR cr_crapass IS
      SELECT ass.nrcpfcgc nrcpfcgc
            ,ass.inpessoa inpessoa              
            ,SUBSTR(ass.nmprimtl,1,50) nmprimtl
            ,ass.cdagenci cdagenci
            ,enc.dsendere dsendere
            ,enc.nrendere nrendere
            ,enc.nrcepend nrcepend
            ,SUBSTR(enc.complend,1,40) complend
            ,SUBSTR(enc.nmbairro,1,30) nmbairro
            ,enc.nmcidade nmcidade
            ,enc.cdufende cdufende
        FROM crapass ass
            ,crapenc enc
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND enc.cdcooper = ass.cdcooper
         AND enc.nrdconta = ass.nrdconta
         AND ((enc.tpendass = 10 AND ass.inpessoa = 1)
         OR   (enc.tpendass = 9  AND ass.inpessoa IN (2,3))) /* Residencial */
   ;
   rw_crapass cr_crapass%ROWTYPE;
   
   -- Cursor para busca dos sacados cobrança
   CURSOR cr_crapsab (pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrctabnf IN crapsab.nrdconta%TYPE
                     ,pr_nrinssac IN crapass.nrcpfcgc%TYPE) IS
     SELECT 1
       FROM crapsab sab
     WHERE sab.cdcooper = pr_cdcooper
       AND sab.nrdconta = pr_nrctabnf
       AND sab.nrinssac = pr_nrinssac;
   rw_crapsab cr_crapsab%ROWTYPE;
   --Variaveis locais
   vr_index PLS_INTEGER;
   vr_index_tit PLS_INTEGER;
   vr_nrdconta_cob crapsab.nrdconta%TYPE;
   vr_nrcnvcob crapcob.nrcnvcob%TYPE;
   vr_tab_cob cobr0005.typ_tab_cob;
   vr_vlmintit craptdb.vltitulo%TYPE; 
   vr_qtregist         number;   
   vr_tab_dados_titulos DSCT0003.typ_tab_tit_bordero;
   vr_dsinform          VARCHAR2(400);
   vr_dstitulo          VARCHAR2(200);
   vr_vltitulo          NUMBER;
	 vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
	 vr_nrdrowid ROWID;
   -- Sacado do boleto
   vr_cdtpinsc crapass.inpessoa%TYPE;
   vr_nrinssac crapass.nrcpfcgc%TYPE;
   vr_nmprimtl crapass.nmprimtl%TYPE;
   vr_dsendere crapenc.dsendere%TYPE;
   vr_nmbairro crapenc.nmbairro%TYPE;
   vr_nrcepend crapenc.nrcepend%TYPE;
   vr_nmcidade crapenc.nmcidade%TYPE;
   vr_cdufende crapenc.cdufende%TYPE;
   vr_nrendere crapenc.nrendere%TYPE;
   vr_complend crapenc.complend%TYPE;
   vr_tab_aval        DSCT0002.typ_tab_dados_avais;
   vr_idx_aval        PLS_INTEGER;
 BEGIN
    -- Localizar conta do emitente do boleto, neste caso a cooperativa @TODO criar o de titulo
    vr_nrdconta_cob := GENE0002.fn_char_para_number(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_cdacesso => 'COBEMP_NRDCONTA_BNF'));

    -- Localizar convenio de cobrança @TODO - Criar o de titulo
    vr_nrcnvcob := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_cdacesso => 'COBEMP_NRCONVEN');  
   /*@TODO Verifica o valor minimo para geracao do boleto*/
   BEGIN
     vr_vlmintit := to_number(replace(replace(gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                                                       ,pr_nmsistem => 'CRED'
                                                                       ,pr_cdacesso => 'COBEMP_VLR_MIN_PP'),',',''),'.','')/100);
   EXCEPTION
     WHEN OTHERS THEN
       -- Atribui crítica
       vr_cdcritic := 0;
       vr_dscritic := 'Erro ao acessar parametro de valor minimo para boleto.';
       -- Levanta exceção
       RAISE vr_exc_erro;
   END;
   OPEN cr_crapbdt;
   FETCH cr_crapbdt INTO rw_crapbdt;
   IF (cr_crapbdt%NOTFOUND) THEN
     CLOSE cr_crapbdt;
     vr_dscritic := 'Borderô não encontrado';
     RAISE vr_exc_erro;
   END IF;
   CLOSE cr_crapbdt;
   /*Traz os titulos vencidos do bordero na ordem correta a ser paga*/
   pc_buscar_titulo_vencido(pr_cdcooper         --> Código da Cooperativa
                      ,pr_nrdconta        --> Número da Conta
                      ,pr_nrborder        --> Número do bordero
                      ,pr_dtmvtolt        --> Data de movimentacao
                      ,pr_dtvencto        --> Data de vencimento que o boleto será gerado
                      --------> OUT <--------
                      ,vr_qtregist        --> Quantidade de registros encontrados
                      ,vr_tab_dados_titulos --> Tabela de retorno dos títulos encontrados
                      ,vr_cdcritic        --> Código da crítica
                      ,vr_dscritic        --> Descrição da crítica
                      );
   IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
     RAISE vr_exc_erro;
   END IF;
   
   vr_index := pr_titpagar.first;
   vr_index_tit := vr_tab_dados_titulos.first;
   vr_dstitulo := '';
   vr_vltitulo := 0;
   while vr_index is not null LOOP
     /*Valida a ordem dos títulos selecionados*/
     IF (pr_titpagar(vr_index).nrtitulo<>vr_tab_dados_titulos(vr_index_tit).nrtitulo) THEN
       vr_dscritic := 'Selecione os títulos na ordem de data de vencimento e valor devido.';
       RAISE vr_exc_erro;
     END IF;
     /*Valor pago menor que o total, verifica se é o último registro*/
     IF (pr_titpagar(vr_index).vlapagar<vr_tab_dados_titulos(vr_index_tit).vlpagar) THEN
       IF (pr_titpagar.next(vr_index) IS NOT NULL) THEN
         vr_dscritic := 'Todos os títulos, com exceção o último, devem ser pagos integralmente.';
         RAISE vr_exc_erro;
       END IF;
     END IF;
     /*Valor acima da dívida*/
     IF (pr_titpagar(vr_index).vlapagar>vr_tab_dados_titulos(vr_index_tit).vlpagar) THEN
       vr_dscritic := 'Valor pago acima do devido.';
       RAISE vr_exc_erro;
     END IF;
     IF (vr_tab_dados_titulos(vr_index_tit).dtvencto>pr_dtmvtolt) THEN
       vr_dscritic := 'Apenas títulos vencidos podem ser pagos.';
       RAISE vr_exc_erro;
     END IF;
     
     /*contabiliza para o valor total do boleto e a descricao*/
     vr_vltitulo := vr_vltitulo + pr_titpagar(vr_index).vlapagar;
     vr_dstitulo := vr_dstitulo || to_char(pr_titpagar(vr_index).nrtitulo) || ', ';
     vr_index := pr_titpagar.next(vr_index);
     vr_index_tit := vr_tab_dados_titulos.next(vr_index_tit);
   END LOOP;
   vr_dstitulo := SUBSTR(vr_dstitulo,1,LENGTH(vr_dstitulo)-2);
   
   /*Verifica se o pagador vai ser o cooperado ou o avalista, em seguida verfica se é um pagador cadastrado para a conta e insere/atualiza o cadastro*/
   OPEN cr_crapass;
   FETCH cr_crapass INTO rw_crapass;
   IF (cr_crapass%NOTFOUND) THEN
     vr_dscritic := 'Associado não encontrado';
   END IF;
   IF (pr_nrcpfava IS NULL) THEN
     /*Pagador proprio remetente*/  
     vr_cdtpinsc := rw_crapass.inpessoa;
     vr_nrinssac := rw_crapass.nrcpfcgc;
     vr_nmprimtl := rw_crapass.nmprimtl;
     vr_dsendere := rw_crapass.dsendere;
     vr_nmbairro := rw_crapass.nmbairro;
     vr_nrcepend := rw_crapass.nrcepend;
     vr_nmcidade := rw_crapass.nmcidade;
     vr_cdufende := rw_crapass.cdufende;
     vr_nrendere := rw_crapass.nrendere;
     vr_complend := rw_crapass.complend;
     NULL;
   ELSE
      /*Pagador é outro avalista*/
     -- Dados do Avalista
     DSCT0002.pc_lista_avalistas(pr_cdcooper => pr_cdcooper  --> Código da Cooperativa
                                   ,pr_cdagenci => rw_crapass.cdagenci --> Código da agencia
                                   ,pr_nrdcaixa => 1            --> Numero do caixa do operador
                                   ,pr_cdoperad => pr_cdoperad  --> Código do Operador
                                   ,pr_nmdatela => pr_nmdatela  --> Nome da tela
                                   ,pr_idorigem => pr_idorigem  --> Identificador de Origem
                                   ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                                   ,pr_idseqttl => 1            --> Sequencial do titular
                                   ,pr_tpctrato => 8             --> Tipo de contrado - Dentro da procedure é trocado para 3
                                   ,pr_nrctrato => rw_crapbdt.nrctrlim  --> Numero do contrato
                                   ,pr_nrctaav1 => 0            --> Numero da conta do primeiro avalista
                                   ,pr_nrctaav2 => 0            --> Numero da conta do segundo avalista
                                    --------> OUT <--------                                   
                                   ,pr_tab_dados_avais   => vr_tab_aval   --> retorna dados do avalista
                                   ,pr_cdcritic          => vr_cdcritic   --> Código da crítica
                                   ,pr_dscritic          => vr_dscritic); --> Descrição da crítica
        
     IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;
     vr_idx_aval := vr_tab_aval.first;
     WHILE vr_idx_aval IS NOT NULL LOOP
        IF pr_nrcpfava = vr_tab_aval(vr_idx_aval).nrcpfcgc THEN
          vr_cdtpinsc := vr_tab_aval(vr_idx_aval).inpessoa;
          vr_nrinssac := vr_tab_aval(vr_idx_aval).nrcpfcgc;
          vr_nmprimtl := vr_tab_aval(vr_idx_aval).nmdavali;
          vr_dsendere := vr_tab_aval(vr_idx_aval).dsendere;
          vr_nmbairro := vr_tab_aval(vr_idx_aval).dsendcmp;
          vr_nrcepend := vr_tab_aval(vr_idx_aval).nrcepend;
          vr_nmcidade := vr_tab_aval(vr_idx_aval).nmcidade;
          vr_cdufende := vr_tab_aval(vr_idx_aval).cdufresd;
          vr_nrendere := vr_tab_aval(vr_idx_aval).nrendere;
          vr_complend := vr_tab_aval(vr_idx_aval).complend;
          vr_idx_aval := NULL;
        END IF;
     END LOOP;
   END IF; 
   
   -- Verificar se existe o pagador na crapsab, inclui ou atualiza
   OPEN cr_crapsab (pr_cdcooper => pr_cdcooper
                   ,pr_nrctabnf => vr_nrdconta_cob
                   ,pr_nrinssac => vr_nrinssac);
   FETCH cr_crapsab INTO rw_crapsab;
   
   IF (cr_crapsab%NOTFOUND) THEN
     INSERT INTO crapsab (cdcooper,
                          nrdconta,
                          nrinssac,
                          cdtpinsc,
                          nmdsacad,
                          dsendsac,
                          nmbaisac,
                          nrcepsac,
                          nmcidsac,
                          cdufsaca,
                          cdoperad,
                          hrtransa,
                          dtmvtolt,
                          nrendsac,
                          complend,
                          cdsitsac)
                  VALUES (pr_cdcooper,
                          vr_nrdconta_cob,
                          vr_nrinssac,
                          vr_cdtpinsc,
                          vr_nmprimtl,
                          vr_dsendere,
                          vr_nmbairro,
                          vr_nrcepend,
                          vr_nmcidade,
                          vr_cdufende,
                          pr_cdoperad,
                          GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
                          pr_dtmvtolt,
                          vr_nrendere,
                          vr_complend,
                          1);
    ELSE
     UPDATE crapsab sab
        SET sab.dsendsac = vr_dsendere,
            sab.nmbaisac = vr_nmbairro,
            sab.nrcepsac = vr_nrcepend,
            sab.nmcidsac = vr_nmcidade,
            sab.cdufsaca = vr_cdufende
      WHERE sab.cdcooper = pr_cdcooper
        AND sab.nrdconta = vr_nrdconta_cob
        AND sab.nrinssac = vr_nrinssac;

   END IF;
   CLOSE cr_crapsab;
   
   pc_verifica_gerar_boleto (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
																	 	 ,pr_nrborder => pr_nrborder
                                     ,pr_cdcritic => vr_cdcritic
																		 ,pr_dscritic => vr_dscritic
                                     );
   IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
     RAISE vr_exc_erro;
   END IF;
   /*
   * PREPARA AS Descrições do título */
   
   /*@TODO Criar um parametros para título*/
   vr_dsinform := gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_1');

   vr_dsinform := vr_dsinform || '  - TÍTULO(S): ' || vr_dstitulo;

   vr_dsinform := vr_dsinform || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_2') || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_3') || '_' ||
                     gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_INSTR_LINHA_4');
                                              
   vr_dsinform := REPLACE(vr_dsinform, '#CONTA#', gene0002.fn_mask_conta(pr_nrdconta));
   vr_dsinform := REPLACE(vr_dsinform, '#conta#', gene0002.fn_mask_conta(pr_nrdconta));      
   vr_dsinform := REPLACE(vr_dsinform, '#BORDERO#', to_char(pr_nrborder));
   vr_dsinform := REPLACE(vr_dsinform, '#bordero#', to_char(pr_nrborder));
   
   /*
   *GERA O BOLETO
   */
		cobr0005.pc_gerar_titulo_cobranca(pr_cdcooper => pr_cdcooper
																			 ,pr_nrdconta => vr_nrdconta_cob
																			 ,pr_nrcnvcob => vr_nrcnvcob
																			 ,pr_nrctremp => NULL
																			 ,pr_inemiten => 2                                -- @TODO Confirmar
																			 ,pr_cdbandoc => 085                              -- @TODO Confirmar
																			 ,pr_cdcartei => 1                                -- @TODO Confirmar
																			 ,pr_cddespec => 1                                -- @TODO Confirmar
																			 ,pr_nrctasac => pr_nrdconta
																			 ,pr_cdtpinsc => vr_cdtpinsc
																			 ,pr_nrinssac => vr_nrinssac
																			 ,pr_dtmvtolt => pr_dtmvtolt
																			 ,pr_dtdocmto => pr_dtmvtolt
																			 ,pr_dtvencto => pr_dtvencto
																			 ,pr_cdmensag => 0
																			 ,pr_dsdoccop => to_char(pr_nrborder)
																			 ,pr_vltitulo => vr_vltitulo
                                       ,pr_dsinform => vr_dsinform
																			 ,pr_cdoperad => 1
																			 ,pr_cdcritic => vr_cdcritic
																			 ,pr_dscritic => vr_dscritic
																			 ,pr_tab_cob  => vr_tab_cob);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_erro;
			END IF;
      /*Insere na tabela de ligacao do boleto gerado com os titulos*/
      INSERT INTO tbrecup_cobranca (cdcooper
			                           ,nrdconta
																 ,nrctremp
																 ,nrdconta_cob
																 ,nrcnvcob
																 ,nrboleto
																 ,dsparcelas
																 ,dhtransacao
																 ,tpenvio
																 ,tpparcela
																 ,cdoperad
                                 ,nrcpfava
                                 ,idarquivo
                                 ,idboleto
                                 ,peracrescimo
                                 ,perdesconto
                                 ,vldesconto
                                 ,tpproduto)
													VALUES(pr_cdcooper
													      ,pr_nrdconta
																,pr_nrborder
																,vr_nrdconta_cob
																,vr_nrcnvcob
																,vr_tab_cob(1).nrdocmto
																,vr_dstitulo
																,SYSDATE
																,0
																,0
																,pr_cdoperad
                                ,pr_nrcpfava
                                ,0
                                ,0
                                ,0
                                ,0
                                ,0 
                                ,3);--bordero
                                
      pr_vltitulo := vr_tab_cob(1).vltitulo;
      pr_nrboleto := vr_tab_cob(1).nrdocmto;
      -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => 'Geracao de boleto bordero',
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => vr_nrdrowid);

		  -- Bordero
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Bordero',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrborder);

      -- Títulos
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Titulos',
																	pr_dsdadant => '',
																	pr_dsdadatu => vr_dstitulo);
			
      -- Data do vencimento
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Data do vencimento',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(pr_dtvencto, 'DD/MM/RRRR'));

			-- Valor do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vlr do boleto',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(vr_vltitulo, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));

      -- Cria log de cobrança
      PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
                                    pr_cdoperad => pr_cdoperad,
                                    pr_dtmvtolt => trunc(SYSDATE),
                                    pr_dsmensag => 'Titulo referente ao bordero ' || to_char(pr_nrborder),
                                    pr_des_erro => vr_des_erro,
                                    pr_dscritic => vr_dscritic);

   EXCEPTION
     when vr_exc_erro THEN
       pr_dscritic := vr_dscritic;
 END pc_gerar_boleto;
 
 PROCEDURE pc_gerar_boleto_web (pr_nrdconta IN crapbdt.nrdconta%TYPE   --> Número da conta
                             ,pr_nrborder IN crapbdt.nrborder%TYPE   --> Número do Borderô
                             ,pr_nrtitulo IN VARCHAR2                --> Números e valores a serem pagos
                             ,pr_dtvencto IN VARCHAR2                --> Data de vencimento que o boleto será geradoleto a ser gerado
                             ,pr_nrcpfava IN  crapass.nrcpfcgc%TYPE  --> Cpf do avalisa. Null se for o proprio sacado
                             ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                             --------> OUT <--------
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2      --> Erros do processo
                           ) IS
                           
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
   vr_exc_erro EXCEPTION;
   
   -- Variaveis da procedure
   vr_tab_cobs    gene0002.typ_split;
   vr_tab_chaves  gene0002.typ_split;
   vr_index       INTEGER;
   vr_idtabtitulo INTEGER;
   vr_nrtitulo    INTEGER;
   vr_titpagar    typ_tab_dados_vencidos;
   vr_dtvencto    DATE;
   vr_vltitulo    NUMBER;
   vr_nrboleto    INTEGER;
   -- Informações de data do sistema
   rw_crapdat  btch0001.rw_crapdat%TYPE;
   vr_dtvencto DATE;
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
                              
   vr_tab_cobs := gene0002.fn_quebra_string(pr_string  => pr_nrtitulo,
                                             pr_delimit => ';');
   vr_idtabtitulo:=0;
   IF vr_tab_cobs.count() > 0 THEN   
      --    Verifica se a data esta cadastrada
     open  btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     if    btch0001.cr_crapdat%notfound then
           close btch0001.cr_crapdat;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
           raise vr_exc_erro;
     end   if;
     close btch0001.cr_crapdat;
      
     /*Traz 1 linha para cada titulo sendo selecionado*/
     vr_index := vr_tab_cobs.first;
     while vr_index is not null loop
       -- Pega a chave e o valor para preencher a tabela
       vr_tab_chaves := gene0002.fn_quebra_string(pr_string  => vr_tab_cobs(vr_index),
                                             pr_delimit => '=');
       IF (vr_tab_chaves.count() > 0) THEN
         vr_titpagar(vr_idtabtitulo).nrtitulo := vr_tab_chaves(1);
         vr_titpagar(vr_idtabtitulo).vlapagar := vr_tab_chaves(2);
         vr_titpagar(vr_idtabtitulo).nrborder := pr_nrborder;
       END IF;
       vr_index := vr_tab_cobs.next(vr_index);
       vr_idtabtitulo := vr_idtabtitulo+1;
     END LOOP;
     
     /*Gerar boleto com os titulos selecionados*/
     pc_gerar_boleto (pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_nrborder => pr_nrborder
                             ,pr_nrcpfava => pr_nrcpfava
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtvencto => to_date(pr_dtvencto,'dd/mm/rrrr')
                             ,pr_titpagar => vr_titpagar
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             -->OUT<--
                             ,pr_nrboleto => vr_nrboleto
                             ,pr_vltitulo => vr_vltitulo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                           );
     IF (nvl(vr_cdcritic,0)>0 OR vr_dscritic IS NOT NULL) THEN
       RAISE vr_exc_erro;
     END IF;
     
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;
      IF (vr_nrboleto > 0) THEN
        pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                       '<root><dados><boleto>');
        pc_escreve_xml('  <nrdocmto>' || vr_nrboleto || '</nrdocmto>'||
                       '  <vltitulo>' || vr_vltitulo || '</vltitulo>');
        pc_escreve_xml ('</boleto></dados></root>',true);
        pr_retxml := xmltype.createxml(vr_des_xml);

        /* liberando a memória alocada pro clob */
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);
      ELSE
        vr_dscritic := 'Não foi possível gerar o boleto.';
        RAISE vr_exc_erro;
      END IF;
   ELSE
     vr_dscritic := 'Selecione ao menos um título';
     RAISE vr_exc_erro;
   END IF;
   
   COMMIT;
   EXCEPTION
     when vr_exc_erro then
       ROLLBACK;
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
       ROLLBACK;
          /* montar descriçao de erro nao tratado */
          pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_gerar_boleto_web ' ||sqlerrm;
          -- Carregar XML padrao para variavel de retorno
          pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                          '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
 END pc_gerar_boleto_web;
 
 PROCEDURE pc_lista_avalista_web (pr_nrdconta IN craplim.nrdconta%TYPE
                              ,pr_nrborder IN crapbdt.nrborder%TYPE
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              --------> OUT <--------
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype    --> arquivo de retorno do xml
                              ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2      --> Erros do processo 
                              ) IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : pc_lista_avalista_web
    Sistema  : CRED
    Sigla    : TELA_COBTIT
    Autor    : Luis Fernando (GFT)
    Data     : Maio/2018
    Frequencia: Sempre que for chamado
    Objetivo  : Lista os avalistas de um contrato através do bordero
  ---------------------------------------------------------------------------------------------------------------------*/
   --Tratamento de erros                              
   vr_cdcritic crapcri.cdcritic%type; --> Cód. Erro
   vr_dscritic varchar2(1000);        --> Desc. Erro
   vr_exc_erro EXCEPTION;
   
   -- variaveis de entrada vindas no xml
   vr_cdcooper integer;
   vr_cdoperad varchar2(100);
   vr_nmdatela varchar2(100);
   vr_nmeacao  varchar2(100);
   vr_cdagenci varchar2(100);
   vr_nrdcaixa varchar2(100);
   vr_idorigem varchar2(100);
   
   -- Avalista
   vr_tab_dados_avais dsct0002.typ_tab_dados_avais;
   
   -- Contrato de limite
   vr_nrctrlim craplim.nrctrlim%TYPE;
   
   vr_index PLS_INTEGER;
   
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
    -- Busca o contrato do bordero para listar os avalistas
    BEGIN 
      SELECT 
         nrctrlim INTO vr_nrctrlim 
      FROM 
         crapbdt
      WHERE
         nrdconta = pr_nrdconta
         AND cdcooper = vr_cdcooper
         AND nrborder = pr_nrborder;
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Contrato não encontrato';
           RAISE vr_exc_erro;
    END;
    --> listar avalistas de contratos
    dsct0002.pc_lista_avalistas ( pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                        ,pr_cdagenci => vr_cdagenci  --> Código da agencia
                        ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                        ,pr_cdoperad => vr_cdoperad  --> Código do Operador
                        ,pr_nmdatela => vr_nmdatela  --> Nome da tela
                        ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                        ,pr_nrdconta => pr_nrdconta  --> Numero da conta do cooperado
                        ,pr_idseqttl => 0            --> Sequencial do titular
                        ,pr_tpctrato => 8             --> Tipo de contrado - Dentro da procedure é trocado para 3
                        ,pr_nrctrato => vr_nrctrlim  --> Numero do contrato
                        ,pr_nrctaav1 => NULL  --> Numero da conta do primeiro avalista --> Nao utilizado
                        ,pr_nrctaav2 => NULL  --> Numero da conta do segundo avalista --> Nao utilizado
                         --------> OUT <--------
                        ,pr_tab_dados_avais   => vr_tab_dados_avais   --> retorna dados do avalista
                        ,pr_cdcritic          => vr_cdcritic          --> Código da crítica
                        ,pr_dscritic          => vr_dscritic);        --> Descrição da crítica

    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    -- inicializar o clob
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- inicilizar as informaçoes do xml
    vr_texto_completo := null;

    /*Monta o XML dos avalistas*/
    pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="' || vr_tab_dados_avais.count ||'" >');
                     
    vr_index := vr_tab_dados_avais.first;
    WHILE vr_index IS NOT NULL LOOP
        pc_escreve_xml('<avalista>');
        pc_escreve_xml('<nrctaava>' || vr_tab_dados_avais(vr_index).nrctaava || '</nrctaava>' ||
                        '<nmdavali>' || vr_tab_dados_avais(vr_index).nmdavali || '</nmdavali>' ||
                        '<nrcpfcgc>' || vr_tab_dados_avais(vr_index).nrcpfcgc || '</nrcpfcgc>' ||
                        '<nrdocava>' || vr_tab_dados_avais(vr_index).nrdocava || '</nrdocava>' ||
                        '<tpdocava>' || vr_tab_dados_avais(vr_index).tpdocava || '</tpdocava>' ||
                        '<nmconjug>' || vr_tab_dados_avais(vr_index).nmconjug || '</nmconjug>' ||
                        '<nrcpfcjg>' || vr_tab_dados_avais(vr_index).nrcpfcjg || '</nrcpfcjg>' ||
                        '<nrdoccjg>' || vr_tab_dados_avais(vr_index).nrdoccjg || '</nrdoccjg>' ||
                        '<tpdoccjg>' || vr_tab_dados_avais(vr_index).tpdoccjg || '</tpdoccjg>' ||
                        '<nrfonres>' || vr_tab_dados_avais(vr_index).nrfonres || '</nrfonres>' ||
                        '<dsdemail>' || vr_tab_dados_avais(vr_index).dsdemail || '</dsdemail>' ||
                        '<dsendere>' || vr_tab_dados_avais(vr_index).dsendere || '</dsendere>' ||
                        '<dsendcmp>' || vr_tab_dados_avais(vr_index).dsendcmp || '</dsendcmp>' ||
                        '<nmcidade>' || vr_tab_dados_avais(vr_index).nmcidade || '</nmcidade>' ||
                        '<cdufresd>' || vr_tab_dados_avais(vr_index).cdufresd || '</cdufresd>' ||
                        '<nrcepend>' || vr_tab_dados_avais(vr_index).nrcepend || '</nrcepend>' ||
                        '<dsnacion>' || vr_tab_dados_avais(vr_index).dsnacion || '</dsnacion>' ||
                        '<vledvmto>' || vr_tab_dados_avais(vr_index).vledvmto || '</vledvmto>' ||
                        '<vlrenmes>' || vr_tab_dados_avais(vr_index).vlrenmes || '</vlrenmes>' ||
                        '<idavalis>' || vr_tab_dados_avais(vr_index).idavalis || '</idavalis>' ||
                        '<nrendere>' || vr_tab_dados_avais(vr_index).nrendere || '</nrendere>' ||
                        '<complend>' || vr_tab_dados_avais(vr_index).complend || '</complend>' ||
                        '<nrcxapst>' || vr_tab_dados_avais(vr_index).nrcxapst || '</nrcxapst>' ||
                        '<inpessoa>' || vr_tab_dados_avais(vr_index).inpessoa || '</inpessoa>' ||
                        '<cdestcvl>' || vr_tab_dados_avais(vr_index).cdestcvl || '</cdestcvl>');
        pc_escreve_xml('</avalista>');
      vr_index := vr_tab_dados_avais.next(vr_index);
    END LOOP;
    
    pc_escreve_xml ('</dados></root>',true);
    pr_retxml := xmltype.createxml(vr_des_xml);
    /* liberando a memória alocada pro clob */
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);    
    
 END pc_lista_avalista_web;
 
	
 PROCEDURE pc_verifica_gerar_boleto (pr_cdcooper IN crapcop.cdcooper%TYPE                   --> Cód. cooperativa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE                   --> Nr. da Conta
																	 	 ,pr_nrborder IN crapbdt.nrborder%TYPE                   --> Nr. do Bordero
                                     ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
																		 ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                                     ) IS
		BEGIN
	 	  /* .............................................................................

      Programa: pc_verifica_gerar_boleto
      Sistema : CECRED
      Sigla   : TELA
      Autor   : Luis Fernando (GFT)
      Data    : 02/06/2018

      Dados referentes ao programa:
      Frequencia: Sempre que for chamado
      Objetivo  : Realiza verificação de regras para geração de boletos de borderos com titulos vencidos

      Observacao: Parte das regras vieram da EMPR0007 da geração de boletos de contratos
    ..............................................................................*/
		DECLARE
		  -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; -- Cód. crítica
      vr_dscritic VARCHAR2(10000);       -- Desc. crítica

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

			-- Variaveis locais
			vr_qtmaxbol INTEGER;
			vr_qtbolnpg INTEGER;
      vr_dtconsec DATE;
			vr_blqemico VARCHAR2(10);
			vr_dtultpgt DATE;
		  vr_blqemico_split   gene0002.typ_split;
      vr_inusatab     BOOLEAN;                --> Indicador S/N de utilização de tabela de juros      
      vr_parempct craptab.dstextab%TYPE := '';      			      
      vr_qtregist INTEGER := 0;      
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_des_reto VARCHAR2(3);
      vr_dstextab     craptab.dstextab%TYPE;  --> Busca na craptab      
      vr_digitali craptab.dstextab%TYPE := '';     
      
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      
      
			--------------------------- CURSORES --------------------------------------
			-- Cursor para verificar se existe algum boleto em aberto
			CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%TYPE
                        ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
          SELECT 1
            FROM crapcob cob
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 0
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrboleto
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrborder
                     AND cde.tpproduto = 3);
			rw_crapcob cr_crapcob%ROWTYPE;
      
			-- Cursor para verificar se existe algum boleto pago pendente de processamento
			CURSOR cr_crapret (pr_cdcooper IN crapcob.cdcooper%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%TYPE
                        ,pr_nrborder IN crapbdt.nrborder%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
          SELECT 1
            FROM crapcob cob, crapret ret
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto = pr_dtmvtolt
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac, cob.nrdocmto) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta, nrboleto
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrborder
                     AND cde.tpproduto = 3)
             AND ret.cdcooper = cob.cdcooper
             AND ret.nrdconta = cob.nrdconta
             AND ret.nrcnvcob = cob.nrcnvcob
             AND ret.nrdocmto = cob.nrdocmto
             AND ret.dtocorre = cob.dtdpagto
             AND ret.cdocorre = 6
             AND ret.flcredit = 0;
			rw_crapret cr_crapret%ROWTYPE;      

		  -- Busca os convernios de emprestimo da cooperativa
		  CURSOR cr_crapprm (pr_cdcooper IN crapcop.cdcooper%TYPE
			                  ,pr_cdacesso IN crapprm.cdacesso%TYPE)IS
			  SELECT prm.dsvlrprm
				  FROM crapprm prm
				 WHERE prm.cdcooper = pr_cdcooper
				 	 AND prm.nmsistem = 'CRED'
					 AND prm.cdacesso = pr_cdacesso;

		  -- Buscar a quantidade de boletos nao pagos a partir da última data de pagto
			CURSOR cr_crapcob_bnp (pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN crapass.nrdconta%TYPE
                            ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT COUNT(*) qtbolbnp,
               MIN(dtdbaixa) dtminbai, 
               MAX(dtdbaixa) dtmaxbai
          FROM crapcob cob
         WHERE cob.cdcooper = pr_cdcooper
           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac) IN 
               (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta
                  FROM tbrecup_cobranca cde
                 WHERE cde.cdcooper = pr_cdcooper
                   AND cde.nrdconta = pr_nrdconta
                   AND cde.nrctremp = pr_nrborder
                   AND cde.tpproduto = 3)
           AND cob.incobran = 3
           AND cob.dtdbaixa >= nvl(nvl((SELECT MAX(cob.dtdpagto) -- 1) buscar pelo ultimo pagamento
                                      FROM crapcob cob
                                     WHERE cob.cdcooper = pr_cdcooper
                                       AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac) IN 
                                           (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta
                                              FROM tbrecup_cobranca cde
                                             WHERE cde.cdcooper = pr_cdcooper
                                               AND cde.nrdconta = pr_nrdconta
                                               AND cde.nrctremp = pr_nrborder
                                               AND cde.tpproduto = 3)                                   
                                       AND cob.dtdpagto IS NOT NULL
                                       AND cob.incobran = 5),
                                       (SELECT MAX(cob.dtdbaixa) -- 2) buscar pela ultima baixa
                                          FROM crapcob cob
                                         WHERE cob.cdcooper = pr_cdcooper
                                           AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac) IN 
                                               (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta
                                                  FROM tbrecup_cobranca cde
                                                 WHERE cde.cdcooper = pr_cdcooper
                                                   AND cde.nrdconta = pr_nrdconta
                                                   AND cde.nrctremp = pr_nrborder
                                                   AND cde.tpproduto = 3)                                   
                                           AND cob.dtdbaixa IS NOT NULL 
                                           AND cob.incobran = 3)),(SELECT bdt.dtmvtolt FROM crapbdt bdt --3) se nao encontrar nenhum dos dois, entao buscar pela data do bordero
                                                                  WHERE bdt.cdcooper = pr_cdcooper
                                                                    AND bdt.nrdconta = pr_nrdconta
                                                                    AND bdt.nrborder = pr_nrborder));
      rw_crapcob_bnp cr_crapcob_bnp%ROWTYPE;                                                                         

			-- Cursor para buscar a data do último boleto pago
			CURSOR cr_crapcob_ubp (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
          SELECT MAX(cob.dtdpagto)
            FROM crapcob cob
           WHERE cob.cdcooper = pr_cdcooper
             AND cob.incobran = 5
             AND cob.dtdpagto IS NOT NULL
             AND (cob.nrdconta, cob.nrcnvcob, cob.nrctasac) IN 
                 (SELECT DISTINCT nrdconta_cob, nrcnvcob, nrdconta
                    FROM tbrecup_cobranca cde
                   WHERE cde.cdcooper = pr_cdcooper
                     AND cde.nrdconta = pr_nrdconta
                     AND cde.nrctremp = pr_nrborder
                     AND cde.tpproduto = 3);      
                     
      -- cursor Bordero
      CURSOR cr_bdt (pr_cdcooper IN crapbdt.cdcooper%TYPE
                    ,pr_nrdconta IN crapbdt.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT bdt.insitbdt,
               bdt.dtmvtolt
          FROM crapbdt bdt
         WHERE bdt.cdcooper = pr_cdcooper
           AND bdt.nrdconta = pr_nrdconta
           AND bdt.nrborder = pr_nrborder;
      rw_bdt cr_bdt%ROWTYPE;
           
      -- cursor Cyber - ativos
      CURSOR cr_cyb (pr_cdcooper IN crapcyb.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyb.nrdconta%TYPE
                    ,pr_nrborder IN crapbdt.nrborder%TYPE) IS
        SELECT 
          nrctremp
        FROM 
          crapcyb cyb
          INNER JOIN tbdsct_titulo_cyber c ON c.cdcooper=cyb.cdcooper AND c.nrdconta=cyb.nrdconta AND c.nrctrdsc=cyb.nrctremp
         WHERE cyb.cdcooper = pr_cdcooper
           AND cyb.nrdconta = pr_nrdconta
           AND c.nrborder = pr_nrborder
           AND cyb.cdorigem IN (4)
           AND cyb.dtdbaixa IS NULL;
      rw_cyb cr_cyb%ROWTYPE;
      
      -- cursor Cyber - Judicial, Extrajudicial ou VIP
      CURSOR cr_cyc (pr_cdcooper IN crapcyc.cdcooper%TYPE
                    ,pr_nrdconta IN crapcyc.nrdconta%TYPE
                    ,pr_nrctremp IN crapcyc.nrctremp%TYPE) IS
        SELECT flgjudic,
               flextjud,
               flgehvip 
          FROM crapcyc cyc
         WHERE cyc.cdcooper = pr_cdcooper
           AND cyc.nrdconta = pr_nrdconta
           AND cyc.nrctremp = pr_nrctremp
           AND cyc.cdorigem = 3;
      rw_cyc cr_cyc%ROWTYPE;

		BEGIN
	    -- Verifica se existe algum boleto em aberto
		  OPEN cr_crapcob(pr_cdcooper, pr_nrdconta, pr_nrborder);
			FETCH cr_crapcob INTO rw_crapcob;

			-- Existe boleto em aberto
			IF cr_crapcob%FOUND THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe um boleto em aberto para este contrato. Favor aguardar regularizacao.';
        -- Fecha cursor
				CLOSE cr_crapcob;
				-- Levanta exceção
				RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
			CLOSE cr_crapcob;
      
      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      END IF;
      CLOSE btch0001.cr_crapdat;      

	    -- Verifica se existe algum boleto pago pendente de processamento
		  OPEN cr_crapret(pr_cdcooper, pr_nrdconta, pr_nrborder, rw_crapdat.dtmvtolt );
			FETCH cr_crapret INTO rw_crapret;

			-- Existe boleto Pago pendente de processamento
			IF cr_crapret%FOUND THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Existe um boleto pago pendente de processamento. Favor aguardar lancamento no proximo dia util.';
        -- Fecha cursor
				CLOSE cr_crapret;
				-- Levanta exceção
				RAISE vr_exc_erro;
      END IF;
      -- Fecha cursor
			CLOSE cr_crapret;      

			-- Busca quantidade máxima de boletos emitidos por contrato da cooperativa
		  OPEN cr_crapprm(pr_cdcooper
			               ,'COBEMP_QTD_MAX_BOL_EPR');
			FETCH cr_crapprm INTO vr_qtmaxbol;
			CLOSE cr_crapprm;

			-- Busca a quantidade de boletos emitidos nao pagos após o último boleto pago do contrato
			OPEN cr_crapcob_bnp(pr_cdcooper => pr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrborder => pr_nrborder);
			FETCH cr_crapcob_bnp INTO rw_crapcob_bnp;
			-- Fecha cursor
			CLOSE cr_crapcob_bnp;

			IF vr_qtmaxbol <= rw_crapcob_bnp.qtbolbnp THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Foi atingido a quantidade maxima (' || vr_qtmaxbol || ') de boletos emitidos para este contrato.';
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;

 			-- Busca quantidade máxima de boletos emitidos por contrato da cooperativa
		  OPEN cr_crapprm(pr_cdcooper
			               ,'COBEMP_BLQ_EMI_CONSEC');
			FETCH cr_crapprm INTO vr_blqemico;
			CLOSE cr_crapprm;

			-- Divide a String para atribuir os dias e boletos na variavel (XX;YY)
		  vr_blqemico_split := gene0002.fn_quebra_string(pr_string  => vr_blqemico
		                                                 ,pr_delimit => ';');

			-- Busca a data do último boleto pago
			OPEN cr_crapcob_ubp (pr_cdcooper);
			FETCH cr_crapcob_ubp INTO vr_dtultpgt;
      
      OPEN cr_bdt (pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrborder => pr_nrborder);
      FETCH cr_bdt INTO rw_bdt;
      CLOSE cr_bdt;

      vr_dtconsec := nvl(rw_crapcob_bnp.dtmaxbai,rw_bdt.dtmvtolt) + TO_NUMBER(vr_blqemico_split(1));
      
      -- Verifica a quantidade de boletos emitidos e não pagos dentro do prazo para emissão de novos boletos
			IF vr_dtconsec > rw_crapdat.dtmvtolt AND
				 to_number(vr_blqemico_split(2)) <= nvl(rw_crapcob_bnp.qtbolbnp,0) THEN
 				-- Atribui crítica
				vr_cdcritic := 0;
        vr_dscritic := 'Favor aguardar ' || to_char(vr_dtconsec - rw_crapdat.dtmvtolt)
				            || ' dias para emissao de um novo boleto.';
				-- Levanta exceção
				RAISE vr_exc_erro;
 		  END IF;
      
      -- verificar se o contrato esta ativo no Cyber
      OPEN cr_cyb (pr_cdcooper => pr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrborder => pr_nrborder);
      IF (cr_cyb%FOUND) THEN
        LOOP
        FETCH cr_cyb INTO rw_cyb;
          EXIT WHEN cr_cyb%NOTFOUND;         
            -- verificar que tipo contrato esta no Cyber
            OPEN cr_cyc (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrctremp => rw_cyb.nrctremp);
            FETCH cr_cyc INTO rw_cyc;

            IF cr_cyc%FOUND THEN
              CLOSE cr_cyc;     
              IF nvl(rw_cyc.flgjudic,0) = 1 THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Não é permitido gerar boleto de títulos em Cobranca Judicial.';
                -- Levanta exceção
                RAISE vr_exc_erro;              
              END IF;
                              
              IF nvl(rw_cyc.flextjud,0) = 1 THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Não é permitido gerar boleto de títulos em Cobranca Extrajudicial.';
                -- Levanta exceção
                RAISE vr_exc_erro;              
              END IF;
                              
              IF nvl(rw_cyc.flgehvip,0) = 1 THEN
                -- Atribui crítica
                vr_cdcritic := 0;
                vr_dscritic := 'Não é permitido gerar boleto de títulos VIP.';
                -- Levanta exceção
                RAISE vr_exc_erro;              
              END IF;                       
            ELSE
              CLOSE cr_cyc;                             
            END IF;
        END LOOP;
      END IF;
      
      CLOSE cr_cyb;

		EXCEPTION
			WHEN vr_exc_erro THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
				   vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			  END IF;

        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

			WHEN OTHERS THEN
        -- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na TELA_COBTIT.pc_verifica_gerar_boleto: ' || SQLERRM;
		END;
 END pc_verifica_gerar_boleto;
 
 PROCEDURE pc_buscar_email_web(pr_nrdconta IN INTEGER
                           ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                           ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                           ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_email_web
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : COB
    Autor   : Luis Fernando (GFT)
    Data    : 02/06/2018 

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina busca email boletos cobranca de borderos.
    ..............................................................................*/
    DECLARE

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_emails(pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT DISTINCT dsdemail, secpscto, nmpescto
          FROM crapcem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
        UNION
        SELECT DISTINCT dsemail, ' ', nmcontato
          FROM tbrecup_cobranca
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dsemail IS NOT NULL
           AND dsemail <> ' '
           AND tpproduto = 3;
           
      rw_emails cr_emails%ROWTYPE;
      -- Variável de críticas
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
      
      vr_contador INTEGER := 0; -- controlar a paginacao
      vr_xmltxt   VARCHAR2(32767) := '';
    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      OPEN cr_emails (pr_cdcooper=>vr_cdcooper,pr_nrdconta=>pr_nrdconta);
      LOOP 
        FETCH cr_emails INTO rw_emails;
        vr_contador := vr_contador+1;
        EXIT WHEN (cr_emails%NOTFOUND OR (vr_contador < pr_nriniseq) OR (vr_contador >= (pr_nriniseq + pr_nrregist)) );
             vr_xmltxt := vr_xmltxt || '<email>' ||
                            '<dsdemail>' ||TO_CHAR(rw_emails.dsdemail)|| '</dsdemail>' ||
                            '<secpscto>' ||TO_CHAR(rw_emails.secpscto)|| '</secpscto>' ||
                            '<nmpescto>' ||TO_CHAR(rw_emails.nmpescto)|| '</nmpescto>' ||
                        '</email>';
      END LOOP;
      IF (vr_contador=1) THEN
         CLOSE cr_emails;
        vr_dscritic := 'Nenhum E-mail localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_emails;
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="'|| to_char(vr_contador-1) ||'">');
      pc_escreve_xml(vr_xmltxt);
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_buscar_email_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_buscar_email_web;

  PROCEDURE pc_buscar_telefone_web(pr_nrdconta IN INTEGER
                              ,pr_flcelula IN INTEGER DEFAULT 0 --> Define se é apenas celular ou tudo                 
                              ,pr_nriniseq IN INTEGER DEFAULT 1 --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER DEFAULT 15 --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_telefone_web
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : COB
    Autor   : Luis Fernando (GFT)
    Data    : 02/06/2018 

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina busca telefones boletos cobranca de borderos.
    ..............................................................................*/
    DECLARE
      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_telefones(pr_cdcooper IN crapcop.cdcooper%TYPE, pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT DISTINCT nrdddtfc, nrtelefo, nrdramal, tptelefo, nmpescto, cdopetfn
          FROM craptfc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtelefo > 0
           AND (cdopetfn > 0 OR pr_flcelula=0)
        UNION
        SELECT DISTINCT nrddd_sms, nrtel_sms, 0 ramal, 0, nmcontato, 0
          FROM tbrecup_cobranca
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrtel_sms > 0
           AND tpproduto = 3;
      rw_telefones cr_telefones%ROWTYPE;
      -- Variável de críticas
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

      vr_contador INTEGER := 0; --controla paginacao
      vr_xmltxt   VARCHAR2(32767) := '';
      vr_nmopetfn VARCHAR2(100);
      vr_destptfc VARCHAR2(100);

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      OPEN cr_telefones(pr_cdcooper => vr_cdcooper,pr_nrdconta => pr_nrdconta);
      LOOP 
        FETCH cr_telefones INTO rw_telefones;
        vr_contador := vr_contador+1;
        EXIT WHEN (cr_telefones%NOTFOUND OR (vr_contador < pr_nriniseq) OR (vr_contador >= (pr_nriniseq + pr_nrregist)) );
          vr_nmopetfn := ' ';
          IF rw_telefones.cdopetfn > 0 THEN
            CASE rw_telefones.cdopetfn
              WHEN 10 THEN
                vr_nmopetfn := 'VIVO';
              WHEN 11 THEN
                vr_nmopetfn := 'TIM';
              WHEN 14 THEN
                vr_nmopetfn := 'OI/BRASIL TEL.';
              WHEN 21 THEN
                vr_nmopetfn := 'EMBRATEL';
              WHEN 23 THEN
                vr_nmopetfn := 'INTELIG';
              WHEN 36 THEN
                vr_nmopetfn := 'CLARO';
            END CASE;
          END IF;

          vr_destptfc := ' ';
          IF rw_telefones.tptelefo > 0 THEN
            CASE rw_telefones.tptelefo
              WHEN 1 THEN
                vr_destptfc := 'RESIDENCIAL';
              WHEN 2 THEN
                vr_destptfc := 'CELULAR';
              WHEN 3 THEN
                vr_destptfc := 'COMERCIAL';
              WHEN 4 THEN
                vr_destptfc := 'CONTATO';
            END CASE;
          END IF;
        
          vr_xmltxt := vr_xmltxt || '<telefone>' ||
                            '<nrdddtfc>' ||TO_CHAR(rw_telefones.nrdddtfc)|| '</nrdddtfc>' ||
                            '<nrtelefo>' ||TO_CHAR(rw_telefones.nrtelefo)|| '</nrtelefo>' ||
                            '<nrdramal>' ||TO_CHAR(rw_telefones.nrdramal)|| '</nrdramal>' ||
                            '<tptelefo>' ||vr_destptfc                   || '</tptelefo>' ||
                            '<nmpescto>' ||TO_CHAR(rw_telefones.nmpescto)|| '</nmpescto>' ||
                            '<nmopetfn>' ||vr_nmopetfn                   || '</nmopetfn>' ||
                        '</telefone>';

      END LOOP;
      IF (vr_contador=1) THEN
         CLOSE cr_telefones;
        vr_dscritic := 'Nenhum Telefone localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_telefones;
      
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
             '<root><dados qtregist="'|| to_char(vr_contador-1) ||'">');
      pc_escreve_xml(vr_xmltxt);
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_buscar_telefone_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

 END pc_buscar_telefone_web;
 
 PROCEDURE pc_lista_pa_web(pr_cdagenci IN INTEGER          
                       ,pr_nriniseq IN INTEGER --> Registro inicial da listagem
                       ,pr_nrregist IN INTEGER --> Numero de registros p/ paginaca
                       ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_lista_pa_web
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : TELA
    Autor   : Luis Fernando (GFT)
    Data    : 02/06/2018

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotinapara lista pa.
    ..............................................................................*/
    DECLARE
      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE,
                        pr_cdcooper IN crapage.cdcooper%TYPE) IS
        SELECT age.cdagenci, age.nmresage
          FROM crapage age, crapcop cop
         WHERE age.cdcooper  = pr_cdcooper
           AND age.cdagenci >= pr_cdagenci
           AND cop.cdcooper = age.cdcooper
           AND age.cdagenci <> 999;
      rw_crapage cr_crapage%ROWTYPE;
      -- Variável de críticas
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
      vr_contador INTEGER := 0; -- controla paginacao
      
      vr_xmltxt   VARCHAR2(32767) := '';

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      OPEN cr_crapage (pr_cdcooper=>vr_cdcooper,pr_cdagenci=>pr_cdagenci);
      LOOP 
        FETCH cr_crapage INTO rw_crapage;
        vr_contador := vr_contador+1;
        EXIT WHEN (cr_crapage%NOTFOUND OR (vr_contador < pr_nriniseq) OR (vr_contador >= (pr_nriniseq + pr_nrregist)) );
             vr_xmltxt := vr_xmltxt || '<pa>' ||
                            '<cdagenci>' ||TO_CHAR(rw_crapage.cdagenci)|| '</cdagenci>' ||
                            '<nmresage>' ||TO_CHAR(rw_crapage.nmresage)|| '</nmresage>' ||
                        '</pa>';
      END LOOP;
      IF (vr_contador=1) THEN
         CLOSE cr_crapage;
        vr_dscritic := 'Nenhum PA localizado!';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapage;
      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados qtregist="'|| to_char(vr_contador-1) ||'">');
      pc_escreve_xml(vr_xmltxt);
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);
      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_COBTIT.pc_lista_pa_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
  END pc_lista_pa_web;
  
  PROCEDURE pc_buscar_boletos (pr_cdcooper IN crapcop.cdcooper%TYPE                  --> Cooperativa
																				,pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0        --> PA
																				,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0 --> Nr. do Contrato
																				,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0        --> Nr. da Conta
																				,pr_dtbaixai IN DATE DEFAULT NULL                      --> Data de baixa inicial
																				,pr_dtbaixaf IN DATE DEFAULT NULL                      --> Data de baixa final
																				,pr_dtemissi IN DATE DEFAULT NULL                      --> Data de emissão inicial
																				,pr_dtemissf IN DATE DEFAULT NULL                      --> Data de emissão final
																				,pr_dtvencti IN DATE DEFAULT NULL                      --> Data de vencimento inicial
																				,pr_dtvenctf IN DATE DEFAULT NULL                      --> Data de vencimento final
																				,pr_dtpagtoi IN DATE DEFAULT NULL                      --> Data de pagamento inicial
																				,pr_dtpagtof IN DATE DEFAULT NULL                      --> Data de pagamento final
																				,pr_cdoperad IN crapope.cdoperad%TYPE                  --> Cód. Operador
                                        ,pr_qtregist OUT NUMBER                                 --> Quantidade de Registros  
																				,pr_cdcritic OUT crapcri.cdcritic%TYPE                 --> Cód. da crítica
																				,pr_dscritic OUT crapcri.dscritic%TYPE                 --> Descrição da crítica
																				,pr_tab_cde  OUT typ_tab_cde) IS		                   --> Pl/Table com os dados de cobrança de emprestimos
		BEGIN
	 	  /* .............................................................................

      Programa: pc_buscar_boletos
      Sistema : CECRED
      Sigla   : COBTIT
      Autor   : Vitor Shimada Assanuma
      Data    : Junho/2018                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina referente a busca dos boletos de contratos
      Observacao: Importação da Rotina da EMPR0007
      Alteracoes: 

    ..............................................................................*/
			DECLARE
			----------------------------- VARIAVEIS ---------------------------------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

			vr_ind_cde INTEGER := 0;

      vr_tab_cob cobr0005.typ_tab_cob;

			---------------------------- CURSORES -----------------------------------
			CURSOR cr_crapcob
      IS SELECT cde.cdcooper cdcooper
			         ,ass.cdagenci cdagenci
							 ,cde.nrctremp nrctremp
							 ,cde.nrdconta nrdconta
							 ,cde.nrcnvcob nrcnvcob
							 ,cde.nrboleto nrdocmto
							 ,cob.dtmvtolt dtmvtolt
							 ,cob.dtvencto dtvencto
							 ,cob.vltitulo vlboleto
							 ,cob.dtdpagto dtdpagto
							 ,cob.vldpagto vldpagto
               ,cob.rowid    rowidcob
							 ,decode(cde.tpenvio,1,'EMAIL',2,'SMS',3,'IMPRESSO') dstipenv
							 ,cde.cdoperad_envio cdopeenv
							 ,cde.dhenvio dtdenvio
							 ,decode(cde.tpenvio,0,'PENDENTE',1,cde.dsemail,2,to_char(nrddd_sms) || to_char(nrtel_sms),3,'IMPRESSO') dsdenvio
               ,decode(cob.incobran,0,'ABERTO',3,'BAIXADO',5,'PAGO') dssituac
			         ,cob.dtdbaixa dtdbaixa
							 ,cde.dsemail  dsdemail
							 ,('(' || to_char(cde.nrddd_sms,'000') || ')' || to_char(cde.nrtel_sms, '9999g9999','nls_numeric_characters=.-')) dsdtelef
							 ,cde.nmcontato nmpescto
							 ,cde.nrdconta_cob nrctacob
               ,cde.dsparcelas
           FROM crapcob cob, tbrecup_cobranca cde, crapass ass
          WHERE cde.cdcooper = pr_cdcooper                            --> Cód. cooperativa
					  AND (pr_cdagenci = 0     OR ass.cdagenci =  pr_cdagenci)  --> PA
						AND (pr_nrdconta = 0     OR cde.nrdconta =  pr_nrdconta)  --> Nr. da Conta
						AND (pr_nrborder = 0     OR cde.nrctremp =  pr_nrborder)  --> Nr. Bordero
            AND ( cob.dtdbaixa >= NVL(pr_dtbaixai, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtdbaixa IS NULL AND pr_dtbaixai IS NULL))
            AND ( cob.dtdbaixa <= NVL(pr_dtbaixaf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtdbaixa IS NULL AND pr_dtbaixaf IS NULL))
            AND ( cob.dtmvtolt >= NVL(pr_dtemissi, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtmvtolt IS NULL AND pr_dtemissi IS NULL))
            AND ( cob.dtmvtolt <= NVL(pr_dtemissf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtmvtolt IS NULL AND pr_dtemissf IS NULL))
            AND ( cob.dtvencto >= NVL(pr_dtvencti, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtvencto IS NULL AND pr_dtvencti IS NULL))
            AND ( cob.dtvencto <= NVL(pr_dtvenctf, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtvencto IS NULL AND pr_dtvenctf IS NULL))
            AND ( cob.dtdpagto >= NVL(pr_dtpagtoi, to_date('01/01/0001','dd/mm/yyyy')) OR ( cob.dtdpagto IS NULL AND pr_dtpagtoi IS NULL))
            AND ( cob.dtdpagto <= NVL(pr_dtpagtof, to_date('31/12/2099','dd/mm/yyyy')) OR ( cob.dtdpagto IS NULL AND pr_dtpagtof IS NULL))
					  AND cob.cdcooper = cde.cdcooper
            AND cob.nrdconta = cde.nrdconta_cob
            AND cob.nrcnvcob = cde.nrcnvcob
            AND cob.nrdocmto = cde.nrboleto
            AND ass.cdcooper = cde.cdcooper
            AND ass.nrdconta = cde.nrdconta
            AND cde.tpproduto = 3 -- Bordero
				  ORDER BY cde.nrdconta,
					         cde.nrctremp;
      rw_crapcob cr_crapcob%ROWTYPE;

			BEGIN

        ---------------------------------- VALIDACOES INICIAIS --------------------------

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtbaixai IS NOT NULL AND pr_dtbaixaf IS NULL OR
					 pr_dtbaixai IS NULL AND pr_dtbaixaf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Baixa.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtemissi IS NOT NULL AND pr_dtemissf IS NULL OR
					 pr_dtemissi IS NULL AND pr_dtemissf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Emissao.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtvencti IS NOT NULL AND pr_dtvenctf IS NULL OR
					 pr_dtvencti IS NULL AND pr_dtvenctf IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Vencimento.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
			  END IF;

			  -- Gera exceção se informar data de inicio e não informar data final e vice-versa
				IF pr_dtpagtoi IS NOT NULL AND pr_dtpagtof IS NULL OR
					 pr_dtpagtoi IS NULL AND pr_dtpagtof IS NOT NULL THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Deve ser informado data De e Ate do Campo Data Pagto.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
			  END IF;

				-- Gera exceção se a data inicial informada for maior que a final
			  IF pr_dtbaixai > pr_dtbaixaf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
		    IF pr_dtemissi > pr_dtemissf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
				IF pr_dtvencti > pr_dtvenctf THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Gera exceção se a data inicial informada for maior que a final
 				IF pr_dtpagtoi > pr_dtpagtof THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto inicial deve ser menor ou igual a final.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtbaixaf - pr_dtbaixai) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Baixa final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtemissf - pr_dtemissi) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Emissao final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtvenctf - pr_dtvencti) > 30 THEN
				   -- Monta Crítica
					 vr_cdcritic := 0;
					 vr_dscritic := 'Data Vencimento final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

			  -- Gera exceção se a data final ultrapassar 30 dias da data inicial
			  IF (pr_dtpagtof - pr_dtpagtoi) > 30 THEN
					 -- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Data Pagto final nao deve ultrapassar 30 dias da data inicial.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				IF (pr_cdagenci > 0) AND
					 (pr_dtbaixai IS NULL AND
					  pr_dtemissi IS NULL AND
					  pr_dtvencti IS NULL AND
						pr_dtpagtoi IS NULL) THEN
					-- Monta Crítica
				   vr_cdcritic := 0;
					 vr_dscritic := 'Ao informar o PA, deve ser informado alguma data.';
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				-- Abre cursor para atribuir os registros encontrados na PL/Table
				FOR rw_crapcob IN cr_crapcob LOOP
 				  -- Incrementa contador para utilizar como indice da PL/Table
			    vr_ind_cde := vr_ind_cde + 1;

				  pr_tab_cde(vr_ind_cde).cdcooper := rw_crapcob.cdcooper;
					pr_tab_cde(vr_ind_cde).cdagenci := rw_crapcob.cdagenci;
					pr_tab_cde(vr_ind_cde).nrborder := rw_crapcob.nrctremp;
					pr_tab_cde(vr_ind_cde).nrdconta := rw_crapcob.nrdconta;
					pr_tab_cde(vr_ind_cde).nrcnvcob := rw_crapcob.nrcnvcob;
					pr_tab_cde(vr_ind_cde).nrdocmto := rw_crapcob.nrdocmto;
					pr_tab_cde(vr_ind_cde).dtmvtolt := rw_crapcob.dtmvtolt;
					pr_tab_cde(vr_ind_cde).dtvencto := rw_crapcob.dtvencto;
					pr_tab_cde(vr_ind_cde).vlboleto := rw_crapcob.vlboleto;
					pr_tab_cde(vr_ind_cde).dstipenv := rw_crapcob.dstipenv;
					pr_tab_cde(vr_ind_cde).cdopeenv := rw_crapcob.cdopeenv;
					pr_tab_cde(vr_ind_cde).dtdenvio := rw_crapcob.dtdenvio;
					pr_tab_cde(vr_ind_cde).dsdenvio := rw_crapcob.dsdenvio;
					pr_tab_cde(vr_ind_cde).dssituac := rw_crapcob.dssituac;
					pr_tab_cde(vr_ind_cde).dtdbaixa := rw_crapcob.dtdbaixa;
					pr_tab_cde(vr_ind_cde).dsdemail := rw_crapcob.dsdemail;
					pr_tab_cde(vr_ind_cde).dsdtelef := rw_crapcob.dsdtelef;
					pr_tab_cde(vr_ind_cde).nmpescto := rw_crapcob.nmpescto;
					pr_tab_cde(vr_ind_cde).nrctacob := rw_crapcob.nrctacob;
          pr_tab_cde(vr_ind_cde).dtdpagto := rw_crapcob.dtdpagto;
          pr_tab_cde(vr_ind_cde).vldpagto := rw_crapcob.vldpagto;
          pr_tab_cde(vr_ind_cde).dsparcel := rw_crapcob.dsparcelas;

          cobr0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
--                                            ,pr_rowidcob => rw_crapcob.rowidcob
                                            ,pr_nrdconta => rw_crapcob.nrctacob
                                            ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                            ,pr_nrdocmto => rw_crapcob.nrdocmto
                                            ,pr_cdoperad => pr_cdoperad
                                            ,pr_nriniseq => 1
                                            ,pr_nrregist => 1
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_tab_cob  => vr_tab_cob);

          IF pr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
             RAISE vr_exc_erro;
          END IF;

          IF vr_tab_cob.EXISTS(1) IS NOT NULL THEN
             pr_tab_cde(vr_ind_cde).lindigit := vr_tab_cob(1).lindigit;
          END IF;

				END LOOP;
        
        IF (vr_ind_cde=0) THEN
          vr_dscritic := 'Dados nao encontrados!';
          RAISE vr_exc_erro;
        END IF;
        -- Quantidade de Registros
        pr_qtregist := vr_ind_cde;

			EXCEPTION
        WHEN vr_exc_erro THEN
          -- Se possui código de crítica e não foi informado a descrição
          IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
             -- Busca descrição da crítica
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;

          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

        WHEN OTHERS THEN
          -- Atribui exceção para os parametros de crítica
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro nao tratado na TELA_COBTIT.pc_buscar_boletos: ' || SQLERRM;

			END;
	END pc_buscar_boletos;
  
  PROCEDURE pc_buscar_boletos_web (pr_cdagenci IN crapass.cdagenci%TYPE DEFAULT 0         --> PA
                              ,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE DEFAULT 0  --> Nr. do Bordero
                              ,pr_nrdconta IN crapass.nrdconta%TYPE DEFAULT 0         --> Nr. da Conta
                              ,pr_dtbaixai IN VARCHAR2                                --> Data de baixa inicial
                              ,pr_dtbaixaf IN VARCHAR2                                --> Data de baixa final
                              ,pr_dtemissi IN VARCHAR2                                --> Data de emissão inicial
                              ,pr_dtemissf IN VARCHAR2                                --> Data de emissão final
                              ,pr_dtvencti IN VARCHAR2                                --> Data de vencimento inicial
                              ,pr_dtvenctf IN VARCHAR2                                --> Data de vencimento final
                              ,pr_dtpagtoi IN VARCHAR2                                --> Data de pagamento inicial
                              ,pr_dtpagtof IN VARCHAR2                                --> Data de pagamento final
                              ,pr_nriniseq IN INTEGER                                 --> Registro inicial da listagem
                              ,pr_nrregist IN INTEGER                                 --> Numero de registros p/ paginaca
                              ,pr_xmllog   IN VARCHAR2                                --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                            --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                               --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType                      --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                               --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS                           --> Erros do processo
  BEGIN
    /* .............................................................................

    Programa: pc_buscar_boletos_web
    Sistema : CECRED
    Sigla   : TELA
    Autor   : Vitor Shimada Assanuma
    Data    : Junho/2018.                    Ultima atualizacao: --/--/----

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina referente a busca dos boletos da COBTIT
    Observacao: -----
    Alteracoes: 

  ..............................................................................*/
    DECLARE
      -- Variável de críticas
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
      vr_index INTEGER := 0; -- controla paginacao 
      vr_qtregist NUMBER;
      
      -- Tabela de Saida
			vr_tab_cde typ_tab_cde; -- PL/Table com os dados retornados da procedure
      
      -- Datas
      vr_dtbaixai DATE;
      vr_dtbaixaf DATE;
      vr_dtemissi DATE;
      vr_dtemissf DATE;
      vr_dtvencti DATE;
      vr_dtvenctf DATE;
      vr_dtpagtoi DATE;
      vr_dtpagtof DATE;

    BEGIN
      -- Extrair dados padrao
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);
     
      -- Ajuste de data
      vr_dtbaixai := to_date(pr_dtbaixai,'DD/MM/RRRR');
      vr_dtbaixaf := to_date(pr_dtbaixaf,'DD/MM/RRRR');
      vr_dtemissi := to_date(pr_dtemissi,'DD/MM/RRRR');
      vr_dtemissf := to_date(pr_dtemissf,'DD/MM/RRRR');
      vr_dtvencti := to_date(pr_dtvencti,'DD/MM/RRRR');
      vr_dtvenctf := to_date(pr_dtvenctf,'DD/MM/RRRR');
      vr_dtpagtoi := to_date(pr_dtpagtoi,'DD/MM/RRRR');
      vr_dtpagtof := to_date(pr_dtpagtof,'DD/MM/RRRR');
        
      -- Busca os boletos
      pc_buscar_boletos(pr_cdcooper => vr_cdcooper     --> Cooperativa
                                       ,pr_cdagenci => pr_cdagenci     --> PA
                                       ,pr_nrborder => pr_nrborder     --> Nr. do Bordero
                                       ,pr_nrdconta => pr_nrdconta     --> Nr. da Conta
                                       ,pr_dtbaixai => vr_dtbaixai     --> Data de baixa inicial
                                       ,pr_dtbaixaf => vr_dtbaixaf     --> Data de baixa final
                                       ,pr_dtemissi => vr_dtemissi     --> Data de emissão inicial
                                       ,pr_dtemissf => vr_dtemissf     --> Data de emissão final
                                       ,pr_dtvencti => vr_dtvencti     --> Data de vencimento inicial
                                       ,pr_dtvenctf => vr_dtvenctf     --> Data de vencimento final
                                       ,pr_dtpagtoi => vr_dtpagtoi     --> Data de pagamento inicial
                                       ,pr_dtpagtof => vr_dtpagtof     --> Data de pagamento final
                                       ,pr_cdoperad => vr_cdoperad     --> Cód. Operador
                                       ,pr_qtregist => vr_qtregist     --> Quantidade de Registros
                                       ,pr_cdcritic => vr_cdcritic     --> Cód. da crítica
                                       ,pr_dscritic => vr_dscritic     --> Descrição da crítica
                                       ,pr_tab_cde  => vr_tab_cde);    --> Pl/Table com os dados de cobrança de emprestimos
                                       
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
      vr_index := vr_tab_cde.first;
      while vr_index is not null loop
         pc_escreve_xml('<inf>'||
                          '<cdcooper>' || vr_tab_cde(vr_index).cdcooper  || '</cdcooper>' ||
                          '<cdagenci>' || vr_tab_cde(vr_index).cdagenci  || '</cdagenci>' ||
                          '<nrborder>' || vr_tab_cde(vr_index).nrborder  || '</nrborder>' ||
                          '<nrdconta>' || vr_tab_cde(vr_index).nrdconta  || '</nrdconta>' ||
                          '<nrcnvcob>' || vr_tab_cde(vr_index).nrcnvcob  || '</nrcnvcob>' ||
                          '<nrdocmto>' || vr_tab_cde(vr_index).nrdocmto  || '</nrdocmto>' ||
                          '<dtmvtolt>' || to_char(vr_tab_cde(vr_index).dtmvtolt, 'DD/MM/RRRR')  || '</dtmvtolt>' ||
                          '<dtvencto>' || to_char(vr_tab_cde(vr_index).dtvencto, 'DD/MM/RRRR')  || '</dtvencto>' ||
                          '<vlboleto>' || vr_tab_cde(vr_index).vlboleto  || '</vlboleto>' ||
                          '<dstipenv>' || vr_tab_cde(vr_index).dstipenv  || '</dstipenv>' ||
                          '<cdopeenv>' || vr_tab_cde(vr_index).cdopeenv  || '</cdopeenv>' ||
                          '<dtdenvio>' || to_char(vr_tab_cde(vr_index).dtdenvio, 'DD/MM/RRRR')  || '</dtdenvio>' ||
                          '<dsdenvio>' || vr_tab_cde(vr_index).dsdenvio  || '</dsdenvio>' ||
                          '<dssituac>' || vr_tab_cde(vr_index).dssituac  || '</dssituac>' ||
                          '<dtdbaixa>' || to_char(vr_tab_cde(vr_index).dtdbaixa, 'DD/MM/RRRR')  || '</dtdbaixa>' ||
                          '<dsdemail>' || vr_tab_cde(vr_index).dsdemail  || '</dsdemail>' ||
                          '<dsdtelef>' || vr_tab_cde(vr_index).dsdtelef  || '</dsdtelef>' ||
                          '<nmpescto>' || vr_tab_cde(vr_index).nmpescto  || '</nmpescto>' ||
                          '<nrctacob>' || vr_tab_cde(vr_index).nrctacob  || '</nrctacob>' ||
                          '<dtdpagto>' || to_char(vr_tab_cde(vr_index).dtdpagto, 'DD/MM/RRRR')  || '</dtdpagto>' ||
                          '<vldpagto>' || vr_tab_cde(vr_index).vldpagto  || '</vldpagto>' ||
                          '<dsparcelas>' || vr_tab_cde(vr_index).dsparcel  || '</dsparcelas>' ||
                          '<lindigit>' || vr_tab_cde(vr_index).lindigit  || '</lindigit>' ||
                        '</inf>'
                      );
          /* buscar proximo */
          vr_index := vr_tab_cde.next(vr_index);
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
           pr_dscritic := 'erro nao tratado na TELA_COBTIT.pc_buscar_bordero_vencido_web ' ||sqlerrm;
           -- Carregar XML padrao para variavel de retorno
            pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');    
    END;
  END pc_buscar_boletos_web;
  
  	PROCEDURE pc_baixa_boleto(pr_cdcooper IN crapepr.cdcooper%TYPE         --> Cód. cooperativa
																		,pr_nrdconta IN crapepr.nrdconta%TYPE         --> Nr. da conta
																		,pr_nrborder IN crapepr.nrctremp%TYPE         --> Nr. contrato de empréstiomo
																		,pr_nrctacob IN crapepr.nrdconta%TYPE         --> Nr. da conta cobrança
																		,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE         --> Nr. convenio
																		,pr_nrdocmto IN crapcob.nrdocmto%TYPE         --> Nr. documento
																		,pr_dtmvtolt IN crapepr.dtmvtolt%TYPE         --> Data de movimento
																		,pr_idorigem IN INTEGER                       --> Id origem
																		,pr_cdoperad IN crapcob.cdoperad%TYPE         --> Cód. operador
																		,pr_nmdatela IN VARCHAR2                      --> Nome da tela
																		,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Cód. da crítica
																		,pr_dscritic OUT crapcri.dscritic%TYPE) IS    --> Descrição da crítica
	BEGIN																		
	/* .............................................................................

      Programa: pc_baixa_boleto
      Sistema : CECRED
      Sigla   : COBTIT
      Autor   : Vitor Shimada Assanuma (GFT)
      Data    : Setembro/15.                    Ultima atualizacao: --/--/----

      Dados referentes ao programa:
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar a instrução de baixa de boleto utilizados no bordero
      Observacao: -----
      Alteracoes: 
  ..............................................................................*/																								
		DECLARE
		
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro
			vr_des_erro VARCHAR(3);                   --> Retorno da procedure
		
		  -- Tratamento de erros
		  vr_exc_erro EXCEPTION;			
			
			-- Pl/Table utilizada na procedure de baixa
			vr_tab_lat_consolidada paga0001.typ_tab_lat_consolidada;

      -- Variáveis locais
			vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
 			vr_dstransa VARCHAR2(1000) := 'Boleto baixado pela tela COBTIT';
			vr_nrdrowid ROWID;
      --------------------------------- CURSORES --------------------------------
      -- Cursor para verificar se operador tem acesso a opção de baixa da tela
			CURSOR cr_crapace IS
			  SELECT 1
				  FROM crapace ace
				 WHERE ace.cdcooper = pr_cdcooper
				   AND UPPER(ace.cdoperad) = UPPER(pr_cdoperad)
           AND UPPER(ace.nmdatela) = 'COBTIT'
					 AND ace.idambace = 2     
					 AND UPPER(ace.cddopcao) = 'B';
			rw_crapace cr_crapace%ROWTYPE;					 					 
			
			-- Cursor para verificar se o boleto está em aberto
			CURSOR cr_crapcob IS
			  SELECT cob.incobran
				      ,cob.dtvencto
							,cob.vltitulo
				      ,cob.rowid
				  FROM crapcob cob,
					     tbrecup_cobranca cde
				 WHERE cob.cdcooper = pr_cdcooper
				   AND cob.nrdconta = pr_nrctacob
					 AND cob.nrcnvcob = pr_nrcnvcob
					 AND cob.nrdocmto = pr_nrdocmto
					 AND cde.cdcooper = cob.cdcooper
					 AND cde.nrdconta_cob = cob.nrdconta
					 AND cde.nrcnvcob = cob.nrcnvcob
					 AND cde.nrboleto = cob.nrdocmto
           AND cde.tpproduto = 3;
			rw_crapcob cr_crapcob%ROWTYPE;

		BEGIN
      OPEN cr_crapace;
			FETCH cr_crapace INTO rw_crapace;
			
			IF cr_crapace%NOTFOUND AND pr_cdoperad <> '1' THEN
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Operacao nao permitida';
				-- Gera exceção
				RAISE vr_exc_erro;
			END IF;
			
			OPEN cr_crapcob;
			FETCH cr_crapcob INTO rw_crapcob;
			
			IF cr_crapcob%FOUND THEN
   			-- Fecha cursor
			  CLOSE cr_crapcob;
        
				IF rw_crapcob.incobran = 3 THEN
   				-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto ja foi baixado.';					
					-- Gera exceção
					RAISE vr_exc_erro;
				ELSIF rw_crapcob.incobran = 5 THEN
   				-- Atribui crítica
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto ja foi liquidado.';
					-- Gera exceção
					RAISE vr_exc_erro;
				END IF;
				
				-- Efetua baixa
				COBR0007.pc_inst_pedido_baixa(pr_idregcob => rw_crapcob.rowid
				                             ,pr_cdocorre => 0
																		 ,pr_dtmvtolt => pr_dtmvtolt
																		 ,pr_cdoperad => pr_cdoperad
																		 ,pr_nrremass => 0
																		 ,pr_tab_lat_consolidada => vr_tab_lat_consolidada
																		 ,pr_cdcritic => vr_cdcritic
																		 ,pr_dscritic => vr_dscritic);
				-- Se retornou alguma crítica							 
		    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					RAISE vr_exc_erro;
				END IF;
				
		    -- Gera log na lgm
			  gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
														 pr_cdoperad => pr_cdoperad,
														 pr_dscritic => '',
														 pr_dsorigem => vr_dsorigem,
														 pr_dstransa => vr_dstransa,
														 pr_dttransa => TRUNC(SYSDATE),
														 pr_flgtrans => 1,
														 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
														 pr_idseqttl => 0,
														 pr_nmdatela => pr_nmdatela,
														 pr_nrdconta => pr_nrdconta,
														 pr_nrdrowid => vr_nrdrowid);

				-- Gera log de itens
				-- Nr. do contrato														 
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Bordero',
																	pr_dsdadant => '',
																	pr_dsdadatu => pr_nrborder);
				-- Nr. do Boleto
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Nr. do Boleto',
																	pr_dsdadant => '',
																	pr_dsdadatu => pr_nrdocmto);
				-- Vencimento
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Vencimento',
																	pr_dsdadant => '',
																	pr_dsdadatu => TO_CHAR(rw_crapcob.dtvencto, 'DD/MM/RRRR'));
				-- Valor do Boleto
				gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																	pr_nmdcampo => 'Vlr do boleto',
																	pr_dsdadant => '',
																	pr_dsdadatu => to_char(rw_crapcob.vltitulo, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));
																	
   			-- Cria log de cobrança
				PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.rowid,
																			pr_cdoperad => pr_cdoperad,
																			pr_dtmvtolt => trunc(SYSDATE),
																			pr_dsmensag => vr_dstransa,
																			pr_des_erro => vr_des_erro,
																			pr_dscritic => vr_dscritic);

				-- Se retornou algum erro
				IF vr_des_erro <> 'OK' AND
					 trim(vr_dscritic) IS NOT NULL THEN
					 -- Levanta exceção
					 RAISE vr_exc_erro;
				END IF;

				COMMIT;
                npcb0002.pc_libera_sessao_sqlserver_npc('COBTIT_1');
				
			ELSE
				-- Fecha cursor
				CLOSE cr_crapcob;
				-- Atribui crítica
				vr_cdcritic := 0;
				vr_dscritic := 'Boleto nao encontrado';
				-- Gera exceção
				RAISE vr_exc_erro;
			END IF;
			
		EXCEPTION	
		  WHEN vr_exc_erro THEN
      begin
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('COBTIT_2');
      end;
			WHEN OTHERS THEN  				
      begin
				-- Atribui exceção para os parametros de crítica				
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na COBTIT.pc_baixa_boleto: ' || SQLERRM;			
        ROLLBACK;
        npcb0002.pc_libera_sessao_sqlserver_npc('TELA_COBTIT');
      end;
		END;						
	END pc_baixa_boleto;
  
  PROCEDURE pc_baixa_boleto_web(pr_nrdconta IN crapepr.nrdconta%TYPE  --> Nr. da conta
                              ,pr_nrborder IN crapepr.nrctremp%TYPE  --> Nr. do bordero
                              ,pr_nrctacob IN crapepr.nrdconta%TYPE  --> Nr. da conta cobrança
                              ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE  --> Nr. convenio
                              ,pr_nrdocmto IN crapcob.nrdocmto%TYPE  --> Nr. documento
                              ,pr_dtmvtolt IN VARCHAR2               --> Data de movimento
                              ,pr_dsjustif IN VARCHAR2               --> Justificativa de Baixa
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN  OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
	/* .............................................................................

      Programa: pc_baixa_boleto_web
      Sistema : CECRED
      Sigla   : CRED
      Autor   : Vitor Shimada Assanuma
      Data    : Junho/2018                               Ultima atualizacao: --/--/----

      Dados referentes ao programa:
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para realizar a instrução de baixa de boleto utilizados para bordero
      Observacao: Adaptação do EMPR0007.pc_inst_baixa_boleto_epr_web para Bordero
      Alteracoes: 
  ..............................................................................*/																									
  BEGIN
		DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro

		  -- Tratamento de erros
		  vr_exc_erro EXCEPTION;

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis Gerais
      vr_dsjustif VARCHAR2(1000);
      
      FUNCTION fn_normalizar(str_in VARCHAR2) RETURN VARCHAR2 IS
         pos           NUMBER(10);
         chars_special VARCHAR2(255);
         chars_normal  VARCHAR2(255);
         str           VARCHAR2(255) := UPPER(str_in);
		BEGIN
         chars_special := 'ÁÀÃÂÉÊÍÓÔÕÚÜÇ.-';
         chars_normal  := 'AAAAEEIOOOUUC  ';
         str           := TRIM(upper(str));
         pos           := length(chars_normal);
         WHILE pos > 0
         LOOP
            str := REPLACE(str,
                           substr(chars_special, pos, 1),
                           substr(chars_normal, pos, 1));
            pos := pos - 1;
         END LOOP;
         str := TRIM(str);
         WHILE regexp_like(str, ' {2,}')
         LOOP
            str := REPLACE(str, '  ', ' ');
         END LOOP;
         pos := length(str);
         WHILE pos > 0
         LOOP
            IF regexp_like(substr(str, pos, 1), '[^A-Z0-9Ç@._ +-]+')
            THEN
               str := concat(substr(str, 1, pos - 1), substr(str, pos + 1));
            END IF;
            pos := pos - 1;
         END LOOP;
         RETURN str;
      END;

		BEGIN

			pr_des_erro := 'OK';
			-- Extrai dados do xml
			gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF trim(vr_dscritic) IS NOT NULL THEN
				-- Levanta exceção
				RAISE vr_exc_erro;
			END IF;

      vr_dsjustif := fn_normalizar(GENE0007.fn_remove_cdata(pr_dsjustif));
      
      IF LENGTH(vr_dsjustif) < 5 THEN
        vr_dscritic := 'Justificativa da Baixa deve ser informada!';
        RAISE vr_exc_erro;
      END IF;

      IF LENGTH(vr_dsjustif) > 200 THEN
        vr_dscritic := 'Justificativa da Baixa deve respeitar o tamanho maximo de 200 caracteres!';
				RAISE vr_exc_erro;
			END IF;

      pc_baixa_boleto(pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrborder => pr_nrborder
                    ,pr_nrctacob => pr_nrctacob
                    ,pr_nrcnvcob => pr_nrcnvcob
                    ,pr_nrdocmto => pr_nrdocmto
                    ,pr_dtmvtolt => to_date(pr_dtmvtolt, 'DD/MM/RRRR')
                    ,pr_idorigem => GENE0002.fn_char_para_number(vr_idorigem)
                    ,pr_cdoperad => vr_cdoperad
                    ,pr_nmdatela => vr_nmdatela
                    ,pr_cdcritic => vr_cdcritic
                    ,pr_dscritic => vr_dscritic);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_erro;
		  END IF;

      -- Atualiza a Justificativa
      BEGIN
        UPDATE tbrecup_cobranca
           SET dsjustifica_baixa = vr_dsjustif
         WHERE cdcooper          = vr_cdcooper
           AND nrdconta          = pr_nrdconta
           AND nrctremp          = pr_nrborder
           AND nrdconta_cob      = pr_nrctacob
           AND nrcnvcob          = pr_nrcnvcob
           AND nrboleto          = pr_nrdocmto
           AND tpproduto = 3; -- Bordero
	  EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao alterar dados na tabela tbrecup_cobranca: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;

	  EXCEPTION
      WHEN vr_exc_erro THEN

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
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
			  pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
	END pc_baixa_boleto_web;
  
  PROCEDURE pc_gerar_pdf_boletos(pr_cdcooper IN crapass.cdcooper%TYPE --> Cód. cooperativa
		                            ,pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
																,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> Nr. do convênio
																,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Nr docmto
																,pr_cdoperad IN crapope.cdoperad%TYPE --> Cód operador
																,pr_idorigem IN NUMBER                --> Id origem
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE DEFAULT 0  --> Tipo de envio
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT '' --> Email
																,pr_nmarqpdf OUT VARCHAR2             --> Nome do arquivo em PDF
																,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
																,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
																,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
	/* .............................................................................

		Programa: pc_gerar_pdf_boletos
		Sistema : CECRED
		Sigla   : CRED
		Autor   : Luis Fernando (GFT)
		Data    : Junho/2018

		Dados referentes ao programa:
		Frequencia: Sempre que for chamado
		Objetivo  : Rotina para gerar a impressao do boleto em pdf
		Observacao: -----

	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
			vr_cdcritic crapcri.cdcritic%TYPE;
			vr_dscritic VARCHAR2(10000);

			-- Tratamento de erros
			vr_exc_erro EXCEPTION;
			vr_tab_erro  gene0001.typ_tab_erro;

			-- PL/Table com as informações do boleto
			vr_tab_cob cobr0005.typ_tab_cob;

			vr_des_reto VARCHAR2(3);

			-- Variáveis para geração do relatório
			vr_clobxml    CLOB;
			vr_dstextorel VARCHAR2(32600);
			vr_dstexto    VARCHAR2(32600);
			vr_nmdireto   VARCHAR2(1000);
			vr_dsparams   VARCHAR2(1000);
      vr_nmrescop   crapcop.nmrescop%TYPE;
	    
			vr_valords    NUMBER; 
			vr_valorad    NUMBER;

      -- variaveis do email
      vr_dscorema   VARCHAR2(4000); -- corpo do email                 
      vr_des_erro VARCHAR2(4000);
      
       vr_flgativo INTEGER := 0;
			---------------------------- CURSORES -----------------------------------
			CURSOR cr_tbepr_cde(pr_cdcooper crapcop.cdcooper%TYPE
												 ,pr_nrctacob tbrecup_cobranca.nrdconta_cob%TYPE
												 ,pr_nrcnvcob tbrecup_cobranca.nrcnvcob%TYPE
												 ,pr_nrdocmto tbrecup_cobranca.nrboleto%TYPE) IS
				SELECT cde.nrdconta
              ,cde.nrctremp
					FROM tbrecup_cobranca cde
				 WHERE cde.cdcooper = pr_cdcooper
					 AND cde.nrdconta_cob = pr_nrctacob
					 AND cde.nrcnvcob = pr_nrcnvcob
					 AND cde.nrboleto = pr_nrdocmto
           AND cde.tpproduto = 3; -- bordero
	    rw_tbepr_cde cr_tbepr_cde%ROWTYPE;
		BEGIN

			---------------------------------- VALIDACOES INICIAIS --------------------------

				COBR0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper
																					,pr_nrdconta => pr_nrdconta
																					,pr_nrcnvcob => pr_nrcnvcob
																					,pr_nrdocmto => pr_nrdocmto
																					,pr_cdoperad => pr_cdoperad
																					,pr_nriniseq => 1
																					,pr_nrregist => 1
																					,pr_cdcritic => vr_cdcritic
																					,pr_dscritic => vr_dscritic
																					,pr_tab_cob  => vr_tab_cob);

        -- Verifica se retornou alguma crítica
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					 -- Gera exceção
					 RAISE vr_exc_erro;
				END IF;

				IF NOT vr_tab_cob.EXISTS(vr_tab_cob.FIRST) THEN
					 vr_cdcritic := 0;
					 vr_dscritic := 'Dados nao encontrados';
					 RAISE vr_exc_erro;
				END IF;
				
				-- Abre cursor de boleto de cobrança de emprestimo
				OPEN cr_tbepr_cde(pr_cdcooper => pr_cdcooper
				                 ,pr_nrctacob => pr_nrdconta
												 ,pr_nrcnvcob => pr_nrcnvcob
												 ,pr_nrdocmto => pr_nrdocmto);
	      FETCH cr_tbepr_cde INTO rw_tbepr_cde;
				
				-- Se não encontrou boleto de cobrança de emprestimo
				IF cr_tbepr_cde%NOTFOUND THEN
					-- Atribui crítca
					vr_cdcritic := 0;
					vr_dscritic := 'Boleto nao encontrado';
					-- Gera exceção
					RAISE vr_exc_erro;
				END IF;
				
         -- Verifica se retornou alguma crítica
				IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					 -- Gera exceção
					 RAISE vr_exc_erro;
				END IF;
/*
        -- Verifica contratos de acordo
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => rw_tbepr_cde.nrctremp
                                         ,pr_cdorigem => 3
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
            
        IF vr_flgativo = 1 THEN
          vr_dscritic := 'Geracao do boleto nao permitido, bordero em acordo.';
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;*/

				-- Busca do diretório base da cooperativa para a geração de relatórios
				vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'          --> /usr/coop
																						,pr_cdcooper => pr_cdcooper  --> Cooperativa
																						,pr_nmsubdir => 'rl');       --> Utilizaremos o rl

				-- Inicializar as informações do XML de dados para o relatório
				dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
				dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
				--Escrever no arquivo XML
				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel,'<?xml version="1.0" encoding="UTF-8"?><Root><Dados>');

				vr_dstexto :=               '<cdcooper>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdcooper, '') || '</cdcooper>';
				vr_dstexto := vr_dstexto || '<nrdconta>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdconta, '') || '</nrdconta>';
				vr_dstexto := vr_dstexto || '<idseqttl>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).idseqttl, '') || '</idseqttl>';
				vr_dstexto := vr_dstexto || '<nmprimtl>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmprimtl, '') || '</nmprimtl>';
				vr_dstexto := vr_dstexto || '<incobran>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).incobran, '') || '</incobran>';
				vr_dstexto := vr_dstexto || '<nossonro>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nossonro, '') || '</nossonro>';
				vr_dstexto := vr_dstexto || '<nrctremp>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrctremp, '') || '</nrctremp>';
				vr_dstexto := vr_dstexto || '<nmdsacad>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmdsacad, '') || '</nmdsacad>';
				vr_dstexto := vr_dstexto || '<cdbandoc>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdbandoc, '') || '</cdbandoc>';
				vr_dstexto := vr_dstexto || '<nmdavali>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nmdavali, '') || '</nmdavali>';
				vr_dstexto := vr_dstexto || '<dsbandig>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsbandig, '') || '</dsbandig>';
				vr_dstexto := vr_dstexto || '<nrinsava>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrinsava, '') || '</nrinsava>';
				vr_dstexto := vr_dstexto || '<cdtpinav>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdtpinav, '') || '</cdtpinav>';
				vr_dstexto := vr_dstexto || '<nrcnvcob>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrcnvcob, '') || '</nrcnvcob>';
				vr_dstexto := vr_dstexto || '<nrcnvceb>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrcnvceb, '') || '</nrcnvceb>';
				vr_dstexto := vr_dstexto || '<nrdctabb>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdctabb, '') || '</nrdctabb>';
				vr_dstexto := vr_dstexto || '<nrcpfcgc>' || NVL(gene0002.fn_mask_cpf_cnpj(vr_tab_cob(vr_tab_cob.FIRST).nrcpfcgc, vr_tab_cob(vr_tab_cob.FIRST).inpessoa), '') || '</nrcpfcgc>';
				vr_dstexto := vr_dstexto || '<inpessoa>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).inpessoa, '') || '</inpessoa>';
				vr_dstexto := vr_dstexto || '<nrdocmto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrdocmto, '') || '</nrdocmto>';
				vr_dstexto := vr_dstexto || '<dtmvtolt>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtmvtolt, 'DD/MM/RRRR'), '') || '</dtmvtolt>';
				vr_dstexto := vr_dstexto || '<dsdinstr>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinstr, '') || '</dsdinstr>';
				vr_dstexto := vr_dstexto || '<dsdinst1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst1, '') || '</dsdinst1>';
				vr_dstexto := vr_dstexto || '<dsdinst2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst2, '') || '</dsdinst2>';
				vr_dstexto := vr_dstexto || '<dsdinst3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst3, '') || '</dsdinst3>';
				vr_dstexto := vr_dstexto || '<dsdinst4>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst4, '') || '</dsdinst4>';
				vr_dstexto := vr_dstexto || '<dsdinst5>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdinst5, '') || '</dsdinst5>';
				vr_dstexto := vr_dstexto || '<dsinform>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinform, '') || '</dsinform>';
				vr_dstexto := vr_dstexto || '<dsinfor1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor1, '') || '</dsinfor1>';
				vr_dstexto := vr_dstexto || '<dsinfor2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor2, '') || '</dsinfor2>';
				vr_dstexto := vr_dstexto || '<dsinfor3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor3, '') || '</dsinfor3>';
				vr_dstexto := vr_dstexto || '<dsinfor4>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor4, '') || '</dsinfor4>';
				vr_dstexto := vr_dstexto || '<dsinfor5>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinfor5, '') || '</dsinfor5>';
				vr_dstexto := vr_dstexto || '<dslocpag>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dslocpag, '') || '</dslocpag>';
				vr_dstexto := vr_dstexto || '<dsavis2v>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsavis2v, '') || '</dsavis2v>';
				vr_dstexto := vr_dstexto || '<dsagebnf>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsagebnf, '') || '</dsagebnf>';
				vr_dstexto := vr_dstexto || '<dspagad1>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad1, '') || '</dspagad1>';
				vr_dstexto := vr_dstexto || '<dspagad2>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad2, '') || '</dspagad2>';
				vr_dstexto := vr_dstexto || '<dspagad3>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dspagad3, '') || '</dspagad3>';
				vr_dstexto := vr_dstexto || '<dssacava>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dssacava, '') || '</dssacava>';
				vr_dstexto := vr_dstexto || '<dsdoccop>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdoccop, '') || '</dsdoccop>';
				vr_dstexto := vr_dstexto || '<dtvencto>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtvencto, 'DD/MM/RRRR'), '') || '</dtvencto>';
				vr_dstexto := vr_dstexto || '<vltitulo>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vltitulo, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''')  || '</vltitulo>';
				vr_dstexto := vr_dstexto || '<vldescto>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vldescto, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vldescto>';
				vr_dstexto := vr_dstexto || '<vlabatim>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlabatim, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlabatim>';
			 
        -- Valor Desconto
        vr_valords := NVL(vr_tab_cob(vr_tab_cob.FIRST).vldescto, 0) + NVL(vr_tab_cob(vr_tab_cob.FIRST).vlabatim, 0);
        vr_dstexto := vr_dstexto || '<valordes>' || to_char(NVL(vr_valords, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</valordes>';
        
        --Valor Adicional
        vr_valorad := NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrmulta, 0) + NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrjuros, 0);
        vr_dstexto := vr_dstexto || '<valoradi>' || to_char(NVL(vr_valorad, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</valoradi>';
        
				vr_dstexto := vr_dstexto || '<vlrmulta>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrmulta, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlrmulta>';
				vr_dstexto := vr_dstexto || '<vlrjuros>' || to_char(NVL(vr_tab_cob(vr_tab_cob.FIRST).vlrjuros, 0), 'fm999G999G990D00','NLS_NUMERIC_CHARACTERS = '',.''') || '</vlrjuros>';
				vr_dstexto := vr_dstexto || '<cddespec>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cddespec, '') || '</cddespec>';
				vr_dstexto := vr_dstexto || '<dsdespec>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsdespec, '') || '</dsdespec>';
				vr_dstexto := vr_dstexto || '<dtdocmto>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtdocmto, 'DD/MM/RRRR'), '') || '</dtdocmto>';
				vr_dstexto := vr_dstexto || '<cdcartei>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdcartei, '') || '</cdcartei>';
				vr_dstexto := vr_dstexto || '<nrvarcar>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrvarcar, '') || '</nrvarcar>';
				vr_dstexto := vr_dstexto || '<cdagenci>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdagenci, '') || '</cdagenci>';
				vr_dstexto := vr_dstexto || '<nrnosnum>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).nrnosnum, '') || '</nrnosnum>';
				vr_dstexto := vr_dstexto || '<flgaceit>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).flgaceit, '') || '</flgaceit>';
				vr_dstexto := vr_dstexto || '<agencidv>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).agencidv, '') || '</agencidv>';
				vr_dstexto := vr_dstexto || '<vldocmto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vldocmto, '') || '</vldocmto>';
				vr_dstexto := vr_dstexto || '<vlmormul>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vlmormul, '') || '</vlmormul>';
				vr_dstexto := vr_dstexto || '<dtvctori>' || NVL(TO_CHAR(vr_tab_cob(vr_tab_cob.FIRST).dtvctori, 'DD/MM/RRRR'), '') || '</dtvctori>';
				vr_dstexto := vr_dstexto || '<dscjuros>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscjuros, '') || '</dscjuros>';
				vr_dstexto := vr_dstexto || '<dscmulta>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscmulta, '') || '</dscmulta>';
				vr_dstexto := vr_dstexto || '<dscdscto>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dscdscto, '') || '</dscdscto>';
				vr_dstexto := vr_dstexto || '<dsinssac>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsinssac, '') || '</dsinssac>';
				vr_dstexto := vr_dstexto || '<vldesabt>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vldesabt, '') || '</vldesabt>';
				vr_dstexto := vr_dstexto || '<vljurmul>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).vljurmul, '') || '</vljurmul>';
				vr_dstexto := vr_dstexto || '<inemiten>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).inemiten, '') || '</inemiten>';
				vr_dstexto := vr_dstexto || '<dsemiten>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsemiten, '') || '</dsemiten>';
				vr_dstexto := vr_dstexto || '<dsemitnt>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).dsemitnt, '') || '</dsemitnt>';
				vr_dstexto := vr_dstexto || '<cdbarras>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).cdbarras, '') || '</cdbarras>';
				vr_dstexto := vr_dstexto || '<lindigit>' || NVL(vr_tab_cob(vr_tab_cob.FIRST).lindigit, '') || '</lindigit>';

				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, vr_dstexto);
				-- Fechar arquivo XML
				gene0002.pc_escreve_xml(vr_clobxml, vr_dstextorel, '</Dados></Root>', TRUE);

				pr_nmarqpdf := 'boleto_' || vr_tab_cob(1).nrdconta
																 || vr_tab_cob(1).nrctremp
                                 || TO_CHAR(SYSDATE,'SSSSS')
																 || '.pdf';

				-- Busca caminho da imagem do logo do boleto da cecred
				vr_dsparams := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
																								,pr_cdcooper => 0
																								,pr_cdacesso => 'IMG_BOLETO_085');

        -- Envia relatório por email
        IF pr_tpdenvio = 1 THEN
          
          -- buscar nome da cooperativa
          SELECT cop.nmrescop INTO vr_nmrescop
            FROM crapcop cop
           WHERE cop.cdcooper = pr_cdcooper;
        
          -- corpo do email
          vr_dscorema := '<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >';                    
          vr_dscorema := vr_dscorema || 
                         'Bom dia, <br/><br/>' ||
                         'Esta mensagem refere-se ao boleto emitido pela ' || vr_nmrescop || 
                         ' para o cooperado: <br/><br/>' ||
                         'Nome: ' || vr_tab_cob(vr_tab_cob.FIRST).dspagad1 || '<br/>' ||
                         'E-mail: ' || pr_dsdemail;        
          vr_dscorema := vr_dscorema || '<br/><br/>';
          vr_dscorema := vr_dscorema || 'Boleto em anexo.<br/><br/>';
          vr_dscorema := vr_dscorema || 'D&uacute;vidas, entrar em contato no telefone (47) 3231-1700.<br/>';          
          vr_dscorema := vr_dscorema || '</meta>';                        
					
 					-- Gera impressão do boleto
					gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
																		 ,pr_cdprogra  => 'COBTIT'                      --> Programa chamador
																		 ,pr_dtmvtolt  => TRUNC(SYSDATE)                --> Data do movimento atual
																		 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
																		 ,pr_dsxmlnode => '/Root/Dados'                 --> Nó base do XML para leitura dos dados
																		 ,pr_dsjasper  => 'boleto.jasper'               --> Arquivo de layout do iReport
																		 ,pr_dsparams  => 'PR_IMGDLOGO##' || vr_dsparams--> Parametros do boleto
																		 ,pr_dsarqsaid => vr_nmdireto||'/'||pr_nmarqpdf --> Arquivo final com o path
																		 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
																		 ,pr_cdrelato  => '702'                         --> Cód. relatório
                                     ,pr_flg_gerar => 'S'                           --> gerar PDF
 																		 ,pr_dsmailcop  => pr_dsdemail                  --> Email
																		 ,pr_dsassmail => 'Boleto Bancario - CECRED 085' --> Assunto do e-mail que enviará o arquivo
																		 ,pr_dscormail => vr_dscorema                   --> Corpor do email
																		 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
																		 ,pr_nrcopias  => 1                             --> Número de cópias
																		 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
                                     
          IF vr_dscritic IS NOT NULL THEN             
             RAISE vr_exc_erro;
          END IF;
					
				ELSE                  
					
          EMPR0007.pc_enviar_boleto(pr_cdcooper => vr_tab_cob(vr_tab_cob.FIRST).cdcooper
																	 ,pr_nrdconta => rw_tbepr_cde.nrdconta
																	 ,pr_nrctremp => vr_tab_cob(vr_tab_cob.FIRST).nrctremp
																	 ,pr_nrctacob => vr_tab_cob(vr_tab_cob.FIRST).nrdconta
																	 ,pr_nrcnvcob => vr_tab_cob(vr_tab_cob.FIRST).nrcnvcob
																	 ,pr_nrdocmto => vr_tab_cob(vr_tab_cob.FIRST).nrdocmto
																	 ,pr_cdoperad => pr_cdoperad
																	 ,pr_nmcontat => vr_tab_cob(vr_tab_cob.FIRST).nmprimtl
																	 ,pr_tpdenvio => 3 /* IMPRESSAO */
																	 ,pr_nmdatela => 'COBTIT'
																	 ,pr_idorigem => pr_idorigem
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic);

					 -- Verifica se retornou alguma crítica
					IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
						 -- Gera exceção
						 RAISE vr_exc_erro;
					END IF;

					-- Gera impressão do boleto
					gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
																		 ,pr_cdprogra  => 'COBTIT'                      --> Programa chamador
																		 ,pr_dtmvtolt  => TRUNC(SYSDATE)                --> Data do movimento atual
																		 ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
																		 ,pr_dsxmlnode => '/Root/Dados'                 --> Nó base do XML para leitura dos dados
																		 ,pr_dsjasper  => 'boleto.jasper'               --> Arquivo de layout do iReport
																		 ,pr_dsparams  => 'PR_IMGDLOGO##' || vr_dsparams--> Parametros do boleto
																		 ,pr_dsarqsaid => vr_nmdireto||'/'||pr_nmarqpdf --> Arquivo final com o path
																		 ,pr_qtcoluna  => 132                           --> Colunas do relatorio
																		 ,pr_cdrelato  => '702'                         --> Cód. relatório
																		 ,pr_flg_gerar => 'S'                           --> Geraçao na hora
																		 ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
																		 ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
																		 ,pr_nrcopias  => 1                             --> Número de cópias
																		 ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
																		 
					--Se ocorreu erro no relatorio
					IF vr_dscritic IS NOT NULL THEN
						--Levantar Excecao
						RAISE vr_exc_erro;
					END IF;
					
					gene0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper    --Codigo Cooperativa
																		  ,pr_cdagenci => 1              --Codigo Agencia
																		  ,pr_nrdcaixa => 1
																		  ,pr_nmarqpdf => vr_nmdireto || '/' || pr_nmarqpdf    --Nome Arquivo PDF
                                      ,pr_des_reto => vr_des_reto    --Retorno OK/NOK
																		  ,pr_tab_erro => vr_tab_erro);  --Tabela erro

				  --Se ocorreu erro
				  IF vr_des_reto <> 'OK' THEN
					  --Se tem erro na tabela
						IF vr_tab_erro.COUNT > 0 THEN
							vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
						ELSE
							vr_dscritic:= 'Erro ao enviar arquivo para web.';
						END IF;
					  --Sair
					  RAISE vr_exc_erro;
				  END IF;
												 
					-- Remover relatorio da pasta rl apos gerar
					gene0001.pc_OScommand(pr_typ_comando => 'S'
															 ,pr_des_comando => 'rm ' || vr_nmdireto || '/' ||
																									pr_nmarqpdf
															 ,pr_typ_saida   => vr_des_reto
															 ,pr_des_saida   => vr_dscritic);
					-- Se retornou erro
					IF vr_des_reto = 'ERR'
						 OR vr_dscritic IS NOT null THEN
						-- Concatena o erro que veio
						vr_dscritic := 'Erro ao remover arquivo: ' || vr_dscritic;
						RAISE vr_exc_erro;
					END IF;

        END IF;

				--Fechar Clob e Liberar Memoria
				dbms_lob.close(vr_clobxml);
				dbms_lob.freetemporary(vr_clobxml);

        pr_des_erro := 'OK';

		EXCEPTION
			WHEN vr_exc_erro THEN

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;
				
        pr_des_erro := 'NOK';
				
		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBTIT: ' || SQLERRM;
      pr_des_erro := 'NOK';
		END;
	END pc_gerar_pdf_boletos;
  
  PROCEDURE pc_gerar_pdf_boleto_web (pr_nrdconta IN crapass.nrdconta%TYPE          --> Nr. da Conta
                             ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE          --> Nr. do convenio
                             ,pr_nrdocmto IN crapcob.nrdocmto%TYPE          --> Nr. Docmto
                             ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo
  BEGIN
	/* .............................................................................

		Programa: pc_gerar_pdf_boleto_web
		Sistema : CECRED
		Sigla   : CRED
		Autor   : Luis Fernando (GFT)
		Data    : Junho/2018

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado

		Objetivo  : Rotina para gerar a impressao do boleto em pdf


	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
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

			vr_des_reto VARCHAR2(3);

			vr_nmarqpdf   VARCHAR2(1000);
	    
			---------------------------- CURSORES -----------------------------------
		BEGIN

			---------------------------------- VALIDACOES INICIAIS --------------------------

			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

      -- Chama rotina para gerar o pdf do boleto
      pc_gerar_pdf_boletos(pr_cdcooper => vr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
																	 ,pr_nrcnvcob => pr_nrcnvcob
																	 ,pr_nrdocmto => pr_nrdocmto
																	 ,pr_cdoperad => vr_cdoperad
																	 ,pr_idorigem => vr_idorigem
																	 ,pr_nmarqpdf => vr_nmarqpdf
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic
																	 ,pr_des_erro => vr_des_reto);

      IF vr_des_reto <> 'OK' THEN
				RAISE vr_exc_erro;
			END IF;

			-- Criar XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
																		 vr_nmarqpdf || '</nmarqpdf>');

		EXCEPTION
			WHEN vr_exc_erro THEN

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
	END pc_gerar_pdf_boleto_web;
  
  PROCEDURE pc_enviar_boleto(pr_cdcooper IN tbrecup_cobranca.cdcooper%TYPE              --> Cooperativa
		                        ,pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
														,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
														,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
														,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
														,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
														,pr_cdoperad IN tbrecup_cobranca.cdoperad_envio%TYPE        --> Cód. Operador
														,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
														,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
														,pr_nmdatela IN VARCHAR2                                  --> Nome da tela
														,pr_idorigem IN INTEGER                                   --> ID Origem
														,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
														,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
														,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
														,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
														,pr_cdcritic OUT crapcri.cdcritic%TYPE                    --> Cód. Crítica
														,pr_dscritic OUT crapcri.dscritic%TYPE) IS                --> Desc. Crítica
	BEGIN
 	  /* .............................................................................

      Programa: pc_enviar_boleto
      Sistema : CECRED
      Sigla   : COBTIT
      Autor   : Luis Fernando (GFT)
      Data    : Junho/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Rotina para enviar os boletos por E-mail e SMS
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;        --> Cód. Erro
      vr_dscritic VARCHAR2(1000);               --> Desc. Erro
		  vr_des_erro VARCHAR2(3);                  --> Indicador erro

		  -- Tratamento de erros
      vr_exc_update	EXCEPTION;
		  vr_exc_saida EXCEPTION;
      vr_exc_erro EXCEPTION;

			-- Variaveis locais
			vr_dstransa VARCHAR2(1000);
			vr_dsmensag VARCHAR2(1000);
			vr_nrdrowid ROWID;
			vr_dsorigem VARCHAR2(1000) := TRIM(GENE0001.vr_vet_des_origens(pr_idorigem));
			vr_nmarqpdf VARCHAR2(1000);
      vr_flgativo INTEGER := 0;

			-- PL/Table com os dados retornados da COBR0005.pc_buscar_titulo_cobranca
			vr_tab_cob cobr0005.typ_tab_cob;
      
      -- cursores
      CURSOR cr_boleto (pr_cdcooper IN crapcob.cdcooper%TYPE
                ,pr_nrdconta IN crapcob.nrdconta%TYPE
                ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
         SELECT incobran,
                decode(incobran,0,'aberto',3,'baixado',5,'pago') dscobran
           FROM crapcob cob
          WHERE cob.cdcooper = pr_cdcooper
            AND cob.nrdconta = pr_nrdconta
            AND cob.nrcnvcob = pr_nrcnvcob
            AND cob.nrdocmto = pr_nrdocmto;
      rw_boleto cr_boleto%ROWTYPE;                       

		BEGIN
			BEGIN
        /*
        -- Verifica contratos de acordo
        RECP0001.pc_verifica_acordo_ativo(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrborder => pr_nrborder
                                         ,pr_cdorigem => 3
                                         ,pr_flgativo => vr_flgativo
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
            
        IF vr_flgativo = 1 THEN
          IF pr_tpdenvio = 1 THEN
            vr_dscritic := 'Envio de e-mail nao permitido, emprestimo em acordo.';
          ELSIF pr_tpdenvio = 2 THEN
            vr_dscritic := 'Envio de SMS nao permitido, emprestimo em acordo.';
          ELSIF pr_tpdenvio = 3 THEN
            vr_dscritic := 'Impressao nao permitida, emprestimo em acordo.';    
          END IF;
          -- Gerar exceção
          RAISE vr_exc_erro;
        END IF;
                */
        -- verificar estado do boleto antes de imprimir ou enviar boleto        
        OPEN cr_boleto(pr_cdcooper
                      ,pr_nrctacob
                      ,pr_nrcnvcob
                      ,pr_nrdocmto);
        FETCH cr_boleto INTO rw_boleto;
        IF rw_boleto.incobran IN (3,5) THEN
           CLOSE cr_boleto;
           vr_dscritic := 'Nao e permitido imprimir/enviar boleto ' || rw_boleto.dscobran || '.';
           RAISE vr_exc_erro;
        ELSE
           CLOSE cr_boleto;
        END IF;        
        
				CASE pr_tpdenvio
					-- EMAIL
					WHEN 1 THEN
						UPDATE tbrecup_cobranca cde
							 SET cde.dsemail        = pr_dsdemail
									,cde.nmcontato      = pr_nmcontat
						 WHERE cde.cdcooper = pr_cdcooper
							 AND cde.nrdconta = pr_nrdconta
							 AND cde.nrctremp = pr_nrborder
							 AND cde.nrdconta_cob = pr_nrctacob
							 AND cde.nrcnvcob = pr_nrcnvcob
							 AND cde.nrboleto = pr_nrdocmto
               AND cde.tpproduto = 3;
            
            IF SQL%ROWCOUNT = 0 THEN 
               vr_dscritic := 'Erro ao atualizar boleto. Boleto nao encontrado.';
               RAISE vr_exc_erro;
            END IF;   
               
						vr_dstransa := 'Enviado boleto por e-mail refente ao borderô nr: ' || to_char(pr_nrborder);
						vr_dsmensag := 'Boleto enviado por e-mail ' || pr_dsdemail;
						
						-- Gerar boleto e enviar por email
						pc_gerar_pdf_boletos(pr_cdcooper => pr_cdcooper
						                    ,pr_nrdconta => pr_nrctacob
																,pr_nrcnvcob => pr_nrcnvcob
																,pr_nrdocmto => pr_nrdocmto
																,pr_cdoperad => pr_cdoperad
																,pr_idorigem => pr_idorigem
																,pr_tpdenvio => pr_tpdenvio
																,pr_dsdemail => pr_dsdemail
																,pr_nmarqpdf => vr_nmarqpdf
																,pr_cdcritic => vr_cdcritic
																,pr_dscritic => vr_dscritic
																,pr_des_erro => vr_des_erro);
						
						-- Se retorno for diferente de OK
						IF vr_des_erro <> 'OK' THEN
							-- Gera exceção
							RAISE vr_exc_erro;
						END IF;
					   
					-- SMS
					WHEN 2 THEN
						UPDATE tbrecup_cobranca cde
							 SET cde.tpenvio        = pr_tpdenvio
									,cde.cdoperad_envio = pr_cdoperad
									,cde.dhenvio        = SYSDATE
									,cde.nrddd_sms      = pr_nrdddsms
									,cde.nrtel_sms      = pr_nrtelsms
									,cde.cdenvio_sms    = GENE0002.fn_char_para_number(fn_sequence('tbrecup_cobranca','CDENVIO_SMS',TO_CHAR(pr_cdcooper) ||
																																									 TO_CHAR(SYSDATE, 'RRRR') ||
																																									 TO_CHAR(SYSDATE, 'MM') ||
																																									 TO_CHAR(SYSDATE, 'DD')))
									,cde.nmcontato      = pr_nmcontat
									,cde.indretorno     = pr_indretor
						 WHERE cde.cdcooper = pr_cdcooper
							 AND cde.nrdconta = pr_nrdconta
							 AND cde.nrctremp = pr_nrborder
							 AND cde.nrdconta_cob = pr_nrctacob
							 AND cde.nrcnvcob = pr_nrcnvcob
							 AND cde.nrboleto = pr_nrdocmto
               AND cde.tpproduto = 3;
						vr_dstransa := 'Enviado boleto por SMS refente ao bordero nr: ' || to_char(pr_nrborder);
						vr_dsmensag := 'Boleto enviado por SMS (' || to_char(pr_nrdddsms, '000') || ') ' ||
						               to_char(pr_nrtelsms, '9999g9999','nls_numeric_characters=.-');
					-- IMPRESSAO
					WHEN 3 THEN
 						vr_dstransa := 'Boleto impresso refente ao bordero nr: ' || to_char(pr_nrborder);
						vr_dsmensag := 'Boleto impresso pela tela ' || pr_nmdatela;
					ELSE
   					-- Levanta exceção
					  RAISE vr_exc_update;
						
				END CASE;

				-- Se nao atualizou nenhum registro
				IF SQL%ROWCOUNT = 0 THEN
					-- Levanta exceção
					RAISE vr_exc_update;
				END IF;

			EXCEPTION
        WHEN vr_exc_erro THEN
					-- Atribui exceção devido a um erro tratado
					vr_cdcritic := 0;
					RAISE vr_exc_saida;
          
			  WHEN vr_exc_update THEN
					-- Atribui exceção caso nao seja atualizado nenhum registro
					vr_cdcritic := 0;
					vr_dscritic := 'Erro ao atualizar tabela tbrecup_cobranca: Dados nao encontrados.';
					RAISE vr_exc_saida;
				WHEN OTHERS THEN
          -- Atribui exceção para os parametros de crítica
          vr_cdcritic := vr_cdcritic;
          vr_dscritic := 'Erro nao tratado ao atualizar tabela tbrecup_cobranca' ||
					               ' na TELA_COBTIT.pc_enviar_boleto: ' || SQLERRM;
					RAISE vr_exc_saida;
			END;

		  -- Gera log na lgm
			gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
				                   pr_cdoperad => pr_cdoperad,
													 pr_dscritic => '',
													 pr_dsorigem => vr_dsorigem,
													 pr_dstransa => vr_dstransa,
													 pr_dttransa => TRUNC(SYSDATE),
													 pr_flgtrans => 1,
													 pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
													 pr_idseqttl => 0,
													 pr_nmdatela => pr_nmdatela,
													 pr_nrdconta => pr_nrdconta,
													 pr_nrdrowid => vr_nrdrowid);

      -- Buscar tabela de boletos de cobrança
      COBR0005.pc_buscar_titulo_cobranca(pr_cdcooper => pr_cdcooper,
																				 pr_nrdconta => pr_nrctacob,
																				 pr_nrcnvcob => pr_nrcnvcob,
																				 pr_nrdocmto => pr_nrdocmto,
										                     pr_cdoperad => pr_cdoperad,
                                         pr_nriniseq => 1,
                                         pr_nrregist => 1,
																				 pr_cdcritic => vr_cdcritic,
																				 pr_dscritic => vr_dscritic,
																				 pr_tab_cob  => vr_tab_cob);

			-- Se retornou alguma crítica
			IF vr_cdcritic <> 0 OR
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
			   RAISE vr_exc_saida;
		  END IF;

		  -- Contrato
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Bordero',
																pr_dsdadant => '',
																pr_dsdadatu => pr_nrborder);
			-- Nr. do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Nr. do Boleto',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tab_cob(1).nrdocmto);
			-- Vencimento
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vencimento',
																pr_dsdadant => '',
																pr_dsdadatu => TO_CHAR(vr_tab_cob(1).dtvencto, 'DD/MM/RRRR'));

			-- Valor do Boleto
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Vlr do boleto',
																pr_dsdadant => '',
																pr_dsdadatu => to_char(vr_tab_cob(1).vltitulo, 'fm999g999g990d00', 'NLS_NUMERIC_CHARACTERS = '',.'''));

			-- Linha Digitável
			gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																pr_nmdcampo => 'Linha digitavel',
																pr_dsdadant => '',
																pr_dsdadatu => vr_tab_cob(1).lindigit);


		  -- Gera log de itens
			CASE pr_tpdenvio
				-- Email
				WHEN 1 THEN
					-- E-mail
				  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																		pr_nmdcampo => 'E-mail',
																		pr_dsdadant => '',
																		pr_dsdadatu => vr_tab_cob(1).dsdemail);
				-- SMS
				WHEN 2 THEN
					-- Telefone
				  gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
																		pr_nmdcampo => 'Telefone',
																		pr_dsdadant => '',
																		pr_dsdadatu => '(' || to_char(pr_nrdddsms, '000') || ')' ||
						                                       to_char(pr_nrtelsms, '9999g9999','nls_numeric_characters=.-'));
																									 
			  ELSE
					NULL;

			END CASE;

			-- Cria log de cobrança
			PAGA0001.pc_cria_log_cobranca(pr_idtabcob => vr_tab_cob(1).rowidcob,
			                              pr_cdoperad => pr_cdoperad,
																		pr_dtmvtolt => trunc(SYSDATE),
																		pr_dsmensag => vr_dsmensag,
																		pr_des_erro => vr_des_erro,
																		pr_dscritic => vr_dscritic);

			-- Se retornou algum erro
		  IF vr_des_erro <> 'OK' AND
				 trim(vr_dscritic) IS NOT NULL THEN
				 -- Levanta exceção
				 RAISE vr_exc_saida;
		  END IF;

      COMMIT;

		EXCEPTION
      WHEN vr_exc_saida THEN
				-- Se possui código de crítica e não foi informado a descrição
				IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					 -- Busca descrição da crítica
					 vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := vr_dscritic;

        ROLLBACK;
			WHEN OTHERS THEN
				-- Atribui exceção para os parametros de crítica
				pr_cdcritic := vr_cdcritic;
				pr_dscritic := 'Erro nao tratado na TELA_COBTIT.pc_enviar_boleto: ' || SQLERRM;
        ROLLBACK;
		END;

	END pc_enviar_boleto;
  
  PROCEDURE pc_enviar_boleto_web (pr_nrdconta IN tbrecup_cobranca.nrdconta%TYPE              --> Nr. da Conta
																,pr_nrborder IN tbrecup_cobranca.nrctremp%TYPE              --> Nr. Contrato
																,pr_nrctacob IN tbrecup_cobranca.nrdconta_cob%TYPE          --> Nr. Conta Cobrança
																,pr_nrcnvcob IN tbrecup_cobranca.nrcnvcob%TYPE              --> Nr. Convenio Cobrança
																,pr_nrdocmto IN tbrecup_cobranca.nrboleto%TYPE              --> Nr. Documento
																,pr_nmcontat IN tbrecup_cobranca.nmcontato%TYPE             --> Nome Contato
																,pr_tpdenvio IN tbrecup_cobranca.tpenvio%TYPE               --> Tipo de Envio (1 = EMAIL, 2 = SMS, 3 = IMPRESSAO)
																,pr_dsdemail IN tbrecup_cobranca.dsemail%TYPE DEFAULT NULL  --> Email
																,pr_indretor IN tbrecup_cobranca.indretorno%TYPE DEFAULT 0  --> Indicador de retorno
																,pr_nrdddsms IN tbrecup_cobranca.nrddd_sms%TYPE DEFAULT 0   --> DDD
																,pr_nrtelsms IN tbrecup_cobranca.nrtel_sms%TYPE DEFAULT 0   --> Telefone
																,pr_xmllog   IN VARCHAR2                                  --> XML com informações de LOG
																,pr_cdcritic OUT PLS_INTEGER                              --> Código da crítica
																,pr_dscritic OUT VARCHAR2                                 --> Descrição da crítica
																,pr_retxml   IN OUT NOCOPY XMLType                        --> Arquivo de retorno do XML
																,pr_nmdcampo OUT VARCHAR2                                 --> Nome do campo com erro
																,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo

  BEGIN

	/* .............................................................................

		Programa: pc_enviar_boleto_web
		Sistema : CECRED
		Sigla   : CRED
		Autor   : Luis Fernando (GFT)
		Data    : Junho/2018

		Dados referentes ao programa:

		Frequencia: Sempre que for chamado
		Objetivo  : Rotina para gerar enviar o boleto por SMS ou email


	..............................................................................*/
		DECLARE
			----------------------------- VARIAVEIS ---------------------------------
			-- Variável de críticas
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

			vr_nmarqpdf   VARCHAR2(1000);
	    
			---------------------------- CURSORES -----------------------------------
		BEGIN

			---------------------------------- VALIDACOES INICIAIS --------------------------

			GENE0004.pc_extrai_dados(pr_xml      => pr_retxml,
															 pr_cdcooper => vr_cdcooper,
															 pr_nmdatela => vr_nmdatela,
															 pr_nmeacao  => vr_nmeacao,
															 pr_cdagenci => vr_cdagenci,
															 pr_nrdcaixa => vr_nrdcaixa,
															 pr_idorigem => vr_idorigem,
															 pr_cdoperad => vr_cdoperad,
															 pr_dscritic => vr_dscritic);

      -- Chama rotina para gerar o pdf do boleto
      pc_enviar_boleto(pr_cdcooper => vr_cdcooper
			                             ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrborder => pr_nrborder
                                   ,pr_nrctacob => pr_nrctacob
																	 ,pr_nrcnvcob => pr_nrcnvcob
																	 ,pr_nrdocmto => pr_nrdocmto
																	 ,pr_cdoperad => vr_cdoperad
                                   ,pr_nmcontat => pr_nmcontat
																	 ,pr_idorigem => vr_idorigem
                                   ,pr_tpdenvio => pr_tpdenvio
                                   ,pr_nmdatela => vr_nmdatela
                                   ,pr_dsdemail => pr_dsdemail
                                   ,pr_indretor => pr_indretor
                                   ,pr_nrdddsms => pr_nrdddsms
                                   ,pr_nrtelsms => pr_nrtelsms
																	 ,pr_cdcritic => vr_cdcritic
																	 ,pr_dscritic => vr_dscritic);
                                   
      IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN
				RAISE vr_exc_erro;
			END IF;

			-- Criar XML de retorno
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><nmarqpdf>' ||
																		 vr_nmarqpdf || '</nmarqpdf>');

		EXCEPTION
			WHEN vr_exc_erro THEN

				-- Busca descrição da crítica se houver código
				IF vr_cdcritic <> 0 THEN
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
				ELSE
					pr_cdcritic := vr_cdcritic;
					pr_dscritic := vr_dscritic;
				END IF;

				-- Carregar XML padrão para variável de retorno não utilizada.
				-- Existe para satisfazer exigência da interface.
				pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																			 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		WHEN OTHERS THEN

			pr_cdcritic := vr_cdcritic;
			pr_dscritic := 'Erro geral na rotina da tela TELA_COBEMP: ' || SQLERRM;

			-- Carregar XML padrão para variável de retorno não utilizada.
			-- Existe para satisfazer exigência da interface.
			pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
																		 '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

		END;
	END pc_enviar_boleto_web;
  
  
  PROCEDURE pc_busca_texto_sms(pr_cdcooper IN crapcob.cdcooper%TYPE 
                              ,pr_nrdconta IN crapcob.nrdconta%TYPE
                              ,pr_lindigit IN VARCHAR2
                              ,pr_textosms OUT VARCHAR2
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ) IS
  BEGIN

    /* .............................................................................
    Programa: pc_busca_texto_sms
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Luis Fernando (GFT)
    Data    : Junho/2018.

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina buscar texto a ser utilizado no envio de sms cobrança
    ..............................................................................*/
    DECLARE

      CURSOR cr_crapass IS
      SELECT nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para buscar os dados da cooperativa
      CURSOR cr_crapcop is
        select crapcop.nmextcop,
               crapcop.cdageitg,
               crapcop.cdagebcb,
               crapcop.cdagectl,
               crapcop.cdbcoctl,
               crapcop.nmrescop,
               crapcop.dsendcop,
               crapcop.nrendcop,
               crapcop.nmbairro,
               crapcop.nrtelvoz,
               crapcop.nmcidade,
               crapcop.cdufdcop
          from crapcop
         where crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      vr_texto_sms VARCHAR2(4000);
      vr_nmextcop VARCHAR2(100);
      vr_nmprimtl VARCHAR2(100);

    BEGIN
      -- Verifica se a cooperativa esta cadastrada
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH btch0001.cr_crapdat
        INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Busca os dados da cooperativa
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_cdcritic := 651;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;

      -- Busca os dados do associado
      OPEN cr_crapass;
      FETCH cr_crapass INTO rw_crapass;
      CLOSE cr_crapass;

      vr_nmprimtl := rw_crapass.nmprimtl;
      vr_nmextcop := rw_crapcop.nmrescop;


      /*@TODO  Criar um para cobtit*/
      vr_texto_sms:= gene0001.fn_param_sistema(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_cdacesso => 'COBEMP_TXT_SMS');

      vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperativa#',vr_nmextcop);
      vr_texto_sms := REPLACE(vr_texto_sms,'#Cooperado#',vr_nmprimtl);
      vr_texto_sms := REPLACE(vr_texto_sms,'#LinhaDigitavel#',pr_lindigit);

      pr_textosms := vr_texto_sms;
                     
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
        pr_dscritic := 'Erro geral na rotina da tela TELA_COBTIT.pc_busca_texto_sms: ' || SQLERRM;

    END;

  END pc_busca_texto_sms;
  
  PROCEDURE pc_busca_texto_sms_web(pr_nrdconta IN INTEGER
                              ,pr_lindigit IN VARCHAR2
                              ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................
    Programa: pc_busca_texto_sms_web
    Sistema : Cobrança - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Luis Fernando (GFT)
    Data    : Junho/2018.

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina buscar texto a ser utilizado no envio de sms cobrança
    ..............................................................................*/
    DECLARE
      -- Variável de críticas
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

      vr_texto_sms VARCHAR2(4000);

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      pc_busca_texto_sms(pr_cdcooper => vr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_lindigit => pr_lindigit
                              ,pr_textosms => vr_texto_sms
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
                              
      IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN
        RAISE vr_exc_erro;
      END IF;
                              

      -- inicializar o clob
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- inicilizar as informaçoes do xml
      vr_texto_completo := null;

      pc_escreve_xml('<?xml version="1.0" encoding="iso-8859-1" ?>'||
                     '<root><dados >');

      pc_escreve_xml('<textosms>'||vr_texto_sms||'</textosms>');
      
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_COBTIT.pc_busca_texto_sms: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_texto_sms_web;
  
  
  PROCEDURE pc_buscar_log(pr_cdcooper IN crapcob.cdcooper%TYPE --> Cooperativa
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE --> Conta
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE --> Numero do boleto
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE --> convenio
                         ,pr_nriniseq IN INTEGER                 --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER                 --> Numero de registros p/ paginaca
                         ,pr_qtregist OUT INTEGER                 --> total de logs encontrados
                         ,pr_tab_log  OUT typ_tab_dados_log --> Saída dos dados de log
                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                         ) IS
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_log
    Sistema : CRED
    Sigla   : TELA
    Autor   : Luis Fernando (GFT)
    Data    : 07/06/2018

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina busca de log boletos.
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapcol IS
        SELECT col.dtaltera,
               col.hrtransa,
               col.dslogtit,
               col.cdoperad,
               nvl(ope.nmoperad,col.cdoperad) nmoperad
          FROM crapcol col,
               crapope ope
         WHERE col.cdcooper = pr_cdcooper
           AND col.nrdconta = pr_nrdconta
           AND col.nrdocmto = pr_nrdocmto
           AND col.nrcnvcob = pr_nrcnvcob
           AND ope.cdcooper (+) = col.cdcooper
           AND ope.cdoperad (+) = col.cdoperad
           ORDER BY col.dtaltera DESC, col.hrtransa DESC;
      rw_crapcol cr_crapcol%ROWTYPE;
      
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      vr_index    PLS_INTEGER;
    BEGIN
      vr_index := 0;
      OPEN cr_crapcol;
      LOOP 
        FETCH cr_crapcol INTO rw_crapcol;
        vr_index := vr_index+1;
        EXIT WHEN cr_crapcol%NOTFOUND OR vr_index < pr_nriniseq OR vr_index >= (pr_nriniseq + pr_nrregist);
        pr_tab_log(vr_index).dtaltera := rw_crapcol.dtaltera;
        pr_tab_log(vr_index).hrtransa := rw_crapcol.hrtransa;
        pr_tab_log(vr_index).dslogtit := rw_crapcol.dslogtit;
        pr_tab_log(vr_index).cdoperad := rw_crapcol.cdoperad;
        pr_tab_log(vr_index).nmoperad := rw_crapcol.nmoperad;
      END LOOP;
      pr_qtregist := vr_index;
      IF (vr_index=0) THEN
        vr_dscritic := 'Nenhum log localizados.';
        RAISE vr_exc_erro;
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
        pr_dscritic := 'Erro geral na rotina da tela COBEMP: ' || SQLERRM;
    END;

  END pc_buscar_log;
  
  PROCEDURE pc_buscar_log_web(pr_nrdconta IN INTEGER
                         ,pr_nrdocmto IN INTEGER
                         ,pr_nrcnvcob IN INTEGER
                         ,pr_nriniseq IN INTEGER                 --> Registro inicial da listagem
                         ,pr_nrregist IN INTEGER                 --> Numero de registros p/ paginaca
                         ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                         ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                         ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                         ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                         ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_buscar_log_web
    Sistema : CRED
    Sigla   : TELA
    Autor   : Luis Fernando (GFT)
    Data    : 07/06/2018

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina busca de log boletos.

    Observacao: -----
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados de indexadores pelo nome
      CURSOR cr_crapcol(pr_cdcooper IN crapcop.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE,
                        pr_nrdocmto IN crapcob.nrdocmto%TYPE,
                        pr_nrcnvcob IN crapcob.nrcnvcob%TYPE) IS
        SELECT col.dtaltera,
               col.hrtransa,
               col.dslogtit,
               col.cdoperad,
               nvl(ope.nmoperad,col.cdoperad) nmoperad
          FROM crapcol col,
               crapope ope
         WHERE col.cdcooper = pr_cdcooper
           AND col.nrdconta = pr_nrdconta
           AND col.nrdocmto = pr_nrdocmto
           AND col.nrcnvcob = pr_nrcnvcob
           AND ope.cdcooper (+) = col.cdcooper
           AND ope.cdoperad (+) = col.cdoperad
           ORDER BY col.dtaltera DESC, col.hrtransa DESC;

      -- Variável de críticas
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
      vr_contador INTEGER := 0; -- Contador p/ posicao no XML
      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      vr_flgresgi BOOLEAN := FALSE;

      vr_tab_log  typ_tab_dados_log;
      vr_index    PLS_INTEGER;
      vr_qtregist INTEGER;
    BEGIN
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
                               pr_nmdatela => vr_nmdatela,
                               pr_nmeacao  => vr_nmeacao,
                               pr_cdagenci => vr_cdagenci,
                               pr_nrdcaixa => vr_nrdcaixa,
                               pr_idorigem => vr_idorigem,
                               pr_cdoperad => vr_cdoperad,
                               pr_dscritic => vr_dscritic);

      pc_buscar_log(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_nrdocmto => pr_nrdocmto
                         ,pr_nrcnvcob => pr_nrcnvcob
                         ,pr_nriniseq => pr_nriniseq
                         ,pr_nrregist => pr_nrregist
                         ,pr_qtregist => vr_qtregist
                         ,pr_tab_log  => vr_tab_log
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         );
                         
      IF (vr_cdcritic<>0 OR vr_dscritic IS NOT NULL) THEN
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
      vr_index := vr_tab_log.first;
      while vr_index is not null loop
         pc_escreve_xml('<log>'||
                           '<dtaltera>' || TO_CHAR(vr_tab_log(vr_index).dtaltera, 'dd/mm/RRRR') || '</dtaltera>' ||
                           '<hrtransa>' || GENE0002.fn_converte_time_data(vr_tab_log(vr_index).hrtransa) || '</hrtransa>' ||
                           '<dslogtit>' || vr_tab_log(vr_index).dslogtit || '</dslogtit>' ||
                           '<nmoperad>' || vr_tab_log(vr_index).nmoperad || '</nmoperad>' ||
                        '</log>'
                      );
          /* buscar proximo */
          vr_index := vr_tab_log.next(vr_index);
      end loop;
      pc_escreve_xml ('</dados></root>',true);
      pr_retxml := xmltype.createxml(vr_des_xml);

      /* liberando a memória alocada pro clob */
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
    EXCEPTION
      WHEN vr_exc_erro THEN

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da procedure TELA_COBTIT.pc_buscar_log_web: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_buscar_log_web;
  
end TELA_COBTIT;
/
