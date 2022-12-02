BEGIN
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'URL_CONSULTA_IBRATAN', 'URL consulta biro Ibratan','https://app.capacitor.digital/api/commands-raw/Cmd001AtzSubmeterConsultas',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'URL_RESPOSTA_IBRATAN', 'URL resposta biro Ibratan','https://app.capacitor.digital/api/commands-raw/Cmd001AtzBuscarResposta?protocolo=',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));

 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'ACCESSKEY_BIRO_IBRATAN', 'Chave AccessKey consulta/resposta biro Ibratan','9f64f2bda96248299d30a9a3e5575cb9',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm)); 
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'SECRETKEY_BIRO_IBRATAN', 'Chave SecretKey consulta/resposta biro Ibratan','46ed0313698b42519e63553c9b0b28f49bf571a967a7432c8ef4222981519c3b49b30b083dee4ac68cd99787331f8c4adb92e7f90be740bdbbdc92d90973f101',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm)); 
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'SCRIPT_PROTOCOLO_IBRATAN', 'Script curl busca protocolo biro Ibratan','curl -X HEAD -i --noproxy "*" --max-time 30 --location --request POST "[url]" -H "AccessKey: [accesskey]" -H "SecretKey: [secretkey]" -H "Authorization: [authorization]" -H "Content-Type: application/xml" --data-raw "[xml]"',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'SCRIPT_RETORNO_IBRATAN', 'Script curl retorno biro Ibratan','curl --noproxy "*" --max-time [timeout] --location --request POST "[url]" -H "AccessKey: [accesskey]" -H "SecretKey: [secretkey]" -H "Content-Type: application/xml" --data-raw "[xml]"',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;

