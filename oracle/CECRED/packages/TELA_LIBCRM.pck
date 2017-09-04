CREATE OR REPLACE PACKAGE CECRED.TELA_LIBCRM AS

 /*---------------------------------------------------------------------------------------------
 Programa: TELA_MANCRD
 Autor   : Kelvin Souza Ott
 Data    : Agosto/2017                   Ultima Atualizacao: 
  
 Dados referentes ao programa:
   
 Objetivo  : Package ref. a tela LIBCRM (Ayllos Web)
  
 Alteracoes:                                   
 ---------------------------------------------------------------------------------------------*/
 PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                            
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK 

 PROCEDURE pc_altera_parametros(pr_flgaccrm IN crapprm.dstexprm%TYPE --> Flag para identificar                              ,
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);                                
END TELA_LIBCRM;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_LIBCRM AS
  /*---------------------------------------------------------------------------------------------
    Programa: TELA_LIBCRM
    Autor   : Kelvin Souza Ott
    Data    : Agosto/2017                   Ultima Atualizacao: 
      
    Dados referentes ao programa:    
    Objetivo  : Package ref. a tela LIBCRM (Ayllos Web)
      
    Alteracoes:     
	---------------------------------------------------------------------------------------------*/
  
  PROCEDURE pc_busca_parametros(pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                            
                               ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /*--------------------------------------------------------------------------------------------- 
      Programa: pc_busca_parametros
      Sistema : Ayllos Web
      Autor   : Kelvin Souza Ott
      Data    : Agosto/2017                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Busca as informacoes dos parametros do CRM
                      
      Alteracoes: 
    ---------------------------------------------------------------------------------------------*/
             
    --Variaveis auxiliares
    vr_dadosxml VARCHAR(32676);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_flgaccrm NUMBER(1);
    vr_nrdrowid ROWID;
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
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

    --Busca o parâmetro
    vr_flgaccrm := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'LIBCRM');
                                            
    IF TRIM(vr_flgaccrm) IS NULL THEN
      BEGIN      
        INSERT INTO crapprm
          (nmsistem
          ,cdcooper
          ,cdacesso
          ,dstexprm
          ,dsvlrprm)
        VALUES
          ('CRED'
           ,0
           ,'LIBCRM'
           ,'Indicador que liberará o uso do Ayllos Web mesmo quando estiver com o CRM'
           ,0);
         
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro na TELA_LIBCRM.PC_BUSCA_PARAMETROS - Problema ao inserir registro na tabela crapprm: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
      
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'Parametro de CRM criado com sucesso.'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                          ,pr_dstransa => 'Criar parametros de CRM'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'LIBCRM'
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'flgaccrm'
                               ,pr_dsdadant => ''
                               ,pr_dsdadatu => 0);
      
      vr_flgaccrm := 0;
                                            
    END IF;                                                                                        
                
    vr_dadosxml := '<?xml version="1.0" encoding="ISO-8859-1" ?>
                       <root>';
                       
    vr_dadosxml := vr_dadosxml || '<dados>  
                                     <flgaccrm>' || vr_flgaccrm || '</flgaccrm>
                                   </dados>'; 
                                   
    vr_dadosxml := vr_dadosxml || '</root>';
    
    IF vr_dadosxml IS NOT NULL THEN
        pr_retxml := XMLType.createXML(vr_dadosxml);
    END IF;
    
    pr_des_erro := 'OK';
    
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    
    WHEN OTHERS THEN
      ROLLBACK;
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LIBCRM.PC_BUSCA_PARAMETROS: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    
  END pc_busca_parametros;
  
  PROCEDURE pc_altera_parametros(pr_flgaccrm IN crapprm.dstexprm%TYPE --> Numero de conta                              ,
                                ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG                            
                                ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_altera_parametros
    Sistema : Ayllos Web
    Autor   : Kelvin Souza Ott
    Data    : Agosto/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Altera as informacoes dos parametros
                    
    Alteracoes: 
    ............................................................................. */
  
   -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_nrdrowid ROWID;
    vr_flgaccrm_ant NUMBER(1);
    
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_dscritic crapcri.dscritic%TYPE;    
  
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

    vr_flgaccrm_ant := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                ,pr_cdcooper => 0
                                                ,pr_cdacesso => 'LIBCRM');
    
    BEGIN
      
      UPDATE crapprm
         SET dsvlrprm = pr_flgaccrm
       WHERE nmsistem = 'CRED'
         AND cdcooper = '0'
         AND cdacesso = 'LIBCRM';
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'TELA_LIBCRM.PC_ALTERA_PARAMETROS: Erro ao atualizar a tabela crapprm ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    pr_des_erro := 'OK';
    
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'Parametros de CRM atualizados com sucesso.'
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(1)
                          ,pr_dstransa => 'Atualizar parametros de CRM'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'LIBCRM'
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'flgaccrm'
                             ,pr_dsdadant => vr_flgaccrm_ant
                             ,pr_dsdadatu => pr_flgaccrm);
    
    
    COMMIT; 
  EXCEPTION 
    WHEN vr_exc_erro THEN
      ROLLBACK;
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
    WHEN OTHERS THEN
      ROLLBACK;
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_LIBCRM.PC_ALTERA_PARAMETROS: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');  

  END pc_altera_parametros;
  
  
END TELA_LIBCRM;
/
