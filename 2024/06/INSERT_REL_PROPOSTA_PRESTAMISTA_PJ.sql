BEGIN

  INSERT INTO CECRED.tbseg_historico_relatorio (IDHISTORICO_RELATORIO,CDACESSO,DSTEXPRM,DSVLRPRM,DTINICIO,FLTPCUSTEIO)
  VALUES (9,'PROPOSTA_PRSTAMISTA_PJ_1','Relatório Prestamista Contributário PJ','proposta_prestamista_contributario_pj_01.jasper',TRUNC(SYSDATE),0);

COMMIT;
END;

