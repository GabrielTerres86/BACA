/*
  INC0046626 - INC0046539
  
  Altera��o no indicador de liquida��o de empr�stimos. 
  
  Alinhado com Fabricio W. (Analista) e Marina Santos (�rea de neg�cio). Analisado que o 
  indicador estava erroneamente indicando que o empr�stimo n�o estava liquidado.
  
  Daniel Lombardi - Mout'S

*/
UPDATE crapepr epr
   SET epr.inliquid = 1  
WHERE epr.cdcooper = 1 
  AND epr.nrdconta IN (2715023, 7026498) 
  AND epr.inliquid = 0;
COMMIT;
