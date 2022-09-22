BEGIN
  update cecred.crapavt avt
  set avt.DSDEMAIL = 'adm@jocumcuritiba.org.br'
  where avt.CDCOOPER = 1
    and avt.NRDCONTA = 15427404
    and avt.NRCPFCGC = 77886364953;
    
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA = 15461084  
    and opi.NRCPFOPE = 77886364953;
  
  commit;
END;
