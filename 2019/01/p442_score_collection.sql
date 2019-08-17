BEGIN

  UPDATE crapprm prm 
     SET prm.cdacesso = 'DBLINK_SAS_DESEN_RO' 
   WHERE prm.cdacesso = 'DBLINK_SAS_DESEN';
  UPDATE crapprm prm 
     SET prm.cdacesso = 'DBLINK_SAS_PROD_RO'  
        ,prm.dsvlrprm = 'SASRO'
   WHERE prm.cdacesso = 'DBLINK_SAS_PROD';
  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'DBLINK_SAS_DESEN_RW','DBLink para acesso escrita ao SAS em ambientes n�o produ��o','sasd1');  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'DBLINK_SAS_PROD_RW','DBLink para acesso escrita ao SAS em ambiente produ��o','SASRW');  

  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'OWNER_SAS_DESEN','Owner para acesso ao SAS em ambientes n�o produ��o','');  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'OWNER_SAS_PROD','Owner para acesso ao SAS em ambiente produ��o','integradados.');  

  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'SKPROC_SCORE_BEHAVIOUR','SK de carga do Score Behaviour','856');  
  commit;  
  
end;
