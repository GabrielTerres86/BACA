----------------------------Ribeiro------------------------------------------
-- Cadastro relatorio proposta_prestamista_contributario
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
-- COOPERATIVA CUSTEIO PADRAO
BEGIN
  FOR st_cdcooper IN (SELECT c.cdcooper FROM crapcop c) LOOP
    INSERT INTO crapprm
      (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES
      ('CRED',
       st_cdcooper.cdcooper,
       'TPCUSTEI_PADRAO',
       'Valor padrão do tipo de custeio para cadastro de uma nova linha de crédito',
       '1');
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('6 ERRO: ' || SQLERRM);
    ROLLBACK;
END;
/
