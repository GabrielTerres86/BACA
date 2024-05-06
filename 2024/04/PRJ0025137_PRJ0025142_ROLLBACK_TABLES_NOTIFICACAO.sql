DECLARE
  v_cdmensagem CECRED.tbgen_notif_msg_cadastro.cdmensagem%type;
BEGIN
  dbms_output.put_line('Removendo CECRED.tbgen_notif_automatica_prm'); 
  DELETE FROM CECRED.tbgen_notif_automatica_prm
   WHERE 1=1
     AND cdorigem_mensagem = 17
     AND cdmotivo_mensagem = 1;
     
  select cdmensagem
    into v_cdmensagem
    from CECRED.tbgen_notif_msg_cadastro
   where 1=1
     and cdorigem_mensagem = 17
     and dstitulo_mensagem = 'Consentimento Pendente Aprovacao';
  
  dbms_output.put_line('Codigo da Mensagem encontrado, para remocao na tabela CECRED.tbgen_notif_msg_cadastro: ' || v_cdmensagem);
  
  dbms_output.put_line('Removendo registro em CECRED.tbgen_notif_msg_cadastro'); 
  DELETE FROM CECRED.tbgen_notif_msg_cadastro
   WHERE cdmensagem = v_cdmensagem;

  dbms_output.put_line('Removendo CECRED.tbgen_notif_msg_origem'); 
  DELETE FROM CECRED.tbgen_notif_msg_origem
  WHERE cdorigem_mensagem = 17;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao remover tabelas de notificacoes: ' || sqlerrm); 
END; 
