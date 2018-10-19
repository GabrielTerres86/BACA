declare 
  -- Local variables here
  CURSOR cr_crapprm(pr_cdcooper NUMBER) IS
	SELECT 1
	  FROM crapprm prm
	 WHERE prm.cdcooper = pr_cdcooper
		 AND prm.nmsistem = 'CRED'
		 AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU'
	;
	
	vr_jacadastrado INTEGER;	
BEGIN
	OPEN cr_crapprm(0);
	FETCH cr_crapprm INTO vr_jacadastrado;
	
	IF cr_crapprm%FOUND THEN
		-- Test statements here
		UPDATE crapprm prm
			 SET prm.dsvlrprm = 'N'
		 WHERE prm.cdcooper = 0
			 AND prm.nmsistem = 'CRED'
			 AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU'
		;
	ELSE
		INSERT INTO crapprm (
		    cdcooper
			, nmsistem
			, cdacesso
			, dsvlrprm
		)
		VALUES (
		    0
			, 'CRED'
			, 'IN_ATIVA_REGRAS_PREJU'
			, 'N'
		);
	END IF;
	
	CLOSE cr_crapprm;

	OPEN cr_crapprm(11);
	FETCH cr_crapprm INTO vr_jacadastrado;
	
	IF cr_crapprm%FOUND THEN
		-- Test statements here
		UPDATE crapprm prm
			 SET prm.dsvlrprm = 'S'
		 WHERE prm.cdcooper = 0
			 AND prm.nmsistem = 'CRED'
			 AND prm.cdacesso = 'IN_ATIVA_REGRAS_PREJU'
		;
	ELSE
		INSERT INTO crapprm (
		    cdcooper
			, nmsistem
			, cdacesso
			, dsvlrprm
		)
		VALUES (
		    0
			, 'CRED'
			, 'IN_ATIVA_REGRAS_PREJU'
			, 'S'
		);
	END IF;
	
	CLOSE cr_crapprm;

	COMMIT;
end;

