BEGIN

     UPDATE crapepr epr
        SET epr.vlsdeved = (SELECT nvl(sum(vlsdvpar),0)
                            FROM   crappep pep 
                            WHERE  pep.cdcooper = epr.cdcooper 
                            AND    pep.nrdconta = epr.nrdconta 
                            AND    pep.nrctremp = epr.nrctremp
                            and    pep.inliquid = 0)
      WHERE (cdcooper , nrdconta, nrctremp ) in ((1, 8063265, 2340869),(1, 8834377, 2287659),(1, 9912371, 2525794)) ;      
   
   COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
