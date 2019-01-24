CREATE OR REPLACE FUNCTION cecred.fn_sit_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
																								,pr_nrdconta IN crapceb.nrdconta%TYPE
																								,pr_nrconven IN crapceb.nrconven%TYPE
																								) RETURN NUMBER IS
  --
  vr_situacao number;
  --
BEGIN
  --
	SELECT SUM(qtregis)
	  INTO vr_situacao
		FROM( SELECT COUNT(1) qtregis
						FROM crapceb ceb2
					 WHERE ceb2.cdcooper = pr_cdcooper
						 AND ceb2.nrdconta = pr_nrdconta
						 AND ceb2.insitceb = 1
						 AND ceb2.nrconven = pr_nrconven
						 AND ceb2.idrecipr = idrecipr
					 UNION
					SELECT COUNT(1) qtregis
						FROM tbcobran_crapceb ceb2
					 WHERE ceb2.cdcooper = pr_cdcooper
						 AND ceb2.nrdconta = pr_nrdconta
						 AND ceb2.insitceb = 1
						 AND ceb2.nrconven = pr_nrconven
						 AND ceb2.idrecipr = idrecipr);
	--
  RETURN(vr_situacao);
END fn_sit_crapceb;
