BEGIN
 
  UPDATE craplft lft 
  SET lft.dtdenvio = '28/10/2021' 
  WHERE lft.idsicred IN (4204532,4204531,4204524,4204528,4204530,4204529);

  COMMIT;
END;
        
        
