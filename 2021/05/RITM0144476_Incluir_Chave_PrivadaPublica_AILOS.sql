BEGIN
  
  -- Incluir chave privada da Ailos
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                          VALUES ('PCPS_CHAVE_PRIVADA_AILOS'
                                 ,to_date('03/06/2021','DD/MM/YYYY') 
                                 ,'-----BEGIN RSA PRIVATE KEY-----'||CHR(10)||
                                  'MIIEowIBAAKCAQEAuyim29mxwdc1WCaIHIfLYMfwEfX2E+O1VsZ8Bf/OU0IqbwTX'||CHR(10)||
                                  '1c2yQLdh8e4Tnc0NlmuphYDmL9gaM8oP7zbMGuKT7Fbepq6yy7AXXA6g8qppNmcl'||CHR(10)||
                                  'k0n7JSzP8GQfxLBhovYbNJ2dHQNvMNEVxUvnaLUJnim3EoK/CmFW4HAZd8N57r6k'||CHR(10)||
                                  '2gx9SOZaoPa+jWSjcWmG6sSDxYnmrUDkO9j1/dOuicTkWy2Ea76QqHOkmWCaP+ii'||CHR(10)||
                                  'aXPaYA4iZohvsvhnwJbLKjCIe81jfD9BAdrS61K1sLxKI63t9Ca24JiW65bi1XFO'||CHR(10)||
                                  'IVrnfrUJYdONG64nQFWAHtZru7FTX+QlnVCLrQIDAQABAoIBAD24yVZls56Wh4wb'||CHR(10)||
                                  'oPWvvt2a8kwqDk4+4TXN3WbpFrUUdAQK19c1r9xx3cY4WpXG4v1BYjWZ7c/Hd9Su'||CHR(10)||
                                  'hZTBQIx5PolJmMHliSdtWjbMyD1e/7WmTJkHY+C9p5HCo0ttU7W3bf9rHz5LPKcf'||CHR(10)||
                                  'vQtE3fsFATf8z9g18CTPNyRrM6rv5dC6C2RNsIDlg4xeDpaLvSqoBguCXbIAbKo6'||CHR(10)||
                                  '3Eenca9dl6KjxwxlBecI+13g0MB9Hr3rji5YxNf74TO6m8GRbaURnjLxNXikdk/2'||CHR(10)||
                                  '5bNrZkhD7ks0wExUuVc2QL8zlDYUPQDMmMAXUr0OYCRfqEGt3HuJiSN03tBzD4jR'||CHR(10)||
                                  'gJ+I9AECgYEA980QQELttt+JWDCKMaY+GiWHWcRmtEYT3X2OjN29pSSmLBSaX2WC'||CHR(10)||
                                  '3HKSzzQ9wG00fzQ58OGZVj1RA9xIDic3PYlxfMt5vW5ZvOF4fg/uEWfNCPZJ7Gh4'||CHR(10)||
                                  'mixvVm5WOKlAKQIxNC7kGjKzikFZ0584pzEf4mUilS9CcmzQ5g5w1K0CgYEAwVnu'||CHR(10)||
                                  '+A2RBQoepEx31sV11As1hPXYeNlxq0wbHRjpwOPMmJe8ZxXP9qg5t0HeR79eQOOY'||CHR(10)||
                                  'qT2TbwgFND6EwT/KysnW6iIfmivPgdVhscc8Ocb2p6g6oXhkV8XHUfqBV3nlpLGa'||CHR(10)||
                                  'sfRDexQDtY5rq1PmuNaacTaIrz519kiFyBFucwECgYEAwu8TIKpF3D1fCvwsSkBv'||CHR(10)||
                                  'zBvHrQs+jAQwrmWOFSx+eoIpIrYWdoMhfY+4A74h8dU2nfaUufSOrnPP3oyUNmYN'||CHR(10)||
                                  'I6CSoUxj+WvsthRcuDaJ3jFc7vboUkwgy4+3CjQEKdCjA1+RG27jy+QkrtcX9czk'||CHR(10)||
                                  'QUn4vh03JkqmJ+OINeIYSoUCgYBIc9jWXs8O4mHlEzp84nVqxeCCOFWrw1+S3uvy'||CHR(10)||
                                  'FVnSjAoozAMvZb8OIK+v+iC/Jfi9vAuCr65Flu3MS/kXKT5miwfbqHnLHcueTUVU'||CHR(10)||
                                  'huIMjH/1B1chFqoTMeukzogVLXpeIqdjM7LttexF5l52TvRQIyqwbcz+ThuJ9Fcd'||CHR(10)||
                                  'R1rqAQKBgD0cBK3tuvDrf3uawUAk7e8Yxb6t8sw+V/OyuCbP1y2SgsSIHpNJhUFs'||CHR(10)||
                                  't6iSg6nUe6mjBBFVGgEhgVlkuc4RIUbvulk2UpfhfIDCnBrQKKltixEDGUqbJLdg'||CHR(10)||
                                  'FY9CbEfdL1NU41mySnFmFSwvIqkYhK0ryXaRns8AcwexDp5DX9j1'||CHR(10)||
                                  '-----END RSA PRIVATE KEY-----'
                                 ,'72CA0C90D4BE7A95');
                             
  -- Incluir chave pública da Ailos
  INSERT INTO tbgen_chaves_crypto(cdacesso
                                 ,dtinicio_vigencia
                                 ,dschave_crypto
                                 ,dsserie_chave)
                          VALUES ('PCPS_CHAVE_PUBLICA_AILOS'
                                 ,to_date('03/06/2021','DD/MM/YYYY') 
                                 ,'-----BEGIN PUBLIC KEY-----'||CHR(10)||
                                  'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuyim29mxwdc1WCaIHIfL'||CHR(10)||
                                  'YMfwEfX2E+O1VsZ8Bf/OU0IqbwTX1c2yQLdh8e4Tnc0NlmuphYDmL9gaM8oP7zbM'||CHR(10)||
                                  'GuKT7Fbepq6yy7AXXA6g8qppNmclk0n7JSzP8GQfxLBhovYbNJ2dHQNvMNEVxUvn'||CHR(10)||
                                  'aLUJnim3EoK/CmFW4HAZd8N57r6k2gx9SOZaoPa+jWSjcWmG6sSDxYnmrUDkO9j1'||CHR(10)||
                                  '/dOuicTkWy2Ea76QqHOkmWCaP+iiaXPaYA4iZohvsvhnwJbLKjCIe81jfD9BAdrS'||CHR(10)||
                                  '61K1sLxKI63t9Ca24JiW65bi1XFOIVrnfrUJYdONG64nQFWAHtZru7FTX+QlnVCL'||CHR(10)||
                                  'rQIDAQAB'||CHR(10)||
                                  '-----END PUBLIC KEY-----'
                                 ,'72CA0C90D4BE7A95');

  COMMIT;
  
END;
