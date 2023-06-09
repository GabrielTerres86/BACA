BEGIN
  
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>Sua chave do Pix #chaveenderecamento foi cadastrada e vinculada à sua conta com sucesso.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5323;
		 
		UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>A tentativa de inclusão da chave #chaveenderecamento não foi efetivada por estar em processo de #motivo.<br><br>Tente novamente!<br><br>'		   
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5324;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Uma solicitação de portabilidade da sua chave de endereçamento Pix #chaveenderecamento para outra instituição financeira foi aberta.<br><br>Para aceitar ou cancelar a solicitação você deve acessar o menu Gerenciamento de Chaves dentro da opção Pix no seu App Ailos.<br><br><b>Se não houver resposta em 7 dias, o processo de portabilidade será cancelado.</b><br><br>Em caso de dúvidas, entre em contato com o SAC da sua Cooperativa.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5459;
		  
 		UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido<br><br>Sua chave de endereçamento Pix #chaveenderecamento recebeu uma solicitação de reivindicação de posse por outro usuário.<br><br>Para aceitar ou cancelar a solicitação você deve acessar o menu Gerenciamento de Chaves dentro da opção Pix no seu App Ailos.<br><br><b>Se não houver resposta em 7 dias, a chave de endereçamento será cancelada de sua conta na Cooperativa.</b><br><br>Em caso de dúvidas, entre em contato com o SAC da sua Cooperativa.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5460;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>Sua chave de endereçamento do Pix #chaveenderecamento foi excluída por falta de uso ao longo de 12 meses.Caso ainda deseje utilizar essa chave, deve fazer um novo cadastro acessando Pix > Gerenciamento de Chaves > Cadastrar nova Chave, no App Ailos.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5461;

		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O seu processo de portabilidade de chave Pix #chaveenderecamento foi cancelado pela instituição em que a chave está atualmente cadastrada.<br><br>Entre em contato com a instituição para verificar a situação.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5462;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O seu processo de portabilidade da chave #chaveenderecamento foi concluído com sucesso.Você pode verificar o cadastramento acessando a opção Pix > Gerenciamento de Chaves, no App Ailos.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5463;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O seu processo de reivindicação de chave Pix #chaveenderecamento foi cancelado pela instituição em que a chave está atualmente cadastrada.<br><br>Entre em contato com a instituição para verificar a situação.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5464;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O seu processo de reivindicação da chave #chaveenderecamento foi aprovado com sucesso.<br><br><b>Agora você precisa finalizar o cadastro da chave em sua conta, acessando o Gerenciamento de Chave no App Ailos e validando novamente a posse da chave de endereçamento Pix.</b><br><br>Em caso de dúvidas, entre em contato com o SAC.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5465;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Não deixe a sua chave de endereçamento #chaveenderecamento ser cancelada.<br><br><b>Faça a validação que está pendente, acessando o Gerenciamento de Chave do Pix no seu App Ailos para concluir o processo.</b><br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5466;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>Não recebemos retorno do processo de reivindicação da chave Pix #chaveenderecamento enviado a você em #datadareivindicacaorecebida.Conforme informado, após sete dias sem retorno sua chave é automaticamente cancelada.<br><br>Caso não tenha identificado a solicitação de reivindicação e ainda possua a chave de endereçamento reivindicada, acesse o Gerenciamento de Chave do Pix no seu App Ailos e faça uma nova validação de posse para evitar a transferência da chave para outra instituição. Se não possui mais esta chave, conclua o processo de solicitação autorizando a reivindicação.<br><br>Em caso de dúvidas, entre em contato com o SAC.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5467;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido>,<br><br>O seu processo de reivindicação da chave #chaveenderecamento foi concluído com sucesso. A chave está ativa na Cooperativa.<br><br>Você pode verificar o cadastramento acessando a opção Pix > Gerenciamento de Chaves, no App Ailos.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5468;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5469;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O Pix que você realizou em #datahoratransacao, no valor de #valorpix para #beneficiario foi devolvido no valor #parcialtotalmente de #valordevolvido.<br><br><b>O valor está novamente disponível em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolução.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5470;
		 		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Concluímos o processo de análise da sua operação realizada via Pix e confirmamos o sucesso da transação.<br><br>Valor: #valorpix <br>Beneficiário: #beneficiario <br>Instituição: #instituicao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5471;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Concluímos o processo de análise da sua operação realizada via Pix.<br><br>A sua transação foi cancelada por medidas se segurança.<br><br>Valor: #valorpix <br>Beneficiário: #beneficiario <br>Instituição: #instituicao <br><br><b>O valor foi estornado e está disponível em sua conta corrente.</b><br><br>Em caso de dúvidas, entre em contato com a Cooperativa.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5472;
		 
		   UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Concluímos o processo de análise da sua operação realizada via Pix e confirmamos o sucesso da transação.<br><br>Valor: #valorpix <br>Beneficiário: #beneficiario <br>Instituição: #instituicao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5473;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Concluímos o processo de análise da sua operação realizada via Pix.<br><br>A sua transação foi cancelada por medidas de segurança.<br><br>Valor: #valorpix <br>Beneficiário: #beneficiario <br>Instituição: #instituicao <br><br>Tente novamente mais tarde ou entre em contato com a sua Cooperativa.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5474;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O Pix que você recebeu hoje no valor de #valorPix teve uma tarifa no valor de #valorTarifa. <br> Para saber mais sobre a tarifa do Pix. clique aqui ou acesse o site da sua cooperativa <br> Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200)<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 6663;
		 
		 	 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido, <br><br> Sua chave Pix que estava sem utilização foi cancelada.<br><br> Chave: #chave <br><br>Em caso de dúvidas, entre em contato com a sua cooperativa no Posto de Atendimento mais próximo ou ligue para o SAC (0800 647 2200).',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 6968;
		 
		 		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O Pix Saque que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvido <b>#parcialtotalmente.<br><br>O valor está novamente disponível em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolução.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 8207;
		 
		 	  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'A parcela #parcelacompratroco do Pix Troco que você realizou às #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvida <b>#parcialtotalmente.<br><br>O valor está novamente disponível em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolução.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 8208;
		 
		   UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 15251;
		 
 
  COMMIT;
  
END;
