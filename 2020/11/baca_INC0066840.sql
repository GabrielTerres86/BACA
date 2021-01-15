begin
  update crapbpr x
  set    x.flglbseg = 1
  where  x.cdcooper = 13
  and    x.nrdconta = 301353
  and    x.nrctrpro = 24855
  and    x.dschassi = '9BYC48A2AAC000394';
  --
  commit;
end;  
