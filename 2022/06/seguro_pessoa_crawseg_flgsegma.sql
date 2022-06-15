BEGIN
  UPDATE crapaca c
     SET c.lstparam = lstparam || ',pr_flgsegma'
   WHERE c.nmpackag = 'TELA_ATENDA_SEGURO'
     AND c.nmdeacao = 'ATUALIZA_PROPOSTA_PREST';   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/