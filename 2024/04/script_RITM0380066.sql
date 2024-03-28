DECLARE

BEGIN

   update cecred.crawepr
      set crawepr.insitapr = 1
    where crawepr.NRCTREMP = 338282
      and crawepr.nrdconta = 16904974
      and crawepr.cdcooper = 13;

  COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;