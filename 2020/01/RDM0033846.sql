 
 UPDATE crappep
    SET inliquid = 1
      , vlmrapar = 0
      , vlsdvpar = 0      
      , vlsdvatu = 0
      , vlsdvsji = 0
  WHERE ( cdcooper = 1 AND nrdconta =  889768  AND nrctremp = 1681914 AND nrparepr IN (  2 ) )
     OR ( cdcooper = 1 AND nrdconta =  9351604 AND nrctremp = 1149711 AND nrparepr IN (  13 ) );                       
   
commit;
