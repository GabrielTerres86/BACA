BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO msg
  SET msg.DSHTML_MENSAGEM = 'Cooperado,<br><br>O Pix de #valorpix para #nomerecebedor que voc� contestou foi analisado, mas a transa��o n�o pode ser devolvida pela conta recebedora por insufici�ncia de saldo/encerramento de conta.<br><br>Infelizmente n�o ser� poss�vel creditar o valor � sua conta.'
  WHERE msg.CDMENSAGEM = 7397;

  COMMIT;
END;