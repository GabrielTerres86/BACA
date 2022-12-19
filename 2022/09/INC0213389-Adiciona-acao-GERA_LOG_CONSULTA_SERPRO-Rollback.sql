BEGIN
  
  DELETE CECRED.crapaca a
  WHERE a.nrseqrdr = 211
    and a.nmdeacao = 'GERA_LOG_CONSULTA_SERPRO'
    and a.nmproced = 'geraLogConsultaSerpro';
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
