DECLARE
    codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
  SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
    INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
    (codigoMensagem, 13, 'Voc� enviou um Pix', 'Voc� enviou um Pix de R$ #ValorPix. A transa��o j� foi conclu�da.', 'Cooperado, <br><br>Voc� enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor do pagamento: #ValorPix <br>Institui��o: #Instituicao <br> Identifica��o: #Identificacao <br>Descri��o: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);
    
    INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 53, 'PIX - Voc� enviou um Pix', codigoMensagem, 1, 0, '<br>#NomeRecebedor - Nome do Recebedor<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#Instituicao - Nome da Institui��o<br>#Identificacao - Identifica��o do Pix<br>#Descricao - Descri��o do Pagamento');
    commit;
  
  SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
    INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
    (codigoMensagem, 13, 'Voc� enviou um Pix', 'Voc� enviou um Pix de R$ #ValorPix. A transa��o j� foi conclu�da.', 'Cooperado, <br><br>Voc� enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor do pagamento: #ValorPix <br>Valor da tarifa: #ValorTarifaPix <br>Institui��o: #Instituicao <br> Identifica��o: #Identificacao <br>Descri��o: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.', 16, 0, 1, 'Ver comprovante', 400, 'Ver comprovante', 1);
    
    INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 54, 'PIX - Voc� enviou um Pix', codigoMensagem, 1, 0, '<br>#NomeRecebedor - Nome do Recebedor<br>#ValorPix - Valor do pagamento (Ex.: 5000,00)<br>#ValorTarifaPix# - Valor da tarifa (Ex.: 5,00)<br>Instituicao - Nome da Institui��o<br>#Identificacao - Identifica��o do Pix<br>#Descricao - Descri��o do Pagamento');
    commit;
END;