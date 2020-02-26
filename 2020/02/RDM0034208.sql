UPDATE tbgen_batch_controle c SET c.insituacao  = 2
  where c.cdcooper    = 3
   and c.cdprogra   LIKE 'CRPS652%'
   and c.dtmvtolt    = '21/02/2020'
   and c.nrexecucao  = 1
   AND c.tpagrupador = 3
   and c.insituacao  = 1;

COMMIT;