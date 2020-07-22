update crapris 
set vldivida = 6954.17
    ,vlvec180 = 6954.17
    ,qtdiaatr = 0    
where cdcooper =1 and nrdconta = 8376573 and nrctremp = 1864288 and progress_recid = 1304399284;

delete from crapvri where progress_recid = 4217861213;

update crappep set
       vlpagpar = vlparepr,
       vldespar = 0,
       vlsdvatu = 0,
       inliquid = 1
where cdcooper = 1 
   and nrdconta = 8376573 
   and nrctremp = 1864288
   and nrparepr = 1;
   
UPDATE crapepr SET
       vlsdeved = 6954.17,
       vlsdvctr = 6954.17,
       vlsdevat = 6954.17
where cdcooper = 1 
   and nrdconta = 8376573 
   and nrctremp = 1864288;


commit;
