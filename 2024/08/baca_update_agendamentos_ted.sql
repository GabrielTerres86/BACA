BEGIN
 
  UPDATE cecred.craplau
     SET DSORIGEM = 'INTERNET'
        ,DSCEDENT = 'DEBITO TED'
   WHERE dtmvtolt >= to_date('09/08/2024','DD/MM/RRRR')
     AND cdhistor = 555
     AND dsorigem = 'InternetBank'
     AND insitlau = 1;
         
  COMMIT;  

END;
