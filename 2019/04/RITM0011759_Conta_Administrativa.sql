-- Setar conta para tipo administrativo. RITM0011759. Jackson.
update CRAPASS 
   set INPESSOA = 3 
 where cdcooper = 1 
   and nrdconta = 8579997;
   
COMMIT;
   
   