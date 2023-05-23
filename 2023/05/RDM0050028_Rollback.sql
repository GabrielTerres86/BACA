BEGIN
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$ #LimiteDiurno <br>Transa��o: R$ #PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$ #LimiteNoturno <br>Transa��o: R$ #PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9280;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = -'<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 44 AND CDMENSAGEM = 9280;
	
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$ #LimiteDiurno <br>Transa��o: R$ #PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$ #LimiteNoturno <br>Transa��o: R$ #PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9281;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#nomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 45 AND CDMENSAGEM = 9281;
	
	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSHTML_MENSAGEM = '#NomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Ag�ncia: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Per�odo: R$ #LimiteDiurno <br>Transa��o: R$ #PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Per�odo: R$ #LimiteNoturno <br>Transa��o: R$ #PorTransacaoLimiteNoturno <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM = 9282;
	
	UPDATE CECRED.TBGEN_NOTIF_AUTOMATICA_PRM SET DSVARIAVEIS_MENSAGEM = '<br>#nomeCooperado - Nome do cooperado<br>#NomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#BancoContaCadastrada - C�digo e descri��o do banco da conta cadastrada<br>#AgenciaContaCadastrada - Agencia da conta cadastrada<br>#NumeroContaCadastrada - N�mero da conta cadastrada<br>#LimiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#LimiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteNoturno - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)'
	WHERE CDORIGEM_MENSAGEM = 13 AND CDMOTIVO_MENSAGEM = 46 AND CDMENSAGEM = 9282;
COMMIT;
END;