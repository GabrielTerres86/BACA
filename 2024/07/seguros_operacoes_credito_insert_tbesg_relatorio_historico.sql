BEGIN
  INSERT INTO CECRED.TBSEG_HISTORICO_RELATORIO
    (IDHISTORICO_RELATORIO,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     DTINICIO,
     FLTPCUSTEIO,
     TPPESSOA)
  VALUES
    (9,
     'PROP_PRST_CONTRB_PJ_1',
     'Relatório Prestamista PJ',
     'proposta_prestamista_contributario_pj_01.jasper',
     TRUNC(SYSDATE),
     0,
     2);
  COMMIT;
END;
/
