begin
  
delete cecred.crapdev v
where  v.cdcooper = 12
  and  v.nrdctabb = 82921288;

commit;
end;
