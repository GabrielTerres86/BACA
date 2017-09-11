CREATE OR REPLACE PACKAGE CECRED.TELA_CADOCP AS
  /*---------------------------------------------------------------------------------------------
    Programa: TELA_CADOCP
    Autor   : Kelvin Souza Ott
    Data    : Agosto/2017                   Ultima Atualizacao: 
      
    Dados referentes ao programa:    
    Objetivo  : Package ref. a tela CADOCP (Ayllos Web)
      
    Alteracoes:     
	---------------------------------------------------------------------------------------------*/
PROCEDURE pc_consulta_ocupacao(pr_cdnatocp IN gncdnto.cdnatocp%TYPE  --> Codigo da natureza da ocupacao                            
                              ,pr_nrregist IN INTEGER                --> Quantidade de registros                               
                              ,pr_nriniseq IN INTEGER                --> Qunatidade inicial
                              ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                              
                              ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

PROCEDURE pc_alterar_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                             ,pr_cdocupa  IN gncdocp.cdocupa%TYPE  --> Codigo da ocupacao
                             ,pr_dsdocupa IN gncdocp.dsdocupa%TYPE --> Descrição da ocupacao
                             ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE --> Descrição resumida da ocupacao
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                            

PROCEDURE pc_incluir_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                             ,pr_dsdocupa IN gncdocp.dsdocupa%TYPE --> Descrição da ocupacao
                             ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE --> Descrição resumida da ocupacao
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);           --> Erros do processo  

PROCEDURE pc_excluir_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                             ,pr_cdocupa  IN gncdocp.cdocupa%TYPE  --> Codigo da ocupacao                               
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);            --> Erros do processo                                                        
END TELA_CADOCP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADOCP AS
  /*---------------------------------------------------------------------------------------------
    Programa: TELA_CADOCP
    Autor   : Kelvin Souza Ott
    Data    : Agosto/2017                   Ultima Atualizacao: 
      
    Dados referentes ao programa:    
    Objetivo  : Package ref. a tela CADOCP (Ayllos Web)
      
    Alteracoes:     
  ---------------------------------------------------------------------------------------------*/
  PROCEDURE pc_consulta_ocupacao(pr_cdnatocp IN gncdnto.cdnatocp%TYPE  --> Codigo da natureza da ocupacao                            
                                ,pr_nrregist IN INTEGER                --> Quantidade de registros                            
                                ,pr_nriniseq IN INTEGER                --> Qunatidade inicial
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG                                
                                ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY xmltype     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    /*--------------------------------------------------------------------------------------------- 
      Programa: pc_consulta_ocupacao
      Sistema : Ayllos Web
      Autor   : Kelvin Souza Ott
      Data    : Agosto/2017                       Ultima atualizacao: 
      
      Dados referentes ao programa:
      
      Frequencia: Sempre que for chamado
      Objetivo  : Busca informacoes das ocupacoes da tela CADOCP
                      
      Alteracoes: 
    ---------------------------------------------------------------------------------------------*/
    
    CURSOR cr_gncdocp(pr_cdnatocp IN gncdnto.cdnatocp%TYPE) IS
      SELECT ocp.cdocupa
            ,ocp.dsdocupa
            ,ocp.rsdocupa
        FROM gncdocp ocp
       WHERE ocp.cdnatocp = pr_cdnatocp
       ORDER BY ocp.cdocupa;
             
    --Variaveis auxiliares
    vr_clob     CLOB;
    vr_xml_temp VARCHAR2(32726) := '';
    vr_qtregist INTEGER;  
    vr_nrregist INTEGER := nvl(pr_nrregist,9999);
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);    
      
    --Controle de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
  BEGIN
    --Inicializar Variaveis
    vr_qtregist:= 0;
    
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
                                        
    -- Monta documento XML 
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
    
    -- Criar cabeçalho do XML
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><dados>');

                       
    
    
    FOR rw_gncdocp IN cr_gncdocp(pr_cdnatocp) LOOP
      
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
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<ocupacao>  
                                                         <cdocupa>' || rw_gncdocp.cdocupa  || '</cdocupa>
                                                         <dsdocupa>' || rw_gncdocp.dsdocupa || '</dsdocupa>
                                                         <rsdocupa>' || rw_gncdocp.rsdocupa || '</rsdocupa>
                                                      </ocupacao>');
       END IF;                                                                                                              

       --Diminuir registros
       vr_nrregist:= nvl(vr_nrregist,0) - 1; 
       
    END LOOP;
    
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</dados><qtregist>' || vr_qtregist  || '</qtregist>');
    
    gene0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Root>'
                           ,pr_fecha_xml      => TRUE);                                  
    
    dbms_output.put_line(vr_clob);
    
    IF vr_clob IS NOT NULL THEN
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
    END IF;
    
    pr_des_erro := 'OK';
    
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
      pr_dscritic := 'Erro na TELA_LIBCRM.PC_CONSULTA_OCUPACAO: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');
      
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
    
  END pc_consulta_ocupacao;
  
  PROCEDURE pc_alterar_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                               ,pr_cdocupa  IN gncdocp.cdocupa%TYPE  --> Codigo da ocupacao
                               ,pr_dsdocupa IN gncdocp.dsdocupa%TYPE --> Descrição da ocupacao
                               ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE --> Descrição resumida da ocupacao
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  
  /* .............................................................................
   Programa: pc_alterar_ocupacao
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott - CECRED
   Data    : Agosto/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar ocupacoes

   Alteracoes: 
                
  ............................................................................. */   
    CURSOR cr_gncdocp(pr_cdnatocp IN gncdocp.cdnatocp%TYPE
                     ,pr_cdocupa  IN gncdocp.cdocupa%TYPE) IS
      SELECT 1
        FROM gncdocp ocp
       WHERE ocp.cdnatocp = pr_cdnatocp
         AND ocp.cdocupa  = pr_cdocupa;

    rw_gncdocp cr_gncdocp%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
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
    
    OPEN cr_gncdocp(pr_cdnatocp
                   ,pr_cdocupa);
      FETCH cr_gncdocp
       INTO rw_gncdocp;
       
      IF cr_gncdocp%NOTFOUND THEN        
        CLOSE cr_gncdocp;        
        vr_dscritic := 'Ocupação não encontrada.';        
        RAISE vr_exc_erro;
      END IF;
      
    CLOSE cr_gncdocp;
    
    BEGIN
      UPDATE gncdocp 
         SET dsdocupa = UPPER(pr_dsdocupa)
            ,rsdocupa = UPPER(pr_rsdocupa)
       WHERE cdnatocp = pr_cdnatocp
         AND cdocupa  = pr_cdocupa;
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'TELA_CADOCP.PC_ALTERAR_OCUPACAO: Erro ao atualizar a tabela gncdocp ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    pr_des_erro := 'OK';
    
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
      pr_dscritic := 'Erro na TELA_CADOCP.PC_ALTERAR_OCUPACAO: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');  
      
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                                              
  END pc_alterar_ocupacao;
  
  PROCEDURE pc_incluir_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                               ,pr_dsdocupa IN gncdocp.dsdocupa%TYPE --> Descrição da ocupacao
                               ,pr_rsdocupa IN gncdocp.rsdocupa%TYPE --> Descrição resumida da ocupacao
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  
  /* .............................................................................
   Programa: pc_incluir_ocupacao
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott - CECRED
   Data    : Agosto/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para incluir ocupacoes

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
    
    BEGIN
      INSERT INTO cecred.gncdocp
        (cdocupa
        ,dsdocupa
        ,cdnatocp
        ,rsdocupa)
      VALUES
        ((SELECT max(nvl(cdocupa,0)) + 1
            FROM gncdocp)
        ,UPPER(pr_dsdocupa)
        ,pr_cdnatocp
        ,UPPER(pr_rsdocupa));
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'TELA_CADOCP.PC_INCLUIR_OCUPACAO: Erro ao inserir na tabela gncdocp ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    pr_des_erro := 'OK';
    
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
      pr_dscritic := 'Erro na TELA_CADOCP.PC_INCLUIR_OCUPACAO: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');    

      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);
                                                                                      
  END pc_incluir_ocupacao;
  
  PROCEDURE pc_excluir_ocupacao(pr_cdnatocp IN gncdocp.cdnatocp%TYPE --> Codigo da natureza
                               ,pr_cdocupa  IN gncdocp.cdocupa%TYPE  --> Codigo da ocupacao                               
                               ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  
  /* .............................................................................
   Programa: pc_alterar_ocupacao
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Kelvin Souza Ott - CECRED
   Data    : Agosto/2017                        Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado
   Objetivo  : Rotina para alterar ocupacoes

   Alteracoes: 
                
  ............................................................................. */   
    CURSOR cr_gncdocp(pr_cdnatocp IN gncdocp.cdnatocp%TYPE
                     ,pr_cdocupa  IN gncdocp.cdocupa%TYPE) IS
      SELECT 1
        FROM gncdocp ocp
       WHERE ocp.cdnatocp = pr_cdnatocp
         AND ocp.cdocupa  = pr_cdocupa;

    rw_gncdocp cr_gncdocp%ROWTYPE;
    
    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
        
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
    
    OPEN cr_gncdocp(pr_cdnatocp
                   ,pr_cdocupa);
      FETCH cr_gncdocp
       INTO rw_gncdocp;
       
      IF cr_gncdocp%NOTFOUND THEN        
        CLOSE cr_gncdocp;        
        vr_dscritic := 'Ocupação não encontrada.';        
        RAISE vr_exc_erro;
      END IF;
      
    CLOSE cr_gncdocp;
    
    BEGIN
      DELETE gncdocp 
       WHERE cdnatocp = pr_cdnatocp
         AND cdocupa  = pr_cdocupa;
      
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'TELA_CADOCP.PC_EXCLUIR_OCUPACAO: Erro ao atualizar a tabela gncdocp ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    pr_des_erro := 'OK';
    
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
      pr_dscritic := 'Erro na TELA_CADOCP.PC_EXCLUIR_OCUPACAO: ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> 
                                        <Root>
                                          <Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>
                                        </Root>');  
                                        
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper);                                        
  
  END pc_excluir_ocupacao;
END TELA_CADOCP;
/
