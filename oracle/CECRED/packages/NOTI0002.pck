CREATE OR REPLACE PACKAGE CECRED.NOTI0002 IS

  -- Author  : Pablão
  -- Created : 19/10/2017 10:04:24
  -- Purpose : Pachage com todas as procedures relacionadas à configuração e visualização das notificações no Cecred Mobile e Internet Bank
  
  -- Quantidade de notificações não visualizadas pelo cooperado
  PROCEDURE pc_qtd_notif_nao_visualizadas(pr_cdcooper IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                         ,pr_idseqttl IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                         ,pr_cdcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                         ,pr_xml_ret OUT CLOB --> Retorno XML
                                          );

  -- Consulta as notificações do cooperado
  PROCEDURE pc_consulta_notificacoes(pr_cdcooper     IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                    ,pr_idseqttl     IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                    ,pr_pesquisa     IN VARCHAR2 --> Texto pesquisado
                                    ,pr_reginicial   IN NUMBER --> Índice do primeiro registro à buscar (paginação)
                                    ,pr_qtdregistros IN NUMBER --> Contagem de registros à serem buscados
                                    ,pr_cdcanal      IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                    ,pr_xml_ret     OUT CLOB --> Retorno XML
                                     );

  -- Obtem os detalhes de uma notificação
  PROCEDURE pc_obtem_detalhes_notificacao(pr_cdcooper      IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta      IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                         ,pr_idseqttl      IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                         ,pr_cdnotificacao IN tbgen_notificacao.cdnotificacao%TYPE -- Código da notificacao
                                         ,pr_cdcanal       IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                         ,pr_xml_ret      OUT CLOB --> Retorno XML
                                          );

  -- Obtém as configurações de recebimento de push
  PROCEDURE pc_obtem_config_receb_push(pr_cdcooper IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                      ,pr_idseqttl IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                      ,pr_cdcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                      ,pr_xml_ret OUT CLOB --> Retorno XML
                                       );

  -- Altera as configurações de recebimento de push
  PROCEDURE pc_altera_config_receb_push(pr_cdcooper            IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta            IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                       ,pr_idseqttl            IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                       ,pr_dispositivomobileid IN dispositivomobile.dispositivomobileid%TYPE --> ID do dispositivo
                                       ,pr_recbpush            IN NUMBER --> Indicador se dispositivo recebe Push Notification
                                       ,pr_chavedsp            IN VARCHAR2 --> Chave do dispositivo para recebimento de Push Notification
                                       ,pr_lstconfg            IN VARCHAR2 --> Lista com todas as origens e situação de push (ativo/inativo). Formato: "origem1-ind;origem2-ind". Exemplo: "1-0;2-1;3-0"
                                       ,pr_cdcanal             IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                       ,pr_xml_ret            OUT CLOB --> Retorno XML
                                        );
END NOTI0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NOTI0002 IS

  PROCEDURE pc_qtd_notif_nao_visualizadas(pr_cdcooper IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                         ,pr_idseqttl IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                         ,pr_cdcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                         ,pr_xml_ret OUT CLOB --> Retorno XML
                                          ) IS
  
    --Cursor que busca a lista de notificações
    CURSOR cr_notificacoes IS
    SELECT COUNT(1) qtdnaovisualizadas
      FROM tbgen_notificacao noti
     WHERE noti.dhvisualizacao IS NULL
       AND noti.dhenvio <= SYSDATE
       AND noti.cdcooper = pr_cdcooper
       AND noti.nrdconta = pr_nrdconta
       AND noti.idseqttl = pr_idseqttl;
    rw_notificacoes cr_notificacoes%ROWTYPE;
  
    -- Variaveis de XML
    vr_xml_tmp VARCHAR2(32767);
  
    -- Variáveis de Exceção
    vr_dscritic VARCHAR2(1000);
    vr_exception EXCEPTION;
  
  BEGIN
    
    OPEN cr_notificacoes;
    FETCH cr_notificacoes
    INTO rw_notificacoes;
    CLOSE cr_notificacoes;
    
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
    
    -- Quando for o último registro indica que esta é a última pagina
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<qtdnaovisualizadas>' ||
                                                   rw_notificacoes.qtdnaovisualizadas ||
                                                 '</qtdnaovisualizadas>'
                           ,pr_fecha_xml      => TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao buscar as notificações.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
    
  END pc_qtd_notif_nao_visualizadas;

  PROCEDURE pc_consulta_notificacoes(pr_cdcooper     IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_nrdconta     IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                    ,pr_idseqttl     IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                    ,pr_pesquisa     IN VARCHAR2 --> Texto pesquisado
                                    ,pr_reginicial   IN NUMBER --> Índice do primeiro registro à buscar (paginação)
                                    ,pr_qtdregistros IN NUMBER --> Contagem de registros à serem buscados
                                    ,pr_cdcanal      IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                    ,pr_xml_ret     OUT CLOB --> Retorno XML
                                     ) IS
  
    --Cursor que busca a lista de notificações
    CURSOR cr_notificacoes IS
      SELECT *
        FROM (SELECT noti.cdnotificacao
                    ,mens.dstitulo_mensagem
                    ,noti0001.fn_substitui_variaveis(noti.cdcooper
                                                    ,noti.nrdconta
                                                    ,noti.idseqttl
                                                    ,mens.dstexto_mensagem
                                                    ,noti.dsvariaveis) dstexto_mensagem
                    ,to_char(noti.dhenvio, 'yyyy-MM-dd HH24:MI:SS') dhenvio
                    ,to_char(noti.dhenvio ,'DD MON','nls_date_language =''brazilian portuguese''') dhenviofmt
                    ,NVL2(noti.dhleitura, 1, 0) indicadorlida
                    ,icon.nmimagem_lida nomeiconelida
                    ,icon.nmimagem_naolida nomeiconenaolida
                    ,row_number() OVER(ORDER BY noti.dhenvio DESC, noti.cdnotificacao DESC) indiceregistro -- Índice utilizado para paginação
                    ,COUNT(1) OVER() totalregistros -- Quantidade total de registros
                FROM tbgen_notificacao        noti
                    ,tbgen_notif_msg_cadastro mens
                    ,tbgen_notif_icone        icon
               WHERE noti.cdmensagem = mens.cdmensagem
                 AND mens.cdicone = icon.cdicone
                 AND noti.cdcooper = pr_cdcooper
                 AND noti.nrdconta = pr_nrdconta
                 AND noti.idseqttl = pr_idseqttl
                 AND (TRIM(pr_pesquisa) IS NULL -- Parãmetro de pesquisa
                     OR gene0007.fn_caract_acento(UPPER(mens.dstitulo_mensagem)) LIKE '%' || gene0007.fn_caract_acento(UPPER(pr_pesquisa)) || '%'
                     OR gene0007.fn_caract_acento(UPPER(noti0001.fn_substitui_variaveis(noti.cdcooper
                                                                                       ,noti.nrdconta
                                                                                       ,noti.idseqttl
                                                                                       ,mens.dstexto_mensagem
                                                                                       ,noti.dsvariaveis))) LIKE
                                                       '%' || gene0007.fn_caract_acento(UPPER(pr_pesquisa)) || '%')
                 AND noti.dhenvio <= SYSDATE -- Mensagens > sysdate são Agendamentos e não devem ser exibidas ainda
               ORDER BY dhenvio            DESC
                       ,noti.cdnotificacao DESC)
       WHERE indiceregistro BETWEEN pr_reginicial AND
             pr_reginicial + pr_qtdregistros - 1; -- Controle de paginação
  
    vr_ultimoindice   NUMBER(10) := 0;
    vr_totalregistros NUMBER(10) := 0;
  
    -- Variaveis de XML
    vr_xml_tmp VARCHAR2(32767);
  
    -- Variáveis de Exceção
    vr_dscritic VARCHAR2(1000);
    vr_exception EXCEPTION;
  
  BEGIN
  
    -- Atualiza data da visualização da notificação (se ainda não foi visualizada)
    UPDATE tbgen_notificacao noti
       SET noti.dhvisualizacao = SYSDATE
     WHERE noti.cdcooper = pr_cdcooper
       AND noti.nrdconta = pr_nrdconta
       AND noti.idseqttl = pr_idseqttl
       AND noti.dhvisualizacao IS NULL; -- Somente se não possui data de visualização
       
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
  
    -- Abrir a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<NOTIFICACOES>');
  
    FOR rw_notificacao IN cr_notificacoes LOOP
      -- Insere dados
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                             ,pr_texto_completo => vr_xml_tmp
                             ,pr_texto_novo     => '<NOTIFICACAO>' ||
                                                      '<codigo>'           || rw_notificacao.cdnotificacao || '</codigo>' ||
                                                      '<titulo>'           || rw_notificacao.dstitulo_mensagem || '</titulo>' ||
                                                      '<mensagem>'         || rw_notificacao.dstexto_mensagem || '</mensagem>' ||
                                                      '<dataenvio>'        || rw_notificacao.dhenvio || '</dataenvio>' ||
                                                      '<dataenviofmt>'     || rw_notificacao.dhenviofmt || '</dataenviofmt>' ||
                                                      '<indicadorlida>'    || rw_notificacao.indicadorlida || '</indicadorlida>' ||
                                                      '<indiceregistro>'   || rw_notificacao.indiceregistro || '</indiceregistro>' ||
                                                      '<nomeiconelida>'    || rw_notificacao.nomeiconelida || '</nomeiconelida>' ||
                                                      '<nomeiconenaolida>' || rw_notificacao.nomeiconenaolida || '</nomeiconenaolida>' ||
                                                   '</NOTIFICACAO>');
    
      vr_totalregistros := rw_notificacao.totalregistros;
      vr_ultimoindice := rw_notificacao.indiceregistro;
    
    END LOOP;
  
    -- Fechar a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '</NOTIFICACOES>');
  
    -- Quando for o último registro indica que esta é a última pagina
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<indicadorultimapagina>' ||
                                                   CASE vr_ultimoindice WHEN vr_totalregistros THEN 1 ELSE 0 END ||
                                                 '</indicadorultimapagina>');
  
    -- Armazena o contador total
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<totalregistros>' || vr_totalregistros || '</totalregistros>'
                           ,pr_fecha_xml      => TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao buscar as notificações.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
    
  END pc_consulta_notificacoes;

  PROCEDURE pc_obtem_detalhes_notificacao(pr_cdcooper      IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                         ,pr_nrdconta      IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                         ,pr_idseqttl      IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                         ,pr_cdnotificacao IN tbgen_notificacao.cdnotificacao%TYPE -- Código da notificacao
                                         ,pr_cdcanal       IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                         ,pr_xml_ret      OUT CLOB --> Retorno XML
                                          ) IS
  
    --Cursor que busca a lista de notificações
    CURSOR cr_notificacao IS
      SELECT noti.cdnotificacao
            ,mens.dstitulo_mensagem
            ,noti0001.fn_substitui_variaveis(noti.cdcooper
                                            ,noti.nrdconta
                                            ,noti.idseqttl
                                            ,mens.dstexto_mensagem
                                            ,noti.dsvariaveis) dstexto_mensagem
            ,REPLACE(REPLACE(noti0001.fn_substitui_variaveis(noti.cdcooper
                                                            ,noti.nrdconta
                                                            ,noti.idseqttl
                                                            ,mens.dshtml_mensagem
                                                            ,noti.dsvariaveis)
                            ,CHR(10),''),CHR(13),'') dshtml_mensagem
            ,to_char(noti.dhenvio, 'yyyy-MM-dd HH24:MI:SS') dhenvio
            ,to_char(noti.dhenvio,'DD MON','nls_date_language =''brazilian portuguese''') dhenviofmt
            ,NVL2(noti.dhleitura, 1, 0) indicadorlida
            ,icon.nmimagem_lida nomeiconelida
            ,icon.nmimagem_naolida nomeiconenaolida
            ,mens.nmimagem_banner
            ,mens.inexibir_banner
            ,mens.inexibe_botao_acao_mobile
            ,mens.dstexto_botao_acao_mobile
            ,mens.cdmenu_acao_mobile
            ,mens.dslink_acao_mobile
            ,mens.dsmensagem_acao_mobile
            ,noti0001.fn_substitui_variaveis(noti.cdcooper
                                            ,noti.nrdconta
                                            ,noti.idseqttl
                                            ,mens.dsparam_acao_mobile
                                            ,noti.dsvariaveis) dsparam_acao_mobile
        FROM tbgen_notificacao        noti
            ,tbgen_notif_msg_cadastro mens
            ,tbgen_notif_icone        icon
       WHERE noti.cdmensagem = mens.cdmensagem
         AND mens.cdicone = icon.cdicone
         AND noti.cdnotificacao = pr_cdnotificacao
         AND noti.cdcooper = pr_cdcooper -- Filtra coop/conta apenas para garantir a pessoa que acessou a notificação é a dona da conta
         AND noti.nrdconta = pr_nrdconta
         AND noti.idseqttl = pr_idseqttl;
    rw_notificacao       cr_notificacao%ROWTYPE;
    cr_notificacao_found BOOLEAN := FALSE;
  
    -- Variaveis de XML
    vr_xml_tmp VARCHAR2(32767);
  
    -- Variáveis de Exceção
    vr_dscritic VARCHAR2(1000);
    vr_exception EXCEPTION;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
  
    -- Atualiza data da leitura da notificação (se ainda não foi lida)
    UPDATE tbgen_notificacao noti
       SET noti.dhleitura = SYSDATE
          ,noti.cdcanal_leitura = pr_cdcanal
     WHERE noti.cdnotificacao = pr_cdnotificacao
       AND noti.cdcooper = pr_cdcooper -- Filtra coop/conta apenas para garantir a pessoa que acessou a notificação é a dona da conta
       AND noti.nrdconta = pr_nrdconta
       AND noti.idseqttl = pr_idseqttl
       AND noti.dhleitura IS NULL; -- Somente se não possui data de leitura
  
    OPEN cr_notificacao;
    FETCH cr_notificacao
      INTO rw_notificacao;
    cr_notificacao_found := cr_notificacao%FOUND;
    CLOSE cr_notificacao;
  
    -- Se não encontrou, dispara exceção
    IF NOT cr_notificacao_found THEN
      vr_dscritic := 'Notificação não encontrada';
      RAISE vr_exception;
    END IF;
  
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<NOTIFICACAO>' ||
                                                    '<codigo>'               || rw_notificacao.cdnotificacao || '</codigo>' ||
                                                    '<titulo>'               || rw_notificacao.dstitulo_mensagem || '</titulo>' ||
                                                    '<mensagem>'             || rw_notificacao.dstexto_mensagem || '</mensagem>' ||
                                                    /*Envolve o HTML em uma tag CDATA para não ocorrer erro no XML*/
                                                    '<conteudohtml>'         || '<![CDATA[<html><body>' || rw_notificacao.dshtml_mensagem || '</body></html>]]>' || '</conteudohtml>' ||
                                                    '<dataenvio>'            || rw_notificacao.dhenvio || '</dataenvio>' ||
                                                    '<dataenviofmt>'         || rw_notificacao.dhenviofmt || '</dataenviofmt>' ||
                                                    '<indicadorlida>'        || rw_notificacao.indicadorlida || '</indicadorlida>' ||
                                                    '<nomeiconelida>'        || rw_notificacao.nomeiconelida || '</nomeiconelida>' ||
                                                    '<nomeiconenaolida>'     || rw_notificacao.nomeiconenaolida || '</nomeiconenaolida>' ||
                                                    '<indicadorexibebanner>' || rw_notificacao.inexibir_banner || '</indicadorexibebanner>' ||
                                                    '<nomeimagembanner>'     || rw_notificacao.nmimagem_banner || '</nomeimagembanner>' ||
                                                    '<indicadorexibebotaoacao>' || rw_notificacao.inexibe_botao_acao_mobile || '</indicadorexibebotaoacao>' ||
                                                    '<botaoacaomobile>' ||
                                                        '<texto>'      || rw_notificacao.dstexto_botao_acao_mobile || '</texto>' ||
                                                        '<idmenu>'     || rw_notificacao.cdmenu_acao_mobile || '</idmenu>' ||
                                                        '<urllink>'    || rw_notificacao.dslink_acao_mobile || '</urllink>' ||
                                                        '<mensagem>'   || rw_notificacao.dsmensagem_acao_mobile || '</mensagem>' ||
                                                        '<parametros>' || rw_notificacao.dsparam_acao_mobile || '</parametros>' ||
                                                    '</botaoacaomobile>' ||
                                                 '</NOTIFICACAO>'
                           ,pr_fecha_xml      => TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao buscar os detalhes da notificação.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
    
  END pc_obtem_detalhes_notificacao;

  PROCEDURE pc_obtem_config_receb_push(pr_cdcooper IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                      ,pr_nrdconta IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                      ,pr_idseqttl IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                      ,pr_cdcanal  IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                      ,pr_xml_ret OUT CLOB --> Retorno XML
                                       ) IS
  
    --Cursor que busca a lista de notificações
    CURSOR cr_notificacoes IS
      SELECT tip.cdtipo_mensagem
            ,tip.dstipo_mensagem
            ,ori.cdorigem_mensagem
            ,ori.dsorigem_mensagem
            ,NVL(prm.inpush_ativo, 1) inpush_ativo
            ,DECODE(row_number() OVER(PARTITION BY tip.cdtipo_mensagem ORDER BY ori.cdorigem_mensagem), 1, 1, 0) inicio_tipo
            ,DECODE(row_number() OVER(PARTITION BY tip.cdtipo_mensagem ORDER BY ori.cdorigem_mensagem DESC), 1, 1, 0) fim_tipo
        FROM tbgen_notif_msg_tipo      tip
            ,tbgen_notif_msg_origem    ori
            ,tbgen_notif_push_orig_prm prm
       WHERE ori.cdtipo_mensagem = tip.cdtipo_mensagem
         AND ori.cdorigem_mensagem = prm.cdorigem_mensagem(+)
         AND prm.cdcooper(+) = pr_cdcooper
         AND prm.nrdconta(+) = pr_nrdconta
         AND prm.idseqttl(+) = pr_idseqttl
       ORDER BY tip.cdtipo_mensagem
               ,ori.cdorigem_mensagem;
  
    -- Variaveis de XML
    vr_xml_tmp VARCHAR2(32767);
  
    -- Variáveis de Exceção
    vr_dscritic VARCHAR2(1000);
    vr_exception EXCEPTION;
  
  BEGIN
  
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
  
    -- Abrir a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '<TIPOSNOTIFICACAO>');
  
    FOR rw_notificacao IN cr_notificacoes LOOP
    
      --Abre a tag <TIPO>
      IF rw_notificacao.inicio_tipo = 1 THEN
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                               ,pr_texto_completo => vr_xml_tmp
                               ,pr_texto_novo     => '<TIPO>' ||
                                                         '<codigo>' || rw_notificacao.cdtipo_mensagem || '</codigo>' ||
                                                         '<descricao>' || rw_notificacao.dstipo_mensagem || '</descricao>' ||
                                                     '<ORIGENSNOTIFICACAO>');
      END IF;
    
      -- Insere dados
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                             ,pr_texto_completo => vr_xml_tmp
                             ,pr_texto_novo     => '<ORIGEM>' ||
                                                      '<codigo>'    || rw_notificacao.cdorigem_mensagem || '</codigo>' ||
                                                      '<descricao>' || rw_notificacao.dsorigem_mensagem || '</descricao>' ||
                                                      '<idpushhabilitado>' || rw_notificacao.inpush_ativo || '</idpushhabilitado>' ||
                                                   '</ORIGEM>');
    
      --Fecha a tag <TIPO>
      IF rw_notificacao.fim_tipo = 1 THEN
        gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                               ,pr_texto_completo => vr_xml_tmp
                               ,pr_texto_novo     => '</ORIGENSNOTIFICACAO></TIPO>');
      END IF;
    
    END LOOP;
  
    -- Fechar a tag NOTIFICACOES
    gene0002.pc_escreve_xml(pr_xml            => pr_xml_ret
                           ,pr_texto_completo => vr_xml_tmp
                           ,pr_texto_novo     => '</TIPOSNOTIFICACAO>'
                           ,pr_fecha_xml      => TRUE);
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao buscar as configurações do push.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
    
  END pc_obtem_config_receb_push;

  PROCEDURE pc_altera_config_receb_push(pr_cdcooper            IN tbgen_notificacao.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta            IN tbgen_notificacao.nrdconta%TYPE --> Numero da conta
                                       ,pr_idseqttl            IN tbgen_notificacao.idseqttl%TYPE --> Sequencial titular
                                       ,pr_dispositivomobileid IN dispositivomobile.dispositivomobileid%TYPE --> ID do dispositivo
                                       ,pr_recbpush            IN NUMBER --> Indicador se dispositivo recebe Push Notification
                                       ,pr_chavedsp            IN VARCHAR2 --> Chave do dispositivo para recebimento de Push Notification
                                       ,pr_lstconfg            IN VARCHAR2 --> Lista com todas as origens e situação de push (ativo/inativo). Formato: "origem1-ind;origem2-ind". Exemplo: "1-0;2-1;3-0"
                                       ,pr_cdcanal             IN tbgen_canal_entrada.cdcanal%TYPE --> Canal de entrada
                                       ,pr_xml_ret            OUT CLOB --> Retorno XML
                                        ) IS
  
    -- Variáveis de Exceção
    vr_dscritic VARCHAR2(1000);
    vr_exception EXCEPTION;
  
  BEGIN
    
    -- Atualiza a situação do dispositivo. Seta TODOS os demais para 0 - Cada coop/conta/titular só pode ter 1 ativo
    UPDATE dispositivomobile dsp
       SET dsp.pushhabilitado = DECODE(dsp.dispositivomobileid, pr_dispositivomobileid, pr_recbpush, 0)
     WHERE dsp.cooperativaid = pr_cdcooper
       AND dsp.numeroconta = pr_nrdconta
       AND dsp.titularid = pr_idseqttl;
  
    -- Criar documento XML
    dbms_lob.createtemporary(pr_xml_ret, TRUE);
    dbms_lob.open(pr_xml_ret, dbms_lob.lob_readwrite);
    
    IF TRIM(pr_lstconfg) IS NOT NULL THEN
      --Quebra a string do parâmetro pr_lsttipos, e atualiza os registros na tabela
      MERGE INTO tbgen_notif_push_orig_prm prm
      USING (SELECT to_number(regexp_substr(item, '[^-]+', 1, 1)) cdorigem_mensagem
                   ,to_number(regexp_substr(item, '[^-]+', 1, 2)) inpush_ativo
               FROM (SELECT regexp_substr(pr_lstconfg, '[^;]+', 1, LEVEL) item
                       FROM dual
                     CONNECT BY LEVEL <= regexp_count(pr_lstconfg, '[^;]+'))) lst
      ON (prm.cdcooper = pr_cdcooper AND prm.nrdconta = pr_nrdconta AND prm.idseqttl = pr_idseqttl AND prm.cdorigem_mensagem = lst.cdorigem_mensagem)
      --Se já possuir o código de origem cadastrado, então atualiza
      WHEN MATCHED THEN
        UPDATE
           SET prm.inpush_ativo = lst.inpush_ativo
         WHERE prm.cdcooper = pr_cdcooper
           AND prm.nrdconta = pr_nrdconta
           AND prm.idseqttl = pr_idseqttl
           AND prm.cdorigem_mensagem = lst.cdorigem_mensagem
        --Senão cria um registro novo com os dados recebidos
      
      WHEN NOT MATCHED THEN
        INSERT
          (prm.cdcooper
          ,prm.nrdconta
          ,prm.idseqttl
          ,prm.cdorigem_mensagem
          ,prm.inpush_ativo)
        VALUES
          (pr_cdcooper
          ,pr_nrdconta
          ,pr_idseqttl
          ,lst.cdorigem_mensagem
          ,lst.inpush_ativo);
    END IF;
  
    pr_xml_ret := '<dsmsgsuc>' || 'Configurações alteradas com sucesso.' || '</dsmsgsuc>';
  
  EXCEPTION
    WHEN OTHERS THEN
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Ocorreu um erro ao alterar as configurações de recebimento de push notification.';
      END IF;
    
      pr_xml_ret := '<dsmsgerr>' || vr_dscritic || '</dsmsgerr>';
    
  END pc_altera_config_receb_push;

END NOTI0002;
/
