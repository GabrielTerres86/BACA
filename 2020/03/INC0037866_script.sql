begin
 update crawepr e
    set e.insitest = 0,
        e.qttentreenv = 0
  where exists (SELECT w.cdcooper,
                       w.nrdconta,
                       w.nrctremp,
                       d.dtmvtolt,
                       w.cdoperad,
                       w.cdagenci
                  FROM crawepr w, crapdat d
                 WHERE w.cdfinemp = 77
                   AND w.insitapr = 0
                   AND w.insitest in (0, 1)
                   AND w.dtmvtolt > '01/02/2020'
                   AND w.dtmvtolt < d.dtmvtolt
                   AND w.cdcooper = d.cdcooper
                   and w.rowid = e.rowid); 
           
  dbms_output.put_line('Registros Atualizados Update: '||sql%rowcount);         

  FOR rw_crawepr IN ( SELECT w.cdcooper
                           , w.nrdconta
                           , w.nrctremp
                           , d.dtmvtolt
                           , w.cdoperad
                           , w.cdagenci
                        FROM crawepr w
                            ,crapdat d
                       WHERE w.cdfinemp = 77
                         AND w.insitapr = 0
                         AND w.insitest in (0,1)
                         AND w.dtmvtolt > '01/02/2020'
                         AND w.dtmvtolt < d.dtmvtolt
                         AND w.cdcooper = d.cdcooper )
  LOOP
    begin
      INSERT INTO tbepr_reenvio_analise
                  (dtinclus, --1
                   cdcooper, --2
                   nrdconta, --3 
                   nrctremp, --4
                   insitrnv, --5
                   dtagernv, --6
                   nrhragen, --7
                   cdagenci, --8
                   cdoperad) --9
                VALUES
                  (rw_crawepr.dtmvtolt,      --1
                   rw_crawepr.cdcooper,      --2
                   rw_crawepr.nrdconta,      --3
                   rw_crawepr.nrctremp,      --4
                   0,                        --5
                   rw_crawepr.dtmvtolt,      --6
                   to_char(sysdate,'sssss'), --7
                   rw_crawepr.cdagenci,      --8
                   rw_crawepr.cdoperad);     --9
    exception
       when dup_val_on_index then
           null; 
    end;             
  END LOOP;
  dbms_output.put_line('Registros Inseridos : '||sql%rowcount);  
  --
  commit;
exception  
  when others then
   rollback;
end;




