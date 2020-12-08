begin
	insert into CRAPACA 
		(
			NMDEACAO,
			NMPACKAG,
			NMPROCED,
			LSTPARAM,
			NRSEQRDR
		)
	values 
		(
			'QBRSIG_REL_BLOQS_COOP',
			'TELA_QBRSIG',
			'pc_gera_rel_bloq_cooperado',
			'pr_nroficon,pr_cdcooper,pr_nrdconta',
			1744
		);

	commit;
end;