BEGIN

  UPDATE cecred.tbseg_historico_relatorio
     SET dtfim = TO_DATE('13/11/2022','dd/mm/yyyy'),
         dstexprm = 'Relatório Prestamista antes da modificação da RITM0252232'
   WHERE cdacesso = 'PROPOSTA_PREST_CONTRIB';
 
	INSERT INTO cecred.tbseg_historico_relatorio (IDHISTORICO_RELATORIO, CDACESSO, DSTEXPRM, DSVLRPRM, DTINICIO, DTFIM, FLTPCUSTEIO)
	VALUES (4, 'ADESAO_PROP_PRST_CONTRIB', 'Relatório Prestamista depois da modificação da RITM0252232', 'proposta_prestamista_contributario_adesao.jasper', TO_DATE('14/11/2022', 'dd/mm/yyyy'), NULL, 0); 


  FOR rw_crapcop in (SELECT cdcooper FROM cecred.crapcop) LOOP
    INSERT INTO cecred.craprel
      (cdrelato,
       nrviadef,
       nrviamax,
       nmrelato,
       nrmodulo,
       nmdestin,
       nmformul,
       indaudit,
       cdcooper,
       periodic,
       tprelato,
       inimprel,
       ingerpdf)
    VALUES
      (826,
       '1',
       '999',
       'ADESAO PROPOSTA SEGURO PRESTAMISTA CONTRIBUTARIO',
       '5',
       'PRESTAMISTA',
       '234col',
       '0',
       rw_crapcop.cdcooper,
       'D',
       '1',
       '1',
       '1');
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('2 ERRO: ' || SQLERRM);
    ROLLBACK;
END;
/


