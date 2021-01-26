-- Atualizacao da flag e data de envio do registros para que nao seja enviado no arquivo consolidado por erro de pgto

UPDATE craplft SET 
	craplft.insitfat = 2, 
	craplft.dtdenvio = trunc(sysdate)
WHERE 
	craplft.cdcooper = 1 
	AND craplft.insitfat = 1 
	AND craplft.cdhistor = 1063
	AND craplft.vllanmto = 92.35
	AND craplft.dtmvtolt = trunc(sysdate);

commit;