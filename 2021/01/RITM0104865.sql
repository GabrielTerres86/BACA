-- Created on 12/01/2021 by F0032494 
declare 
  -- Local variables here
  i integer;
  cursor cr_contas is
     SELECT TCO.CDCOPANT  AS COOP_ORIG
       , TCO.NRCTAANT  AS CTA_ORIG
       , TCO.CDCOOPER  AS COOP_DESTINO
       , TCO.NRDCONTA  AS CTA_DESTINO
       , ORIG.DTADMISS AS ADMISSAO_ORIG
       , DEST.DTADMISS AS ADMISSAO_DEST
       , ORIG.DTABTCCT AS ABERTURA_CTA_ORIG
       , DEST.DTABTCCT AS ABERTURA_CTA_DEST
    FROM CRAPASS ORIG
       , CRAPASS DEST
       , CRAPTCO TCO
   WHERE TCO.CDCOOPER = DEST.CDCOOPER
     AND TCO.NRDCONTA = DEST.NRDCONTA
     AND TCO.CDCOPANT = ORIG.CDCOOPER
     AND TCO.NRCTAANT = ORIG.NRDCONTA
     AND ORIG.CDCOOPER = 17
   ORDER BY 1;
   
   rw_contas cr_contas%rowtype;


begin

  
   FOR rw_contas IN cr_contas LOOP
      
      UPDATE CRAPASS ASS
         SET ASS.DTADMISS = CASE WHEN ASS.DTABTCCT > rw_contas.ABERTURA_CTA_ORIG THEN  rw_contas.ABERTURA_CTA_ORIG ELSE ASS.DTADMISS END
       WHERE ASS.CDCOOPER = rw_contas.coop_destino
         AND ASS.NRDCONTA = rw_contas.cta_destino;
         
   END LOOP;
   
   commit;
  
end;