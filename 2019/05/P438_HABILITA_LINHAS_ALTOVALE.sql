UPDATE craplcr 
   SET craplcr.flgstlcr = 1
 WHERE craplcr.cdlcremp in (7080,7081)
   AND craplcr.cdcooper = 16;

COMMIT; 
