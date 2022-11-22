select *
  from tbepr_renegociacao_contrato a
 where cdcooper = 1 and nrdconta = 92971997
 and nrctremp = 6287061
 --FOR UPDATE


select * from tbepr_renegociacao_craplem
 where cdcooper = 1 and nrdconta = 92971997
 

BEGIN

  UPDATE tbepr_renegociacao_contrato
     SET NRVERSAO = 2
   WHERE cdcooper = 1 and nrdconta = 7027940 and nrctremp = 6287061;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;

 
 
