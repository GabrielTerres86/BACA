DECLARE

V_CODIGO_MENSAGEM TBGEN_NOTIF_MSG_CADASTRO.cdmensagem%TYPE;
V_CODIGO_MOTIVO TBGEN_NOTIF_AUTOMATICA_PRM.cdmotivo_mensagem%TYPE;

BEGIN
  
  SELECT MAX(CDMENSAGEM)
  INTO V_CODIGO_MENSAGEM
  FROM TBGEN_NOTIF_MSG_CADASTRO;
  
  SELECT MAX(CDMOTIVO_MENSAGEM)
  INTO V_CODIGO_MOTIVO
  FROM TBGEN_NOTIF_AUTOMATICA_PRM;
  
  INSERT INTO TBGEN_NOTIF_MSG_CADASTRO
    (CDMENSAGEM
    ,CDORIGEM_MENSAGEM
    ,DSTITULO_MENSAGEM
    ,DSTEXTO_MENSAGEM
    ,DSHTML_MENSAGEM
    ,CDICONE
    ,INEXIBIR_BANNER
    ,INENVIAR_PUSH)
  VALUES
    ((V_CODIGO_MENSAGEM + 1)
    ,13
    ,'Validação de posse de chave Pix'
    ,'A validação do processo de reivindicação está pendente. Saiba mais!'
    ,'Cooperado,<br><br>Você possui uma solicitação de reivindicação de posse da chave Pix <b>#chaveenderecamento</b> pendente de validação.<br><br>Para validar da chave, você deve acessar o menu Minhas Chaves dentro da opção Pix no App Ailos.<br><br><b>Se não houver resposta em 16 dias, a chave Pix será cancelada de sua conta na Cooperativa.</b><br><br>Em caso de dúvidas, entre em contato com o SAC ou sua Cooperativa.'
    ,16
    ,0
    ,1);
    
  INSERT INTO TBGEN_NOTIF_AUTOMATICA_PRM
    (CDORIGEM_MENSAGEM
    ,CDMOTIVO_MENSAGEM
    ,DSMOTIVO_MENSAGEM
    ,CDMENSAGEM
    ,DSVARIAVEIS_MENSAGEM
    ,INMENSAGEM_ATIVA
    ,INTIPO_REPETICAO)
  VALUES
    (13
    ,(V_CODIGO_MOTIVO + 1)
    ,'PIX - Validação de Posse de Chave PIX'
    ,(V_CODIGO_MENSAGEM + 1)
    ,'</br>#chaveenderecamento - Chave de endereçamento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
