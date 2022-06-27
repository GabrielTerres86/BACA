begin

update tbseg_historico_relatorio a
set a.dtfim = to_date('31/12/3000','dd/mm/yyyy')
where a.idhistorico_relatorio = 3;

commit;

end;