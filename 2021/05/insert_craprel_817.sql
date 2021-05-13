DECLARE
  CURSOR cr_crapcop IS
  SELECT cop.cdcooper
  FROM crapcop cop
  WHERE cop.flgativo = 1;
  vr_cdrelato number(10);
BEGIN
   vr_cdrelato := 817;  
   FOR rw_crapcop IN cr_crapcop
   LOOP         
      Insert into cecred.craprel (CDRELATO,NRVIADEF,NRVIAMAX,NMRELATO,NRMODULO,NMDESTIN,NMFORMUL,INDAUDIT,CDCOOPER,PERIODIC,TPRELATO,INIMPREL,INGERPDF)
      values (vr_cdrelato,'1','999','RECUSA DE SEGURO PRESTAMISTA ','1','PRESTAMISTA','234col','0', rw_crapcop.cdcooper,'Diario','1','1','1');  
   END LOOP;
   COMMIT;
   EXCEPTION 
     WHEN OTHERS THEN 
       ROLLBACK;
END;
/