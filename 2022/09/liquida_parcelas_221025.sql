BEGIN

UPDATE cecred.crappep p
  SET p.inliquid = 1 
    , p.vlpagpar = p.vlsdvatu
    , p.vlsdvpar = 0
    , p.vlsdvatu = 0 
 WHERE p.cdcooper = 1
  AND p.nrdconta = 15108236
  AND p.nrctremp =  5932280;

COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;

END;
