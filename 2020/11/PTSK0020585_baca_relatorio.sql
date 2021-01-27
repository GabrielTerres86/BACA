DECLARE
  CURSOR cr_crapcop IS
  SELECT cop.cdcooper
  FROM crapcop cop
  WHERE cop.flgativo = 1;

  vr_cdrelato number(10);
BEGIN
  
  SELECT MAX(cdrelato)+1 
  INTO vr_cdrelato
  FROM craprel;
 
 FOR rw_crapcop IN cr_crapcop
   LOOP
   INSERT INTO craprel
         (cdrelato, nrviadef, nrviamax, nmrelato, nrmodulo, nmdestin, nmformul, indaudit, cdcooper)  
   VALUES(vr_cdrelato,1,1,'CONTRATO DE EMPRESTIMO SAC', 3, 'Credito', 'PADRAO', 1, rw_crapcop.cdcooper) ;    
     
   END LOOP;
   COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       ROLLBACK;
END;
