BEGIN
    UPDATE cecred.parametromobile SET valor = '2.63.0' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid'; 
    COMMIT;
END;