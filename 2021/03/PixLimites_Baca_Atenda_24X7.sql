begin

	update craptel 
	   set inacesso = 2
	 where nmdatela = 'ATENDA'
	   and nmrotina in(' ','INTERNET','REVISAO_CADASTRAL');
	   
	update craptel 
	   set inacesso = 1
	 where nmdatela = 'ATENDA'
	   and nmrotina not in(' ','INTERNET','REVISAO_CADASTRAL');   

    COMMIT;
	
END;
