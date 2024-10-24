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
  & pr_dtmvtolt, 
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
  cdcooper = & pr_cdcooper 
  AND cdagenci = & pr_cdagenci 
  AND cdopecxa = & pr_cdopecxa 
  AND nrdcaixa = & pr_nrdcaixa 
  AND dtmvtolt = (
    SELECT 
      MAX(dtmvtolt) 
    FROM 
      crapbcx 
    WHERE 
      cdcooper = & pr_cdcooper 
      AND cdagenci = & pr_cdagenci 
      AND cdopecxa = & pr_cdopecxa 
      AND nrdcaixa = & pr_nrdcaixa
  );
  COMMIT;
END;