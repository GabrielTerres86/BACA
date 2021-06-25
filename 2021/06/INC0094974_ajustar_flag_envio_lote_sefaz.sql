-- Atualizacao da flag e data de envio do registros para que nao seja enviado no arquivo consolidado por erro de pgto

UPDATE craplft SET 
  craplft.insitfat = 2, 
  craplft.dtdenvio = trunc(sysdate)
WHERE 
  craplft.cdcooper = 14 
  AND craplft.insitfat = 1
  AND craplft.cdhistor = 1063
  AND craplft.vllanmto = 62.31
  AND craplft.dtmvtolt = trunc(sysdate)
  AND craplft.cdbarras = 85250000000623100247200022778587000210021353;

COMMIT;
