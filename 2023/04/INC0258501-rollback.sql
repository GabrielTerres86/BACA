DECLARE
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
OPEN cr_crapass(pr_cdcooper => 	1	,pr_progress => 	1558796	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 1	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2721	and vllanmto = 		20.25	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	+	20.25	WHERE cdcooper = 	1	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	11	,pr_progress => 	903861	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 11	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		7.79	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	7.79	WHERE cdcooper = 	11	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	1	,pr_progress => 	1525657	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 1	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		16.42	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	16.42	WHERE cdcooper = 	1	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	16	,pr_progress => 	878171	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 16	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		45.24	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	45.24	WHERE cdcooper = 	16	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	16	,pr_progress => 	741489	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 16	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		127.47	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	127.47	WHERE cdcooper = 	16	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	1	,pr_progress => 	1405088	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 1	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		9.52	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	9.52	WHERE cdcooper = 	1	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	1	,pr_progress => 	1534015	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 1	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2408	and vllanmto = 		0.84	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	-	0.84	WHERE cdcooper = 	1	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;
OPEN cr_crapass(pr_cdcooper => 	1	,pr_progress => 	266707	);	FETCH cr_crapass INTO rw_crapass;	IF cr_crapass%FOUND THEN	delete from tbcc_prejuizo_detalhe where cdcooper = 1	and nrdconta = rw_crapass.nrdconta and cdhistor = 		2721	and vllanmto = 		7.65	and dtmvtolt = to_date('', 'dd/mm/rrrr');	UPDATE tbcc_prejuizo SET vlsdprej = Nvl(vlsdprej, 0) 	+	7.65	WHERE cdcooper = 	1	AND nrdconta = rw_crapass.nrdconta;	END IF; CLOSE cr_crapass;

COMMIT;

END;
