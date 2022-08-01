begin
update crapprm p
  set p.dsvlrprm = 44
 where p.cdacesso = 'DIAS_MAX_REPIQUE_SEGPRE';
 commit;
end;
/
