BEGIN

  DELETE cecred.tbbi_opf_header x
   WHERE x.DTBASE = to_date('31/03/2024', 'DD/MM/RRRR');
  commit;
  DELETE cecred.crapopf x
   WHERE x.DTREFERE = to_date('31/03/2024', 'DD/MM/RRRR');
  commit;
  DELETE cecred.crapvop x
   WHERE x.DTREFERE = to_date('31/03/2024', 'DD/MM/RRRR');

  COMMIT;
  
END;
