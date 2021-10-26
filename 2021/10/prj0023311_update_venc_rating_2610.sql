BEGIN
  UPDATE  tbrisco_operacoes o
  SET o.dtvencto_rating = to_date('11/03/2021','dd/mm/yyyy')
  WHERE o.cdcooper =1
  AND o.nrdconta IN (835943,19,6578179,9659579,12525529,15725, 3926079,3794342)
  AND o.nrctremp IN (660883,660958,660959,660975,660158,660194,660241,4656026,4656025)  
  AND o.insituacao_rating = 4 --efetivado
  AND o.inrisco_rating_autom IS NOT NULL
  AND o.tpctrato = 93  --imobiliario
  AND o.flencerrado = 0 -- Contratos ativo
  AND o.flintegrar_sas = 0;
  
  COMMIT;
END;
