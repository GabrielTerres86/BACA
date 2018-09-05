--select * from crapaca x where x.nmproced='pc_tela_buscar_dados_integrant' for update
update crapaca set lstparam='pr_idgrupo,pr_listar_todos,pr_nrdconta,pr_contaref' where nmproced='pc_tela_buscar_dados_integrant';
commit;
