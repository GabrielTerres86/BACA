CREATE OR REPLACE PACKAGE CECRED.TELA_CONTAS_DESAB AS
  
  -- Busca dados
  PROCEDURE pc_busca_dados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
  -- Busca dados
  PROCEDURE pc_grava_dados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Numero do titular
                           ,pr_flgcrdpa  IN INTEGER               --> Libera pre aprovado
                           ,pr_flgrenli  IN crapass.flgrenli%TYPE --> Renova Limite de Credito
                           ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK
   
END TELA_CONTAS_DESAB;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CONTAS_DESAB AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_IMPPRE
  --    Autor   : lucas Lombardi
  --    Data    : Marco/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela IMPPRE (Ayllos Web)
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------
  
  -- Busca dados
  PROCEDURE pc_busca_dados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar dados da tela Desabilitar Operacoes
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca dados do cooperado
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT flgrenli
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Buscar dados do pre aprovado
      CURSOR cr_param_conta(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nvl(m.dsmotivo, '') dsmotivo
              ,TO_CHAR(p.dtatualiza_pre_aprv,'DD/MM/RRRR') dtatualiza
              ,p.flglibera_pre_aprv flglibera
          FROM tbepr_param_conta p
     LEFT JOIN tbgen_motivo m
            ON p.idmotivo = m.idmotivo
         WHERE p.cdcooper = pr_cdcooper
           AND p.nrdconta = pr_nrdconta;
      rw_param_conta cr_param_conta%ROWTYPE;
      
      -- Buscar dados do pre aprovado automatico
      CURSOR cr_carga_auto (pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT 1
          FROM crapcpa cpa
              ,tbepr_carga_pre_aprv carga
         WHERE cpa.cdcooper = pr_cdcooper
           AND cpa.nrdconta = pr_nrdconta
           AND cpa.iddcarga = carga.idcarga
           AND carga.cdcooper           = cpa.cdcooper
           AND carga.indsituacao_carga  = 1  -- Gerada
           AND carga.flgcarga_bloqueada = 0  -- Liberada
           AND carga.tpcarga            = 2; -- Automática
      rw_carga_auto cr_carga_auto%ROWTYPE;
      
      
      -- Buscar dados do pre aprovado manual
      CURSOR cr_carga_manu (pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT carga.dscarga
              ,to_char(carga.dtliberacao,'DD/MM/RRRR') dtinicial
              ,nvl(to_char(carga.dtfinal_vigencia,'DD/MM/RRRR'),'indeterminado') dtfinal
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper           = 3
           AND carga.indsituacao_carga  = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 0 -- Liberada
           AND carga.tpcarga            = 1 -- Manual
           AND EXISTS (SELECT 1 -- Cargas que a conta está relacionada
                         FROM crapcpa cpa
                        WHERE cpa.cdcooper = pr_cdcooper
                          AND cpa.nrdconta = pr_nrdconta
                          AND cpa.iddcarga = carga.idcarga)
         ORDER BY tpcarga ASC  -- Priorizar as cargas 1 - Manual
              ,dtcalculo DESC; -- Priorizar as cargas recentes
      rw_carga_manu cr_carga_manu%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound   BOOLEAN;
      vr_preautom   INTEGER := 0;
      vr_premanua   INTEGER := 0;
      vr_dscarga    tbepr_carga_pre_aprv.dscarga%TYPE := '';
      vr_dtinicial  VARCHAR2(20) := '';
      vr_dtfinal    VARCHAR2(20) := '';
      vr_dsmotivo   tbgen_motivo.dsmotivo%TYPE := '';
      vr_dtatualiza VARCHAR2(20) := '';
      vr_flgcrdpa   INTEGER := 1;
      
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
        
        -- Busca cooperado
        OPEN cr_crapass(vr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        vr_flgfound := cr_crapass%FOUND;
        CLOSE cr_crapass;
        IF NOT vr_flgfound THEN
          vr_cdcritic := 9;
          RAISE vr_exc_erro;
        END IF;
        
        -- Busca dados do pre aprovado
        OPEN cr_param_conta(vr_cdcooper, pr_nrdconta);
        FETCH cr_param_conta INTO rw_param_conta;
        vr_flgfound := cr_param_conta%FOUND;
        CLOSE cr_param_conta;
        IF vr_flgfound THEN
          vr_dsmotivo   := rw_param_conta.dsmotivo;
          vr_dtatualiza := rw_param_conta.dtatualiza;
          vr_flgcrdpa   := rw_param_conta.flglibera;
        END IF;
        
        -- Verifica dados do pre aprovado automatica
        OPEN cr_carga_auto (vr_cdcooper, pr_nrdconta);
        FETCH cr_carga_auto INTO rw_carga_auto;
        vr_flgfound := cr_carga_auto%FOUND;
        CLOSE cr_carga_auto;
        IF vr_flgfound THEN
          vr_preautom := 1;
        END IF;
        
        -- Verifica dados do pre aprovado manual
        OPEN cr_carga_manu (vr_cdcooper, pr_nrdconta);
        FETCH cr_carga_manu INTO rw_carga_manu;
        vr_flgfound := cr_carga_manu%FOUND;
        CLOSE cr_carga_manu;
        IF vr_flgfound THEN
          vr_premanua  := 1;
          vr_dscarga   := rw_carga_manu.dscarga;
          vr_dtinicial := rw_carga_manu.dtinicial;
          vr_dtfinal   := rw_carga_manu.dtfinal;
        END IF;
        
        -- Criar cabecalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

        -- Pre aprovado liberado para o cooperado
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgcrdpa'
                              ,pr_tag_cont => vr_flgcrdpa
                              ,pr_des_erro => vr_dscritic);
        -- Renova automaticamente limite de credito
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgrenli'
                              ,pr_tag_cont => rw_crapass.flgrenli
                              ,pr_des_erro => vr_dscritic);
        -- Renova automaticamente limite de credito
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsmotivo'
                              ,pr_tag_cont => vr_dsmotivo
                              ,pr_des_erro => vr_dscritic);
        -- Renova automaticamente limite de credito
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtatualiza'
                              ,pr_tag_cont => vr_dtatualiza
                              ,pr_des_erro => vr_dscritic);
        -- Possui pre aprovado carga automatica
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'preautom'
                              ,pr_tag_cont => vr_preautom
                              ,pr_des_erro => vr_dscritic);
        -- Possui pre aprovado carga manual
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'premanua'
                              ,pr_tag_cont => vr_premanua
                              ,pr_des_erro => vr_dscritic);
        -- Descricao da carga
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscarga'
                              ,pr_tag_cont => vr_dscarga
                              ,pr_des_erro => vr_dscritic);
        -- Data inicio vigencia
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtinicial'
                              ,pr_tag_cont => vr_dtinicial
                              ,pr_des_erro => vr_dscritic);
        -- Data final vigencia
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dtfinal'
                              ,pr_tag_cont => vr_dtfinal
                              ,pr_des_erro => vr_dscritic);
                              
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
        pr_dscritic := 'Erro geral em CONTAS_DESAB: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_dados;
  
  -- Busca dados
  PROCEDURE pc_grava_dados (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                           ,pr_idseqttl  IN crapttl.idseqttl%TYPE --> Numero do titular
                           ,pr_flgcrdpa  IN INTEGER               --> Libera pre aprovado
                           ,pr_flgrenli  IN crapass.flgrenli%TYPE --> Renova Limite de Credito
                           ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                           ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_grava_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Lucas Lombardi
    Data    : Julho/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar dados da tela Desabilitar Operacoes
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      
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
        
        -- Leitura do calendario da CECRED
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
        CLOSE BTCH0001.cr_crapdat;
        
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);
        
        BEGIN
          UPDATE crapass
             SET flgrenli = pr_flgrenli
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar dados do cooperado. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        -- Bloqueia pre aprovado na conta do cooperado
        EMPR0002.pc_mantem_param_conta (pr_cdcooper => vr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_flglibera_pre_aprv =>  pr_flgcrdpa
                                       ,pr_dtatualiza_pre_aprv => NULL
                                       ,pr_idmotivo => NULL -- Sem motivo
                                       ,pr_cdoperad => vr_cdoperad
                                       ,pr_idorigem => vr_idorigem
                                       ,pr_nmdatela => 'CONTAS_DESAB'
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_dscritic => vr_dscritic
                                       ,pr_des_erro => pr_des_erro);
          
        IF pr_des_erro = 'NOK' THEN
          RAISE vr_exc_erro;
        END IF;
        
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
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral em CONTAS_DESAB: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_grava_dados;
  
END TELA_CONTAS_DESAB;
/
