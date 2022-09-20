begin
update credito.tbcred_unidade_recebivel_cerc t
   set t.inprocesso = 1,
       t.cdcooperativa = 2,
       t.nrconta_corrente = 84651504,
       t.nrcontrato = 5698974 
where t.cdhash_recebiveis in ('82413081000116734576910001207345769100012025042025VCC','82413081000116734576910001207345769100012004082025VCC');

update credito.tbcred_unidade_recebivel_cerc t
   set t.inprocesso = 1,
       t.cdcooperativa = 2,
       t.nrconta_corrente = 84651504,
       t.nrcontrato = 3256786
where t.cdhash_recebiveis in ('82413081000116734576910001207345769100012030062024VCC','82413081000116734576910001207345769100012007062026VCC','82413081000116734576910001207345769100012021062026VCC');

update credito.tbcred_unidade_recebivel_cerc t
   set t.inprocesso = 1,
       t.cdcooperativa = 2,
       t.nrconta_corrente = 84651504,
       t.nrcontrato = 4789564 
where t.cdhash_recebiveis in ('82413081000116734576910001207345769100012004042024VCC','82413081000116734576910001207345769100012025062025VCC','82413081000116734576910001207345769100012023122025VCC');
commit;
end;
