BEGIN
    UPDATE cecred.parametromobile SET valor = '2.57.0' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.57.0' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;