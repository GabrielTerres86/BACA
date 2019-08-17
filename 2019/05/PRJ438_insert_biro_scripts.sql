/*Cadastro do birô*/
insert into crapbir values ((select max(cdbircon)+1 from crapbir),'BV Score','BVSSCORE');

/*Cadastro modalidades birô*/
insert into crapmbr values (4,1,'BV Score PF',1,'PF12M',1);
insert into crapmbr values (4,2,'BV Score PJ',2,'PJ12M',1);