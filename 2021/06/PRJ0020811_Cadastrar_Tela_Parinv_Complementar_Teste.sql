
  
DECLARE
  vr_ListaDeF gene0002.typ_split;
BEGIN       
  vr_ListaDeF := gene0002.fn_quebra_string('f0030439,f0030003,f0030010,f0030011,f0030018,f0030066', ',');
  IF vr_ListaDeF.COUNT() > 0 THEN  
    FOR ind_registro IN vr_ListaDeF.first .. vr_ListaDeF.last LOOP
      IF (vr_ListaDeF(ind_registro) in ('f0030439', 'f0030011', 'f0030018')) THEN
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
        END IF;
           
      IF (vr_ListaDeF(ind_registro) in ('f0030003', 'f0030011', 'f0030066')) THEN
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
      END IF;
        
      IF (vr_ListaDeF(ind_registro) in ('f0030010', 'f0030018', 'f0030066')) THEN
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
      END IF;
    END LOOP;    
  END IF;
	COMMIT;
END;