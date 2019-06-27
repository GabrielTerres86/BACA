CREATE OR REPLACE PACKAGE TELA_ATENDA_LIMITE AS

  -- Busca dados
  PROCEDURE pc_busca_dados_conta (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

  -- Busca dados
  PROCEDURE pc_grava_dados_conta (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_flgrenli  IN crapass.flgrenli%TYPE --> Renova Limite de Credito
                                 ,pr_flmajora  IN crapass.flmajora%TYPE --> Flag Majoracao
                                 ,pr_dsmotmaj  IN crapass.dsmotmaj%TYPE --> Motivo Bloqueio Majoracao
                                 ,pr_flcnaulc  IN crapass.flcnaulc%TYPE --> Flag de cancelamento de credito automatico
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2);            --> Saida OK/NOK

END TELA_ATENDA_LIMITE;
/
CREATE OR REPLACE PACKAGE BODY TELA_ATENDA_LIMITE AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_ATENDA_LIMITE
  --    Autor   : Marcos Martini (Envolti)
  --    Data    : Fevereiro/2019                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela ATENDA_LIMITE
  --
  --    Alteracoes: 
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Busca dados
  PROCEDURE pc_busca_dados_conta (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
    BEGIN

    /* .............................................................................
    Programa: pc_busca_dados_conta
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Heitor Schmitt
    Data    : Julho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar dados da tela Desabilitar Operacoes
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      
      -- Busca dados do cooperado
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT c.flgrenli
             , c.flmajora
             , c.flcnaulc
             , c.dsmotmaj
             , c.cdopemaj
             , o.nmoperad nmopemaj
          FROM crapope o
             , crapass c
         WHERE o.cdcooper (+) = c.cdcooper
           AND o.cdoperad (+) = c.cdopemaj --pr_cdoperad 
           AND c.cdcooper = pr_cdcooper
           AND c.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      -- Variável de críticas
      vr_exc_erro  EXCEPTION;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(1000);
      
      -- Variaveis auxiliares
      vr_flgfound   BOOLEAN;
      
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
        
        -- Criar cabecalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados/></Root>');

        -- Renova automaticamente limite de credito
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgrenli'
                              ,pr_tag_cont => rw_crapass.flgrenli
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flmajora'
                              ,pr_tag_cont => rw_crapass.flmajora
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsmotmaj'
                              ,pr_tag_cont => rw_crapass.dsmotmaj
                              ,pr_des_erro => vr_dscritic);
                              
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flcnaulc'
                              ,pr_tag_cont => rw_crapass.flcnaulc
                              ,pr_des_erro => vr_dscritic);
                              
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdopemaj'
                              ,pr_tag_cont => rw_crapass.cdopemaj
                              ,pr_des_erro => vr_dscritic);
        
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmopemaj'
                              ,pr_tag_cont => rw_crapass.nmopemaj
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
        pr_dscritic := 'Erro geral em LIMITE: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_busca_dados_conta;

  PROCEDURE pc_grava_dados_conta (pr_nrdconta  IN crapass.nrdconta%TYPE --> Numero da conta
                                 ,pr_flgrenli  IN crapass.flgrenli%TYPE --> Renova Limite de Credito
                                 ,pr_flmajora  IN crapass.flmajora%TYPE --> Flag Majoracao
                                 ,pr_dsmotmaj  IN crapass.dsmotmaj%TYPE --> Motivo Bloqueio Majoracao
                                 ,pr_flcnaulc  IN crapass.flcnaulc%TYPE --> Flag de cancelamento de credito automatico
                                 ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do Campo
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Saida OK/NOK
  BEGIN

    /* .............................................................................
    Programa: pc_grava_dados_conta
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : EMPR
    Autor   : Heitor Schmitt
    Data    : Julho/2017                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar dados da tela Desabilitar Operacoes
    
    Alteracoes: 
    ..............................................................................*/ 
    DECLARE
      CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE
                        ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT flgrenli
             , flmajora
             , flcnaulc
             , dsmotmaj
             , cdopemaj
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;  
    
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
      vr_dsmotmaj crapass.dsmotmaj%TYPE;
      vr_nrdrowid ROWID;
      
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

        OPEN cr_crapass (vr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;
        CLOSE cr_crapass;

        if pr_flmajora = 1 then
          vr_dsmotmaj := ' ';
        else
          vr_dsmotmaj := pr_dsmotmaj;
        end if;

        BEGIN
          UPDATE crapass
             SET flgrenli = pr_flgrenli
               , flmajora = pr_flmajora
               , flcnaulc = pr_flcnaulc
               , dsmotmaj = vr_dsmotmaj
               , cdopemaj = vr_cdoperad
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta;

          /* Inclusão de log com retorno do rowid */
          gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(vr_idorigem) --> Origem enviada
                              ,pr_dstransa => 'Desabilitar Operacoes Conta Corrente'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => 1
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          
          --Desenvolver outros logs necessarios
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Renova Limite Credito Automatico.'
                                 ,pr_dsdadant => CASE rw_crapass.flgrenli
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END
                                 ,pr_dsdadatu => CASE pr_flgrenli
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END);
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Majoracao de Credito Habilitada'
                                 ,pr_dsdadant => CASE rw_crapass.flmajora
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END
                                 ,pr_dsdadatu => CASE pr_flmajora
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END);
                                                 
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Cancelamento Automatico Limite Credito'
                                 ,pr_dsdadant => CASE rw_crapass.flcnaulc
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END
                                 ,pr_dsdadatu => CASE pr_flcnaulc
                                                   WHEN 1 THEN 'Sim'
                                                   ELSE 'Nao'
                                                 END);
                                                 
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Motivo Bloqueio Majoracao'
                                 ,pr_dsdadant => rw_crapass.dsmotmaj
                                 ,pr_dsdadatu => vr_dsmotmaj);
          
          gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                 ,pr_nmdcampo => 'Operador'
                                 ,pr_dsdadant => rw_crapass.cdopemaj
                                 ,pr_dsdadatu => vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar dados do cooperado. ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
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
        pr_dscritic := 'Erro geral em LIMITE: ' || SQLERRM;
          
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      END;
  END pc_grava_dados_conta;
  
END TELA_ATENDA_LIMITE;
/
