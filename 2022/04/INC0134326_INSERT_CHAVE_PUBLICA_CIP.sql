BEGIN
  
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                           VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                 ,to_date('09/04/2022','dd/mm/yyyy')
                                 ,'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqZYhJPhyXIxdmm78tjPL'||CHR(10)||
                                  'oM6ZbG3zYku5CCXPuDWTHkJXIKY9aPdMVHBBbGqde6Dkin3ijDtcAwwMg8TNhT88'||CHR(10)||
                                  'vh1luCNl8Jt6pmD1XMXKeOkYc2lI82pSSSIcSFgP+dCZz4YSZYH4//uW55nLGeCy'||CHR(10)||
                                  'GOblJz2Ro6woKa1Nm2GOaUHj9Z5YQyEH4FFKkMPDr2n3NfsF9VaI8j24+7Dspoep'||CHR(10)||
                                  'oVqrAfcZwL6HCLh7tJd9yjO2xmBeWgxmlYysa8G7Q3FmaU48UU8qKlKSm1lMQ4Xa'||CHR(10)||
                                  'GXnSMlkV6D5WCClKBN/BuQN3AOSupDlveVxOoNwLB4fArkgrmEaEs1MBByZ7Lr2f'||CHR(10)||
                                  'LwIDAQAB'
                                 ,'36BC847F285A81BA');

  COMMIT;

END;


