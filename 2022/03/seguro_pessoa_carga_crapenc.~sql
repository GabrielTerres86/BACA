BEGIN
  FOR rw_conta in (SELECT epr.nrdconta
                     FROM crapepr epr, crapass ass, craplcr lcr
                    WHERE ass.cdcooper = 1
                      AND ass.cdcooper = epr.cdcooper
                      AND ass.nrdconta = epr.nrdconta
                      AND lcr.cdcooper = epr.cdcooper
                      AND lcr.cdlcremp = epr.cdlcremp
                      AND ass.inpessoa = 1 
                      AND epr.inliquid = 0 
                      AND epr.inprejuz = 0 
                      AND epr.dtmvtolt >=
                          to_date('31/01/2000', 'DD/MM/RRRR') 
                      AND lcr.flgsegpr = 1
                      AND lcr.tpcuspr = 1 
                      AND NOT EXISTS (SELECT 'X'
                             from crapenc e
                            WHERE cdcooper = epr.cdcooper
                              and nrdconta = epr.nrdconta
                              and idseqttl = 1 
                              and dsendere is not null
                              and tpendass = 10 
                           )
                      AND NOT EXISTS
                    (SELECT seg.idseqtra
                             FROM tbseg_prestamista seg
                            WHERE seg.cdcooper = epr.cdcooper
                              AND seg.nrdconta = epr.nrdconta
                              AND seg.nrctremp = epr.nrctremp)
                    GROUP BY epr.nrdconta) LOOP
    INSERT INTO crapenc
      (cdcooper,
       nrdconta,
       dsendere,
       nrendere,
       nmbairro,
       nmcidade,
       cdufende,
       nrcepend,
       complend,
       tpendass)
    VALUES
      (1,
       rw_conta.nrdconta,
       'FICTICIO',
       99999,
       'FICTICIO',
       'FICTICIO',
       'SC',
       9999999999,
       'FICTICIO',
       10);
  END LOOP;
  COMMIT;
END;
/
