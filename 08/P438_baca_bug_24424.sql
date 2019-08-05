/* -------------------------------
BUG 24424 
PROJETO 438


Atualizar o campo tpdescto = 1 das tabelas crawepr e crapepr
das propostas finalidadede crédito de INTERNET (77) 
da cooperativa 16.
 
--------------------------------*/

/* Atualiza os contratos */   
UPDATE crapepr p
   SET p.tpdescto = (select tpdescto from craplcr where craplcr.cdcooper = p.cdcooper and craplcr.cdlcremp = p.cdlcremp)
 WHERE p.cdcooper = 16
   AND p.nrctremp in ( SELECT w.nrctremp 
                         FROM crawepr w
                        WHERE w.cdcooper = 16
                          AND w.cdfinemp = 77
                          AND w.dtmvtolt > '01/05/2019'
                          AND w.nrsimula > 0);
                          
/* Atualiza as propostas */   
UPDATE CRAWEPR w
   SET w.tpdescto = (select tpdescto from craplcr where craplcr.cdcooper = w.cdcooper and craplcr.cdlcremp = w.cdlcremp)
                      WHERE w.cdcooper = 16
                        AND w.cdfinemp = 77
                        AND w.dtmvtolt > '01/05/2019'
                        AND w.nrsimula > 0;
  
COMMIT;
