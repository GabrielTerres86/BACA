BEGIN
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('REENVIAR_CONTRATO',
     'TELA_RCONSI',
     'PC_REENVIAR_CONTRATO_WEB',
     'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_dsxmlenv',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'TELA_RCONSI'));
     
  INSERT INTO crapaca
    (NMDEACAO,
     NMPACKAG,
     NMPROCED,
     LSTPARAM,
     NRSEQRDR)
  VALUES
    ('EST_RNV_PARCELA',
     'TELA_RCONSI',
     'PC_PARCELAS_EST_RNV_WEB',
     'pr_cdcooper,pr_nrdconta,pr_nrctremp,pr_nrparepr1,pr_nrparepr2,pr_dtmvtolt,pr_tiposoli',
     (SELECT NRSEQRDR
        FROM craprdr
       WHERE upper(NMPROGRA) = 'TELA_RCONSI'));
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;