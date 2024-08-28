BEGIN
  UPDATE CECRED.crapmun SET cdcomarc = 3503901 WHERE cdcidade = 6177;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEn
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;