DECLARE
	codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Altera��o de limites Pix', 'O ajuste de limite Pix que voc� solicitou foi realizado com sucesso.', '#nomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#limiteDiurno <br>Transa��o: R$#limiteDiurnoPorTransacao <br><br>NOTURNO <br>Per�odo: R$#limiteNoturno <br>Transa��o: R$#limiteNoturnoPorTransacao <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 44, 'PIX - Efetiva��o novos limites', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#limiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#limiteDiurnoPorTransacao - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#limiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#limiteNoturnoPorTransacao - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Altera��o de limites Pix Saque/Troco', 'O ajuste de limite Pix Saque e Pix Troco que voc� solicitou foi realizado com sucesso.', '#nomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que voc� solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#limiteDiurno <br>Transa��o: R$#limiteDiurnoPorTransacao <br><br>NOTURNO <br>Per�odo: R$#limiteNoturno <br>Transa��o: R$#limiteNoturnoPorTransacao <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 45, 'PIX - Efetiva��o novos limites Saque/Troco', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#limiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#limiteDiurnoPorTransacao - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#limiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#limiteNoturnoPorTransacao - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Altera��o de limites Pix de uma conta cadastrada', 'O ajuste de limite Pix que voc� solicitou foi realizado com sucesso.', '#nomeCooperado, <br><br>O ajuste de limite Pix que voc� solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #nomeContaCadastrada <br>Banco: #bancoContaCadastrada <br>Ag�ncia: #agenciaContaCadastrada <br>Conta: #numeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Per�odo: R$#limiteDiurno <br>Transa��o: R$#limiteDiurnoPorTransacao <br><br>NOTURNO <br>Per�odo: R$#limiteNoturno <br>Transa��o: R$#limiteNoturnoPorTransacao <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 46, 'PIX - Efetiva��o novos limites de uma conta cadastrada', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#nomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#bancoContaCadastrada - C�digo e descri��o do banco da conta cadastrada<br>#agenciaContaCadastrada - Agencia da conta cadastrada<br>#numeroContaCadastrada - N�mero da conta cadastrada<br>#limiteDiurno - Valor do novo limite do per�odo diurno (Ex.: 1000,00)<br>#limiteDiurnoPorTransacao - Valor do novo limite por transa��o do per�odo diurno (Ex.: 1000,00)<br>#limiteNoturno - Valor do novo limite do per�odo noturno (Ex.: 1000,00)<br>#limiteNoturnoPorTransacao - Valor do novo limite por transa��o do per�odo noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Aumento de limite m�ximo do Pix', 'O aumento de limite m�ximo do Pix que voc� solicitou foi realizado com sucesso.', '#nomeCooperado, <br><br>O aumento de limite m�ximo do Pix que voc� solicitou foi realizado com sucesso. <br><br>Novo limite m�ximo: R$#novoLimite. <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 47, 'PIX - Efetiva��o novo limite total', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#novoLimite - Valor do novo limite (Ex.: 5000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Efetiva��o de uma conta cadastrada', 'O cadastro da conta que voc� solicitou foi realizado com sucesso.', '#nomeCooperado, <br><br>O cadastro da conta que voc� solicitou foi realizado com sucesso. Voc� j� pode gerenciar de forma personalizada os limites Pix dessa conta. <br><br>Dados da Conta: <br><br>Nome: #nomeContaCadastrada <br>Banco: #bancoContaCadastrada <br>Ag�ncia: #agenciaContaCadastrada <br>Conta: #numeroContaCadastrada <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 48, 'PIX - Efetiva��o novos limites de uma conta cadastrada', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#nomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#bancoContaCadastrada - C�digo e descri��o do banco da conta cadastrada<br>#agenciaContaCadastrada - Agencia da conta cadastrada<br>#numeroContaCadastrada - N�mero da conta cadastrada');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Efetiva��o de novo hor�rio noturno', 'A altera��o de hor�rio do per�odo noturno que voc� solicitou foi realizada com sucesso.', '#nomeCooperado, <br><br>A altera��o de hor�rio do per�odo noturno que voc� solicitou foi realizada com sucesso. <br><br>Novo hor�rio do per�odo noturno: <br><br>In�cio: #horarioInicio <br>Fim: #horarioFim <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.', 9, 0, 1, 'Tirar d�vidas!', 1042, 'Tirar d�vidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 49, 'PIX - Efetiva��o de novo hor�rio noturno', codigoMensagem, 1, 0, '<br>#nomeCooperado - Nome do cooperado<br>#horarioInicio - Hor�rio de inicio do periodo noturno. Ex: 21:00<br>#horarioFim - Hor�rio de fim do periodo noturno Ex: 06:00');

END;
