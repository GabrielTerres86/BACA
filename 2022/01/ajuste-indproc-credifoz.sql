begin
  update crapdat set inproces = 1 where cdcooper = 11;
  
  commit;
end;