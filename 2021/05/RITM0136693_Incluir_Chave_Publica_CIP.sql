BEGIN
  
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                           VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                 ,to_date('08/05/2021','dd/mm/yyyy')
                                 ,'-----BEGIN PUBLIC KEY-----'||CHR(10)||
                                  'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmPjLfCiQp6rka1M9KuXL'||CHR(10)||
                                  '5+y+xHP8zUGDE1HGnUoV16FN4pMw1qoqhAK9PQSl4tKep8j0HT8Z8sYonzpP7Ubu'||CHR(10)||
                                  'wrt9rfZGqLnu5xXEWqWNgallsAUTUtxAAQrWYpMoOYuQ0YUcziYdEgyN2azwHKdn'||CHR(10)||
                                  'EVAbQn4z3NB3qZVaA28IvohysSDmNlpTvxNpvurtwMLVpuNBsBy6w57y6SeY+7mh'||CHR(10)||
                                  'LqXDpTm2M+wg25zBaZlwImuZnL7k0/IcD65wQIxUN8KgNCH5BjNOSjbkbp0CNy5v'||CHR(10)||
                                  'oypSh8PFakIlzs3xfu+0T0ha5MDKkXr7vxUYILGLMQ2KG61I176FLE/ycffo2lMG'||CHR(10)||
                                  'pQIDAQAB'||CHR(10)||
                                  '-----END PUBLIC KEY-----'
                                 ,'44113114C65E1B94');

  COMMIT;

END;
