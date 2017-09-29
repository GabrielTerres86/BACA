CREATE OR REPLACE PACKAGE CECRED.TELA_ATENDA_INTERNET IS

  --> Retornar uma lista com todos os dispositivos do Cecred Mobile habilitados para push
  PROCEDURE pc_busca_dispositivos_push(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);           --> Erros do processo                               
   
  --> Esta procedure deverá desativar o dispositivo recebido por parâmetro para recebimento de notificações push do Cecred Mobile
  PROCEDURE pc_desativa_disposit_push(pr_dispositivomobileid IN dispositivomobile.dispositivomobileid%TYPE --> Dispositivo Mobile
                                     ,pr_xmllog   IN VARCHAR2                                              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                                          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                                             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                                    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                                             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                                           --> Erros do processo                                     
END TELA_ATENDA_INTERNET;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_ATENDA_INTERNET IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_ATENDA_MOBILE
  --  Sistema  : Ayllos Web
  --  Autor    : Jean Michel Deschamps
  --  Data     : Setembro - 2017                 Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas ao mobile na tela ATENDA
  --
  -- Alteracoes: 
  --
  ---------------------------------------------------------------------------

  --> Retornar uma lista com todos os dispositivos do Cecred Mobile habilitados para push
  PROCEDURE pc_busca_dispositivos_push(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Sequencial do Titular
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_busca_dispositivos_push
        Sistema : CECRED
        Sigla   : ATENDA
        Autor   : Jean Michel
        Data    : Setembro/2017                 Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Retornar uma lista com todos os dispositivos do Cecred Mobile habilitados para push
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------
    --> Buscar logs
    CURSOR cr_dispositivomobile(pr_cdcooper crapass.cdcooper%TYPE
                               ,pr_nrdconta crapass.nrdconta%TYPE
                               ,pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT d.dispositivomobileid AS dispositivo
            ,d.modelo              AS modelo
            ,TO_CHAR(TRUNC(d.datacriacao),'dd/mm/RRRR')  AS datacriacao
            ,d.plataforma || ' (' || d.versaoso || ')' AS sistemaoperacional
        FROM dispositivomobile d
       WHERE d.pushhabilitado = 1
         AND d.cooperativaid = pr_cdcooper
         AND d.numeroconta = pr_nrdconta
         AND d.titularid = pr_idseqttl;

    rw_dispositivomobile cr_dispositivomobile%ROWTYPE;     

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador INTEGER := 0;
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
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'dispositivos', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_dispositivomobile IN cr_dispositivomobile(pr_cdcooper => vr_cdcooper
                                                    ,pr_nrdconta => pr_nrdconta
                                                    ,pr_idseqttl => pr_idseqttl) LOOP                  
        

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dispositivos', pr_posicao => 0, pr_tag_nova => 'dispositivo', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dispositivo', pr_posicao => vr_contador, pr_tag_nova => 'dispositivomobileid', pr_tag_cont => rw_dispositivomobile.dispositivo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dispositivo', pr_posicao => vr_contador, pr_tag_nova => 'modelo',              pr_tag_cont => rw_dispositivomobile.modelo, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dispositivo', pr_posicao => vr_contador, pr_tag_nova => 'datacriacao',         pr_tag_cont => rw_dispositivomobile.datacriacao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dispositivo', pr_posicao => vr_contador, pr_tag_nova => 'sistemaoperacional',  pr_tag_cont => rw_dispositivomobile.sistemaoperacional, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
            
    END LOOP;
        
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_MOBILE.pc_busca_dispositivos_push. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_busca_dispositivos_push;  

  --> Esta procedure deverá desativar o dispositivo recebido por parâmetro para recebimento de notificações push do Cecred Mobile
  PROCEDURE pc_desativa_disposit_push(pr_dispositivomobileid IN dispositivomobile.dispositivomobileid%TYPE --> Dispositivo Mobile
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
    /* .............................................................................
    
        Programa: pc_desativa_disposit_push
        Sistema : CECRED
        Sigla   : ATENDA
        Autor   : Jean Michel
        Data    : Setembro/2017                 Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Esta procedure deverá desativar o dispositivo recebido por parâmetro para recebimento de notificações push do Cecred Mobile.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
    ---------> CURSORES <--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_plataforma dispositivomobile.plataforma%TYPE;
    vr_modelo     dispositivomobile.modelo%TYPE;
    vr_titularid  dispositivomobile.titularid%TYPE;
    vr_nrdconta   dispositivomobile.numeroconta%TYPE;
    vr_dstransa   craplgm.dstransa%TYPE := 'Desativação de alertas push em dispositivo do Cecred Mobile.';
    vr_nrdrowid ROWID;
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
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    -- Atualização para desativar dispositivo
    BEGIN
      UPDATE dispositivomobile d
         SET d.pushhabilitado = 0
       WHERE d.dispositivomobileid = pr_dispositivomobileid
      RETURNING d.plataforma, d.modelo, d.titularid, d.numeroconta into vr_plataforma, vr_modelo, vr_titularid, vr_nrdconta;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar registro(dispositivomobile). Erro: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    IF SQL%ROWCOUNT = 0 THEN
      vr_dscritic := 'Dispositivo não encontrado. ID: ' || TO_CHAR(pr_dispositivomobileid);
      RAISE vr_exc_saida;
    END IF;

    -- Gerar log ao cooperado
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => ''
                        ,pr_dsorigem => 'AYLLOS'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => vr_titularid
                        ,pr_nmdatela => 'ATENDA'
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
						  
    -- Gerar informacoes do item - PLATAFORMA
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'plataforma'
                             ,pr_dsdadant => vr_plataforma
                             ,pr_dsdadatu => NULL);      -- Gerar informacoes do item
							   
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                             ,pr_nmdcampo => 'modelo'
                             ,pr_dsdadant => vr_modelo
                             ,pr_dsdadatu => NULL);
    COMMIT;    
    
  EXCEPTION
    WHEN vr_exc_saida THEN
      
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
      pr_dscritic := 'Erro geral na rotina na procedure TELA_ATENDA_MOBILE.pc_desativa_disposit_push. Erro: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

  END pc_desativa_disposit_push;   

END TELA_ATENDA_INTERNET;
/
