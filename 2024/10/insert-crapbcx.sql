BEGIN
INSERT INTO crapbcx (
  cdagenci, cdopecxa, dtmvtolt, cdsitbcx, 
  nrdcaixa, nrdlacre, nrdmaqui, qtautent, 
  vldsdfin, vldsdini, nrseqdig, hrabtbcx, 
  hrfecbcx, qtcompln, nrsequni, vlmaxcbb, 
  flgauten, cdcooper, ipmaqcxa, qtchqprv, 
  hrultsgr, flgcxsgr
)
SELECT 
  bcx.cdagenci, 
  bcx.cdopecxa, 
  '24/10/2024', 
  1, 
  bcx.nrdcaixa, 
  bcx.nrdlacre, 
  bcx.nrdmaqui, 
  bcx.qtautent, 
  bcx.vldsdfin, 
  bcx.vldsdini, 
  bcx.nrseqdig, 
  bcx.hrabtbcx, 
  bcx.hrfecbcx, 
  bcx.qtcompln, 
  bcx.nrsequni, 
  bcx.vlmaxcbb, 
  bcx.flgauten, 
  bcx.cdcooper, 
  bcx.ipmaqcxa, 
  bcx.qtchqprv, 
  bcx.hrultsgr, 
  bcx.flgcxsgr 
FROM 
  crapbcx bcx 
WHERE 
  cdcooper = 9 
  AND cdagenci = 90 
  AND cdopecxa = 996 
  AND nrdcaixa = 900 
  AND dtmvtolt = (
    SELECT 
      MAX(dtmvtolt) 
    FROM 
      crapbcx 
    WHERE 
      cdcooper = 9 
      AND cdagenci = 90 
      AND cdopecxa = 996 
      AND nrdcaixa = 900
  );
  COMMIT;
END;