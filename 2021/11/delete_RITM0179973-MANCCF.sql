begin
  
delete crapneg  
where cdcooper = 1
  and nrdconta = 13151215
  and nrdocmto = 78
  and flgctitg = 4;
  
commit;
end;
