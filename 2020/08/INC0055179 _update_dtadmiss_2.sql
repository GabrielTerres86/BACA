begin
  --Informar a data de admiss�o para CREDCREA
  update crapass c 
     set c.dtadmiss = to_date('07/05/2004', 'dd/mm/yyyy')
   where c.nrdconta = 7239530 
     and c.cdcooper = 7;

  --Informar a data de admiss�o para ACREDICOOP
  update crapass c 
     set c.dtadmiss = to_date('31/03/2000', 'dd/mm/yyyy')
   where c.nrdconta = 7239530 
     and c.cdcooper = 2;

  --Informar a data de admiss�o para UNILOS
  update crapass c 
     set c.dtadmiss = to_date('31/03/2004', 'dd/mm/yyyy')
   where c.nrdconta = 7239530 
     and c.cdcooper = 6;

  --Informar a data de admiss�o para ACENTRA
  update crapass c 
     set c.dtadmiss = to_date('28/11/2003', 'dd/mm/yyyy')
   where c.nrdconta = 7239530 
     and c.cdcooper = 5;

  --Informar a data de admiss�o para CREDICOMIN
  update crapass c 
     set c.dtadmiss = to_date('18/06/2008', 'dd/mm/yyyy')
   where c.nrdconta = 7239530 
     and c.cdcooper = 10;

  --Efetiva as altera��es
  commit;      
end;
