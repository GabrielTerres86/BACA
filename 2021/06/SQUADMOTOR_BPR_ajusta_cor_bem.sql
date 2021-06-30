begin
  update crapbpr set dscorbem = 'PRATA METÁLICA'
  where cdcooper = 1
  and nrdconta = 8009082
  and tpctrpro = 90
  and nrctrpro = 1465171
  and idseqbem = 1;

  update crapbpr set dscorbem = 'PRATA METÁLICA'
  where cdcooper = 1
  and nrdconta = 9353607
  and tpctrpro = 90
  and nrctrpro = 1468263
  and idseqbem = 1;

  update crapbpr set dscorbem = 'PRATA METÁLICA'
  where cdcooper = 1
  and nrdconta = 8563101
  and tpctrpro = 90
  and nrctrpro = 1476207
  and idseqbem = 1;

  commit;
end;
/