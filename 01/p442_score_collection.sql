BEGIN

  UPDATE crapprm prm 
     SET prm.cdacesso = 'DBLINK_SAS_DESEN_RO' 
   WHERE prm.cdacesso = 'DBLINK_SAS_DESEN';
  UPDATE crapprm prm 
     SET prm.cdacesso = 'DBLINK_SAS_PROD_RO' 
   WHERE prm.cdacesso = 'DBLINK_SAS_PROD';
  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'DBLINK_SAS_DESEN_RW','DBLink para acesso escrita ao SAS em ambientes não produção','sasd1');  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'DBLINK_SAS_PROD_RW','DBLink para acesso escrita ao SAS em ambiente produção','sasp');  

  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'OWNER_SAS_DESEN','Owner para acesso ao SAS em ambientes não produção','');  
  insert into crapprm (nmsistem,cdcooper,cdacesso,dstexprm,dsvlrprm)
               VALUES ('CRED',0,'OWNER_SAS_PROD','Owner para acesso ao SAS em ambiente produção','integradados.');  

  commit;
  
end;
