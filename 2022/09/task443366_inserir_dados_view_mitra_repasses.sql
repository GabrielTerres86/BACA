BEGIN 
    insert into credito.tbcred_repasse_contrato (IDREPASSE_CONTRATO, CDCOOPERATIVA, NRCONTA_CORRENTE, NRCONTRATO, NRCONTRATO_REPASSADOR, DHIMPORTACAO_VIEW, CDUSUARIO_INCLUSAO, VLOPERACAO, VLPARCELA, DTHOMOLOGACAO_REPASSADOR, DTCONTRATACAO, DTLIBERACAO_RECURSO, DTLIQUIDACAO_OPERACAO, NRDIA_PAGAMENTO, DTVENCTO_PROXIMA_PARCELA, DTULTIMO_PAGAMENTO, DTINICIO_PGTO_PRINCIPAL, DTINICIO_PGTO_CARENCIA, DTFIM_PGTO_PRINCIPAL, DTFIM_PGTO_CARENCIA, DTPREJUIZO, INSITUACAO_CONTRATO, INCARACTERISTICA_OPERACAO, IDREPASSADOR_SUBPRODUTO, VLSALDO_DEVEDOR, NRPRAZO_TOTAL, NRPRAZO_CARENCIA, NRPRAZO_PRINCIPAL, INPERIODO_CARENCIA, QTPARCELAS_PAGAS, CDINDEXADOR, DSINDEXADOR, NRBASE_CALCULO_INDEXADOR, VLPERCENTUAL_INDEXADOR, VLCUSTO_EFETIVO_OPERACAO, VLSPREAD_COOPERATIVA, VLSPREAD_REPASSADOR, VLIOF, VLTARIFA, FLFORMA_PAGAMENTO, QTDIAS_ATRASO, VLATRASO, INRATING, QTMESES_DECORRIDOS, VLMULTA_ATRASO, VLIOF_ATRASO, VLJUROS_MAIS_60, VLTAXA_AO_ANO)
    values (22, 10, 99996596, 5680905, 999, to_date('30-09-2022 12:09:41', 'dd-mm-yyyy hh24:mi:ss'), '123', 500000.00, 8393.81, to_date('04-05-2022', 'dd-mm-yyyy'), to_date('17-05-2022', 'dd-mm-yyyy'), to_date('18-05-2022', 'dd-mm-yyyy'), null, 15, to_date('15-08-2022', 'dd-mm-yyyy'), null, to_date('15-01-2023', 'dd-mm-yyyy'), to_date('15-08-2022', 'dd-mm-yyyy'), to_date('17-05-2027', 'dd-mm-yyyy'), to_date('15-12-2022', 'dd-mm-yyyy'), null, 'N', 'A', 1, 507052.94, 44, 3, 41, 1, 2, 32, 'SELIC', 252, 0.00, 8.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0.00, 'A', 0, 0.00, 0.00, 0.00, 0.00);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 1, to_date('15-08-2022', 'dd-mm-yyyy'), 'C', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 2, to_date('15-11-2022', 'dd-mm-yyyy'), 'C', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 3, to_date('15-02-2023', 'dd-mm-yyyy'), 'C', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 4, to_date('15-03-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 5, to_date('15-04-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 6, to_date('15-05-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 7, to_date('15-06-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 8, to_date('15-07-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 9, to_date('15-08-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 10, to_date('15-09-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 11, to_date('15-10-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 12, to_date('15-11-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 13, to_date('15-12-2023', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 14, to_date('15-01-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 15, to_date('15-02-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 16, to_date('15-03-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 17, to_date('15-04-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 18, to_date('15-05-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 19, to_date('15-06-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 20, to_date('15-07-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 21, to_date('15-08-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 22, to_date('15-09-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 23, to_date('15-10-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 24, to_date('15-11-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 25, to_date('15-12-2024', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 26, to_date('15-01-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 27, to_date('15-02-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 28, to_date('15-03-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 29, to_date('15-04-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 30, to_date('15-05-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 31, to_date('15-06-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 32, to_date('15-07-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 33, to_date('15-08-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 34, to_date('15-09-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 35, to_date('15-10-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 36, to_date('15-11-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 37, to_date('15-12-2025', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 38, to_date('15-01-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 39, to_date('15-02-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 40, to_date('15-03-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 41, to_date('15-04-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 42, to_date('15-05-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 43, to_date('15-06-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into credito.tbcred_repasse_parcela (IDREPASSE_CONTRATO, NRPARCELA, DTVENCIMENTO, TPPARCELA, FLPARCELA_PAGA)
    values (22, 44, to_date('15-07-2026', 'dd-mm-yyyy'), 'P', 0);

    insert into crapris (NRDCONTA, DTREFERE, INNIVRIS, QTDIAATR, VLDIVIDA, VLVEC180, VLVEC360, VLVEC999, VLDIV060, VLDIV180, VLDIV360, VLDIV999, VLPRJANO, VLPRJAAN, INPESSOA, NRCPFCGC, VLPRJANT, INDDOCTO, CDMODALI, NRCTREMP, NRSEQCTR, DTINICTR, CDORIGEM, CDAGENCI, INNIVORI, CDCOOPER, VLPRJM60, DTDRISCO, QTDRICLQ, NRDGRUPO, VLJURA60, ININDRIS, CDINFADI, NRCTRNOV, FLGINDIV, DSINFAUX, DTPRXPAR, VLPRXPAR, QTPARCEL, DTVENCOP, DTTRFPRJ, VLSLD59D, FLINDBNDES, VLMRAPAR60, VLJUREMU60, VLJURCOR60, VLJURANTPP, VLJURPARPP, VLJURMORPP, VLJURMULPP, VLJURIOFPP, VLJURCORPP, INESPECIE, QTDIAATR_ORI, NRACORDO, FLARRASTO)
    values (99996596, to_date('31/08/2022', 'dd-mm-yyyy'), 2, 0, 2521.24, 336.46, 616.56, 1904.68, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 29525450732, 0.00, 1, 499, 5680905, 2, to_date('09-06-2021', 'dd-mm-yyyy'), 3, 1, 2, 10, 0.00, to_date('15-06-2021', 'dd-mm-yyyy'), 0, 0, 0.00, 2, ' ', 0, 0, 'BNDES', to_date('17-10-2022', 'dd-mm-yyyy'), 53.16, 60, to_date('15-06-2026', 'dd-mm-yyyy'), null, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0, 0, 1);

    commit;
    
EXCEPTION
  WHEN OTHERS THEN
  RAISE_APPLICATION_ERROR(-25000, SQLERRM);
END;