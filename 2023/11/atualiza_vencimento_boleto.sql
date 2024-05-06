BEGIN

update crapcob set dtvencto = sysdate +30 where progress_recid= 131520919;
  COMMIT;

END;
