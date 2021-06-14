declare
  v_nrseqrdr craprdr.nrseqrdr%type;
begin

for i in (select cdcooper from crapcop) loop
  
  insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
  values ('RECJUD', 5, '@,I,A,C,D', 'RECUPERACAO JUDUCIAL', ' ', 0, 1, ' ', ' ', 0, i.cdcooper, 1, 0, 1, 1, ' ', 2);

  insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
  values ('RECJUD', 'C', '1', ' ', i.cdcooper, 5, 1, 2);

  insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
  values ('CRED', 'RECJUD', 'Recuperacao Judicial', '.', '.', '.', 51, 10846, 1, 0, 0, 0, 0, 0, 1, i.cdcooper, null);

end loop;

insert into craprdr (nmprogra, dtsolici) values ('RECJUD',sysdate) returning nrseqrdr into v_nrseqrdr;

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('PESQ_CNPJ_RECJUD', 'TELA_RECJUD', 'pc_pesquisa_cnpj', 'pr_cnpj', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('INCLUIR_RECJUD', 'TELA_RECJUD', 'pc_incluir_rec_judicial', 'pr_cnpj, pr_rzscrjud', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('EXCLUIR_RECJUD', 'TELA_RECJUD', 'pc_excluir_rec_judicial', 'pr_cnpj, pr_rzscrjud', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('PLANILHA_RECJUD', 'TELA_RECJUD', 'pc_salva_planilha_recjud', 'pr_tipo_planilha', v_nrseqrdr);

commit;
end;