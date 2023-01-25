BEGIN
  UPDATE cecred.crapris ris
     SET ris.cdmodali = 499
   WHERE ris.rowid IN (SELECT r.rowid
                         FROM crapris r
                             ,crapepr e
                        WHERE r.CDCOOPER = 7
                          AND r.CDCOOPER = e.cdcooper
                          AND r.NRDCONTA = e.NRDCONTA
                          AND r.NRCTREMP = e.NRCTREMP
                          AND r.cdmodali = 299
                          AND r.DTREFERE = to_date('31/12/2022', 'DD/MM/RRRR')
                          AND e.CDLCREMP IN (60202, 60204));

  COMMIT;                        
END;
