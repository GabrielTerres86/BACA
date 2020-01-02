update crapprm 
   set dsvlrprm = '2208,2216,2240,2321,2429,3107,2704,2712,2658,2682,2801,2810,2852,2879,4105,4136,4142,6432,6629'
 where cdacesso = 'IDENTIF_CEI_PAGFOR'
   and cdcooper = 0
   and nmsistem = 'CRED';
commit;
