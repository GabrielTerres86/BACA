BEGIN

UPDATE CECRED.craplft 
   SET dtmvtolt = to_date('16/05/2024', 'DD/MM/YYYY') , flintegra = 0, insitfat = 1 
 WHERE PROGRESS_RECID IN (74916620, 74904420);

COMMIT;

END;