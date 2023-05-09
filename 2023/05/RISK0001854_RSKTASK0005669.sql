BEGIN
    UPDATE cecred.parametromobile SET valor = '2.53.6' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    UPDATE cecred.parametromobile SET valor = '2.53.6' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid';
    UPDATE cecred.parametromobile SET valor = '2.54.0' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.54.0' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;