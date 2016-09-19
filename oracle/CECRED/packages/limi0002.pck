CREATE OR REPLACE PACKAGE CECRED.LIMI0002 AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0002
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina referente a consulta da tela de Limite de Saque do TAA
  PROCEDURE pc_tela_lim_saque_consultar(pr_nrdconta tbtaa_limite_saque.nrdconta%TYPE --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType            --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2                     --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);                   --> Erros do processo
                                    
  -- Rotina referente a alteracao da tela de Limite de Saque do TAA
  PROCEDURE pc_tela_lim_saque_alterar(pr_nrdconta                tbtaa_limite_saque.nrdconta%TYPE                --> Numero da Conta
                                     ,pr_dtmvtolt IN VARCHAR2                                                        --> Data de Movimentacao
                                     ,pr_vllimite_saque          tbtaa_limite_saque.vllimite_saque%TYPE          --> Valor do Limite do Saque
                                     ,pr_flgemissao_recibo_saque tbtaa_limite_saque.flgemissao_recibo_saque%TYPE --> Recibo Saque
                                     ,pr_xmllog   IN VARCHAR2                                                    --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                                                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                                                   --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                                          --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                                                   --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);                                                 --> Erros do processo
  
END LIMI0002;
/

CREATE OR REPLACE PACKAGE BODY CECRED.LIMI0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0002
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_tela_lim_saque_consultar(pr_nrdconta tbtaa_limite_saque.nrdconta%TYPE  --> Numero da Conta
                                       ,pr_xmllog   IN VARCHAR2                       --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER                   --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2                      --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType             --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2                      --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2) IS                  --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_lim_saque_consultar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Julho/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Consultar a tela de limite de saque do TAA

     Observacao: -----
     Alteracoes: 
     ..............................................................................*/ 
    DECLARE
      
      -- Selecionar os dados
      CURSOR cr_tbtaa_limite_saque(pr_cdcooper IN tbtaa_limite_saque.cdcooper%TYPE
                                  ,pr_nrdconta IN tbtaa_limite_saque.nrdconta%TYPE) IS
        SELECT vllimite_saque,
               flgemissao_recibo_saque,
               dtalteracao_limite,
               cdoperador_alteracao
          FROM tbtaa_limite_saque
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbtaa_limite_saque cr_tbtaa_limite_saque%ROWTYPE;
      
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT nmoperad
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND crapope.cdoperad = pr_cdoperad;
      rw_crapope cr_crapope%ROWTYPE;
    
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis do Limite de Saque
      vr_vllimite_saque           tbtaa_limite_saque.vllimite_saque%TYPE;
      vr_flgemissao_recibo_saque  tbtaa_limite_saque.flgemissao_recibo_saque%TYPE;
      vr_dtalteracao_limite       tbtaa_limite_saque.dtalteracao_limite%TYPE;
      vr_cdoperador_alteracao     tbtaa_limite_saque.cdoperador_alteracao%TYPE;
      vr_nmoperad                 crapope.nmoperad%TYPE;
      
    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      -- Cursor com os dados do limite de saque
      OPEN cr_tbtaa_limite_saque(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbtaa_limite_saque INTO rw_tbtaa_limite_saque;
      IF cr_tbtaa_limite_saque%FOUND THEN
        CLOSE cr_tbtaa_limite_saque;
        -- Armazena os valores em variaveis
        vr_vllimite_saque           := rw_tbtaa_limite_saque.vllimite_saque;
        vr_flgemissao_recibo_saque  := rw_tbtaa_limite_saque.flgemissao_recibo_saque;
        vr_dtalteracao_limite       := rw_tbtaa_limite_saque.dtalteracao_limite;
        vr_cdoperador_alteracao     := rw_tbtaa_limite_saque.cdoperador_alteracao;
      ELSE
        CLOSE cr_tbtaa_limite_saque;  
      END IF;
      
      -- Verifica se possui operador cadastrado
      IF rw_tbtaa_limite_saque.cdoperador_alteracao <> ' ' THEN          
        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => rw_tbtaa_limite_saque.cdoperador_alteracao);
        FETCH cr_crapope 
         INTO rw_crapope;
        IF cr_crapope%FOUND THEN
          CLOSE cr_crapope;
          vr_nmoperad := rw_crapope.nmoperad;          
        ELSE 
          CLOSE cr_crapope;
        END IF;
          
      END IF; /* END IF rw_tbtaa_limite_saque.cdoperador_alteracao <> ' ' THEN */        
      
      -- Cria o XML de retorno
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimite_saque', pr_tag_cont => vr_vllimite_saque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'flgemissao_recibo_saque', pr_tag_cont => vr_flgemissao_recibo_saque, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dtalteracao_limite', pr_tag_cont => TO_CHAR(vr_dtalteracao_limite,'DD/MM/RRRR'), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdoperador_alteracao', pr_tag_cont => vr_cdoperador_alteracao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nmoperador_alteracao', pr_tag_cont => vr_nmoperad, pr_des_erro => vr_dscritic);
      
    EXCEPTION      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0002.pc_tela_lim_saque_consultar: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_lim_saque_consultar;  
  
  PROCEDURE pc_tela_lim_saque_alterar(pr_nrdconta                tbtaa_limite_saque.nrdconta%TYPE                --> Numero da Conta
                                     ,pr_dtmvtolt IN VARCHAR2                                                        --> Data de Movimentacao
                                     ,pr_vllimite_saque          tbtaa_limite_saque.vllimite_saque%TYPE          --> Valor do Limite do Saque
                                     ,pr_flgemissao_recibo_saque tbtaa_limite_saque.flgemissao_recibo_saque%TYPE --> Recibo Saque
                                     ,pr_xmllog   IN VARCHAR2                                                    --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER                                                --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2                                                   --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType                                          --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2                                                   --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS                                               --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_lim_saque_alterar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Julho/15.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Alterar as regras do limite de saque do TAA

     Observacao: -----
     Alteracoes: 
     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_tbtaa_limite_saque(pr_cdcooper IN tbtaa_limite_saque.cdcooper%TYPE
                                  ,pr_nrdconta IN tbtaa_limite_saque.nrdconta%TYPE) IS
        SELECT vllimite_saque,
               flgemissao_recibo_saque,
               CASE WHEN flgemissao_recibo_saque = 0 THEN 'Nao Emite'
                    ELSE 'Emite'
               END AS emissao_recibo_saque
          FROM tbtaa_limite_saque
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_tbtaa_limite_saque cr_tbtaa_limite_saque%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_dtmvtolt      DATE;
      
      -- Variaveis de log
      vr_dstransa             VARCHAR2(1000);
      vr_dsorigem             VARCHAR2(1000);
      vr_emissao_recibo_saque VARCHAR2(100);
      vr_indtrans             INTEGER;
      vr_nrdrowid             ROWID;

    BEGIN
      
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      vr_dsorigem := TRIM(GENE0001.vr_vet_des_origens(vr_idorigem));
      vr_dstransa := 'Inclusao/Alteracao Limite Saque TAA';
      vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');
      
      IF pr_vllimite_saque <= 0 THEN
        vr_dscritic := 'Limite de saque invalido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_flgemissao_recibo_saque NOT IN (0,1) THEN
        vr_dscritic := 'Indicador invalido para emissao de recibo de saque.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Cursor com os dados do limite de saque
      OPEN cr_tbtaa_limite_saque(pr_cdcooper => vr_cdcooper
                                ,pr_nrdconta => pr_nrdconta);
      FETCH cr_tbtaa_limite_saque 
       INTO rw_tbtaa_limite_saque;
      IF cr_tbtaa_limite_saque%FOUND THEN
        CLOSE cr_tbtaa_limite_saque;
        -- Atualiza os dados do Limite de Saque
        BEGIN
          UPDATE tbtaa_limite_saque SET   
                 vllimite_saque          = pr_vllimite_saque
                ,flgemissao_recibo_saque = pr_flgemissao_recibo_saque
                ,dtalteracao_limite      = vr_dtmvtolt
                ,cdoperador_alteracao    = vr_cdoperad
           WHERE cdcooper = vr_cdcooper
             AND nrdconta = pr_nrdconta;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao alterar o limite de saque: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
           
      ELSE
        CLOSE cr_tbtaa_limite_saque;
        
        -- Grava os dados do Limite de saque do TAA
        BEGIN         
          INSERT INTO tbtaa_limite_saque
                      (cdcooper
                      ,nrdconta
                      ,vllimite_saque
                      ,flgemissao_recibo_saque
                      ,dtalteracao_limite
                      ,cdoperador_alteracao)
               VALUES (vr_cdcooper
                      ,pr_nrdconta
                      ,pr_vllimite_saque
                      ,pr_flgemissao_recibo_saque
                      ,vr_dtmvtolt
                      ,vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir limite de saque. '||SQLERRM;
            RAISE vr_exc_saida;
        END;         
        
      END IF;    
      
      -- Chamar geracao de LOG
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => SYSDATE
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => GENE0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Limite de Saque'
                               ,pr_dsdadatu => To_Char(nvl(pr_vllimite_saque,0),'fm999g999g990d00')
                               ,pr_dsdadant => To_Char(nvl(rw_tbtaa_limite_saque.vllimite_saque,0),'fm999g999g990d00'));
                               
      -- Verifica o Recibo de Saque   
      IF pr_flgemissao_recibo_saque = 0 THEN
        vr_emissao_recibo_saque := 'Nao Emite';
      ELSE
        vr_emissao_recibo_saque := 'Emite';          
      END IF;        
                               
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Recibo de Saque'
                               ,pr_dsdadatu => nvl(vr_emissao_recibo_saque,' ')
                               ,pr_dsdadant => nvl(rw_tbtaa_limite_saque.emissao_recibo_saque,' '));
                               
      COMMIT;   

    EXCEPTION      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0002.pc_tela_lim_saque_alterar: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_lim_saque_alterar;
  
END LIMI0002;
/

