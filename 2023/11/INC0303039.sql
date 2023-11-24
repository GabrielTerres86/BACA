begin	 
  update cecred.tbepr_portabilidade 
     set nrcnpjbase_if_origem = '60746948000112' 
   where cdcooper = 1 
     and nrdconta = 17464447 
	 and nrctremp = 7588565 
	 and nrunico_portabilidade = '202311170000287023610';
	 	 
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
