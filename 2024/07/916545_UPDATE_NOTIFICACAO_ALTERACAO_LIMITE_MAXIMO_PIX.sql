BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSTITULO_MENSAGEM = 'Altera��o de limite m�ximo do Pix',
  DSTEXTO_MENSAGEM = 'A altera��o de limite m�ximo do Pix que voc� solicitou foi realizado com sucesso.',
  DSHTML_MENSAGEM = '#nomeCooperado, <br><br>A altera��o de limite m�ximo do Pix que voc� solicitou foi realizado com sucesso. <br><br>Novo limite m�ximo: R$#novoLimite. <br><br>Para mais informa��es sobre Limites Pix, acesse a se��o de d�vidas.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM =  9283;
COMMIT;
END;
