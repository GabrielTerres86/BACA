CREATE OR REPLACE PACKAGE CECRED.TELA_TAB049 IS

  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB049
  --  Sistema  : Rotinas utilizadas pela Tela TAB049
  --  Sigla    : EMPR
  --  Autor    : Márcioe/Mouts
  --  Data     : Agosto/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB049
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------

  ---------------------------- ESTRUTURAS DE REGISTRO -----------------------



  ---------------------------------- ROTINAS --------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2 --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2);

  PROCEDURE pc_alterar( pr_valormin  IN NUMBER
                       ,pr_valormax  IN NUMBER
                       ,pr_datadvig  IN VARCHAR
                       ,pr_pgtosegu  IN NUMBER
                       ,pr_subestip  IN VARCHAR
                       ,pr_sglarqui  IN VARCHAR
                       ,pr_nrsequen  IN INTEGER
                       ,pr_vallidps  IN NUMBER
                       ,pr_xmllog      IN VARCHAR2  --> XML com informações de LOG
                       ,pr_cdcritic   OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic   OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml     IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo   OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro   OUT VARCHAR2); --> Erros do processo

END TELA_TAB049;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_TAB049 IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_TAB049
  --  Sistema  : Rotinas utilizadas pela Tela TAB049
  --  Sigla    : EMPR
  --  Autor    : Márcio/Mouts
  --  Data     : Agosto/2018                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Centralizar rotinas relacionadas a Tela TAB049
  --
  -- Alteracoes:  
  --
  ---------------------------------------------------------------------------
  PROCEDURE pc_consultar(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                        ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                        ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                        ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                        ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                        ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
    /* .............................................................................

        Programa: pc_consultar
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Márcio/Mouts
        Data    : Agosto/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para consultar Parâmetros de Seguros

        Observacao: -----

        Alteracoes: 
    ..............................................................................*/
      ----------->>> VARIAVEIS <<<--------
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
      vr_dscritic VARCHAR2(1000);        --> Desc. Erro

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      vr_auxconta INTEGER := 0; -- Contador auxiliar p/ posicao no XML
      
      vr_dstextab craptab.dstextab%TYPE;

      vr_valormin NUMBER  :=0;
      vr_valormax NUMBER  :=0;
      vr_datadvig VARCHAR2(10);      
      vr_pgtosegu VARCHAR2(7);
      vr_subestip VARCHAR2(25);
      vr_sglarqui VARCHAR2(2);
      vr_nrsequen VARCHAR2(5):=0;
      vr_vallidps NUMBER  :=0;      
            
      -- Variaveis retornadas da gene0004.pc_extrai_dados
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN

      pr_des_erro := 'OK';
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

      -- Buscar dados da TAB
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'SEGPRESTAM'
                                               ,pr_tpregist => 0);

      --Se nao encontrou parametro
      IF TRIM(vr_dstextab) IS NULL THEN
        vr_cdcritic := 55;
        RAISE vr_exc_saida;
      ELSE
        -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
        vr_valormin := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,12));
        vr_valormax := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));        
        vr_datadvig := SUBSTR(vr_dstextab,40,10);
        vr_pgtosegu := to_char(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7)),'FM0D00000');  
        vr_subestip := SUBSTR(vr_dstextab,59,25);
        vr_sglarqui := SUBSTR(vr_dstextab,85,2);
        vr_nrsequen := SUBSTR(vr_dstextab,88,5);
        vr_vallidps := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
                
      END IF;

      -- PASSA OS DADOS PARA O XML RETORNO      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Root',
                             pr_posicao  => 0,
                             pr_tag_nova => 'Dados',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      -- Insere as tags
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'Dados',
                             pr_posicao  => 0,
                             pr_tag_nova => 'inf',
                             pr_tag_cont => NULL,
                             pr_des_erro => vr_dscritic);
      
      -- CAMPOS
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'valormin',
                             pr_tag_cont => to_char(vr_valormin,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'valormax',
                             pr_tag_cont => to_char(vr_valormax,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'datadvig',
                             pr_tag_cont => vr_datadvig,
                             pr_des_erro => vr_dscritic);             

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'pgtosegu',
                             pr_tag_cont => to_char(vr_pgtosegu,
                                                    'FM0D00000',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'subestip',
                             pr_tag_cont => vr_subestip,
                             pr_des_erro => vr_dscritic);             

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'sglarqui',
                             pr_tag_cont => vr_sglarqui,
                             pr_des_erro => vr_dscritic); 
      
      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'nrsequen',
                             pr_tag_cont => to_char(vr_nrsequen),
                             pr_des_erro => vr_dscritic);

      gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                             pr_tag_pai  => 'inf',
                             pr_posicao  => vr_auxconta,
                             pr_tag_nova => 'vallidps',
                             pr_tag_cont => to_char(vr_vallidps,
                                                    '999999999D00',
                                                    'NLS_NUMERIC_CHARACTERS='',.'''),
                             pr_des_erro => vr_dscritic);
                             
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
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_consultar;

  PROCEDURE pc_alterar( pr_valormin  IN NUMBER
                       ,pr_valormax  IN NUMBER
                       ,pr_datadvig  IN VARCHAR
                       ,pr_pgtosegu  IN NUMBER
                       ,pr_subestip  IN VARCHAR
                       ,pr_sglarqui  IN VARCHAR
                       ,pr_nrsequen  IN INTEGER
                       ,pr_vallidps  IN NUMBER
                       ,pr_xmllog    IN VARCHAR2 --> XML com informações de LOG
                       ,pr_cdcritic OUT PLS_INTEGER --> Código da crítica
                       ,pr_dscritic OUT VARCHAR2 --> Descrição da crítica
                       ,pr_retxml    IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                       ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                       ,pr_des_erro OUT VARCHAR2) IS --> Erros do processo
    /* .............................................................................

        Programa: pc_alterar
        Sistema : CECRED
        Sigla   : EMPR
        Autor   : Márcio/Mouts
        Data    : Agosto/2018                 Ultima atualizacao:

        Dados referentes ao programa:

        Frequencia: Sempre que for chamado

        Objetivo  : Rotina para alterar os Parâmetros de Seguros

        Observacao: -----

        Alteracoes: 
    ..............................................................................*/

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variaveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_cdacesso VARCHAR2(100);

    vr_dstextab craptab.dstextab%TYPE;

    vr_valormin NUMBER  :=0;
    vr_valormax NUMBER  :=0;
    vr_datadvig VARCHAR2(10);      
    vr_pgtosegu NUMBER  :=0;
    vr_subestip VARCHAR2(25);
    vr_sglarqui VARCHAR2(2);
    vr_nrsequen INTEGER(5):=0;
    vr_vallidps NUMBER  :=0;     

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
    
    -- Cursor para buscar o departamnento do operador
    CURSOR cr_crapope(pr_cdcooper in crapcop.cdcooper%type,
                   pr_cdoperad in crapope.cdoperad%type) is
      SELECT
            c.cddepart
      FROM
           crapope c
      WHERE
           c.cdcooper = pr_cdcooper
       AND c.cdoperad = pr_cdoperad;

    --------------->>> SUB-ROTINA <<<-----------------
    --> Gerar Log da tela
    PROCEDURE pc_log_tab049(pr_cdcooper IN crapcop.cdcooper%TYPE,
                            pr_cdoperad IN crapope.cdoperad%TYPE,
                            pr_dscdolog IN VARCHAR2) IS
      vr_dscdolog VARCHAR2(500);
    BEGIN

      vr_dscdolog := to_char(rw_crapdat.dtmvtolt,'DD/MM/RRRR')||' '|| to_char(SYSDATE,'HH24:MI:SS') ||
                     ' --> '|| vr_cdacesso || ' --> '|| 'Operador '|| pr_cdoperad ||
                     ' '||pr_dscdolog;

      btch0001.pc_gera_log_batch(pr_cdcooper => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log  => vr_dscdolog,
                                 pr_nmarqlog => 'tab049',
                                 pr_flfinmsg => 'N');
    END;

  BEGIN

    pr_des_erro := 'OK';
    
    IF pr_valormin is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Valor mínimo é obrigatório!';      
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    IF pr_valormax is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Valor máximo é obrigatório!';      
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    IF pr_datadvig is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Data de início da vigência é obrigatória!';      
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
      
    IF pr_pgtosegu is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Pagamento Seguradora é obrigatório!';      
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;

    IF pr_vallidps is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Valor Limite para Impressão DPS é obrigatório!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    IF pr_subestip is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Substipulante é obrigatório!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    IF pr_sglarqui is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic :=  'Sigla do Arquivo é obrigatória!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    IF pr_nrsequen is null THEN
        vr_cdcritic :=0 ;
        vr_dscritic :=  'Sequencia é obrigatória!';
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
      
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
    
    IF pr_valormin > pr_valormax THEN
        vr_cdcritic :=0 ;
        vr_dscritic := 'Valor máximo não pode ser menor que o valor mínimo!';      
      -- Levanta exceção
      RAISE vr_exc_saida;
    END IF;
    
    FOR c1 in cr_crapope(vr_cdcooper,vr_cdoperad) LOOP
      --Departamento 20 - TI e 9 - COORD.PRODUTOS
      IF c1.cddepart not in (9,20) THEN
        vr_cdcritic := 36;
        RAISE vr_exc_saida;
      END IF;
    END LOOP;

    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => vr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'SEGPRESTAM'
                                             ,pr_tpregist => 0);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_valormin := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,12));
      vr_valormax := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));        
      vr_datadvig := SUBSTR(vr_dstextab,40,10);
      vr_pgtosegu := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));        
      vr_subestip := SUBSTR(vr_dstextab,59,25);
      vr_sglarqui := SUBSTR(vr_dstextab,85,2);
      vr_nrsequen := SUBSTR(vr_dstextab,88,5);
      vr_vallidps := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
    END IF;

    vr_dstextab := to_char(pr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_valormax,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(pr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||                   
                   pr_datadvig                                                              || ' ' ||                   
                   to_char(pr_pgtosegu,   'FM0D00000'     ,'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||                   
                   lpad(pr_subestip,25,'0')                                                 || ' ' ||                   
                   lpad(pr_sglarqui,2,' ')                                                  || ' ' ||                                                         
                   lpad(pr_nrsequen,5,'0')                                                  || ' ' ||                                                                            
                   to_char(pr_vallidps,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') 
                         ||'';                   

    BEGIN
      UPDATE craptab tab
         SET tab.dstextab = vr_dstextab
       WHERE tab.cdcooper        = vr_cdcooper
         AND upper(tab.nmsistem) = 'CRED'
         AND upper(tab.tptabela) = 'USUARI'
         AND tab.cdempres        = 11
         AND upper(tab.cdacesso) = 'SEGPRESTAM'
         AND tab.tpregist        = 0;
    EXCEPTION
      WHEN OTHERS THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Parametros Seguro!';
        -- volta para o programa chamador
        RAISE vr_exc_saida;

    END;

    IF vr_valormin <> pr_valormin THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Valor Minimo Seguro Prestamista de ' ||
                                    to_char(vr_valormin,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                   ' para ' || to_char(pr_valormin,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_valormax <> pr_valormax THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Valor Maximo Seguro Prestamista de ' ||
                                    to_char(vr_valormax,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_valormax,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_datadvig <> pr_datadvig THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou a Data de início da Vigência de ' ||
                                    vr_datadvig ||
                                    ' para ' || pr_datadvig);
    END IF;

    IF vr_pgtosegu <> pr_pgtosegu THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou Pagamento Seguradora de ' ||
                                    to_char(vr_pgtosegu,'FM0D00000', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_pgtosegu,'FM0D00000', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;

    IF vr_subestip <> pr_subestip THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou o Subestipulante de ' ||
                                    vr_subestip ||
                                    ' para ' || pr_subestip);
    END IF;

    IF vr_sglarqui <> pr_sglarqui THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou a Sigla do Arquivo de ' ||
                                    vr_sglarqui ||
                                    ' para ' || pr_sglarqui);
    END IF;

    IF vr_nrsequen <> pr_nrsequen THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou a Sequencia de ' ||
                                    lpad(vr_nrsequen,5,'0') ||
                                    ' para ' || lpad(pr_nrsequen,5,'0'));
    END IF;

    IF vr_vallidps <> pr_vallidps THEN
      --> gerar log da tela
      pc_log_tab049(pr_cdcooper => vr_cdcooper,
                    pr_cdoperad => vr_cdoperad,
                    pr_dscdolog => 'Alterou o Limite que Determina se Imprime Relatório com DPS ou sem DPS de ' ||
                                    to_char(vr_vallidps,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.''') ||
                                    ' para ' || to_char(pr_vallidps,'FM000000000D00', 'NLS_NUMERIC_CHARACTERS='',.'''));
    END IF;
 
    COMMIT;

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
      pr_dscritic := 'Erro geral na rotina da tela ' || vr_nmdatela || ': ' || SQLERRM;
      pr_des_erro := 'NOK';
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_alterar;

END TELA_TAB049;
/
