begin

  FOR cop IN (SELECT cdcooper FROM crapcop 
	             WHERE cdcooper <> 3 
                 AND cdcooper >= 1 
                 AND flgativo = 1) LOOP

    FOR rw IN ( SELECT bdt.cdcooper, tdb.rowid tdb_rowid, cob.rowid cob_rowid, cco.nrdctabb
		              FROM crapbdt bdt, craptdb tdb, crapcob cob, crapcco cco
                 WHERE bdt.cdcooper = cop.cdcooper
                   AND bdt.insitbdt = 3
                   AND tdb.cdcooper = bdt.cdcooper
                   AND tdb.nrborder = bdt.nrborder
                   AND tdb.insittit = 4
                   AND cob.cdcooper = tdb.cdcooper
                   AND cob.nrdconta = tdb.nrdconta
                   AND cob.nrcnvcob = tdb.nrcnvcob
                   AND cob.nrdocmto = tdb.nrdocmto
                   AND cco.cdcooper = cob.cdcooper
                   AND cco.nrconven = cob.nrcnvcob
                   ) LOOP  
     
        UPDATE crapcob cob SET nrdctabb = rw.nrdctabb, nrnosnum = to_char(cob.nrdconta,'fm00000000') || to_char(cob.nrdocmto,'fm000000000')
         WHERE ROWID = rw.cob_rowid;
         
        UPDATE craptdb tdb SET nrdctabb = rw.nrdctabb
         WHERE ROWID = rw.tdb_rowid;                  
    
    END LOOP;

    COMMIT;

  END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
     
end;
