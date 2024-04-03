BEGIN
  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '892');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '914');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'CONTA_FUNDING_CONTRATO', 'Registro do movimento de inclusão de contrato de Funding na Central', '930');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 2, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '906');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 7, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '922');

  insert into cecred.crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 11, 'CONTA_PRO_COTISTA_CTR', 'Registro do movimento de inclusão de contrato de Pro-Cotista na Central', '949');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
