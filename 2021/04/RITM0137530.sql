DECLARE 
  i integer;
BEGIN

  UPDATE crapbpr e
     SET e.vlmerbem = 1222000
   WHERE e.cdcooper = 14 
     AND e.nrdconta = 171832 
     AND e.nrctrpro = 22904;
     
  UPDATE tbepr_bens_hst e
     SET e.vlmerbem = 1222000
   WHERE e.cdcooper = 14 
     AND e.nrdconta = 171832 
     AND e.nrctrpro = 22904;

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END;