BEGIN
  
  update credito.tbepr_parcelas_cred_imob
     set idsituacao = 'C'
   where cdcooper = 16
     and nrdconta = 156647
     and nrctremp = 474
     and idparcela = 6953;
	 
  COMMIT;
  
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 3);
END;	 