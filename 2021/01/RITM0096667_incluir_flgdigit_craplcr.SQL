BEGIN
  update crapaca set lstparam = lstparam || ',pr_flgdigit' 
    where nmdeacao = 'INCLINHA' and nmpackag = 'TELA_LCREDI';
  update crapaca set lstparam = lstparam || ',pr_flgdigit' 
    where nmdeacao = 'ALTLINHA' and nmpackag = 'TELA_LCREDI';
  commit;
END;