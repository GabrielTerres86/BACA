BEGIN
  UPDATE CRAPPCO PCO
     SET PCO.DSCONTEU = 'S'
   WHERE PCO.CDPARTAR = (select PAT.CDPARTAR from CRAPPAT PAT WHERE 1=1 AND pat.nmpartar LIKE '%PC_PROCES_ARQ_CET_BANCOOB%');
   
  COMMIT;
END;
/
