BEGIN
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_idseqbem'
   WHERE NMPACKAG = 'TELA_IMOVEL'
     AND NMDEACAO = 'BAIXA_IMOVEL'
     AND NMPROCED = 'pc_gravar_baixa_manual_imovel';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
