Begin
update crapaca a
   set a.lstparam = a.lstparam||',pr_imobiliario'
 where nmpackag = 'TELA_RATMOV'
   AND nmdeacao = 'PC_IMPRIMIR';
commit;
exception
  when others then
    rollback;
end;
