BEGIN
  
  -- Inserir a mensagem de cr�tica
  INSERT INTO crapcri(cdcritic
                     ,dscritic
                     ,tpcritic
                     ,flgchama)
              VALUES (10500
                     ,'10500 - Saldo insuficiente para lan�amento em conta de modalidade Ente P�blico'
                     ,1
                     ,0);
                   
  COMMIT;
  
END;
