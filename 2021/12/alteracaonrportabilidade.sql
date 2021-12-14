begin

 UPDATE CECRED.tbepr_portabilidade 
 set nrunico_portabilidade = '202112070000220106640'
 where cdcooper = 1 
   and nrdconta = 11035528 
   AND nrctremp = 4901280;
   
 commit;
 
end;