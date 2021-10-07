BEGIN
  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Solicitação de devolução de Pix'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Solicitação de devolução de Pix'
     AND DSTEXTO_MENSAGEM =
         'Você recebeu um Pix, mas o pagador contestou e solicitou devolução do valor.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Pix Devolvido'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Pix Devolvido'
     AND DSTEXTO_MENSAGEM =
         'Analisamos o Pix que você recebeu e ele será devolvido para o pagador.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Solicitação de devolução de Pix negada'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Solicitação de devolução de Pix negada'
     AND DSTEXTO_MENSAGEM =
         'Você recebeu uma solicitação de devolução de Pix, mas analisamos que a contestação é improcedente e o valor foi liberado em sua conta.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contestação de Pix em análise'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contestação de Pix em análise'
     AND DSTEXTO_MENSAGEM =
         'O Pix que você contestou está sendo analisado.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contestação de Pix aceita'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contestação de Pix aceita'
     AND DSTEXTO_MENSAGEM =
         'A devolução do Pix que você contestou foi recebida.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM = 'PIX - Contestação de Pix não atendida'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM = 'Contestação de Pix não atendida'
     AND DSTEXTO_MENSAGEM =
         'A sua contestação de Pix não foi respondida pela instituição do recebedor e o valor não foi devolvido.'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_AUTOMATICA_PRM
   WHERE DSMOTIVO_MENSAGEM =
         'PIX - Contestação de Pix rejeitada pela contraparte'
     AND CDORIGEM_MENSAGEM = 13;

  DELETE FROM TBGEN_NOTIF_MSG_CADASTRO
   WHERE DSTITULO_MENSAGEM =
         'Contestação de Pix rejeitada pela contraparte'
     AND DSTEXTO_MENSAGEM =
         'A sua contestação de Pix foi rejeitada e o valor não pode ser devolvido.'
     AND CDORIGEM_MENSAGEM = 13;

  COMMIT;
END;
