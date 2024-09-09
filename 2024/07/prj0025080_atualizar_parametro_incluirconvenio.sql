BEGIN
  UPDATE cecred.crapaca
     SET lstparam = 'pr_nrdconta, pr_nrconven, pr_flghomol, pr_idretorn, pr_flgativo, pr_flgvan'
   WHERE nmdeacao = 'INCLUIRCONVENIO'
     AND nmpackag = 'PGTA0001'
     AND nmproced = 'pc_inserir_convenio';
  COMMIT;
END;