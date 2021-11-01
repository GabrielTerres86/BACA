BEGIN
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 1, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '30');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 2, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 3, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 5, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 6, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 7, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 8, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 9, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 10, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 11, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 12, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 13, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 14, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 16, 'QTD_PARALE_CRPS724_DIA', 'Quantidade de execuções paralelas no CRPS724 diario', '0');

    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
