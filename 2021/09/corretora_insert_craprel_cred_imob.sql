BEGIN
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
    (850,
     '1',
     '999',
     'Comissao Seg. Cred. Imobiliario',
     '1',
     'Credito Imobiliario',
     '234col',
     '0',
     '3',
     'Mensal',
     '1',
     '1',
     '1');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/
