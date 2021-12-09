BEGIN


UPDATE CRAPEPA
   SET NMFANSIA = ''
     , NATJURID = null
     , CDSETECO = null
     , CDRMATIV = null
 where cdcooper = 6
   and nrdconta = 501840; 
   
   commit;

END;

