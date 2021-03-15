begin
  UPDATE crapbpr        bpr
  SET    bpr.flgbaixa = 0
        ,bpr.cdsitgrv = 4
        ,bpr.flginclu = 0
  WHERE  bpr.cdcooper = 14
  AND    bpr.nrdconta = 4766
  AND    bpr.tpctrpro = 90
  AND    bpr.nrctrpro = 188
  AND    bpr.flgalien = 1;
  commit;
end;


