BEGIN
 
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     1,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     2,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     3,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     5,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     6,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     7,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     8,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     9,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     10,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     11,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     12,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     13,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     14,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA FISICA (S/N)'),
     16,
     'S');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     1,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     2,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     3,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     5,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     6,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     7,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     8,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     9,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     10,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     11,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     12,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     13,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     14,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE MENU OPEN FINANCE PESSOA JURIDICA (S/N)'),
     16,
     'N');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     1,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     2,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     3,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     5,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     6,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     7,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     8,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     9,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     10,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     11,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     12,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     13,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     14,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA FISICA (S/N)'),
     16,
     'S');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     1,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     2,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     3,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     5,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     6,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     7,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     8,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     9,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     10,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     11,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     12,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     13,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     14,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU TRAZER DINHEIRO PESSOA JURIDICA (S/N)'),
     16,
     'N');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     1,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     2,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     3,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     5,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     6,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     7,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     8,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     9,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     10,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     11,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     12,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     13,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     14,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA FISICA (S/N)'),
     16,
     'S');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     1,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     2,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     3,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     5,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     6,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     7,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     8,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     9,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     10,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     11,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     12,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     13,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     14,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS PAGAMENTOS PESSOA JURIDICA (S/N)'),
     16,
     'N');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     1,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     2,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     3,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     5,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     6,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     7,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     8,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     9,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     10,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     11,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     12,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     13,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     14,
     'S');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA FISICA (S/N)'),
     16,
     'S');
  
  INSERT INTO cecred.crappat
    (cdpartar, nmpartar, tpdedado)
  VALUES
    ((SELECT MAX(cecred.crappat.cdpartar) + 1 FROM cecred.crappat),
     'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)',
     2);

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     1,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     2,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     3,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     5,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     6,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     7,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     8,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     9,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     10,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     11,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     12,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     13,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     14,
     'N');

  INSERT INTO cecred.crappco
    (crappco.cdpartar, cdcooper, dsconteu)
  VALUES
    ((SELECT cecred.crappat.cdpartar
       FROM cecred.crappat
      WHERE cecred.crappat.nmpartar like
            'OPEN FINANCE MOBILE - EXIBE SUBMENU MEUS AGENDAMENTOS PESSOA JURIDICA (S/N)'),
     16,
     'N');
  
  INSERT INTO CECRED.MENUMOBILE
    (MENUMOBILEID,
     MENUPAIID,
     NOME,
     SEQUENCIA,
     HABILITADO,
     AUTORIZACAO,
     VERSAOMINIMAAPP,
     VERSAOMAXIMAAPP)
  VALUES
    (1100, 30, 'Open Finance', 1, 1, 1, '2.55.0', null);
  
  INSERT INTO CECRED.MENUMOBILE
    (MENUMOBILEID,
     MENUPAIID,
     NOME,
     SEQUENCIA,
     HABILITADO,
     AUTORIZACAO,
     VERSAOMINIMAAPP,
     VERSAOMAXIMAAPP)
  VALUES
    (1101, 1100, 'Trazer Dinheiro', 1, 1, 1, '2.55.0', null);
  
  INSERT INTO CECRED.MENUMOBILE
    (MENUMOBILEID,
     MENUPAIID,
     NOME,
     SEQUENCIA,
     HABILITADO,
     AUTORIZACAO,
     VERSAOMINIMAAPP,
     VERSAOMAXIMAAPP)
  VALUES
    (1102, 1100, 'Meus Pagamentos', 2, 1, 1, '2.55.0', null);
  
  INSERT INTO CECRED.MENUMOBILE
    (MENUMOBILEID,
     MENUPAIID,
     NOME,
     SEQUENCIA,
     HABILITADO,
     AUTORIZACAO,
     VERSAOMINIMAAPP,
     VERSAOMAXIMAAPP)
  VALUES
    (1103, 1100, 'Pagamentos Agendados', 3, 1, 1, '2.55.0', null);

  COMMIT;

END;
