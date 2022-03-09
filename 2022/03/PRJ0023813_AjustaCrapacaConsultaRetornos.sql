BEGIN
  UPDATE crapaca a
     SET a.lstparam = 'pr_cdcooper,pr_tipooperacao,pr_nrdconta,pr_nrcontrato,pr_dtinicio,pr_dtfim,pr_status'
   WHERE a.nmdeacao = 'CONSULTA_RETORNOS_PEAC';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
