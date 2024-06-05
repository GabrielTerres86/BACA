BEGIN    
	UPDATE cecred.parametromobile SET valor = '2.61.3' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.61.3' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    COMMIT;
END;