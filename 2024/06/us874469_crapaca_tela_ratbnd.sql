BEGIN
  INSERT INTO cecred.crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('BUSCA_DADOS_PROPOSTAS_CONTA',
     'EMPR0026',
     'pc_obter_dados_propostas_conta_web',
     'pr_cdcooper, pr_nrdconta',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'RATBND'));

  INSERT INTO cecred.crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('GERA_NUMERO_CONTRATO_BNDES',
     'EMPR0026',
     'pc_gerar_numero_contrato_bdnes_web',
     'pr_cdcooper, pr_nrdconta, pr_nrctremp',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'RATBND'));
	   
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
	  RAISE_APPLICATION_ERROR(-20500, SQLERRM);
END;