BEGIN
  
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>Sua chave do Pix #chaveenderecamento foi cadastrada e vinculada � sua conta com sucesso.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5323;
		 
		UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>A tentativa de inclus�o da chave #chaveenderecamento n�o foi efetivada por estar em processo de #motivo.<br><br>Tente novamente!<br><br>'		   
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5324;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Uma solicita��o de portabilidade da sua chave de endere�amento Pix #chaveenderecamento para outra institui��o financeira foi aberta.<br><br>Para aceitar ou cancelar a solicita��o voc� deve acessar o menu Gerenciamento de Chaves dentro da op��o Pix no seu App Ailos.<br><br><b>Se n�o houver resposta em 7 dias, o processo de portabilidade ser� cancelado.</b><br><br>Em caso de d�vidas, entre em contato com o SAC da sua Cooperativa.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5459;
		  
 		UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido<br><br>Sua chave de endere�amento Pix #chaveenderecamento recebeu uma solicita��o de reivindica��o de posse por outro usu�rio.<br><br>Para aceitar ou cancelar a solicita��o voc� deve acessar o menu Gerenciamento de Chaves dentro da op��o Pix no seu App Ailos.<br><br><b>Se n�o houver resposta em 7 dias, a chave de endere�amento ser� cancelada de sua conta na Cooperativa.</b><br><br>Em caso de d�vidas, entre em contato com o SAC da sua Cooperativa.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5460;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>Sua chave de endere�amento do Pix #chaveenderecamento foi exclu�da por falta de uso ao longo de 12 meses.Caso ainda deseje utilizar essa chave, deve fazer um novo cadastro acessando Pix > Gerenciamento de Chaves > Cadastrar nova Chave, no App Ailos.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5461;

		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O seu processo de portabilidade de chave Pix #chaveenderecamento foi cancelado pela institui��o em que a chave est� atualmente cadastrada.<br><br>Entre em contato com a institui��o para verificar a situa��o.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5462;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O seu processo de portabilidade da chave #chaveenderecamento foi conclu�do com sucesso.Voc� pode verificar o cadastramento acessando a op��o Pix > Gerenciamento de Chaves, no App Ailos.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5463;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O seu processo de reivindica��o de chave Pix #chaveenderecamento foi cancelado pela institui��o em que a chave est� atualmente cadastrada.<br><br>Entre em contato com a institui��o para verificar a situa��o.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5464;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O seu processo de reivindica��o da chave #chaveenderecamento foi aprovado com sucesso.<br><br><b>Agora voc� precisa finalizar o cadastro da chave em sua conta, acessando o Gerenciamento de Chave no App Ailos e validando novamente a posse da chave de endere�amento Pix.</b><br><br>Em caso de d�vidas, entre em contato com o SAC.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5465;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'N�o deixe a sua chave de endere�amento #chaveenderecamento ser cancelada.<br><br><b>Fa�a a valida��o que est� pendente, acessando o Gerenciamento de Chave do Pix no seu App Ailos para concluir o processo.</b><br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5466;
		 
		 	UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>N�o recebemos retorno do processo de reivindica��o da chave Pix #chaveenderecamento enviado a voc� em #datadareivindicacaorecebida.Conforme informado, ap�s sete dias sem retorno sua chave � automaticamente cancelada.<br><br>Caso n�o tenha identificado a solicita��o de reivindica��o e ainda possua a chave de endere�amento reivindicada, acesse o Gerenciamento de Chave do Pix no seu App Ailos e fa�a uma nova valida��o de posse para evitar a transfer�ncia da chave para outra institui��o. Se n�o possui mais esta chave, conclua o processo de solicita��o autorizando a reivindica��o.<br><br>Em caso de d�vidas, entre em contato com o SAC.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5467;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido>,<br><br>O seu processo de reivindica��o da chave #chaveenderecamento foi conclu�do com sucesso. A chave est� ativa na Cooperativa.<br><br>Voc� pode verificar o cadastramento acessando a op��o Pix > Gerenciamento de Chaves, no App Ailos.<br><br>',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5468;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5469;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O Pix que voc� realizou em #datahoratransacao, no valor de #valorpix para #beneficiario foi devolvido no valor #parcialtotalmente de #valordevolvido.<br><br><b>O valor est� novamente dispon�vel em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolu��o.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5470;
		 		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Conclu�mos o processo de an�lise da sua opera��o realizada via Pix e confirmamos o sucesso da transa��o.<br><br>Valor: #valorpix <br>Benefici�rio: #beneficiario <br>Institui��o: #instituicao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5471;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Conclu�mos o processo de an�lise da sua opera��o realizada via Pix.<br><br>A sua transa��o foi cancelada por medidas se seguran�a.<br><br>Valor: #valorpix <br>Benefici�rio: #beneficiario <br>Institui��o: #instituicao <br><br><b>O valor foi estornado e est� dispon�vel em sua conta corrente.</b><br><br>Em caso de d�vidas, entre em contato com a Cooperativa.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5472;
		 
		   UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Conclu�mos o processo de an�lise da sua opera��o realizada via Pix e confirmamos o sucesso da transa��o.<br><br>Valor: #valorpix <br>Benefici�rio: #beneficiario <br>Institui��o: #instituicao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente.<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5473;
		 
		 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Conclu�mos o processo de an�lise da sua opera��o realizada via Pix.<br><br>A sua transa��o foi cancelada por medidas de seguran�a.<br><br>Valor: #valorpix <br>Benefici�rio: #beneficiario <br>Institui��o: #instituicao <br><br>Tente novamente mais tarde ou entre em contato com a sua Cooperativa.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 5474;
		 
		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido,<br><br>O Pix que voc� recebeu hoje no valor de #valorPix teve uma tarifa no valor de #valorTarifa. <br> Para saber mais sobre a tarifa do Pix. clique aqui ou acesse o site da sua cooperativa <br> Em caso de d�vidas, entre em contato com a sua cooperativa no Posto de Atendimento mais pr�ximo ou ligue para o SAC (0800 647 2200)<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 6663;
		 
		 	 UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = '#nomeresumido, <br><br> Sua chave Pix que estava sem utiliza��o foi cancelada.<br><br> Chave: #chave <br><br>Em caso de d�vidas, entre em contato com a sua cooperativa no Posto de Atendimento mais pr�ximo ou ligue para o SAC (0800 647 2200).',
		  	  TBNMC.DSTEXTO_BOTAO_ACAO_MOBILE = 'Pix',
		  	  TBNMC.DSMENSAGEM_ACAO_MOBILE = 'Pix' 	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 6968;
		 
		 		  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'O Pix Saque que voc� realizou �s #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvido <b>#parcialtotalmente.<br><br>O valor est� novamente dispon�vel em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolu��o.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 8207;
		 
		 	  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'A parcela #parcelacompratroco do Pix Troco que voc� realizou �s #horatransacao no valor de <b>#valorpix<b> na(o) <b>#beneficiario</b>, foi devolvida <b>#parcialtotalmente.<br><br>O valor est� novamente dispon�vel em sua conta corrente.</b><br><br>Acesse o comprovante para mais detalhes da devolu��o.'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 8208;
		 
		   UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO TBNMC
		  SET TBNMC.DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'	  
		  WHERE TBNMC.CDORIGEM_MENSAGEM = 13
		  AND TBNMC.CDMENSAGEM = 15251;
		 
 
  COMMIT;
  
END;
