BEGIN
  UPDATE cecred.gnconve gnc
  SET gnc.flgativo = 0
  WHERE gnc.cdconven = 53;
     
 COMMIT;
END;