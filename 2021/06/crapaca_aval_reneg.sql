BEGIN
  insert into crapaca (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ('CONFERE_AVAIS_RENEG', 'empr0021', 'pc_confere_aval_contratos_web', 'pr_cdcooper,pr_nrdconta,pr_dadosctr', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'ATENDA'));
  
  COMMIT;
END;

