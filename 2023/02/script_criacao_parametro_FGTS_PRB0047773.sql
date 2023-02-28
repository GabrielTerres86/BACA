BEGIN
  INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 0, 'HIST_TRIBUTOS_VAL_DUPLI', 'Lista de tributos(histórico) que valida a duplicidade','2515,3361,3192,3194,3196,3198,3200,3202,3204');

  UPDATE cecred.crapprm
     SET dsvlrprm = 32
   WHERE cdacesso = 'TEMPO_FATURA_TRIBUTOS';
  
  COMMIT;
END;