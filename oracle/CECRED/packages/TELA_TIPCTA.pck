CREATE OR REPLACE PACKAGE CECRED.TELA_TIPCTA IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TIPCTA
  --  Sistema  : Rotinas utilizadas pela Tela TIPCTA
  --  Sigla    : EMPR
  --  Autor    : Lombardi
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TIPCTA
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  

  PROCEDURE pc_buscar_tipo_de_conta(pr_inpessoa       IN tbcc_tipo_conta.inpessoa%TYPE
                                   ,pr_cdtipo_conta   IN tbcc_tipo_conta.cdtipo_conta%TYPE
                                   ,pr_xmllog         IN VARCHAR2 --> XML com informa��es de LOG
                                   ,pr_cdcritic      OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic      OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml         IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro      OUT VARCHAR2); --> Erros do processo
                                   
  PROCEDURE pc_incluir_tipo_de_conta(pr_inpessoa               IN INTEGER --> Tipo de pessoa
                                    ,pr_dstipo_conta           IN VARCHAR2 --> Descri�ao do tipo de conta
                                    ,pr_individual             IN INTEGER --> Categoria individual
                                    ,pr_conjunta_solidaria     IN INTEGER --> Categoria conjunta solidaria
                                    ,pr_conjunta_nao_solidaria IN INTEGER --> Categoria conjunta n�o solidaria
                                    ,pr_tpcadast               IN INTEGER --> Tipo de cadastro
                                    ,pr_cdmodali               IN INTEGER --> Modalidade
                                    ,pr_indconta_itg           IN INTEGER --> Flag Conta integracao
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2); --> Erros do processo
                                    
  PROCEDURE pc_alterar_tipo_de_conta(pr_inpessoa               IN INTEGER --> tipo de pessoa
                                    ,pr_cdtipo_conta           IN INTEGER --> Codigo do tipo de conta
                                    ,pr_dstipo_conta           IN VARCHAR2 --> Descri�ao do tipo de conta
                                    ,pr_individual             IN INTEGER --> Categoria individual
                                    ,pr_conjunta_solidaria     IN INTEGER --> Categoria conjunta solidaria
                                    ,pr_conjunta_nao_solidaria IN INTEGER --> Categoria conjunta n�o solidaria
                                    ,pr_tpcadast               IN INTEGER --> Tipo de cadastro
                                    ,pr_cdmodali               IN INTEGER --> Modalidade
                                    ,pr_indconta_itg           IN INTEGER --> Flag Conta integracao
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2); --> Erros do processo
                                    
  PROCEDURE pc_excluir_tipo_de_conta(pr_inpessoa               IN INTEGER --> tipo de pessoa
                                    ,pr_cdtipo_conta           IN INTEGER --> Codigo do tipo de conta
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2); --> Erros do processo
                                    
  PROCEDURE pc_transferir_contas(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                ,pr_cdcooper   IN INTEGER --> C�digo da cooperativa
                                ,pr_tipcta_ori IN INTEGER --> Codigo tipo de conta de origem
                                ,pr_tipcta_des IN INTEGER --> Codigo tipo de conta de destino
                                ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2); --> Erros do processo
END TELA_TIPCTA;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TIPCTA IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TIPCTA
  --  Sistema  : Rotinas utilizadas pela Tela TIPCTA
  --  Sigla    : EMPR
  --  Autor    : Lombardi
  --  Data     : Dezembro - 2017.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TIPCTA
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_buscar_tipo_de_conta(pr_inpessoa      IN tbcc_tipo_conta.inpessoa%TYPE
                                   ,pr_cdtipo_conta  IN tbcc_tipo_conta.cdtipo_conta%TYPE
                                   ,pr_xmllog        IN VARCHAR2 --> XML com informa��es de LOG
                                   ,pr_cdcritic     OUT PLS_INTEGER --> C�digo da cr�tica
                                   ,pr_dscritic     OUT VARCHAR2 --> Descri��o da cr�tica
                                   ,pr_retxml        IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo     OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro     OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_tipo_de_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para incluir novo tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_tipo_conta (pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE
                           ,pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE) IS
        SELECT cta.inpessoa
              ,cta.cdtipo_conta
              ,cta.dstipo_conta
              ,cta.idindividual
              ,cta.idconjunta_solidaria
              ,cta.idconjunta_nao_solidaria
              ,cta.idtipo_cadastro
              ,cta.cdmodalidade_tipo
              ,cta.indconta_itg
          FROM tbcc_tipo_conta cta
         WHERE cta.cdtipo_conta = pr_cdtipo_conta
           AND cta.inpessoa = pr_inpessoa;
      rw_tipo_conta cr_tipo_conta%ROWTYPE;
    BEGIN
      
      OPEN cr_tipo_conta(pr_cdtipo_conta => pr_cdtipo_conta
                        ,pr_inpessoa     => pr_inpessoa);
      FETCH cr_tipo_conta INTO rw_tipo_conta;
      
      IF cr_tipo_conta%NOTFOUND THEN
        vr_dscritic := 'Tipo de conta n�o encontrada.';
        RAISE vr_exc_saida;
      END IF;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><tipo_conta>' ||
                                     '<inpessoa>'                 || rw_tipo_conta.inpessoa                 || '</inpessoa>' ||
                                     '<cdtipo_conta>'             || rw_tipo_conta.cdtipo_conta             || '</cdtipo_conta>' ||
                                     '<dstipo_conta>'             || rw_tipo_conta.dstipo_conta             || '</dstipo_conta>' ||
                                     '<idindividual>'             || rw_tipo_conta.idindividual             || '</idindividual>' ||
                                     '<idconjunta_solidaria>'     || rw_tipo_conta.idconjunta_solidaria     || '</idconjunta_solidaria>' ||
                                     '<idconjunta_nao_solidaria>' || rw_tipo_conta.idconjunta_nao_solidaria || '</idconjunta_nao_solidaria>' ||
                                     '<idtipo_cadastro>'          || rw_tipo_conta.idtipo_cadastro          || '</idtipo_cadastro>' ||
                                     '<cdmodalidade_tipo>'        || rw_tipo_conta.cdmodalidade_tipo        || '</cdmodalidade_tipo>' ||
                                     '<indconta_itg>'             || rw_tipo_conta.indconta_itg             || '</indconta_itg>' ||
                                     '</tipo_conta></Root>');
      
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_buscar_tipo_de_conta;
  
  PROCEDURE pc_incluir_tipo_de_conta(pr_inpessoa               IN INTEGER --> Tipo de pessoa
                                    ,pr_dstipo_conta           IN VARCHAR2 --> Descri�ao do tipo de conta
                                    ,pr_individual             IN INTEGER --> Categoria individual
                                    ,pr_conjunta_solidaria     IN INTEGER --> Categoria conjunta solidaria
                                    ,pr_conjunta_nao_solidaria IN INTEGER --> Categoria conjunta n�o solidaria
                                    ,pr_tpcadast               IN INTEGER --> Tipo de cadastro
                                    ,pr_cdmodali               IN INTEGER --> Modalidade
                                    ,pr_indconta_itg           IN INTEGER --> Flag Conta integracao
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_incluir_tipo_de_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para incluir novo tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Variaveis auxiliares
      vr_maior_id     tbcc_tipo_conta.cdtipo_conta%TYPE;
      vr_cdtipo_conta tbcc_tipo_conta.cdtipo_conta%TYPE;
      
      -- Busca ultimo id de tipo de conta
      CURSOR cr_ult_tipo_conta (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE) IS
        SELECT NVL(MAX(cdtipo_conta), 0) + 1
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa;
      
    BEGIN
      
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_dstipo_conta IS NULL THEN
        vr_dscritic := 'Descri��o do tipo de conta inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_individual = 0 AND 
         pr_conjunta_solidaria = 0 AND 
         pr_conjunta_nao_solidaria = 0 THEN
        vr_dscritic := 'Nenhuma categoria selecionada.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_tpcadast = 0 THEN
        vr_dscritic := 'Tipo de cadastro inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdmodali = 0 THEN
        vr_dscritic := 'Modalidade inv�lida.';
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_ult_tipo_conta(pr_inpessoa => pr_inpessoa);
      FETCH cr_ult_tipo_conta INTO vr_maior_id;
      CLOSE cr_ult_tipo_conta;
      
      BEGIN
        INSERT INTO tbcc_tipo_conta (inpessoa
                                    ,cdtipo_conta
                                    ,dstipo_conta
                                    ,idindividual
                                    ,idconjunta_solidaria
                                    ,idconjunta_nao_solidaria
                                    ,idtipo_cadastro
                                    ,cdmodalidade_tipo
                                    ,indconta_itg)
                             VALUES (pr_inpessoa
                                    ,vr_maior_id
                                    ,pr_dstipo_conta
                                    ,pr_individual
                                    ,pr_conjunta_solidaria
                                    ,pr_conjunta_nao_solidaria
                                    ,pr_tpcadast
                                    ,pr_cdmodali
                                    ,pr_indconta_itg)
        RETURNING cdtipo_conta INTO vr_cdtipo_conta;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Descri��o do tipo de conta j� existe.';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir tipo de conta. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><cdtipo_conta>'||vr_cdtipo_conta||'</cdtipo_conta></Root>');
      
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_incluir_tipo_de_conta;
  
  PROCEDURE pc_alterar_tipo_de_conta(pr_inpessoa               IN INTEGER --> tipo de pessoa
                                    ,pr_cdtipo_conta           IN INTEGER --> Codigo do tipo de conta
                                    ,pr_dstipo_conta           IN VARCHAR2 --> Descri�ao do tipo de conta
                                    ,pr_individual             IN INTEGER --> Categoria individual
                                    ,pr_conjunta_solidaria     IN INTEGER --> Categoria conjunta solidaria
                                    ,pr_conjunta_nao_solidaria IN INTEGER --> Categoria conjunta n�o solidaria
                                    ,pr_tpcadast               IN INTEGER --> Tipo de cadastro
                                    ,pr_cdmodali               IN INTEGER --> Modalidade
                                    ,pr_indconta_itg           IN INTEGER --> Flag Conta integracao
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_alterar_tipo_de_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para alterar tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_ult_tipo_conta (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                               ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.cdtipo_conta
              ,cta.idindividual
              ,cta.idconjunta_solidaria
              ,cta.idconjunta_nao_solidaria
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      rw_ult_tipo_conta cr_ult_tipo_conta%ROWTYPE;
      
      -- Busca tipo de conta
      CURSOR cr_crapass (pr_cdcatego IN crapass.cdcatego%TYPE
                        ,pr_cdtipcta IN crapass.cdtipcta%TYPE
                        ,pr_inpessoa IN crapass.inpessoa%TYPE) IS
        SELECT 1
          FROM crapass ass
         WHERE ass.cdcatego = pr_cdcatego
           AND ass.cdtipcta = pr_cdtipcta
           AND ass.inpessoa = pr_inpessoa
           AND rownum = 1;
      rw_crapass cr_crapass%ROWTYPE;
      
    BEGIN
      
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdtipo_conta = 0 THEN
        vr_dscritic := 'C�digo do tipo de conta inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_dstipo_conta IS NULL THEN
        vr_dscritic := 'Descri��o do tipo de conta inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_individual = 0 AND 
         pr_conjunta_solidaria = 0 AND 
         pr_conjunta_nao_solidaria = 0 THEN
        vr_dscritic := 'Nenhuma categoria selecionada.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_tpcadast = 0 THEN
        vr_dscritic := 'Tipo de cadastro inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdmodali = 0 THEN
        vr_dscritic := 'Modalidade inv�lida.';
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_ult_tipo_conta (pr_inpessoa => pr_inpessoa
                             ,pr_cdtipo_conta => pr_cdtipo_conta);
      FETCH cr_ult_tipo_conta INTO rw_ult_tipo_conta;
      
      IF cr_ult_tipo_conta%NOTFOUND THEN
        CLOSE cr_ult_tipo_conta;
        vr_dscritic := 'Tipo de conta n�o encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_ult_tipo_conta;
      
      IF rw_ult_tipo_conta.idindividual = 1 AND
         pr_individual = 0 THEN
        OPEN cr_crapass (pr_cdcatego => 1
                        ,pr_cdtipcta => pr_cdtipo_conta
                        ,pr_inpessoa => pr_inpessoa);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'N�o � permitido desmarcar a op��o Individual, pois h� contas nesta categoria.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
      END IF;
      
      IF rw_ult_tipo_conta.idconjunta_solidaria = 1 AND
         pr_conjunta_solidaria = 0 THEN
        OPEN cr_crapass (pr_cdcatego => 2
                        ,pr_cdtipcta => pr_cdtipo_conta
                        ,pr_inpessoa => pr_inpessoa);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'N�o � permitido desmarcar a op��o Conjunta, pois h� contas nesta categoria.';
          --vr_dscritic := 'N�o � permitido desmarcar a op��o Conjunta Solid�ria, pois h� contas nesta categoria.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
      END IF;
      
      IF rw_ult_tipo_conta.idconjunta_nao_solidaria = 1 AND
         pr_conjunta_nao_solidaria = 0 THEN
        OPEN cr_crapass (pr_cdcatego => 3
                        ,pr_cdtipcta => pr_cdtipo_conta
                        ,pr_inpessoa => pr_inpessoa);
        FETCH cr_crapass INTO rw_crapass;
        IF cr_crapass%FOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'N�o � permitido desmarcar a op��o Conjunta N�o Solid�ria, pois h� contas nesta categoria.';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapass;
      END IF;
      
      BEGIN
        UPDATE tbcc_tipo_conta cta
           SET cta.dstipo_conta             = pr_dstipo_conta
              ,cta.idindividual             = pr_individual
              ,cta.idconjunta_solidaria     = pr_conjunta_solidaria
              ,cta.idconjunta_nao_solidaria = pr_conjunta_nao_solidaria
              ,cta.idtipo_cadastro          = pr_tpcadast
              ,cta.cdmodalidade_tipo        = pr_cdmodali
              ,cta.indconta_itg             = pr_indconta_itg
         WHERE cta.inpessoa                 = pr_inpessoa
           AND cta.cdtipo_conta             = pr_cdtipo_conta;
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Descri��o do tipo de conta j� existe.';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar tipo de conta. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>OK</Root>');
      
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_alterar_tipo_de_conta;
  
  PROCEDURE pc_excluir_tipo_de_conta(pr_inpessoa               IN INTEGER --> tipo de pessoa
                                    ,pr_cdtipo_conta           IN INTEGER --> codigo do tipo de conta
                                    ,pr_xmllog                 IN VARCHAR2 --> XML com informa��es de LOG
                                    ,pr_cdcritic              OUT PLS_INTEGER --> C�digo da cr�tica
                                    ,pr_dscritic              OUT VARCHAR2 --> Descri��o da cr�tica
                                    ,pr_retxml                 IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                    ,pr_nmdcampo              OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_des_erro              OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_excluir_tipo_de_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para excluir tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic VARCHAR2(1000); --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
      -- Busca tipo de conta
      CURSOR cr_ult_tipo_conta (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                               ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT cta.cdtipo_conta
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      rw_ult_tipo_conta cr_ult_tipo_conta%ROWTYPE;
      
      -- Busca contas atreladas ao tipo de conta
      CURSOR cr_cta_ctc (pr_inpessoa     IN tbcc_tipo_conta.inpessoa%TYPE
                        ,pr_cdtipo_conta IN tbcc_tipo_conta.cdtipo_conta%TYPE) IS
        SELECT 1
          FROM tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta
           AND EXISTS ( SELECT 1
                          FROM tbcc_tipo_conta_coop ctc
                              ,crapass              ass
                         WHERE ctc.inpessoa = cta.inpessoa
                           AND ctc.cdtipo_conta = cta.cdtipo_conta
                           AND ass.cdcooper = ctc.cdcooper
                           AND ass.inpessoa = ctc.inpessoa
                           AND ass.cdtipcta = ctc.cdtipo_conta
                           AND ROWNUM = 1);
      rw_cta_ctc cr_cta_ctc%ROWTYPE;
      
    BEGIN
      
    -- Verifica tipo de pessoa
      IF pr_inpessoa = 0 THEN
        vr_dscritic := 'Tipo de pessoa inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_cdtipo_conta = 0 THEN
        vr_dscritic := 'C�digo do tipo de conta inv�lido.';
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_ult_tipo_conta (pr_inpessoa     => pr_inpessoa
                             ,pr_cdtipo_conta => pr_cdtipo_conta);
      FETCH cr_ult_tipo_conta INTO rw_ult_tipo_conta;
      
      IF cr_ult_tipo_conta%NOTFOUND THEN
        CLOSE cr_ult_tipo_conta;
        vr_dscritic := 'Tipo de conta n�o encontrado.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_ult_tipo_conta;

      -- Verifica se h� contas atreladas
      OPEN cr_cta_ctc (pr_inpessoa     => pr_inpessoa
                      ,pr_cdtipo_conta => pr_cdtipo_conta);
      FETCH cr_cta_ctc INTO rw_cta_ctc;
      
      IF cr_cta_ctc%FOUND THEN
        CLOSE cr_cta_ctc;
        vr_dscritic := 'H� contas que utilizam este Tipo de Conta. Exclus�o n�o permitida!';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_cta_ctc;
      
      -- Exclui o tipo de conta
      BEGIN
        DELETE tbcc_tipo_conta cta
         WHERE cta.inpessoa = pr_inpessoa
           AND cta.cdtipo_conta = pr_cdtipo_conta;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir tipo de conta. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>OK</Root>');
      
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_excluir_tipo_de_conta;
  
  PROCEDURE pc_transferir_contas(pr_inpessoa   IN INTEGER --> Tipo de pessoa
                                ,pr_cdcooper   IN INTEGER --> C�digo da cooperativa
                                ,pr_tipcta_ori IN INTEGER --> Codigo tipo de conta de origem
                                ,pr_tipcta_des IN INTEGER --> Codigo tipo de conta de destino
                                ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                                ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_transferir_contas
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para transferir tipo de conta.
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
  BEGIN
    DECLARE
    
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> C�d. Erro
      vr_dscritic crapcri.dscritic%TYPE; --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      
    BEGIN
      
      -- Valida transferencia
      cada0006.pc_valida_transferencia(pr_inpessoa => pr_inpessoa
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_tipcta_ori => pr_tipcta_ori
                                      ,pr_tipcta_des => pr_tipcta_des
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_dscritic => vr_dscritic);
      -- Se ocorrer algum erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      /*
      -- Realiza transferencia
      BEGIN
        UPDATE crapass
           SET cdtipcta = pr_tipcta_des
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND cdtipcta = pr_tipcta_ori;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao transferir contas do tipo de conta ' || pr_tipcta_ori || 
                                              ' para o tipo de conta ' || pr_tipcta_des || '. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;     
      */
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root>OK</Root>');
      
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
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
      
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TIPCTA: ' || SQLERRM;
        pr_des_erro := 'NOK';
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;
  END pc_transferir_contas;
  
END TELA_TIPCTA;
/
