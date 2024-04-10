BEGIN

  UPDATE cecred.crapcob c
     SET c.incobran = 5
   WHERE progress_recid in (131238846, 133954547, 139450642);

  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;