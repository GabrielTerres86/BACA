BEGIN

update crapprm a
   set dsvlrprm = '/usr/coop/'
 where a.cdacesso = 'ROOT_DIRCOOP';
   COMMIT;

exception
  when others then
    raise_application_error(-20000, 'erro ao inserir dados: ' || sqlerrm);
END;