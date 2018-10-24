declare 
  vr_recid_lcm craplcm.progress_recid%TYPE := 123456; -- **** ALTERAR AQUI **** --
	
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
  -- Exclui o lançamento de débito da CRAPLCM
	DELETE FROM craplcm
	 WHERE progress_recid = rw_craplcm.progress_recid;
	
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
			   rw_crapdat.dtmvtolt
			 , rw_craplcm.cdagenci
			 , rw_craplcm.nrdconta
			 , rw_craplcm.nrdocmto
			 , 2739
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

