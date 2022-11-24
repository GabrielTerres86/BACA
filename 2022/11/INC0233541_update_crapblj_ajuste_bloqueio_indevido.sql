BEGIN
  UPDATE cecred.crapblj blj 
     SET blj.dtblqfim = TRUNC(SYSDATE),
         blj.dsinfdes = 'Bloqueio via script'  
   WHERE nrdconta = 8453985 
     AND cdcooper = 1 
     AND dtblqfim IS NULL;
  COMMIT;
END;
