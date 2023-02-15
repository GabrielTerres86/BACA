begin

  insert into cecred.tbgen_batch_param values((select max(idparametro)+1 from tbgen_batch_param),20,0,1,'CRPS782');

  commit;

end ;
