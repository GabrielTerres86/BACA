DECLARE
  TYPE tp_varray IS VARRAY(15) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0020460',
								 'f0020379',
								 'f0020471',
								 'f0020380',
								 'f0020295',
								 'f0020405',
								 'f0020661',
								 'f0020695',
								 'f0020403',
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
     AND crapace.cdcooper = 2
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'C', vr_user(i), ' ', 2, 1, 0, 2);
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