BEGIN
   update cecred.crawepr e
   SET e.FLGRENEG = 0
   WHERE e.cdcooper = 16    AND
         e.nrdconta = 48275 AND
         e.NRCTREMP IN (220291,273875,273897);
         
   COMMIT;
EXCEPTION
WHEN OTHERS THEN
  raise_application_error(-20010, SQLERRM);
END;