Begin
update crapaca a
   set a.lstparam = a.lstparam||',pr_vlinicial,pr_vlfinal,pr_incartao'
 where nmpackag = 'TELA_RECCRD'
   and nmproced = 'pc_executa_acao_web';
commit;
exception
  when others then
    rollback;
end; 
