CREATE OR REPLACE PACKAGE CECRED.RREG0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : RREG0001
  --  Sistema  : Rotinas genericas referente a CADREG
  --  Sigla    : RREG
  --  Autor    : Jéssica Laverde Gracino (DB1)
  --  Data     : Agosto - 2015.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a CADREG

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  --Tipo de Registros de bancos  /*antiga tt-crapreg da BO 0086*/
  TYPE typ_reg_crapreg IS RECORD
    (nmoperad crapope.nmoperad%TYPE 
    ,dsoperad VARCHAR2(500)
    ,cddsregi VARCHAR2(500)
    ,dsdemail crapreg.dsdemail%TYPE
    ,dsdregio crapreg.dsdregio%TYPE
    ,cdopereg crapreg.cdopereg%TYPE
    ,cddregio crapreg.cddregio%TYPE
    ,cdcooper crapreg.cdcooper%TYPE);
    
  --Tipo de Tabela de bancos
  TYPE typ_tab_crapreg IS TABLE OF typ_reg_crapreg INDEX BY PLS_INTEGER;

  /* Tabela para guardar os operadores */
  TYPE typ_operadores IS RECORD 
    (cdcooper crapope.cdcooper%TYPE
    ,cdoperad crapope.cdoperad%TYPE
    ,nmoperad crapope.nmoperad%TYPE
    ,cdagenci crapope.cdagenci%TYPE
    ,vlpagchq crapope.vlpagchq%TYPE);
    
  --Tabela para guardar os operadores  
  TYPE typ_tab_operadores IS TABLE OF typ_operadores INDEX BY PLS_INTEGER;
  
  /* Rotina referente a consulta de regionais Modo Web */
  PROCEDURE pc_busca_crapreg_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                ,pr_flgerlog IN INTEGER               -->flag log                           
                                ,pr_nriniseq IN INTEGER               -->Quantidade inicial
                                ,pr_nrregist IN INTEGER               -->Quantidade registros
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                ,pr_dscritic OUT VARCHAR2);           --> Descricao Erro

  /* Rotina referente a consulta de regionais Modo Web */
  PROCEDURE pc_busca_crapreg_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL           -->Data Movimento
                                ,pr_cddopcao IN VARCHAR2 DEFAULT NULL           -->Codigo da opcao
                                ,pr_flgerlog IN INTEGER                         -->flag log 
                                ,pr_nriniseq IN INTEGER                         -->Quantidade inicial
                                ,pr_nrregist IN INTEGER                         -->Quantidade de registros 
                                ,pr_xmllog   IN VARCHAR2 DEFAULT NULL           -->XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    -->Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       -->Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              -->Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       -->Nome do Campo
                                ,pr_des_erro OUT VARCHAR2);                     -->Saida OK/NOK

  /* Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG Modo Caracter */
  PROCEDURE pc_grava_regional_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa                      
                                 ,pr_cdagenci IN INTEGER DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN INTEGER DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                 ,pr_cdoperad IN VARCHAR2 DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                 ,pr_cddregio IN INTEGER               -->Codigo da Regional
                                 ,pr_dsdregio IN VARCHAR2 DEFAULT NULL -->Descrição da Regional
                                 ,pr_cdopereg IN VARCHAR2 DEFAULT NULL -->Codigo do operador da regional
                                 ,pr_dsdemail IN VARCHAR2 DEFAULT NULL -->Email
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento 
                                 ,pr_flgerlog IN INTEGER               -->flag log     
                                 ,pr_cddopcao IN VARCHAR2              -->Opcao da tela
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2);           --Descricao Erro 

  /* Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG Modo Web */
  PROCEDURE pc_grava_regional_web(pr_dsdregio IN VARCHAR2 DEFAULT NULL -->Descrição da Regional
                                 ,pr_cdopereg IN VARCHAR2 DEFAULT NULL -->Codigo do operador da regional
                                 ,pr_dsdemail IN VARCHAR2 DEFAULT NULL -->Email
                                 ,pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                                 ,pr_flgerlog IN INTEGER               -->flag log     
                                 ,pr_cddopcao IN VARCHAR2
                                 ,pr_cddregio IN INTEGER  -->Codigo da Regional
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);                     -->Saida OK/NOK

  /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
  PROCEDURE pc_busca_proxima_sequencia_web(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER        -->Código da crítica
                                          ,pr_dscritic OUT VARCHAR2           -->Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType  -->Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2           -->Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2);         -->Saida OK/NOK                                  
                                          
  /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
  PROCEDURE pc_busca_proxima_sequencia_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE -->Codigo agencia
                                          ,pr_nrdcaixa IN INTEGER               -->Código caixa
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE -->Operador
                                          ,pr_nmdatela IN VARCHAR2              -->Nome da tela
                                          ,pr_idorigem IN INTEGER               -->Origem
                                          ,pr_cddregio OUT crapreg.cddregio%TYPE-->Sequencial da regional
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2);         --> Descricao Erro                                          
                                   
END RREG0001;
/

CREATE OR REPLACE PACKAGE BODY CECRED.RREG0001 AS

/*---------------------------------------------------------------------------------------------------------------
   Programa: RREG0001
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED

   Autor   : Jéssica Laverde Gracino (DB1)
   Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

   Dados referentes ao programa:

   Frequencia: 
   Objetivo  : Consulta, Inclusão e Alteração de Regionais para PA's.

   Alteracoes: 16/11/2015 - Ajustes na comparacao do campo cdoperad da
                            tabela crapope para usar upper (Tiago SD339476)
                            
               27/11/2015 - Ajuste em todas as rotinas decorrente a homologação
                            de conversão realizada pela DB1
                            (Adriano).
                                         
  ---------------------------------------------------------------------------------------------------------------*/

  /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
  PROCEDURE pc_busca_proxima_sequencia(pr_cdcooper IN crapcop.cdcooper%TYPE  -->Cooperativa
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Agencia
                                      ,pr_nrdcaixa IN INTEGER                --> Caixa
                                      ,pr_cddregio OUT crapreg.cddregio%TYPE -->Sequencial da regional
                                      ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro 
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                      ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
  /* .............................................................................
     Programa: pc_busca_proxima_sequencia
     Autor   : Adriano Marchi (CECRED)
     Data    : 27/11/2015                     Ultima atualizacao: 

     Dados referentes ao programa:

     Objetivo  : Buscar a proxima sequencia para Inclusao na tela CADREG.

     Alteracoes : 
     
    .................................................................................... */
    CURSOR cr_crapreg(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cddregio
      FROM crapreg
     WHERE crapreg.cdcooper = pr_cdcooper
       AND crapreg.cddregio <> 999;
    rw_crapreg cr_crapreg%ROWTYPE;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;
    vr_retornvl  VARCHAR2(3):= 'NOK';
    
    vr_dscritic VARCHAR2(4000);

    BEGIN
      OPEN cr_crapreg(pr_cdcooper => pr_cdcooper); 
      
      FETCH cr_crapreg INTO rw_crapreg;
      
      IF cr_crapreg%FOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapreg;
 
        SELECT MAX(crapreg.cddregio) + 1
          INTO pr_cddregio FROM crapreg 
         WHERE crapreg.cdcooper = pr_cdcooper
           AND crapreg.cddregio <> 999;

      ELSE
        --Fechar o cursor
        CLOSE cr_crapreg;
        pr_cddregio := 1;
      END IF;

      -- Retorno  OK
      pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;
        
        --Monta mensagem de critica
        vr_dscritic := 'Nao foi encontrar o sequencial da regional.';

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na RREG0001.pc_busca_proxima_sequencia --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    
  END pc_busca_proxima_sequencia;
  
  /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
  PROCEDURE pc_busca_proxima_sequencia_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                          ,pr_cdagenci IN crapage.cdagenci%TYPE -->Codigo agencia
                                          ,pr_nrdcaixa IN INTEGER               -->Código caixa
                                          ,pr_cdoperad IN crapope.cdoperad%TYPE -->Operador
                                          ,pr_nmdatela IN VARCHAR2              -->Nome da tela
                                          ,pr_idorigem IN INTEGER               -->Origem
                                          ,pr_cddregio OUT crapreg.cddregio%TYPE-->Sequencial da regional
                                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                          ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                          ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                          ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_proxima_sequencia_car                Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Adriano Marchi (CECRED)
    Data    : 27/11/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Buscar a proxima sequencia para Inclusao na tela CADREG.

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_crapreg RREG0001.typ_tab_crapreg;

    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_crapreg.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
                                                                
      --Busca proximo sequencial da regional       
      pc_busca_proxima_sequencia(pr_cdcooper => pr_cdcooper  -->Cooperativa
                                ,pr_cdagenci => pr_cdagenci  --> Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --> Caixa
                                ,pr_cddregio => pr_cddregio  --> Sequencial da regional
                                ,pr_nmdcampo => pr_nmdcampo  -->Nome do Campo                                
                                ,pr_tab_erro => vr_tab_erro  -->Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK
                                      
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a RREG0001.pc_busca_proxima_sequencia_car.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;           
                                                                                                                   
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
        pr_dscritic:= 'Erro na RREG0001.pc_busca_proxima_sequencia_car --> '|| SQLERRM;

  END pc_busca_proxima_sequencia_car;

  /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
  PROCEDURE pc_busca_proxima_sequencia_web(pr_xmllog   IN VARCHAR2            --> XML com informações de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER        -->Código da crítica
                                          ,pr_dscritic OUT VARCHAR2           -->Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType  -->Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2           -->Nome do Campo
                                          ,pr_des_erro OUT VARCHAR2) IS       -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_proxima_sequencia_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Adriano Marchi (CECRED)
    Data    : 27/11/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Buscar a proxima sequencia para Inclusao na tela CADREG.

    Alteracoes: 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    --Tabela de contratos
    vr_tab_crapreg RREG0001.typ_tab_crapreg;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis auxiliares
    vr_cddregio crapreg.cddregio%TYPE := 0;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_crapreg.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
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
      
      --Busca proximo sequencial da regional       
      pc_busca_proxima_sequencia(pr_cdcooper => vr_cdcooper  -->Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --> Agencia
                                ,pr_nrdcaixa => vr_nrdcaixa  --> Caixa
                                ,pr_cddregio => vr_cddregio  --> Sequencial da regional
                                ,pr_nmdcampo => pr_nmdcampo  -->Nome do Campo
                                ,pr_tab_erro => vr_tab_erro  -->Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK
            
      --Se Ocorreu erro
      IF vr_des_reto <> 'OK'     OR 
         NVL(vr_cddregio,0)  = 0 THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na RREG0001.pc_busca_proxima_sequencia_web.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados cddregio="' || vr_cddregio || '"/>');

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
        pr_dscritic:= 'Erro na RREG0001.pc_busca_proxima_sequencia_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_proxima_sequencia_web;

  /* Trazer o cadastro de Regionais para PACs.*/
  PROCEDURE pc_busca_crapreg(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                            ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                            ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                            ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                            ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                            ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                            ,pr_flgerlog IN INTEGER      -->flag log  
                            ,pr_nriniseq IN INTEGER      -->Quantidade inicial
                            ,pr_nrregist IN INTEGER      -->Quantidade de registros
                            ,pr_qtregist OUT INTEGER     -->Quantidade total de registros
                            ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                            ,pr_tab_crapreg OUT RREG0001.typ_tab_crapreg --Tabela regionais
                            ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                            ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_busca_crapreg       Antiga: consulta da b1wgen0086.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Trazer o cadastro de Regionais para PACs.

     Alteracoes: 20/08/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
                 
                 27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                              (Adriano). 
                              
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor sobre a tabela de regionais
    CURSOR cr_crapreg (pr_cdcooper IN crapreg.cdcooper%TYPE) IS
    SELECT cddregio
          ,dsdregio
          ,cdopereg
          ,cdcooper
          ,dsdemail
      FROM crapreg
     WHERE crapreg.cdcooper = pr_cdcooper;
    rw_crapreg cr_crapreg%ROWTYPE;

    -- Cursor para seleciona operador
    CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%TYPE,
                       pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT nmoperad
          ,cdoperad
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND upper(crapope.cdoperad) = upper(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;

    ------------------------------- VARIAVEIS ---------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    
    vr_retornvl  VARCHAR2(3):= 'NOK';
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    --Variaveis auxiliares
    vr_nrregist INTEGER;

    --Variaveis de Indice
    vr_index PLS_INTEGER;

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;
      vr_index := 0;
      vr_nrregist := pr_nrregist;
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      --Leitura no cadastro de regionais
      FOR rw_crapreg IN cr_crapreg(pr_cdcooper) LOOP

        --Incrementar contador
        pr_qtregist:= nvl(pr_qtregist,0) + 1;
        
        -- controles da paginacao 
        IF (pr_qtregist < pr_nriniseq) OR
           (pr_qtregist > (pr_nriniseq + pr_nrregist)) THEN
          
          --Proximo
          CONTINUE;  
          
        END IF; 
        
        IF vr_nrregist >= 1 THEN  
          
          -- Verifica se o operador esta cadastrada
          OPEN cr_crapope (pr_cdcooper => rw_crapreg.cdcooper,
                           pr_cdoperad => rw_crapreg.cdopereg);

          FETCH cr_crapope INTO rw_crapope; 

          vr_index := vr_index + 1;

          pr_tab_crapreg(vr_index).cddsregi := TO_CHAR(rw_crapreg.cddregio) || ' - ' || rw_crapreg.dsdregio;
          pr_tab_crapreg(vr_index).dsdemail := rw_crapreg.dsdemail;
          pr_tab_crapreg(vr_index).dsdregio := rw_crapreg.dsdregio; 
          pr_tab_crapreg(vr_index).cdopereg := rw_crapreg.cdopereg;   
          pr_tab_crapreg(vr_index).cddregio := rw_crapreg.cddregio; 
          pr_tab_crapreg(vr_index).cdcooper := rw_crapreg.cdcooper;                                       

          -- Se encontrar
          IF cr_crapope%FOUND THEN

            -- Fechar o cursor
            CLOSE cr_crapope;
            pr_tab_crapreg(vr_index).nmoperad := rw_crapope.nmoperad;
            pr_tab_crapreg(vr_index).dsoperad := rw_crapreg.cdopereg || ' - ' || rw_crapope.nmoperad;
            
          ELSE
            -- fechar o cursor
            CLOSE cr_crapope;

            pr_tab_crapreg(vr_index).nmoperad := 'NAO CADASTRADO';
            
            IF NVL(rw_crapreg.cdopereg,' ') <> ' ' THEN

              pr_tab_crapreg(vr_index).dsoperad := rw_crapreg.cdopereg || ' - NAO CADASTRADO';
              
            ELSE
              pr_tab_crapreg(vr_index).dsoperad := 'NAO CADASTRADO';
            END IF;

          END IF; 
          
        END IF;
        
        --Diminuir registros
        vr_nrregist:= nvl(vr_nrregist,0) - 1;
                
      END LOOP;
       
      -- Retorno  OK
      pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

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
        vr_dscritic := 'Erro na RREG0001.pc_busca_crapreg --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_busca_crapreg;
  
  /* Trazer o cadastro de Regionais para PACs Modo Caracter */
  PROCEDURE pc_busca_crapreg_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento                                 
                                ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                ,pr_flgerlog IN INTEGER  -->flag log                           
                                ,pr_nriniseq IN INTEGER  -->Quantidade inicial
                                ,pr_nrregist IN INTEGER  -->Quantidade registros
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do Campo
                                ,pr_des_erro OUT VARCHAR2             --> Saida OK/NOK
                                ,pr_clob_ret OUT CLOB                 --> Tabela clob                                 
                                ,pr_cdcritic OUT PLS_INTEGER          --> Codigo Erro
                                ,pr_dscritic OUT VARCHAR2) IS         --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_crapreg_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Trazer o cadastro de Regionais para PACs Modo Caracter

    Alteracoes: 20/08/2015 - Desenvolvimento - Jéssica (DB1)
                 
                27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                             (Adriano). 
                              
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_crapreg RREG0001.typ_tab_crapreg;
    
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
      vr_tab_crapreg.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
                                                                
      --Consultar Regionais Cadastradas
      RREG0001.pc_busca_crapreg(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa	
                               ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                               ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                               ,pr_idorigem => pr_idorigem  --Origem Processamento
                               ,pr_cdoperad => pr_cdoperad  --Operador
                               ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                               ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento  
                               ,pr_flgerlog => pr_flgerlog  --flag log        
                               ,pr_nriniseq => pr_nriniseq  --Quantidade inicial
                               ,pr_nrregist => pr_nrregist  --Quantidade registros
                               ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                               ,pr_qtregist => vr_qtregist  --Quantidade total de registros
                               ,pr_tab_crapreg => vr_tab_crapreg --Tabela Regionais
                               ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                               ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a RREG0001.pc_busca_crapreg_car.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;           
                                                    
      --Montar CLOB
      IF vr_tab_crapreg.COUNT > 0 THEN

        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE);
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root qtregist="'|| vr_qtregist || '">');

        --Buscar Primeira regional
        vr_index:= vr_tab_crapreg.FIRST;

        --Percorrer todos as regionais
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<regi>'||
                        '<cdcooper>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).cdcooper),'0')|| '</cdcooper>'||
                        '<cddregio>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).cddregio),'0')|| '</cddregio>'||
                        '<cddsregi>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).cddsregi),' ')|| '</cddsregi>'||
                        '<dsoperad>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).dsoperad),' ')|| '</dsoperad>'||
                        '<dsdregio>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).dsdregio),' ')|| '</dsdregio>'||
                        '<cdopereg>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).cdopereg),' ')|| '</cdopereg>'||
                        '<nmoperad>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).nmoperad),' ')|| '</nmoperad>'||
                        '<dsdemail>'||NVL(TO_CHAR(vr_tab_crapreg(vr_index).dsdemail),' ')|| '</dsdemail>'||
                      '</regi>';

           -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                                 ,pr_texto_completo => vr_dstexto
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);

          --Proximo Registro
          vr_index:= vr_tab_crapreg.NEXT(vr_index);

        END LOOP;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret
                               ,pr_texto_completo => vr_dstexto
                               ,pr_texto_novo     => '</root>'
                               ,pr_fecha_xml      => TRUE);

      END IF;
                                                                                                                   
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
        pr_dscritic:= 'Erro na RREG0001.pc_busca_crapreg_car --> '|| SQLERRM;

  END pc_busca_crapreg_car;

  /* Trazer o cadastro de Regionais para PACs Modo Caracter Modo Web */
  PROCEDURE pc_busca_crapreg_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL           -->Data Movimento
                                ,pr_cddopcao IN VARCHAR2 DEFAULT NULL           -->Codigo da opcao
                                ,pr_flgerlog IN INTEGER                         -->flag log 
                                ,pr_nriniseq IN INTEGER                         -->Quantidade inicial
                                ,pr_nrregist IN INTEGER                         -->Quantidade de registros 
                                ,pr_xmllog   IN VARCHAR2 DEFAULT NULL           -->XML com informações de LOG
                                ,pr_cdcritic OUT PLS_INTEGER                    -->Código da crítica
                                ,pr_dscritic OUT VARCHAR2                       -->Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType              -->Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2                       -->Nome do Campo
                                ,pr_des_erro OUT VARCHAR2) IS                   -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_crapreg_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Trazer o cadastro de Regionais para PACs Modo Caracter modo Web

    Alteracoes: 27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                            (Adriano). 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    --Tabela de contratos
    vr_tab_crapreg RREG0001.typ_tab_crapreg;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
       
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    vr_auxconta PLS_INTEGER:= 0;
    
    --Variaveis auxiliares
    vr_qtregist INTEGER := 0;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_crapreg.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
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
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/RRRR'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
            
      --Consultar Regionais Cadastradas
      RREG0001.pc_busca_crapreg(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                               ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                               ,pr_idorigem => vr_idorigem  --Origem Processamento
                               ,pr_cdoperad => vr_cdoperad  --Operador
                               ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                               ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento
                               ,pr_flgerlog => pr_flgerlog  --flag log 
                               ,pr_nriniseq => pr_nriniseq  --Quantidade inicial
                               ,pr_nrregist => pr_nrregist  --Quantidade registros
                               ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                               ,pr_qtregist => vr_qtregist  --Quantidade total de registros
                               ,pr_tab_crapreg => vr_tab_crapreg --Tabela Regionais
                               ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                               ,pr_des_erro => vr_des_reto); --Saida OK/NOK   

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na RREG0001.pc_busca_crapreg_web.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 

      --Montar CLOB
      IF vr_tab_crapreg.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Buscar Primeira regional
        vr_index:= vr_tab_crapreg.FIRST;

        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de regionais
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmoperad', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).nmoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsoperad', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).dsoperad), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cddsregi', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).cddsregi), pr_des_erro => vr_dscritic);
  				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdemail', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).dsdemail), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdregio', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).dsdregio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cddregio', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).cddregio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdopereg', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).cdopereg), pr_des_erro => vr_dscritic);
                    
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_crapreg.NEXT(vr_index);

        END LOOP;

      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
      END IF;                                 
      
      -- Insere atributo na tag Dados com a quantidade de registros
      gene0007.pc_gera_atributo(pr_xml   => pr_retxml           --> XML que irá receber o novo atributo
                               ,pr_tag   => 'Dados'             --> Nome da TAG XML
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
        pr_dscritic:= 'Erro na RREG0001.pc_busca_crapreg_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_crapreg_web;

  /* Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG */
  PROCEDURE pc_grava_regional(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa
                             ,pr_cdagenci IN INTEGER DEFAULT NULL -->Codigo Agencia
                             ,pr_nrdcaixa IN INTEGER DEFAULT NULL -->Numero Caixa
                             ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                             ,pr_cdoperad IN VARCHAR2 DEFAULT NULL -->Operador
                             ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                             
                             ,pr_cddregio IN INTEGER               -->Codigo da Regional   
                             ,pr_dsdregio IN VARCHAR2 DEFAULT NULL -->Descrição da Regional
                             ,pr_cdopereg IN VARCHAR2 DEFAULT NULL -->Codigo do operador da regional
                             ,pr_dsdemail IN VARCHAR2 DEFAULT NULL -->Email
                             ,pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                             ,pr_flgerlog IN INTEGER               -->flag log     
                             ,pr_cddopcao IN VARCHAR2              -->Opcao da tela               
                             ,pr_nmdcampo OUT VARCHAR2              -->Nome do campo com erro                                                                            
                             ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                             ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_grava_regional       Antiga: grava-regional da b1wgen0086.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015 

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG

     Alteracoes: 27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                             (Adriano). 
                             
    ---------------------------------------------------------------------------------------------------------------*/

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor sobre a tabela de regionais
    CURSOR cr_crapreg (pr_cdcooper IN crapreg.cdcooper%TYPE,
                       pr_cddregio IN crapreg.cddregio%TYPE) IS
    SELECT cddregio
          ,dsdregio
          ,cdopereg
          ,cdcooper
          ,dsdemail       
      FROM crapreg
     WHERE crapreg.cdcooper = pr_cdcooper
       AND crapreg.cddregio = pr_cddregio
       FOR UPDATE NOWAIT;
    rw_crapreg cr_crapreg%ROWTYPE;
    
    --Cursor para encontrar o operador
    CURSOR cr_crapope(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
    SELECT cdcooper
          ,cdoperad
          ,nmoperad
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;
      
    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;
    vr_tab_erro gene0001.typ_tab_erro;

    ------------------------------- VARIAVEIS ---------------------------------

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    vr_retornvl VARCHAR2(3):= 'NOK';

    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    vr_dsdregio VARCHAR2(500);
    vr_cdopereg VARCHAR2(500);
    vr_dsdemail VARCHAR2(500);
    vr_cddregio INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;
    vr_exc_erro  EXCEPTION;
    vr_exc_saida EXCEPTION;

    -- Variável exceção para locke
    vr_exc_locked EXCEPTION;
    PRAGMA EXCEPTION_INIT(vr_exc_locked, -54);

    --> Tabela de retorno do operadores que estao alocando a tabela especifidada
    vr_tab_locktab GENE0001.typ_tab_locktab;

    BEGIN

      --Inicializar Variaveis
      vr_cdcritic := 0;
      vr_dscritic := NULL;  
      vr_index := 0;    
                  
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

       RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
           
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
        
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
            
      IF TRIM(pr_dsdregio) IS NULL THEN

        -- Montar mensagem de critica
        vr_cdcritic := 375;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);

        pr_nmdcampo:= 'dsdregio';

        RAISE vr_exc_erro;

      END IF;

      OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                     ,pr_cdoperad => pr_cdopereg);
      
      FETCH cr_crapope INTO rw_crapope;

      --Se não encontrou o operador
      IF cr_crapope%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapope;

        -- Montar mensagem de critica
        vr_cdcritic := 0;
        -- Busca critica
        vr_dscritic:= '067 - Operador nao cadastrado.';

        pr_nmdcampo:= 'cdoperad';

        RAISE vr_exc_erro;
        
      ELSE
         --Fecha o cursor
        CLOSE cr_crapope;
        
      END IF;
      
      /* Tratamento para buscar registro crapreg se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1..100 LOOP
        BEGIN
          -- Busca regional
          OPEN cr_crapreg(pr_cdcooper => pr_cdcooper,
                          pr_cddregio => pr_cddregio);
                      
          FETCH cr_crapreg INTO rw_crapreg;  
          
          vr_dscritic := NULL;
          
          EXIT;
          
        EXCEPTION
          WHEN vr_exc_locked THEN
            gene0001.pc_ver_lock(pr_nmtabela    => 'CRAPREG'
                                ,pr_nrdrecid    => ''
                                ,pr_des_reto    => vr_des_reto
                                ,pt_tab_locktab => vr_tab_locktab);
                                
            IF vr_des_reto = 'OK' THEN
              FOR VR_IND IN 1..vr_tab_locktab.COUNT LOOP
                vr_dscritic := 'Registro sendo alterado em outro terminal (CRAPREG)' || 
                               ' - ' || vr_tab_locktab(VR_IND).nmusuari;
              END LOOP;
            END IF;
            
          WHEN OTHERS THEN
             IF cr_crapreg%ISOPEN THEN
               CLOSE cr_crapreg;
             END IF;

             -- setar critica caso for o ultimo
             IF i = 100 THEN
               vr_dscritic:= vr_dscritic||'Registro da regional '||pr_cddregio||' em uso. Tente novamente.';
             END IF;
             -- aguardar 0,5 seg. antes de tentar novamente
             sys.dbms_lock.sleep(0.1);
        END;
        
      END LOOP;

      -- se encontrou erro ao buscar regional, abortar programa
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;        
      END IF;

      IF cr_crapreg%NOTFOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapreg; 
        
        --Se for inclusao de uma nova regional
        IF pr_cddopcao = 'I' THEN

          /*Buscar a proxima sequencia para Inclusao na tela CADREG.*/
          pc_busca_proxima_sequencia(pr_cdcooper => pr_cdcooper  -->Cooperativa
                                    ,pr_cdagenci => pr_cdagenci  --> Agencia
                                    ,pr_nrdcaixa => pr_nrdcaixa  --> Caixa
                                    ,pr_cddregio => vr_cddregio  -->Sequencial da regional
                                    ,pr_nmdcampo => pr_nmdcampo  -->Nome do campo com erro 
                                    ,pr_tab_erro => vr_tab_erro  -->Tabela Erros
                                    ,pr_des_erro => pr_des_erro);-->Errro OK/NOK 

          --Se Ocorreu erro
          IF vr_des_reto <> 'OK'     OR 
             NVL(vr_cddregio,0)  = 0 THEN
            
            --Se possuir erro na tabela
            IF vr_tab_erro.COUNT > 0 THEN
              --Mensagem Erro
              vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
            ELSE  
              --Mensagem Erro
              vr_dscritic:= 'Erro na RREG0001.pc_grava_regional.';
            END IF;  
            
            --Levantar Excecao
            RAISE vr_exc_erro;
            
          END IF; 

          BEGIN
            INSERT INTO crapreg 
                       (cdcooper,
                        cddregio,
                        dsdregio,
                        cdopereg,
                        dsdemail)
                 VALUES(pr_cdcooper,
                        vr_cddregio,
                        pr_dsdregio,
                        pr_cdopereg,
                        pr_dsdemail);
                
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao incluir Regional: '||SQLERRM;
              RAISE vr_exc_erro;
          END;
                                                   
          -- Inclui mensagem no log
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                     pr_ind_tipo_log => 1, -- Somente mensagem
                                     pr_nmarqlog     => 'cadreg.log',
                                     pr_des_log      => to_char(sysdate,'hh24:mi:ss')||'  '
                                                     || 'Operador ' || pr_cdoperad 
                                                     || ' --> Inclusao de Regional -' 
                                                     || ' Codigo: ' || TO_CHAR(vr_cddregio) 
                                                     || ', Descricao ' || pr_dsdregio
                                                     || ', Operador Resp.: ' || pr_cdopereg
                                                     || ', Email: ' || NVL(TRIM(pr_dsdemail),'""') );
                                                     
          --Salvar
          COMMIT;

        END IF;
        
      ELSE
        --Fechar o cursor
        CLOSE cr_crapreg;
        
        --Se for alteração de regional
        IF pr_cddopcao = 'A' THEN

          IF TRIM(pr_dsdregio) IS NULL THEN

            vr_dsdregio := rw_crapreg.dsdregio;

          ELSE

            vr_dsdregio := pr_dsdregio; 
                            
          END IF;

          IF TRIM(pr_cdopereg) IS NULL THEN
              
            vr_cdopereg := rw_crapreg.cdopereg;

          ELSE
                            
            vr_cdopereg := pr_cdopereg;  

          END IF;

          vr_dsdemail := NVL(TRIM(pr_dsdemail),' ');
          
          BEGIN
            UPDATE crapreg 
               SET crapreg.dsdregio = vr_dsdregio
                  ,crapreg.cdopereg = vr_cdopereg
                  ,crapreg.dsdemail = vr_dsdemail
             WHERE crapreg.cdcooper = pr_cdcooper
               AND crapreg.cddregio = pr_cddregio;

          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar Regional: '||SQLERRM;
              RAISE vr_exc_erro;
          END;    

          IF vr_dsdregio <> rw_crapreg.dsdregio THEN /* Descricao */
              
            -- Inclui mensagem no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 1, -- Somente mensagem
                                       pr_nmarqlog     => 'cadreg.log',
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||'  '
                                                       || 'Operador ' || pr_cdoperad 
                                                       || ' --> Alteracao de Regional -' 
                                                       || ' Codigo: ' || TO_CHAR(pr_cddregio) 
                                                       || ' - Descricao de ' 
                                                       || rw_crapreg.dsdregio || ' para ' || pr_dsdregio);

          END IF;

          IF vr_cdopereg <> rw_crapreg.cdopereg THEN /* Operador */
              
            -- Inclui mensagem no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 1, -- Somente mensagem
                                       pr_nmarqlog     => 'cadreg.log',
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||'  '
                                                       || 'Operador ' || pr_cdoperad 
                                                       || ' --> Alteracao de Regional -' 
                                                       || ' Codigo: ' || TO_CHAR(pr_cddregio) 
                                                       || ' - Responsavel de ' 
                                                       || rw_crapreg.cdopereg || ' para ' || pr_cdopereg);

          END IF;

          IF vr_dsdemail <> rw_crapreg.dsdemail THEN /* E-mail */
              
            -- Inclui mensagem no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 1, -- Somente mensagem
                                       pr_nmarqlog     => 'cadreg.log',
                                       pr_des_log      => to_char(sysdate,'hh24:mi:ss')||'  '
                                                       || 'Operador ' || pr_cdoperad 
                                                       || ' --> Alteracao de Regional -' 
                                                       || ' Codigo: ' || TO_CHAR(pr_cddregio) 
                                                       || ' - E-mail de ' 
                                                       || NVL(TRIM(rw_crapreg.dsdemail),'""') || ' para ' || NVL(TRIM(vr_dsdemail),'""'));

          END IF;
          
          --Salvar
          COMMIT;
          
      END IF;

     END IF; 
    
     -- Retorno OK
     pr_des_erro:= 'OK';
        
    EXCEPTION
      WHEN vr_exc_erro THEN

        -- Retorno não OK
        pr_des_erro:= vr_retornvl;

        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

      -- Efetuar rollback
      ROLLBACK;                                                          

      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';

        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na RREG0001.pc_grava_regional --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Efetuar rollback
        ROLLBACK;

  END pc_grava_regional;

  /* Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG Modo Caracter */
  PROCEDURE pc_grava_regional_car(pr_cdcooper IN crapreg.cdcooper%type -->Codigo Cooperativa                      
                                 ,pr_cdagenci IN INTEGER DEFAULT NULL -->Codigo Agencia
                                 ,pr_nrdcaixa IN INTEGER DEFAULT NULL -->Numero Caixa
                                 ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                 ,pr_cdoperad IN VARCHAR2 DEFAULT NULL -->Operador
                                 ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela                                 
                                 ,pr_cddregio IN INTEGER               -->Codigo da Regional
                                 ,pr_dsdregio IN VARCHAR2 DEFAULT NULL -->Descrição da Regional
                                 ,pr_cdopereg IN VARCHAR2 DEFAULT NULL -->Codigo do operador da regional
                                 ,pr_dsdemail IN VARCHAR2 DEFAULT NULL -->Email
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento 
                                 ,pr_flgerlog IN INTEGER               -->flag log     
                                 ,pr_cddopcao IN VARCHAR2              -->Opcao da tela
                                 ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                 ,pr_clob_ret OUT CLOB                 --Tabela XML                                 
                                 ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                 ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_grava_regional_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG modo Caracter

    Alteracoes: 27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                            (Adriano). 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;

    vr_tab_crapreg RREG0001.typ_tab_crapreg;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN

      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_crapreg.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Gravar Regional
      RREG0001.pc_grava_regional(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa   
                                ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => pr_idorigem  --Origem Processamento
                                ,pr_cdoperad => pr_cdoperad  --Operador
                                ,pr_nmdatela => pr_nmdatela  --Nome da tela                                
                                ,pr_dsdregio => pr_dsdregio
                                ,pr_cdopereg => pr_cdopereg
                                ,pr_dsdemail => pr_dsdemail
                                ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento                                                                  
                                ,pr_flgerlog => pr_flgerlog                                                                
                                ,pr_cddopcao => pr_cddopcao  --Codigo da opção                                  
                                ,pr_cddregio => pr_cddregio
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo                                
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a RREG0001.pc_grava_regional_car.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
                           
      END IF;                                            
                                                           
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
        pr_dscritic:= 'Erro na RREG0001.pc_grava_regional_car --> '|| SQLERRM;

  END pc_grava_regional_car;

  /* Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG Modo Web */
  PROCEDURE pc_grava_regional_web(pr_dsdregio IN VARCHAR2 DEFAULT NULL -->Descrição da Regional
                                 ,pr_cdopereg IN VARCHAR2 DEFAULT NULL -->Codigo do operador da regional
                                 ,pr_dsdemail IN VARCHAR2 DEFAULT NULL -->Email
                                 ,pr_dtmvtolt IN VARCHAR2 DEFAULT NULL -->Data Movimento 
                                 ,pr_flgerlog IN INTEGER               -->flag log     
                                 ,pr_cddopcao IN VARCHAR2              -->Opção da tela
                                 ,pr_cddregio IN INTEGER               -->Codigo da Regional
                                 ,pr_xmllog   IN VARCHAR2 DEFAULT NULL            -->XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER                     -->Código da crítica
                                 ,pr_dscritic OUT VARCHAR2                        -->Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType               -->Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2                        -->Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS                    -->Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_grava_regional_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 20/08/2015                        Ultima atualizacao: 27/11/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Procedure utilizada na gravacao das Opcoes 'A' e 'I' da tela CADREG modo Web

    Alteracoes: 27/11/2015 - Ajuste decorrente a homologação de conversão realizada pela DB1
                            (Adriano). 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;

    --Tabela de contratos
    vr_tab_crapreg RREG0001.typ_tab_crapreg;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_cddregio INTEGER;
                
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;

      --Limpar tabela dados
      vr_tab_crapreg.DELETE;
                  
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;

      vr_cddregio := pr_cddregio;
      
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
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/RRRR'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
         
      --Gravar Regional
      RREG0001.pc_grava_regional(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                ,pr_idorigem => vr_idorigem  --Origem Processamento
                                ,pr_cdoperad => vr_cdoperad  --Operador
                                ,pr_nmdatela => vr_nmdatela  --Nome da tela                                
                                ,pr_dsdregio => pr_dsdregio  --Descricao da regional
                                ,pr_cdopereg => pr_cdopereg  --Operador responsavel
                                ,pr_dsdemail => pr_dsdemail  --E-mail
                                ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento                                                                  
                                ,pr_flgerlog => pr_flgerlog  --Gera log
                                ,pr_cddopcao => pr_cddopcao  --Codigo da opção
                                ,pr_cddregio => vr_cddregio  --Código da regional
                                ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo                                                                  
                                ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                ,pr_des_erro => vr_des_reto); --Saida OK/NOK                                

      --Se Ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na RREG0001.pc_grava_regional_web.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF; 
                 
      --Montar CLOB
      IF vr_tab_crapreg.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        --Buscar Primeira regional
        vr_index:= vr_tab_crapreg.FIRST;

        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de regionais
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);    
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cddregio', pr_tag_cont => TO_CHAR(vr_cddregio), pr_des_erro => vr_dscritic);      
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdregio', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).dsdregio), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdopereg', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).cdopereg), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmoperad', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).nmoperad), pr_des_erro => vr_dscritic);
  				gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'dsdemail', pr_tag_cont => TO_CHAR(vr_tab_crapreg(vr_index).dsdemail), pr_des_erro => vr_dscritic);
          
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_crapreg.NEXT(vr_index);


        END LOOP;

      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        
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
        pr_dscritic:= 'Erro na RREG0001.pc_grava_regional_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_grava_regional_web;
  
END RREG0001;
/

