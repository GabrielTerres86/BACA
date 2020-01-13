BEGIN
  UPDATE crapaca t
     SET t.lstparam = t.lstparam||',pr_vlfgcoop'
   WHERE t.nmdeacao = 'ALTCOOP'
     AND t.lstparam NOT LIKE '%pr_vlfgcoop%'; -- Evitar que o parametro seja inserido mais de uma vez
     
  COMMIT;

END;
