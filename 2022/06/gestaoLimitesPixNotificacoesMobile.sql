DECLARE
	codigoMensagem tbgen_notif_msg_cadastro.cdmensagem%TYPE := 0;
BEGIN
	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Alteração de limites Pix', 'O ajuste de limite Pix que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurno <br><br>NOTURNO <br>Período: R$#PorTransacaoLimiteDiurno <br>Transação: R$#PorTransacaoLimiteNoturno <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 44, 'PIX - Efetivação novos limites', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteDiurnoPorTransacao - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurnoPorTransacao - Valor do novo limite por transação do período noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Alteração de limites Pix Saque/Troco', 'O ajuste de limite Pix Saque e Pix Troco que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O ajuste de limite Pix Saque e Pix Troco que você solicitou foi realizado com sucesso. <br><br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#LimiteDiurnoPorTransacao <br><br>NOTURNO <br>Período: R$#PorTransacaoLimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurnoPorTransacao <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 45, 'PIX - Efetivação novos limites Saque/Troco', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteDiurnoPorTransacao - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurnoPorTransacao - Valor do novo limite por transação do período noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Alteração de limites Pix de uma conta cadastrada', 'O ajuste de limite Pix que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O ajuste de limite Pix que você solicitou foi realizado com sucesso. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Agência: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br>Novos limites: <br><br>DIURNO <br>Período: R$#LimiteDiurno <br>Transação: R$#LimiteDiurnoPorTransacao <br><br>NOTURNO <br>Período: R$#PorTransacaoLimiteDiurno <br>Transação: R$#PorTransacaoLimiteDiurnoPorTransacao <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 46, 'PIX - Efetivação novos limites de uma conta cadastrada', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#NomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#BancoContaCadastrada - Código e descrição do banco da conta cadastrada<br>#AgenciaContaCadastrada - Agencia da conta cadastrada<br>#NumeroContaCadastrada - Número da conta cadastrada<br>#LimiteDiurno - Valor do novo limite do período diurno (Ex.: 1000,00)<br>#LimiteDiurnoPorTransacao - Valor do novo limite por transação do período diurno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurno - Valor do novo limite do período noturno (Ex.: 1000,00)<br>#PorTransacaoLimiteDiurnoPorTransacao - Valor do novo limite por transação do período noturno (Ex.: 1000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Aumento de limite máximo do Pix', 'O aumento de limite máximo do Pix que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O aumento de limite máximo do Pix que você solicitou foi realizado com sucesso. <br><br>Novo limite máximo: R$#novoLimite. <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 47, 'PIX - Efetivação novo limite total', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#novoLimite - Valor do novo limite (Ex.: 5000,00)');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Efetivação de uma conta cadastrada', 'O cadastro da conta que você solicitou foi realizado com sucesso.', '#NomeCooperado, <br><br>O cadastro da conta que você solicitou foi realizado com sucesso. Você já pode gerenciar de forma personalizada os limites Pix dessa conta. <br><br>Dados da Conta: <br><br>Nome: #NomeContaCadastrada <br>Banco: #BancoContaCadastrada <br>Agência: #AgenciaContaCadastrada <br>Conta: #NumeroContaCadastrada <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 48, 'PIX - Efetivação novos limites de uma conta cadastrada', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#NomeContaCadastrada - Nome do beneficiario da conta cadastrada<br>#BancoContaCadastrada - Código e descrição do banco da conta cadastrada<br>#AgenciaContaCadastrada - Agencia da conta cadastrada<br>#NumeroContaCadastrada - Número da conta cadastrada');

	SELECT (max(cdmensagem) + 1) into codigoMensagem FROM tbgen_notif_msg_cadastro;  
	INSERT INTO tbgen_notif_msg_cadastro (cdmensagem, cdorigem_mensagem, dstitulo_mensagem, dstexto_mensagem, dshtml_mensagem, cdicone, inexibir_banner, inexibe_botao_acao_mobile, dstexto_botao_acao_mobile, cdmenu_acao_mobile, dsmensagem_acao_mobile, inenviar_push) VALUES
	(codigoMensagem, 13, 'Efetivação de novo horário noturno', 'A alteração de horário do período noturno que você solicitou foi realizada com sucesso.', '#NomeCooperado, <br><br>A alteração de horário do período noturno que você solicitou foi realizada com sucesso. <br><br>Novo horário do período noturno: <br><br>Início: #horarioInicio <br>Fim: #horarioFim <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.', 9, 0, 1, 'Tirar dúvidas!', 1042, 'Tirar dúvidas!', 1);

 	INSERT INTO tbgen_notif_automatica_prm (cdorigem_mensagem, cdmotivo_mensagem, dsmotivo_mensagem, cdmensagem, inmensagem_ativa, intipo_repeticao, dsvariaveis_mensagem) VALUES
	(13, 49, 'PIX - Efetivação de novo horário noturno', codigoMensagem, 1, 0, '<br>#NomeCooperado - Nome do cooperado<br>#horarioInicio - Horário de inicio do periodo noturno. Ex: 21:00<br>#horarioFim - Horário de fim do periodo noturno Ex: 06:00');

	commit;

END;
