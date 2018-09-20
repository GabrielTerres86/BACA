insert into craprel 
 (CDRELATO,
  NRVIADEF, 
  NRVIAMAX, 
  NMRELATO, 
  NRMODULO, 
  NMDESTIN, 
  NMFORMUL, 
  INDAUDIT, 
  CDCOOPER, 
  PERIODIC, 
  TPRELATO, 
  INIMPREL, 
  INGERPDF)

SELECT 751,                                               --> CDRELATO
1,                                                        --> NRVIADEF 
1,                                                        --> NRVIAMAX 
'ESTORNOS CC EM PREJUÍZO',                                --> NMRELATO 
3,                                                        --> NRMODULO 
' ',                                                       --> NMDESTIN 
'234col',                                                 --> NMFORMUL
0,                                                        --> INDAUDIT 
cop.cdcooper,                                             --> CDCOOPER 
'D',                                                      --> PERIODIC 
1,                                                        --> TPRELATO 
1,                                                        --> INIMPREL 
1                                                         --> INGERPDF      

FROM crapcop cop                                              
WHERE cop.flgativo = 1;

commit;  
