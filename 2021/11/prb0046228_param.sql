BEGIN
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 1, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 2, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 3, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 5, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 6, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 7, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 8, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 9, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 10, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 11, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 12, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 13, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 14, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');

    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 16, 'CCB_PERCENT_CUSTO_FINAN', 'valor a ser exbido no percentual de custo financeiro do CCB', '100');
    
    COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
