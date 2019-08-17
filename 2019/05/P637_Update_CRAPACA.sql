begin

update crapaca set lstparam = lstparam || ',pr_idfluata'
where upper(nmdeacao) = 'PROCESSA_ANALISE'
and upper(nmpackag) = 'EMPR0012';

update crapaca set lstparam = lstparam || ',pr_idfluata'
where upper(nmdeacao) = 'WEBS0001_ANALISE_MOTOR'
and upper(nmpackag) = 'WEBS0001'; 

commit;

end;

