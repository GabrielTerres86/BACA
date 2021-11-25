BEGIN

UPDATE crapldt ldt
   SET ldt.cdpacrem = 91
 WHERE ldt.tpoperac = 9;

COMMIT;

END;