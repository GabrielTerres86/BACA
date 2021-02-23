BEGIN 
  update crapepr e set e.dtdpagto = to_date('20/01/2021','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 2356848   and e.nrctremp = 277548;
  update crapepr e set e.dtdpagto = to_date('22/11/2020','DD/MM/YYYY') where e.cdcooper = 1 and e.nrdconta = 3672409   and e.nrctremp = 473448;

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
END;
