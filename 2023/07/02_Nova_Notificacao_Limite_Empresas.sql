DECLARE
    codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
 INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
    (codigoMensagem, 13, 'Altera��o de limites Pix para Empresas', 'O ajuste de limite Pix para Empresas, que voc� solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O ajuste de limite Pix para Empresas, que voc� solicitou foi realizado com sucesso. <br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 58, 'Altera��o de limites Pix para Empresas', codigoMensagem, 1, 0, '#NomeCooperado, <br><br>O ajuste de limite Pix para Empresas, que voc� solicitou foi realizado com sucesso. <br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.');	
commit;
END;
