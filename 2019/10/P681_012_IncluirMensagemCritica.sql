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
                   
  COMMIT;
  
END;
