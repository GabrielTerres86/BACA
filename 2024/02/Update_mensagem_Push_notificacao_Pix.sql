BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Você recebeu de #nomepagador um crédito Pix de #valorpix. O valor já está em sua conta.'
  WHERE CDMENSAGEM = 16051;
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
