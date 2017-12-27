CREATE OR REPLACE PACKAGE CECRED.TELA_CADRIS IS

  PROCEDURE pc_busca_risco(pr_cdnivel_risco  IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                          ,pr_xmllog         IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro      OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_exclui_risco(pr_nrdconta      IN VARCHAR2 --> Conta
                           ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro      OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_inclui_risco(pr_nrdconta        IN tbrisco_cadastro_conta.nrdconta%TYPE --> Conta
                           ,pr_cdnivel_risco   IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_dsjustificativa IN tbrisco_cadastro_conta.dsjustificativa%TYPE --> Justificativa
                           ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro       OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_importa_risco(pr_nmdarqui        IN VARCHAR2 --> Conta
                            ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2); --> Erros do processo

END TELA_CADRIS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADRIS IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADRIS
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Maio - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADRIS
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------

	-- Tipos de Risco
  TYPE typ_tab_risco IS VARRAY(9) OF VARCHAR2(1);
  vr_tab_risco typ_tab_risco := typ_tab_risco('','A','B','C','D','E','F','G','H');

  PROCEDURE pc_busca_risco(pr_cdnivel_risco  IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                          ,pr_xmllog         IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro      OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_risco
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os cadastros de risco.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar a listagem de riscos
      CURSOR cr_risco(pr_cdcooper      IN crapcop.cdcooper%TYPE
                     ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE) IS
        SELECT tcc.nrdconta
              ,tcc.dsjustificativa
              ,ass.nmprimtl
          FROM tbrisco_cadastro_conta tcc,
               crapass ass
         WHERE tcc.cdcooper      = pr_cdcooper
           AND tcc.cdnivel_risco = pr_cdnivel_risco
           AND tcc.cdcooper      = ass.cdcooper
           AND tcc.nrdconta      = ass.nrdconta;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

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
      
      -- Variaveis Gerais
      vr_contador INTEGER := 0;

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

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Listagem de riscos
      FOR rw_risco IN cr_risco(pr_cdcooper      => vr_cdcooper
                              ,pr_cdnivel_risco => pr_cdnivel_risco) LOOP

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'risco'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nrdconta'
                              ,pr_tag_cont => GENE0002.fn_mask_conta(rw_risco.nrdconta)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'nmprimtl'
                              ,pr_tag_cont => rw_risco.nmprimtl
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'risco'
                              ,pr_posicao  => vr_contador
                              ,pr_tag_nova => 'dsjustificativa'
                              ,pr_tag_cont => rw_risco.dsjustificativa
                              ,pr_des_erro => vr_dscritic);

        vr_contador := vr_contador + 1;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADRIS: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_busca_risco;

  PROCEDURE pc_exclui_risco(pr_nrdconta      IN VARCHAR2 --> Conta
                           ,pr_cdnivel_risco IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_xmllog        IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic      OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic      OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml     IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo      OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro      OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_exclui_risco             Antigo: 
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para excluir o risco.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_dsmsglog  VARCHAR2(4000) := '';
      vr_ds_enter  VARCHAR2(10) := '';
      vr_indice    VARCHAR2(7);
      vr_tab_split GENE0002.typ_split;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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

	    vr_tab_split := GENE0002.fn_quebra_string(pr_nrdconta,'|');

      vr_indice := vr_tab_split.FIRST;
      WHILE vr_indice IS NOT NULL LOOP

        BEGIN
          DELETE tbrisco_cadastro_conta
           WHERE cdcooper      = vr_cdcooper
             AND nrdconta      = vr_tab_split(vr_indice)
             AND cdnivel_risco = pr_cdnivel_risco;
        EXCEPTION
          WHEN OTHERS THEN
          vr_dscritic := 'Problema ao excluir risco: ' || SQLERRM;
          RAISE vr_exc_saida;
        END;
        
        vr_dsmsglog := vr_dsmsglog || vr_ds_enter || TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                       ' -->  Operador '|| vr_cdoperad || ' - ' ||
                       'Excluiu a conta: ' || vr_tab_split(vr_indice) || 
                       ' - Nivel de Risco: ' || vr_tab_risco(pr_cdnivel_risco);
        vr_ds_enter := chr(10);

        vr_indice := vr_tab_split.NEXT(vr_indice);
      END LOOP;

      -- Gera log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadris.log'
                                ,pr_des_log      => vr_dsmsglog);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_exclui_risco;

  PROCEDURE pc_inclui_risco(pr_nrdconta        IN tbrisco_cadastro_conta.nrdconta%TYPE --> Conta
                           ,pr_cdnivel_risco   IN tbrisco_cadastro_conta.cdnivel_risco%TYPE --> Nivel de risco
                           ,pr_dsjustificativa IN tbrisco_cadastro_conta.dsjustificativa%TYPE --> Justificativa
                           ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro       OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_inclui_risco             Antigo: 
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Maio/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir o risco.

    Alteracoes: 02/08/2016 - Inclusao da data e operador que efetuou o cadastro.
                             (Jaison - SD: 491821)
    ..............................................................................*/
    DECLARE

      -- Valida conta
      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT COUNT(1)
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;

      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_qtassoci NUMBER;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

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

      -- Valida conta
      OPEN  cr_crapass(pr_cdcooper => vr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO vr_qtassoci;
      CLOSE cr_crapass;

      -- Caso nao encontre gera critica
      IF vr_qtassoci = 0 THEN
        vr_cdcritic := 564;
        RAISE vr_exc_saida;
      END IF;

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

	    BEGIN
        INSERT INTO tbrisco_cadastro_conta
                   (cdcooper
                   ,nrdconta
                   ,cdnivel_risco
                   ,dsjustificativa
                   ,dtmvtolt
                   ,cdoperad)
             VALUES(vr_cdcooper
                   ,pr_nrdconta
                   ,pr_cdnivel_risco
                   ,pr_dsjustificativa
                   ,rw_crapdat.dtmvtolt
                   ,vr_cdoperad);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          vr_dscritic := 'Conta já cadastrada!';
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir risco: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;
        
      -- Gera log
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => 'cadris.log'
                                ,pr_des_log      => TO_CHAR(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                    ' -->  Operador '|| vr_cdoperad || ' - ' ||
                                                    'Incluiu a conta: ' || pr_nrdconta || 
                                                    ' - Nivel de Risco: ' || vr_tab_risco(pr_cdnivel_risco) ||
                                                    ' - Justificativa: ' || pr_dsjustificativa);

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela TELA_ATENDA_COBRAN: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_inclui_risco;

  PROCEDURE pc_importa_risco(pr_nmdarqui        IN VARCHAR2 --> Conta
                            ,pr_xmllog          IN VARCHAR2 --> XML com informacoes de LOG
                            ,pr_cdcritic       OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic       OUT VARCHAR2 --> Descricao da critica
                            ,pr_retxml      IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                            ,pr_nmdcampo       OUT VARCHAR2 --> Nome do campo com erro
                            ,pr_des_erro       OUT VARCHAR2) IS
    
    -- Valida conta
    cursor cr_crapass(pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type) is
      select count(1)
        from crapass
       where crapass.cdcooper = pr_cdcooper
         and crapass.nrdconta = pr_nrdconta;

    cursor cr_tbrisco(pr_cdcooper in crapass.cdcooper%type
                     ,pr_nrdconta in crapass.nrdconta%type) is
      select t.cdnivel_risco
        from tbrisco_cadastro_conta t
       where t.cdcooper = pr_cdcooper
         and t.nrdconta = pr_nrdconta;
    
    type typ_tab_nivris is table of tbrisco_cadastro_conta.cdnivel_risco%type index by varchar2(2);
    vr_tab_nivris typ_tab_nivris;
  
    vr_arquivo      UTL_FILE.file_type;
    vr_nmdireto     varchar2(100);
    vr_nmdarqui     varchar2(100);
    vr_dserro       varchar2(1000);
    vr_dsmotivo     varchar2(1000);
    vr_dscritic     crapcri.dscritic%type;
    vr_texto        varchar2(1000);
    vr_tabtexto     gene0002.typ_split;
    w_cdcooper      crapcop.cdcooper%type;
    w_nrdconta      crapass.nrdconta%type;
    w_dsnivris      varchar2(2);
    w_cdnivris      tbrisco_cadastro_conta.cdnivel_risco%type;
    w_dsjustif      crappco.dsconteu%type;
    vr_idsucess     varchar(1);
    vr_sqlerrm      varchar2(1000);
    vr_datahora     varchar2(14);
    vr_geroulog     varchar2(1) := 'N';
    vr_arquivo_clob clob;
    vr_idprglog     number;
    
    -- Cursor da data
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
    
    -- Variaveis
    vr_qtassoci NUMBER;
    
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis de excecao
    vr_exc_conta  exception;
    vr_exc_insert exception;
    vr_exc_duplic exception;
    vr_exc_risco  exception;
    
    --Variavel para testes em homol/desenvolvimento
    vr_root_micros varchar2(4000);
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
    
    --Carrega tabela de memoria com os niveis de risco
    vr_tab_nivris('A') := 2;
    vr_tab_nivris('B') := 3;
    vr_tab_nivris('C') := 4;
    vr_tab_nivris('D') := 5;
    vr_tab_nivris('E') := 6;
    vr_tab_nivris('F') := 7;
    vr_tab_nivris('G') := 8;
    vr_tab_nivris('H') := 9;
    
    -- Busca a data do sistema
    OPEN  BTCH0001.cr_crapdat(3); --Arquivo podera conter registros de varias cooperativas, utilizar data da CECRED
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    CLOSE BTCH0001.cr_crapdat;
    
    --Separa path do nome do arquivo
    gene0001.pc_separa_arquivo_path(pr_caminho => pr_nmdarqui
                                   ,pr_direto  => vr_nmdireto
                                   ,pr_arquivo => vr_nmdarqui);
    
    --ambientes de desenvolvimento/homologacao possuem diretorio microsd/microsh por exemplo
    vr_root_micros := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdcooper => 0, pr_cdacesso => 'ROOT_MICROS');
    vr_nmdireto    := replace(vr_nmdireto,'/micros/',vr_root_micros);
    
    --Abre arquivo a ser importado
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto,
                             pr_nmarquiv => vr_nmdarqui,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_arquivo,
                             pr_des_erro => vr_dserro);
    
    if vr_dserro is not null then
      vr_dserro := 'Erro ao abrir arquivo';
      raise_application_error(-20001,'Erro ao abrir arquivo - '||vr_dserro);
    end if;
    
    --Abre arquivo de saida para geracao de logs linha a linha
    dbms_lob.createtemporary(vr_arquivo_clob, TRUE);
    dbms_lob.open(vr_arquivo_clob, dbms_lob.lob_readwrite);
    
    loop
      begin
        vr_dsmotivo := '';
        vr_dserro   := '';
        vr_idsucess := 'N';
        vr_qtassoci := 0;

        --Leitura da linha do arquivo
        gene0001.pc_le_linha_arquivo(vr_arquivo,vr_texto);
        vr_texto := trim(translate(translate(vr_texto,chr(10),' '),chr(13),' '));
        vr_tabtexto := gene0002.fn_quebra_string(vr_texto,';');
        
        for x in 1..vr_tabtexto.count loop
          case
            when x = 1 then w_cdcooper := to_number(vr_tabtexto(x));
            when x = 2 then w_nrdconta := to_number(vr_tabtexto(x));
            when x = 3 then w_dsnivris := vr_tabtexto(x);
            when x = 4 then w_dsjustif := substr(vr_tabtexto(x),1,1000);
            else null;
          end case;
        end loop;
        
        begin
          w_cdnivris := to_number(vr_tab_nivris(w_dsnivris));
        exception
          when no_data_found then
            raise vr_exc_risco;
        end;
        
        open  cr_crapass(pr_cdcooper => w_cdcooper,
                         pr_nrdconta => w_nrdconta);
        fetch cr_crapass into vr_qtassoci;
        close cr_crapass;

        -- Caso nao encontre gera critica
        if vr_qtassoci = 0 then
          raise vr_exc_conta;
        end if;
        
        begin
          insert into tbrisco_cadastro_conta
                     (cdcooper
                     ,nrdconta
                     ,cdnivel_risco
                     ,dsjustificativa
                     ,dtmvtolt
                     ,cdoperad)
               values(w_cdcooper
                     ,w_nrdconta
                     ,w_cdnivris
                     ,w_dsjustif
                     ,rw_crapdat.dtmvtolt
                     ,vr_cdoperad);
        exception
          when dup_val_on_index then
            open cr_tbrisco(w_cdcooper,w_nrdconta);
            fetch cr_tbrisco into w_cdnivris;
            close cr_tbrisco;
            
            w_dsnivris := vr_tab_risco(w_cdnivris);
            
            raise vr_exc_duplic;
          when others then
            vr_sqlerrm := sqlerrm;
            raise vr_exc_insert;
        end;
        
        -- Gera log
        pc_log_programa(PR_DSTIPLOG           => 'O',
                        PR_CDPROGRAMA         => 'TELA_CADRIS',
                        pr_cdcooper           => vr_cdcooper,
                        pr_tpexecucao         => 3,
                        pr_tpocorrencia       => 4,
                        pr_dsmensagem         => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')      ||
                                                      ' -->  Operador '     || vr_cdoperad || ' - ' ||
                                                      'Incluiu a conta: '   || w_nrdconta  ||
                                                      ' - Nivel de Risco: ' || w_dsnivris  ||
                                                      ' - Justificativa: '  || w_dsjustif,
                        PR_IDPRGLOG           => vr_idprglog);
        /*
        btch0001.pc_gera_log_batch(pr_cdcooper     => w_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => 'cadris.log'
                                  ,pr_des_log      => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')      ||
                                                      ' -->  Operador '     || vr_cdoperad || ' - ' ||
                                                      'Incluiu a conta: '   || w_nrdconta  ||
                                                      ' - Nivel de Risco: ' || w_dsnivris  ||
                                                      ' - Justificativa: '  || w_dsjustif);
        */

        vr_idsucess := 'S';
        commit;
      exception
        when vr_exc_risco then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Risco inválido';
        when vr_exc_duplic then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Conta já cadastrada com risco '||w_dsnivris||'!';
        when vr_exc_insert then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Erro ao inserir - '||vr_sqlerrm;
        when vr_exc_conta then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Associado não cadastrado';
        when invalid_number then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Dado inválido na linha';
        when value_error then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Dado inválido na linha';
        when no_data_found then
          raise;
        when others then
          vr_geroulog := 'S';
          vr_dsmotivo := 'Erro não identificado - '||sqlerrm;
      end;
      
      dbms_lob.writeappend(vr_arquivo_clob,length(vr_texto||';'||vr_idsucess||';'||vr_dsmotivo||';'||chr(10)),vr_texto||';'||vr_idsucess||';'||vr_dsmotivo||';'||chr(10));
    end loop;
  exception
    when no_data_found then
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);
      
      vr_datahora := to_char(sysdate,'YYYYMMDD');
      
      gene0002.pc_clob_para_arquivo(pr_clob => vr_arquivo_clob
                                   ,pr_caminho => vr_nmdireto || '/processados'
                                   ,pr_arquivo => vr_datahora||'_'||substr(vr_nmdarqui,1,instr(vr_nmdarqui,'.')-1)||'_saida.txt'
                                   ,pr_des_erro => vr_dserro);
      
      
      
      -- Mover os arquivos para a pasta /processados
      gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmdarqui || ' ' || 
                                   vr_nmdireto || '/processados/' ||vr_datahora||'_'||vr_nmdarqui);
      
      if vr_geroulog = 'S' then
        -- Gerar mensagem para apresentar na tela
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Mensagem>' || 'Arquivo importado, verifique arquivo de saida para detalhamento das contas!' || '</Mensagem></Root>');
      else
        -- Gerar mensagem para apresentar na tela
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Mensagem>' || 'Arquivo importado com sucesso!' || '</Mensagem></Root>');
      end if;

      commit;
    when others then
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_arquivo);
      vr_datahora := to_char(sysdate,'YYYYMMDD');
      
      gene0002.pc_clob_para_arquivo(pr_clob => vr_arquivo_clob
                                   ,pr_caminho => vr_nmdireto || '/processados'
                                   ,pr_arquivo => vr_datahora||'_'||substr(vr_nmdarqui,1,instr(vr_nmdarqui,'.')-1)||'_saida.txt'
                                   ,pr_des_erro => vr_dserro);

      -- Mover os arquivos para a pasta /processados
      gene0001.pc_OScommand_Shell('mv ' || vr_nmdireto || '/' || vr_nmdarqui || ' ' || 
                                   vr_nmdireto || '/processados/' ||vr_datahora||'_'||vr_nmdarqui);
      
      --
      if vr_dserro is null then
        vr_dserro := 'Erro no processamento do arquivo, favor contactar o analista responsavel';
        pc_internal_exception;
      end if;

      -- Carregar XML padrão para variavel de retorno
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || vr_dserro || '</Erro></Root>');

      rollback;
  END pc_importa_risco;
END TELA_CADRIS;
/
