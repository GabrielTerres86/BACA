begin
  
update crapprm m 
  set m.dsvlrprm = '%06/10/2021#1%'
where m.cdacesso like '%CTRL_CRPS538_2_EXEC%';

commit;
end;
