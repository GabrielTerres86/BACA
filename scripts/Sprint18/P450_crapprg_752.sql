/* Incluir programa crps752 - na cadeia*/
INSERT INTO crapprg  
           (nmsistem, 
            cdprogra, 
            dsprogra##1, 
            dsprogra##2, 
            dsprogra##3, 
            dsprogra##4, 
            nrsolici, 
            nrordprg, 
            inctrprg, 
            cdrelato##1, 
            cdrelato##2, 
            cdrelato##3, 
            cdrelato##4, 
            cdrelato##5, 
            inlibprg, 
            cdcooper, 
            qtminmed)
SELECT 'CRED'                   --> nmsistem
       ,'CRPS752'               --> cdprogra 
       ,'PROCESSA PREJUIZO CC'  --> dsprogra##1 
       ,' '                     --> dsprogra##2 
       ,' '                     --> dsprogra##3 
       ,' '                     --> dsprogra##4 
       ,'1'                     --> nrsolici 
       ,p.NRORDPRG              --> nrordprg
       ,2                       --> inctrprg 
       ,0                       --> cdrelato##1 
       ,0                       --> cdrelato##2 
       ,0                       --> cdrelato##3 
       ,0                       --> cdrelato##4 
       ,0                       --> cdrelato##5 
       ,1                       --> inlibprg 
       ,c.cdcooper              --> cdcooper 
       ,0                       --> qtminmed

  FROM crapcop c,
       (SELECT cdcooper, NRORDPRG + 1 AS "NRORDPRG"
          FROM (SELECT cop.cdcooper,max(NRORDPRG) NRORDPRG
                  FROM CRAPPRG X,
                       crapcop cop
                 WHERE X.CDCOOPER = cop.cdcooper
                   AND X.NRORDPRG < (SELECT NRORDPRG FROM CRAPPRG P WHERE P.CDCOOPER = X.CDCOOPER AND P.CDPROGRA = 'CRPS001' )
                   AND X.NRSOLICI = 1
                   GROUP BY cop.cdcooper)) p
 WHERE c.cdcooper <> 3
   AND c.cdcooper = p.cdcooper
   AND c.flgativo = 1;
   
   COMMIT;
   
