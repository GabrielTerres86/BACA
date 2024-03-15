begin
	UPDATE cecred.crappep
	   SET inliquid = 1
	 WHERE cdcooper = 13 
	   AND nrdconta = 99874954
	   and nrctremp = 240184
	   and nrparepr in (12, 13,14, 15,16, 17);
	commit;
end;