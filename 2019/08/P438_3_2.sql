/*
 8 - Credelesc
14 - Evolua
 2 - Acrediccop 
13 - Civia
 5 - Acentra */


--> 13 - Civia
--> 14 - Evolua
update tbepr_subsegmento s
   set s.cdlinha_credito = 1105
 where s.cdcooper in(13,14)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 2105
 where s.cdcooper in(13,14)
   and s.idsegmento = 2;   
   
--> 2 - Acrediccop
--> 5 - Acentra 
--> 8 - Credelesc
update tbepr_subsegmento s
   set s.cdlinha_credito = 7081
 where s.cdcooper in (2,5,8)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 7080
 where s.cdcooper in (2,5,8)
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

 where seg.cdcooper in (2,5,8,13,14)
   and seg.idsegmento in (1,2);

 
update tbepr_segmento_canais_perm s
   set s.tppermissao = 2
 where s.cdcooper in (2,5,8,13,14) 
   and s.cdcanal = 3;

/*
 2 - Acrediccop 
 5 - Acentra
 7 - Credcrea 
 8 - Credelesc
13 - Civia
14 - Evolua
 */

--> 2 - Acrediccop
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 20000
 where s.cdcooper = 2 -- Acrediccop
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 2 -- Acrediccop
   and s.idsegmento = 2
   and s.cdcanal = 3; 

--> 5 - Acentra
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 25000
 where s.cdcooper = 5 -- Acentra
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 5 -- Acentra
   and s.idsegmento = 2
   and s.cdcanal = 3;      

--> 7 - Credcrea
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 7 -- Credcrea
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 60000
 where s.cdcooper = 7 -- Credcrea
   and s.idsegmento = 2
   and s.cdcanal = 3;

--> 8 - Credelesc
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 10000
 where s.cdcooper = 8 -- Credelesc
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 20000
 where s.cdcooper = 8 -- Credelesc
   and s.idsegmento = 2
   and s.cdcanal = 3;  
          
--> 13 - Civia
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 20000
 where s.cdcooper = 13 -- Civia
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 13 -- Civia
   and s.idsegmento = 2
   and s.cdcanal = 3;
   
--> 14 - Evolua
update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 14 -- Evolua
   and s.idsegmento = 1
   and s.cdcanal = 3;

update tbepr_segmento_canais_perm s
   set s.vlmax_autorizado = 30000
 where s.cdcooper = 14 -- Evolua
   and s.idsegmento = 2
   and s.cdcanal = 3;   

update crapprm p
   set p.dsvlrprm = p.dsvlrprm ||';2;5;8;13;14'
 where p.cdacesso = 'LIBERA_COOP_SIMULA_IB';  

Commit; 
        
