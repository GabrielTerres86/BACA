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
      (821,
       '1',
       '999',
       'RECUSA DE SEGURO PRESTAMISTA SEMANAL',
       '5',
       'PRESTAMISTA',
       '234col',
       '0',
       rw_crapcop.cdcooper,
       'Semanal',
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
      (822,
       '1',
       '999',
       'RECUSA DE SEGURO PRESTAMISTA MENSAL',
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
