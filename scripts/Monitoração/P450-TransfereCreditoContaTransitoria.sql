declare 
  vr_recid_lcm craplcm.progress_recid%TYPE := 580321923; -- **** ALTERAR AQUI **** --
	
	vr_nrseqdig craplcm.nrseqdig%TYPE;
	
	vr_exc_notfound EXCEPTION;
	
	CURSOR cr_craplcm IS
	SELECT *
	  FROM craplcm
	 WHERE progress_recid = vr_recid_lcm;
	rw_craplcm cr_craplcm%ROWTYPE;
	
	CURSOR cr_crapdat(pr_cdcooper IN crapdat.cdcooper%TYPE) IS
	SELECT * 
	  FROM crapdat
	 WHERE cdcooper = pr_cdcooper;
	rw_crapdat cr_crapdat%ROWTYPE;
BEGIN
	-- Recupera registro da CRAPLCM a partir do PROGRESS_RECID fornecido
  OPEN cr_craplcm;
	FETCH cr_craplcm INTO rw_craplcm;
	
	IF cr_craplcm%NOTFOUND THEN
	  CLOSE cr_craplcm;
		
		RAISE vr_exc_notfound;
	ELSE
	  CLOSE cr_craplcm;
	END IF;
	
	OPEN cr_crapdat(rw_craplcm.cdcooper);
	FETCH cr_crapdat INTO rw_crapdat;
	CLOSE cr_crapdat;
  
	-- Lança estorno do crédito na CRAPLCM
	-- Calcula o "nrseqdig"
	vr_nrseqdig := FN_SEQUENCE(pr_nmtabela => 'CRAPLOT'
														,pr_nmdcampo => 'NRSEQDIG'
														,pr_dsdchave => to_char(rw_craplcm.cdcooper)||';'||
														to_char(rw_crapdat.dtmvtolt, 'DD/MM/RRRR')||';'||
														'1;100;650009');

	-- Efetua débito (estorno) do valor que será transferido para a Conta Transitória 
	INSERT INTO craplcm (
			dtmvtolt
		, cdagenci
		, cdbccxlt
		, nrdolote
		, nrdconta
		, nrdocmto
		, cdhistor
		, nrseqdig
		, vllanmto
		, nrdctabb
		, cdpesqbb
		, dtrefere
		, hrtransa
		, cdoperad
		, cdcooper
		, cdorigem
	)
	VALUES (
			rw_craplcm.dtmvtolt
		, rw_craplcm.cdagenci
		, rw_craplcm.cdbccxlt
		, 650009
		, rw_craplcm.nrdconta
		, rw_craplcm.nrdocmto
		, 2719
		, vr_nrseqdig
		, rw_craplcm.vllanmto
		, rw_craplcm.nrdctabb
		, 'ESTORNO DE CREDITO RECEBIDO EM C/C EM PREJUIZO'
		, rw_craplcm.dtmvtolt
		, 0
		, 1
		, rw_craplcm.cdcooper
		, 5
	);
	
	-- Insere lançamento do crédito transferido para a Conta Transitória
	INSERT INTO TBCC_PREJUIZO_LANCAMENTO (
				 dtmvtolt
			 , cdagenci
			 , nrdconta
			 , nrdocmto
			 , cdhistor
			 , vllanmto
			 , dthrtran
			 , cdoperad
			 , cdcooper
			 , cdorigem
	)
	VALUES (
				 rw_craplcm.dtmvtolt
			 , rw_craplcm.cdagenci
			 , rw_craplcm.nrdconta
			 , rw_craplcm.nrdocmto
			 , 2738
			 , rw_craplcm.vllanmto
			 , SYSDATE
			 , 1
			 , rw_craplcm.cdcooper
			 , 5
	);
	
	COMMIT;
	
	dbms_output.put_line('Sucesso');
EXCEPTION
	WHEN vr_exc_notfound THEN
		dbms_output.put_line('ERRO. Nao foi encontrado registro na CRAPLCM com o PROGRESS_RECID fornecido.');
end;

