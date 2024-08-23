begin
  
delete crapdev v
where  v.cdcooper = 12;
commit;

update crapfdc c
  set c.nrdctabb = 82921288,
      c.nrctachq = 82921288
where  c.cdcooper = 12
  and  c.dtliqchq is null
  and  c.nrdconta = 82921288
  and  c.dtretchq is not null;
commit;  
end;
