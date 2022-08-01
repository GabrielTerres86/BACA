begin
	UPDATE craplcr
	   SET tpcuspr = 1
	 WHERE flgsegpr = 0 
	   AND tpcuspr = 0;
  commit;
end;
/
