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

SELECT 743,                                               --> CDRELATO
1,                                                        --> NRVIADEF 
1,                                                        --> NRVIAMAX 
'EXTRATO BLOQ. PREJUIZO CC',                              --> NMRELATO 
5,                                                        --> NRMODULO 
'Financeiro',                                             --> NMDESTIN 
'80col',                                                  --> NMFORMUL 
0,                                                        --> INDAUDIT 
cop.cdcooper,                                             --> CDCOOPER 
'D',                                                      --> PERIODIC 
1,                                                        --> TPRELATO 
2,                                                        --> INIMPREL 
1                                                         --> INGERPDF      

FROM crapcop cop                                              
WHERE cop.cdcooper <> 1
