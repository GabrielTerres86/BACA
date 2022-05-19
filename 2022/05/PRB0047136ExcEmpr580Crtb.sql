BEGIN
delete FROM cecred.craptab WHERE cdcooper = 13 AND cdempres = 0 AND NMSISTEM = 'CRED' and TPTABELA = 'GENERI' and  CDACESSO = 'NUMLOTECOT' and TPREGIST = 580 and DSTEXTAB= '805800';
COMMIT;
END;
/