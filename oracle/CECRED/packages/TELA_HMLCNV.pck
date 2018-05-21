CREATE OR REPLACE PACKAGE CECRED.TELA_HMLCNV IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_HMLCNV
  --  Sistema  : Rotinas utilizadas pela Tela HMLCNV
  --  Sigla    : CONVENIO
  --  Autor    : Tiago/ Ranghetti
  --  Data     : Maio - 2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela HMLCNV para 
  --             homologa��o de novos convenios
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------
  

  PROCEDURE pc_buscar_situacoes_conta(pr_xmllog    IN VARCHAR2 --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2); --> Erros do processo
                                     
  PROCEDURE pc_buscar_situacao_conta_coop(pr_cdsituacao IN tbcc_situacao_conta.cdsituacao%TYPE
                                         ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                         ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                         ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2); --> Erros do processo
                                         
  PROCEDURE pc_alterar_situacao_conta_coop(pr_cdsituacao            IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> Codigo da situacao
                                          ,pr_inimpede_credito      IN tbcc_situacao_conta_coop.inimpede_credito%TYPE --> Ind. de impedimento de operacao de credito
                                          ,pr_inimpede_talionario   IN tbcc_situacao_conta_coop.inimpede_talionario%TYPE --> Ind. de impedimento para retirada de talionarios
                                          ,pr_incontratacao_produto IN tbcc_situacao_conta_coop.incontratacao_produto%TYPE --> Ind. de impedimento para contratacao de produtos e servi�os
                                          ,pr_tpacesso              IN tbcc_situacao_conta_coop.tpacesso%TYPE --> Tipo do acesso
                                          ,pr_lancamentos           IN VARCHAR2 --> Lancamentos permitidos
                                          ,pr_xmllog                IN VARCHAR2 --> XML com informa��es de LOG
                                          ,pr_cdcritic             OUT PLS_INTEGER --> C�digo da cr�tica
                                          ,pr_dscritic             OUT VARCHAR2 --> Descri��o da cr�tica
                                          ,pr_retxml                IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro             OUT VARCHAR2); --> Erros do processo
  
END TELA_HMLCNV;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_HMLCNV IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_HMLCNV
  --  Sistema  : Rotinas utilizadas pela Tela HMLCNV
  --  Sigla    : CONVENIO
  --  Autor    : Tiago/ Ranghetti
  --  Data     : Maio - 2018.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela HMLCNV para 
  --             homologa��o de novos convenios
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

  PROCEDURE pc_buscar_situacoes_conta(pr_xmllog    IN VARCHAR2 --> XML com informa��es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2 --> Descri��o da cr�tica
                                     ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_tipo_de_conta
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar situacoes de conta.
    
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
      
      -- Busca situacoes de conta
      CURSOR cr_situacao_conta IS
        SELECT sit.cdsituacao
              ,sit.dssituacao
          FROM tbcc_situacao_conta sit
         ORDER BY sit.cdsituacao;
          
    BEGIN
      
      -- Criar cabecalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><situacoes_conta></situacoes_conta></Root>');
      
      FOR rw_situacao_conta IN cr_situacao_conta LOOP
        -- Registros
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root/situacoes_conta'
                                           ,XMLTYPE('<situacao_conta>'
                                                  ||   '<cdsituacao>' || rw_situacao_conta.cdsituacao || '</cdsituacao>'
                                                  ||   '<dssituacao>' || rw_situacao_conta.dssituacao || '</dssituacao>'
                                                  ||'</situacao_conta>'));
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
  END pc_buscar_situacoes_conta;
  
  PROCEDURE pc_buscar_situacao_conta_coop(pr_cdsituacao IN tbcc_situacao_conta.cdsituacao%TYPE
                                         ,pr_xmllog     IN VARCHAR2 --> XML com informa��es de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER --> C�digo da cr�tica
                                         ,pr_dscritic  OUT VARCHAR2 --> Descri��o da cr�tica
                                         ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2 --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_buscar_situacao_conta_coop
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para buscar situacao de conta.
    
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
      
      -- Variaveis para xml
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Busca situacao de conta
      CURSOR cr_situacao_conta (pr_cdcooper   IN tbcc_situacao_conta_coop.cdcooper%TYPE
                               ,pr_cdsituacao IN tbcc_situacao_conta_coop.cdsituacao%TYPE) IS
        SELECT sit.inimpede_credito
              ,sit.inimpede_talionario
              ,sit.incontratacao_produto
              ,sit.tpacesso
          FROM tbcc_situacao_conta_coop sit
         WHERE sit.cdcooper = pr_cdcooper
           AND sit.cdsituacao = pr_cdsituacao;
      rw_situacao_conta cr_situacao_conta%ROWTYPE;
      
      -- Buscar grupos de historicos
      CURSOR cr_grupo_historico IS
        SELECT his.cdgrupo_historico
              ,his.dsgrupo_historico
          FROM tbcc_grupo_historico his
         ORDER BY his.cdgrupo_historico;
      
      -- Buscar grupos de historicos
      CURSOR cr_grupo_situacao (pr_cdcooper   IN tbcc_situacao_conta_coop.cdcooper%TYPE
                               ,pr_cdsituacao IN tbcc_situacao_conta_coop.cdsituacao%TYPE) IS
        SELECT his.cdgrupo_historico
              ,his.dsgrupo_historico
          FROM tbcc_grupo_situacao_cta cta
              ,tbcc_grupo_historico his
         WHERE cta.cdcooper = pr_cdcooper
           AND cta.cdsituacao = pr_cdsituacao
           AND cta.cdgrupo_historico = his.cdgrupo_historico
         ORDER BY cta.cdgrupo_historico;
      
    BEGIN
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      OPEN cr_situacao_conta(pr_cdcooper   => vr_cdcooper
                            ,pr_cdsituacao => pr_cdsituacao);

      FETCH cr_situacao_conta INTO rw_situacao_conta;
      
      IF cr_situacao_conta%FOUND THEN
        
        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
        gene0002.pc_escreve_xml(pr_xml => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root>'
                                                 || '<situacao_conta>'
                                                 ||   '<inimpede_credito>'      || rw_situacao_conta.inimpede_credito      || '</inimpede_credito>'
                                                 ||   '<inimpede_talionario>'   || rw_situacao_conta.inimpede_talionario   || '</inimpede_talionario>'
                                                 ||   '<incontratacao_produto>' || rw_situacao_conta.incontratacao_produto || '</incontratacao_produto>'
                                                 ||   '<tpacesso>'              || rw_situacao_conta.tpacesso 	           || '</tpacesso>'
                                                 || '</situacao_conta>'
                                                 || '<lancamentos>');
        
        FOR rw_grupo_historico IN cr_grupo_historico LOOP
        gene0002.pc_escreve_xml(pr_xml => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<lancamento>'
                                                 ||  '<cdlancmto>' || rw_grupo_historico.cdgrupo_historico || '</cdlancmto>'
                                                 ||  '<dslancmto>' || rw_grupo_historico.dsgrupo_historico || '</dslancmto>'
                                               ||'</lancamento>');
        END LOOP;
                                               
        gene0002.pc_escreve_xml(pr_xml => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '</lancamentos>'
                                               ||'<lancamentos_permitidos>');
                               
        FOR rw_grupo_situacao IN cr_grupo_situacao(pr_cdcooper   => vr_cdcooper
                                                  ,pr_cdsituacao => pr_cdsituacao) LOOP
        gene0002.pc_escreve_xml(pr_xml => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<lancamento>'
                                                 ||  '<cdlancmto>' || rw_grupo_situacao.cdgrupo_historico || '</cdlancmto>'
                                                 ||  '<dslancmto>' || rw_grupo_situacao.dsgrupo_historico || '</dslancmto>'
                                               ||'</lancamento>');
        END LOOP;
                                               
        gene0002.pc_escreve_xml(pr_xml => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '</lancamentos_permitidos></Root>'
                               ,pr_fecha_xml => TRUE);
        
        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);
        
      ELSE
        vr_dscritic := 'Situa��o n�o encontrada!';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_situacao_conta;
      
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
  END pc_buscar_situacao_conta_coop;
  
  PROCEDURE pc_alterar_situacao_conta_coop(pr_cdsituacao            IN tbcc_situacao_conta_coop.cdsituacao%TYPE --> Codigo da situacao
                                          ,pr_inimpede_credito      IN tbcc_situacao_conta_coop.inimpede_credito%TYPE --> Ind. de impedimento de operacao de credito
                                          ,pr_inimpede_talionario   IN tbcc_situacao_conta_coop.inimpede_talionario%TYPE --> Ind. de impedimento para retirada de talionarios
                                          ,pr_incontratacao_produto IN tbcc_situacao_conta_coop.incontratacao_produto%TYPE --> Ind. de impedimento para contratacao de produtos e servi�os
                                          ,pr_tpacesso              IN tbcc_situacao_conta_coop.tpacesso%TYPE --> Tipo do acesso
                                          ,pr_lancamentos           IN VARCHAR2 --> Lancamentos permitidos
                                          ,pr_xmllog                IN VARCHAR2 --> XML com informa��es de LOG
                                          ,pr_cdcritic             OUT PLS_INTEGER --> C�digo da cr�tica
                                          ,pr_dscritic             OUT VARCHAR2 --> Descri��o da cr�tica
                                          ,pr_retxml                IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                          ,pr_nmdcampo             OUT VARCHAR2 --> Nome do campo com erro
                                          ,pr_des_erro             OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................
    
        Programa: pc_alterar_situacao_conta_coop
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Lombardi
        Data    : Dezembro/17.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Rotina para alterar cadastro de situacao de conta.
    
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
      
      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      -- Variaveis auxiliares
      vr_lancamentos GENE0002.typ_split; -- tabela de servi�os
      vr_nmtabela    tbcc_campo_historico.nmtabela_oracle%TYPE;
      vr_cdgrupo     tbcc_grupo_situacao_cta.cdgrupo_historico%TYPE;
      
      -- Tabela de mem�ria
      TYPE tp_reg_grupos IS TABLE OF tbcc_grupo_situacao_cta.cdgrupo_historico%TYPE INDEX BY BINARY_INTEGER;
      vr_tab_grupo_old  tp_reg_grupos;
      vr_tab_grupo_new  tp_reg_grupos;
      
      -- Busca tipo de conta
      CURSOR cr_situacao (pr_cdcooper   IN tbcc_situacao_conta_coop.cdcooper%TYPE
                         ,pr_cdsituacao IN tbcc_situacao_conta_coop.cdsituacao%TYPE) IS
        SELECT sit.cdsituacao
             , sit.inimpede_credito
             , sit.inimpede_talionario
             , sit.incontratacao_produto
             , sit.tpacesso
          FROM tbcc_situacao_conta_coop sit
         WHERE sit.cdcooper = pr_cdcooper
           AND sit.cdsituacao = pr_cdsituacao;
      rw_situacao cr_situacao%ROWTYPE;
      
      -- Buscar todos os grupos selecionados
      CURSOR cr_grupos(pr_cdcooper   IN tbcc_situacao_conta_coop.cdcooper%TYPE
                      ,pr_cdsituacao IN tbcc_situacao_conta_coop.cdsituacao%TYPE) IS
        SELECT grp.cdgrupo_historico cdgrupo
          FROM tbcc_grupo_situacao_cta grp
         WHERE grp.cdsituacao = pr_cdsituacao
           AND grp.cdcooper   = pr_cdcooper;
      
    BEGIN
      
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
      
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Verifica se existe a situacao
      OPEN cr_situacao (pr_cdcooper   => vr_cdcooper
                       ,pr_cdsituacao => pr_cdsituacao);
      FETCH cr_situacao INTO rw_situacao;
      
      IF cr_situacao%NOTFOUND THEN
        CLOSE cr_situacao;
        vr_dscritic := 'Situa��o n�o encontrada.';
        RAISE vr_exc_saida;
      END IF;
      
      CLOSE cr_situacao;
      
      -- Altera a situacao
      BEGIN
        UPDATE tbcc_situacao_conta_coop sit
           SET sit.inimpede_credito      = pr_inimpede_credito
              ,sit.inimpede_talionario   = pr_inimpede_talionario
              ,sit.incontratacao_produto = pr_incontratacao_produto
              ,sit.tpacesso              = pr_tpacesso
         WHERE sit.cdcooper   = vr_cdcooper
           AND sit.cdsituacao = pr_cdsituacao;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar situa��o. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- CRIAR OS REGISTROS DE HIST�RICO
      DECLARE
        vr_exphistor   EXCEPTION;
      BEGIN
        -- Fixa o nome da tabela 
        vr_nmtabela := 'TBCC_SITUACAO_CONTA_COOP';
        
        -- INIMPEDE_CREDITO
        CADA0006.pc_grava_dados_hist(pr_nmtabela => vr_nmtabela
                                    ,pr_nmdcampo => 'INIMPEDE_CREDITO'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdsituac => pr_cdsituacao
                                    ,pr_tpoperac => 2 -- Altera��o
                                    ,pr_dsvalant => rw_situacao.inimpede_credito
                                    ,pr_dsvalnov => pr_inimpede_credito
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer erro 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exphistor;
        END IF;
        
        -- INIMPEDE_TALIONARIO
        CADA0006.pc_grava_dados_hist(pr_nmtabela => vr_nmtabela
                                    ,pr_nmdcampo => 'INIMPEDE_TALIONARIO'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdsituac => pr_cdsituacao
                                    ,pr_tpoperac => 2 -- Altera��o
                                    ,pr_dsvalant => rw_situacao.inimpede_talionario
                                    ,pr_dsvalnov => pr_inimpede_talionario
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer erro 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exphistor;
        END IF;
        
        -- INCONTRATACAO_PRODUTO
        CADA0006.pc_grava_dados_hist(pr_nmtabela => vr_nmtabela
                                    ,pr_nmdcampo => 'INCONTRATACAO_PRODUTO'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdsituac => pr_cdsituacao
                                    ,pr_tpoperac => 2 -- Altera��o
                                    ,pr_dsvalant => rw_situacao.incontratacao_produto
                                    ,pr_dsvalnov =>  pr_incontratacao_produto
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer erro 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exphistor;
        END IF;
        
        -- TPACESSO
        CADA0006.pc_grava_dados_hist(pr_nmtabela => vr_nmtabela
                                    ,pr_nmdcampo => 'TPACESSO'
                                    ,pr_cdcooper => vr_cdcooper
                                    ,pr_cdsituac => pr_cdsituacao
                                    ,pr_tpoperac => 2 -- Altera��o
                                    ,pr_dsvalant => rw_situacao.tpacesso
                                    ,pr_dsvalnov => pr_tpacesso
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_dscritic => vr_dscritic);
        
        -- Se ocorrer erro 
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exphistor;
        END IF;
        
      EXCEPTION
        WHEN vr_exphistor THEN
          vr_dscritic := 'Erro ao gerar hist�rico: '||vr_dscritic;
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao gerar hist�rico: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Buscar e guardar todos os grupos selecionados atualmente
      FOR rw_grupos IN cr_grupos(vr_cdcooper, pr_cdsituacao) LOOP
        -- Adiciona o registro 
        vr_tab_grupo_old(rw_grupos.cdgrupo) := rw_grupos.cdgrupo;
      END LOOP;
      
      BEGIN
        -- Exclui os registros anteriores
        DELETE 
          FROM tbcc_grupo_situacao_cta 
         WHERE cdcooper = vr_cdcooper
           AND cdsituacao = pr_cdsituacao;
      EXCEPTION 
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir lancamentos permitidos. ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Faz o split dos lancamentos permitidos
      vr_lancamentos := GENE0002.fn_quebra_string(pr_string  => pr_lancamentos
                                                 ,pr_delimit => ';');
      IF vr_lancamentos.COUNT() > 0 THEN
      -- Loop pelos lancamentos permitidos
      FOR vr_indice IN vr_lancamentos.FIRST()..vr_lancamentos.LAST() LOOP
        -- Insere os registros de lancamentos permitidos
        BEGIN 
          INSERT INTO tbcc_grupo_situacao_cta (cdcooper, cdsituacao, cdgrupo_historico)
                                       VALUES (vr_cdcooper, pr_cdsituacao, to_number(vr_lancamentos(vr_indice)));
        EXCEPTION 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir lancamentos permitidos. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
          
          -- Insere o os dados no registro de mem�ria
          vr_tab_grupo_new(vr_lancamentos(vr_indice)) := vr_lancamentos(vr_indice);
        END LOOP;
      END IF;
      
      -- Se tem registros antigos
      IF vr_tab_grupo_old.count() > 0 THEN
        -- Percorrer os grupos para gerar os hist�ricos
        vr_cdgrupo := vr_tab_grupo_old.FIRST();
        
        LOOP
          -- Verifica se o grupo foi REMOVIDO
          IF NOT vr_tab_grupo_new.EXISTS(vr_cdgrupo) THEN
            
            -- Gravar Hist�rico
            CADA0006.pc_grava_dados_hist(pr_nmtabela => 'TBCC_GRUPO_SITUACAO_CTA'
                                        ,pr_nmdcampo => 'CDGRUPO_HISTORICO'
                                        ,pr_cdcooper => vr_cdcooper
                                        ,pr_cdsituac => pr_cdsituacao
                                        ,pr_tpoperac => 2 -- Altera��o
                                        ,pr_dsvalant => vr_cdgrupo
                                        ,pr_dsvalnov => NULL
                                        ,pr_cdoperad => vr_cdoperad
                                        ,pr_dscritic => vr_dscritic);
          
            -- Se ocorrer erro 
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          
          ELSE
            -- Se existir deve remover pois n�o alterou
            vr_tab_grupo_new.DELETE(vr_cdgrupo);
          END IF;
                
          EXIT WHEN vr_cdgrupo = vr_tab_grupo_old.LAST();
          vr_cdgrupo := vr_tab_grupo_old.NEXT(vr_cdgrupo);
        END LOOP;
      END IF;
      
      -- Se h� registros indica grupos inclu�dos
      IF vr_tab_grupo_new.count() > 0 THEN
        -- Percorrer os grupos para gerar os hist�ricos
        vr_cdgrupo := vr_tab_grupo_new.FIRST();
        
        LOOP
          -- Gravar Hist�rico
          CADA0006.pc_grava_dados_hist(pr_nmtabela => 'TBCC_GRUPO_SITUACAO_CTA'
                                      ,pr_nmdcampo => 'CDGRUPO_HISTORICO'
                                      ,pr_cdcooper => vr_cdcooper
                                      ,pr_cdsituac => pr_cdsituacao
                                      ,pr_tpoperac => 2 -- Altera��o
                                      ,pr_dsvalant => NULL
                                      ,pr_dsvalnov => vr_cdgrupo
                                      ,pr_cdoperad => vr_cdoperad
                                      ,pr_dscritic => vr_dscritic);
          
          -- Se ocorrer erro 
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          
          EXIT WHEN vr_cdgrupo = vr_tab_grupo_new.LAST();
          vr_cdgrupo := vr_tab_grupo_new.NEXT(vr_cdgrupo);
      END LOOP;
      END IF;
      
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
  END pc_alterar_situacao_conta_coop;
  
END TELA_HMLCNV;
/
