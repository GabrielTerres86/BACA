BEGIN
  
  UPDATE CECRED.CRAPLAU SET  DTDEBITO = to_date('17/10/2022', 'DD/MM/YYYY')
WHERE CDCOOPER = 13  
  AND NRDCONTA = 183946
  AND CDSEQTEL = '202210140000592038357';
  
  COMMIT;
END;