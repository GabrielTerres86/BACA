begin
  
update cecred.crapprm m
  set m.dsvlrprm = '19/06/2024#1'
where m.cdacesso like '%CTRL_DEBNET_EXEC%' 
  and m.cdcooper = 13;
  
update cecred.crapprm m
  set m.dsvlrprm = '19/06/2024#1'
where m.cdacesso like '%CTRL_DEBNET_PRIORI_EXEC%' 
  and m.cdcooper = 13;      

commit;
end;
