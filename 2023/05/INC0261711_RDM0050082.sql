BEGIN
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#nomeresumido, <br><br> Seu pagamento Pix que estava agendado para hoje não foi realizado devido a uma falha no processamento. <br><br> Beneficiário: #beneficiario <br> Valor: #valorpix <br><br>  Por favor, refaça o pagamento ou agendamento.'
	WHERE CDORIGEM_MENSAGEM = 13 and cdmensagem = 6624;
COMMIT;
END;