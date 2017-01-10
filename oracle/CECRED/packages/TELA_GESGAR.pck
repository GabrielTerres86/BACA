CREATE OR REPLACE PACKAGE CECRED.TELA_GESGAR AS

  PROCEDURE pc_busca_dados(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

  PROCEDURE pc_grava_dados(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                          ,pr_nrdemsgs IN INTEGER            --> Numero de Mensagens
                          ,pr_nrdesnhs IN INTEGER            --> Numero de Senhas
                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2);        --> Saida OK/NOK

END TELA_GESGAR;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_GESGAR AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADCAT
  --    Autor   : Dionathan
  --    Data    : Janeiro/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela AGENET
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_dados(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar dados de Gestao de Garantias
    
    Alteracoes: 
                25/11/2016 - Alteração para que o fonte realize a avaliação do departamento
                             pelo campo CDDEPART ao invés do DSDEPART. (Renato Darosci - Supero)
    ............................................................................. */
    
    --- CURSORES ---   
    -- Cursor do Operador
    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT cddepart
        FROM crapope
       WHERE crapope.cdcooper        = pr_cdcooper
         AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
    rw_crapope cr_crapope%ROWTYPE;
    
    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Variáveis auxiliares
    vr_dstexto   VARCHAR2(32700);
    vr_clobxml   CLOB;
    
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
  
    -- Diversas
    vr_dsvlrgar VARCHAR2(10) := '';
    vr_tipsplit  gene0002.typ_split;
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
    
    -- Valida se operador tem acesso
    OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                    ,pr_cdoperad => vr_cdoperad);

    FETCH cr_crapope INTO rw_crapope;

    -- Verifica se a retornou registro
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_cdcritic := 67;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas Fecha o Cursor
      CLOSE cr_crapope;
    END IF;
        
    -- Somente o departamento credito irá ter acesso para alterar as informacoes
    IF rw_crapope.cddepart NOT IN (14,20) THEN
      vr_dscritic := 'Operador nao tem permissao de acesso.';
      RAISE vr_exc_erro;
    END IF; 
    
    vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdcooper => vr_cdcooper,pr_cdacesso => 'GESGAR');
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';');
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrdemsgs', pr_tag_cont => TO_CHAR(vr_tipsplit(1)), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'nrdesnhs', pr_tag_cont => TO_CHAR(vr_tipsplit(2)), pr_des_erro => vr_dscritic);
  
    pr_des_erro := 'OK';
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_GESGAR.PC_BUSCA_DADOS --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_busca_dados;

  PROCEDURE pc_grava_dados(pr_cddopcao IN VARCHAR2           --> Código da Opcao
                          ,pr_nrdemsgs IN INTEGER            --> Numero de Mensagens
                          ,pr_nrdesnhs IN INTEGER            --> Numero de Senhas
                          ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_grava_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Fevereiro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para inserir dados de gestao de garantias
    
    Alteracoes:
    ............................................................................. */
        
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
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
        
    BEGIN
      UPDATE crapprm
      SET crapprm.dsvlrprm = TO_CHAR(pr_nrdemsgs) || ';' || TO_CHAR(pr_nrdesnhs)
      WHERE
        UPPER(crapprm.nmsistem) = UPPER('CRED')
        AND crapprm.cdcooper = vr_cdcooper
        AND UPPER(crapprm.cdacesso) = UPPER('GESGAR');
      IF SQL%ROWCOUNT = 0 THEN
        BEGIN
          INSERT INTO crapprm(
            crapprm.nmsistem,          
            crapprm.cdcooper,
            crapprm.cdacesso,
            crapprm.dsvlrprm)
           VALUES(UPPER('CRED'),
                  vr_cdcooper,
                  UPPER('GESGAR'),
                  TO_CHAR(pr_nrdemsgs) || ';' || TO_CHAR(pr_nrdesnhs));
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir registro. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro. Erro: ' || SQLERRM;
        RAISE vr_exc_erro;
    END;

    COMMIT;
      
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK          
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_GESGAR.PC_GRAVA_DADOS --> ' ||
                     SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
  END pc_grava_dados;

END TELA_GESGAR;
/
