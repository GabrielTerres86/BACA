BEGIN
  UPDATE  tbrisco_operacoes o
  SET o.dtvencto_rating = to_date('11/03/2021','dd/mm/yyyy')
  WHERE o.cdcooper IN(1, 16)
  AND o.insituacao_rating = 4 --efetivado
  AND o.inrisco_rating_autom IS NOT NULL
  AND o.nrctremp in (4237504, 4237772,4238081,4238009, 307974,4238066)
  AND o.tpctrato = 93  --imobiliario
  AND o.flencerrado = 0 -- Contratos ativo
  AND o.flintegrar_sas = 0;
  
  COMMIT;
END;