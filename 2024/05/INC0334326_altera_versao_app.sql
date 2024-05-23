BEGIN
    UPDATE cecred.parametromobile SET valor = '2.61.1' WHERE parametromobileid = 39 AND nome = 'VersaoAtualiOS';
    COMMIT;
END;