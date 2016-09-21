CREATE OR REPLACE PACKAGE CECRED.ZOOM0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : ZOOM0001                         antigo: /sistema/generico/procedures/b1wgen0059.p
    Sistema  : Rotinas genericas referente a zoom de pesquisa
    Sigla    : ZOOM
    Autor    : Adriano Marchi
    Data     : 30/11/2015.                   Ultima atualizacao: 24/02/2016
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : Buscar os dados p/ telas de pesquisas ou zoom's

   Alteracoes: 24/02/2016 - Criação das rotinas respectivas a conversão da tela CADCCO/ATURAT
   				            (Jonathan RJKAM).
  
  ---------------------------------------------------------------------------------------------------------------*?
  
  /* Tabela para guardar os operadores */
  TYPE typ_operadores IS RECORD 
    (cdcooper crapope.cdcooper%TYPE
    ,cdoperad crapope.cdoperad%TYPE
    ,nmoperad crapope.nmoperad%TYPE
    ,cdagenci crapope.cdagenci%TYPE
    ,vlpagchq crapope.vlpagchq%TYPE);
    
  --Tabela para guardar os operadores  
  TYPE typ_tab_operadores IS TABLE OF typ_operadores INDEX BY PLS_INTEGER;
  
  /* Tabela para guardar os historicos */
  TYPE typ_historicos IS RECORD 
    (cdhistor craphis.cdhistor%TYPE
    ,dshistor craphis.dshistor%TYPE);
    
  --Tabela para guardar os historicos  
  TYPE typ_tab_historicos IS TABLE OF typ_historicos INDEX BY PLS_INTEGER;
  
  /* Tabela para guardar os bancos caixa */
  TYPE typ_banco_caixa IS RECORD 
    (cdbccxlt crapbcl.cdbccxlt%TYPE
    ,nmextbcc crapbcl.nmextbcc%TYPE);
    
  --Tabela para guardar os bancos caixa  
  TYPE typ_tab_banco_caixa IS TABLE OF typ_banco_caixa INDEX BY PLS_INTEGER;

  /* Tabela para guardar os parametro de cobranca */
  TYPE typ_cobranca IS RECORD 
    (nrconven crapcco.nrconven%TYPE
    ,nrdctabb crapcco.nrdctabb%TYPE
    ,cddbanco crapcco.cddbanco%TYPE
    ,situacao VARCHAR(10)
    ,dsorgarq crapcco.dsorgarq%TYPE);
    
  --Tabela para guardar os parametro de cobranca 
  TYPE typ_tab_cobranca IS TABLE OF typ_cobranca INDEX BY PLS_INTEGER;
  
  --Tabela para guardar os bancos
  TYPE typ_tab_bancos IS TABLE OF crapban%ROWTYPE INDEX BY PLS_INTEGER;

  /* Procedure para encontrar operadores */
  PROCEDURE pc_busca_operadores_web(pr_cdoperad IN crapope.cdoperad%TYPE   --Operador                                   
                                   ,pr_nmoperad IN crapope.nmoperad%TYPE   --Nome do operador
                                   ,pr_nrregist IN NUMBER                  --Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                  --Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
                                   
  /* Rotina para encontrar os operadores */
  PROCEDURE pc_busca_operadores_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                   ,pr_nriniseq IN INTEGER  -->Quantidade inicial
                                   ,pr_nrregist IN INTEGER  -->Quantidade registros
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro    
								   
  PROCEDURE pc_busca_bancos_web (pr_cdbccxlt  IN crapban.cdbccxlt%TYPE
                                ,pr_cddbanco  IN crapban.cdbccxlt%TYPE
                                ,pr_nmextbcc  IN crapban.nmextbcc%TYPE
                                ,pr_nrregist  IN INTEGER          --> Quantidade de registros                    
                                ,pr_nriniseq  IN INTEGER          --> Qunatidade inicial
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) ;           --Saida OK/NOK
     
  --Rotina para buscar os bancos                            
  PROCEDURE pc_busca_bancos_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                               ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                               ,pr_nrregist IN INTEGER                              
                               ,pr_nriniseq IN INTEGER  
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                               ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro  
    
  --Rotina para buscar os convenios                           
  PROCEDURE pc_busca_param_cnv_cob(pr_nrconven IN crapcco.nrconven%TYPE        --Convenio
                                  ,pr_nriniseq IN NUMBER                  --Quantidade inicial
                                  ,pr_nrregist IN NUMBER                  --Qunatidade de registros
                                  ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) ;           --Saida OK/NOK 


  --Rotina para buscar os históricos 
  PROCEDURE pc_busca_historico_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                   ,pr_nrdcaixa IN INTEGER               --Código caixa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                   ,pr_cdhistor IN craphis.cdhistor%TYPE --> cd historico
                                   ,pr_dshistor IN craphis.dshistor%TYPE --> ds historico
                                   ,pr_flglanca IN INTEGER --> flag se lancamento
                                   ,pr_inautori IN INTEGER -->                                    
                                   ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro  
  
  --Rotina para buscar os históricos 
  PROCEDURE pc_busca_historico_web(pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdtarhis  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhiscxa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisnet  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhistaa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisblq  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                                  ,pr_flglanca  IN INTEGER --> flag se lancamento
                                  ,pr_inautori  IN INTEGER 
                                  ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                  ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                  ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2) ;           --Saida OK/NOK 	
                                  
  --Rotina para buscar os banco/caixa
  PROCEDURE pc_busca_banco_caixa_web(pr_cdbccxlt  IN crapbcl.cdbccxlt%TYPE -- Código do banco
                                    ,pr_nmextbcc  IN crapbcl.nmextbcc%TYPE -- Nome do Banco
                                    ,pr_nmbcolot  IN crapban.nmextbcc%TYPE
                                    ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                    ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                    ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro  OUT VARCHAR2);           --Saida OK/NOK 
                                    
  --Rotina para buscar os banco/caixa 
  PROCEDURE pc_busca_banco_caixa_car( pr_cdcooper IN crapcop.cdcooper%type --> Codigo Cooperativa  
                                     ,pr_nrdcaixa IN INTEGER               --> Código caixa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE --> Código do banco
                                     ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE --> Nome do banco
                                     ,pr_nrregist IN INTEGER               --> Quantidade de registros                            
                                     ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro                                                                       							                                  
                                   
END ZOOM0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ZOOM0001 AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: ZOOM0001                          antigo: /sistema/generico/procedures/b1wgen0059.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Adriano Marchi
   Data    : 30/11/2015                       Ultima atualizacao: 24/02/2016

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Buscar os dados p/ telas de pesquisas ou zoom's

   Alteracoes: 24/02/2016 - Criação das rotinas respectivas a conversão da tela CADCCO/ATURAT
   				                 (Jonathan RJKAM).                                         
  ---------------------------------------------------------------------------------------------------------------*/
  
  /*PROCEDURE RESPONSAVEL POR ENCONTRAR OPERADORES*/
  PROCEDURE pc_busca_operadores(pr_cdcooper IN crapcop.cdcooper%TYPE --Cooperativa do operador                               
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdoperad IN crapope.cdoperad%TYPE --Código do Operador
                               ,pr_nmoperad IN crapope.nmoperad%TYPE --Nome do operador
                               ,pr_nrregist IN INTEGER               --Número de registros
                               ,pr_nriniseq IN INTEGER               --Número sequencial
                               ,pr_qtregist OUT INTEGER              --Quantidade de registros
                               ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                               ,pr_tab_operadores OUT ZOOM0001.typ_tab_operadores --Tabela w-inform
                               ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                               ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
                                                
     
    /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_operador                            antiga: b1wgen0059.p busca-crapope
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Novembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para Buscar Informacoes operadores
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/
    CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE
                     ,pr_nmoperad IN crapope.nmoperad%TYPE) IS                     
    SELECT ope.cdcooper
          ,ope.cdoperad
          ,ope.cdagenci
          ,ope.nmoperad
          ,ope.vlpagchq
     FROM crapope ope
    WHERE (TRIM(pr_cdoperad) IS NULL 
           OR UPPER(ope.cdoperad) = UPPER(pr_cdoperad))
       AND ope.cdcooper = pr_cdcooper       
       AND (TRIM(pr_nmoperad) IS NULL
            OR UPPER(ope.nmoperad) LIKE '%' || UPPER(pr_nmoperad) || '%');
    rw_crapope cr_crapope%ROWTYPE;
    
    --Variaveis Locais
    vr_nrregist INTEGER;
    vr_index    PLS_INTEGER;
      
    --Variaveis de Erro
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
      
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;
      
    BEGIN
      --Limpar tabelas auxiliares
      pr_tab_operadores.DELETE;
        
      --Inicializar Variavel
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      --Selecionar Titular
      FOR rw_crapope IN cr_crapope(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_nmoperad => pr_nmoperad) LOOP
                                   
        --Indice para a temp-table
        vr_index:= pr_tab_operadores.COUNT + 1;
                                    
        --Incrementar Quantidade Registros do Parametro
        pr_qtregist:= nvl(pr_qtregist,0) + 1;
          
        /* controles da paginacao */
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
          
        --Numero Registros
        IF vr_nrregist > 0 THEN 
                               
          --Verificar se já existe na temp-table                             
          IF NOT pr_tab_operadores.EXISTS(vr_index) THEN
              
            --Popular dados na tabela memoria
            pr_tab_operadores(vr_index).cdcooper:= rw_crapope.cdcooper;
            pr_tab_operadores(vr_index).cdoperad:= rw_crapope.cdoperad;
            pr_tab_operadores(vr_index).cdagenci:= rw_crapope.cdagenci;
            pr_tab_operadores(vr_index).nmoperad:= rw_crapope.nmoperad;
            pr_tab_operadores(vr_index).vlpagchq:= rw_crapope.vlpagchq;
              
          END IF;  
        END IF;
          
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;  
      END LOOP;  

      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;                           
       
      IF pr_tab_operadores.COUNT() = 0 THEN
      
        vr_dscritic := 'Nenhum operador foi encontrado.';
        RAISE vr_exc_erro;
        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
          
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
          
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
          
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
      
  END pc_busca_operadores;

  /* Procedure para encontrar operadores */
  PROCEDURE pc_busca_operadores_web(pr_cdoperad IN crapope.cdoperad%TYPE   --Operador                                   
                                   ,pr_nmoperad IN crapope.nmoperad%TYPE   --Nome do operador
                                   ,pr_nrregist IN NUMBER                  --Quantidade de registros
                                   ,pr_nriniseq IN NUMBER                  --Qunatidade inicial
                                   ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                   ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
 
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_busca_opreradores_web              Antigo: busca-crapope
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Adriano Marchi
    Data     : Novembro/2015                           Ultima atualizacao: 26/02/2016 
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para buscar os operadores. Apenas chama a rotina pc_busca_operadores.
  
    Alterações : 26/02/2016 - Ajuste para contabilizar os registros encontrados corretamente
                             (Jonathan - RKAM)
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_operadores ZOOM0001.typ_tab_operadores;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_operadores.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      
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
      
      pc_busca_operadores(pr_cdcooper => vr_cdcooper
                         ,pr_nrdcaixa => vr_nrdcaixa
                         ,pr_cdagenci => vr_cdagenci                        
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nmoperad => pr_nmoperad
                         ,pr_nrregist => pr_nrregist
                         ,pr_nriniseq => pr_nriniseq
                         ,pr_qtregist => vr_qtregist
                         ,pr_nmdcampo => pr_nmdcampo
                         ,pr_tab_operadores => vr_tab_operadores 
                         ,pr_tab_erro => vr_tab_erro
                         ,pr_des_erro => vr_des_reto);
                               
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_web.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><Operadores>');
      
      --Buscar Primeiro beneficiario
      vr_index:= vr_tab_operadores.FIRST;
        
      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<inf>'||
                                                        '<cdcooper>' || vr_tab_operadores(vr_index).cdcooper ||'</cdcooper>'||
                                                        '<cdoperad>' || vr_tab_operadores(vr_index).cdoperad ||'</cdoperad>'||
                                                        '<cdagenci>' || vr_tab_operadores(vr_index).cdagenci ||'</cdagenci>'||
                                                        '<nmoperad>' || vr_tab_operadores(vr_index).nmoperad ||'</nmoperad>'||
                                                        '<vlpagchq>' || vr_tab_operadores(vr_index).vlpagchq ||'</vlpagchq>'||                                                          
                                                     '</inf>');         
                   
        --Proximo Registro
        vr_index:= vr_tab_operadores.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</Operadores></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);

      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Operadores'        --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                                   
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
                                      
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_operadores_web;  

  /* Rotina para encontrar os operadores */
  PROCEDURE pc_busca_operadores_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                   ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                   ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                   ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                   ,pr_nriniseq IN INTEGER  -->Quantidade inicial
                                   ,pr_nrregist IN INTEGER  -->Quantidade registros
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_operadores_car            Antiga: busca-crapope
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Adrinao Marchi (CECRED)
    Data    : 30/11/2015                          Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Realizar a busca de operadores

    Alteracoes:                               
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_operadores ZOOM0001.typ_tab_operadores;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_operadores.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
       
      --Busca operadores                                                         
      pc_busca_operadores(pr_cdcooper => pr_cdcooper
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_cdagenci => pr_cdagenci                        
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nmoperad => ''
                         ,pr_nrregist => pr_nrregist
                         ,pr_nriniseq => pr_nriniseq
                         ,pr_qtregist => vr_qtregist
                         ,pr_nmdcampo => pr_nmdcampo
                         ,pr_tab_operadores => vr_tab_operadores 
                         ,pr_tab_erro => vr_tab_erro
                         ,pr_des_erro => vr_des_reto);
                               
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_car.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
      
      -- Criar documento XML
      dbms_lob.createtemporary(pr_clob_ret, TRUE);
      dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

      --Buscar Primeira regional
      vr_index:= vr_tab_operadores.FIRST;
        
      --Percorrer todos as regionais
      WHILE vr_index IS NOT NULL LOOP
        vr_string:= '<regi>'||
                      '<cdcooper>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdcooper),'0')|| '</cdcooper>'||
                      '<cdoperad>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdoperad),'0')|| '</cdoperad>'||
                      '<cdagenci>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).cdoperad),' ')|| '</cdagenci>'||
                      '<nmoperad>'||NVL(TO_CHAR(vr_tab_operadores(vr_index).nmoperad),' ')|| '</nmoperad>'||                        
                    '</regi>';

         -- Escrever no XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => vr_string
                               ,pr_fecha_xml      => FALSE);

        --Proximo Registro
        vr_index:= vr_tab_operadores.NEXT(vr_index);

      END LOOP;

      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => '</root>'
                             ,pr_fecha_xml      => TRUE);
                                                                                                                   
      --Retorno
      pr_des_erro:= 'OK';       
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na ZOOM0001.pc_busca_operadores_car --> '|| SQLERRM;

  END pc_busca_operadores_car;

  
  PROCEDURE pc_busca_param_cnv_cob(pr_nrconven IN crapcco.nrconven%TYPE   --Convenio
                                  ,pr_nriniseq IN NUMBER                  --Quantidade inicial
                                  ,pr_nrregist IN NUMBER                  --Qunatidade de registros
                                  ,pr_xmllog   IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS           --Saida OK/NOK
    
                              
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_param_convenios                            
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para trazer parametros do cadastro de cobranca.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/  
                              
  --Cursor para encontrar os convenios  
  CURSOR cr_crapcco(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrconven IN crapcco.nrconven%TYPE) IS
  SELECT crapcco.nrconven
        ,crapcco.nrdctabb
        ,crapcco.cddbanco
        ,DECODE(crapcco.flgativo,1,'ATIVO','INATIVO') situacao
        ,crapcco.dsorgarq    
    FROM crapcco 
   WHERE crapcco.cdcooper = pr_cdcooper  
     AND(pr_nrconven IS NULL  OR
         crapcco.nrconven = pr_nrconven)
         ORDER BY crapcco.nmdbanco;
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de parametros cobranca
    vr_tab_cobranca typ_tab_cobranca;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nrregist INTEGER;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_cobranca.DELETE;
      
      --Inicializar Variaveis
      vr_nrregist:= pr_nrregist;
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
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
      
      FOR rw_crapcco IN cr_crapcco(pr_cdcooper => vr_cdcooper
                                  ,pr_nrconven => pr_nrconven) LOOP
      
        --Incrementar Quantidade Registros do Parametro
        vr_qtregist:= nvl(vr_qtregist,0) + 1;
          
        /* controles da paginacao */
        IF (vr_qtregist < pr_nriniseq) OR
           (vr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
           --Proximo Titular
          CONTINUE;
        END IF; 
          
        --Numero Registros
        IF vr_nrregist > 0 THEN 
          
          --Indice para a temp-table
          vr_index:= vr_tab_cobranca.COUNT + 1;        
          vr_tab_cobranca(vr_index).nrconven:= rw_crapcco.nrconven;
          vr_tab_cobranca(vr_index).nrdctabb:= rw_crapcco.nrdctabb;
          vr_tab_cobranca(vr_index).cddbanco:= rw_crapcco.cddbanco;
          vr_tab_cobranca(vr_index).situacao:= rw_crapcco.situacao;
          vr_tab_cobranca(vr_index).dsorgarq:= rw_crapcco.dsorgarq;
          
        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1; 
        
      END LOOP;          
             
      IF vr_tab_cobranca.COUNT() = 0 THEN      
        vr_dscritic := 'Nenhum parametro de convenio encontrado.';
        RAISE vr_exc_erro;        
      END IF;
        
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros>');
      
      --Buscar Primeiro beneficiario
      vr_index:= vr_tab_cobranca.FIRST;
        
      --Percorrer todos os beneficiarios
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados            
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<cobranca>'||  
                                                        '<nrconven>' || TO_CHAR(gene0002.fn_mask(vr_tab_cobranca(vr_index).nrconven,'zzzzzz.zz9')) ||'</nrconven>'||
                                                        '<nrdctabb>' || LTrim(RTRIM(gene0002.fn_mask(vr_tab_cobranca(vr_index).nrdctabb, 'zzzz.zzz.9'))) ||'</nrdctabb>'||                                                         
                                                        '<cddbanco>' || vr_tab_cobranca(vr_index).cddbanco ||'</cddbanco>'||
                                                        '<flgativo>' || vr_tab_cobranca(vr_index).situacao ||'</flgativo>'||
                                                        '<dsorgarq>' || vr_tab_cobranca(vr_index).dsorgarq ||'</dsorgarq>'||                                                          
                                                     '</cobranca>'); 
          
        --Proximo Registro
        vr_index:= vr_tab_cobranca.NEXT(vr_index);
          
      END LOOP;
        
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</parametros></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'parametros'            --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'             --> Nome do atributo
                               ,pr_atval => vr_qtregist    --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                               
      

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);      
                                   
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;  
      
    EXCEPTION
      WHEN vr_exc_erro THEN        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_busca_param_cnv_cob --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');   
    
  END pc_busca_param_cnv_cob;
  
  
  PROCEDURE pc_busca_bancos (pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa 
                            ,pr_nrdcaixa IN INTEGER               --Código caixa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                            ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                            ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                            ,pr_nrregist IN INTEGER
                            ,pr_nriniseq IN INTEGER
                            ,pr_qtregist OUT INTEGER
                            ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                            ,pr_tab_bancos OUT typ_tab_bancos --Tabela w-inform
                            ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                            ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    CURSOR cr_crapban IS
    SELECT crapban.cdbccxlt
          ,crapban.nmextbcc
          ,crapban.nmresbcc
          ,crapban.dtmvtolt
          ,crapban.cdoperad
          ,crapban.flgoppag
          ,crapban.nrispbif
          ,crapban.flgdispb
          ,crapban.dtinispb
     FROM  crapban 
    WHERE crapban.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,crapban.cdbccxlt,pr_cdbccxlt)
      AND (TRIM(pr_nmextbcc) IS NULL 
       OR upper(crapban.nmextbcc) LIKE '%'|| upper(pr_nmextbcc) || '%' )
         ORDER BY crapban.cdbccxlt;
    
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000):= NULL;
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
  
  --Tabela de bancos
  vr_tab_bancos typ_tab_bancos;
  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;
  
  BEGIN
   --limpar tabela BANCOS
    vr_tab_bancos.DELETE;
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    vr_nrregist := nvl(pr_nrregist,0);
    
    FOR rw_crapban IN cr_crapban LOOP
      
      --Indice para a temp-table
      vr_index:= pr_tab_bancos.COUNT + 1;
                                    
      --Incrementar Quantidade Registros do Parametro
      pr_qtregist:= nvl(pr_qtregist,0) + 1;
          
      /* controles da paginacao */
      IF (pr_qtregist < nvl(pr_nriniseq,0)) OR
         (pr_qtregist > (nvl(pr_nriniseq,0) + nvl(pr_nrregist,0))) THEN
         --Proximo registro
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_bancos.EXISTS(vr_index) THEN   
                     
            --Popular dados na tabela memoria
            pr_tab_bancos(vr_index).cdbccxlt:= rw_crapban.cdbccxlt;
            pr_tab_bancos(vr_index).nmextbcc:= rw_crapban.nmextbcc;
            pr_tab_bancos(vr_index).nmresbcc:= rw_crapban.nmresbcc;
            pr_tab_bancos(vr_index).dtmvtolt:= rw_crapban.dtmvtolt;
            pr_tab_bancos(vr_index).cdoperad:= rw_crapban.cdoperad;
            pr_tab_bancos(vr_index).flgoppag:= rw_crapban.flgoppag;   
            pr_tab_bancos(vr_index).nrispbif:= rw_crapban.nrispbif;             
            pr_tab_bancos(vr_index).flgdispb:= rw_crapban.flgdispb;   
            pr_tab_bancos(vr_index).dtinispb:= rw_crapban.dtinispb;
                       
          END IF;  
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    --Retorno OK
    pr_des_erro:= 'OK';  
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';          
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
          
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
          
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
  END  pc_busca_bancos;     
  
  PROCEDURE pc_busca_bancos_web (pr_cdbccxlt  IN crapban.cdbccxlt%TYPE
                                ,pr_cddbanco  IN crapban.cdbccxlt%TYPE
                                ,pr_nmextbcc  IN crapban.nmextbcc%TYPE
                                ,pr_nrregist  IN INTEGER                              
                                ,pr_nriniseq  IN INTEGER  
                                ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                ,pr_des_erro  OUT VARCHAR2) IS           --Saida OK/NOK
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos_web                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos, apenas chama pc_busca_bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_bancos typ_tab_bancos;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;    
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_cdbccxlt crapban.cdbccxlt%TYPE := 0;
   
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                 
  
  BEGIN
    --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_bancos.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= NULL;
      
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
      
      --Pega o código do banco a ser pesquisado
      IF pr_cdbccxlt > 0 THEN
        
        vr_cdbccxlt := pr_cdbccxlt;
        
      ELSIF pr_cddbanco > 0 THEN
        
        vr_cdbccxlt := pr_cddbanco;
        
      END IF;
      
      pc_busca_bancos(pr_cdcooper   => vr_cdcooper 
                     ,pr_nrdcaixa   => vr_nrdcaixa
                     ,pr_cdagenci   => vr_cdagenci
                     ,pr_cdbccxlt   => vr_cdbccxlt
                     ,pr_nmextbcc   => pr_nmextbcc
                     ,pr_nrregist   => pr_nrregist
                     ,pr_nriniseq   => pr_nriniseq
                     ,pr_qtregist   => vr_qtregist
                     ,pr_nmdcampo   => pr_nmdcampo
                     ,pr_tab_bancos => vr_tab_bancos
                     ,pr_tab_erro   => vr_tab_erro
                     ,pr_des_erro   => vr_des_reto);
                     
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN    
            
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na pc_busca_bancos_web.';
        END IF;  
                
        --Levantar Excecao
        RAISE vr_exc_erro; 
              
      END IF;
      
      -- Monta documento XML de ERRO
      dbms_lob.createtemporary(vr_clob, TRUE);
      dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
      -- Criar cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><bancos>');
      
      --Buscar Primeiro registro
      vr_index:= vr_tab_bancos.FIRST;
        
      --Percorrer todos os registros
      WHILE vr_index IS NOT NULL LOOP

        -- Carrega os dados           
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<banco>'||
                                                     '  <cdbccxlt>' || vr_tab_bancos(vr_index).cdbccxlt ||'</cdbccxlt>'||
                                                     '  <nmextbcc>' || vr_tab_bancos(vr_index).nmextbcc ||'</nmextbcc>'||
                                                     '  <nmresbcc>' || vr_tab_bancos(vr_index).nmresbcc ||'</nmresbcc>'||
                                                     '  <dtmvtolt>' || vr_tab_bancos(vr_index).dtmvtolt ||'</dtmvtolt>'||
                                                     '  <cdoperad>' || vr_tab_bancos(vr_index).cdoperad ||'</cdoperad>'||
                                                     '  <flgoppag>' || vr_tab_bancos(vr_index).flgoppag ||'</flgoppag>'||
                                                     '  <nrispbif>' || vr_tab_bancos(vr_index).nrispbif ||'</nrispbif>'||
                                                     '  <flgdispb>' || vr_tab_bancos(vr_index).flgdispb ||'</flgdispb>'||
                                                     '  <dtinispb>' || vr_tab_bancos(vr_index).dtinispb ||'</dtinispb>'||                                                        
                                                     '</banco>'); 
                   
        --Proximo Registro
        vr_index:= vr_tab_bancos.NEXT(vr_index);      
            
      END LOOP;
      
      -- Encerrar a tag raiz
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '</bancos></Root>'
                             ,pr_fecha_xml      => TRUE);
                  
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      
      -- Insere atributo na tag banco com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'bancos'            --> Nome da TAG XML
                               ,pr_atrib => 'qtregist'          --> Nome do atributo
                               ,pr_atval => vr_qtregist         --> Valor do atributo
                               ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                               ,pr_des_erro => vr_dscritic);    --> Descrição de erros

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);    
                                   
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF; 
                                      
      --Retorno
      pr_des_erro:= 'OK'; 
  
  EXCEPTION
    WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                       
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na pc_busca_bancos_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_bancos_web;
                                
  PROCEDURE pc_busca_bancos_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                               ,pr_nrdcaixa IN INTEGER               --Código caixa
                               ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                               ,pr_cdbccxlt IN crapban.cdbccxlt%TYPE
                               ,pr_nmextbcc IN crapban.nmextbcc%TYPE
                               ,pr_nrregist IN INTEGER                              
                               ,pr_nriniseq IN INTEGER  
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                               ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                               ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                               ,pr_dscritic OUT VARCHAR2)IS         --> Descricao Erro  
                                
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_bancos_car                            antiga: b1wgen0059\busca-crapban
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Procedure para pesquisa de bancos, apenas chama pc_busca_bancos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_bancos typ_tab_bancos;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;         
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_bancos.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= null;   
    
    pc_busca_bancos(pr_cdcooper   => pr_cdcooper 
                   ,pr_nrdcaixa   => pr_nrdcaixa
                   ,pr_cdagenci   => pr_cdagenci
                   ,pr_cdbccxlt   => pr_cdbccxlt
                   ,pr_nmextbcc   => pr_nmextbcc
                   ,pr_nrregist   => pr_nrregist
                   ,pr_nriniseq   => pr_nriniseq
                   ,pr_qtregist   => vr_qtregist
                   ,pr_nmdcampo   => pr_nmdcampo
                   ,pr_tab_bancos => vr_tab_bancos
                   ,pr_tab_erro   => vr_tab_erro
                   ,pr_des_erro   => vr_des_reto);
                     
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN    
          
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_car.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF; 
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_bancos.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      
      vr_string:= '<banco>'||
                  '  <cdbccxlt>' || vr_tab_bancos(vr_index).cdbccxlt ||'</cdbccxlt>'||
                  '  <nmextbcc>' || vr_tab_bancos(vr_index).nmextbcc ||'</nmextbcc>'||
                  '  <nmresbcc>' || vr_tab_bancos(vr_index).nmresbcc ||'</nmresbcc>'||
                  '  <dtmvtolt>' || vr_tab_bancos(vr_index).dtmvtolt ||'</dtmvtolt>'||
                  '  <cdoperad>' || vr_tab_bancos(vr_index).cdoperad ||'</cdoperad>'||
                  '  <flgoppag>' || vr_tab_bancos(vr_index).flgoppag ||'</flgoppag>'||
                  '  <nrispbif>' || vr_tab_bancos(vr_index).nrispbif ||'</nrispbif>'||
                  '  <flgdispb>' || vr_tab_bancos(vr_index).flgdispb ||'</flgdispb>'||
                  '  <dtinispb>' || vr_tab_bancos(vr_index).dtinispb ||'</dtinispb>'||                          
                  '</banco>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_bancos.NEXT(vr_index);
      
    END LOOP; 
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
    --Retorno
    pr_des_erro:= 'OK';       
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;                  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      pr_cdcritic:= 0;
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na pc_busca_bancos_car --> '|| SQLERRM;
  
  END pc_busca_bancos_car; 
  
  PROCEDURE pc_busca_historico(pr_cdcooper IN crapcop.cdcooper%TYPE   -- Cooperativa 
                              ,pr_nrdcaixa IN INTEGER               --Código caixa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                              ,pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                              ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                              ,pr_flglanca  IN INTEGER --> flag se lancamento
                              ,pr_inautori  IN INTEGER 
                              ,pr_nrregist IN INTEGER
                              ,pr_nriniseq IN INTEGER
                              ,pr_qtregist OUT INTEGER
                              ,pr_nmdcampo OUT VARCHAR2             -->Nome do campo com erro
                              ,pr_tab_historicos OUT typ_tab_historicos --Tabela historicos
                              ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                              ,pr_des_erro OUT VARCHAR2)IS --Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_craphis IS
  SELECT craphis.indebfol
        ,craphis.tplotmov
        ,craphis.indebcre
        ,craphis.inhistor
        ,craphis.indebcta
        ,craphis.inautori
        ,craphis.cdhistor
        ,craphis.dshistor
   FROM craphis 
  WHERE craphis.cdcooper = pr_cdcooper                
    AND craphis.cdhistor = decode(nvl(pr_cdhistor,0),0,craphis.cdhistor,pr_cdhistor)
    AND (TRIM(pr_dshistor) IS NULL
     OR upper(craphis.dsexthst) LIKE '%'|| upper(pr_dshistor) ||'%');
    
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;
                              
  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_historicos.DELETE;  
    
    FOR rw_craphis IN cr_craphis LOOP
      
      IF pr_flglanca = 1   THEN /* Utilizado pela LOTE e LANAUT */
        
        IF rw_craphis.indebfol <> 1   THEN 
          
          IF rw_craphis.tplotmov <> 1   OR
             rw_craphis.indebcre <> 'D' OR
             rw_craphis.inhistor <> 1   OR
             rw_craphis.indebcta <> 1   THEN
             CONTINUE;
          END IF;
          
        END IF;
        
      END IF;
      
      IF pr_inautori = 9 THEN  /* Utilizado pelo programa DCTROR */
        
        IF rw_craphis.tplotmov <> 8 AND
           rw_craphis.tplotmov <> 9 THEN 
           CONTINUE;
        END IF;      
         
      ELSE 
        IF pr_inautori <> 0 THEN
          IF rw_craphis.inautori <> 1 THEN
            CONTINUE;
          END IF;
        END IF;
      END IF;
      
      --Indice para a temp-table
      vr_index:= pr_tab_historicos.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo historico
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_historicos.EXISTS(vr_index) THEN  
                      
            --Popular dados na tabela memoria
            pr_tab_historicos(vr_index).cdhistor:= rw_craphis.cdhistor;
            pr_tab_historicos(vr_index).dshistor:= rw_craphis.dshistor;
                       
          END IF;  
          
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_historico;                             
  
  PROCEDURE pc_busca_historico_web(pr_cdhistor  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdtarhis  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhiscxa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisnet  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhistaa  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_cdhisblq  IN craphis.cdhistor%TYPE -- cd historico
                                  ,pr_dshistor  IN craphis.dshistor%TYPE -- descricao historico
                                  ,pr_flglanca  IN INTEGER --> flag se lancamento
                                  ,pr_inautori  IN INTEGER 
                                  ,pr_nrregist  IN INTEGER  --> Quantidade de registros                            
                                  ,pr_nriniseq  IN INTEGER  --> Qunatidade inicial
                                  ,pr_xmllog    IN VARCHAR2                --XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER            --Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2               --Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType      --Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2               --Nome do Campo
                                  ,pr_des_erro  OUT VARCHAR2)IS            --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico_web                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos para WEB, apenas chama a pc_busca_historico.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de historicos
    vr_tab_historicos typ_tab_historicos;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_cdhistor craphis.cdhistor%TYPE := 0;
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_historicos.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
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
                                
    --Pega o códito do histórico a ser utilizado
    IF pr_cdhistor > 0 THEN
      
      vr_cdhistor := pr_cdhistor;
      
    ELSIF pr_cdtarhis > 0 THEN
      
      vr_cdhistor := pr_cdtarhis;
      
    ELSIF pr_cdhiscxa > 0 THEN
      
      vr_cdhistor := pr_cdhiscxa;
      
    ELSIF pr_cdhisnet > 0 THEN
      
      vr_cdhistor := pr_cdhisnet;
      
    ELSIF pr_cdhistaa > 0 THEN
      
      vr_cdhistor := pr_cdhistaa;
      
    ELSIF pr_cdhisblq > 0 THEN
      
      vr_cdhistor := pr_cdhisblq;
      
    END IF;  
    
    pc_busca_historico(pr_cdcooper      => vr_cdcooper
                      ,pr_nrdcaixa      => vr_nrdcaixa
                      ,pr_cdagenci      => vr_cdagenci
                      ,pr_cdhistor      => vr_cdhistor
                      ,pr_dshistor      => pr_dshistor
                      ,pr_flglanca      => pr_flglanca
                      ,pr_inautori      => pr_inautori
                      ,pr_nrregist      => pr_nrregist
                      ,pr_nriniseq      => pr_nriniseq
                      ,pr_qtregist      => vr_qtregist
                      ,pr_nmdcampo      => pr_nmdcampo
                      ,pr_tab_historicos => vr_tab_historicos
                      ,pr_tab_erro       => vr_tab_erro
                      ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN       
       
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_web.';
        
      END IF;          
      
      --Levantar Excecao
      RAISE vr_exc_erro;  
            
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><historicos>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_historicos.FIRST;
        
    --Percorrer todos os historicos
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<historico>'||
                                                   '  <cdhistor>' || vr_tab_historicos(vr_index).cdhistor||'</cdhistor>'||
                                                   '  <dshistor>' || vr_tab_historicos(vr_index).dshistor||'</dshistor>'||                                                   
                                                   '</historico>'); 
            
      --Proximo Registro
      vr_index:= vr_tab_historicos.NEXT(vr_index); 
    
    END LOOP;
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</historicos></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'historicos'        --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
                                      
    --Retorno
    pr_des_erro:= 'OK'; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_historico_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_historico_web;                             
  
  PROCEDURE pc_busca_historico_car( pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa  
                                   ,pr_nrdcaixa IN INTEGER               --Código caixa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE --Código da agência
                                   ,pr_cdhistor IN craphis.cdhistor%TYPE --> cd historico
                                   ,pr_dshistor IN craphis.dshistor%TYPE --> ds historico
                                   ,pr_flglanca IN INTEGER --> flag se lancamento
                                   ,pr_inautori IN INTEGER -->                                    
                                   ,pr_nrregist IN INTEGER   --> Quantidade de registros                            
                                   ,pr_nriniseq IN INTEGER   --> Qunatidade inicial
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                   ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                   ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                   ,pr_dscritic OUT VARCHAR2)IS         --> Descricao Erro  
                                   
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_historico_car                            antiga: b1wgen0059\busca-historico
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Tiago Castro
    Data     : Dezembro/2015                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de historicos caracter, apenas chama a pc_busca_historico.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de bancos
    vr_tab_historicos typ_tab_historicos;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_historicos.DELETE;
    
    pc_busca_historico(pr_cdcooper      => pr_cdcooper
                      ,pr_nrdcaixa      => pr_nrdcaixa
                      ,pr_cdagenci      => pr_cdagenci
                      ,pr_cdhistor      => pr_cdhistor
                      ,pr_dshistor      => pr_dshistor
                      ,pr_flglanca      => pr_flglanca
                      ,pr_inautori      => pr_inautori
                      ,pr_nrregist      => pr_nrregist
                      ,pr_nriniseq      => pr_nriniseq
                      ,pr_qtregist      => vr_qtregist
                      ,pr_nmdcampo      => pr_nmdcampo
                      ,pr_tab_historicos => vr_tab_historicos
                      ,pr_tab_erro       => vr_tab_erro
                      ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_bancos_web.';
      END IF; 
               
      --Levantar Excecao
      RAISE vr_exc_erro; 
             
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeira regional
    vr_index:= vr_tab_historicos.FIRST;
        
    --Percorrer todos as regionais
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<historico>'||
                  '  <cdhistor>' || vr_tab_historicos(vr_index).cdhistor||'</cdhistor>'||
                  '  <dshistor>' || vr_tab_historicos(vr_index).dshistor||'</dshistor>'||                    
                  '</historico>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_historicos.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
    --Retorno
    pr_des_erro:= 'OK';         

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;                  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      pr_cdcritic:= 0;
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na pc_busca_historico_car --> '|| SQLERRM;
      
  END pc_busca_historico_car; 
    
  PROCEDURE pc_busca_banco_caixa(pr_cdcooper IN crapcop.cdcooper%TYPE     -- Cooperativa 
                                ,pr_nrdcaixa IN INTEGER                   -- Código caixa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE     -- Código da agência
                                ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE     -- Código do banco
                                ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE     -- Nome do banco
                                ,pr_nrregist IN INTEGER                   -- Número de registros
                                ,pr_nriniseq IN INTEGER                   -- Quantidade inicial
                                ,pr_qtregist OUT INTEGER                  -- Quantidade total de registros
                                ,pr_nmdcampo OUT VARCHAR2                 -- Nome do campo com erro
                                ,pr_tab_banco_caixa OUT typ_tab_banco_caixa -- Tabela banco caixa
                                ,pr_tab_erro OUT gene0001.typ_tab_erro    -- Tabela Erros
                                ,pr_des_erro OUT VARCHAR2)IS              -- Tabela de erros 
  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa                            
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
  CURSOR cr_crapbcl(pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE
                   ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE) IS
  SELECT crapbcl.cdbccxlt
        ,crapbcl.nmextbcc
    FROM crapbcl 
   WHERE crapbcl.cdbccxlt = decode(nvl(pr_cdbccxlt,0),0,crapbcl.cdbccxlt,pr_cdbccxlt)
    AND (TRIM(pr_nmextbcc) IS NULL
     OR upper(crapbcl.nmextbcc) LIKE '%'|| upper(pr_nmextbcc) ||'%')
   ORDER BY crapbcl.cdbccxlt;
      
  vr_nrregist INTEGER := pr_nrregist;
  
  --Variaveis de Criticas
  vr_exc_erro EXCEPTION;
  
  vr_index PLS_INTEGER;

  BEGIN
    
    --Limpar tabelas auxiliares
    pr_tab_banco_caixa.DELETE;  
    
    FOR rw_crapbcl IN cr_crapbcl(pr_cdbccxlt => pr_cdbccxlt
                                ,pr_nmextbcc => pr_nmextbcc) LOOP      
      
      --Indice para a temp-table
      vr_index:= pr_tab_banco_caixa.COUNT + 1;
      pr_qtregist := nvl(pr_qtregist,0) + 1;
      
      /* controles da paginacao */
      IF (pr_qtregist < pr_nriniseq) OR
         (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
         --Proximo registro
          CONTINUE;
      END IF; 
      
      --Numero Registros
      IF vr_nrregist > 0 THEN 
        
        --Verificar se já existe na temp-table                             
        IF NOT pr_tab_banco_caixa.EXISTS(vr_index) THEN   
                     
            --Popular dados na tabela memoria
            pr_tab_banco_caixa(vr_index).cdbccxlt:= rw_crapbcl.cdbccxlt;
            pr_tab_banco_caixa(vr_index).nmextbcc:= rw_crapbcl.nmextbcc;
                       
          END IF;  
      END IF;
      
      --Diminuir registros
      vr_nrregist:= nvl(vr_nrregist,0) - 1; 
      
    END LOOP;
    
    --Retorno OK
    pr_des_erro:= 'OK';  
  
  END pc_busca_banco_caixa;                             
  
  PROCEDURE pc_busca_banco_caixa_web(pr_cdbccxlt  IN crapbcl.cdbccxlt%TYPE -- Código do banco
                                    ,pr_nmextbcc  IN crapbcl.nmextbcc%TYPE -- Nome do Banco
                                    ,pr_nmbcolot  IN crapban.nmextbcc%TYPE
                                    ,pr_nrregist  IN INTEGER               -- Quantidade de registros                            
                                    ,pr_nriniseq  IN INTEGER               -- Qunatidade inicial
                                    ,pr_xmllog    IN VARCHAR2              --XML com informações de LOG
                                    ,pr_cdcritic  OUT PLS_INTEGER          --Código da crítica
                                    ,pr_dscritic  OUT VARCHAR2             --Descrição da crítica
                                    ,pr_retxml    IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                    ,pr_nmdcampo  OUT VARCHAR2             --Nome do Campo
                                    ,pr_des_erro  OUT VARCHAR2)IS          --Saida OK/NOK
                                  
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa_web                          
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa para WEB, apenas chama a pc_busca_banco_caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
   --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de historicos
    vr_tab_banco_caixa typ_tab_banco_caixa;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Locais
    vr_qtregist INTEGER := 0;   
    vr_clob     CLOB;   
    vr_xml_temp VARCHAR2(32726) := ''; 
    vr_nmextbcc crapbcl.nmextbcc%TYPE;
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      
  
  
  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_banco_caixa.DELETE;
      
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
      
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
    
    --Pega o nome do banco a ser pesquisado
    IF trim(pr_nmextbcc) IS NOT NULL THEN
        
      vr_nmextbcc := pr_nmextbcc;
        
    ELSIF trim(pr_nmbcolot) IS NOT NULL THEN
        
      vr_nmextbcc := pr_nmbcolot;
        
    END IF;
      
    pc_busca_banco_caixa(pr_cdcooper      => vr_cdcooper
                        ,pr_nrdcaixa      => vr_nrdcaixa
                        ,pr_cdagenci      => vr_cdagenci
                        ,pr_cdbccxlt      => pr_cdbccxlt
                        ,pr_nmextbcc      => vr_nmextbcc
                        ,pr_nrregist      => pr_nrregist
                        ,pr_nriniseq      => pr_nriniseq
                        ,pr_qtregist      => vr_qtregist
                        ,pr_nmdcampo      => pr_nmdcampo
                        ,pr_tab_banco_caixa => vr_tab_banco_caixa
                        ,pr_tab_erro       => vr_tab_erro
                        ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN  
            
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_banco_caixa.';
      END IF;      
          
      --Levantar Excecao
      RAISE vr_exc_erro;   
           
    END IF;
    
    -- Monta documento XML de ERRO
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);                                          
      
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><bancoCaixa>');
      
    --Buscar Primeiro registro
    vr_index:= vr_tab_banco_caixa.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      
      -- Carrega os dados           
      gene0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<banco>'||
                                                   '  <cdbccxlt>' || vr_tab_banco_caixa(vr_index).cdbccxlt||'</cdbccxlt>'||
                                                   '  <nmextbcc>' || vr_tab_banco_caixa(vr_index).nmextbcc||'</nmextbcc>'||                                                   
                                                   '</banco>'); 
            
      --Proximo Registro
      vr_index:= vr_tab_banco_caixa.NEXT(vr_index); 
    
    END LOOP;
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</bancoCaixa></Root>'
                           ,pr_fecha_xml      => TRUE);
                  
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Insere atributo na tag banco com a quantidade de registros
    gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                             ,pr_tag   => 'bancoCaixa'        --> Nome da TAG XML
                             ,pr_atrib => 'qtregist'          --> Nome do atributo
                             ,pr_atval => vr_qtregist         --> Valor do atributo
                             ,pr_numva => 0                   --> Número da localização da TAG na árvore XML
                             ,pr_des_erro => vr_dscritic);    --> Descrição de erros
                             
    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);  
                                   
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
                                      
    --Retorno
    pr_des_erro:= 'OK'; 
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                                                            
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_busca_banco_caixa_web --> '|| SQLERRM;
        
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
  
  END pc_busca_banco_caixa_web;                             
  
  PROCEDURE pc_busca_banco_caixa_car( pr_cdcooper IN crapcop.cdcooper%type --> Codigo Cooperativa  
                                     ,pr_nrdcaixa IN INTEGER               --> Código caixa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE --> Código da agência
                                     ,pr_cdbccxlt IN crapbcl.cdbccxlt%TYPE --> Código do banco
                                     ,pr_nmextbcc IN crapbcl.nmextbcc%TYPE --> Nome do banco
                                     ,pr_nrregist IN INTEGER               --> Quantidade de registros                            
                                     ,pr_nriniseq IN INTEGER               --> Qunatidade inicial
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                     ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                     ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                     ,pr_dscritic OUT VARCHAR2)IS          --> Descricao Erro  
                                   
  /*---------------------------------------------------------------------------------------------------------------
    
    Programa : pc_busca_banco_caixa_car                          
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonathan
    Data     : Marco/2016                           Ultima atualizacao:
    
    Dados referentes ao programa:
    
    Frequencia: -----
    Objetivo   : Pesquisa de banco caixa caracter, apenas chama a pc_busca_banco_caixa.
    
    Alterações : 
    -------------------------------------------------------------------------------------------------------------*/                                    
  
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Tabela de bancos
    vr_tab_banco_caixa typ_tab_banco_caixa;
    
    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
            
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;      

  BEGIN
    --limpar tabela erros
    vr_tab_erro.DELETE;
      
    --Limpar tabela dados
    vr_tab_banco_caixa.DELETE;
    
    pc_busca_banco_caixa(pr_cdcooper      => pr_cdcooper
                        ,pr_nrdcaixa      => pr_nrdcaixa
                        ,pr_cdagenci      => pr_cdagenci
                        ,pr_cdbccxlt      => pr_cdbccxlt
                        ,pr_nmextbcc      => pr_nmextbcc
                        ,pr_nrregist      => pr_nrregist
                        ,pr_nriniseq      => pr_nriniseq
                        ,pr_qtregist      => vr_qtregist
                        ,pr_nmdcampo      => pr_nmdcampo
                        ,pr_tab_banco_caixa => vr_tab_banco_caixa
                        ,pr_tab_erro       => vr_tab_erro
                        ,pr_des_erro       => vr_des_reto);
                      
    --Se Ocorreu erro
    IF vr_des_reto <> 'OK' THEN   
           
      --Se possuir erro na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        
        --Mensagem Erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        
      ELSE  
        --Mensagem Erro
        vr_dscritic:= 'Erro na pc_busca_banco_caixa.';
      END IF;      
          
      --Levantar Excecao
      RAISE vr_exc_erro;
              
    END IF;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_clob_ret, TRUE);
    dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

    -- Insere o cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

    --Buscar Primeiro registro
    vr_index:= vr_tab_banco_caixa.FIRST;
        
    --Percorrer todos os registros
    WHILE vr_index IS NOT NULL LOOP
      vr_string:= '<bancoCaixa>'||
                  '  <cdbccxlt>' || vr_tab_banco_caixa(vr_index).cdbccxlt||'</cdbccxlt>'||
                  '  <nmextbcc>' || vr_tab_banco_caixa(vr_index).nmextbcc||'</nmextbcc>'||                    
                  '</bancoCaixa>';

       -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                             ,pr_texto_completo => vr_dstexto
                             ,pr_texto_novo     => vr_string
                             ,pr_fecha_xml      => FALSE);

      --Proximo Registro
      vr_index:= vr_tab_banco_caixa.NEXT(vr_index);
      
    END LOOP;     
    
    -- Encerrar a tag raiz
    gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                           ,pr_texto_completo => vr_dstexto
                           ,pr_texto_novo     => '</root>'
                           ,pr_fecha_xml      => TRUE);
                                                                                                                   
    --Retorno
    pr_des_erro:= 'OK';         

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
        
      --Erro
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;                  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
        
      pr_cdcritic:= 0;
      -- Chamar rotina de gravação de erro
      pr_dscritic:= 'Erro na pc_busca_banco_caixa_car --> '|| SQLERRM;
      
  END pc_busca_banco_caixa_car; 

END ZOOM0001;
/
