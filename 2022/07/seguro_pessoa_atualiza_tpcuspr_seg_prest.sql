begin
	UPDATE cecred.craplcr a
	   SET a.tpcuspr = 1
	 WHERE a.flgsegpr = 0 
	   AND a.tpcuspr = 0;
  commit;
end;
/
