BEGIN
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#nomeresumido, <br><br> Seu pagamento Pix que estava agendado para hoje n�o foi realizado devido a uma falha no processamento. <br><br> Benefici�rio: #beneficiario <br> Valor: #valorpix <br><br>  Por favor, refa�a o pagamento ou agendamento.'
	WHERE CDORIGEM_MENSAGEM = 13 and cdmensagem = 6624;
COMMIT;
END;