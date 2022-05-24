begin    
    insert into tbcapt_saldo_consolidado (CDCOOPER, CDPRODUT, DTMVTOLT, VLSALDO, DTATUALIZACAO)
    values (3, 1109, to_date('16-05-2022', 'dd-mm-yyyy'), 114461482.9100, to_date('17-05-2022 09:31:07', 'dd-mm-yyyy hh24:mi:ss'));
    insert into tbcapt_saldo_consolidado (CDCOOPER, CDPRODUT, DTMVTOLT, VLSALDO, DTATUALIZACAO)
    values (3, 1109, to_date('17-05-2022', 'dd-mm-yyyy'), 116860364.8800, to_date('18-05-2022 07:15:36', 'dd-mm-yyyy hh24:mi:ss'));
    insert into tbcapt_saldo_consolidado (CDCOOPER, CDPRODUT, DTMVTOLT, VLSALDO, DTATUALIZACAO)
    values (3, 1109, to_date('18-05-2022', 'dd-mm-yyyy'), 117696763.7000, to_date('19-05-2022 07:15:33', 'dd-mm-yyyy hh24:mi:ss'));
    insert into tbcapt_saldo_consolidado (CDCOOPER, CDPRODUT, DTMVTOLT, VLSALDO, DTATUALIZACAO)
    values (3, 1109, to_date('19-05-2022', 'dd-mm-yyyy'), 119640174.5400, to_date('20-05-2022 07:15:33', 'dd-mm-yyyy hh24:mi:ss'));
    insert into tbcapt_saldo_consolidado (CDCOOPER, CDPRODUT, DTMVTOLT, VLSALDO, DTATUALIZACAO)
    values (3, 1109, to_date('20-05-2022', 'dd-mm-yyyy'), 120491358.5200, to_date('23-05-2022 07:15:34', 'dd-mm-yyyy hh24:mi:ss'));
    commit;
end;