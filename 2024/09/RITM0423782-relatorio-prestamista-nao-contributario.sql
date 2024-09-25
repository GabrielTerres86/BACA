BEGIN
      
UPDATE cecred.tbseg_historico_relatorio r
   SET r.dtfim = TO_DATE('24/09/2024','DD/MM/YYYY')
 WHERE r.cdacesso = 'NOVA_PROPOSTA_PREST_4';
 
INSERT INTO cecred.tbseg_historico_relatorio(idhistorico_relatorio, cdacesso, dstexprm, dsvlrprm, dtinicio, dtfim, fltpcusteio, tppessoa)
VALUES (10,'NOVA_PROPOSTA_PREST_5','Relatório Prestamista depois da modificação da RITM0423782','proposta_prestamista_r0423782.jasper',TO_DATE('25/09/2024','DD/MM/YYYY'),NULL,1,1);

COMMIT;
END;