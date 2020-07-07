/*
  [RITM0082488] Script para prorrogar prazo de prova de vida
  Criado script para prorrogar o prazo de prova de vida para os beneficiários do INSS que 
  possuem o prazo expirado a partir de 01/06/2020 e os que irão expirar até 31/08/2020. 
*/
UPDATE tbinss_dcb d
   SET d.dtvencpv = add_months(d.dtvencpv, 60)
 WHERE trunc(d.dtvencpv) >= '01/06/2020'
   AND trunc(d.dtvencpv) <= '31/08/2020';

commit;
