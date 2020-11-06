INSERT INTO tbepr_renegociacao_craplem
  (NRVERSAO, DTMVTOLT,
   CDAGENCI, CDBCCXLT,
   NRDOLOTE, NRDCONTA,
   NRDOCMTO, CDHISTOR,
   NRSEQDIG, NRCTREMP,
   VLLANMTO, 
   DTPAGEMP,
   TXJUREPR, VLPREEMP,
   NRAUTDOC, NRSEQUNI,
   CDCOOPER, NRPAREPR,
   NRSEQAVA, DTESTORN,
   CDORIGEM, DTHRTRAN,
   QTDIACAL, VLTAXPER,
   VLTAXPRD)
VALUES
  (1,       to_date('30-09-2020', 'dd-mm-yyyy'),
   50,      100,
   600009,  10266089,
   3,       2346,
   5,       2600190,
   4.68,    -- Valor da diferenca
   to_date('30-09-2020', 'dd-mm-yyyy'),
   0.0000000, 0.00,
   0,         0,
   1,         0,
   0,         NULL,
   7,         to_date('30-09-2020 16:58:36', 'dd-mm-yyyy hh24:mi:ss'),
   0,         0.00000000,
   0.00000000);
commit;