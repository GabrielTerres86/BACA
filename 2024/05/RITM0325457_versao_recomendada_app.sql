BEGIN
    UPDATE cecred.parametromobile SET valor = '2.61.0' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.61.1' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;