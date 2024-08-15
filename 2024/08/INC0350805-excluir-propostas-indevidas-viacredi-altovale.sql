DECLARE

CURSOR cr_propostas IS
  SELECT w.cdcooper,
		 w.nrdconta,
		 w.tpcustei,
		 w.nrctrato,
		 w.nrctrseg,
		 w.nrproposta,
		 w.nmdsegur,
		 w.vlpremio,
		 w.dtinivig,
		 w.dtfimvig
	FROM cecred.crawseg w
   WHERE NOT EXISTS (SELECT 0
	         		   FROM cecred.tbseg_prestamista p
					  WHERE p.cdcooper = w.cdcooper
						AND p.nrdconta = w.nrdconta
						AND p.nrctremp = w.nrctrato
						AND p.nrctrseg = w.nrctrseg)
					    AND w.tpcustei = 0
					    AND w.cdcooper IN (1, 16);

BEGIN

	FOR rw_propostas IN cr_propostas LOOP

	  DELETE FROM cecred.crawseg 
	   WHERE cdcooper = rw_propostas.cdcooper 
		 AND nrdconta = rw_propostas.nrdconta 
		 AND nrctrseg = rw_propostas.nrctrseg 
		 AND nrctrato = rw_propostas.nrctrato;

	END LOOP;

COMMIT;

END;