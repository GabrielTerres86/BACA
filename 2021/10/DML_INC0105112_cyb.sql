BEGIN
  
  UPDATE crapcyb x
     SET x.vlsdprej = 0 
   WHERE x.cdcooper = 14
     AND x.nrdconta = 138940
     AND x.nrctremp = 14479;

 COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500,'Erro ao atualizar registro '||SQLERRM);
END;  
