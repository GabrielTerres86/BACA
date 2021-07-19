BEGIN
  UPDATE craphec c 
     SET c.flgativo = 0,
         c.hriniexe = 0,
         c.hrfimexe = 0
   WHERE c.cdcooper = 3
     AND UPPER(c.dsprogra) LIKE UPPER('TAA E INTERNET%');
  
COMMIT;

END;

   
