BEGIN
  UPDATE cecred.craplgp lgp
  SET lgp.cddpagto = 2003
  WHERE lgp.progress_recid = 3606981;     
 COMMIT;
END;