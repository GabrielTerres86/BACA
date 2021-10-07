BEGIN
  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Solicita��o de devolu��o de Pix'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Solicita��o de devolu��o de Pix'
     AND DSTEXTO_MENSAGEM =
         'Voc� recebeu um Pix, mas o pagador contestou e solicitou devolu��o do valor.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Pix Devolvido'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Pix Devolvido'
     AND DSTEXTO_MENSAGEM =
         'Analisamos o Pix que voc� recebeu e ele ser� devolvido para o pagador.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Solicita��o de devolu��o de Pix negada'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Solicita��o de devolu��o de Pix negada'
     AND DSTEXTO_MENSAGEM =
         'Voc� recebeu uma solicita��o de devolu��o de Pix, mas analisamos que a contesta��o � improcedente e o valor foi liberado em sua conta.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contesta��o de Pix em an�lise'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contesta��o de Pix em an�lise'
     AND DSTEXTO_MENSAGEM =
         'O Pix que voc� contestou est� sendo analisado.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contesta��o de Pix aceita'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contesta��o de Pix aceita'
     AND DSTEXTO_MENSAGEM =
         'A devolu��o do Pix que voc� contestou foi recebida.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contesta��o de Pix n�o atendida'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contesta��o de Pix n�o atendida'
     AND DSTEXTO_MENSAGEM =
         'A sua contesta��o de Pix n�o foi respondida pela institui��o do recebedor e o valor n�o foi devolvido.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM =
         'PIX - Contesta��o de Pix rejeitada pela contraparte'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM =
         'Contesta��o de Pix rejeitada pela contraparte'
     AND DSTEXTO_MENSAGEM =
         'A sua contesta��o de Pix foi rejeitada e o valor n�o pode ser devolvido.'
     AND CDORIGEM_MENSAGEM = 13;

  COMMIT;
END;
