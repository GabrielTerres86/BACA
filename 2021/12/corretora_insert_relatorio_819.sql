-- Cadastro do relatorio 819
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
      (819,
       '1',
       '999',
       'SEGURO PRESTAMISTA CONTRIBUTÁRIO',
       '1',
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
    ROLLBACK;
END;
/
