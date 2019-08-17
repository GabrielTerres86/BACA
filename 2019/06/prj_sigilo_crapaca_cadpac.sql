BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam||',pr_dtabertu,pr_dtfechto'
   WHERE c.nmdeacao = 'CADPAC_GRAVA';
  
  COMMIT;
END;
