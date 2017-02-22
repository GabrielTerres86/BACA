CREATE OR REPLACE PACKAGE CECRED.TELA_CADPAA AS

  -- LISTAS AS COOPERATIVAS A SEREM LISTADAS NA TELA
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo

  -- LISTAS OS RATEIOS A SEREM LISTADOS NA TELA
  PROCEDURE pc_lista_rateio(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
  -- REALIZA A BUSCA DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_busca_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                             ,pr_cdpaadmi   IN NUMBER
                             ,pr_cddopcao   IN VARCHAR2
                             ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
  -- REALIZA A INCLUSÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_inclui_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                              ,pr_cdpaadmi   IN NUMBER
                              ,pr_dspaadmi   IN VARCHAR2
                              ,pr_tprateio   IN NUMBER
                              ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
  -- REALIZA A ALTERAÇÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_altera_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                              ,pr_cdpaadmi   IN NUMBER
                              ,pr_dspaadmi   IN VARCHAR2
                              ,pr_tprateio   IN NUMBER
                              ,pr_flgativo   IN NUMBER
                              ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
  -- REALIZA A REPLICAÇÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_replica_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                               ,pr_cdpaadmi   IN NUMBER
                               ,pr_lscooper   IN VARCHAR2
                               ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
  
END TELA_CADPAA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADPAA AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_CADPAA 
  --    Autor   : Renato Darosci/SUPERO
  --    Data    : novembro/2016                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela CADPAA
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  -- CONSTANTES
  vr_dsarqlog     CONSTANT VARCHAR2(100) := 'cadpaa.log';
  
  
  -- REGISTRAR OS REGISTROS DE LOG NA LOGTEL
  PROCEDURE pc_gera_log(pr_cdcooper  IN NUMBER
                       ,pr_cdoperad  IN VARCHAR2
                       ,pr_des_log   IN VARCHAR2) IS
  
  BEGIN
    
    -- gerar log
    BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => vr_dsarqlog 
                              ,pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                  ' -->  CADPAA - '||pr_cdoperad||' - '|| pr_des_log);
  
  END pc_gera_log;
  
  
  -- LISTAS AS COOPERATIVAS A SEREM LISTADAS NA TELA
  PROCEDURE pc_lista_coop_pesquisa(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                  ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_lista_coop_pesquisa
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Junho/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza listagem das cooperativas que serão listadas nos
                  parametros da tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    -- Cursores
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
           , cop.cdcooper||' - '||cop.nmrescop  nmrescop
        FROM crapcop  cop
       ORDER BY cop.cdcooper;

    /*-- Variáveis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);*/

    -- Excessões
    vr_exc_erro         EXCEPTION;

  BEGIN

    /*-- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);
*/
    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Para cada cooperativa encontrada
     FOR rw_crapcop IN cr_crapcop LOOP

       -- Criar nodo filho
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<coop>'||
                                                   '<cdcooper>'||rw_crapcop.cdcooper||'</cdcooper>'||
                                                   '<nmrescop>'||rw_crapcop.nmrescop||'</nmrescop>'||
                                                   '</coop>'));

     END LOOP;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina pc_lista_coop_pesquisa: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_coop_pesquisa;
  
  
  -- LISTAS OS RATEIOS A SEREM LISTADOS NA TELA
  PROCEDURE pc_lista_rateio(pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                           ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                           ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                           ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                           ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                           ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_lista_rateio
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Novembro/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza listagem dos tipo de rateio que serão listadas nos
                  parametros da tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    -- Cursores
    CURSOR cr_craptab IS
      SELECT t.tpregist
           , t.dstextab
        FROM craptab t 
       WHERE t.cdcooper = 0
         AND t.nmsistem = 'CRED'
         AND t.tptabela = 'CONFIG'
         AND t.cdempres = 0
         AND t.cdacesso = 'CADPAA_TPRATEIO'
       ORDER BY t.dstextab;

  BEGIN

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Para cada cooperativa encontrada
     FOR rw_craptab IN cr_craptab LOOP

       -- Criar nodo filho
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<tipo>'||
                                                   '<codigo>'||rw_craptab.tpregist||'</codigo>'||
                                                   '<descricao>'||rw_craptab.dstextab||'</descricao>'||
                                                   '</tipo>'));

     END LOOP;


  EXCEPTION
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina PC_LISTA_RATEIO: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_rateio;
  
  -- REALIZA A BUSCA DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_busca_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                             ,pr_cdpaadmi   IN NUMBER
                             ,pr_cddopcao   IN VARCHAR2
                             ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                             ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_busca_pa_admin
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Novembro/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza a busca dos dados da tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    
    -- CURSORES
    
    -- Buscar os dados para a tela CADPAA
    CURSOR cr_crpaadm IS
      SELECT t.dspa_admin
           , t.tprateio
           , t.flgativo
           , to_char(t.dtinclusao, 'DD/MM/YYYY') dtinclusao
           , t.cdoperad_inclusao
           , to_char(t.dtalteracao, 'DD/MM/YYYY') dtalteracao
           , t.cdoperad_alteracao
           , to_char(t.dtinativacao, 'DD/MM/YYYY') dtinativacao
           , t.cdoperad_inativacao
        FROM tbbi_pa_admin t
       WHERE t.cdcooper   = pr_cdcooper
         AND t.cdpa_admin = pr_cdpaadmi;
    rw_crpaadm   cr_crpaadm%ROWTYPE;
    
    -- Buscar o operador
    CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                     ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
      SELECT UPPER(ope.cdoperad)||' - '||ope.nmoperad  dsoperad
        FROM crapope ope
       WHERE UPPER(ope.cdoperad) = UPPER(pr_cdoperad)
         AND ope.cdcooper        = pr_cdcooper;
    
    -- Buscar todas as cooperativas onde o código já não esteja registrado
    CURSOR cr_crapcop IS
      SELECT t.cdcooper||' - '||t.nmrescop  dscooper
           , t.cdcooper
        FROM crapcop t
       WHERE t.cdcooper <> pr_cdcooper  -- Apenas para garantir(não seria necessário visto que jah há cadastro)
         AND NOT EXISTS (SELECT 1  
                           FROM tbbi_pa_admin a
                          WHERE a.cdcooper   = t.cdcooper
                            AND a.cdpa_admin = pr_cdpaadmi)
      ORDER BY t.cdcooper;
    
    -- VARIÁVEIS
    vr_nmoperad    VARCHAR2(100);
    vr_dscritic    VARCHAR2(100);
    vr_nrposicao   NUMBER;
    
    -- EXCEPTION
    vr_exc_erro    EXCEPTION;
    
  BEGIN
    
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
     
    -- Buscar os dados da cooperativa administrativa
    OPEN  cr_crpaadm;
    FETCH cr_crpaadm INTO rw_crpaadm;
    
    -- Se não for encontrado registro
    IF cr_crpaadm%NOTFOUND THEN
      pr_des_erro := 'Codigo informado nao encontrado para a cooperativa.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_crpaadm;
    
    ---------------------- ## TAG ## ----------------------
    -- Descrição do PA Administrativo
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dspa_admn'
                          ,pr_tag_cont => rw_crpaadm.dspa_admin
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Tipo do Rateio
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'tprateio'
                          ,pr_tag_cont => rw_crpaadm.tprateio
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Flag de ativo ou inativo
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'flgativo'
                          ,pr_tag_cont => rw_crpaadm.flgativo
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------        
    -- Data de inclusão
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtinclus'
                          ,pr_tag_cont => rw_crpaadm.dtinclusao
                          ,pr_des_erro => vr_dscritic);
     
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Se há usuário
    IF rw_crpaadm.cdoperad_inclusao IS NOT NULL THEN
      -- Buscar o nome do usuário 
      OPEN  cr_crapope(pr_cdcooper,rw_crpaadm.cdoperad_inclusao);
      FETCH cr_crapope INTO vr_nmoperad;
      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN
        vr_nmoperad := 'USUARIO NAO ENCONTRADO';
      END IF;
      CLOSE cr_crapope;
    ELSE 
      vr_nmoperad := NULL;
    END IF;
    
    -- Usuário de inclusao
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'cdopeinc'
                          ,pr_tag_cont => vr_nmoperad
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Data de alteração 
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtaltera'
                          ,pr_tag_cont => rw_crpaadm.dtalteracao
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Se há usuário
    IF rw_crpaadm.cdoperad_alteracao IS NOT NULL THEN
      -- Buscar o nome do usuário de alteração
      OPEN  cr_crapope(pr_cdcooper,rw_crpaadm.cdoperad_alteracao);
      FETCH cr_crapope INTO vr_nmoperad;
      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN
        vr_nmoperad := 'USUARIO NAO ENCONTRADO';
      END IF;
      CLOSE cr_crapope;
    ELSE 
      vr_nmoperad := NULL;
    END IF;
    
    -- Usuário de alteração
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'cdopealt'
                          ,pr_tag_cont => vr_nmoperad
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Data de inativação
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'dtinativ'
                          ,pr_tag_cont => rw_crpaadm.dtinativacao
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    -- Se há usuário
    IF rw_crpaadm.cdoperad_inativacao IS NOT NULL THEN
      -- Buscar o nome do usuário de inativação
      OPEN  cr_crapope(pr_cdcooper,rw_crpaadm.cdoperad_inativacao);
      FETCH cr_crapope INTO vr_nmoperad;
      -- Se não encontrar registro
      IF cr_crapope%NOTFOUND THEN
        vr_nmoperad := 'USUARIO NAO ENCONTRADO';
      END IF;
      CLOSE cr_crapope;
    ELSE 
      vr_nmoperad := NULL;
    END IF;
    
    -- Usuário de inativação
    GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                          ,pr_tag_pai  => 'Root'
                          ,pr_posicao  => 0
                          ,pr_tag_nova => 'cdopeina'
                          ,pr_tag_cont => vr_nmoperad
                          ,pr_des_erro => vr_dscritic);
    
    -- verifica a ocorrencia de erros
    IF vr_dscritic IS NOT NULL THEN
      pr_des_erro := vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    ---------------------- ## TAG ## ----------------------
    
    -- Se a opção for replicação
    IF pr_cddopcao = 'R' THEN
    
      -- Cooperativas para replicação
      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'replica'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);
    
      -- verifica a ocorrencia de erros
      IF vr_dscritic IS NOT NULL THEN
        pr_des_erro := vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
    
      vr_nrposicao := 0;
    
      -- Buscar todas as cooperativas onde o código já não esteja registrado
      FOR rw_crapcop IN cr_crapcop LOOP
        
        -- Cooperativas para replicação
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'replica'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cooper'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);
      
        -- verifica a ocorrencia de erros
        IF vr_dscritic IS NOT NULL THEN
          pr_des_erro := vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        -- Inserir os nós filhos
        -- Cooperativas para replicação
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'cooper'
                              ,pr_posicao  => vr_nrposicao
                              ,pr_tag_nova => 'cdcooper'
                              ,pr_tag_cont => rw_crapcop.cdcooper
                              ,pr_des_erro => vr_dscritic);
      
        -- verifica a ocorrencia de erros
        IF vr_dscritic IS NOT NULL THEN
          pr_des_erro := vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        -- Cooperativas para replicação
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'cooper'
                              ,pr_posicao  => vr_nrposicao
                              ,pr_tag_nova => 'dscooper'
                              ,pr_tag_cont => rw_crapcop.dscooper
                              ,pr_des_erro => vr_dscritic);
      
        -- verifica a ocorrencia de erros
        IF vr_dscritic IS NOT NULL THEN
          pr_des_erro := vr_dscritic;
          RAISE vr_exc_erro;
        END IF;
        
        vr_nrposicao := nvl(vr_nrposicao,0) + 1;
        
      END LOOP; -- Loop cooperativas
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');          
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina PC_BUSCA_PA_ADMIN: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_busca_pa_admin;
  
  
  -- REALIZA A INCLUSÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_inclui_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                              ,pr_cdpaadmi   IN NUMBER
                              ,pr_dspaadmi   IN VARCHAR2
                              ,pr_tprateio   IN NUMBER
                              ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_inclui_pa_admin
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Novembro/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza a inclusão dos dados informados na tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    
    -- VARIÁVEIS
    vr_cdcooper    crapcop.cdcooper%TYPE;
    vr_cdoperad    VARCHAR2(100);
    vr_nmdatela    VARCHAR2(100);
    vr_nmeacao     VARCHAR2(100);
    vr_cdagenci    VARCHAR2(100);
    vr_nrdcaixa    VARCHAR2(100);
    vr_idorigem    VARCHAR2(100);
    vr_dscritic    VARCHAR2(100);
    
    -- EXCEPTION
    vr_exc_erro    EXCEPTION;
    
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
  
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
     
    -- Inserir o registro
    BEGIN
      INSERT INTO tbbi_pa_admin(cdcooper
                               ,cdpa_admin
                               ,dspa_admin
                               ,tprateio
                               ,flgativo
                               ,dtinclusao
                               ,cdoperad_inclusao)
                         VALUES(pr_cdcooper        -- cdcooper
                               ,pr_cdpaadmi        -- cdpa_admin
                               ,UPPER(pr_dspaadmi) -- dspa_admin
                               ,pr_tprateio        -- tprateio
                               ,1                  -- flgativo
                               ,TRUNC(SYSDATE)     -- dtinclusao
                               ,vr_cdoperad);      -- cdoperad_inclusao
    
    EXCEPTION
      WHEN dup_val_on_index THEN
        pr_des_erro := 'Codigo informado ja cadastrado para a cooperativa.';
        RAISE vr_exc_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro ao inserir TBBI_PA_ADMIN: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Gerar o registro de log - Na cooperativa conectada ##LOG##
    pc_gera_log(vr_cdcooper
               ,vr_cdoperad
               ,'Inclusão PA Administrativo: Coop: '||pr_cdcooper||' - Codigo: '||pr_cdpaadmi||'.');
              
    
    -- Gravar as informações na base de dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');          
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina PC_INCLUI_PA_ADMIN: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_inclui_pa_admin;
  
  -- REALIZA A ALTERAÇÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_altera_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                              ,pr_cdpaadmi   IN NUMBER
                              ,pr_dspaadmi   IN VARCHAR2
                              ,pr_tprateio   IN NUMBER
                              ,pr_flgativo   IN NUMBER
                              ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_altera_pa_admin
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Novembro/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza a alteração dos dados informados na tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    -- CURSORES
    CURSOR cr_crpaadmin IS
      SELECT t.flgativo
           , t.dtinativacao
           , t.cdoperad_inativacao
        FROM tbbi_pa_admin t
       WHERE t.cdcooper   = pr_cdcooper
         AND t.cdpa_admin = pr_cdpaadmi;
    rw_crpaadmin  cr_crpaadmin%ROWTYPE;
     
    -- VARIÁVEIS
    vr_cdcooper      crapcop.cdcooper%TYPE;
    vr_cdoperad      VARCHAR2(100);
    vr_nmdatela      VARCHAR2(100);
    vr_nmeacao       VARCHAR2(100);
    vr_cdagenci      VARCHAR2(100);
    vr_nrdcaixa      VARCHAR2(100);
    vr_idorigem      VARCHAR2(100);
    vr_dscritic      VARCHAR2(100);
    
    vr_dtinativacao  tbbi_pa_admin.dtinativacao%TYPE := NULL;
    vr_cdopinativa   tbbi_pa_admin.cdoperad_inativacao%TYPE := NULL;
    
    -- EXCEPTION
    vr_exc_erro    EXCEPTION;
    
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
  
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Buscar pelo registro do PA Administrativo
    OPEN  cr_crpaadmin;
    FETCH cr_crpaadmin INTO rw_crpaadmin;
    
    -- Se não encontrar o registro
    IF cr_crpaadmin%NOTFOUND THEN
      pr_des_erro := 'Codigo informado nao encontrado para a cooperativa.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar o cursor
    CLOSE cr_crpaadmin;
    
    -- Atualiza variáveis com o valor atual
    vr_dtinativacao := rw_crpaadmin.dtinativacao;
    vr_cdopinativa  := rw_crpaadmin.cdoperad_inativacao;
    
    -- Se houve alteração no flag de ativo para inativo
    IF rw_crpaadmin.flgativo <> pr_flgativo THEN
      IF pr_flgativo = 0 THEN
        -- Preenche os campos com os dados da inativação 
        vr_dtinativacao := TRUNC(SYSDATE);
        vr_cdopinativa  := vr_cdoperad;
      ELSE
        -- Limpar os campos pois o registro foi reativado
        vr_dtinativacao := NULL;
        vr_cdopinativa  := NULL;
      END IF;
    END IF;
    
    -- Atualizar o registro
    BEGIN
      UPDATE tbbi_pa_admin
         SET dspa_admin          = pr_dspaadmi
           , tprateio            = pr_tprateio
           , flgativo            = pr_flgativo
           , dtalteracao         = TRUNC(SYSDATE)
           , cdoperad_alteracao  = vr_cdoperad
           , dtinativacao        = vr_dtinativacao
           , cdoperad_inativacao = vr_cdopinativa
       WHERE cdcooper            = pr_cdcooper
         AND cdpa_admin          = pr_cdpaadmi;
        
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro ao atualizar TBBI_PA_ADMIN: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    -- Gerar o registro de log - Na cooperativa conectada ##LOG##
    pc_gera_log(vr_cdcooper
               ,vr_cdoperad
               ,'Alteração PA Administrativo: Coop: '||pr_cdcooper||' - Codigo: '||pr_cdpaadmi||'.');
    
    -- Se houve alteração no flag de ativo para inativo
    IF rw_crpaadmin.flgativo <> pr_flgativo THEN
      IF pr_flgativo = 0 THEN
        -- Gerar o registro de log - Na cooperativa conectada ##LOG##
        pc_gera_log(vr_cdcooper
                   ,vr_cdoperad
                   ,'Inativação de PA Administrativo: Coop: '||pr_cdcooper||' - Codigo: '||pr_cdpaadmi||'.');
      ELSE
        -- Gerar o registro de log - Na cooperativa conectada ##LOG##
        pc_gera_log(vr_cdcooper
                   ,vr_cdoperad
                   ,'Ativação de PA Administrativo: Coop: '||pr_cdcooper||' - Codigo: '||pr_cdpaadmi||'.');
      END IF;
    END IF;
    
    -- Gravar as informações na base de dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');          
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina PC_ALTERA_PA_ADMIN: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_altera_pa_admin;
  
  -- REALIZA A REPLICAÇÃO DO REGISTRO DO PA ADMINISTRATIVO
  PROCEDURE pc_replica_pa_admin(pr_cdcooper   IN NUMBER              --> COOPERATIVA DA TELA
                               ,pr_cdpaadmi   IN NUMBER
                               ,pr_lscooper   IN VARCHAR2
                               ,pr_xmllog     IN VARCHAR2            --> XML com informações de LOG
                               ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                               ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                               ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                               ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                               ,pr_des_erro  OUT VARCHAR2) IS        --> Erros do processo

    /* .............................................................................

      Programa: pc_inclui_pa_admin
      Sistema : Conta-Corrente - Cooperativa de Credito
      Sigla   : CRED
      Autor   : Renato Darosci/SUPERO
      Data    : Novembro/2016                       Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Realiza a inclusão dos dados informados na tela CADPAA
      Observacao: -----

      Alteracoes:

    ..............................................................................*/
    
    -- Buscar os dados para a tela CADPAA
    CURSOR cr_crpaadm IS
      SELECT t.cdpa_admin
           , t.dspa_admin
           , t.tprateio
        FROM tbbi_pa_admin t
       WHERE t.cdcooper   = pr_cdcooper
         AND t.cdpa_admin = pr_cdpaadmi;
    rw_crpaadm   cr_crpaadm%ROWTYPE;
    
    -- VARIÁVEIS
    vr_cdcooper    crapcop.cdcooper%TYPE;
    vr_cdoperad    VARCHAR2(100);
    vr_nmdatela    VARCHAR2(100);
    vr_nmeacao     VARCHAR2(100);
    vr_cdagenci    VARCHAR2(100);
    vr_nrdcaixa    VARCHAR2(100);
    vr_idorigem    VARCHAR2(100);
    vr_dscritic    VARCHAR2(100);
    
    vr_tbcooper    GENE0002.typ_split;
    
    -- EXCEPTION
    vr_exc_erro    EXCEPTION;
    
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
  
    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    
    -- Quebrar a lista de cooperativas
    vr_tbcooper := GENE0002.fn_quebra_string(pr_string => pr_lscooper, pr_delimit => ';');
    
    -- Verificar se foram informados registros
    IF vr_tbcooper.count() = 0 THEN
      pr_des_erro := 'Nao ha cooperativas selecionadas, verifique.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar o PA administrativo referencia
    OPEN  cr_crpaadm;
    FETCH cr_crpaadm INTO rw_crpaadm;
    
    -- Se não encontrar o registro
    IF cr_crpaadm%NOTFOUND THEN
      pr_des_erro := 'PA de refencia para replica nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Fechar
    CLOSE cr_crpaadm;
    
    -- Percorrer as cooperativas informadas
    FOR ind IN vr_tbcooper.FIRST..vr_tbcooper.LAST LOOP
    
      -- Se o código da cooperativa for Nulo ignora pois é a ultima posição do cursor
      IF vr_tbcooper(ind) IS NULL THEN
        CONTINUE; -- pula o registro
      END IF;
    
      -- Inserir o registro
      BEGIN
        INSERT INTO tbbi_pa_admin(cdcooper
                                 ,cdpa_admin
                                 ,dspa_admin
                                 ,tprateio
                                 ,flgativo
                                 ,dtinclusao
                                 ,cdoperad_inclusao)
                           VALUES(vr_tbcooper(ind)      -- cdcooper
                                 ,rw_crpaadm.cdpa_admin -- cdpa_admin
                                 ,rw_crpaadm.dspa_admin -- dspa_admin
                                 ,rw_crpaadm.tprateio   -- tprateio
                                 ,1                     -- flgativo -- Sempre incluir como ATIVO
                                 ,TRUNC(SYSDATE)        -- dtinclusao
                                 ,vr_cdoperad);         -- cdoperad_inclusao
      
      EXCEPTION
        WHEN dup_val_on_index THEN
          pr_des_erro := 'Codigo informado ja cadastrado para a cooperativa.';
          RAISE vr_exc_erro;
        WHEN OTHERS THEN
          pr_des_erro := 'Erro ao inserir TBBI_PA_ADMIN: '||SQLERRM;
          RAISE vr_exc_erro;
      END;
    
      -- Gerar o registro de log - Na cooperativa conectada ##LOG##
      pc_gera_log(vr_cdcooper
                 ,vr_cdoperad
                 ,'PA Administrativo: Coop: '||vr_tbcooper(ind)||' - Codigo: '||rw_crpaadm.cdpa_admin||', replicado a partir do PA: '||
                                     'Coop: '||pr_cdcooper||' - Codigo: '||pr_cdpaadmi||'.');
    END LOOP;
    
    -- Gravar as informações na base de dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');          
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_des_erro := 'Erro geral na rotina PC_REPLICA_PA_ADMIN: '||SQLERRM;
      pr_dscritic := pr_des_erro;

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_replica_pa_admin;
  
  
END TELA_CADPAA;
/
