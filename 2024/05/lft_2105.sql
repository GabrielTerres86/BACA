BEGIN

UPDATE CECRED.craplft 
   SET dtmvtolt = to_date('21/05/2024', 'DD/MM/YYYY') , flintegra = 0, insitfat = 1, idanafrd = Null
 WHERE PROGRESS_RECID IN (75204154, 75204152);

COMMIT;

END;