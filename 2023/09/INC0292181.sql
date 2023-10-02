begin
  delete from cecred.tbcrd_limite_atualiza a
  where a.cdcooper = 1
  and nrdconta = 14661063
  and a.NRCTRCRD = 2680006
  and a.NRPROPOSTA_EST = 3304393;
  commit;
end;
