DECLARE
  TYPE tp_varray IS VARRAY(2) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0060078',
							     'f0060259');
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'N'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 6
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 6, 1, 0, 2);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN	    
        ROLLBACK;	
    END;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;	   