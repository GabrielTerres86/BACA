BEGIN
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA = 15529495  
    and opi.NRCPFOPE in (30251535800);
  
  commit;
END;
