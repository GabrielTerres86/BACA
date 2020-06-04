/*
  INC0049807 e INC0049776 - Script para mudar o nome fantasia no portal do lojista
  ID:2058  NOME:CIPRIANI AGÊNCIA DE TURISMO para NOME: CEDROS MARMORARIA LTDA ME
  ID:14386 NOME:LV MODAS                    para NOME: SORRICLICK
  
  Daniel Lombardi - Mout'S
*/
UPDATE tbepr_cdc_vendedor 
   SET nmvendedor = 'CEDROS MARMORARIA LTDA ME' 
   WHERE idvendedor = 2058;
UPDATE tbepr_cdc_vendedor 
   SET nmvendedor = 'SORRICLICK' 
   WHERE idvendedor = 14386;
COMMIT;
