UPDATE CRAPCOB C
   SET C.DTLIPGTO = C.DTVENCTO + (CASE c.cdcooper WHEN 1 THEN 100
                                                  WHEN 9 THEN 125
                                                  ELSE 70
                                                    END)    
                 
 WHERE EXISTS ( SELECT COB.ROWID
                  FROM CRAPCCO CCO, CRAPCOB COB
                 WHERE CCO.DSORGARQ = 'ACORDO'
                   AND COB.CDCOOPER = CCO.CDCOOPER
                   AND COB.NRCNVCOB = CCO.NRCONVEN
                   AND COB.CDBANDOC = CCO.CDDBANCO
                   AND cob.cdbandoc = 85
                   AND cob.nrdconta = 850004
                   AND COB.INCOBRAN = 0
                   AND COB.DTVENCTO < '31/07/2020'
                   AND COB.ROWID = C.ROWID);
     
                   
commit;