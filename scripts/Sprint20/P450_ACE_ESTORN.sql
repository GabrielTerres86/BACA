

UPDATE craptel t
   SET t.cdopptel = t.cdopptel|| ',CCT,ECT,RCT',
       t.lsopptel = t.lsopptel|| ',CONSULTA CC,ESTORNA CC,RELATORIO CC'
 WHERE t.nmdatela = 'ESTORN'; 
   
 
 INSERT INTO crapace 
       (nmdatela, 
        cddopcao, 
        cdoperad, 
        nmrotina, 
        cdcooper, 
        nrmodulo, 
        idevento, 
        idambace)
    
 SELECT 'ESTORN', --nmdatela
        'CCT'   , --cddopcao 
        a.cdoperad, 
        a.nmrotina, 
        a.cdcooper, 
        a.nrmodulo, 
        a.idevento, 
        a.idambace 
   FROM crapace a,
        crapope o         
  WHERE a.nmdatela = 'ESTPRJ'
    AND a.cddopcao = 'C'
    AND a.cdcooper = o.cdcooper
    AND a.cdoperad = o.cdoperad
    AND o.cdsitope = 1; 
    
    
  
 INSERT INTO crapace 
       (nmdatela, 
        cddopcao, 
        cdoperad, 
        nmrotina, 
        cdcooper, 
        nrmodulo, 
        idevento, 
        idambace)
    
 SELECT 'ESTORN', --nmdatela
        'ECT'   , --cddopcao 
        a.cdoperad, 
        a.nmrotina, 
        a.cdcooper, 
        a.nrmodulo, 
        a.idevento, 
        a.idambace 
   FROM crapace a,
        crapope o         
  WHERE a.nmdatela = 'ESTPRJ'
    AND a.cddopcao = 'C'
    AND a.cdcooper = o.cdcooper
    AND a.cdoperad = o.cdoperad
    AND o.cdsitope = 1; 
  
  
 INSERT INTO crapace 
       (nmdatela, 
        cddopcao, 
        cdoperad, 
        nmrotina, 
        cdcooper, 
        nrmodulo, 
        idevento, 
        idambace)
    
 SELECT 'ESTORN', --nmdatela
        'RCT'   , --cddopcao 
        a.cdoperad, 
        a.nmrotina, 
        a.cdcooper, 
        a.nrmodulo, 
        a.idevento, 
        a.idambace 
   FROM crapace a,
        crapope o         
  WHERE a.nmdatela = 'ESTPRJ'
    AND a.cddopcao = 'C'
    AND a.cdcooper = o.cdcooper
    AND a.cdoperad = o.cdoperad
    AND o.cdsitope = 1; 

INSERT INTO crapace 
       (nmdatela, 
        cddopcao, 
        cdoperad, 
        nmrotina, 
        cdcooper, 
        nrmodulo, 
        idevento, 
        idambace)
    
 SELECT DISTINCT 'ESTORN', --nmdatela
        t.cddopcao,        --cddopcao 
        o.cdoperad, 
        ' ',              --nmrotina 
        a.cdcooper, 
        1,                --nrmodulo
        0,                --idevento 
        2                --idambace 
   FROM crapope a,
        crapope o,
        (SELECT 'RCT' cddopcao FROM dual UNION
         SELECT 'ECT' cddopcao FROM dual UNION
         SELECT 'CCT' cddopcao FROM dual ) t                 
  WHERE a.cdcooper = o.cdcooper
    AND upper(o.cdoperad) IN ('F0030567','F0030688','F0030539')
    AND o.cdsitope = 1;        
    
    COMMIT;
