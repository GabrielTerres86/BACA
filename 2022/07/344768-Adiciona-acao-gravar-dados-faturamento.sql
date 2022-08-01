BEGIN
  
  INSERT INTO CECRED.crapaca (
    nmdeacao
    , nmpackag
    , nmproced
    , lstparam
    , nrseqrdr
  ) VALUES (
    'GRAVAR_DADOS_FATURAMENTO'
    , NULL
    , 'gravarDadosFaturamento'
    , 'pr_nrdconta,pr_idseqttl,pr_dados_fat'
    , 211
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
