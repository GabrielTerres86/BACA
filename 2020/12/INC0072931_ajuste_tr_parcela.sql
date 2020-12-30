BEGIN
  update crapepr e set e.dtdpagto = to_date('16/12/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 646849 and e.nrctremp = 786138;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;