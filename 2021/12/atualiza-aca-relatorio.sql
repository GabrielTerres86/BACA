BEGIN
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper,pr_cdcoptel,pr_intiprel,pr_dtrefere,pr_cddolote,pr_dtinclusao'
   WHERE NMPACKAG = 'TELA_IMOVEL'
     AND NMDEACAO = 'RELATO_IMOVEL'
     AND NMPROCED = 'pc_imprime_relatorio_imovel';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
