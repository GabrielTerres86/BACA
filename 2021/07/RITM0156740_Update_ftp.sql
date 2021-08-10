Begin

update crapprm 
   set DSVLRPRM = 'filetransfervpnsts.icatuseguros.com.br'
 where cdacesso = 'PRST_FTP_ENDERECO'
   and cdcooper = 3 
   and nmsistem = 'CRED'; 
    
  COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       ROLLBACK;
END;
/
