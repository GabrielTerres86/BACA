CREATE OR REPLACE FUNCTION cecred.fn_idrecipr(pr_cdcooper IN crapceb.cdcooper%TYPE
																						 ,pr_nrdconta IN crapceb.nrdconta%TYPE
																						 ,pr_nrconven IN crapceb.nrconven%TYPE
																						 ) RETURN NUMBER IS
  --
	vr_idrecipr NUMBER;
	--
BEGIN
	--
	SELECT MAX(idrecipr)
	  INTO vr_idrecipr
		FROM( SELECT MAX(ceb.idrecipr) idrecipr
						FROM crapceb ceb
					 WHERE ceb.cdcooper = pr_cdcooper
						 AND ceb.nrconven = pr_nrconven
						 AND ceb.nrdconta = pr_nrdconta
					 UNION ALL
					SELECT MAX(ceb.idrecipr) idrecipr
						FROM tbcobran_crapceb ceb
					 WHERE ceb.cdcooper = pr_cdcooper
						 AND ceb.nrconven = pr_nrconven
						 AND ceb.nrdconta = pr_nrdconta
						 );
	--
  RETURN(vr_idrecipr);
	--
END fn_idrecipr;
/
