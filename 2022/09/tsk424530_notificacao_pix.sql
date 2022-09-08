DECLARE
    codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
    INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
    (codigoMensagem, 13, 'Voc� enviou um Pix', 'Voc� enviou um Pix de R$ #ValorPix. A transa��o j� foi conclu�da', 'Cooperado, <br><br>Voc� enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor: #ValorPix <br>Institui��o: #Instituicao <br>Descri��o: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira extrato da sua conta corrente.', 16, 0, 1, 'Ver comprovantes', 400, 'Ver comprovantes', 1);
    
    INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 53, 'Voc� enviou um Pix', codigoMensagem, 1, 0, 'Cooperado, <br><br>Voc� enviou um Pix.<br><br>Recebedor: #NomeRecebedor <br>Valor: #ValorPix <br>Institui��o: #Instituicao <br>Descri��o: #Descricao <br><br>Acesse o comprovante no App Ailos ou confira extrato da sua conta corrente.');
    commit;
END;
