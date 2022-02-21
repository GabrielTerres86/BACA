DECLARE
  TYPE tp_varray IS VARRAY(10) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0130197',
								 'f0130474',
								 'f0130372',
								 'f0130495',
								 'f0130392',
								 'f0130035',
								 'f0130538',
								 'f0130479',
								 'f0130245',
								 'f0130405');
					 
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'A'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 13
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'A', vr_user(i), ' ', 13, 1, 0, 2);
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