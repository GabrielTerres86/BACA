BEGIN
  UPDATE tbgen_notif_msg_cadastro
     SET inexibe_botao_acao_mobile = 0,
         dstexto_botao_acao_mobile = NULL
   WHERE cdorigem_mensagem = 15;
   COMMIT;
END;
