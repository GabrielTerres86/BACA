BEGIN
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 766.25
   WHERE progress_recid = 139680198;

  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 1453.12
   WHERE progress_recid = 131624799;

  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;