BEGIN
  DELETE FROM CRAPACA WHERE NMPACKAG LIKE '%PARINV%';
  DELETE FROM CRAPACE WHERE NMDATELA LIKE '%PARINV%';
  DELETE FROM CRAPRDR WHERE NMPROGRA LIKE '%PARINV%';
  DELETE FROM CRAPTEL WHERE NMDATELA LIKE '%PARINV%';
  DELETE FROM CRAPPRG WHERE CDPROGRA LIKE '%PARINV%';

  INSERT INTO craptel
    (nmdatela,
     nrmodulo,
     cdopptel,
     tldatela,
     tlrestel,
     flgteldf,
     flgtelbl,
     nmrotina,
     lsopptel,
     inacesso,
     cdcooper,
     idsistem,
     idevento,
     nrordrot,
     nrdnivel,
     nmrotpai,
     idambtel)
    VALUES('PARINV',
           12,
           '@,A,C',
           'PARAMETROS MESA INVESTIMENTO',
           'MES. INV.',
           0,
           1,
           ' ',
           'Acesso,Alterar,Consulta',
           1,
           3,
           1,
           0,
           1,
           1,
           '',
           2);

  DECLARE
    vr_ListaDeF gene0002.typ_split;
  BEGIN       
    vr_ListaDeF := gene0002.fn_quebra_string('f0033330,f0030757,f0033023,f0030519,f0033346', ',');
    IF vr_ListaDeF.COUNT() > 0 THEN  
      FOR ind_registro IN vr_ListaDeF.first .. vr_ListaDeF.last LOOP
        INSERT INTO crapace
             (nmdatela,
             cddopcao,
             cdoperad,
             nmrotina,
             cdcooper,
             nrmodulo,
             idevento,
             idambace)
        VALUES('PARINV',
               'C',
               vr_ListaDeF(ind_registro),
               ' ',
               3,
               1,
               1,
               2);
               
        INSERT INTO crapace
            (nmdatela,
             cddopcao,
             cdoperad,
             nmrotina,
             cdcooper,
             nrmodulo,
             idevento,
             idambace)
        VALUES('PARINV',
               'A',
               vr_ListaDeF(ind_registro),
               ' ',
               3,
               1,
               1,
               2);
               
        INSERT INTO crapace
            (nmdatela,
             cddopcao,
             cdoperad,
             nmrotina,
             cdcooper,
             nrmodulo,
             idevento,
             idambace)             
        VALUES('PARINV',
               '@',
               vr_ListaDeF(ind_registro),
               ' ',
               3,
               1,
               1,
               2);
      END LOOP;    
    END IF;
  END;

  INSERT INTO crapprg
    (nmsistem,
     cdprogra,
     dsprogra##1,
     dsprogra##2,
     dsprogra##3,
     dsprogra##4,
     nrsolici,
     nrordprg,
     inctrprg,
     cdrelato##1,
     cdrelato##2,
     cdrelato##3,
     cdrelato##4,
     cdrelato##5,
     inlibprg,
     cdcooper)
    SELECT 'CRED',
           'PARINV',
           'MES. INV.',
           '.',
           '.',
           '.',
           406,
           NULL,
           1,
           0,
           0,
           0,
           0,
           0,
           1,
           cdcooper
      FROM crapcop
     WHERE cdcooper IN 3;

  INSERT INTO CRAPRDR (nmprogra, dtsolici) values ('TELA_PARINV', sysdate);

  INSERT INTO crapaca
    (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ((SELECT MAX(NRSEQACA) + 1 FROM CRAPACA),
     'PARINV_CARREGAR_COOPERATIVAS',
     'TELA_PARINV',
     'pc_Carregar_Cooperativas',
     '',
     (SELECT NRSEQRDR FROM CRAPRDR WHERE NMPROGRA = 'TELA_PARINV'));

  INSERT into crapaca
    (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  VALUES
    ((SELECT MAX(NRSEQACA) + 1 FROM CRAPACA),
     'PARINV_ALTERAR_PARAMETROS',
     'TELA_PARINV',
     'pc_altera_params_parinv',
     'pr_cdCoopDistribuiFundos', 
     (SELECT NRSEQRDR FROM CRAPRDR WHERE NMPROGRA = 'TELA_PARINV'));

  COMMIT;
END;