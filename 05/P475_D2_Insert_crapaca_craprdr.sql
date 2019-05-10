DECLARE
  vr_nrseqrdr number;
BEGIN
  insert into craprdr (NRSEQRDR,NMPROGRA,DTSOLICI)
               values (NULL, 'TELA_CONSPB', sysdate)
               returning NRSEQRDR into vr_nrseqrdr;

  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
               values (null, 'PC_EXECUTAR_CONCILIACAO_MNL', 'TELA_CONSPB', 'PC_EXECUTAR_CONCILIACAO_MNL','PR_TIPO_MSG, PR_DTMENSAGEM_DE, PR_DTMENSAGEM_ATE, PR_DSENDERE', vr_nrseqrdr);


  Commit;
  
END;



