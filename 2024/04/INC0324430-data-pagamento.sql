BEGIN
  UPDATE cecred.crapcob c
     SET c.dtdpagto = trunc(sysdate), c.vldpagto = 54.11
   WHERE progress_recid = 131238846;

  UPDATE cecred.crapcob c
     SET c.dtdpagto = trunc(sysdate), c.vldpagto = 715.78
   WHERE progress_recid = 133954547;

  UPDATE cecred.crapcob c
     SET c.dtdpagto = trunc(sysdate), c.vldpagto = 263.25
   WHERE progress_recid = 139450642;

  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;