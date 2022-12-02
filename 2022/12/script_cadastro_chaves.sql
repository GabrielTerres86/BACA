BEGIN
  
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_ACCESS_MULE_1', 'Chave Access url URL_MULE_DWLD_PDF', 'a99f6ed28c514b7db6c17ffdf3cfa36d',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_SECRET_MULE_1', 'Chave secret url URL_MULE_DWLD_PDF', '4B7F301163FE408Da7B140e229EC3804',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));



 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_ACCESS_MULE_2', 'Chave Access url NOVOMOTOR_URI_WSAYLLOS', 'a99f6ed28c514b7db6c17ffdf3cfa36d',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_SECRET_MULE_2', 'Chave secret url NOVOMOTOR_URI_WSAYLLOS', '4B7F301163FE408Da7B140e229EC3804',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_ACCESS_MULE_3', 'Chave Access url NOVOMOTOR_URI_WEBSRV', 'a99f6ed28c514b7db6c17ffdf3cfa36d',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));
 
 INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm, progress_recid)
 VALUES ('CRED',0, 'MOTOR_SECRET_MULE_3', 'Chave secret url NOVOMOTOR_URI_WEBSRV', '4B7F301163FE408Da7B140e229EC3804',(SELECT MAX(PROGRESS_RECID) + 1 FROM crapprm));

COMMIT;
END;
