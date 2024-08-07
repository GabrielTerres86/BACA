BEGIN
  UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 774.35
   WHERE progress_recid = 145272178;

     UPDATE cecred.crapcob c
     SET c.incobran = 5, c.dtdpagto = trunc(sysdate), c.vldpagto = 67.82
   WHERE progress_recid = 144753334;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;