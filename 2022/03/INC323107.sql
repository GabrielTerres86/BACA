BEGIN

  BEGIN
      UPDATE crapsli sli
         SET sli.vlsddisp = 79403.06
       WHERE sli.nrdconta = 364843
         AND sli.cdcooper = 9;
       
  EXCEPTION 
       WHEN OTHERS THEN
          raise_application_error(-20001,'Ocorreu um erro ao atualizar o registro da tabela CRAPSLI. Código do erro:'||SQLERRM);   
  END;
  
  COMMIT;          

END;


