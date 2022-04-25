BEGIN
  UPDATE tbseg_historico_relatorio t SET t.fltpcusteio = 1;

  INSERT INTO cecred.tbseg_historico_relatorio
    (cdacesso, dstexprm, dsvlrprm, dtinicio, fltpcusteio)
  VALUES
    ('PROPOSTA_PREST_CONTRIB',
     'Relatório Prestamista contributário',
     'proposta_prestamista_contributario.jasper',
     TRUNC(SYSDATE),
     0);
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('1 ERRO: ' || SQLERRM);
  ROLLBACK;
END;
/
BEGIN
  FOR rw_crapcop in (SELECT cdcooper FROM crapcop) LOOP
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
    values
      (820,
       '1',
       '999',
       'ARQUIVO PRESTAMISTA INADIMPLENTES',
       '5',
       'PRESTAMISTA',
       '234col',
       '0',
       rw_crapcop.cdcooper,
       'Mensal',
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
BEGIN
  INSERT INTO crapprm
    (nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
  VALUES
    ('CRED',
     0,
     'DATA_LIMITE_SEGPRE',
     'Data limite de geração de rotinas de seguro prestamista não contributário',
     '31/12/2024');
     COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
END;
/