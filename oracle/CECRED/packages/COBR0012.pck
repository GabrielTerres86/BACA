CREATE OR REPLACE PACKAGE CECRED.COBR0012 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : COBR0012
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas de busca e pesquiasa de pagadores
  */

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


END COBR0012;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0012 IS
  /*---------------------------------------------------------------------------------------------------------------------
    Programa : COBR0012
    Sistema  : Ayllos Web
    Autor    : Luis Fernando (GFT)
    Data     : Março - 2018

    Dados referentes ao programa:

    Objetivo  : Centralizar rotinas de busca e pesquiasa de pagadores
  */
  /* tratamento de erro */
  vr_exc_erro exception;

  /* descriçao e código da critica */
  vr_cdcritic crapcri.cdcritic%type;
  vr_dscritic varchar2(4000);

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

END COBR0012;
/
