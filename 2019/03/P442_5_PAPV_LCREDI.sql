BEGIN
   
  UPDATE craplcr lcr
    SET lcr.flprapol = 1
   WHERE lcr.cdlcremp IN(7000,7001);
                   
                   
UPDATE crapaca aca 
   SET aca.lstparam = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_nrgrplcr,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx'
 WHERE aca.nmdeacao = 'ALTLINHA';
 
UPDATE crapaca aca 
   SET aca.lstparam = 'pr_cdlcremp,pr_dslcremp,pr_tpctrato,pr_nrgrplcr,pr_txjurfix,pr_txjurvar,pr_txpresta,pr_qtdcasas,pr_nrinipre,pr_nrfimpre,pr_txbaspre,pr_qtcarenc,pr_vlmaxass,pr_vlmaxasj,pr_txminima,pr_txmaxima,pr_perjurmo,pr_tpdescto,pr_nrdevias,pr_cdusolcr,pr_flgtarif,pr_flgtaiof,pr_vltrfesp,pr_flgcrcta,pr_dsoperac,pr_dsorgrec,pr_manterpo,pr_flgimpde,pr_flglispr,pr_tplcremp,pr_cdmodali,pr_cdsubmod,pr_flgrefin,pr_flgreneg,pr_qtrecpro,pr_consaut,pr_flgdisap,pr_flgcobmu,pr_flgsegpr,pr_cdhistor,pr_flprapol,pr_cdfinali,pr_tpprodut,pr_cddindex,pr_permingr,pr_vlperidx'
 WHERE aca.nmdeacao = 'INCLINHA';                    
                   
  commit;
end;
