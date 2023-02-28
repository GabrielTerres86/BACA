BEGIN
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$ #LimiteDiurno <br><br>NOTURNO <br>Período: R$ #LimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9280;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 44 AND CDMENSAGEM = 9280;
	
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$ #LimiteDiurno <br><br>NOTURNO <br>Período: R$ #LimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9281;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 45 AND CDMENSAGEM = 9281;
	
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Agência: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Período: R$ #LimiteDiurno <br><br>NOTURNO <br>Período: R$ #LimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9282;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#nomeCooperado - Nome do cooperado<br>#NomeContaCadastrada - Nome do beneficiário da conta cadastrada<br>#BancoContaCadastrada - Código e descrição do banco da conta cadastrada<br>#AgenciaContaCadastrada - Agência da conta cadastrada<br>#NumeroContaCadastrada - Número da conta cadastrada<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do período noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 46 AND CDMENSAGEM = 9282;
COMMIT;
END;