BEGIN
  UPDATE CRAPACA 
	SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_idseqbem,pr_cdoperad,pr_nrmatcar,pr_nrcnscar,pr_tpimovel,pr_nrreggar,pr_dtreggar,pr_nrgragar,pr_nrceplgr,pr_tplograd,pr_dslograd,pr_nrlograd,pr_dscmplgr,pr_dsbairro,pr_cdcidade,pr_dtavlimv,pr_vlavlimv,pr_dtcprimv,pr_vlcprimv,pr_tpimpimv,pr_incsvimv,pr_inpdracb,pr_vlmtrtot,pr_vlmtrpri,pr_qtdormit,pr_qtdvagas,pr_vlmtrter,pr_vlmtrtes,pr_incsvcon,pr_inpesvdr,pr_nrdocvdr,pr_nmvendor,pr_nrreginc,pr_dtinclus,pr_dsjstinc,pr_flgtpimovel'
	WHERE NMPACKAG ='TELA_IMOVEL' AND NMDEACAO = 'SALVA_IMOVEL';

COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
