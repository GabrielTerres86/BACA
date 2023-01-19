DECLARE
	
BEGIN
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'SCRIPT_PROTOCOLO_IBRATAN', 'Script curl busca protocolo biro Ibratan','curl -X HEAD -i --noproxy "*" --max-time 30 --location --request POST "[url]" -H "AccessKey: [accesskey]" -H "SecretKey: [secretkey]" -H "Authorization: [authorization]" -H "Content-Type: application/xml" --data-raw "[xml]"');
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
 VALUES ('CRED',0, 'SCRIPT_RETORNO_IBRATAN', 'Script curl retorno biro Ibratan','curl --noproxy "*" --max-time [timeout] --location --request POST "[url]" -H "AccessKey: [accesskey]" -H "SecretKey: [secretkey]" -H "Content-Type: application/xml" --data-raw "[xml]"');
 
 COMMIT;
 
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;