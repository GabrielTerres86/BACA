BEGIN
    
  DELETE FROM crapris t
       WHERE t.cdcooper = 9
       AND t.dtrefere >= '26/07/2021'
       ;
 COMMIT;
END;
