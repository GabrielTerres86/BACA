BEGIN
  UPDATE CRAPACA
  SET LSTPARAM = 'pr_dsUrlPortalCotista,pr_dsUrlApi,pr_dsUsuarioApi,pr_dsSenhaApi, pr_dsUrlToken'
  WHERE NMDEACAO = 'PARINV_ALTERAR_PARAMETROS';
  COMMIT;
END;