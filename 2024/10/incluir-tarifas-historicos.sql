DECLARE 

  CURSOR cr_dados IS
    SELECT t.cdcooper
         , t.cdhistor
      FROM craphis t 
     WHERE t.cdcooper IN (8,16)
       AND t.cdhistor >= 4580;
       
BEGIN
  
  FOR reg IN cr_dados LOOP
    BEGIN
      INSERT INTO crapthi(cdhistor
                         ,dsorigem
                         ,vltarifa
                         ,cdcooper)
                   VALUES(reg.cdhistor
                         ,'AIMARO'
                         ,0
                         ,reg.cdcooper);
    EXCEPTION
      WHEN dup_val_on_index THEN
        NULL;
    END;
  END LOOP;
  
  COMMIT;
END;
