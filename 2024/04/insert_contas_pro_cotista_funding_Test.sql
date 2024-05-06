BEGIN
  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '99999927');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '99999919');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '99999900');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '99999897');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '99999889');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '99999870');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
