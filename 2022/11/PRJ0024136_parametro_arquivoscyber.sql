BEGIN
  BEGIN
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
    values ('CRED', 0, 'CRPS652_CYBER_CONTACTR', 'Indica se irá gerar dados da conta e contrato com mais dígitos', 'S');
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE CRAPPRM
         SET DSVLRPRM = 'S'
       WHERE CDCOOPER = 0
         AND CDACESSO = 'CRPS652_CYBER_CONTACTR'
         AND NMSISTEM = 'CRED';
  END;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
