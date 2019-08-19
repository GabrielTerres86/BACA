DECLARE
  vr_nrseqrdr number;
BEGIN
  insert into craprdr (NRSEQRDR,NMPROGRA,DTSOLICI)
               values (NULL, 'TELA_CONSPB', sysdate)
               returning NRSEQRDR into vr_nrseqrdr;

  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
               values (null, 'PC_EXECUTAR_CONCILIACAO_MNL', 'TELA_CONSPB', 'pc_executar_conciliacao_mnl','pr_tipo_msg,pr_dtmensagem_de,pr_dtmensagem_ate,pr_dsendere', vr_nrseqrdr);


  Commit;
  
END;



