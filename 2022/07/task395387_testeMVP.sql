DECLARE
  pr_contrato credito.tbcred_repasses_contrato%ROWTYPE;
  pr_riscosrepasse credito.tbcred_repasses_risco%ROWTYPE;
  
  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);

BEGIN
  
  pr_contrato.CDCOOPER             := 1;
  pr_contrato.NRDCONTA             := 2634600;
  pr_contrato.NRCTREMP             := 5680903;
  pr_contrato.NRCTRREPASSADOR      := 999;
  pr_contrato.DHIMPORTACAOVIEW     := to_date('18-07-2022 12:24:31','dd-mm-yyyy hh24:mi:ss');
  pr_contrato.CDUSUARIOINCLUSAO    := '123';
  pr_contrato.VLOPERACAO           := 500000.00;
  pr_contrato.VLPARCELA            := 8393.81;
  pr_contrato.DTHOMOLREPASSADOR    := to_date('04-05-2022', 'dd-mm-yyyy');
  pr_contrato.DTCONTRATACAO        := to_date('17-05-2022', 'dd-mm-yyyy');
  pr_contrato.DTLIBERARECURSO      := to_date('18-05-2022', 'dd-mm-yyyy');
  pr_contrato.DTLIQUIDOPERACAO     := NULL;
  pr_contrato.NRDIAPAGAMENTO       := 15;
  pr_contrato.DTVENCTOPROXPARC     := to_date('15-08-2022', 'dd-mm-yyyy');
  pr_contrato.DTULTIMOPAGTO        := NULL;
  pr_contrato.DTINIPGTOPRINC       := to_date('15-01-2023', 'dd-mm-yyyy');
  pr_contrato.DTINIPGTOCARENC      := to_date('15-08-2022', 'dd-mm-yyyy');
  pr_contrato.DTFIMPGTOPRINC       := to_date('17-05-2027', 'dd-mm-yyyy');
  pr_contrato.DTFIMPGTOCARENC      := to_date('15-12-2022', 'dd-mm-yyyy');
  pr_contrato.DTPREJUZ             := NULL;
  pr_contrato.INSITCONTRATO        := 'N';
  pr_contrato.INCARACTEROPERAC     := 'A';
  pr_contrato.IDREPASSADOR_CREDITO := 1;
  pr_contrato.IDPRODUTO_REPASSE    := 24000;
  pr_contrato.IDSUBPRODUTO_REPASSE := 1;
  pr_contrato.VLSALDODEVEDOR       := 507052.94;
  pr_contrato.NRPRAZOTOTAL         := 44;
  pr_contrato.NRPRAZOCARENCIA      := 3;
  pr_contrato.NRPRAZOPRINCIPAL     := 41;
  pr_contrato.INPERIODOCARENCIA    := '1';
  pr_contrato.QTPARCELASPAGAS      := 0;
  pr_contrato.CDINDEXADOR          := 32;
  pr_contrato.DSINDEXADOR          := 'SELIC';
  pr_contrato.NRBASECALCINDEX      := 252;
  pr_contrato.VLPERCENTINDEX       := 0.00;
  pr_contrato.VLCUSTOEFETIVOPE     := 8.00;
  pr_contrato.VLSPREADCOOPERATIVA  := 0.00;
  pr_contrato.VLSPREADREPASSADOR   := 0.00;
  pr_contrato.VLIOF                := 0.00;
  pr_contrato.VLTARIFA             := 0.00;
  pr_contrato.TPFORMAPAGTO         := 0;
  pr_contrato.QTDIASATRASO         := 0;
  pr_contrato.VLATRASO             := 0.00;
  pr_contrato.INRATING             := 'A';
  pr_contrato.QTMESESDECORRIDOS    := 0;
  pr_contrato.VLMULTAATRASO        := 0.00;
  pr_contrato.VLIOFATRASO          := 0.00;
  pr_contrato.VLJURM60             := 0.00;

  pr_riscosrepasse.CDCOOPER     := 1;
  pr_riscosrepasse.NRDCONTA     := 2634600;
  pr_riscosrepasse.NRCTREMP     := 5680903;
  pr_riscosrepasse.DTREFERE     := to_date('30-06-2022', 'dd-mm-yyyy');
  pr_riscosrepasse.CDMODALI     := '04';
  pr_riscosrepasse.CDSUBMODALI  := '99';
  pr_riscosrepasse.DHIMPORTVIEW := to_date('04-07-2022 17:02:18','dd-mm-yyyy hh24:mi:ss');
  pr_riscosrepasse.INCLASSRISCO := 'X';
  pr_riscosrepasse.VLVEC30      := 444.90;
  pr_riscosrepasse.VLVEC60      := 416.67;
  pr_riscosrepasse.VLVEC90      := 416.67;
  pr_riscosrepasse.VLVEC180     := 1250.01;
  pr_riscosrepasse.VLVEC360     := 2500.02;
  pr_riscosrepasse.VLVEC720     := 2083.05;
  pr_riscosrepasse.VLVEC1080    := 0.00;
  pr_riscosrepasse.VLVEC1440    := 0.00;
  pr_riscosrepasse.VLVEC1800    := 0.00;
  pr_riscosrepasse.VLVEC5400    := 0.00;
  pr_riscosrepasse.VLVECSUP5400 := 0.00;
  pr_riscosrepasse.VLDIV14      := 0.00;
  pr_riscosrepasse.VLDIV30      := 0.00;
  pr_riscosrepasse.VLDIV60      := 0.00;
  pr_riscosrepasse.VLDIV90      := 0.00;
  pr_riscosrepasse.VLDIV120     := 0.00;
  pr_riscosrepasse.VLDIV150     := 0.00;
  pr_riscosrepasse.VLDIV180     := 0.00;
  pr_riscosrepasse.VLDIV240     := 0.00;
  pr_riscosrepasse.VLDIV300     := 0.00;
  pr_riscosrepasse.VLDIV360     := 0.00;
  pr_riscosrepasse.VLDIV540     := 0.00;
  pr_riscosrepasse.VLDIVSUP540  := 0.00;
  pr_riscosrepasse.VLPRJ12      := 0.00;
  pr_riscosrepasse.VLPRJ48      := 0.00;
  pr_riscosrepasse.VLPRJSUP48   := 0.00;
  
  credito.inserirContratoRepasse(pr_contrato => pr_contrato, pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
  
  credito.inserirRiscosRepasse(pr_riscosrepasse => pr_riscosrepasse, pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);
  
  pr_riscosrepasse.INCLASSRISCO := 'Y';
  
  credito.atualizarRiscosRepasse(pr_riscosrepasse => pr_riscosrepasse, pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 1, to_date('15-08-2022', 'dd-mm-yyyy'), 'C', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 2, to_date('15-11-2022', 'dd-mm-yyyy'), 'C', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 3, to_date('15-02-2023', 'dd-mm-yyyy'), 'C', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 4, to_date('15-03-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 5, to_date('15-04-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 6, to_date('15-05-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 7, to_date('15-06-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 8, to_date('15-07-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 9, to_date('15-08-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 10, to_date('15-09-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 11, to_date('15-10-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 12, to_date('15-11-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 13, to_date('15-12-2023', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 14, to_date('15-01-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 15, to_date('15-02-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 16, to_date('15-03-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 17, to_date('15-04-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 18, to_date('15-05-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 19, to_date('15-06-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 20, to_date('15-07-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 21, to_date('15-08-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 22, to_date('15-09-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 23, to_date('15-10-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 24, to_date('15-11-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 25, to_date('15-12-2024', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 26, to_date('15-01-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 27, to_date('15-02-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 28, to_date('15-03-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 29, to_date('15-04-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 30, to_date('15-05-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 31, to_date('15-06-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 32, to_date('15-07-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 33, to_date('15-08-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 34, to_date('15-09-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 35, to_date('15-10-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 36, to_date('15-11-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 37, to_date('15-12-2025', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 38, to_date('15-01-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 39, to_date('15-02-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 40, to_date('15-03-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 41, to_date('15-04-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 42, to_date('15-05-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 43, to_date('15-06-2026', 'dd-mm-yyyy'), 'P', 0);

  insert into credito.tbcred_repasses_parcelas (CDCOOPER, NRDCONTA, NRCTREMP, NRPARCELA, DTVENCIMENTO, TPPARCELA, INPARCELAPAGA)
  values (1, 2634600, 5680903, 44, to_date('15-07-2026', 'dd-mm-yyyy'), 'P', 0);
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
END;