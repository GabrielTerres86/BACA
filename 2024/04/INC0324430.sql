BEGIN

  UPDATE cecred.crapcob c
     SET c.incobran = 5
   WHERE c.cdcooper = 1
     AND c.nrdconta = 9297685
     AND c.nrdocmto = 1645;

  UPDATE cecred.crapcob c
     SET c.incobran = 5
   WHERE c.cdcooper = 1
     AND c.nrdconta = 8013764
     AND c.nrdocmto = 204332;
  
  COMMIT;
	
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
   	dbms_output.put_line('Erro ao executar baca de atualizacao incobran na tabela crapcob: ' || SQLERRM);
END;