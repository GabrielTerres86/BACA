DECLARE
  TYPE tp_varray IS VARRAY(14) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0070618',
								 'f0070686',
								 'f0070631',
								 'f0070451',
								 'f0070397',
								 'f0070079',
								 'f0070681',
								 'f0070001',
								 'f0033715',
								 'f0033379',
								 'f0033210',
								 'f0033304',
								 'f0033328',
								 'f0033406');
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'N'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 7
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'N', vr_user(i), ' ', 7, 1, 0, 2);
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