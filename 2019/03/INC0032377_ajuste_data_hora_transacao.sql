UPDATE craplem lem
   SET lem.dthrtran = to_date('10/01/2019 10:18:34', 'dd/mm/RRRR HH:MI:SS')
 WHERE lem.cdcooper = 1 
   AND lem.nrdconta = 7096763 
   AND lem.nrctremp = 1389416
   AND lem.cdhistor = 1036;
   
COMMIT;
