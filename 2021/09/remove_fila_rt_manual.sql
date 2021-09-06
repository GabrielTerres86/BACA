BEGIN

UPDATE tbgen_analise_fraude_rt_manual
   SET statusret_manual = 1
 WHERE idanalise_fraude = 94136694;
 COMMIT;
END;