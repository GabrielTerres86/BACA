BEGIN
  update cecred.tbgen_batch_jobs set
         flexec_ultimo_dia_ano = 1
  where nmjob in ('JBCRD_BANCOOB_ENVSLD_DIA', 'JBCRD_BANCOOB_RECEB_CEXT');
  
  commit;

END;
