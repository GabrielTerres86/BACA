BEGIN
   
  DELETE crapsnh snh 
   WHERE snh.tpdsenha = 1
     AND snh.idseqttl > 1
     AND snh.idseqttl <= 5 
     -- Seja pessoa fisica
     AND EXISTS(SELECT 1
                  FROM crapass ass
                 WHERE ass.cdcooper = snh.cdcooper
                   AND ass.nrdconta = snh.nrdconta
                   AND ass.inpessoa = 1)
     -- O primeiro titular está ativo
     AND EXISTS(SELECT 1 
                  FROM crapsnh snh1 
                 WHERE snh1.cdcooper = snh.cdcooper 
                   AND snh1.nrdconta = snh.nrdconta 
                   AND snh1.idseqttl = 1
                   AND snh1.tpdsenha = 1
                   AND snh1.vllimweb < snh.vllimweb
                  )
     -- Nao tenha crapttl
     AND NOT EXISTS(SELECT 1 
                      FROM crapttl ttl 
                     WHERE ttl.cdcooper = snh.cdcooper 
                       AND ttl.nrdconta = snh.nrdconta 
                       AND ttl.idseqttl = snh.idseqttl);

  COMMIT;
END;






