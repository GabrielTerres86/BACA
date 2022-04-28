BEGIN
  
  UPDATE tbcadast_pessoa_fisica t 
     SET t.tppreferenciacontato = 0 
   WHERE t.idpessoa = 5168527;
   
 COMMIT;

END;
