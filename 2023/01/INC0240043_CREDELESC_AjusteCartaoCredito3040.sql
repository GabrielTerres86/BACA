BEGIN
  UPDATE cecred.crapris ris
     SET ris.flgindiv = 1
   WHERE ris.cdcooper = 8
     AND ris.dtrefere = to_date('31/12/2022', 'dd/mm/yyyy')
     AND ris.cdmodali = 1513
     AND ris.cdorigem = 6;
  COMMIT;
END;
