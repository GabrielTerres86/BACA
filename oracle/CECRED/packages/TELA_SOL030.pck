CREATE OR REPLACE PACKAGE CECRED.TELA_SOL030 AS
  
  --Tipo de registro de contas rateio ted capital
  TYPE typ_reg_contas IS
    RECORD (nrdconta crapass.nrdconta%TYPE
           ,cdcooper crapcop.cdcooper%TYPE
           ,nmprimtl crapass.nmprimtl%TYPE
           ,cdagenci crapass.cdagenci%TYPE
           ,inpessoa crapass.inpessoa%TYPE
           ,vldcotas crapcot.vldcotas%TYPE
           ,nrconta_dest tbcotas_transf_sobras.nrconta_dest%TYPE
           ,cdbanco_dest tbcotas_transf_sobras.cdbanco_dest%TYPE
           ,cdagenci_dest tbcotas_transf_sobras.cdagenci_dest%TYPE
           ,nrcpfcgc_dest tbcotas_transf_sobras.nrcpfcgc_dest%TYPE
           ,nmtitular_dest tbcotas_transf_sobras.nmtitular_dest%TYPE
           ,nrdigito_dest tbcotas_transf_sobras.nrdigito_dest%TYPE
           ,dscritic VARCHAR2(1000)
           ,fldebito BOOLEAN);

  --Tipo de tabela de contas rateio ted capital
  TYPE typ_tab_contas IS TABLE OF typ_reg_contas INDEX BY VARCHAR2(300);
  
  -- Busca calculo sobras
  PROCEDURE pc_busca_calculo_sobras (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  -- Busca data informativo
  PROCEDURE pc_busca_data_informativo (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
  
  -- Busca calculo sobras
  PROCEDURE pc_altera_calculo_sobras (pr_ininccmi  IN VARCHAR2
                                     ,pr_increret  IN VARCHAR2
                                     ,pr_txretorn  IN VARCHAR2
                                     ,pr_txjurcap  IN VARCHAR2
                                     ,pr_txjurapl  IN VARCHAR2
                                     ,pr_txjursdm  IN VARCHAR2
                                     ,pr_txjurtar  IN VARCHAR2
                                     ,pr_txreauat  IN VARCHAR2
                                     ,pr_inpredef  IN VARCHAR2
                                     ,pr_indeschq  IN VARCHAR2
                                     ,pr_indemiti  IN VARCHAR2
                                     ,pr_indestit  IN VARCHAR2
                                     ,pr_unsobdep  IN VARCHAR2
                                     ,pr_dssopfco  IN VARCHAR2
                                     ,pr_dssopjco  IN VARCHAR2
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
    
  -- Busca data informativo
  PROCEDURE pc_altera_data_informativo (pr_dtapinco  IN VARCHAR2           --> Data informativo
                                       ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);         --> Saida OK/NOK
   
  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_cal_retorno_sobras_web(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
                                       
  PROCEDURE pc_consulta_prazo_desligamento(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
                                          
  PROCEDURE pc_altera_prazo_desligamento(pr_qtddias   IN INTEGER               --> Quantidade de dias
                                        ,pr_tpprazo   IN INTEGER               --> Tipo do prazo
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) ;          --> Saida OK/NOK
                                 
  PROCEDURE pc_busca_vlminimo_capital_ted(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
                                         
  PROCEDURE pc_altera_vlminimo_capital_ted(pr_vlminimo  IN NUMBER                --> Quantidade de dias
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK      
                                          
  PROCEDURE pc_contas_rateio_ted_capital(pr_cddopcao  IN VARCHAR2              --> Código da opção
                                        ,pr_flctadst  IN INTEGER               --> 1 - Possui conta destino ativa / 2 - Possui conta destino e ativa e não possui conta destino
                                        ,pr_nriniseq  IN INTEGER               --> Número sequencial
                                        ,pr_nrregist  IN INTEGER               --> Número de registros   
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
                                        
  PROCEDURE pc_gerar_ted_rateio_capital(pr_cddopcao  IN VARCHAR2              --> Código da opção
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
                                                                      
  
END TELA_SOL030;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_SOL030 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SOL030
  --    Autor   : lucas Lombardi
  --    Data    : Marco/2016                   Ultima Atualizacao: 16/06/2017
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela SOL030 (Ayllos Web)
  --
  --    Alteracoes: 16/06/2017 - Ajustes para inclusão da rotina responsável pelo prazo de desligamento (Jonata  - RKAM P364).                             
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE
                       ,pr_dsdcampo IN VARCHAR2
                       ,pr_vlrcampo IN VARCHAR2
                       ,pr_vlcampo2 IN VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - RKAM
    Data     : Junho/2017                           Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

   BEGIN

     IF pr_vlrcampo <> pr_vlcampo2 THEN

       -- Gera log
       btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                 ,pr_ind_tipo_log => 2 -- Erro tratato
                                 ,pr_nmarqlog     => 'sol030.log'
                                 ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                     ' -->  Operador '|| pr_cdoperad || ' - ' ||
                                                     'Alterou o limite minimo para envio de TED de capital - ' ||
                                                     pr_dsdcampo || ' de ' || pr_vlrcampo ||
                                                     ' para ' || pr_vlcampo2 || '.');

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN OTHERS THEN
       pr_des_erro := 'NOK';
   END pc_gera_log;
  
  -- Busca calculo sobras
  PROCEDURE pc_busca_calculo_sobras (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                    ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_calculo_sobras
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca Carga Solicitada/Executando
      CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT SUBSTR(dstextab,1,1)                                        ininccmi
              ,SUBSTR(dstextab,3,1)                                        increret
              ,to_char(to_number(SUBSTR(dstextab,5,12)),'FM990D00000000')  txretorn   
              ,to_char(to_number(SUBSTR(dstextab,20,13)),'FM990D00000000') txjurcap
              ,to_char(to_number(SUBSTR(dstextab,33,12)),'FM990D00000000') txjurapl
              ,to_char(to_number(SUBSTR(dstextab,54,12)),'FM990D00000000') txjursdm
              ,to_char(to_number(SUBSTR(dstextab,78,12)),'FM990D00000000') txjurtar
              ,to_char(to_number(SUBSTR(dstextab,91,12)),'FM990D00000000') txreauat
              ,SUBSTR(dstextab,18,1)                                       inpredef
              ,SUBSTR(dstextab,46,1)                                       indeschq
              ,SUBSTR(dstextab,50,1)                                       indemiti
              ,SUBSTR(dstextab,52,1)                                       indestit
              ,SUBSTR(dstextab,118,1)                                      unsobdep
              ,to_char(to_number(SUBSTR(dstextab,104,6)),'FM990D00')       dssopfco
              ,to_char(to_number(SUBSTR(dstextab,111,6)),'FM990D00')       dssopjco
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND nmsistem = 'CRED'
           AND tptabela = 'GENERI'
           AND cdempres = 00
           AND cdacesso = 'EXEICMIRET'
           AND tpregist = 001;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound  BOOLEAN;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        OPEN cr_craptab(vr_cdcooper);
        FETCH cr_craptab INTO rw_craptab;
        vr_flgfound := cr_craptab%FOUND;
        CLOSE cr_craptab;
        
        -- Se não encontrar registro
        IF NOT vr_flgfound THEN
          vr_cdcritic := 115;
          RAISE vr_exc_erro;
        END IF;

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
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Dados',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dtanoret',pr_tag_cont => to_char(rw_crapdat.dtmvtolt,'RRRR'),pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'ininccmi',pr_tag_cont => rw_craptab.ininccmi,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'increret',pr_tag_cont => rw_craptab.increret,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txretorn',pr_tag_cont => rw_craptab.txretorn,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurcap',pr_tag_cont => rw_craptab.txjurcap,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurapl',pr_tag_cont => rw_craptab.txjurapl,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjursdm',pr_tag_cont => rw_craptab.txjursdm,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txjurtar',pr_tag_cont => rw_craptab.txjurtar,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'txreauat',pr_tag_cont => rw_craptab.txreauat,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'inpredef',pr_tag_cont => rw_craptab.inpredef,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indeschq',pr_tag_cont => rw_craptab.indeschq,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indemiti',pr_tag_cont => rw_craptab.indemiti,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'indestit',pr_tag_cont => rw_craptab.indestit,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'unsobdep',pr_tag_cont => rw_craptab.unsobdep,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dssopfco',pr_tag_cont => rw_craptab.dssopfco,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dssopjco',pr_tag_cont => rw_craptab.dssopjco,pr_des_erro => vr_dscritic);
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_calculo_sobras;
  
  -- Busca data informativo
  PROCEDURE pc_busca_data_informativo (pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                      ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                      ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_data_informativo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca Carga Solicitada/Executando
      CURSOR cr_craptab (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT SUBSTR(dstextab,67,10) dtinform
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND nmsistem = 'CRED'
           AND tptabela = 'GENERI'
           AND cdempres = 00
           AND cdacesso = 'EXEICMIRET'
           AND tpregist = 001;
      rw_craptab cr_craptab%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound  BOOLEAN;
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        OPEN cr_craptab(vr_cdcooper);
        FETCH cr_craptab INTO rw_craptab;
        vr_flgfound := cr_craptab%FOUND;
        CLOSE cr_craptab;
        
        -- Se não encontrar registro
        IF NOT vr_flgfound THEN
          vr_cdcritic := 115;
          RAISE vr_exc_erro;
        END IF;
        
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
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Root',pr_posicao => 0,pr_tag_nova => 'Dados',pr_tag_cont => NULL,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml => pr_retxml,pr_tag_pai => 'Dados',pr_posicao => 0,pr_tag_nova => 'dtinform',pr_tag_cont => rw_craptab.dtinform,pr_des_erro => vr_dscritic);
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_data_informativo;
  
  -- Busca calculo sobras
  PROCEDURE pc_altera_calculo_sobras (pr_ininccmi  IN VARCHAR2
                                     ,pr_increret  IN VARCHAR2
                                     ,pr_txretorn  IN VARCHAR2
                                     ,pr_txjurcap  IN VARCHAR2
                                     ,pr_txjurapl  IN VARCHAR2
                                     ,pr_txjursdm  IN VARCHAR2
                                     ,pr_txjurtar  IN VARCHAR2
                                     ,pr_txreauat  IN VARCHAR2
                                     ,pr_inpredef  IN VARCHAR2
                                     ,pr_indeschq  IN VARCHAR2
                                     ,pr_indemiti  IN VARCHAR2
                                     ,pr_indestit  IN VARCHAR2
                                     ,pr_unsobdep  IN VARCHAR2
                                     ,pr_dssopfco  IN VARCHAR2
                                     ,pr_dssopjco  IN VARCHAR2
                                     ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_altera_calculo_sobras
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Verifica lock na tabela
      CURSOR cr_craptab_lock (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT dstextab
          FROM craptab
         WHERE cdcooper = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'GENERI'
           AND cdempres = 00
           AND upper(craptab.cdacesso) = 'EXEICMIRET'
           AND tpregist = 001 FOR UPDATE NOWAIT;
      rw_craptab_lock cr_craptab_lock%ROWTYPE;
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN  
      
      
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
        
        BEGIN
          OPEN cr_craptab_lock(vr_cdcooper);
          FETCH cr_craptab_lock INTO rw_craptab_lock;
          CLOSE cr_craptab_lock;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Calculo das sobras já está sendo executado.';
            RAISE vr_exc_erro;
        END;
        
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
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
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        -- Tratar mês limite para calculo e distribuição
        IF to_char(rw_crapdat.dtmvtolt,'MM') > to_number(gene0001.fn_param_sistema('CRED', vr_cdcooper, 'NRMES_LIM_JURO_SOBRA')) THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 282;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||gene0001.fn_param_sistema('CRED', vr_cdcooper, 'NRMES_LIM_JURO_SOBRA')||'.';
          RAISE vr_exc_erro;
        END IF;
        
        /* Deve ser selecionado pelo menos um dos percentuais */
        IF pr_txretorn + pr_txjurtar + pr_txreauat + 
           pr_txjurcap + pr_txjurapl + pr_txjursdm = 0 THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 284;
          RAISE vr_exc_erro;
        END IF;

        /* Não pode ter sido selecionado valor negativo */
        IF pr_txretorn < 0 OR pr_txjurtar < 0 OR pr_txreauat < 0 
        OR pr_txjurcap < 0 OR pr_txjurapl < 0 OR pr_txjursdm < 0 THEN
          pr_nmdcampo := 'txretorn';
          vr_cdcritic := 180;
          RAISE vr_exc_erro;
        END IF;        
        
        /* Efetuar gravação na tabela de parâmetros */
        BEGIN
          UPDATE craptab
             SET dstextab = TRIM(pr_ininccmi)         || ' ' || 
                            TRIM(pr_increret)         || ' ' ||
                       lpad(TRIM(pr_txretorn),12,'0') || ' ' || 
                            TRIM(pr_inpredef)         || ' ' ||
                       lpad(TRIM(pr_txjurcap),12,'0') || ' ' || 
                       lpad(TRIM(pr_txjurapl),12,'0') || ' ' ||
                            TRIM(pr_indeschq)         ||'   '|| 
                            TRIM(pr_indemiti)         || ' ' ||
                            TRIM(pr_indestit)         || ' ' || 
                       lpad(TRIM(pr_txjursdm),12,'0') || ' ' ||
                     SUBSTR(dstextab,67,10)     || ' ' ||
                       lpad(TRIM(pr_txjurtar),12,'0') || ' ' || 
                       lpad(TRIM(pr_txreauat),12,'0') || ' ' ||
                       lpad(TRIM(pr_dssopfco),6,'0')  || ' ' || 
                       lpad(TRIM(pr_dssopjco),6,'0')  || ' ' ||
                       TRIM(pr_unsobdep)
          WHERE cdcooper = vr_cdcooper
            AND upper(nmsistem) = 'CRED'
            AND upper(tptabela) = 'GENERI'
            AND cdempres = 00
            AND upper(cdacesso) = 'EXEICMIRET'
            AND tpregist = 001;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível alterar a data informativa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Para processo prévio
        IF pr_inpredef = '0' THEN
           BEGIN
             INSERT INTO crapsol (nrsolici,dtrefere,nrseqsol,cdempres,dsparame,insitsol,nrdevias,cdcooper)
                          VALUES (106,rw_crapdat.dtmvtolt,01,11,'',1,1,vr_cdcooper);
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Não foi possível criar registro na crapsol. ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');
        
        COMMIT;        
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_altera_calculo_sobras;
  
  -- Busca data informativo
  PROCEDURE pc_altera_data_informativo (pr_dtapinco  IN VARCHAR2           --> Data informativo
                                       ,pr_xmllog    IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2           --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS       --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_altera_data_informativo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar cargas manuais do pre aprovado
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
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
        
        IF to_date(pr_dtapinco, 'DD/MM/RRRR') < TRUNC(rw_crapdat.dtmvtolt) THEN
          vr_dscritic := 'Data informada deve ser maior ou igual a data atual.';
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN
          UPDATE craptab
             SET dstextab = SUBSTR(dstextab,1,66) || pr_dtapinco || SUBSTR(dstextab,77,117)
          WHERE cdcooper = vr_cdcooper
            AND nmsistem = 'CRED'
            AND tptabela = 'GENERI'
            AND cdempres = 00
            AND cdacesso = 'EXEICMIRET'
            AND tpregist = 001;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Não foi possível alterar a data informativa. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>OK</Dados></Root>');

        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_altera_data_informativo;
  
  -- Procedure para calculo e credito do retorno de sobras e juros sobre o capital. Emissao do relatorio CRRL043
  PROCEDURE pc_cal_retorno_sobras_web(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                     ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

     BEGIN

    /* .............................................................................
    Programa: pc_cal_retorno_sobras_web
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : SOBR
    Autor   : Lucas Lombardi
    Data    : Agosto/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para acessar Procedure de calculo e credito do retorno
                de sobras e juros sobre o capital. Emissao do relatorio CRRL043.
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- cursor generico de data
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        pr_des_erro := 'OK';
      
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
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
        
        sobr0001.pc_calculo_retorno_sobras(pr_cdcooper => vr_cdcooper  --> Cooperativa solicitada
                                          ,pr_cdprogra => 'SOL030'     --> Programa chamador
                                          ,pr_cdcritic => vr_cdcritic  --> Critica encontrada
                                          ,pr_dscritic => vr_dscritic);--> Texto de erro/critica encontrada
        
        IF vr_cdcritic IS NOT NULL OR
           vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        BEGIN
           DELETE FROM crapsol
            WHERE nrsolici = 106
              AND dtrefere = rw_crapdat.dtmvtolt
              AND nrseqsol = 01
              AND cdempres = 11
              AND dsparame IS NULL
              AND insitsol = 1
              AND nrdevias = 1
              AND cdcooper = vr_cdcooper;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao deletar registro na crapsol. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        
        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>Calculo efetuado com sucesso! Relatórios em processo de emissão...</Dados></Root>');

        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em SOL030: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_cal_retorno_sobras_web;
  
  
  PROCEDURE pc_consulta_prazo_desligamento(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN

  /* .............................................................................
  Programa: pc_consulta_prazo_desligamento
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Junho/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por buscar as informações de prazo de desligamento
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE
  
    -- Variável de críticas
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  INTEGER;
    vr_dscritic  VARCHAR2(1000);
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variavies auxiliares
    vr_dstextab craptab.dstextab%TYPE;
    vr_pos      INTEGER;
    
    -- Array para guardar o split dos dados contidos na dstexttb
    vr_vet_dados gene0002.typ_split;
      
    BEGIN
        
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'SOL030');      
      
      -- Selecionar os tipos de registro da tabela generica
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'PRAZODESLIGAMENTO'
                                              ,pr_tpregist => 1);
                                              
      vr_vet_dados := gene0002.fn_quebra_string(pr_string  => vr_dstextab
                                               ,pr_delimit => ';');
        
        
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'parametros', pr_tag_cont => null , pr_des_erro => vr_dscritic);
      
      -- Pesquisar o vetor de tipo 
      FOR vr_pos IN 1..vr_vet_dados.COUNT LOOP
        
        CASE vr_pos
            
          -- Tipo do prazo (1 - No ato/ 2 - Após AGO)
          WHEN 1 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametros', pr_posicao => 0, pr_tag_nova => 'tpprazo', pr_tag_cont => to_char(vr_vet_dados(1),'9990') , pr_des_erro => vr_dscritic);
        
          -- Quantidade de dias
          WHEN 2 THEN
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametros', pr_posicao => 0, pr_tag_nova => 'qtddias', pr_tag_cont => to_char(vr_vet_dados(2),'9990') , pr_des_erro => vr_dscritic);
                        
        END CASE;  
        
      END LOOP;
                
      pr_des_erro := 'OK';
        
        
    EXCEPTION        
      WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_SOL030.pc_consulta_prazo_desligamento.' || SQLERRM;
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       
    END;
      
  END pc_consulta_prazo_desligamento;
  
  
  PROCEDURE pc_altera_prazo_desligamento(pr_qtddias   IN INTEGER               --> Quantidade de dias
                                        ,pr_tpprazo   IN INTEGER               --> Tipo do prazo
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

     BEGIN

    /* .............................................................................
    Programa: pc_altera_prazo_desligamento
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TELA_SOL030
    Autor   : Jonata - RKAM
    Data    : Junho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsável por estabelecer o prazo utilizado pelas cooperativas para efetuar a devolução de capital.
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE)IS
      SELECT craptab.tpregist
            ,craptab.dstextab
        FROM craptab
       WHERE craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 0
         AND craptab.cdacesso = 'PRAZODESLIGAMENTO'
         AND craptab.cdcooper = pr_cdcooper
         AND craptab.tpregist = 1;
      rw_craptab cr_craptab%ROWTYPE;
       
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      vr_des_erro  VARCHAR2(10);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;
      
      BEGIN
        
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => 'SOL030'); 
       
        OPEN cr_craptab(pr_cdcooper => vr_cdcooper);
        
        FETCH cr_craptab INTO rw_craptab;
        
        CLOSE cr_craptab;
                 
        -- 1 - No ato / 2 - Apos AGO                  
        IF nvl(pr_tpprazo,0) NOT IN (1,2) THEN
            
          vr_dscritic := 'Tipo do prazo inválido.';
          pr_nmdcampo:= 'tpprazo';
          RAISE vr_exc_erro;
          
        END IF;  
        
        -- 1 - No ato, não deve deixar gravar quantidade de dias
        IF pr_tpprazo = 1         AND 
           nvl(pr_qtddias,0) <> 0 THEN
            
          vr_dscritic := 'Quantidade de dias não deve ser informada.';
          pr_nmdcampo:= 'qtddias';
          RAISE vr_exc_erro;
          
        END IF;           
          
        IF nvl(pr_tpprazo,0) = 2 AND 
           nvl(pr_qtddias,0) = 0 THEN
            
          vr_dscritic := 'Quantidade de dias inválido.';
          pr_nmdcampo:= 'qtddias';
          RAISE vr_exc_erro;
          
        END IF;         
          
        BEGIN
          UPDATE craptab
             SET craptab.dstextab = to_char(pr_tpprazo,'9990')  || ';' || to_char(pr_qtddias,'9990')
           WHERE craptab.nmsistem = 'CRED'
             AND craptab.tptabela = 'GENERI'
             AND craptab.cdempres = 0
             AND craptab.cdacesso = 'PRAZODESLIGAMENTO'
             AND craptab.cdcooper = vr_cdcooper
             AND craptab.tpregist = 1;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar registro na craptab.';
            RAISE vr_exc_erro;
        END;
          
        -- Verifica se houve delecao de registro, caso contrario aborta o processo e mostra critica
        IF SQL%ROWCOUNT = 0 THEN
            
          BEGIN
            INSERT INTO craptab(craptab.nmsistem
                               ,craptab.tptabela
                               ,craptab.cdempres
                               ,craptab.cdacesso
                               ,craptab.tpregist
                               ,craptab.dstextab
                               ,craptab.cdcooper)
                         VALUES('CRED' 
                               ,'GENERI'
                               ,0
                               ,'PRAZODESLIGAMENTO'
                               ,1
                               ,to_char(pr_tpprazo,'9990')  || ';' || to_char(pr_qtddias,'9990') 
                               ,vr_cdcooper);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na craptab.';
              RAISE vr_exc_erro;
          END;
            
          -- Gera log
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_nmarqlog     => 'sol030.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                        'Inseriu o prazo de devolucao de capital - ' ||
                                                        'Tipo do prazo: ' ||(CASE WHEN pr_tpprazo = 1 THEN 'NO ATO' ELSE 'APOS AGO' END) ||
                                                        ', Quantidade de dias: ' ||  to_char(pr_qtddias,'9990') || '.');
                                                          
        ELSE
            
          vr_vet_dados := gene0002.fn_quebra_string(pr_string  => rw_craptab.dstextab
                                                   ,pr_delimit => ';');                                               
          
          pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                     ,pr_cdoperad => vr_cdoperad -- Operador
                     ,pr_dsdcampo => 'Tipo do prazo'  --Descrição do campo
                     ,pr_vlrcampo => (CASE WHEN to_number( to_char(vr_vet_dados(1),'9990')) = 1 THEN 'NO ATO' ELSE 'APOS AGO' END)    --Valor antigo
                     ,pr_vlcampo2 => (CASE WHEN pr_tpprazo = 1 THEN 'NO ATO' ELSE 'APOS AGO' END)  --Valor atual
                     ,pr_des_erro => vr_des_erro); --Erro

          IF vr_des_erro <> 'OK' THEN

            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao registar no log.';
            -- volta para o programa chamador
            RAISE vr_exc_erro;

          END IF;
          
          pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                     ,pr_cdoperad => vr_cdoperad -- Operador
                     ,pr_dsdcampo => 'Quantidade de dias'  --Descrição do campo
                     ,pr_vlrcampo => to_char(vr_vet_dados(2),'9990')    --Valor antigo
                     ,pr_vlcampo2 => to_char(pr_qtddias,'9990')  --Valor atual
                     ,pr_des_erro => vr_des_erro); --Erro

          IF vr_des_erro <> 'OK' THEN

            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao registar no log.';
            -- volta para o programa chamador
            RAISE vr_exc_erro;

          END IF;
          
        END IF;
        
        pr_des_erro := 'OK';
        
        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em TELA_SOL030.pc_altera_prazo_desligamento.';
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
      
  END pc_altera_prazo_desligamento;
  
  PROCEDURE pc_busca_vlminimo_capital_ted(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                         ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN

  /* .............................................................................
  Programa: pc_busca_vlminimo_capital_ted
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Julho/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por buscar o valor mínimo de capital 
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE
  
    -- Variável de críticas
    vr_exc_erro  EXCEPTION;
    vr_cdcritic  INTEGER;
    vr_dscritic  VARCHAR2(1000);
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variavies auxiliares
    vr_dstextab craptab.dstextab%TYPE;
   
      
    BEGIN
        
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
        
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'SOL030');      
      
      -- Selecionar os tipos de registro da tabela generica
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'VALORMINCAPITALTED'
                                              ,pr_tpregist => 1);                                             
            
        
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'parametros', pr_tag_cont => null , pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametros', pr_posicao => 0, pr_tag_nova => 'vlminimo', pr_tag_cont => nvl(vr_dstextab,0) , pr_des_erro => vr_dscritic);
                
      pr_des_erro := 'OK';        
        
    EXCEPTION        
      WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_SOL030.pc_busca_vlminimo_capital_ted.';
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       
    END;
      
  END pc_busca_vlminimo_capital_ted;
  
  PROCEDURE pc_altera_vlminimo_capital_ted(pr_vlminimo  IN NUMBER                --> Quantidade de dias
                                          ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                          ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                          ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN

    /* .............................................................................
    Programa: pc_altera_vlminimo_capital_ted
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TELA_SOL030
    Autor   : Jonata - RKAM
    Data    : Julho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina responsável por estabelecer o valor minimo pelas cooperativas para efetuar a TED de capital.
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE)IS
      SELECT craptab.tpregist
            ,craptab.dstextab
        FROM craptab
       WHERE craptab.nmsistem = 'CRED'
         AND craptab.tptabela = 'GENERI'
         AND craptab.cdempres = 0
         AND craptab.cdacesso = 'VALORMINCAPITALTED'
         AND craptab.cdcooper = pr_cdcooper
         AND craptab.tpregist = 1;
      rw_craptab cr_craptab%ROWTYPE;
       
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      vr_des_erro  VARCHAR2(10);
      
      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      BEGIN
        
        -- Recupera dados de log para consulta posterior
        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
      
        -- Verifica se houve erro recuperando informacoes de log                              
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => 'SOL030'); 
       
        OPEN cr_craptab(pr_cdcooper => vr_cdcooper);
        
        FETCH cr_craptab INTO rw_craptab;
        
        CLOSE cr_craptab;
                 
        BEGIN
          UPDATE craptab
             SET craptab.dstextab = to_char(nvl(pr_vlminimo,0),'fm999g999g990d00') 
           WHERE craptab.nmsistem = 'CRED'
             AND craptab.tptabela = 'GENERI'
             AND craptab.cdempres = 0
             AND craptab.cdacesso = 'VALORMINCAPITALTED'
             AND craptab.cdcooper = vr_cdcooper
             AND craptab.tpregist = 1;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar registro na craptab.';
            RAISE vr_exc_erro;
        END;
          
        -- Verifica se houve delecao de registro, caso contrario aborta o processo e mostra critica
        IF SQL%ROWCOUNT = 0 THEN
            
          BEGIN
            INSERT INTO craptab(craptab.nmsistem
                               ,craptab.tptabela
                               ,craptab.cdempres
                               ,craptab.cdacesso
                               ,craptab.tpregist
                               ,craptab.dstextab
                               ,craptab.cdcooper)
                         VALUES('CRED' 
                               ,'GENERI'
                               ,0
                               ,'VALORMINCAPITALTED'
                               ,1
                               ,nvl(pr_vlminimo,0) 
                               ,vr_cdcooper);

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao inserir registro na craptab.';
              RAISE vr_exc_erro;
          END;
            
          -- Gera log
          btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_nmarqlog     => 'sol030.log'
                                    ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                        'Inseriu o limite minimo para envio de TED de capital - ' ||
                                                        'Valor minimo: ' || to_char(pr_vlminimo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')  || '.');
                                                      
                                                          
        ELSE
            
          pc_gera_log(pr_cdcooper => vr_cdcooper -- Código da cooperativa
                     ,pr_cdoperad => vr_cdoperad -- Operador
                     ,pr_dsdcampo => 'Valor minimo'  --Descrição do campo
                     ,pr_vlrcampo => rw_craptab.dstextab  --Valor antigo
                     ,pr_vlcampo2 => to_char(pr_vlminimo,'fm999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')  --Valor atual
                     ,pr_des_erro => vr_des_erro); --Erro

          IF vr_des_erro <> 'OK' THEN

            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao registar no log.';
            -- volta para o programa chamador
            RAISE vr_exc_erro;

          END IF;
                   
        END IF;
        
        pr_des_erro := 'OK';
        
        COMMIT;
        
      EXCEPTION        
        WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro := 'NOK';
      
        IF NVL(vr_cdcritic,0) > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em TELA_SOL030.pc_altera_vlminimo_capital_ted.';
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
      
  END pc_altera_vlminimo_capital_ted;
  
  PROCEDURE pc_contas_rateio_ted_capital(pr_cddopcao  IN VARCHAR2              --> Código da opção
                                        ,pr_flctadst  IN INTEGER               --> 1 - Possui conta destino ativa / 2 - Possui conta destino e ativa e não possui conta destino
                                        ,pr_nriniseq  IN INTEGER               --> Número sequencial
                                        ,pr_nrregist  IN INTEGER               --> Número de registros   
                                        ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                        ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN

  /* .............................................................................
  Programa: pc_contas_rateio_ted_capital
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Julho/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por buscar todas as contas que devem ser enviado a TED de capital
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE
         
    CURSOR cr_banco(pr_cddbanco IN crapban.cdbccxlt%TYPE
                   ,pr_cdageban IN crapagb.cdageban%TYPE) IS
    SELECT ban.cdbccxlt 
          ,ban.nmextbcc
          ,agb.nmageban
      FROM crapban ban  
          ,crapagb agb              
     WHERE ban.cdbccxlt = pr_cddbanco
       AND agb.cddbanco = ban.cdbccxlt
       AND agb.cdageban = pr_cdageban;
    rw_banco cr_banco%ROWTYPE;
        
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida   EXCEPTION;
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de controle
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    vr_qtregist INTEGER := 0;
    vr_vlrtotal NUMBER(25,2) := 0;
    
    -- Variáveis para criação de cursor dinâmico
    vr_num_cursor     number;
    vr_num_retor      number;
    vr_cursor         varchar2(32000);    
    
    --Variáveis locais
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_nmprimtl crapass.nmprimtl%TYPE;
    vr_inpessoa crapass.inpessoa%TYPE;
    vr_vldcotas crapcot.vldcotas%TYPE;
    vr_nrconta_dest tbcotas_transf_sobras.nrconta_dest%TYPE;
    vr_nrdigito_dest tbcotas_transf_sobras.nrdigito_dest%TYPE;
    vr_cdbanco_dest tbcotas_transf_sobras.cdbanco_dest%TYPE;
    vr_cdagenci_dest tbcotas_transf_sobras.cdagenci_dest%TYPE;
    vr_nrcpfcgc_dest tbcotas_transf_sobras.nrcpfcgc_dest%TYPE;
    vr_nmtitular_dest tbcotas_transf_sobras.nmtitular_dest%TYPE;
    vr_situacao  VARCHAR2(15);
      
    BEGIN
        
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
        
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'SOL030');     
      
      IF pr_flctadst = 1 THEN
       
        -- Define a query do cursor dinâmico
        vr_cursor := 'SELECT ass.nrdconta' ||
                           ',ass.nmprimtl' ||
                           ',ass.inpessoa ' ||
                           ',cot.vldcotas ' ||
                           ',tbcotas.nrconta_dest ' ||
                           ',tbcotas.nrdigito_dest ' ||
                           ',tbcotas.cdbanco_dest ' ||
                           ',tbcotas.cdagenci_dest ' ||
                           ',tbcotas.nrcpfcgc_dest ' ||
                           ',tbcotas.nmtitular_dest ' ||
                           ',decode(tbcotas.insit_autoriza,1,''ATIVO'',2,''CANCELADO'','' '') situacao ' ||                         
                       'FROM crapass ass ' ||
                     'INNER JOIN crapcot cot ' ||
                             'ON cot.cdcooper = ass.cdcooper ' ||
                            'AND cot.nrdconta = ass.nrdconta ' ||
                            'AND cot.vldcotas > 0 ' ||                               
                      'INNER JOIN tbcotas_transf_sobras tbcotas ' ||
                              'ON tbcotas.cdcooper = ass.cdcooper ' ||
                             'AND tbcotas.nrdconta = ass.nrdconta ' ||
                             'AND tbcotas.insit_autoriza = 1' ||
                      'WHERE ass.cdcooper = ' || vr_cdcooper  ||
                        'AND ass.cdsitdct = 4';    
      
      ELSE
        -- Define a query do cursor dinâmico
        vr_cursor := 'SELECT ass.nrdconta' ||
                           ',ass.nmprimtl' ||
                           ',ass.inpessoa ' ||
                           ',cot.vldcotas ' ||
                           ',tbcotas.nrconta_dest ' ||
                           ',tbcotas.nrdigito_dest ' ||
                           ',tbcotas.cdbanco_dest ' ||
                           ',tbcotas.cdagenci_dest ' ||
                           ',tbcotas.nrcpfcgc_dest ' ||
                           ',tbcotas.nmtitular_dest ' ||
                           ',decode(tbcotas.insit_autoriza,1,''ATIVO'',2,''CANCELADO'','' '') situacao ' ||                         
                       'FROM crapass ass ' ||
                     'INNER JOIN crapcot cot ' ||
                             'ON cot.cdcooper = ass.cdcooper ' ||
                            'AND cot.nrdconta = ass.nrdconta ' ||
                            'AND cot.vldcotas > 0 ' ||    
                      'LEFT JOIN tbcotas_transf_sobras tbcotas ' ||
                             'ON tbcotas.cdcooper = ass.cdcooper ' ||
                            'AND tbcotas.nrdconta = ass.nrdconta ' ||
                      'WHERE ass.cdcooper = ' || vr_cdcooper  ||
                        'AND ass.cdsitdct = 4'; 
      
      END IF;
                     
      -- Cria cursor dinâmico
      vr_num_cursor := dbms_sql.open_cursor;

      -- Comando Parse
      dbms_sql.parse(vr_num_cursor, vr_cursor, 1);

      -- Definindo Colunas de retorno
      dbms_sql.define_column(vr_num_cursor, 1, vr_nrdconta);
      dbms_sql.define_column(vr_num_cursor, 2, vr_nmprimtl,60);
      dbms_sql.define_column(vr_num_cursor, 3, vr_inpessoa);
      dbms_sql.define_column(vr_num_cursor, 4, vr_vldcotas);
      dbms_sql.define_column(vr_num_cursor, 5, vr_nrconta_dest);
      dbms_sql.define_column(vr_num_cursor, 6, vr_nrdigito_dest,1);
      dbms_sql.define_column(vr_num_cursor, 7, vr_cdbanco_dest);
      dbms_sql.define_column(vr_num_cursor, 8, vr_cdagenci_dest);
      dbms_sql.define_column(vr_num_cursor, 9, vr_nrcpfcgc_dest);
      dbms_sql.define_column(vr_num_cursor, 10, vr_nmtitular_dest,60);
      dbms_sql.define_column(vr_num_cursor, 11, vr_situacao,15);   
          
      -- Execução do select dinamico
      vr_num_retor := dbms_sql.execute(vr_num_cursor);
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
             
      -- Executa o fetch no cursor dinamico para retornar a quantidade de linhas
      WHILE dbms_sql.fetch_rows(vr_num_cursor) > 0 LOOP
      
        -- Carrega variáveis com o retorno do cursor
        dbms_sql.column_value(vr_num_cursor, 1, vr_nrdconta);
        dbms_sql.column_value(vr_num_cursor, 2, vr_nmprimtl);
        dbms_sql.column_value(vr_num_cursor, 3, vr_inpessoa);
        dbms_sql.column_value(vr_num_cursor, 4, vr_vldcotas);
        dbms_sql.column_value(vr_num_cursor, 5, vr_nrconta_dest);
        dbms_sql.column_value(vr_num_cursor, 6, vr_nrdigito_dest);
        dbms_sql.column_value(vr_num_cursor, 7, vr_cdbanco_dest);
        dbms_sql.column_value(vr_num_cursor, 8, vr_cdagenci_dest);
        dbms_sql.column_value(vr_num_cursor, 9, vr_nrcpfcgc_dest);
        dbms_sql.column_value(vr_num_cursor, 10, vr_nmtitular_dest);
        dbms_sql.column_value(vr_num_cursor, 11, vr_situacao);
            
        --Incrementar Quantidade Registros do Parametro
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
        vr_vlrtotal:= vr_vlrtotal + nvl(vr_vldcotas,0);
        
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
            
        --Numero Registros
        IF vr_nrregist > 0 THEN 
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => null , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => vr_nrdconta , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'vldcotas', pr_tag_cont => vr_vldcotas , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprimtl', pr_tag_cont => vr_nmprimtl , pr_des_erro => vr_dscritic);          
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nrconta_dest', pr_tag_cont => gene0002.fn_mask_conta(vr_nrconta_dest) , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdigito_dest', pr_tag_cont => vr_nrdigito_dest , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'cdbanco_dest', pr_tag_cont => vr_cdbanco_dest , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'cdagenci_dest', pr_tag_cont => vr_cdagenci_dest , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc_dest', pr_tag_cont => gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_nrcpfcgc_dest,
                                                                                                                                                                                  pr_inpessoa => vr_inpessoa) , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nmtitular_dest', pr_tag_cont => vr_nmtitular_dest , pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'insit_autoriza', pr_tag_cont => vr_situacao , pr_des_erro => vr_dscritic);
          
          IF nvl(vr_nrconta_dest,0) <> 0 THEN
            
            OPEN cr_banco(pr_cddbanco => vr_cdbanco_dest
                         ,pr_cdageban => vr_cdagenci_dest);
            
            FETCH cr_banco INTO rw_banco;

            IF cr_banco%NOTFOUND THEN
              
              -- Fecha cursor
              CLOSE cr_banco;      
              vr_dscritic := 'Banco/Agência destino não encontrado.';
              RAISE vr_exc_saida;
              
            ELSE
              
              -- Fecha cursor
              CLOSE cr_banco;      
              
            END IF; 
            
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'dsbanco_dest', pr_tag_cont => rw_banco.nmextbcc , pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'dsagenci_dest', pr_tag_cont => rw_banco.nmageban , pr_des_erro => vr_dscritic);
                    
          END IF;
           
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := nvl(vr_auxconta,0) + 1;  
                
        END IF;
          
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
                  
      END LOOP;
      
      -- Fecha o mesmo
      dbms_sql.close_cursor(vr_num_cursor);
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'              --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'              --> Nome da TAG XML
                               ,pr_atrib => 'vlrtotal'          --> Nome do atributo
                               ,pr_atval => vr_vlrtotal         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      pr_des_erro := 'OK';        
        
    EXCEPTION        
      WHEN vr_exc_saida THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    WHEN OTHERS THEN
      cecred.pc_internal_exception(3);
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_SOL030.pc_contas_rateio_ted_capital.';
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       
    END;
      
  END pc_contas_rateio_ted_capital;
  
  PROCEDURE pc_obtem_contas_rateio_capital(pr_cdcooper IN crapcop.cdcooper%TYPE    --Cooperativa
                                          ,pr_tab_contas OUT typ_tab_contas      --tabela de contas
                                          ,pr_cdcritic OUT INTEGER   --Codigo da Critica
                                          ,pr_dscritic OUT VARCHAR2) IS --Descricao da critica

  BEGIN

  /* .............................................................................
  Programa: pc_obtem__contas_rateio_capital
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Agosto/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por buscar as contas na qual será enviado TED de rateio de capital
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE
    
    --Informacoes da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%type) IS
    SELECT crapcop.cdagectl
          ,crapcop.cdcooper
          ,crapcop.nmrescop
     FROM crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
        
    CURSOR cr_contas(pr_cdcooper IN crapass.cdcooper%TYPE)IS
    SELECT ass.nrdconta
          ,ass.cdcooper
          ,ass.nmprimtl
          ,ass.cdagenci
          ,ass.inpessoa
          ,cot.vldcotas
          ,tbcotas.nrconta_dest
          ,tbcotas.cdbanco_dest
          ,tbcotas.cdagenci_dest
          ,tbcotas.nrcpfcgc_dest
          ,tbcotas.nmtitular_dest
          ,tbcotas.nrdigito_dest
      FROM crapass ass
    INNER JOIN crapcot cot 
            ON cot.cdcooper = ass.cdcooper
           AND cot.nrdconta = ass.nrdconta  
           AND cot.vldcotas > 0          
    INNER JOIN tbcotas_transf_sobras tbcotas
            ON tbcotas.cdcooper = ass.cdcooper
           AND tbcotas.nrdconta = ass.nrdconta
           AND tbcotas.insit_autoriza = 1
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.dtdemiss IS NOT NULL;    
       
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida   EXCEPTION;
    
    vr_index_contas VARCHAR2(300);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    BEGIN
      
      --Inicializar retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Limpar tabela memoria contas 
      pr_tab_contas.DELETE; 
       
      --Selecionar Cooperativa
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      --Posicionar no primeiro registro
      FETCH cr_crapcop INTO rw_crapcop;
      --Se encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cooperativa não cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapcop;
           
      FOR rw_contas IN cr_contas(pr_cdcooper => pr_cdcooper) LOOP
        
        --Montar indice contas
        vr_index_contas:= lpad(rw_contas.nrdconta,10,'0');
        
        --Inserir dados tabela memoria contas
        pr_tab_contas(vr_index_contas).cdcooper:= rw_contas.cdcooper;
        pr_tab_contas(vr_index_contas).nrdconta:= rw_contas.nrdconta;
        pr_tab_contas(vr_index_contas).nmprimtl:= rw_contas.nmprimtl;
        pr_tab_contas(vr_index_contas).cdagenci:= rw_contas.cdagenci;
        pr_tab_contas(vr_index_contas).inpessoa:= rw_contas.inpessoa;
        pr_tab_contas(vr_index_contas).vldcotas:= rw_contas.vldcotas;
        pr_tab_contas(vr_index_contas).nrconta_dest:= rw_contas.nrconta_dest;
        pr_tab_contas(vr_index_contas).cdbanco_dest:= rw_contas.cdbanco_dest;
        pr_tab_contas(vr_index_contas).cdagenci_dest:= rw_contas.cdagenci_dest;
        pr_tab_contas(vr_index_contas).nrcpfcgc_dest:= rw_contas.nrcpfcgc_dest;
        pr_tab_contas(vr_index_contas).nmtitular_dest:= rw_contas.nmtitular_dest;
        pr_tab_contas(vr_index_contas).nrdigito_dest:= rw_contas.nrdigito_dest;
        pr_tab_contas(vr_index_contas).fldebito:= FALSE;
        pr_tab_contas(vr_index_contas).dscritic:= NULL;
                      
        
      END LOOP;     
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        cecred.pc_internal_exception(3);
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina TELA_SOL030.pc_obtem_contas_rateio_capital. '||sqlerrm;
    END;
      
  END pc_obtem_contas_rateio_capital;
  
  
  PROCEDURE pc_efetua_envio_ted(pr_cdcooper IN crapcop.cdcooper%TYPE --> Código da cooperativa
                               ,pr_idorigem IN INTEGER --> Código de origem
                               ,pr_cdoperad IN crapope.cdoperad%TYPE -->Código do operador
                               ,pr_vldcotas IN crapcot.vldcotas%TYPE --> Valor da cotas/TED
                               ,pr_cdbanco_dest   IN tbcotas_transf_sobras.cdbanco_dest%TYPE --> Banco destino
                               ,pr_cdagenci_dest  IN tbcotas_transf_sobras.cdagenci_dest%TYPE --> Banco destino
                               ,pr_nrconta_dest   IN tbcotas_transf_sobras.nrconta_dest%TYPE --> Banco destino
                               ,pr_nrdigito_dest  IN tbcotas_transf_sobras.nrdigito_dest%TYPE --> Banco destino
                               ,pr_nrcpfcgc_dest  IN tbcotas_transf_sobras.nrcpfcgc_dest%TYPE --> Banco destino
                               ,pr_nmtitular_dest IN tbcotas_transf_sobras.nmtitular_dest%TYPE --> Banco destino
                               ,pr_nrdconta  IN crapass.cdcooper%TYPE --> Conta origem
                               ,pr_inpessoa  IN crapass.inpessoa%TYPE --> Fisica/Juridica
                               ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Código da agência
                               ,pr_cdcritic  OUT INTEGER       --> Codigo da Critica
                               ,pr_dscritic  OUT VARCHAR2) IS  --> Saida OK/NOK

  BEGIN

  /* .............................................................................
  Programa: pc_efetua_envio_ted
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Agosto/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por gerar as TED`s referente ao rateio de capital
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE  
           
    --Selecionar informacoes dos bancos
    CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nrispbif
     FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;
              
    -- Cursor sobre a tabela de datas
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida   EXCEPTION;
      
    --Variaveis de controle
    vr_vlmincap NUMBER(25,2) := 0;
    vr_dsorigem VARCHAR2(100);
    vr_nrdrowid ROWID;
    vr_nrdocmto craplct.nrdocmto%TYPE;
    vr_busca    VARCHAR2(100);    
    vr_nrdolote craplcm.nrdolote%TYPE;
    vr_nrseqdig craplot.nrseqdig%TYPE;
    vr_dsprotoc  crappro.dsprotoc%TYPE;
    vr_tab_protocolo_ted CXON0020.typ_tab_protocolo_ted;
    vr_vldcotas crapcot.vldcotas%TYPE;
    vr_vllanmto crapcot.vldcotas%TYPE := pr_vldcotas;
    vr_vllantar NUMBER;
    vr_vllanto_aux NUMBER;
    vr_cdhistar craphis.cdhistor%TYPE;
    vr_cdhisest craphis.cdhistor%TYPE;
    vr_cdfvlcop INTEGER;
    vr_qtacobra INTEGER;
  	vr_fliseope INTEGER;	

    BEGIN
      
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      
      -- Busca a data do sistema
      OPEN btch0001.cr_crapdat(pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      CLOSE btch0001.cr_crapdat;
      
      -- inicializar valor
      vr_vllanto_aux := 1;
    
      -- Rotina para buscar valor tarifa TED/DOC
      CXON0020.pc_busca_tarifa_ted (pr_cdcooper => pr_cdcooper         --> Codigo Cooperativa
                                   ,pr_cdagenci => pr_cdagenci         --> Codigo Agencia
                                   ,pr_nrdconta => pr_nrdconta         --> Numero da Conta
                                   ,pr_vllanmto => vr_vllanto_aux      --> Valor Lancamento
                                   ,pr_vltarifa => vr_vllantar         --> Valor Tarifa
                                   ,pr_cdhistor => vr_cdhistar         --> Historico da tarifa
                                   ,pr_cdhisest => vr_cdhisest         --> Historico estorno
                                   ,pr_cdfvlcop => vr_cdfvlcop         --> Codigo Filial Cooperativa
                                   ,pr_cdcritic => vr_cdcritic         --> Codigo do erro
                                   ,pr_dscritic => vr_dscritic);       --> Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      IF vr_vllantar <> 0 THEN
			
        /* Verificar isenção ou não de tarifa */
        TARI0001.pc_verifica_tarifa_operacao(pr_cdcooper => pr_cdcooper         -- Cooperativa
                                            ,pr_cdoperad => '888'               -- Operador
                                            ,pr_cdagenci => 1                   -- PA
                                            ,pr_cdbccxlt => 100                 -- Banco
                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt -- Data de movimento
                                            ,pr_cdprogra => 'CXON0020'          -- Cód. do programa
                                            ,pr_idorigem => 2                   -- Id. de origem
                                            ,pr_nrdconta => pr_nrdconta         -- Número da conta
                                            ,pr_tipotari => 12                  -- Tipo de tarifa 12 - TED Eletrônico
                                            ,pr_tipostaa => 0                   -- Tipo TAA
                                            ,pr_qtoperac => 1                   -- Quantidade de operações
                                            ,pr_qtacobra => vr_qtacobra         -- Quantidade de operações a serem tarifadas
                                            ,pr_fliseope => vr_fliseope         -- Identificador de isenção de tarifa (0 - nao isenta/1 - isenta)
                                            ,pr_cdcritic => vr_cdcritic         -- Cód. da crítica
                                            ,pr_dscritic => vr_dscritic);       -- Desc. da crítica

        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --Levantar Exececao
          RAISE vr_exc_saida;
        END IF;
        
        --Nao isenta
        IF vr_fliseope <> 1 THEN
          
          vr_vllanmto := vr_vllanmto - nvl(vr_vllantar,0);
        
        END IF;
        
        
      END IF;
      
      -- Selecionar os tipos de registro da tabela generica
      vr_vlmincap:= nvl(to_number(TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                            ,pr_nmsistem => 'CRED'
                                                            ,pr_tptabela => 'GENERI'
                                                            ,pr_cdempres => 0
                                                            ,pr_cdacesso => 'VALORMINCAPITALTED'
                                                            ,pr_tpregist => 1)),0);  
            
     
      IF vr_vllanmto < vr_vlmincap THEN
          
        vr_dscritic := 'Valor da TED menor que o valor mínimo parametrizado.';
        RAISE vr_exc_saida;
          
      END IF;
        
      /* Busca o registro do banco */
      OPEN cr_crapban (pr_cdbccxlt => pr_cdbanco_dest);
        
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;

      IF cr_crapban%NOTFOUND THEN
          
        --Fechar Cursor
        CLOSE cr_crapban;
        vr_dscritic := 'Banco destino não encontrado.';
        RAISE vr_exc_saida;
          
      END IF;

      --Fechar Cursor
      CLOSE cr_crapban;
         
      vr_nrdolote := 600038;
        
      vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                  TRIM(to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')) || ';' ||
                  TRIM(to_char(pr_cdagenci)) || ';' ||
                  '100;' || --cdbccxlt
                  vr_nrdolote || ';' || 
                  TRIM(to_char(pr_nrdconta));
                     
      vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);    
        
      vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                                          to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||';'||
                                                          pr_cdagenci||
                                                          ';100;'|| --cdbccxlt
                                                          vr_nrdolote);
                                                            
      BEGIN                                        
        INSERT INTO craplct(cdcooper
                           ,cdagenci
                           ,cdbccxlt
                           ,nrdolote
                           ,dtmvtolt
                           ,cdhistor
                           ,nrctrpla
                           ,nrdconta
                           ,nrdocmto
                           ,nrseqdig
                           ,vllanmto)
                    VALUES (pr_cdcooper
                           ,pr_cdagenci
                           ,100
                           ,vr_nrdolote
                           ,rw_crapdat.dtmvtolt
                           ,2136 --DEB. COTAS
                           ,pr_nrdconta
                           ,pr_nrdconta
                           ,vr_nrdocmto
                           ,vr_nrseqdig
                           ,pr_vldcotas);
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lancamento de cotas.';
          cecred.pc_internal_exception(pr_cdcooper);
          RAISE vr_exc_saida;
      END; 

      BEGIN
         INSERT INTO craplcm(cdcooper
                            ,dtmvtolt
                            ,dtrefere
                            ,cdagenci
                            ,cdbccxlt
                            ,nrdolote
                            ,nrdconta
                            ,nrdctabb
                            ,nrdctitg
                            ,nrdocmto
                            ,cdhistor     
                            ,vllanmto
                            ,nrseqdig)
                      VALUES(pr_cdcooper
                            ,rw_crapdat.dtmvtolt
                            ,rw_crapdat.dtmvtolt
                            ,pr_cdagenci
                            ,100
                            ,vr_nrdolote
                            ,pr_nrdconta
                            ,pr_nrdconta
                            ,TO_CHAR(gene0002.fn_mask(pr_nrdconta,'99999999'))
                            ,vr_nrdocmto
                            ,2137 -- CR. COTAS/CAP
                            ,pr_vldcotas
                            ,vr_nrseqdig); 
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir lancamento.';
          cecred.pc_internal_exception(pr_cdcooper);
          RAISE vr_exc_saida;
      END;

      BEGIN
         
        UPDATE crapcot
           SET vldcotas = vldcotas - pr_vldcotas
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           RETURNING crapcot.vldcotas INTO vr_vldcotas; 


      EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar o valor de cotas.';
           cecred.pc_internal_exception(pr_cdcooper);
           RAISE vr_exc_saida;

      END;
        
      --> Procedure para executar o envio da TED
      CXON0020.pc_executa_envio_ted(pr_cdcooper => pr_cdcooper        --> Cooperativa    
                                   ,pr_cdagenci => pr_cdagenci        --> Agencia
                                   ,pr_nrdcaixa => 1                  --> Caixa Operador    
                                   ,pr_cdoperad => 1                  --> Operador Autorizacao
                                   ,pr_idorigem => 7                  --> Origem                 
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt--> Data do movimento
                                   ,pr_nrdconta => pr_nrdconta        --> Conta Remetente        
                                   ,pr_idseqttl => 1                  --> Titular                
                                   ,pr_nrcpfope => 0                  --> CPF operador juridico
                                   ,pr_cddbanco => pr_cdbanco_dest    --> Banco destino
                                   ,pr_cdageban => pr_cdagenci_dest   --> Agencia destino
                                   ,pr_nrctatrf => pr_nrconta_dest    --> Conta transferencia
                                   ,pr_nmtitula => pr_nmtitular_dest  --> nome do titular destino
                                   ,pr_nrcpfcgc => pr_nrcpfcgc_dest   --> CPF do titular destino
                                   ,pr_inpessoa => pr_inpessoa        --> Tipo de pessoa
                                   ,pr_intipcta => 1                  --> Tipo de conta
                                   ,pr_vllanmto => vr_vllanmto        --> Valor do lançamento
                                   ,pr_dstransf => 'Sobras Cotas'           --> Identificacao Transf.
                                   ,pr_cdfinali => 10 --Credito Conta Corrente  --> Finalidade TED   
                                   ,pr_dshistor => 'Rateio sobras cotas'       --> Descriçao do Histórico
                                   ,pr_cdispbif => rw_crapban.nrispbif  --> ISPB Banco Favorecido=
                                   ,pr_idagenda => 1
                                   -- saida        
                                   ,pr_dsprotoc => vr_dsprotoc  --> Retorna protocolo    
                                   ,pr_tab_protocolo_ted => vr_tab_protocolo_ted --> dados do protocolo
                                   ,pr_cdcritic => vr_cdcritic  --> Codigo do erro
                                   ,pr_dscritic => vr_dscritic);--> Descricao do erro
       
      --Se ocorreu erro na transferencia
      IF trim(vr_dscritic) IS NOT NULL OR 
         nvl(vr_cdcritic,0) <> 0       THEN
            
        RAISE vr_exc_saida;
            
      END IF;
         
      -- Gerar informações do log
      GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => NULL
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'TED - Sobras cotas'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 1 --> TRUE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'SOL030'
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
 
      -- Gerar log 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Conta/dv Destino'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => GENE0002.fn_mask_conta(pr_nrconta_dest || nvl(pr_nrdigito_dest,' ')));
                                 
      -- Gerar log 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor da TED'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => To_Char(pr_vldcotas,'fm999g999g990d00'));
                                 
                                 
      -- Gerar log 
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Saldo de cotas'
                               ,pr_dsdadant => To_Char(pr_vldcotas,'fm999g999g990d00')
                               ,pr_dsdadatu => To_Char(vr_vldcotas,'fm999g999g990d00'));
                                 
      --Efetua o commit a cada lançamento                  
      COMMIT;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        
        cecred.pc_internal_exception(3);
                
        pr_dscritic:= 'Erro na rotina TELA_SOL030.pc_efetua_envio_ted.';
        
    END;
      
  END pc_efetua_envio_ted;
  
  
  
  PROCEDURE pc_gerar_ted_rateio_capital(pr_cddopcao  IN VARCHAR2              --> Código da opção
                                       ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                       ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK

  BEGIN

  /* .............................................................................
  Programa: pc_gerar_ted_rateio_capital
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : TELA_SOL030
  Autor   : Jonata - RKAM
  Data    : Agosto/2017                       Ultima atualizacao: 
    
  Dados referentes ao programa:
    
  Frequencia: Sempre que for chamado
  Objetivo  : Rotina responsável por gerar as TED`s referente ao rateio de capital
    
  Alteracoes: 
  ..............................................................................*/ 
  
  DECLARE
  
    -- Variaveis de critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_exc_saida   EXCEPTION;
      
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_auxconta PLS_INTEGER := 0;
    
    --Variaveis de controle
    vr_vlrtotal NUMBER(25,2) := 0;
    vr_index    VARCHAR2(300);
    
    --Definicao das tabelas de memoria
    vr_tab_contas TELA_SOL030.typ_tab_contas;
     
    BEGIN
      
      -- Incluir nome
      GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                ,pr_action => 'SOL030');     
        
      -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_tab_contas.DELETE;
                                                 
      --Obter Agendamentos de Debito
      TELA_SOL030.pc_obtem_contas_rateio_capital (pr_cdcooper    => vr_cdcooper         --Cooperativa
                                                 ,pr_tab_contas  => vr_tab_contas       --tabela de agendamento
                                                 ,pr_cdcritic    => vr_cdcritic         --Codigo da Critica
                                                 ,pr_dscritic    => vr_dscritic);       --Descricao da Critica
                                     
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      
      --Percorrer todos contas
      vr_index:= vr_tab_contas.FIRST;
      WHILE vr_index IS NOT NULL LOOP
               
        --Efetuar Debitos
        TELA_SOL030.pc_efetua_envio_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_idorigem => vr_idorigem
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_vldcotas => vr_tab_contas(vr_index).vldcotas
                                       ,pr_cdbanco_dest   => vr_tab_contas(vr_index).cdbanco_dest
                                       ,pr_cdagenci_dest  => vr_tab_contas(vr_index).cdagenci_dest
                                       ,pr_nrconta_dest   => vr_tab_contas(vr_index).nrconta_dest
                                       ,pr_nrdigito_dest  => vr_tab_contas(vr_index).nrdigito_dest
                                       ,pr_nrcpfcgc_dest  => vr_tab_contas(vr_index).nrcpfcgc_dest
                                       ,pr_nmtitular_dest => vr_tab_contas(vr_index).nmtitular_dest
                                       ,pr_nrdconta  => vr_tab_contas(vr_index).nrdconta
                                       ,pr_inpessoa  => vr_tab_contas(vr_index).inpessoa
                                       ,pr_cdagenci  => vr_tab_contas(vr_index).cdagenci
                                       ,pr_cdcritic  => vr_cdcritic
                                       ,pr_dscritic  => vr_dscritic);                                      
                  
        --Se ocorreu erro atualiza a tabela de contas
        IF NVL(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
         
          vr_tab_contas(vr_index).dscritic:= vr_dscritic;
        ELSE
          vr_tab_contas(vr_index).fldebito:= TRUE;
        END IF;

        -- Gera log
        btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_nmarqlog     => 'sol030.log'
                                  ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                      ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                      'Efetuou o envio de TED referente ao rateio de capital -> ' || 
                                                      'Conta: ' || gene0002.fn_mask_conta(vr_tab_contas(vr_index).nrdconta) || 
                                                      ', Valor da TED: ' || To_Char(vr_tab_contas(vr_index).vldcotas,'fm999g999g990d00') ||
                                                      ', Conta destino: ' || gene0002.fn_mask_conta(vr_tab_contas(vr_index).nrconta_dest || nvl(vr_tab_contas(vr_index).nrdigito_dest,' ')) ||
                                                      ', CPF/CNPJ: ' || gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_contas(vr_index).nrcpfcgc_dest,
                                                                                                  pr_inpessoa => vr_tab_contas(vr_index).inpessoa) ||
                                                      ', Banco destino: ' || vr_tab_contas(vr_index).cdbanco_dest ||
                                                      ', Agência destino: ' || vr_tab_contas(vr_index).cdagenci_dest || 
                                                      (CASE WHEN vr_tab_contas(vr_index).fldebito THEN ', Enviado com sucesso.' ELSE ', Erro ao enviar: ' ||
                                                       vr_tab_contas(vr_index).dscritic
                                                       END)); 
                                                      
        --efetuar commit a cada lançamento
        commit;

        --Buscar o proximo registro do vetor
        vr_index:= vr_tab_contas.NEXT(vr_index);
         
      END LOOP;
      
      --Monta retorno com os registros inconsistentes
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?><Root/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Root', pr_posicao => 0, pr_tag_nova => 'dados', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
             
      --Percorrer todos contas
      vr_index:= vr_tab_contas.FIRST;
      WHILE vr_index IS NOT NULL LOOP   
       
        IF vr_tab_contas(vr_index).fldebito THEN
        
          --Buscar o proximo registro do vetor
          vr_index:= vr_tab_contas.NEXT(vr_index);
          continue;
            
        END IF;
        
        vr_vlrtotal:= vr_vlrtotal + nvl(vr_tab_contas(vr_index).vldcotas,0);
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'contas', pr_tag_cont => null , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => vr_tab_contas(vr_index).nrdconta , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'dscritic', pr_tag_cont => vr_tab_contas(vr_index).dscritic , pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'contas', pr_posicao => vr_auxconta, pr_tag_nova => 'vldcotas', pr_tag_cont => vr_tab_contas(vr_index).vldcotas , pr_des_erro => vr_dscritic);
          
        -- Incrementa contador p/ posicao no XML
        vr_auxconta := nvl(vr_auxconta,0) + 1;  
                
        --Buscar o proximo registro do vetor
        vr_index:= vr_tab_contas.NEXT(vr_index);
        
      END LOOP;
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Root'              --> Nome da TAG XML
                               ,pr_atrib => 'vlrtotal'          --> Nome do atributo
                               ,pr_atval => vr_vlrtotal         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                 
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      vr_tab_contas.DELETE;
           
      pr_des_erro := 'OK';          
        
    EXCEPTION        
      WHEN vr_exc_saida THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
      
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    WHEN OTHERS THEN
      
      cecred.pc_internal_exception(3);
      
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral em TELA_SOL030.pc_gerar_ted_rateio_capital.';
          
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       
    END;
      
  END pc_gerar_ted_rateio_capital;
  
  
  
END TELA_SOL030;
/
