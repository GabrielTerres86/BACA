BEGIN

  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Voc� recebeu de #nomepagador um cr�dito Pix de #valorpix. O valor j� est� em sua conta.',
      DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Data/Hora Transa��o: #datahoratransacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDMENSAGEM = 5469;

  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Voc� recebeu de #nomepagador um cr�dito Pix de #valorpix. O valor j� est� em sua conta.',
      DSHTML_MENSAGEM = 'Cooperado,<br><br>Voc� recebeu um cr�dito Pix.<br><br>Pagador: #nomepagador <br>CPF/CNPJ : #documentopagador<br>Valor: #valorpix <br>Institui��o: #psppagador <br>Identifica��o: #identificacao <br>Data/Hora Transa��o: #datahoratransacao <br>Descri��o: #descricao <br><br>Acesse o comprovante no App Ailos ou confira o extrato da sua conta corrente<br><br>'
  WHERE CDMENSAGEM = 16051;
  
	COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
