-- Created on 06/05/2020 by F0030248 
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  FOR rw IN (
		SELECT DISTINCT b.rowid rowid_bx, t.dscodbar, c.cdcooper, c.nrdconta, c.nrcnvcob, c.nrdocmto
			FROM tbcobran_devolucao t, tbcobran_baixa_operac b, crapcob c
		WHERE t.dtmvtolt >= '01/01/2020'
			AND b.cdcooper = t.cdcooper
			AND b.nrdconta = t.nrdconta
			AND b.nrcnvcob = t.nrcnvcob
			AND b.nrdocmto = t.nrdocmto
			AND c.cdcooper = t.cdcooper
			AND c.nrdconta = t.nrdconta
			AND c.nrcnvcob = t.nrcnvcob
			AND c.nrdocmto = t.nrdocmto
			AND c.incobran = 0
			AND b.tpoperac_jd = 'BO'
			AND NOT EXISTS (SELECT 1 FROM tbcobran_baixa_operac x
											WHERE 1=1
												AND x.cdcooper = t.cdcooper
												AND x.nrdconta = t.nrdconta
												AND x.nrcnvcob = t.nrcnvcob
												AND x.nrdocmto = t.nrdocmto
												AND x.tpoperac_jd = 'CO'
												AND x.dtmvtolt >= t.dtmvtolt)
		  
			ORDER BY c.cdcooper, c.nrdconta, c.nrcnvcob, c.nrdocmto) LOOP
			
		UPDATE tbcobran_baixa_operac SET tpoperac_jd = 'DV'
		WHERE ROWID = rw.rowid_bx;
			
	END LOOP;
	COMMIT;
end;