DECLARE
    codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN

 DELETE FROM CECRED.tbgen_notif_automatica_prm WHERE cdorigem_mensagem = 13 AND cdmotivo_mensagem = 58 AND cdmensagem = 12421;

 SELECT (max(cdmensagem) + 1) into codigoMensagem FROM CECRED.tbgen_notif_msg_cadastro;
 INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
    (codigoMensagem, 13, 'Alteração de limites Pix para Empresas', 'O ajuste de limite Pix para Empresas, que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O ajuste de limite Pix para Empresas, que você solicitou foi realizado com sucesso. <br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 INSERT INTO CECRED.tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
    (13, 58, 'Alteração de limites Pix para Empresas', codigoMensagem, 1, 0, '#NomeCooperado, <br><br>O ajuste de limite Pix para Empresas, que você solicitou foi realizado com sucesso. <br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.');	

 INSERT INTO CECRED.MENUMOBILE (MENUMOBILEID, MENUPAIID, NOME, SEQUENCIA, HABILITADO, AUTORIZACAO, VERSAOMINIMAAPP, VERSAOMAXIMAAPP)
 VALUES (1051, 1021, 'Limites Pix para Empresas', 1, 1, 1, '2.53.0', NULL);
 
 INSERT INTO PIX.TBPIX_TIPO_LIMITE (IDTIPO_LIMITE, NMTIPO_LIMITE) VALUES (4, 'Transferencia para empresas');

COMMIT;
END;
