
insert into crapind (CDDINDEX, NMDINDEX, IDPERIOD, IDCADAST, IDEXPRES, PROGRESS_RECID)
values (5, 'IPCA NUMERICO', 2, 1, 1, null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-12-2019', 'dd-mm-yyyy'), to_date('01-12-2019', 'dd-mm-yyyy'), 5320.25000000, to_date('29-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-01-2020', 'dd-mm-yyyy'), to_date('01-01-2020', 'dd-mm-yyyy'), 5331.42000000, to_date('14-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-02-2020', 'dd-mm-yyyy'), to_date('01-02-2020', 'dd-mm-yyyy'), 5344.75000000, to_date('14-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-03-2020', 'dd-mm-yyyy'), to_date('01-03-2020', 'dd-mm-yyyy'), 5348.49000000, to_date('14-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-04-2020', 'dd-mm-yyyy'), to_date('01-04-2020', 'dd-mm-yyyy'), 5331.91000000, to_date('14-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-05-2020', 'dd-mm-yyyy'), to_date('01-05-2020', 'dd-mm-yyyy'), 5311.65000000, to_date('15-09-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-06-2020', 'dd-mm-yyyy'), to_date('01-06-2020', 'dd-mm-yyyy'), 5325.46000000, to_date('15-06-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-07-2020', 'dd-mm-yyyy'), to_date('01-07-2020', 'dd-mm-yyyy'), 5344.63000000, to_date('15-07-2020', 'dd-mm-yyyy'), null);

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (5, to_date('01-08-2020', 'dd-mm-yyyy'), to_date('01-08-2020', 'dd-mm-yyyy'), 5357.46000000, to_date('15-08-2020', 'dd-mm-yyyy'), null);


insert into crapprg ( 
select 'CRED' nmsistem
      ,'CRPS795' cdprogra
      ,'Gera relatorio mensal de produtos de captacao PCAPTA' DSPROGRA##1
      ,'.' DSPROGRA##2
      ,'.' DSPROGRA##3
      ,'.' DSPROGRA##4
      ,999 NRSOLICI
      ,1215 NRORDPRG
      ,1 INCTRPRG
      ,823 CDRELATO##1
      ,0 CDRELATO##2
      ,0 CDRELATO##3
      ,0 CDRELATO##4
      ,0 CDRELATO##5
      ,1 INLIBPRG
      ,cdcooper
      ,null progress_recid
      ,null qtminmed
from crapcop
where flgativo = 1
);

commit;