BEGIN
  INSERT INTO cecred.crapaca ( nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
  VALUES ('VALIDA_EMPR_CONSIG', 'TELA_CONSIG', 'pc_valida_empr_consig_web', NULL, 1805);
  COMMIT;
EXCEPTION    
  WHEN OTHERS THEN 
  ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, SQLERRM);
END;
