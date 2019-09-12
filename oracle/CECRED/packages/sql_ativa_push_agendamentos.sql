UPDATE tbgen_notif_msg_cadastro msg
   SET msg.inenviar_push = 1
 WHERE msg.cdorigem_mensagem = 3;
