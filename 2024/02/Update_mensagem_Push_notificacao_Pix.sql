BEGIN
  UPDATE DSTEXTO_MENSAGEM = 'Voc� recebeu de #nomepagador um cr�dito Pix de #valorpix. O valor j� est� em sua conta.'
  FROM CECRED.TBGEN_NOTIF_MSG_CADASTRO 
  WHERE CDMENSAGEM = 16051 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
