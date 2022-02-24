DECLARE
BEGIN
  
  INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
  (7892, 13, 'Devolução de Pix Saque recebida', 'Você recebeu a devolução de um Pix Saque que realizou.', 'O Pix Saque que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvido <b>#parcialtotalmente.</br></br> O valor está novamente disponível em sua conta corrente.</b></br></br> Acesse o comprovante para mais detalhes da devolução.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);

  INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
  (7893, 13, 'Devolução de Pix Troco recebida', 'Você recebeu a devolução de um Pix Troco que realizou.', 'A parcela #parcelacompratroco do Pix Troco que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvida <b>#parcialtotalmente.</br></br> O valor está novamente disponível em sua conta corrente.</b></br></br> Acesse o comprovante para mais detalhes da devolução.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);

  INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
  (13, 39, 'PIX - Recebimento de devolução Pix Saque', 7892, 1, 0, '</br>#horatransacao - Hora da transação (Ex.: 10:30)</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#beneficiario - Nome do beneficiário</br>#parcialtotalmente - Tipo da devolução (Parcial/Totalmente)');

  INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
  (13, 40, 'PIX - Recebimento de devolução Pix Troco', 7893, 1, 0, '</br>#parcelacompratroco - Tipo da parcela (Ex.: Compra/Troco)</br>#horatransacao - Hora da transação (Ex.: 10:30)</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#beneficiario - Nome do beneficiário</br>#parcialtotalmente - Tipo da devolução (Parcial/Totalmente)');

  COMMIT;
END;