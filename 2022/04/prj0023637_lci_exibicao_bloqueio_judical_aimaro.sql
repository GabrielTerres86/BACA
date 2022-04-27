BEGIN
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),'BUSCA_VALOR_BLOQUEIO_JUDICIAL', 'apli0013', 'obterBloqueioJudicialWeb', 'pr_cdcooper, pr_nrdconta, pr_dtmvtolt', 71);
  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ((SELECT MAX(NRSEQACA)+1 FROM CECRED.CRAPACA),'BUSCA_VALOR_BLOQUEIO_JUDICIAL_APLICACAO', 'apli0013', 'obterBloqueioJudicialAplWeb', 'pr_cdcooper, pr_nrdconta, pr_dtmvtolt', 71);
 commit;

END;
/

