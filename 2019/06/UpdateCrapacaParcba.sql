  update crapaca c
     set c.lstparam = 'pr_dtmvtolt'
   where nmdeacao = 'EXECUTA_CONCILIACAO' and NMPACKAG = 'TELA_PARCBA';
  commit;
