BEGIN
  update crappep a
     set a.inliquid = 1 --0
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 502294
     and a.nrctremp = 10002260
     and a.nrparepr = 15
  ;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;