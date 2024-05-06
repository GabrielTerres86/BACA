BEGIN
  UPDATE CECRED.crappfp
     SET cdocorrencia = 'YK'
   WHERE cdcooper = 9
     AND cdempres = 283
     AND dtcredit = to_date('04/03/2024','DD/MM/RRRR');
  COMMIT;
END;
