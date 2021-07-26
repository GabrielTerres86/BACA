BEGIN
  BEGIN
    UPDATE crawcrd
       SET cdadmcrd = 15,
           cdlimcrd = 20,
           dddebito = 11,
           dtentreg = NULL,
           dtlibera = trunc(SYSDATE),
           dtrejeit = NULL,
           insitcrd = 3,
           nrcctitg = 7563232018039,
           nrcrcard = 5474080216784437
     WHERE cdcooper = 6
       AND nrdconta = 201901
       AND nrctrcrd = 91041;
    
  END;

  BEGIN
    INSERT INTO crapcrd
      (cdcooper,
       nrdconta,
       nrcrcard,
       nrcpftit,
       nmtitcrd,
       dddebito,
       cdlimcrd,
       dtvalida,
       nrctrcrd,
       cdmotivo,
       nrprotoc,
       cdadmcrd,
       tpcartao,
       dtcancel,
       flgdebit,
       flgprovi)
    VALUES
      (6,
       201901,
       5474080216784437,
       2135268917,
       'EDUARDO DOS REIS',
       11,
       20,
       '30/04/2027',
       91041,
       0,
       0,
       15,
       2,
       NULL,
       0,
       0);
  END;
  
  COMMIT;
  
END;
