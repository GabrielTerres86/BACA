begin
  insert into crapaca values(
  (select max(nrseqaca)+1 from crapaca),
  'BUSCA_LOG_CONTRATO_IMOB',
  null,
  'CREDITO.pc_busca_log_contrato_imob',
  'pr_cdcooper, pr_nrdconta ,pr_nrctremp,pr_nriniseq,pr_nrregist',
  71);
commit;
exception when others then
  null;
end;
 