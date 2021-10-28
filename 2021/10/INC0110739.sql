BEGIN
	delete 
	from crapavt
	where cdcooper = 1
	and nrdconta = 13638092;
    
    COMMIT;
END;
