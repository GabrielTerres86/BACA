BEGIN
  UPDATE credito.tbcred_pronampe_remessa r
     SET r.dtenviospb       = NULL
        ,r.nrctrlifenviospb = NULL
        ,r.flenviospb       = 0
   WHERE nrremessa = 70;
  COMMIT;
END;
