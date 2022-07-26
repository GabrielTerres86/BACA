declare
   cursor cr_refin (pr_data date) is
   SELECT e.cdcooper, e.nrdconta, e.nrctremp
  FROM CECRED.tbcrd_cessao_credito t
  JOIN CECRED.crapepr e
    ON e.cdcooper = t.cdcooper
   AND e.nrdconta = t.nrdconta
   AND e.nrctremp = t.nrctremp
 WHERE t.dtvencto = pr_data
   AND EXISTS (SELECT 1
                 FROM CECRED.crawepr w
                WHERE w.cdcooper = e.cdcooper
                  AND w.nrdconta = e.nrdconta
                  AND w.nrctremp = e.nrctremp
                  AND w.flgreneg = 0)
  AND  (t.idcessao,t.cdcooper, t.nrdconta, t.nrctremp) NOT  IN 
                              (( 164147,  1,   11909412,  5494204), 
                               ( 164384,  16,  581291,	  468657),
                               ( 164464,  11,	 601241,	  228267), 
                               ( 164127,  1,	 7780877,   5494172),
                               ( 164377,  16,	 790702,	  468648));
  TYPE tr_refin IS TABLE OF cr_refin%ROWTYPE INDEX BY BINARY_INTEGER;
  vr_refin tr_refin;
  
  vr_data  date;
  
BEGIN
  
  vr_data := to_date('22/03/2022','dd/mm/yyyy');
  
  OPEN cr_refin(vr_data);
  FETCH cr_refin BULK COLLECT INTO vr_refin ;
  close cr_refin;
  
  for x in nvl(vr_refin.first,1).. nvl(vr_refin.last,0) LOOP
    UPDATE CECRED.crapepr
      SET dtinicio_atraso_refin = vr_data
    WHERE cdcooper = vr_refin(x).cdcooper
      AND nrdconta = vr_refin(x).nrdconta
      AND nrctremp = vr_refin(x).nrctremp;   
  END LOOP;
  
  vr_data := to_date('19/03/2022','dd/mm/yyyy');
  
  OPEN cr_refin(vr_data);
  FETCH cr_refin BULK COLLECT INTO vr_refin ;
  close cr_refin;
  
  for x in nvl(vr_refin.first,1).. nvl(vr_refin.last,0) LOOP
    UPDATE CECRED.crapepr
      SET dtinicio_atraso_refin = vr_data
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
