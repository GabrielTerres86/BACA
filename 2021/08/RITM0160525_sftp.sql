Begin
  update crapprm 
     set DSVLRPRM = 'filetransfer.icatuseguros.com.br'
   where cdacesso = 'PRST_FTP_ENDERECO'
     and cdcooper in( 1,3)
     and nmsistem = 'CRED';           
    COMMIT;
EXCEPTION 
  WHEN OTHERS THEN 
    ROLLBACK;
END;

