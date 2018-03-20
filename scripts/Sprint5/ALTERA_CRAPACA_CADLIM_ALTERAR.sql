update crapaca c
   set c.lstparam = 'pr_inpessoa, pr_vlmaxren, pr_nrrevcad, pr_qtmincta, pr_qtdiaren, pr_qtmeslic, pr_qtmaxren, pr_qtdiaatr, pr_qtatracc, pr_dssitdop, pr_dsrisdop, pr_tplimite, pr_pcliqdez, pr_qtdialiq,pr_qtcarpag,pr_qtaltlim, pr_idgerlog' 
 where c.nmdeacao = 'CADLIM_ALTERAR';
 COMMIT;