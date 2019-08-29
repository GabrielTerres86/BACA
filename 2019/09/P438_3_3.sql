/*
 1 - Viacredi
11 - Credifoz 
 7 - Credcrea */


--> 1 - Viacredi
update tbepr_subsegmento s
   set s.cdlinha_credito = 112
 where s.cdcooper in(1)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 113
 where s.cdcooper in(1)
   and s.idsegmento = 2;   
   
--> 7 - Credcrea
update tbepr_subsegmento s
   set s.cdlinha_credito = 1105
 where s.cdcooper in (7)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 2105
 where s.cdcooper in (7)
   and s.idsegmento = 2; 

--> 11 - Credifoz
update tbepr_subsegmento s
   set s.cdlinha_credito = 7002
 where s.cdcooper in (11)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 7003
 where s.cdcooper in (11)
   and s.idsegmento = 2;    

update tbepr_segmento seg
   set seg.dssegmento_detalhada =
       (select decode(s.idsegmento,
                      1,
                      'Você pode usar esse crédito como preferir. O pagamento pode ser parcelado em até ' ||
                      l.nrfimpre ||
                      ' meses sem exigência de garantia ou avalista.',
                      'Para desenvolver seu negócio, pagamento em até ' ||
                      l.nrfimpre ||
                      ' vezes com a praticidade do débito em conta no dia escolhido.')
          from tbepr_subsegmento s, craplcr l
         where s.cdcooper        = l.cdcooper
           and s.cdlinha_credito = l.cdlcremp
           and seg.cdcooper      = s.cdcooper
           and seg.idsegmento    = s.idsegmento)

 where seg.cdcooper in (1,7,11)
   and seg.idsegmento in (1,2);

 
update tbepr_segmento_canais_perm s
   set s.tppermissao = 2
 where s.cdcooper in (1,7,11) 
   and s.cdcanal = 3;

/*
 1 - Viacredi
11 - Credifoz 
 7 - Credcrea 
 */

--> 2 - Acrediccop
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper in (1,7) -- 1 - Viacredi, 7 - Credcrea 
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 60000
 where s.cdcooper = in (1,7) -- 1 - Viacredi, 7 - Credcrea 
   and s.idsegmento = 2
   and s.cdcanal = 3; 

--> 11 - Credifoz
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 20000
 where s.cdcooper = 11 -- Credifoz
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 20000
 where s.cdcooper = 11 -- Credifoz
   and s.idsegmento = 2
   and s.cdcanal = 3;       

update crapprm p
   set p.dsvlrprm = p.dsvlrprm ||';1;11;7'
 where p.cdacesso = 'LIBERA_COOP_SIMULA_IB';  

Commit; 
        
