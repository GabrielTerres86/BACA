BEGIN

  update cecred.crappep  
     set DTULTPAG = to_date('10-09-2022', 'dd-mm-yyyy')
        ,VLPAGPAR = 363.17
        ,INLIQUID = 1
        ,VLDESPAR = 0
        ,VLSDVATU = 0
  where nrdconta = 99814293 
    and nrctremp = 40911 
    and cdcooper = 10 
    and nrparepr = 3;

  COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
