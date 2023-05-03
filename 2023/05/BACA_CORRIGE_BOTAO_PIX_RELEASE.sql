BEGIN

	UPDATE cecred.tbgen_notif_msg_cadastro tnmc
	SET tnmc.dstexto_botao_acao_mobile = 'Pix',
	tnmc.dsmensagem_acao_mobile = 'Pix'
	WHERE tnmc.cdmensagem = 5460
	AND tnmc.cdorigem_mensagem = 13;
	
	COMMIT;
END;