BEGIN
  UPDATE crapris a
     SET a.qtdiaatr = 321
   WHERE a.progress_recid IN (2131805806, 2123737044);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
