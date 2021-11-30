BEGIN
	delete 
	from crapavt
	where cdcooper = 1
	and nrdconta = 13842080;
    
    COMMIT;
END;
