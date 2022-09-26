DECLARE
  pr_contrato      credito.tbcred_repasse_contrato%ROWTYPE;
  pr_riscosrepasse credito.tbcred_repasse_risco%ROWTYPE;

  vr_cdcritic NUMBER;
  vr_dscritic VARCHAR2(1000);
BEGIN

  pr_contrato.CDCOOPERATIVA             := 1;
  pr_contrato.NRCONTA_CORRENTE          := 99914492;
  pr_contrato.NRCONTRATO                := 5680904;
  pr_contrato.NRCONTRATO_REPASSADOR     := 999;
  pr_contrato.DHIMPORTACAO_VIEW         := to_date('18-07-2022 12:24:31',
                                                   'dd-mm-yyyy hh24:mi:ss');
  pr_contrato.CDUSUARIO_INCLUSAO        := '123';
  pr_contrato.VLOPERACAO                := 500000.00;
  pr_contrato.VLPARCELA                 := 6048.16;
  pr_contrato.DTHOMOLOGACAO_REPASSADOR  := to_date('03-05-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTCONTRATACAO             := to_date('17-05-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTLIBERACAO_RECURSO       := to_date('18-05-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTLIQUIDACAO_OPERACAO     := NULL;
  pr_contrato.NRDIA_PAGAMENTO           := 15;
  pr_contrato.DTVENCTO_PROXIMA_PARCELA  := to_date('15-08-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTULTIMO_PAGAMENTO        := NULL;
  pr_contrato.DTINICIO_PGTO_PRINCIPAL   := to_date('15-01-2023',
                                                   'dd-mm-yyyy');
  pr_contrato.DTINICIO_PGTO_CARENCIA    := to_date('15-08-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTFIM_PGTO_PRINCIPAL      := to_date('15-05-2027',
                                                   'dd-mm-yyyy');
  pr_contrato.DTFIM_PGTO_CARENCIA       := to_date('15-12-2022',
                                                   'dd-mm-yyyy');
  pr_contrato.DTPREJUIZO                := NULL;
  pr_contrato.INSITUACAO_CONTRATO       := 'N';
  pr_contrato.INCARACTERISTICA_OPERACAO := 'A';
  pr_contrato.IDREPASSADOR_SUBPRODUTO   := 1;
  pr_contrato.VLSALDO_DEVEDOR           := 507392.19;
  pr_contrato.NRPRAZO_TOTAL             := 24;
  pr_contrato.NRPRAZO_CARENCIA          := 2;
  pr_contrato.NRPRAZO_PRINCIPAL         := 22;
  pr_contrato.INPERIODO_CARENCIA        := '1';
  pr_contrato.QTPARCELAS_PAGAS          := 0;
  pr_contrato.CDINDEXADOR               := 32;
  pr_contrato.DSINDEXADOR               := 'SELIC';
  pr_contrato.NRBASE_CALCULO_INDEXADOR  := 252;
  pr_contrato.VLPERCENTUAL_INDEXADOR    := 0.00;
  pr_contrato.VLCUSTO_EFETIVO_OPERACAO  := 7.00;
  pr_contrato.VLSPREAD_COOPERATIVA      := 0.00;
  pr_contrato.VLSPREAD_REPASSADOR       := 0.00;
  pr_contrato.VLIOF                     := 0.00;
  pr_contrato.VLTARIFA                  := 0.00;
  pr_contrato.FLFORMA_PAGAMENTO         := 0;
  pr_contrato.QTDIAS_ATRASO             := 0;
  pr_contrato.VLATRASO                  := 0.00;
  pr_contrato.INRATING                  := 'A';
  pr_contrato.QTMESES_DECORRIDOS        := 0;
  pr_contrato.VLMULTA_ATRASO            := 0.00;
  pr_contrato.VLIOF_ATRASO              := 0.00;
  pr_contrato.VLJUROS_MAIS_60           := 0.00;
  pr_contrato.VLTAXA_AO_ANO             := 0.00;

  pr_riscosrepasse.IDREPASSE_CONTRATO     := 1;
  pr_riscosrepasse.DTREFERENCIA           := to_date('30-06-2022',
                                                     'dd-mm-yyyy');
  pr_riscosrepasse.CDMODALIDADE           := '04';
  pr_riscosrepasse.CDSUBMODALIDADE        := '99';
  pr_riscosrepasse.DHIMPORTACAO_VIEW      := to_date('04-07-2022 17:02:18',
                                                     'dd-mm-yyyy hh24:mi:ss');
  pr_riscosrepasse.INCLASSIFICACAO_RISCO  := 'X';
  pr_riscosrepasse.VLVENCER_30            := 444.90;
  pr_riscosrepasse.VLVENCER_60            := 416.67;
  pr_riscosrepasse.VLVENCER_90            := 416.67;
  pr_riscosrepasse.VLVENCER_180           := 1250.01;
  pr_riscosrepasse.VLVENCER_360           := 2500.02;
  pr_riscosrepasse.VLVENCER_720           := 2083.05;
  pr_riscosrepasse.VLVENCER_1080          := 0.00;
  pr_riscosrepasse.VLVENCER_1440          := 0.00;
  pr_riscosrepasse.VLVENCER_1800          := 0.00;
  pr_riscosrepasse.VLVENCER_5400          := 0.00;
  pr_riscosrepasse.VLVENCER_SUPERIOR_5400 := 0.00;
  pr_riscosrepasse.VLVENCIDO_14           := 0.00;
  pr_riscosrepasse.VLVENCIDO_30           := 0.00;
  pr_riscosrepasse.VLVENCIDO_60           := 0.00;
  pr_riscosrepasse.VLVENCIDO_90           := 0.00;
  pr_riscosrepasse.VLVENCIDO_120          := 0.00;
  pr_riscosrepasse.VLVENCIDO_150          := 0.00;
  pr_riscosrepasse.VLVENCIDO_180          := 0.00;
  pr_riscosrepasse.VLVENCIDO_240          := 0.00;
  pr_riscosrepasse.VLVENCIDO_300          := 0.00;
  pr_riscosrepasse.VLVENCIDO_360          := 0.00;
  pr_riscosrepasse.VLVENCIDO_540          := 0.00;
  pr_riscosrepasse.VLVENCIDO_SUPERIOR_540 := 0.00;
  pr_riscosrepasse.VLPREJUIZO_12          := 0.00;
  pr_riscosrepasse.VLPREJUIZO_48          := 0.00;
  pr_riscosrepasse.VLPREJUIZO_SUPERIOR_48 := 0.00;

  credito.inserirContratoRepasse(pr_contrato => pr_contrato,
                                 pr_cdcritic => vr_cdcritic,
                                 pr_dscritic => vr_dscritic);

  credito.inserirRiscosRepasse(pr_cdcooper      => 1,
                               pr_riscosrepasse => pr_riscosrepasse,
                               pr_cdcritic      => vr_cdcritic,
                               pr_dscritic      => vr_dscritic);

  pr_riscosrepasse.INCLASSIFICACAO_RISCO := 'Y';

  credito.atualizarRiscosRepasse(pr_cdcooper      => 1,
                                 pr_riscosrepasse => pr_riscosrepasse,
                                 pr_cdcritic      => vr_cdcritic,
                                 pr_dscritic      => vr_dscritic);

  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 1, to_date('15-08-2022', 'dd-mm-yyyy'), 'C', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 2, to_date('15-11-2022', 'dd-mm-yyyy'), 'C', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 3, to_date('15-02-2023', 'dd-mm-yyyy'), 'C', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 4, to_date('15-03-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 5, to_date('15-04-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 6, to_date('15-05-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 7, to_date('15-06-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 8, to_date('15-07-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 9, to_date('15-08-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 10, to_date('15-09-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 11, to_date('15-10-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 12, to_date('15-11-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 13, to_date('15-12-2023', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 14, to_date('15-01-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 15, to_date('15-02-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 16, to_date('15-03-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 17, to_date('15-04-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 18, to_date('15-05-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 19, to_date('15-06-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 20, to_date('15-07-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 21, to_date('15-08-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 22, to_date('15-09-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 23, to_date('15-10-2024', 'dd-mm-yyyy'), 'P', 0);
  INSERT INTO credito.tbcred_repasse_parcela
    (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
  VALUES
    (1, 24, to_date('15-11-2024', 'dd-mm-yyyy'), 'P', 0);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
END;