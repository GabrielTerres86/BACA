CREATE OR REPLACE VIEW CECRED.VW_CAPT_HISTOR_OPERAC AS
select hst.tpaplicacao
      ,0 cdprodut
      ,hst.cdhistorico
      ,hst.idtipo_arquivo
      ,hst.idtipo_lancto
      ,hst.cdoperacao_b3
  from CECRED.TBCAPT_HISTOR_OPERAC_B3 hst
/* Aplicações da PCAPTA - A configuração está na tabela crapcpc */
UNION
SELECT cpc.idtippro + 2 /* Para que Pré fique 3 e Pós fique 4 */
      ,cpc.cdprodut
      ,cpc.cdhsraap
      ,1
      ,1
      ,'0001'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex
UNION
SELECT cpc.idtippro + 2 /* Para que Pré fique 3 e Pós fique 4 */
      ,cpc.cdprodut
      ,cpc.cdhsnrap
      ,1
      ,1
      ,'0001'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex
/*UNION
SELECT cpc.idtippro + 2 -- Para que Pré fique 3 e Pós fique 4
      ,cpc.cdprodut
      ,cpc.cdhsirap
      ,2
      ,3
      ,'0064'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex*/
UNION      -- IRRF
SELECT cpc.idtippro + 2 -- Para que Pré fique 3 e Pós fique 4
      ,cpc.cdprodut
      ,cpc.cdhsirap
      ,2
      ,3
      ,'0314'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex
UNION      -- RENDIMENTO
SELECT cpc.idtippro + 2 -- Para que Pré fique 3 e Pós fique 4
      ,cpc.cdprodut
      ,cpc.cdhsrdap
      ,2
      ,4
      ,'0314'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex
UNION
SELECT cpc.idtippro + 2 /* Para que Pré fique 3 e Pós fique 4 */
      ,cpc.cdprodut
      ,cpc.cdhsrgap
      ,2
      ,2
      ,'0314'
  FROM crapind ind
      ,crapcpc cpc
 WHERE cpc.cddindex = ind.cddindex