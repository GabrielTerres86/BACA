BEGIN
  UPDATE crapaca aca 
     SET aca.lstparam = 'pr_idsicredi,pr_nsu,pr_dscomprovante' 
   WHERE aca.nmdeacao = 'TAB057_ATUALIZA_COMPROVANTE_SEGVIA';
 COMMIT;
END;
