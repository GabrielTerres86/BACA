BEGIN
  UPDATE cecred.crapcob c
     SET c.dtbloque = trunc(SYSDATE)
        ,c.dtsitcrt = trunc(SYSDATE)
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 60001
     AND c.nrdocmto <= 60002;

  UPDATE cecred.crapcob c
     SET c.incobran = 5
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 60003
     AND c.nrdocmto <= 60004;

  UPDATE cecred.crapcob c
     SET c.vltitulo = 8
   WHERE c.nrdconta = 97693154
     AND c.dtvencto >= '22-12-2023'
     AND c.incobran = 0
     AND c.insitpro = 3
     AND c.nrdocmto >= 60005
     AND c.nrdocmto <= 60006;
 COMMIT;     
END;
