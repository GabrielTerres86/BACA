CREATE OR REPLACE PACKAGE CECRED.TELA_MANPAC AS

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consulta_inf_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                                  ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK

  -- Rotina para listar pacotes de tarifas
  PROCEDURE pc_lista_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
    
  -- Rotina para listar pacotes de tarifas
  PROCEDURE pc_lista_tarifa(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                           ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote 
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
   
  -- Rotina para validar e desativar pacote de tarifas
  PROCEDURE pc_desativa_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                              ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK
  
  -- Rotina para validar e habilitar pacote de tarifas
  PROCEDURE pc_habilita_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                              ,pr_dtvigenc IN VARCHAR2                      --> Data de Vigencia do Pacote
                              ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK

  -- Rotina para migracao de pacotes de tarifas
  PROCEDURE pc_migra_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                           ,pr_cdpctant IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote Antigo
                           ,pr_cdpctnov IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote Novo
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consult_inf_pcte(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                               ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                               ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2);                   --> Saida OK/NOK

  -- Procedure de pesquisa da tela MANPAC
  PROCEDURE pc_pesquisa_manpac(pr_cddopcao         IN VARCHAR2                            --> Código da Opcao
                              ,pr_cdcooper         IN tbtarif_pacotes_coop.cdcooper%TYPE  --> Codigo da Cooperativa
                              ,pr_cdpacote         IN tbtarif_pacotes.cdpacote%TYPE       --> Código do Pacote de Tarifas
                              ,pr_dspacote         IN tbtarif_pacotes.dspacote%TYPE       --> Descricao do Pacote de Tarifas
                              ,pr_nrregist         IN NUMBER                              --> Numero de Registros Exibidos
                              ,pr_nrinireg         IN NUMBER                              --> Registro Inicial
                              ,pr_qtregist        OUT NUMBER                              --> Quantidade de Registros
                              ,pr_tbtarif_pacotes OUT TELA_PACTAR.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                              ,pr_cdcritic        OUT crapcri.cdcritic%TYPE               --> Código da crítica
                              ,pr_dscritic        OUT crapcri.dscritic%TYPE);             --> Descriçao da crítica

  -- Procedure de pesquisa da tela MANPAC para acessar via PROGRESS
  PROCEDURE pc_pesquisa_manpac_car(pr_cddopcao IN VARCHAR2                           --> Código da Opcao
                                  ,pr_cdcooper IN tbtarif_pacotes_coop.cdcooper%TYPE --> Codigo da Cooperativa                
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE      --> Código do Pacote de Tarifas
                                  ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE      --> Descricao do Pacote de Tarifas
                                  ,pr_nrregist IN NUMBER                             --> Numero de Registros Exibidos
                                  ,pr_nrinireg IN NUMBER                             --> Registro Inicial
                                  ,pr_qtregist OUT NUMBER                            --> Quantidade de Registros
                                  ,pr_clobxmlc OUT CLOB                              --> XML com dos Pacotes de tarifas
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Código da crítica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE);           --> Descriçao da crítica
END TELA_MANPAC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANPAC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_MANPAC
  --    Autor   : Jean Michel
  --    Data    : Marco/2016                   Ultima Atualizacao: 03/04/2018
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Package ref. a tela MANPAC (Ayllos Web)
  --
  --    Alteracoes: 03/04/2018 - Inserido noti0001.pc_cria_notificacao                            
  --    
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consulta_inf_pacote(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                                  ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                                  ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                                  ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consulta_inf_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar informacoes dos pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.flgsituacao = 1;   

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 

    CURSOR cr_tbtarif_pacotes_coop(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                                  ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
        FROM tbtarif_pacotes tar
            ,tbtarif_pacotes_coop tarcop
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.flgsituacao = 1
         AND tarcop.cdcooper = pr_cdcooper
         AND tarcop.cdpacote = tar.cdpacote
         AND tarcop.cdpacote = pr_cdpacote
         AND tarcop.flgsituacao = 1;   

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;
 
    CURSOR cr_crapfco(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                     ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT fco.vltarifa AS vlpacote
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND (fco.cdcooper = pr_cdcooper OR pr_cdcooper = 3);

    rw_crapfco cr_crapfco%ROWTYPE;
     
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
      
    vr_vlpacote NUMBER := 0;

    --Controle de erro
    vr_exc_erro EXCEPTION;

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
    
    IF UPPER(pr_cddopcao) <> 'D' THEN
      -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
      OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote);

      FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

      -- Verifica se encontrou registros com o codigo informado
      IF cr_tbtarif_pacotes%NOTFOUND THEN
        CLOSE cr_tbtarif_pacotes;
        vr_dscritic := 'Serviço Cooperativo não encontrado.'; 
        RAISE vr_exc_erro;    
      END IF;

      CLOSE cr_tbtarif_pacotes;

      IF pr_cddopcao = 'D' THEN
        IF rw_tbtarif_pacotes.flgsituacao = 0 THEN 
          vr_dscritic := 'Serviço Cooperativo desativado.'; 
          RAISE vr_exc_erro;    
        END IF;
      END IF;

      OPEN cr_crapfco(pr_cdpacote => pr_cdpacote
                     ,pr_cdcooper => vr_cdcooper);
          
      FETCH cr_crapfco INTO rw_crapfco;

      IF cr_crapfco%NOTFOUND THEN
        CLOSE cr_crapfco; 
        vr_dscritic := 'Valor do Serviço Cooperativo não está cadastrado.';
       RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapfco; 
        vr_vlpacote := rw_crapfco.vlpacote;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdpacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dspacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tppessoa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.tppessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'vlpacote', pr_tag_cont => TO_CHAR(vr_vlpacote,'999g990d00'), pr_des_erro => vr_dscritic);
      
    ELSE
      -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
      OPEN cr_tbtarif_pacotes_coop(pr_cdpacote => pr_cdpacote
                                  ,pr_cdcooper => vr_cdcooper);

      FETCH cr_tbtarif_pacotes_coop INTO rw_tbtarif_pacotes_coop;

      -- Verifica se encontrou registros com o codigo informado
      IF cr_tbtarif_pacotes_coop%NOTFOUND THEN
        CLOSE cr_tbtarif_pacotes_coop;
        vr_dscritic := 'Serviço Cooperativo não encontrado.'; 
        RAISE vr_exc_erro;    
      END IF;

      CLOSE cr_tbtarif_pacotes_coop;

      IF rw_tbtarif_pacotes_coop.flgsituacao = 0 THEN 
        vr_dscritic := 'Serviço Cooperativo desativado.'; 
        RAISE vr_exc_erro;    
      END IF;

      OPEN cr_crapfco(pr_cdpacote => pr_cdpacote
                     ,pr_cdcooper => vr_cdcooper);
          
      FETCH cr_crapfco INTO rw_crapfco;

      IF cr_crapfco%NOTFOUND THEN
        CLOSE cr_crapfco; 
        vr_dscritic := 'Valor do Serviço Cooperativo não está cadastrado.';
       RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapfco; 
        vr_vlpacote := rw_crapfco.vlpacote;
      END IF;

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes_coop.cdpacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes_coop.dspacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tppessoa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes_coop.tppessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'vlpacote', pr_tag_cont => TO_CHAR(vr_vlpacote,'999g990d00'), pr_des_erro => vr_dscritic);
      
    END IF;  

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_CONSULTA_INF_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_consulta_inf_pacote;

  -- Rotina para consultar dados gerais de todos os pacote de tarifas
  PROCEDURE pc_lista_pacote(pr_cddopcao IN VARCHAR2           --> Código da Opcao    
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descriçao da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS      --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_lista_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar dados gerais de todos os pacote de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,DECODE(tar.tppessoa,1,'PESSOA FISICA',2,'PESSOA JURIDICA') AS tppessoa
            ,DECODE((SELECT tarcop.flgsituacao FROM tbtarif_pacotes_coop tarcop
                   WHERE tarcop.cdcooper = pr_cdcooper AND tarcop.cdpacote = tar.cdpacote
                     AND tarcop.flgsituacao = 1)        
            ,1,'HABILITADO','') AS situacao
            ,NVL((SELECT fco.vltarifa FROM crapfco fco, crapfvl fvl WHERE fco.cdcooper = pr_cdcooper
        AND fvl.cdtarifa = tar.cdtarifa_lancamento
        AND fco.cdfaixav = fvl.cdfaixav
        AND fco.flgvigen = 1),0) AS vlpacote
      FROM tbtarif_pacotes tar
          ,craptar tari
      WHERE tar.flgsituacao = 1
        AND tar.cdtarifa_lancamento = tari.cdtarifa
   ORDER BY tar.cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 
 
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

    -- Gerais
    vr_contapct INTEGER := 0;
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
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_tbtarif_pacotes IN cr_tbtarif_pacotes(pr_cdcooper => vr_cdcooper) LOOP
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'pacote', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contapct, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdpacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contapct, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dspacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contapct, pr_tag_nova => 'tppessoa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.tppessoa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contapct, pr_tag_nova => 'situacao', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.situacao), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contapct, pr_tag_nova => 'vlpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.vlpacote,'999g990d00'), pr_des_erro => vr_dscritic);
      
      vr_contapct := vr_contapct + 1;
    END LOOP;    

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contapct), pr_des_erro => vr_dscritic);

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_LISTA_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_lista_pacote;

  -- Rotina para consultar dados gerais de todos os pacote de tarifas
  PROCEDURE pc_lista_tarifa(pr_cddopcao IN VARCHAR2                      --> Código da Opcao  
                           ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote  
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_lista_tarifa
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para listar tarifas de determinado pacote
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    
    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE) IS
      SELECT tarif.cdpacote AS cdpacote
            ,tarif.cdtarifa AS cdtarifa
            ,tar.dstarifa AS dstarifa
            ,tarif.qtdoperacoes AS qtdoperacoes
      FROM tbtarif_servicos tarif
          ,craptar tar
      WHERE tarif.cdpacote = pr_cdpacote
        AND tarif.cdtarifa = tar.cdtarifa;

    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;

    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper tbtarif_contas_pacote.cdcooper%TYPE 
                                   ,pr_cdpacote tbtarif_contas_pacote.cdpacote%TYPE) IS

      SELECT tar.cdcooper
            ,tar.nrdconta
        FROM tbtarif_contas_pacote tar
       WHERE tar.cdcooper = pr_cdcooper
         AND tar.cdpacote = pr_cdpacote
         AND tar.flgsituacao = 1;
        
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;

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

    -- Gerais
    vr_contatar INTEGER := 0;
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
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_tbtarif_servicos IN cr_tbtarif_servicos(pr_cdpacote => pr_cdpacote) LOOP
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'pacote', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contatar, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.cdpacote), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contatar, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.cdtarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contatar, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.dstarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'pacote',   pr_posicao => vr_contatar, pr_tag_nova => 'qtoperacoes', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.qtdoperacoes), pr_des_erro => vr_dscritic);
      
      vr_contatar := vr_contatar + 1;
    END LOOP;    

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtdregis', pr_tag_cont => TO_CHAR(vr_contatar), pr_des_erro => vr_dscritic);

    -- Verifica se existem cooperados que utilizam a tarifa
    OPEN cr_tbtarif_contas_pacote(pr_cdcooper => vr_cdcooper
                                 ,pr_cdpacote => pr_cdpacote);

    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;

    IF cr_tbtarif_contas_pacote%FOUND THEN
      CLOSE cr_tbtarif_contas_pacote;
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'flgcooper', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
    ELSE
      CLOSE cr_tbtarif_contas_pacote;
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'flgcooper', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    END IF;

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_LISTA_TARIFA --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_lista_tarifa;

  -- Rotina para validar e desativar pacote de tarifas
  PROCEDURE pc_desativa_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote
                              ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_desativa_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar e desativar pacote de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa 
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 
 
    CURSOR cr_tbtarif_pacotes_coop(pr_cdpacote tbtarif_pacotes_coop.cdpacote%TYPE
                                  ,pr_cdcooper tbtarif_pacotes_coop.cdcooper%TYPE) IS 
      SELECT t.cdpacote
        FROM tbtarif_pacotes_coop t
       WHERE t.cdpacote = pr_cdpacote
         AND t.cdcooper = pr_cdcooper
         AND t.flgsituacao = 1;

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;

    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper tbtarif_contas_pacote.cdcooper%TYPE 
                                   ,pr_cdpacote tbtarif_contas_pacote.cdpacote%TYPE) IS

      SELECT tar.cdcooper
            ,tar.nrdconta
        FROM tbtarif_contas_pacote tar
       WHERE tar.cdcooper = pr_cdcooper
         AND tar.cdpacote = pr_cdpacote
         AND tar.dtcancelamento IS NULL;
        
    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;

    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Verifica se Pacote de Tarifas é valido
    OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote); -- Codigo do Pacote

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;
    END IF;    

    IF rw_tbtarif_pacotes.flgsituacao = 0 THEN
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    -- Consulta pacotes nas cooperativas
    OPEN cr_tbtarif_pacotes_coop(pr_cdpacote => pr_cdpacote
                                ,pr_cdcooper => vr_cdcooper);

    FETCH cr_tbtarif_pacotes_coop INTO rw_tbtarif_pacotes_coop;
                            
    IF cr_tbtarif_pacotes_coop%FOUND THEN
      CLOSE cr_tbtarif_pacotes_coop;
    ELSE
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Verifica se existem cooperados que utilizam a tarifa
    OPEN cr_tbtarif_contas_pacote(pr_cdcooper => vr_cdcooper
                                 ,pr_cdpacote => pr_cdpacote);

    FETCH cr_tbtarif_contas_pacote INTO rw_tbtarif_contas_pacote;

    IF cr_tbtarif_contas_pacote%FOUND THEN
      CLOSE cr_tbtarif_contas_pacote;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'flgcooper', pr_tag_cont => 1, pr_des_erro => vr_dscritic);
    ELSE
      CLOSE cr_tbtarif_contas_pacote;
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      -- Informacoes de cabecalho de pacote
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'flgcooper', pr_tag_cont => 0, pr_des_erro => vr_dscritic);
    END IF;
    
    -- Desativa pacote de tarifas
    IF pr_cddopcao = 'D' THEN
      BEGIN
        UPDATE 
          tbtarif_pacotes_coop
        SET
          tbtarif_pacotes_coop.flgsituacao = 0,
          tbtarif_pacotes_coop.dtcancelamento = rw_crapdat.dtmvtolt
        WHERE 
          tbtarif_pacotes_coop.cdcooper = vr_cdcooper
          AND tbtarif_pacotes_coop.cdpacote = pr_cdpacote;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao desativar Serviço Cooperativo. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;       
      END;
    END IF;

    COMMIT;

    pr_des_erro := 'OK';

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
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_DESATIVA_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_desativa_pacote;

  -- Rotina para validar e habilitar pacote de tarifas
  PROCEDURE pc_habilita_pacote(pr_cddopcao IN VARCHAR2                                    --> Código da Opcao                                 
                              ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE               --> Codigo do Pacote
                              ,pr_dtvigenc IN VARCHAR2                                    --> Data de Vigencia do Pacote
                              ,pr_xmllog   IN VARCHAR2                                    --> XML com informações de LOG
                              ,pr_cdcritic OUT PLS_INTEGER                                --> Código da crítica
                              ,pr_dscritic OUT VARCHAR2                                   --> Descriçao da crítica
                              ,pr_retxml   IN OUT NOCOPY xmltype                          --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2                                   --> Nome do Campo
                              ,pr_des_erro OUT VARCHAR2) IS                          	    --> Saida OK/NOK
  
    /* .............................................................................
    Programa: pc_habilita_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para validar e habilitar pacote de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdcooper tbtarif_pacotes_coop.cdcooper%TYPE
                             ,pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tari.dstarifa
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
            ,fco.vltarifa AS vlpacote
            ,COUNT(*) OVER(PARTITION BY tar.cdpacote)AS contador
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.cdcooper = pr_cdcooper
         AND fco.flgvigen = 1;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 

    CURSOR cr_tbtarif_pacotes_coop(pr_cdcooper tbtarif_pacotes_coop.cdcooper%TYPE
                                  ,pr_cdpacote tbtarif_pacotes_coop.cdpacote%TYPE) IS
      SELECT tr.cdcooper
        FROM tbtarif_pacotes_coop tr
       WHERE tr.cdcooper = pr_cdcooper
         AND tr.cdpacote = pr_cdpacote
         AND tr.flgsituacao = 1;

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;
     
    -- Consulta valores das tarifas
    CURSOR cr_vlr_tbtarif(pr_cdcooper tbtarif_pacotes_coop.cdcooper%TYPE
                         ,pr_cdpacote tbtarif_pacotes_coop.cdpacote%TYPE) IS
    SELECT p.cdpacote, SUM (c.vltarifa * s.qtdoperacoes) AS vltarifa
      FROM tbtarif_pacotes p,
           tbtarif_servicos s,
           crapfvl f,
           crapfco c
     WHERE p.cdpacote = s.cdpacote
       AND p.cdpacote = pr_cdpacote
       AND s.cdtarifa = f.cdtarifa
       AND f.cdfaixav = c.cdfaixav
       AND c.cdcooper = pr_cdcooper
       AND c.flgvigen = 1
    GROUP BY p.cdpacote;

    rw_vlr_tbtarif cr_vlr_tbtarif%ROWTYPE;
    
    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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
      
    vr_dtvigenc DATE;

    --Controle de erro
    vr_exc_erro EXCEPTION;

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
    
    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Verifica se pacote ja esta habilitado para a cooperativa    
    OPEN cr_tbtarif_pacotes_coop(pr_cdcooper => vr_cdcooper
                                ,pr_cdpacote => pr_cdpacote);

    FETCH cr_tbtarif_pacotes_coop INTO rw_tbtarif_pacotes_coop;

    IF cr_tbtarif_pacotes_coop%FOUND THEN
      -- Fecha cursor    
      CLOSE cr_tbtarif_pacotes_coop;
      vr_dscritic := 'Operação não efetuada! Serviço Cooperativo já está ativo na cooperativa.';
      RAISE vr_exc_erro;
    ELSE
      -- Fecha cursor    
      CLOSE cr_tbtarif_pacotes_coop;  
    END IF;

    -- Verifica informacoes do pacote de tarifas que sera habilitado
    OPEN cr_tbtarif_pacotes(pr_cdcooper => vr_cdcooper
                           ,pr_cdpacote => pr_cdpacote);

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;                       

    IF cr_tbtarif_pacotes%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      -- Fecha cursor
      CLOSE cr_tbtarif_pacotes;

      IF rw_tbtarif_pacotes.flgsituacao = 0 THEN
        vr_dscritic := 'Serviço Cooperativo desabilitado.';
        RAISE vr_exc_erro;
      END IF;

      IF rw_tbtarif_pacotes.contador > 1 THEN
        vr_dscritic := 'Não foi possível obter o valor da tarifa ' || TO_CHAR(rw_tbtarif_pacotes.cdtarifa_lancamento) || '. As tarifas incluídas no Serviço Cooperativo devem ser cadastradas com uma única faixa de valor.';
        RAISE vr_exc_erro;
      END IF; 
    END IF;
    
    -- Verifica se data de vigencia foi informada
    IF TRIM(pr_dtvigenc) IS NULL THEN
      vr_dscritic := 'Informe a Data de inicio da vigência.';
      pr_nmdcampo := 'dtvigencHab';
      RAISE vr_exc_erro;
    END IF;

    BEGIN
      vr_dtvigenc := TO_DATE(pr_dtvigenc,'dd/mm/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic:= 'Data de vigência inválida.';
        pr_nmdcampo := 'dtvigencHab';
        RAISE vr_exc_erro;
    END;

    -- Verifica se a data de vigencia e menor que a data atual
    IF TO_DATE(pr_dtvigenc,'dd/mm/RRRR') < rw_crapdat.dtmvtolt THEN
      vr_dscritic := 'Data de inicio da vigência deve ser maior ou igual a data atual.';
      pr_nmdcampo := 'dtvigencHab';
      RAISE vr_exc_erro;
    END IF;
    
    OPEN cr_vlr_tbtarif(pr_cdcooper => vr_cdcooper, pr_cdpacote => pr_cdpacote);

    FETCH cr_vlr_tbtarif INTO rw_vlr_tbtarif;

    IF cr_vlr_tbtarif%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_vlr_tbtarif;
      vr_dscritic := 'Valores de tarifas não cadastrados.';
      RAISE vr_exc_erro;      
    ELSE
      -- Fecha cursor
      CLOSE cr_vlr_tbtarif;
    END IF;

    -- Verifica valor do pacote excede soma das tarifas individuais 
    IF NVL(rw_tbtarif_pacotes.vlpacote,0) > NVL(rw_vlr_tbtarif.vltarifa,0) THEN
      vr_dscritic := 'Operação não efetuada! O valor da tarifa do Serviço Cooperativo não pode ser superior a soma das tarifas individuais dos serviços disponibilizados.';
      RAISE vr_exc_erro; 
    END IF;

    IF pr_cddopcao = 'H' THEN
      BEGIN
        INSERT INTO tbtarif_pacotes_coop(
          cdcooper,
          cdpacote,
          dtmvtolt,
          flgsituacao,
          dtinicio_vigencia)
        VALUES(
          vr_cdcooper,
          pr_cdpacote,
          rw_crapdat.dtmvtolt,
          1,
          TO_DATE(pr_dtvigenc,'dd/mm/RRRR'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro de Serviço Cooperativo. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
     
    COMMIT;

    pr_des_erro := 'OK';

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
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_HABILITA_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_habilita_pacote;

  -- Rotina para migracao de pacotes de tarifas
  PROCEDURE pc_migra_pacote(pr_cddopcao IN VARCHAR2                      --> Código da Opcao                                 
                           ,pr_cdpctant IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote Antigo
                           ,pr_cdpctnov IN tbtarif_pacotes.cdpacote%TYPE --> Codigo do Pacote Novo
                           ,pr_xmllog   IN VARCHAR2                      --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                  --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                     --> Descriçao da crítica
                           ,pr_retxml   IN OUT NOCOPY xmltype            --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                     --> Nome do Campo
                           ,pr_des_erro OUT VARCHAR2) IS                 --> Saida OK/NOK
  
    /* .............................................................................
    Programa: pc_migra_pacote
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para migracao de pacote de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdcooper crapcop.cdcooper%TYPE
                             ,pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tari.dstarifa
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
            ,fco.vltarifa AS vlpacote
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.cdcooper = pr_cdcooper
         AND fco.flgvigen = 1;   

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 

    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE) IS
      SELECT 
        COUNT(tarser.cdtarifa) AS qtdservicos
        FROM tbtarif_servicos tarser
       WHERE cdpacote = pr_cdpacote;
    
    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE; 

    CURSOR cr_tbtarif_servicos_ant(pr_cdpacote tbtarif_servicos.cdpacote%TYPE) IS
      SELECT 
         tarser.cdpacote
        ,tarser.cdtarifa
        ,tarser.qtdoperacoes
        FROM tbtarif_servicos tarser
       WHERE cdpacote = pr_cdpacote;
    
    rw_tbtarif_servicos_ant cr_tbtarif_servicos_ant%ROWTYPE;

    CURSOR cr_tbtarif_servicos_nov(pr_cdpacote tbtarif_servicos.cdpacote%TYPE
                                  ,pr_cdtarifa tbtarif_servicos.cdtarifa%TYPE) IS
      SELECT tarser.cdpacote
            ,tarser.cdtarifa
            ,tarser.qtdoperacoes
        FROM tbtarif_servicos tarser
       WHERE tarser.cdpacote = pr_cdpacote
         AND tarser.cdtarifa = pr_cdtarifa;
    
    rw_tbtarif_servicos_nov cr_tbtarif_servicos_nov%ROWTYPE;   

    CURSOR cr_tbtarif_contas_pacote(pr_cdcooper crapcop.cdcooper%TYPE
                                   ,pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
    SELECT ctapct.cdcooper
          ,ctapct.nrdconta
          ,ctapct.cdpacote
          ,ctapct.dtadesao
          ,ctapct.dtinicio_vigencia
          ,ctapct.dtcancelamento
          ,ctapct.nrdiadebito
          ,ctapct.indorigem
          ,ctapct.flgsituacao
          ,ctapct.perdesconto_manual
          ,ctapct.qtdmeses_desconto
          ,ctapct.cdreciprocidade
          ,ctapct.flgdigit_adesao
          ,ctapct.flgdigit_cancela
          ,ctapct.cdoperador_adesao
          ,ctapct.cdoperador_cancela
          ,ctapct.rowid
      FROM tbtarif_contas_pacote ctapct
     WHERE ctapct.cdcooper = pr_cdcooper
       AND ctapct.cdpacote = pr_cdpacote
       AND ctapct.dtcancelamento IS NULL;

    rw_tbtarif_contas_pacote cr_tbtarif_contas_pacote%ROWTYPE;
   
    CURSOR cr_crapsnh(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT snh.idseqttl
        FROM crapsnh snh
       WHERE snh.cdcooper = pr_cdcooper
         AND snh.nrdconta = pr_nrdconta
         AND snh.tpdsenha = 1
         AND snh.cdsitsnh = 1;

    rw_crapsnh cr_crapsnh%ROWTYPE;

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND cop.flgativo = 1;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_tbtarif_pacotes_nom(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.dspacote
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;
    
    rw_tbtarif_pacotes_nom cr_tbtarif_pacotes_nom%ROWTYPE;      

    CURSOR cr_tbtarif_pacotes_ger(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa 
        FROM tbtarif_pacotes tar
       WHERE tar.cdpacote = pr_cdpacote;

    rw_tbtarif_pacotes_ger cr_tbtarif_pacotes_ger%ROWTYPE; 
 
    CURSOR cr_tbtarif_pacotes_coop(pr_cdpacote tbtarif_pacotes_coop.cdpacote%TYPE) IS 
      SELECT t.cdpacote
        FROM tbtarif_pacotes_coop t
       WHERE t.cdpacote = pr_cdpacote
         AND t.flgsituacao = 1;

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;

    --Tipo de Dados para cursor data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

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

    -- Variaveis Gerais
    vr_vlrpctan crapfco.vltarifa%TYPE := 0; -- Valor do Pacote Antigo
    vr_vlrpctnv crapfco.vltarifa%TYPE := 0; -- Valor do Pacote Novo
    vr_qtdtaran INTEGER := 0;               -- Quantidade de Servicos do Antigo Pacote           
    vr_qtdtarnv INTEGER := 0;               -- Quantidade de Servicos do Novo Pacote
    vr_tippesan INTEGER := 0;               -- Tipo de Pessoa do Antigo Pacote   
    vr_tippesnv INTEGER := 0;               -- Tipo de Pessoa do Novo Pacote

    vr_dspctant tbtarif_pacotes.dspacote%TYPE; -- Nome do antigo pacote   
    vr_dspctnov tbtarif_pacotes.dspacote%TYPE; -- Nome do novo pacote
    vr_dsdmensg VARCHAR2(1000):= '';           -- Texto de email para ser exibido no IB
    vr_qtdmeses_desconto INTEGER := 0;
   
    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem   tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE := 8;
    vr_notif_motivo   tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE := 6; 
    
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
       
    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);

    FETCH cr_crapcop INTO rw_crapcop;

    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      vr_cdcritic:= 651;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Verifica se Pacote de Tarifas é valido
    OPEN cr_tbtarif_pacotes_ger(pr_cdpacote => pr_cdpctant); -- Codigo do Pacote

    FETCH cr_tbtarif_pacotes_ger INTO rw_tbtarif_pacotes_ger;

    IF cr_tbtarif_pacotes_ger%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes_ger;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes_ger;
    END IF;    

    IF rw_tbtarif_pacotes_ger.flgsituacao = 0 THEN
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    -- Consulta pacotes nas cooperativas
    OPEN cr_tbtarif_pacotes_coop(pr_cdpacote => pr_cdpctant);

    FETCH cr_tbtarif_pacotes_coop INTO rw_tbtarif_pacotes_coop;

    IF cr_tbtarif_pacotes_coop%FOUND THEN
      CLOSE cr_tbtarif_pacotes_coop;
    ELSE
      CLOSE cr_tbtarif_pacotes_coop;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    END IF;

    -- Consulta nomes dos pacote novos e antigos
    OPEN cr_tbtarif_pacotes_nom(pr_cdpacote => pr_cdpctant);

    FETCH cr_tbtarif_pacotes_nom INTO rw_tbtarif_pacotes_nom;

    IF cr_tbtarif_pacotes_nom%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes_nom;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes_nom;
      vr_dspctant := rw_tbtarif_pacotes_nom.dspacote;
    END IF;

    -- Consulta nomes dos pacote novos e antigos
    OPEN cr_tbtarif_pacotes_nom(pr_cdpacote => pr_cdpctnov);

    FETCH cr_tbtarif_pacotes_nom INTO rw_tbtarif_pacotes_nom;

    IF cr_tbtarif_pacotes_nom%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes_nom;
      vr_dscritic := 'Serviço Cooperativo não encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes_nom;
      vr_dspctnov := rw_tbtarif_pacotes_nom.dspacote;
    END IF;
                                              
    -- Verifica se codigo dos pacotes(Antigo e Novo) sao iguais
    IF pr_cdpctant = pr_cdpctnov THEN
      vr_dscritic := 'Código do novo serviço deve ser diferente do serviço atual.';
      RAISE vr_exc_erro;
    END IF;
                            
    -- Consulta valor do antigo pacote
    OPEN cr_tbtarif_pacotes(pr_cdcooper => vr_cdcooper
                           ,pr_cdpacote => pr_cdpctant); 

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Serviço Cooperativo não encontrado(Antigo).';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;

      IF rw_tbtarif_pacotes.flgsituacao = 0 THEN
        vr_dscritic := 'Serviço Cooperativo não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      vr_vlrpctan := rw_tbtarif_pacotes.vlpacote;
      vr_tippesan := rw_tbtarif_pacotes.tppessoa;
    END IF;  

    -- Consulta valor do novo pacote
    OPEN cr_tbtarif_pacotes(pr_cdcooper => vr_cdcooper
                           ,pr_cdpacote => pr_cdpctnov); 

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Serviço Cooperativo não encontrado(Novo).';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;

      IF rw_tbtarif_pacotes.flgsituacao = 0 THEN
        vr_dscritic := 'Serviço Cooperativo não encontrado.';
        RAISE vr_exc_erro;
      END IF;

      vr_vlrpctnv := rw_tbtarif_pacotes.vlpacote;
      vr_tippesnv := rw_tbtarif_pacotes.tppessoa;
    END IF;                     
      
    -- Verifica tipo de pessoa do novo e antigo pacote
    IF vr_tippesnv <> vr_tippesan THEN
      vr_dscritic := 'Operação não efetuada! Tipo de pessoa do novo serviço não confere com o serviço atual.';
      RAISE vr_exc_erro;
    END IF;
  
    -- Verifica se novo pacote tem valor menor ou igual ao antigo
    IF vr_vlrpctnv > vr_vlrpctan THEN
      vr_dscritic := 'Operação não efetuada! Valor do novo Serviço Cooperativo é superior ao valor do Serviço Cooperativo atual.';
      RAISE vr_exc_erro;
    END IF;
         
    -- Consulta qtd de servicos do antigo pacote
    OPEN cr_tbtarif_servicos(pr_cdpacote => pr_cdpctant);

    FETCH cr_tbtarif_servicos INTO rw_tbtarif_servicos;

    IF cr_tbtarif_servicos%NOTFOUND THEN
      CLOSE cr_tbtarif_servicos;
      vr_dscritic := 'Operação não efetuada! Não existem serviços habilitados para o Serviço Cooperativo informado.';
      RAISE vr_exc_erro;
    ELSE                            
      CLOSE cr_tbtarif_servicos;
      vr_qtdtaran := rw_tbtarif_servicos.qtdservicos;
    END IF;

    -- Consulta qtd de servicos do novo pacote
    OPEN cr_tbtarif_servicos(pr_cdpacote => pr_cdpctnov);

    FETCH cr_tbtarif_servicos INTO rw_tbtarif_servicos;

    IF cr_tbtarif_servicos%NOTFOUND THEN
      CLOSE cr_tbtarif_servicos;
      vr_dscritic := 'Operação não efetuada! Não existem serviços cadastrados para o Serviço Cooperativo informado.';
      RAISE vr_exc_erro;
    ELSE                            
      CLOSE cr_tbtarif_servicos;
      vr_qtdtarnv := rw_tbtarif_servicos.qtdservicos;
    END IF;
        
    -- Verifica qtd de servicos nos pacotes(Novo e Antigo)
    -- Novos pacote devem conter no minimo a mesma quantidade de servicos do pacote antigo
    IF vr_qtdtaran > vr_qtdtarnv THEN
      vr_dscritic := 'Operação não efetuada! O novo Serviço Cooperativo não contempla todos os serviços atuais.';
      RAISE vr_exc_erro;
    END IF;
   
    -- Consulta servicos do pacote antigo
    FOR rw_tbtarif_servicos_ant IN cr_tbtarif_servicos_ant(pr_cdpacote => pr_cdpctant) LOOP
    
      -- Consulta se novo pacote tem tarifas do antigo e se qtd igual ou maior
      OPEN cr_tbtarif_servicos_nov(pr_cdpacote => pr_cdpctnov
                                  ,pr_cdtarifa => rw_tbtarif_servicos_ant.cdtarifa);

      FETCH cr_tbtarif_servicos_nov INTO rw_tbtarif_servicos_nov;                            
      
      -- Verifica se os mesmos servicos do pacote antigo estao contemplados no pacote atual
      IF cr_tbtarif_servicos_nov%NOTFOUND THEN
        CLOSE cr_tbtarif_servicos_nov;
        vr_dscritic := 'Operação não efetuada! O novo Serviço Cooperativo não contempla todos os serviços atuais.';
        RAISE vr_exc_erro;        
      ELSE
        CLOSE cr_tbtarif_servicos_nov;
        -- Verifica se a quantidade de operacoes do pacote atual e igual ou superior a quantidade de operacoes do pacote antigo
        -- Para ser um pacote valido o pacote atual deve contemplar todos os servicos e quantidades de operacoes do pacote antigo
        -- Caso contrario o pacote antigo nao podera ser migrado para o novo
        -- Nao e verificado os servicos a mais que o pacote de servico atual contempla com relacao ao pacote antigo
        IF rw_tbtarif_servicos_nov.qtdoperacoes < rw_tbtarif_servicos_ant.qtdoperacoes THEN
          vr_dscritic := 'Operação não efetuada! Qtd. de operações isentas do novo Serviço Cooperativo é inferior a qtd. de operações do Serviço Cooperativo atual.';
          RAISE vr_exc_erro;  
        END IF;
      END IF;

    END LOOP;
    
    IF pr_cddopcao = 'D' THEN
      -- Migrar tbtarif_contas_pacote
      FOR rw_tbtarif_contas_pacote IN cr_tbtarif_contas_pacote(pr_cdcooper => vr_cdcooper
                                                              ,pr_cdpacote => pr_cdpctant) LOOP
        -- Desativar pacote da conta do cooperado
        BEGIN
          UPDATE 
            tbtarif_contas_pacote
          SET
            tbtarif_contas_pacote.dtcancelamento = rw_crapdat.dtmvtolt,
            tbtarif_contas_pacote.cdoperador_cancela = vr_cdoperad
          WHERE 
            tbtarif_contas_pacote.rowid = rw_tbtarif_contas_pacote.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao desativar Serviço Cooperativo do cooperado, conta: ' || TO_CHAR(rw_tbtarif_contas_pacote.nrdconta) || '. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;       
        END;

        vr_qtdmeses_desconto := rw_tbtarif_contas_pacote.qtdmeses_desconto - (TRUNC(MONTHS_BETWEEN(rw_crapdat.dtmvtolt,rw_tbtarif_contas_pacote.dtinicio_vigencia)) + 1);

        IF vr_qtdmeses_desconto <= 0 THEN
          vr_qtdmeses_desconto := 0;
        END IF;

        BEGIN
          INSERT INTO 
            tbtarif_contas_pacote(
              cdcooper
             ,nrdconta
             ,cdpacote
             ,dtadesao
             ,dtinicio_vigencia
             ,nrdiadebito
             ,indorigem
             ,flgsituacao
             ,perdesconto_manual
             ,qtdmeses_desconto
             ,cdreciprocidade
             ,cdoperador_adesao)
           VALUES(
             rw_tbtarif_contas_pacote.cdcooper
            ,rw_tbtarif_contas_pacote.nrdconta
            ,pr_cdpctnov
            ,rw_crapdat.dtmvtolt 
            ,ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt,'mm'),1)
            ,rw_tbtarif_contas_pacote.nrdiadebito
            ,1
            ,1
            ,rw_tbtarif_contas_pacote.perdesconto_manual
            ,vr_qtdmeses_desconto
            ,rw_tbtarif_contas_pacote.cdreciprocidade
            ,vr_cdoperad);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inseir novo Serviço Cooperativo do cooperado, conta: ' || TO_CHAR(rw_tbtarif_contas_pacote.nrdconta) || '. Erro: ' || SQLERRM;
            RAISE vr_exc_erro;       
        END;

        vr_dsdmensg := 'Caro cooperado, o Serviço Cooperativo ' || TO_CHAR(pr_cdpctant) || '-' || vr_dspctant || ' foi descontinuado pela Cooperativa
                        e substitu&iacute;do pelo serviço ' || TO_CHAR(pr_cdpctnov) || '-' || vr_dspctnov ||'. 
                        O Servi&ccedil;o Cooperativo ' || TO_CHAR(pr_cdpctant) || '-' || vr_dspctant || ' estar&aacute; em vigor at&eacute; o &uacute;ltimo dia do m&ecirc;s corrente.
                        Sua migra&ccedil;&atilde;o para o novo Serviço Cooperativo foi realizada automaticamente. 
                        Entre em contato com a Cooperativa para maiores esclarecimentos.';

        -- crapsnh filtrando por cdcooper , nrdconta, tpdsenha=1, cdsitsnh=1.
        FOR rw_crapsnh IN cr_crapsnh(pr_cdcooper => vr_cdcooper
                                    ,pr_nrdconta => rw_tbtarif_contas_pacote.nrdconta) LOOP

          -- Grava mensagem para ser exibida no IB na conta do cooperado.                
          GENE0003.pc_gerar_mensagem(pr_cdcooper => vr_cdcooper                       -- Cooperativa
                                    ,pr_nrdconta => rw_tbtarif_contas_pacote.nrdconta -- Conta
                                    ,pr_idseqttl => rw_crapsnh.idseqttl               -- Titular
                                    ,pr_cdprogra => 'MANPAC'                          -- Programa
                                    ,pr_inpriori => 0                                 -- Sem prioridade
                                    ,pr_dsdmensg => vr_dsdmensg                       -- Corpo da mensagem
                                    ,pr_dsdassun => 'Migração serviço cooperativo'  -- Assunto da mensagem
                                    ,pr_dsdremet => rw_crapcop.nmrescop               -- Nome da Cooperativa
                                    ,pr_dsdplchv => 'Pacote Tarifas'
                                    ,pr_cdoperad => 1
                                    ,pr_cdcadmsg => 0
                                    ,pr_dscritic => vr_dscritic);

          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;
          -- 
          vr_variaveis_notif('#cdpctant') := TO_CHAR(pr_cdpctant);
          vr_variaveis_notif('#dspctant') := vr_dspctant;
          vr_variaveis_notif('#cdpctnov') := TO_CHAR(pr_cdpctant);
          vr_variaveis_notif('#dspctnov') := vr_dspctant;
          -- Cria uma notificação
          noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                      ,pr_cdmotivo_mensagem => vr_notif_motivo
                                      ,pr_cdcooper => vr_cdcooper
                                      ,pr_nrdconta => rw_tbtarif_contas_pacote.nrdconta
                                      ,pr_idseqttl => rw_crapsnh.idseqttl 
                                      ,pr_variaveis => vr_variaveis_notif); 
          --

        END LOOP;      

      END LOOP;
         
      -- Desativar pacote de tarifas antigo
      BEGIN
        UPDATE 
          tbtarif_pacotes_coop
        SET
          tbtarif_pacotes_coop.flgsituacao = 0,
          tbtarif_pacotes_coop.dtcancelamento = rw_crapdat.dtmvtolt
        WHERE 
          tbtarif_pacotes_coop.cdcooper = vr_cdcooper
          AND tbtarif_pacotes_coop.cdpacote = pr_cdpctant;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao desativar Serviço Cooperativo. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;       
      END;
    END IF;

    COMMIT;

    pr_des_erro := 'OK';

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
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_MIGRA_PACOTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_migra_pacote;

  -- Rotina para consultar dados gerais do pacote de tarifas
  PROCEDURE pc_consult_inf_pcte(pr_cddopcao IN VARCHAR2                                 --> Código da Opcao                                 
                               ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE            --> Codigo do Pacote
                               ,pr_xmllog   IN VARCHAR2                                 --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER                             --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2                                --> Descriçao da crítica
                               ,pr_retxml   IN OUT NOCOPY xmltype                       --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2                                --> Nome do Campo
                               ,pr_des_erro OUT VARCHAR2) IS                            --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_consult_inf_pcte
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : Maio/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para consultar informacoes dos pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
       
    -- CURSORES --
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                             ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tari.dstarifa
            ,tar.flgsituacao
            ,tar.dtmvtolt
            ,tar.dtcancelamento
            ,tar.tppessoa
        FROM tbtarif_pacotes tar,
             craptar tari
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE; 

    CURSOR cr_crapfvl(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE) IS
      SELECT count(fvl.cdtarifa) AS contador
        FROM tbtarif_pacotes tar,
             crapfvl fvl
       WHERE tar.cdpacote = pr_cdpacote
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
     UNION
       SELECT tbtarif_pacotes.cdtarifa_lancamento
         FROM tbtarif_pacotes 
        WHERE tbtarif_pacotes.cdpacote = pr_cdpacote;

    rw_crapfvl cr_crapfvl%ROWTYPE; 
 
    CURSOR cr_tbtarif_servicos(pr_cdpacote tbtarif_servicos.cdpacote%TYPE) IS
      SELECT ser.cdpacote
            ,ser.cdtarifa
            ,tar.dstarifa
            ,ser.qtdoperacoes 
        FROM tbtarif_servicos ser,
             craptar tar
       WHERE ser.cdpacote = pr_cdpacote
         AND ser.cdtarifa = tar.cdtarifa;

    rw_tbtarif_servicos cr_tbtarif_servicos%ROWTYPE;

    CURSOR cr_crapfco(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                     ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT fco.vltarifa AS vlpacote
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND (fco.cdcooper = pr_cdcooper OR pr_cdcooper = 3);

    rw_crapfco cr_crapfco%ROWTYPE;

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
  
    -- Gerais
    vr_auxconta INTEGER := 0;
    vr_vlpacote NUMBER := 0;
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
    
    -- Consulta codigo na tabela para se certificar que codigo e valido e nao havera registro duplicado
    OPEN cr_tbtarif_pacotes(pr_cdpacote => pr_cdpacote
                           ,pr_cdcooper => vr_cdcooper);

    FETCH cr_tbtarif_pacotes INTO rw_tbtarif_pacotes;

    -- Verifica se encontrou registros com o codigo informado
    IF cr_tbtarif_pacotes%NOTFOUND THEN
      CLOSE cr_tbtarif_pacotes;
      vr_dscritic := 'Serviço Cooperativo não encontrado.'; 
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_tbtarif_pacotes;
      IF rw_tbtarif_pacotes.flgsituacao = 0 AND (pr_cddopcao IN('D','H')) THEN
        vr_dscritic := 'Serviço Cooperativo não encontrado.';
        --vr_dscritic := 'Pacote de tarifas já esta cancelado.'; 
        RAISE vr_exc_erro;
      END IF;      
    END IF;

    -- Verifica faixas de valores do pacote
    OPEN cr_crapfvl(pr_cdpacote => pr_cdpacote);

    FETCH cr_crapfvl INTO rw_crapfvl;

    IF cr_crapfvl%NOTFOUND THEN
      -- Fecha cursor
      CLOSE cr_crapfvl;
      FETCH cr_crapfvl INTO rw_crapfvl;
      vr_dscritic := 'Não foi possível obter o valor da tarifa ' || rw_crapfvl.contador ||'. Verifique as faixas de valores';
      RAISE vr_exc_erro;
    ELSE
      -- Fecha cursor
      CLOSE cr_crapfvl;
      IF rw_crapfvl.contador > 1 OR
         rw_crapfvl.contador = 0 THEN
         vr_dscritic := 'Não foi possível obter o valor da tarifa ' || rw_crapfvl.contador ||'. Verifique as faixas de valores';
         RAISE vr_exc_erro;
      ELSE
        OPEN cr_crapfco(pr_cdpacote => pr_cdpacote
                       ,pr_cdcooper => vr_cdcooper);
        
        FETCH cr_crapfco INTO rw_crapfco;

        IF cr_crapfco%NOTFOUND THEN
          CLOSE cr_crapfco; 
          vr_dscritic := 'Valor do Serviço Cooperativo não está cadastrado.';
         RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapfco; 
          vr_vlpacote := rw_crapfco.vlpacote;
        END IF;           
      END IF;      
    END IF;

    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

    -- Informacoes de cabecalho de pacote
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdpacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdpacote), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dspacote', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dspacote), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.cdtarifa_lancamento), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dstarifa), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'flgsitua', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.flgsituacao), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dtmvtolt,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'dtcancel', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.dtcancelamento,'dd/mm/RRRR'), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'tppessoa', pr_tag_cont => TO_CHAR(rw_tbtarif_pacotes.tppessoa), pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf',   pr_posicao => 0, pr_tag_nova => 'vlpacote', pr_tag_cont => TO_CHAR(vr_vlpacote,'999g990d00'), pr_des_erro => vr_dscritic);

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'tar', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
    
    -- Para cada registro de tarifa
    FOR rw_tbtarif_servicos IN cr_tbtarif_servicos(pr_cdpacote => pr_cdpacote) LOOP
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tar', pr_posicao => 0     , pr_tag_nova => 'tarifa', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'cdtarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.cdtarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'dstarifa', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.dstarifa), pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tarifa', pr_posicao => vr_auxconta, pr_tag_nova => 'qtdopera', pr_tag_cont => TO_CHAR(rw_tbtarif_servicos.qtdoperacoes), pr_des_erro => vr_dscritic);

      -- Incrementa contador p/ posicao no XML
      vr_auxconta := vr_auxconta + 1;
    END LOOP;

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'qtd', pr_tag_cont => TO_CHAR(vr_auxconta), pr_des_erro => vr_dscritic);

    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno nao OK          
      pr_des_erro := 'NOK';
    
      IF NVL(vr_cdcritic,0) > 0 THEN
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);       
      END IF;

      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;
    WHEN OTHERS THEN
      -- Retorno nao OK
      pr_des_erro := 'NOK';
      
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_CONSULT_INF_PCTE --> ' || SQLERRM;
      
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');
    
      ROLLBACK;

  END pc_consult_inf_pcte;

  -- Procedure de pesquisa da tela MANPAC
  PROCEDURE pc_pesquisa_manpac(pr_cddopcao         IN VARCHAR2                            --> Código da Opcao
                              ,pr_cdcooper         IN tbtarif_pacotes_coop.cdcooper%TYPE  --> Codigo da Cooperativa
                              ,pr_cdpacote         IN tbtarif_pacotes.cdpacote%TYPE       --> Código do Pacote de Tarifas
                              ,pr_dspacote         IN tbtarif_pacotes.dspacote%TYPE       --> Descricao do Pacote de Tarifas
                              ,pr_nrregist         IN NUMBER                              --> Numero de Registros Exibidos
                              ,pr_nrinireg         IN NUMBER                              --> Registro Inicial
                              ,pr_qtregist        OUT NUMBER                              --> Quantidade de Registros
                              ,pr_tbtarif_pacotes OUT TELA_PACTAR.typ_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                              ,pr_cdcritic        OUT crapcri.cdcritic%TYPE               --> Código da crítica
                              ,pr_dscritic        OUT crapcri.dscritic%TYPE) IS           --> Descriçao da crítica

    /* .............................................................................
    Programa: pc_pesquisa_manpac
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : TARI
    Autor   : Jean Michel
    Data    : Marco/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina geral para consulta de pacotes de tarifas
    
    Alteracoes: 
    ............................................................................. */
        
    -- CURSORES --
    -- Consulta p/ habilitar pacote (OPCAO H)
    CURSOR cr_tbtarif_pacotes(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                             ,pr_dspacote tbtarif_pacotes.dspacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,TRUNC(tar.dtmvtolt) AS dtmvtolt      
            ,TRUNC(tar.dtcancelamento) AS dtcancelamento
            ,tar.tppessoa
            ,decode(tar.tppessoa,1,'PESSOA FISICA',2,'PESSOA JURIDICA',3,'ADMINISTRATIVA','N.A') AS dspessoa
            ,tari.dstarifa AS dstarifa       
        FROM tbtarif_pacotes tar,
             craptar tari
       WHERE (tar.cdpacote = pr_cdpacote OR pr_cdpacote = 0)
         AND (UPPER(tar.dspacote) LIKE UPPER('%' || pr_dspacote || '%') OR TRIM(pr_dspacote) IS NULL)
         AND tar.flgsituacao = 1
         AND tar.cdtarifa_lancamento = tari.cdtarifa
    ORDER BY tar.tppessoa, tar.dspacote;

    rw_tbtarif_pacotes cr_tbtarif_pacotes%ROWTYPE;

    -- Consulta p/ desabilitar pacote (OPCAO D)
    CURSOR cr_tbtarif_pacotes_coop(pr_cdcooper tbtarif_pacotes_coop.cdcooper%TYPE
                                  ,pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                                  ,pr_dspacote tbtarif_pacotes.dspacote%TYPE) IS
      SELECT tar.cdpacote
            ,tar.dspacote
            ,tarcop.cdcooper
            ,tar.cdtarifa_lancamento
            ,tar.flgsituacao
            ,TRUNC(tar.dtmvtolt) AS dtmvtolt      
            ,TRUNC(tar.dtcancelamento) AS dtcancelamento
            ,tar.tppessoa
            ,decode(tar.tppessoa,1,'PESSOA FISICA',2,'PESSOA JURIDICA',3,'ADMINISTRATIVA','N.A') AS dspessoa
            ,tari.dstarifa AS dstarifa       
        FROM tbtarif_pacotes tar,
             craptar tari,
             tbtarif_pacotes_coop tarcop
       WHERE (tar.cdpacote = pr_cdpacote OR pr_cdpacote = 0)
         AND (UPPER(tar.dspacote) LIKE UPPER('%' || pr_dspacote || '%') OR TRIM(pr_dspacote) IS NULL)
         AND tar.flgsituacao = 1
         AND tar.cdpacote = tarcop.cdpacote
         AND tarcop.flgsituacao = 1
         AND tarcop.cdcooper = pr_cdcooper
         AND tar.cdtarifa_lancamento = tari.cdtarifa
    ORDER BY tar.tppessoa, tar.dspacote;

    rw_tbtarif_pacotes_coop cr_tbtarif_pacotes_coop%ROWTYPE;
        
    -- Consulta valor do pacote
    CURSOR cr_crapfco(pr_cdpacote tbtarif_pacotes.cdpacote%TYPE
                     ,pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT fco.vltarifa AS vlpacote
        FROM tbtarif_pacotes tar,
             craptar tari,
             crapfvl fvl,
             crapfco fco
       WHERE tar.cdpacote = pr_cdpacote
         AND tar.cdtarifa_lancamento = tari.cdtarifa
         AND fvl.cdtarifa = tar.cdtarifa_lancamento
         AND fco.cdfaixav = fvl.cdfaixav
         AND fco.flgvigen = 1
         AND (fco.cdcooper = pr_cdcooper OR pr_cdcooper = 3);

    rw_crapfco cr_crapfco%ROWTYPE;

    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    vr_tbtarif_pacotes TELA_PACTAR.typ_tab_tbtarif_pacotes;
    vr_ind_pacotes NUMBER(10);
    
    vr_nrregist NUMBER(10) := 0;
    vr_nrinireg NUMBER(10) := 0;
    vr_vlpacote NUMBER(10,5) := 0;
  BEGIN
    vr_tbtarif_pacotes.DELETE;

    IF pr_cddopcao = 'D' THEN -- pr_cdcooper
      FOR rw_tbtarif_pacotes_coop IN cr_tbtarif_pacotes_coop(pr_cdcooper => pr_cdcooper        --> Codigo da Cooperativa
                                                            ,pr_cdpacote => NVL(pr_cdpacote,0) --> Código do Pacote
                                                            ,pr_dspacote => pr_dspacote)       --> Descricao do Pacote
        LOOP

        EXIT WHEN cr_tbtarif_pacotes_coop%NOTFOUND OR NVL(vr_nrregist,0) = pr_nrregist;

        -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
        vr_ind_pacotes := vr_tbtarif_pacotes.COUNT() + 1;

        IF vr_nrinireg <= vr_nrregist AND vr_nrregist <= pr_nrregist THEN

          OPEN cr_crapfco(pr_cdpacote => rw_tbtarif_pacotes_coop.cdpacote
                         ,pr_cdcooper => rw_tbtarif_pacotes_coop.cdcooper);
              
          FETCH cr_crapfco INTO rw_crapfco;

          IF cr_crapfco%NOTFOUND THEN
            CLOSE cr_crapfco; 
            vr_vlpacote := 0;
          ELSE
            CLOSE cr_crapfco; 
            vr_vlpacote := rw_crapfco.vlpacote;
          END IF;
 
          -- Criar um registro no vetor de extratos a enviar
          vr_tbtarif_pacotes(vr_ind_pacotes).cdpacote            := rw_tbtarif_pacotes_coop.cdpacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspacote            := rw_tbtarif_pacotes_coop.dspacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).cdtarifa_lancamento := rw_tbtarif_pacotes_coop.cdtarifa_lancamento;
          vr_tbtarif_pacotes(vr_ind_pacotes).dstarifa            := SUBSTR(rw_tbtarif_pacotes_coop.dstarifa,0,50);
          vr_tbtarif_pacotes(vr_ind_pacotes).flgsituacao         := rw_tbtarif_pacotes_coop.flgsituacao;
          vr_tbtarif_pacotes(vr_ind_pacotes).dtmvtolt            := NVL(rw_tbtarif_pacotes_coop.dtmvtolt,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).dtcancelamento      := NVL(rw_tbtarif_pacotes_coop.dtcancelamento,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).tppessoa            := rw_tbtarif_pacotes_coop.tppessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspessoa            := rw_tbtarif_pacotes_coop.dspessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).cddopcao            := pr_cddopcao;
          vr_tbtarif_pacotes(vr_ind_pacotes).vlpacote            := vr_vlpacote;
            
          vr_nrregist := NVL(vr_nrregist,0) + 1;
        END IF;

      END LOOP;	

    ELSIF pr_cddopcao = 'H' THEN

      FOR rw_tbtarif_pacotes IN cr_tbtarif_pacotes(pr_cdpacote => NVL(pr_cdpacote,0) --> Código do Pacote
                                                  ,pr_dspacote => pr_dspacote)       --> Descricao do Pacote
        LOOP                                          

        EXIT WHEN cr_tbtarif_pacotes%NOTFOUND OR NVL(vr_nrregist,0) = pr_nrregist;

        -- Buscar qual a quantidade atual de registros no vetor para posicionar na próxima
        vr_ind_pacotes := vr_tbtarif_pacotes.COUNT() + 1;

        IF vr_nrinireg <= vr_nrregist AND vr_nrregist <= pr_nrregist THEN
          -- Criar um registro no vetor de extratos a enviar
          vr_tbtarif_pacotes(vr_ind_pacotes).cdpacote            := rw_tbtarif_pacotes.cdpacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspacote            := rw_tbtarif_pacotes.dspacote;
          vr_tbtarif_pacotes(vr_ind_pacotes).cdtarifa_lancamento := rw_tbtarif_pacotes.cdtarifa_lancamento;
          vr_tbtarif_pacotes(vr_ind_pacotes).dstarifa            := SUBSTR(rw_tbtarif_pacotes.dstarifa,0,50);
          vr_tbtarif_pacotes(vr_ind_pacotes).flgsituacao         := rw_tbtarif_pacotes.flgsituacao;
          vr_tbtarif_pacotes(vr_ind_pacotes).dtmvtolt            := NVL(rw_tbtarif_pacotes.dtmvtolt,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).dtcancelamento      := NVL(rw_tbtarif_pacotes.dtcancelamento,TO_DATE('01/01/1900','dd/mm/RRRR'));
          vr_tbtarif_pacotes(vr_ind_pacotes).tppessoa            := rw_tbtarif_pacotes.tppessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).dspessoa            := rw_tbtarif_pacotes.dspessoa;
          vr_tbtarif_pacotes(vr_ind_pacotes).cddopcao            := pr_cddopcao;
            
          vr_nrregist := NVL(vr_nrregist,0) + 1;
        END IF;

      END LOOP;	

    END IF;    

      pr_tbtarif_pacotes := vr_tbtarif_pacotes;
      pr_qtregist        := vr_tbtarif_pacotes.COUNT();

  EXCEPTION
    WHEN vr_exc_erro THEN
      
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
      ROLLBACK;  

    WHEN OTHERS THEN
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANPAC.PC_PESQUISA_MANPAC --> ' || SQLERRM;
      
      ROLLBACK;
          
  END pc_pesquisa_manpac;

  -- Procedure de pesquisa da tela MANPAC para acessar via PROGRESS
  PROCEDURE pc_pesquisa_manpac_car(pr_cddopcao IN VARCHAR2                           --> Código da Opcao
                                  ,pr_cdcooper IN tbtarif_pacotes_coop.cdcooper%TYPE --> Codigo da Cooperativa                
                                  ,pr_cdpacote IN tbtarif_pacotes.cdpacote%TYPE      --> Código do Pacote de Tarifas
                                  ,pr_dspacote IN tbtarif_pacotes.dspacote%TYPE      --> Descricao do Pacote de Tarifas
                                  ,pr_nrregist IN NUMBER                             --> Numero de Registros Exibidos
                                  ,pr_nrinireg IN NUMBER                             --> Registro Inicial
                                  ,pr_qtregist OUT NUMBER                            --> Quantidade de Registros
                                  ,pr_clobxmlc OUT CLOB                              --> XML com dos Pacotes de tarifas
                                  ,pr_cdcritic OUT crapcri.cdcritic%TYPE             --> Código da crítica
                                  ,pr_dscritic OUT crapcri.dscritic%TYPE) IS         --> Descriçao da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_pesquisa_manpac_car
     Sistema : Novos Produtos de Captaçao
     Sigla   : TARI
     Autor   : Jean Michel
     Data    : Maio/16.                    Ultima atualizacao: 08/03/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a consulta de pacotes de tarifas.

     Observacao: -----

     Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      vr_tab_tbtarif_pacotes TELA_PACTAR.typ_tab_tbtarif_pacotes;
      vr_xml_temp VARCHAR2(32767);

    BEGIN
      -- Leitura de pacote de tarifas
      TELA_MANPAC.pc_pesquisa_manpac(pr_cddopcao        => pr_cddopcao            --> Código da Opcao
                                    ,pr_cdcooper        => pr_cdcooper            --> Codigo da Cooperativa
                                    ,pr_cdpacote        => pr_cdpacote            --> Código do Pacote de Tarifas
                                    ,pr_dspacote        => pr_dspacote            --> Descricao do Pacote de Tarifas
                                    ,pr_nrregist        => pr_nrregist            --> Numero de Registros Exibidos
                                    ,pr_nrinireg        => pr_nrinireg            --> Registro Inicial
                                    ,pr_qtregist        => pr_qtregist            --> Quantidade de Registros
                                    ,pr_tbtarif_pacotes => vr_tab_tbtarif_pacotes --> Tabela com os dados de pacotes
                                    ,pr_cdcritic        => pr_cdcritic            --> Código da crítica
                                    ,pr_dscritic        => pr_dscritic);          --> Descriçao da crítica

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF vr_tab_tbtarif_pacotes.count() > 0 THEN
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
        dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);       

        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
  			
                               
        -- Percorre todas as aplicações de captaçao da conta											 
        FOR vr_contador IN vr_tab_tbtarif_pacotes.FIRST..vr_tab_tbtarif_pacotes.LAST LOOP
          
          IF NOT vr_tab_tbtarif_pacotes.exists(vr_contador) THEN
            CONTINUE;
          END IF;
         
          -- Montar XML com registros de aplicaçao
          gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
                                 ,pr_texto_completo => vr_xml_temp 
                                 ,pr_texto_novo     => '<pacote>'															                    
                                                    ||  '<cdpacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cdpacote),'0') || '</cdpacote>'
                                                    ||  '<dspacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspacote),'0') || '</dspacote>'
                                                    ||  '<cdtarifa_lancamento>' || NVL(vr_tab_tbtarif_pacotes(vr_contador).cdtarifa_lancamento,0) || '</cdtarifa_lancamento>'
                                                    ||  '<flgsituacao>' || NVL(TRIM(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).flgsituacao)),'0') || '</flgsituacao>'
                                                    ||  '<dtmvtolt>' || TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtmvtolt,'dd/mm/RRRR') || '</dtmvtolt>'                                                    
                                                    ||  '<dtcancelamento>' || TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dtcancelamento,'dd/mm/RRRR') || '</dtcancelamento>'
                                                    ||  '<tppessoa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).tppessoa),'0') || '</tppessoa>'
                                                    ||  '<dspessoa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dspessoa),'0') || '</dspessoa>'
                                                    ||  '<cddopcao>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).cddopcao),'0') || '</cddopcao>'
                                                    ||  '<dstarifa>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).dstarifa),'0') || '</dstarifa>'
                                                    ||  '<vlpacote>' || NVL(TO_CHAR(vr_tab_tbtarif_pacotes(vr_contador).vlpacote,'999g990d00'),0) || '</vlpacote>'
                                                    || '</pacote>');	

        END LOOP;
  			
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
		  END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN

        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
					vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
				END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em Consulta de Serviços Cooperativos -> TELA_MANPAC.PC_PESQUISA_MANPAC_CAR: ' || SQLERRM;
    END;

  END pc_pesquisa_manpac_car;

END TELA_MANPAC;
/
