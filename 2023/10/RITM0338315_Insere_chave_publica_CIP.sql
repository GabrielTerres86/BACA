BEGIN
  
  INSERT INTO CECRED.tbgen_chaves_crypto(cdacesso
                                        ,dtinicio_vigencia
                                        ,dschave_crypto
                                        ,dsserie_chave)
                                  VALUES('PCPS_CHAVE_PUBLICA_CIP'
                                        ,to_date('21/10/2023','dd/mm/yyyy')
                                        ,'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvNdYq8LBEqQ0JQ5Kay+H'||CHR(10)||
                                         'sgQP506w96kYSnhbyE2bfoEOLCXSczDqkPNmlYXOwt/A37lIbpbhxVXEH/QWyqIY'||CHR(10)||
                                         'xQp2/Ptta2e/YPtuSLjRVv8SdZzbcQ16pLrHIwFmqQQ9r4HHGiOLbuTN8/utkbID'||CHR(10)||
                                         'GaJs6vY9lnpecMqTAOLg37+RgX8pTx+zLAgrh8fh4a+Q0mNfnb94iTFrCcB6MQE7'||CHR(10)||
                                         'j5GP/iT/YWaCQPVuUKLXfnE3Yn0CZ9mkiBXc8GW6uaXgn3mKqCS6oFPaAs/VlWoK'||CHR(10)||
                                         'REg2eMqcusHo+tIYJCnE9A6YjouxYG0B4UTbiiQREniWAJNQLVUg6jvNn+OdJLz1'||CHR(10)||
                                         'dQIDAQAB'
                                        ,'06DEA1C548D7C9CB');

  COMMIT;

END;
