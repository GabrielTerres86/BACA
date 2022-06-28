begin

update cecred.crapfdc fdc
  set fdc.incheque = 8,
      fdc.dtemschq = trunc(sysdate),
      fdc.dtretchq = trunc(sysdate),
      fdc.dtliqchq = trunc(sysdate)
where  fdc.cdcooper = 13
  and  fdc.nrdconta = 705772
  and  fdc.incheque = 0
  and  fdc.nrcheque in (461
                       ,462
                       ,463
                       ,464
                       ,465
                       ,466
                       ,467
                       ,468
                       ,469
                       ,470
                       ,471
                       ,472
                       ,473
                       ,474
                       ,475 
                       ,476
                       ,477
                       ,478
                       ,479
                       ,480);

commit;
end;
