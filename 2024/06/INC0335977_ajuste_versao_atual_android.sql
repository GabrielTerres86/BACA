BEGIN
    UPDATE cecred.parametromobile SET valor = '2.61.4' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid'; 
    COMMIT;
END;