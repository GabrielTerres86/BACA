

update crapbpr
   set cdsitgrv = 3
     , flcancel = 1
     , dtcancel = '21/08/2019'
     , tpcancel = 'M'
     , dsjuscnc = 'cancelado manualmente'
 where cdcooper = 14
   and nrdconta = 13927
   and nrctrpro = 10411
   and progress_recid = 6010714;
   
 
-- Efetuar commit
COMMIT;
