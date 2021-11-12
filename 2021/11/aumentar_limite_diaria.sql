begin
  update crapprm prm
  set prm.dsvlrprm = '9'
  WHERE prm.nmsistem = 'CRED'
    AND prm.cdcooper = 11
    AND prm.cdacesso = 'CTRL_CRPS538_EXEC';

  commit;
exception
  when OTHERS then
    raise_application_error(-20501, SQLERRM);
end;
/
