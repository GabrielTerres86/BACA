BEGIN
  BEGIN
    UPDATE cecred.crapprm prm 
       SET prm.dsvlrprm = prm.dsvlrprm||';9'
     WHERE prm.nmsistem = 'CRED'
       AND prm.cdcooper = 0
       AND prm.cdacesso = 'TRANSLATE_CHR_ESPACO'
       AND prm.dsvlrprm NOT LIKE '%;9%';
  EXCEPTION 
    WHEN OTHERS THEN 
      rollback;
    	raise_application_error(-20111, 'Erro ao fazer update na crapprm. ' || SQLERRM );
  END; 
  COMMIT;
END;    
