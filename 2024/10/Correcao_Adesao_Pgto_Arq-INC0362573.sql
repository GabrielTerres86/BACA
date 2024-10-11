BEGIN
  UPDATE cecred.crapaca
     SET lstparam = 'pr_nrdconta, pr_nrconven, pr_flghomol, pr_idretorn, pr_flgativo'
   WHERE nmdeacao = 'INCLUIRCONVENIO'
     AND nmpackag = 'PGTA0001'
     AND nmproced = 'pc_inserir_convenio';
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
