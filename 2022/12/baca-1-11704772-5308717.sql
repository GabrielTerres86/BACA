BEGIN
  DELETE cecred.crapebn WHERE cdcooper = 1 AND nrdconta = 11704772 AND nrctremp = 5308717;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
