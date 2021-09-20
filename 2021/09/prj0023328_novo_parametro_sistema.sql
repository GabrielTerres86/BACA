BEGIN
  
INSERT INTO crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED',0,'FLG_NOTIF_INSS_SICREDI', 'Ligar ou desligar integração com notificação do INSS pelo Sicredi. S = Ligado e N = desligado','S');

COMMIT;  
END;
