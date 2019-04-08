BEGIN

  UPDATE CRAPFDC
     SET INCHEQUE = 1
   WHERE (CDCOOPER = 1 AND NRDCONTA = 10058346 AND NRCHEQUE = 4);
  IF SQL%ROWCOUNT = 1 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

  INSERT INTO CRAPNEG
    (NRDCONTA,
     NRSEQDIG,
     DTINIEST,
     CDHISEST,
     CDOBSERV,
     NRDCTABB,
     NRDOCMTO,
     VLESTOUR,
     QTDIAEST,
     VLLIMCRE,
     CDBANCHQ,
     CDTCTANT,
     CDAGECHQ,
     CDTCTATU,
     NRCTACHQ,
     DTFIMEST,
     CDOPERAD,
     CDCOOPER,
     FLGCTITG,
     DTECTITG,
     IDSEQTTL,
     DTIMPREG,
     CDOPEIMP)
  VALUES
    (10058346,
     FN_SEQUENCE('CRAPNEG', 'NRSEQDIG', 1 || ';' || 10058346),
     TO_DATE('08-04-2019', 'dd-mm-yyyy'),
     1,
     49,
     10058346,
     43,
     833,
     0,
     500,
     85,
     0,
     101,
     0,
     10058346,
     NULL,
     '1',
     1,
     0,
     NULL,
     0,
     NULL,
     ' ');
  IF SQL%ROWCOUNT = 1 THEN
    COMMIT;
  ELSE
    ROLLBACK;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
    ROLLBACK;
END;
