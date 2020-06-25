UPDATE crapass a
   SET a.nmprimtl = replace(a.nmprimtl,chr(39),' ')
 WHERE a.nmprimtl like  ('%' || chr(39) || '%') AND a.cdcooper = 1 AND a.nrdconta = 9110240;
 
 UPDATE crapass a
   SET a.nmprimtl = replace(a.nmprimtl,chr(39),' ')
 WHERE a.nmprimtl like   ('%' || chr(39) || '%') AND a.cdcooper = 6 AND a.nrdconta = 12475;
 
  UPDATE crapass a
   SET a.nmprimtl = replace(a.nmprimtl,chr(39),' ')
 WHERE a.nmprimtl like   ('%' || chr(39) || '%') AND a.cdcooper = 4 AND a.nrdconta = 10243;