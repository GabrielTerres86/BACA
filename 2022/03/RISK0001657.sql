BEGIN

	-- Altera todos operadores para acessarem apenas pelo Aimaro via Browser
	UPDATE crapope set INUTLCRM = 0;
  
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
