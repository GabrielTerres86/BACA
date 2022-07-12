begin
 update CECRED.tbepr_portabilidade 
    set nrunico_portabilidade = '202207050000234706130'
  where cdcooper = 11
    and nrdconta = 15015246 
    and nrctremp = 250563;
commit;   
end;
