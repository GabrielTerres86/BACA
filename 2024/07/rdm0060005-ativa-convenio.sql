BEGIN
  UPDATE cecred.crapcon
     SET flginter = 1
   WHERE cdempcon = 4746 and cdsegmto = 2;
  COMMIT;
END; 
