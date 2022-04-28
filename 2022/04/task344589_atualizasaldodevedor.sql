BEGIN
     UPDATE crapepr epr
        SET epr.vlsdeved = (SELECT nvl(sum(vlsdvpar),0)
                            FROM   crappep pep 
                            WHERE  pep.cdcooper = epr.cdcooper 
                            AND    pep.nrdconta = epr.nrdconta 
                            AND    pep.nrctremp = epr.nrctremp
                            and    pep.inliquid = 0)
      WHERE (cdcooper , nrdconta, nrctremp ) in ( (1, 6461328, 2219322),
                                                  (1, 9677143, 2343723),
                                                  (1, 9770739, 2422995),
                                                  (1, 10313761, 2470783),
                                                  (1, 2759438, 2806359)) ;      
   
   COMMIT;
   
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
