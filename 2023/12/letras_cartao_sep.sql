BEGIN
  UPDATE CECRED.tbtaa_letras_segura_sep a
     SET a.cdcooper = 9
        ,a.nrdconta = 81366078
        ,a.nrcartao = 6393500065179583
   WHERE a.idtaa_letras_segura_sep = 18;

  COMMIT;

END;