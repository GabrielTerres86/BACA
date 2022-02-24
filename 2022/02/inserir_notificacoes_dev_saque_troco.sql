DECLARE
BEGIN
  
  INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
  (7892, 13, 'Devolu��o de Pix Saque recebida', 'Voc� recebeu a devolu��o de um Pix Saque que realizou.', 'O Pix Saque que voc� realizou �s #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvido <b>#parcialtotalmente.</br></br> O valor est� novamente dispon�vel em sua conta corrente.</b></br></br> Acesse o comprovante para mais detalhes da devolu��o.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);

  INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
  (7893, 13, 'Devolu��o de Pix Troco recebida', 'Voc� recebeu a devolu��o de um Pix Troco que realizou.', 'A parcela #parcelacompratroco do Pix Troco que voc� realizou �s #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvida <b>#parcialtotalmente.</br></br> O valor est� novamente dispon�vel em sua conta corrente.</b></br></br> Acesse o comprovante para mais detalhes da devolu��o.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);

  INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
  (13, 39, 'PIX - Recebimento de devolu��o Pix Saque', 7892, 1, 0, '</br>#horatransacao - Hora da transa��o (Ex.: 10:30)</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#beneficiario - Nome do benefici�rio</br>#parcialtotalmente - Tipo da devolu��o (Parcial/Totalmente)');

  INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
  (13, 40, 'PIX - Recebimento de devolu��o Pix Troco', 7893, 1, 0, '</br>#parcelacompratroco - Tipo da parcela (Ex.: Compra/Troco)</br>#horatransacao - Hora da transa��o (Ex.: 10:30)</br>#valorpix - Valor do Pix (Ex.: 45,00)</br>#beneficiario - Nome do benefici�rio</br>#parcialtotalmente - Tipo da devolu��o (Parcial/Totalmente)');

  COMMIT;
END;