BEGIN

  UPDATE crapaca
     SET lstparam = lstparam||',pr_flgenvio_nao_util'
   WHERE nmdeacao = 'CADFRA_GRAVA';
 
  COMMIT;

END;