BEGIN

  insert into cecred.crapaca
    (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values
    ('INSERE_CAPA_RENEG',
     null,
     'CREDITO.incluirCapaRenegociacao',
     'pr_nrdconta,pr_nrctremp,pr_nrctrcap,pr_nrdiaatr',
     71);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
