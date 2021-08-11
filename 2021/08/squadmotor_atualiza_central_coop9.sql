BEGIN
    
  DELETE FROM crapris t
       WHERE t.cdcooper = 9
       AND t.dtrefere >= to_date('26/07/2021','dd/mm/yyyy');
 COMMIT;
END;
