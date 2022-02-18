DECLARE
  TYPE tp_varray IS VARRAY(11) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0110357',
								 'f0110365',
								 'f0110478',
								 'f0110255',
								 'f0110243',
								 'f0110318',
								 'f0110595',
								 'f0110381',
								 'f0110008',
								 'f0110263',
								 'f0110320');
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'F'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 11
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 11, 1, 0, 2);
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