begin 
 
 UPDATE CECRED.tbepr_portabilidade 
 set nrunico_portabilidade = '202112140000001480504'
 where cdcooper  = 13 
   and nrdconta = 500100 
   AND nrctremp = 151348;
   
 commit;
end;