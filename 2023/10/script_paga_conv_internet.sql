BEGIN
  UPDATE crapcon con
     SET con.flginter = 1
   WHERE con.cdempcon = 1764
     AND con.cdsegmto = 2;
   
  UPDATE crapcon con
     SET con.flginter = 1
   WHERE con.cdempcon = 9999
     AND con.cdsegmto = 2;
   
  COMMIT;
END; 