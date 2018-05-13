CREATE OR REPLACE PACKAGE CECRED.LOGI0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : LOGI0001                               antigo: /sistema/generico/procedures/b1wgen0000.p
    Sistema  : BO PARA LOGIN E MENU DO SISTEMA AYLLOS (INTERNET)
    Sigla    : CRED
    Autor    : Jose Luis Marchezoni - (DB1)
    Data     : Setembor - 2015                 Ultima atualizacao: 
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : BO PARA LOGIN E MENU DO SISTEMA AYLLOS (INTERNET)

   Alteracoes: 
  
  ---------------------------------------------------------------------------------------------------------------*/
  
  /* Rotina referente a verificacao de senha de usuario com nivel coordenador para interface caracter */
  PROCEDURE pc_val_senha_coordenador_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --Sequencial do titular
                                        ,pr_nvoperad IN INTEGER               --Nivel do operador  
                                        ,pr_operador IN VARCHAR2              --Codigo do operador informado
                                        ,pr_nrdsenha IN VARCHAR2              --Numero da senha
                                        ,pr_flgerlog IN VARCHAR2              --Gerar log?                                        
                                        ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela de Retorno                                        
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                        ,pr_dscritic OUT VARCHAR2);           --Descricao critica
  
  /* Rotina referente a verificacao de senha de usuario com nivel coordenador para interface Web */
  PROCEDURE pc_val_senha_coordenador_web(pr_nrdconta IN crapass.nrdconta%TYPE --Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --Sequencial do titular
                                        ,pr_nvoperad IN INTEGER               --Nivel do operador  
                                        ,pr_operador IN VARCHAR2              --Codigo do operador informado
                                        ,pr_nrdsenha IN VARCHAR2              --Numero da senha
                                        ,pr_flgerlog IN VARCHAR2              --Gerar log?                                        
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK
  
END LOGI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.LOGI0001 AS

  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : LOGI0001                               antigo: /sistema/generico/procedures/b1wgen0000.p
    Sistema  : BO PARA LOGIN E MENU DO SISTEMA AYLLOS (INTERNET)
    Sigla    : CRED
    Autor    : Jose Luis Marchezoni - (DB1)
    Data     : Setembor - 2015                 Ultima atualizacao: 30/06/2016
  
   Dados referentes ao programa:
  
   Frequencia: -----
   Objetivo  : BO PARA LOGIN E MENU DO SISTEMA AYLLOS (INTERNET)

   Alteracoes: 07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                            (Adriano).
  
               30/06/2016 - Adicionado UPPER no campo do operador (Douglas - Chamado 478630)
  ---------------------------------------------------------------------------------------------------------------*/
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  /* Rotina referente a verificacao de senha de usuario com nivel coordenador */
  PROCEDURE pc_val_senha_coordenador (pr_cdcooper IN crapcop.cdcooper%TYPE  --Codigo Cooperativa
                                     ,pr_cdagenci IN INTEGER DEFAULT NULL   --Codigo Agencia
                                     ,pr_nrdcaixa IN INTEGER DEFAULT NULL   --Numero Caixa
                                     ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  --Operador
                                     ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  --Nome da tela
                                     ,pr_idorigem IN INTEGER DEFAULT NULL   --Origem Processamento
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE  --Sequencial do titular
                                     ,pr_nvoperad IN INTEGER                --Nivel do operador  
                                     ,pr_operador IN VARCHAR2               --Codigo do operador informado
                                     ,pr_nrdsenha IN VARCHAR2               --Numero da senha
                                     ,pr_flgerlog IN VARCHAR2               --Gerar log?
                                     ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela Erros
                                     ,pr_des_erro OUT VARCHAR2) IS          --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_valida_senha_coordenador        Antiga: cadscr.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 28/09/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para validar a senha do operador (coordenador) 

    Alteracoes: 28/09/2015 - Conversao Progress >> Oracle (PLSQL) - José Luís (DB1)
    
                30/06/2016 - Adicionado UPPER no campo do operador (Douglas - Chamado 478630)
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- CURSORES ---------------------------------
  -- Busca os dados do operador
  CURSOR cr_crapope (pr_cdcooper IN crapope.cdcooper%TYPE,
                     pr_cdoperad IN crapope.cdoperad%TYPE,
                     pr_cddsenha IN crapope.cddsenha%TYPE) IS
  SELECT ope.nvoperad
        ,ope.cdsitope
    FROM crapope ope
   WHERE ope.cdcooper = pr_cdcooper
     AND UPPER(ope.cdoperad) = UPPER(pr_cdoperad)
     AND ope.cddsenha = pr_cddsenha;
     
  rw_crapope cr_crapope%ROWTYPE;   
  
  ------------------------------- VARIÁVEIS --------------------------------    
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000); 

  --Variaveis gerais
  vr_retornvl VARCHAR2(3):= 'NOK';    
  vr_dsorigem VARCHAR2(40);
  vr_dstransa VARCHAR2(100);
  
  -- Rowid para tabela de log
  vr_nrdrowid ROWID;
      
  --Variaveis de Excecoes
  vr_exc_erro EXCEPTION;

  BEGIN

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
    
    --Se for para gerar log
    IF pr_flgerlog = '1' THEN
      --Atribuir Descricao da Origem
      vr_dsorigem := GENE0001.vr_vet_des_origens(pr_idorigem);
      --Atribuir Descricao da Transacao
      vr_dstransa := 'Validar senha de Operador/Coordenador/Gerente';
    END IF;    
    
    -- Verificar os dados do operador
    OPEN cr_crapope (pr_cdcooper => pr_cdcooper,
                     pr_cdoperad => pr_operador,
                     pr_cddsenha => pr_nrdsenha);
    
    FETCH cr_crapope INTO rw_crapope;
    
    -- Se não encontrar registro
    IF cr_crapope%NOTFOUND THEN                     
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapope;
      
      -- Montar mensagem de critica
      vr_cdcritic := 0;
      vr_dscritic := 'Senha invalida';
           
      RAISE vr_exc_erro; 
    ELSE
      -- Verificar o nivel do operador, confirmar se eh coordenador
      IF rw_crapope.nvoperad < pr_nvoperad THEN
        -- Concatenar a descricao do nivel do operador na msg de critica
        IF pr_nvoperad = 1 THEN
          vr_dscritic := 'operador';
        ELSIF pr_nvoperad = 2 THEN
          vr_dscritic := 'coordenador';
        ELSIF pr_nvoperad = 3 THEN 
          vr_dscritic := 'gerente';
        END IF; 
         
        -- Mensagem de critica      
        vr_cdcritic := 0;
        vr_dscritic := 'E necessario que a senha digitada seja de um '|| vr_dscritic || '!';
      
        RAISE vr_exc_erro;       
      END IF;      
    
      -- Operador bloqueado
      IF rw_crapope.cdsitope = 2 THEN 
        -- Montar mensagem de critica
        vr_cdcritic := 627;
        vr_dscritic := NULL;
             
        RAISE vr_exc_erro;        
      END IF;
    
      -- Apenas fechar o cursor
      CLOSE cr_crapope;
    END IF;    
    
    --Atualizar o parametro de retorno
    vr_retornvl := 'OK';
                
  EXCEPTION 
    WHEN vr_exc_erro THEN
      
      -- Retorno não OK          
      pr_des_erro := vr_retornvl;
      
      -- Chamar rotina de gravação de erro
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
                           
      --Se for para gerar log
      IF pr_flgerlog = '1' THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 0
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
  
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro:= 'NOK';
      
      -- Chamar rotina de gravação de erro
      vr_dscritic := 'Erro na logi0001.pc_val_senha_coordenador --> '|| SQLERRM;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  

      --Se for para gerar log
      IF pr_flgerlog = '1' THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 0
                            ,pr_nmdatela => NULL
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      
  END pc_val_senha_coordenador;    
  
  /* Rotina referente a verificacao de senha de usuario com nivel coordenador para interface caracter */
  PROCEDURE pc_val_senha_coordenador_car(pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_nrdconta IN crapass.nrdconta%TYPE --Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --Sequencial do titular
                                        ,pr_nvoperad IN INTEGER               --Nivel do operador  
                                        ,pr_operador IN VARCHAR2              --Codigo do operador informado
                                        ,pr_nrdsenha IN VARCHAR2              --Numero da senha
                                        ,pr_flgerlog IN VARCHAR2              --Gerar log?                                        
                                        ,pr_des_erro OUT VARCHAR2             --Erros do processo OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela de Retorno                                        
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo critica
                                        ,pr_dscritic OUT VARCHAR2) IS         --Descricao critica
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_val_senha_coordenador_car      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 28/09/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para validar a senha do operador (coordenador) em interface caracter

    Alteracoes: 28/09/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
                             
  ---------------------------------------------------------------------------------------------------------------*/

  ------------------------------- VARIÁVEIS --------------------------------
  
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 

  --Tabelas de Memoria
  vr_tab_erro gene0001.typ_tab_erro;

  --Variaveis de Excecoes
  vr_exc_erro  EXCEPTION;                                       
      
  BEGIN      
    --limpar tabela erros
    vr_tab_erro.DELETE;
    
    --Inicializar Variaveis
    vr_cdcritic:= 0;                         
    vr_dscritic:= NULL;
    
    -- Procedura para verificacao dos dados informados
    logi0001.pc_val_senha_coordenador(pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                     ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                     ,pr_nrdcaixa => pr_nrdcaixa   --Numero Caixa
                                     ,pr_cdoperad => pr_cdoperad   --Operador
                                     ,pr_nmdatela => pr_nmdatela   --Nome da tela
                                     ,pr_idorigem => pr_idorigem   --Origem Processamento      
                                     ,pr_nrdconta => pr_nrdconta   --Conta
                                     ,pr_idseqttl => pr_idseqttl   --Sequencial do titular                        
                                     ,pr_nvoperad => pr_nvoperad   --Nivel do operador  
                                     ,pr_operador => pr_operador   --Codigo do operador informado
                                     ,pr_nrdsenha => pr_nrdsenha   --Numero da senha
                                     ,pr_flgerlog => pr_flgerlog   --Gerar log?
                                     ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                     ,pr_des_erro => vr_des_reto); --Saida OK/NOK

    --Se Ocorreu erro
    IF vr_des_reto = 'NOK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic := 'Erro ao executar a logi0001.pc_val_senha_coordenador.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;        
    END IF;                                          
                                       
    --Retorno
    pr_des_erro := 'OK';   
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro:= 'NOK';
      
      --Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;        
        
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';        
      pr_cdcritic := 0;
      
      -- Chamar rotina de gravação de erro
      pr_dscritic := 'Erro na logi0001.pc_val_senha_coordenador_car --> '|| SQLERRM;

  END pc_val_senha_coordenador_car;  
  
  /* Rotina referente a verificacao de senha de usuario com nivel coordenador para interface Web */
  PROCEDURE pc_val_senha_coordenador_web(pr_nrdconta IN crapass.nrdconta%TYPE --Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE --Sequencial do titular
                                        ,pr_nvoperad IN INTEGER               --Nivel do operador  
                                        ,pr_operador IN VARCHAR2              --Codigo do operador informado
                                        ,pr_nrdsenha IN VARCHAR2              --Numero da senha
                                        ,pr_flgerlog IN VARCHAR2              --Gerar log?                                        
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
  /*---------------------------------------------------------------------------------------------------------------
    Programa: pc_val_senha_coordenador_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : José Luís Marchezoni(DB1)
    Data    : 02/10/2015                        Ultima atualizacao: 07/12/2015

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina para validar a senha do operador (coordenador) em interface Web

    Alteracoes: 02/10/2015 - Desenvolvimento - José Luís (DB1)
    
                07/12/2015 - Ajustes de homoologação referente a conversão realizada pela DB1
                             (Adriano).
  ---------------------------------------------------------------------------------------------------------------*/
  
  ------------------------------- VARIÁVEIS --------------------------------  
  --Variaveis de Criticas
  vr_cdcritic INTEGER;
  vr_dscritic VARCHAR2(4000);
  vr_des_reto VARCHAR2(3); 
  
  --Tabela de Erros
  vr_tab_erro gene0001.typ_tab_erro;
  
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
         
  --Variaveis de Excecoes    
  vr_exc_erro  EXCEPTION;                                       
  
  BEGIN
    
    --limpar tabela erros
    vr_tab_erro.DELETE;
                
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
    
    -- Procedura para gerar o arquivo
    logi0001.pc_val_senha_coordenador(pr_cdcooper => vr_cdcooper   --Codigo Cooperativa
                                     ,pr_cdagenci => vr_cdagenci   --Codigo Agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa   --Numero Caixa
                                     ,pr_cdoperad => vr_cdoperad   --Operador
                                     ,pr_nmdatela => vr_nmdatela   --Nome da tela
                                     ,pr_idorigem => vr_idorigem   --Origem Processamento 
                                     ,pr_nrdconta => pr_nrdconta   --Conta
                                     ,pr_idseqttl => pr_idseqttl   --Sequencial do titular
                                     ,pr_nvoperad => pr_nvoperad   --Nivel do operador  
                                     ,pr_operador => pr_operador   --Codigo do operador informado
                                     ,pr_nrdsenha => pr_nrdsenha   --Numero da senha
                                     ,pr_flgerlog => pr_flgerlog   --Gerar log?
                                     ,pr_tab_erro => vr_tab_erro   --Tabela Erros
                                     ,pr_des_erro => vr_des_reto); --Saida OK/NOK
    --Se Ocorreu erro
    IF vr_des_reto = 'NOK' THEN        
      --Se possuir dados na tabela
      IF vr_tab_erro.COUNT > 0 THEN
        --Mensagem erro
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        --Mensagem erro
        vr_dscritic:= 'Erro ao executar a sscr0001.pc_val_senha_coordenador.';
      END IF;    
      
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;                   
                                      
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');           
        
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
      pr_dscritic:= 'Erro na sscr0001.pc_val_senha_coordenador_web --> '|| SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');
  
  END pc_val_senha_coordenador_web;
  
END LOGI0001;
/
