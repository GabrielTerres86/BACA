/*
*  Daniel Lombardi Mout'S                                                    Data: 28/04/2020
*
*  Script com objetivo de n�o for�ar o d�bito das respectivas tarifas que estavam com a data nula.
*  Conforme alinhado com �rea de neg�cios (Nayara Fernanda Cestari Reichert).
* 
*/
UPDATE craplat
SET craplat.dtmvtolt = craplat.dttransa
   ,craplat.insitlat = 3
WHERE craplat.dtmvtolt IS NULL;
COMMIT;
