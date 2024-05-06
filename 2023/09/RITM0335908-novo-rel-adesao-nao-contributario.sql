BEGIN

UPDATE cecred.tbseg_historico_relatorio r 
   SET r.dtfim = TO_DATE('22/10/2023','dd/mm/yyyy')
 WHERE r.cdacesso = 'NOVA_PROPOSTA_PREST_2';
 
INSERT INTO cecred.tbseg_historico_relatorio (IDHISTORICO_RELATORIO, CDACESSO, DSTEXPRM, DSVLRPRM, DTINICIO, DTFIM, FLTPCUSTEIO)
VALUES (5, 'NOVA_PROPOSTA_PREST_3', 'Relatório Prestamista depois da modificação da RITM0335908', 'proposta_prestamista_r0335908.jasper', TO_DATE('23/10/2023', 'dd/mm/yyyy'), NULL, 1);

COMMIT;
END;

 
