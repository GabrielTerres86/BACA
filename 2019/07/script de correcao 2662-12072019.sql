--1-Conta 8454868 cooperativa 1 - correção de ch no vlr 2100.00 NRDOCMTO 154242

 UPDATE crapdpb t 
    SET t.VLLANMTO = t.VLLANMTO - 2100.00
  WHERE t.cdcooper = 1
    AND t.nrdconta = 8454868
  AND t.cdhistor=2662
  AND t.DTLIBLAN = '12/07/2019'
  AND NRDOCMTO = 154242;

commit;
-----------------------------------------------------

--2-Conta 2685655 cooperativa 1 - correção de ch no vlr 8334.00 NRDOCMTO 157008

 UPDATE crapdpb t 
    SET t.VLLANMTO = t.VLLANMTO - 8334.00
  WHERE t.cdcooper = 1
    AND t.nrdconta = 2685655
  AND t.cdhistor=2662
  AND t.DTLIBLAN = '12/07/2019'
  AND NRDOCMTO = 157008;

commit;
-----------------------------------------------------