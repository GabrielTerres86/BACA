/* INC0059563 - Atualizar o titulo para sem instru��o cip para poder excluir o protesto com anu�ncia*/
begin
  
  update crapcob cob
  set cob.ininscip = 0
  where cob.cdcooper = 5
  and   cob.nrdconta = 216771
  and   cob.nrcnvcob = 104002
  and   cob.nrdocmto = 102;
  commit;
  
end;
