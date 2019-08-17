-- 28/12/2018 inc0029997 Correção de codificação do nome do PA 13 para possibilitar a administração do seu cadastro no Aimaro (Carlos)
UPDATE crapage
   SET crapage.nmresage = 'PA PARANA'
 WHERE cdcooper = 7
   AND cdagenci = 13;
COMMIT;
