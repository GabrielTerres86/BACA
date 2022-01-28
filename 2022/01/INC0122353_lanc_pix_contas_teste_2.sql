BEGIN
  
UPDATE crapsld SET  vlsmnmes = 888 ,vlsmnesp = -888.88 ,vliofmes = 8.88 WHERE cdcooper = 1   AND nrdconta = 256;

COMMIT;


EXCEPTION
  
 WHEN OTHERS THEN
    ROLLBACK;
END;

