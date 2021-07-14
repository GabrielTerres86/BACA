DELETE crapscn
 WHERE cdempcon = 12
   AND UPPER(cdsegmto) = '5'
   AND UPPER(cdempres) = '07';
COMMIT;
/