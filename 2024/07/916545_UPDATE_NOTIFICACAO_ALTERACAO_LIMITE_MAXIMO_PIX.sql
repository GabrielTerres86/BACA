BEGIN
  UPDATE CECRED.TBGEN_NOTIF_MSG_CADASTRO SET DSTITULO_MENSAGEM = 'A alteração de limite  Pix',
  DSTEXTO_MENSAGEM = 'A alteração de limite  Pix que você solicitou foi realizada com sucesso.',
  DSHTML_MENSAGEM = '#nomeCooperado, <br><br>A alteração de limite  Pix que você solicitou foi realizada com sucesso. <br><br>Novo limite máximo: R$#novoLimite. <br><br>Para mais informações sobre Limites Pix, acesse a seção de dúvidas.'
  WHERE CDORIGEM_MENSAGEM = 13 AND CDMENSAGEM =  9283;
COMMIT;
END;
