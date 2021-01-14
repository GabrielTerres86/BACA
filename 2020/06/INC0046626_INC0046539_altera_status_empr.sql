/*
  INC0046626 - INC0046539
  
  Alteração no indicador de liquidação de empréstimos. 
  
  Alinhado com Fabricio W. (Analista) e Marina Santos (Área de negócio). Analisado que o 
  indicador estava erroneamente indicando que o empréstimo não estava liquidado.
  
  Daniel Lombardi - Mout'S

*/
UPDATE crapepr epr
   SET epr.inliquid = 1  
WHERE epr.cdcooper = 1 
  AND epr.nrdconta IN (2715023, 7026498) 
  AND epr.inliquid = 0;
COMMIT;
