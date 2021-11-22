begin

/* Preparar propostas para teste - rotina atual */

update crawcrd a
set a.insitcrd = 2,
    a.dtrejeit = null,
    a.dtlibera = null,
    a.dtentreg = null,
    a.nrcrcard = 0,
    a.nrcctitg = 0
where a.nrdconta in (13651269,13628623,13650122,13651625)
and a.cdcooper = 1
and (a.nrcrcard = 0 or a.nrcrcard = 111111 or a.nrcrcard in (5161620003334785,5161620003335048,5127070391650140));

delete from tbcrd_conta_cartao a
where a.nrdconta in (13651269,13628623,13650122,13651625)
and a.cdcooper = 1
and a.nrconta_cartao in (7563239837927,7563239838184,7563239838171);

delete from crapcrd a
where a.nrdconta in (13651269,13628623,13650122,13651625)
and a.cdcooper = 1
and a.nrcrcard in (5161620003334785,5161620003335048,5127070391650140);

/* Preparar propostas para teste - rotina nova */

update crawcrd a
set a.insitcrd = 2,
    a.dtrejeit = null,
    a.dtlibera = null,
    a.dtentreg = null,
    a.nrcrcard = 0,
    a.nrcctitg = 0
where a.nrdconta in (13651390,13627805,8374856,13652540)
and a.cdcooper = 1
and (a.nrcrcard = 0 or a.nrcrcard = 111111 or a.nrcrcard in (6393500222232069,5161620003334652,5127070391720059));

delete from tbcrd_conta_cartao a
where a.nrdconta in (13651390,13627805,8374856,13652540)
and a.cdcooper = 1
and a.nrconta_cartao in (7563239838186,7563239838170,7563239837987);

delete from crapcrd a
where a.nrdconta in (13651390,13627805,8374856,13652540)
and a.cdcooper = 1
and a.nrcrcard in (6393500222232069,5161620003334652,5127070391720059);

commit;

end;