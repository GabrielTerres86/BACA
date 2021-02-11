-- Squad Risco - Pagamento com Aval na CT
UPDATE crapaca
   SET lstparam = 'pr_nrdconta,pr_nrctremp,pr_vlpagmto,pr_vldabono,pr_nrseqava'
 WHERE UPPER(nmproced) = 'PC_PAGAMENTO_PREJUIZO_WEB'
   AND UPPER(nmdeacao) = 'EFETUA_PAGTO';

COMMIT;