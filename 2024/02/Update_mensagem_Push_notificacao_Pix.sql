BEGIN

  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO
  SET DSTEXTO_MENSAGEM = 'Voc� recebeu de #nomepagador um cr�dito Pix de #valorpix. O valor j� est� em sua conta.'
  WHERE CDMENSAGEM in (16051, 5469);
  
	COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
