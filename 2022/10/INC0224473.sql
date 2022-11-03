 BEGIN 
  update credito.tbepr_parcelas_cred_imob
     set idsituacao = 'C'
   where cdcooper = 1
     and nrdconta = 14795051
     and nrctremp = 5789536
     and idparcela = 11007;
   commit;
 EXCEPTION
   WHEN OTHERS THEN
     rollback;
 END;