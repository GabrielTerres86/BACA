
update crapaca aca
set aca.lstparam = 'pr_cdcooper, pr_nrdconta, pr_operacao,pr_dtgerini,pr_dtgerfim,pr_situacao, pr_sitarqret'
where aca.nmpackag = 'PGTA0001'
and   aca.nmdeacao = 'CONSULTARARQREM';

commit;

