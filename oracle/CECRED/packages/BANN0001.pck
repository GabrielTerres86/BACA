CREATE OR REPLACE PACKAGE CECRED.BANN0001 IS

PROCEDURE pc_consulta_banner(pr_cdcooper     IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_nrdconta     IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                            ,pr_idseqttl     IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                            ,pr_cdcanal      IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                            ,pr_xml_ret     OUT CLOB --> Retorno XML
                             );

END BANN0001;
/
/*
Alterações:

31/01/2019 - INC0031835 Melhoria do exists do cursor cur_banner (Carlos)
*/
CREATE OR REPLACE PACKAGE BODY CECRED.BANN0001 IS

  PROCEDURE pc_consulta_banner(pr_cdcooper     IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                              ,pr_nrdconta     IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                              ,pr_idseqttl     IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                              ,pr_cdcanal      IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                              ,pr_xml_ret     OUT CLOB --> Retorno XML
                               ) IS
                               
    -- Seleciona o Banner
    CURSOR cur_banner(pcur_tipo_pessoa    IN NUMBER
                     ,pcur_produto        IN NUMBER) IS
      SELECT tban.cdbanner
            ,tban.cdcanal
            ,tban.dstitulo_banner AS titulo
            ,tbpa.dsurlserver||tban.nmimagem_banner AS imagem
            ,tban.inacao_banner
            ,decode(tban.inacao_banner,0,null,tban.cdmenu_acao_mobile) cdmenu_acao_mobile
            ,decode(tban.inacao_banner,0,null,tban.dslink_acao_banner) dslink_acao_banner
            ,tban.inexibe_msg_confirmacao
            ,decode(tban.inexibe_msg_confirmacao,0,null,tban.dsmensagem_acao_banner) dsmensagem_acao_banner
      FROM   TBGEN_BANNER tban
            ,TBGEN_BANNER_PARAM tbpa
            ,(with t as (select p.dsbannerorder as str from dual,tbgen_banner_param p WHERE p.cdcanal = pr_cdcanal)
              --
              select level as seqbanner, regexp_substr(str,'[^,]+',1,level) as cdbanner
              from   t
              connect by regexp_substr(str,'[^,]+',1,level) is not null) ordembanner 
      WHERE  1=1
      AND    tban.cdcanal  = pr_cdcanal  
      AND    tbpa.cdcanal  = tban.cdcanal   
      AND    tban.insituacao_banner = 1 -- ativo
      AND    ((tban.inexibir_quando = 1 AND trunc(tban.dtexibir_de) <= trunc(SYSDATE) AND trunc(tban.dtexibir_ate) >= trunc(SYSDATE)) OR
              (tban.inexibir_quando = 0))
      AND    EXISTS (
                     SELECT 1 -- filtro generico
                     FROM    TBGEN_BANNER_FILTRO_GENERICO tbfg
                     WHERE   tbfg.cdbanner = tban.cdbanner
                     AND     tbfg.cdcanal  = tban.cdcanal
                     AND tban.tpfiltro = 0
                     AND pr_cdcooper IN (SELECT regexp_substr(tbfg.dsfiltro_cooperativas, '[^,]+', 1, LEVEL)
                                         FROM dual
                                         CONNECT BY regexp_substr(tbfg.dsfiltro_cooperativas,'[^,]+',1,LEVEL) IS NOT NULL) -- cooperativa
                     AND pcur_tipo_pessoa IN (SELECT regexp_substr(tbfg.dsfiltro_tipos_conta, '[^,]+', 1, LEVEL)
                                              FROM dual
                                              CONNECT BY regexp_substr(tbfg.dsfiltro_tipos_conta,'[^,]+',1,LEVEL) IS NOT NULL) -- tipo de pessoa
                     AND ((tbfg.inoutros_filtros = 1 AND tbfg.dsfiltro_produto = 35 AND pcur_produto = 1) OR (tbfg.inoutros_filtros = 0))
                     UNION
                     SELECT 1 -- arquivo csv
                     FROM    TBGEN_BANNER_FILTRO_ESPECIFICO tbfe
                     WHERE   tbfe.cdbanner = tban.cdbanner
                     AND     tbfe.cdcanal  = tban.cdcanal
                     AND tban.tpfiltro = 1
                     AND     tbfe.cdcooper  = pr_cdcooper
                     AND     tbfe.nrdconta  = pr_nrdconta
                     AND (tbfe.idseqttl = pr_idseqttl OR tbfe.idseqttl IS NULL)
                     )
      AND    ordembanner.cdbanner = tban.cdbanner
      ORDER BY ordembanner.seqbanner;
    
    CURSOR cur_preaprovado IS
    SELECT 1
      FROM crapcpa              cpa
          ,tbepr_carga_pre_aprv car
          ,tbepr_param_conta    par
     WHERE cpa.iddcarga = car.idcarga
       AND cpa.cdcooper = par.cdcooper(+)
       AND cpa.nrdconta = par.nrdconta(+)
       AND car.indsituacao_carga = 1 -- Gerada
       AND car.flgcarga_bloqueada = 0 -- Liberada
       AND (car.dtfinal_vigencia IS NULL OR car.dtfinal_vigencia >= TRUNC(SYSDATE)) -- Vigente
       AND NVL(par.flglibera_pre_aprv, 1) = 1 -- Valida se Pré-Aprovado está liberado para a conta específica
       AND cpa.cdcooper = pr_cdcooper
       AND cpa.nrdconta = pr_nrdconta;
    -- Variaveis de XML
    vr_xml_tmp VARCHAR2(32767);
    --
    vr_exc_erro EXCEPTION;                        
    vr_dscritic VARCHAR2(10000);
    --
    vr_intransicao                 tbgen_banner_param.intransicao%TYPE;
    vr_nrsegundos_transicao        tbgen_banner_param.nrsegundos_transicao%TYPE;
    --
    vr_tipo_pessoa                 CRAPASS.Inpessoa%TYPE;
    vr_pre_aprovado                NUMBER:=0;
  BEGIN
    --
    --Busca o código do tipo de pessoa
    BEGIN
      SELECT crap.INPESSOA
      INTO   vr_tipo_pessoa
      FROM   CRAPASS crap
      WHERE  1=1
        AND    crap.nrdconta = pr_nrdconta
        AND    crap.cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN no_data_found THEN
        vr_tipo_pessoa := 0; 
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel localizar o tipo de pessoa. Erro: '||SQLERRM;
        RAISE;                            
    END;
    -- Verifica se o usuário tem crédito pre-aprovado
    BEGIN
       OPEN cur_preaprovado;
       FETCH cur_preaprovado
       INTO vr_pre_aprovado;
       CLOSE cur_preaprovado;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel verificar se o cooperado tem crédito pré-aprovado. Erro: '||SQLERRM;
        RAISE;  
    END;
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
  
    -- Abrir a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<BANNERS>');
  
    FOR rw_banner IN cur_banner(vr_tipo_pessoa
                               ,vr_pre_aprovado) LOOP
      -- Insere dados
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                             ,pr_texto_completo => vr_xml_tmp
                             ,pr_texto_novo     => '<BANNER>' ||
                                                      '<codigo>'           || rw_banner.cdbanner || '</codigo>' ||
                                                      '<titulo>'           || rw_banner.titulo || '</titulo>' ||
                                                      '<imagem>'         || rw_banner.imagem || '</imagem>' ||
                                                      '<inacaobanner>'         || rw_banner.inacao_banner || '</inacaobanner>' ||
                                                      '<acaobanner>' ||
                                                        '<idmenu>'     || rw_banner.cdmenu_acao_mobile || '</idmenu>' ||
                                                        '<urllink>'    || rw_banner.dslink_acao_banner || '</urllink>' ||
                                                        '<mensagem>'   || rw_banner.dsmensagem_acao_banner || '</mensagem>' ||
                                                      '</acaobanner>' ||
                                                   '</BANNER>');
    END LOOP;
    
     -- Fechar a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '</BANNERS>'
                           );
                           
    BEGIN
      SELECT tbpa.intransicao
            ,tbpa.nrsegundos_transicao
      INTO   vr_intransicao
            ,vr_nrsegundos_transicao
      FROM   tbgen_banner_param tbpa
      WHERE  tbpa.cdcanal    = pr_cdcanal;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao localizar parametros do banner. Erro: '||SQLERRM;
        RAISE;
    END;
                           
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<intransicao>' || vr_intransicao || '</intransicao>' ||
                                                 '<nrsegundos_transicao>'||vr_nrsegundos_transicao||'</nrsegundos_transicao>'
                           ,pr_fecha_xml      => TRUE);
      
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao buscar os banners.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
  END;                             
                               
END BANN0001;
/
