BEGIN 

  BEGIN 

    DELETE 
    FROM CECRED.CRAWCRD C 
    WHERE ROWID IN ('AA9OJCAIQAAKWGJAAN','AA9OJCAIQAALRMHAAG');

    COMMIT;

  END;


  DECLARE

    VR_NRCTRCRD CRAWCRD.NRCTRCRD%TYPE;
    VR_NRSEQCRD CRAWCRD.NRSEQCRD%TYPE;

  BEGIN

    VR_NRCTRCRD := FN_SEQUENCE('CRAPMAT','NRCTRCRD', 2);
    VR_NRSEQCRD := CCRD0003.FN_SEQUENCE_NRSEQCRD(2);

    INSERT INTO CECRED.CRAWCRD
      (NRDCONTA,
      NRCRCARD,
      NRCCTITG,
      NRCPFTIT,
      VLLIMCRD,
      FLGCTITG,
      DTMVTOLT,
      NMEXTTTL,
      FLGPRCRD,
      TPDPAGTO,
      FLGDEBCC,
      TPENVCRD,
      VLSALARI,
      DDDEBITO,
      CDLIMCRD,
      TPCARTAO,
      DTNASCCR,
      NRDOCCRD,
      NMTITCRD,
      NRCTRCRD,
      CDADMCRD,
      CDCOOPER,
      NRSEQCRD,
      DTPROPOS,
      DTSOLICI,
      FLGDEBIT,
      CDGRAUPR,
      INSITCRD,
      DTLIBERA,
      INSITDEC)
    VALUES  (950521,
             5474080364028579,
             7564438085820,
             10265625971,
             1000,
             3,
             TRUNC(SYSDATE),
             'SINAL SAT COMERCIO E SERVICOS ELETRICOS LTDA',
             1,
             1,
             1,
             0,
             0,
             19,
             0,
             2,
             TO_DATE('11/04/1997','DD/MM/YYYY'),
             06411980483,
             'JORDAN CALASANS',
             VR_NRCTRCRD,
             15,
             11,
             VR_NRSEQCRD,
             TO_DATE('16/05/2022','DD/MM/YYYY'),
             TO_DATE('16/05/2022','DD/MM/YYYY'),
             1,
             5,
             3,
             NULL,
             3);

    INSERT INTO CECRED.CRAPCRD
      (CDCOOPER,
      NRDCONTA,
      NRCRCARD,
      NRCPFTIT,
      NMTITCRD,
      DDDEBITO,
      CDLIMCRD,
      DTVALIDA,
      NRCTRCRD,
      CDMOTIVO,
      NRPROTOC,
      CDADMCRD,
      TPCARTAO,
      DTCANCEL,
      FLGDEBIT,
      FLGPROVI)
    VALUES  (11,
             950521,
             5474080364028579,
             10265625971,
             'JORDAN CALASANS',
             19,
             0,
             TO_DATE('31/07/2029','DD/MM/YYYY'),
             VR_NRCTRCRD,
             0,
             12,
             2,
             NULL,
             1,
             0);



  INSERT INTO TBCRD_CONTA_CARTAO 
    (CDCOOPER, NRDCONTA, NRCONTA_CARTAO, VLLIMITE_GLOBAL, CDADMCRD)
  VALUES 
    (11, 950521, 7564438085820, NULL, 16);

  COMMIT;


  END;
END; 