--INC0052421 - ajuste id cessão de cartão
--Ana Volles - 10/07/2020
/*
SELECT * FROM tbcrd_cessao_credito a WHERE a.cdcooper = 1 AND a.nrdconta = 7878753;
SELECT cdorigem, nrdconta, nrctremp, idcessao FROM crapcyb WHERE cdcooper = 1 AND nrdconta = 7878753 AND nrctremp = 171071; 
*/

BEGIN
  UPDATE crapcyb a 
  SET    a.idcessao = 65796
  WHERE  a.cdcooper = 1
  AND    a.nrdconta = 7878753
  AND    a.nrctremp = 171071;
  
  COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END;
      
