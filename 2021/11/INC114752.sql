declare
  cursor cSaldo is
   select *
     from craprac
    where idsaqtot = 0
      and vlsldatl = 0
      and cdprodut = 1007;
begin
  for x in cSaldo loop
  -- Atualizando os registros encontrados.
  update craprac 
     set idsaqtot = 1 
   where cdcooper = x.cdcooper
     and nrdconta = x.nrdconta
     and nraplica = x.nraplica;
end loop;
--
commit;
--
end;
