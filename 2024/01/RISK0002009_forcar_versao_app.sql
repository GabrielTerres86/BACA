BEGIN
    UPDATE cecred.parametromobile SET valor = '2.57.0' WHERE parametromobileid = 25 AND nome = 'VersaoMinimaiOS';
    UPDATE cecred.parametromobile SET valor = '2.57.0' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid';
    COMMIT;
END;