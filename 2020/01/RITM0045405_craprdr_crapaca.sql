declare
  vr_nrseqrdr craprdr.nrseqrdr%type;
begin
  insert into craprdr(nmprogra, dtsolici) values ('CADMOB',trunc(sysdate)) returning nrseqrdr into vr_nrseqrdr;

  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
               values('CADMOB_CONSULTAR','TELA_CADMOB','pc_lista_modalidade',null,vr_nrseqrdr);

  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
               values('CADMOB_CONSULTA_MODALIDADE','TELA_CADMOB','pc_busca_modalidade','pr_cdmodalidade_bacen,pr_tpemprst',vr_nrseqrdr);

  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
               values('CADMOB_EXCLUI_MODALIDADE','TELA_CADMOB','pc_exclui_modalidade','pr_cdmodalidade_bacen,pr_tpemprst',vr_nrseqrdr);

  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
               values('CADMOB_CONSULTA_DSMODALIDADE','TELA_CADMOB','pc_busca_dsmodalidade','pr_cdmodalidade_bacen',vr_nrseqrdr);

  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
               values('CADMOB_ATUALIZAR','TELA_CADMOB','pc_atualizar_modalidade','pr_cdmodalidade_bacen,pr_tpemprst,pr_nrctadeb,pr_nrctacrd,pr_nrconta_cosif',vr_nrseqrdr);

  commit;
end;
/
