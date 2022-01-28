BEGIN
  
UPDATE crapsld SET  vlsmnmes = '999999' ,vlsmnesp = '-999,99' ,vliofmes = '9,99' WHERE cdcooper = 1   AND nrdconta = 329;

COMMIT;


EXCEPTION
  
 WHEN OTHERS THEN
    ROLLBACK;
END;
