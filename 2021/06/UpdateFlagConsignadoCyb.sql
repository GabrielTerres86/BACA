BEGIN
  UPDATE crapcyb b
     SET b.flgconsg = 1
   WHERE b.dtdbaixa IS NULL
     AND b.cdorigem = 3
     AND b.flgpreju = 1
     AND b.cdcooper = 1
     AND b.flgconsg = 0
     AND EXISTS (SELECT 1
            FROM crapepr epr
           WHERE epr.cdcooper = b.cdcooper
             AND epr.nrdconta = b.nrdconta
             AND epr.nrctremp = b.nrctremp
             AND epr.tpdescto = 2);
  COMMIT;
END;
