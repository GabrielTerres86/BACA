BEGIN
  BEGIN
    UPDATE crawcrd
       SET cdadmcrd = 15,
           cdlimcrd = 5,
           dddebito = 19,
           dtentreg = NULL,
           dtlibera = trunc(SYSDATE),
           dtrejeit = NULL,
           insitcrd = 3,
           nrcctitg = 7563239681343,
           nrcrcard = 5474080191152410
     WHERE cdcooper = 1
       AND nrdconta = 12184047
       AND nrctrcrd = 1992508;
    
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
      (1,
       12184047,
       5474080191152410,
       11055670955,
       'MARIANA ELOISA PRIM',
       19,
       5,
       '31/03/2026',
       1992508,
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
