--script de ajuste
update crapris a
   set a.dtdrisco = to_date('31/07/2021','dd/mm/yyyy')
 where a.dtdrisco in to_date('19/08/2021','dd/mm/yyyy')
   and a.cdagenci = 28
   and a.cdcooper = 9
   and a.cdmodali IN (299,499)
   and (a.cdcooper, a.nrdconta, a.nrctremp) in (
        select r.cdcooper, r.nrdconta, r.nrctremp
          from tbrating_historicos h, crapass a, crapris r
         where a.cdcooper = h.cdcooper
           and a.nrdconta = h.nrdconta
           and h.cdcooper = r.cdcooper
           and h.nrdconta = r.nrdconta
           and h.nrctremp = r.nrctremp
           and r.cdmodali IN (299,499)
           and a.cdcooper = 9
           and a.cdagenci = 28
           and h.ds_justificativa like 'Incorpora%'
   )
;

update crapris a
   set a.dtdrisco = to_date('10/08/2021','dd/mm/yyyy')
 where a.dtdrisco in to_date('28/08/2021','dd/mm/yyyy')
   and a.cdagenci = 28
   and a.cdcooper = 9
   and a.cdmodali IN (299,499)
   and (a.cdcooper, a.nrdconta, a.nrctremp) in (
        select r.cdcooper, r.nrdconta, r.nrctremp
          from tbrating_historicos h, crapass a, crapris r
         where a.cdcooper = h.cdcooper
           and a.nrdconta = h.nrdconta
           and h.cdcooper = r.cdcooper
           and h.nrdconta = r.nrdconta
           and h.nrctremp = r.nrctremp
           and r.cdmodali IN (299,499)
           and a.cdcooper = 9
           and a.cdagenci = 28
           and h.ds_justificativa like 'Incorpora%'
   )
;

COMMIT;
