/*
* Viacredi
* CNPJ: 10222398000164
* Proposta: 3532829
* Conta: 1025350-5
* Contrato: 1599183

select e.flgdocdg 
from crawepr e 
where e.cdcooper = 1 
and e.nrdconta = 10253505 
and e.nrctremp = 1599183;

Rollback:

update crawepr e 
set e.flgdocdg = 0
where e.cdcooper = 1 
and e.nrdconta = 10253505 
and e.nrctremp = 1599183;

*/


update crawepr e 
set e.flgdocdg = 1
where e.cdcooper = 1 
and e.nrdconta = 10253505 
and e.nrctremp = 1599183;


commit;
