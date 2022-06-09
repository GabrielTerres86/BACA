BEGIN
  UPDATE cecred.craptab tab 
  SET tab.dstextab = '001002' || ' ' || TO_CHAR(sysdate-1,'DDMMYYYY')
 WHERE upper(tab.nmsistem) = 'CRED'
   AND upper(tab.tptabela) = 'GENERI'
   AND tab.cdempres in (8580239,8580179)
   AND upper(tab.cdacesso) = 'ARQBANCOOB'
   AND tab.tpregist = 00
   AND tab.cdcooper = 1;

  UPDATE cecred.gncontr gnc
   SET gnc.nrsequen = 1001
 WHERE gnc.cdcooper = 1
   AND gnc.cdconven in (8580239,8580179)
   AND gnc.nrsequen = 1000
   AND gnc.dtmvtolt = TO_DATE(sysdate-1,'DD/MM/YYYY');

  COMMIT;
END;