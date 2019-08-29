

update crapbpr
   set cdsitgrv = 2
     , flcancel = 0
     , dtcancel = null
     , tpcancel = ' '
     , dsjuscnc = ''
 where cdcooper = 14
   and nrdconta = 13927
   and nrctrpro = 10411
   and progress_recid = 6010714;
   
 
-- Efetuar commit
COMMIT;
