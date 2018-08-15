CREATE OR REPLACE PACKAGE CECRED.TELA_HISPES is
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_HISPES
  --  Sistema  : Rotinas para a tela HISPES - Historico de manutenção do cadastro de pessoa
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Novembro/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para a tela HISPES - Historico de manutenção do cadastro de pessoa
  --
  -- Alteracoes:   
  --  
  ---------------------------------------------------------------------------------------------------------------*/
  
  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
 
  -- Definicao do tipo de array tipos de alteracao
  TYPE typ_tpalteracao IS VARRAY(3) OF VARCHAR2(15);
  -- Vetor de memória com os tipos de alteracao
  vr_tab_tpalteracao typ_tpalteracao := typ_tpalteracao( 'Inclusão'
                                                        ,'Alteração'
                                                        ,'Exclusão');
  
  -- Tabela de memoria contendo as descrição de nome de tabela
  TYPE typ_tab_dstabela IS TABLE OF VARCHAR2(500)
       INDEX BY VARCHAR2(80);
  vr_tab_dstabela typ_tab_dstabela;     
       
  
  
  --------->>>> PROCUDURES/FUNCTIONS <<<<----------
  
  /*****************************************************************************/
  /**            Function para retornar campo de valor formatato             **/
  /*****************************************************************************/
  FUNCTION fn_formata_valor (pr_valor IN NUMBER) RETURN VARCHAR2; 
  
  --> Buscar dados da pessoa do CPF/CNPJ informadp
  PROCEDURE pc_busca_pessoa ( pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                             ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                             ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                             ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                             
  --> Listar resumo do historico de manutenção da pessoa
  PROCEDURE pc_resumo_hst  (pr_idpessoa IN NUMBER             --> Identificador de pessoa
                           ,pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                           ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                           ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                           ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);        --> Erros do processo     
                           
  --> Listar historico por tabela
  PROCEDURE pc_historico_tabela
                           (pr_idpessoa IN NUMBER             --> Identificador de pessoa                           
                           ,pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                           ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                           ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                           ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                           ,pr_nmtabela IN VARCHAR2           --> Nome da tabela
                           ,pr_dtaltera IN VARCHAR2           --> Data de alteracao
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);        --> Erros do processo                           
END TELA_HISPES;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_HISPES IS
  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_HISPES
  --  Sistema  : Rotinas para a tela HISPES - Historico de manutenção do cadastro de pessoa
  --  Sigla    : CADA
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Novembro/2017.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas para a tela HISPES - Historico de manutenção do cadastro de pessoa
  --
  -- Alteracoes:   
  --    
  --  
  ---------------------------------------------------------------------------------------------------------------*/


  
  
  /*****************************************************************************/
  /**            Function para retornar campo de valor formatato             **/
  /*****************************************************************************/
  FUNCTION fn_formata_valor (pr_valor IN NUMBER) RETURN VARCHAR2 IS  
     
  /* ..........................................................................
    --
    --  Programa : fn_formata_valor
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(Amcom)
    --  Data     : Julho/2017.                   Ultima atualizacao: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para carregar os campos da tabela hist. 
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <-----------------         
    
  BEGIN
    RETURN to_char(pr_valor, 'fm9g999g999g999g999g990d00', 'NLS_NUMERIC_CHARACTERS='',.''');
  
  EXCEPTION 
    WHEN OTHERS THEN
      RETURN pr_valor;
  END fn_formata_valor;  
  
  --> Buscar dados da pessoa do CPF/CNPJ informadp
  PROCEDURE pc_busca_pessoa ( pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                             ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                             ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                             ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................
    
        Programa: pc_busca_pessoa
        Sistema : CECRED
        Sigla   : CADAST
        Autor   : Odirlei Busana
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Buscar dados da pessoa do CPF/CNPJ informadp
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares
      vr_idpessoa        tbcadast_pessoa.idpessoa%TYPE;   
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_flgexist        BOOLEAN;
      
      ---------->> CURSORES <<--------
      --> Buscar pessoa
      CURSOR cr_pessoa (pr_idpessoa NUMBER) IS
        SELECT pes.nmpessoa,
               pes.idpessoa,
               pes.nrcpfcgc,
               pes.tppessoa
          FROM tbcadast_pessoa pes
         WHERE pes.idpessoa = pr_idpessoa;
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
      
      -- Se nao foi informado a idpessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        
        --> Identificar idpessoa
        vr_idpessoa := cada0015.fn_busca_pessoa( pr_cdcooper => pr_cdcoptel, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_idseqttl => pr_idseqttl, 
                                                 pr_nrcpfcgc => pr_nrcpfcgc);                   
      END IF;   
      
      IF nvl(vr_idpessoa,0) = 0 THEN
        vr_dscritic := 'Pessoa não cadastrada';
        RAISE vr_exc_erro;
      END IF;
            
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<root><Dados>');
      
      vr_flgexist := FALSE;
      -- Listar pessoa
      FOR rw_pessoa  IN cr_pessoa(pr_idpessoa => vr_idpessoa) LOOP
        vr_flgexist := TRUE;
        BEGIN
          pc_escreve_xml( '<pessoa>
                           <nmpessoa>'|| rw_pessoa.nmpessoa ||'</nmpessoa>'||
                          '<idpessoa>'|| rw_pessoa.idpessoa ||'</idpessoa>'||
                          '<nrcpfcgc>'|| gene0002.fn_mask_cpf_cnpj(rw_pessoa.nrcpfcgc, rw_pessoa.tppessoa) ||'</nrcpfcgc>'||
                          '<tppessoa>'|| rw_pessoa.tppessoa ||'</tppessoa>'||                         
                          '</pessoa>');   
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de pessoas'||
                         ': '||SQLERRM;
          RAISE vr_exc_erro;               
        END;                         
      END LOOP;                     
      
      pc_escreve_xml('</Dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
      
      IF vr_flgexist = FALSE THEN
        vr_dscritic := 'Pessoa não encontrada';
       RAISE vr_exc_erro;
      END IF;
                             
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
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
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_pessoa;
  
  
  --> Listar resumo do historico de manutenção da pessoa
  PROCEDURE pc_resumo_hst  (pr_idpessoa IN NUMBER             --> Identificador de pessoa
                           ,pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                           ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                           ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                           ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................
    
        Programa: pc_resumo_hst
        Sistema : CECRED
        Sigla   : CADAST
        Autor   : Odirlei Busana
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Listar resumo do historico de manutenção da pessoa
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares
      vr_idpessoa tbcadast_pessoa.idpessoa%TYPE;   
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      
      ---------->> CURSORES <<--------
      --> Buscar resumo do historico
      CURSOR cr_peshis (pr_idpessoa IN NUMBER) IS
        SELECT cmp.nmtabela_oracle         nmtabela_oracle, 
               hst.tpoperacao              tpoperacao,
               hst.dhalteracao             dhalteracao,
               hst.cdoperad_altera
          FROM tbcadast_pessoa_historico hst,
               tbcadast_campo_historico cmp
         WHERE hst.idcampo  = cmp.idcampo
           AND hst.idpessoa = pr_idpessoa
         GROUP BY cmp.nmtabela_oracle, 
               hst.tpoperacao,
               hst.dhalteracao,
               hst.cdoperad_altera
         ORDER BY hst.dhalteracao DESC ,hst.tpoperacao;
      rw_peshis cr_peshis%ROWTYPE;
      
      CURSOR cr_crapope(pr_cdoperad VARCHAR2) IS
        SELECT ope.nmoperad
          FROM crapope ope
         WHERE ope.cdoperad = pr_cdoperad
           AND rownum < 2
         ORDER BY decode(ope.cdcooper,3,0,1);
      rw_crapope cr_crapope%ROWTYPE;
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
      
      vr_idpessoa := pr_idpessoa;
      
      -- Se nao foi informado a idpessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        
        --> Identificar idpessoa
        vr_idpessoa := cada0015.fn_busca_pessoa( pr_cdcooper => pr_cdcoptel, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_idseqttl => pr_idseqttl, 
                                                 pr_nrcpfcgc => pr_nrcpfcgc);                   
      END IF;   
      
      IF nvl(vr_idpessoa,0) = 0 THEN
        vr_dscritic := 'Pessoa não cadastrada';
        RAISE vr_exc_erro;
      END IF;
      
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<root><Dados>');
      
      -- Listar resumo de historico
      FOR rw_peshis  IN cr_peshis(pr_idpessoa => vr_idpessoa) LOOP
        OPEN cr_crapope(pr_cdoperad => rw_peshis.cdoperad_altera);
        FETCH cr_crapope INTO rw_crapope;
        CLOSE cr_crapope;
      
        BEGIN
          pc_escreve_xml( '<resumo>
                           <nmtabela_oracle>'|| rw_peshis.nmtabela_oracle                  ||'</nmtabela_oracle>'||
                          '<dsresumo>'       || vr_tab_dstabela(rw_peshis.nmtabela_oracle) ||'</dsresumo>'       ||
                          '<tpoperacao>'     || rw_peshis.tpoperacao                       ||'</tpoperacao>'     ||
                          '<dstpoperac>'     || vr_tab_tpalteracao(rw_peshis.tpoperacao)   ||'</dstpoperac>'     ||
                          '<dhalteracao>'    || to_char(rw_peshis.dhalteracao,'DD/MM/RRRR HH24:MI:SS') ||'</dhalteracao>' ||
                          '<cdoperad>'       || rw_peshis.cdoperad_altera                  ||'</cdoperad>'     ||
                          '<nmoperad>'       || rw_crapope.nmoperad                        ||'</nmoperad>'     ||
                          '</resumo>');   
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar resumo da tabela '||rw_peshis.nmtabela_oracle||
                         ': '||SQLERRM;
          RAISE vr_exc_erro;               
        END;                         
      END LOOP;                     
      
      pc_escreve_xml('</Dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
                             
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
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
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_resumo_hst;
  
  --> Listar historico por tabela
  PROCEDURE pc_historico_tabela
                           (pr_idpessoa IN NUMBER             --> Identificador de pessoa                           
                           ,pr_nrcpfcgc IN NUMBER             --> Numero do CPF/CNPJ da pessoa
                           ,pr_cdcoptel IN NUMBER             --> Codigo da cooperativa informada
                           ,pr_nrdconta IN NUMBER             --> Numero da conta informada
                           ,pr_idseqttl IN NUMBER             --> Sequencial do titular informada
                           ,pr_nmtabela IN VARCHAR2           --> Nome da tabela
                           ,pr_dtaltera IN VARCHAR2           --> Data de alteracao
                           ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................
    
        Programa: pc_historico_tabela
        Sistema : CECRED
        Sigla   : CADAST
        Autor   : Odirlei Busana
        Data    : Novembro/2017.                    Ultima atualizacao: --/--/----
    
        Dados referentes ao programa:
    
        Frequencia: Sempre que for chamado
    
        Objetivo  : Listar historico por tabela
    
        Observacao: -----
    
        Alteracoes:
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------   
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro
    
      -- Tratamento de erros
      vr_exc_erro EXCEPTION;
    
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcoplog INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);      
      
      
      --> variaveis auxiliares      
      vr_des_xml         CLOB;  
      vr_texto_completo  VARCHAR2(32600); 
      vr_idpessoa        NUMBER;
      vr_dsvalant        VARCHAR2(600); 
      vr_dsvalnov        VARCHAR2(600); 
      
      ---------->> CURSORES <<--------
      --> Buscar historico
      CURSOR cr_peshis(pr_idpessoa NUMBER) IS
        SELECT hst.dhalteracao,
               hst.tpoperacao,
               cmp.dscampo,
               cmp.nmcampo,
               hst.dsvalor_anterior,
               hst.dsvalor_novo,
               hst.cdoperad_altera,
               (SELECT ope.nmoperad
                  FROM crapope ope
                 WHERE ope.cdoperad = hst.cdoperad_altera
                   AND rownum < 2
                 --ORDER BY decode(ope.cdcooper,3,0,1)
               ) nmoperad
          FROM tbcadast_pessoa_historico hst,
               tbcadast_campo_historico cmp
         WHERE hst.idcampo  = cmp.idcampo
           AND hst.idpessoa = pr_idpessoa
           AND upper(cmp.nmtabela_oracle) = UPPER(pr_nmtabela)          
           AND ( hst.dhalteracao = to_date(TRIM(pr_dtaltera),'DD/MM/YYYY HH24:MI:SS') 
                 OR
                 TRIM(pr_dtaltera) IS NULL
                )
         ORDER BY hst.dhalteracao DESC ,hst.tpoperacao;
      rw_peshis cr_peshis%ROWTYPE;
      
      --> buscar pessoa
      CURSOR cr_pessoa (pr_idpessoa NUMBER) IS
        SELECT pes.tppessoa,
               pes.nrcpfcgc,
               pes.nmpessoa,
               pes.idpessoa
          FROM tbcadast_pessoa pes
         WHERE pes.idpessoa = pr_idpessoa; 
      rw_pessoa_ant cr_pessoa%ROWTYPE;    
      rw_pessoa_nov cr_pessoa%ROWTYPE;    
      
      -- Subrotina para escrever texto na variável CLOB do XML
      procedure pc_escreve_xml(pr_des_dados in varchar2,
                               pr_fecha_xml in boolean default false) is
      begin
        gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
      end;
    
    BEGIN
    
      pr_des_erro := 'OK';
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcoplog,
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
        RAISE vr_exc_erro;
      END IF;
      
      
      vr_idpessoa := pr_idpessoa;
      
      -- Se nao foi informado a idpessoa
      IF nvl(vr_idpessoa,0) = 0 THEN
        
        --> Identificar idpessoa
        vr_idpessoa := cada0015.fn_busca_pessoa( pr_cdcooper => pr_cdcoptel, 
                                                 pr_nrdconta => pr_nrdconta, 
                                                 pr_idseqttl => pr_idseqttl, 
                                                 pr_nrcpfcgc => pr_nrcpfcgc);                   
      END IF;   
      
      IF nvl(vr_idpessoa,0) = 0 THEN
        vr_dscritic := 'Pessoa não cadastrada';
        RAISE vr_exc_erro;
      END IF;
           
      
      -- Inicializar o CLOB
      vr_des_xml := null;
      dbms_lob.createtemporary(vr_des_xml, true);
      dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
      -- Inicilizar as informações do XML
      vr_texto_completo := null;        
        
      -- Criar cabeçalho do XML
      pc_escreve_xml('<?xml version="1.0" encoding="ISO-8859-1" ?>'||
                     '<root><Dados>');
      
      -- Listar resumo de historico
      FOR rw_peshis  IN cr_peshis(pr_idpessoa => vr_idpessoa) LOOP
      
        IF rw_peshis.nmcampo LIKE 'IDPESSOA_%' THEN
          --> buscar pessoa ant
          rw_pessoa_ant := NULL;
          IF trim(rw_peshis.dsvalor_anterior) IS NOT NULL THEN
            OPEN cr_pessoa (pr_idpessoa => rw_peshis.dsvalor_anterior);
            FETCH cr_pessoa INTO rw_pessoa_ant;
            CLOSE cr_pessoa;
            
            IF TRIM(rw_pessoa_ant.nmpessoa) IS NULL THEN
              rw_pessoa_ant.nmpessoa := 'Pessoa ('||rw_peshis.dsvalor_anterior||') nao encontrada.';  
            END IF;            
          END IF;
          
          --> buscar pessoa nova
          rw_pessoa_nov := NULL;
          IF trim(rw_peshis.dsvalor_novo) IS NOT NULL THEN
            OPEN cr_pessoa (pr_idpessoa => rw_peshis.dsvalor_novo);
            FETCH cr_pessoa INTO rw_pessoa_nov;
            CLOSE cr_pessoa;
            
            IF TRIM(rw_pessoa_nov.nmpessoa) IS NULL THEN
              rw_pessoa_nov.nmpessoa := 'Pessoa ('||rw_peshis.dsvalor_novo||') nao encontrada.';  
            END IF;            
          END IF;
          
        END IF;
      
        BEGIN          
          pc_escreve_xml( '<hist>
                            <dhalteracao>' || to_char(rw_peshis.dhalteracao,'DD/MM/RRRR HH24:MI:SS') ||'</dhalteracao>' ||
                           '<dstpoperac>'  || vr_tab_tpalteracao(rw_peshis.tpoperacao)   ||'</dstpoperac>'   ||
                           '<dscampo>'     || rw_peshis.dscampo                          ||'</dscampo>'      ||
                           '<nmcampo>'     || rw_peshis.nmcampo                          ||'</nmcampo>'      ||
                           '<cdoperad>'    || rw_peshis.cdoperad_altera                  ||'</cdoperad>'     ||
                           '<nmoperad>'    || rw_peshis.nmoperad                         ||'</nmoperad>');
                 
          --> Caso o campo seja o identificador de pessoa, enviar dados da pessoa          
          IF rw_peshis.nmcampo LIKE 'IDPESSOA_%' THEN   
          
            vr_dsvalant := NULL;
            IF rw_pessoa_ant.nrcpfcgc > 0 THEN
              vr_dsvalant := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_pessoa_ant.nrcpfcgc,
                                                       pr_inpessoa => rw_pessoa_ant.tppessoa) ||' - ';
                                                       
            END IF;                                           
            vr_dsvalant := vr_dsvalant || rw_pessoa_ant.nmpessoa;
            
            vr_dsvalnov := NULL;
            IF rw_pessoa_nov.nrcpfcgc > 0 THEN
              vr_dsvalnov := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_pessoa_nov.nrcpfcgc,
                                                       pr_inpessoa => rw_pessoa_nov.tppessoa) ||' - ';
                                                       
            END IF;                                           
            vr_dsvalnov := vr_dsvalnov || rw_pessoa_nov.nmpessoa;
                            
            --> Pessoa anterior
            pc_escreve_xml( '<dsvalant>'    || vr_dsvalant            ||'</dsvalant>'     ||
                            '<nrcpfcgc_ant>'|| rw_pessoa_ant.nrcpfcgc || '</nrcpfcgc_ant>' ||
                            '<nmpessoa_ant>'|| rw_pessoa_ant.nmpessoa || '</nmpessoa_ant>' ||
                            '<tppessoa_ant>'|| rw_pessoa_ant.tppessoa || '</tppessoa_ant>' ||
                            '<idpessoa_ant>'|| rw_pessoa_ant.idpessoa || '</idpessoa_ant>');
            
            --> Pessoa nova                
            pc_escreve_xml( '<dsvalnov>'    || vr_dsvalnov            ||'</dsvalnov>'     ||
                            '<nrcpfcgc_nov>'|| rw_pessoa_nov.nrcpfcgc || '</nrcpfcgc_nov>' ||
                            '<nmpessoa_nov>'|| rw_pessoa_nov.nmpessoa || '</nmpessoa_nov>' ||
                            '<tppessoa_nov>'|| rw_pessoa_nov.tppessoa || '</tppessoa_nov>' ||
                            '<idpessoa_nov>'|| rw_pessoa_nov.idpessoa || '</idpessoa_nov>');
                            
          ELSE
            pc_escreve_xml( '<dsvalant>'    || rw_peshis.dsvalor_anterior                 ||'</dsvalant>'     ||
                            '<dsvalnov>'    || rw_peshis.dsvalor_novo                     ||'</dsvalnov>');
          END IF;
               
          pc_escreve_xml( '</hist>');   
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Erro ao montar tabela de hist.'||
                         ': '||SQLERRM;
          RAISE vr_exc_erro;               
        END;                         
      END LOOP;                     
      
      pc_escreve_xml('</Dados></root>',TRUE);
      pr_retxml := xmltype.createxml(vr_des_xml);        
      
      -- Liberando a memória alocada pro CLOB
      dbms_lob.close(vr_des_xml);
      dbms_lob.freetemporary(vr_des_xml);
                             
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      
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
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_historico_tabela;
  
  
BEGIN

  IF vr_tab_dstabela.COUNT = 0 THEN
  
    vr_tab_dstabela('TBCADAST_PESSOA')              :=  'Dados Basicos Pessoa';
    vr_tab_dstabela('TBCADAST_PESSOA_FISICA')       :=  'Pessoa física';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA')     :=  'Pessoa jurídica';
    vr_tab_dstabela('TBCADAST_PESSOA_RENDA')        :=  'Renda'; 
    vr_tab_dstabela('TBCADAST_PESSOA_RENDACOMPL')   :=  'Renda Complementar';
    vr_tab_dstabela('TBCADAST_PESSOA_FISICA_RESP')  :=  'Responsável Legal';
    vr_tab_dstabela('TBCADAST_PESSOA_ESTRANGEIRA')  :=  'Pessoa Estrangeira';
    vr_tab_dstabela('TBCADAST_PESSOA_BEM')          :=  'Bens';
    vr_tab_dstabela('TBCADAST_PESSOA_EMAIL')        :=  'E-mail';
    vr_tab_dstabela('TBCADAST_PESSOA_ENDERECO')     :=  'Endereço';
    vr_tab_dstabela('TBCADAST_PESSOA_FISICA_DEP')   :=  'Dependentes';
    vr_tab_dstabela('TBCADAST_PESSOA_POLEXP')       :=  'Politicamente Expostos';
    vr_tab_dstabela('TBCADAST_PESSOA_REFERENCIA')   :=  'Pessoa de referência';
    vr_tab_dstabela('TBCADAST_PESSOA_RELACAO')      :=  'Pessoas de relação';
    vr_tab_dstabela('TBCADAST_PESSOA_TELEFONE')     :=  'Telefone';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA_BCO') :=  'Dados bancários de pessoa jurídica';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA_FAT') :=  'Dados de faturamento de pessoa jurídica';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA_FNC') :=  'Dados financeiros da pessoa jurídica';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA_PTP') :=  'Empresas de participação';
    vr_tab_dstabela('TBCADAST_PESSOA_JURIDICA_REP') :=  'Representantes';
    
  END IF;
   
  
END TELA_HISPES;
/
