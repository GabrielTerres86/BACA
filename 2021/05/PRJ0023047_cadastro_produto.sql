insert into crapind (CDDINDEX, NMDINDEX, IDPERIOD, IDCADAST, IDEXPRES, PROGRESS_RECID)
values (6, 'POUPANCA', 1, 1, 1, NULL);

insert into crapcpc (CDPRODUT, NMPRODUT, IDSITPRO, CDDINDEX, IDTIPPRO, IDTXFIXA, IDACUMUL, CDHSCACC, CDHSVRCC, CDHSRAAP, CDHSNRAP, CDHSPRAP, CDHSRVAP, CDHSRDAP, CDHSIRAP, CDHSRGAP, CDHSVTAP, PROGRESS_RECID, INDPLANO, CDHSRNAP, INDANIVE)
values (1109, 'POUPANCA', 1, 6, 2, 2, 2, 3526, 3529, 3527, 3527, 3530, 3531, 3532, 3332, 3528, 3528, NULL, 0, 3331, 1);

insert into CRAPNPC (CDPRODUT, CDNOMENC, DSNOMENC, IDSITNOM, QTMINCAR, QTMAXCAR, VLMINAPL, VLMAXAPL, PROGRESS_RECID)
values (1109, 552, 'POUPANCA', 1, 30, 90, 1.00, 999999999.00, null);

insert into crapmpc (CDPRODUT, CDMODALI, QTDIACAR, QTDIAPRZ, VLRFAIXA, VLPERREN, VLTXFIXA, PROGRESS_RECID)
values (1109, null, 30, 9999, 1.00, 0.000001, 0.000000, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (1, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (2, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (5, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (6, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (7, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (8, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (9, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (10, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (11, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (12, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (13, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (14, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

insert into crapdpc (CDCOOPER, CDMODALI, IDSITMOD, PROGRESS_RECID)
values (16, (select CDMODALI from crapmpc where CDPRODUT = 1109), 1, null);

commit;
