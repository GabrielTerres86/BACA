DECLARE
  vr_nmtabela cecred.crapsqu.nmtabela%TYPE := 'CRAPNEG';
  vr_nmdcampo cecred.crapsqu.nmdcampo%TYPE := 'NRSEQDIG';
  vr_cdcooper NUMBER := 14;
BEGIN
  DELETE 
    FROM cecred.crapsqu a
   WHERE a.nmtabela = vr_nmtabela
     AND a.nmdcampo = vr_nmdcampo
     AND a.dsdchave LIKE vr_cdcooper || ';%';

  INSERT INTO cecred.crapsqu
    (SELECT vr_nmtabela nmtabela
           ,vr_nmdcampo nmdcampo
           ,a.cdcooper || ';' || a.nrdconta dsdchave
           ,MAX(a.nrseqdig) nrseqatu
       FROM crapneg a
      WHERE a.cdcooper = vr_cdcooper
      GROUP BY a.cdcooper
              ,a.nrdconta);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
