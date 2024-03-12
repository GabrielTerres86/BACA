BEGIN

  INSERT INTO cecred.crapstf
    (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
  VALUES
    (to_date('29-11-2023', 'dd-mm-yyyy'),43,0,0,16);

  INSERT INTO cecred.crapstf
    (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
  VALUES
    (to_date('29-11-2023', 'dd-mm-yyyy'),17,0,0,16);

  INSERT INTO cecred.crapstf
    (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
  VALUES
    (to_date('06-12-2023', 'dd-mm-yyyy'),63,0,0,16);
  
  INSERT INTO cecred.crapstf
    (DTMVTOLT,NRTERFIN,VLDSDINI,VLDSDFIN,CDCOOPER)
  VALUES
    (to_date('15-01-2016', 'dd-mm-yyyy'),2,0,0,16);

  COMMIT;

END;
