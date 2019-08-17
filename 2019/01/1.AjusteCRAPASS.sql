 UPDATE CRAPASS
    SET CDVINCULACAO = 4
  WHERE CDCOOPER = 16  
   AND CDVINCULACAO IS NULL
   AND DTDEMISS IS NULL;
   
 COMMIT;


    update tbrecip_calculo
     set idvinculacao = 4
     where idcalculo_reciproci in (select a.idcalculo_reciproci
          from tbrecip_calculo a, crapass b, crapceb c
         where a.idcalculo_reciproci = c.idrecipr
           and c.nrdconta = b.nrdconta
           and c.cdcooper = b.cdcooper
           and b.cdvinculacao is null
           and b.cdcooper = 16);
commit;