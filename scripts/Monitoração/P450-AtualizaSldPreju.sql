declare 
  vr_recid_lcm craplcm.progress_recid%TYPE := 123456; -- **** ALTERAR AQUI **** --
	
	vr_exc_notfound EXCEPTION;
	
	CURSOR cr_craplcm IS
	SELECT *
	  FROM craplcm
	 WHERE progress_recid = vr_recid_lcm;
	rw_craplcm cr_craplcm%ROWTYPE;
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
	
	-- Atualiza o saldo do prejuízo da conta corrente
	UPDATE tbcc_prejuizo
  	 SET vlsdprej = vlsdprej + rw_craplcm.vllanmto;
	
	COMMIT;
	
	dbms_output.put_line('Sucesso');
EXCEPTION
	WHEN vr_exc_notfound THEN
		dbms_output.put_line('ERRO. Nao foi encontrado registro na CRAPLCM com o PROGRESS_RECID fornecido.');
end;

