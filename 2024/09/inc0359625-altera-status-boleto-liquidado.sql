BEGIN
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 233.10
   WHERE progress_recid = 130480688;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;