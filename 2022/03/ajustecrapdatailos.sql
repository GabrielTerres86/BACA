begin
  update crapdat
  set inproces = 1
  where cdcooper = 3;
  
  commit;
end;