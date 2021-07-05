begin
insert into crapaca values(
(select max(nrseqaca)+1 from crapaca),
'BUSCA_EMP_IMOB_CAPA',
null,
'CREDITO.pc_busca_imob_capa',
'pr_cdcooper, pr_nrdconta',
71);

insert into crapaca values(
(select max(nrseqaca)+1 from crapaca),
'BUSCA_EMPRESTIMOS_IMOB',
null,
'CREDITO.pc_consulta_emprestimo_imobiliario',
'pr_cdcooper, pr_nrdconta, pr_nrctremp',
71);

commit;
exception when others then 
	null;
	
end;

