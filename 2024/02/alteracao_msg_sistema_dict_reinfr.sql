BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO msg
  SET msg.DSHTML_MENSAGEM = 'Cooperado,<br><br>O Pix de #valorpix para #nomerecebedor que você contestou foi analisado, mas a transação não pode ser devolvida pela conta recebedora por insuficiência de saldo/encerramento de conta.<br><br>Infelizmente não será possível creditar o valor à sua conta.'
  WHERE msg.CDMENSAGEM = 7397;

  COMMIT;
END;