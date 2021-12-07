DECLARE
 CURSOR cr_crapat IS
    SELECT C.CDPARTAR
      FROM CRAPPAT C
     WHERE C.CDPARTAR = 144;
  rw_crapat cr_crapat%ROWTYPE;  
BEGIN 
  OPEN cr_crapat;
  FETCH cr_crapat INTO rw_crapat;
  CLOSE cr_crapat;
    
  IF rw_crapat.CDPARTAR IS NOT NULL THEN
    DELETE FROM CRAPPAT WHERE CDPARTAR = 144;    
    DELETE FROM CRAPPCO WHERE CDPARTAR = 144;
    COMMIT; 
  END IF;
    insert into CRAPPAT (CDPARTAR, NMPARTAR, TPDEDADO, CDPRODUT)
    values (144, 'Responsavel pelo home equity', 2, 0); 
  
    insert into CRAPPCO (CDPARTAR, CDCOOPER, DSCONTEU)
    values (144, 3, 'Samuel Diego Roesler Rese#samuel.rese@ailos.coop.br#47996918329');
  
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
