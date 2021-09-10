DECLARE
 /* RITM0159747 - Inativar convênios BB e seus respetivos contratos */
BEGIN

  UPDATE CRAPCCO CCO
  SET CCO.FLGATIVO = 0
  WHERE (CCO.CDCOOPER, CCO.NRCONVEN) IN
      ((1  ,2280695),
      (2  ,2287333),
      (4  ,2280713),
      (4  ,2280716),
      (5  ,2287337),
      (6  ,2306320),
      (7  ,2306335),
      (10 ,2287344),
      (11 ,2293514),
      (12 ,2293529),
      (13 ,2293532),
      (14 ,2287349),
      (15 ,2567994),
      (16 ,2459285),
      (17 ,2649126),
      (17 ,2649135))
  AND CCO.FLGATIVO = 1;
  
  COMMIT;
  
  FOR rw_contratos_inat IN (
                          SELECT ceb.cdcooper
                                ,ceb.nrdconta
                                ,ceb.nrconven
                                ,ceb.nrcnvceb
                                ,ceb.idrecipr
                          FROM crapceb ceb
                              ,crapcco cco
                          WHERE ceb.insitceb = 1
                            AND ceb.nrconven = cco.nrconven
                            AND ceb.cdcooper = cco.cdcooper
                            --
                            AND cco.cddbanco = 1
                          ORDER BY 1,2,3,4,5) LOOP
    --                          
    UPDATE crapceb ceb
    SET ceb.insitceb = 2
    WHERE (              ceb.cdcooper,              ceb.nrdconta,               ceb.nrconven,               ceb.nrcnvceb,              ceb.idrecipr)
      IN ((rw_contratos_inat.cdcooper,rw_contratos_inat.nrdconta, rw_contratos_inat.nrconven, rw_contratos_inat.nrcnvceb,rw_contratos_inat.idrecipr));
    --
  END LOOP;
  --
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.put_line(SQLERRM);
    sistema.excecaoInterna(pr_compleme => 'RITM0159747');  
END;                            
