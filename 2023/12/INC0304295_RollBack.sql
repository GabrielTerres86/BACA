BEGIN
  UPDATE cecred.crappfp
     SET flsitcre = 0
       , dthorcre = SYSDATE
   WHERE cdempres = 441
     AND cdcooper = 12
     AND progress_recid = 1078895;
  UPDATE cecred.craplfp
     SET IDSITLCT = 'L'
       , dsobslct = NULL
   WHERE cdempres = 441
     AND cdcooper = 12
     AND progress_recid in (10722905, 10722906, 10722907, 10722908, 10722909, 10722910, 10722911, 10722912, 10722913, 10722934, 10722935, 10722936, 10722937);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;