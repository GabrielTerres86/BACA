BEGIN
  UPDATE CRAPACA
  SET LSTPARAM = 'pr_cdCoopDistribuiFundos, pr_dsUrlPortalCotista'
  WHERE NMDEACAO = 'PARINV_ALTERAR_PARAMETROS';
  
  UPDATE CRAPACA
  SET NMDEACAO = 'PARINV_CARREGAR_PARAMETROS',
      NMPROCED = 'pc_carregar_parametros'
  WHERE NMDEACAO = 'PARINV_CARREGAR_COOPERATIVAS';
  COMMIT;
END;