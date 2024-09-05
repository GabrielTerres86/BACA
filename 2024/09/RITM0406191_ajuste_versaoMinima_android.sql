BEGIN
    UPDATE cecred.parametromobile SET valor = '2.63.0' WHERE parametromobileid = 26 AND nome = 'VersaoMinimaAndroid'; 
    COMMIT;
END;