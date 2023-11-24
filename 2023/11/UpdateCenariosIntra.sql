BEGIN
  UPDATE cecred.crapcob c
     SET c.dtbloque = trunc(SYSDATE)
        ,c.dtsitcrt = trunc(SYSDATE)
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 90002
     AND c.nrdocmto <= 90003;

  UPDATE cecred.crapcob c
     SET c.incobran = 5
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 90004
     AND c.nrdocmto <= 90005;

  UPDATE cecred.crapcob c
     SET c.vltitulo = 10
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 90006
     AND c.nrdocmto <= 90007;
 COMMIT;     
END;
