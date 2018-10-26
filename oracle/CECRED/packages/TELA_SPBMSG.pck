CREATE OR REPLACE PACKAGE CECRED.tela_spbmsg AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SPBMSG
  --    Autor   : Everton Souza - Mouts
  --    Data    : Julho/2018                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Atender as necessidades da tela SPBMSG
  --                Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_busca_filtros(pr_xmllog        IN VARCHAR2            --> XML com informações de LOG
                            ,pr_cdcritic     OUT PLS_INTEGER         --> Código da crítica
                            ,pr_dscritic     OUT VARCHAR2            --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                            ,pr_nmdcampo     OUT VARCHAR2            --> Nome do campo com erro
                            ,pr_des_erro     OUT VARCHAR2);          --> Erros do processo

  PROCEDURE pc_busca_mensagens(pr_cdcooper_filtro IN crapcop.cdcooper%type                  --> Código da Cooperativa
                              ,pr_cdfase          IN tbspb_fase_mensagem.cdfase%type        --> Código da Fase Mensagem
                              ,pr_mensagem        IN tbspb_msg_enviada_fase.Nmmensagem%type --> Nome da mensagem
                              ,pr_valorini        IN VARCHAR2                               --> Valor de Inicio
                              ,pr_valorfim        IN VARCHAR2                               --> Valor fim
                              ,pr_horarioini      IN VARCHAR2                               --> Horário inicio
                              ,pr_horariofim      IN VARCHAR2                               --> Horário final
                              ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                              ,pr_des_erro       OUT VARCHAR2);                             --> Saida OK/NOK

  PROCEDURE pc_reprocessa_msg(pr_nrseq_mensagem_xml IN VARCHAR2                 --> Sequência da mensagem XML - Separado por ;
                             ,pr_cdcooper_msg       IN VARCHAR2                 --> Código da Cooperativa     - Separado por ;
                             ,pr_nrdconta           IN VARCHAR2                 --> Número da Conta           - Separado por ;
                             ,pr_xmllog             IN VARCHAR2                 --> XML com informações de LOG
                             ,pr_cdcritic          OUT PLS_INTEGER              --> Código da crítica
                             ,pr_dscritic          OUT VARCHAR2                 --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY xmltype           --> Arquivo de retorno do XML
                             ,pr_nmdcampo          OUT VARCHAR2                 --> Nome do Campo
                             ,pr_des_erro          OUT VARCHAR2);               --> Saida OK/NOK



END tela_spbmsg;
/
CREATE OR REPLACE PACKAGE BODY CECRED.tela_spbmsg AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_SPBMSG
  --    Autor   : Everton Souza
  --    Data    : Agosto/2018                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela SPBMSG
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Busca dados para popular combos de filtragem tela concip
  PROCEDURE pc_busca_filtros(pr_xmllog        IN VARCHAR2            --> XML com informações de LOG
                            ,pr_cdcritic     OUT PLS_INTEGER         --> Código da crítica
                            ,pr_dscritic     OUT VARCHAR2            --> Descrição da crítica
                            ,pr_retxml    IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                            ,pr_nmdcampo     OUT VARCHAR2            --> Nome do campo com erro
                            ,pr_des_erro     OUT VARCHAR2) IS        --> Erros do processo

      vr_xml_temp VARCHAR2(32726) := '';
      vr_clob     CLOB;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(32000);

      -- Consulta cooperativas
      CURSOR cr_busca_coop IS
          SELECT a.cdcooper,
                 a.nmrescop
            FROM crapcop a
           WHERE a.flgativo = 1
           ORDER BY 1;

      -- Consulta fase mensagem
      CURSOR cr_busca_fasemsg IS
          SELECT a.cdfase,
                 a.nmfase
            FROM tbspb_fase_mensagem a
           WHERE a.idreprocessa_mensagem = 1
            ORDER BY 1;

      BEGIN

          gene0001.pc_informa_acesso(pr_module => 'SPBMSG');

          -- Monta documento XML
          dbms_lob.createtemporary(vr_clob, TRUE);
          dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

          -- Criar cabeçalho do XML
          GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Dados><cooperativas>');

          -- Iteracao credenciadoras
          FOR rw_busca_coop IN cr_busca_coop() LOOP
              GENE0002.pc_escreve_xml(
                  pr_xml => vr_clob,
                  pr_texto_completo => vr_xml_temp,
                  pr_texto_novo => '<item>' ||
                                   '<codigo>' || TRIM(rw_busca_coop.cdcooper) ||'</codigo>' ||
                                   '<nome>' || TRIM(rw_busca_coop.nmrescop) ||'</nome>' ||
                                   '</item>');
          END LOOP;

          -- Escreve delimitador
          GENE0002.pc_escreve_xml(
                  pr_xml => vr_clob,
                  pr_texto_completo => vr_xml_temp,
                  pr_texto_novo => '</cooperativas><fases>');
          --
          -- Fases Mensagens
          FOR rw_busca_fasemsg IN cr_busca_fasemsg() LOOP
              GENE0002.pc_escreve_xml(
                  pr_xml => vr_clob,
                  pr_texto_completo => vr_xml_temp,
                  pr_texto_novo => '<item>' ||
                                   '<codigo>' || TRIM(rw_busca_fasemsg.cdfase) ||'</codigo>' ||
                                   '<nome>' || TRIM(rw_busca_fasemsg.nmfase) ||'</nome>' ||
                                   '</item>');
          END LOOP;

          -- Escreve delimitador
          GENE0002.pc_escreve_xml(
                  pr_xml => vr_clob,
                  pr_texto_completo => vr_xml_temp,
                  pr_texto_novo => '</fases></Dados>'
                  ,pr_fecha_xml => TRUE);

          -- Atualiza o XML de retorno
          pr_retxml := xmltype(vr_clob);

          -- Libera a memoria do CLOB
          dbms_lob.close(vr_clob);
          dbms_lob.freetemporary(vr_clob);

        EXCEPTION
          WHEN vr_exc_saida THEN

            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;

            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

          WHEN OTHERS THEN

            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral em pc_busca_filtros: ' || SQLERRM;

            -- Carregar XML padrão para variável de retorno não utilizada.
            -- Existe para satisfazer exigência da interface.
            pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_busca_filtros;

  PROCEDURE pc_busca_mensagens(pr_cdcooper_filtro IN crapcop.cdcooper%type                  --> Código da Cooperativa
                              ,pr_cdfase          IN tbspb_fase_mensagem.cdfase%type        --> Código da Fase Mensagem
                              ,pr_mensagem        IN tbspb_msg_enviada_fase.Nmmensagem%type --> Nome da mensagem
                              ,pr_valorini        IN VARCHAR2                               --> Valor de Inicio
                              ,pr_valorfim        IN VARCHAR2                               --> Valor fim
                              ,pr_horarioini      IN VARCHAR2                               --> Horário inicio
                              ,pr_horariofim      IN VARCHAR2                               --> Horário final
                              ,pr_xmllog          IN VARCHAR2                               --> XML com informações de LOG
                              ,pr_cdcritic       OUT PLS_INTEGER                            --> Código da crítica
                              ,pr_dscritic       OUT VARCHAR2                               --> Descrição da crítica
                              ,pr_retxml      IN OUT NOCOPY xmltype                         --> Arquivo de retorno do XML
                              ,pr_nmdcampo       OUT VARCHAR2                               --> Nome do Campo
                              ,pr_des_erro       OUT VARCHAR2) IS                           --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_mensagens
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Everton Souza
    Data    : Agosto/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para carregar as mensagens SPB a serem reprocessadas

    Alteracoes:
    ............................................................................. */

    --Cursor para pegar fases das mensagens SPB
    CURSOR cr_mensagem IS

      SELECT d.nmfase,
             a.nrseq_mensagem,
             b.nmmensagem,
             TO_CHAR(b.dhmensagem,'hh24:mi') dhmensagem,
             a.cdcooper,
             f.nmrescop,
             GENE0002.fn_mask_conta(a.nrdconta)  nrdconta,
             a.nrcontrole_str_pag,
             b.nrseq_mensagem_xml,
             a.nrcontrole_if,
             sspb0003.fn_busca_conteudo_campo(e.dsxml_completo,
                                              'VlrLanc',
                                              'N' ) valor,
             sspb0003.fn_busca_conteudo_campo(e.dsxml_completo,
                                              'ISPBIFCredtd',
                                              'S' ) ifdestino,
             REPLACE(REPLACE(dbms_lob.substr(DSXML_COMPLETO, 4000, 1),
                             '><',
                             '>' || CHR(10) || '<'),' ','') dsxml_completo
        FROM tbspb_msg_enviada      a,
             tbspb_msg_enviada_fase b,
             tbspb_fase_mensagem    d,
             TBSPB_MSG_XML          e,
             crapcop                f
       WHERE b.nrseq_mensagem     = a.nrseq_mensagem
         AND b.cdfase             = 10
         AND b.cdfase             = d.cdfase
         AND b.nrseq_mensagem_xml = e.nrseq_mensagem_xml
         AND a.cdcooper           = f.cdcooper
         AND b.dhmensagem        >= TRUNC(SYSDATE)
         AND a.cdcooper           = nvl(pr_cdcooper_filtro,a.cdcooper)
         AND NOT EXISTS (SELECT 1
                           FROM tbspb_msg_enviada_fase pp
                          WHERE pp.nrseq_mensagem = a.nrseq_mensagem
                            AND pp.cdfase         = NVL(pr_cdfase,999))
         AND b.nmmensagem         = NVL(UPPER(pr_mensagem),b.nmmensagem)
         AND TO_CHAR(a.dhmensagem,'hh24:mi')
                            BETWEEN NVL(pr_horarioini,TO_CHAR(a.dhmensagem,'hh24:mi'))
                                AND NVL(pr_horariofim,TO_CHAR(a.dhmensagem,'hh24:mi'))
         AND to_number(sspb0003.fn_busca_conteudo_campo(e.dsxml_completo,
	                                                 'VlrLanc',
                                                'N' ),'99999990.00')
                            BETWEEN TO_NUMBER(NVL(pr_valorini,0))
                                AND TO_NUMBER(NVL(pr_valorfim,9999999999))
         AND (SELECT COUNT(*)
                FROM tbspb_fase_mensagem zz
                    ,tbspb_msg_enviada_fase xx
               WHERE xx.nrseq_mensagem        = a.nrseq_mensagem
                 AND xx.cdfase                = zz.cdfase
                 AND zz.idreprocessa_mensagem = 1) <> (SELECT COUNT(*)
                                                         FROM tbspb_fase_mensagem mm
                                                        WHERE mm.idreprocessa_mensagem = 1)
       ORDER BY 2 desc;

    rw_mensagem cr_mensagem%ROWTYPE;

    CURSOR cr_crapban (pr_nrispbif number) IS
      select nmresbcc
        from CRAPBAN
       where dtinispb is not null
         and nrispbif = pr_nrispbif;

    rw_crapban cr_crapban%ROWTYPE;

    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    -- Variaveis locais
    vr_contador INTEGER := 0;

    --Controle de erro
    vr_exc_erro EXCEPTION;

  BEGIN
    -- valida horário
    IF NVL(pr_horarioini,'00:00') > NVL(pr_horariofim,'23:59') THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Horário DE deve ser menor que o horário ATE!';
      RAISE vr_exc_erro;
    END IF;
    --
    -- valida valor
    IF TO_NUMBER(NVL(pr_valorini,0)) > TO_NUMBER(NVL(pr_valorfim,9999999999)) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Valor DE deve ser menor que o Valor ATE!';
      RAISE vr_exc_erro;
    END IF;
    --
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
    --
    -- Carregar arquivo com a tabela tbspb_fase_mensagem
    FOR rw_mensagem in cr_mensagem LOOP
      -- Buscar a fase da mensagem que está faltando
      FOR r1 in (SELECT *
                   FROM tbspb_fase_mensagem a
                  WHERE a.idreprocessa_mensagem = 1
                    AND NOT EXISTS (SELECT 1
                                      FROM TBSPB_MSG_ENVIADA_FASE b
                                     WHERE b.nrseq_mensagem = rw_mensagem.nrseq_mensagem
                                       AND b.cdfase         = a.cdfase)
                                     ORDER BY a.cdfase)
      LOOP
        rw_mensagem.nmfase := r1.nmfase;
        EXIT;
      END LOOP;
      --
      --Escrever no XML
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Dados',
                               pr_posicao  => 0,
                               pr_tag_nova => 'mensagem',
                               pr_tag_cont => NULL,
                               pr_des_erro => vr_dscritic);

        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmfase',
                               pr_tag_cont => rw_mensagem.nmfase,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrseq_mensagem',
                               pr_tag_cont => rw_mensagem.nrseq_mensagem,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmmensagem',
                               pr_tag_cont => rw_mensagem.nmmensagem,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dhmensagem',
                               pr_tag_cont => rw_mensagem.dhmensagem,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'cdcooper',
                               pr_tag_cont => rw_mensagem.cdcooper,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nmrescop',
                               pr_tag_cont => rw_mensagem.nmrescop,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrdconta',
                               pr_tag_cont => rw_mensagem.nrdconta,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrcontrole_str_pag',
                               pr_tag_cont => rw_mensagem.nrcontrole_str_pag,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrseq_mensagem_xml',
                               pr_tag_cont => rw_mensagem.nrseq_mensagem_xml,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'valor',
                               pr_tag_cont => rw_mensagem.valor,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'nrcontrole_if',
                               pr_tag_cont => rw_mensagem.nrcontrole_if,
                               pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'mensagem',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsxml_completo',
                               pr_tag_cont => rw_mensagem.dsxml_completo,
                               pr_des_erro => vr_dscritic);

        FOR rw_crapban in cr_crapban(to_number(rw_mensagem.ifdestino)) LOOP
          gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                                 pr_tag_pai  => 'mensagem',
                                 pr_posicao  => vr_contador,
                                 pr_tag_nova => 'ifdestino',
                                 pr_tag_cont => rw_crapban.nmresbcc,
                                 pr_des_erro => vr_dscritic);
        END LOOP;

        vr_contador := vr_contador + 1;
        --
    END LOOP;
    --
    pr_des_erro := 'OK';
    --
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_SPBMSG.pc_busca_mensagens --> ' ||SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

  END pc_busca_mensagens;


  PROCEDURE pc_reprocessa_msg(pr_nrseq_mensagem_xml IN VARCHAR2                 --> Sequência da mensagem XML - Separado por ;
                             ,pr_cdcooper_msg       IN VARCHAR2                 --> Código da Cooperativa     - Separado por ;
                             ,pr_nrdconta           IN VARCHAR2                 --> Número da Conta           - Separado por ;
                             ,pr_xmllog             IN VARCHAR2                 --> XML com informações de LOG
                             ,pr_cdcritic          OUT PLS_INTEGER              --> Código da crítica
                             ,pr_dscritic          OUT VARCHAR2                 --> Descrição da crítica
                             ,pr_retxml         IN OUT NOCOPY xmltype           --> Arquivo de retorno do XML
                             ,pr_nmdcampo          OUT VARCHAR2                 --> Nome do Campo
                             ,pr_des_erro          OUT VARCHAR2) IS             --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_reprocessa_msg
    Sistema : Sistema Pagamentos Brasileiros - Cooperativa de Credito
    Sigla   : SPB
    Autor   : Everton Souza
    Data    : Agosto/2018                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para reprocessar mensagens SPB (SSPB0003.pc_grava_XML)

    Alteracoes:
    ............................................................................. */

    CURSOR cr_msg_xml(pr_nrseq_mensagem_xml TBSPB_MSG_XML.nrseq_mensagem_xml%TYPE) IS
      SELECT a.*
            ,b.nrseq_mensagem
        FROM tbspb_msg_xml a
            ,tbspb_msg_enviada_fase b
       WHERE a.nrseq_mensagem_xml = pr_nrseq_mensagem_xml
         AND b.nrseq_mensagem_xml = a.nrseq_mensagem_xml;

    rw_msg_xml            cr_msg_xml%ROWTYPE;
    vr_cdcritic           crapcri.cdcritic%TYPE;
    vr_dscritic           crapcri.dscritic%TYPE;
    vr_des_erro           varchar2(4000);
    vr_nrseq_mensagem_xml TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE := null;
    vr_tab_XML            gene0002.typ_split;
    vr_tab_NRDCONTA       gene0002.typ_split;
    vr_tab_CDCOOPER       gene0002.typ_split;

    --Controle de erro
    vr_exc_erro EXCEPTION;

    -- Variaveis XML
    vr_xml_temp VARCHAR2(32726) := '';
    vr_clob     CLOB;
    vr_retxml   VARCHAR2(32726);

  BEGIN
    --
    pr_des_erro := 'NOK';
    -- Monta documento XML
    dbms_lob.createtemporary(vr_clob, TRUE);
    dbms_lob.open(vr_clob, dbms_lob.lob_readwrite);

    -- Criar cabeçalho do XML
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><Root>');
    --
    vr_tab_XML      := gene0002.fn_quebra_string(pr_nrseq_mensagem_xml,';');
    vr_tab_CDCOOPER := gene0002.fn_quebra_string(pr_cdcooper_msg,';');
    vr_tab_NRDCONTA := gene0002.fn_quebra_string(replace(pr_nrdconta,'.',''),';');
    --
    FOR idx IN vr_tab_XML.first..vr_tab_XML.last LOOP
      IF vr_tab_XML(idx) IS NOT NULL THEN
        OPEN cr_msg_xml(vr_tab_XML(idx));
        FETCH cr_msg_xml INTO rw_msg_xml;

        -- Se não existe
        IF cr_msg_xml%NOTFOUND THEN
          -- Gera crítica
          vr_cdcritic := 0;
          vr_dscritic := 'XML de origem nao encontrado - XML='||vr_tab_XML(idx);
        END IF;
        -- Fecha cursor
        CLOSE cr_msg_xml;
        --
        IF trim(vr_dscritic) IS NULL  THEN
          SSPB0003.pc_grava_XML(pr_nmmensagem            => rw_msg_xml.NMMENSAGEM           --> Nome da mensagem enviada
                               ,pr_inorigem_mensagem     => rw_msg_xml.INORIGEM_MENSAGEM    --> Origem da mensagem (E=Enviada, R=Recebida)
                               ,pr_dhmensagem            => SYSDATE                         --> Data/Hora de processamento da mensagem
                               ,pr_dsxml_mensagem        => rw_msg_xml.DSXML_MENSAGEM       --> XML descriptografado da mensagem limitado a 4000
                               ,pr_dsxml_completo        => rw_msg_xml.DSXML_COMPLETO       --> XML descriptografado da mensagem completo
                               ,pr_inenvio               => rw_msg_xml.INENVIO              --> Indicador de mensagem a ser enviada para o JDSPB (0=Não Enviar, 1=Enviar)
                               ,pr_nrdconta              => vr_tab_NRDCONTA(idx)            --> Numero da conta/dv do associado
                               ,pr_cdcooper              => vr_tab_CDCOOPER(idx)            --> Codigo que identifica a Cooperativa
                               ,pr_cdproduto             => 30                              --> Codigo do produto de abertura de conta
                               ,pr_nrseq_mensagem_xml    => vr_nrseq_mensagem_xml           --> Nr.sequencial do XML da mensagem
                               ,pr_dscritic              => vr_dscritic
                               ,pr_des_erro              => vr_des_erro);
        END IF;
        --
        IF trim(vr_dscritic) IS NOT NULL or nvl(vr_des_erro,'OK') <> 'OK' THEN
          vr_retxml := '<Dados>Msg: '||rw_msg_xml.nrseq_mensagem ||' - ERRO='||vr_dscritic||' </Dados>';
        ELSE
          vr_retxml := '<Dados>Msg: '||rw_msg_xml.nrseq_mensagem ||' - Reenviada com sucesso! </Dados>';
        END IF;
      --
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => vr_retxml);
      END IF;
    END LOOP;
    --
    COMMIT;
    --
    pr_des_erro := 'OK';
    --
    GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                           ,pr_texto_completo => vr_xml_temp
                           ,pr_texto_novo     => '</Root>'
                           ,pr_fecha_xml => TRUE);
    -- Atualiza o XML de retorno
    pr_retxml := xmltype(vr_clob);

    -- Libera a memoria do CLOB
    dbms_lob.close(vr_clob);
    dbms_lob.freetemporary(vr_clob);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;

      -- Existe para satisfazer exigência da interface.
      vr_retxml := '<Erro>' || pr_cdcritic || '-' || pr_dscritic || '</Erro>';
      --
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => vr_retxml||'</Root>'
                             ,pr_fecha_xml => TRUE);

      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);
      --
      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_SPBMSG.pc_reprocessa_msg --> ' || SQLERRM;

      -- Existe para satisfazer exigência da interface.
      vr_retxml := '<Erro>' || pr_dscritic || '</Erro>';
      --
      GENE0002.pc_escreve_xml(pr_xml            => vr_clob
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => vr_retxml||'</Root>');
      -- Atualiza o XML de retorno
      pr_retxml := xmltype(vr_clob);

      -- Libera a memoria do CLOB
      dbms_lob.close(vr_clob);
      dbms_lob.freetemporary(vr_clob);

  END pc_reprocessa_msg;


END tela_spbmsg;
/
