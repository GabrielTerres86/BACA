UPDATE crawepr SET
       dsnivris = 'A',
       dsnivcal = 'A',
       dsnivori = 'A'
 where cdcooper = 7 
   and nrdconta = 139084 
   and nrctremp = 28447;
   
UPDATE crapass SET
       dsnivris = 'A'
 where cdcooper = 7 
   and nrdconta = 139084;
 
UPDATE crawepr SET
       dsnivris = 'B',
       dsnivcal = 'B',
       dsnivori = 'B'
 where cdcooper = 11
   and nrdconta = 310000
   and nrctremp = 56191;
   
UPDATE crapass SET
       dsnivris = 'B'
 where cdcooper = 11 
   and nrdconta = 310000;
   
commit;
