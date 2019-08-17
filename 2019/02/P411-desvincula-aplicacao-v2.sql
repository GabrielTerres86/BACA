

update craprac set idsaqtot = 1 where cdcooper = 1 and nrdconta = 9439293 and nraplica = 6;
update craprac set idsaqtot = 1 where cdcooper = 1 and nrdconta = 8376670 and nraplica = 8;
update craprac set idsaqtot = 1 where cdcooper = 1 and nrdconta = 3719782 and nraplica = 11;

update tbcapt_custodia_aplicacao set tpaplicacao = 9 where idaplicacao in (2677846, 2650263, 2649190);

commit;
