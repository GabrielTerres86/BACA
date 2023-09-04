DECLARE
BEGIN
  UPDATE CECRED.crapopi opi SET opi.flgsitop = 1 WHERE opi.nrdconta = 14672146 and opi.cdcooper = 1 and opi.nrcpfope = 2070265056;
  commit;
END;
