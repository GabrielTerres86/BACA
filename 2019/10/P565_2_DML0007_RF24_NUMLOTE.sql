begin
  for creg in (select cdcooper from crapcop) loop
     insert into crapprm (nmsistem, cdcooper, cdacesso,dstexprm,dsvlrprm)
     values ('CRED',   creg.cdcooper,'NUMLOTEXTCONV','Nro lote para geracao historico 2996', 1);
  end loop;
  commit;
end;
/
