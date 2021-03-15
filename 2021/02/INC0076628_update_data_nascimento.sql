begin
  update crapass c
     set c.dtnasctl = to_date('26/07/1972', 'dd/mm/yyyy')
   where c.nrdconta = 86010
     and c.cdcooper = 16;

  update crapttl t
     set t.dtnasttl = to_date('26/07/1972', 'dd/mm/yyyy')
   where t.nrdconta = 86010
     and t.cdcooper = 16
     and t.idseqttl = 1;
     
  commit;
end;
