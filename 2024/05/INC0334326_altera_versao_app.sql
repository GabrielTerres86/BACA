BEGIN
    UPDATE cecred.parametromobile SET valor = '2.61.1' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.61.1' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    UPDATE cecred.parametromobile SET valor = '2.61.1' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid';
    COMMIT;
END;