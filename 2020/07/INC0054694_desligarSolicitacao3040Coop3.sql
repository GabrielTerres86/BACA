/*
Squad Riscos
Analista: Wagner Silva
Desenvolvedor: Luiz Ot�vio Olinger Momm / AMCOM

INC0054694
Devido crps573 n�o ter finalizado com sucesso a rotina manteve
ativa a solicita��o do 3040 rodando todos os dias na noturna.
*/
UPDATE craptab tab
   SET tab.dstextab = '2' || SUBSTR(tab.dstextab,2)
 WHERE tab.nmsistem = 'CRED'      
   AND tab.tptabela = 'USUARI'    
   AND tab.cdempres = 11          
   AND tab.cdacesso = 'RISCOBACEN'
   AND tab.tpregist = 000;
   AND tab.cdcooper = 3;
COMMIT;
