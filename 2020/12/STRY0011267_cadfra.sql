DECLARE
  TYPE tp_varray IS VARRAY(16) OF VARCHAR2(10);
  vr_user tp_varray := tp_varray('f0030588'
                                ,'f0031608'
                                ,'f0031264'
                                ,'f0031901'
                                ,'f0031976'
                                ,'f0032686'
                                ,'f0032709'
                                ,'f0031295'
                                ,'f0032960'
                                ,'f0032858'
                                ,'f0030800'
                                ,'f0032602'
                                ,'f0032563'
                                ,'f0033117'
                                ,'f0033116'
                                ,'f0031251');
BEGIN
  UPDATE craptel
     SET cdopptel = 'C,A,E,B', lsopptel = 'CONSULTAR,ALTERAR,EXCLUIR,BLOQUEAR'
   WHERE nmdatela = 'CADFRA';
  COMMIT;
  FOR i IN 1 .. vr_user.count LOOP
    BEGIN
      INSERT INTO crapace
        (nmdatela, cddopcao, cdoperad, nmrotina, cdcooper, nrmodulo, idevento, idambace)
      VALUES
        ('CADFRA', 'B', vr_user(i), ' ', 3, 1, 0, 2);
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
