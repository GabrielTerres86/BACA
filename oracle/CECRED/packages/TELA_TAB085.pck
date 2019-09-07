CREATE OR REPLACE PACKAGE CECRED.TELA_TAB085 IS

 ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB085
  --  Sistema  : Rotinas utilizadas pela Tela TAB085
  --  Sigla    :
  --  Autor    : Jonata/Mouts
  --  Data     : Agosto/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB085
  --
  -- Alteracoes:
  --
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------



  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consultar_parametros(pr_cddopcao VARCHAR2 --Código da opção
                                   ,pr_cdcopsel crapcop.cdcooper%TYPE --Cõdigo da cooperativa
                                   ,pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar_parametros(pr_cddopcao IN VARCHAR2  --> Código da opção
                                 ,pr_cdcopsel IN crapcop.cdcooper%TYPE --> Cooperativa selecionada
                                 ,pr_flgopstr IN INTEGER   --> Opera str
                                 ,pr_iniopstr IN VARCHAR2   --> Hora inicio str
                                 ,pr_fimopstr IN VARCHAR2   --> Hora fim str
                                 ,pr_flgoppag IN INTEGER   --> Opera pag
                                 ,pr_inioppag IN VARCHAR2   --> Hora inicio pag
                                 ,pr_fimoppag IN VARCHAR2   --> Hora fim pag
                                 ,pr_vlmaxpag IN crapcop.vlmaxpag%TYPE --> Valor maximo pagamento vr-boleto
                                 ,pr_flgopbol IN INTEGER   --> Opera VR-boleto
                                 ,pr_iniopbol IN VARCHAR2   --> Hora inicio vr-boleto
                                 ,pr_fimopbol IN VARCHAR2   --> Hora fim vr-boleto
                                 ,pr_flgcrise IN INTEGER   --> Estado de crise
                                 ,pr_hrtrpen1 IN VARCHAR2 --> Hora execução
                                 ,pr_hrtrpen2 IN VARCHAR2 --> Hora execução
                                 ,pr_hrtrpen3 IN VARCHAR2 --> Hora execução
                                 ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);            --> Descrição do erro


  PROCEDURE pc_lista_cooperativas(pr_cdcopsel IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);         --> Descricao do Erro

END TELA_TAB085;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB085 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB085
  --  Sistema  : Rotinas utilizadas pela Tela TAB085
  --  Sigla    :
  --  Autor    : Jonata/Mouts
  --  Data     : Agosto/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB085
  --
  -- Alteracoes:
  --           17/04/2019 - Melhorias gerais e correções de erros.
  --                        Jose Dill (Mouts). P475 - REQ14
  --
  --
  ---------------------------------------------------------------------------

  --Tipo de Registro para log
  TYPE typ_reg_log IS
    RECORD(cdcooper crapcop.cdcooper%TYPE
          ,cdoperad crapope.cdoperad%TYPE
          ,nmrescop crapcop.nmrescop%TYPE
          ,dsdcampo VARCHAR2(500)
          ,vlrantes VARCHAR2(100)
          ,vldepois VARCHAR2(100));

  --Tipo de tabela de memoria para log
  TYPE typ_tab_log IS TABLE OF typ_reg_log INDEX BY pls_integer;

  -- Variavel para armazenar a tabela de memoria de log
  vr_tab_log typ_tab_log;


  PROCEDURE pc_consultar_parametros(pr_cddopcao VARCHAR2 --Código da opção
                                   ,pr_cdcopsel crapcop.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar_parametros
        Sistema : CECRED
        Autor   : Jonata/Mouts
        Data    : Agosto/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar parâmetros do SPB

        Observacao: -----

        Alteracoes:
    ..............................................................................*/



      ------Cursores
      --Cursor para encontrar a cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.flgopstr
            ,crapcop.flgoppag
            ,crapcop.iniopstr
            ,crapcop.fimopstr
            ,crapcop.inioppag
            ,crapcop.fimoppag
            ,crapcop.vlmaxpag
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;


      vr_dstextab craptab.dstextab%TYPE:= '';
      vr_flgcrise craptab.dstextab%TYPE:= '';
      vr_flgopbol INT := 0;
      vr_iniopbol VARCHAR(5);
      vr_fimopbol VARCHAR(5);
      vr_hrtrpen1 VARCHAR(5);
      vr_hrtrpen2 VARCHAR(5);
      vr_hrtrpen3 VARCHAR(5);

      --Variáveis auxiliares
      vr_clob     CLOB;
      vr_xml_temp VARCHAR2(32726) := '';

      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TAB085'
                                ,pr_action => null);
                                
      -- Extrai dados do xml
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                               pr_cdcooper => vr_cdcooper,
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
        RAISE vr_exc_saida;        
      END IF;

      IF pr_cdcopsel IS NULL THEN
        -- Busca critica
        vr_dscritic := 'Nenhuma cooperativa selecionada.';
        pr_nmdcampo := 'cdcooper';

        RAISE vr_exc_saida;

      END IF;

      IF pr_cddopcao NOT IN ('H', 'A') AND
         pr_cdcopsel = 0    THEN

        -- Busca critica
        vr_dscritic := 'Cooperativa selecionada inválida.';
        pr_nmdcampo := 'cdcooper';

        RAISE vr_exc_saida;
      END IF;

      --Se for alteração para todas as cooperativas
      IF pr_cddopcao IN ('H', 'A') AND
         pr_cdcopsel = 0   THEN

        /*REQ14 - Seleciona somente as informações de agendamento de TED's para opção H. O estado de crise 
                  deve ser inicializado como default Não. Para a opação A, as informacoes de SPB e VR-Boleto
                  devem ser inicializados com default Não para todos os campos.*/
        IF pr_cddopcao = 'H' THEN

          -- Buscar dados da TAB
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 00
                                                   ,pr_cdacesso => 'HRAGENDEBTED'
                                                   ,pr_tpregist => 0);

          --Se nao encontrou parametro
          IF TRIM(vr_dstextab) IS NULL THEN
            vr_dstextab:=0;
          END IF;
        
          vr_hrtrpen1 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 1
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');

          vr_hrtrpen2 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 2
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');

          vr_hrtrpen3 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 3
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');
        END IF;
        
        --REQ14
        vr_flgcrise := (CASE upper(TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                                     ,pr_nmsistem => 'CRED'
                                                                     ,pr_tptabela => 'GENERI'
                                                                     ,pr_cdempres => 00
                                                                     ,pr_cdacesso => 'ESTCRISE'
                                                                     ,pr_tpregist => 0))
                                   WHEN 'S' THEN
                                      1
                                   ELSE
                                      0
                                   END);        
                
        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros>');

         -- Carrega os dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<parametro>'||
                                                     '  <flgopstr>0</flgopstr>'||
                                                     '  <flgoppag>0</flgoppag>'||
                                                     '  <flgopbol>0</flgopbol>'||
                                                     '  <iniopstr>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</iniopstr>'||
                                                     '  <fimopstr>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</fimopstr>'||
                                                     '  <inioppag>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</inioppag>'||
                                                     '  <fimoppag>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</fimoppag>'||
                                                     '  <vlmaxpag>' || to_char(0,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')||'</vlmaxpag>'||
                                                     '  <iniopbol>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</iniopbol>'||
                                                     '  <fimopbol>' || to_char(to_date(0,'sssss'),'hh24:mi')||'</fimopbol>'||
                                                     '  <flgcrise>'||vr_flgcrise||'</flgcrise>'||
                                                     '  <hrtrpen1>' || vr_hrtrpen1||'</hrtrpen1>'||
                                                     '  <hrtrpen2>' || vr_hrtrpen2||'</hrtrpen2>'||
                                                     '  <hrtrpen3>' || vr_hrtrpen3||'</hrtrpen3>'||
                                                     '</parametro>');

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</parametros></Root>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

      ELSE
        /* Seleciona as informações de uma cooperativa em específico. Busca os dados do SPB-STR e PAG
           através da tabela crapcop.*/

        
        OPEN cr_crapcop(pr_cdcooper => pr_cdcopsel);

        FETCH cr_crapcop INTO rw_crapcop;

        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN

          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapcop;

          -- Montar mensagem de critica
          vr_cdcritic := 651;

          -- Busca critica
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

          RAISE vr_exc_saida;

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapcop;

        END IF;
  
        /* REQ14 - Selecionar as informações do VR_Boletos para a opção C e A*/
        IF pr_cddopcao IN ('C','A') THEN 
          -- Buscar dados da TAB
          vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 00
                                                   ,pr_cdacesso => 'HRVRBOLETO'
                                                   ,pr_tpregist => 0);

          --Se nao encontrou parametro
          IF TRIM(vr_dstextab) IS NULL THEN
            vr_cdcritic := 55;
            RAISE vr_exc_saida;
          END IF;

          vr_flgopbol := (CASE upper(gene0002.fn_busca_entrada( pr_postext => 1
                                                               ,pr_dstext  => vr_dstextab
                                                               ,pr_delimitador => ';'))
                             WHEN 'YES' THEN
                                1
                             ELSE
                                0
                          END);

          vr_iniopbol := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 2
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'sssss'),'hh24:mi');

          vr_fimopbol := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 3
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'sssss'),'hh24:mi');

        END IF;
        --
        vr_flgcrise := (CASE upper(TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                             ,pr_nmsistem => 'CRED'
                                                             ,pr_tptabela => 'GENERI'
                                                             ,pr_cdempres => 00
                                                             ,pr_cdacesso => 'ESTCRISE'
                                                             ,pr_tpregist => 0))
                           WHEN 'S' THEN
                              1
                           ELSE
                              0
                        END);
                        
        -- Buscar dados da TAB
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => 0
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 00
                                                 ,pr_cdacesso => 'HRAGENDEBTED'
                                                 ,pr_tpregist => 0);

        --Se nao encontrou parametro
        IF TRIM(vr_dstextab) IS NULL THEN
          vr_dstextab:=0;
        END IF;

        vr_hrtrpen1 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 1
                                                                  ,pr_dstext  => vr_dstextab
                                                                  ,pr_delimitador => ';'),'hh24:mi'),'hh24:mi');

        vr_hrtrpen2 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 2
                                                                  ,pr_dstext  => vr_dstextab
                                                                  ,pr_delimitador => ';'),'hh24:mi'),'hh24:mi');

        vr_hrtrpen3 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 3
                                                                  ,pr_dstext  => vr_dstextab
                                                                  ,pr_delimitador => ';'),'hh24:mi'),'hh24:mi');

        -- Monta documento XML de ERRO
        dbms_lob.createtemporary(vr_clob, TRUE);
        dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

        -- Criar cabeçalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root><parametros>');

        -- Carrega os dados
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<parametro>'||
                                                     '  <flgopstr>' || rw_crapcop.flgopstr||'</flgopstr>'||
                                                     '  <flgoppag>' || rw_crapcop.flgoppag ||'</flgoppag>'||
                                                     '  <flgopbol>' || vr_flgopbol ||'</flgopbol>'||
                                                     '  <iniopstr>' || to_char(to_date(rw_crapcop.iniopstr,'sssss'),'hh24:mi')||'</iniopstr>'||
                                                     '  <fimopstr>' || to_char(to_date(rw_crapcop.fimopstr,'sssss'),'hh24:mi')||'</fimopstr>'||
                                                     '  <inioppag>' || to_char(to_date(rw_crapcop.inioppag,'sssss'),'hh24:mi')||'</inioppag>'||
                                                     '  <fimoppag>' || to_char(to_date(rw_crapcop.fimoppag,'sssss'),'hh24:mi')||'</fimoppag>'||
                                                     '  <vlmaxpag>' || to_char(rw_crapcop.vlmaxpag,'fm999g999g999g990d00','NLS_NUMERIC_CHARACTERS='',.''')||'</vlmaxpag>'||
                                                     '  <iniopbol>' || vr_iniopbol ||'</iniopbol>'||
                                                     '  <fimopbol>' || vr_fimopbol ||'</fimopbol>'||
                                                     '  <flgcrise>' || vr_flgcrise ||'</flgcrise>'||
                                                     '  <hrtrpen1>' || vr_hrtrpen1||'</hrtrpen1>'||
                                                     '  <hrtrpen2>' || vr_hrtrpen2||'</hrtrpen2>'||
                                                     '  <hrtrpen3>' || vr_hrtrpen3||'</hrtrpen3>'||
                                                     '</parametro>');

        -- Encerrar a tag raiz
        gene0002.pc_escreve_xml(pr_xml            => vr_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</parametros></Root>'
                               ,pr_fecha_xml      => TRUE);

        -- Atualiza o XML de retorno
        pr_retxml := xmltype(vr_clob);

        -- Libera a memoria do CLOB
        dbms_lob.close(vr_clob);

    END IF;

    pr_des_erro := 'OK';

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
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela TELA_TAB085.pc_consultar_parametros: ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;

      CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

  END pc_consultar_parametros;


  PROCEDURE pc_gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_tab_log  IN typ_tab_log
                       ,pr_dscritic OUT VARCHAR2
                       ,pr_des_erro OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_gera_log                            antiga:
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Jonata - Mouts
    Data     : Agosto/2018                         Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: -----
    Objetivo   : Procedure para gerar log

    Alterações :
    -------------------------------------------------------------------------------------------------------------*/

    vr_ind PLS_INTEGER;
    -- Variáveis para armazenar as informações em XML
    vr_des_clob        clob;
    -- Variável para armazenar os dados do XML antes de incluir no CLOB
    vr_texto_completo  varchar2(32600);
    vr_nmdireto VARCHAR2(500);
    vr_exc_saida EXCEPTION;

    -- Subrotina para escrever texto na variável CLOB
    procedure pc_escreve_clob(pr_des_dados in varchar2,
                              pr_fecha_clob in boolean default false) is
    begin
      gene0002.pc_escreve_xml(vr_des_clob, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    end;

   BEGIN

     -- Inicializar o CLOB
     vr_des_clob := null;

     vr_nmdireto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_nmsubdir => '');

     IF pr_tab_log.COUNT > 0 THEN

       dbms_lob.createtemporary(vr_des_clob, true);
       dbms_lob.open(vr_des_clob, dbms_lob.lob_readwrite);
       -- Inicilizar as informações do XML
       vr_texto_completo := null;

       FOR vr_ind IN pr_tab_log.first .. pr_tab_log.COUNT LOOP

         IF pr_tab_log(vr_ind).vlrantes <> pr_tab_log(vr_ind).vldepois  THEN

           pc_escreve_clob(to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                           ' -->  Operador '|| pr_tab_log(vr_ind).cdoperad  || ' - ' ||
                           'Alterou o campo ' ||
                           pr_tab_log(vr_ind).dsdcampo || ' de ' || pr_tab_log(vr_ind).vlrantes  ||
                           ' para ' || pr_tab_log(vr_ind).vldepois  || '.' ||
                           ' Cooperativa: ' || pr_tab_log(vr_ind).nmrescop || '.' ||chr(10));

         END IF;

       END LOOP;

       -- descarregar buffer
       pc_escreve_clob('',true);

       -- Gerar arquivo
       gene0002.pc_clob_para_arquivo( pr_clob    => vr_des_clob
                                     ,pr_caminho => vr_nmdireto || '/log'
                                     ,pr_arquivo => 'tab085.log'
                                     ,pr_flappend => 'S' -- Sobreescrever
                                     ,pr_des_erro=> pr_dscritic);

       -- gerar log da critica
       IF trim(pr_dscritic) is not null THEN

         RAISE vr_exc_saida;

       END IF;

       -- Liberando a memória alocada pro CLOB
       dbms_lob.close(vr_des_clob);
       dbms_lob.freetemporary(vr_des_clob);

     END IF;

     pr_des_erro := 'OK';

   EXCEPTION
     WHEN vr_exc_saida THEN
       pr_des_erro := 'NOK';
     WHEN OTHERS THEN
       pr_dscritic := 'Erro geral em TELA_TAB085.pc_gera_log: ' || SQLERRM;
       pr_des_erro := 'NOK';
       CECRED.pc_internal_exception( pr_cdcooper => pr_cdcooper );

   END pc_gera_log;


  PROCEDURE pc_alterar_parametros(pr_cddopcao IN VARCHAR2  --> Código da opção
                                 ,pr_cdcopsel IN crapcop.cdcooper%TYPE --> Cooperativa selecionada
                                 ,pr_flgopstr IN INTEGER   --> Opera str
                                 ,pr_iniopstr IN VARCHAR2   --> Hora inicio str
                                 ,pr_fimopstr IN VARCHAR2   --> Hora fim str
                                 ,pr_flgoppag IN INTEGER   --> Opera pag
                                 ,pr_inioppag IN VARCHAR2   --> Hora inicio pag
                                 ,pr_fimoppag IN VARCHAR2   --> Hora fim pag
                                 ,pr_vlmaxpag IN crapcop.vlmaxpag%TYPE --> Valor maximo pagamento vr-boleto
                                 ,pr_flgopbol IN INTEGER   --> Opera VR-boleto
                                 ,pr_iniopbol IN VARCHAR2   --> Hora inicio vr-boleto
                                 ,pr_fimopbol IN VARCHAR2   --> Hora fim vr-boleto
                                 ,pr_flgcrise IN INTEGER   --> Estado de crise
                                 ,pr_hrtrpen1 IN VARCHAR2 --> Hora execução
                                 ,pr_hrtrpen2 IN VARCHAR2 --> Hora execução
                                 ,pr_hrtrpen3 IN VARCHAR2 --> Hora execução
                                 ,pr_xmllog    IN VARCHAR2                --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER            --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2               --> Descrição da crítica
                                 ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS           --> Descrição do erro

    -- ..........................................................................
    --
    --  Programa : pc_alterar_parametros
    --  Sistema  : CECRED
    --  Sigla    : GENE
    --  Autor    : Jonata
    --  Data     : Agosto/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Alterar parâmetros do SPB
    --
    --  Alteracoes:
    -- .............................................................................

    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.iniopstr
          ,crapcop.fimoppag
          ,crapcop.fimopstr
          ,crapcop.vlmaxpag
          ,crapcop.progress_recid
          ,crapcop.nmrescop
      FROM crapcop
     WHERE (pr_cdcooper = 0
       AND crapcop.cdcooper <> 3)
        OR crapcop.cdcooper = pr_cdcooper;

    CURSOR cr_craptab(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nmsistem IN craptab.nmsistem%TYPE
                     ,pr_tptabela IN craptab.tptabela%TYPE
                     ,pr_cdempres IN craptab.cdempres%TYPE
                     ,pr_cdacesso IN craptab.cdacesso%TYPE
                     ,pr_tpregist IN craptab.tpregist%TYPE) IS
    SELECT tab.progress_recid
          ,tab.dstextab
      FROM craptab tab
     WHERE tab.cdcooper = pr_cdcooper
       AND UPPER(tab.nmsistem) = UPPER(pr_nmsistem)
       AND UPPER(tab.tptabela) = UPPER(pr_tptabela)
       AND tab.cdempres = pr_cdempres
       AND UPPER(tab.cdacesso) = UPPER(pr_cdacesso)
       AND tab.tpregist = pr_tpregist;
    rw_craptab cr_craptab%ROWTYPE;

    --Variaveis locais
    vr_dstextab craptab.dstextab%TYPE := '';
    vr_cdoperad VARCHAR2(100);
    vr_cdcooper NUMBER;
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_des_erro VARCHAR2(10);

    vr_flgcrise craptab.dstextab%TYPE:= '';
    vr_hhinistr INTEGER(2);
    vr_mministr INTEGER(2);
    vr_hhfimstr INTEGER(2);
    vr_mmfimstr INTEGER(2);
    vr_hhinipag INTEGER(2);
    vr_mminipag INTEGER(2);
    vr_hhfimpag INTEGER(2);
    vr_mmfimpag INTEGER(2);
    vr_hhinibol INTEGER(2);
    vr_mminibol INTEGER(2);
    vr_hhfimbol INTEGER(2);
    vr_mmfimbol INTEGER(2);
    vr_hrtrpen1 INTEGER(2);
    vr_mmtrpen1 INTEGER(2);
    vr_hrtrpen2 INTEGER(2);
    vr_mmtrpen2 INTEGER(2);
    vr_hrtrpen3 INTEGER(2);
    vr_mmtrpen3 INTEGER(2);

    --Variáveis para controle de log
    vr_log_flgopbol INT := 0;
    vr_log_iniopbol VARCHAR(5);
    vr_log_fimopbol VARCHAR(5);
    vr_log_hrtrpen1 VARCHAR(5);
    vr_log_hrtrpen2 VARCHAR(5);
    vr_log_hrtrpen3 VARCHAR(5);

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_exc_saida EXCEPTION;
    vr_ind PLS_INTEGER := 0;

  BEGIN
      
    -- Inicializando as tabelas temporarias
    vr_tab_log.DELETE;

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'TELA_TAB085'
                              ,pr_action => null);

    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    OPEN cr_crapcop(pr_cdcooper => vr_cdcooper); 

    FETCH cr_crapcop into rw_crapcop;

    IF cr_crapcop%NOTFOUND THEN

      CLOSE cr_crapcop;

      vr_cdcritic := 794;
      RAISE vr_exc_saida;

    ELSE

      CLOSE cr_crapcop;

    END IF;

    IF pr_cddopcao IN ('H', 'A') AND
       vr_cdcooper <> 3 THEN

      vr_dscritic := 'Operação permitida apenas para a central AILOS.';
      RAISE vr_exc_saida;

    END IF;

    IF pr_cdcopsel IS NULL THEN
      -- Busca critica
      vr_dscritic := 'Nenhuma cooperativa selecionada.';
      pr_nmdcampo := 'cdcooper';

      RAISE vr_exc_saida;

    END IF;

    /* REQ14 - Valida e altera as informações da opção A (SPB STR, PAG e VR-Boleto) */
    IF pr_cddopcao = 'A' THEN

      IF pr_flgopstr IS NULL     OR
         pr_flgopstr NOT IN(0,1) THEN

        -- Busca critica
        vr_dscritic := 'Não informado se opera com SPB-STR.';
        pr_nmdcampo := 'flgopstr';

        RAISE vr_exc_saida;

      END if;

      IF pr_flgoppag IS NULL     OR
         pr_flgoppag NOT IN(0,1) THEN

        -- Busca critica
        vr_dscritic := 'Não informado se opera com SPB-PAG.';
        pr_nmdcampo := 'flgoppag';

        RAISE vr_exc_saida;

      END if;

      BEGIN

        vr_hhinistr := to_number(to_char(to_date(pr_iniopstr,'hh24:mi:ss'),'hh24'));
        vr_mministr := to_number(to_char(to_date(pr_iniopstr,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'iniopstr';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      BEGIN

        vr_hhfimstr := to_number(to_char(to_date(pr_fimopstr,'hh24:mi:ss'),'hh24'));
        vr_mmfimstr := to_number(to_char(to_date(pr_fimopstr,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'fimopstr';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      IF vr_hhinistr > vr_hhfimstr THEN

        -- Montar mensagem de critica
        vr_cdcritic := 687;
        pr_nmdcampo := 'iniopstr';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      BEGIN

        vr_hhinipag := to_number(to_char(to_date(pr_inioppag,'hh24:mi:ss'),'hh24'));
        vr_mminipag := to_number(to_char(to_date(pr_inioppag,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'inioppag';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      BEGIN

        vr_hhfimpag := to_number(to_char(to_date(pr_fimoppag,'hh24:mi:ss'),'hh24'));
        vr_mmfimpag := to_number(to_char(to_date(pr_fimoppag,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'fimoppag';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      IF vr_hhinipag > vr_hhfimpag THEN

        -- Montar mensagem de critica
        vr_cdcritic := 687;
        pr_nmdcampo := 'inioppag';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      BEGIN

        vr_hhinibol := to_number(to_char(to_date(pr_iniopbol,'hh24:mi:ss'),'hh24'));
        vr_mminibol := to_number(to_char(to_date(pr_iniopbol,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'iniopbol';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      BEGIN

        vr_hhfimbol := to_number(to_char(to_date(pr_fimopbol,'hh24:mi:ss'),'hh24'));
        vr_mmfimbol := to_number(to_char(to_date(pr_fimopbol,'hh24:mi:ss'),'mi'));

      EXCEPTION
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_cdcritic := 0;
          vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
          pr_nmdcampo := 'fimopbol';

          -- volta para o programa chamador
          RAISE vr_exc_saida;

      END;

      IF vr_hhinibol > vr_hhfimbol THEN

        -- Montar mensagem de critica
        vr_cdcritic := 687;
        pr_nmdcampo := 'iniopbol';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      IF pr_flgopstr = 0                                                 AND
         to_number(to_char(to_date(pr_iniopstr,'hh24:mi'),'sssss')) <> 0 AND
         to_number(to_char(to_date(pr_iniopstr,'hh24:mi'),'sssss')) <> 0 THEN

        -- Montar mensagem de critica
        vr_dscritic := 'Horário não deve ser informado.';
        pr_nmdcampo := 'flgopstr';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      IF pr_flgoppag = 0                                                 AND
         to_number(to_char(to_date(pr_inioppag,'hh24:mi'),'sssss')) <> 0 AND
         to_number(to_char(to_date(pr_inioppag,'hh24:mi'),'sssss')) <> 0 THEN

        -- Montar mensagem de critica
        vr_dscritic := 'Horário não deve ser informado.';
        pr_nmdcampo := 'flgoppag';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;

      FOR rw_cooperativa IN cr_cooperativa(pr_cdcooper => pr_cdcopsel) LOOP

        BEGIN

          UPDATE crapcop
             SET crapcop.flgopstr = pr_flgopstr
                ,crapcop.flgoppag = pr_flgoppag
                ,crapcop.iniopstr = CASE WHEN pr_flgopstr = 1 THEN to_number(to_char(to_date(pr_iniopstr,'hh24:mi'),'sssss')) ELSE 0 END /*REQ14 - Nao estava gravando zero quando parametro igual a não. Idem demais campos.*/
                ,crapcop.fimopstr = CASE WHEN pr_flgopstr = 1 THEN to_number(to_char(to_date(pr_fimopstr,'hh24:mi'),'sssss')) ELSE 0 END
                ,crapcop.inioppag = CASE WHEN pr_flgoppag = 1 THEN to_number(to_char(to_date(pr_inioppag,'hh24:mi'),'sssss')) ELSE 0 END
                ,crapcop.fimoppag = CASE WHEN pr_flgoppag = 1 THEN to_number(to_char(to_date(pr_fimoppag,'hh24:mi'),'sssss')) ELSE 0 END
                ,crapcop.vlmaxpag = CASE WHEN pr_flgoppag = 1 THEN pr_vlmaxpag                                                ELSE 0 END
           WHERE crapcop.cdcooper = rw_cooperativa.progress_recid;

        EXCEPTION
          WHEN OTHERS THEN
            -- Montar mensagem de critica
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar parâmetros para a cooperativa!' || SQLERRM;
            -- volta para o programa chamador
            RAISE vr_exc_saida;

        END;

        -- Busca craptab
        OPEN cr_craptab(pr_cdcooper => rw_cooperativa.cdcooper,
                        pr_nmsistem => 'CRED',
                        pr_tptabela => 'GENERI',
                        pr_cdempres => 0,
                        pr_cdacesso => 'HRVRBOLETO',
                        pr_tpregist => 0);

        FETCH cr_craptab INTO rw_craptab;

        -- Gerar erro caso não encontre
        IF cr_craptab%NOTFOUND THEN

           -- Fechar cursor pois teremos raise
           CLOSE cr_craptab;

           vr_dstextab := '';

           BEGIN

            INSERT INTO craptab (craptab.cdcooper
                                ,craptab.nmsistem
                                ,craptab.tptabela
                                ,craptab.cdempres
                                ,craptab.cdacesso
                                ,craptab.tpregist
                                ,craptab.dstextab)
                         VALUES(rw_cooperativa.cdcooper
                               ,'CRED'
                               ,'GENERI'
                               ,0
                               ,'HRVRBOLETO'
                               ,0
                               ,(CASE pr_flgopbol
                                  WHEN 1 THEN
                                    'YES'
                                  ELSE
                                    'NO'
                                 END) || ';' ||
                                 to_number(to_char(to_date(pr_iniopbol,'hh24:mi:ss'),'sssss')) || ';' ||
                                 to_number(to_char(to_date(pr_fimopbol,'hh24:mi:ss'),'sssss')) || ';');
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao gravar tabela de controle!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;

        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_craptab;

          vr_dstextab := rw_craptab.dstextab;

          BEGIN

            UPDATE craptab
               SET craptab.dstextab = (CASE pr_flgopbol
                                        WHEN 1 THEN
                                          'YES'
                                        ELSE
                                          'NO'
                                       END) || ';' ||
                                       to_number(to_char(to_date(pr_iniopbol,'hh24:mi:ss'),'sssss')) || ';' ||
                                       to_number(to_char(to_date(pr_fimopbol,'hh24:mi:ss'),'sssss')) || ';'
             WHERE craptab.progress_recid = rw_craptab.progress_recid;
            EXCEPTION
              WHEN OTHERS THEN
                -- Montar mensagem de critica
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar tabela de controle!' || SQLERRM;
                -- volta para o programa chamador
                RAISE vr_exc_saida;

          END;

        END IF;

        vr_log_flgopbol := (CASE upper(gene0002.fn_busca_entrada( pr_postext => 1
                                                                 ,pr_dstext  => vr_dstextab
                                                                 ,pr_delimitador => ';'))
                              WHEN 'YES' THEN
                                 1
                              ELSE
                                 0
                            END);

        vr_log_iniopbol := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 2
                                                                      ,pr_dstext  => vr_dstextab
                                                                      ,pr_delimitador => ';'),'sssss'),'hh24:mi');

        vr_log_fimopbol := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 3
                                                                      ,pr_dstext  => vr_dstextab
                                                                      ,pr_delimitador => ';'),'sssss'),'hh24:mi');

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Operando com SPB-STR';
        vr_tab_log(vr_ind).vlrantes := (CASE WHEN rw_cooperativa.flgopstr = 0 THEN 'Nao' ELSE 'Sim' END);
        vr_tab_log(vr_ind).vldepois := (CASE WHEN pr_flgopstr = 0 THEN 'Nao' ELSE 'Sim' END);

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario inicial para SPB-STR';
        vr_tab_log(vr_ind).vlrantes := to_char(to_date(rw_cooperativa.iniopstr,'sssss'),'hh24:mi');
        vr_tab_log(vr_ind).vldepois := pr_iniopstr;

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario final para SPB-STR';
        vr_tab_log(vr_ind).vlrantes := to_char(to_date(rw_cooperativa.fimopstr,'sssss'),'hh24:mi');
        vr_tab_log(vr_ind).vldepois := pr_fimopstr;

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Operando com SPB-PAG';
        vr_tab_log(vr_ind).vlrantes := (CASE WHEN rw_cooperativa.flgoppag = 0 THEN 'Nao' ELSE 'Sim' END);
        vr_tab_log(vr_ind).vldepois := (CASE WHEN pr_flgoppag = 0 THEN 'Nao' ELSE 'Sim' END);

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario inicial para SPB-PAG';
        vr_tab_log(vr_ind).vlrantes := to_char(to_date(rw_cooperativa.inioppag,'sssss'),'hh24:mi');
        vr_tab_log(vr_ind).vldepois := pr_inioppag;

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario final para SPB-PAG';
        vr_tab_log(vr_ind).vlrantes := to_char(to_date(rw_cooperativa.fimoppag,'sssss'),'hh24:mi');
        vr_tab_log(vr_ind).vldepois := pr_fimoppag;

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Valor maximo';
        vr_tab_log(vr_ind).vlrantes := to_char(rw_cooperativa.vlmaxpag,'fm999g999g999g990d00');
        vr_tab_log(vr_ind).vldepois := to_char(pr_vlmaxpag,'fm999g999g999g990d00');

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Pagamento VR-BOLETO';
        vr_tab_log(vr_ind).vlrantes := (CASE WHEN vr_log_flgopbol = 0 THEN 'Nao' ELSE 'Sim' END);
        vr_tab_log(vr_ind).vldepois := (CASE WHEN pr_flgopbol = 0 THEN 'Nao' ELSE 'Sim' END);

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario inicial de pagamento VR-BOLETO';
        vr_tab_log(vr_ind).vlrantes := vr_log_iniopbol;
        vr_tab_log(vr_ind).vldepois := pr_iniopbol;

        vr_ind:= vr_ind + 1;

        -- alimentando a tabela temporaria
        vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
        vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
        vr_tab_log(vr_ind).nmrescop := rw_cooperativa.nmrescop;
        vr_tab_log(vr_ind).dsdcampo := 'Horario final de pagamento VR-BOLETO';
        vr_tab_log(vr_ind).vlrantes := vr_log_fimopbol;
        vr_tab_log(vr_ind).vldepois := pr_fimopbol;

      END LOOP;

      pc_gera_log(pr_cdcooper => vr_cdcooper
                 ,pr_tab_log  => vr_tab_log
                 ,pr_dscritic => vr_dscritic
                 ,pr_des_erro => vr_des_erro);

      IF vr_des_erro <> 'OK' THEN

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END IF;      

    END IF; -- IF pr_cddopcao = 'A' THEN
      

    /* REQ14 - A opção H atualiza as informacoes do estado de crise e de agendamentos*/
    IF pr_cddopcao = 'H' THEN

      -- Busca craptab
      OPEN cr_craptab(pr_cdcooper => 0,
                      pr_nmsistem => 'CRED',
                      pr_tptabela => 'GENERI',
                      pr_cdempres => 0,
                      pr_cdacesso => 'ESTCRISE',
                      pr_tpregist => 0);

      FETCH cr_craptab INTO rw_craptab;

      -- Gerar erro caso não encontre
      IF cr_craptab%NOTFOUND THEN

         -- Fechar cursor pois teremos raise
         CLOSE cr_craptab;

         BEGIN

          INSERT INTO craptab (craptab.cdcooper
                              ,craptab.nmsistem
                              ,craptab.tptabela
                              ,craptab.cdempres
                              ,craptab.cdacesso
                              ,craptab.tpregist
                              ,craptab.dstextab)
                       VALUES(0
                             ,'CRED'
                             ,'GENERI'
                             ,0
                             ,'ESTCRISE'
                             ,0
                             ,(CASE WHEN pr_flgcrise = 0 THEN 'N' ELSE 'S' END) );
          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao gravar tabela de controle!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_craptab;

        vr_flgcrise := rw_craptab.dstextab;


        BEGIN

          UPDATE craptab
             SET craptab.dstextab = (CASE WHEN pr_flgcrise = 0 THEN 'N' ELSE 'S' END)
           WHERE craptab.progress_recid = rw_craptab.progress_recid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar tabela de controle!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      END IF;
      

      BEGIN

        vr_hrtrpen1 := to_number(to_char(to_date(pr_hrtrpen1,'hh24:mi:ss'),'hh24'));
        vr_mmtrpen1 := to_number(to_char(to_date(pr_hrtrpen1,'hh24:mi:ss'),'mi'));

      EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
        pr_nmdcampo := 'hrtrpen1';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END;

      BEGIN

        vr_hrtrpen2 := to_number(to_char(to_date(pr_hrtrpen2,'hh24:mi:ss'),'hh24'));
        vr_mmtrpen2 := to_number(to_char(to_date(pr_hrtrpen2,'hh24:mi:ss'),'mi'));

      EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
        pr_nmdcampo := 'hrtrpen2';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END;

      BEGIN

        vr_hrtrpen3 := to_number(to_char(to_date(pr_hrtrpen3,'hh24:mi:ss'),'hh24'));
        vr_mmtrpen3 := to_number(to_char(to_date(pr_hrtrpen3,'hh24:mi:ss'),'mi'));

      EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'O intervalo em horas deve estar entre 0 e 23.';
        pr_nmdcampo := 'hrtrpen3';

        -- volta para o programa chamador
        RAISE vr_exc_saida;

      END;
      
      -- Busca craptab
      OPEN cr_craptab(pr_cdcooper => 0,
                      pr_nmsistem => 'CRED',
                      pr_tptabela => 'GENERI',
                      pr_cdempres => 0,
                      pr_cdacesso => 'HRAGENDEBTED',
                      pr_tpregist => 0);

      FETCH cr_craptab INTO rw_craptab;

      -- Gerar erro caso não encontre
      IF cr_craptab%NOTFOUND THEN

         -- Fechar cursor pois teremos raise
         CLOSE cr_craptab;

         vr_dstextab := '';

         BEGIN

          INSERT INTO craptab (craptab.cdcooper
                              ,craptab.nmsistem
                              ,craptab.tptabela
                              ,craptab.cdempres
                              ,craptab.cdacesso
                              ,craptab.tpregist
                              ,craptab.dstextab)
                       VALUES(0
                             ,'CRED'
                             ,'GENERI'
                             ,0
                             ,'HRAGENDEBTED'
                             ,0
                             ,to_char(to_date(pr_hrtrpen1,'hh24:mi'),'hh24mi') || ';' ||
                              to_char(to_date(pr_hrtrpen2,'hh24:mi'),'hh24mi') || ';' ||
                              to_char(to_date(pr_hrtrpen3,'hh24:mi'),'hh24mi') || ';');
          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao gravar tabela de controle!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_craptab;

        vr_dstextab := rw_craptab.dstextab;

        BEGIN

          UPDATE craptab
             SET craptab.dstextab = to_char(to_date(pr_hrtrpen1,'hh24:mi'),'hh24mi') || ';' ||
                                    to_char(to_date(pr_hrtrpen2,'hh24:mi'),'hh24mi') || ';' ||
                                    to_char(to_date(pr_hrtrpen3,'hh24:mi'),'hh24mi') || ';'
           WHERE craptab.progress_recid = rw_craptab.progress_recid;
          EXCEPTION
            WHEN OTHERS THEN
              -- Montar mensagem de critica
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar tabela de controle!' || SQLERRM;
              -- volta para o programa chamador
              RAISE vr_exc_saida;

        END;

      END IF;

      vr_log_hrtrpen1 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 1
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');

      vr_log_hrtrpen2 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 2
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');

      vr_log_hrtrpen3 := to_char(to_date( gene0002.fn_busca_entrada( pr_postext => 3
                                                                    ,pr_dstext  => vr_dstextab
                                                                    ,pr_delimitador => ';'),'hh24mi'),'hh24:mi');

      vr_ind:= vr_ind + 1;

      -- alimentando a tabela temporaria
      vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
      vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
      vr_tab_log(vr_ind).nmrescop := 'Todas';
      vr_tab_log(vr_ind).dsdcampo := 'Sistema em estado de crise';
      vr_tab_log(vr_ind).vlrantes := (CASE WHEN vr_flgcrise = 'S' THEN 'Sim' ELSE 'Nao' END);
      vr_tab_log(vr_ind).vldepois := (CASE WHEN pr_flgcrise = 1 THEN 'Sim' ELSE 'Nao' END);

      vr_ind:= vr_ind + 1;

      -- alimentando a tabela temporaria
      vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
      vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
      vr_tab_log(vr_ind).nmrescop := 'Todas';
      vr_tab_log(vr_ind).dsdcampo := 'Horario execucao 1 para SPB-Transacoes Agendadas';
      vr_tab_log(vr_ind).vlrantes := vr_log_hrtrpen1;
      vr_tab_log(vr_ind).vldepois := pr_hrtrpen1;


      vr_ind:= vr_ind + 1;

      -- alimentando a tabela temporaria
      vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
      vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
      vr_tab_log(vr_ind).nmrescop := 'Todas';
      vr_tab_log(vr_ind).dsdcampo := 'Horario execucao 2 para SPB-Transacoes Agendadas';
      vr_tab_log(vr_ind).vlrantes := vr_log_hrtrpen2;
      vr_tab_log(vr_ind).vldepois := pr_hrtrpen2;

      vr_ind:= vr_ind + 1;

      -- alimentando a tabela temporaria
      vr_tab_log(vr_ind).cdcooper := vr_cdcooper;
      vr_tab_log(vr_ind).cdoperad := vr_cdoperad;
      vr_tab_log(vr_ind).nmrescop := 'Todas';
      vr_tab_log(vr_ind).dsdcampo := 'Horario execucao 3 para SPB-Transacoes Agendadas';
      vr_tab_log(vr_ind).vlrantes := vr_log_hrtrpen3;
      vr_tab_log(vr_ind).vldepois := pr_hrtrpen3;
      --
      pc_gera_log(pr_cdcooper => vr_cdcooper
                     ,pr_tab_log  => vr_tab_log
                     ,pr_dscritic => vr_dscritic
                     ,pr_des_erro => vr_des_erro);
      --
      IF vr_des_erro <> 'OK' THEN
        -- volta para o programa chamador
        RAISE vr_exc_saida;
      END IF;            

    END IF; -- IF pr_cddopcao = 'H' THEN

    --Realiza commit das alterações
    COMMIT;
    pr_des_erro := 'OK';


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

      ROLLBACK;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral em TELA_TAB085.pc_alterar_parametros: ' || SQLERRM;
      pr_des_erro := 'NOK';

      pr_retxml   := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

      ROLLBACK;

  END pc_alterar_parametros;

  -- Listar cooperativa ayllosweb
  PROCEDURE pc_lista_cooperativas(pr_cdcopsel IN crapcop.cdcooper%TYPE --> Codigo da Cooperativa
                                 ,pr_flgativo IN crapcop.flgativo%TYPE --> Flag Ativo
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY xmltype    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_lista_cooperativas
    --  Sistema  : Rotinas para listar as cooperativas do sistema
    --  Sigla    : GENE
    --  Autor    : Jonata
    --  Data     : Agosto/2018.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Retornar a lista de cooperativas no sistema.
    --
    --  Alteracoes:
    -- .............................................................................
  BEGIN
    DECLARE

      -- Cursores
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper,
               INITCAP(cop.nmrescop) nmrescop,
               cop.flgativo
          FROM crapcop cop
         WHERE (cop.cdcooper = pr_cdcopsel OR pr_cdcopsel = 0)
           AND cop.flgativo = pr_flgativo
         ORDER BY cop.nmrescop;

      rw_crapcop cr_crapcop%ROWTYPE;

      -- Variaveis locais
      vr_contador INTEGER := 0;
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      vr_exc_saida EXCEPTION;


    BEGIN

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_TAB085'
                                ,pr_action => null);

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Se retornou alguma crítica
      IF TRIM(pr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
      END IF;

      FOR rw_crapcop IN cr_crapcop LOOP

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'inf',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => rw_crapcop.cdcooper,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmrescop',
                               pr_tag_cont => rw_crapcop.nmrescop,
                               pr_des_erro => pr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'inf',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'flgativo',
                               pr_tag_cont => rw_crapcop.flgativo,
                               pr_des_erro => pr_dscritic);

        vr_contador := vr_contador + 1;

      END LOOP;

      pr_des_erro := 'OK';

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_des_erro := 'NOK';

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'NOK';
        pr_dscritic := 'Erro geral em TELA_tab085.pc_lista_cooperativas: ' || SQLERRM;

        CECRED.pc_internal_exception( pr_cdcooper => vr_cdcooper );

    END;
  END pc_lista_cooperativas;


END TELA_TAB085;
/
