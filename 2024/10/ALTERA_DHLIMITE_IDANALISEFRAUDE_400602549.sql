BEGIN
 update CECRED.TBGEN_ANALISE_FRAUDE set dhlimite_analise = (sysdate + interval '1' minute) where idanalise_fraude = 400602549 ;
  COMMIT;
END;