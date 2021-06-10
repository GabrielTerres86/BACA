BEGIN
  
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                           VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                 ,to_date('12/06/2021','dd/mm/yyyy')
                                 ,'-----BEGIN PUBLIC KEY-----'||CHR(10)||
                                  'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAssEXUfveP56v7iCrmwQV'||CHR(10)||
                                  'BT1xFwddahHe1c+75kue/kpEmmfEfzLYuqA48IQS7FJn29IwESwIst2gFsTDQ2+Z'||CHR(10)||
                                  'sV49lYsKnHPGEm1WDzR3lyrXyT6wO9Srr1cqqI/uPG8FW/Wu3ZgHoCMRfF6hfhoD'||CHR(10)||
                                  'Tg0T6D9W6b2leoPZsKKwYSBAZZcdpEsCPlDmyZRNwmV8aLumWMtsbos3xL/41uov'||CHR(10)||
                                  'S9yA4ILP3tqIuf+N5BzcPicZqAUXzkQo/lhdUjEHEXb+cu6VFS1pxQHfqGzZikpS'||CHR(10)||
                                  'ruCITzRvDID4krq6UfrXYkv8vw/bCHFLx43wQ90KM2xIOm9co6T1szb/mTUMTHuF'||CHR(10)||
                                  'kwIDAQAB'||CHR(10)||
                                  '-----END PUBLIC KEY-----'
                                 ,'7A78FA3DED099D25');

  COMMIT;

END;

