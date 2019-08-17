BEGIN
  UPDATE crapcns c SET c.flgativo = 0, c.dtcancel = TRUNC(SYSDATE)
   WHERE c.cdcooper = 7
     AND c.nrdconta = 281115  
     AND c.progress_recid = 706422;
  COMMIT;
END;
