declare  

  /* 044 grupos foram executados em 166 segundos no dev2 */
  /* 036 grupos foram executados em 153 segundos no dev2 */
  
  -- Parametros para execucao do script
  vr_idprglog            number := 0;
  vr_exc_saida           exception;
  vr_cdcritic            pls_integer;
  vr_nmarquivo_upload    varchar2(4000);
  vr_caminho_arq_upload  varchar2(255);
  vr_dtenvio_mensagem    date;
  vr_dscritic            varchar2(4000);
  vr_nmdcampo            varchar2(4000);
  vr_des_erro            varchar2(4000);
  vr_xmllog              varchar2(4000);
  vr_nmdirarq varchar2(1000) := gene0001.fn_diretorio(pr_tpdireto => 'C'     
                                                     ,pr_cdcooper => 3       
                                                     ,pr_nmsubdir => '/upload');
  vr_dtexibir_ate        date; -- Tabela Elton
  vr_text1               clob;
  vr_text2               varchar2(255);
  
  cursor cr_crapdat is
  select dat.dtmvtopr
    from crapdat dat
   where dat.cdcooper = 1;
  rw_crapdat cr_crapdat%rowtype;

  -- Cursor que busca as agencias
  cursor cr_crapage is
  select age.cdcooper
       , age.cdagenci
       , age.nrdgrupo
       , lower(cop.nmrescop) nmrescop
    from tbevento_grupos age
       , crapcop cop
   where age.cdcooper = 9
     and cop.cdcooper = age.cdcooper
   order
      by age.cdcooper
       , age.cdagenci
       , age.nrdgrupo;
       
  -- Cursor que busca dados do evento
  cursor cr_dados_evento (pr_cdcooper in crapldp.cdcooper%type
                         ,pr_cdagenci in crapldp.cdagenci%type
                         ,pr_nrdgrupo in crapadp.nrdgrupo%type) is
  select ldp.cdcooper
       , ldp.cdagenci
       , adp.nrdgrupo
       , adp.nmdgrupo
       , adp.dtinieve
       , adp.dshroeve
       , rpad(replace(upper(adp.dshroeve),'H',','),5,'0') dshroeve2
       , ldp.dslocali
       , ldp.dsendloc
       , ldp.nmcidloc
    from crapldp ldp
       , crapadp adp
   where ldp.cdcooper = pr_cdcooper
     and ldp.cdagenci = pr_cdagenci
     and adp.nrdgrupo = pr_nrdgrupo
     and ldp.cdcooper = adp.cdcooper
     and ldp.nrseqdig = adp.cdlocali
     and adp.idevento = 2
     and adp.dtanoage = 2019;
  rw_dados_evento cr_dados_evento%rowtype;

  -- Auxiliar para popular xml da rotina
  pr_retxml   xmltype;
  pr_auxiliar clob := '<Root>'                         ||
                      '<params>'                       ||
                      '<cdcooper>3</cdcooper>'         ||
                      '<nmprogra>UNDEFINED</nmprogra>' ||
                      '<nmeacao>UNDEFINED</nmeacao>'   ||
                      '<cdagenci>1</cdagenci>'         ||
                      '<nrdcaixa>1</nrdcaixa>'         ||
                      '<idorigem>1</idorigem>'         ||
                      '<cdoperad>1</cdoperad>'         ||
                      '</params></Root>'; 

  DESCRICAOVARIAVEISUNIVERSAIS CONSTANT VARCHAR2(32000) := 
  '<br/>#numeroconta - Número da conta do cooperado (Ex.: 99.999-0)' ||
  '<br/>#nomecompleto - Contas PF: Nome completo do titular, Contas PJ: Razão social (Ex.: JOÃO DA SILVA, ou GOOGLE BRASIL INTERNET LTDA)' ||
  '<br/>#nomeresumido - Contas PF: Primeiro nome do titular, Contas PJ: nome fantasia (Ex.: JOÃO, ou GOOGLE)' ||
  '<br/>#cpfcnpj - CPF ou CNPJ da conta do cooperado (Ex.: 099.999.999-01)' ||
  '<br/>#siglacoop - Sigla da cooperativa (Ex.: AILOS)' ||
  '<br/>#nomecoop - Nome completo da cooperativa (Ex.: COOPERATIVA CENTRAL DE CRÉDITO URBANO)';

  NMDATELA CONSTANT VARCHAR2(6) := 'ENVNOT';
 
  -- Proc que gera a relacao de contas
  procedure gerar_arquivo (pr_nmdirarq  in varchar2
                          ,pr_cdcritic out pls_integer
                          ,pr_dscritic out varchar2) is

    -- Buscar cooperados para apresentar no relatorio
    cursor cr_busca_cooperados (pr_cdcooper in tbevento_pessoa_grupos.cdcooper%type
                               ,pr_cdagenci in tbevento_pessoa_grupos.cdagenci%type
                               ,pr_nrdgrupo in tbevento_pessoa_grupos.nrdgrupo%type) is
    select gru.cdcooper
         , gru.nrdconta
         , gru.nrdgrupo
         , gru.nrcpfcgc
         , gru.cdagenci
      from tbevento_pessoa_grupos gru
     where gru.cdcooper = decode(pr_cdcooper,0,gru.cdcooper,pr_cdcooper)
       and gru.cdagenci = decode(pr_cdagenci,0,gru.cdagenci,pr_cdagenci)
       and gru.nrdgrupo = decode(pr_nrdgrupo,0,gru.nrdgrupo,pr_nrdgrupo)
     order
        by gru.cdcooper
         , gru.cdagenci
         , gru.nrdgrupo;
          
    -- Verifica se cpf / cnpj possui outras contas
    cursor cr_busca_contas (pr_cdcooper in crapass.cdcooper%type
                           ,pr_nrcpfcgc in crapass.nrcpfcgc%type
                           ,pr_nrdconta in crapass.nrcpfcgc%type) is
    select ass.cdcooper
         , ass.nrdconta
      from crapass ass
     where ass.cdcooper =  pr_cdcooper
       and ass.nrcpfcgc =  pr_nrcpfcgc
       and ass.nrdconta <> pr_nrdconta
       and ass.dtdemiss is null;
       
    vr_nrdgrupo    NUMBER;
    vr_cdagenci    crapage.cdagenci%type;
    vr_nmarquiv    VARCHAR2(2000);
    vr_ind_arquiv  utl_file.file_type;
    -- Array para guardar o split dos dados contidos na dsvlrprm       
    vr_parametro  gene0002.typ_split; 
    
    -- Tabela temporaria do bulk collect
    type typ_dados_cursor is table of cr_busca_cooperados%rowtype;
    vr_dados_cursor typ_dados_cursor;
    vr_idx pls_integer;
    
  begin

    -- Listar arquivos (retorna somente um)
    gene0001.pc_lista_arquivos(pr_path     => pr_nmdirarq
                              ,pr_pesq     => 'lst-arq-grp-%'
                              ,pr_listarq  => vr_nmarquivo_upload
                              ,pr_des_erro => vr_dscritic);
                                
    -- Se ocorreu erro, cancela o programa
    if vr_dscritic is not null then
      raise vr_exc_saida;
    end if;
    
    -- Recebe arquivos existentes e quebra string
    vr_parametro := gene0002.fn_quebra_string(pr_string => vr_nmarquivo_upload
                                             ,pr_delimit => ',');

    -- Se encontrou executa comando shell                                    
    for i in 1..vr_parametro.count() loop
      begin
        -- Comando remove
        gene0001.pc_OScommand_Shell('rm ' || pr_nmdirarq || '/' || vr_parametro(i));
      exception
        when others then
          vr_dscritic := 'Erro ao fazer limpeza da pasta upload: '||sqlerrm;
          raise vr_exc_saida;
      end;
    end loop;

    -- Abrir cursor do bulk collect 
    open cr_busca_cooperados (9,0,0);

    loop
      
      -- Loop principal de retorno de dados
      fetch cr_busca_cooperados bulk collect into vr_dados_cursor limit 200;
      exit when vr_dados_cursor.count = 0;

      for vr_idx in 1 .. vr_dados_cursor.count loop

        -- Verificacao para primeiro registro do grupo
        if vr_nrdgrupo is null or 
           vr_nrdgrupo <> vr_dados_cursor(vr_idx).nrdgrupo or
           vr_cdagenci <> vr_dados_cursor(vr_idx).cdagenci then
             
          -- Fecha arquivo caso mude de grupo
          -- Caso seja o primeiro, nao realiza nenhuma acao
          if vr_nrdgrupo is not null then
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
          end if;
          
          -- Seta valor do grupo
          vr_nrdgrupo := vr_dados_cursor(vr_idx).nrdgrupo;

          -- Concatena o nome do arquivo
          vr_nmarquiv := 'lst-arq-grp-'||
                         lpad(trim(vr_dados_cursor(vr_idx).cdcooper),2,'0')||'-'||
                         lpad(trim(vr_dados_cursor(vr_idx).cdagenci),3,'0')||'-'||
                         lpad(trim(vr_dados_cursor(vr_idx).nrdgrupo),2,'0')||'-'||
                         trim(to_char(sysdate,'yyyymmdd-sssss'))||
                         '.csv';
            
          --Abrir arquivo
          gene0001.pc_abre_arquivo (pr_nmdireto => pr_nmdirarq  --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                   ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                   ,pr_utlfileh => vr_ind_arquiv  --> Handle do arquivo aberto
                                   ,pr_des_erro => vr_dscritic);  --> Erro
                        
          -- Aborta em caso de critica             
          if trim(vr_dscritic) is not null then
            raise vr_exc_saida;
          end if;
                                              
        end if;

        -- Adicionar linha ao arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                      ,pr_des_text => vr_dados_cursor(vr_idx).cdcooper||';'||
                                                      vr_dados_cursor(vr_idx).nrdconta||';1');
                                                        
        -- Cpf / cnpj pode ter outras contas porem tabela 
        -- tbevento_pessoa_grupos nao repete cpf / cnpj
        for rw_busca_contas in cr_busca_contas (vr_dados_cursor(vr_idx).cdcooper
                                               ,vr_dados_cursor(vr_idx).nrcpfcgc
                                               ,vr_dados_cursor(vr_idx).nrdconta) loop
            
          -- Adicionar linha ao arquivo
          gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                        ,pr_des_text => rw_busca_contas.cdcooper||';'||
                                                        rw_busca_contas.nrdconta||';1');
          
        end loop;

        vr_cdagenci := vr_dados_cursor(vr_idx).cdagenci;

      end loop;

    end loop;

    -- Ao final, fechar o arquivo
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

  exception
    
    when others then
      
      if nvl(vr_cdcritic,0) <> 0 then
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      else
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      end if;
      
      pr_dscritic := pr_dscritic || ' - ' || sqlerrm;
      
  end gerar_arquivo;

  PROCEDURE pc_mantem_msg_manual(pr_cdmensagem                IN TBGEN_NOTIF_MSG_CADASTRO.CDMENSAGEM%TYPE               -- Codigo da a mensagem
                                ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- Ação do botão de ação do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                ,pr_dsmensagem_acao_mobile    IN TBGEN_NOTIF_MSG_CADASTRO.DSMENSAGEM_ACAO_MOBILE%TYPE   -- Mensagem de confirmacao que sera exibida ao clicar no botao de acao no Cecred Mobile
                                ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                ,pr_inenviar_push            IN TBGEN_NOTIF_MSG_CADASTRO.INENVIAR_PUSH%TYPE           -- Indicador se envia push notification (0-Nao/ 1-Sim)
                                -- Parâmetros para mensagens manuais
                                ,pr_dtenvio_mensagem      IN VARCHAR2                                         -- Data do envio da mensagem
                                ,pr_hrenvio_mensagem      IN VARCHAR2                                         -- Hora do envio da mensagem
                                ,pr_tpfiltro              IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO%TYPE             -- Tipo do filtro (1-Filtro manual/ 2-Importacao de arquivo CSV)
                                ,pr_dsfiltro_cooperativas IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE-- Filtro de cooperativas: Codigos separados por virgula
                                ,pr_dsfiltro_tipos_conta  IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE -- Filtro de tipo de conta: Tipos separados por virgula
                                ,pr_tpfiltro_mobile       IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO_MOBILE%TYPE      -- Filtro para usuario do Cecred Mobile (0-Todas as plataformas/ 1-Cooperados sem Mobile/ 2-Android/ 3-IOS)
                                ,pr_nmarquivo_csv         IN VARCHAR                                          -- Nome do arquivo CSV para envio das notificações
                                ,pr_caminho_arq_upload    IN VARCHAR2                                         -- Caminho do arquivo CSV
                                
                                ,pr_xmllog       IN VARCHAR2                                                  --> XML com informacoes de LOG
                                ,pr_cdcritic    OUT PLS_INTEGER                                               --> Codigo da critica
                                ,pr_dscritic    OUT VARCHAR2                                                  --> Descricao da critica
                                ,pr_retxml   IN OUT NOCOPY xmltype                                            --> Arquivo de retorno do XML
                                ,pr_nmdcampo    OUT VARCHAR2                                                  --> Nome do campo com erro
                                ,pr_des_erro    OUT VARCHAR2) IS                                              --> Erros do processo
    -- Constantes
    TIPO_AVISOS tbgen_notif_msg_tipo.cdtipo_mensagem%TYPE := 3; -- Origem: Avisos (Notificação manual)
    ORIGEM_AVISOS tbgen_notif_msg_cadastro.cdorigem_mensagem%TYPE := 1; -- Tipo: Avisos (Notificação manual)
    SITUACAO_PENDENTE tbgen_notif_manual_prm.cdsituacao_mensagem%TYPE := 1; -- Situação: Pendente
    
    -- Cursor para buscar a situação da mensagem
    CURSOR cr_situacao_mensagem IS
     SELECT man.cdsituacao_mensagem
           ,man.dhenvio_mensagem
       FROM tbgen_notif_manual_prm     man
           ,tbgen_notif_msg_cadastro   msg
      WHERE man.cdmensagem = msg.cdmensagem
        AND man.cdmensagem = pr_cdmensagem;
    rw_situacao_mensagem cr_situacao_mensagem%ROWTYPE;
    cr_situacao_mensagem_found BOOLEAN := FALSE;
    
    --Variáveis
    vr_cdmensagem tbgen_notif_msg_cadastro.cdorigem_mensagem%TYPE;
    vr_dhenvio_mensagem tbgen_notif_manual_prm.dhenvio_mensagem%TYPE;
    vr_dshtml_mensagem tbgen_notif_msg_cadastro.dshtml_mensagem%TYPE;
    vr_dsxml_destinatarios CLOB;
    vr_dsfiltro_cooperativas tbgen_notif_manual_prm.dsfiltro_cooperativas%TYPE;
    vr_validacao NUMBER:= 0;
    vr_inalterou_dhenvio NUMBER := 0;
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

    --Retorna 1 se OK, ou 0 se NOK
    FUNCTION fn_valida_cadastro_mensagem(pr_cdtipo_mensagem           IN TBGEN_NOTIF_MSG_ORIGEM.CDTIPO_MENSAGEM%TYPE          -- Codigo do tipo da mensagem
                                        ,pr_dstitulo_mensagem         IN TBGEN_NOTIF_MSG_CADASTRO.DSTITULO_MENSAGEM%TYPE        -- Titulo da mensagem
                                        ,pr_dstexto_mensagem          IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_MENSAGEM%TYPE         -- Texto da mensagem
                                        ,pr_dshtml_mensagem           IN TBGEN_NOTIF_MSG_CADASTRO.DSHTML_MENSAGEM%TYPE          -- Conteudo da notificacao no formato Html
                                        ,pr_dsvariaveis_disponiveis    IN VARCHAR2                                               -- Descrição das variáveis disponíveis
                                        ,pr_inexibe_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBE_BOTAO_ACAO_MOBILE%TYPE-- Indicador se exibe botao de acao da notificacao no Cecred Mobile
                                        ,pr_dstexto_botao_acao_mobile IN TBGEN_NOTIF_MSG_CADASTRO.DSTEXTO_BOTAO_ACAO_MOBILE%TYPE-- Texto do botao de acao da notificacao no Cecred Mobile
                                        ,pr_idacao_botao_acao_mobile  IN NUMBER                                                 -- Ação do botão de ação do Cecred Mobile. 1 - Abrir Link, 2 - Abrir tela
                                        ,pr_cdmenu_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.CDMENU_ACAO_MOBILE%TYPE       -- Codigo da tela do Cecred Mobile que deve ser aberta ao clicar no botao de acao
                                        ,pr_dslink_acao_mobile        IN TBGEN_NOTIF_MSG_CADASTRO.DSLINK_ACAO_MOBILE%TYPE       -- Link para ser acessado ao clicar no botao de acao no Cecred Mobile
                                        ,pr_cdicone                   IN TBGEN_NOTIF_MSG_CADASTRO.CDICONE%TYPE                  -- Codigo do icone da notificacao
                                        ,pr_inexibir_banner           IN TBGEN_NOTIF_MSG_CADASTRO.INEXIBIR_BANNER%TYPE          -- Indicador de exibicao da imagem de banner
                                        ,pr_nmimagem_banner           IN TBGEN_NOTIF_MSG_CADASTRO.NMIMAGEM_BANNER%TYPE          -- Nome da imagem do banner para notificacao nao lida
                                        -- Parâmetros para mensagens automáticas
                                        ,pr_intipo_repeticao     IN NUMBER                                             DEFAULT NULL -- Tipo de Repetição: 1 - Semanal, 2 - Mensal
                                        ,pr_nrdias_semana       IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE       DEFAULT NULL -- Numeros dos dias da semana em que deve repetir a mensagem (Separados por virgula)
                                        ,pr_nrsemanas_repeticao IN TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE DEFAULT NULL -- Numero das semanas do mês em que deve repetir a mensagem (Separadas por virgula)
                                        ,pr_nrdias_mes          IN TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE          DEFAULT NULL -- Dia(s) do mês para disparar a mensagem (Separados por virgula)
                                        ,pr_nrmeses_repeticao   IN TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE   DEFAULT NULL -- Numeros dos meses em que deve repetir a mensagem (Separados por virgula)
                                        ,pr_hrenvio_mensagem    IN VARCHAR2                                            DEFAULT NULL -- Hora do envio da mensagem
                                        -- Parâmetros para mensagens manuais
                                        ,pr_dhenvio_mensagem      IN TBGEN_NOTIF_MANUAL_PRM.DHENVIO_MENSAGEM%TYPE      DEFAULT NULL -- Data e hora do envio da mensagem
                                        ,pr_tpfiltro              IN TBGEN_NOTIF_MANUAL_PRM.TPFILTRO%TYPE              DEFAULT NULL -- Tipo do filtro (1-Filtro manual/ 2-Importacao de arquivo CSV)
                                        ,pr_dsfiltro_cooperativas IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE DEFAULT NULL -- Filtro de cooperativas: Codigos separados por virgula
                                        ,pr_dsfiltro_tipos_conta  IN TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE  DEFAULT NULL -- Filtro de tipos de conta: Codigos separados por virgula
                                        -- RETORNO
                                        ,pr_nmdcampo OUT VARCHAR2 --> Nome do campo com erro
                                        ,pr_dscritic OUT VARCHAR2 -- Mensagem de retorno de critica da validação
                                        ) RETURN NUMBER IS
                                        
      CURSOR cr_var_inexistentes IS
      SELECT listagg(variavel, ', ') WITHIN GROUP (ORDER BY rownum) variaveis
        FROM (SELECT regexp_replace(regexp_substr(pr_dstexto_mensagem||' '||pr_dshtml_mensagem,'#\w+',1,LEVEL),'#\d+$') variavel -- Replace para tirar os códigos html que usam #. Ex: Apóstrofo = &#39;
                FROM dual
              CONNECT BY LEVEL <= regexp_count(pr_dstexto_mensagem||' '||pr_dshtml_mensagem, '[^#]+'))
       WHERE variavel IS NOT NULL
         AND pr_dsvariaveis_disponiveis NOT LIKE '%' || variavel || ' %';
      vr_var_inexistentes VARCHAR2(1000);

      vr_nrdias_semana        TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_SEMANA%TYPE;
      vr_nrsemanas_repeticao  TBGEN_NOTIF_AUTOMATICA_PRM.NRSEMANAS_REPETICAO%TYPE;
      vr_nrdias_mes           TBGEN_NOTIF_AUTOMATICA_PRM.NRDIAS_MES%TYPE;
      vr_nrmeses_repeticao    TBGEN_NOTIF_AUTOMATICA_PRM.NRMESES_REPETICAO%TYPE;

      vr_dsfiltro_cooperativas TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_COOPERATIVAS%TYPE;
      vr_dsfiltro_tipos_conta TBGEN_NOTIF_MANUAL_PRM.DSFILTRO_TIPOS_CONTA%TYPE;

      vr_exc_erro EXCEPTION;

    BEGIN
      
      /*VALIDA OS CAMPOS OBRIGATÓRIOS*/
      IF pr_dstitulo_mensagem IS NULL THEN
        pr_dscritic:= 'Título é obrigatório';
      ELSIF pr_cdicone IS NULL THEN
        pr_dscritic:= 'Ícone é obrigatório';
      ELSIF pr_dstexto_mensagem IS NULL THEN
        pr_dscritic:= 'Mensagem é obrigatória';
      ELSIF pr_inexibir_banner = 1 AND pr_nmimagem_banner IS NULL THEN
        pr_dscritic:= 'Exibir Banner está ativo mas nenhuma imagem foi selecionada';
      ELSIF pr_dshtml_mensagem IS NULL THEN
        pr_dscritic:= 'Conteúdo é obrigatório';
      ELSIF pr_inexibe_botao_acao_mobile = 1 THEN -- Validações refetentes ao botão de ação
        IF pr_dstexto_botao_acao_mobile IS NULL THEN
        pr_dscritic:= 'O texto do botão de ação do Ailos Mobile é obrigatório';
        ELSIF pr_idacao_botao_acao_mobile = 1 AND pr_dslink_acao_mobile IS NULL THEN
        pr_dscritic:= 'URL do botão de ação é obrigatório';
        ELSIF pr_idacao_botao_acao_mobile = 2 AND pr_cdmenu_acao_mobile IS NULL THEN
        pr_dscritic:= 'Tela do Ailos Mobile do botão de ação é obrigatória';
        END IF;
      END IF;
      
      IF pr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      /*VALIDA AS MENSAGENS AUTOMÁTICAS RECORRENTES (Tipo: Serviços)*/
      IF (pr_cdtipo_mensagem = 1) THEN -- Serviços
        --Limpa as virgulas e espaços dos parâmetros de lista
        vr_nrdias_semana := REPLACE(REPLACE(pr_nrdias_semana,',',''),' ','');
        vr_nrsemanas_repeticao := REPLACE(REPLACE(pr_nrsemanas_repeticao,',',''),' ','');
        vr_nrdias_mes := REPLACE(REPLACE(pr_nrdias_mes,',',''),' ','');
        vr_nrmeses_repeticao := REPLACE(REPLACE(pr_nrmeses_repeticao,',',''),' ','');
        
        IF pr_intipo_repeticao <> 1 AND pr_intipo_repeticao <> 2 THEN -- Se não for selecionado nenhum tipo de recorrência
          pr_dscritic:= 'É obrigatório escolher um tipo de recorrência: Por mês ou por semana';
        ELSIF pr_intipo_repeticao = 1 AND (vr_nrdias_semana IS NULL OR vr_nrsemanas_repeticao IS NULL) THEN -- Se for semana
          pr_dscritic:= 'Para ativar a recorrência por semana é necessário informar os dias e as semanas em que deve ocorrer os envios da mensagem';
        ELSIF pr_intipo_repeticao = 2 AND (vr_nrdias_mes IS NULL OR vr_nrmeses_repeticao IS NULL) THEN -- Se for mês
          pr_dscritic:= 'Para ativar a recorrência por mês é necessário informar os dias e os meses em que deve ocorrer os envios da mensagem';
        END IF;
        
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      /*VALIDA AS MENSAGENS MANUAIS (Tipo: Avisos)*/
      ELSIF (pr_cdtipo_mensagem = 3) THEN -- Avisos
        --Limpa as virgulas e espaços dos parâmetros de lista
        vr_dsfiltro_cooperativas := REPLACE(REPLACE(pr_dsfiltro_cooperativas,',',''),' ','');
        vr_dsfiltro_tipos_conta := REPLACE(REPLACE(pr_dsfiltro_tipos_conta,',',''),' ','');
        
        IF pr_dhenvio_mensagem IS NULL THEN 
          pr_dscritic:= 'Data do envio da mensagem é obrigatória';
        ELSIF pr_hrenvio_mensagem IS NULL THEN
          pr_dscritic:= 'Hora do envio da mensagem é obrigatória';
        ELSIF TRUNC(pr_dhenvio_mensagem) < TRUNC(SYSDATE) THEN
          pr_dscritic:= 'Data do envio da mensagem já passou';
        ELSIF pr_dhenvio_mensagem < SYSDATE THEN
          pr_dscritic:= 'Hora do envio da mensagem já passou';
        ELSIF pr_tpfiltro <> 1 AND pr_tpfiltro <> 2 THEN
          pr_dscritic:= 'É necessário escolher um tipo de filtro';
        ELSIF pr_tpfiltro = 2 AND TRUNC(pr_dhenvio_mensagem) <> TRUNC(SYSDATE) THEN -- Arquivo csv só pode ser importado para mensagens enviadas no dia, pq seus dados são estáticos
          pr_dscritic:= 'Arquivo .csv só pode ser importado para mensagens enviadas no mesmo dia';
        ELSIF (vr_dsfiltro_cooperativas IS NULL OR vr_dsfiltro_cooperativas = 0) AND pr_tpfiltro = 1 THEN
          pr_dscritic:= 'É necessário selecionar ao menos uma cooperativa';
        ELSIF (vr_dsfiltro_tipos_conta IS NULL OR vr_dsfiltro_tipos_conta = 0) AND pr_tpfiltro = 1 THEN
          pr_dscritic:= 'É necessário selecionar ao menos um tipo de conta';
        END IF;
        
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      
      END IF;
      
      -- Depois de tudo, valida se o html possui variaveis inexistentes
      OPEN cr_var_inexistentes;
      FETCH cr_var_inexistentes
      INTO vr_var_inexistentes;
      CLOSE cr_var_inexistentes;
      
      IF vr_var_inexistentes IS NOT NULL THEN
        pr_dscritic:= 'Variável inexistente: ' || vr_var_inexistentes;
        RAISE vr_exc_erro;
      END IF;
      
      

      --Se passou por todas as validações
      RETURN 1;
      
    EXCEPTION
      WHEN OTHERS THEN
           RETURN 0;
    END fn_valida_cadastro_mensagem;

    
    -- Procedure para percorrer o arquivo CSV importado e agendar as notificações. Executa apenas se pr_tpfiltro = 2 (Importação de CSV)
    PROCEDURE pc_cria_notificacoes_csv(pr_nmarquivo_csv         IN VARCHAR                                          -- Nome do arquivo CSV para envio das notificações
                                      ,pr_caminho_arq_upload    IN VARCHAR2
                                      ,pr_cdmensagem            IN tbgen_notif_manual_prm.cdmensagem%TYPE
                                      ,pr_inalterou_dhenvio     IN NUMBER  -- Indicador se o usuário alterou a data do envio
                                      ,pr_dhenvio               IN tbgen_notif_manual_prm.dhenvio_mensagem%TYPE
                                      ,pr_xmllog                IN VARCHAR2 --> XML com informações de LOG
                                      ,pr_cdcritic              OUT PLS_INTEGER --> Código da crítica
                                      ,pr_dscritic              OUT VARCHAR2 --> Descrição da crítica
                                      ,pr_retxml                IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                      ,pr_nmdcampo              OUT VARCHAR2 --> Nome do Campo
                                      ,pr_des_erro              OUT VARCHAR2) IS

      vr_destinatarios NOTI0001.typ_destinatarios_notif;
    BEGIN
      
      -- Se deve entrou um xml gera as notificacoes (apaga as anticas se houver)
      IF pr_nmarquivo_csv IS NOT NULL AND pr_caminho_arq_upload IS NOT NULL THEN
        
        -- Delete Notificações e Pushs para não duplicar registros (quando o usuário importou um CSV, e depois importou outro CSV para substitur o anterior)
        DELETE FROM tbgen_notif_push push WHERE push.cdnotificacao IN (SELECT noti.cdnotificacao FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem);
        DELETE FROM tbgen_notificacao noti WHERE noti.cdmensagem = pr_cdmensagem;
        
        -- Carrega os destinatários para a tabela de importação
        tela_envnot.pc_importar_arquivo_notif(pr_arquivo    => pr_nmarquivo_csv
                                 ,pr_dirarquivo => pr_caminho_arq_upload
                                 ,pr_destinatarios => vr_destinatarios
                                 ,pr_xmllog     => pr_xmllog
                                 ,pr_cdcritic   => pr_cdcritic
                                 ,pr_dscritic   => pr_dscritic
                                 ,pr_retxml     => pr_retxml
                                 ,pr_nmdcampo   => pr_nmdcampo
                                 ,pr_des_erro   => pr_des_erro);
                                        
        -- Cria as notificações para os destinatários que estão no CSV
        NOTI0001.pc_cria_notificacoes(pr_cdmensagem    => pr_cdmensagem    
                                     ,pr_dhenvio       => pr_dhenvio
                                     ,pr_destinatarios => vr_destinatarios);
        
      -- Se não recebeu XML e a data foi alterada, então atualiza as datas das notificações que já foram geradas antes...
      ELSIF pr_inalterou_dhenvio = 1 THEN
         UPDATE tbgen_notificacao noti
            SET noti.dhenvio = pr_dhenvio
          WHERE noti.cdmensagem = pr_cdmensagem;
          
          -- Atualiza a data de envio dos lotes de push desta notificação
          UPDATE tbgen_notif_lote_push lote
            SET lote.dhagendamento = pr_dhenvio
          WHERE lote.cdlote_push IN (SELECT DISTINCT push.cdlote_push
                                       FROM tbgen_notif_push push
                                           ,tbgen_notificacao noti
                                      WHERE noti.cdnotificacao = push.cdnotificacao
                                        AND noti.cdmensagem = pr_cdmensagem);
      END IF;
    
    END pc_cria_notificacoes_csv;

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
    
    -- Obtém a data + hora
    vr_dhenvio_mensagem := TRUNC(TO_DATE(pr_dtenvio_mensagem,'dd/mm/RRRR')) +
                           (TO_NUMBER(TO_CHAR(TO_DATE(pr_hrenvio_mensagem,'HH24:MI'),'SSSSS'))/60/60/24);
    
    -- Remove o CDATA dos XMLs
    vr_dshtml_mensagem := SUBSTR(pr_dshtml_mensagem,10,LENGTH(pr_dshtml_mensagem)-12);
    --vr_dsxml_destinatarios := SUBSTR(pr_dsxml_destinatarios,10,LENGTH(pr_dsxml_destinatarios)-12);
    
    
    -- Se for UPDATE de registro existente, então valida o pr_cdmensagem
    IF pr_cdmensagem <> 0 THEN
      
      -- Valida pela situação se ainda pode alterar (Só pode alterar se estiver PENDENTE)
      OPEN cr_situacao_mensagem;
      FETCH cr_situacao_mensagem
      INTO rw_situacao_mensagem;
      cr_situacao_mensagem_found := cr_situacao_mensagem%FOUND;
      CLOSE cr_situacao_mensagem;
    
      -- Se não encontrou
      IF NOT cr_situacao_mensagem_found THEN
        vr_dscritic := 'Registro de Mensagem não encontrado';
        RAISE ex_erro;
      -- Se não estiver PENDENTE ou já foi enviada
      ELSIF rw_situacao_mensagem.cdsituacao_mensagem <> SITUACAO_PENDENTE OR rw_situacao_mensagem.dhenvio_mensagem <= SYSDATE THEN
        vr_dscritic := 'Esta mensagem não pode mais ser alterada';
        RAISE ex_erro;
      END IF;
      
      -- Verifica se o usuário alterou a data
      vr_inalterou_dhenvio := CASE WHEN rw_situacao_mensagem.dhenvio_mensagem <> vr_dhenvio_mensagem THEN 1 ELSE 0 END;
      
    END IF;
    
    -- Se for um operador de cooperativa, ignora o filtro de cooperativas e trava a coop atual
    IF vr_cdcooper <> 3 THEN
      vr_dsfiltro_cooperativas := vr_cdcooper;
    ELSE
      vr_dsfiltro_cooperativas := pr_dsfiltro_cooperativas;
    END IF;

    -- Valida os dados da mensagem
    vr_validacao := fn_valida_cadastro_mensagem (pr_cdtipo_mensagem => TIPO_AVISOS -- Avisos (fixo)
                                                            ,pr_dstitulo_mensagem => pr_dstitulo_mensagem
                                                            ,pr_dstexto_mensagem => pr_dstexto_mensagem
                                                            ,pr_dshtml_mensagem => vr_dshtml_mensagem
                                                            ,pr_dsvariaveis_disponiveis => DESCRICAOVARIAVEISUNIVERSAIS
                                                            ,pr_inexibe_botao_acao_mobile => pr_inexibe_botao_acao_mobile
                                                            ,pr_dstexto_botao_acao_mobile => pr_dstexto_botao_acao_mobile
                                                            ,pr_idacao_botao_acao_mobile => pr_idacao_botao_acao_mobile
                                                            ,pr_cdmenu_acao_mobile => pr_cdmenu_acao_mobile
                                                            ,pr_dslink_acao_mobile => pr_dslink_acao_mobile
                                                            ,pr_cdicone => pr_cdicone
                                                            ,pr_inexibir_banner => pr_inexibir_banner
                                                            ,pr_nmimagem_banner => pr_nmimagem_banner
                                                            ,pr_dhenvio_mensagem => (TRUNC(TO_DATE(sysdate,'dd/mm/RRRR')) +
                                                                                    (TO_NUMBER(TO_CHAR(TO_DATE('23,00','HH24:MI'),'SSSSS'))/60/60/24))
                                                            ,pr_hrenvio_mensagem => '23,00'
                                                            ,pr_tpfiltro => pr_tpfiltro
                                                            ,pr_dsfiltro_cooperativas => vr_dsfiltro_cooperativas
                                                            ,pr_dsfiltro_tipos_conta => pr_dsfiltro_tipos_conta
                                                            ,pr_nmdcampo => pr_nmdcampo
                                                            ,pr_dscritic => vr_dscritic);
                        
    IF vr_validacao = 0 THEN
        RAISE vr_exc_erro;
    END IF;
    
    vr_cdmensagem := NVL(pr_cdmensagem,0);
    
    -- Se for INSERT de uma nova mensagem
    IF vr_cdmensagem = 0 THEN
      BEGIN 
      INSERT INTO tbgen_notif_msg_cadastro msg
                 (msg.cdmensagem
                 ,msg.cdorigem_mensagem
                 ,msg.dstitulo_mensagem
                 ,msg.cdicone
                 ,msg.dstexto_mensagem
                 ,msg.dshtml_mensagem
                 ,msg.inenviar_push
                 ,msg.inexibir_banner
                 ,msg.nmimagem_banner
                 ,msg.inexibe_botao_acao_mobile
                 ,msg.dstexto_botao_acao_mobile
                 ,msg.dslink_acao_mobile
                 ,msg.cdmenu_acao_mobile
                 ,msg.dsmensagem_acao_mobile)
           VALUES
                 ((SELECT NVL(MAX(seq.cdmensagem),0)+1 FROM tbgen_notif_msg_cadastro seq)
                 ,ORIGEM_AVISOS -- cdorigem_mensagem
                 ,pr_dstitulo_mensagem
                 ,pr_cdicone
                 ,pr_dstexto_mensagem
                 ,vr_dshtml_mensagem
                 ,pr_inenviar_push
                 ,pr_inexibir_banner
                 ,pr_nmimagem_banner
                 ,pr_inexibe_botao_acao_mobile
                 ,pr_dstexto_botao_acao_mobile
                 ,DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL) --dslink_acao_mobile
                 ,DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL) --cdmenu_acao_mobile
                 ,pr_dsmensagem_acao_mobile)
         RETURNING msg.cdmensagem INTO vr_cdmensagem;
       EXCEPTION
         WHEN OTHERS THEN
           vr_dscritic := 'Erro ao inserir registro(TBGEN_NOTIF_MSG_CADASTRO) - ' || vr_cdmensagem || '. Erro: ' || SQLERRM;
           RAISE;
       END;   

      BEGIN       
        INSERT INTO tbgen_notif_manual_prm man
                    (man.cdmensagem
                    ,man.cdcooper
                    ,man.cdoperad
                    ,man.dhcadastro_mensagem
                    ,man.dhenvio_mensagem
                    ,man.cdsituacao_mensagem
                    ,man.tpfiltro
                    ,man.dsfiltro_cooperativas
                    ,man.dsfiltro_tipos_conta
                    ,man.tpfiltro_mobile
                    ,man.nmarquivo_csv
                    ) VALUES
                    (vr_cdmensagem
                    ,vr_cdcooper
                    ,vr_cdoperad
                    ,SYSDATE --dhcadastro_mensagem
                    ,vr_dhenvio_mensagem
                    ,1 -- Situação Ativa
                    ,pr_tpfiltro
                    ,vr_dsfiltro_cooperativas
                    ,pr_dsfiltro_tipos_conta
                    ,pr_tpfiltro_mobile
                    ,pr_nmarquivo_csv
                    );
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir registro(TBGEN_NOTIF_MANUAL_PRM). Erro: ' || SQLERRM;
          RAISE;
      END;
    ELSE  -- Se for UPDATE de registro existente
      
      BEGIN
        --Atualiza o registro de Mensagem
        UPDATE tbgen_notif_msg_cadastro msg
           SET msg.dstitulo_mensagem          = pr_dstitulo_mensagem
              ,msg.cdicone                    = pr_cdicone
              ,msg.inenviar_push              = pr_inenviar_push
              ,msg.dstexto_mensagem          = pr_dstexto_mensagem
              ,msg.inexibir_banner            = pr_inexibir_banner
              ,msg.nmimagem_banner            = pr_nmimagem_banner
              ,msg.dshtml_mensagem           = vr_dshtml_mensagem
              ,msg.inexibe_botao_acao_mobile = pr_inexibe_botao_acao_mobile
              ,msg.dstexto_botao_acao_mobile = pr_dstexto_botao_acao_mobile
              ,msg.dslink_acao_mobile        = DECODE(pr_idacao_botao_acao_mobile,1,pr_dslink_acao_mobile,NULL) --dslink_acao_mobile
              ,msg.cdmenu_acao_mobile        = DECODE(pr_idacao_botao_acao_mobile,2,pr_cdmenu_acao_mobile,NULL) --cdmenu_acao_mobile
              ,msg.dsmensagem_acao_mobile     = pr_dsmensagem_acao_mobile
         WHERE msg.cdmensagem = vr_cdmensagem;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro(TBGEN_NOTIF_MSG_CADASTRO). Erro: ' || SQLERRM;
          RAISE;
      END;
      
      BEGIN
        --Atualiza o registro de Mensagem manual
        UPDATE tbgen_notif_manual_prm man
          SET man.cdcooper                = vr_cdcooper
             ,man.cdoperad                = vr_cdoperad
             ,man.dhenvio_mensagem        = vr_dhenvio_mensagem
             ,man.tpfiltro                = pr_tpfiltro
             ,man.dsfiltro_cooperativas   = vr_dsfiltro_cooperativas
             ,man.dsfiltro_tipos_conta    = pr_dsfiltro_tipos_conta
             ,man.tpfiltro_mobile         = pr_tpfiltro_mobile
             ,man.nmarquivo_csv            = pr_nmarquivo_csv
        WHERE man.cdmensagem = vr_cdmensagem;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar registro(TBGEN_NOTIF_MANUAL_PRM). Erro: ' || SQLERRM;
          RAISE;
      END;
    END IF;
    
    -- Se foi importação de CSV, então cria/altera os agendamentos das notificações
    IF pr_tpfiltro = 2 THEN
      pc_cria_notificacoes_csv(pr_nmarquivo_csv       => pr_nmarquivo_csv                     
                              ,pr_caminho_arq_upload  => pr_caminho_arq_upload
                              ,pr_cdmensagem          => vr_cdmensagem
                              ,pr_inalterou_dhenvio   => vr_inalterou_dhenvio
                              ,pr_dhenvio             => vr_dhenvio_mensagem
                              ,pr_xmllog              => pr_xmllog
                              ,pr_cdcritic            => pr_cdcritic
                              ,pr_dscritic            => pr_dscritic
                              ,pr_retxml              => pr_retxml
                              ,pr_nmdcampo            => pr_nmdcampo
                              ,pr_des_erro            => pr_des_erro);
    ELSE -- Se não for CSV, apaga os registros das notificações (para não ficar lixo caso o usuário importar um CSV e depois alterar o tpfiltro)
      DELETE FROM tbgen_notificacao noti WHERE noti.cdmensagem = vr_cdmensagem;
    END IF;

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
        pr_dscritic := 'Erro geral na rotina da tela '|| NMDATELA ||' (Manual): ' || SQLERRM;
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_mantem_msg_manual;

begin
  
  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'I'         
                 ,pr_cdprograma => 'BACA-ACP-NOTIF'
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0     
                 ,pr_idprglog   => vr_idprglog);

  begin
    -- Busca endereco do arquivo
    select prm.dsvlrprm
      into vr_caminho_arq_upload
      from crapprm prm
     where prm.cdacesso = 'SRVINTRA';
     vr_caminho_arq_upload := vr_caminho_arq_upload||'/upload_files/';
  exception
    when others then
      vr_dscritic := 'Erro ao buscar caminho para upload: '||sqlerrm;
      raise vr_exc_saida;
  end;

  begin
    -- Burla xml e passa coop
    pr_retxml := xmltype(pr_auxiliar);
  exception
    when others then
      vr_dscritic := 'Erro ao atribuir xml: '||sqlerrm;
      raise vr_exc_saida;
  end;
  
  -- Gerar arquivos .csv
  gerar_arquivo (vr_nmdirarq
                ,vr_cdcritic
                ,vr_dscritic);
  
  -- Aborta em caso de critica             
  if trim(vr_dscritic) is not null or nvl(vr_cdcritic,0) > 0 then
    raise vr_exc_saida;
  end if;
  
  open cr_crapdat;
  fetch cr_crapdat into rw_crapdat;
  close cr_crapdat;

  for rw_crapage in cr_crapage loop

    -- Listar arquivos (retorna somente um)
    gene0001.pc_lista_arquivos(pr_path     => vr_nmdirarq
                              ,pr_pesq     => 'lst-arq-grp-'||lpad(rw_crapage.cdcooper,2,'0')||'-'||
                                                              lpad(rw_crapage.cdagenci,3,'0')||'-'||
                                                              lpad(rw_crapage.nrdgrupo,2,'0')||'-%'
                              ,pr_listarq  => vr_nmarquivo_upload
                              ,pr_des_erro => vr_dscritic);
                                
    -- Se ocorreu erro, cancela o programa
    if trim(vr_dscritic) is not null then
      raise vr_exc_saida;
    end if;
      
    -- Verifica retorno da rotina 
    if instr(vr_nmarquivo_upload,',') > 0 then
      vr_dscritic := 'Erro na rotina gene0001.pc_lista_arquivos: retorno de mais de um arquivo.';
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'ERRO-BACA-ACP-NOTIF-1'
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 0   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
        continue;
    elsif trim(vr_nmarquivo_upload) is null then
      vr_dscritic := 'Erro na rotina gene0001.pc_lista_arquivos: arquivo nao encontrado.';
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'ERRO-BACA-ACP-NOTIF-1'
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 0   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
      continue;
    end if;
  
    -- A rotina "corta" os primeiros nove caracteres
    -- inserido oito + enter
    -- Tambem corta os ultimos tres caracteres 
    -- enter + dois  
    vr_text1 := '12345678
<p>Ficou mais fácil votar nas nossas Assembleias: o evento realizado na sua região agora tem poder de decisão. Venha, conheça os resultados de 2018 e decida os próximos passos da sua Cooperativa. Juntos vamos sempre mais longe.<br /></p>
<p><strong>Dia:</strong> !data<br /><strong>Hora:</strong> !horario<br /><strong>Local:</strong> !local<strong><br />Endereço:</strong> !endereco &#8208; !cidade<br /></p>
<p>Essa é a data exclusiva para você votar nas decisões da Cooperativa.</p>
<p><strong>Obs: Se você transferiu sua conta para outro Posto de Atendimento após o dia 1º/03/2019, a data do evento poderá sofrer alteração. Consulte pelo SAC 0800 647 2200.</strong></p>
<p>Aguardamos você ;)</p>
12'; 

    -- Busca endereco do arquivo
    open cr_dados_evento (rw_crapage.cdcooper
                         ,rw_crapage.cdagenci
                         ,rw_crapage.nrdgrupo);
    fetch cr_dados_evento into rw_dados_evento;
    
    -- Aborta se nao encontrar
    if cr_dados_evento%notfound then
      close cr_dados_evento;
      continue;
    end if;
    
    close cr_dados_evento;
  
    -- Se o evento ja aconteceu ou eh no dia da execucao
    -- pula para proximo registro
    if rw_dados_evento.dtinieve <= trunc(sysdate) then
      continue;
    -- Se o evento eh no dia seguinte da execucao
    -- pula para proximo registro      
    elsif rw_dados_evento.dtinieve = trunc(sysdate) + 1 then
      continue;
    -- Se o evento esta a mais de 10 dias da execucao
    -- envia o evento 10 dias antes  
    elsif rw_dados_evento.dtinieve > trunc(sysdate) + 10 then
      vr_dtenvio_mensagem := rw_dados_evento.dtinieve - 10;
    -- Para eventos que ainda nao aconteceram porem estao
    -- a menos de 10 dias, enviara no dia seguinte da execucao
    else
      vr_dtenvio_mensagem := rw_crapdat.dtmvtopr;      
    end if;

    -- Titulo do push
    vr_text1 := replace(vr_text1,'!data',to_char(rw_dados_evento.dtinieve,'dd/mm'));
    vr_text1 := replace(vr_text1,'!horario',rw_dados_evento.dshroeve);
    vr_text1 := replace(vr_text1,'!local',rw_dados_evento.dslocali);
    vr_text1 := replace(vr_text1,'!nomedacooperativa','Viacredi');
    vr_text1 := replace(vr_text1,'!endereco',rw_dados_evento.dsendloc);
    vr_text1 := replace(vr_text1,'!cidade',rw_dados_evento.nmcidloc);

    -- Texto do push
    vr_text2 := 'Dia !data às !hora &#8208; !local &#8208; !endereco &#8208; !cidade';
    vr_text2 := replace(vr_text2,'!data',to_char(rw_dados_evento.dtinieve,'dd/mm'));
    vr_text2 := replace(vr_text2,'!hora',rw_dados_evento.dshroeve);
    vr_text2 := replace(vr_text2,'!local',rw_dados_evento.dslocali);
    vr_text2 := replace(vr_text2,'!endereco',rw_dados_evento.dsendloc);
    vr_text2 := replace(vr_text2,'!cidade',rw_dados_evento.nmcidloc);

    -- Procedure que insere a notificacao push 
    pc_mantem_msg_manual(pr_cdmensagem                => 0
                        ,pr_dstitulo_mensagem         => 'Assembleias 2019'
                                                      -- Campo de texto 1 (Mensagem)
                        ,pr_dstexto_mensagem          => vr_text2
                                                      -- Campo de texto 2 (Conteudo)
                        ,pr_dshtml_mensagem           => vr_text1
                        ,pr_inexibe_botao_acao_mobile => 1
                        ,pr_dstexto_botao_acao_mobile => 'Saiba mais'
                        ,pr_idacao_botao_acao_mobile  => 1
                        ,pr_cdmenu_acao_mobile        => null -- ?
                        ,pr_dslink_acao_mobile        => 'http://www.aquivoceparticipa.coop.br/'||rw_crapage.nmrescop
                        ,pr_dsmensagem_acao_mobile    => 'Você será redirecionado para fora do app.'
                        ,pr_cdicone                   => 11
                        ,pr_inexibir_banner           => 1
                        ,pr_nmimagem_banner           => 'assembleias_2019_transpocred.jpg'
                        ,pr_inenviar_push             => 1
                        -- Parâmetros para mensagens 
                        ,pr_dtenvio_mensagem          => vr_dtenvio_mensagem
                        ,pr_hrenvio_mensagem          => '19,00'
                        ,pr_tpfiltro                  => 2
                        ,pr_dsfiltro_cooperativas     => rw_crapage.cdcooper
                        ,pr_dsfiltro_tipos_conta      => '1,2'
                        ,pr_tpfiltro_mobile           => 0
                        ,pr_nmarquivo_csv             => vr_nmarquivo_upload
                        ,pr_caminho_arq_upload        => vr_caminho_arq_upload
                                      
                        ,pr_xmllog                    => vr_xmllog
                        ,pr_cdcritic                  => vr_cdcritic
                        ,pr_dscritic                  => vr_dscritic
                        ,pr_retxml                    => pr_retxml
                        ,pr_nmdcampo                  => vr_nmdcampo
                        ,pr_des_erro                  => vr_des_erro);

    -- Aborta em caso de critica
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      rollback;
      vr_dscritic := 'Erro na rotina tela_envnot.pc_mantem_msg_manual: '||vr_dscritic;
      cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                            ,pr_cdprograma    => 'ERRO-BACA-ACP-NOTIF-1'
                            ,pr_cdcooper      => 0
                            ,pr_tpexecucao    => 0   -- Job
                            ,pr_tpocorrencia  => 2   -- Erro nao tratado
                            ,pr_cdcriticidade => 3   -- Critica
                            ,pr_cdmensagem    => 0
                            ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                            ,pr_idprglog      => vr_idprglog);
    end if;
    
    commit;

  end loop;

  -- Gera log no início da execução
  pc_log_programa(pr_dstiplog   => 'F'         
                 ,pr_cdprograma => 'BACA-ACP-NOTIF'
                 ,pr_cdcooper   => 0
                 ,pr_tpexecucao => 0     
                 ,pr_idprglog   => vr_idprglog);
                 
  dbms_output.put_line('Sucesso');

  commit;
  
exception
  
  when vr_exc_saida then

    rollback;
     
    dbms_output.put_line(vr_dscritic);
                  
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'ERRO-BACA-ACP-NOTIF-1'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Job
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    commit;  
    
  when others then

    rollback;

    vr_cdcritic:= 0;
    vr_dscritic:= 'Erro no baca de '||
                  'automatizacao de notificacoes (P484) --> '||
                   vr_dscritic||' - '||sqlerrm;
                   
    dbms_output.put_line(vr_dscritic);
                   
    cecred.pc_log_programa(pr_dstiplog      => 'E' -- Erro
                          ,pr_cdprograma    => 'ERRO-BACA-ACP-NOTIF-2'
                          ,pr_cdcooper      => 0
                          ,pr_tpexecucao    => 0   -- Job
                          ,pr_tpocorrencia  => 2   -- Erro nao tratado
                          ,pr_cdcriticidade => 3   -- Critica
                          ,pr_cdmensagem    => 0
                          ,pr_dsmensagem    => ' Module: AGRP0001 '||vr_dscritic
                          ,pr_idprglog      => vr_idprglog);
  
    commit;  
  
end;