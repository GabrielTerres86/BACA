BEGIN
  UPDATE crapepr pr
     SET inliquid = 1, vlsdeved = 0
   WHERE pr.tpemprst = 1
   AND pr.tpdescto = 2
   AND pr.inliquid = 0
   AND NOT EXISTS (SELECT 1 FROM crappep p
                    WHERE p.cdcooper = pr.cdcooper
                      AND p.nrdconta = pr.nrdconta
                      AND p.nrctremp = pr.nrctremp
                      AND p.inliquid = 0);
  COMMIT;
END;