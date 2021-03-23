declare
  v_nrseqrdr craprdr.nrseqrdr%type;
begin

insert into craptel (NMDATELA, NRMODULO, CDOPPTEL, TLDATELA, TLRESTEL, FLGTELDF, FLGTELBL, NMROTINA, LSOPPTEL, INACESSO, CDCOOPER, IDSISTEM, IDEVENTO, NRORDROT, NRDNIVEL, NMROTPAI, IDAMBTEL)
values ('ASSELE', 5, '@,I,A,C,D', 'ASSINATURA ELETRONICA', ' ', 0, 1, ' ', ' ', 0, 1, 1, 0, 1, 1, ' ', 2);

insert into crapace (NMDATELA, CDDOPCAO, CDOPERAD, NMROTINA, CDCOOPER, NRMODULO, IDEVENTO, IDAMBACE)
values ('ASSELE', 'C', '1', ' ', 1, 5, 1, 2);

insert into crapprg (NMSISTEM, CDPROGRA, DSPROGRA##1, DSPROGRA##2, DSPROGRA##3, DSPROGRA##4, NRSOLICI, NRORDPRG, INCTRPRG, CDRELATO##1, CDRELATO##2, CDRELATO##3, CDRELATO##4, CDRELATO##5, INLIBPRG, CDCOOPER, QTMINMED)
values ('CRED', 'ASSELE', 'Assinatura Eletrônica', '.', '.', '.', 50, 10846, 1, 0, 0, 0, 0, 0, 1, 1, null);

insert into craprdr (nmprogra, dtsolici) values ('ASSELE',sysdate) returning nrseqrdr into v_nrseqrdr;

insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('INCL_PROPOSTA_ASSELE', 'TELA_ASSELE', 'pc_incluir_proposta', 'pr_documento,pr_cdcooper,pr_nrdconta,pr_proposta,pr_email,pr_whatsapp', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('CONS_PROPOSTA_ASSELE', 'TELA_ASSELE', 'pc_listar_propostas', 'pr_cdcooper,pr_nrdconta,pr_tipodocu,pr_status,pr_iniregis,pr_qtregpag', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_CONTRATOS_ASSELE', 'TELA_ASSELE', 'pc_busca_contratos', 'pr_nrdconta', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_CONTAS_ASSELE', 'TELA_ASSELE', 'pc_busca_contas', null, v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_EMAIL_ASSELE', 'TELA_ASSELE', 'pc_busca_email', 'pr_nrdconta', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('BUSCA_WHATS_ASSELE', 'TELA_ASSELE', 'pc_busca_whats', 'pr_nrdconta', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('EXCL_PROPOSTA_ASSELE', 'TELA_ASSELE', 'pc_excluir_proposta', 'pr_idenvass', v_nrseqrdr);
insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
values ('GRAVA_CODIGO_DOCUMENTO', 'TELA_ASSELE', 'pc_grava_codigo_documento', 'pr_idenvass,pr_cddoc', v_nrseqrdr);

commit;
end;