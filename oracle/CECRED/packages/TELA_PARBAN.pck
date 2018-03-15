CREATE OR REPLACE PACKAGE CECRED.TELA_PARBAN
IS
PROCEDURE pc_parametros_banner(pr_cdcanal  in TBGEN_BANNER_PARAM.CDCANAL%TYPE
                               ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
PROCEDURE pc_consultar_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                             ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                             ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  

PROCEDURE pc_manter_banner_ordem(pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                                  ,pr_dsbannerorder           IN TBGEN_BANNER_PARAM.DSBANNERORDER%TYPE
                                  ,pr_intransicao             IN TBGEN_BANNER_PARAM.INTRANSICAO%TYPE
                                  ,pr_nrsegundos_transicao    IN tbgen_banner_param.nrsegundos_transicao%TYPE
                                  --
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  
                             
PROCEDURE pc_manter_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                            ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                            ,pr_dstitulo_banner         in TBGEN_BANNER.DSTITULO_BANNER%TYPE
                            ,pr_insituacao_banner       in TBGEN_BANNER.INSITUACAO_BANNER%TYPE
                            ,pr_nmimagem_banner         in TBGEN_BANNER.NMIMAGEM_BANNER%TYPE
                            ,pr_inacao_banner           in TBGEN_BANNER.INACAO_BANNER%TYPE
                            ,pr_cdmenu_acao_mobile      in TBGEN_BANNER.CDMENU_ACAO_MOBILE%TYPE
                            ,pr_dslink_acao_banner      in TBGEN_BANNER.DSLINK_ACAO_BANNER%TYPE
                            ,pr_inexibe_msg_confirmacao in TBGEN_BANNER.INEXIBE_MSG_CONFIRMACAO%TYPE
                            ,pr_idacao_banner           IN NUMBER
                            ,pr_dsmensagem_acao_banner  in TBGEN_BANNER.DSMENSAGEM_ACAO_BANNER%TYPE
                            ,pr_tpfiltro                in TBGEN_BANNER.TPFILTRO%TYPE
                            ,pr_inexibir_quando         in TBGEN_BANNER.INEXIBIR_QUANDO%TYPE
                            ,pr_dtexibir_de             in varchar2
                            ,pr_dtexibir_ate            in VARCHAR2
                            ,pr_nmarquivo_upload        in TBGEN_BANNER.NMARQUIVO_UPLOAD%TYPE                            
                            --
                            ,pr_dsfiltro_cooperativas   in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_COOPERATIVAS%TYPE
                            ,pr_dsfiltro_tipos_conta    in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_TIPOS_CONTA%TYPE
                            ,pr_inoutros_filtros        in TBGEN_BANNER_FILTRO_GENERICO.INOUTROS_FILTROS%TYPE
                            ,pr_dsfiltro_produto        in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_PRODUTO%TYPE
                            --
                            ,pr_cdcooper                in TBGEN_BANNER_FILTRO_ESPECIFICO.CDCOOPER%TYPE
                            ,pr_nrdconta                in TBGEN_BANNER_FILTRO_ESPECIFICO.NRDCONTA%TYPE
                            ,pr_idseqttl                in TBGEN_BANNER_FILTRO_ESPECIFICO.IDSEQTTL%TYPE
                             --
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);        --> Erros do processo  
                            
PROCEDURE pc_deletar_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                           ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                           ,pr_xmllog                  IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic                OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic                OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml                  IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo                OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro                OUT VARCHAR2);      --> Erros do processo                            

PROCEDURE pc_busca_telas_mobile(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);        --> Erros do processo
                               
PROCEDURE pc_dados_acesso_server_imagem(pr_cdcanal  tbgen_banner_param.cdcanal%TYPE
									   ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                       ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);      --> Erros do processo

END TELA_PARBAN;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_PARBAN
IS

  NMDATELA CONSTANT VARCHAR2(6) := 'PARBAN';
  
  -- PRIVATE FUNCTIONS, PROCEDURES
  FUNCTION fn_valida_cadastro_banner(pr_tbgen_banner               IN tbgen_banner%ROWTYPE
                                    ,pr_tbgen_banner_filtro_gen    IN tbgen_banner_filtro_generico%ROWTYPE
                                    ,pr_tbgen_banner_filtro_esp    IN tbgen_banner_filtro_especifico%ROWTYPE
                                    ,pr_idacao_banner              IN NUMBER
                                    -- RETORNO
                                    ,pr_nmdcampo                   OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_dscritic                   OUT VARCHAR2 --> Mensagem de retorno de critica da validação
                                    ) RETURN NUMBER;
                                    
  FUNCTION fn_busca_parametro_mobile(pr_parametroid    IN parametromobile.parametromobileid%TYPE) RETURN VARCHAR2;
  
  PROCEDURE pc_insupd_banner_param(pr_cdcanal                 tbgen_banner_param.cdcanal%TYPE
                                  ,pr_dsurlserver             tbgen_banner_param.dsurlserver%TYPE
                                  ,pr_dsbannerorder           tbgen_banner_param.dsbannerorder%TYPE
                                  ,pr_intransicao             tbgen_banner_param.intransicao%TYPE
                                  ,pr_nrsegundos_transicao    tbgen_banner_param.nrsegundos_transicao%TYPE);
  --
  -- BODY PLSQL PROCEDURES, FUNCTIONS
  FUNCTION fn_valida_cadastro_banner(pr_tbgen_banner               IN tbgen_banner%ROWTYPE
                                    ,pr_tbgen_banner_filtro_gen    IN tbgen_banner_filtro_generico%ROWTYPE
                                    ,pr_tbgen_banner_filtro_esp    IN tbgen_banner_filtro_especifico%ROWTYPE
                                    ,pr_idacao_banner              IN NUMBER
                                    -- RETORNO
                                    ,pr_nmdcampo                   OUT VARCHAR2 --> Nome do campo com erro
                                    ,pr_dscritic                   OUT VARCHAR2 --> Mensagem de retorno de critica da validação
                                    ) RETURN NUMBER IS

  vr_exc_erro EXCEPTION;

  BEGIN
    
  /*VALIDA OS CAMPOS OBRIGATÓRIOS*/
  IF pr_tbgen_banner.DSTITULO_BANNER IS NULL THEN
    pr_dscritic:= 'Título é obrigatório';
  ELSIF pr_tbgen_banner.CDCANAL IS NULL THEN
    pr_dscritic:= 'Canal de atendimento é obrigatório';
  ELSIF pr_tbgen_banner.INSITUACAO_BANNER = 1 AND pr_tbgen_banner.NMIMAGEM_BANNER IS NULL THEN
    pr_dscritic:= 'Banner está ativo mas nenhuma imagem foi selecionada';
  ELSIF pr_tbgen_banner.INACAO_BANNER = 1 THEN -- Validações refetentes ao botão de ação
    IF pr_tbgen_banner.INEXIBE_MSG_CONFIRMACAO = 1 AND pr_tbgen_banner.DSMENSAGEM_ACAO_BANNER IS NULL THEN
    pr_dscritic:= 'O texto da mensagem de ação do Banner é obrigatório';
    ELSIF pr_idacao_banner = 1 AND pr_tbgen_banner.DSLINK_ACAO_BANNER IS NULL THEN
    pr_dscritic:= 'URL do banner é obrigatório';
    ELSIF pr_idacao_banner = 2 AND pr_tbgen_banner.CDMENU_ACAO_MOBILE IS NULL THEN
    pr_dscritic:= 'Tela do Cecred Mobile do Banner é obrigatória';
    END IF;
  ELSIF pr_tbgen_banner.INEXIBIR_QUANDO = 1 THEN
    IF pr_tbgen_banner.DTEXIBIR_DE > pr_tbgen_banner.DTEXIBIR_ATE THEN
      pr_dscritic:= 'Data inicial de exibição do banner é maior que a data final';
    END IF; 
  ELSIF pr_tbgen_banner.TPFILTRO = 0 THEN
    IF  pr_tbgen_banner_filtro_gen.INOUTROS_FILTROS <> 0 THEN
      IF pr_tbgen_banner_filtro_gen.DSFILTRO_PRODUTO IS NULL THEN
        pr_dscritic:= 'É necessário selecionar uma opção para outros filtros';
      END IF;
    END IF;
  ELSIF pr_tbgen_banner.TPFILTRO = 1 THEN
    IF pr_tbgen_banner.NMARQUIVO_UPLOAD IS NULL THEN
      pr_dscritic:= 'Arquivo de carga é obrigatório';   
    END IF;
  END IF;
    
  IF pr_dscritic IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;
    
  --Se passou por todas as validações
  RETURN 1;
    
  EXCEPTION
    WHEN OTHERS THEN
         RETURN 0;
  END fn_valida_cadastro_banner;

  
  ---
  PROCEDURE pc_parametros_banner(pr_cdcanal  in TBGEN_BANNER_PARAM.CDCANAL%TYPE
                               ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo) IS

    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER(10);

    -- Seleciona o Banner
    CURSOR cur_banner_parametros(pcur_cdcanal   IN TBGEN_BANNER.CDCANAL%TYPE) IS
	  SELECT  tbpa.cdcanal
			 ,tbpa.dsurlserver
			 ,tbpa.dsbannerorder
			 ,tbpa.intransicao
			 ,tbpa.nrsegundos_transicao
		FROM TBGEN_BANNER_PARAM tbpa
		WHERE tbpa.cdcanal = decode(pcur_cdcanal,0,tbpa.cdcanal,pcur_cdcanal);

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

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'parametros', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Obtém os dados dos parametros
    vr_contador := 0;
    FOR rw_banner IN cur_banner_parametros(pr_cdcanal) LOOP

      -- Gera o XML do BANNER
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametros', pr_posicao => 0, pr_tag_nova => 'parametro', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => vr_contador, pr_tag_nova => 'cdcanal', pr_tag_cont => rw_banner.cdcanal, pr_des_erro => vr_dscritic);
     
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => vr_contador, pr_tag_nova => 'dsurlserver', pr_tag_cont => rw_banner.dsurlserver, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => vr_contador, pr_tag_nova => 'dsbannerorder', pr_tag_cont => rw_banner.dsbannerorder, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => vr_contador, pr_tag_nova => 'intransicao', pr_tag_cont => rw_banner.intransicao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => vr_contador, pr_tag_nova => 'nrsegundos_transicao', pr_tag_cont => rw_banner.nrsegundos_transicao, pr_des_erro => vr_dscritic);
      
	  vr_contador := vr_contador+1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END;
  --
  
  PROCEDURE pc_consultar_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                               ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                               ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo) IS

    vr_exc_erro EXCEPTION;                        
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
                              
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    vr_contador NUMBER(10);
    
    vr_titulo_formatado    VARCHAR2(200);

    -- Seleciona o Banner
    CURSOR cur_banner(pcur_cdbanner IN TBGEN_BANNER.CDBANNER%TYPE
                    ,pcur_cdcanal   IN TBGEN_BANNER.CDCANAL%TYPE) IS
      SELECT tban.cdbanner
            ,tban.cdcanal
            ,tban.dstitulo_banner
            ,CASE WHEN tban.insituacao_banner = 0 THEN
              tban.dstitulo_banner||' (Desabilitado)'
             WHEN tban.inexibir_quando = 1 AND trunc(tban.dtexibir_ate) < trunc(SYSDATE) THEN
              tban.dstitulo_banner||' (Expirado)'
             ELSE
              tban.dstitulo_banner
            END dstitulo_banner_formatado
            ,tban.insituacao_banner
            ,tban.nmimagem_banner
            ,tban.inacao_banner
            ,CASE WHEN tban.dslink_acao_banner IS NOT NULL THEN
              1
             WHEN tban.cdmenu_acao_mobile IS NOT NULL THEN
               2 
            END idacao_banner
            ,tban.cdmenu_acao_mobile
            ,tban.dslink_acao_banner
            ,tban.inexibe_msg_confirmacao
            ,tban.dsmensagem_acao_banner
            ,tban.tpfiltro
            ,tban.inexibir_quando
            ,to_char(tban.dtexibir_de,'DD/MM/YYYY') AS dtexibir_de
            ,to_char(tban.dtexibir_ate,'DD/MM/YYYY') AS dtexibir_ate
            ,tban.nmarquivo_upload
            ,tbpa.dsurlserver
            ,tbpa.dsbannerorder
            ,tbpa.intransicao
            ,tbpa.nrsegundos_transicao
            ,tbfg.dsfiltro_cooperativas
            ,tbfg.dsfiltro_tipos_conta
            ,tbfg.inoutros_filtros
            ,tbfg.dsfiltro_produto
            ,filtro_espec.TOTAL
      FROM   TBGEN_BANNER tban
            ,TBGEN_BANNER_PARAM tbpa
            ,TBGEN_BANNER_FILTRO_GENERICO tbfg
            ,(SELECT COUNT(*) AS TOTAL
                    ,tbfe.cdbanner
                    ,tbfe.cdcanal
              FROM   TBGEN_BANNER_FILTRO_ESPECIFICO tbfe
              GROUP  BY tbfe.cdbanner
                       ,tbfe.cdcanal) filtro_espec
            ,(with t as (select p.dsbannerorder as str from dual,tbgen_banner_param p WHERE p.cdcanal = pcur_cdcanal)
              --
              select level as seqbanner, regexp_substr(str,'[^,]+',1,level) as cdbanner
              from   t
              connect by regexp_substr(str,'[^,]+',1,level) is not null) ordembanner          
      WHERE 1=1
      AND    tban.CDBANNER = decode(pcur_cdbanner,0,tban.CDBANNER,pcur_cdbanner)
      AND    tban.cdcanal  = pcur_cdcanal
      AND    tbpa.cdcanal  = tban.cdcanal
      AND    tbfg.cdbanner (+)= tban.cdbanner
      AND    tbfg.cdcanal  (+)= tban.cdcanal
      AND    filtro_espec.cdbanner (+)= tban.CDBANNER
      AND    filtro_espec.cdcanal  (+)= tban.CDCANAL
      AND    ordembanner.cdbanner = tban.cdbanner
      ORDER BY ordembanner.seqbanner;
    --
    vr_cd_banner       tbgen_banner.cdbanner%TYPE;
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
      
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'banners', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      
    --vr_cd_banner := nvl(pr_cdbanner,0);
    
    vr_cd_banner := pr_cdbanner;
    
    -- Obtém os dados dos Banners
    vr_contador := 0;
    FOR rw_banner IN cur_banner(vr_cd_banner,pr_cdcanal) LOOP
      
      -- Gera o XML do BANNER
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banners', pr_posicao => 0, pr_tag_nova => 'banner', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'cdbanner', pr_tag_cont => rw_banner.cdbanner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'cdcanal', pr_tag_cont => rw_banner.cdcanal, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dstitulo_banner', pr_tag_cont => rw_banner.dstitulo_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dstitulo_banner_formatado', pr_tag_cont => rw_banner.dstitulo_banner_formatado, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'insituacao_banner', pr_tag_cont => rw_banner.insituacao_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'nmimagem_banner', pr_tag_cont => rw_banner.nmimagem_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'inacao_banner', pr_tag_cont => rw_banner.inacao_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'idacao_banner', pr_tag_cont => rw_banner.idacao_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'cdmenu_acao_mobile', pr_tag_cont => rw_banner.cdmenu_acao_mobile, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dslink_acao_banner', pr_tag_cont => rw_banner.dslink_acao_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'inexibe_msg_confirmacao', pr_tag_cont => rw_banner.inexibe_msg_confirmacao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsmensagem_acao_banner', pr_tag_cont => rw_banner.dsmensagem_acao_banner, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'tpfiltro', pr_tag_cont => rw_banner.tpfiltro, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'inexibir_quando', pr_tag_cont => rw_banner.inexibir_quando, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dtexibir_de', pr_tag_cont => rw_banner.dtexibir_de, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dtexibir_ate', pr_tag_cont => rw_banner.dtexibir_ate, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'nmarquivo_upload', pr_tag_cont => rw_banner.nmarquivo_upload, pr_des_erro => vr_dscritic);
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsurlserver', pr_tag_cont => rw_banner.dsurlserver, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsbannerorder', pr_tag_cont => rw_banner.dsbannerorder, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'intransicao', pr_tag_cont => rw_banner.intransicao, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'nrsegundos_transicao', pr_tag_cont => rw_banner.nrsegundos_transicao, pr_des_erro => vr_dscritic);
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsfiltro_cooperativas', pr_tag_cont => rw_banner.dsfiltro_cooperativas, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsfiltro_tipos_conta', pr_tag_cont => rw_banner.dsfiltro_tipos_conta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'inoutros_filtros', pr_tag_cont => rw_banner.inoutros_filtros, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'dsfiltro_produto', pr_tag_cont => rw_banner.dsfiltro_produto, pr_des_erro => vr_dscritic);
      --
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'banner', pr_posicao => vr_contador, pr_tag_nova => 'total_cooperados_importado', pr_tag_cont => rw_banner.TOTAL, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador+1;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END;
  --
  PROCEDURE pc_manter_banner_ordem(pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                                  ,pr_dsbannerorder           IN TBGEN_BANNER_PARAM.DSBANNERORDER%TYPE
                                  ,pr_intransicao             IN TBGEN_BANNER_PARAM.INTRANSICAO%TYPE
                                  ,pr_nrsegundos_transicao    IN tbgen_banner_param.nrsegundos_transicao%TYPE
                                  --
                                  ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo) IS
                                  
    vr_exc_erro           EXCEPTION;                        
    vr_cdcritic           crapcri.cdcritic%TYPE;
    vr_dscritic           VARCHAR2(10000);
    vr_existe_banner      NUMBER;                              
    vr_url_server         TBGEN_BANNER_PARAM.DSURLSERVER%TYPE;
  BEGIN
    --
    -- Busca o caminho onde é armazenado o banner
    BEGIN
      vr_url_server := fn_busca_parametro_mobile(46);
    EXCEPTION
      WHEN no_data_found THEN
        vr_dscritic := 'Parametro não encontrado.';
        RAISE;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao tentar localizar caminho do banner' || '. Erro: ' || SQLERRM;
        RAISE;
    END;  
    -- Insere ou atualizar parametros do banner
    BEGIN
      pc_insupd_banner_param(pr_cdcanal
                            ,vr_url_server
                            ,pr_dsbannerorder
                            ,pr_intransicao
                            ,pr_nrsegundos_transicao);
    EXCEPTION  
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao tentar registrar os parametros do banner' || '. Erro: ' || SQLERRM;
        RAISE;
    END;
    --
    
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' - '|| SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;   
  END pc_manter_banner_ordem;
  --
  PROCEDURE pc_manter_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                            ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                            ,pr_dstitulo_banner         in TBGEN_BANNER.DSTITULO_BANNER%TYPE
                            ,pr_insituacao_banner       in TBGEN_BANNER.INSITUACAO_BANNER%TYPE
                            ,pr_nmimagem_banner         in TBGEN_BANNER.NMIMAGEM_BANNER%TYPE
                            ,pr_inacao_banner           in TBGEN_BANNER.INACAO_BANNER%TYPE
                            ,pr_cdmenu_acao_mobile      in TBGEN_BANNER.CDMENU_ACAO_MOBILE%TYPE
                            ,pr_dslink_acao_banner      in TBGEN_BANNER.DSLINK_ACAO_BANNER%TYPE
                            ,pr_inexibe_msg_confirmacao in TBGEN_BANNER.INEXIBE_MSG_CONFIRMACAO%TYPE
                            ,pr_idacao_banner           IN NUMBER
                            ,pr_dsmensagem_acao_banner  in TBGEN_BANNER.DSMENSAGEM_ACAO_BANNER%TYPE
                            ,pr_tpfiltro                in TBGEN_BANNER.TPFILTRO%TYPE
                            ,pr_inexibir_quando         in TBGEN_BANNER.INEXIBIR_QUANDO%TYPE
                            ,pr_dtexibir_de             in varchar2
                            ,pr_dtexibir_ate            in VARCHAR2
                            ,pr_nmarquivo_upload        in TBGEN_BANNER.NMARQUIVO_UPLOAD%TYPE
                            --
                            ,pr_dsfiltro_cooperativas   in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_COOPERATIVAS%TYPE
                            ,pr_dsfiltro_tipos_conta    in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_TIPOS_CONTA%TYPE
                            ,pr_inoutros_filtros        in TBGEN_BANNER_FILTRO_GENERICO.INOUTROS_FILTROS%TYPE
                            ,pr_dsfiltro_produto        in TBGEN_BANNER_FILTRO_GENERICO.DSFILTRO_PRODUTO%TYPE
                            --
                            ,pr_cdcooper                in TBGEN_BANNER_FILTRO_ESPECIFICO.CDCOOPER%TYPE
                            ,pr_nrdconta                in TBGEN_BANNER_FILTRO_ESPECIFICO.NRDCONTA%TYPE
                            ,pr_idseqttl                in TBGEN_BANNER_FILTRO_ESPECIFICO.IDSEQTTL%TYPE
                             --
                            ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo
                            
    vr_exc_erro EXCEPTION;                        
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
                              
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    --
    vr_seq_banner    NUMBER; -- Sequencia do banner
    vr_cdbanner      NUMBER; -- Código do banner
    vr_dtexibir_de   date; -- Data de vigencia inicial
    vr_dtexibir_ate  date;  -- Data de vigencia final
    vr_validacao     NUMBER; -- validação dos campos   
    vr_tbgen_banner             tbgen_banner%ROWTYPE;
    vr_tbgen_banner_param       tbgen_banner_param%ROWTYPE;
    vr_tbgen_banner_filtro_gen  tbgen_banner_filtro_generico%ROWTYPE;
    vr_tbgen_banner_filtro_esp  tbgen_banner_filtro_especifico%ROWTYPE;
    --    
    vr_url_server               VARCHAR2(500):='http://conteudo.cecred.coop.br/imagens/notificacoes/banners/';
    --
    vr_dsbannerorder            tbgen_banner_param.dsbannerorder%TYPE;
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
    
    --Código do banner                        
    vr_cdbanner := nvl(pr_cdbanner,0);
    
    -- Converte parametro para tipo data  
    vr_dtexibir_de    := TRUNC(TO_DATE(pr_dtexibir_de,'dd/mm/RRRR'));
    vr_dtexibir_ate   :=  TRUNC(TO_DATE(pr_dtexibir_ate,'dd/mm/RRRR'));
    
    --RowType TBGEN_BANNER
    vr_tbgen_banner.CDBANNER                  := vr_cdbanner;
    vr_tbgen_banner.CDCANAL                   := pr_cdcanal;
    vr_tbgen_banner.DSTITULO_BANNER           := pr_dstitulo_banner;
    vr_tbgen_banner.INSITUACAO_BANNER         := pr_insituacao_banner;
    vr_tbgen_banner.NMIMAGEM_BANNER           := pr_nmimagem_banner;
    vr_tbgen_banner.INACAO_BANNER             := pr_inacao_banner;
    vr_tbgen_banner.CDMENU_ACAO_MOBILE        := pr_cdmenu_acao_mobile;
    vr_tbgen_banner.DSLINK_ACAO_BANNER        := pr_dslink_acao_banner;
    vr_tbgen_banner.INEXIBE_MSG_CONFIRMACAO   := pr_inexibe_msg_confirmacao;
    vr_tbgen_banner.DSMENSAGEM_ACAO_BANNER    := pr_dsmensagem_acao_banner;
    vr_tbgen_banner.TPFILTRO                  := pr_tpfiltro;
    vr_tbgen_banner.INEXIBIR_QUANDO           := pr_inexibir_quando;
    vr_tbgen_banner.DTEXIBIR_DE               := vr_dtexibir_de;
    vr_tbgen_banner.DTEXIBIR_ATE              := vr_dtexibir_ate;
    vr_tbgen_banner.NMARQUIVO_UPLOAD          := pr_nmarquivo_upload;
    --RowType TBGEN_BANNER_FILTRO_GENERICO
    vr_tbgen_banner_filtro_gen.CDBANNER               := vr_cdbanner;
    vr_tbgen_banner_filtro_gen.CDCANAL                := pr_cdcanal;
    vr_tbgen_banner_filtro_gen.DSFILTRO_COOPERATIVAS  := pr_dsfiltro_cooperativas;
    vr_tbgen_banner_filtro_gen.DSFILTRO_TIPOS_CONTA   := pr_dsfiltro_tipos_conta;
    vr_tbgen_banner_filtro_gen.INOUTROS_FILTROS       := pr_inoutros_filtros;
    vr_tbgen_banner_filtro_gen.DSFILTRO_PRODUTO       := pr_dsfiltro_produto;
    --RowType TBGEN_BANNER_FILTRO_ESPECIFICO
    vr_tbgen_banner_filtro_esp.CDBANNER          := vr_cdbanner;
    vr_tbgen_banner_filtro_esp.CDCANAL           := pr_cdcanal;
    vr_tbgen_banner_filtro_esp.CDCOOPER          := pr_cdcooper;
    vr_tbgen_banner_filtro_esp.NRDCONTA          := pr_nrdconta;
    vr_tbgen_banner_filtro_esp.IDSEQTTL          := pr_idseqttl;
    
    --Efetua a validação dos dados
    vr_validacao := fn_valida_cadastro_banner(pr_tbgen_banner              => vr_tbgen_banner
                                             ,pr_tbgen_banner_filtro_gen   => vr_tbgen_banner_filtro_gen
                                             ,pr_tbgen_banner_filtro_esp   => vr_tbgen_banner_filtro_esp
                                             ,pr_idacao_banner             => pr_idacao_banner
                                             ,pr_nmdcampo                  => pr_nmdcampo   
                                             ,pr_dscritic                  => vr_dscritic);
                            
    IF vr_validacao = 0 THEN
      RAISE vr_exc_erro;
    END IF;                         
    
    --Cadastro novo do banner                        
    if nvl(vr_cdbanner,0) = 0 then
      -- Gera o sequencial do Banner
      begin
        select seqgen_banner_id.nextval
        into   vr_seq_banner
        from   dual;
      exception
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao gerar sequencial do banner (SEQGEN_BANNER_ID) - ' || '. Erro: ' || SQLERRM;
           RAISE;  
      end;
      --
      IF vr_seq_banner = 0 THEN
        begin
          select seqgen_banner_id.nextval
          into   vr_seq_banner
          from   dual;
        exception
          WHEN OTHERS THEN
             vr_dscritic := 'Erro ao gerar sequencial do banner (SEQGEN_BANNER_ID) - ' || '. Erro: ' || SQLERRM;
             RAISE;  
        end;
      END IF;
      -- Busca o caminho onde é armazenado o banner
      BEGIN
        vr_url_server := fn_busca_parametro_mobile(46);
      EXCEPTION
        WHEN no_data_found THEN
          vr_dscritic := 'Parametro não encontrado.';
          RAISE;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao tentar localizar caminho do banner' || '. Erro: ' || SQLERRM;
          RAISE;
      END;                                            
      --    
      begin
        insert into TBGEN_BANNER(CDBANNER
                                ,CDCANAL
                                ,DSTITULO_BANNER
                                ,INSITUACAO_BANNER
                                ,NMIMAGEM_BANNER
                                ,INACAO_BANNER
                                ,CDMENU_ACAO_MOBILE
                                ,DSLINK_ACAO_BANNER
                                ,INEXIBE_MSG_CONFIRMACAO
                                ,DSMENSAGEM_ACAO_BANNER
                                ,TPFILTRO
                                ,INEXIBIR_QUANDO
                                ,DTEXIBIR_DE
                                ,DTEXIBIR_ATE)
                          values(vr_seq_banner
                                ,pr_cdcanal
                                ,pr_dstitulo_banner
                                ,pr_insituacao_banner
                                ,pr_nmimagem_banner
                                ,pr_inacao_banner
                                ,DECODE(pr_idacao_banner,2,pr_cdmenu_acao_mobile,NULL)
                                ,DECODE(pr_idacao_banner,1,pr_dslink_acao_banner,NULL)
                                ,pr_inexibe_msg_confirmacao
                                ,pr_dsmensagem_acao_banner
                                ,pr_tpfiltro
                                ,pr_inexibir_quando
                                ,vr_dtexibir_de
                                ,vr_dtexibir_ate);
        
      exception
        WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir registro (TBGEN_BANNER) - ' || '. Erro: ' || SQLERRM;
           RAISE;  
      end;
      --
      BEGIN
        SELECT DSBANNERORDER
        INTO   vr_dsbannerorder
        FROM   TBGEN_BANNER_PARAM tbpa
        WHERE  CDCANAL = pr_cdcanal;
      EXCEPTION
        WHEN no_data_found THEN
          -- Insere ou atualizar parametros do banner
          BEGIN
            pc_insupd_banner_param(pr_cdcanal
                                  ,vr_url_server
                                  ,vr_seq_banner
                                  ,0
                                  ,NULL);
          EXCEPTION  
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao tentar registrar os parametros do banner' || '. Erro: ' || SQLERRM;
              RAISE;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao buscar ordem dos banners. '||' Erro: '||SQLERRM;
          RAISE;
      END;
      --
      IF vr_dsbannerorder IS NOT NULL THEN
        BEGIN
          UPDATE tbgen_banner_param
          SET    dsbannerorder = vr_dsbannerorder||','||vr_seq_banner
          WHERE  cdcanal = pr_cdcanal;
        EXCEPTION
          WHEN OTHERS THEN
           vr_dscritic := 'Erro ao atualizar registro (TBGEN_BANNER_PARAM) ' || '. Erro: ' || SQLERRM;
           RAISE;  
        END;
      END IF;
      --
      if pr_tpfiltro = 0 then
        begin
          insert into TBGEN_BANNER_FILTRO_GENERICO(CDBANNER
                                                  ,CDCANAL
                                                  ,DSFILTRO_COOPERATIVAS
                                                  ,DSFILTRO_TIPOS_CONTA
                                                  ,INOUTROS_FILTROS
                                                  ,DSFILTRO_PRODUTO)
                                            values(vr_seq_banner
                                                  ,pr_cdcanal
                                                  ,pr_dsfiltro_cooperativas
                                                  ,pr_dsfiltro_tipos_conta
                                                  ,pr_inoutros_filtros
                                                  ,pr_dsfiltro_produto);
          
        exception
          WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir registro (TBGEN_BANNER_FILTRO_GENERICO) - ' || vr_seq_banner || '. Erro: ' || SQLERRM;
             RAISE;  
        end;
      ELSIF pr_tpfiltro = 1 then
        NULL;
      end if;
      
    ELSE -- Atualização do banner
      begin
        UPDATE TBGEN_BANNER
        SET    DSTITULO_BANNER           = pr_dstitulo_banner
              ,INSITUACAO_BANNER         = pr_insituacao_banner
              ,NMIMAGEM_BANNER           = pr_nmimagem_banner
              ,INACAO_BANNER             = pr_inacao_banner
              ,CDMENU_ACAO_MOBILE        = DECODE(pr_idacao_banner,2,pr_cdmenu_acao_mobile,NULL)
              ,DSLINK_ACAO_BANNER        = DECODE(pr_idacao_banner,1,pr_dslink_acao_banner,NULL)
              ,INEXIBE_MSG_CONFIRMACAO   = pr_inexibe_msg_confirmacao
              ,DSMENSAGEM_ACAO_BANNER    = DECODE(pr_inexibe_msg_confirmacao,1,pr_dsmensagem_acao_banner,NULL)
              ,TPFILTRO                  = pr_tpfiltro
              ,INEXIBIR_QUANDO           = pr_inexibir_quando
              ,DTEXIBIR_DE               = DECODE(pr_inexibir_quando,1,vr_dtexibir_de,NULL)
              ,DTEXIBIR_ATE              = DECODE(pr_inexibir_quando,1,vr_dtexibir_ate,NULL)
        WHERE CDBANNER = vr_cdbanner
        AND   CDCANAL  = pr_cdcanal;   
       exception
        WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro (TBGEN_BANNER) - ' || vr_seq_banner || '. Erro: ' || SQLERRM;
         RAISE;                                     
      END;
      --
      begin
        DELETE FROM  TBGEN_BANNER_FILTRO_GENERICO
         WHERE CDBANNER = vr_cdbanner
        AND   CDCANAL   = pr_cdcanal;
       exception
        WHEN OTHERS THEN
         vr_dscritic := 'Erro ao atualizar registro (TBGEN_BANNER_FILTRO_GENERICO) ' || '. Erro: ' || SQLERRM;
         RAISE;                                     
      end;
      
       --
      if pr_tpfiltro = 0 then
        begin
          insert into TBGEN_BANNER_FILTRO_GENERICO(CDBANNER
                                                  ,CDCANAL
                                                  ,DSFILTRO_COOPERATIVAS
                                                  ,DSFILTRO_TIPOS_CONTA
                                                  ,INOUTROS_FILTROS
                                                  ,DSFILTRO_PRODUTO)
                                            values(vr_cdbanner
                                                  ,pr_cdcanal
                                                  ,pr_dsfiltro_cooperativas
                                                  ,pr_dsfiltro_tipos_conta
                                                  ,pr_inoutros_filtros
                                                  ,pr_dsfiltro_produto);
          
        exception
          WHEN OTHERS THEN
             vr_dscritic := 'Erro ao inserir registro (TBGEN_BANNER_FILTRO_GENERICO) - ' || vr_seq_banner || '. Erro: ' || SQLERRM;
             RAISE;  
        end;
      ELSIF pr_tpfiltro = 1 then
        NULL;
      end if;
    end if;
    
    
    
                        
  EXCEPTION
      WHEN OTHERS THEN
        IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        ELSE  -- Senão, Dispara a EXCEPTION padrão
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' - '|| SQLERRM;
        END IF;

        -- Carregar XML padrão para variável de retorno não utilizada.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;  
  END;
  --
  PROCEDURE pc_deletar_banner(pr_cdbanner                in TBGEN_BANNER.CDBANNER%TYPE
                             ,pr_cdcanal                 in TBGEN_BANNER.CDCANAL%TYPE
                             ,pr_xmllog                  IN VARCHAR2           --> XML com informações de LOG
                             ,pr_cdcritic                OUT PLS_INTEGER       --> Código da crítica
                             ,pr_dscritic                OUT VARCHAR2          --> Descrição da crítica
                             ,pr_retxml                  IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                             ,pr_nmdcampo                OUT VARCHAR2          --> Nome do campo com erro
                             ,pr_des_erro                OUT VARCHAR2) IS      --> Erros do processo
  
    vr_exc_erro EXCEPTION;                        
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);
    --
    vr_existe_banner    VARCHAR2(1);
    --
    vr_dsbannerorder    tbgen_banner_param.dsbannerorder%TYPE;
    --
    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
  BEGIN
    --
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
    --                        
    BEGIN
      SELECT 'X'
      INTO   vr_existe_banner
      FROM   tbgen_banner tbba
      WHERE  tbba.cdbanner = pr_cdbanner
      AND    tbba.cdcanal  = pr_cdcanal;
      
      -- Deleta o banner
      DELETE FROM tbgen_banner
      WHERE  cdbanner = pr_cdbanner
      AND    cdcanal  = pr_cdcanal;
      -- Deleta o filtro generico do banner
      DELETE FROM tbgen_banner_filtro_generico
      WHERE  cdbanner = pr_cdbanner
      AND    cdcanal  = pr_cdcanal;
      -- Deleta o filtro especifico do banner
      DELETE FROM tbgen_banner_filtro_especifico
      WHERE  cdbanner = pr_cdbanner
      AND    cdcanal  = pr_cdcanal;
      
      -- Atualiza ordenamento dos banners
      UPDATE tbgen_banner_param
      SET    dsbannerorder = CASE WHEN length(REPLACE(dsbannerorder,pr_cdbanner||',','')) <> length(dsbannerorder) THEN 
                               REPLACE(dsbannerorder,pr_cdbanner||',','')
                             ELSE
                               REPLACE(dsbannerorder,pr_cdbanner,'0')
                             END
      WHERE  cdcanal       = pr_cdcanal;
      --Remove a virgula no final da coluna de ordenamento
      UPDATE tbgen_banner_param
      SET    dsbannerorder = SUBSTR(dsbannerorder,1,LENGTH(dsbannerorder)-1)
      WHERE  substr(dsbannerorder,LENGTH(dsbannerorder)) = ',';
      
    EXCEPTION
      WHEN no_data_found THEN
        vr_dscritic := 'Banner não encontrado!';
        RAISE;
      WHEN OTHERS THEN
        vr_dscritic := 'Houve um erro ao remover o banner. Erro: '||SQLERRM;
        RAISE;    
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' - '|| SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;  
  END;  

  PROCEDURE pc_busca_telas_mobile(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo 
      
    -- Cursor para buscar a situação da mensagem
    CURSOR cr_menumobile IS
     SELECT men.menumobileid AS menumobileid
           ,replace(NVL2(men.menupaiid, pai.nome || ' - ','') || men.nome,'–','-') AS nome
       FROM menumobile men
           ,menumobile pai
      WHERE men.menupaiid = pai.menumobileid(+)
        AND NOT EXISTS (SELECT 1 FROM menumobile sub
                         WHERE sub.menupaiid = men.menumobileid) -- Somente menus que não possuem filhos (itens clicáveis)
      ORDER BY NVL(pai.sequencia, men.sequencia)
                  ,men.sequencia;

    rw_menumobile cr_menumobile%ROWTYPE;
       
    --Variáveis
    ex_erro EXCEPTION;
      
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
      
    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'telas', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    FOR rw_menumobile IN cr_menumobile LOOP

      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'telas', pr_posicao => 0, pr_tag_nova => 'tela', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tela', pr_posicao => vr_contador, pr_tag_nova => 'menumobileid', pr_tag_cont => rw_menumobile.menumobileid, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'tela', pr_posicao => vr_contador, pr_tag_nova => 'nome', pr_tag_cont => rw_menumobile.nome, pr_des_erro => vr_dscritic);
      vr_contador := vr_contador + 1;
              
    END LOOP;    

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_busca_telas_mobile;
  --
  FUNCTION fn_busca_parametro_mobile(pr_parametroid    IN parametromobile.parametromobileid%TYPE) RETURN VARCHAR2 IS
    
    vr_valor_parametro     parametromobile.valor%TYPE;
  BEGIN
    
    SELECT pamo.valor
    INTO   vr_valor_parametro
    FROM   parametromobile pamo
    WHERE  pamo.parametromobileid = pr_parametroid;
      
    RETURN vr_valor_parametro;
      
  END;
  --
  PROCEDURE pc_insupd_banner_param(pr_cdcanal                 tbgen_banner_param.cdcanal%TYPE
                                  ,pr_dsurlserver             tbgen_banner_param.dsurlserver%TYPE
                                  ,pr_dsbannerorder           tbgen_banner_param.dsbannerorder%TYPE
                                  ,pr_intransicao             tbgen_banner_param.intransicao%TYPE
                                  ,pr_nrsegundos_transicao    tbgen_banner_param.nrsegundos_transicao%TYPE) IS
  
    vr_existe_banner_param     VARCHAR2(1);  
  
  BEGIN
    
    IF pr_intransicao = 1 AND pr_nrsegundos_transicao IS NULL THEN
      RAISE_APPLICATION_ERROR(-20100,'Segundos de transição é obrigatório!');
    END IF; 
    
    BEGIN
      SELECT 'x'
      INTO   vr_existe_banner_param
      FROM   TBGEN_BANNER_PARAM tbbp
      WHERE  tbbp.cdcanal     = pr_cdcanal;
     
      UPDATE TBGEN_BANNER_PARAM
      SET    INTRANSICAO            = pr_intransicao
            ,NRSEGUNDOS_TRANSICAO   = pr_nrsegundos_transicao
            ,DSBANNERORDER          = pr_dsbannerorder
      WHERE  CDCANAL  = pr_cdcanal;  
       
      
    EXCEPTION
      WHEN no_data_found THEN
        INSERT INTO TBGEN_BANNER_PARAM(CDCANAL
                                    ,DSURLSERVER
                                    ,DSBANNERORDER
                                    ,INTRANSICAO
                                    ,NRSEGUNDOS_TRANSICAO)
                              VALUES(pr_cdcanal
                                    ,pr_dsurlserver
                                    ,pr_dsbannerorder
                                    ,pr_intransicao
                                    ,pr_nrsegundos_transicao);
    END;  
  END pc_insupd_banner_param;
  ---
  PROCEDURE pc_dados_acesso_server_imagem(pr_cdcanal  tbgen_banner_param.cdcanal%TYPE
										 ,pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2) IS      --> Erros do processo) IS

    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(10000);

    -- Variaveis de log
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    vr_contador NUMBER(10);
    vr_user_urlserver VARCHAR(500);
	  vr_pwd_urlserver VARCHAR(500);

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

    gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'parametro', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);

    -- Obtém os dados dos parametros
	begin
	
		SELECT 
		   NMUSUARIO_IMAGESERVER,
		   CDDSENHA_IMAGESERVER
		   INTO vr_user_urlserver, vr_pwd_urlserver
		FROM TBGEn_BANNER_PARAM
		WHERE CDCANAL = pr_cdcanal; 

    exception
      when others then
        vr_dscritic := 'Não foi possivel localizar o dado de acesso ao servidor de imagem. - '||' Erro: '||sqlerrm;
    end;
    -- 
	  
	-- Gera o XML do PARAMETRO
	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => 0, pr_tag_nova => 'dsuser_urlserver', pr_tag_cont => vr_user_urlserver, pr_des_erro => vr_dscritic); 
	gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'parametro', pr_posicao => 0, pr_tag_nova => 'dspwd_urlserver', pr_tag_cont => vr_pwd_urlserver, pr_des_erro => vr_dscritic);

  EXCEPTION
    WHEN OTHERS THEN
      IF vr_cdcritic <> 0 THEN -- Tenta pegar a exception pelo CDCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSIF vr_dscritic IS NOT NULL THEN -- Tenta pegar a exception pelo DSCRITIC
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      ELSE  -- Senão, Dispara a EXCEPTION padrão
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||': ' || SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_dados_acesso_server_imagem;
  --
END;
/
