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
    ,'Valida��o de posse de chave Pix'
    ,'A valida��o do processo de reivindica��o est� pendente. Saiba mais!'
    ,'Cooperado,<br><br>Voc� possui uma solicita��o de reivindica��o de posse da chave Pix <b>#chaveenderecamento</b> pendente de valida��o.<br><br>Para validar da chave, voc� deve acessar o menu Minhas Chaves dentro da op��o Pix no App Ailos.<br><br><b>Se n�o houver resposta em 16 dias, a chave Pix ser� cancelada de sua conta na Cooperativa.</b><br><br>Em caso de d�vidas, entre em contato com o SAC ou sua Cooperativa.'
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
    ,'PIX - Valida��o de Posse de Chave PIX'
    ,(V_CODIGO_MENSAGEM + 1)
    ,'</br>#chaveenderecamento - Chave de endere�amento (Ex: 123e4567-e89b-12d3-a456-426655440000)'
    ,1
    ,0);
    
  COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

END;
