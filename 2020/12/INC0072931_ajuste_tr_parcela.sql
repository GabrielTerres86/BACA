BEGIN
  update crapepr e set e.dtdpagto = to_date('16/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 646849 and e.nrctremp = 786138;
  update crapepr e set e.dtdpagto = to_date('15/10/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2041286 and e.nrctremp = 497053;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;