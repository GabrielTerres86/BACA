BEGIN
  BEGIN
    insert into CRAPPRM
      (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
    values
      ('CRED',
       3,
       'PINPAD_MIGRA_PA',
       'Miragração de PAs para utilização do novo PINPAD',
       null,
       null);
  END;

  BEGIN
    insert into CRAPACA
      (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values
      (NULL,
       'GRAVACAO_PINPAD_LOG',
       'CARTAO.CRD_PINPAD',
       'gravarLogPINPAD',
       'pr_cdcooper,pr_nrdconta,pr_dslog,pr_idlog,pr_dscritic',
       2164);
  
    insert into CRAPACA
      (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
    values
      (NULL,
       'MIGRACAO_PINPAD',
       'CARTAO.CRD_PINPAD',
       'obterMigracaoPINPAD',
       'pr_cdcooper,pr_cdagenci',
       2164);
  
  END;

  COMMIT;

END;
