DECLARE
  TYPE tp_varray IS VARRAY(16) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0160198',
								 'f0160656',
								 'f0160262',
								 'f0160718',
								 'f0160017',
								 'f0160019',
								 'f0160351',
								 'f0160507',
								 'f0160255',
								 'f0160003',
								 'f0160039',
								 'f0160107',
								 'f0160062',
								 'f0160597',
								 'f0160595',
								 'f0160055');
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'N'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 16
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 16, 1, 0, 2);
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