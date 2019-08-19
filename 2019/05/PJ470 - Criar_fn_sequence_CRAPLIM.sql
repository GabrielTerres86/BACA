DECLARE
  vr_nrctrato NUMBER;
BEGIN
  FOR r1 IN (SELECT *
               FROM CRAPCOP
              ORDER BY cdcooper)
  LOOP
    vr_nrctrato := fn_sequence('CRAPLIM'
                              ,'NRCTRLIM'
                              ,TO_CHAR(r1.cdcooper));
    UPDATE crapsqu a
       SET a.nrseqatu = '100000'
     WHERE a.nmtabela = 'CRAPLIM'
       AND a.nmdcampo = 'NRCTRLIM'
       AND a.dsdchave = TO_CHAR(r1.cdcooper);
  END LOOP;
  COMMIT;
END;
