-- Corrige dsnivori (Risco Original) gravado com valor incorreto
UPDATE crawepr 
   SET dsnivori = dsnivris
 WHERE cdcooper = 2
   AND nrdconta = 459291
	 AND nrctremp = 237018
;

UPDATE crawepr 
   SET dsnivori = dsnivris
 WHERE cdcooper = 2
   AND nrdconta = 582808 
	 AND nrctremp = 236243
;

COMMIT;
