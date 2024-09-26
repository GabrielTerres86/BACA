BEGIN
  UPDATE CECRED.crapsab SET complend = ' ' WHERE complend IS NULL;
  COMMIT;
END;