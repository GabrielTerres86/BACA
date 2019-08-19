BEGIN
  
 UPDATE crapsab s SET s.nrcepsac = 89052000
  WHERE s.cdcooper = 12
    AND s.nrdconta = 80594
    AND s.nrinssac = '28760537000179';
 
 COMMIT;
 
END;
