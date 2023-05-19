BEGIN
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PUBLICA_AILOS', to_date('19/05/2023','DD/MM/YYYY'), 
                                                               'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqKkHSbD/WrvNoafccV0r' || chr(10) 
                                                            || 'jTW/Tdf0tYKUtotHWRVbCcB2uD4XRM1XKawcSj0zfV/u2w6UJTH9/kncM6sMy31G' || chr(10) 
                                                            || 'hDFqmkODYFjkixkM92hs5oI2z7i8Iy9PSIuOdc0+36cKD1MqGkEjs/eDyxXmnrYA' || chr(10) 
                                                            || 'XTKTlKchVU25F9oqn4RLRhdidrwwc5aWzgTJobpim8+HNApRgRbGiFTB/NFepJmZ' || chr(10) 
                                                            || '9mjOFotC8+8qee7AdohH1stlHlfrXtMKYpg5svMti04MCYDxIGVYL0RxZZWvN+Jk' || chr(10) 
                                                            || 'V2npHEGmRmjEev+USi7c2UsTTw5JOrEKUc0QjusNjMc/2nDGNj8xFGIs2cLNetFc' || chr(10) 
                                                            || 'PQIDAQAB' 
                                                            , '29DFEED1CF285C2B');
  
  insert into CECRED.TBGEN_CHAVES_CRYPTO (cdacesso, dtinicio_vigencia, dschave_crypto, dsserie_chave)
  values ('PCPS_CHAVE_PRIVADA_AILOS', to_date('19/05/2023','DD/MM/YYYY'), 
                                                               'MIIEpAIBAAKCAQEAqKkHSbD/WrvNoafccV0rjTW/Tdf0tYKUtotHWRVbCcB2uD4X' || chr(10) 
                                                            || 'RM1XKawcSj0zfV/u2w6UJTH9/kncM6sMy31GhDFqmkODYFjkixkM92hs5oI2z7i8' || chr(10) 
                                                            || 'Iy9PSIuOdc0+36cKD1MqGkEjs/eDyxXmnrYAXTKTlKchVU25F9oqn4RLRhdidrww' || chr(10) 
                                                            || 'c5aWzgTJobpim8+HNApRgRbGiFTB/NFepJmZ9mjOFotC8+8qee7AdohH1stlHlfr' || chr(10) 
                                                            || 'XtMKYpg5svMti04MCYDxIGVYL0RxZZWvN+JkV2npHEGmRmjEev+USi7c2UsTTw5J' || chr(10) 
                                                            || 'OrEKUc0QjusNjMc/2nDGNj8xFGIs2cLNetFcPQIDAQABAoIBAAQFu/nC8eQdFINl' || chr(10) 
                                                            || 'eHlvqmk8vepCW0C0840C91mli71IzMwKFw36A7kntKkEmqTD0/N/foMAlTkqU8kb' || chr(10) 
                                                            || 'rDtyKmterlctgwWaOSEkIM4JvIcm1d3QXxRLvY1SXrxqf7RfzHqfFiL4KLzTC16d' || chr(10) 
                                                            || 'kBl657lRSnnCHqZlKyPpfRi+0/jA7hfMCBiOmEsVv4Fe0SylKrSq0Y0Ynn1v3wnz' || chr(10) 
                                                            || 'FqZYTREQULBFsY+iIQ8AGaBLfARsIGRCGG5lXnmvixadhyqD6gM0kxG20yEVi2qQ' || chr(10) 
                                                            || 'yuppyXGsYf1uOaas503xCtpqDmoLfAa4j7qgwdkk8RIQjegECSKAGXxUtKfKajks' || chr(10) 
                                                            || 'G13exEECgYEA2/ljOfshIz/GmA2NQVvClVAjPH11tE5sZNsay6hTbJXDfXWsCsZ7' || chr(10) 
                                                            || 'nt3Dsezz9Z8TYf90Uakqzot/DQl4AbSRwKNo/lUFM0TPk4ceBtLykpxtTkUuMFVb' || chr(10) 
                                                            || 'UmSdAmKyaD+isvF5elvIhari33SpAsquZks9i2LPSitxN/3Z6oh6XZECgYEAxEhC' || chr(10) 
                                                            || 'ipoV/Nywv5AxTJQEiMQKwIOE96705cKIH8WTvsLbE+5H6DIWkICgOeBeYki6qcsd' || chr(10) 
                                                            || 'JAeVa1RkjcMYR4MG5Sz/06Ck9ex5ssZbPmPWyHuhGkwmHn7NPoUMc4dbj++prNIa' || chr(10) 
                                                            || 'DreFBWe6Kra8j1UwFUEI+ZFmPaLUIKhtI3uSbe0CgYEAlJvHyFz7RygHz6OgIV6P' || chr(10) 
                                                            || 'd3YbR/tuMHCm1AAd+yZtrbcDyddcci8jRvGFCsgNDIv6eUMuXxjNPZqKK9GQzH4j' || chr(10) 
                                                            || '1aPQA7qGd9tt7LnktDGBBUE+qxkbmjWgK2qjk///jWQoU4HFUr99GaiX+uSCZctt' || chr(10) 
                                                            || 'xNfh7S/E4NO2emA5/zNSj7ECgYEAk4MO5yVYIvokp0MRmdCf+70Bq57r/kzxZf8l' || chr(10) 
                                                            || '2GLfX30HslnglqOWC7FvOS/jHxAzoMmyM9KzO79n9pZJl+zj8LY56W0QrHW1HGMw' || chr(10) 
                                                            || 'TZow3+jxsVbLSx3W2AabzfNLH8hpByW7SZYolWBYLCO7YCkQgtimixD3+ph1vbl2' || chr(10) 
                                                            || 'lDUZXh0CgYBHjJQ0E9YhkNKLuttH++re6/kLxN+BCtRGaMRzU741dGncBsvErR0O' || chr(10) 
                                                            || '7lSRRQRu+nCy9yizk9h36hipVX7NUo9eaxnfmKOFCL6GfjuIh/OM/qkJfBbETaGO' || chr(10) 
                                                            || 'YtED07YbxiwojCKTTMI385lReATop9yh7mXmB5qHZc1QIF24pNZ8ZQ=='
                                                            , '29DFEED1CF285C2B');
  
  commit;

END;
