BEGIN
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idseqttl            = 1    -- Todos s�o do primeiro titular at� a libera��o
   WHERE t.idseqttl            = 0;
       
  COMMIT;

END;
