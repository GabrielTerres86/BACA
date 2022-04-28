BEGIN
  UPDATE crapaca a
     SET a.lstparam = 'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_tpctrlim'
   WHERE a.nmdeacao = 'EXEC_CARGA_MANUAL';
   COMMIT;
END;
