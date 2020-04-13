begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'URL_NOVO_SGE', 'URL do portal Dynamics do novo Sistema de Gerenciamento de Eventos', 'https://ailosincident.powerappsportals.com/pa/registrar/');
  commit;
exception
  when others then
    cecred.pc_internal_exception;
end;