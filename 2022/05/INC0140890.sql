begin
  
delete from crapcrd
where cdcooper = 1
and nrdconta = 10349782;

delete from crawcrd
where cdcooper = 1
and nrdconta = 10349782;

delete from tbcrd_conta_cartao
where cdcooper = 1
and nrdconta = 10349782;

commit;

end;
