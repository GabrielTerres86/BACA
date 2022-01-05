BEGIN
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper, pr_dtinclusao, pr_dtgeracao'
   WHERE NMPACKAG = 'TELA_IMOVEL'
     AND NMDEACAO = 'GERAR_ARQ'
     AND NMPROCED = 'pc_gera_arquivo';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
