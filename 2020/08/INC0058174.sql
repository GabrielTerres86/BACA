begin
  update crapcem c
     set c.cddemail = nvl((select max(e.cddemail) from crapcem e where e.cdcooper = c.cdcooper and e.nrdconta = c.nrdconta and e.cddemail is not null),0) + 1 
   where c.cddemail is null;
   
  commit;
end;
