BEGIN
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idseqttl            = 1    -- Todos são do primeiro titular até a liberação
   WHERE t.idseqttl            = 0;
       
  COMMIT;

END;
