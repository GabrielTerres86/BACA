/* ------------ LIMPA SAIDA DE OPERACAO E INDICADOR DE INDIVIDUALIZACAO DE OPERACAO DA CENTRAL DE RISCO ---------- */
/* VIACREDI */

DELETE FROM crapris ris
 WHERE ris.cdcooper = 1
   AND ris.inddocto = 2
   AND ris.dtrefere = '31/07/2019'; -- Se atentar a data da mensal

UPDATE crapris ris
   SET ris.flgindiv = 0
 WHERE ris.cdcooper = 1
   AND ris.dtrefere = '31/07/2019'; -- Se atentar a data da mensal

/* --------- ALTERA CONTROLE PARA PERMITIR SOLICITAR A GERACAO DO 3040 NO BATCH --------- */

UPDATE craptab tab
   SET tab.dstextab = '0' || SUBSTR(tab.dstextab,2)
 WHERE tab.cdcooper = 1
   AND tab.nmsistem = 'CRED'       
   AND tab.tptabela = 'USUARI'     
   AND tab.cdempres = 11           
   AND tab.cdacesso = 'RISCOBACEN' 
   AND tab.tpregist = 000;
   
   
COMMIT;

