BEGIN
    UPDATE cecred.parametromobile SET valor = '2.62.2' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    UPDATE cecred.parametromobile SET valor = '2.62.2' WHERE parametromobileid = 40 AND nome = 'VersaoAtualAndroid';
    UPDATE cecred.parametromobile SET valor = '6200' WHERE parametromobileid = 56 AND nome = 'AvaliacaoLimiteMensal';
    COMMIT;
END;