-- inativar senha
update crapsnh snh
   set snh.cdsitsnh = 0 -- inativo
 WHERE snh.cdcooper = 3
   and snh.nrdconta = 1060007
   AND snh.tpdsenha = 2
   AND snh.cdsitsnh = 1;  -- Ativa
   
COMMIT;

   