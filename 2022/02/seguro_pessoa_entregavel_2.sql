BEGIN
  UPDATE tbseg_historico_relatorio t SET t.fltpcusteio = 1;

  INSERT INTO cecred.tbseg_historico_relatorio
    (cdacesso, dstexprm, dsvlrprm, dtinicio, fltpcusteio)
  VALUES
    ('PROPOSTA_PREST_CONTRIB',
     'Relatório Prestamista contributário',
     'proposta_prestamista_contributario.jasper',
     TO_DATE('01/01/2022','DD/MM/RRRR'),
     0);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('1 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/