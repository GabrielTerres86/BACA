
begin
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',1);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',2);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',3);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',5);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',6);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',7);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',8);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',9);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',10);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',11);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',12);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',13);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',14);
    insert into cecred.craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) values ('CRED', 'GENERI',0,'FORMCONTINUO',0,'1500',16);
end;


select * from crapcop where flgativo = 1;

select *
  from craptab
 where /* craptab.cdcooper = 1
   AND */ craptab.nmsistem = 'CRED'
   AND craptab.tptabela = 'GENERI'
   AND craptab.cdempres = 0
   AND craptab.cdacesso = 'FORMCONTINUO'
   AND craptab.tpregist = 0;

select *  from craptab where tptabela = 'COMPBB';

select *
  from craptab
 where craptab.cdcooper = 1
   AND craptab.nmsistem = 'CRED'
   AND craptab.tptabela = 'GENERI'
   AND craptab.cdempres = 0
   AND craptab.cdacesso = 'VALORESVLB'
   AND craptab.tpregist = 0;
