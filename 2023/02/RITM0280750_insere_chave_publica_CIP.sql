BEGIN
  
  INSERT INTO CECRED.tbgen_chaves_crypto(cdacesso
                                        ,dtinicio_vigencia
                                        ,dschave_crypto
                                        ,dsserie_chave)
                                  VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                        ,to_date('17/02/2023','dd/mm/yyyy')
                                        ,'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmxLOzIbvusmWwDLxkjsh'||CHR(10)||
                                         'J0UUfX/GStpAKWro3uX2GRoOnSvmY45oD4rqNIami+VfceY2ibnYgwbiQvU+Bu5w'||CHR(10)||
                                         'HUJq6+ViYBrM0UM335ONR6OTr43fQ/2SAAGMFol8d9LqPkFoSmh6EFy9eCBZG8+b'||CHR(10)||
                                         'Lg4ODSkYetVH54IPkzqAa53aLB+FZCS+s5eMqxwwRJJhjti531jOAclgIDcfGr1B'||CHR(10)||
                                         'Z4/Q8+xZCTFiHYAuPTZxxVG3MZ7VTcuZD1YjH08FgaCkriryKnB4lLW/CAcbRVD2'||CHR(10)||
                                         'V5vIGQ0EiaW+kOT2h74f91Q68KU2DO0kGxh3VXC9Fv5mbeUkW4l6GmBx1kRADmIG'||CHR(10)||
                                         '/wIDAQAB'
                                        ,'52390F16776DC53B');

  COMMIT;

END;
