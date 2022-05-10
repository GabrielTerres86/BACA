begin

update crapsli 
    SET vlsddisp = 399255.92
   WHERE nrdconta = 191051 
     AND cdcooper = 9
     AND dtrefere = to_date('30/04/2022','dd/mm/yyyy');
     
  insert into craplci (CDAGENCI, CDBCCXLT, DTMVTOLT, NRDOLOTE, NRDCONTA, CDHISTOR, NRDOCMTO, NRSEQDIG, VLLANMTO, CDCOOPER, NRAPLICA)
  values (1, 100, to_date('02-05-2022', 'dd-mm-yyyy'), 10113, 191051, 490, 38, 1, 399255.92, 9,  0);

  commit;

end;       
