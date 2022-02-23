DECLARE
  TYPE tp_varray IS VARRAY(20) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0110454',
								 'f0110470',
								 'f0110595',
								 'f0110357',
								 'f0110365',
								 'f0110478',
								 'f0110255',
								 'f0110243',
								 'f0110318',
								 'f0110595',
								 'f0110381',
								 'f0110008',
								 'f0110263',
								 'f0110320',
								 'f0033715',
								 'f0033379',
								 'f0033210',
								 'f0033304',
								 'f0033328',
								 'f0033406');								 
								 
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'C'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 11
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 11, 1, 0, 2);
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