--INC0043245 - Excluir procuradores vencidos
begin
  delete crapavt c
   where c.cdcooper = 6
     and c.nrdconta = 119547
     and c.tpctrato = 6
     and c.dtvalida <= trunc(sysdate);
  
  commit;
end;