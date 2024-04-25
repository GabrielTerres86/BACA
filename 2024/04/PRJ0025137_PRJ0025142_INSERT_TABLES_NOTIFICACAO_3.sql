DECLARE
  v_cdmensagem CECRED.tbgen_notif_msg_cadastro.cdmensagem%type;
BEGIN
  
  select max(cdmensagem)
    into v_cdmensagem
    from CECRED.tbgen_notif_msg_cadastro;
  
  IF (v_cdmensagem is null or v_cdmensagem = 0) THEN
    v_cdmensagem := 1;
  ELSE
    v_cdmensagem := v_cdmensagem + 1;
  END IF;
  
  dbms_output.put_line('Inserindo CECRED.tbgen_notif_automatica_prm'); 
  INSERT INTO CECRED.tbgen_notif_automatica_prm
  (cdorigem_mensagem
  ,cdmotivo_mensagem
  ,dsmotivo_mensagem
  ,cdmensagem
  ,dsvariaveis_mensagem
  ,inmensagem_ativa
  ,intipo_repeticao)
  VALUES
  (17
  ,1
  ,'Consentimento Pagamento Pix via OpenFinance de conta Multipla Alcada'
  ,v_cdmensagem
  ,'<br />#urlopenfinance - Url de acesso ao Portal OpenFinance'
  ,1
  ,0);  
  
  v_cdmensagem := v_cdmensagem + 1;
  dbms_output.put_line('Codigo da Mensagem, para insert na tabela CECRED.tbgen_notif_msg_cadastro, para Notificacao da V1: ' || v_cdmensagem);
    
  dbms_output.put_line('Inserindo CECRED.tbgen_notif_msg_cadastro'); 
  INSERT INTO CECRED.tbgen_notif_msg_cadastro
  (cdmensagem
  ,cdorigem_mensagem
  ,dstitulo_mensagem
  ,dstexto_mensagem
  ,dshtml_mensagem
  ,cdicone
  ,inexibir_banner
  ,inexibe_botao_acao_mobile
  ,inenviar_push)
  VALUES
  (v_cdmensagem
  ,17
  ,'Consentimento Transf. Inteligentes Pendente'
  ,'Cooperado, você possui um Consentimento de Transferencias Inteligentes pendente de aprovação. Acesse #urlopenfinance para saber mais.'
  ,'Cooperado,<br /><br /> você possui um Consentimento de Transferencias Inteligentes OpenFinance pendente de aprovação.<br /><br /> Acesse #urlopenfinance no menu Minhas Autorizações para saber mais.'
  ,16
  ,0
  ,0
  ,1);
  
  dbms_output.put_line('Inserindo CECRED.tbgen_notif_automatica_prm'); 
  INSERT INTO CECRED.tbgen_notif_automatica_prm
  (cdorigem_mensagem
  ,cdmotivo_mensagem
  ,dsmotivo_mensagem
  ,cdmensagem
  ,dsvariaveis_mensagem
  ,inmensagem_ativa
  ,intipo_repeticao)
  VALUES
  (17
  ,2
  ,'Consentimento Transferencias Inteligentes de conta Multipla Alcada'
  ,v_cdmensagem
  ,'<br />#urlopenfinance - Url de acesso ao Portal OpenFinance'
  ,1
  ,0);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao inserir tabelas de notificacoes: ' || sqlerrm);
    rollback; 
END; 
