CREATE OR REPLACE PACKAGE CECRED.TELA_MANCEC AS

  PROCEDURE pc_busca_dados(pr_cddopcao IN VARCHAR2 --> Código da Opcao
                          ,pr_cdcmpchq IN NUMBER
                          ,pr_cdbanchq IN NUMBER
                          ,pr_cdagechq IN NUMBER
                          ,pr_nrctachq IN NUMBER
                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

  PROCEDURE pc_grava_dados(pr_cddopcao IN VARCHAR2 --> Código da Opcao
                          ,pr_cdcmpchq IN NUMBER
                          ,pr_cdbanchq IN NUMBER
                          ,pr_cdagechq IN NUMBER
                          ,pr_nrctachq IN NUMBER
                          ,pr_nmemichq IN VARCHAR2
                          ,pr_nrcpfchq IN NUMBER
                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2); --> Saida OK/NOK

END TELA_MANCEC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_MANCEC AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_MANCEC
  --    Autor   : Daniel Zimmermann
  --    Data    : Outubro/2016                   Ultima Atualizacao: 
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela MANCEC
  --
  --    Alteracoes:                              
  --    
  ---------------------------------------------------------------------------------------------------------------

  PROCEDURE pc_busca_dados(pr_cddopcao IN VARCHAR2 --> Código da Opcao
                          ,pr_cdcmpchq IN NUMBER
                          ,pr_cdbanchq IN NUMBER
                          ,pr_cdagechq IN NUMBER
                          ,pr_nrctachq IN NUMBER
                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2) IS
    --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimmermann
    Data    : Outubro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar dados de Emitentes de Cheque
    
    Alteracoes: 
    ............................................................................. */
  
    --- CURSORES ---   
    -- Cursor do Emitentes de Cheque
    CURSOR cr_crapcec(pr_cdcooper IN crapcec.cdcooper%TYPE
                     ,pr_cdcmpchq IN crapcec.cdcmpchq%TYPE
                     ,pr_cdbanchq IN crapcec.cdbanchq%TYPE
                     ,pr_cdagechq IN crapcec.cdagechq%TYPE
                     ,pr_nrctachq IN crapcec.nrctachq%TYPE) IS
      SELECT *
        FROM crapcec cec
       WHERE cec.cdcooper = pr_cdcooper
         AND cec.cdcmpchq = pr_cdcmpchq
         AND cec.cdbanchq = pr_cdbanchq
         AND cec.cdagechq = pr_cdagechq
         AND cec.nrctachq = pr_nrctachq;
    rw_crapcec cr_crapcec%ROWTYPE;
  
    CURSOR cr_crapban(pr_cdbanchq IN crapban.cdbccxlt%TYPE) IS
      SELECT ban.cdbccxlt
        FROM crapban ban
       WHERE ban.cdbccxlt = pr_cdbanchq;
    rw_crapban cr_crapban%ROWTYPE;
  
    --- VARIAVEIS ---
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
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_cdcmpchq = 0 OR
       pr_cdcmpchq IS NULL THEN
      vr_dscritic := 'Compe deve ser Informada.';
      pr_nmdcampo := 'cdcmpchq';
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_cdbanchq = 0 OR
       pr_cdbanchq IS NULL THEN
      vr_dscritic := 'Banco deve ser Informada.';
      pr_nmdcampo := 'cdbanchq';
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_cdagechq = 0 OR
       pr_cdagechq IS NULL THEN
      vr_dscritic := '089 - Agencia devera ser Informada.';
      pr_nmdcampo := 'cdagechq';
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_nrctachq = 0 OR
       pr_nrctachq IS NULL THEN
      vr_dscritic := 'Conta deve ser Informada.';
      pr_nmdcampo := 'nrctachq';
      RAISE vr_exc_erro;
    END IF;
  
    -- Valida se operador tem acesso
    OPEN cr_crapban(pr_cdbanchq => pr_cdbanchq);
    FETCH cr_crapban
      INTO rw_crapban;
  
    -- Verifica se a retornou registro
    IF cr_crapban%NOTFOUND THEN
      CLOSE cr_crapban;
      vr_dscritic := '057 - Banco não Cadastrado.';
      RAISE vr_exc_erro;
    ELSE
      -- Apenas Fecha Cursor
      CLOSE cr_crapban;
    END IF;
  
    OPEN cr_crapcec(pr_cdcooper => vr_cdcooper,
                    pr_cdcmpchq => pr_cdcmpchq,
                    pr_cdbanchq => pr_cdbanchq,
                    pr_cdagechq => pr_cdagechq,
                    pr_nrctachq => pr_nrctachq);
  
    FETCH cr_crapcec
      INTO rw_crapcec;
  
    -- Verifica se a retornou registro
    IF cr_crapcec%NOTFOUND THEN
      CLOSE cr_crapcec;
      IF pr_cddopcao <> 'I' THEN
        vr_dscritic := 'Emitente de Cheque não Encontrado!';
        RAISE vr_exc_erro;
      END IF;
    ELSE
      -- Apenas Fecha o Cursor
      CLOSE cr_crapcec;
      
      IF pr_cddopcao = 'I' THEN
        vr_dscritic := 'Emitente já Cadastrado.';
        RAISE vr_exc_erro;
      END IF;
    END IF;
  
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'inf',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'nrcpfcgc',
                           pr_tag_cont => TO_CHAR(rw_crapcec.nrcpfcgc),
                           pr_des_erro => vr_dscritic);
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'inf',
                           pr_posicao  => 0,
                           pr_tag_nova => 'nmcheque',
                           pr_tag_cont => rw_crapcec.nmcheque,
                           pr_des_erro => vr_dscritic);
  
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
                                     '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                     '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANCEC.PC_BUSCA_DADOS --> ' || SQLERRM;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                     '</Erro></Root>');
    
  END pc_busca_dados;

  PROCEDURE pc_grava_dados(pr_cddopcao IN VARCHAR2 --> Código da Opcao
                          ,pr_cdcmpchq IN NUMBER
                          ,pr_cdbanchq IN NUMBER
                          ,pr_cdagechq IN NUMBER
                          ,pr_nrctachq IN NUMBER
                          ,pr_nmemichq IN VARCHAR2
                          ,pr_nrcpfchq IN NUMBER
                          ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2 --> Nome do Campo
                          ,pr_des_erro OUT VARCHAR2) IS
    --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_grava_dados
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Daniel Zimmermann
    Data    : Outubro/2016                       Ultima atualizacao: 
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    
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
  
    vr_stsnrcal BOOLEAN;
    vr_inpessoa NUMBER;
  
    --Controle de erro
    vr_exc_erro EXCEPTION;
  
    CURSOR cr_crapcst(pr_cdcooper IN crapcst.cdcooper%TYPE
                     ,pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                     ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                     ,pr_cdagechq IN crapcst.cdagechq%TYPE
                     ,pr_nrctachq IN crapcst.nrctachq%TYPE) IS
      SELECT cst.cdcooper
        FROM crapcst cst
       WHERE cst.cdcooper = pr_cdcooper
         AND cst.cdcmpchq = pr_cdcmpchq
         AND cst.cdbanchq = pr_cdbanchq
         AND cst.cdagechq = pr_cdagechq
         AND cst.nrctachq = pr_nrctachq;
    rw_crapcst cr_crapcst%ROWTYPE;
  
    CURSOR cr_crapcdb(pr_cdcooper IN crapcst.cdcooper%TYPE
                     ,pr_cdcmpchq IN crapcst.cdcmpchq%TYPE
                     ,pr_cdbanchq IN crapcst.cdbanchq%TYPE
                     ,pr_cdagechq IN crapcst.cdagechq%TYPE
                     ,pr_nrctachq IN crapcst.nrctachq%TYPE) IS
      SELECT cdb.cdcooper
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.cdcmpchq = pr_cdcmpchq
         AND cdb.cdbanchq = pr_cdbanchq
         AND cdb.cdagechq = pr_cdagechq
         AND cdb.nrctachq = pr_nrctachq;
    rw_crapcdb cr_crapcdb%ROWTYPE;
  
  BEGIN
  
    pr_des_erro := 'OK';
  
    -- Recupera dados de log para consulta posterior
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);
  
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
  
    IF TRIM(pr_nmemichq) IS NULL THEN
      vr_dscritic := 'Nome do Emitente deve ser informado.';
      pr_nmdcampo := 'nmemichq';
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_nrcpfchq = 0 OR
       pr_nrcpfchq IS NULL THEN
      vr_dscritic := 'CPF/CNPJ do Emitente deve ser informado.';
      pr_nmdcampo := 'nrcpfchq';
      RAISE vr_exc_erro;
    END IF;
  
    -- Validar CPF/CNPJ
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_nrcpfchq,
                                pr_stsnrcal => vr_stsnrcal,
                                pr_inpessoa => vr_inpessoa);
  
    -- CPF ou CNPJ inválido
    IF NOT vr_stsnrcal THEN
      -- Atribui crítica
      vr_dscritic := '27 - CPF/CNPJ com Erro.';
      -- Levanta exceção
      RAISE vr_exc_erro;
    END IF;
  
    IF pr_cddopcao = 'I' THEN
      BEGIN
        INSERT INTO crapcec
          (crapcec.cdcooper,
           crapcec.cdcmpchq,
           crapcec.cdbanchq,
           crapcec.cdagechq,
           crapcec.nrctachq,
           crapcec.nrdconta,
           crapcec.nmcheque,
           crapcec.nrcpfcgc)
        VALUES
          (vr_cdcooper,
           pr_cdcmpchq,
           pr_cdbanchq,
           pr_cdagechq,
           pr_nrctachq,
           0,
           UPPER(pr_nmemichq),
           pr_nrcpfchq);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir Emitente. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    END IF;
  
    IF pr_cddopcao = 'A' THEN
      BEGIN
        UPDATE crapcec cec
           SET cec.nmcheque = TRIM(UPPER(pr_nmemichq)),
               cec.nrcpfcgc = pr_nrcpfchq
         WHERE cec.cdcooper = vr_cdcooper
           AND cec.cdcmpchq = pr_cdcmpchq
           AND cec.cdbanchq = pr_cdbanchq
           AND cec.cdagechq = pr_cdagechq
           AND cec.nrctachq = pr_nrctachq
           AND cec.nrdconta = 0;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar Emitente. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    END IF;
  
    IF pr_cddopcao = 'E' THEN
    
      OPEN cr_crapcst(pr_cdcooper => vr_cdcooper,
                      pr_cdcmpchq => pr_cdcmpchq,
                      pr_cdbanchq => pr_cdbanchq,
                      pr_cdagechq => pr_cdagechq,
                      pr_nrctachq => pr_nrctachq);
    
      FETCH cr_crapcst
        INTO rw_crapcst;
    
      -- Verifica se a retornou registro
      IF cr_crapcst%FOUND THEN
        CLOSE cr_crapcst;
        vr_dscritic := 'Emitente Possui Cheques em Custodia!';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapcst;
      END IF;
    
      OPEN cr_crapcdb(pr_cdcooper => vr_cdcooper,
                      pr_cdcmpchq => pr_cdcmpchq,
                      pr_cdbanchq => pr_cdbanchq,
                      pr_cdagechq => pr_cdagechq,
                      pr_nrctachq => pr_nrctachq);
    
      FETCH cr_crapcdb
        INTO rw_crapcdb;
    
      -- Verifica se a retornou registro
      IF cr_crapcdb%FOUND THEN
        CLOSE cr_crapcdb;
        vr_dscritic := 'Emitente Possui Cheques em Desconto!';
        RAISE vr_exc_erro;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapcdb;
      END IF;
    
      BEGIN
        DELETE FROM crapcec cec
         WHERE cec.cdcooper = vr_cdcooper
           AND cec.cdcmpchq = pr_cdcmpchq
           AND cec.cdbanchq = pr_cdbanchq
           AND cec.cdagechq = pr_cdagechq
           AND cec.nrctachq = pr_nrctachq
           AND cec.nrdconta = 0;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Excluir Emitente. Erro: ' || SQLERRM;
          RAISE vr_exc_erro;
      END;
    
    END IF;
  
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
                                     '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                     '</Erro></Root>');
    
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';
    
      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_MANCEC.PC_GRAVA_DADOS --> ' || SQLERRM;
    
      -- Existe para satisfazer exigência da interface. 
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' || pr_dscritic ||
                                     '</Erro></Root>');
    
  END pc_grava_dados;

END TELA_MANCEC;
/
