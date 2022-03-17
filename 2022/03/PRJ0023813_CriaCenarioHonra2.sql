BEGIN
  UPDATE crappep r
     SET r.vlpagpar = 0
        ,r.inliquid = 0
   WHERE r.cdcooper = 1
     AND r.nrdconta = 6653740
     AND r.nrctremp = 2979852;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
