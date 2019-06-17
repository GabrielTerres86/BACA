BEGIN
	UPDATE crapaca
	   SET nmproced = 'pc_busca_prazo_venc_web'
	 WHERE nmpackag = 'TELA_COBEMP'
	   AND nmdeacao = 'BUSCA_PRAZO_VCTO_MAX';

	UPDATE crapaca
	   SET nmproced = 'pc_buscar_email_web'
	 WHERE nmpackag = 'TELA_COBEMP'
	   AND nmdeacao = 'BUSCAR_EMAIL';
   
	COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;
