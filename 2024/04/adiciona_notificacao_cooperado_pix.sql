DECLARE
  codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
  SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
  INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem,
  cdicone, inexibe_botao_acao_mobile, cdmenu_acao_mobile, inenviar_push) VALUES
  (codigoMensagem, 13, 'Chave Pix removida', 'Informamos que a sua chave Pix #chave foi removida por questões de segurança, de acordo com as normas estabelecidas pelo Banco Central',
  '#nomeCooperado, <br><br>Informamos que a sua chave Pix #chave foi removida por questões de segurança, de acordo com as normas estabelecidas pelo Banco Central.',
  16, 0, 0, 1);
 
  INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
  (13, 66, 'Pix - Chave Pix removida', codigoMensagem, 1, 0,
  '<br>#nomeCooperado - Nome do cooperado<br>Informamos que a sua chave Pix #chave foi removida por questões de segurança, de acordo com as normas estabelecidas pelo Banco Central.');
 
  commit;
END;