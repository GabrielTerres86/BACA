
BEGIN
  update crappep a
     set a.inliquid = 0
        ,a.vlsdvpar = a.vlparepr - a.vlpagpar
        ,a.vlsdvatu = a.vlparepr - a.vlpagpar
        ,a.vlsdvsji = a.vlparepr - a.vlpagpar
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 514110
     and a.nrctremp = 20000379
     and a.nrparepr = 16
    ;
  --
  COMMIT;
  --
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(sqlerrm);
    ROLLBACK;
END;
