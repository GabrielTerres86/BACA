BEGIN
  
  -- Inserir a mensagem de crítica
  INSERT INTO crapcri(cdcritic
                     ,dscritic
                     ,tpcritic
                     ,flgchama)
              VALUES (10500
                     ,'10500 - Saldo insuficiente para lançamento em conta de modalidade Ente Público'
                     ,1
                     ,0);

    -- Inserir a mensagem de crítica
  INSERT INTO crapcri(cdcritic
                     ,dscritic
                     ,tpcritic
                     ,flgchama)
              VALUES (10501
                     ,'10501 - Historico exclusivo para pessoa juridica, nao pode ser utilizado para ente publico'
                     ,1
                     ,0);

  -- Inserir a mensagem de crítica
  INSERT INTO crapcri(cdcritic
                     ,dscritic
                     ,tpcritic
                     ,flgchama)
              VALUES (10502
                     ,'10502 - Historico exclusivo para ente publico, nao pode ser utilizado para pessoa juridica'
                     ,1
                     ,0);
                   
                   
  COMMIT;
  
END;
