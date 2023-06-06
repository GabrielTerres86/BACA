BEGIN
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA in (13212176)
    and opi.NRCPFOPE in (00968387012);
  
  commit;
END;
