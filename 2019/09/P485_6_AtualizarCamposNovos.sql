BEGIN
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idseqttl            = 1    -- Todos são do primeiro titular
       , t.tppessoa_empregador = 2;   -- Todos pessoas jurídicas até esse momento
       
  UPDATE tbcc_portabilidade_recebe t
     SET t.tppessoa_empregador = 2;   -- Todos pessoas jurídicas até esse momento

  COMMIT;

END;
