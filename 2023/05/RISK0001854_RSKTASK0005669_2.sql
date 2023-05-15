BEGIN
    UPDATE cecred.parametromobile SET valor = '2.53.6' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.53.6' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    COMMIT;
END;