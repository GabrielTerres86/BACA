declare
   cursor cr_refin is
   SELECT e.cdcooper, e.nrdconta, e.nrctremp
  FROM CECRED.tbcrd_cessao_credito t
  JOIN CECRED.crapepr e
    ON e.cdcooper = t.cdcooper
   AND e.nrdconta = t.nrdconta
   AND e.nrctremp = t.nrctremp
 WHERE t.cdcooper = 1
   AND t.dtvencto = to_date('11/04/2022','dd/mm/yyyy')
   AND EXISTS (SELECT 1
                 FROM CECRED.crawepr w
                WHERE w.cdcooper = e.cdcooper
                  AND w.nrdconta = e.nrdconta
                  AND w.nrctremp = e.nrctremp
                  AND w.flgreneg = 0);
  TYPE tr_refin IS TABLE OF cr_refin%ROWTYPE INDEX BY BINARY_INTEGER;
  vr_refin tr_refin;
  
  
BEGIN
  OPEN cr_refin;
  FETCH cr_refin BULK COLLECT INTO vr_refin ;
  close cr_refin;
  
  for x in nvl(vr_refin.first,1).. nvl(vr_refin.last,0) LOOP
    UPDATE CECRED.crapepr
      SET dtinicio_atraso_refin = TO_DATE('11/04/2022','dd/mm/yyyy')
    WHERE cdcooper = vr_refin(x).cdcooper
      AND nrdconta = vr_refin(x).nrdconta
      AND nrctremp = vr_refin(x).nrctremp;
     
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM); 
END;
