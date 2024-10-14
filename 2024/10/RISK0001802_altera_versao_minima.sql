BEGIN
    UPDATE cecred.parametromobile SET valor = '2.63.4' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    UPDATE cecred.parametromobile SET valor = '2.63.4' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid';
    COMMIT;
END;