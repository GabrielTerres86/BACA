CREATE OR REPLACE PACKAGE CECRED.TELA_CADPCP IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_CADPCP
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 16/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela CADPCP
  */
  
  PROCEDURE pc_busca_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
                          ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2             --> Erros do processo
                          );
                                
  PROCEDURE pc_pesquisa_pagadores(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nmdsacad IN VARCHAR2               --> Nome do pagador
                                 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                                 );
                                 
  PROCEDURE pc_obter_pagador(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> CPF/CNPJ do pagador
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                             );
                             
  PROCEDURE pc_alterar_pagador(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> CPF/CNPJ do pagador
                                 ,pr_vlpercen IN crapsab.vlpercen%TYPE  --> Valor da nova porcentagem
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2              --> Erros do processo
                               );
END TELA_CADPCP;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADPCP IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : TELA_CADPCP
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018                 Ultima atualizacao: 16/03/2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas relacionadas a tela CADPCP
  */
  /* tratamento de erro */
  vr_exc_erro exception;

  /* descriçao e código da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);
  
    -- Buscar informações da conta  
  PROCEDURE pc_busca_conta(pr_nrdconta IN crapass.nrdconta%TYPE --> Nr. da conta
                          ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                          ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................
    Programa: pc_busca_conta
    Sistema : Ayllos Web
    Autor   : Luis Fernando (GFT)
    Data    : Março/2018

    Dados referentes ao programa:
    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar os dados do cooperado
    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Buscar associado
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      vr_nmprimtl crapass.nmprimtl%TYPE;
      
    BEGIN
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADPCP'
                                ,pr_action => null); 
      
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

      -- Se retornou algum erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Buscar nome do associado
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_nmprimtl;
      
      -- Se não encontrou associado
      IF cr_crapass%NOTFOUND THEN
        -- Fechar cursor
        CLOSE cr_crapass;
        -- Gera crítica
        vr_cdcritic := 9;
        vr_dscritic := '';
        -- Levanta exceção
        RAISE vr_exc_erro;
      END IF;
      -- Fechar cursor
      CLOSE cr_crapass;      
      
      -- Criar XML de retorno
      pr_retxml := XMLTYPE.CREATEXML(
                    '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>'
                 || '<nmprimtl>' || vr_nmprimtl || '</nmprimtl>'
                 || '</Dados></Root>');

      
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPCP: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_conta;
  
    -- Rotina para pesquisar pagadores
  PROCEDURE pc_pesquisa_pagadores(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nmdsacad IN VARCHAR2               --> Nome do pagador
                                 ,pr_nriniseq IN PLS_INTEGER            --> Numero inicial do registro para enviar
                                 ,pr_nrregist IN PLS_INTEGER            --> Numero de registros que deverao ser retornados
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_pesquisa_pagadores
    Sistema : Ayllos Web
    Autor   : Luis Fernando (GFT)
    Data    : Março/2018

    Dados referentes ao programa:
    Frequencia: Chamado pelo mostrapesquisa
    Objetivo  : Rotina para pesquisar os pagadores da conta
    Alteracoes: -----
    ..............................................................................*/

        

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_contador PLS_INTEGER := 0;
      vr_posreg   PLS_INTEGER := 0;
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      
      -- Cursor sobre a tabela de operadoras
      CURSOR cr_crapsab IS
        SELECT crapsab.nmdsacad
              ,crapsab.cdtpinsc
              ,crapsab.nrinssac
              ,crapsab.nmcidsac
              ,crapsab.cdufsaca
              ,count(1) over() retorno
              ,crapsab.vlpercen
        FROM crapsab
        WHERE 
            crapsab.cdcooper = vr_cdcooper
            AND   crapsab.nrdconta = pr_nrdconta
            AND   UPPER(crapsab.nmdsacad) LIKE UPPER('%'||pr_nmdsacad||'%')
        ORDER BY nmdsacad;
        rw_crapsab cr_crapsab%rowtype;
      
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de Pagadores
         OPEN  cr_crapsab;
         LOOP
               FETCH cr_crapsab INTO rw_crapsab;
               EXIT  WHEN cr_crapsab%NOTFOUND;
               vr_posreg := vr_posreg + 1;
                -- Incrementa o contador de registros
                -- Se for o primeiro registro, insere uma tag com o total de registros existentes no filtro
                IF vr_posreg = 1 THEN
                  gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                         ,pr_texto_completo => vr_xml_temp
                                         ,pr_texto_novo     => '<PAGADORES qtregist="' || rw_crapsab.retorno || '">');
                END IF;
                -- Enviar somente se a linha for superior a linha inicial
                IF nvl(pr_nriniseq,0) <= vr_posreg THEN
                  -- Carrega os dados
                  gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                         ,pr_texto_completo => vr_xml_temp
                                         ,pr_texto_novo     => '<inf>'||
                                                                  '<nrinssac>'|| rw_crapsab.nrinssac ||'</nrinssac>'||
                                                                  '<nmdsacad>'|| rw_crapsab.nmdsacad||'</nmdsacad>'||                                                           
                                                                  '<cdtpinsc>' || rw_crapsab.cdtpinsc ||'</cdtpinsc>'||
                                                                  '<vlpercen>' || rw_crapsab.vlpercen ||'</vlpercen>'||
                                                                  '<nrdconta>' || pr_nrdconta ||'</nrdconta>'||
                                                               '</inf>');
                  vr_contador := vr_contador + 1;
                END IF;

                -- Deve-se sair se o total de registros superar o total solicitado
                EXIT WHEN vr_contador > nvl(pr_nrregist,99999);

        END LOOP;

        -- Se nao possuir nenhum registro, envia a quantidade de registros zerada
        IF vr_posreg = 0 THEN
          -- Gerar crítica
          gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<PAGADORES qtregist="0">');
        END IF;

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</PAGADORES></Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na pesquisa pagadores: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_pesquisa_pagadores;
  
   -- Rotina para pesquisar pagadores
  PROCEDURE pc_obter_pagador(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> CPF/CNPJ do pagador
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_obter_pagador
    Sistema : Ayllos Web
    Autor   : Luis Fernando (GFT)
    Data    : Março/2018

    Dados referentes ao programa:
    Frequencia: Sempre que chamado
    Objetivo  : Rotina que traz o pagador tomando em base o cpf/cnpj e a conta
    Alteracoes: -----
    ..............................................................................*/

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      
      
      -- Cursor sobre a tabela de operadoras
      CURSOR cr_crapsab IS
        SELECT crapsab.nmdsacad
              ,crapsab.cdtpinsc
              ,crapsab.nrinssac
              ,crapsab.nmcidsac
              ,crapsab.cdufsaca
              ,crapsab.vlpercen
        FROM crapsab
        WHERE
            crapsab.cdcooper = vr_cdcooper
            AND   crapsab.nrdconta = pr_nrdconta
            AND   nrinssac = pr_nrinssac;
        rw_crapsab cr_crapsab%rowtype;
      
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
         OPEN  cr_crapsab;
         FETCH cr_crapsab INTO rw_crapsab;
         IF (cr_crapsab%NOTFOUND) THEN
            vr_dscritic := 'Pagador nao encontrado para essa conta';
            raise vr_exc_erro;
         END IF;
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de Pagadores
                  gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                         ,pr_texto_completo => vr_xml_temp
                                         ,pr_texto_novo     => '<inf>'||
                                                                  '<nrinssac>'|| rw_crapsab.nrinssac ||'</nrinssac>'||
                                                                  '<nmdsacad>'|| rw_crapsab.nmdsacad||'</nmdsacad>'||                                                           
                                                                  '<cdtpinsc>' || rw_crapsab.cdtpinsc ||'</cdtpinsc>'||
                                                                  '<vlpercen>' || rw_crapsab.vlpercen ||'</vlpercen>'||
                                                                  '<nrdconta>' || pr_nrdconta ||'</nrdconta>'||
                                                               '</inf>');
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na BUSCA DE PAGADOR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_obter_pagador;
  
   -- Rotina para pesquisar pagadores
  PROCEDURE pc_alterar_pagador(pr_nrdconta IN crapass.nrdconta%TYPE  --> Nr. da conta
                                 ,pr_nrinssac IN crapsab.nrinssac%TYPE  --> CPF/CNPJ do pagador
                                 ,pr_vlpercen IN crapsab.vlpercen%TYPE  --> Valor da nova porcentagem
                                 ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
    /* .............................................................................
    Programa: pc_obter_pagador
    Sistema : Ayllos Web
    Autor   : Luis Fernando (GFT)
    Data    : Março/2018

    Dados referentes ao programa:
    Frequencia: Sempre que chamado
    Objetivo  : Rotina que altera o valor da procentagem do pagador
    Alteracoes: -----
    ..............................................................................*/

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Variaveis de log
      vr_cdoperad      VARCHAR2(100);
      vr_cdcooper      NUMBER;
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      -- Variaveis gerais
      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;
      vr_vlpercen INTEGER; -- FEITA PARA DAR MENSAGEM NA ALTERACAO
      
      
      -- Cursor sobre a tabela de operadoras
      CURSOR cr_crapsab IS
        SELECT crapsab.nmdsacad
              ,crapsab.cdtpinsc
              ,crapsab.nrinssac
              ,crapsab.nmcidsac
              ,crapsab.cdufsaca
              ,crapsab.vlpercen
        FROM crapsab
        WHERE
            crapsab.cdcooper = vr_cdcooper
            AND   crapsab.nrdconta = pr_nrdconta
            AND   nrinssac = pr_nrinssac;
        rw_crapsab cr_crapsab%rowtype;
      
    BEGIN

        gene0004.pc_extrai_dados(pr_xml => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);
                                
         OPEN  cr_crapsab;
         FETCH cr_crapsab INTO rw_crapsab;
         IF (cr_crapsab%NOTFOUND) THEN
            vr_dscritic := 'Pagador nao encontrado para essa conta';
            raise vr_exc_erro;
         END IF;
         vr_vlpercen := rw_crapsab.vlpercen;
         
         UPDATE 
             crapsab
         SET
             crapsab.vlpercen = pr_vlpercen
         WHERE
             crapsab.cdcooper = vr_cdcooper
             AND crapsab.nrdconta = pr_nrdconta
             AND crapsab.nrinssac = pr_nrinssac;
         
        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);
        
        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados>');

        -- Loop sobre a tabela de Pagadores
                  gene0002.pc_escreve_xml(pr_xml            => vr_clob
                                         ,pr_texto_completo => vr_xml_temp
                                         ,pr_texto_novo     => '<inf>'||
                                                                  '<vlpercenan>'|| vr_vlpercen ||'</vlpercenan>'||
                                                                  '<vlpercen>'|| pr_vlpercen ||'</vlpercen>'||  
                                                               '</inf>');
        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</Dados>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na ALTERACAO DE PAGADOR: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
  END pc_alterar_pagador;
  
END TELA_CADPCP;
/
