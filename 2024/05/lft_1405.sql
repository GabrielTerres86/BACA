BEGIN

UPDATE CECRED.craplft 
   SET dtmvtolt = to_date('14/05/2024', 'DD/MM/YYYY') , flintegra = 0, insitfat = 1 
 WHERE PROGRESS_RECID IN (75204119, 75204118);

COMMIT;

END;