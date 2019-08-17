DECLARE
  I INTEGER;
  CURSOR BUSCAREPETIDOS IS
    SELECT CRAPCEB.CDCOOPER,
           CRAPCEB.NRDCONTA,
           CRAPCEB.NRCONVEN,
           CRAPCEB.NRCNVCEB,
           COUNT(1)
      FROM CRAPCEB
     WHERE CRAPCEB.CDCOOPER = 16
     GROUP BY CRAPCEB.CDCOOPER,
              CRAPCEB.NRDCONTA,
              CRAPCEB.NRCONVEN,
              CRAPCEB.NRCNVCEB
    HAVING COUNT(1) > 1;

BEGIN
  BEGIN
    FOR C1 IN BUSCAREPETIDOS LOOP
      DELETE FROM CRAPCEB A
       WHERE A.NRDCONTA = C1.NRDCONTA
         AND A.NRCONVEN = C1.NRCONVEN
         AND A.PROGRESS_RECID <>
             (SELECT MAX(B.PROGRESS_RECID)
                FROM CRAPCEB B
               WHERE B.NRDCONTA = A.NRDCONTA
                 AND B.NRCONVEN = A.NRCONVEN
                 AND B.CDCOOPER = 16
                 /*AND B.INSITCEB = 1*/
				 );
    
      DBMS_OUTPUT.PUT_LINE('Conta: ' || C1.NRDCONTA || ' - Conve: ' ||
                           C1.NRCONVEN);
    end loop;
    
    Commit;
  
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Ocorreu um erro ao executar o baca: ' ||
                           SQLERRM);
    rollback;
  END;
END;
