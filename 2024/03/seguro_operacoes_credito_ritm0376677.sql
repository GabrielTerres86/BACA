BEGIN
  UPDATE CECRED.tbseg_historico_relatorio r
     SET r.dtfim = TRUNC(SYSDATE) - 1
   WHERE r.dtfim IS NULL
     AND r.fltpcusteio = 0;

  INSERT INTO CECRED.tbseg_historico_relatorio
    (IDHISTORICO_RELATORIO,
     CDACESSO,
     DSTEXPRM,
     DSVLRPRM,
     DTINICIO,
     FLTPCUSTEIO)
  VALUES
    (6,
     'ADITIVO_PROP_PRST_CONTRB',
     'Relatório Prestamista depois da modificação da RITM0376677',
     'proposta_prestamista_contributario_aditivo.jasper',
     TRUNC(SYSDATE),
     0);
  COMMIT;
END;
/
