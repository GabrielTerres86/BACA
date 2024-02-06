BEGIN 
  UPDATE crapprm t 
     SET t.dsvlrprm = 1
   WHERE t.cdacesso = 'MLC_ATIVO';
   
 COMMIT;
 
END;
