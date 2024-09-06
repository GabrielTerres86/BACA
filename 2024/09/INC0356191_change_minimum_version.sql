BEGIN
    UPDATE cecred.parametromobile SET valor = '2.63.0' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    UPDATE cecred.parametromobile SET valor = '2.63.0' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    COMMIT;
END;