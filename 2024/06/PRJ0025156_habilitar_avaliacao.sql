BEGIN
    UPDATE cecred.parametromobile SET valor = '1' WHERE parametromobileid = 58 AND nome = 'AvaliacaoHabilitada';
    UPDATE cecred.parametromobile SET valor = '200' WHERE parametromobileid = 55 AND nome = 'AvaliacaoLimiteDiario';
    update cecred.menumobile set flavaliacao = 1 where menumobileid = 200 and menupaiid = 30;
    update cecred.menumobile set flavaliacao = 1 where menumobileid = 700 and menupaiid = 701 and versaominimaapp = '2.0.0.0';
    update cecred.menumobile set flavaliacao = 1 where menumobileid = 804 and menupaiid = 30;
    update cecred.menumobile set flavaliacao = 1 where menumobileid = 1011 and menupaiid = 1009;
    COMMIT;
END;