BEGIN
    UPDATE cecred.parametromobile SET valor = '2.56.1' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid';
    UPDATE cecred.parametromobile SET valor = '2.56.0' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.56.1' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;