-- 28/12/2018 inc0029997 Corre��o de codifica��o do nome do PA 13 para possibilitar a administra��o do seu cadastro no Aimaro (Carlos)
UPDATE crapage
   SET crapage.nmresage = 'PA PARANA'
 WHERE cdcooper = 7
   AND cdagenci = 13;
COMMIT;
