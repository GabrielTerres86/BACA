begin

update	tbcrd_preaprov_carga a
set	a.dtfinvigencia	= to_date('31/01/2022','dd/mm/yyyy')
where	a.idcarga	= 158025
and	a.cdcooper	= 1;

commit;

end;