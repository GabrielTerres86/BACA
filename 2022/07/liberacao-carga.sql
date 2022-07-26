begin
update credito.TBCRED_PREAPROV b
set b.dtliberacao = to_date('01/07/2022','dd/mm/yyyy')
where b.idcarga = 182;
commit;
end;
