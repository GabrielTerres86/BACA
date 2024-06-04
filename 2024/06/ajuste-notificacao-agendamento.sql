DECLARE
BEGIN
	UPDATE TBGEN_NOTIF_AUTOMATICA_PRM
	SET DSVARIAVEIS_MENSAGEM = '#nomeresumido,<br><br> Seu pagamento Pix que estava agendado para hoje não foi realizado, irão acontecer novas tentativas durante o dia.<br><br> Beneficiário: #beneficiario <br> Valor: #valorpix <br><br> Verifique seu limite diário Pix ou o saldo em conta corrente.'
	WHERE CDMOTIVO_MENSAGEM = 20
	AND CDORIGEM_MENSAGEM = 13;
COMMIT;
END;
