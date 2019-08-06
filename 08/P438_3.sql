
--> 6 -- UNILOS
update tbepr_subsegmento s
   set s.cdlinha_credito = 1105
 where s.cdcooper in(6,9)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 2105
 where s.cdcooper in(6,9)
   and s.idsegmento = 2;   
   
--> 10 -- CREDICOMIN 
--> 12 -- CREVISC
update tbepr_subsegmento s
   set s.cdlinha_credito = 7081
 where s.cdcooper in (10,12)
   and s.idsegmento = 1;  
   
update tbepr_subsegmento s
   set s.cdlinha_credito = 7080
 where s.cdcooper in (10,12)
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

 where seg.cdcooper in in (6,9,10,12,16)
   and seg.idsegmento in (1,2);

 
update tbepr_segmento_canais_perm s
   set s.tppermissao = 2
 where s.cdcooper in (6,9,10,12) 
   and s.cdcanal = 3;

update crapprm p
   set p.dsvlrprm = p.dsvlrprm ||';6;9;10;12'
 where p.cdacesso = 'LIBERA_COOP_SIMULA_IB';  

Commit; 
        
