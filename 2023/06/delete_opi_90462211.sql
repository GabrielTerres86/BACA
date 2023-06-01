BEGIN
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA in (90462211)
    and opi.NRCPFOPE in (11575361906);
  
  
  delete tbib_permissoes_operador opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA in (90462211)
    and opi.NRCPFOPE in (11575361906);
  
  commit;

END;