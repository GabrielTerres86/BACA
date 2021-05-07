begin
update crapaca a
   set a.lstparam = a.lstparam||',pr_idmicrocredito'
 where nmpackag = 'TELA_SEGEMP' 
   and nmdeacao = 'SEGEMP_ALTERA_SUB';
   commit;
exception
  when others then
   null;
end;      


