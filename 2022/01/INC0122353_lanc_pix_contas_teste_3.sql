BEGIN
  
UPDATE crapsld SET vlsmnmes = to_number('7'),vlsmnesp = to_number('-777,77'),vliofmes = to_number('7,77') WHERE cdcooper = 1 AND nrdconta = 329;

COMMIT;


EXCEPTION
  
 WHEN OTHERS THEN
    ROLLBACK;
END;

