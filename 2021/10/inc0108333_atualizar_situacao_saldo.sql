BEGIN
  update crapepr a
     set a.inliquid = 0
        ,a.vlsdeved = 126.95
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 502600
     and a.nrctremp in (19000767)
  ;
  --
  update crappep a
     set a.inliquid = 0
        ,a.vlsdvpar = 126.95
        ,a.vlsdvatu = 126.95
        ,a.vljura60 = 0
   where 1=1
     and a.cdcooper = 9
     and a.nrdconta = 502600
     and a.nrctremp in (19000767)
     and a.nrparepr = 20
  ;
  --
  DBMS_OUTPUT.PUT_LINE('OK');
  commit;
  --
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;