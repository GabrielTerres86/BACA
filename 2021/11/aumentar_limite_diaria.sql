begin
  update crapprm prm
  set prm.dsvlrprm = '08/11/2021#0'
  WHERE prm.nmsistem = 'CRED'
    AND prm.cdcooper = 11
    AND prm.cdacesso = 'CTRL_CRPS538_EXEC';

  update crapprm prm
  set prm.dsvlrprm = '9'
  WHERE prm.nmsistem = 'CRED'
    AND prm.cdcooper = 11
    AND prm.cdacesso = 'QTD_EXEC_CRPS538';

  commit;
exception
  when OTHERS then
    raise_application_error(-20501, SQLERRM);
end;
/
