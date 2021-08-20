BEGIN
  UPDATE gnsbmod
     SET dssubmod = 'Imobiliario Garantido'
   WHERE cdmodali = '02'
     AND cdsubmod = '99';
  COMMIT;
END;
/