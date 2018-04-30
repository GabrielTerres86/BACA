--select * from crapaca x where x.nmdeacao = 'CADLIM_ALTERAR'
update crapaca set LSTPARAM='pr_inpessoa, pr_vlmaxren, pr_nrrevcad, pr_qtmincta, pr_qtdiaren, pr_qtmeslic, pr_cnauinad, pr_qtdiatin, pr_qtmaxren, pr_qtdiaatr, pr_qtatracc, pr_dssitdop, pr_dsrisdop, pr_tplimite, pr_pcliqdez, pr_qtdialiq, pr_idgerlog' where nmdeacao = 'CADLIM_ALTERAR';
COMMIT;
