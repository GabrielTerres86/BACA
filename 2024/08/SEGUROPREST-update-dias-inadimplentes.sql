begin
update cecred.crapprm p
   set p.dsvlrprm = 5
 where p.cdacesso = 'DIAS_MAX_REPIQUE_SEGPRE';
commit;
end;
