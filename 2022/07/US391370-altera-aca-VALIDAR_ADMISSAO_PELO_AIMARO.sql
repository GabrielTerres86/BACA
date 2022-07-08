BEGIN
  
  UPDATE CECRED.crapaca
    SET lstparam = 'pr_inpessoa'
  WHERE nmdeacao = 'VALIDAR_ADMISSAO_PELO_AIMARO'
    AND nmproced = 'validarAdmissaoPeloAimaro'
    AND nrseqrdr = 211;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
