BEGIN

  BEGIN
      UPDATE crapsli sli
         SET sli.vlsddisp = 10525.28
       WHERE sli.nrdconta = 392200
         AND sli.cdcooper = 9;
           
  EXCEPTION         
    WHEN OTHERS THEN
      ROLLBACK;   
      raise_application_error(-20000,'Ocorreu um erro ao atualizar o registro da tabela CRAPSLI. Código do erro:'||SQLERRM);   
  END;
  
  COMMIT;

END;











  
