BEGIN
  
  
  update crapaca set LSTPARAM = 'pr_cdcooper,pr_cdlcremp,pr_nrdconta'
  where NMPROCED = 'pc_retorna_tpcuspr';

  COMMIT;   

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
