BEGIN
 DELETE FROM cecred.crapcon con WHERE con.cdempcon IN (2448,2044) AND con.cdhistor IN (659,3390);

 COMMIT;
END;