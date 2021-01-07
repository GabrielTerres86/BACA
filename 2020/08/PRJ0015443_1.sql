begin

  insert into CRAPACA (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(C.NRSEQACA) + 1 FROM CRAPACA C), 'QBRSIG_LISTA_QUEBRA', 'QBRSIG', 'pc_lista_quebra', 'pr_nrseq_quebra_sigilo,pr_nrodocumento,pr_nrregist,pr_nriniseq', 1744);

  insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'BLQJ_JOB_QUEBRA', 'Endereco de email para receber info de quebras automatizadas', 'bacenjud@ailos.coop.br');
  
  commit;
  
end;