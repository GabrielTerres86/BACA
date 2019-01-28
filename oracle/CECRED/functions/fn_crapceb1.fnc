create or replace function fn_crapceb1(pr_cdcooper IN crapceb.cdcooper%TYPE
                                      ,pr_nrdconta IN crapceb.nrdconta%TYPE
                                      ,pr_nrconven IN crapceb.nrconven%TYPE
																			) return number is
  --
	Result number;
	--
BEGIN
	--
	SELECT MAX(idrecipr)
	  INTO RESULT
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
		 
  return(Result);
end fn_crapceb1;
/
