BEGIN
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idseqttl            = 1    -- Todos s�o do primeiro titular
       , t.tppessoa_empregador = 2;   -- Todos pessoas jur�dicas at� esse momento
       
  UPDATE tbcc_portabilidade_recebe t
     SET t.tppessoa_empregador = 2;   -- Todos pessoas jur�dicas at� esse momento

  COMMIT;

END;
