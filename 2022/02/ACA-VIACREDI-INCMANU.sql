DECLARE
  TYPE tp_varray IS VARRAY(7) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0014246',
								 'f0015571',
								 'f0014236',
								 'f0015085',
								 'f0014948',
								 'f0014339',
								 'f0013438');
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'F'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 1
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 1, 1, 0, 2);
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