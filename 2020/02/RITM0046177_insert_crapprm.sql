begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'EAD_AUTORIZATION', 'Autorização para EAD Konviva', 'KONVIVA');
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'EAD_PROTOCOLO', 'Protocolo para EAD Konviva', 'HTTPS');
  commit;
exception
  when others then
    cecred.pc_internal_exception;
end;
