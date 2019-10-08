begin
  for creg in (select cdcooper from crapcop) loop
     insert into craptab (nmsistem, tptabela, cdempres, cdacesso, tpregist, dstextab, cdcooper)
     values ('CRED','GENERI',0,'NUMLOTEXTCONV',0,1,creg.cdcooper);
  end loop;
  commit;
end;
