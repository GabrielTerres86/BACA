BEGIN
	INSERT INTO cecred.crapbcx
	  (cdagenci
	  ,cdopecxa
	  ,dtmvtolt
	  ,cdsitbcx
	  ,nrdcaixa
	  ,nrdlacre
	  ,nrdmaqui
	  ,qtautent
	  ,vldsdfin
	  ,vldsdini
	  ,nrseqdig
	  ,hrabtbcx
	  ,hrfecbcx
	  ,qtcompln
	  ,nrsequni
	  ,vlmaxcbb
	  ,flgauten
	  ,cdcooper
	  ,ipmaqcxa
	  ,qtchqprv
	  ,hrultsgr
	  ,flgcxsgr)
	  SELECT bcx.cdagenci
			,bcx.cdopecxa
			,'22/01/2024' dtmvtolt
			,1 cdsitbcx
			,bcx.nrdcaixa
			,bcx.nrdlacre
			,bcx.nrdmaqui
			,bcx.qtautent
			,bcx.vldsdfin
			,bcx.vldsdini
			,bcx.nrseqdig
			,bcx.hrabtbcx
			,bcx.hrfecbcx
			,bcx.qtcompln
			,bcx.nrsequni
			,bcx.vlmaxcbb
			,bcx.flgauten
			,bcx.cdcooper
			,bcx.ipmaqcxa
			,bcx.qtchqprv
			,bcx.hrultsgr
			,bcx.flgcxsgr
		FROM cecred.crapbcx bcx
	   WHERE cdcooper = 1
		 AND cdagenci = 90
		 AND cdopecxa = 996
		 AND nrdcaixa = 900
		 AND dtmvtolt = (SELECT MAX(dtmvtolt)
						   FROM cecred.crapbcx
						  WHERE cdcooper = 1
							AND cdagenci = 90
							AND cdopecxa = 996
							AND nrdcaixa = 900);
							
	INSERT INTO cecred.crapbcx
	  (cdagenci
	  ,cdopecxa
	  ,dtmvtolt
	  ,cdsitbcx
	  ,nrdcaixa
	  ,nrdlacre
	  ,nrdmaqui
	  ,qtautent
	  ,vldsdfin
	  ,vldsdini
	  ,nrseqdig
	  ,hrabtbcx
	  ,hrfecbcx
	  ,qtcompln
	  ,nrsequni
	  ,vlmaxcbb
	  ,flgauten
	  ,cdcooper
	  ,ipmaqcxa
	  ,qtchqprv
	  ,hrultsgr
	  ,flgcxsgr)
	  SELECT bcx.cdagenci
			,bcx.cdopecxa
			,'23/01/2024' dtmvtolt
			,1 cdsitbcx
			,bcx.nrdcaixa
			,bcx.nrdlacre
			,bcx.nrdmaqui
			,bcx.qtautent
			,bcx.vldsdfin
			,bcx.vldsdini
			,bcx.nrseqdig
			,bcx.hrabtbcx
			,bcx.hrfecbcx
			,bcx.qtcompln
			,bcx.nrsequni
			,bcx.vlmaxcbb
			,bcx.flgauten
			,bcx.cdcooper
			,bcx.ipmaqcxa
			,bcx.qtchqprv
			,bcx.hrultsgr
			,bcx.flgcxsgr
		FROM cecred.crapbcx bcx
	   WHERE cdcooper = 1
		 AND cdagenci = 90
		 AND cdopecxa = 996
		 AND nrdcaixa = 900
		 AND dtmvtolt = (SELECT MAX(dtmvtolt)
						   FROM cecred.crapbcx
						  WHERE cdcooper = 1
							AND cdagenci = 90
							AND cdopecxa = 996
							AND nrdcaixa = 900);
							
	INSERT INTO cecred.crapbcx
	  (cdagenci
	  ,cdopecxa
	  ,dtmvtolt
	  ,cdsitbcx
	  ,nrdcaixa
	  ,nrdlacre
	  ,nrdmaqui
	  ,qtautent
	  ,vldsdfin
	  ,vldsdini
	  ,nrseqdig
	  ,hrabtbcx
	  ,hrfecbcx
	  ,qtcompln
	  ,nrsequni
	  ,vlmaxcbb
	  ,flgauten
	  ,cdcooper
	  ,ipmaqcxa
	  ,qtchqprv
	  ,hrultsgr
	  ,flgcxsgr)
	  SELECT bcx.cdagenci
			,bcx.cdopecxa
			,'23/01/2024' dtmvtolt
			,1 cdsitbcx
			,bcx.nrdcaixa
			,bcx.nrdlacre
			,bcx.nrdmaqui
			,bcx.qtautent
			,bcx.vldsdfin
			,bcx.vldsdini
			,bcx.nrseqdig
			,bcx.hrabtbcx
			,bcx.hrfecbcx
			,bcx.qtcompln
			,bcx.nrsequni
			,bcx.vlmaxcbb
			,bcx.flgauten
			,bcx.cdcooper
			,bcx.ipmaqcxa
			,bcx.qtchqprv
			,bcx.hrultsgr
			,bcx.flgcxsgr
		FROM cecred.crapbcx bcx
	   WHERE cdcooper = 1
		 AND cdagenci = 91
		 AND cdopecxa = 996
		 AND nrdcaixa = 900
		 AND dtmvtolt = (SELECT MAX(dtmvtolt)
						   FROM cecred.crapbcx
						  WHERE cdcooper = 1
							AND cdagenci = 91
							AND cdopecxa = 996
							AND nrdcaixa = 900);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;						