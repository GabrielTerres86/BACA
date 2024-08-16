BEGIN
  
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                           VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                 ,to_date('24/08/2024','dd/mm/yyyy')
                                 ,'-----BEGIN PUBLIC KEY-----'||CHR(10)||
                                  'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo34hGpz2qwR1kYfuAtPV'||CHR(10)||
                                  'Vg2G9zg+Xxk3lV9E/RN1hgqicTne9gZuEnJEOKZ8fBwDuBwl4uwimKjGY9ddTNHB'||CHR(10)||
                                  'rpAHFp81Lx5E14vO1oTuo83abZqHEfTCtBdxemFPxhYO5FgTfmItorKNuS8qI9uR'||CHR(10)||
                                  'g6N54XXs9cDTkTNZF7DPsZ0pDBwrRYqA5lSBAV/9uc0GhTRzov/CUXL/fB5hkCLc'||CHR(10)||
                                  'qwovmUmhGIu3E2hcdpD7nfOIZhpsAoOKDLqb99x38lfpg1em0WiYnD9b+p8rgP5v'||CHR(10)||
                                  '4jR+/n4vbUmDWD5IZWStiuUWaLL08CAgkylJgDQemjZszzuiIy1gHUFni9BtkASE'||CHR(10)||
                                  '5wIDAQAB'||CHR(10)||
                                  '-----END PUBLIC KEY-----'
                                 ,'43AA2CD16EC56321');

  COMMIT;

END;
