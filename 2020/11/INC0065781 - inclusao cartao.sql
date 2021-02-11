BEGIN
  INSERT INTO CRAWCRD
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
     DTENTR2V,
     DTPROPOS,
     FLGDEBIT,
     NMEMPCRD,
     INSITCRD,
     CDGRAUPR,
     DTLIBERA)
  VALUES
    (9487921,
     5158940055456061,
     7563239346153,
     88637999115.00,
     10000.00,
     3,
     TRUNC(SYSDATE),
     'WELINGTON ZAHN SILVA',
     1,
     3,
     0,
     1,
     8056.00,
     11,
     44,
     2,
     TO_DATE('05-10-1979', 'dd-mm-yyyy'),
     '298144330',
     'JOAQUIM SOUZA',
     FN_SEQUENCE('CRAPMAT', 'NRCTRCRD', 1),
     13,
     1,
     CCRD0003.FN_SEQUENCE_NRSEQCRD(PR_CDCOOPER => 1),
     TRUNC(SYSDATE),
     TRUNC(SYSDATE),
     1,
     '0',
     3,
     5,
     TRUNC(SYSDATE));

  -- Insere o cartao
  INSERT INTO CRAPCRD
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
     FLGDEBIT)
    SELECT W.CDCOOPER,
           W.NRDCONTA,
           W.NRCRCARD,
           W.NRCPFTIT,
           W.NMTITCRD,
           W.DDDEBITO,
           W.CDLIMCRD,
           W.DTVALIDA,
           W.NRCTRCRD,
           W.CDMOTIVO,
           W.NRPROTOC,
           W.CDADMCRD,
           W.TPCARTAO,
           W.DTCANCEL,
           W.FLGDEBIT
      FROM CRAWCRD W
     WHERE W.CDCOOPER = 1
       AND W.NRDCONTA = 9487921
       AND W.NRCRCARD = 5158940055456061;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20343,
                            'Erro ao inserir registro de cartao de credito crawcrd/crapcrd.' ||
                            SQLERRM);
       

END;