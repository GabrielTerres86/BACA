BEGIN

  UPDATE tbrisco_operacoes opr
     SET opr.insituacao_rating = 4
   WHERE opr.cdcooper = 1
     AND opr.nrdconta = 3234665
     AND opr.nrctremp = 4656466;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;