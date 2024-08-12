BEGIN
	UPDATE tbcadast_empresa_consig A
	  SET A.cdlocal_conciliacao = 2
	WHERE A.cdcooper = 14
	  AND A.cdempres = 242;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
END;