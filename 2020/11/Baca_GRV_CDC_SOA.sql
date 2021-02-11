-- 24 registros
 update crapbpr b
    set b.cdsitgrv = 0
    where b.rowid in (
 select b.rowid--, w.*--, s.dhoperacao,
   from crapbpr b
       ,crawepr w
       ,tbgen_evento_soa s 
  where /*w.dtmvtolt between ('16/11/2020') and ('20/11/2020')
    and */w.cdfinemp = 59
    and b.cdcooper = w.cdcooper
    and b.nrdconta = w.nrdconta
    and b.nrctrpro = w.nrctremp
    and b.flgalien = 1
    and b.cdsitgrv = 1
    and s.cdcooper = w.cdcooper
    and s.nrdconta = w.nrdconta
    and s.nrctrprp = w.nrctremp
    and s.tpevento = 'REGISTRO_GRAVAME'
    ); 
    
    commit;
