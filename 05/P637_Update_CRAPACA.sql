begin

update crapaca set lstparam = 'pr_cdorigem,pr_dsprotoc,pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nrtransa,pr_dsresana,pr_indrisco,pr_nrnotrat,pr_nrinfcad,pr_nrliquid,pr_nrgarope,pr_nrparlvr,pr_nrperger,pr_desscore,pr_datscore,pr_flgpreap,pr_dsrequis,pr_namehost,pr_idfluata'
where nmdeacao = 'PROCESSA_ANALISE'
and nmpackag = 'EMPR0012';

update crapaca set lstparam = 'pr_cdorigem,pr_dsprotoc,pr_nrtransa,pr_dsresana,pr_indrisco,pr_nrnotrat,pr_nrinfcad,pr_nrliquid,pr_nrgarope,pr_inopeatr,pr_nrparlvr,pr_nrperger,pr_desscore,pr_datscore,pr_dsrequis,pr_namehost,pr_idfluata'
where nmdeacao = 'WEBS0001_ANALISE_MOTOR'
and nmpackag = 'WEBS0001'; 

commit;

end;

