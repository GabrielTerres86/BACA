CREATE OR REPLACE PACKAGE CECRED.NOTI0001 IS

  -- Author  : Pablão
  -- Created : 22/08/2017 10:04:24
  -- Purpose : Package com todas as procedures relacionadas ao envio de notificações para o Cecred Mobile e Internet Bank

  -- Definição da tipo de registro que representa os dados do destinatário de uma notificação
  TYPE typ_destinatario_notif IS RECORD(
     cdcooper    tbgen_notificacao.cdcooper%TYPE
    ,nrdconta    tbgen_notificacao.nrdconta%TYPE
    ,idseqttl    tbgen_notificacao.idseqttl%TYPE
    ,dsvariaveis tbgen_notificacao.dsvariaveis%TYPE);
  -- Tabela para comportar os registros de destinatários de uma notificação
  TYPE typ_destinatarios_notif IS TABLE OF typ_destinatario_notif INDEX BY BINARY_INTEGER;

  -- Tabela para comportar os registros de variáveis de uma notificação
  TYPE typ_variaveis_notif IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(1000);

  -- Obtem o texto da mensagem, substituindo as variáveis (Versão para VARCHAR)
  FUNCTION fn_substitui_variaveis(pr_cdcooper  IN tbgen_notificacao.cdcooper%TYPE
                                 ,pr_nrdconta  IN tbgen_notificacao.nrdconta%TYPE
                                 ,pr_idseqttl  IN tbgen_notificacao.idseqttl%TYPE
                                 ,pr_mensagem  IN VARCHAR2
                                 ,pr_variaveis IN VARCHAR2) RETURN VARCHAR2;

  -- Obtem o texto da mensagem, substituindo as variáveis (Versão para CLOB)
  FUNCTION fn_substitui_variaveis(pr_cdcooper  IN tbgen_notificacao.cdcooper%TYPE
                                 ,pr_nrdconta  IN tbgen_notificacao.nrdconta%TYPE
                                 ,pr_idseqttl  IN tbgen_notificacao.idseqttl%TYPE
                                 ,pr_mensagem  IN CLOB
                                 ,pr_variaveis IN VARCHAR2) RETURN CLOB;
  
  -- Cria um lote de notificações, recebe a o código da mensagem (Para envio de msg manuais)
  PROCEDURE pc_cria_notificacoes(pr_cdmensagem    tbgen_notificacao.cdmensagem%TYPE
                                ,pr_dhenvio       DATE DEFAULT SYSDATE
                                ,pr_destinatarios typ_destinatarios_notif);
  
  -- Cria um lote de notificações, recebe a origem e motivo da mensagem (Para envio de msg automáticas)
  PROCEDURE pc_cria_notificacoes(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                                ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                                ,pr_dhenvio           DATE DEFAULT SYSDATE
                                ,pr_destinatarios typ_destinatarios_notif);

  -- Cria uma notificação única (Recebe os dados da conta quebrados, um por parâmetro, com variáveis)
  PROCEDURE pc_cria_notificacao(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                               ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                               ,pr_dhenvio     DATE DEFAULT SYSDATE
                               ,pr_cdcooper    tbgen_notificacao.cdcooper%TYPE
                               ,pr_nrdconta    tbgen_notificacao.nrdconta%TYPE
                               ,pr_idseqttl    tbgen_notificacao.idseqttl%TYPE DEFAULT NULL
                               ,pr_variaveis   typ_variaveis_notif);
  
  -- Cria uma notificação única (Recebe os dados da conta quebrados, um por parâmetro, sem variáveis)
  PROCEDURE pc_cria_notificacao(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                               ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                               ,pr_dhenvio     DATE DEFAULT SYSDATE
                               ,pr_cdcooper    tbgen_notificacao.cdcooper%TYPE
                               ,pr_nrdconta    tbgen_notificacao.nrdconta%TYPE
                               ,pr_idseqttl    tbgen_notificacao.idseqttl%TYPE DEFAULT NULL);
                               
  -- Processa e envia as notiicações automáticas
  PROCEDURE pc_job_notificacoes_autom(pr_dhexecucao IN DATE);

  -- Processa e envia as notiicações manuais
  PROCEDURE pc_job_notificacoes_manuais(pr_dhexecucao IN DATE);

  -- Envia os pushes pendentes ao Cecred Mobile
  PROCEDURE pc_job_dispara_push_mobile(pr_dhexecucao IN DATE);

  -- Processa o retorno dos pushes enviados
  PROCEDURE pc_processa_retorno_push(pr_cdlote_push IN tbgen_notif_lote_push.cdlote_push%TYPE
                                    ,pr_xmlerros    IN XMLTYPE);

END NOTI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NOTI0001 IS

  qtdmaxlotepush CONSTANT NUMBER(10) := 1000;

  -- Obtém as variáveis universais da conta (nome da cooperativa, nome do cooperado, etc..)
  FUNCTION fn_obtem_variaveis_universais(pr_cdcooper IN tbgen_notificacao.cdcooper%TYPE
                                        ,pr_nrdconta IN tbgen_notificacao.nrdconta%TYPE
                                        ,pr_idseqttl IN tbgen_notificacao.idseqttl%TYPE)
    RETURN VARCHAR2 IS
  
    CURSOR cr_dados_conta IS
      SELECT usr.*
            ,REPLACE(nmrescop, ' AV', ' ALTO VALE') nmrescop
            ,cop.nmextcop
            ,REPLACE(to_char(usr.nrdconta / 10, 'fm999999G990D0'),',' ,'-') nrdcontafmt
            ,gene0002.fn_mask_cpf_cnpj(usr.nrcpfcgc, usr.inpessoa) nrcpfcgcfmt
        FROM vw_usuarios_internet usr
            ,crapcop              cop
       WHERE usr.cdcooper = cop.cdcooper
         AND usr.cdcooper = pr_cdcooper
         AND usr.nrdconta = pr_nrdconta
         AND usr.idseqttl = pr_idseqttl;
    rw_dados_conta cr_dados_conta%ROWTYPE;
  
    vr_dsvariaveis VARCHAR2(1000);
  
  BEGIN
  
    OPEN cr_dados_conta;
    FETCH cr_dados_conta
      INTO rw_dados_conta;
    CLOSE cr_dados_conta;
  
    IF rw_dados_conta.nrdconta IS NOT NULL THEN
      vr_dsvariaveis := vr_dsvariaveis || '#cdcooper=' || rw_dados_conta.cdcooper || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nrdconta=' || rw_dados_conta.nrdconta || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#idseqttl=' || rw_dados_conta.idseqttl || ';';
          
      vr_dsvariaveis := vr_dsvariaveis || '#siglacoop=' || rw_dados_conta.nmrescop || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nomecoop=' || rw_dados_conta.nmextcop || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#numeroconta=' || rw_dados_conta.nrdcontafmt || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#cpfcnpj=' || rw_dados_conta.nrcpfcgcfmt || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nomecompleto=' || rw_dados_conta.nmextttl || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nomeresumido=' || rw_dados_conta.nmresttl || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#cpfprocurador=' || rw_dados_conta.nrcpfpro || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nomecompletoprocurador=' || rw_dados_conta.nmextpro || ';';
      vr_dsvariaveis := vr_dsvariaveis || '#nomeresumidoprocurador=' || rw_dados_conta.nmrespro || ';';
    END IF;
  
    RETURN vr_dsvariaveis;
  
  END;

  -- Obtem o texto da mensagem, substituindo as variáveis (Versão para VARCHAR)
  FUNCTION fn_substitui_variaveis(pr_cdcooper  IN tbgen_notificacao.cdcooper%TYPE
                                 ,pr_nrdconta  IN tbgen_notificacao.nrdconta%TYPE
                                 ,pr_idseqttl  IN tbgen_notificacao.idseqttl%TYPE
                                 ,pr_mensagem  IN VARCHAR2
                                 ,pr_variaveis IN VARCHAR2) RETURN VARCHAR2 IS
  
    --Cursor para obter as variaveis
    CURSOR cr_variaveis(pr_variaveis IN VARCHAR2) IS
      SELECT variavel
            ,regexp_substr(variavel, '[^=]+', 1, 1) chave
            ,SUBSTR(regexp_substr(variavel, '=.+'), 2) valor
        FROM (SELECT regexp_substr(pr_variaveis, '[^;]+', 1, LEVEL) variavel
                FROM dual
              CONNECT BY LEVEL <= regexp_count(pr_variaveis, '[^;]+'));
  
    vr_variaveis_universais VARCHAR2(4000);
    vr_result               VARCHAR2(4000);
  
  BEGIN
  
    vr_result := pr_mensagem;
  
    IF LENGTH(vr_result) = 0 THEN
      RETURN vr_result;
    END IF;
  
    vr_variaveis_universais := fn_obtem_variaveis_universais(pr_cdcooper => pr_cdcooper
                                                            ,pr_nrdconta => pr_nrdconta
                                                            ,pr_idseqttl => pr_idseqttl);
  
    -- Faz o replace de todas as variáveis
    FOR rw_variavel IN cr_variaveis(vr_variaveis_universais || pr_variaveis) LOOP
      vr_result := REPLACE(vr_result, rw_variavel.chave, rw_variavel.valor);
    END LOOP;
  
    RETURN vr_result;
  
  END fn_substitui_variaveis; -- (Versão para VARCHAR)

  -- Obtem o texto da mensagem, substituindo as variáveis (Versão para CLOB)
  FUNCTION fn_substitui_variaveis(pr_cdcooper  IN tbgen_notificacao.cdcooper%TYPE
                                 ,pr_nrdconta  IN tbgen_notificacao.nrdconta%TYPE
                                 ,pr_idseqttl  IN tbgen_notificacao.idseqttl%TYPE
                                 ,pr_mensagem  IN CLOB
                                 ,pr_variaveis IN VARCHAR2) RETURN CLOB IS
  
    --Cursor para obter as variaveis
    CURSOR cr_variaveis(pr_variaveis IN VARCHAR2) IS
      SELECT variavel
            ,regexp_substr(variavel, '[^=]+', 1, 1) chave
            ,SUBSTR(regexp_substr(variavel, '=.+'), 2) valor
        FROM (SELECT regexp_substr(pr_variaveis, '[^;]+', 1, LEVEL) variavel
                FROM dual
              CONNECT BY LEVEL <= regexp_count(pr_variaveis, '[^;]+'));
  
    vr_variaveis_universais VARCHAR2(4000);
    vr_result               CLOB;
  
  BEGIN
  
    vr_result := pr_mensagem;
  
    IF LENGTH(vr_result) = 0 THEN
      RETURN vr_result;
    END IF;
  
    vr_variaveis_universais := fn_obtem_variaveis_universais(pr_cdcooper => pr_cdcooper
                                                            ,pr_nrdconta => pr_nrdconta
                                                            ,pr_idseqttl => pr_idseqttl);
  
    -- Faz o replace de todas as variáveis
    FOR rw_variavel IN cr_variaveis(vr_variaveis_universais ||
                                    NVL(pr_variaveis, '')) LOOP
      vr_result := REPLACE(vr_result
                          ,rw_variavel.chave
                          ,'<b>' || rw_variavel.valor || '</b>');
    END LOOP;
  
    RETURN vr_result;
  
  END fn_substitui_variaveis; -- (Versão para CLOB)
  
  FUNCTION fn_gera_str_variaveis(pr_variaveis typ_variaveis_notif) RETURN VARCHAR2 IS
    vr_dsvariaveis tbgen_notificacao.dsvariaveis%TYPE;
    vr_chave VARCHAR(100);
  BEGIN
    
    vr_chave := pr_variaveis.first;
    WHILE (vr_chave IS NOT NULL) LOOP
      vr_dsvariaveis := vr_dsvariaveis || vr_chave||'='||pr_variaveis(vr_chave)||';';
      vr_chave := pr_variaveis.next(vr_chave);
    END LOOP;
    
    RETURN vr_dsvariaveis;
    
  END fn_gera_str_variaveis;

  PROCEDURE pc_cria_notificacoes(pr_cdmensagem    tbgen_notificacao.cdmensagem%TYPE
                                ,pr_dhenvio       DATE DEFAULT SYSDATE
                                ,pr_destinatarios typ_destinatarios_notif) IS
  
    push_pendente CONSTANT NUMBER(1) := 0;
  
    CURSOR cr_params IS
      SELECT NVL(msg.inenviar_push, 0) inenviar_push
            ,ori.cdorigem_mensagem
            ,NVL(ori.hrinicio_push, 0) hrinicio_push
            ,NVL(ori.hrfim_push, 0) hrfim_push
        FROM tbgen_notif_msg_cadastro msg
            ,tbgen_notif_msg_origem   ori
       WHERE msg.cdorigem_mensagem = ori.cdorigem_mensagem
         AND msg.cdmensagem = pr_cdmensagem;
    rw_params cr_params%ROWTYPE;
  
    CURSOR cr_dispositivos(pr_cdmensagem        tbgen_notificacao.cdmensagem%TYPE
                          ,pr_cdorigem_mensagem tbgen_notif_push_orig_prm.cdorigem_mensagem%TYPE
                          ,pr_dhcadastro        DATE) IS
      SELECT ntf.cdnotificacao
            ,dsp.dispositivomobileid
        FROM tbgen_notificacao         ntf
            ,dispositivomobile         dsp
            ,tbgen_notif_push_orig_prm prm
       WHERE ntf.cdcooper = dsp.cooperativaid
         AND ntf.nrdconta = dsp.numeroconta
         AND ntf.idseqttl = dsp.titularid
         AND dsp.autorizado = 1
         AND dsp.habilitado = 1
         AND dsp.pushhabilitado = 1
            
            -- Valida as permissões para push do cooperado
         AND ntf.cdcooper = prm.cdcooper(+)
         AND ntf.nrdconta = prm.nrdconta(+)
         AND ntf.idseqttl = prm.idseqttl(+)
         AND prm.cdorigem_mensagem(+) = pr_cdorigem_mensagem
         AND NVL(prm.inpush_ativo, 1) = 1
            
         AND ntf.cdmensagem = pr_cdmensagem
         AND ntf.dhcadastro = pr_dhcadastro;
    TYPE typ_tab_dispositivos IS TABLE OF cr_dispositivos%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_tab_dispositivos typ_tab_dispositivos;
  
    vr_sysdate DATE;
    vr_hrenvio NUMBER(10);
  
    -- Variáveis do envio de PUSH
    vr_dhenvio_push    DATE;
    vr_idx_lote_inicio PLS_INTEGER;
    vr_idx_lote_fim    PLS_INTEGER;
    vr_cdlote_push     tbgen_notif_lote_push.cdlote_push%TYPE;
  
  BEGIN
   
    IF pr_cdmensagem IS NULL OR pr_cdmensagem <= 0 THEN
      RETURN;
    END IF;
    
    vr_sysdate := SYSDATE; -- Obtém a data atual para padronizar os registros inseridos
  
    /*----------------CRIA OS REGISTROS DE NOTIFICAÇÃO AO COOPERADO--------------------*/
  
    FORALL idx IN 1 .. pr_destinatarios.count
      INSERT INTO tbgen_notificacao
        (cdcooper
        ,nrdconta
        ,idseqttl
        ,cdmensagem
        ,dsvariaveis
        ,dhenvio
        ,dhcadastro)
      VALUES
        (pr_destinatarios(idx).cdcooper
        ,pr_destinatarios(idx).nrdconta
        ,pr_destinatarios(idx).idseqttl
        ,pr_cdmensagem
        ,pr_destinatarios(idx).dsvariaveis
        ,pr_dhenvio
        ,vr_sysdate);
  
    COMMIT;
  
    /*------------------ENVIA OS PUSH NOTIFICATION PARA O CECRED MOBILE------------------*/
  
    --Obtém a parametrização de janela de envio de PUSH (para não enviar fora de hora)
    OPEN cr_params;
    FETCH cr_params
      INTO rw_params;
    CLOSE cr_params;
  
    -- Verifica se deve enviar push para esta mensagem
    IF rw_params.inenviar_push = 1 THEN
    
      vr_dhenvio_push := pr_dhenvio;
      vr_hrenvio := to_number(to_char(pr_dhenvio, 'SSSSS'));
    
      -- Se os dois parâmetros estiverem zerados é por que não tem janela, então envia push à qualquer hora
      IF rw_params.hrinicio_push > 0 OR rw_params.hrfim_push > 0 THEN
        IF vr_hrenvio < rw_params.hrinicio_push THEN
          -- Se ainda não chegou a hora início da janela de envio de push, então agenda para a hora início
          vr_dhenvio_push := TRUNC(pr_dhenvio) + (rw_params.hrinicio_push / 24 / 60 / 60);
        ELSIF vr_hrenvio > rw_params.hrfim_push THEN
          -- Se já passou da hora fim da janela do push, então agenda para a hora início do dia seguinte
          vr_dhenvio_push := TRUNC(pr_dhenvio) + 1 + (rw_params.hrinicio_push / 24 / 60 / 60);
        END IF;
      END IF;
    
      -- Obtém os dispositivos habilitados para push dos cooperados que receberam as notificações criadas acima
      OPEN cr_dispositivos(pr_cdmensagem        => pr_cdmensagem
                          ,pr_cdorigem_mensagem => rw_params.cdorigem_mensagem
                          ,pr_dhcadastro        => vr_sysdate);
      FETCH cr_dispositivos BULK COLLECT
        INTO vr_tab_dispositivos;
      CLOSE cr_dispositivos;
    
      -- GERA OS LOTES DE PUSH, DE 1000 EM 1000 REGISTROS (Quantidade que estiver na constante QTDMAXLOTEPUSH)
      vr_idx_lote_inicio := 1;
      vr_idx_lote_fim := 0;
      WHILE vr_idx_lote_inicio <= vr_tab_dispositivos.count LOOP
      
        BEGIN
        
          -- Insere o lote 
          INSERT INTO tbgen_notif_lote_push (dhagendamento)
          VALUES (vr_dhenvio_push)
          RETURNING cdlote_push INTO vr_cdlote_push;
        
          -- Calcula quantos registro inserir (1000 registros, a nao ser que na última iteração do LOOP restaram menos de 1000)
          vr_idx_lote_fim := vr_idx_lote_fim + qtdmaxlotepush;
          IF (vr_idx_lote_fim > vr_tab_dispositivos.count) THEN
            vr_idx_lote_fim := vr_tab_dispositivos.count;
          END IF;
        
          -- Insere os itens
          FORALL idx IN vr_idx_lote_inicio .. vr_idx_lote_fim
            INSERT INTO tbgen_notif_push
              (cdnotificacao
              ,iddispositivo_mobile
              ,cdlote_push
              ,insituacao)
            VALUES
              (vr_tab_dispositivos(idx).cdnotificacao
              ,vr_tab_dispositivos(idx).dispositivomobileid
              ,vr_cdlote_push
              ,push_pendente);
        
          COMMIT; -- COMMIT A CADA LOTE
        
          -- A próxima iteração do loop deve começar onde esta acabou
          vr_idx_lote_inicio := vr_idx_lote_fim + 1;
        
        EXCEPTION
          WHEN OTHERS THEN
            EXIT; -- Se ocorrer erro no envio do push, ignora e segue a vida... não precisamos parar o programa pcausa de erro no envio de PUSH
        END;
      
      END LOOP;
    
    END IF; -- IF rw_params.inenviar_push = 1
  
  END pc_cria_notificacoes;
  
  PROCEDURE pc_cria_notificacoes(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                                ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                                ,pr_dhenvio           DATE DEFAULT SYSDATE
                                ,pr_destinatarios typ_destinatarios_notif) IS
  
  CURSOR cr_mensagem IS
  SELECT aut.cdmensagem
    FROM tbgen_notif_automatica_prm aut
   WHERE aut.cdorigem_mensagem = pr_cdorigem_mensagem
     AND aut.cdmotivo_mensagem = pr_cdmotivo_mensagem;
  vr_cdmensagem tbgen_notificacao.cdmensagem%TYPE;
  
  BEGIN
    
    OPEN cr_mensagem;
    FETCH cr_mensagem
    INTO vr_cdmensagem;
    CLOSE cr_mensagem;
    
    IF vr_cdmensagem > 0 THEN
      pc_cria_notificacoes(pr_cdmensagem    => vr_cdmensagem
                          ,pr_dhenvio       => pr_dhenvio
                          ,pr_destinatarios => pr_destinatarios);
    END IF;
    
  END pc_cria_notificacoes;

  -- Cria uma notificação única (Recebe os dados da conta quebrados, um por parâmetro, com variáveis)
  PROCEDURE pc_cria_notificacao(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                               ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                               ,pr_dhenvio     DATE DEFAULT SYSDATE
                               ,pr_cdcooper    tbgen_notificacao.cdcooper%TYPE
                               ,pr_nrdconta    tbgen_notificacao.nrdconta%TYPE
                               ,pr_idseqttl    tbgen_notificacao.idseqttl%TYPE DEFAULT NULL
                               ,pr_variaveis   typ_variaveis_notif) IS
                               
    CURSOR cr_destinatarios(pr_dsvariaveis IN VARCHAR2) IS
    SELECT usu.cdcooper
          ,usu.nrdconta
          ,usu.idseqttl
          ,pr_dsvariaveis dsvariaveis
      FROM vw_usuarios_internet usu
     WHERE usu.cdcooper = pr_cdcooper
       AND usu.nrdconta = pr_nrdconta;
  
    vr_destinatarios typ_destinatarios_notif;
    vr_dsvariaveis tbgen_notificacao.dsvariaveis%TYPE;
    
  BEGIN
    
    vr_dsvariaveis := fn_gera_str_variaveis(pr_variaveis);
   
    IF pr_idseqttl IS NULL THEN -- Se não possuir titular, cria um registro para cada usuário da conta
      
      OPEN cr_destinatarios(vr_dsvariaveis);
     FETCH cr_destinatarios BULK COLLECT
      INTO vr_destinatarios;
     CLOSE cr_destinatarios;
                                 
    ELSE -- Se recebeu titular por parâmetro, cria apenas um registro fixo
      
      -- Cria um objeto de destinatário a partir dos parâmetros
      vr_destinatarios(1).cdcooper := pr_cdcooper;
      vr_destinatarios(1).nrdconta := pr_nrdconta;
      vr_destinatarios(1).idseqttl := pr_idseqttl;
      vr_destinatarios(1).dsvariaveis := vr_dsvariaveis;
       
    END IF;
    
    -- Cria as notificações
    noti0001.pc_cria_notificacoes(pr_cdorigem_mensagem => pr_cdorigem_mensagem
                                 ,pr_cdmotivo_mensagem => pr_cdmotivo_mensagem
                                 ,pr_dhenvio           => pr_dhenvio
                                 ,pr_destinatarios     => vr_destinatarios);
  
  END;
  
  -- Cria uma notificação única (Recebe os dados da conta quebrados, um por parâmetro, sem variáveis)
  PROCEDURE pc_cria_notificacao(pr_cdorigem_mensagem tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE
                               ,pr_cdmotivo_mensagem tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE
                               ,pr_dhenvio     DATE DEFAULT SYSDATE
                               ,pr_cdcooper    tbgen_notificacao.cdcooper%TYPE
                               ,pr_nrdconta    tbgen_notificacao.nrdconta%TYPE
                               ,pr_idseqttl    tbgen_notificacao.idseqttl%TYPE DEFAULT NULL) IS
                               
    vr_variaveis typ_variaveis_notif;
    
  BEGIN
  
    noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => pr_cdorigem_mensagem
                                ,pr_cdmotivo_mensagem => pr_cdmotivo_mensagem
                                ,pr_dhenvio    => pr_dhenvio   
                                ,pr_cdcooper   => pr_cdcooper  
                                ,pr_nrdconta   => pr_nrdconta  
                                ,pr_idseqttl   => pr_idseqttl
                                ,pr_variaveis  => vr_variaveis);
  
  END;

  PROCEDURE pc_job_notificacoes_autom(pr_dhexecucao IN DATE) IS
  
    CURSOR cr_mensagens IS
      WITH hoje AS
       (SELECT data
              ,to_char(data, 'DD') nrdia
              ,to_char(data, 'MM') nrmes
              ,to_char(data, 'D') nrdiasemana
              ,to_char(ceil(to_number(to_char(data, 'DD')) / 7)) nrsemana -- Obtém o dia e divide por 7, arredondando pra cima
              ,CASE WHEN to_number(to_char(last_day(data), 'DD')) - to_number(to_char(data, 'DD')) < 7 THEN 'U' END inultimasemana
          FROM (SELECT pr_dhexecucao data FROM dual))
      /*RECORRÊNCIA SEMANAL*/
      SELECT aut.cdorigem_mensagem
            ,aut.cdmotivo_mensagem
            ,aut.cdmensagem
            ,(TRUNC(hoje.data) + aut.hrenvio_mensagem / 60 / 60 / 24) dhenvio_mensagem
            ,aut.nmfuncao_contas
        FROM tbgen_notif_automatica_prm aut
            ,hoje
       WHERE aut.inmensagem_ativa = 1 -- ATIVAS
         AND (TRUNC(hoje.data) + aut.hrenvio_mensagem / 60 / 60 / 24) <= hoje.data -- Verifica se já chegou a hora de enviar a notificação
         AND TRUNC(aut.dhultima_execucao) < TRUNC(hoje.data)
         AND (aut.intipo_repeticao = 1 -- Semanal
             AND (INSTR(',' || aut.nrsemanas_repeticao || ',',',' || hoje.nrsemana || ',') > 0 -- Verifica se a semana atual está na lista de semanas para executar
              OR INSTR(',' || UPPER(aut.nrsemanas_repeticao) || ',',',' || hoje.inultimasemana || ',') > 0) -- Verifica se está na última semana do mês, e se deve executar
             AND INSTR(',' || aut.nrdias_semana || ',',',' || hoje.nrdiasemana || ',') > 0 -- Verifica se o dia da semana atual está na lista de dias da semana
             )
          OR (aut.intipo_repeticao = 2 -- Mensal
             AND INSTR(',' || aut.nrmeses_repeticao || ',',',' || hoje.nrmes || ',') > 0 -- Verifica se o mês atual está na lista de meses para executar
             AND INSTR(',' || aut.nrdias_mes || ',', ',' || hoje.nrdia || ',') > 0 -- Verifica se o dia de hj está na lista de dias para executar
             )
         FOR UPDATE;
    TYPE typ_cr_mensagens IS TABLE OF cr_mensagens%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_mensagens typ_cr_mensagens; -- Cria uma tabela temporária baseada no cursor
  
    vr_destinatarios typ_destinatarios_notif;
    
    -- Function para ler um SQL dinamicamente e salvar o resultado em uma temp table do tipo NOTI0001.TYP_DESTINATARIOS_NOTIF
    FUNCTION fn_obtem_destinatarios(pr_nmfuncao IN VARCHAR2)
      RETURN typ_destinatarios_notif IS
      vr_dscomd            VARCHAR2(4000);
      vr_sql_destinatarios CLOB;
      cr_destinatarios     SYS_REFCURSOR;
      vr_retorno           typ_destinatarios_notif;
    BEGIN
      vr_dscomd := 'begin :result := ' || pr_nmfuncao || '; end;';
      EXECUTE IMMEDIATE vr_dscomd
        USING OUT vr_sql_destinatarios;
      -- O retorno da function dinâmeica é um CLOB contendo um sql
      -- Isso pq o EXECUTE IMEDIATE não consegue retornar um tipo complexo, senão a function poderia retornar o TYP_DESTINATARIOS_NOTIF direto
    
      OPEN cr_destinatarios FOR vr_sql_destinatarios;
      FETCH cr_destinatarios BULK COLLECT
        INTO vr_retorno;
      CLOSE cr_destinatarios;
    
      RETURN vr_retorno;
    END fn_obtem_destinatarios;
  
  BEGIN
  
    -- Gera uma temp table com os dados do cursor (Para não deixar o cursor aberto muito tempo)
    OPEN cr_mensagens;
    FETCH cr_mensagens BULK COLLECT
      INTO vr_mensagens;
  
    -- Atualiza a data/hora da execução e comita para evitar conflito caso o job demore e execute novamente
    FORALL idx IN 1 .. vr_mensagens.count
      UPDATE tbgen_notif_automatica_prm aut
         SET aut.dhultima_execucao = pr_dhexecucao
       WHERE aut.cdorigem_mensagem = vr_mensagens(idx).cdorigem_mensagem
         AND aut.cdmotivo_mensagem = vr_mensagens(idx).cdmotivo_mensagem;
  
    CLOSE cr_mensagens;
    COMMIT;
  
    -- Percorre todas as mensagens que estão pendentes para ser enviadas agora
    FOR idx IN 1 .. vr_mensagens.count LOOP
      BEGIN
        vr_destinatarios := fn_obtem_destinatarios(vr_mensagens(idx).nmfuncao_contas);
      
        noti0001.pc_cria_notificacoes(pr_cdmensagem    => vr_mensagens(idx).cdmensagem
                                     ,pr_dhenvio       => vr_mensagens(idx).dhenvio_mensagem
                                     ,pr_destinatarios => vr_destinatarios);
      
        -- Comita para garantir que outro job não execute a mesma mensagem em paralelo
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          NULL; -- [TODO] Colocar log aqui
      END;
    
    END LOOP;
  
  END pc_job_notificacoes_autom;

  PROCEDURE pc_job_notificacoes_manuais(pr_dhexecucao IN DATE) IS
  
    CURSOR cr_mensagens IS
      SELECT man.cdmensagem
            ,man.tpfiltro -- Só gera as notif se for Filtro Manual (= 1) (As mensagens que importam CSV já geraram as notificações na hora)
            ,man.dhenvio_mensagem
            ,man.dsfiltro_cooperativas
            ,man.dsfiltro_tipos_conta
            ,man.tpfiltro_mobile
        FROM tbgen_notif_manual_prm man
       WHERE man.dhenvio_mensagem <= pr_dhexecucao
         AND man.cdsituacao_mensagem = 1 -- PENDENTE
         FOR UPDATE;
    TYPE typ_cr_mensagens IS TABLE OF cr_mensagens%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_mensagens typ_cr_mensagens; -- Cria uma tabela temporária baseada no cursor
  
    vr_destinatarios typ_destinatarios_notif;
  
    --Function para criar um SQL dinamicamente de acordo com os filtros e salvar o resultado em uma temp table do tipo NOTI0001.TYP_DESTINATARIOS_NOTIF
    FUNCTION fn_obtem_destinatarios(pr_dsfiltro_cooperativas tbgen_notif_manual_prm.dsfiltro_cooperativas%TYPE
                                   ,pr_dsfiltro_tipos_conta  tbgen_notif_manual_prm.dsfiltro_tipos_conta%TYPE
                                   ,pr_tpfiltro_mobile       tbgen_notif_manual_prm.tpfiltro_mobile%TYPE)
      RETURN typ_destinatarios_notif IS
      cr_destinatarios     SYS_REFCURSOR;
      vr_sql_destinatarios CLOB;
      vr_retorno           typ_destinatarios_notif;
    BEGIN
    
      -- MONTA A QUERY DE ACORDO COM OS FILTROS
      vr_sql_destinatarios := 'SELECT usr.cdcooper,usr.nrdconta,usr.idseqttl,NULL dsvariaveis ' ||
                                'FROM vw_usuarios_internet usr ' ||
                               'WHERE 1 = 1';
    
      -- Filtro de cooperativas
      IF (NVL(REPLACE(pr_dsfiltro_cooperativas, ',', ''), '0') <> '0') THEN
        vr_sql_destinatarios := vr_sql_destinatarios || ' AND usr.cdcooper IN (' || pr_dsfiltro_cooperativas || ')';
      END IF;
    
      -- Filtro de Tipo de Conta
      IF (NVL(REPLACE(pr_dsfiltro_tipos_conta, ',', ''), '0') <> '0') THEN
        vr_sql_destinatarios := vr_sql_destinatarios || ' AND usr.inpessoa IN (' || pr_dsfiltro_tipos_conta || ')';
      END IF;
    
      -- Filtro de plataforma
      IF (pr_tpfiltro_mobile > 0) THEN
        --0-Todas as plataformas/ 1-Cooperados sem Mobile/ 2-Cooperados com Mobile/ 3-Somente Android/ 4-Somente IOS
      
        vr_sql_destinatarios := vr_sql_destinatarios || ' AND (usr.cdcooper, usr.nrdconta, usr.idseqttl) ';
        -- Se for 1 (Cooperados sem Mobile) então faz NOT IN, senão faz IN
        vr_sql_destinatarios := vr_sql_destinatarios || CASE WHEN pr_tpfiltro_mobile = 1 THEN 'NOT IN' ELSE 'IN' END;
        vr_sql_destinatarios := vr_sql_destinatarios || '(SELECT dsp.cooperativaid,dsp.numeroconta,dsp.titularid ' ||
                                                           'FROM dispositivomobile dsp ' ||
                                                          'WHERE dsp.pushhabilitado = 1 ' ||
                                                            'AND dsp.autorizado = 1 ' ||
                                                            'AND dsp.habilitado = 1 ';
        IF pr_tpfiltro_mobile = 3 THEN
          -- Android
          vr_sql_destinatarios := vr_sql_destinatarios || 'AND dsp.plataforma = ''Android'' ';
        ELSIF pr_tpfiltro_mobile = 4 THEN
          -- IOS
          vr_sql_destinatarios := vr_sql_destinatarios || 'AND dsp.plataforma IN (''iOS'', ''iPhone OS'') ';
        END IF;
      
        vr_sql_destinatarios := vr_sql_destinatarios || ')';
      END IF;
    
      OPEN cr_destinatarios FOR vr_sql_destinatarios;
      FETCH cr_destinatarios BULK COLLECT
        INTO vr_retorno;
      CLOSE cr_destinatarios;
    
      RETURN vr_retorno;
    END fn_obtem_destinatarios;
  
  BEGIN
  
    -- Gera uma temp table com os dados do cursor (Para não deixar o cursor aberto muito tempo)
    OPEN cr_mensagens;
    FETCH cr_mensagens BULK COLLECT
      INTO vr_mensagens;
  
    -- Atualiza a situação para enviada (para que outra instância do job não capture este registro e gere novamente)
    FORALL idx IN 1 .. vr_mensagens.count
      UPDATE tbgen_notif_manual_prm man
         SET man.cdsituacao_mensagem = 2 -- ENVIADA
       WHERE man.cdmensagem = vr_mensagens(idx).cdmensagem;
  
    CLOSE cr_mensagens;
    COMMIT;
  
    -- Percorre todas as mensagens que estão pendentes para ser enviadas agora
    FOR idx IN 1 .. vr_mensagens.count LOOP
    
      BEGIN
        vr_destinatarios := fn_obtem_destinatarios(pr_dsfiltro_cooperativas => vr_mensagens(idx).dsfiltro_cooperativas
                                                  ,pr_dsfiltro_tipos_conta  => vr_mensagens(idx).dsfiltro_tipos_conta
                                                  ,pr_tpfiltro_mobile       => vr_mensagens(idx).tpfiltro_mobile);
      
        noti0001.pc_cria_notificacoes(pr_cdmensagem    => vr_mensagens(idx).cdmensagem
                                     ,pr_dhenvio       => vr_mensagens(idx).dhenvio_mensagem
                                     ,pr_destinatarios => vr_destinatarios);
      
        -- Comita para garantir que outro job não execute a mesma mensagem em paralelo
        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          -- Se ocorreu erro, cancela o envio
          UPDATE tbgen_notif_manual_prm man
             SET man.cdsituacao_mensagem = 3 -- CANCELADA
           WHERE man.cdmensagem = vr_mensagens(idx).cdmensagem;
          COMMIT;
          -- [TODO] Colocar log aqui
      END;
    
    END LOOP;
  
  END pc_job_notificacoes_manuais;

  PROCEDURE pc_job_dispara_push_mobile(pr_dhexecucao IN DATE) IS
  
    CURSOR cr_lotes IS
      SELECT lot.cdlote_push
        FROM tbgen_notif_lote_push lot
       WHERE lot.dhexecucao IS NULL
         AND dhagendamento <= pr_dhexecucao
         AND dhagendamento > pr_dhexecucao - 1 -- Só considera até 1 dia atrás
         FOR UPDATE;
    TYPE typ_cr_lotes IS TABLE OF cr_lotes%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_lotes typ_cr_lotes; -- Cria uma tabela temporária baseada no cursor
  
		-- Variáveis para utilizar o Aymaru
		vr_resposta AYMA0001.typ_http_response_aymaru;
		vr_parametros WRES0001.typ_tab_http_parametros;
    vr_conteudo json := json();
    
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(10000);
    
    ex_erro EXCEPTION;
    
  BEGIN
  
    -- Gera uma temp table com os dados do cursor (Para não deixar o cursor aberto muito tempo)
    OPEN cr_lotes;
    FETCH cr_lotes BULK COLLECT
      INTO vr_lotes;
  
    -- Atualiza a data da execução (para que outra instância do job não capture este registro e envie o push novamente)
    FORALL idx IN 1 .. vr_lotes.count
      UPDATE tbgen_notif_lote_push lot
         SET lot.dhexecucao = SYSDATE
       WHERE lot.cdlote_push = vr_lotes(idx).cdlote_push;
  
    FORALL idx IN 1 .. vr_lotes.count
      UPDATE tbgen_notif_push psh
         SET psh.dhenvio      = SYSDATE
            ,psh.nrtentativas = psh.nrtentativas + 1
            ,psh.insituacao   = 1 -- Processando no Aymaru
       WHERE psh.cdlote_push = vr_lotes(idx).cdlote_push
         AND psh.insituacao = 0; --PENDENTE
  
    CLOSE cr_lotes;
    COMMIT;
  
    -- Percorre todos os lotes e avisa o Aymaru para processá-los
    FOR idx IN 1 .. vr_lotes.count LOOP
      BEGIN
        
      vr_conteudo.put('Lote', vr_lotes(idx).cdlote_push ); -- Codigo do lote de push
			-- Consumir rest do AYMARU
			AYMA0001.pc_consumir_ws_rest_aymaru(pr_rota => '/Mobile/Push/Enviar'
																				 ,pr_verbo => WRES0001.POST
																				 ,pr_servico => 'PUSH.MOBILE'
																				 ,pr_parametros => vr_parametros
																				 ,pr_conteudo => vr_conteudo
																				 ,pr_resposta => vr_resposta
																				 ,pr_dscritic => vr_dscritic
																				 ,pr_cdcritic => vr_cdcritic);
                                         
        -- Se retornou alguma crítica														 
        IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Gerar crítica
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao tentar enviar o push.';
          RAISE ex_erro;
        END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          -- Se ocorreu erro, seta todos os pushes do lote para ERRO
          UPDATE tbgen_notif_push psh
             SET psh.insituacao = 3 -- ERRO
           WHERE psh.cdlote_push = vr_lotes(idx).cdlote_push
             AND psh.insituacao = 1; -- Processando no Aymaru
          COMMIT;
          -- [TODO] Colocar log aqui
          -- (Utilizar vr_cdcritic e vr_dscritic)
      END;
    END LOOP;
  
  END pc_job_dispara_push_mobile;

  PROCEDURE pc_processa_retorno_push(pr_cdlote_push IN tbgen_notif_lote_push.cdlote_push%TYPE
                                    ,pr_xmlerros    IN XMLTYPE) IS
  
    CURSOR cr_status IS
    SELECT psh.cdnotificacao
          ,psh.iddispositivo_mobile
          ,DECODE(err.cdnotificacao,NULL, 2, 3) insituacao -- 2 - Sucesso, 3 - Erro
          ,err.cdstatus
          ,err.dsstatus
      FROM tbgen_notif_push psh
          ,XMLTABLE('lote/pushesinvalidos/push' PASSING
                    pr_xmlerros
                    COLUMNS cdnotificacao NUMBER(15) PATH '/push/cdnotificacao'
                           ,iddispositivo_mobile NUMBER(20) PATH '/push/iddispositivo'
                           ,cdstatus NUMBER(5) PATH '/push/cdstatus'
                           ,dsstatus VARCHAR2(1000) PATH '/push/dsstatus') err
     WHERE psh.cdnotificacao = err.cdnotificacao(+)
       AND psh.iddispositivo_mobile = err.iddispositivo_mobile(+)
       AND psh.cdlote_push = pr_cdlote_push;
    TYPE typ_cr_status IS TABLE OF cr_status%ROWTYPE INDEX BY BINARY_INTEGER;
    vr_status typ_cr_status; -- Cria uma tabela temporária baseada no cursor
    
  BEGIN
    
    -- Gera uma temp table com os dados do cursor (Para não deixar o cursor aberto muito tempo)
    OPEN cr_status;
    FETCH cr_status BULK COLLECT
      INTO vr_status;
    CLOSE cr_status;
    
    FORALL idx IN 1 .. vr_status.count
      UPDATE tbgen_notif_push psh
         SET psh.insituacao = vr_status(idx).insituacao
            ,psh.cdstatus = vr_status(idx).cdstatus
            ,psh.dsstatus = vr_status(idx).dsstatus
       WHERE psh.cdnotificacao = vr_status(idx).cdnotificacao
         AND psh.iddispositivo_mobile = vr_status(idx).iddispositivo_mobile;
  
    COMMIT;
  
  END pc_processa_retorno_push;

END NOTI0001;
/
