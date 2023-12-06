begin
  
  delete from crapneg neg
   where neg.cdcooper = 1
     and neg.dtiniest = to_date('19/10/2023', 'dd/mm/RRRR');
     
  commit;
  
exception
  when others then
    rollback;
  
end;
