BEGIN
  -- Test statements here
  FOR rw IN (  SELECT cob.progress_recid
	                   ,cob.dtvencto
                     ,dsc.*
                 FROM cecred.crapret           ret
                     ,cecred.crapcco           cco
                     ,cecred.crapcob           cob
                     ,cobranca.tbcobran_desconto dsc
                WHERE cco.cdcooper > 0
                  AND cco.cddbanco = 85
                  AND ret.cdcooper = cco.cdcooper
                  AND ret.nrcnvcob = cco.nrconven
                  AND ret.dtocorre >= to_date('22/09/2024','DD/MM/RRRR')
                  AND ret.cdocorre = 7
                  AND cob.cdcooper = ret.cdcooper
                  AND cob.nrdconta = ret.nrdconta
                  AND cob.nrcnvcob = ret.nrcnvcob
                  AND cob.nrdocmto = ret.nrdocmto
                  AND cob.vldescto > 0
                  AND dsc.nrprogress_recid_crapcob = cob.progress_recid
                  AND dsc.dhinativacao IS NULL
                  AND dsc.dtlimite_desconto1 IS NULL
                  AND dsc.tpdesconto = 1) LOOP
                  
    UPDATE cobranca.tbcobran_desconto dsc SET dsc.dtlimite_desconto1 = rw.dtvencto
     WHERE dsc.iddesconto = rw.iddesconto;
                      
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
	  ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
/