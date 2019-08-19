prompt RDM0031027

set feedback off
set define off



update crawepr wepr
   set wepr.nrctremp = 31133
 where wepr.nrctremp = 41576
   and wepr.nrdconta = 31356
   and wepr.cdcooper = 13;

update crapprp prp
   set prp.nrctrato = 31133
 where prp.nrctrato = 41576
   and prp.nrdconta = 31356
   and prp.cdcooper = 13;


update crapbpr bpr
   set bpr.nrctrpro = 31133
 where bpr.nrctrpro = 41576
   and bpr.nrdconta = 31356
   and bpr.cdcooper = 13;


update crappep pep
   set pep.nrctremp = 31133
 where pep.nrctremp = 41576
   and pep.nrdconta = 31356
   and pep.cdcooper = 13;


commit;

prompt Done.
