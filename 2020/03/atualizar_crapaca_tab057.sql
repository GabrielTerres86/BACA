UPDATE crapaca
   SET crapaca.lstparam = 'pr_cdcooper,pr_cdcoptel,pr_cdempres,pr_dtiniper,pr_dtfimper,pr_nriniseq,pr_nrregist'
 WHERE crapaca.nrseqaca = 2238;
 
UPDATE crapaca
   SET crapaca.lstparam = 'pr_cdcooper,pr_cdcoptel,pr_cdempres,pr_seqarnsa'
 WHERE crapaca.nrseqaca = 2240;
 
COMMIT;
