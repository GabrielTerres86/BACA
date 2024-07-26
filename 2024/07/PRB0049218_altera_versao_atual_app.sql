BEGIN
    UPDATE cecred.parametromobile SET valor = '2.62.3' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;