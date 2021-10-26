BEGIN
  UPDATE crapaca c
     SET c.lstparam = c.lstparam || ',pr_tpcuspr'
   WHERE c.nmpackag = 'TELA_LCREDI'
     AND c.nmproced IN ('pc_alterar_linha_credito','pc_incluir_linha_credito');
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
