declare
  vr_nrseqrdr craprdr.nrseqrdr%type;
begin
  insert into craprdr(nmprogra, dtsolici) values ('HISTOR',trunc(sysdate)) returning nrseqrdr into vr_nrseqrdr;
  
  insert into crapaca(nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr) 
              values ('REPLICA_CAMPO_HISTORICO','TELA_HISTOR','pc_replicacao_histor','pr_cdhistor,pr_campo,pr_valor',vr_nrseqrdr);

  commit;
end;
