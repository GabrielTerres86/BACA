BEGIN

	DELETE FROM CECRED."__DBHISTORY" x
	WHERE x.Id = 'XX-20240703_Criar-Tabela-HT-Perda Esperada';
	COMMIT;


	DELETE FROM CECRED."__DBHISTORY" x
	WHERE x.Id = '20240703_Criar-Tabela-HT-Perda Esperada';
	COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;