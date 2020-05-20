declare
begin
  update crapaca
     set lstparam = lstparam || ',pr_flgreneg,pr_dsctrliq'
   where nmdeacao='CALC_TARIFA_CADASTRO';
   commit;
end;

