
begin

  update crapaca
    set lstparam = lstparam || ',pr_indconta_menor'
  where nmdeacao = 'INCLUIR_TIPO_DE_CONTA';
  
  update crapaca
    set lstparam = lstparam || ',pr_indconta_menor'
  where nmdeacao = 'ALTERAR_TIPO_DE_CONTA';

  commit;

end;
/


