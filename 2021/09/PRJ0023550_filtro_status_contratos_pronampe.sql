BEGIN
  --238065 Opcoes na coluna Status da Honra - filtro
  UPDATE crapaca
     SET lstparam = 'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim,pr_sthonra'
   WHERE UPPER(nmdeacao) = 'CONSULTA_CONTRATOS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;