CREATE OR REPLACE PACKAGE CECRED.TELA_GRAVAM AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_GRAVAM                         antigo: /ayllos/fontes/gravam.p
  --  Sistema  : Rotinas genericas referente a tela GRAVAM
  --  Sigla    : CRED
  --  Autor    : Andrei - RKAM
  --  Data     : Maio/2016.                   Ultima atualizacao: 28/07/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Responsavel pelo gerenciamento de GRAVAMES.

  -- Alteracoes: 28/07/2016 - Ajuste devido a criação de uma rotina para solicitação de 
  --                          processamento do arquivos de retorno
  --                         (Adriano - SD  495514)                          
  --
  ---------------------------------------------------------------------------------------------------------------
                               
  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
     
  /*Rotina para criar os arquivos de GRAVAMES*/                             
  PROCEDURE pc_gera_arquivo(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                           ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                           ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                           ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) ;        --> Erros do processo            
  
  PROCEDURE pc_busca_contratos_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_nrregist IN INTEGER               -- Número de registros
                                       ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK                                                                         
  
  PROCEDURE pc_busca_pa_associado(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);         --Saida OK/NOK
                                 
  PROCEDURE pc_busca_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE --Numero do contrato
                             ,pr_nrregist IN INTEGER               -- Número de registros
                             ,pr_nriniseq IN INTEGER               -- Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2);          --Saida OK/NOK
                             
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_solic_proces_retorno(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                                   ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                                   ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                                   ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                                   ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo                             
                                   
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_permissao_situacao(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);         --> Erros do processo
                                 
END TELA_GRAVAM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_GRAVAM AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: TELA_GRAVAM                          antigo: /ayllos/fontes/gravam.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Andrei - RKAM
   Data    : Maio/2016                       Ultima atualizacao: 12/04/2017

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Responsavel pelo gerenciamento de GRAVAMES.

   Alteracoes: 14/07/2016 - Ajuste para agrupar os gravames encontrados (Andrei - RKAM). 
   
               28/07/2016 - Ajuste devido a criação de uma rotina para solicitação de 
                            processamento do arquivos de retorno
                            (Adriano - SD  495514)                          
                                                               
               25/11/2016 - P341 - Automatização BACENJUD - Alterado o parametro PR_DSDEPART 
                            para PR_CDDEPART e as consultas do fonte para utilizar o código 
                            do departamento nas validações (Renato Darosci - Supero)
                                                          
               12/04/2017 - Inclusão da constante ct_nmdatela e correção dos logs, posicionando
                            o nome da tela antes da seta que indica o início da mensagem (Carlos)
                                                          
  ---------------------------------------------------------------------------------------------------------------*/
  
  ct_nmdatela CONSTANT VARCHAR2(6) := 'GRAVAM';
  
  /* Rotina para buscar as cooperativas */
  PROCEDURE pc_buscar_cooperativas(pr_flcecred   IN INTEGER            --> 0- Nao traz CECRED / 1 - Traz cecred 
                                  ,pr_flgtodas   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS  
                                  ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_buscar_cooperativas
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei - RKAM
    Data    : Maio/2016                       Ultima atualizacao:  

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as cooperativas ativas 

    Alteracoes:                            
    ............................................................................. */
      CURSOR cr_crapcop IS
      SELECT crapcop.cdcooper
            ,crapcop.nmrescop
        FROM crapcop
       WHERE (crapcop.cdcooper <> 3 AND pr_flcecred = 0)
          OR pr_flcecred = 1 
      ORDER BY crapcop.cdcooper;
      
      -- Variaveis de locais
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      --Variaveis de Criticas
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
             
      --Variaveis de Excecoes
      vr_exc_erro  EXCEPTION;
      
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
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cooperativas></cooperativas></Root>');
      
      IF pr_flgtodas = 1 AND vr_cdcooper = 3 THEN
        
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root/cooperativas'
                                           ,XMLTYPE('<cooperativa>'
                                                  ||'  <cdcooper>0</cdcooper>'
                                                  ||'  <nmrescop>TODAS</nmrescop>'
                                                  ||'</cooperativa>'));
                                                  
      END IF;                                                                                                
                                                  
      FOR rw_crapcop IN cr_crapcop LOOP
        
        IF vr_cdcooper <> 3                   AND 
           rw_crapcop.cdcooper <> vr_cdcooper THEN 
        
          continue;
          
        END IF;         
          
        -- Criar nodo filho
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                            ,'/Root/cooperativas'
                                            ,XMLTYPE('<cooperativa>'
                                                   ||'  <cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'
                                                   ||'  <nmrescop>'||UPPER(rw_crapcop.nmrescop)||'</nmrescop>'
                                                   ||'</cooperativa>'));
      END LOOP;
    
      -- Retorno OK          
      pr_des_erro:= 'OK';
          
    EXCEPTION
      WHEN vr_exc_erro THEN 
                     
        -- Erro
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        pr_nmdcampo := 'cdcooper';
        pr_des_erro := 'NOK'; 
                  
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                                                                                     
      WHEN OTHERS THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral (TELA_GRAVAM.pc_buscar_cooperativas): ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
        
  END pc_buscar_cooperativas;
  
  PROCEDURE pc_gera_arquivo(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                           ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                           ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                           ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                           ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo
    /* .............................................................................
    Programa: pc_gera_arquivo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Andrei - RKAM
    Data    : Maio/2016                       Ultima atualizacao:  

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para geração de arquivos de GRAVAMES  

    Alteracoes:                            
    ............................................................................. */
    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
           
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
  BEGIN
      
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
                                   
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
      
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    

    IF  vr_cdcooper <> 3 OR pr_cddepart NOT IN (14,20) THEN 

      -- Montar mensagem de critica
      vr_dscritic := 'Operador sem autorizacao para gerar arquivos!';
      RAISE vr_exc_erro;
      
    END IF;
            
    /* Geração dos arquivos do GRAVAMES */
    GRVM0001.pc_gravames_geracao_arquivo(pr_cdcooper  => vr_cdcooper -- Cooperativa conectada
                                        ,pr_cdcoptel  => pr_cdcoptel -- Opção selecionada na tela
                                        ,pr_tparquiv  => pr_tparquiv -- Tipo do arquivo selecionado na tela
                                        ,pr_dtmvtolt  => rw_crapdat.dtmvtolt   -- Data atual
                                        ,pr_cdcritic  => vr_cdcritic   -- Cod Critica de erro
                                        ,pr_dscritic  => vr_dscritic); -- Des Critica de erro
                                        
    --Se ocorreu um erro
    IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
			      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
                                                  
      RAISE vr_exc_erro;
            
    END IF;       
    
      
  EXCEPTION
    WHEN vr_exc_erro THEN 
                     
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      pr_nmdcampo := 'cdcooper';
      pr_des_erro := 'NOK'; 
                
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');    
                                     
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdcriticidade => 2
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - ' ||
                                                    ct_nmdatela || ' --> ' || vr_cdoperad || ' - ' ||
                                                    'ERRO: ' || vr_dscritic || ' [gravames_geracao_arquivo].');
                                                                                                     
    WHEN OTHERS THEN 
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_gera_arquivo --> '|| SQLERRM;
      pr_des_erro:= 'NOK';
          
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
       
      -- Gera log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'gravam.log'
                                ,pr_dstiplog      => 'E'
                                ,pr_cdcriticidade => 2
                                ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') || ' - ' ||
                                                    ct_nmdatela || ' --> ' || vr_cdoperad || ' - ' ||
                                                    'ERRO: ' || vr_dscritic || ' [gravames_geracao_arquivo].');  
        
  END pc_gera_arquivo;
  
  PROCEDURE pc_busca_contratos_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                       ,pr_nrregist IN INTEGER               -- Número de registros
                                       ,pr_nriniseq IN INTEGER               -- Número sequencial 
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_contratos_gravames                            antiga: b1wgen0171.gravames_busca_valida_contrato
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 14/07/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca contratos
    
    Alterações : 14/07/2016 - Ajuste para agrupar os contratos encontrados (Andrei - RKAM).
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_propostas(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE)IS

      SELECT crawepr.nrdconta
            ,crapbpr.nrctrpro
      FROM crawepr
          ,craplcr
          ,crapbpr
     WHERE crawepr.cdcooper = pr_cdcooper
       AND crawepr.nrdconta = pr_nrdconta
       AND craplcr.cdcooper = crawepr.cdcooper
       AND craplcr.cdlcremp = crawepr.cdlcremp
       AND craplcr.tpctrato = 2
       AND crapbpr.cdcooper = crawepr.cdcooper
       AND crapbpr.nrdconta = crawepr.nrdconta
       AND crapbpr.tpctrpro = 90
       AND crapbpr.nrctrpro = crawepr.nrctremp
       AND crapbpr.flgalien = 1
       AND (crapbpr.dscatbem LIKE '%AUTOMOVEL%' OR
            crapbpr.dscatbem LIKE '%MOTO%'      OR
            crapbpr.dscatbem LIKE '%CAMINHAO%')
       GROUP BY crawepr.nrdconta
               ,crapbpr.nrctrpro;  
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
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
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Propostas>');     
                           
    --Busca as propostas
    FOR rw_propostas IN cr_propostas(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<proposta>'||  
                                                       '  <nrdconta>' || rw_propostas.nrdconta ||'</nrdconta>'||                                                                                                      
                                                       '  <nrctrpro>' || TRIM(gene0002.fn_mask(rw_propostas.nrctrpro,'zzz.zzz.zzz')) ||'</nrctrpro>'||                                                      
                                                     '</proposta>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado sem Emprestimos tipo Alienacao Fiduciaria!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Propostas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_contratos_gravames --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_contratos_gravames;  

  PROCEDURE pc_busca_gravames(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                             ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE --Numero do contrato
                             ,pr_nrregist IN INTEGER               -- Número de registros
                             ,pr_nriniseq IN INTEGER               -- Número sequencial 
                             ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                             ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_gravames                             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao: 14/07/2016
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca gravames de um contrato informado
    
    Alterações : 14/07/2016 - Ajuste para agrupar os gravames encontrados (Andrei - RKAM).
    -------------------------------------------------------------------------------------------------------------*/                               
  
    CURSOR cr_crapbpr(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE
                     ,pr_nrctrpro IN crapbpr.nrctrpro%TYPE)IS
    SELECT crapbpr.nrdconta          
          ,crapbpr.nrgravam                  
      FROM crapbpr
     WHERE crapbpr.cdcooper = pr_cdcooper
       AND crapbpr.nrdconta = pr_nrdconta
       AND crapbpr.nrctrpro = pr_nrctrpro
       AND crapbpr.flgalien = 1
       GROUP BY crapbpr.nrdconta
               ,crapbpr.nrgravam;          
                       
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    vr_nrregist  INTEGER; 
    vr_qtregist  INTEGER := 0; 
    vr_contador  INTEGER := 0;  
        
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    vr_nrregist := pr_nrregist;
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
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
       
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
        
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Propostas>');     
                           
    --Busca os gravames
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctrpro => pr_nrctrpro) LOOP
    
      --Incrementar contador
      vr_qtregist:= nvl(vr_qtregist,0) + 1;
              
      -- controles da paginacao 
      IF (vr_qtregist < pr_nriniseq) OR
         (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN

        --Proximo
        CONTINUE;  
                  
      END IF; 
              
      IF vr_nrregist >= 1 THEN   
        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<proposta>'||  
                                                       '  <nrdconta>' || rw_crapbpr.nrdconta ||'</nrdconta>'||                                                                                                      
                                                       '  <nrgravam>' || TRIM(gene0002.fn_mask(rw_crapbpr.nrgravam,'zzz.zzz.zzz')) ||'</nrgravam>'||
                                                     '</proposta>');
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
           
      END IF;         
          
      vr_contador := vr_contador + 1; 
    
    END LOOP;

    IF vr_nrregist = 0 THEN
      
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado sem Emprestimos tipo Alienacao Fiduciaria!';
      
      RAISE vr_exc_erro;
          
    END IF;
        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Propostas></Root>'
                           ,pr_fecha_xml      => TRUE);
     
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);
       
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
               
    -- Insere atributo na tag Dados com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml          --> XML que irá receber o novo atributo
                             ,pr_tag   => 'Root'             --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
                             
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite); 
    
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_gravames --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_gravames;  

  PROCEDURE pc_busca_pa_associado(pr_nrdconta IN crapass.nrdconta%TYPE --Número da conta
                                 ,pr_cddopcao IN VARCHAR2              --Opção
                                 ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2)IS          --Saida OK/NOK
                            
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_pa_associado                            antiga: b1wgen0171.gravames_busca_pa_associado
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Andrei - RKAM
    Data     : Maio/2016                         Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Busca o pa do associado
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                               
    --Cursor para encontrar a cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Busca dos dados do associado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.cdagenci
     FROM crapass ass
    WHERE ass.cdcooper = pr_cdcooper
      AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);

    -- Variaveis de locais
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := '';      
    
    --Variaveis de Excecoes
    vr_exc_erro  EXCEPTION; 
  
  BEGIN
    
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                              ,pr_action => null); 
    
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
    
    --Busca a cooperativa
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
    
    FETCH cr_crapcop INTO rw_crapcop;    
    
    IF cr_crapcop%NOTFOUND THEN
  
      --Fecha o cursor
      CLOSE cr_crapcop;
      
      vr_cdcritic := 794;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
        
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapcop;
    
    END IF;
    
    IF pr_nrdconta = 0 THEN
      
      vr_cdcritic := 0;
      vr_dscritic := 'Informar o numero da conta.';

      RAISE vr_exc_erro;
    END IF;
    
    --Busca o associado
    OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    
    FETCH cr_crapass INTO rw_crapass;    
    
    IF cr_crapass%NOTFOUND THEN
  
      --Fecha o cursor
      CLOSE cr_crapass;
      
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

      RAISE vr_exc_erro;
        
    ELSE
      
      --Fecha o cursor
      CLOSE cr_crapass;
    
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
                        
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><agencia>' || 
                                                 '   <cdagenci>' || rw_crapass.cdagenci || '</cdagenci>' ||
                                                 '</agencia></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);   
                                                   
    pr_des_erro := 'OK';
    
  EXCEPTION
    WHEN vr_exc_erro THEN  
      
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN   
      
      pr_des_erro := 'NOK';
           
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_pa_associado --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');     
    
  END pc_busca_pa_associado;  
  
  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_solic_proces_retorno(pr_cdcoptel   IN INTEGER            --> 0- Não traz a opção TODAS / 1 - Traz a opção TODAS      
                                   ,pr_tparquiv   IN VARCHAR2           --> Tipo do arquivo                      
                                   ,pr_cddopcao   IN VARCHAR2           --> Opção da tela
                                   ,pr_cddepart   IN VARCHAR2           --> Departamento do operador
                                   ,pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                   ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_solic_proces_retorno             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Agosto/2016                           Ultima atualizacao:  
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para solicitar o processamento de arquivos de retorno enviados pela CETIP
  
    Alterações :  
                
  ---------------------------------------------------------------------------------------------------------------*/
    
    -- Selecionar dados da agencia
    CURSOR cr_crapage (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT crapage.cdcooper
          ,crapage.cdorgins
          ,crapage.cdagenci
      FROM crapage
     WHERE crapage.cdcooper = pr_cdcooper
       AND crapage.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
    
    -- Cursor para validacao da cooperativa conectada
    CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%type) IS
      SELECT cdcooper
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%rowtype;
    
    --> Verificar se o job 
    CURSOR cr_job (pr_job_name VARCHAR2) IS
    SELECT job.job_name
          ,job.next_run_date
      FROM dba_scheduler_jobs job
     WHERE job.owner = 'CECRED'
      AND job.job_name LIKE pr_job_name||'%';
    rw_job cr_job%ROWTYPE;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dsplsql  VARCHAR2(32767);
    vr_jobname  VARCHAR2(1000);
    vr_nmarqimp VARCHAR2(100);
    vr_nmarqpdf VARCHAR2(100);
    vr_auxconta PLS_INTEGER:= 0;
    vr_cdorgins INTEGER;
    vr_dtinirec DATE;
    vr_dtfinrec DATE;
    vr_cdcoptel INTEGER := nvl(pr_cdcoptel,0);
            
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                                ,pr_action => null); 
                                     
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
        
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;        
      
      IF  vr_cdcooper <> 3 OR pr_cddepart NOT IN (14,20) THEN 

        -- Montar mensagem de critica
        vr_dscritic := 'Operador sem autorizacao para gerar arquivos!';
        RAISE vr_exc_erro;
        
      END IF;
      
      IF vr_cdcoptel > 0 THEN
         
        --Busca a cooperativa
        OPEN cr_crapcop(pr_cdcooper => vr_cdcoptel);
        
        FETCH cr_crapcop INTO rw_crapcop;    
        
        IF cr_crapcop%NOTFOUND THEN
      
          --Fecha o cursor
          CLOSE cr_crapcop;
          
          vr_cdcritic := 794;
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          RAISE vr_exc_erro;
            
        ELSE
          
          --Fecha o cursor
          CLOSE cr_crapcop;
        
        END IF;
        
      END IF;
        
      -- Montar o prefixo do código do programa para o jobname
      vr_jobname := 'GRAVAM_PROCARQRET';    
             
      --> Verificar se o job 
      OPEN cr_job (pr_job_name => vr_jobname);
      
      FETCH cr_job INTO rw_job;
      
      IF cr_job%FOUND THEN
        
        CLOSE cr_job;
        
        -- Montar mensagem de critica
        vr_dscritic := 'Processamento dos arquivos ja solicitado.';
        RAISE vr_exc_erro;
      
      ELSE
        
        CLOSE cr_job;
        
        -- Montar o bloco PLSQL que será executado
        vr_dsplsql:= 'DECLARE'||chr(13)
                   || '  vr_cdcritic PLS_INTEGER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)
                   || '  vr_des_erro VARCHAR2(3);'||chr(13)
                   || '  vr_nmdcampo VARCHAR2(1000);'||chr(13)
                   || 'BEGIN'||chr(13)
                   || '  GRVM0001.pc_gravames_processa_retorno' 
                   || '  (pr_cdcooper => '||vr_cdcooper
                   || '  ,pr_cdcoptel => '||vr_cdcoptel   
                   || '  ,pr_cdoperad => '||chr(39)||vr_cdoperad||chr(39)    
                   || '  ,pr_tparquiv => '||chr(39)||pr_tparquiv||chr(39)   
                   || '  ,pr_dtmvtolt => '||chr(39)||rw_crapdat.dtmvtolt||chr(39) 
                   || '  ,pr_cdcritic => vr_cdcritic'   
                   || '  ,pr_dscritic => vr_dscritic);'||chr(13)    
                   || 'END;';
        
        --Se conseguiu montar o job
        IF vr_jobname IS NOT NULL THEN
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                                ,pr_cdprogra  => ct_nmdatela  --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                                ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                                ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                                ,pr_jobname   => vr_jobname   --> Nome randomico criado
                                ,pr_des_erro  => vr_dscritic);
          -- Testar saida com erro
          IF vr_dscritic IS NOT NULL THEN
            -- Levantar exceçao
            RAISE vr_exc_erro;
          END IF;
          
        END IF;
           
      END IF;
     
      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na TELA_GRAVAM.pc_solic_proces_retorno --> '|| SQLERRM;
        
         -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_solic_proces_retorno;

  /* Procedure para Solicitar o processamento de arquivos de retorno */
  PROCEDURE pc_permissao_situacao(pr_xmllog     IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER        --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2           --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2           --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS       --> Erros do processo

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_permissao_situacao             
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Lucas Lombardi
    Data     : Agosto/2016                           Ultima atualizacao:  
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para validar se pode ser alterado a situação do GRAVAMES
  
    Alterações :  
                
  ---------------------------------------------------------------------------------------------------------------*/
    
    CURSOR cr_crapope (pr_cdcooper crapope.cdcooper%TYPE
                      ,pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT dpo.dsdepart
        FROM crapdpo   dpo
           , crapope   ope
       WHERE dpo.cddepart = ope.cddepart
         AND dpo.cdcooper = ope.cdcooper
         AND ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope cr_crapope%ROWTYPE;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis Locais
    vr_dsdepart     VARCHAR2(1000);
    vr_dsdepart_ope VARCHAR2(1000);
    vr_flgfound     BOOLEAN;
    vr_retorno      VARCHAR2(1);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de Excecoes
    vr_exc_erro EXCEPTION;                                       
    
    BEGIN
      
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => ct_nmdatela
                                ,pr_action => null); 
                                     
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
      
      -- Buscar os departamentos que podem alterar a situação
      vr_dsdepart := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                              ,pr_cdcooper => vr_cdcooper
                                              ,pr_cdacesso => 'DEPTO_SIT_GRAVAMES');
      
      -- Buscar o departamento em que o operador está cadastrado
      OPEN cr_crapope (vr_cdcooper, vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      vr_flgfound := cr_crapope%FOUND;
      CLOSE cr_crapope;
      
      -- Se não encontrar operador gera erro
      IF NOT vr_flgfound THEN
        vr_cdcritic := 67;
        RAISE vr_exc_erro;
      END IF;
      
      vr_dsdepart_ope := rw_crapope.dsdepart;
      
      -- Retorno do XML
      vr_retorno :=  gene0002.fn_existe_valor(vr_dsdepart, vr_dsdepart_ope,',');
      
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>' || vr_retorno || '</Dados></Root>');

      --Retorno OK
      pr_des_erro:= 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        --Desfaz alteracoes
        ROLLBACK;
        
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        --Monta mensagem de erro
        pr_cdcritic:= 0;
        pr_dscritic := 'Erro na TELA_GRAVAM.pc_solic_proces_retorno --> '|| SQLERRM;
        
         -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
                                         
  END pc_permissao_situacao;


END TELA_GRAVAM;
/
