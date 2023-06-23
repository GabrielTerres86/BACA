BEGIN
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA in (14672146)
    and opi.NRCPFOPE in (968387012);
  commit;
END;
