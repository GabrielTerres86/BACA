BEGIN

         update crappat
            set nmpartar = 'Rendas Automaticas na Atualizacao Cadastral'
          where cdpartar = 85;  

	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/