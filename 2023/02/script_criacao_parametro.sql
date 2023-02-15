BEGIN
  -- insere todos os historicos de convenio que validam a duplicidade                                         
  INSERT INTO cecred.crapprm (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES ('CRED', 0, 'HIST_TRIBUTOS_VAL_DUPLI', 'Lista de tributos(histórico) que valida a duplicidade','2515,3361,3192,3194,3196,3198,3200,3202,3204');
  
  --Aumenta o tempo de validação para 20 segundos
  UPDATE cecred.crapprm
     SET dsvlrprm = 20
   WHERE cdacesso = 'TEMPO_FATURA_TRIBUTOS';
  
  COMMIT;
END;