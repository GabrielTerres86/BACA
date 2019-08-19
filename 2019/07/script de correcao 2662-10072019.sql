--1-Conta 10626 cooperativa 1 - correção de ch no vlr 7000.00

 UPDATE crapdpb t 
    SET t.VLLANMTO = t.VLLANMTO - 7000.00
  WHERE t.cdcooper = 1
    AND t.nrdconta = 10626
	AND t.cdhistor=2662
	AND t.DTLIBLAN = '10/07/2019'
	AND NRDOCMTO = 189561;

commit;
-----------------------------------------------------
