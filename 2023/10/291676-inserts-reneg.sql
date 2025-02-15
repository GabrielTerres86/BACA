begin
  
INSERT INTO CECRED.tbepr_renegociacao(CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR)
VALUES (2, 291676, 492514, 0, 1, to_date('04/11/2023','dd/mm/yyyy'), 24, 2203.74, 120.06, to_date('06/10/2023','dd/mm/yyyy'), 0);
INSERT INTO CECRED.tbepr_renegociacao_contrato
    (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR,
     CDFINEMP, CDLCREMP, DTDPAGTO, IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR,
     CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE,
     TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)
VALUES (2, 291676, 492514, 395778, 2, 2203.74, 2189.673078284, 186.08, 1, 0,62, 985, to_date('04/11/2023','dd/mm/yyyy'), 0, null, 0,0, 0, 4, 87, 832, 54, 2203.74, 2203.74, 0, 0, 30.98, 0,1, 0, 0);


INSERT INTO CECRED.tbepr_renegociacao(CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR)
VALUES (2, 291676, 492516, 0, 1, to_date('04/11/2023','dd/mm/yyyy'), 24, 2510.45, 136.77, to_date('06/10/2023','dd/mm/yyyy'), 0);
INSERT INTO CECRED.tbepr_renegociacao_contrato
    (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR,
     CDFINEMP, CDLCREMP, DTDPAGTO, IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR,
     CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE,
     TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)
VALUES (2, 291676, 492516, 473059, 2, 2510.45, 2440.1058340379, 137.1, 1, 0,62, 985, to_date('04/11/2023','dd/mm/yyyy'), 0, null, 0,0, 0, 4, 0, 6901, 69, 2510.45, 2510.45, 0, 0, 30.98, 0,1, 0, 0);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
