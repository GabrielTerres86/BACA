BEGIN
  UPDATE crapaca
     SET lstparam = 'pr_cdcooper,pr_tipooperacao,pr_nrdconta,pr_nrcontrato,pr_dtinicio,pr_dtfim,pr_status,pr_nriniseq,pr_nrregist'
   WHERE nmpackag = 'TELA_PEAC'
     AND nmdeacao = 'CONSULTA_RETORNOS_PEAC';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
