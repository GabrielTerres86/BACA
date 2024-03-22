BEGIN

update cecred.crapepr epr
   set epr.inliquid = 1
      ,epr.dtliquid =
       (select max(pep.dtultpag)
          from cecred.crappep pep
         where pep.cdcooper = epr.cdcooper
           and pep.nrdconta = epr.nrdconta
           and pep.nrctremp = epr.nrctremp)
 where epr.cdcooper = 9
   and epr.nrdconta = 254029
   and epr.nrctremp = 64002;

update cecred.crapepr epr
   set epr.inliquid = 1
      ,epr.dtliquid =
       (select max(pep.dtultpag)
          from cecred.crappep pep
         where pep.cdcooper = epr.cdcooper
           and pep.nrdconta = epr.nrdconta
           and pep.nrctremp = epr.nrctremp)
 where epr.cdcooper = 13
   and epr.nrdconta = 286540
   and epr.nrctremp = 181564;

update cecred.crapepr epr
   set epr.inliquid = 1
      ,epr.dtliquid =
       (select max(pep.dtultpag)
          from cecred.crappep pep
         where pep.cdcooper = epr.cdcooper
           and pep.nrdconta = epr.nrdconta
           and pep.nrctremp = epr.nrctremp)
 where epr.cdcooper = 13
   and epr.nrdconta = 15897133
   and epr.nrctremp = 254248;
   
   COMMIT;

EXCEPTION

  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;