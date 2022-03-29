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
      (814,
       '1',
       '999',
       'EMPRESTIMO CONTRATADO SEM SEG PREST CONTRIBUTARIO',
       '1',
       'PRESTAMISTA',
       '132col',
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
