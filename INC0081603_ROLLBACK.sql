begin
  UPDATE crapbpr        bpr
  SET    bpr.flgbaixa = 1
        ,bpr.cdsitgrv = 1
        ,bpr.flginclu = 0
  WHERE  bpr.cdcooper = 14
  AND    bpr.nrdconta = 4766
  AND    bpr.tpctrpro = 90
  AND    bpr.nrctrpro = 188
  AND    bpr.flgalien = 1;
  commit;
exception
  when others then
    null;   
end;
