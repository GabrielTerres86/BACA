BEGIN
  INSERT INTO CECRED.tbepr_renegociacao
    (CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR)
  VALUES
    (1, 6037623, 6062588, 0, 1, to_date('26-09-2022', 'dd-mm-yyyy'),48 ,4514.06 ,159.24 , to_date('14-09-2022', 'dd-mm-yyyy'), 0);

  INSERT INTO CECRED.tbepr_renegociacao_contrato
    (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR, CDFINEMP, CDLCREMP, DTDPAGTO,
     IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR, CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, 
     VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE, TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)
  VALUES
    (1, 6037623, 6062588, 3637088, 1, 4514.06, 4514.06, 159.24, 1, 0, 96, 15502, to_date('26-09-2022','dd-mm-yyyy'),  
     0, NULL, 0.00,1.01 , 0.00, 4,65 ,15502 ,62 ,  4514.06, 4514.06,1.01 , 0, 34.04, 0, 0, 0, 0);
 
  INSERT INTO CECRED.tbepr_renegociacao
    (CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR)
  VALUES
    (1, 6037623, 6062589, 0, 1, to_date('26-09-2022', 'dd-mm-yyyy'),48 ,393.39 , 13.88, to_date('14-09-2022', 'dd-mm-yyyy'), 0);

  INSERT INTO CECRED.tbepr_renegociacao_contrato
    (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR, CDFINEMP, CDLCREMP, DTDPAGTO,
     IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR, CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, 
     VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE, TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)
  VALUES
    (1, 6037623, 6062589, 3637132, 1, 393.39, 393.39, 13.88, 1, 0, 96,15502 , to_date('26-09-2022','dd-mm-yyyy'),  
     0, NULL, 0.00, .1, 0.00, 4, 65, 15502, 62,  393.39, 393.39,.1 , 0, 34.07, 0, 0, 0, 0);
     
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
