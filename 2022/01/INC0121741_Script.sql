/* INC0121741 - Retirar o status de remessa de cartório do boleto para poder realizar a baixa */
BEGIN

  UPDATE crapcob cob
     SET cob.insitcrt = 0
   WHERE cob.incobran = 0
     AND cob.insitpro = 3
     AND cob.ininscip = 2
     AND cob.cdcooper IN (9, 11)
     AND cob.nrdconta IN (83399, 448184, 531472)
     AND cob.nrdocmto IN (3085, 3, 526);

  COMMIT;
END;
