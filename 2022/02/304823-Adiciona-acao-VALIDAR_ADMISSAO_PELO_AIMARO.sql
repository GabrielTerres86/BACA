BEGIN
  
  INSERT INTO CECRED.crapaca (
    nmdeacao
    , nmpackag
    , nmproced
    , lstparam
    , nrseqrdr
  ) VALUES (
    'VALIDAR_ADMISSAO_PELO_AIMARO'
    , NULL
    , 'validarAdmissaoPeloAimaro'
    , NULL
    , 211
  );
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
