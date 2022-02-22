DECLARE
  TYPE tp_varray IS VARRAY(17) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0090424',
								 'f0090256',
								 'f0090190',
								 'f0090337',
								 'f0090534',
								 'f0090317',
								 'f0090585',
								 'f0090197',
								 'f0090407',
								 'f0090498',
								 'f0090540',
								 'f0033715',
								 'f0033379',
								 'f0033210',
								 'f0033304',
								 'f0033328',
								 'f0033406');								 
BEGIN
  DELETE FROM crapace
   WHERE UPPER(crapace.nmdatela) = 'IMOVEL'
     AND UPPER(crapace.cddopcao) = 'F'
     AND UPPER(crapace.nmrotina) = ' '
     AND crapace.cdcooper = 9
     AND crapace.idambace = 2;
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('IMOVEL', 'F', vr_user(i), ' ', 9, 1, 0, 2);
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