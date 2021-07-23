DECLARE
  vr_ListaDeF gene0002.typ_split;
BEGIN       
  vr_ListaDeF := gene0002.fn_quebra_string('f0033346,f0033330', ',');
  IF vr_ListaDeF.COUNT() > 0 THEN
    FOR i IN 1 .. 17 LOOP --COOPERATIVAS
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
        VALUES('CADSOA',
             'C',
             vr_ListaDeF(ind_registro),
             ' ',
             i,
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
        VALUES('CADSOA',
             'A',
             vr_ListaDeF(ind_registro),
             ' ',
             i,
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
        VALUES('CADSOA',
             '@',
             vr_ListaDeF(ind_registro),
             ' ',
             i,
             1,
             1,
             2);
      END LOOP;
    END LOOP;
  END IF;
  COMMIT;
END;