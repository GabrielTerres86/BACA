begin
  UPDATE crapbpr        bpr
  SET    bpr.flgbaixa = 0
        ,bpr.cdsitgrv = 4
        ,bpr.flginclu = 0
  WHERE  bpr.cdcooper = 13
  AND    bpr.nrdconta = 402745
  AND    bpr.tpctrpro = 90
  AND    bpr.nrctrpro = 1322
  AND    bpr.idseqbem = 1;
  commit;
end;
