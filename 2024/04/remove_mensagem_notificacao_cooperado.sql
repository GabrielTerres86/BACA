BEGIN
	DELETE FROM tbgen_notif_automatica_prm WHERE cdmensagem = 24890;
	DELETE FROM tbgen_notif_msg_cadastro WHERE cdmensagem = 24890;
	COMMIT;
END;