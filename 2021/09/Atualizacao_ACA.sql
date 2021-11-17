Begin
update crapaca a
   set a.lstparam = a.lstparam||',pr_imobiliario'
 where nmpackag = 'TELA_RATMOV'
   and nmproced = 'PC_CONSULTAR_RATING';
commit;
exception
  when others then
    rollback;
end; 