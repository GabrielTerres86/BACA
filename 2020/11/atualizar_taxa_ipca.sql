--Inserindo taxa IPCA para o mes de outubro
delete from craptxi i 
 where i.dtiniper = '01/11/2020'
   and i.cddindex = 5;

insert into craptxi (CDDINDEX, DTINIPER, DTFIMPER, VLRDTAXA, DTCADAST, PROGRESS_RECID)
values (4, to_date('01-10-2020', 'dd-mm-yyyy'), to_date('01-10-2020', 'dd-mm-yyyy'), 0.86000000, to_date(sysdate, 'dd-mm-yyyy'), null);

update craptxi x
   set x.vlrdtaxa = 5438.12,
       X.dtcadast = to_date(sysdate, 'dd-mm-yyyy')
 where x.cddindex = 5
   and x.dtiniper = '01/10/2020';

COMMIT;   
