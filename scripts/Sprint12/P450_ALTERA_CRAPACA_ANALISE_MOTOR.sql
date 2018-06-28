UPDATE crapaca c 
   SET c.lstparam = 'pr_cdorigem,pr_dsprotoc,pr_nrtransa,
                     pr_dsresana,pr_indrisco,pr_nrnotrat,
                     pr_nrinfcad,pr_nrliquid,pr_nrgarope,
                     pr_inopeatr,pr_nrparlvr,pr_nrperger,
                     pr_desscore,pr_datscore,pr_dsrequis,pr_namehost'
 WHERE c.nmdeacao = 'WEBS0001_ANALISE_MOTOR';
 COMMIT;