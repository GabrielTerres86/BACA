BEGIN
  UPDATE tbcadast_pessoa_atualiza t  
     SET t.insit_atualiza = 2
   WHERE t.insit_atualiza = 1 AND t.dschave = 'S';
   
   commit;
END;
