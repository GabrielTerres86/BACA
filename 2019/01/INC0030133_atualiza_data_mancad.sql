--SELECT c.dtmancad, c.dtmanavl, c.dtmangar, c.* FROM crapcyb c WHERE c.dtmvtolt = '28/12/2018' AND c.dtdbaixa IS NULL

UPDATE crapcyb c
   SET c.dtmancad = to_date('03/01/2019', 'dd/mm/RRRR')
      ,c.dtmanavl = to_date('03/01/2019', 'dd/mm/RRRR')
      ,c.dtmangar = to_date('03/01/2019', 'dd/mm/RRRR')
 WHERE c.dtmvtolt = '28/12/2018' 
   AND c.dtdbaixa IS NULL;
      
COMMIT;
