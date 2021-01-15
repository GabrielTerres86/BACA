BEGIN
--Credcrea > Conta 227870 > Contrato 29924
--Credcrea > Conta 24139 > contrato 27269  
  UPDATE crappep t
    SET inliquid = 1
      , vlmrapar = 0
      , vlsdvpar = 0
      , vlsdvatu = 0
      , vlsdvsji = 0
      , vljura60 = 0
      , vlmtapar = 0
      , vlpagpar = vlparepr
  WHERE cdcooper = 7
    AND (t.nrdconta, t.nrctremp, t.nrparepr) IN ((227870,29924, 8), (24139, 27269, 13));

  COMMIT;
END;
