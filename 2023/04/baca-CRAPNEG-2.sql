BEGIN

  DELETE FROM cecred.crapsqu
   WHERE UPPER(nmtabela) = upper('CRAPNEG')
         AND UPPER(nmdcampo) = upper('NRSEQDIG')
         AND UPPER(dsdchave) LIKE upper('13;%');

  INSERT INTO cecred.crapsqu
    (nmtabela, nmdcampo, dsdchave, nrseqatu)
    SELECT 'CRAPNEG', 'NRSEQDIG', '13;' || nrdconta, 3500
      FROM crapass
     WHERE cdcooper = 13;

  DELETE FROM cecred.tbgen_batch_paralelo p
   WHERE p.cdcooper = 13
         AND p.cdprogra = 'CRPS001' AND
   dtmvtolt = to_date('25/04/2023', 'dd/mm/yyyy');

  DELETE FROM cecred.crapsld a
   WHERE a.cdcooper = 13
         AND a.dtrefere = to_date('17/04/2023', 'dd/mm/yyyy');

  UPDATE cecred.crapsld a
     SET a.dtrefere = to_date('25/04/2023', 'dd/mm/yyyy')
   WHERE a.cdcooper = 13
         AND a.dtrefere = to_date('07/02/2023', 'dd/mm/yyyy');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
