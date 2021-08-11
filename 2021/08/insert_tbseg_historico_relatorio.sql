BEGIN
  INSERT INTO tbseg_historico_relatorio(cdacesso,dstexprm,dsvlrprm,dtinicio,dtfim)
    VALUES('NOVA_PROPOSTA_PREST_1','Relatório Prestamista antes da modificação da RITM0156316','proposta_prestamista_nova.jasper','01/01/1990',TRUNC(SYSDATE)-1);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
BEGIN
  INSERT INTO tbseg_historico_relatorio(cdacesso,dstexprm,dsvlrprm,dtinicio)
    VALUES('NOVA_PROPOSTA_PREST_2','Relatório Prestamista depois da modificação da RITM0156316','proposta_prestamista_r0156316.jasper',TRUNC(SYSDATE));
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
