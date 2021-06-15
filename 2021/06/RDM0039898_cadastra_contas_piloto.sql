begin
  update crapprm 
  set dsvlrprm = dsvlrprm || '8000166,8721386,12591645,12609099,10561,12591645,9515984,7144091,11206705,12236071,2236192,11830336,6767214,'
  where cdcooper = 1 
    and cdacesso = 'CONTA_PILOTO_POUPANCA_PF';
  commit;
end;

