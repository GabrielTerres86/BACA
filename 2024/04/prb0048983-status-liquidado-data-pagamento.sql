BEGIN
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 471.84
   WHERE progress_recid = 140301243;

  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;