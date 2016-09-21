CREATE OR REPLACE PACKAGE CECRED.TELA_PENSEG AS



  PROCEDURE pc_busca_seguros_pend(pr_nriniseq IN INTEGER               --> Registro inicial da listagem
                                 ,pr_nrregist IN INTEGER               --> Numero de registros p/ paginaca
                 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_busca_cooperado(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                              ,pr_nrdconta IN NUMBER                --> Numero da Conta a validar
                              ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_grava_seguros_pend(pr_cdcooper   IN INTEGER               --> Codigo da Agencia Central
                                 ,pr_nrdconta   IN INTEGER               --> Numero da Conta
                                 ,pr_idcontrato IN INTEGER               --> Nr seq. Seguro alterado
                                 ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic   OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo   OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro   OUT VARCHAR2);           --> Erros do processo

END TELA_PENSEG;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PENSEG AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: TELA_PENSEG   (Baseado TELA_GESCAR - Remover comentario)
  --    Autor   : Guilherme/SUPERO
  --    Data    : Junho/2016                   Ultima Atualizacao:
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : BO ref. a Mensageria da tela PENSEG
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

  PROCEDURE pc_busca_seguros_pend(pr_nriniseq IN INTEGER               --> Registro inicial da listagem
                                 ,pr_nrregist IN INTEGER               --> Numero de registros p/ paginaca
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_seguros_pend
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar dados de Seguros Pendentes SICREDI

    Alteracoes:
    ............................................................................. */

    --- CURSORES ---
    CURSOR cr_seg_pend IS
      SELECT * --> Select para filtrar a paginação
        FROM (
              SELECT seg.rowid dsrowid
                    ,seg.idcontrato
                    ,seg.nrproposta
                    ,seg.nrapolice
                    ,seg.nrendosso
                    ,seg.dtinicio_vigencia
                    ,seg.dttermino_vigencia
                    ,TRIM(UPPER(gene0007.fn_caract_acento(csg.nmsegura))) nmsegura
                    ,seg.cdcooper
                    ,seg.nrdconta
                    ,seg.nrcpf_cnpj_segurado
                    ,seg.nmsegurado
                    ,seg.dtmvtolt
                    ,DECODE(seg.indsituacao,'A','ATIVA','V','VENCIDA','R','RENOVADA','CANCELADA') indsituacao
                    ,TRIM(UPPER(gene0007.fn_caract_acento(auto.nmmarca))) nmmarca
                    ,TRIM(UPPER(gene0007.fn_caract_acento(auto.dsmodelo))) dsmodelo
                    ,auto.dschassi
                    ,auto.dsplaca
                    ,auto.nrano_fabrica
                    ,auto.nrano_modelo
                    ,COUNT(1)  OVER (PARTITION BY 1)  qtregist
                    ,rownum      nrrownum
                FROM tbseg_contratos seg
                    ,tbseg_auto_veiculos auto
                    ,crapcsg csg
               WHERE seg.idcontrato    = auto.idcontrato
                 AND seg.tpseguro      = 'A' -- Seguro AUTO
                 AND seg.inerro_import = 1   -- Registros com erros de Conta ou Agencia(cooper)
                 AND csg.cdcooper      = 1   -- Esses registros da SEG nao tem cooperativa, fixo baseado na 1
                 AND csg.cdsegura      = seg.cdsegura
               ORDER BY seg.nrcpf_cnpj_segurado) tmp
       WHERE nrrownum BETWEEN pr_nriniseq AND (pr_nriniseq + (pr_nrregist - 1))
       ORDER BY tmp.idcontrato
       ;
             --seg.dtmvtolt, seg.nrproposta,seg.nrapolice,seg.nrendosso;

    CURSOR cr_crapcop (p_cdagectl IN crapcop.cdagectl%type) IS
      SELECT 1
        FROM crapcop cop
       WHERE p_cdagectl <> 0
         AND (cop.cdcooper = p_cdagectl
           OR cop.cdagectl = p_cdagectl)
          ;
    rw_crapcop cr_crapcop%ROWTYPE;


    --- VARIAVEIS ---
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    vr_qtregist  NUMBER;

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
    vr_exc_erro   EXCEPTION;

    vr_index      PLS_INTEGER;

    -- Variavel Tabela Temporaria
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML
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

    FOR rw_seg_pend IN cr_seg_pend LOOP
      -- Captura ultimo indice da PL Table
      vr_index    := nvl(vr_tab_dados.count, 0) + 1;
      vr_qtregist := rw_seg_pend.qtregist;

      -- Gravando registros
      vr_tab_dados(vr_index)('idcontrato')          := rw_seg_pend.idcontrato;
      vr_tab_dados(vr_index)('nrproposta')          := gene0002.fn_mask(rw_seg_pend.nrproposta,'zzz.zzz.zz9');
      vr_tab_dados(vr_index)('nrapolice')           := gene0002.fn_mask(rw_seg_pend.nrapolice,'zzz.zzz.zz9');
      vr_tab_dados(vr_index)('nrendosso')           := gene0002.fn_mask(rw_seg_pend.nrendosso,'zzz.zzz.zz9');
      vr_tab_dados(vr_index)('dtinicio_vigencia')   := to_char(rw_seg_pend.dtinicio_vigencia,'dd/mm/RRRR');
      vr_tab_dados(vr_index)('dttermino_vigencia')  := to_char(rw_seg_pend.dttermino_vigencia,'dd/mm/RRRR');
      vr_tab_dados(vr_index)('nmsegura')            := rw_seg_pend.nmsegura;
      vr_tab_dados(vr_index)('cdcooper')            := rw_seg_pend.cdcooper;
      vr_tab_dados(vr_index)('nrdconta')            := rw_seg_pend.nrdconta;
      vr_tab_dados(vr_index)('nrcpf_cnpj_segurado') := rw_seg_pend.nrcpf_cnpj_segurado;
      vr_tab_dados(vr_index)('nmsegurado')          := rw_seg_pend.nmsegurado;
      vr_tab_dados(vr_index)('dtmvtolt')            := to_char(rw_seg_pend.dtmvtolt,'dd/mm/RRRR');
      vr_tab_dados(vr_index)('indsituacao')         := rw_seg_pend.indsituacao;

      vr_tab_dados(vr_index)('nmmarca')             := rw_seg_pend.nmmarca;
      vr_tab_dados(vr_index)('dsmodelo')            := rw_seg_pend.dsmodelo;
      vr_tab_dados(vr_index)('dschassi')            := rw_seg_pend.dschassi;
      vr_tab_dados(vr_index)('dsplaca')             := rw_seg_pend.dsplaca;
      vr_tab_dados(vr_index)('nrano_fabrica')       := rw_seg_pend.nrano_fabrica;
      vr_tab_dados(vr_index)('nrano_modelo')        := rw_seg_pend.nrano_modelo;

      -- Verificar se a Cooper ou CdAgeCtl é valido
      OPEN  cr_crapcop(rw_seg_pend.cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrar dados
      IF cr_crapcop%NOTFOUND THEN
        vr_tab_dados(vr_index)('imgSitCoop')        := 'sit_er.png';
        -- Fecha cursor
        CLOSE cr_crapcop;
      ELSE
        vr_tab_dados(vr_index)('imgSitCoop')        := 'sit_ok.png';
        CLOSE cr_crapcop;
      END IF;

    END LOOP;

    -- Geracao de TAG's
    gene0007.pc_gera_tag('idcontrato',vr_tab_tags);
    gene0007.pc_gera_tag('nrproposta',vr_tab_tags);
    gene0007.pc_gera_tag('nrapolice',vr_tab_tags);
    gene0007.pc_gera_tag('nrendosso',vr_tab_tags);
    gene0007.pc_gera_tag('dtinicio_vigencia',vr_tab_tags);
    gene0007.pc_gera_tag('dttermino_vigencia',vr_tab_tags);
    gene0007.pc_gera_tag('nmsegura',vr_tab_tags);
    gene0007.pc_gera_tag('cdcooper',vr_tab_tags);
    gene0007.pc_gera_tag('nrdconta',vr_tab_tags);
    gene0007.pc_gera_tag('nrcpf_cnpj_segurado',vr_tab_tags);
    gene0007.pc_gera_tag('nmsegurado',vr_tab_tags);
    gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
    gene0007.pc_gera_tag('indsituacao',vr_tab_tags);
    gene0007.pc_gera_tag('nmmarca',vr_tab_tags);
    gene0007.pc_gera_tag('dsmodelo',vr_tab_tags);
    gene0007.pc_gera_tag('dschassi',vr_tab_tags);
    gene0007.pc_gera_tag('dsplaca',vr_tab_tags);
    gene0007.pc_gera_tag('nrano_fabrica',vr_tab_tags);
    gene0007.pc_gera_tag('nrano_modelo',vr_tab_tags);
    gene0007.pc_gera_tag('imgSitCoop',vr_tab_tags);

    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root QTREGIST="'||NVL(vr_qtregist,0)||'" />');

    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'retorno'
                        ,pr_des_erro  => pr_des_erro);

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
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_erro := 'NOK';

      -- Erro
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na TELA_PENSEG.pc_busca_seguros_pend --> ' ||
                     SQLERRM;

      -- Existe para satisfazer exigência da interface.
      pr_retxml := xmltype.createxml('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_cdcritic || '-' ||
                                     pr_dscritic || '</Erro></Root>');

  END pc_busca_seguros_pend;

  PROCEDURE pc_busca_cooperado(pr_cdcooper IN NUMBER                --> Código da cooperativa para buscar os dados
                              ,pr_nrdconta IN NUMBER                --> Numero da Conta a validar
                              ,pr_xmllog   IN VARCHAR2              --> XML com informacoes de LOG
                              ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                              ,pr_dscritic OUT VARCHAR2             --> Descricao da critica
                              ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                              ,pr_des_erro OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_busca_cooperado
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para buscar validar Conta com a cooperativa informada

    Alteracoes:
    ............................................................................. */

    -- Buscar dados do associado
    CURSOR cr_crapass(pr_cdcooper  IN crapass.cdcooper%TYPE
                     ,pr_nrdconta  IN crapass.nrdconta%TYPE) IS
      SELECT t.nmprimtl
        FROM crapass    t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta;
    rw_crapass     cr_crapass%ROWTYPE;


    vr_cdcritic    crapcri.cdcritic%TYPE;
    vr_dscritic    crapcri.dscritic%TYPE;
    vr_nmprimtl    VARCHAR2(200);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_nrdconta crapass.nrdconta%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variavel Tabela Temporaria
    vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
    vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG's do XML

    --Controle de erro
    vr_exc_erro EXCEPTION;

    -- Retornar o valor do nodo tratando casos nulos
    FUNCTION fn_extract(pr_nodo  VARCHAR2) RETURN VARCHAR2 IS

    BEGIN
      -- Extrai e retorna o valor... retornando null em caso de erro ao ler
      RETURN TRIM(pr_retxml.extract(pr_nodo).getstringval());
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;


  BEGIN

    pr_des_erro := 'OK';


    -- Extrair as informações do XML
    vr_cdcooper := fn_extract('/Root/Dados/telcooper/text()');
    vr_nrdconta := fn_extract('/Root/Dados/nrdconta/text()');


    -- Criar cabecalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');


    IF NVL(pr_cdcooper,0) = 0 THEN
      -- Retornar a mensagem de erro nos parametros
      pr_cdcritic := 0;
      pr_dscritic := 'Favor informar Cooperativa!';
      pr_nmdcampo := 'newCdcooper';
      RAISE vr_exc_erro;
    ELSE -- Informou Coop
      -- Se tem número de conta
      IF NVL(pr_nrdconta,0) > 0 THEN

        -- Buscar pelo associado
        OPEN  cr_crapass(pr_cdcooper, pr_nrdconta);
        FETCH cr_crapass INTO rw_crapass;

        -- Se não encontrar o registro
        IF cr_crapass%NOTFOUND THEN
          -- Fechar o cursor antes de encerrar a execução
          CLOSE cr_crapass;

          -- Retornar a mensagem de erro nos parametros
          pr_cdcritic := 9;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

          RAISE vr_exc_erro;
        END IF;

        -- Fechar o cursor
        CLOSE cr_crapass;

        -- Guarda o nome
        vr_nmprimtl := rw_crapass.nmprimtl;
      ELSE
          -- Retornar a mensagem de erro nos parametros
          pr_cdcritic := 0;
          pr_dscritic := 'Favor informar Conta/DV!';
          pr_nmdcampo := 'newNrdconta';
          RAISE vr_exc_erro;
      END IF;
    END IF;


    vr_tab_dados(1)('nmprimtl')        := vr_nmprimtl;
    gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);


    -- Forma XML de retorno para casos de sucesso (listar dados)
    gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                        ,pr_tab_tag   => vr_tab_tags
                        ,pr_XMLType   => pr_retxml
                        ,pr_path_tag  => '/Root'
                        ,pr_tag_no    => 'retorno'
                        ,pr_des_erro  => pr_des_erro);





    -- Finaliza com status de sucesso
    pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := pr_des_erro;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

    WHEN OTHERS THEN
      pr_des_erro := 'Erro geral: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

  END pc_busca_cooperado;


  PROCEDURE pc_grava_seguros_pend(pr_cdcooper   IN INTEGER               --> Código da Agencia Central
                                 ,pr_nrdconta   IN INTEGER               --> Numero da Conta
                                 ,pr_idcontrato IN INTEGER               --> Nr seq. Seguro alterado
                                 ,pr_xmllog     IN VARCHAR2              --> XML com informacoes de LOG
                                 ,pr_cdcritic   OUT PLS_INTEGER          --> Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2             --> Descricao da critica
                                 ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo   OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro   OUT VARCHAR2) IS         --> Saida OK/NOK
    /* .............................................................................
    Programa: pc_grava_seguros_pend
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Guilherme/SUPERO
    Data    : Junho/2016                       Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para gravar dados Seguros Sicredi que foram ajustados

    Alteracoes:
    ............................................................................. */

    CURSOR cr_crapcop (p_cdcooper IN crapcop.cdagectl%type) IS
      SELECT 1
        FROM crapcop cop
       WHERE cop.cdcooper = p_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    CURSOR cr_crapass (p_cdcooper IN crapcop.cdagectl%TYPE
                      ,p_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT 1
        FROM crapass ass
       WHERE ass.cdcooper = p_cdcooper
         AND ass.nrdconta = p_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- VERIFICAR SE REGISTRO DO PARAMETRO EXISTE NA BASE
    CURSOR cr_seg_tela (p_idcontrato  IN tbseg_contratos.idcontrato%TYPE) IS
      SELECT seg.idcontrato
            ,seg.cdparceiro
            ,seg.tpseguro
            ,seg.nrproposta
            ,seg.nrapolice
            ,seg.cdcooper
            ,seg.nrdconta
            ,seg.nrcpf_cnpj_segurado
            ,seg.nmsegurado
            ,seg.nrendosso
            ,seg.tpendosso
            ,seg.tpsub_endosso
            ,seg.nrapolice_renovacao
            ,seg.dtinicio_vigencia
            ,seg.dttermino_vigencia
            ,seg.cdsegura
            ,seg.indsituacao
            ,seg.dtcancela
            ,seg.vlpremio_liquido
            ,seg.vlpremio_total
            ,seg.nrdiadebito
            ,seg.qtparcelas
            ,seg.vlparcela
            ,seg.percomissao
            ,seg.dsobservacao
            ,seg.vlcapital
            ,seg.inerro_import
            ,seg.dsplano
            ,seg.dtmvtolt
            ,seg.flgvigente
        FROM tbseg_contratos seg
       WHERE seg.idcontrato  = p_idcontrato;

    -- VERIFICAR SE PROPOSTA/APOLICE/ENDOSSO EXISTE NA BASE
    CURSOR cr_seg_base (p_cdcooper IN tbseg_contratos.cdcooper%TYPE
                       ,p_nrdconta IN tbseg_contratos.nrdconta%TYPE
                       ,p_nrapolic IN tbseg_contratos.nrapolice%TYPE ) IS
      SELECT seg.rowid
            ,seg.idcontrato
            ,seg.nrapolice
            ,seg.tpendosso
            ,seg.nrendosso
            ,seg.indsituacao
            ,COUNT(cdcooper) OVER (PARTITION BY cdcooper) qtd_reg
        FROM tbseg_contratos seg
       WHERE seg.cdcooper      = p_cdcooper
         AND seg.nrdconta      = p_nrdconta
         AND seg.nrapolice     = p_nrapolic
         --AND seg.nrendosso  = p_nrendoss
         AND seg.tpseguro      = 'A'
         AND seg.flgvigente    = 1 -- Buscar contrato Ativo
         AND seg.inerro_import = 0 -- Seguro Sem erro
     -- (Existe a mesma Coop/Conta/Apolice Vigente e Sem Erro?)
       ORDER BY seg.idcontrato DESC
        ;
    rw_seg_base cr_seg_base%ROWTYPE;

    -- Cursor para buscar os veiculos do contrato do PARAMETRO (contrato com erro)
    CURSOR cr_auto_param (p_idcontrato IN tbseg_contratos.idcontrato%TYPE) IS
      SELECT auto.idcontrato
            ,auto.idveiculo
            ,auto.nmmarca
            ,auto.dsmodelo
            ,auto.nrano_fabrica
            ,auto.nrano_modelo
            ,auto.dsplaca
            ,auto.dschassi
            ,auto.cdfipe
            ,auto.vlfranquia
        FROM tbseg_auto_veiculos auto
       WHERE auto.idcontrato = p_idcontrato;
    rw_auto_param cr_auto_param%ROWTYPE;

    -- Cursor para buscar os veiculos do contrato da base
    CURSOR cr_auto_base (p_idcontrato IN tbseg_contratos.idcontrato%TYPE) IS
      SELECT auto.idcontrato
            ,auto.idveiculo
            ,auto.nmmarca
            ,auto.dsmodelo
            ,auto.nrano_fabrica
            ,auto.nrano_modelo
            ,auto.dsplaca
            ,auto.dschassi
            ,auto.cdfipe
            ,auto.vlfranquia
            ,MAX(idveiculo) OVER (PARTITION BY idcontrato) max_id
        FROM tbseg_auto_veiculos auto
       WHERE auto.idcontrato = p_idcontrato;
    rw_auto_base cr_auto_base%ROWTYPE;


    vr_cdcritic       crapcri.cdcritic%TYPE;
    vr_dscritic       crapcri.dscritic%TYPE;

    -- Variaveis de log
    vr_cdcooper       crapcop.cdcooper%TYPE;
    vr_cdoperad       VARCHAR2(100);
    vr_nmdatela       VARCHAR2(100);
    vr_nmeacao        VARCHAR2(100);
    vr_cdagenci       VARCHAR2(100);
    vr_nrdcaixa       VARCHAR2(100);
    vr_idorigem       VARCHAR2(100);

    vr_found_cop      BOOLEAN:=FALSE;
    vr_found_ass      BOOLEAN:=FALSE;
    vr_flg_base       BOOLEAN:=FALSE;

    vr_cont_auto      INTEGER:=0;
    vr_max_auto       INTEGER;
    vr_idx_auto_base  INTEGER;
    vr_flgsegok       BOOLEAN; -- RETORNO DA pc_insere_seguro se TRUE ou FALSE
    vr_tab_erro       gene0001.typ_tab_erro;
    vr_indierro       NUMBER;
    vr_tpdseguro      PLS_INTEGER := 0;

    vr_reg_tpatu      SEGU0001.typ_reg_flg_atu;

    rw_tab_seg_tela   SEGU0001.tp_tab_seguros;
    rw_tab_auto_tela  SEGU0001.tp_tab_auto;

    rw_tab_vida       SEGU0001.tp_tab_vida;
    rw_tab_casa       SEGU0001.tp_tab_casa;
    rw_tab_prst       SEGU0001.tp_tab_prst;

    --Controle de erro
    vr_exc_erro       EXCEPTION;

  BEGIN

    pr_des_erro := NULL;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
     FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

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
 /*   IF vr_dscritic IS NOT NULL THEN
      pr_cdcritic := 9999;
      pr_des_erro := 'Erro ao atualizar o registro na SEGURO(pc_extrai_dados)';
      pr_nmdcampo := 'cnewCdcooper';
      RAISE vr_exc_erro;
    END IF;
*/

    -- Validar Cooperativa parâmetro
    OPEN cr_crapcop (p_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    vr_found_cop := cr_crapcop%FOUND;
    CLOSE cr_crapcop;
    -- Validar Conta parâmetro
    OPEN cr_crapass (p_cdcooper => pr_cdcooper
                    ,p_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    vr_found_ass := cr_crapass%FOUND;
    CLOSE cr_crapass;

    -- Validar seguro PARAMETRO (pr_idcontrato)
    IF cr_seg_tela%ISOPEN THEN
      CLOSE cr_seg_tela;
    END IF;
    OPEN cr_seg_tela (p_idcontrato => pr_idcontrato);
    FETCH cr_seg_tela INTO rw_tab_seg_tela(1);
    IF cr_seg_tela%NOTFOUND THEN
      CLOSE cr_seg_tela;
      pr_cdcritic := 9999;
      pr_des_erro := 'Seguro selecionado invalido!';
      pr_nmdcampo := 'cnewCdcooper';
      RAISE vr_exc_erro;

    ELSE -- Encontrou o Seguro do PARAMETRO (pr_idcontrato)

      -- Validar Cooperativa parâmetro
      IF NOT vr_found_cop THEN
        pr_cdcritic := 9999;
        pr_des_erro := 'Cooperativa invalida! (' || pr_cdcooper ||')';
        pr_nmdcampo := 'cnewCdcooper';
        RAISE vr_exc_erro;
      ELSE -- Encontrou COOPERATIVA
        -- Validar Conta PARAMETRO
        IF NOT vr_found_ass THEN
          pr_cdcritic := 9999;
          pr_des_erro := 'Associado nao encontrado na Cooperativa informada! (' || pr_cdcooper ||'/'||pr_nrdconta ||')';
          pr_nmdcampo := 'cnewNrdconta';
          RAISE vr_exc_erro;

        ELSE -- Encontrou ASSOCIADO - Encontrou COOPER - Encontrou SEGURO

          -- Tipo atualização dos Dados (I-Inclusão / A-Alteração / M-Manter)
          vr_reg_tpatu.tp_seguro         := 'M';
          vr_reg_tpatu.tp_auto           := 'M';
          vr_reg_tpatu.tp_vida           := 'A';
          vr_reg_tpatu.tp_casa           := 'A';
          vr_reg_tpatu.tp_prst           := 'A';

          rw_tab_seg_tela(1).dtmvtolt      := rw_crapdat.dtmvtolt; -- Data de Atualização


          IF  rw_tab_seg_tela(1).nrproposta <> 0
          AND rw_tab_seg_tela(1).nrapolice   = 0
          AND rw_tab_seg_tela(1).nrendosso   = 0 THEN
            -- É PROPOSTA
            vr_tpdseguro := 1;
          ELSIF rw_tab_seg_tela(1).nrproposta <> 0
            AND rw_tab_seg_tela(1).nrapolice  <> 0
            AND rw_tab_seg_tela(1).nrendosso   = 0 THEN
            -- É APOLICE
            vr_tpdseguro := 2;
          ELSIF rw_tab_seg_tela(1).nrapolice  <> 0
            AND rw_tab_seg_tela(1).nrproposta <> 0
            AND rw_tab_seg_tela(1).nrendosso  <> 0 THEN
            -- É ENDOSSO
            vr_tpdseguro := 3;
          END IF;


          IF  pr_nrdconta = 7325800 THEN
            NULL;
          END IF;

          IF cr_seg_base%ISOPEN THEN
            CLOSE cr_seg_base;
          END IF;
          -- Verificar se a Coop/Conta PARAMETRO já possui o seguro do PARAMETRO
          OPEN cr_seg_base (p_cdcooper => pr_cdcooper
                           ,p_nrdconta => pr_nrdconta
                           ,p_nrapolic => rw_tab_seg_tela(1).nrapolice);
          FETCH cr_seg_base INTO rw_seg_base;
          --Se nao Encontrou
          IF cr_seg_base%NOTFOUND THEN
            CLOSE cr_seg_base;

            rw_tab_seg_tela(1).cdcooper      := pr_cdcooper;         -- Atualiza com dados do Parametro
            rw_tab_seg_tela(1).nrdconta      := pr_nrdconta;         -- Atualiza com dados do Parametro
            rw_tab_seg_tela(1).dsobservacao  := '[PENSEG] Atualizado em ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||
                                                 ' as ' || to_char(SYSDATE,'hh24:mi:ss');

            -- Se não encontrou, vai apenas
            -- atualizar CDCOOPER e NRDCONTA do registro do PARAMETRO
            -- Nao faz nada com dados da AUTO (mantem)
            vr_reg_tpatu.tp_seguro := 'A'; -- ATUALIZA DADOS SEGURO
            vr_reg_tpatu.tp_auto   := 'M'; -- MANTEM DADOS VEICULO

            rw_tab_seg_tela(1).flgvigente  := 1;
            rw_tab_seg_tela(1).inerro_import := 0;                   -- Limpa Registro de ERRO
            -- Se é um Endosso e nao existir na base ainda, já cria como CANCELADO
            IF  rw_tab_seg_tela(1).nrendosso <> 0
            AND rw_tab_seg_tela(1).tpendosso IN (4,5) THEN
              rw_tab_seg_tela(1).indsituacao := 'C'; -- Altera a situado Seguro para CANCELADO
              rw_tab_seg_tela(1).dtcancela   := rw_crapdat.dtmvtolt;
            END IF;

          ELSE -- Coop e Conta informada já tem essa Proposta/Apolice

            CLOSE cr_seg_base;
            --vr_reg_tpatu.tp_seguro   := 'Y';  -- Inserir dados do seguro, inativando o registro anterior

            rw_tab_auto_tela.DELETE;     -- Limpa os registros de Veiculos
            rw_tab_seg_tela(1).inerro_import := 0;                   -- Limpa Registro de ERRO
            
            -- POSICIONA NO VEICULO DO SEGURO DO PARAMETRO
            OPEN cr_auto_param(p_idcontrato => pr_idcontrato) ;
            FETCH cr_auto_param INTO rw_tab_auto_tela(1);
            --Se nao Encontrou
            IF cr_auto_param%NOTFOUND THEN
              CLOSE cr_auto_param;
              pr_cdcritic := 9999;
              pr_des_erro := 'Seguro selecionado sem veiculo! (' || pr_idcontrato ||')';
              pr_nmdcampo := 'cnewCdcooper';
              RAISE vr_exc_erro;

            ELSE -- ENCONTROU VEICULO PARAMETRO

              -- POSICIONA NO VEICULO DO CONTRATO BASE
              OPEN cr_auto_base(p_idcontrato => rw_seg_base.idcontrato);
              FETCH cr_auto_base INTO rw_auto_base;
              --Se nao Encontrou
              IF cr_auto_base%NOTFOUND THEN
                CLOSE cr_auto_base;
                pr_cdcritic := 9999;
                pr_des_erro := 'Seguro base sem veiculo! (' || rw_seg_base.idcontrato ||')';
                pr_nmdcampo := 'cnewCdcooper';
                RAISE vr_exc_erro;

              ELSE -- ENCONTROU VEICULO DO SEGURO DA BASE

                -- PARA EVITAR ERROS DE SEQUENCIA
                -- CASO O CONTRATO A SER ATUALIZADO FOR DE SEQUENCIA
                -- MENOR QUE O CONTRATO DA BASE, SIGNIFICA QUE O
                -- OPERADOR SE EQUIVOCOU NA HORA DE EDITAR OS REGISTROS
                -- DE SEGUROS PENDENTES, OU VEIO NA SEQUENCIA UM REGISTRO
                -- NOVO COM DADOS CORRETOS APOS UM COM ERRO.
                -- EX.: CONTRATO 1 - COM ERRO
                     -- CONTRATO 2 - SEM ERRO
                IF pr_idcontrato < rw_seg_base.idcontrato THEN
                  rw_tab_seg_tela(1).inerro_import := 9; -- Segregar registros que tiveram problemas
                  rw_tab_seg_tela(1).dsobservacao  := '[PENSEG] Nao Atualizado - Nr Contrato selecionado inferior ' ||
                                                       'ao Nr Contrato base! ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||
                                                       ' as ' || to_char(SYSDATE,'hh24:mi:ss');
                  vr_reg_tpatu.tp_auto   := 'M'; -- MANTEM DADOS VEICULO

                ELSE -- IDCONTRATO sequencia certa.

                  IF  vr_tpdseguro = 2  THEN -- Apolice
                    IF rw_tab_seg_tela(1).nrapolice = rw_seg_base.nrapolice THEN
                      -- Apolice da Tela = Apolice da Base. Não pode importar
                      rw_tab_seg_tela(1).inerro_import := 9; -- Segregar registros que tiveram problemas
                      pr_cdcritic := 9999;
                      pr_des_erro := 'ERRO! Este seguro já está base! [Coop: ' || rw_tab_seg_tela(1).cdcooper
                                                         ||   ' Conta: ' || rw_tab_seg_tela(1).nrdconta
                                                         || ' Apólice: ' || rw_tab_seg_tela(1).nrapolice
                                                         || ']';
                      pr_nmdcampo := 'cnewCdcooper';
                      RAISE vr_exc_erro;
                    END IF;

                  ELSIF vr_tpdseguro = 3 THEN -- Endosso
                    --rw_tab_seg_tela(1).tpendosso IN (4,5) THEN -- Seguro da Tela

                    IF  rw_seg_base.indsituacao = 'E' THEN
                      -- Se a Base está como "E" ja foi processado na importação do arquivo
                      -- Mantem dados e atualiza CDCOOPER e NRDCONTA
                      vr_reg_tpatu.tp_auto   := 'M'; -- MANTEM DADOS VEICULO
                      vr_reg_tpatu.tp_seguro := 'A'; -- ATUALIZA DADOS SEGURO (COOP/CONTA)

                    ELSE  -- Outra situação

                      vr_reg_tpatu.tp_seguro := 'Y';
                      -- Se o endosso ativo da Base já for de Cancelamento
                      IF  rw_seg_base.nrendosso   <> 0
                      AND rw_seg_base.tpendosso   IN (4,5) THEN
                        rw_tab_seg_tela(1).inerro_import := 9; -- Segregar registros que tiveram problemas
                        pr_cdcritic := 9999;
                        pr_des_erro := 'ERRO! Apólice ' || rw_seg_base.nrapolice || ' já recebeu Endosso de Cancelamento. ';
                        pr_nmdcampo := 'cnewCdcooper';
                        RAISE vr_exc_erro;
                      END IF;                      

                      rw_tab_auto_tela(1).idcontrato    := rw_seg_base.idcontrato;
                      rw_tab_auto_tela(1).idveiculo     := rw_auto_base.idveiculo;

                    END IF; -- FIM ELSE rw_seg_base.indsituacao = 'E'

                  END IF; -- FIM vr_tpdseguro = 3

                  rw_tab_seg_tela(1).cdcooper      := pr_cdcooper;         -- Atualiza com dados do Parametro
                  rw_tab_seg_tela(1).nrdconta      := pr_nrdconta;         -- Atualiza com dados do Parametro
                  rw_tab_seg_tela(1).dsobservacao  := '[PENSEG] Atualizado em ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR') ||
                                                       ' as ' || to_char(SYSDATE,'hh24:mi:ss');
                END IF;

              END IF; -- FIM DO cr_auto_base%NOTFOUND

            END IF;

          END IF; -- FIM IF/ELSE NOTFOUND
          IF cr_seg_base%ISOPEN THEN
            CLOSE cr_seg_base;
          END IF;

          -- AJUSTA SITUAÇÃO DO SEGURO
          IF  rw_tab_seg_tela(1).indsituacao = 'A'  -- ATIVA
          AND rw_tab_seg_tela(1).dttermino_vigencia <= rw_crapdat.dtmvtolt THEN
            rw_tab_seg_tela(1).indsituacao := 'V'; -- VENCIDO
          END IF;


          --- BLOCO DE ATUALIZAÇÃO DO SEGURO
          SEGU0001.pc_insere_seguro(pr_seguros  => rw_tab_seg_tela
                                   ,pr_auto     => rw_tab_auto_tela
                                   ,pr_vida     => rw_tab_vida
                                   ,pr_casa     => rw_tab_casa
                                   ,pr_prst     => rw_tab_prst
                                   ,pr_tipatu   => vr_reg_tpatu
                                   ,pr_flgsegur => vr_flgsegok
                                   ,pr_indierro => vr_indierro
                                   ,pr_des_erro => pr_dscritic
                                   ,pr_tab_erro => vr_tab_erro);
          IF NOT vr_flgsegok OR pr_dscritic IS NOT NULL THEN
            -- OCORREU ERRO NA ATUALIZAÇÃO DO SEGURO
            -- FAZ ROLLBACK
            pr_cdcritic := 9999;
            pr_des_erro := pr_dscritic;
            pr_nmdcampo := 'cnewCdcooper';
            RAISE vr_exc_erro;
          END IF;

/*          IF vr_reg_tpatu.tp_auto = 'A' THEN
             -- SE FOR "M", não exclui registro do PARAMETRO
             -- Quando "A", o Contrato PARAMETRO deve ser excluido
             BEGIN
               DELETE tbseg_auto_veiculos auto
                 WHERE auto.idcontrato = pr_idcontrato;

               DELETE tbseg_contratos seg
                WHERE seg.idcontrato = pr_idcontrato;
             EXCEPTION
               WHEN OTHERS THEN
                 pr_des_erro := 'Erro na atualizacao do Seguro! ' || SQLERRM;
                 pr_cdcritic := 9999;
                 pr_nmdcampo := 'cnewCdcooper';
                 RAISE vr_exc_erro;
             END;
          END IF;
*/        END IF;   -- FIM IF NOT vr_found_ass THEN
      END IF;     -- FIM IF NOT vr_found_cop THEN
    END IF;       -- FIM IF cr_seg_tela%NOTFOUND THEN
    IF cr_seg_tela%ISOPEN THEN
      CLOSE cr_seg_tela;
    END IF;

    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      ROLLBACK;
      pr_dscritic := gene0007.fn_convert_db_web(pr_des_erro);
      --pr_nmdcampo := 'cnewCdcooper';

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                    '<Root><Dados>Rotina com erros</Dados></Root>');


    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 9999;
      pr_nmdcampo := 'cnewCdcooper';
      pr_des_erro := 'Erro geral na rotina pc_grava_seguros_pend: '||SQLERRM;
      pr_dscritic := gene0007.fn_convert_db_web(pr_des_erro);

      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

  END pc_grava_seguros_pend;

END TELA_PENSEG;
/
