BEGIN

  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Você recebeu de #nomepagador um crédito Pix de #valorpix. O valor já está em sua conta.',
      DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDMENSAGEM = 5469;

  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Você recebeu de #nomepagador um crédito Pix de #valorpix. O valor já está em sua conta.',
      DSHTML_MENSAGEM = 'Cooperado,<br><br>Você recebeu um crédito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Instituição: #psppagador <br>Identificação: #identificacao <br>Data/Hora Transação: #datahoratransacao <br>Descrição: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDMENSAGEM = 16051;
  
	COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;