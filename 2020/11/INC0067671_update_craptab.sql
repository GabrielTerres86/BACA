/*
    INC0067671 - Daniel Lombardi Mout'S
    
    Script para ativar incluir novo banco 383.

*/

UPDATE craptab tab
SET tab.dstextab = '7,91,128,130,260,274,368,383'
WHERE tab.cdcooper = 0 
  AND tab.nmsistem = 'CRED' 
  AND tab.tptabela = 'GENERI' 
  AND tab.cdempres = 0 
  AND tab.cdacesso = 'AGE_ATIVAS_CAF' 
  AND tab.tpregist = 0;
COMMIT;
